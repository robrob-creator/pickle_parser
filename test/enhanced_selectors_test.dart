import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pickle_parser/src/converter.dart';

void main() {
  group('Enhanced Text Finders', () {
    testWidgets('createTextFinder should handle various text selectors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Hello World'),
                Text('Welcome to the app'),
                Text('Error: Something went wrong'),
                Text('Success message'),
              ],
            ),
          ),
        ),
      );

      // Test exact text (default)
      var finder = createTextFinder('Hello World');
      expect(finder, findsOneWidget);

      // Test contains
      finder = createTextFinder('contains:Welcome');
      expect(finder, findsOneWidget);

      // Test startsWith
      finder = createTextFinder('startsWith:Error');
      expect(finder, findsOneWidget);

      // Test endsWith
      finder = createTextFinder('endsWith:message');
      expect(finder, findsOneWidget);

      // Test regex
      finder = createTextFinder('regex:^Error.*wrong\$');
      expect(finder, findsOneWidget);

      // Test explicit text
      finder = createTextFinder('text:Hello World');
      expect(finder, findsOneWidget);
    });

    testWidgets('createElementFinder should handle all selector types',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(key: Key('test_container')),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Click Me'),
                ),
                Icon(Icons.add),
                Text('contains:partial text'),
              ],
            ),
          ),
        ),
      );

      // Test key selector
      var finder = await createElementFinder('key:test_container');
      expect(finder, findsOneWidget);

      // Test type selector
      finder = await createElementFinder('type:ElevatedButton');
      expect(finder, findsOneWidget);

      // Test icon selector
      finder = await createElementFinder('icon:add');
      expect(finder, findsOneWidget);

      // Test enhanced text selector
      finder = await createElementFinder('contains:partial');
      expect(finder, findsOneWidget);
    });
  });
}
