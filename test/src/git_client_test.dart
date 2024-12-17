import 'package:test/test.dart';
import 'package:version_assist/src/git_client.dart';

void main() {
  group('GitClient', () {
    late GitClient gitClient;

    setUp(() {
      gitClient = const GitClient();
    });

    test('isTestEnvironment returns true during tests', () {
      expect(GitClient.isTestEnvironment, isTrue);
    });

    test('git operations return success in test environment', () async {
      // All git operations should return success (exit code 0) in test environment
      expect((await gitClient.stageFile('test.txt')).exitCode, equals(0));
      expect(
        (await gitClient.commit('test commit')).exitCode,
        equals(0),
      );
      expect((await gitClient.tag('v1.0.0')).exitCode, equals(0));
      expect(await gitClient.isFileStaged('test.txt'), isFalse);
    });
  });
}
