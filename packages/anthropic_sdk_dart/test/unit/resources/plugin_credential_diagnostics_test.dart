import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test(
    'requestless plugin errors use the credential-aware interceptor',
    () async {
      const token = 'fixture-plugin-token';
      final requests = <http.Request>[];
      final transport = MockClient((request) async {
        requests.add(request);
        expect(request.headers['authorization'], 'Bearer $token');
        return http.Response(
          jsonEncode({
            'type': 'error',
            'request_id': 'req_plugin_body',
            'error': {
              'type': 'permission_error',
              'message': 'Rejected Bearer $token',
              'details': {
                'error_code': 'plugin_forbidden',
                'nested': [
                  'echo $token',
                  {'keep': true},
                ],
              },
            },
          }),
          403,
          headers: {
            'request-id': 'echo $token',
            'echoed-response': token,
            'retry-after': '3',
          },
        );
      });
      final client = AnthropicClient(
        config: const AnthropicConfig(
          authProvider: BearerTokenProvider(token),
          retryPolicy: RetryPolicy(maxRetries: 0),
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      final file = PluginUploadFile(
        path: 'fixture.zip',
        bytes: const [0, 128, 255],
      );
      final plugins = client.organization.plugins;
      final marketplaces = client.organization.pluginMarketplaces;
      for (final action in <Future<Object?> Function()>[
        () => plugins.create(files: [file]),
        () => plugins.versions.create('plugin_fixture', files: [file]),
        () => marketplaces.validateArchive(file),
        () => plugins.versions.download('plugin_fixture', 'pluginver_fixture'),
      ]) {
        await expectLater(
          action(),
          throwsA(
            isA<ApiException>()
                .having((error) => error.statusCode, 'status', 403)
                .having(
                  (error) => error.requestId,
                  'request ID',
                  'req_plugin_body',
                )
                .having(
                  (error) => error.errorCode,
                  'error code',
                  'plugin_forbidden',
                )
                .having(
                  (error) => error.message,
                  'message',
                  'Rejected [REDACTED]',
                )
                .having((error) => error.errorDetails, 'details', const {
                  'error_code': 'plugin_forbidden',
                  'nested': [
                    'echo [REDACTED]',
                    {'keep': true},
                  ],
                })
                .having(
                  (error) => error.responseMetadata?.headers['retry-after'],
                  'retry after',
                  '3',
                )
                .having(
                  (error) => error.responseMetadata?.headers['echoed-response'],
                  'echoed header',
                  isNull,
                )
                .having(
                  (error) => error.responseMetadata?.bodyExcerpt,
                  'body excerpt',
                  isEmpty,
                ),
          ),
        );
      }
      expect(requests, hasLength(4));
      for (final request in requests.take(3)) {
        expect(request.headers['content-type'], contains('boundary='));
      }
      expect(requests.last.headers['accept'], 'application/binary');
    },
  );

  test(
    'successful marketplace validations sanitize only diagnostic fields',
    () async {
      const token = 'fixture-plugin+/=token';
      final encoded = Uri.encodeComponent(token);
      final calls = <http.Request>[];
      final transport = MockClient((request) async {
        calls.add(request);
        expect(request.headers['authorization'], 'Bearer $token');
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'type': 'plugin_marketplace_validation_report',
              'valid': false,
              'total_plugin_count': 1,
              'manifest_error': 'Manifest rejected $token',
              'manifest_error_code': 'bad_manifest',
              'ref': 'refs/heads/feature%2Ffixture',
              'plugin_errors': [
                {
                  'name': 'plugin $token',
                  'error': 'Fetch /archive?token=$encoded',
                  'error_code': 'bad_file',
                },
              ],
              'plugin_warnings': [
                {
                  'name': 'plugin $encoded',
                  'warnings': [
                    {'error_code': 'warning', 'message': 'Echo $token'},
                    {
                      'error_code': 'safe',
                      'message': 'Keep encoded path file%2Fname',
                    },
                  ],
                },
                {
                  'name': 'Plugin 名称',
                  'warnings': [
                    {'error_code': 'notice', 'message': 'Unchanged.'},
                  ],
                },
              ],
              'future': {'preserved': true},
            }),
          ),
          200,
          headers: {'content-type': 'text/plain; charset=iso-8859-1'},
        );
      });
      final client = AnthropicClient(
        config: const AnthropicConfig(authProvider: BearerTokenProvider(token)),
        httpClient: transport,
      );
      addTearDown(client.close);
      final marketplaces = client.organization.pluginMarketplaces;
      final reports = [
        await marketplaces.validateRepository(
          repositoryUrl: 'https://github.com/example/fixture',
        ),
        await marketplaces.validateArchive(
          PluginUploadFile(path: 'fixture.zip', bytes: const [0, 255]),
        ),
      ];
      for (final report in reports) {
        expect(report.valid, isFalse);
        expect(report.manifestError, 'Manifest rejected [REDACTED]');
        expect(report.manifestErrorCode, 'bad_manifest');
        expect(report.pluginErrors.single.name, 'plugin [REDACTED]');
        expect(
          report.pluginErrors.single.error,
          'API error response contained a redacted credential',
        );
        expect(report.pluginErrors.single.errorCode, 'bad_file');
        expect(
          report.pluginWarnings.first.warnings.map(
            (warning) => warning.message,
          ),
          ['Echo [REDACTED]', 'Keep encoded path file%2Fname'],
        );
        expect(report.pluginWarnings.first.name, isNot(contains(encoded)));
        expect(report.pluginWarnings.last.name, 'Plugin 名称');
        expect(report.ref, 'refs/heads/feature%2Ffixture');
        expect(report.toJson()['future'], {'preserved': true});
        expect(
          jsonEncode(report),
          allOf(isNot(contains(token)), isNot(contains(encoded))),
        );
      }
      expect(calls.map((call) => call.url.path), [
        '/v1/organizations/plugin_marketplaces/validate_repository',
        '/v1/organizations/plugin_marketplaces/validate_archive',
      ]);
    },
  );

  test(
    'malformed marketplace diagnostics omit an encoded credential source',
    () async {
      const token = 'fixture-plugin+/=token';
      final encoded = Uri.encodeComponent(token);
      final transport = MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer $token');
        return http.Response('{"manifest_error":"Bearer $encoded', 200);
      });
      final client = AnthropicClient(
        config: const AnthropicConfig(authProvider: BearerTokenProvider(token)),
        httpClient: transport,
      );
      addTearDown(client.close);
      await expectLater(
        client.organization.pluginMarketplaces.validateRepository(
          repositoryUrl: 'https://github.com/example/fixture',
        ),
        throwsA(
          isA<FormatException>()
              .having((error) => error.offset, 'offset', isNotNull)
              .having((error) => error.source, 'source', isNull)
              .having(
                (error) => error.toString(),
                'description',
                isNot(contains(encoded)),
              ),
        ),
      );
    },
  );

  test(
    'plugin multipart and byte redirects terminate before body buffering',
    () async {
      final transport = _StalledRedirectClient();
      final client = AnthropicClient(
        config: const AnthropicConfig(
          authProvider: ApiKeyProvider('fixture-admin-key'),
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      final plugins = client.organization.plugins;
      for (final action in <Future<Object?> Function()>[
        () => plugins.create(
          files: [
            PluginUploadFile(path: 'fixture.zip', bytes: const [0, 255]),
          ],
        ),
        () => plugins.versions.download('plugin_fixture', 'pluginver_fixture'),
      ]) {
        await expectLater(
          action().timeout(const Duration(seconds: 2)),
          throwsA(
            isA<ApiException>()
                .having((error) => error.statusCode, 'statusCode', 302)
                .having(
                  (error) => error.requestId,
                  'requestId',
                  'req_plugin_redirect',
                )
                .having(
                  (error) => error.responseMetadata?.headers['location'],
                  'redirect location',
                  isNull,
                ),
          ),
        );
      }
      expect(transport.paths, [
        '/v1/organizations/plugins',
        '/v1/organizations/plugins/plugin_fixture/versions/pluginver_fixture/content',
      ]);
      expect(transport.canceled, 2);
    },
  );
}

class _StalledRedirectClient extends http.BaseClient {
  final paths = <String>[];
  int canceled = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    paths.add(request.url.path);
    expect(request.followRedirects, isFalse);
    final body = StreamController<List<int>>(onCancel: () => canceled++);
    return http.StreamedResponse(
      body.stream,
      302,
      headers: {
        'location': 'https://example.invalid/redirect',
        'request-id': 'req_plugin_redirect',
      },
    );
  }
}
