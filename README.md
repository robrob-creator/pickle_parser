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

## 📦 Installation

Add `pickle_parser` to your `pubspec.yaml` file:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  pickle_parser: ^1.0.3
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

````

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
````

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

## 📚 Complete Step Reference

### 👁️ Visibility Assertions

#### Positive Assertions

```gherkin
# Check if element is visible
When I see [element]
Then I see [element]
When I can see [element]  # Alternative syntax

# Examples
When I see Login Button
Then I see key:welcome_message
When I can see type:AppBar
```

#### Negative Assertions

```gherkin
# Check if element is NOT visible
When I do not see [element]
When I don't see [element]
Then I do not see [element]
Then I don't see [element]

# Examples
Then I do not see Error Message
When I don't see key:loading_spinner
```

### 🖱️ Touch Interactions

#### Basic Tap

```gherkin
When I tap [element]

# Examples
When I tap Submit
When I tap key:login_button
When I tap type:ElevatedButton
When I tap icon:add
```

#### Long Press

```gherkin
When I long press [element]

# Examples
When I long press Delete Item
When I long press key:context_menu
When I long press type:ListTile
```

#### Double Tap

```gherkin
When I double tap [element]

# Examples
When I double tap Favorite
When I double tap key:heart_icon
When I double tap type:Image
```

### ⌨️ Text Input

#### Enter Text (Multiple Formats)

```gherkin
# Format 1: With field specification
When I enter [text] in field with key:[key]
When I enter [text] in field with type:[type]

# Format 2: Into element
When I enter [text] into [element]

# Examples
When I enter hello@example.com in field with key:email_field
When I enter password123 in field with type:TextField
When I enter Search term into key:search_box
When I enter John Doe into type:TextFormField
```

#### Clear Field

```gherkin
When I clear field [element]

# Examples
When I clear field key:username
When I clear field type:TextField
```

#### Field Content Validation

```gherkin
When field [element] contains [text]
Then field [element] contains [text]

# Examples
Then field key:email_field contains john@example.com
When field type:TextField contains Expected Text
```

### 🎯 Gesture Interactions

#### Swipe

```gherkin
# Screen swipe
When I swipe [direction]

# Element-specific swipe
When I swipe [direction] on [element]

# Directions: left, right, up, down
# Examples
When I swipe left
When I swipe right on key:card_widget
When I swipe up on type:ListView
```

#### Scroll

```gherkin
# Basic scroll
When I scroll [direction]

# Scroll until element is visible
When I scroll until I see [element]

# Examples
When I scroll up
When I scroll down
When I scroll until I see Load More
When I scroll until I see key:bottom_item
```

#### Pull to Refresh

```gherkin
When I refresh

# Example
When I refresh
Then I see Updated Content
```

### ⏱️ Wait and Timing

#### Time-based Wait

```gherkin
When I wait for [seconds]

# Examples
When I wait for 2
When I wait for 5
```

#### Conditional Wait

```gherkin
When I wait until I see [element]

# Examples
When I wait until I see Loading Complete
When I wait until I see key:success_dialog
When I wait until I see type:SnackBar
```

#### Manual Pump

```gherkin
When I pump [count]

# Examples
When I pump 1
When I pump 5
```

#### Settle Animation

```gherkin
When I settle
Then I settle

# Wait for all animations to complete
When I settle
```

### ⌨️ Keyboard Interactions

#### Key Press

```gherkin
When I press [key]
When I trigger [key]  # Alternative for enter

# Supported keys: enter, escape, space, tab, backspace
# Examples
When I press enter
When I press escape
When I trigger enter  # Same as pressing enter
```

### 🧭 Navigation

#### Back Navigation

```gherkin
When I navigate back
When I go back

# Examples
When I navigate back
Then I see Previous Screen
```

#### Dismiss Dialogs/Overlays

```gherkin
When I dismiss [element]

# Auto-detects common dismiss buttons: Dismiss, Close, OK
# Examples
When I dismiss dialog
When I dismiss key:popup_menu
When I dismiss type:AlertDialog
```

## 💡 Usage Examples

### Complete Login Flow

```gherkin
Feature: User Authentication

  Scenario: Successful login and navigation
    # Setup
    Given I am on the login screen

    # Input credentials
    When I enter test@example.com in field with key:email_input
    When I enter secretpass in field with key:password_input

    # Submit form
    When I tap key:login_submit
    When I settle

    # Verify success
    Then I see Welcome back!
    Then I do not see Invalid credentials
    Then I see type:BottomNavigationBar

    # Navigate to profile
    When I tap Profile
    Then I see My Profile
```

### E-commerce Product Search

```gherkin
Feature: Product Search

  Scenario: Search and filter products
    # Search for products
    When I tap key:search_field
    When I enter smartphone into key:search_field
    When I press enter
    When I settle

    # Verify results
    Then I see Search Results
    Then I see type:ListView

    # Apply filters
    When I tap Filters
    When I tap Price: Low to High
    When I tap Apply
    When I settle

    # Verify filtered results
    Then I see Sorted Results
    Then I do not see No results found
```

### Enhanced Text Matching

```gherkin
Feature: Advanced Text Matching

  Scenario: Using flexible text selectors
    # Exact match (default behavior)
    When I see Login Button

    # Partial text matching
    When I tap contains:Submit
    Then I see contains:Success

    # Prefix matching
    When I see startsWith:Welcome

    # Suffix matching
    Then I see endsWith:completed

    # Regex pattern matching
    When I see regex:^Error.*occurred$
    Then I see regex:\d+ items? found

    # Explicit exact match
    When I tap text:Exact Button Text
```

### Form Validation

```gherkin
Feature: Contact Form

  Scenario: Form validation and submission
    # Fill form with invalid data
    When I enter invalid-email in field with key:email_field
    When I enter x in field with key:name_field
    When I tap Submit

    # Check validation errors
    Then I see Please enter a valid email
    Then I see Name must be at least 2 characters

    # Fix errors
    When I clear field key:email_field
    When I enter valid@email.com in field with key:email_field
    When I clear field key:name_field
    When I enter John Doe in field with key:name_field

    # Submit successfully
    When I tap Submit
    When I settle
    Then I see Thank you for your message
    Then I do not see Please enter a valid email
```

## ⚠️ Limitations

### Current Limitations

1. **Limited Icon Support**: Only supports `add`, `delete`, `close`, `menu` icons
2. **Single Element Finding**: Steps target the first matching element
3. **No Parameter Substitution**: Variables/parameters not supported in steps
4. **Asset Loading Only**: Feature files must be in app assets (not external files)
5. **No Custom Steps**: Cannot define custom step implementations
6. **Flutter Dependencies**: Requires Flutter test environment

### Widget Support Limitations

- Custom widgets require `key:` or `type:` selectors
- Complex widget hierarchies may need specific targeting
- Some widget states (disabled, loading) not explicitly supported

### Timing Limitations

- Fixed timeout durations (30 seconds for `pumpUntilFound`)
- No dynamic timeout configuration
- Animation timing depends on Flutter's `pumpAndSettle`

### ✅ Improvements Made

- ✅ **Enhanced Text Matching**: Added support for contains, startsWith, endsWith, and regex patterns
- ✅ **CLI Validation**: Feature files can now be validated before testing
- ✅ **Test Generation**: Automatic test skeleton generation from feature files
- ✅ **Better Error Messages**: More specific error reporting and validation

## 📋 Best Practices

### 1. Widget Keys

Always add keys to important widgets for reliable targeting:

```dart
ElevatedButton(
  key: Key('submit_button'),
  onPressed: () => {},
  child: Text('Submit'),
)
```

### 2. Descriptive Step Names

Use clear, descriptive step names:

```gherkin
# Good
When I tap key:submit_order_button
Then I see Order confirmation message

# Avoid
When I tap button
Then I see text
```

### 3. Wait Strategies

Use appropriate wait strategies:

```gherkin
# For loading states
When I wait until I see type:CircularProgressIndicator
When I wait until I see Content loaded

# For animations
When I settle

# For time-based operations
When I wait for 3
```

### 4. Error Scenarios

Test both positive and negative scenarios:

```gherkin
Scenario: Invalid login
  When I enter wrong@email.com in field with key:email
  When I enter wrongpass in field with key:password
  When I tap key:login_button
  Then I see Invalid credentials
  Then I do not see Dashboard
```

### 5. Organize Feature Files

Structure your feature files logically:

```
assets/features/
├── authentication/
│   ├── login.feature
│   ├── signup.feature
│   └── password_reset.feature
├── shopping/
│   ├── product_search.feature
│   ├── cart.feature
│   └── checkout.feature
└── profile/
    ├── edit_profile.feature
    └── settings.feature
```

## 🐛 Troubleshooting

### Common Issues

#### Element Not Found

```
Error: No widget found with key:my_button
```

**Solutions:**

- Verify the key exists in your widget
- Use `When I wait until I see key:my_button` before interaction
- Check if widget is in a different screen/state

#### Timeout Errors

```
Error: Pump until has timed out
```

**Solutions:**

- Increase wait time: `When I wait for 5`
- Use `When I settle` for animations
- Check if element actually appears

#### Text Input Issues

```
Error: Unable to enter text in field
```

**Solutions:**

- Ensure field is focusable and enabled
- Use correct selector (key vs type)
- Clear field before entering new text

#### Step Not Recognized

```
Error: Unsupported text: my custom step
```

**Solutions:**

- Check step syntax against documentation
- Verify spelling and formatting
- Use supported step patterns only
- Run `dart run pickle_parser:cli --validate` to check feature files

#### Enhanced Text Selector Issues

```
Error: No widget found with contains:partial text
```

**Solutions:**

- Verify the text actually contains the substring
- Use exact text matching if partial matching fails
- Check for case sensitivity in text matching
- Try different selector types (startsWith, endsWith, regex)

### Debugging Tips

1. **Add Logging Steps**:

```gherkin
When I settle
# Add debugging visibility checks
Then I see expected_element
```

2. **Use Type Selectors for Generic Widgets**:

```gherkin
# Instead of relying on text that might change
When I tap type:ElevatedButton
```

3. **Break Down Complex Scenarios**:

```gherkin
# Split complex interactions
When I tap Settings
When I settle
When I tap Profile
When I settle
Then I see Profile Settings
```

4. **Use Enhanced Text Matching**:

```gherkin
# Instead of relying on exact text that might change
When I tap contains:Submit
Then I see startsWith:Success
```

5. **Use CLI Validation**:

```bash
# Validate your feature files before running tests
dart run pickle_parser:cli --validate --verbose

# Generate skeleton tests to verify structure
dart run pickle_parser:cli --generate --input assets/features --output test/validation
```

## 🤝 Contributing

We welcome contributions! If you encounter issues or have suggestions:

1. **Issues**: Create an issue on the [GitHub repository](https://github.com/robrob-creator/pickle_parser.git)
2. **Pull Requests**: Submit PRs for bug fixes or new features
3. **Feature Requests**: Suggest new Gherkin step patterns or widget support

### Development Setup

```bash
# Clone the repository
git clone https://github.com/robrob-creator/pickle_parser.git

# Install dependencies
flutter pub get

# Run tests
flutter test
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Need help?** Check the [example directory](example/) for complete working examples or create an issue on GitHub.
