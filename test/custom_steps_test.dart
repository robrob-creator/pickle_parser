import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickle_parser/pickle_parser.dart';

void main() {
  group('Custom Steps', () {
    setUp(() {
      // Clear any existing custom steps before each test
      CustomStepRegistry().clear();
    });

    test('CustomStepRegistry can register and retrieve exact steps', () {
      final registry = CustomStepRegistry();

      registry.registerExact('I do something custom', (step, tester) async {
        return true;
      });

      expect(registry.handlerCount, equals(1));
      expect(
          registry.exactHandlers.containsKey('I do something custom'), isTrue);
    });

    test('CustomStepRegistry can register and retrieve pattern steps', () {
      final registry = CustomStepRegistry();
      final pattern = RegExp(r'I wait for (\d+) seconds');

      registry.registerPattern(pattern, (step, tester) async {
        return true;
      });

      expect(registry.handlerCount, equals(1));
      expect(registry.patternHandlers.containsKey(pattern), isTrue);
    });

    test('CustomStepRegistry can register template steps', () {
      final registry = CustomStepRegistry();

      registry.registerTemplate('I wait for {} seconds and tap {}',
          (step, tester) async {
        return true;
      });

      expect(registry.handlerCount, equals(1));
    });

    test('CustomStepRegistry can clear all handlers', () {
      final registry = CustomStepRegistry();

      registry.registerExact('step1', (step, tester) async => true);
      registry.registerPattern(RegExp('step2'), (step, tester) async => true);

      expect(registry.handlerCount, equals(2));

      registry.clear();
      expect(registry.handlerCount, equals(0));
    });

    testWidgets('Custom step with exact matching is executed',
        (WidgetTester tester) async {
      bool customStepExecuted = false;

      registerCustomStep('I perform custom action', (step, tester) async {
        customStepExecuted = true;
        return true;
      });

      await getCucumberStepTestCode('When I perform custom action', tester);

      expect(customStepExecuted, isTrue);
    });

    testWidgets('Custom step with pattern matching is executed',
        (WidgetTester tester) async {
      String capturedValue = '';

      registerCustomStepPattern(
        RegExp(r'I wait for (\d+) milliseconds'),
        (step, tester) async {
          final match =
              RegExp(r'I wait for (\d+) milliseconds').firstMatch(step);
          if (match != null) {
            capturedValue = match.group(1)!;
            return true;
          }
          return false;
        },
      );

      await getCucumberStepTestCode('When I wait for 500 milliseconds', tester);

      expect(capturedValue, equals('500'));
    });

    testWidgets('Built-in steps still work when no custom step matches',
        (WidgetTester tester) async {
      // Build a simple widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Hello World'),
          ),
        ),
      );

      // This should use the built-in implementation since no custom step is registered
      await getCucumberStepTestCode('When I see Hello World', tester);

      // If we get here without exception, the built-in step worked
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('Custom step takes precedence over built-in steps',
        (WidgetTester tester) async {
      bool customStepExecuted = false;

      // Register a custom step that matches a built-in pattern
      registerCustomStep('I see custom text', (step, tester) async {
        customStepExecuted = true;
        return true;
      });

      await getCucumberStepTestCode('When I see custom text', tester);

      expect(customStepExecuted, isTrue);
    });

    testWidgets('Failed custom step falls back to built-in implementation',
        (WidgetTester tester) async {
      // Build a simple widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Test Text'),
          ),
        ),
      );

      // Register a custom step that returns false (indicating it couldn't handle the step)
      registerCustomStep('I see Test Text', (step, tester) async {
        return false; // Indicate that this handler couldn't process the step
      });

      // This should fall back to the built-in implementation
      await getCucumberStepTestCode('When I see Test Text', tester);

      // The built-in step should have executed successfully
      expect(find.text('Test Text'), findsOneWidget);
    });

    test('Convenience functions work correctly', () {
      CustomStepRegistry().clear();

      // Test convenience functions
      registerCustomStep('exact step', (step, tester) async => true);
      registerCustomStepPattern(
          RegExp('pattern'), (step, tester) async => true);
      registerCustomStepTemplate('template {}', (step, tester) async => true);

      expect(CustomStepRegistry().handlerCount, equals(3));
    });
  });
}
