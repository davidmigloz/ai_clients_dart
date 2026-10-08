@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:test/test.dart';

void main() {
  late String packageDirectory;
  late String fixturePath;
  setUpAll(() async {
    final library = await Isolate.resolvePackageUri(
      Uri.parse('package:openai_dart/openai_dart.dart'),
    );
    if (library == null) throw StateError('Package library was not resolved.');
    packageDirectory = library.resolve('../').toFilePath();
    fixturePath = library
        .resolve('../test/unit/client/fixtures/webhook_environment_probe.dart')
        .toFilePath();
  });

  for (final mode in ['standalone', 'config', 'client']) {
    for (final webhookState in ['missing', 'empty', 'configured']) {
      for (final apiKeyState in ['missing', 'empty', 'configured']) {
        test('$mode with webhook=$webhookState, API key=$apiKeyState', () async {
          final environment = <String, String>{
            if (webhookState != 'missing')
              'OPENAI_WEBHOOK_SECRET': webhookState == 'empty'
                  ? ''
                  : 'whsec_eA==',
            if (apiKeyState != 'missing')
              'OPENAI_API_KEY': apiKeyState == 'empty'
                  ? ''
                  : 'sk-synthetic-environment',
          };
          final result = await Process.run(
            Platform.resolvedExecutable,
            ['--disable-dart-dev', fixturePath, mode],
            workingDirectory: packageDirectory,
            environment: environment,
            includeParentEnvironment: false,
          );
          expect(result.exitCode, 0, reason: result.stderr as String);
          expect(result.stderr, isEmpty);
          final report =
              jsonDecode((result.stdout as String).trim())
                  as Map<String, dynamic>;
          expect(report['httpRequests'], 0);
          expect(result.stdout, isNot(contains('sk-synthetic-environment')));
          expect(result.stdout, isNot(contains('whsec_eA==')));

          if (mode != 'standalone' && apiKeyState != 'configured') {
            // Existing client/config factories retain their API-key requirement,
            // even when only a signing secret has been provided.
            expect(report['constructed'], false);
            expect(report['error'], 'StateError');
            expect(report['diagnostic'], contains('OPENAI_API_KEY'));
            return;
          }
          expect(report['constructed'], true);
          if (mode != 'standalone') {
            expect(report['apiKeyMatches'], true);
            expect(report['webhookSecretAbsent'], webhookState != 'configured');
            expect(
              report['webhookSecretMatches'],
              webhookState == 'configured',
            );
          }
          if (webhookState == 'configured') {
            expect(report['verified'], true);
            expect(report.containsKey('error'), false);
          } else {
            expect(report['error'], 'ArgumentError');
            expect(report['invalidValueAbsent'], true);
            expect(report['diagnostic'], contains('webhook secret'));
          }
        });
      }
    }
  }
}
