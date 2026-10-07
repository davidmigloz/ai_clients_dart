import 'package:openai_dart/src/resources/responses/websocket_connector_common.dart';
import 'package:openai_dart/src/resources/responses/websocket_connector_stub.dart'
    as stub;
import 'package:test/test.dart';

void main() {
  group('Responses browser connector policy', () {
    for (final headers in [
      {'Authorization': 'secret-bearer'},
      {'authorization': 'secret-bearer'},
      {'OpenAI-Project': 'secret-project'},
      {'OpenAI-Organization': 'secret-organization'},
      {'X-Future-Header': 'secret-future'},
      {'Authorization': 'secret-bearer', 'OpenAI-Project': 'secret-project'},
    ]) {
      test(
        'rejects all supplied headers before dialing: ${headers.keys.join(', ')}',
        () {
          final uri = Uri.parse(
            'invalid://user:secret-url@never-dial.invalid/responses?token=secret-token',
          );
          expect(
            () => validateResponsesBrowserHandshake(uri, headers),
            throwsA(
              isA<ResponsesBrowserHeadersException>()
                  .having(
                    (e) => e.toString(),
                    'keys only',
                    contains(headers.keys.first),
                  )
                  .having(
                    (e) => e.toString(),
                    'no secrets',
                    isNot(contains('secret')),
                  )
                  .having(
                    (e) => e.message,
                    'proxy guidance',
                    contains('authenticated backend WebSocket proxy'),
                  )
                  .having(
                    (e) => e.message,
                    'Responses guidance',
                    contains('Responses API'),
                  )
                  .having(
                    (e) => e.message,
                    'no Realtime guidance',
                    isNot(contains('WebRTC')),
                  )
                  .having((e) => e.url, 'no URL', isNull),
            ),
          );
        },
      );
    }

    test('stub fails safely without displaying URL or headers', () {
      expect(
        () => stub.connectResponsesWebSocket(
          Uri.parse('wss://secret-url.example/responses?token=secret'),
          headers: {'Authorization': 'secret-header'},
        ),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.toString(),
            'safe diagnostic',
            isNot(contains('secret')),
          ),
        ),
      );
    });
    for (final headers in [null, <String, String>{}]) {
      test('headerless invalid URL fails with safe scheme diagnostic', () {
        expect(
          () => validateResponsesBrowserHandshake(
            Uri.parse('https://secret.invalid/responses?token=secret'),
            headers,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.toString(),
              'safe diagnostic',
              isNot(contains('secret')),
            ),
          ),
        );
      });
    }
  });
}
