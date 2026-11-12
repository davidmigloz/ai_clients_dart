import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('invalid Files and Skills identifiers never reach transport', () async {
    var sends = 0;
    final transport = MockClient((_) async {
      sends++;
      return http.Response('{}', 400);
    });
    addTearDown(transport.close);
    final client = AnthropicClient(httpClient: transport);
    addTearDown(client.close);
    final calls = <Future<Object?> Function()>[
      () => client.files.retrieve(fileId: ''),
      () => client.files.deleteFile(fileId: '..'),
      () => client.files.download(fileId: '.'),
      () =>
          client.skills.deleteVersion(skillId: 'skill_fixture', version: '..'),
      () => client.skills.retrieve(skillId: '..;fixture'),
    ];
    for (final call in calls) {
      await expectLater(call, throwsArgumentError);
    }
    expect(sends, 0);
  });

  for (final (name, config) in [
    (
      'base URL',
      const AnthropicConfig(
        baseUrl: 'https://fixture.invalid/proxy?scope_id=sesn_fixture',
        defaultHeaders: {'Anthropic-Beta': 'fixture-beta'},
      ),
    ),
    (
      'configured query',
      const AnthropicConfig(
        baseUrl: 'https://fixture.invalid/proxy',
        defaultQueryParams: {'scope_id': 'sesn_fixture'},
        defaultHeaders: {'Anthropic-Beta': 'fixture-beta'},
      ),
    ),
  ]) {
    test('Files applies the scoped beta for $name', () async {
      final transport = MockClient((request) async {
        expect(request.url.path, '/proxy/v1/files');
        expect(request.url.queryParameters['scope_id'], 'sesn_fixture');
        expect(
          request.headers['anthropic-beta'],
          'fixture-beta,managed-agents-2026-04-01',
        );
        return http.Response(
          '{"data":[],"next_page":null}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      addTearDown(transport.close);
      final client = AnthropicClient(config: config, httpClient: transport);
      addTearDown(client.close);
      expect((await client.files.list()).data, isEmpty);
    });
  }
}
