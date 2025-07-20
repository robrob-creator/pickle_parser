import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickle_parser/pickle_parser.dart';

void main() {
  group('Pickle Parser', () {
    testWidgets('pickleParser function exists and is callable',
        (WidgetTester tester) async {
      // This test verifies that the pickleParser function can be called
      // In a real test, you would load an actual pickle file
      expect(pickleParser, isA<Function>());
    });
  });

  group('Type Converter', () {
    test('getType returns correct types for known widgets', () async {
      final textType = await getType('Text');
      expect(textType, equals(Text));

      final containerType = await getType('Container');
      expect(containerType, equals(Container));
    });

    test('getType returns Text for unknown widget types', () async {
      final unknownType = await getType('UnknownWidget');
      expect(unknownType, equals(Text));
    });
  });

  group('Icon Converter', () {
    test('getIconData returns correct icons for known names', () {
      final addIcon = getIconData('add');
      expect(addIcon, equals(Icons.add));

      final deleteIcon = getIconData('delete');
      expect(deleteIcon, equals(Icons.delete));
    });

    test('getIconData throws exception for unknown icon names', () {
      expect(() => getIconData('unknown_icon'), throwsException);
    });
  });
}
