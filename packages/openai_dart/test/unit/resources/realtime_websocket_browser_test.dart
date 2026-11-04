@TestOn('browser')
library;

import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/resources/realtime/websocket_connector_web.dart'
    as web;
import 'package:test/test.dart';

void main() {
  for (final key in [
    'Authorization',
    'authorization',
    'OpenAI-Project',
    'x-custom',
  ]) {
    test('browser rejects $key before dialing with safe alternatives', () {
      expect(
        () => web.connectWebSocket(
          Uri.parse('wss://offline.invalid/private?secret=private-query'),
          headers: {key: 'private-header-value'},
        ),
        throwsA(
          isA<RealtimeBrowserHeadersException>()
              .having((e) => e.toString(), 'header names', contains(key))
              .having(
                (e) => e.toString(),
                'WebRTC alternative',
                contains('realtimeSessions.calls.create'),
              )
              .having(
                (e) => e.toString(),
                'proxy alternative',
                contains('proxy'),
              )
              .having(
                (e) => e.toString(),
                'safe values',
                isNot(contains('private')),
              ),
        ),
      );
    });
  }
  for (final translation in [false, true]) {
    test(
      'default browser ${translation ? 'Translation' : 'Realtime'} rejects before credential lookup',
      () async {
        final auth = _Auth();
        final client = OpenAIClient(config: OpenAIConfig(authProvider: auth));
        addTearDown(client.close);
        await expectLater(
          translation
              ? client.realtime.connectTranslation(model: 'offline')
              : client.realtime.connect(model: 'offline'),
          throwsA(isA<RealtimeBrowserHeadersException>()),
        );
        expect(auth.calls, 0);
      },
    );
  }
}

class _Auth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    return {'Authorization': 'private-header-value'};
  }
}
