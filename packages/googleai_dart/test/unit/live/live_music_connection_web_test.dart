@TestOn('browser')
library;

import 'dart:convert';
import 'dart:js_interop';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

@JS('installLiveMusicSocketFixture')
external void _installFixture();

@JS('restoreLiveMusicSocketFixture')
external void _restoreFixture();

@JS('liveMusicSocketFixtureState')
external JSString _fixtureState();

void main() {
  // JS interop functions cannot be torn off.
  // ignore: unnecessary_lambdas
  setUp(() => _installFixture());
  // ignore: unnecessary_lambdas
  tearDown(() => _restoreFixture());

  test('uses the browser WebSocket for setup, playback and audio', () async {
    final client = GoogleAIClient(
      config: const GoogleAIConfig(
        baseUrl: 'https://gateway.example.test/music?route=one',
        authProvider: ApiKeyProvider(
          'test+/=',
          placement: AuthPlacement.header,
        ),
      ),
    );
    addTearDown(client.close);
    final music = client.createLiveMusicClient();
    addTearDown(music.close);
    final session = await music.connect(model: 'lyria-realtime-exp');
    session.play();
    final message = await session.messages.first;
    expect(message.serverContent!.audioChunks!.single.data, [0, 255]);
    final state = jsonDecode(_fixtureState().toDart) as Map<String, dynamic>;
    final uri = Uri.parse(state['url'] as String);
    expect(uri.scheme, 'wss');
    expect(uri.host, 'gateway.example.test');
    expect(
      uri.path,
      '/music/ws/google.ai.generativelanguage.v1beta.'
      'GenerativeService.BidiGenerateMusic',
    );
    expect(uri.queryParameters, {'route': 'one', 'key': 'test+/='});
    expect(state['frames'], [
      {
        'setup': {'model': 'models/lyria-realtime-exp'},
      },
      {'playbackControl': 'PLAY'},
    ]);
    expect(state['closes'], 1);
    expect(session.isConnected, isFalse);
  });

  for (final config in [
    const GoogleAIConfig(apiVersion: ApiVersion.v1),
    const GoogleAIConfig(apiMode: ApiMode.vertexAI),
    const GoogleAIConfig(authProvider: EphemeralTokenProvider('unused')),
    const GoogleAIConfig(authProvider: BearerTokenProvider('unused')),
    const GoogleAIConfig(defaultQueryParams: {'access_token': 'unused'}),
  ]) {
    test(
      'rejects unsupported version, backend or credentials before connecting '
      '(${config.apiVersion.name}, ${config.apiMode.name}, '
      '${config.authProvider.runtimeType}, ${config.defaultQueryParams.length})',
      () async {
        final client = GoogleAIClient(config: config);
        addTearDown(client.close);
        final music = client.createLiveMusicClient();
        addTearDown(music.close);
        await expectLater(
          music.connect(model: 'lyria-realtime-exp'),
          throwsUnsupportedError,
        );
        final state =
            jsonDecode(_fixtureState().toDart) as Map<String, dynamic>;
        expect(state['url'], isNull);
      },
    );
  }
}
