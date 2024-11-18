# Version Management Guide

This guide explains how to use version_assist to manage your library's version numbers.

## Running Commands

You can run version_assist commands in two ways:

### 1. Using the Global CLI (After Installation)

If you've installed version_assist globally:

```bash
version_assist bump [options]
version_assist set [options]
```

### 2. Running Locally (During Development)

If you're working with the local source code:

```bash
# From the version_assist directory
dart run bin/version_assist.dart bump [options]
dart run bin/version_assist.dart set [options]

# Or from any directory, specify the full path
dart run /path/to/version_assist/bin/version_assist.dart bump [options]
dart run /path/to/version_assist/bin/version_assist.dart set [options]
```

## Version Format

The tool supports two version formats:
1. With build number: `{major}.{minor}.{patch}+{build}`
   - Example: `1.0.0+1`
2. Without build number: `{major}.{minor}.{patch}`
   - Example: `1.0.0`

## Version Components

### Semantic Version (major.minor.patch)
- **Major** (x.0.0): Increment when making incompatible API changes
- **Minor** (0.x.0): Increment when adding functionality in a backwards compatible manner
- **Patch** (0.0.x): Increment when making backwards compatible bug fixes

### Build Number (Optional)
Two formats available:
1. **Simple Increment**: Increases the build number by 1
2. **Date-based**: Format `yymmddbn` where:
   - `yy`: Year (e.g., 24 for 2024)
   - `mm`: Month (01-12)
   - `dd`: Day (01-31)
   - `bn`: Build number for the day (00-99)

## Version Management Commands

### Bump Command

The bump command incrementally updates version numbers based on semantic versioning rules:

```bash
# Semantic Version Bumping
version_assist bump --major    # 1.0.0 -> 2.0.0
version_assist bump --minor    # 1.0.0 -> 1.1.0
version_assist bump --patch    # 1.0.0 -> 1.0.1
```

### Set Command

The set command allows you to manually specify a version number:

```bash
# Set specific version
version_assist set --version 2.0.0     # Sets to 2.0.0
version_assist set --version 2.0.0+1   # Sets to 2.0.0+1

# Preview changes
version_assist set --version 2.0.0 --dry-run

# Set version with auto-commit
version_assist set --version 2.0.0 --auto-commit
```

Options:
- `--version, -v`: Version to set (required, format: x.y.z or x.y.z+build)
- `--path, -p`: Path to pubspec.yaml (default: pubspec.yaml)
- `--dry-run, -d`: Show what would happen without making changes
- `--auto-commit`: Automatically commit and tag the version change

## Git Operations

### Automatic Commit Control

By default, version changes do NOT automatically create git commits or tags. 
Use the `--auto-commit` flag to enable automatic git operations.

```bash
# Manually change version without git operations (default behavior)
version_assist bump --major
version_assist set --version 2.0.0

# Automatically commit and tag the version change
version_assist bump --major --auto-commit
version_assist set --version 2.0.0 --auto-commit
```

When `--auto-commit` is used, the tool will:
1. Update the version in pubspec.yaml
2. Stage the changes with `git add`
3. Create a commit with the message: `build(version): Bump version to {new_version}`
4. Create a git tag with the new version

## Usage Examples

### Semantic Version Updates

```bash
# With build number increment
version_assist bump --major    # 1.0.0+1 -> 2.0.0+2
version_assist bump --minor    # 1.0.0+1 -> 1.1.0+2
version_assist bump --patch    # 1.0.0+1 -> 1.0.1+2

# Without build number
version_assist bump --major --no-build-number-update  # 1.0.0 -> 2.0.0
version_assist bump --minor --no-build-number-update  # 1.0.0 -> 1.1.0
version_assist bump --patch --no-build-number-update  # 1.0.0 -> 1.0.1

# Manual version setting
version_assist set --version 2.0.0     # Sets to 2.0.0
version_assist set --version 2.0.0+1   # Sets to 2.0.0+1
```

### Build Number Updates

```bash
# Simple increment
version_assist bump                           # 1.0.0+1 -> 1.0.0+2

# Date-based format
version_assist bump --date-based-build-number # 1.0.0+1 -> 1.0.0+24020700

# Keep current build number
version_assist bump --no-build-number-update  # 1.0.0+1 -> 1.0.0+1
                                            # 1.0.0 -> 1.0.0
```

### Combined Updates with Git Operations

```bash
# Major version with date-based build number and auto-commit
version_assist bump --major --date-based-build-number --auto-commit  # 1.0.0+1 -> 2.0.0+24020700

# Minor version keeping current build number and auto-commit
version_assist bump --minor --no-build-number-update --auto-commit   # 1.0.0+1 -> 1.1.0+1

# Set specific version with auto-commit
version_assist set --version 2.0.0 --auto-commit                     # Sets to 2.0.0 and creates commit/tag
```

Note: 
- `--date-based-build-number` and `--no-build-number-update` cannot be used together
- `--auto-commit` is optional and disabled by default

### Preview Changes

Use the dry-run option to preview changes without applying them:

```bash
# Preview bump with build number
version_assist bump --major --dry-run                 # Shows: 1.0.0+1 -> 2.0.0+2

# Preview bump without build number
version_assist bump --major --no-build-number-update --dry-run  # Shows: 1.0.0 -> 2.0.0

# Preview set version
version_assist set --version 2.0.0 --dry-run         # Shows: 1.0.0 -> 2.0.0
```

### Custom Pubspec Location

If your pubspec.yaml is not in the current directory:

```bash
version_assist bump --path=/path/to/pubspec.yaml
version_assist set --version 2.0.0 --path=/path/to/pubspec.yaml
```

## Examples

### Example 1: Package Version Without Auto-Commit

Starting version: `1.0.0`

```bash
version_assist bump --major
# or
version_assist set --version 2.0.0
```

Result:
- New version: `2.0.0`
- No git operations performed

### Example 2: Package Version With Auto-Commit

Starting version: `1.0.0`

```bash
version_assist bump --major --auto-commit
# or
version_assist set --version 2.0.0 --auto-commit
```

Result:
- New version: `2.0.0`
- Git commit created
- Git tag '2.0.0' created

### Example 3: Date-based Build with Auto-Commit

Starting version: `1.0.0+1`

```bash
version_assist bump --date-based-build-number --auto-commit
```

Result (if today is February 7, 2024):
- New version: `1.0.0+24020700`
- Git commit created
- Git tag '1.0.0+24020700' created

## Quick Tips

1. Always use `--dry-run` first to preview changes
2. Use `--date-based-build-number` when you want to track builds by date
3. Use `--no-build-number-update` when:
   - You want to maintain a version without build number
   - You want to keep the current build number while updating the version
4. Use `--auto-commit` when you want automatic git operations
5. Remember to pull latest changes before changing versions
6. Use the `set` command when you need to specify an exact version number
7. Use the `bump` command for incremental version updates
