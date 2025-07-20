## 1.0.3

- Fixed typos in logging ("sucess" -> "success")
- Fixed duplicate logging in error handling
- Added comprehensive dartdoc documentation
- Added unit tests for core functionality
- Added example usage
- Cleaned up unnecessary dependencies
- Improved package description

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
