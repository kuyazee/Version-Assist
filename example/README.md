# Version Assist Example

This example demonstrates how to programmatically use version_assist to manage version numbers in your Flutter/Dart projects.

## Features Demonstrated

The example shows how to:

1. Set up the command runner with version_assist commands
2. Bump version numbers (major, minor, patch)
3. Add and manage build numbers
4. Create version commits and tags
5. Update version badges in README
6. Preview changes with dry run
7. Use date-based build numbers
8. Work with custom pubspec paths
9. Combine version bumping with auto-commit

## Usage

```dart
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:version_assist/src/commands/commit_command.dart';
import 'package:version_assist/src/commands/update_badge_command.dart';
import 'package:version_assist/src/commands/version_bump_command.dart';
import 'package:version_assist/src/commands/version_set_command.dart';

void main() async {
  // Initialize command runner
  final logger = Logger();
  final runner = CommandRunner<int>(
    'version_assist',
    'A CLI tool for managing version numbers in Flutter/Dart projects.',
  );

  // Add version_assist commands
  runner.addCommand(VersionBumpCommand(logger: logger));
  runner.addCommand(VersionSetCommand(logger: logger));
  runner.addCommand(CommitCommand(logger: logger));
  runner.addCommand(UpdateBadgeCommand(logger: logger));

  // Use commands with various options
  await runner.run(['bump', '--major', '--add-build-number']);
  await runner.run(['set', '--version', '2.0.0+1']);
  await runner.run(['commit']);
  await runner.run(['badge']);
}
```

See [main.dart](main.dart) for the complete example with all features demonstrated.

## Command Options

### Bump Version
```bash
bump [options]
--major                      # Bump major version (x.0.0)
--minor                      # Bump minor version (0.x.0)
--patch                      # Bump patch version (0.0.x)
--add-build-number          # Add or update build number
--date-based-build-number   # Use date-based format (yymmddbn)
--no-build-number           # Remove build number
--auto-commit               # Auto commit and tag
--dry-run                   # Preview changes
--path                      # Custom pubspec path
```

### Set Version
```bash
set [options]
--version                   # Version to set (x.y.z or x.y.z+build)
--dry-run                   # Preview changes
--path                      # Custom pubspec path
```

### Commit Version
```bash
commit [options]
--dry-run                   # Preview changes
--path                      # Custom pubspec path
```

### Update Badge
```bash
badge [options]
--dry-run                   # Preview changes
--pubspec-path             # Custom pubspec path
--readme-path              # Custom README path
