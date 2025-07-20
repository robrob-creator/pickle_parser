import 'package:flutter_test/flutter_test.dart';

/// Signature for custom step handlers.
///
/// Takes the full step text and a [WidgetTester] instance.
/// Should return true if the step was handled, false otherwise.
typedef CustomStepHandler = Future<bool> Function(
    String step, WidgetTester tester);

/// Registry for custom step implementations.
///
/// Allows users to register custom step handlers that will be checked
/// before falling back to the built-in step implementations.
class CustomStepRegistry {
  static final CustomStepRegistry _instance = CustomStepRegistry._internal();
  factory CustomStepRegistry() => _instance;
  CustomStepRegistry._internal();

  final Map<RegExp, CustomStepHandler> _stepHandlers = {};
  final Map<String, CustomStepHandler> _exactStepHandlers = {};

  /// Register a custom step handler with a regex pattern.
  ///
  /// The [pattern] is used to match step text using regex.
  /// The [handler] function will be called when a step matches the pattern.
  ///
  /// Example:
  /// ```dart
  /// CustomStepRegistry().registerPattern(
  ///   RegExp(r'I wait for (\d+) milliseconds'),
  ///   (step, tester) async {
  ///     final match = RegExp(r'I wait for (\d+) milliseconds').firstMatch(step);
  ///     if (match != null) {
  ///       final ms = int.parse(match.group(1)!);
  ///       await tester.pump(Duration(milliseconds: ms));
  ///       return true;
  ///     }
  ///     return false;
  ///   },
  /// );
  /// ```
  void registerPattern(RegExp pattern, CustomStepHandler handler) {
    _stepHandlers[pattern] = handler;
  }

  /// Register a custom step handler with exact text matching.
  ///
  /// The [stepText] must match exactly (case-sensitive).
  /// The [handler] function will be called when a step matches exactly.
  ///
  /// Example:
  /// ```dart
  /// CustomStepRegistry().registerExact(
  ///   'I perform a custom action',
  ///   (step, tester) async {
  ///     // Custom implementation here
  ///     await tester.pump();
  ///     return true;
  ///   },
  /// );
  /// ```
  void registerExact(String stepText, CustomStepHandler handler) {
    _exactStepHandlers[stepText] = handler;
  }

  /// Register a custom step handler with a simple text pattern using placeholders.
  ///
  /// Use `{}` as placeholders that will be converted to regex capture groups.
  /// The [handler] receives the full step text and should parse it manually.
  ///
  /// Example:
  /// ```dart
  /// CustomStepRegistry().registerTemplate(
  ///   'I wait for {} seconds and then tap {}',
  ///   (step, tester) async {
  ///     // Parse the step manually to extract values
  ///     final parts = step.split(' ');
  ///     final seconds = int.parse(parts[3]);
  ///     final element = parts.sublist(7).join(' ');
  ///
  ///     await Future.delayed(Duration(seconds: seconds));
  ///     // Use existing element finder logic
  ///     return true;
  ///   },
  /// );
  /// ```
  void registerTemplate(String template, CustomStepHandler handler) {
    // Convert template to regex pattern
    final escapedTemplate = RegExp.escape(template);
    final pattern = escapedTemplate.replaceAll(r'\{\}', r'(.+?)');
    registerPattern(RegExp('^$pattern\$'), handler);
  }

  /// Try to execute a step using registered custom handlers.
  ///
  /// Returns true if a custom handler was found and executed successfully.
  /// Returns false if no custom handler matches the step.
  Future<bool> tryExecuteCustomStep(String step, WidgetTester tester) async {
    // Remove leading/trailing whitespace and extract just the step text
    step = step.trim();

    // Remove Gherkin keywords to get clean step text
    String cleanStep = step;
    if (step.startsWith('Given ')) {
      cleanStep = step.substring(6).trim();
    } else if (step.startsWith('When ')) {
      cleanStep = step.substring(5).trim();
    } else if (step.startsWith('Then ')) {
      cleanStep = step.substring(5).trim();
    }

    // Try exact match first
    if (_exactStepHandlers.containsKey(cleanStep)) {
      try {
        return await _exactStepHandlers[cleanStep]!(step, tester);
      } catch (e) {
        // If custom handler fails, let the built-in handler try
        return false;
      }
    }

    // Try pattern matching
    for (final entry in _stepHandlers.entries) {
      if (entry.key.hasMatch(cleanStep)) {
        try {
          return await entry.value(step, tester);
        } catch (e) {
          // If custom handler fails, continue trying other patterns
          continue;
        }
      }
    }

    return false;
  }

  /// Clear all registered custom step handlers.
  ///
  /// Useful for testing or resetting the registry.
  void clear() {
    _stepHandlers.clear();
    _exactStepHandlers.clear();
  }

  /// Get the number of registered custom step handlers.
  int get handlerCount => _stepHandlers.length + _exactStepHandlers.length;

  /// Get all registered pattern handlers (for debugging/inspection).
  Map<RegExp, CustomStepHandler> get patternHandlers =>
      Map.unmodifiable(_stepHandlers);

  /// Get all registered exact handlers (for debugging/inspection).
  Map<String, CustomStepHandler> get exactHandlers =>
      Map.unmodifiable(_exactStepHandlers);
}

/// Convenience function to register a custom step with exact text matching.
///
/// This is a shorthand for `CustomStepRegistry().registerExact()`.
void registerCustomStep(String stepText, CustomStepHandler handler) {
  CustomStepRegistry().registerExact(stepText, handler);
}

/// Convenience function to register a custom step with regex pattern matching.
///
/// This is a shorthand for `CustomStepRegistry().registerPattern()`.
void registerCustomStepPattern(RegExp pattern, CustomStepHandler handler) {
  CustomStepRegistry().registerPattern(pattern, handler);
}

/// Convenience function to register a custom step with template matching.
///
/// This is a shorthand for `CustomStepRegistry().registerTemplate()`.
void registerCustomStepTemplate(String template, CustomStepHandler handler) {
  CustomStepRegistry().registerTemplate(template, handler);
}
