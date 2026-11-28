import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

const _fixtureToken = 'auth_tokens/fixture-opaque-credential';
const _backend = GoogleAIConfig.googleAI(
  authProvider: ApiKeyProvider(
    'backend-fixture',
    placement: AuthPlacement.header,
  ),
  apiVersion: ApiVersion.v1,
  interactionsApiVersion: ApiVersion.v1,
);

GoogleAIClient _client(
  http.Client transport, {
  GoogleAIConfig config = _backend,
}) {
  final client = GoogleAIClient(config: config, httpClient: transport);
  addTearDown(transport.close);
  addTearDown(client.close);
  return client;
}

void main() {
  test(
    'Genie creates a bare v1beta interaction and an interaction-scoped token',
    () async {
      final expiry = DateTime.utc(2026, 11, 28, 0, 10);
      final requests = <http.Request>[];
      final client = _client(
        MockClient((request) async {
          requests.add(request);
          expect(request.headers['x-goog-api-key'], 'backend-fixture');
          expect(request.method, 'POST');
          expect(request.headers['content-type'], contains('application/json'));
          return request.url.path.endsWith('/auth_tokens')
              ? http.Response(
                  jsonEncode({
                    'auth_token': _fixtureToken,
                    'expires_at': expiry.toIso8601String(),
                  }),
                  200,
                )
              : http.Response(
                  '{"id":"int_genie","status":"in_progress","model":"genie-4"}',
                  200,
                );
        }),
      );
      final interaction = await client.interactions.genie.create();
      final token = await client.interactions.genie.createAuthToken(
        interaction.id,
        expireTime: expiry,
      );
      await client.interactions.genie.createAuthToken(
        'interactions/token-scope',
      );

      expect(interaction.id, 'int_genie');
      expect(token.authToken, _fixtureToken);
      expect(token.expiresAt, expiry);
      expect(requests[0].url.pathSegments, ['v1beta', 'interactions']);
      expect(jsonDecode(requests[0].body), {'model': 'genie-4'});
      expect(requests[1].url.pathSegments, [
        'v1beta',
        'interactions',
        'int_genie',
        'auth_tokens',
      ]);
      expect(jsonDecode(requests[1].body), {
        'expire_time': expiry.toIso8601String(),
      });
      expect(requests[2].url.pathSegments, [
        'v1beta',
        'interactions',
        'interactions/token-scope',
        'auth_tokens',
      ]);
      expect(jsonDecode(requests[2].body), isEmpty);
    },
  );

  test(
    'redacts scoped tokens from successful token logging and HTTP errors',
    () async {
      final oldLevel = Logger.root.level;
      Logger.root.level = Level.ALL;
      addTearDown(() => Logger.root.level = oldLevel);
      final records = <LogRecord>[];
      final subscription = Logger.root.onRecord.listen(records.add);
      addTearDown(subscription.cancel);
      var calls = 0;
      final client = _client(
        MockClient(
          (request) async => ++calls == 1
              ? http.Response('{"auth_token":"$_fixtureToken"}', 200)
              : http.Response(
                  '{"error":{"message":"could not issue token $_fixtureToken","details":[{"auth_token":"$_fixtureToken"}]}}',
                  400,
                ),
        ),
        config: _backend.copyWith(redactionList: const [], logLevel: Level.ALL),
      );
      final token = await client.interactions.genie.createAuthToken(
        'int_genie',
      );
      expect(token.authToken, _fixtureToken);
      await expectLater(
        client.interactions.genie.createAuthToken('int_genie'),
        throwsA(
          isA<ApiException>()
              .having(
                (error) => error.message,
                'message',
                isNot(contains('fixture-opaque-credential')),
              )
              .having(
                (error) => error.details.toString(),
                'details',
                isNot(contains('fixture-opaque-credential')),
              )
              .having(
                (error) => error.responseMetadata?.bodyExcerpt,
                'body excerpt',
                isNot(contains('fixture-opaque-credential')),
              ),
        ),
      );
      expect(
        records.map((record) => record.message).join('\n'),
        contains('Body:'),
      );
      expect(
        records.map((record) => '${record.message} ${record.error}').join('\n'),
        isNot(contains('fixture-opaque-credential')),
      );
    },
  );

  test(
    'validates Developer-only operations, IDs and explicit token form',
    () async {
      final transport = MockClient(
        (_) => throw StateError('Unexpected HTTP request'),
      );
      final vertex = _client(
        transport,
        config: GoogleAIConfig.vertexAI(
          projectId: 'example',
          authProvider: const BearerTokenProvider('unused'),
        ),
      ).interactions.genie;
      await expectLater(vertex.create(), throwsUnsupportedError);
      await expectLater(
        vertex.createAuthToken('int_genie'),
        throwsUnsupportedError,
      );
      await expectLater(vertex.connect('int_genie'), throwsUnsupportedError);

      final genie = _client(
        MockClient((_) => throw StateError('Unexpected HTTP request')),
      ).interactions.genie;
      await expectLater(genie.createAuthToken(' '), throwsArgumentError);
      await expectLater(genie.connect(' '), throwsArgumentError);
      await expectLater(
        genie.connect('int_genie', authToken: 'raw-key'),
        throwsArgumentError,
      );
      await expectLater(
        genie.connect('int_genie', timeout: Duration.zero),
        throwsArgumentError,
      );
    },
  );
}
