import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:version_assist/src/command_runner.dart';

class _MockLogger extends Mock implements Logger {}

class _MockFile extends Mock implements File {}

class _MockProgress extends Mock implements Progress {}

void main() {
  group('version bump', () {
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

    test('bumps version without build number', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);

      final exitCode = await commandRunner
          .run(['bump', '--major', '--no-build-number-update']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 2.0.0'))
          .called(1);
    });

    test('adds build number to version without one', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);

      final exitCode = await commandRunner.run(['bump', '--major']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 2.0.0+1'))
          .called(1);
    });

    test('bumps version with no build number update', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);

      final exitCode = await commandRunner
          .run(['bump', '--major', '--no-build-number-update']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 2.0.0+1'))
          .called(1);
    });

    test('validates date-based with no build number update', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);

      final exitCode = await commandRunner.run([
        'bump',
        '--date-based-build-number',
        '--no-build-number-update',
      ]);

      expect(exitCode, ExitCode.usage.code);
      verify(
        () => logger.err(
          'Cannot use --date-based-build-number with --no-build-number-update',
        ),
      ).called(1);
    });

    test('bumps version in dry run mode', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);

      final exitCode = await commandRunner.run(['bump', '-d']);

      expect(exitCode, ExitCode.success.code);
      verify(
        () => logger.info('Would bump version from 1.0.0+1 to 1.0.0+2'),
      ).called(1);
    });

    test('validates multiple version flags', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);

      final exitCode = await commandRunner.run(['bump', '--major', '--minor']);

      expect(exitCode, ExitCode.usage.code);
      verify(
        () => logger
            .err('Only one of --major, --minor, or --patch can be specified'),
      ).called(1);
    });

    test('bumps major version', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);

      final exitCode = await commandRunner.run(['bump', '--major']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 2.0.0+2'))
          .called(1);
    });

    test('bumps minor version', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);

      final exitCode = await commandRunner.run(['bump', '--minor']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 1.1.0+2'))
          .called(1);
    });

    test('bumps patch version', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);

      final exitCode = await commandRunner.run(['bump', '--patch']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 1.0.1+2'))
          .called(1);
    });

    test('handles file not found', () async {
      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => false);

      final exitCode = await commandRunner.run(['bump']);

      expect(exitCode, ExitCode.usage.code);
      verify(() => logger.err('pubspec.yaml not found at pubspec.yaml')).called(1);
    });

    test('handles invalid version format', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: invalid.version.format
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);

      final exitCode = await commandRunner.run(['bump']);

      expect(exitCode, ExitCode.software.code);
      verify(() => logger.err(any())).called(1);
    });

    test('generates date-based build number for new day', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+230901
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);

      final exitCode =
          await commandRunner.run(['bump', '--date-based-build-number']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success(any())).called(1);
    });

    test('increments date-based build number for same day', () async {
      final now = DateTime.now();
      final datePrefix =
          '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+${datePrefix}01
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);

      final exitCode =
          await commandRunner.run(['bump', '--date-based-build-number']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success(any())).called(1);
    });

    test('auto-commits version bump', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);

      final exitCode = await commandRunner.run(['bump', '--auto-commit']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 1.0.0+2'))
          .called(1);
      verify(
        () => logger.success('Successfully created version commit and tag for 1.0.0+2'),
      ).called(1);
    });
  });
}
