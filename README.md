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

2. Version Formats:

   - Without build number: `1.0.0` (default)
   - With build number: `1.0.0+1` (optional)

3. Build Number Options:
   - Simple increment: Increases the build number by 1
   - Date-based format: Uses format `yymmddbn` where:
     - `yy`: Year (e.g., 24 for 2024)
     - `mm`: Month (01-12)
     - `dd`: Day (01-31)
     - `bn`: Build number for the day (00-99)

For detailed information about version management, including examples and best practices, see our [Version Management Guide](docs/version_management.md).

Basic usage examples:

```sh
# Semantic Version Bumping (preserves format)
$ version_assist bump --major    # 1.0.0 -> 2.0.0
$ version_assist bump --minor    # 1.0.0 -> 1.1.0
$ version_assist bump --patch    # 1.0.0 -> 1.0.1

# Build Number Management
$ version_assist bump --add-build-number          # 1.0.0 -> 1.0.0+1
$ version_assist bump --date-based-build-number   # 1.0.0 -> 1.0.0+24020800
$ version_assist bump --no-build-number           # 1.0.0+1 -> 1.0.0

# Combined Operations
$ version_assist bump --major --add-build-number  # 1.0.0 -> 2.0.0+1
$ version_assist bump --minor --no-build-number   # 1.0.0+1 -> 1.1.0

# Preview changes without making them
$ version_assist bump --dry-run
```

### Set Version

Manually set a specific version number:

```sh
# Set version without build number
$ version_assist set --version 2.0.0    # Sets version to 2.0.0

# Set version with build number
$ version_assist set --version 2.0.0+1  # Sets version to 2.0.0+1

# Preview changes without making them
$ version_assist set --version 2.0.0 --dry-run

# Set version and create commit/tag
$ version_assist set --version 2.0.0 --auto-commit
```

Options:

- `--version, -v`: Version to set (required, format: x.y.z or x.y.z+build)
- `--path, -p`: Path to pubspec.yaml (default: pubspec.yaml)
- `--dry-run, -d`: Show what would happen without making changes
- `--auto-commit`: Automatically commit and tag the version change

### Version Control

The tool provides two ways to create version commits and tags:

1. Using the `commit` command (recommended):

   ```sh
   # First bump the version
   $ version_assist bump --major

   # Then create the commit and tag
   $ version_assist commit
   ```

2. Using the `--auto-commit` flag with bump (legacy):
   ```sh
   $ version_assist bump --major --auto-commit
   ```

Both approaches will:

1. Stage pubspec.yaml with `git add`
2. Create a commit with the message: `build(version): Bump version to {version}`
3. Create a git tag with the version

The separate `commit` command provides more flexibility and can be used independently:

```sh
# Create version commit and tag
$ version_assist commit

# Preview commit without making changes
$ version_assist commit --dry-run

# Use custom pubspec path
$ version_assist commit --path=/path/to/pubspec.yaml
```

### Update Version Badge

Updates the version badge in README.md to match the current version in pubspec.yaml. This is useful for keeping your documentation in sync with your package version.

```sh
# Update version badge
$ version_assist badge

# Preview changes without making them
$ version_assist badge --dry-run

# Use custom file paths
$ version_assist badge --pubspec-path=/path/to/pubspec.yaml --readme-path=/path/to/README.md
```

Options:

- `--pubspec-path, -p`: Path to pubspec.yaml (default: pubspec.yaml)
- `--readme-path, -r`: Path to README.md (default: README.md)
- `--dry-run, -d`: Show what would happen without making changes

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
[pub_version_badge]: https://img.shields.io/badge/pub-v1.3.3-blue
[pub_package_link]: https://pub.dev/packages/version_assist
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
