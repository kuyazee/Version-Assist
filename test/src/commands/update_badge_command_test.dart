import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:version_assist/src/command_runner.dart';

class _MockLogger extends Mock implements Logger {}

class _MockFile extends Mock implements File {}

class _MockProgress extends Mock implements Progress {}

void main() {
  group('update badge', () {
    late Logger logger;
    late Progress progress;
    late VersionAssistCommandRunner commandRunner;

    setUpAll(() {
      registerFallbackValue('');
      registerFallbackValue(<String>[]);
    });

    setUp(() {
      logger = _MockLogger();
      progress = _MockProgress();
      commandRunner = VersionAssistCommandRunner(logger: logger);

      // Set up default mock behavior for logger
      when(() => logger.progress(any())).thenReturn(progress);
      when(() => logger.detail(any())).thenReturn(null);
      when(() => logger.err(any())).thenReturn(null);
      when(() => logger.info(any())).thenReturn(null);
      when(() => logger.success(any())).thenReturn(null);
      when(() => progress.complete(any())).thenReturn(null);
      when(() => progress.fail(any())).thenReturn(null);
    });

    test('updates version badge', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      const testReadme = '''
# Test App
[![pub package][pub_version_badge]][pub_package_link]

[pub_version_badge]: https://img.shields.io/badge/pub-v0.9.0-blue
[pub_package_link]: https://pub.dev/packages/test_app
''';

      final pubspecFile = _MockFile();
      when(pubspecFile.exists).thenAnswer((_) async => true);
      when(pubspecFile.readAsString).thenAnswer((_) async => testPubspec);

      final readmeFile = _MockFile();
      when(readmeFile.exists).thenAnswer((_) async => true);
      when(readmeFile.readAsString).thenAnswer((_) async => testReadme);
      when(() => readmeFile.writeAsString(any())).thenAnswer((_) async => readmeFile);

      final exitCode = await commandRunner.run(['badge']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully updated version badge to v1.0.0+1'))
          .called(1);
    });

    test('handles missing pubspec.yaml', () async {
      final pubspecFile = _MockFile();
      when(pubspecFile.exists).thenAnswer((_) async => false);

      final exitCode = await commandRunner.run(['badge']);

      expect(exitCode, ExitCode.usage.code);
      verify(() => logger.err('pubspec.yaml not found at pubspec.yaml')).called(1);
    });

    test('handles missing README.md', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final pubspecFile = _MockFile();
      when(pubspecFile.exists).thenAnswer((_) async => true);
      when(pubspecFile.readAsString).thenAnswer((_) async => testPubspec);

      final readmeFile = _MockFile();
      when(readmeFile.exists).thenAnswer((_) async => false);

      final exitCode = await commandRunner.run(['badge']);

      expect(exitCode, ExitCode.usage.code);
      verify(() => logger.err('README.md not found at README.md')).called(1);
    });

    test('handles invalid version in pubspec.yaml', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: invalid.version
''';

      final pubspecFile = _MockFile();
      when(pubspecFile.exists).thenAnswer((_) async => true);
      when(pubspecFile.readAsString).thenAnswer((_) async => testPubspec);

      final exitCode = await commandRunner.run(['badge']);

      expect(exitCode, ExitCode.usage.code);
      verify(() => logger.err('Could not find valid version in pubspec.yaml'))
          .called(1);
    });

    test('shows changes in dry run mode', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      const testReadme = '''
# Test App
[![pub package][pub_version_badge]][pub_package_link]

[pub_version_badge]: https://img.shields.io/badge/pub-v0.9.0-blue
[pub_package_link]: https://pub.dev/packages/test_app
''';

      final pubspecFile = _MockFile();
      when(pubspecFile.exists).thenAnswer((_) async => true);
      when(pubspecFile.readAsString).thenAnswer((_) async => testPubspec);

      final readmeFile = _MockFile();
      when(readmeFile.exists).thenAnswer((_) async => true);
      when(readmeFile.readAsString).thenAnswer((_) async => testReadme);

      final exitCode = await commandRunner.run(['badge', '--dry-run']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.info('Would update version badge to v1.0.0+1')).called(1);
    });
  });
}
