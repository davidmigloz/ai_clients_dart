@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('explicit environment factories', () {
    test('empty and missing credentials fail without dispatch', () async {
      for (final environment in [
        <String, String>{},
        {'ANTHROPIC_API_KEY': '', 'ANTHROPIC_AUTH_TOKEN': ''},
      ]) {
        final result = await _probe(environment);
        for (final key in ['configError', 'clientError']) {
          expect(
            result[key],
            allOf(
              contains('ANTHROPIC_API_KEY'),
              contains('ANTHROPIC_AUTH_TOKEN'),
            ),
          );
        }
        expect(result.containsKey('requestRoute'), isFalse);
      }
    });

    test(
      'API key takes precedence over OAuth and preserves base URL',
      () async {
        final result = await _probe({
          'ANTHROPIC_API_KEY': 'fixture-api-key',
          'ANTHROPIC_AUTH_TOKEN': 'fixture-oauth-token',
          'ANTHROPIC_BASE_URL': 'https://fixture.invalid/proxy',
        });
        expect(result, {
          'baseUrlCase': 'proxy',
          'requestRoute': 'proxy',
          'apiKey': 'fixture',
          'authorization': null,
          'beta': null,
        });
      },
    );

    test('missing and empty API keys fall back to OAuth', () async {
      for (final environment in [
        {'ANTHROPIC_AUTH_TOKEN': 'fixture-oauth-token'},
        {
          'ANTHROPIC_API_KEY': '',
          'ANTHROPIC_AUTH_TOKEN': 'fixture-oauth-token',
          'ANTHROPIC_BASE_URL': '',
        },
      ]) {
        final result = await _probe(environment);
        expect(result, {
          'baseUrlCase': 'default',
          'requestRoute': 'default',
          'apiKey': null,
          'authorization': 'fixture',
          'beta': 'oauth-2025-04-20',
        });
      }
    });

    test('subprocess does not print unexpected credentials or URLs', () async {
      const url = 'https://fixture.invalid/private-path';
      for (final variable in ['ANTHROPIC_API_KEY', 'ANTHROPIC_AUTH_TOKEN']) {
        const private = 'other-private-fixture-value';
        final result = await _probe({
          variable: private,
          'ANTHROPIC_BASE_URL': url,
        });
        expect(result['baseUrlCase'], 'other');
        expect(result['requestRoute'], 'other');
        expect(result.values, isNot(contains(private)));
        expect(result.values, isNot(contains(url)));
        final authField = variable == 'ANTHROPIC_API_KEY'
            ? 'apiKey'
            : 'authorization';
        expect(result[authField], 'other');
      }
    });

    test(
      'invalid environment auth fails before transport with a safe error',
      () async {
        for (final (variable, value) in [
          ('ANTHROPIC_API_KEY', 'fixture-key\ninvalid'),
          ('ANTHROPIC_AUTH_TOKEN', 'fixture-token\r\ninvalid'),
          ('ANTHROPIC_AUTH_TOKEN', 'fixture-token\u0100'),
        ]) {
          final result = await _probe({variable: value});
          expect(result['clientError'], 'Invalid authentication header value');
          expect(result.containsKey('requestRoute'), isFalse);
        }
      },
    );
  });

  test('credential validation follows a provider auth rewrite', () async {
    final client = AnthropicFoundryClient(
      resource: 'fixture-resource',
      apiKey: 'fixture-foundry-key',
      config: const AnthropicConfig(
        defaultHeaders: {'Authorization': 'stale\ncredential'},
      ),
      httpClient: MockClient((request) async {
        expect(request.headers['authorization'], isNull);
        expect(request.headers['x-api-key'], 'fixture-foundry-key');
        return http.Response('{"input_tokens":1}', 200);
      }),
    );
    addTearDown(client.close);
    final response = await client.messages.countTokens(
      TokenCountRequest(
        model: 'fixture',
        messages: [InputMessage.user('Hello')],
      ),
    );
    expect(response.inputTokens, 1);
  });
}

Future<Map<String, Object?>> _probe(Map<String, String> environment) async {
  final packageConfig = (await Isolate.packageConfig)!;
  final library = (await Isolate.resolvePackageUri(
    Uri.parse('package:anthropic_sdk_dart/anthropic_sdk_dart.dart'),
  ))!;
  final script = library.resolve(
    '../test/unit/client/fixtures/environment_auth_probe.dart',
  );
  final result = await Process.run(
    Platform.resolvedExecutable,
    ['--packages=${packageConfig.toFilePath()}', script.toFilePath()],
    environment: environment,
    includeParentEnvironment: false,
  );
  expect(result.exitCode, 0, reason: result.stderr.toString());
  return jsonDecode(result.stdout as String) as Map<String, Object?>;
}
