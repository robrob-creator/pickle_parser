import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'converter.dart';

Future<void> pickleParser(WidgetTester tester, String dir) async {
  final featureString = await rootBundle.loadString(dir);

  List<String> lines = featureString.split("\n");

  for (String line in lines) {
    await getCucumberStepTestCode(line, tester);
  }
}
