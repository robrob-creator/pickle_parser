## 1.1.2

### Improvements

- 📖 **Documentation**: Restored Buy Me a Coffee support section
- 🏷️ **Package Metadata**: Added comprehensive topics for better discoverability
  - testing, cucumber, gherkin, bdd, widget-testing, automation, flutter-testing, pickle, test-automation, behavior-driven-development

## 1.1.1

### Major New Features

- 🔧 **Custom Steps**: Added comprehensive support for custom step implementations
  - `registerCustomStep()` - Register exact text match steps
  - `registerCustomStepPattern()` - Register regex pattern steps
  - `registerCustomStepTemplate()` - Register template-based steps with placeholders
  - `CustomStepRegistry` - Full registry management for advanced scenarios
  - Priority system: Custom steps checked first, fallback to built-in steps
  - Comprehensive test suite and documentation

### Improvements

- 📖 **Enhanced Documentation**: Added detailed custom steps guide with examples
- 🏗️ **Better Architecture**: Modular step processing with extensibility support
- ✅ **Feature Completeness**: Addressed major limitation of no custom step support

### Breaking Changes

- None - all changes are backward compatible

## 1.0.4

- Added Buy Me a Coffee support link to README
- Updated documentation formatting

## 1.0.3

### New Features

- ✨ **Enhanced Text Matching**: Added support for flexible text selectors
  - `contains:text` - Find text containing substring
  - `startsWith:text` - Find text starting with prefix
  - `endsWith:text` - Find text ending with suffix
  - `regex:pattern` - Find text matching regex pattern
  - `text:exact` - Explicit exact text matching
- 🛠️ **CLI Tools**: Added command-line validation and code generation
  - `--validate` - Validate feature file syntax and steps
  - `--generate` - Generate test skeletons from feature files
  - Verbose output and detailed error reporting

### Improvements

- 🎯 **Simplified Element Finding**: Unified element finder supporting all selector types
- 📖 **Better Documentation**: Comprehensive usage examples and troubleshooting guide
- 🐛 **Bug Fixes**: Fixed typos and improved error logging

### Breaking Changes

- None - all changes are backward compatible

## 1.0.0

- Initial version.
