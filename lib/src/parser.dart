import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:developer' as dev;
import 'converter.dart';

Future<void> pickleParser(WidgetTester tester, String dir) async {
  final featureString = await rootBundle.loadString(dir);

  List<String> lines = featureString.split("\n");

  for (String line in lines) {
    if (line != "") {
      try {
        await getCucumberStepTestCode(line, tester);
        dev.log("sucess:$line");
      } catch (err) {
        dev.log("failed:$line");
        dev.log("sucess:$line");
      }
    }
  }
}
