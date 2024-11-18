import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:version_assist/src/commands/commit_command.dart';

/// {@template version_set_command}
/// A command which manually sets the version in pubspec.yaml
/// {@endtemplate}
class VersionSetCommand extends Command<int> {
  /// {@macro version_set_command}
  VersionSetCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to pubspec.yaml',
        defaultsTo: path.join('pubspec.yaml'),
      )
      ..addOption(
        'version',
        abbr: 'v',
        help: 'Version to set (format: x.y.z or x.y.z+build)',
        mandatory: true,
      )
      ..addFlag(
        'dry-run',
        abbr: 'd',
        help: 'Show what would happen without making changes',
        negatable: false,
      )
      ..addFlag(
        'auto-commit',
        help: 'Automatically commit and tag the version change',
      );
  }

  final Logger _logger;

  @override
  String get description => 'Manually sets the version in pubspec.yaml';

  @override
  String get name => 'set';

  @override
  Future<int> run() async {
    try {
      final pubspecPath = argResults?['path'] as String;
      final newVersion = argResults?['version'] as String;
      final isDryRun = argResults?['dry-run'] as bool;
      final autoCommit = argResults?['auto-commit'] as bool;

      // Validate version format
      final versionPattern = RegExp(r'^\d+\.\d+\.\d+(?:\+\d+)?$');
      if (!versionPattern.hasMatch(newVersion)) {
        _logger.err(
          'Invalid version format. Must be x.y.z or x.y.z+build',
        );
        return ExitCode.usage.code;
      }

      // Read the current pubspec file
      final file = File(pubspecPath);
      if (!await file.exists()) {
        _logger.err('pubspec.yaml not found at $pubspecPath');
        return ExitCode.usage.code;
      }

      final content = await file.readAsString();

      // Parse the current version
      final currentVersionPattern =
          RegExp(r'version:\s+(\d+\.\d+\.\d+(?:\+\d+)?)');
      final match = currentVersionPattern.firstMatch(content);

      if (match == null) {
        _logger.err('Could not find valid version pattern in pubspec.yaml');
        return ExitCode.usage.code;
      }

      final currentVersion = match.group(1)!;

      if (isDryRun) {
        _logger.info(
          'Would change version from $currentVersion to $newVersion',
        );
        return ExitCode.success.code;
      }

      // Replace the version in the content
      final newContent =
          content.replaceFirst(currentVersionPattern, 'version: $newVersion');

      // Write back to file
      await file.writeAsString(newContent);
      _logger.success('Successfully set version to $newVersion');

      // Handle auto-commit if enabled
      if (autoCommit) {
        final commitCommand = CommitCommand(logger: _logger);
        final commitResult = await commitCommand.run();
        if (commitResult != ExitCode.success.code) {
          return commitResult;
        }
      }

      return ExitCode.success.code;
    } catch (error) {
      _logger.err('$error');
      return ExitCode.software.code;
    }
  }
}
