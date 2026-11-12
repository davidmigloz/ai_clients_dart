import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _token = 'fixture-credential+/=opaque';
const _utf8ContentType = {'content-type': 'application/json; charset=utf-8'};

void main() {
  test(
    'requestless Models JSON keeps format offset without echoing its API key',
    () async {
      const source = '{"name":"Bearer $_token';
      final transport = MockClient((request) async {
        expect(request.url.path, '/v1/models');
        expect(request.headers['x-api-key'], _token);
        return http.Response(source, 200, headers: _utf8ContentType);
      });
      final client = AnthropicClient.withApiKey(_token, httpClient: transport);
      addTearDown(client.close);

      final original = _jsonError(source);
      try {
        await client.models.list();
        fail('Expected invalid JSON to throw');
      } on FormatException catch (error, stackTrace) {
        expect(error.offset, original.offset);
        expect(error.message, original.message);
        expect(error.source, isNull);
        expect(error.toString(), isNot(contains(_token)));
        expect(stackTrace.toString(), contains('decodeApiJsonResponse'));
      }
    },
  );

  test(
    'requestless Managed Agents JSON uses the effective copied OAuth request',
    () async {
      final encoded = Uri.encodeComponent(_token);
      final transport = MockClient((request) async {
        expect(request.url.path, '/v1/agents');
        expect(request.headers['authorization'], 'Bearer $_token');
        return http.Response(
          '{"name":"$encoded',
          200,
          headers: _utf8ContentType,
        );
      });
      final client = AnthropicClient.withAuthToken(
        _token,
        httpClient: transport,
      );
      addTearDown(client.close);

      await expectLater(client.agents.list(), _redactedFormat(encoded));
    },
  );

  test(
    'Admin and Compliance keep strict UTF-8 and suppress invalid-byte excerpts',
    () async {
      final source = <int>[...utf8.encode('{"name":"$_token'), 0xff];
      final requests = <String>[];
      final transport = MockClient((request) async {
        requests.add(request.url.path);
        expect(request.headers['x-api-key'], _token);
        return http.Response.bytes(
          source,
          200,
          headers: {'content-type': 'text/plain; charset=iso-8859-1'},
        );
      });
      final client = AnthropicClient.withApiKey(_token, httpClient: transport);
      addTearDown(client.close);

      for (final operation in <Future<Object?> Function()>[
        client.organization.retrieve,
        () => client.compliance.retrieveGroup('grp_fixture'),
      ]) {
        await expectLater(
          operation(),
          throwsA(
            isA<FormatException>()
                .having(
                  (error) => error.message,
                  'UTF-8 failure',
                  contains('UTF-8'),
                )
                .having(
                  (error) => error.offset,
                  'byte offset',
                  source.length - 1,
                )
                .having((error) => error.source, 'source', isNull)
                .having(
                  (error) => error.toString(),
                  'description',
                  isNot(contains(_token)),
                ),
          ),
        );
      }
      expect(requests, [
        '/v1/organizations/me',
        '/v1/compliance/groups/grp_fixture',
      ]);
    },
  );

  test(
    'valid Admin and Compliance JSON retains Unicode and credential-like fields verbatim',
    () async {
      const name = 'Zoë 嘉 $_token';
      final transport = MockClient((request) async {
        expect(request.headers['x-api-key'], _token);
        final body = request.url.path == '/v1/organizations/me'
            ? {'type': 'organization', 'id': 'org_fixture', 'name': name}
            : {
                'id': 'grp_fixture',
                'name': name,
                'description': name,
                'source_type': 'organization',
              };
        return http.Response.bytes(
          utf8.encode(jsonEncode(body)),
          200,
          headers: {'content-type': 'text/plain; charset=iso-8859-1'},
        );
      });
      final client = AnthropicClient.withApiKey(_token, httpClient: transport);
      addTearDown(client.close);

      expect((await client.organization.retrieve()).name, name);
      final group = await client.compliance.retrieveGroup('grp_fixture');
      expect(group.name, name);
      expect(group.description, name);
    },
  );

  test(
    'a requestless accepted redirect keeps the last actual request for diagnostics',
    () async {
      final paths = <String>[];
      final transport = MockClient((request) async {
        paths.add(request.url.path);
        expect(request.headers['x-api-key'], _token);
        expect(request.followRedirects, isFalse);
        if (paths.length == 1) {
          return http.Response('', 302, headers: {'location': '/proxy/models'});
        }
        return http.Response(
          '{"name":"$_token',
          200,
          headers: _utf8ContentType,
        );
      });
      final client = AnthropicClient.withApiKey(
        _token,
        baseUrl: 'https://example.invalid',
        httpClient: transport,
      );
      addTearDown(client.close);

      await expectLater(client.models.list(), _redactedFormat(_token));
      expect(paths, ['/v1/models', '/proxy/models']);
    },
  );

  test(
    'AWS signed transport provenance keeps the late session token out of typed failures',
    () async {
      final encoded = Uri.encodeComponent(_token);
      final transport = MockClient((request) async {
        expect(request.headers['x-amz-security-token'], _token);
        return http.Response(
          jsonEncode({
            'id': 'model_fixture',
            'type': 'model',
            'display_name': 'Fixture',
            'created_at': encoded,
          }),
          200,
          headers: _utf8ContentType,
        );
      });
      final client = AnthropicAwsClient(
        region: 'us-west-2',
        workspaceId: 'wrkspc_fixture',
        credentials: () => const ClaudeAwsCredentials(
          accessKeyId: 'AKIDFIXTURE',
          secretAccessKey: 'fixture-signing-secret',
          sessionToken: _token,
        ),
        httpClient: transport,
      );
      addTearDown(client.close);

      await expectLater(
        client.models.retrieve('model_fixture'),
        _redactedFormat(encoded),
      );
    },
  );

  test(
    'safe malformed JSON preserves its original source and parser offset',
    () async {
      const source = '{"invalid":';
      final transport = MockClient(
        (_) async => http.Response(source, 200, headers: _utf8ContentType),
      );
      final client = AnthropicClient.withApiKey(_token, httpClient: transport);
      addTearDown(client.close);

      final original = _jsonError(source);
      await expectLater(
        client.models.list(),
        throwsA(
          isA<FormatException>()
              .having((error) => error.source, 'source', original.source)
              .having((error) => error.message, 'message', original.message)
              .having((error) => error.offset, 'offset', original.offset),
        ),
      );
    },
  );
}

Matcher _redactedFormat(String credential) => throwsA(
  isA<FormatException>()
      .having((error) => error.source, 'source', isNull)
      .having(
        (error) => error.toString(),
        'description',
        isNot(contains(credential)),
      ),
);

FormatException _jsonError(String source) {
  try {
    jsonDecode(source);
    throw StateError('Fixture must be malformed.');
  } on FormatException catch (error) {
    return error;
  }
}
