import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:version_assist/src/command_runner.dart';
import 'package:version_assist/src/git_client.dart';

class _MockLogger extends Mock implements Logger {}

class _MockFile extends Mock implements File {}

class _MockProgress extends Mock implements Progress {}

class _MockGitClient extends Mock implements GitClient {}

void main() {
  group('commit', () {
    late Logger logger;
    late Progress progress;
    late GitClient gitClient;
    late VersionAssistCommandRunner commandRunner;

    setUpAll(() {
      registerFallbackValue('');
      registerFallbackValue(<String>[]);
    });

    setUp(() {
      logger = _MockLogger();
      progress = _MockProgress();
      gitClient = _MockGitClient();
      commandRunner = VersionAssistCommandRunner(
        logger: logger,
        gitClient: gitClient,
      );

      // Set up default mock behavior for logger
      when(() => logger.progress(any())).thenReturn(progress);
      when(() => logger.detail(any())).thenReturn(null);
      when(() => logger.err(any())).thenReturn(null);
      when(() => logger.info(any())).thenReturn(null);
      when(() => logger.success(any())).thenReturn(null);
      when(() => progress.complete(any())).thenReturn(null);
      when(() => progress.fail(any())).thenReturn(null);

      // Set up default mock behavior for git client
      when(() => gitClient.isFileStaged(any())).thenAnswer((_) async => false);
      when(() => gitClient.stageFile(any())).thenAnswer(
        (_) async => ProcessResult(0, 0, '', ''),
      );
      when(() => gitClient.commit(any())).thenAnswer(
        (_) async => ProcessResult(0, 0, '', ''),
      );
      when(() => gitClient.tag(any())).thenAnswer(
        (_) async => ProcessResult(0, 0, '', ''),
      );
    });

    test('shows commit info in dry run mode', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);

      final exitCode = await commandRunner.run(['commit', '--dry-run']);

      expect(exitCode, ExitCode.success.code);
      verify(
        () => logger.info('Would create commit with message:'),
      ).called(1);
      verify(
        () => logger.info('build(version): Bump version to 1.0.0+1'),
      ).called(1);
      verify(
        () => logger.info('Would create tag: 1.0.0+1'),
      ).called(1);

      // Verify no git operations were performed
      verifyNever(() => gitClient.stageFile(any()));
      verifyNever(() => gitClient.commit(any()));
      verifyNever(() => gitClient.tag(any()));
    });

    test('handles missing pubspec.yaml', () async {
      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => false);

      final exitCode = await commandRunner.run(['commit']);

      expect(exitCode, ExitCode.usage.code);
      verify(() => logger.err('pubspec.yaml not found at pubspec.yaml'))
          .called(1);
    });

    test('handles invalid version format', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: invalid.version
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);

      final exitCode = await commandRunner.run(['commit']);

      expect(exitCode, ExitCode.usage.code);
      verify(() => logger.err('Could not find valid version in pubspec.yaml'))
          .called(1);
    });

    test('creates version commit and tag', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);

      final exitCode = await commandRunner.run(['commit']);

      expect(exitCode, ExitCode.success.code);
      verify(() => gitClient.stageFile('pubspec.yaml')).called(1);
      verify(
        () => gitClient.commit('build(version): Bump version to 1.0.0+1'),
      ).called(1);
      verify(() => gitClient.tag('1.0.0+1')).called(1);
      verify(
        () => logger
            .success('Successfully created version commit and tag for 1.0.0+1'),
      ).called(1);
    });

    test('handles git stage failure', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => gitClient.stageFile(any())).thenAnswer(
        (_) async => ProcessResult(0, 1, '', 'git add failed'),
      );

      final exitCode = await commandRunner.run(['commit']);

      expect(exitCode, ExitCode.software.code);
      verify(() => logger.err('Error during git add: git add failed')).called(1);
    });

    test('handles git commit failure', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => gitClient.commit(any())).thenAnswer(
        (_) async => ProcessResult(0, 1, '', 'git commit failed'),
      );

      final exitCode = await commandRunner.run(['commit']);

      expect(exitCode, ExitCode.software.code);
      verify(() => logger.err('Error during git commit: git commit failed'))
          .called(1);
    });

    test('handles git tag failure', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => gitClient.tag(any())).thenAnswer(
        (_) async => ProcessResult(0, 1, '', 'git tag failed'),
      );

      final exitCode = await commandRunner.run(['commit']);

      expect(exitCode, ExitCode.software.code);
      verify(() => logger.err('Error during git tag: git tag failed')).called(1);
    });
  });
}
