import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// {@template update_badge_command}
/// A command which updates version badges in README.md
/// {@endtemplate}
class UpdateBadgeCommand extends Command<int> {
  /// {@macro update_badge_command}
  UpdateBadgeCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'pubspec-path',
        abbr: 'p',
        help: 'Path to pubspec.yaml',
        defaultsTo: path.join('pubspec.yaml'),
      )
      ..addOption(
        'readme-path',
        abbr: 'r',
        help: 'Path to README.md',
        defaultsTo: path.join('README.md'),
      )
      ..addFlag(
        'dry-run',
        abbr: 'd',
        help: 'Show what would happen without making changes',
        negatable: false,
      );
  }

  final Logger _logger;

  @override
  String get description => 'Updates version badges in README.md';

  @override
  String get name => 'badge';

  /// Extracts version from pubspec.yaml content
  String? _extractVersion(String content) {
    final versionPattern = RegExp(r'version:\s+(\d+\.\d+\.\d+(?:\+\d+)?)');
    final match = versionPattern.firstMatch(content);
    return match?.group(1);
  }

  /// Updates version badge in README.md content
  String _updateVersionBadge(String content, String version) {
    final badgePattern =
        RegExp(r'\[pub_version_badge\]:.+v[\d\.]+(?:\+\d+)?-blue');
    return content.replaceFirst(
      badgePattern,
      '[pub_version_badge]: https://img.shields.io/badge/pub-v$version-blue',
    );
  }

  @override
  Future<int> run() async {
    try {
      final pubspecPath = argResults?['pubspec-path'] as String;
      final readmePath = argResults?['readme-path'] as String;
      final isDryRun = argResults?['dry-run'] as bool;

      // Read pubspec.yaml
      final pubspecFile = File(pubspecPath);
      if (!await pubspecFile.exists()) {
        _logger.err('pubspec.yaml not found at $pubspecPath');
        return ExitCode.usage.code;
      }

      final pubspecContent = await pubspecFile.readAsString();
      final version = _extractVersion(pubspecContent);

      if (version == null) {
        _logger.err('Could not find valid version in pubspec.yaml');
        return ExitCode.usage.code;
      }

      // Read README.md
      final readmeFile = File(readmePath);
      if (!await readmeFile.exists()) {
        _logger.err('README.md not found at $readmePath');
        return ExitCode.usage.code;
      }

      final readmeContent = await readmeFile.readAsString();
      final updatedContent = _updateVersionBadge(readmeContent, version);

      if (isDryRun) {
        _logger.info('Would update version badge to v$version');
        return ExitCode.success.code;
      }

      // Write updated README.md
      await readmeFile.writeAsString(updatedContent);
      _logger.success('Successfully updated version badge to v$version');

      return ExitCode.success.code;
    } catch (error) {
      _logger.err('$error');
      return ExitCode.software.code;
    }
  }
}
