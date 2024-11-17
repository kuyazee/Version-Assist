## version_assist

![coverage][coverage_badge]
[![pub package][pub_version_badge]][pub_package_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A CLI tool for managing version numbers in Flutter/Dart projects.

## Installation 🚀

If the CLI application is available on [pub](https://pub.dev), activate globally via:

```sh
dart pub global activate version_assist
```

## Local Development 🛠️

1. Clone the repository:

```sh
git clone git@github.com:kuyazee/Version-Assist.git
cd version_assist
```

2. Install dependencies:

```sh
dart pub get
```

3. Run locally during development:

```sh
# Run directly with Dart
dart run bin/version_assist.dart bump

# Or use the make command if available
dart run bin/version_assist.dart bump --path=/path/to/pubspec.yaml
```

4. Activate locally for testing:

```sh
# From the version_assist directory
dart pub global activate --source path .

# Now you can run it like a global command
version_assist bump
```

## Usage

### Bump Version

The tool supports several versioning options:

1. Semantic Versioning (major.minor.patch):

   - Major version (x.0.0): Breaking changes
   - Minor version (0.x.0): New features, backwards compatible
   - Patch version (0.0.x): Bug fixes, backwards compatible

2. Build Number Formats:
   - Simple increment: Increases the build number by 1
   - Date-based format: Uses format `yymmddbn` where:
     - `yy`: Year (e.g., 24 for 2024)
     - `mm`: Month (01-12)
     - `dd`: Day (01-31)
     - `bn`: Build number for the day (00-99)

For detailed information about version management, including examples and best practices, see our [Version Management Guide](docs/version_management.md).

Basic usage examples:

```sh
# Semantic Version Bumping
$ version_assist bump --major    # 1.0.0 -> 2.0.0
$ version_assist bump --minor    # 1.0.0 -> 1.1.0
$ version_assist bump --patch    # 1.0.0 -> 1.0.1

# Build Number Options
$ version_assist bump                  # Simple increment
$ version_assist bump --date-based-build-number     # Date-based format

# Preview changes without making them
$ version_assist bump --dry-run
```

The tool will automatically:

1. Update the version in pubspec.yaml
2. Create a git commit with the message format:
   ```
   build(version): Bump version to {new_version}
   ```
3. Create a git tag with the new version

### Update CLI

Update the CLI tool to the latest version.

```sh
$ version_assist update
```

### General Commands

```sh
# Show CLI version
$ version_assist --version

# Show usage help
$ version_assist --help
```

## Running Tests with coverage 🧪

To run all unit tests use the following command:

```sh
$ dart pub global activate coverage 1.2.0
$ dart test --coverage=coverage
$ dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
$ genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
$ open coverage/index.html
```

For detailed information about our testing requirements (minimum 80% coverage), best practices, and guidelines, see our [Testing Documentation](docs/testing.md).

---

[coverage_badge]: coverage_badge.svg
[pub_version_badge]: https://img.shields.io/badge/pub-v0.0.1-blue
[pub_package_link]: https://pub.dev/packages/version_assist
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
