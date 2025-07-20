import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'converter.dart';

/// Parses a pickle file and executes Cucumber steps using the provided WidgetTester.
///
/// The [tester] is the WidgetTester instance used for widget testing.
/// The [dir] is the path to the pickle file to parse.
Future<void> pickleParser(WidgetTester tester, String dir) async {
  final featureString = await rootBundle.loadString(dir);

  List<String> lines = featureString.split("\n");

  for (String line in lines) {
    if (line != "") {
      try {
        await getCucumberStepTestCode(line, tester);
        dev.log("success: $line");
      } catch (err) {
        dev.log("failed: $line");
        dev.log("error: $err");
      }
    }
  }
}
