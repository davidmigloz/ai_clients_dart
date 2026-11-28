@TestOn('browser')
library;

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  test('browser live URI carries only the interaction-scoped credential', () {
    const config = GoogleAIConfig(
      baseUrl: 'https://proxy.example.test/service/?key=unsafe&x=a&x=b',
      defaultQueryParams: {
        'auth_token': 'old-token',
        'access_token': 'old',
        'api_key': 'unsafe',
      },
      apiVersion: ApiVersion.v1,
    );
    final uri = GenieResource.buildWebSocketUri(
      config,
      'auth_tokens/scoped+fixture',
    );
    expect(uri.scheme, 'wss');
    expect(uri.host, 'proxy.example.test');
    expect(uri.path, '/service/v1beta/interactions/live');
    expect(uri.queryParametersAll, {
      'x': ['a', 'b'],
      'auth_token': ['auth_tokens/scoped+fixture'],
    });
  });

  test('browser refuses a raw API key before opening a socket', () async {
    final client = GoogleAIClient.withApiKey('raw-api-key-fixture');
    addTearDown(client.close);
    await expectLater(
      client.interactions.genie.connect('int_fixture'),
      throwsA(
        isA<GenieConnectionException>()
            .having(
              (error) => error.message,
              'message',
              contains('scoped token'),
            )
            .having(
              (error) => error.toString(),
              'diagnostic',
              isNot(contains('raw-api-key-fixture')),
            ),
      ),
    );
  });
}
