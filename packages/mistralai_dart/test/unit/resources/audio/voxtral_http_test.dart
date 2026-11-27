import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

MistralClient _mockClient(
  Future<http.Response> Function(http.Request request) handler,
) {
  final httpClient = MockClient(handler);
  final client = MistralClient(
    config: const MistralConfig(
      authProvider: ApiKeyProvider('test-key'),
      defaultHeaders: {'accept': '*/*', 'Content-Type': 'application/json'},
    ),
    httpClient: httpClient,
  );
  addTearDown(client.close);
  addTearDown(httpClient.close);
  return client;
}

void main() {
  group('Current Voxtral HTTP contract', () {
    const transcription = TranscriptionRequest(
      model: 'voxtral-mini-transcribe-3-0',
      file: 'file-123',
      diarize: true,
      // The explicit list has precedence over the legacy segment+word flag.
      timestampGranularities: true,
      timestampGranularityOptions: [TranscriptionTimestampGranularity.segment],
      speakerReferences: {'Míra': 'YQ=='},
    );
    const usage = {
      'prompt_tokens': 10,
      'completion_tokens': 4,
      'total_tokens': 14,
    };
    const segment = {
      'type': 'transcription_segment',
      'start': null,
      'end': null,
      'speaker_id': 'Míra',
      'score': 0.75,
      'text': 'Hello.',
    };
    const transcript = {
      'model': 'voxtral-mini-transcribe-3-0',
      'text': 'Hello.',
      'language': null,
      'segments': [segment],
      'usage': usage,
    };

    void expectMultipart(http.Request request, {required bool stream}) {
      final headers = request.headers;
      expect(request.method, 'POST');
      expect(request.url.path, '/v1/audio/transcriptions');
      expect(request.url.fragment, isEmpty);
      expect(
        headers['accept'],
        stream ? 'text/event-stream' : 'application/json',
      );
      expect(
        headers['content-type'],
        startsWith('multipart/form-data; boundary='),
      );
      expect(headers['authorization'], 'Bearer test-key');

      final body = utf8.decode(request.bodyBytes);
      expect(body, contains('name="file_id"\r\n\r\nfile-123'));
      expect(body, contains('name="diarize"\r\n\r\ntrue'));
      final timestamp = RegExp(
        'name="timestamp_granularities"\r\n\r\n([^\r]+)',
      ).allMatches(body).map((value) => value.group(1));
      expect(timestamp, ['segment']);
      final references = RegExp(
        'name="speaker_references"[^\r]*\r\n(?:[^\r]+\r\n)*\r\n([^\r]+)',
      ).allMatches(body).map((value) => jsonDecode(value.group(1)!));
      expect(references, [
        {'Míra': 'YQ=='},
      ]);
      expect(body.contains('name="stream"\r\n\r\ntrue'), stream);
    }

    test(
      'complete transcribes multipart options and retains the response',
      () async {
        final client = _mockClient((request) async {
          expectMultipart(request, stream: false);
          return http.Response(
            jsonEncode(transcript),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });
        final result = await client.audio.transcriptions.create(
          request: transcription,
        );
        expect(result.model, 'voxtral-mini-transcribe-3-0');
        expect(result.segments?.single.speakerId, 'Míra');
        expect(result.segments?.single.id, isNull);
        expect(result.segments?.single.duration, isNull);
        expect(result.toJson(), transcript);
      },
    );

    test(
      'stream requests the same fields and preserves each SSE event',
      () async {
        const frames = [
          {'type': 'transcription.language', 'audio_language': 'en'},
          {'type': 'transcription.text.delta', 'text': 'Hello.'},
          {
            'type': 'transcription.segment',
            'text': 'Hello.',
            'start': null,
            'end': null,
            'speaker_id': 'Míra',
          },
          {'type': 'turn.start', 'time_s': 0.1},
          {'type': 'turn.eager_end', 'time_s': 0.8},
          {'type': 'turn.resume', 'time_s': 1},
          {'type': 'turn.end', 'time_s': 1.2, 'end_reason': 'threshold'},
          {'type': 'transcription.done', ...transcript},
          {
            'type': 'new.event',
            'payload': {'state': 'new'},
          },
        ];
        final client = _mockClient((request) async {
          expectMultipart(request, stream: true);
          return http.Response(
            frames.map((frame) => 'data: ${jsonEncode(frame)}\n\n').join(),
            200,
            headers: {'content-type': 'text/event-stream; charset=utf-8'},
          );
        });
        final events = await client.audio.transcriptions
            .createStream(request: transcription)
            .toList();
        expect(events.map((event) => event.toJson()), frames);
        expect(events[0].audioLanguage, 'en');
        expect(events[2].segment?.speakerId, 'Míra');
        final edited = events[2].copyWith(
          segment: events[2].segment?.copyWith(text: 'Edited.'),
        );
        expect(edited.text, 'Edited.');
        expect(edited.toJson()['text'], 'Edited.');
        expect(events[6].endReason, 'threshold');
        expect(events[7].isDone, isTrue);
        expect(events[7].usage?.totalTokens, 14);
      },
    );

    test('speaker references require diarization before submitting', () async {
      final client = _mockClient(
        (_) => fail('An invalid request reached the transport.'),
      );

      final request = transcription.copyWith(diarize: false);
      await expectLater(
        client.audio.transcriptions.create(request: request),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        client.audio.transcriptions.createStream(request: request),
        emitsError(isA<ValidationException>()),
      );
    });

    test(
      'speech serializes expressive options in JSON and SSE requests',
      () async {
        const speech = SpeechRequest(
          model: 'voxtral-mini-tts-3-0',
          input: 'Welcome, Voxtral.',
          voiceId: 'preset-pvc',
          expressiveness: 2,
          phonemeHints: {
            'Voxtral': [IpaPhoneme.v, IpaPhoneme.openO],
          },
          conversationHistory: [
            SpeechTurn.user(audio: SpeechTurnAudio(data: 'YQ==')),
            SpeechTurn.assistant(
              text: 'Hi.',
              audio: SpeechTurnAudio(data: 'Yg=='),
            ),
            SpeechTurn.user(audio: SpeechTurnAudio(data: 'Yw==')),
          ],
        );
        var calls = 0;
        final client = _mockClient((request) async {
          final stream = calls++ > 0;
          expect(request.method, 'POST');
          expect(request.url.path, '/v1/audio/speech');
          expect(
            request.headers['accept'],
            stream ? 'text/event-stream' : 'application/json',
          );
          expect(request.headers['authorization'], 'Bearer test-key');
          expect(jsonDecode(request.body), {
            'model': 'voxtral-mini-tts-3-0',
            'input': 'Welcome, Voxtral.',
            'voice_id': 'preset-pvc',
            'expressiveness': 2,
            'phoneme_hints': {
              'Voxtral': ['v', 'ɔ'],
            },
            'conversation_history': [
              {
                'role': 'user',
                'audio': {'data': 'YQ=='},
              },
              {
                'role': 'assistant',
                'audio': {'data': 'Yg=='},
                'text': 'Hi.',
              },
              {
                'role': 'user',
                'audio': {'data': 'Yw=='},
              },
            ],
            'stream': stream,
          });
          if (!stream) return http.Response('{"audio_data":"YQ=="}', 200);
          return http.Response(
            'event: speech.audio.delta\n'
            'data: {"audio_data":"YQ=="}\n\n'
            'data: {"type":"speech.audio.done","usage":${jsonEncode(usage)}}\n\n',
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        });

        final response = await client.audio.speech.create(request: speech);
        final events = await client.audio.speech
            .createStream(request: speech)
            .toList();
        expect(base64Decode(response.audioData), [97]);
        expect(events, [
          const SpeechStreamAudioDelta(audioData: 'YQ=='),
          const SpeechStreamDone(
            usage: UsageInfo(
              promptTokens: 10,
              completionTokens: 4,
              totalTokens: 14,
            ),
          ),
        ]);
        expect(calls, 2);

        final copy = SpeechRequest.fromJson(speech.toJson());
        expect(copy, speech);
        expect(copy.hashCode, speech.hashCode);
        expect(
          copy.copyWith(phonemeHints: null).toJson(),
          isNot(contains('phoneme_hints')),
        );
      },
    );

    test(
      'voice search follows cursors and repeats array filter keys',
      () async {
        const voice = {
          'id': 'voice-1',
          'name': 'Current preset',
          'description': 'Test voice',
          'created_at': '2026-11-27T12:00:00Z',
          'user_id': null,
          'type': 'preset',
          'kind': 'pvc',
        };
        var calls = 0;
        final client = _mockClient((request) async {
          final first = calls++ == 0;
          expect(request.method, 'GET');
          expect(request.url.path, '/v2/audio/voices');
          expect(request.url.queryParametersAll, {
            'page_size': ['3'],
            if (!first) 'page_token': ['next +/? token'],
            'type': ['preset'],
            'gender': ['female', 'neutral'],
            'language': ['en', 'fr'],
            'query': ['woman + child'],
            'kind': ['pvc'],
          });
          return http.Response(
            jsonEncode({
              'data': [if (first) voice],
              'next_page_token': first ? 'next +/? token' : null,
            }),
            200,
          );
        });
        Future<VoiceListPage> search({String? cursor}) =>
            client.audio.voices.search(
              pageSize: 3,
              pageToken: cursor,
              type: 'preset',
              gender: const [VoiceGender.female, VoiceGender.neutral],
              language: const ['en', 'fr'],
              query: 'woman + child',
              kind: VoiceKind.pvc,
            );
        final page = await search();
        expect(page.data.single.type, VoiceType.preset);
        expect(page.data.single.kind, VoiceKind.pvc);
        expect(page.data.single.description, 'Test voice');
        final tail = await search(cursor: page.nextPageToken);
        expect(tail.data, isEmpty);
        expect(tail.nextPageToken, isNull);
        expect(calls, 2);
      },
    );

    test(
      'voice sample negotiates binary audio and encodes the voice ID',
      () async {
        const wave = [82, 73, 70, 70, 0, 128, 255];
        final client = _mockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.pathSegments, [
            'v1',
            'audio',
            'voices',
            'a/b +',
            'sample',
          ]);
          expect(request.headers['accept'], 'audio/wav');
          expect(request.headers.containsKey('content-type'), isFalse);
          return http.Response.bytes(
            wave,
            200,
            headers: {'content-type': 'audio/wav'},
          );
        });
        expect(
          await client.audio.voices.getSampleAudio(voiceId: 'a/b +'),
          wave,
        );
      },
    );

    test('voice sample errors still use the HTTP exception mapping', () async {
      final client = _mockClient(
        (_) async => http.Response('{"message":"Unknown voice"}', 404),
      );
      await expectLater(
        client.audio.voices.getSampleAudio(voiceId: 'missing'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
    });

    test(
      'voice create and PATCH send current metadata keys and nullable fields',
      () async {
        var calls = 0;
        final client = _mockClient((request) async {
          if (calls++ == 0) {
            expect(request.method, 'POST');
            expect(request.url.path, '/v1/audio/voices');
            expect(jsonDecode(request.body), {'name': 'Voice'});
          } else {
            expect(request.method, 'PATCH');
            expect(request.url.path, '/v1/audio/voices/voice-1');
            expect(jsonDecode(request.body), {
              'retention_notice': 21,
              'description': null,
            });
          }
          return http.Response(
            '{"id":"voice-1","name":"Voice","type":"custom","kind":"ivc",'
            '"created_at":"2026-11-27T12:00:00Z","user_id":"user-1"}',
            200,
          );
        });
        final created = await client.audio.voices.create(
          request: const VoiceCreateRequest(name: 'Voice'),
        );
        final updated = await client.audio.voices.update(
          voiceId: created.id,
          request: const VoiceUpdateRequest(
            retentionNotice: 21,
            clearFields: {VoiceUpdateField.description},
          ),
        );
        expect(updated.kind, VoiceKind.ivc);
        expect(updated.type, VoiceType.custom);
        expect(calls, 2);
      },
    );
  });
}
