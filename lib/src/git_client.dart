import 'dart:io';

/// A client for interacting with git operations
class GitClient {
  /// Creates a new [GitClient]
  const GitClient();

  /// Whether we're running in a test environment
  static bool get isTestEnvironment => Platform.environment['DART_TEST'] == 'true';

  /// Checks if a file is staged in git
  Future<bool> isFileStaged(String filePath) async {
    if (isTestEnvironment) return false;

    final result = await Process.run(
      'git',
      ['diff', '--cached', '--name-only', filePath],
    );
    return (result.stdout as String).trim().isNotEmpty;
  }

  /// Stages a file in git
  Future<ProcessResult> stageFile(String filePath) async {
    if (isTestEnvironment) {
      return ProcessResult(0, 0, '', '');
    }

    return Process.run('git', ['add', filePath]);
  }

  /// Creates a commit with the given message
  Future<ProcessResult> commit(String message) async {
    if (isTestEnvironment) {
      return ProcessResult(0, 0, '', '');
    }

    return Process.run('git', ['commit', '-m', message]);
  }

  /// Creates a tag with the given name
  Future<ProcessResult> tag(String tagName) async {
    if (isTestEnvironment) {
      return ProcessResult(0, 0, '', '');
    }

    return Process.run('git', ['tag', tagName]);
  }
}
