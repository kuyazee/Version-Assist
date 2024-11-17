import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:version_assist/src/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

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
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);
      
      final exitCode = await commandRunner.run(['bump', '--major', '--no-build-number-update']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 2.0.0')).called(1);
    });

    test('adds build number to version without one', () async {
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);
      
      final exitCode = await commandRunner.run(['bump', '--major']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 2.0.0+1')).called(1);
    });

    test('bumps version with no build number update', () async {
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);
      
      final exitCode = await commandRunner.run(['bump', '--major', '--no-build-number-update']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 2.0.0+1')).called(1);
    });

    test('validates date-based with no build number update', () async {
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      
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
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      
      final exitCode = await commandRunner.run(['bump', '-d']);

      expect(exitCode, ExitCode.success.code);
      verify(
        () => logger.info('Would bump version from 1.0.0+1 to 1.0.0+2'),
      ).called(1);
    });

    test('bumps version without build number in dry run mode', () async {
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      
      final exitCode = await commandRunner.run(['bump', '-d', '--major', '--no-build-number-update']);

      expect(exitCode, ExitCode.success.code);
      verify(
        () => logger.info('Would bump version from 1.0.0 to 2.0.0'),
      ).called(1);
    });

    test('bumps major version', () async {
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);
      
      final exitCode = await commandRunner.run(['bump', '--major']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 2.0.0+2')).called(1);
    });

    test('bumps minor version', () async {
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);
      
      final exitCode = await commandRunner.run(['bump', '--minor']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 1.1.0+2')).called(1);
    });

    test('bumps patch version', () async {
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);
      
      final exitCode = await commandRunner.run(['bump', '--patch']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 1.0.1+2')).called(1);
    });

    test('validates multiple version flags', () async {
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      
      final exitCode = await commandRunner.run(['bump', '--major', '--minor']);

      expect(exitCode, ExitCode.usage.code);
      verify(
        () => logger.err('Only one of --major, --minor, or --patch can be specified'),
      ).called(1);
    });

    test('bumps version with date-based format in dry run mode', () async {
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+24020100
''';

      final now = DateTime.now();
      final dateFormatter = DateFormat('yyMMdd');
      final expectedDate = dateFormatter.format(now);

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      
      final exitCode = await commandRunner.run(['bump', '-d', '--date-based-build-number']);

      expect(exitCode, ExitCode.success.code);
      verify(
        () => logger.info('Would bump version from 1.0.0+24020100 to 1.0.0+${expectedDate}00'),
      ).called(1);
    });

    test('increments date-based build number when same day', () async {
      final now = DateTime.now();
      final dateFormatter = DateFormat('yyMMdd');
      final today = dateFormatter.format(now);
      
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+${today}00
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);
      
      final exitCode = await commandRunner.run(['bump', '--date-based-build-number']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 1.0.0+${today}01')).called(1);
    });

    test('handles non-existent file', () async {
      final exitCode = await commandRunner.run(['bump', '-p', 'nonexistent.yaml']);

      expect(exitCode, ExitCode.usage.code);
      verify(
        () => logger.err('pubspec.yaml not found at nonexistent.yaml'),
      ).called(1);
    });

    test('handles invalid version format', () async {
      final testPubspec = '''
name: test_app
description: A test application
version: invalid_version
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      
      final exitCode = await commandRunner.run(['bump']);

      expect(exitCode, ExitCode.usage.code);
      verify(
        () => logger.err('Could not find valid version pattern in pubspec.yaml'),
      ).called(1);
    });

    test('verifies file content update in dry run', () async {
      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+1
dependencies:
  some_package: ^1.0.0
''';

      final expectedContent = '''
name: test_app
description: A test application
version: 1.0.0+2
dependencies:
  some_package: ^1.0.0
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((invocation) async {
        final content = invocation.positionalArguments.first as String;
        expect(content, expectedContent);
        return file;
      });
      
      final exitCode = await commandRunner.run(['bump']);
      expect(exitCode, ExitCode.success.code);
    });

    test('verifies file content update with date-based version', () async {
      final now = DateTime.now();
      final dateFormatter = DateFormat('yyMMdd');
      final today = dateFormatter.format(now);

      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+23121500
dependencies:
  some_package: ^1.0.0
''';

      final expectedContent = '''
name: test_app
description: A test application
version: 1.0.0+${today}00
dependencies:
  some_package: ^1.0.0
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((invocation) async {
        final content = invocation.positionalArguments.first as String;
        expect(content, expectedContent);
        return file;
      });
      
      final exitCode = await commandRunner.run(['bump', '--date-based-build-number']);
      expect(exitCode, ExitCode.success.code);
    });

    test('combines major version bump with date-based build number', () async {
      final now = DateTime.now();
      final dateFormatter = DateFormat('yyMMdd');
      final today = dateFormatter.format(now);

      final testPubspec = '''
name: test_app
description: A test application
version: 1.0.0+23121500
''';

      final file = _MockFile();
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.readAsString()).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);
      
      final exitCode = await commandRunner.run(['bump', '--major', '--date-based-build-number']);
      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully bumped version to 2.0.0+${today}00')).called(1);
    });
  });
}
