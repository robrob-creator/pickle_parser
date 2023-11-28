<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Pickle Parser

A Flutter package for parsing pickle files and executing Cucumber steps in widget tests.

### Overview

The Pickle Parser package provides a convenient way to parse pickle files and execute Cucumber steps in Flutter widget tests. It includes a pickleParser function that takes a WidgetTester and the directory of the pickle file as input, then iterates through the file's lines, executing Cucumber steps and logging the results.

### Installation

To use this package, add pickle_parser as a dependency in your pubspec.yaml file:
yaml

dependencies: pickle_parser: ^1.0.0
Then run:
bash

flutter pub get

### Features

Cucumber Steps Execution: The package executes Cucumber steps defined in the pickle file within a Flutter widget test.
Logging: Successful and failed steps are logged using Dart's dart:developer package, providing visibility into the test execution process.
Issues and Contributions
If you encounter any issues or have suggestions for improvements, feel free to create an issue on the GitHub repository.
Pull requests are welcome!

### License

This project is licensed under the MIT License - see the LICENSE file for details.

### Usage

Here's an example of how to use the pickle parser in your tests:

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickle_parser/pickle_parser.dart';

void main() {
  testWidgets('Pickle Parser Test', (WidgetTester tester) async {
    await pickleParser(tester, 'path/to/your/pickle/file.feature');
  });
}
```
