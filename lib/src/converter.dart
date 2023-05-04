import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpForSeconds(WidgetTester tester, int seconds) async {
  bool timerDone = false;
  Timer(Duration(seconds: seconds), () => timerDone = true);
  while (timerDone != true) {
    await tester.pump();
  }
}

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
    print(finder);
    final found = tester.any(finder);
    if (found) {
      timerDone = true;
      break;
    }
  }
  timer.cancel();
}

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
  };
  returnType = typeMap[type] ?? Text;
  return returnType;
}

Future<void> getCucumberStepTestCode(String step, WidgetTester tester) async {
  // Remove any leading/trailing whitespace from the step
  step = step.trim();

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
        if (element.startsWith('key:')) {
          String key = element.substring(4);
          await pumpUntilFound(tester, find.byKey(Key(key)));
          expect(find.byKey(Key(key)), findsOneWidget);
        } else if (element.startsWith('type:')) {
          Type type = await getType(element.substring(5));
          await pumpUntilFound(tester, find.byType(type));
          expect(find.byType(type), findsOneWidget);
        } else {
          await pumpUntilFound(tester, find.text(element));
          expect(find.text(element), findsOneWidget);
        }
      } else if (text.startsWith('I refresh')) {
        await pumpUntilFound(tester, pullToRefreshFinder);
        await tester.drag(pullToRefreshFinder, const Offset(0.0, 200.0));
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
      } else if (step.startsWith('I scroll')) {
        String direction = step.substring(8).trim().toLowerCase();
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
          await pumpUntilFound(tester, find.byKey(Key(key)));
          expect(find.byKey(Key(key)), findsOneWidget);
        } else if (element.startsWith('type:')) {
          Type type = await getType(element.substring(5));
          await pumpUntilFound(tester, find.byType(type));
          expect(find.byType(type), findsOneWidget);
        } else {
          await pumpUntilFound(tester, find.text(element));
          expect(find.text(element), findsOneWidget);
        }
      } else if (text.startsWith('I refresh')) {
        await pumpUntilFound(tester, pullToRefreshFinder);
        await tester.drag(pullToRefreshFinder, const Offset(0.0, 200.0));
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
      } else if (step.startsWith('I scroll')) {
        String direction = step.substring(8).trim().toLowerCase();
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
