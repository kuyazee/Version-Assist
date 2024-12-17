import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:version_assist/src/commands/commit_command.dart';
import 'package:version_assist/src/commands/update_badge_command.dart';
import 'package:version_assist/src/commands/version_bump_command.dart';
import 'package:version_assist/src/commands/version_set_command.dart';

/// This example demonstrates how to programmatically use version_assist
/// to manage version numbers in your Flutter/Dart projects.
Future<void> main() async {
  final logger = Logger();
  final runner = CommandRunner<int>(
    'version_assist',
    'A CLI tool for managing version numbers in Flutter/Dart projects.',
  );

  // Add commands to the runner
  runner.addCommand(VersionBumpCommand(logger: logger));
  runner.addCommand(VersionSetCommand(logger: logger));
  runner.addCommand(CommitCommand(logger: logger));
  runner.addCommand(UpdateBadgeCommand(logger: logger));

  // Example 1: Bump major version with build number
  await runner.run(['bump', '--major', '--add-build-number']);

  // Example 2: Set a specific version
  await runner.run(['set', '--version', '2.0.0+1']);

  // Example 3: Create version commit and tag
  await runner.run(['commit']);

  // Example 4: Update version badge in README
  await runner.run(['badge']);

  // Example 5: Preview changes without making them (dry run)
  await runner.run(['bump', '--major', '--dry-run']);

  // Example 6: Use date-based build number
  await runner.run(['bump', '--patch', '--date-based-build-number']);

  // Example 7: Remove build number
  await runner.run(['bump', '--no-build-number']);

  // Example 8: Use custom pubspec path
  await runner.run(['bump', '--major', '--path', 'path/to/pubspec.yaml']);

  // Example 9: Bump version and auto-commit
  await runner.run(['bump', '--major', '--auto-commit']);
}
