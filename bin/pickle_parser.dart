#!/usr/bin/env dart
// Entry point for the pickle_parser CLI tool
// This delegates to the actual CLI implementation in tool/cli

import '../tool/cli/bin/pickle_parser_cli.dart' as cli;

void main(List<String> arguments) {
  cli.main(arguments);
}
