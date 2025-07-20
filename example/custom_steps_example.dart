import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickle_parser/pickle_parser.dart';

/// Example demonstrating how to register and use custom steps with pickle_parser.
void main() {
  group('Custom Steps Examples', () {
    setUpAll(() {
      // Register custom steps before running tests
      _registerCustomSteps();
    });

    testWidgets('Custom step with exact text matching',
        (WidgetTester tester) async {
      // Build a simple app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Welcome'),
                ElevatedButton(
                  key: const Key('custom_button'),
                  onPressed: () {},
                  child: const Text('Custom Action'),
                ),
                const Text('Result: Not clicked'),
              ],
            ),
          ),
        ),
      );

      // This will use our custom step implementation
      await getCucumberStepTestCode('When I perform a special action', tester);

      // Verify the custom action was performed
      expect(find.text('Custom action performed!'), findsOneWidget);
    });

    testWidgets('Custom step with pattern matching',
        (WidgetTester tester) async {
      // Build a simple app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Timer Test'),
                ElevatedButton(
                  key: const Key('timer_button'),
                  onPressed: () {},
                  child: const Text('Start Timer'),
                ),
              ],
            ),
          ),
        ),
      );

      // This will use our pattern-based custom step
      await getCucumberStepTestCode('When I wait for 500 milliseconds', tester);
      await getCucumberStepTestCode(
          'When I wait for 1000 milliseconds', tester);
    });

    testWidgets('Custom step with template matching',
        (WidgetTester tester) async {
      // Build a simple app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Multi-action Test'),
                ElevatedButton(
                  key: const Key('action_button'),
                  onPressed: () {},
                  child: const Text('Action Button'),
                ),
                ElevatedButton(
                  key: const Key('other_button'),
                  onPressed: () {},
                  child: const Text('Other Button'),
                ),
              ],
            ),
          ),
        ),
      );

      // This will use our template-based custom step
      await getCucumberStepTestCode(
          'When I wait for 2 seconds and then tap action_button', tester);
    });
  });
}

/// Register custom step implementations.
void _registerCustomSteps() {
  // Example 1: Exact text matching
  registerCustomStep(
    'I perform a special action',
    (step, tester) async {
      // Custom implementation for this specific step
      print('Executing custom step: $step');

      // Tap a specific button
      await tester.tap(find.byKey(const Key('custom_button')));
      await tester.pump();

      // Add some custom text to verify the action
      // In a real app, this might trigger some state change
      // For demo purposes, we'll just pump and assume success
      await tester.pumpAndSettle();

      return true; // Step was handled successfully
    },
  );

  // Example 2: Pattern matching with regex
  registerCustomStepPattern(
    RegExp(r'I wait for (\d+) milliseconds'),
    (step, tester) async {
      final match = RegExp(r'I wait for (\d+) milliseconds').firstMatch(step);
      if (match != null) {
        final ms = int.parse(match.group(1)!);
        print('Custom wait step: waiting for ${ms}ms');

        // Custom wait implementation
        await tester.pump(Duration(milliseconds: ms));
        return true;
      }
      return false;
    },
  );

  // Example 3: Template matching for complex steps
  registerCustomStepTemplate(
    'I wait for {} seconds and then tap {}',
    (step, tester) async {
      // Parse the step manually to extract values
      print('Executing template step: $step');

      // Simple parsing - in real usage you might want more robust parsing
      final parts = step.split(' ');
      if (parts.length >= 8) {
        final seconds = int.tryParse(parts[3]);
        final elementKey =
            parts[7]; // Assuming format: "I wait for X seconds and then tap Y"

        if (seconds != null) {
          // Wait for the specified duration
          await Future.delayed(Duration(seconds: seconds));
          await tester.pump();

          // Tap the specified element
          await tester.tap(find.byKey(Key(elementKey)));
          await tester.pump();

          return true;
        }
      }
      return false;
    },
  );

  // Example 4: Advanced custom step with complex logic
  registerCustomStepPattern(
    RegExp(r'I verify that (.+) contains (.+)'),
    (step, tester) async {
      final match =
          RegExp(r'I verify that (.+) contains (.+)').firstMatch(step);
      if (match != null) {
        final elementName = match.group(1)!;
        final expectedText = match.group(2)!;

        // Custom verification logic
        Finder finder;
        if (elementName.startsWith('key:')) {
          finder = find.byKey(Key(elementName.substring(4)));
        } else {
          finder = find.text(elementName);
        }

        // Get the widget and check its text content
        final widget = tester.widget(finder);
        String actualText = '';

        if (widget is Text) {
          actualText = widget.data ?? '';
        } else if (widget is TextField) {
          actualText = (widget as dynamic).controller?.text ?? '';
        }

        // Custom assertion
        if (actualText.contains(expectedText)) {
          print(
              '✅ Custom verification passed: "$actualText" contains "$expectedText"');
          return true;
        } else {
          throw TestFailure(
              'Custom verification failed: "$actualText" does not contain "$expectedText"');
        }
      }
      return false;
    },
  );

  // Example 5: Custom step for app-specific actions
  registerCustomStep(
    'I login with default credentials',
    (step, tester) async {
      // This could encapsulate a complex login flow
      print('Executing app-specific login step');

      // Enter username
      await tester.enterText(
          find.byKey(const Key('username')), 'testuser@example.com');

      // Enter password
      await tester.enterText(find.byKey(const Key('password')), 'password123');

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));

      // Wait for navigation
      await tester.pumpAndSettle();

      return true;
    },
  );

  print(
      '✅ Custom steps registered: ${CustomStepRegistry().handlerCount} handlers');
}
