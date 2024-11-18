import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:intl/intl.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:version_assist/src/commands/commit_command.dart';

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
        'date-based-build-number',
        abbr: 'b',
        help: 'Use date-based build number format (yymmddbn)',
        negatable: false,
      )
      ..addFlag(
        'no-build-number-update',
        help:
            'Keep the current build number or use version without build number',
        negatable: false,
      )
      ..addFlag(
        'major',
        help: 'Bump major version (x.0.0)',
        negatable: false,
      )
      ..addFlag(
        'minor',
        help: 'Bump minor version (0.x.0)',
        negatable: false,
      )
      ..addFlag(
        'patch',
        help: 'Bump patch version (0.0.x)',
        negatable: false,
      )
      ..addFlag(
        'auto-commit',
        help: 'Automatically commit and tag the version bump',
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

  /// Bumps the version number based on semver rules
  String _bumpVersion(
    String version, {
    bool major = false,
    bool minor = false,
    bool patch = false,
  }) {
    final parts = version.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid version format: $version');
    }

    var majorVersion = int.parse(parts[0]);
    var minorVersion = int.parse(parts[1]);
    var patchVersion = int.parse(parts[2]);

    if (major) {
      majorVersion++;
      minorVersion = 0;
      patchVersion = 0;
    } else if (minor) {
      minorVersion++;
      patchVersion = 0;
    } else if (patch) {
      patchVersion++;
    }

    return '$majorVersion.$minorVersion.$patchVersion';
  }

  @override
  Future<int> run() async {
    try {
      final pubspecPath = argResults?['path'] as String;
      final isDryRun = argResults?['dry-run'] as bool;
      final isDateBased = argResults?['date-based-build-number'] as bool;
      final isMajor = argResults?['major'] as bool;
      final isMinor = argResults?['minor'] as bool;
      final isPatch = argResults?['patch'] as bool;
      final noBuildNumberUpdate = argResults?['no-build-number-update'] as bool;
      final autoCommit = argResults?['auto-commit'] as bool;

      // Validate version bump flags
      final versionFlagCount =
          [isMajor, isMinor, isPatch].where((f) => f).length;
      if (versionFlagCount > 1) {
        _logger
            .err('Only one of --major, --minor, or --patch can be specified');
        return ExitCode.usage.code;
      }

      // Validate build number flags
      if (isDateBased && noBuildNumberUpdate) {
        _logger.err(
          'Cannot use --date-based-build-number with --no-build-number-update',
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

      // Parse the version - support both formats: x.y.z and x.y.z+build
      final versionPattern = RegExp(r'version:\s+(\d+\.\d+\.\d+)(?:\+(\d+))?');
      final match = versionPattern.firstMatch(content);

      if (match == null) {
        _logger.err('Could not find valid version pattern in pubspec.yaml');
        return ExitCode.usage.code;
      }

      final baseVersion = match.group(1)!;
      final currentBuildNumber = match.group(2);
      final hasBuildNumber = currentBuildNumber != null;

      // Generate new version based on flags
      final newBaseVersion = versionFlagCount > 0
          ? _bumpVersion(
              baseVersion,
              major: isMajor,
              minor: isMinor,
              patch: isPatch,
            )
          : baseVersion;

      // Determine if we should include a build number in the new version
      final includeBuildNumber =
          !noBuildNumberUpdate || isDateBased || hasBuildNumber;

      String newVersion;
      if (includeBuildNumber) {
        final newBuildNumber = noBuildNumberUpdate
            ? (currentBuildNumber ?? '1')
            : isDateBased
                ? _generateDateBasedBuildNumber(currentBuildNumber ?? '1')
                : ((int.parse(currentBuildNumber ?? '0') + 1).toString());
        newVersion = '$newBaseVersion+$newBuildNumber';
      } else {
        newVersion = newBaseVersion;
      }

      // Replace the version in the content
      final newContent =
          content.replaceFirst(versionPattern, 'version: $newVersion');

      if (isDryRun) {
        final currentVersion =
            hasBuildNumber ? '$baseVersion+$currentBuildNumber' : baseVersion;
        _logger.info(
          'Would bump version from $currentVersion to $newVersion',
        );
        return ExitCode.success.code;
      }

      // Write back to file
      await file.writeAsString(newContent);
      _logger.success('Successfully bumped version to $newVersion');

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
