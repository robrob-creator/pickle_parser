#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Show usage information')
    ..addFlag('validate', abbr: 'v', help: 'Validate feature files')
    ..addFlag('generate',
        abbr: 'g', help: 'Generate test skeleton from feature files')
    ..addOption('input',
        abbr: 'i',
        help: 'Input directory containing .feature files',
        defaultsTo: 'assets/features')
    ..addOption('output',
        abbr: 'o',
        help: 'Output directory for generated tests',
        defaultsTo: 'test/generated')
    ..addFlag('verbose', help: 'Show detailed output');

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool || arguments.isEmpty) {
      print('Pickle Parser CLI - Tools for managing Gherkin feature files\n');
      print('Usage: pickle_parser [options]\n');
      print(parser.usage);
      print('\nExamples:');
      print('  pickle_parser --validate');
      print(
          '  pickle_parser --generate --input assets/features --output test/generated');
      print('  pickle_parser --validate --verbose');
      exit(0);
    }

    final inputDir = results['input'] as String;
    final outputDir = results['output'] as String;
    final verbose = results['verbose'] as bool;

    if (results['validate'] as bool) {
      await validateFeatureFiles(inputDir, verbose);
    }

    if (results['generate'] as bool) {
      await generateTestSkeletons(inputDir, outputDir, verbose);
    }
  } catch (e) {
    print('Error: $e');
    print('\nUse --help for usage information');
    exit(1);
  }
}

Future<void> validateFeatureFiles(String inputDir, bool verbose) async {
  print('🔍 Validating feature files in: $inputDir');

  final dir = Directory(inputDir);
  if (!await dir.exists()) {
    print('❌ Input directory does not exist: $inputDir');
    return;
  }

  final featureFiles = await dir
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.feature'))
      .cast<File>()
      .toList();

  if (featureFiles.isEmpty) {
    print('⚠️  No .feature files found in $inputDir');
    return;
  }

  print('📁 Found ${featureFiles.length} feature file(s)');

  int validFiles = 0;
  int totalSteps = 0;
  List<String> errors = [];

  for (final file in featureFiles) {
    final relativePath = path.relative(file.path, from: inputDir);
    if (verbose) print('\n📄 Validating: $relativePath');

    try {
      final content = await file.readAsString();
      final validation = validateFeatureContent(content, relativePath);

      if (validation.isValid) {
        validFiles++;
        totalSteps += validation.stepCount;
        if (verbose) {
          print('  ✅ Valid (${validation.stepCount} steps)');
        }
      } else {
        errors.addAll(validation.errors.map((e) => '$relativePath: $e'));
        if (verbose) {
          print('  ❌ Invalid:');
          for (final error in validation.errors) {
            print('    - $error');
          }
        }
      }
    } catch (e) {
      errors.add('$relativePath: Failed to read file - $e');
    }
  }

  print('\n📊 Validation Summary:');
  print('  ✅ Valid files: $validFiles/${featureFiles.length}');
  print('  📋 Total steps: $totalSteps');

  if (errors.isNotEmpty) {
    print('  ❌ Errors found: ${errors.length}');
    print('\n🚨 Issues:');
    for (final error in errors) {
      print('  - $error');
    }
    exit(1);
  } else {
    print('  🎉 All feature files are valid!');
  }
}

class ValidationResult {
  final bool isValid;
  final int stepCount;
  final List<String> errors;

  ValidationResult(this.isValid, this.stepCount, this.errors);
}

ValidationResult validateFeatureContent(String content, String fileName) {
  final lines = content.split('\n');
  final errors = <String>[];
  int stepCount = 0;
  bool hasFeature = false;
  bool hasScenario = false;

  final supportedSteps = {
    'I see', 'I can see', 'I do not see', 'I don\'t see',
    'I tap', 'I long press', 'I double tap',
    'I enter', 'I clear field',
    'I swipe', 'I scroll', 'I refresh',
    'I wait for', 'I wait until I see', 'I pump',
    'I settle', 'I press', 'I trigger',
    'I navigate back', 'I go back', 'I dismiss',
    'field', // for field validation
  };

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    final lineNumber = i + 1;

    if (line.isEmpty || line.startsWith('#')) continue;

    if (line.startsWith('Feature:')) {
      hasFeature = true;
    } else if (line.startsWith('Scenario:')) {
      hasScenario = true;
    } else if (line.startsWith('Given ') ||
        line.startsWith('When ') ||
        line.startsWith('Then ')) {
      stepCount++;
      final stepText = line.substring(line.indexOf(' ') + 1);

      // Check if step is supported
      bool isSupported =
          supportedSteps.any((step) => stepText.startsWith(step));

      if (!isSupported) {
        errors.add('Line $lineNumber: Unsupported step - "$stepText"');
      }

      // Check for common selector formats
      if (stepText.contains('key:') ||
          stepText.contains('type:') ||
          stepText.contains('icon:')) {
        // Valid selector format
      } else if (stepText.contains('contains:') ||
          stepText.contains('startsWith:') ||
          stepText.contains('endsWith:') ||
          stepText.contains('regex:') ||
          stepText.contains('text:')) {
        // Valid enhanced text selector
      }
    }
  }

  if (!hasFeature) {
    errors.add('Missing Feature declaration');
  }
  if (!hasScenario) {
    errors.add('Missing Scenario declaration');
  }

  return ValidationResult(errors.isEmpty, stepCount, errors);
}

Future<void> generateTestSkeletons(
    String inputDir, String outputDir, bool verbose) async {
  print('🏗️  Generating test skeletons from: $inputDir to: $outputDir');

  final inputDirectory = Directory(inputDir);
  if (!await inputDirectory.exists()) {
    print('❌ Input directory does not exist: $inputDir');
    return;
  }

  final outputDirectory = Directory(outputDir);
  if (!await outputDirectory.exists()) {
    await outputDirectory.create(recursive: true);
    if (verbose) print('📁 Created output directory: $outputDir');
  }

  final featureFiles = await inputDirectory
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.feature'))
      .cast<File>()
      .toList();

  if (featureFiles.isEmpty) {
    print('⚠️  No .feature files found in $inputDir');
    return;
  }

  int generatedFiles = 0;

  for (final featureFile in featureFiles) {
    try {
      final relativePath = path.relative(featureFile.path, from: inputDir);
      final testFileName =
          '${path.basenameWithoutExtension(relativePath)}_test.dart';
      final testFilePath = path.join(outputDir, testFileName);

      final content = await featureFile.readAsString();
      final testContent = generateTestContent(content, relativePath);

      final testFile = File(testFilePath);
      await testFile.writeAsString(testContent);

      generatedFiles++;
      if (verbose) print('  ✅ Generated: $testFileName');
    } catch (e) {
      print('  ❌ Failed to generate test for ${featureFile.path}: $e');
    }
  }

  print('\n📊 Generation Summary:');
  print('  ✅ Generated $generatedFiles test file(s)');
  print('  📁 Output directory: $outputDir');

  if (generatedFiles > 0) {
    print('\n💡 Next steps:');
    print('  1. Review generated test files');
    print('  2. Add imports for your app widgets');
    print('  3. Customize the test setup as needed');
    print('  4. Run: flutter test $outputDir');
  }
}

String generateTestContent(String featureContent, String featurePath) {
  final lines = featureContent.split('\n');
  String featureName = 'Generated Test';
  final scenarios = <String>[];
  String currentScenario = '';

  for (final line in lines) {
    final trimmed = line.trim();

    if (trimmed.startsWith('Feature:')) {
      featureName = trimmed.substring(8).trim();
    } else if (trimmed.startsWith('Scenario:')) {
      if (currentScenario.isNotEmpty) {
        scenarios.add(currentScenario);
      }
      currentScenario = trimmed.substring(9).trim();
    }
  }

  if (currentScenario.isNotEmpty) {
    scenarios.add(currentScenario);
  }

  final buffer = StringBuffer();

  // File header
  buffer.writeln('// Generated test file for: $featurePath');
  buffer.writeln('// Feature: $featureName');
  buffer.writeln('// Generated on: ${DateTime.now().toIso8601String()}');
  buffer.writeln();
  buffer.writeln('import \'package:flutter_test/flutter_test.dart\';');
  buffer.writeln('import \'package:pickle_parser/pickle_parser.dart\';');
  buffer.writeln('// TODO: Import your app widgets here');
  buffer.writeln('// import \'package:your_app/main.dart\';');
  buffer.writeln();
  buffer.writeln('void main() {');
  buffer.writeln('  group(\'$featureName\', () {');

  // Generate test cases for each scenario
  for (int i = 0; i < scenarios.length; i++) {
    final scenario = scenarios[i];
    buffer.writeln();
    buffer.writeln(
        '    testWidgets(\'$scenario\', (WidgetTester tester) async {');
    buffer.writeln('      // TODO: Set up your app widget');
    buffer.writeln('      // await tester.pumpWidget(YourApp());');
    buffer.writeln();
    buffer.writeln('      // Execute the pickle file');
    buffer.writeln('      await pickleParser(tester, \'$featurePath\');');
    buffer.writeln('    });');
  }

  buffer.writeln('  });');
  buffer.writeln('}');

  return buffer.toString();
}
