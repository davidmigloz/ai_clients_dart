@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'shared byte extraction preserves original Speech SocketException contract',
    () async {
      const original = SocketException('PRIVATE provider failure');
      final shared = _SocketClient(original);
      final owned = _SocketClient(original);
      final client = _client(shared, streamClientFactory: () => owned);
      addTearDown(client.close);
      await expectLater(
        client.audio.speech
            .createByteStream(
              const SpeechRequest(
                model: 'tts-1',
                input: 'PRIVATE-input',
                voice: SpeechVoice.alloy,
              ),
            )
            .toList(),
        throwsA(same(original)),
      );
      expect(owned.sends, 1);
      expect(owned.closes, 1);
      expect(shared.closes, 0);
    },
  );
  test(
    'outbound SIP actual SocketException is private and never retried',
    () async {
      const original = SocketException('PRIVATE provider failure');
      final transport = _SocketClient(original);
      final client = _client(transport);
      addTearDown(client.close);
      await expectLater(
        client.live.sessions.create(
          LiveSessionCreateRequest(
            session: LiveMediaSessionCreateParams(model: 'gpt-live-1'),
            transport: LiveSIPTransport(
              destination: '+14155550123',
              trunk: LiveSIPTrunk(
                providerUrl: 'sips:sip.example.com:5061',
                auth: LiveSIPTrunkAuth(
                  username: 'PRIVATE-user',
                  password: 'PRIVATE-password',
                ),
                callerNumber: '+14155550100',
              ),
            ),
          ),
        ),
        throwsA(
          isA<ConnectionException>()
              .having((e) => e.cause, 'actual socket cause', same(original))
              .having(
                (e) => e.url,
                'original URL',
                contains('/PRIVATE-proxy/v1/live/sessions'),
              )
              .having(
                (e) => e.toString(),
                'private diagnostic',
                isNot(contains('PRIVATE')),
              ),
        ),
      );
      expect(transport.sends, 1);
      expect(transport.closes, 0);
    },
  );

  for (final afterAudio in [false, true]) {
    test(
      'recording actual SocketException ${afterAudio ? 'after audio' : 'before headers'} owns cleanup and never replays',
      () async {
        const original = SocketException('PRIVATE recording failure');
        final shared = _SocketClient(original);
        final owned = _SocketClient(original, afterAudio: afterAudio);
        final client = _client(shared, streamClientFactory: () => owned);
        addTearDown(client.close);
        await expectLater(
          client.live.sessions.downloadRecordingStream('live_PRIVATE').toList(),
          throwsA(
            isA<ConnectionException>()
                .having((e) => e.cause, 'actual socket cause', same(original))
                .having(
                  (e) => e.url,
                  'original URL',
                  contains(
                    '/PRIVATE-proxy/v1/live/sessions/live_PRIVATE/content',
                  ),
                )
                .having(
                  (e) => e.toString(),
                  'private diagnostic',
                  isNot(contains('PRIVATE')),
                ),
          ),
        );
        expect(owned.sends, 1);
        expect(owned.closes, 1);
        expect(shared.sends, 0);
        expect(shared.closes, 0);
      },
    );
  }
}

OpenAIClient _client(
  http.Client transport, {
  http.Client Function()? streamClientFactory,
}) => OpenAIClient(
  config: const OpenAIConfig(
    authProvider: ApiKeyProvider('PRIVATE-key'),
    baseUrl: 'https://fixture.invalid/PRIVATE-proxy/v1',
    retryPolicy: RetryPolicy(
      maxRetries: 4,
      initialDelay: Duration(milliseconds: 1),
      maxDelay: Duration(milliseconds: 5),
      jitter: 0,
    ),
  ),
  httpClient: transport,
  streamClientFactory: streamClientFactory,
);

class _SocketClient extends http.BaseClient {
  _SocketClient(this.original, {this.afterAudio = false});
  final SocketException original;
  final bool afterAudio;
  int sends = 0;
  int closes = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sends++;
    await request.finalize().drain<void>();
    if (!afterAudio) throw original;
    return http.StreamedResponse(
      _audioThenError(),
      200,
      headers: {'content-type': 'audio/wav'},
    );
  }

  Stream<List<int>> _audioThenError() async* {
    yield [0, 255, 128, 13, 10];
    throw original;
  }

  @override
  void close() => closes++;
}
