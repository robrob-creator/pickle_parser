/// A Flutter package for parsing pickle files and executing Cucumber steps in widget tests.
///
/// This library provides functionality to parse Gherkin/Cucumber pickle files
/// and execute the corresponding test steps using Flutter's widget testing framework.
///
/// The main entry point is the [pickleParser] function which takes a [WidgetTester]
/// and the path to a pickle file, then executes the Cucumber steps defined in the file.
library pickle_parser;

export 'src/converter.dart';
export 'src/parser.dart';
export 'src/custom_steps.dart';
