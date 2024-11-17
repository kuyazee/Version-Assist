import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:intl/intl.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// {@template version_bump_command}
/// A command which updates the version in pubspec.yaml
/// {@endtemplate}
class VersionBumpCommand extends Command<int> {
  /// {@macro version_bump_command}
  VersionBumpCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to pubspec.yaml',
        defaultsTo: path.join('pubspec.yaml'),
      )
      ..addFlag(
        'dry-run',
        abbr: 'd',
        help: 'Show what would happen without making changes',
        negatable: false,
      )
      ..addFlag(
        'date-based',
        abbr: 'b',
        help: 'Use date-based build number format (yymmddbn)',
        negatable: false,
      );
  }

  final Logger _logger;

  @override
  String get description => 'Updates the version in pubspec.yaml';

  @override
  String get name => 'bump';

  /// Generates a date-based build number in format yymmddbn
  String _generateDateBasedBuildNumber(String currentBuildNumber) {
    final now = DateTime.now();
    final dateFormatter = DateFormat('yyMMdd');
    final datePrefix = dateFormatter.format(now);

    // If current build number matches today's date format, increment the suffix
    if (currentBuildNumber.length == 8 &&
        currentBuildNumber.startsWith(datePrefix)) {
      final currentSuffix = int.parse(currentBuildNumber.substring(6));
      return '$datePrefix${(currentSuffix + 1).toString().padLeft(2, '0')}';
    }

    // Otherwise start with 00 for today
    return '${datePrefix}00';
  }

  @override
  Future<int> run() async {
    try {
      final pubspecPath = argResults?['path'] as String;
      final isDryRun = argResults?['dry-run'] as bool;
      final isDateBased = argResults?['date-based'] as bool;

      // Read the current pubspec file
      final file = File(pubspecPath);
      if (!await file.exists()) {
        _logger.err('pubspec.yaml not found at $pubspecPath');
        return ExitCode.usage.code;
      }

      final content = await file.readAsString();

      // Parse the version
      final versionPattern = RegExp(r'version:\s+(\d+\.\d+\.\d+)\+(\d+)');
      final match = versionPattern.firstMatch(content);

      if (match == null) {
        _logger.err('Could not find valid version pattern in pubspec.yaml');
        return ExitCode.usage.code;
      }

      final baseVersion = match.group(1);
      final currentBuildNumber = match.group(2)!;

      // Generate new build number based on format
      final newBuildNumber = isDateBased
          ? _generateDateBasedBuildNumber(currentBuildNumber)
          : (int.parse(currentBuildNumber) + 1).toString();

      // Create new version string
      final newVersion = '$baseVersion+$newBuildNumber';

      // Replace the version in the content
      final newContent =
          content.replaceFirst(versionPattern, 'version: $newVersion');

      if (isDryRun) {
        _logger.info(
          'Would bump version from $baseVersion+$currentBuildNumber to $newVersion',
        );
        return ExitCode.success.code;
      }

      // Write back to file
      await file.writeAsString(newContent);

      // Run git commands
      final gitAdd = await Process.run(
        'git',
        ['add', pubspecPath],
      );
      if (gitAdd.exitCode != 0) {
        _logger.err('Error during git add: ${gitAdd.stderr}');
        return ExitCode.software.code;
      }

      final commitMessage =
          'build(versionCode+$newBuildNumber): Automated version bump using version_assist';
      final gitCommit = await Process.run(
        'git',
        ['commit', '-m', commitMessage, pubspecPath],
      );

      if (gitCommit.exitCode != 0) {
        _logger.err('Error during git commit: ${gitCommit.stderr}');
        return ExitCode.software.code;
      }

      final gitTag = await Process.run(
        'git',
        ['tag', newVersion],
      );

      if (gitTag.exitCode != 0) {
        _logger.err('Error during git tag: ${gitTag.stderr}');
        return ExitCode.software.code;
      }

      _logger.success('Successfully bumped version to $newVersion');
      return ExitCode.success.code;
    } catch (error) {
      _logger.err('$error');
      return ExitCode.software.code;
    }
  }
}
