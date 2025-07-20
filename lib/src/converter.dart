import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'custom_steps.dart';

/// Pumps the widget tree for the specified number of seconds.
///
/// This is useful for waiting during animations or other time-based operations.
Future<void> pumpForSeconds(WidgetTester tester, int seconds) async {
  bool timerDone = false;
  Timer(Duration(seconds: seconds), () => timerDone = true);
  while (timerDone != true) {
    await tester.pump();
  }
}

/// Returns the IconData for a given icon name string.
///
/// Supports common Material Design icons. Throws an exception for unknown icons.
IconData getIconData(String iconName) {
  switch (iconName) {
    case 'add':
      return Icons.add;
    case 'delete':
      return Icons.delete;
    case 'close':
      return Icons.close;
    case 'menu':
      return Icons.menu;
    // Add more cases for other icons as needed
    default:
      throw Exception('Unknown icon name: $iconName');
  }
}

/// Pumps the widget tree until the specified finder locates a widget or times out.
///
/// This is useful for waiting for widgets to appear after async operations.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  bool timerDone = false;
  final timer =
      Timer(timeout, () => throw TimeoutException('Pump until has timed out'));
  while (timerDone != true) {
    await tester.pump();

    final found = tester.any(finder);
    if (found) {
      timerDone = true;
      break;
    }
  }
  timer.cancel();
}

/// Creates a flexible text finder based on the text selector format.
///
/// Supports multiple text matching strategies:
/// - `text:exact` - Exact text match (default behavior)
/// - `contains:partial` - Text contains the specified substring
/// - `startsWith:prefix` - Text starts with the specified prefix
/// - `endsWith:suffix` - Text ends with the specified suffix
/// - `regex:pattern` - Text matches the regex pattern
Finder createTextFinder(String textSelector) {
  if (textSelector.startsWith('contains:')) {
    String searchText = textSelector.substring(9);
    return find.textContaining(searchText);
  } else if (textSelector.startsWith('startsWith:')) {
    String prefix = textSelector.substring(11);
    return find.byWidgetPredicate((widget) {
      if (widget is Text) {
        final String? data = widget.data;
        return data != null && data.startsWith(prefix);
      }
      return false;
    });
  } else if (textSelector.startsWith('endsWith:')) {
    String suffix = textSelector.substring(9);
    return find.byWidgetPredicate((widget) {
      if (widget is Text) {
        final String? data = widget.data;
        return data != null && data.endsWith(suffix);
      }
      return false;
    });
  } else if (textSelector.startsWith('regex:')) {
    String pattern = textSelector.substring(6);
    RegExp regex = RegExp(pattern);
    return find.byWidgetPredicate((widget) {
      if (widget is Text) {
        final String? data = widget.data;
        return data != null && regex.hasMatch(data);
      }
      return false;
    });
  } else if (textSelector.startsWith('text:')) {
    // Explicit exact match
    String exactText = textSelector.substring(5);
    return find.text(exactText);
  } else {
    // Default to exact match for backward compatibility
    return find.text(textSelector);
  }
}

/// Creates a finder for the specified element with enhanced selector support.
///
/// Supports key:, type:, icon:, and flexible text selectors.
Future<Finder> createElementFinder(String element) async {
  if (element.startsWith('key:')) {
    String key = element.substring(4);
    return find.byKey(Key(key));
  } else if (element.startsWith('type:')) {
    Type type = await getType(element.substring(5));
    return find.byType(type);
  } else if (element.startsWith('icon:')) {
    String iconName = element.substring(5);
    return find.byIcon(getIconData(iconName));
  } else {
    // Use flexible text finder
    return createTextFinder(element);
  }
}

/// Returns the Type object for a given widget type name string.
///
/// Maps string names to Flutter widget types for dynamic widget finding.
Future<Type> getType(String type) async {
  Type returnType;
  final Map<String, Type> typeMap = {
    'AppBar': AppBar,
    'BottomNavigationBar': BottomNavigationBar,
    'Card': Card,
    'Column': Column,
    'Container': Container,
    'CupertinoNavigationBar': CupertinoNavigationBar,
    'ElevatedButton': ElevatedButton,
    'Expanded': Expanded,
    'FloatingActionButton': FloatingActionButton,
    'GridView': GridView,
    'Icon': Icon,
    'IconButton': IconButton,
    'Image': Image,
    'IndexedStack': IndexedStack,
    'ListView': ListView,
    'Material': Material,
    'Navigator': Navigator,
    'OutlinedButton': OutlinedButton,
    'Padding': Padding,
    'Row': Row,
    'Scaffold': Scaffold,
    'SizedBox': SizedBox,
    'Text': Text,
    'TextFormField': TextFormField,
    'CheckBox': Checkbox,
    'TextButton': TextButton,
    'TextField': TextField,
    // Add more common widget types
    'Switch': Switch,
    'Slider': Slider,
    'Radio': Radio,
    'DropdownButton': DropdownButton,
    'AlertDialog': AlertDialog,
    'SnackBar': SnackBar,
    'Drawer': Drawer,
    'BottomSheet': BottomSheet,
    'Tab': Tab,
    'TabBar': TabBar,
    'NavigationBar': NavigationBar,
    'RefreshIndicator': RefreshIndicator,
  };
  returnType = typeMap[type] ?? Text;
  return returnType;
}

/// Converts a Cucumber step string into executable Flutter test code.
///
/// Parses Gherkin/Cucumber step definitions and executes the corresponding
/// widget test actions using the provided [WidgetTester].
///
/// First attempts to execute any registered custom steps, then falls back
/// to built-in step implementations if no custom handler is found.
Future<void> getCucumberStepTestCode(String step, WidgetTester tester) async {
  // Remove any leading/trailing whitespace from the step
  step = step.trim();

  // Try custom steps first
  if (await CustomStepRegistry().tryExecuteCustomStep(step, tester)) {
    return; // Custom step was handled successfully
  }

  // Assume all steps are "When" steps and use the full text as the "text" component
  String keyword = 'When';
  String text = step;
  final pullToRefreshFinder = find.byType(RefreshIndicator);
  // Check if the step starts with a supported keyword
  if (step.startsWith('Given')) {
    keyword = 'Given';
    text = step.substring(6).trim();
  } else if (step.startsWith('When')) {
    keyword = 'When';
    text = step.substring(5).trim();
  } else if (step.startsWith('Then')) {
    keyword = 'Then';
    text = step.substring(5).trim();
  }

  // Build the Flutter test code based on the keyword and text components
  switch (keyword) {
    case 'Given':
      testWidgets(step, (WidgetTester tester) async {
        // test code goes here
      });
      break;
    case 'When':
      if (String.fromCharCode(text.codeUnitAt(0)) == "#") {
        //do nothing
      } else if (text.startsWith('I see ')) {
        String element = text.substring(6);
        Finder finder = await createElementFinder(element);
        await pumpUntilFound(tester, finder.first);
        expect(finder, findsOneWidget);
      } else if (text.startsWith('I do not see ') ||
          text.startsWith('I don\'t see ')) {
        String element = text.startsWith('I do not see ')
            ? text.substring(13)
            : text.substring(12);
        Finder finder = await createElementFinder(element);
        expect(finder, findsNothing);
      } else if (text.startsWith('field ') && text.contains(' contains ')) {
        List<String> parts = text.split(' contains ');
        String fieldPart = parts[0].substring(6); // Remove "field "
        String expectedValue = parts[1];

        if (fieldPart.startsWith('key:')) {
          String key = fieldPart.substring(4);
          final finder = find.byKey(Key(key));
          await pumpUntilFound(tester, finder);
          final widget = tester.widget(finder) as dynamic;
          if (widget is TextField) {
            expect(widget.controller?.text ?? '', equals(expectedValue));
          } else if (widget is TextFormField) {
            expect(widget.controller?.text ?? '', equals(expectedValue));
          }
        } else if (fieldPart.startsWith('type:')) {
          Type type = await getType(fieldPart.substring(5));
          final finder = find.byType(type);
          await pumpUntilFound(tester, finder);
          final widget = tester.widget(finder) as dynamic;
          if (widget is TextField) {
            expect(widget.controller?.text ?? '', equals(expectedValue));
          } else if (widget is TextFormField) {
            expect(widget.controller?.text ?? '', equals(expectedValue));
          }
        }
      } else if (text.startsWith('I can see ')) {
        // Alternative to "I see" for better readability
        String element = text.substring(10);
        Finder finder = await createElementFinder(element);
        await pumpUntilFound(tester, finder.first);
        expect(finder, findsOneWidget);
      } else if (text.startsWith('I refresh')) {
        await pumpUntilFound(tester, pullToRefreshFinder);
        await tester.drag(pullToRefreshFinder, const Offset(0.0, 200.0));
      } else if (text.startsWith('I settle')) {
        await tester.pumpAndSettle();
      } else if (text.startsWith('I trigger enter')) {
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      } else if (text.startsWith('I tap ')) {
        String element = text.substring(6);
        Finder finder = await createElementFinder(element);
        await pumpUntilFound(tester, finder);
        await tester.tap(finder.first);
      } else if (text.startsWith('I enter ')) {
        String element = text.substring(8).trim();

        String value = "";
        if (element.contains("in field with key:")) {
          List<String> inputParts = element.split("in field with key:");
          value = inputParts[0].trim();

          await pumpUntilFound(tester, find.byKey(Key(inputParts[1].trim())));
          await tester.enterText(find.byKey(Key(inputParts[1].trim())), value);
          // await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        } else if (element.contains("in field with type:")) {
          List<String> inputParts = element.split("in field with type:");
          Type type = await getType(inputParts[1].trim());
          value = inputParts[0].trim();

          await pumpUntilFound(tester, find.byType(type));
          await tester.enterText(find.byType(type), value);
          // await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        } else if (element.contains(" into ")) {
          List<String> inputParts = element.split(" into ");
          value = inputParts[0].trim();
          String targetElement = inputParts[1].trim();

          if (targetElement.startsWith('key:')) {
            String key = targetElement.substring(4);
            await pumpUntilFound(tester, find.byKey(Key(key)));
            await tester.enterText(find.byKey(Key(key)), value);
          } else if (targetElement.startsWith('type:')) {
            Type type = await getType(targetElement.substring(5));
            await pumpUntilFound(tester, find.byType(type));
            await tester.enterText(find.byType(type), value);
          } else {
            await pumpUntilFound(tester, find.text(targetElement));
            await tester.enterText(find.text(targetElement), value);
          }
        } else {
          List<String> inputParts = element.split("enter ");

          await pumpUntilFound(tester, find.byType(TextField));
          await tester.enterText(find.byType(TextField), inputParts[1].trim());

          // await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        }
      } else if (text.startsWith('I wait for ')) {
        String duration = text.substring(11);
        await pumpForSeconds(tester, int.parse(duration));
      } else if (text.startsWith('I long press ')) {
        String element = text.substring(13);
        if (element.startsWith('key:')) {
          String key = element.substring(4);
          await pumpUntilFound(tester, find.byKey(Key(key)));
          await tester.longPress(find.byKey(Key(key)).first);
        } else if (element.startsWith('type:')) {
          String typeName = element.substring(5);
          Type type = await getType(typeName);
          await pumpUntilFound(tester, find.byType(type));
          await tester.longPress(find.byType(type).first);
        } else {
          await pumpUntilFound(tester, find.text(element));
          await tester.longPress(find.text(element).first);
        }
      } else if (text.startsWith('I double tap ')) {
        String element = text.substring(13);
        if (element.startsWith('key:')) {
          String key = element.substring(4);
          await pumpUntilFound(tester, find.byKey(Key(key)));
          await tester.tap(find.byKey(Key(key)).first);
          await tester.pump(const Duration(milliseconds: 100));
          await tester.tap(find.byKey(Key(key)).first);
        } else if (element.startsWith('type:')) {
          String typeName = element.substring(5);
          Type type = await getType(typeName);
          await pumpUntilFound(tester, find.byType(type));
          await tester.tap(find.byType(type).first);
          await tester.pump(const Duration(milliseconds: 100));
          await tester.tap(find.byType(type).first);
        } else {
          await pumpUntilFound(tester, find.text(element));
          await tester.tap(find.text(element).first);
          await tester.pump(const Duration(milliseconds: 100));
          await tester.tap(find.text(element).first);
        }
      } else if (text.startsWith('I clear field ')) {
        String element = text.substring(14);
        if (element.startsWith('key:')) {
          String key = element.substring(4);
          await pumpUntilFound(tester, find.byKey(Key(key)));
          await tester.enterText(find.byKey(Key(key)), '');
        } else if (element.startsWith('type:')) {
          String typeName = element.substring(5);
          Type type = await getType(typeName);
          await pumpUntilFound(tester, find.byType(type));
          await tester.enterText(find.byType(type), '');
        } else {
          await pumpUntilFound(tester, find.byType(TextField));
          await tester.enterText(find.byType(TextField), '');
        }
      } else if (text.startsWith('I swipe ')) {
        List<String> parts = text.substring(8).split(' ');
        String direction = parts[0].toLowerCase();
        Offset offset;
        switch (direction) {
          case 'left':
            offset = const Offset(-300, 0);
            break;
          case 'right':
            offset = const Offset(300, 0);
            break;
          case 'up':
            offset = const Offset(0, -300);
            break;
          case 'down':
            offset = const Offset(0, 300);
            break;
          default:
            offset = const Offset(0, -300);
        }

        if (parts.length > 2 && parts[1] == 'on') {
          String element = parts.sublist(2).join(' ');
          if (element.startsWith('key:')) {
            String key = element.substring(4);
            await pumpUntilFound(tester, find.byKey(Key(key)));
            await tester.drag(find.byKey(Key(key)).first, offset);
          } else if (element.startsWith('type:')) {
            String typeName = element.substring(5);
            Type type = await getType(typeName);
            await pumpUntilFound(tester, find.byType(type));
            await tester.drag(find.byType(type).first, offset);
          } else {
            await pumpUntilFound(tester, find.text(element));
            await tester.drag(find.text(element).first, offset);
          }
        } else {
          // Swipe on the screen
          final gesture = await tester.startGesture(const Offset(200, 300));
          await gesture.moveBy(offset);
          await gesture.up();
          await tester.pump();
        }
      } else if (text.startsWith('I navigate back') ||
          text.startsWith('I go back')) {
        // Navigate back using system back button
        await tester.pageBack();
        await tester.pumpAndSettle();
      } else if (text.startsWith('I dismiss ')) {
        String element = text.substring(10);
        if (element.startsWith('key:')) {
          String key = element.substring(4);
          await pumpUntilFound(tester, find.byKey(Key(key)));
          await tester.tap(find.byKey(Key(key)).first);
        } else if (element.startsWith('type:')) {
          String typeName = element.substring(5);
          Type type = await getType(typeName);
          await pumpUntilFound(tester, find.byType(type));
          await tester.tap(find.byType(type).first);
        } else {
          // Try to find dismiss button or close button
          var dismissFinder = find.textContaining('Dismiss');
          var closeFinder = find.textContaining('Close');
          var okFinder = find.textContaining('OK');

          if (tester.any(dismissFinder)) {
            await tester.tap(dismissFinder.first);
          } else if (tester.any(closeFinder)) {
            await tester.tap(closeFinder.first);
          } else if (tester.any(okFinder)) {
            await tester.tap(okFinder.first);
          } else {
            await tester.tap(find.text(element).first);
          }
        }
      } else if (text.startsWith('I press ')) {
        String keyName = text.substring(8).toLowerCase();
        LogicalKeyboardKey key;
        switch (keyName) {
          case 'enter':
            key = LogicalKeyboardKey.enter;
            break;
          case 'escape':
            key = LogicalKeyboardKey.escape;
            break;
          case 'space':
            key = LogicalKeyboardKey.space;
            break;
          case 'tab':
            key = LogicalKeyboardKey.tab;
            break;
          case 'backspace':
            key = LogicalKeyboardKey.backspace;
            break;
          default:
            key = LogicalKeyboardKey.enter;
        }
        await tester.sendKeyEvent(key);
      } else if (text.startsWith('I wait until I see ')) {
        String element = text.substring(19);
        if (element.startsWith('key:')) {
          String key = element.substring(4);
          await pumpUntilFound(tester, find.byKey(Key(key)));
        } else if (element.startsWith('type:')) {
          Type type = await getType(element.substring(5));
          await pumpUntilFound(tester, find.byType(type));
        } else {
          await pumpUntilFound(tester, find.text(element));
        }
      } else if (text.startsWith('I pump ')) {
        String times = text.substring(7);
        int pumpCount = int.tryParse(times) ?? 1;
        for (int i = 0; i < pumpCount; i++) {
          await tester.pump();
        }
      } else if (text.startsWith('I scroll until I see ')) {
        String element = text.substring(21);
        if (element.startsWith('key:')) {
          String key = element.substring(4);
          await pumpForSeconds(tester, 5);
          await tester.dragUntilVisible(
            find.byKey(Key(key)).first,
            find.byKey(Key(key)).first,
            const Offset(0, -500),
          );
        } else {
          await pumpForSeconds(tester, 5);
          await tester.dragUntilVisible(
            find.text(element).first,
            find.text(element).first,
            const Offset(0, -500),
          );
        }
      } else if (step.startsWith('I scroll ')) {
        String direction = step.substring(9).trim().toLowerCase();
        if (direction == 'up') {
          final gesture = await tester.startGesture(const Offset(0, 300));
          await gesture.moveBy(const Offset(0, 300));
          await tester.pump();
        } else {
          final gesture = await tester.startGesture(const Offset(0, 300));
          await gesture.moveBy(const Offset(0, -300));
          await tester.pump();
        }
      } else {
        throw UnsupportedError('Unsupported text: $text');
      }
      break;
    case 'Then':
      if (String.fromCharCode(text.codeUnitAt(0)) == "#") {
        //do nothing
      } else if (text.startsWith('I see ')) {
        String element = text.substring(6);
        if (element.startsWith('key:')) {
          String key = element.substring(4);
          await pumpUntilFound(tester, find.byKey(Key(key)).first);
          expect(find.byKey(Key(key)).first, findsOneWidget);
        } else if (element.startsWith('type:')) {
          Type type = await getType(element.substring(5));
          await pumpUntilFound(tester, find.byType(type).first);
          expect(find.byType(type).first, findsOneWidget);
        } else {
          await pumpUntilFound(tester, find.text(element));
          expect(find.text(element).first, findsOneWidget);
        }
      } else if (text.startsWith('I refresh')) {
        await pumpUntilFound(tester, pullToRefreshFinder);
        await tester.drag(pullToRefreshFinder, const Offset(0.0, 200.0));
      } else if (text.startsWith('I settle')) {
        await tester.pumpAndSettle();
      } else if (text.startsWith('I trigger enter')) {
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      } else if (text.startsWith('I tap ')) {
        String element = text.substring(6);
        if (element.startsWith('key:')) {
          String key = element.substring(4);
          await pumpUntilFound(tester, find.byKey(Key(key)));
          await tester.tap(find.byKey(Key(key)).first);
        } else if (element.startsWith('type:')) {
          String typeName = element.substring(5);
          Type type = await getType(typeName);
          await pumpUntilFound(tester, find.byType(type));
          await tester.tap(find.byType(type).first);
        } else if (element.startsWith('icon:')) {
          String iconName = element.substring(5);
          await pumpUntilFound(tester, find.byIcon(getIconData(iconName)));
          await tester.tap(find.byIcon(getIconData(iconName)).first);
        } else {
          await pumpUntilFound(tester, find.text(element));
          await tester.tap(find.text(element).first);
        }
      } else if (text.startsWith('I enter ')) {
        String element = text.substring(8).trim();

        String value = "";
        if (element.contains("in field with key:")) {
          List<String> inputParts = element.split("in field with key:");
          value = inputParts[0].trim();

          await pumpUntilFound(tester, find.byKey(Key(inputParts[1].trim())));
          await tester.enterText(find.byKey(Key(inputParts[1].trim())), value);
          // await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        } else if (element.contains("in field with type:")) {
          List<String> inputParts = element.split("in field with type:");

          Type type = await getType(inputParts[1].trim());
          value = inputParts[0].trim();

          await pumpUntilFound(tester, find.byType(type));
          await tester.enterText(find.byType(type), value);
          // await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        } else {
          List<String> inputParts = element.split("enter ");

          await pumpUntilFound(tester, find.byType(TextField));
          await tester.enterText(find.byType(TextField), inputParts[1].trim());
          // await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        }
      } else if (text.startsWith('I wait for ')) {
        String duration = text.substring(11);
        await pumpForSeconds(tester, int.parse(duration));
      } else if (text.startsWith('I scroll until I see ')) {
        String element = text.substring(21);
        if (element.startsWith('key:')) {
          String key = element.substring(4);
          await pumpForSeconds(tester, 5);
          await tester.dragUntilVisible(
            find.byKey(Key(key)).first,
            find.byKey(Key(key)).first,
            const Offset(0, -500),
          );
        } else {
          await pumpForSeconds(tester, 5);
          await tester.dragUntilVisible(
            find.text(element).first,
            find.text(element).first,
            const Offset(0, -500),
          );
        }
      } else if (step.startsWith('I scroll ')) {
        String direction = step.substring(9).trim().toLowerCase();
        if (direction == 'up') {
          final gesture = await tester.startGesture(const Offset(0, 300));
          await gesture.moveBy(const Offset(0, 300));
          await tester.pump();
        } else {
          final gesture = await tester.startGesture(const Offset(0, 300));
          await gesture.moveBy(const Offset(0, -300));
          await tester.pump();
        }
      } else {
        throw UnsupportedError('Unsupported text: $text');
      }
      break;
    default:
      throw UnsupportedError('Unsupported keyword: $keyword');
  }
}
