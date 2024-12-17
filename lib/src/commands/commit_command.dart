import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:version_assist/src/git_client.dart';

/// {@template commit_command}
/// A command which creates a version commit and tag
/// {@endtemplate}
class CommitCommand extends Command<int> {
  /// {@macro commit_command}
  CommitCommand({
    required Logger logger,
    GitClient? gitClient,
  })  : _logger = logger,
        _gitClient = gitClient ?? const GitClient() {
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
      );
  }

  final Logger _logger;
  final GitClient _gitClient;

  @override
  String get description => 'Creates a version commit and tag';

  @override
  String get name => 'commit';

  /// Extracts version from pubspec.yaml content
  String? _extractVersion(String content) {
    final versionPattern = RegExp(r'version:\s+(\d+\.\d+\.\d+(?:\+\d+)?)');
    final match = versionPattern.firstMatch(content);
    return match?.group(1);
  }

  /// Runs the commit command with explicit parameters
  /// This allows other commands to use the commit functionality directly
  Future<int> runWith({
    required String pubspecPath,
    bool isDryRun = false,
  }) async {
    try {
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

      if (isDryRun) {
        _logger
          ..info('Would create commit with message:')
          ..info('build(version): Bump version to $version')
          ..info('Would create tag: $version');
        return ExitCode.success.code;
      }

      // Only stage pubspec.yaml if it's not already staged
      if (!await _gitClient.isFileStaged(pubspecPath)) {
        final gitAdd = await _gitClient.stageFile(pubspecPath);
        if (gitAdd.exitCode != 0) {
          _logger.err('Error during git add: ${gitAdd.stderr as String}');
          return ExitCode.software.code;
        }
      }

      final commitMessage = 'build(version): Bump version to $version';
      final gitCommit = await _gitClient.commit(commitMessage);

      if (gitCommit.exitCode != 0) {
        _logger.err('Error during git commit: ${gitCommit.stderr as String}');
        return ExitCode.software.code;
      }

      final gitTag = await _gitClient.tag(version);

      if (gitTag.exitCode != 0) {
        _logger.err('Error during git tag: ${gitTag.stderr as String}');
        return ExitCode.software.code;
      }

      _logger.success('Successfully created version commit and tag for $version');
      return ExitCode.success.code;
    } catch (error) {
      _logger.err('$error');
      return ExitCode.software.code;
    }
  }

  @override
  Future<int> run() async {
    final args = argResults;
    if (args == null) {
      _logger.err('No arguments provided');
      return ExitCode.usage.code;
    }

    return runWith(
      pubspecPath: args['path'] as String,
      isDryRun: args['dry-run'] as bool,
    );
  }
}
