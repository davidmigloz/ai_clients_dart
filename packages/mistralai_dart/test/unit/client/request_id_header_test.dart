@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('X-Request-ID header on streaming requests', () {
    late http.BaseRequest captured;

    MistralClient createClient({
      bool sendRequestIdHeader = false,
      Map<String, String> defaultHeaders = const {},
    }) {
      final mockClient = MockClient.streaming((request, _) async {
        captured = request;
        return http.StreamedResponse(
          Stream.value(utf8.encode('data: [DONE]\n\n')),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });
      addTearDown(mockClient.close);
      final client = MistralClient(
        config: MistralConfig(
          authProvider: const ApiKeyProvider('test-key'),
          defaultHeaders: defaultHeaders,
          sendRequestIdHeader: sendRequestIdHeader,
        ),
        httpClient: mockClient,
      );
      addTearDown(client.close);
      return client;
    }

    final streams = <String, Future<void> Function(MistralClient)>{
      'chat.createStream': (client) async {
        await client.chat
            .createStream(
              request: ChatCompletionRequest(
                model: 'mistral-small-latest',
                messages: [ChatMessage.user('Hello')],
              ),
            )
            .drain<void>();
      },
      'audio.transcriptions.createStream (multipart)': (client) async {
        await client.audio.transcriptions
            .createStream(
              request: const TranscriptionRequest(
                model: 'voxtral-mini-latest',
                fileBytes: [1, 2, 3],
                fileName: 'clip.wav',
              ),
            )
            .drain<void>();
      },
    };

    for (final MapEntry(key: name, value: stream) in streams.entries) {
      group(name, () {
        test('does not send X-Request-ID by default', () async {
          await stream(createClient());

          expect(captured.headers['Authorization'], 'Bearer test-key');
          expect(captured.headers.containsKey('X-Request-ID'), isFalse);
        });

        test('sends X-Request-ID when sendRequestIdHeader is true', () async {
          await stream(createClient(sendRequestIdHeader: true));

          expect(captured.headers['X-Request-ID'], isNotEmpty);
        });

        for (final sendRequestIdHeader in [false, true]) {
          test('preserves caller-supplied X-Request-ID '
              '(sendRequestIdHeader: $sendRequestIdHeader)', () async {
            await stream(
              createClient(
                sendRequestIdHeader: sendRequestIdHeader,
                defaultHeaders: const {'X-Request-ID': 'caller-id'},
              ),
            );

            expect(captured.headers['X-Request-ID'], 'caller-id');
          });
        }
      });
    }
  });
}
