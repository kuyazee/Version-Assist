# Version Management Guide

This guide explains how to use version_assist to manage your library's version numbers.

## Running Commands

You can run version_assist commands in two ways:

### 1. Using the Global CLI (After Installation)

If you've installed version_assist globally:

```bash
version_assist bump [options]
```

### 2. Running Locally (During Development)

If you're working with the local source code:

```bash
# From the version_assist directory
dart run bin/version_assist.dart bump [options]

# Or from any directory, specify the full path
dart run /path/to/version_assist/bin/version_assist.dart bump [options]
```

## Version Format

The version format follows the standard Dart/Flutter convention:
```
version: {major}.{minor}.{patch}+{build}
```

Example: `1.0.0+1`

## Version Components

### Semantic Version (major.minor.patch)
- **Major** (x.0.0): Increment when making incompatible API changes
- **Minor** (0.x.0): Increment when adding functionality in a backwards compatible manner
- **Patch** (0.0.x): Increment when making backwards compatible bug fixes

### Build Number
Two formats available:
1. **Simple Increment**: Increases the build number by 1
2. **Date-based**: Format `yymmddbn` where:
   - `yy`: Year (e.g., 24 for 2024)
   - `mm`: Month (01-12)
   - `dd`: Day (01-31)
   - `bn`: Build number for the day (00-99)

## Usage Examples

### Semantic Version Updates

```bash
# Using global CLI
version_assist bump --major    # 1.0.0+1 -> 2.0.0+2
version_assist bump --minor    # 1.0.0+1 -> 1.1.0+2
version_assist bump --patch    # 1.0.0+1 -> 1.0.1+2

# Using local source
dart run bin/version_assist.dart bump --major
dart run bin/version_assist.dart bump --minor
dart run bin/version_assist.dart bump --patch
```

### Build Number Updates

```bash
# Using global CLI
version_assist bump                           # Simple increment
version_assist bump --date-based-build-number # Date-based format

# Using local source
dart run bin/version_assist.dart bump
dart run bin/version_assist.dart bump --date-based-build-number
```

### Combined Updates

You can combine semantic version updates with build number formats:

```bash
# Using global CLI
version_assist bump --major --date-based-build-number
version_assist bump --minor --date-based-build-number
version_assist bump --patch --date-based-build-number

# Using local source
dart run bin/version_assist.dart bump --major --date-based-build-number
dart run bin/version_assist.dart bump --minor --date-based-build-number
dart run bin/version_assist.dart bump --patch --date-based-build-number
```

### Preview Changes

Use the dry-run option to preview changes without applying them:

```bash
# Using global CLI
version_assist bump --major --dry-run
version_assist bump --date-based-build-number --dry-run

# Using local source
dart run bin/version_assist.dart bump --major --dry-run
dart run bin/version_assist.dart bump --date-based-build-number --dry-run
```

### Custom Pubspec Location

If your pubspec.yaml is not in the current directory:

```bash
# Using global CLI
version_assist bump --path=/path/to/pubspec.yaml

# Using local source
dart run bin/version_assist.dart bump --path=/path/to/pubspec.yaml
```

## Automatic Git Operations

When you bump the version, the tool automatically:

1. Updates the version in pubspec.yaml
2. Creates a git commit with the message:
   ```
   build(version): Bump version to {new_version}
   ```
3. Creates a git tag with the new version

## Examples

### Example 1: Major Version Release

Starting version: `1.0.0+1`

```bash
# Using global CLI
version_assist bump --major

# Using local source
dart run bin/version_assist.dart bump --major
```

Result:
- New version: `2.0.0+2`
- Git commit created
- Git tag '2.0.0+2' created

### Example 2: Date-based Build for Today

Starting version: `1.0.0+1`

```bash
# Using global CLI
version_assist bump --date-based-build-number

# Using local source
dart run bin/version_assist.dart bump --date-based-build-number
```

Result (if today is February 7, 2024):
- New version: `1.0.0+24020700`
- Git commit created
- Git tag '1.0.0+24020700' created

### Example 3: Minor Update with Date-based Build

Starting version: `1.0.0+24020700`

```bash
# Using global CLI
version_assist bump --minor --date-based-build-number

# Using local source
dart run bin/version_assist.dart bump --minor --date-based-build-number
```

Result:
- New version: `1.1.0+24020701`
- Git commit created
- Git tag '1.1.0+24020701' created

## Quick Tips

1. Always use `--dry-run` first to preview changes
2. Use `--date-based-build-number` when you want to track builds by date
3. Remember to pull latest changes before bumping versions
4. The tool automatically handles git operations, no need for manual commits
