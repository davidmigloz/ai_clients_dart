@TestOn('browser')
library;

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'rejects Vertex OAuth headers before a browser network attempt',
    () async {
      final client = GoogleAIClient(
        config: GoogleAIConfig.vertexAI(
          projectId: 'P',
          authProvider: const BearerTokenProvider('adc-secret'),
        ),
      );
      final live = client.createLiveClient();
      addTearDown(client.close);
      addTearDown(live.close);

      await expectLater(
        live.connect(model: 'gemini-3.8-live'),
        throwsA(
          isA<LiveConnectionException>()
              .having(
                (error) => error.message,
                'guidance',
                contains('Vertex AI Live requires OAuth headers'),
              )
              .having((error) => error.uri?.query, 'URI query', isEmpty)
              .having(
                (error) => '${error.message} ${error.cause}',
                'diagnostics',
                isNot(contains('adc-secret')),
              ),
        ),
      );
    },
  );

  test('guides browser ephemeral auth to query placement', () async {
    final client = GoogleAIClient(
      config: const GoogleAIConfig.googleAI(
        authProvider: EphemeralTokenProvider(
          'auth_tokens/header-secret',
          placement: EphemeralTokenPlacement.header,
        ),
        defaultQueryParams: {'key': 'config-secret'},
      ),
    );
    final live = client.createLiveClient();
    addTearDown(client.close);
    addTearDown(live.close);

    await expectLater(
      live.connect(model: 'gemini-3.8-live'),
      throwsA(
        isA<LiveConnectionException>()
            .having(
              (error) => error.message,
              'guidance',
              contains('connect(accessToken: ...)'),
            )
            .having(
              (error) => error.uri?.path,
              'URI path',
              endsWith('.BidiGenerateContentConstrained'),
            )
            .having((error) => error.uri?.query, 'URI query', isEmpty)
            .having(
              (error) => '${error.message} ${error.cause}',
              'diagnostics',
              allOf(
                isNot(contains('header-secret')),
                isNot(contains('config-secret')),
              ),
            ),
      ),
    );
  });
}
