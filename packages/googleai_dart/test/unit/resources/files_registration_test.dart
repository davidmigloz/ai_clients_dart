import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  for (final version in [ApiVersion.v1, ApiVersion.v1beta]) {
    test('registers Cloud Storage by OAuth on ${version.value}', () async {
      final client = GoogleAIClient(
        config: GoogleAIConfig(
          apiVersion: version,
          authProvider: const ApiKeyProvider('globally-configured-key'),
          baseUrl: 'https://proxy.example.com/gemini?key=old&trace=1',
          defaultHeaders: {
            'x-goog-api-key': 'old-header-key',
            'authorization': 'Bearer old-oauth',
            'x-goog-user-project': 'default-project',
            'x-other': 'preserve',
          },
          defaultQueryParams: {'api_key': 'old-query-key', 'trace': '2'},
        ),
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/gemini/${version.value}/files:register');
          expect(request.url.queryParameters, {'trace': '2'});
          expect(request.followRedirects, isFalse);
          expect(request.headers['authorization'], 'Bearer storage-oauth');
          expect(request.headers['x-goog-user-project'], 'billing-project');
          expect(request.headers['x-goog-api-key'], isNull);
          expect(request.headers['x-other'], 'preserve');
          expect(jsonDecode(request.body), {
            'uris': ['gs://bucket/report.pdf', 'gs://bucket/data/sheet.xlsx'],
          });
          return http.Response(
            jsonEncode({
              'files': [
                {
                  'name': 'files/report',
                  'uri':
                      'https://generativelanguage.googleapis.com/v1beta/files/report',
                  'mimeType': 'application/pdf',
                  'state': 'ACTIVE',
                  'source': 'REGISTERED',
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.close);

      final response = await client.files.register(
        uris: ['gs://bucket/report.pdf', 'gs://bucket/data/sheet.xlsx'],
        authProvider: const BearerTokenProvider('storage-oauth'),
        quotaProjectId: 'billing-project',
      );

      expect(response.files!.single.name, 'files/report');
      final file = response.files!.single;
      expect(file.mimeType, 'application/pdf');
      expect(file.expirationTime, isNull);
      expect(file.toJson(), isNot(contains('expirationTime')));
      expect(
        file.copyWith(updateTime: DateTime.utc(2026, 11, 28)).updateTime,
        DateTime.utc(2026, 11, 28),
      );
      expect(file.copyWith(sizeBytes: null).sizeBytes, isNull);
      expect(response.files!.single.toJson()['source'], 'REGISTERED');
    });
  }

  test('uses client OAuth and preserves an omitted files list', () async {
    final client = GoogleAIClient(
      config: const GoogleAIConfig(
        authProvider: BearerTokenProvider('client-token'),
      ),
      httpClient: MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer client-token');
        expect(request.headers['x-goog-user-project'], isNull);
        return http.Response('{}', 200);
      }),
    );
    addTearDown(client.close);
    final result = await client.files.register(uris: ['gs://bucket/path']);
    expect(result.files, isNull);
  });

  test('redacts reflected OAuth credentials from diagnostics', () async {
    const token = 'cloud-fixture+/=bearer';
    final encoded = Uri.encodeComponent(token);
    final logs = <LogRecord>[];
    final listener = Logger.root.onRecord.listen(logs.add);
    addTearDown(listener.cancel);
    final client = GoogleAIClient(
      config: const GoogleAIConfig(logLevel: Level.ALL),
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {
              'message': 'Reflected diagnostic $encoded for registration',
              'details': [
                {token: 'Nested diagnostic $token'},
              ],
            },
          }),
          400,
          headers: {
            'content-type': 'application/json',
            'x-diagnostic-echo': 'Reflected $encoded',
          },
        ),
      ),
    );
    addTearDown(client.close);
    await expectLater(
      client.files.register(
        uris: ['gs://bucket/path'],
        authProvider: const BearerTokenProvider(token),
      ),
      throwsA(
        isA<ApiException>().having(
          (error) => [
            error.message,
            error.details,
            error.responseMetadata?.headers,
            error.responseMetadata?.bodyExcerpt,
          ].join(' '),
          'redacted diagnostics',
          allOf(
            contains('Reflected'),
            isNot(contains(token)),
            isNot(contains(encoded)),
          ),
        ),
      ),
    );
    expect(logs.any((log) => log.level == Level.SEVERE), isTrue);
    for (final log in logs) {
      final diagnostic = '${log.message} ${log.error}';
      expect(diagnostic, isNot(contains(token)));
      expect(diagnostic, isNot(contains(encoded)));
    }
  });

  test(
    'validates the backend, version, object URI, and OAuth before dispatch',
    () async {
      final transport = MockClient((_) async => fail('Unexpected request'));
      final defaults = GoogleAIClient(
        config: const GoogleAIConfig(authProvider: ApiKeyProvider('key-only')),
        httpClient: transport,
      );
      final vertex = GoogleAIClient(
        config: const GoogleAIConfig(apiMode: ApiMode.vertexAI),
        httpClient: transport,
      );
      final legacy = GoogleAIClient(
        config: const GoogleAIConfig(apiVersion: ApiVersion.v1beta1),
        httpClient: transport,
      );
      addTearDown(defaults.close);
      addTearDown(vertex.close);
      addTearDown(legacy.close);

      await expectLater(
        defaults.files.register(uris: []),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        defaults.files.register(uris: ['https://example.com/file']),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        defaults.files.register(uris: ['gs://bucket/object']),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        vertex.files.register(uris: ['gs://bucket/object']),
        throwsUnsupportedError,
      );
      await expectLater(
        legacy.files.register(uris: ['gs://bucket/object']),
        throwsUnsupportedError,
      );
    },
  );
}
