# Pickle Parser

A comprehensive Flutter package for parsing pickle/Gherkin files and executing Cucumber steps in widget tests. This package allows you to write human-readable test scenarios using Gherkin syntax and automatically execute them as Flutter widget tests.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Dependencies](#dependencies)
- [Quick Start](#quick-start)
- [Supported Gherkin Syntax](#supported-gherkin-syntax)
- [Element Selectors](#element-selectors)
- [Custom Steps](#custom-steps)
- [Complete Step Reference](#complete-step-reference)
- [Usage Examples](#usage-examples)
- [Limitations](#limitations)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🔍 Overview

The Pickle Parser package bridges the gap between business-readable Gherkin scenarios and Flutter widget tests. It automatically parses pickle/feature files and executes corresponding test actions, making it easier to maintain test scenarios and improve collaboration between developers and non-technical stakeholders.

## ✨ Features

- 🥒 **Full Gherkin Support**: Parse and execute Given/When/Then steps
- 🎯 **Multiple Element Selectors**: Find widgets by key, type, text, or icon
- 🔍 **Advanced Text Matching**: Supports exact, contains, startsWith, endsWith, and regex patterns
- 💫 **Rich Interactions**: Tap, long press, double tap, swipe, scroll, and keyboard input
- ⌨️ **Text Input**: Support for various text field interactions
- 🕒 **Wait Strategies**: Time-based waits and conditional waiting
- 📱 **Navigation Support**: Back navigation and dialog dismissal
- 🎨 **Gesture Support**: Swipe, scroll, refresh, and custom gestures
- 📖 **Clear Error Messages**: Detailed logging and error reporting
- 🛠️ **CLI Tools**: Validate feature files and generate test skeletons
- 🔧 **Custom Steps**: Register your own step implementations for app-specific actions

## 📦 Installation

Add `pickle_parser` to your `pubspec.yaml` file:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  pickle_parser: ^1.1.0
```

Then run:

```bash
flutter pub get
```

## 🛠️ CLI Tools

The package includes powerful command-line tools for validating feature files and generating test skeletons, making it easier to maintain and debug your Gherkin scenarios.

### Installation

The CLI tools are included with the package. After installing `pickle_parser`, you can run them directly:

```bash
# Run from your project directory
dart run pickle_parser:cli --help
```

Or run the tool file directly:

```bash
# Navigate to the package location and run
dart tool/cli/bin/pickle_parser_cli.dart --help
```

### CLI Commands

#### Validate Feature Files

```bash
# Validate all feature files in default directory (assets/features)
dart run pickle_parser:cli --validate

# Validate with verbose output
dart run pickle_parser:cli --validate --verbose

# Validate specific directory
dart run pickle_parser:cli --validate --input assets/features
```

#### Generate Test Skeletons

```bash
# Generate test files from feature files
dart run pickle_parser:cli --generate

# Specify input and output directories
dart run pickle_parser:cli --generate --input assets/features --output test/integration

# Generate with verbose output
dart run pickle_parser:cli --generate --verbose
```

#### Combined Operations

```bash
# Validate and generate in one command
dart run pickle_parser:cli --validate --generate --verbose

# Full workflow with custom directories
dart run pickle_parser:cli --validate --generate --input assets/scenarios --output test/generated --verbose
```

### CLI Features

- ✅ **Feature File Validation**: Checks syntax and supported step patterns
- 🏗️ **Test Skeleton Generation**: Creates ready-to-use test files
- 📊 **Detailed Reporting**: Shows validation results and statistics
- 🎯 **Smart Error Detection**: Identifies unsupported steps and syntax issues
- 📁 **Batch Processing**: Handles multiple feature files at once
- 🔍 **Step Pattern Recognition**: Validates against all supported Gherkin patterns
- 📋 **Summary Statistics**: Reports total files, steps, and validation status

### CLI Usage Examples

#### Basic Validation

```bash
$ dart run pickle_parser:cli --validate
🔍 Validating feature files in: assets/features
📁 Found 3 feature file(s)
📊 Validation Summary:
  ✅ Valid files: 3/3
  📋 Total steps: 45
  🎉 All feature files are valid!
```

#### Validation with Errors

```bash
$ dart run pickle_parser:cli --validate --verbose
🔍 Validating feature files in: assets/features
📁 Found 2 feature file(s)

📄 Validating: login.feature
  ✅ Valid (12 steps)

📄 Validating: checkout.feature
  ❌ Invalid:
    - Line 15: Unsupported step - "I click the mysterious button"
    - Line 23: Missing Feature declaration

📊 Validation Summary:
  ✅ Valid files: 1/2
  📋 Total steps: 12
  ❌ Errors found: 2
```

#### Test Generation

```bash
$ dart run pickle_parser:cli --generate --verbose
🏗️ Generating test skeletons from: assets/features to: test/generated
📁 Created output directory: test/generated
  ✅ Generated: login_test.dart
  ✅ Generated: checkout_test.dart

📊 Generation Summary:
  ✅ Generated 2 test file(s)
  📁 Output directory: test/generated

💡 Next steps:
  1. Review generated test files
  2. Add imports for your app widgets
  3. Customize the test setup as needed
  4. Run: flutter test test/generated
```

## 🔗 Dependencies

### Required Dependencies

- **Flutter SDK**: `>=2.19.5 <4.0.0`
- **flutter**: Core Flutter framework
- **flutter_test**: Flutter testing framework

### What's Included

The package automatically provides:

- Gherkin step parsing and execution
- Widget finding capabilities
- Gesture simulation
- Text input handling
- Wait and timing utilities

### Asset Configuration

To use pickle files, add them to your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/features/
    - test/features/
```

## 🚀 Quick Start

### 1. Create a Feature File

Create a `.feature` file in your assets folder:

```gherkin
# assets/features/login.feature
Feature: User Login

  Scenario: Successful login
    When I see Welcome to MyApp
    When I enter john@example.com in field with key:email_field
    When I enter password123 in field with key:password_field
    When I tap key:login_button
    Then I see Dashboard
    Then I do not see Login Failed
```

### 2. Create a Test File

```dart
// test/login_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pickle_parser/pickle_parser.dart';
import 'package:myapp/main.dart'; // Your app

void main() {
  testWidgets('Login flow from pickle file', (WidgetTester tester) async {
    // Build your app
    await tester.pumpWidget(MyApp());

    // Execute the pickle file
    await pickleParser(tester, 'assets/features/login.feature');
  });
}
```

## 📝 Supported Gherkin Syntax

### Keywords

- `Given` - Setup steps (currently treated as When steps)
- `When` - Action steps
- `Then` - Assertion steps
- `#` - Comments (ignored)

### Step Structure

```gherkin
When I [action] [element]
Then I [assertion] [element]
```

## 🎯 Element Selectors

The package supports multiple ways to find widgets:

### 1. By Key

```gherkin
When I tap key:submit_button
Then I see key:success_message
```

### 2. By Widget Type

```gherkin
When I tap type:ElevatedButton
Then I see type:Text
```

**Supported Widget Types:**

- `Text`, `TextField`, `TextFormField`
- `ElevatedButton`, `TextButton`, `OutlinedButton`
- `Container`, `Column`, `Row`, `Expanded`
- `AppBar`, `Scaffold`, `Material`
- `Icon`, `IconButton`, `FloatingActionButton`
- `ListView`, `GridView`, `Card`
- `Checkbox`, `Switch`, `Slider`, `Radio`
- `DropdownButton`, `AlertDialog`, `SnackBar`
- `Drawer`, `BottomSheet`, `Tab`, `TabBar`
- `NavigationBar`, `BottomNavigationBar`
- `RefreshIndicator`, `CupertinoNavigationBar`

### 3. By Text Content

```gherkin
# Exact match (default)
When I tap Submit
Then I see Welcome!

# Enhanced text matching
When I tap contains:Submit
Then I see startsWith:Welcome
When I see endsWith:Message
Then I see regex:^Error.*occurred$
```

**Text Selector Formats:**

- `text:exact` - Exact text match (explicit)
- `contains:partial` - Text contains substring
- `startsWith:prefix` - Text starts with prefix
- `endsWith:suffix` - Text ends with suffix
- `regex:pattern` - Text matches regex pattern

### 4. By Icon

```gherkin
When I tap icon:add
Then I see icon:check
```

**Supported Icons:**

- `add`, `delete`, `close`, `menu`

## 🔧 Custom Steps

The package supports registering custom step implementations for app-specific actions. This allows you to extend the built-in step library with your own business logic.

### How Custom Steps Work

1. **Priority**: Custom steps are checked first, before built-in implementations
2. **Fallback**: If a custom step returns `false` or throws an error, built-in steps are tried
3. **Flexibility**: Support for exact matching, regex patterns, and templates

### Registration Methods

#### Exact Text Matching

Register a step handler for exact text matches:

```dart
import 'package:pickle_parser/pickle_parser.dart';

// Register before running tests
registerCustomStep(
  'I login with default credentials',
  (step, tester) async {
    await tester.enterText(find.byKey(Key('username')), 'test@example.com');
    await tester.enterText(find.byKey(Key('password')), 'password123');
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pumpAndSettle();
    return true; // Step handled successfully
  },
);
```

#### Pattern Matching with Regex

Register steps that match regex patterns:

```dart
registerCustomStepPattern(
  RegExp(r'I wait for (\d+) milliseconds'),
  (step, tester) async {
    final match = RegExp(r'I wait for (\d+) milliseconds').firstMatch(step);
    if (match != null) {
      final ms = int.parse(match.group(1)!);
      await tester.pump(Duration(milliseconds: ms));
      return true;
    }
    return false;
  },
);
```

#### Template Matching

Register steps using simple templates with placeholders:

```dart
registerCustomStepTemplate(
  'I wait for {} seconds and then tap {}',
  (step, tester) async {
    // Parse step manually to extract values
    final parts = step.split(' ');
    final seconds = int.parse(parts[3]);
    final elementKey = parts[7];

    await Future.delayed(Duration(seconds: seconds));
    await tester.tap(find.byKey(Key(elementKey)));
    return true;
  },
);
```

### Advanced Custom Steps

#### Complex Business Logic

```dart
registerCustomStep(
  'I complete the checkout process',
  (step, tester) async {
    // Multi-step business process
    await tester.enterText(find.byKey(Key('credit_card')), '4111111111111111');
    await tester.enterText(find.byKey(Key('expiry')), '12/25');
    await tester.enterText(find.byKey(Key('cvv')), '123');

    await tester.tap(find.byKey(Key('submit_payment')));
    await tester.pumpAndSettle();

    // Verify success
    expect(find.text('Payment Successful'), findsOneWidget);
    return true;
  },
);
```

#### Custom Assertions

```dart
registerCustomStepPattern(
  RegExp(r'I verify that (.+) contains (.+)'),
  (step, tester) async {
    final match = RegExp(r'I verify that (.+) contains (.+)').firstMatch(step);
    if (match != null) {
      final elementName = match.group(1)!;
      final expectedText = match.group(2)!;

      Finder finder = elementName.startsWith('key:')
          ? find.byKey(Key(elementName.substring(4)))
          : find.text(elementName);

      final widget = tester.widget(finder);
      String actualText = '';

      if (widget is Text) {
        actualText = widget.data ?? '';
      } else if (widget is TextField) {
        actualText = (widget as dynamic).controller?.text ?? '';
      }

      if (!actualText.contains(expectedText)) {
        throw TestFailure('Text "$actualText" does not contain "$expectedText"');
      }

      return true;
    }
    return false;
  },
);
```

### Using the Registry Directly

For more control, use the `CustomStepRegistry` directly:

```dart
void setupCustomSteps() {
  final registry = CustomStepRegistry();

  // Register multiple patterns
  registry.registerPattern(RegExp(r'I scroll to (.+)'), myScrollHandler);
  registry.registerExact('I perform cleanup', myCleanupHandler);

  // Check registration
  print('Registered ${registry.handlerCount} custom steps');

  // Clear all (useful for testing)
  registry.clear();
}
```

### Custom Step Handler Signature

```dart
typedef CustomStepHandler = Future<bool> Function(String step, WidgetTester tester);
```

**Parameters:**

- `step`: The full step text including Gherkin keyword
- `tester`: The `WidgetTester` instance for widget interactions

**Return Value:**

- `true`: Step was handled successfully
- `false`: Step couldn't be handled, try built-in steps
- `Exception`: Step failed with error

### Best Practices

#### 1. Return `false` for Unhandled Cases

```dart
registerCustomStepPattern(
  RegExp(r'I wait for (\d+) seconds'),
  (step, tester) async {
    final match = RegExp(r'I wait for (\d+) seconds').firstMatch(step);
    if (match == null) {
      return false; // Let built-in handlers try
    }

    final seconds = int.tryParse(match.group(1)!);
    if (seconds == null) {
      return false; // Invalid format, let others handle
    }

    await Future.delayed(Duration(seconds: seconds));
    return true;
  },
);
```

#### 2. Use Descriptive Step Names

```dart
// Good - clear and specific
registerCustomStep('I login as admin user', adminLoginHandler);
registerCustomStep('I verify shopping cart total', cartTotalHandler);

// Avoid - too generic
registerCustomStep('I do something', genericHandler);
```

#### 3. Setup in Test Suite

```dart
void main() {
  setUpAll(() {
    // Register custom steps before all tests
    registerCustomStep('I setup test data', setupTestDataHandler);
    registerCustomStep('I cleanup test data', cleanupTestDataHandler);
  });

  tearDownAll(() {
    // Clean up if needed
    CustomStepRegistry().clear();
  });

  testWidgets('My test', (tester) async {
    // Use custom steps in feature files or directly
    await getCucumberStepTestCode('When I setup test data', tester);
    // ... test logic ...
    await getCucumberStepTestCode('When I cleanup test data', tester);
  });
}
```

#### 4. Error Handling

```dart
registerCustomStep(
  'I verify complex state',
  (step, tester) async {
    try {
      // Complex verification logic
      await verifyComplexState(tester);
      return true;
    } catch (e) {
      // Log error and let built-in steps try, or rethrow if critical
      print('Custom step failed: $e');
      return false; // Or rethrow if you want the test to fail
    }
  },
);
```

### Feature File Examples

With custom steps registered, you can use them in feature files:

```gherkin
Feature: Shopping Cart

  Scenario: Complete purchase
    Given I am on the product page
    When I add item to cart
    And I login with default credentials          # Custom step
    And I complete the checkout process           # Custom step
    Then I verify that receipt contains "Success" # Custom step
    And I cleanup test data                       # Custom step
```

### Custom Steps in CLI Validation

The CLI tool recognizes custom steps when they are registered:

```bash
# Run validation with custom steps
dart run pickle_parser:cli --validate

# The validator will check:
# 1. Built-in step patterns
# 2. Registered custom step patterns
# 3. Report any unmatched steps
```

**Note**: For CLI validation to recognize custom steps, you need to register them in a setup file that the CLI can access.

## ☕ Support This Project

If you find this package helpful and want to support its development, consider buying me a coffee! Your support helps maintain and improve this open-source project.

[![Buy Me A Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png)](https://buymeacoffee.com/robmoonshoz)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Need help?** Check the [example directory](example/) for complete working examples or create an issue on GitHub.
