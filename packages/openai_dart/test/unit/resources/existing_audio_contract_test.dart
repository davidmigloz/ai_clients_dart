import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _privateText = 'PRIVATE transcript café 🚀';
const Map<String, String> _done = {
  'type': 'transcript.text.done',
  'text': _privateText,
};
const _delta = {'type': 'transcript.text.delta', 'delta': 'café 🚀'};
const Map<String, Object> _segment = {
  'type': 'transcript.text.segment',
  'id': 'segment-one',
  'start': 0.25,
  'end': 1.75,
  'text': 'café 🚀',
  'speaker': 'speaker-one',
};
const Map<String, Object> _verbose = {
  'language': 'english',
  'duration': 2.5,
  'text': _privateText,
};
const Map<String, Object> _diarized = {
  'task': 'transcribe',
  'duration': 2.5,
  'text': _privateText,
  'segments': [_segment],
};
const _rawText = ' \r\n1\r\n00:00:00,000 --> 00:00:01,000\r\n café 🚀 \r\n\r\n';

enum _Mode {
  transcriptionJson,
  transcriptionVerbose,
  transcriptionDiarized,
  transcriptionText,
  transcriptionSrt,
  transcriptionVtt,
  translationJson,
  translationVerbose,
  translationText,
  translationSrt,
  translationVtt,
  transcriptionStream;

  bool get streaming => this == transcriptionStream;
  bool get translation => name.startsWith('translation');
  bool get raw =>
      name.endsWith('Text') || name.endsWith('Srt') || name.endsWith('Vtt');
  String get endpoint => translation ? 'translations' : 'transcriptions';
  String get format => switch (this) {
    transcriptionVerbose || translationVerbose => 'verbose_json',
    transcriptionDiarized => 'diarized_json',
    transcriptionText || translationText => 'text',
    transcriptionSrt || translationSrt => 'srt',
    transcriptionVtt || translationVtt => 'vtt',
    _ => 'json',
  };
  String get accept => streaming
      ? 'text/event-stream'
      : raw
      ? 'text/plain'
      : 'application/json';
}

void main() {
  group('Existing Audio public multipart contract', () {
    test('all fourteen canonical fields reach exact multipart parts', () async {
      final fixture = _Fixture((_, _) => _success(_Mode.transcriptionJson));
      addTearDown(fixture.client.close);
      final bytes = Uint8List.fromList([0, 255, 128, 13, 10, 65]);
      final request = _transcription().copyWith(
        file: bytes,
        filename: 'meeting.wav',
        fileContentType: 'audio/wav',
        model: 'future-transcription-model',
        chunkingStrategy: const TranscriptionChunkingStrategy.serverVad(
          TranscriptionVadConfig(
            prefixPaddingMs: 17,
            silenceDurationMs: 29,
            threshold: 0.3,
          ),
        ),
        include: const [TranscriptionInclude.logprobs],
        keywords: const ['OpenAI', 'café'],
        knownSpeakerNames: const ['one', 'two', 'three', 'four'],
        knownSpeakerReferences: const [
          'data:audio/wav;base64,AA==',
          'data:audio/ogg;base64,AQ==',
          'data:audio/flac;base64,Ag==',
          'data:audio/webm;base64,Aw==',
        ],
        language: 'en',
        languages: const ['en', 'es'],
        prompt: 'A Unicode café prompt',
        responseFormat: AudioResponseFormat.json,
        stream: false,
        temperature: 0.37,
        timestampGranularities: const [
          TimestampGranularity.word,
          TimestampGranularity.segment,
        ],
      );
      await fixture.client.audio.transcriptions.create(request);
      final sent = fixture.borrowed.requests.single;
      final parts = _parts(sent, fixture.borrowed.bodies.single);
      expect(parts.keys.toSet(), {
        'file',
        'model',
        'chunking_strategy[type]',
        'chunking_strategy[prefix_padding_ms]',
        'chunking_strategy[silence_duration_ms]',
        'chunking_strategy[threshold]',
        'include[]',
        'keywords[]',
        'known_speaker_names[]',
        'known_speaker_references[]',
        'language',
        'languages[]',
        'prompt',
        'response_format',
        'stream',
        'temperature',
        'timestamp_granularities[]',
      });
      expect(parts['file']!.single.bytes, orderedEquals(bytes));
      expect(parts['file']!.single.filename, 'meeting.wav');
      expect(parts['file']!.single.contentType, 'audio/wav');
      expect(_values(parts, 'model'), ['future-transcription-model']);
      expect(_values(parts, 'chunking_strategy[type]'), ['server_vad']);
      expect(_values(parts, 'chunking_strategy[prefix_padding_ms]'), ['17']);
      expect(_values(parts, 'chunking_strategy[silence_duration_ms]'), ['29']);
      expect(_values(parts, 'chunking_strategy[threshold]'), ['0.3']);
      expect(_values(parts, 'include[]'), ['logprobs']);
      expect(_values(parts, 'keywords[]'), ['OpenAI', 'café']);
      expect(_values(parts, 'known_speaker_names[]'), [
        'one',
        'two',
        'three',
        'four',
      ]);
      expect(
        _values(parts, 'known_speaker_references[]'),
        request.knownSpeakerReferences,
      );
      expect(_values(parts, 'language'), ['en']);
      expect(_values(parts, 'languages[]'), ['en', 'es']);
      expect(_values(parts, 'prompt'), ['A Unicode café prompt']);
      expect(_values(parts, 'response_format'), ['json']);
      expect(_values(parts, 'stream'), ['false']);
      expect(_values(parts, 'temperature'), ['0.37']);
      expect(_values(parts, 'timestamp_granularities[]'), ['word', 'segment']);
      for (final name in parts.keys.where((name) => name.endsWith('[]'))) {
        expect(parts[name]!.every((part) => part.filename == null), isTrue);
      }
      expect(fixture.borrowed.sends, 1);
      expect(fixture.auth.calls, greaterThan(0));
    });

    test(
      'auto chunking is one literal field and nullable options are omitted',
      () async {
        final fixture = _Fixture((_, _) => _success(_Mode.transcriptionJson));
        addTearDown(fixture.client.close);
        await fixture.client.audio.transcriptions.create(
          _transcription().copyWith(
            chunkingStrategy: const TranscriptionChunkingStrategy.auto(),
            stream: null,
          ),
        );
        final parts = _parts(
          fixture.borrowed.requests.single,
          fixture.borrowed.bodies.single,
        );
        expect(_values(parts, 'chunking_strategy'), ['auto']);
        expect(parts.keys.toSet(), {'file', 'model', 'chunking_strategy'});
        expect(parts.containsKey('stream'), isFalse);
        expect(
          parts.entries
              .where((entry) => entry.key != 'file')
              .map((entry) => entry.value)
              .expand((parts) => parts)
              .any((part) => part.text == 'null'),
          isFalse,
        );
      },
    );

    test(
      'valid percent-encoded speaker data URL reaches multipart unchanged',
      () async {
        final fixture = _Fixture((_, _) => _success(_Mode.transcriptionJson));
        addTearDown(fixture.client.close);
        const reference = 'data:audio/wav,%00%FF%80%01';
        await fixture.client.audio.transcriptions.create(
          _transcription().copyWith(
            knownSpeakerNames: const ['speaker'],
            knownSpeakerReferences: const [reference],
          ),
        );
        final parts = _parts(
          fixture.borrowed.requests.single,
          fixture.borrowed.bodies.single,
        );
        expect(_values(parts, 'known_speaker_references[]'), [reference]);
        expect(_values(parts, 'known_speaker_names[]'), ['speaker']);
        expect(fixture.borrowed.sends, 1);
      },
    );

    for (final mode in _Mode.values.where((mode) => !mode.streaming)) {
      test(
        '${mode.name} selects output and preserves exact request metadata',
        () async {
          final fixture = _Fixture((_, _) => _success(mode));
          addTearDown(fixture.client.close);
          final result = await _invoke(mode, fixture.client);
          final sent = fixture.borrowed.requests.single;
          expect(sent.method, 'POST');
          expect(
            sent.url.toString(),
            'https://fixture.invalid/proxy/v1/audio/${mode.endpoint}',
          );
          expect(sent.headers['accept'], mode.accept);
          expect(
            sent.headers['content-type'],
            startsWith('multipart/form-data; boundary='),
          );
          expect(sent.headers['authorization'], 'Bearer fixture-credential');
          expect(sent.headers['openai-project'], 'project-fixture');
          final parts = _parts(sent, fixture.borrowed.bodies.single);
          expect(_values(parts, 'model'), [
            if (mode.translation)
              'future-translation-model'
            else
              'future-transcription-model',
          ]);
          expect(_values(parts, 'response_format'), [mode.format]);
          expect(_values(parts, 'prompt'), ['A Unicode café prompt']);
          expect(_values(parts, 'temperature'), ['0.25']);
          expect(parts['file']!.single.filename, 'recording.ogg');
          expect(parts['file']!.single.contentType, 'audio/ogg');
          expect(
            parts['file']!.single.bytes,
            orderedEquals([0, 255, 128, 1, 2]),
          );
          if (mode.raw) {
            expect(result, _rawText);
          } else if (mode == _Mode.translationVerbose) {
            final verbose = result! as TranslationVerboseResponse;
            expect(verbose.task, isNull);
            expect(verbose.language, 'english');
            expect(verbose.duration, 2.5);
            expect(verbose.text, _privateText);
          } else {
            expect((result! as dynamic).text, _privateText);
          }
          expect(fixture.borrowed.sends, 1);
          expect(fixture.borrowed.closes, 0);
          expect(fixture.factoryCalls, 0);
        },
      );
    }

    for (final mode in [_Mode.transcriptionJson, _Mode.translationJson]) {
      for (final entry in const {
        'flac': 'audio/flac',
        'mp3': 'audio/mpeg',
        'mp4': 'audio/mp4',
        'mpeg': 'audio/mpeg',
        'mpga': 'audio/mpeg',
        'm4a': 'audio/mp4',
        'ogg': 'audio/ogg',
        'wav': 'audio/wav',
        'webm': 'audio/webm',
      }.entries) {
        test(
          '${mode.name} keeps ${entry.key} upload bytes and explicit MIME',
          () async {
            final fixture = _Fixture((_, _) => _success(mode));
            addTearDown(fixture.client.close);
            await _invoke(
              mode,
              fixture.client,
              transcription: _transcription().copyWith(
                filename: 'audio.${entry.key}',
                fileContentType: entry.value,
              ),
              translation: _translation().copyWith(
                filename: 'audio.${entry.key}',
                fileContentType: entry.value,
              ),
            );
            final parts = _parts(
              fixture.borrowed.requests.single,
              fixture.borrowed.bodies.single,
            );
            expect(parts['file']!.single.filename, 'audio.${entry.key}');
            expect(parts['file']!.single.contentType, entry.value);
            expect(
              parts['file']!.single.bytes,
              orderedEquals([0, 255, 128, 1, 2]),
            );
            expect(parts.containsKey('file_content_type'), isFalse);
          },
        );
      }
    }

    for (final stream in [null, false]) {
      test(
        'buffered stream=$stream/chunking=null never emits literal null',
        () async {
          final fixture = _Fixture((_, _) => _success(_Mode.transcriptionJson));
          addTearDown(fixture.client.close);
          await fixture.client.audio.transcriptions.create(
            _transcription().copyWith(chunkingStrategy: null, stream: stream),
          );
          final parts = _parts(
            fixture.borrowed.requests.single,
            fixture.borrowed.bodies.single,
          );
          expect(parts.containsKey('chunking_strategy'), isFalse);
          expect(
            _values(parts, 'stream'),
            stream == null ? <String>[] : ['false'],
          );
          expect(
            parts.entries
                .where((entry) => entry.key != 'file')
                .map((entry) => entry.value)
                .expand((parts) => parts)
                .any((part) => part.text == 'null'),
            isFalse,
          );
        },
      );
    }
  });

  group('Existing Audio admission and preflight', () {
    final badRequests = <String, TranscriptionRequest Function()>{
      'raw Base64 speaker reference': () => _transcription().copyWith(
        knownSpeakerReferences: const ['UFJJVkFURQ=='],
      ),
      'malformed percent speaker reference': () => _transcription().copyWith(
        knownSpeakerReferences: const ['data:audio/wav,%ZZ'],
      ),
      'unknown format': () => _transcription().copyWith(
        responseFormat: AudioResponseFormat.unknown,
      ),
      'unknown include': () => _transcription().copyWith(
        include: const [TranscriptionInclude.unknown],
      ),
      'empty languages': () =>
          _transcription().copyWith(languages: const <String>[]),
      'five speaker names': () => _transcription().copyWith(
        knownSpeakerNames: const ['a', 'b', 'c', 'd', 'e'],
      ),
      'five speaker references': () => _transcription().copyWith(
        knownSpeakerReferences: List.filled(5, 'data:audio/wav;base64,AA=='),
      ),
      'gpt-transcribe singular language': () => _transcription().copyWith(
        model: 'gpt-transcribe',
        language: 'en',
        languages: const ['en'],
      ),
      'gpt-transcribe angle keyword': () => _transcription().copyWith(
        model: 'gpt-transcribe',
        keywords: const ['<private>'],
      ),
      'gpt-transcribe CR keyword': () => _transcription().copyWith(
        model: 'gpt-transcribe',
        keywords: const ['private\rkeyword'],
      ),
      'gpt-transcribe LF keyword': () => _transcription().copyWith(
        model: 'gpt-transcribe',
        keywords: const ['private\nkeyword'],
      ),
    };
    for (final entry in badRequests.entries) {
      test('${entry.key} fails before auth or dispatch', () async {
        final fixture = _Fixture((_, _) => _success(_Mode.transcriptionJson));
        addTearDown(fixture.client.close);
        await expectLater(
          Future<void>.sync(() async {
            await fixture.client.audio.transcriptions.create(entry.value());
          }),
          throwsA(anyOf(isA<ArgumentError>(), isA<FormatException>())),
        );
        expect(fixture.auth.calls, 0);
        expect(fixture.borrowed.sends, 0);
        expect(fixture.factoryCalls, 0);
      });
    }
    for (final mode in [
      _Mode.transcriptionVerbose,
      _Mode.transcriptionDiarized,
    ]) {
      test(
        '${mode.name} rejects original unknown format before forcing mode',
        () async {
          final fixture = _Fixture((_, _) => _success(mode));
          addTearDown(fixture.client.close);
          await expectLater(
            _invoke(
              mode,
              fixture.client,
              transcription: _transcription().copyWith(
                responseFormat: AudioResponseFormat.unknown,
              ),
            ),
            throwsA(anyOf(isA<ArgumentError>(), isA<FormatException>())),
          );
          expect(fixture.auth.calls, 0);
          expect(fixture.borrowed.sends, 0);
        },
      );
    }
    for (final mode in _Mode.values) {
      test(
        '${mode.name} pre-abort does no authentication/send/factory work',
        () async {
          final fixture = _Fixture((_, _) => _success(mode));
          addTearDown(fixture.client.close);
          final abort = Completer<void>()..complete();
          await expectLater(
            _invoke(mode, fixture.client, abort: abort.future),
            throwsA(isA<AbortedException>()),
          );
          expect(fixture.auth.calls, 0);
          expect(fixture.borrowed.sends, 0);
          expect(fixture.owned.sends, 0);
          expect(fixture.factoryCalls, 0);
        },
      );
      test(
        '${mode.name} refuses closed client without authentication',
        () async {
          final fixture = _Fixture((_, _) => _success(mode));
          fixture.client.close();
          final authCalls = fixture.auth.calls;
          await expectLater(_invoke(mode, fixture.client), throwsStateError);
          expect(fixture.auth.calls, authCalls);
          expect(fixture.borrowed.sends, 0);
          expect(fixture.owned.sends, 0);
        },
      );
    }
    for (final format in [
      AudioResponseFormat.unknown,
      AudioResponseFormat.verboseJson,
      AudioResponseFormat.text,
      AudioResponseFormat.srt,
      AudioResponseFormat.vtt,
    ]) {
      test('stream mode ${format.toJson()} fails eagerly before listen', () {
        final fixture = _Fixture((_, _) => _success(_Mode.transcriptionStream));
        addTearDown(fixture.client.close);
        expect(
          () => fixture.client.audio.transcriptions.createStream(
            _transcription().copyWith(responseFormat: format),
          ),
          throwsA(anyOf(isA<ArgumentError>(), isA<FormatException>())),
        );
        expect(fixture.auth.calls, 0);
        expect(fixture.borrowed.sends, 0);
        expect(fixture.factoryCalls, 0);
      });
    }
    test('stream sentinel include fails eagerly before listen', () {
      final fixture = _Fixture((_, _) => _success(_Mode.transcriptionStream));
      addTearDown(fixture.client.close);
      expect(
        () => fixture.client.audio.transcriptions.createStream(
          _transcription().copyWith(
            include: const [TranscriptionInclude.unknown],
          ),
        ),
        throwsA(anyOf(isA<ArgumentError>(), isA<FormatException>())),
      );
      expect(fixture.auth.calls, 0);
      expect(fixture.factoryCalls, 0);
    });
    for (final format in TranslationResponseFormat.values.where(
      (f) => f != TranslationResponseFormat.json,
    )) {
      test(
        'generic translation refuses ${format.toJson()} before auth',
        () async {
          final fixture = _Fixture((_, _) => _success(_Mode.translationJson));
          addTearDown(fixture.client.close);
          await expectLater(
            fixture.client.audio.translations.create(
              _translation().copyWith(responseFormat: format),
            ),
            throwsA(anyOf(isA<ArgumentError>(), isA<FormatException>())),
          );
          expect(fixture.auth.calls, 0);
          expect(fixture.borrowed.sends, 0);
        },
      );
    }
  });

  group('Existing Audio public decoding and diagnostics', () {
    for (final mode in _Mode.values.where((m) => !m.raw && !m.streaming)) {
      for (final body in [
        'not JSON $_privateText',
        '["$_privateText"]',
        '{"text": {"$_privateText":true}}',
      ]) {
        test(
          '${mode.name} malformed body safely retains caller responseBody $body',
          () async {
            final fixture = _Fixture((_, _) => _response(utf8.encode(body)));
            addTearDown(fixture.client.close);
            final error = await _failure(_invoke(mode, fixture.client));
            expect(error, isA<ParseException>());
            final parse = error as ParseException;
            expect(parse.responseBody, body);
            expect(
              '${parse.message} ${parse.cause} $parse',
              isNot(contains(_privateText)),
            );
            expect(fixture.borrowed.sends, 1);
          },
        );
      }
    }
    for (final mode in _Mode.values.where((m) => !m.streaming)) {
      test(
        '${mode.name} malformed UTF8 cannot escape safe parse boundary',
        () async {
          final bytes = [...utf8.encode(_privateText), 255];
          final fixture = _Fixture(
            (_, _) => _response(
              bytes,
              contentType:
                  '${mode.raw ? 'text/plain' : 'application/json'}; charset=utf-8',
            ),
          );
          addTearDown(fixture.client.close);
          final error = await _failure(_invoke(mode, fixture.client));
          expect(error, isA<ParseException>());
          final parse = error as ParseException;
          expect(parse.responseBody, utf8.decode(bytes, allowMalformed: true));
          expect(
            '${parse.message} ${parse.cause} $parse',
            isNot(contains(_privateText)),
          );
          expect(fixture.borrowed.sends, 1);
        },
      );
    }
    test(
      'REST logprob numeric bytes retain fractions without rounding',
      () async {
        final fixture = _Fixture(
          (_, _) => _jsonResponse({
            'text': _privateText,
            'logprobs': [
              {
                'token': 'café',
                'bytes': [65, 66.5],
                'logprob': -0.25,
              },
            ],
            'languages': [
              {'code': 'en'},
            ],
            'usage': {'type': 'duration', 'seconds': 2.5},
          }),
        );
        addTearDown(fixture.client.close);
        final response = await fixture.client.audio.transcriptions.create(
          _transcription(),
        );
        expect(response.logprobs!.single.bytes, [65, 66.5]);
        expect(response.toJson()['logprobs'], [
          {
            'token': 'café',
            'bytes': [65, 66.5],
            'logprob': -0.25,
          },
        ]);
        expect(response.languages!.single.code, 'en');
        expect((response.usage! as TranscriptTextUsageDuration).seconds, 2.5);
      },
    );
    for (final mode in [
      _Mode.transcriptionJson,
      _Mode.translationJson,
      _Mode.translationVerbose,
    ]) {
      test('${mode.name} FINEST malformed bodies remain private', () async {
        const body =
            '$_privateText private-speaker data:audio/wav;base64,UFJJVkFURQ==';
        final logs = await _captureLogs(() async {
          final fixture = _Fixture(
            (_, _) => _response(utf8.encode(body)),
            logLevel: Level.FINEST,
          );
          addTearDown(fixture.client.close);
          final error = await _failure(_invoke(mode, fixture.client));
          expect(error, isA<ParseException>());
          expect((error as ParseException).responseBody, body);
          expect(
            '${error.message} ${error.cause} $error',
            isNot(contains(_privateText)),
          );
        });
        final text = logs
            .map((record) => '${record.message} ${record.error}')
            .join('\n');
        for (final secret in [
          _privateText,
          'private-speaker',
          'UFJJVkFURQ==',
          'A Unicode café prompt',
        ]) {
          expect(text, isNot(contains(secret)));
        }
      });
    }
  });

  group('Existing Audio HTTP context', () {
    for (final mode in _Mode.values) {
      for (final status in [302, 400, 403, 429, 503]) {
        test(
          '${mode.name} HTTP$status precedes data and retains original context',
          () async {
            final wire = utf8.encode(
              jsonEncode({
                'error': {
                  'message': _privateText,
                  'type': 'invalid_request_error',
                  'code': 'fixture-code',
                },
              }),
            );
            final fixture = _Fixture(
              (_, _) => _response(
                wire,
                status: status,
                headers: {
                  'x-request-id': status == 400
                      ? _privateText
                      : 'req-audio-fixture',
                  'retry-after': '3',
                  'x-provider': 'original',
                },
              ),
            );
            addTearDown(fixture.client.close);
            final error = await _failure(_invoke(mode, fixture.client));
            expect(error, isA<ApiException>());
            final api = error as ApiException;
            expect(api.statusCode, status);
            expect(
              api.requestId,
              status == 400 ? _privateText : 'req-audio-fixture',
            );
            expect(api.message, _privateText);
            expect(api.body?['error'], isA<Map<String, dynamic>>());
            expect(api.cause, isA<http.Response>());
            final original = api.cause! as http.Response;
            expect(original.bodyBytes, orderedEquals(wire));
            expect(original.headers['x-provider'], 'original');
            expect(original.headers['retry-after'], '3');
            expect(api.toString(), isNot(contains(_privateText)));
            expect(fixture.borrowed.sends + fixture.owned.sends, 1);
            if (mode.streaming) expect(fixture.owned.closes, 1);
          },
        );
      }
      test(
        '${mode.name} invalid UTF8 HTTP400 preserves status and raw bytes',
        () async {
          final bytes = [...utf8.encode(_privateText), 255];
          final fixture = _Fixture(
            (_, _) => _response(
              bytes,
              status: 400,
              headers: const {'x-request-id': 'req-invalid-utf8'},
            ),
          );
          addTearDown(fixture.client.close);
          final error = await _failure(_invoke(mode, fixture.client));
          expect(error, isA<BadRequestException>());
          final api = error as ApiException;
          expect(api.statusCode, 400);
          expect(api.requestId, 'req-invalid-utf8');
          expect((api.cause! as http.Response).bodyBytes, orderedEquals(bytes));
          expect(api.toString(), isNot(contains(_privateText)));
        },
      );
    }
  });

  group('Existing Audio typed stream protocol', () {
    for (final stream in [null, false, true]) {
      test('stream=$stream is forced true only on subscription', () async {
        final fixture = _Fixture((_, _) => _sse([_delta, _done]));
        addTearDown(fixture.client.close);
        final streamResult = fixture.client.audio.transcriptions.createStream(
          _transcription().copyWith(stream: stream, chunkingStrategy: null),
        );
        expect(fixture.auth.calls, 0);
        expect(fixture.factoryCalls, 0);
        expect(fixture.borrowed.sends + fixture.owned.sends, 0);
        final events = await streamResult.toList();
        expect(events, hasLength(2));
        final sent = fixture.owned.requests.single;
        final parts = _parts(sent, fixture.owned.bodies.single);
        expect(_values(parts, 'stream'), ['true']);
        expect(parts.containsKey('chunking_strategy'), isFalse);
        expect(sent.headers['accept'], 'text/event-stream');
        expect(
          sent.headers['content-type'],
          startsWith('multipart/form-data; boundary='),
        );
        expect(fixture.owned.closes, 1);
        expect(fixture.borrowed.closes, 0);
      });
    }
    test(
      'split UTF8 CRLF yields all three variants and an immutable future event',
      () async {
        final events = [
          _segment,
          _delta,
          {
            'type': 'transcript.future',
            'error': {'metadata': 'future error-shaped field'},
            'metadata': {
              'values': [1, 2],
            },
          },
          {
            ..._done,
            'languages': [
              {'code': 'en'},
            ],
            'logprobs': [
              {
                'token': 'café',
                'bytes': [195, 169],
                'logprob': -0.25,
              },
            ],
            'usage': {
              'type': 'tokens',
              'input_tokens': 2,
              'output_tokens': 3,
              'total_tokens': 5,
              'input_token_details': {'audio_tokens': 2, 'text_tokens': 0},
            },
          },
        ];
        final wire = utf8.encode(
          events.map((event) => 'data: ${jsonEncode(event)}\r\n\r\n').join(),
        );
        final fixture = _Fixture(
          (_, _) => http.StreamedResponse(
            Stream.fromIterable(wire.map((byte) => [byte])),
            200,
            headers: const {'content-type': 'text/event-stream'},
          ),
        );
        addTearDown(fixture.client.close);
        final received = await fixture.client.audio.transcriptions
            .createStream(
              _transcription().copyWith(
                responseFormat: AudioResponseFormat.diarizedJson,
              ),
            )
            .toList();
        expect(received, hasLength(4));
        expect(received[0], isA<TranscriptTextSegmentEvent>());
        expect(
          (received[0] as TranscriptTextSegmentEvent).speaker,
          'speaker-one',
        );
        expect((received[1] as TranscriptTextDeltaEvent).delta, 'café 🚀');
        final unknown = received[2] as TranscriptTextUnknownEvent;
        expect(unknown.rawType, 'transcript.future');
        expect(
          () =>
              (unknown.rawJson['metadata'] as Map<String, dynamic>)['values'] =
                  <Object?>[],
          throwsUnsupportedError,
        );
        final done = received[3] as TranscriptTextDoneEvent;
        expect(done.logprobs!.single.bytes, [195, 169]);
        expect(done.languages!.single.code, 'en');
        expect(done.usage!.totalTokens, 5);
        expect(fixture.owned.sends, 1);
        expect(fixture.owned.closes, 1);
      },
    );
    for (final type in ['transcript.text.delta', 'transcript.text.done']) {
      test('$type rejects fractional SSE bytes without rounding', () async {
        final payload = {
          'type': type,
          if (type.endsWith('delta'))
            'delta': _privateText
          else
            'text': _privateText,
          'logprobs': [
            {
              'bytes': [65, 66.5],
            },
          ],
        };
        final fixture = _Fixture((_, _) => _sse([payload, _done]));
        addTearDown(fixture.client.close);
        final error = await _failure(
          _invoke(_Mode.transcriptionStream, fixture.client),
        );
        expect(error, isA<ParseException>());
        final parse = error as ParseException;
        expect(parse.responseBody, contains('66.5'));
        expect(
          '${parse.message} ${parse.cause} $parse',
          isNot(contains(_privateText)),
        );
        expect(fixture.owned.closes, 1);
      });
    }
    final malformed = <String, Object>{
      'missing type': {'delta': _privateText},
      'null type': {'type': null, 'delta': _privateText},
      'numeric type': {'type': 9, 'delta': _privateText},
      'wrong delta': {
        'type': 'transcript.text.delta',
        'delta': {'private': _privateText},
      },
      'wrong text': {
        'type': 'transcript.text.done',
        'text': [_privateText],
      },
      'missing speaker': {
        'type': 'transcript.text.segment',
        'id': 'one',
        'start': 0,
        'end': 1,
        'text': _privateText,
      },
      'fractional usage': {
        'type': 'transcript.text.done',
        'text': _privateText,
        'usage': {
          'type': 'tokens',
          'input_tokens': 1.5,
          'output_tokens': 2,
          'total_tokens': 3,
        },
      },
      'not object': [_privateText],
    };
    for (final entry in malformed.entries) {
      test('${entry.key} is malformed and never an unknown variant', () async {
        final body = jsonEncode(entry.value);
        final fixture = _Fixture(
          (_, _) => _response(
            utf8.encode('data: $body\n\n'),
            contentType: 'text/event-stream',
          ),
        );
        addTearDown(fixture.client.close);
        final error = await _failure(
          _invoke(_Mode.transcriptionStream, fixture.client),
        );
        expect(error, isA<ParseException>());
        expect((error as ParseException).responseBody, contains(_privateText));
        expect(
          '${error.message} ${error.cause} $error',
          isNot(contains(_privateText)),
        );
        expect(fixture.owned.closes, 1);
      });
    }
    for (final body in [
      '',
      'data: [DONE]\n\n',
      'data: ${jsonEncode(_delta)}\n\n',
      'data: {"type":"transcript.future"}\n\n',
    ]) {
      test('incomplete stream does not fabricate completion: $body', () async {
        final fixture = _Fixture(
          (_, _) =>
              _response(utf8.encode(body), contentType: 'text/event-stream'),
        );
        addTearDown(fixture.client.close);
        await expectLater(
          _invoke(_Mode.transcriptionStream, fixture.client),
          throwsA(isA<StreamException>()),
        );
        expect(fixture.owned.closes, 1);
        expect(fixture.owned.sends, 1);
      });
    }
    for (final owns in [true, false]) {
      test(
        'done releases held-open ${owns ? 'owned' : 'borrowed'} body and ignores queued bytes',
        () async {
          var canceled = 0;
          final body = StreamController<List<int>>(onCancel: () => canceled++);
          final fixture = _Fixture(
            (_, _) => http.StreamedResponse(
              body.stream,
              200,
              headers: const {'content-type': 'text/event-stream'},
            ),
            ownsStream: owns,
          );
          addTearDown(fixture.client.close);
          final result = fixture.client.audio.transcriptions
              .createStream(_transcription())
              .toList();
          await (owns ? fixture.owned : fixture.borrowed).sent.future;
          body
            ..add(utf8.encode('data: ${jsonEncode(_done)}\n\n'))
            ..add(utf8.encode('data: {bad $_privateText}\n\n'));
          final received = await result.timeout(const Duration(seconds: 3));
          expect(received, hasLength(1));
          expect(received.single, isA<TranscriptTextDoneEvent>());
          expect(canceled, 1);
          expect(fixture.owned.closes, owns ? 1 : 0);
          expect(fixture.borrowed.closes, 0);
          body.add([255]);
          await body.close();
        },
      );
    }
    test(
      'consumed delta/source error is never replayed by retry policy',
      () async {
        final body = StreamController<List<int>>();
        final fixture = _Fixture(
          (_, _) => http.StreamedResponse(
            body.stream,
            200,
            headers: const {'content-type': 'text/event-stream'},
          ),
          maxRetries: 3,
        );
        addTearDown(fixture.client.close);
        final received = Completer<void>();
        final errors = <Object>[];
        final closed = Completer<void>();
        final subscription = fixture.client.audio.transcriptions
            .createStream(_transcription())
            .listen(
              (event) {
                expect(event, isA<TranscriptTextDeltaEvent>());
                received.complete();
              },
              onError: errors.add,
              onDone: closed.complete,
            );
        body.add(utf8.encode('data: ${jsonEncode(_delta)}\n\n'));
        await received.future;
        body.addError(StateError('fixture source failure'));
        await closed.future.timeout(const Duration(seconds: 3));
        expect(errors, hasLength(1));
        expect(fixture.owned.sends, 1);
        expect(fixture.owned.closes, 1);
        expect(fixture.factoryCalls, 1);
        await subscription.cancel();
        await body.close();
      },
    );
  });
  group('Existing Audio strict encoding and inline errors', () {
    test(
      'malformed UTF8 SSE has safe cause and caller-readable raw responseBody',
      () async {
        final bytes = [
          ...utf8.encode(
            'data: {"type":"transcript.text.delta","delta":"$_privateText"',
          ),
          255,
        ];
        final fixture = _Fixture(
          (_, _) => _response(bytes, contentType: 'text/event-stream'),
        );
        addTearDown(fixture.client.close);
        final error = await _failure(
          _invoke(_Mode.transcriptionStream, fixture.client),
        );
        expect(error, isA<ParseException>());
        final parse = error as ParseException;
        expect(parse.responseBody, utf8.decode(bytes, allowMalformed: true));
        expect(
          '${parse.message} ${parse.cause} $parse',
          isNot(contains(_privateText)),
        );
        expect(fixture.owned.sends, 1);
        expect(fixture.owned.closes, 1);
      },
    );
    for (final kind in ['event', 'type', 'envelope']) {
      test(
        'inline $kind error before data is safe and never retried',
        () async {
          final payload = kind == 'type'
              ? {'type': 'error', 'message': _privateText}
              : {
                  'error': {
                    'message': _privateText,
                    'type': 'invalid_request_error',
                  },
                };
          final raw = jsonEncode(payload);
          final logs = await _captureLogs(() async {
            final fixture = _Fixture(
              (_, _) => _response(
                utf8.encode(
                  '${kind == 'event' ? 'event: error\n' : ''}data: $raw\n\n',
                ),
                contentType: 'text/event-stream',
              ),
              maxRetries: 3,
              logLevel: Level.FINEST,
            );
            addTearDown(fixture.client.close);
            final error = await _failure(
              _invoke(_Mode.transcriptionStream, fixture.client),
            );
            expect(error, isA<StreamException>());
            expect((error as StreamException).partialData, raw);
            expect(error.message, _privateText);
            expect(error.toString(), isNot(contains(_privateText)));
            expect(fixture.owned.sends, 1);
            expect(fixture.owned.closes, 1);
            expect(fixture.factoryCalls, 1);
          });
          expect(
            logs
                .map((record) => '${record.message} ${record.error}')
                .join('\n'),
            isNot(contains(_privateText)),
          );
        },
      );
    }
    for (final mode in [_Mode.transcriptionJson, _Mode.translationJson]) {
      test(
        '${mode.name} malformed upload MIME fails safely before auth',
        () async {
          final fixture = _Fixture((_, _) => _success(mode));
          addTearDown(fixture.client.close);
          final error = await _failure(
            _invoke(
              mode,
              fixture.client,
              transcription: _transcription().copyWith(
                fileContentType: 'private MIME $_privateText',
              ),
              translation: _translation().copyWith(
                fileContentType: 'private MIME $_privateText',
              ),
            ),
          );
          expect(error, isA<FormatException>());
          expect(error.toString(), isNot(contains(_privateText)));
          expect(fixture.auth.calls, 0);
          expect(fixture.borrowed.sends, 0);
        },
      );
    }
  });

  group('Existing Audio native abort and stream ownership', () {
    for (final mode in _Mode.values.where((m) => !m.streaming)) {
      test(
        '${mode.name} native mid-body abort preserves borrowed transport',
        () async {
          final ready = Completer<void>();
          final body = StreamController<List<int>>(onListen: ready.complete);
          final fixture = _Fixture((request, _) {
            expect(request, isA<http.Abortable>());
            final nativeAbort = (request as http.Abortable).abortTrigger;
            expect(nativeAbort, isNotNull);
            unawaited(
              nativeAbort!.then(
                (_) => body.addError(http.RequestAbortedException(request.url)),
              ),
            );
            return http.StreamedResponse(
              body.stream,
              200,
              headers: {
                'content-type':
                    '${mode.raw ? 'text/plain' : 'application/json'}; charset=utf-8',
              },
            );
          }, maxRetries: 3);
          addTearDown(fixture.client.close);
          final abort = Completer<void>();
          final future = _invoke(mode, fixture.client, abort: abort.future);
          await ready.future;
          body.add(utf8.encode('partial $_privateText'));
          abort.complete();
          final error = await _failure(future);
          expect(error, isA<AbortedException>());
          expect(fixture.borrowed.sends, 1);
          expect(fixture.borrowed.closes, 0);
          expect(fixture.factoryCalls, 0);
          await body.close();
        },
      );
    }
    for (final owns in [true, false]) {
      test(
        'cancel after delta releases ${owns ? 'owned' : 'borrowed'} subscription once',
        () async {
          var canceled = 0;
          final body = StreamController<List<int>>(onCancel: () => canceled++);
          final fixture = _Fixture(
            (_, _) => http.StreamedResponse(
              body.stream,
              200,
              headers: const {'content-type': 'text/event-stream'},
            ),
            ownsStream: owns,
          );
          addTearDown(fixture.client.close);
          final delta = Completer<void>();
          final subscription = fixture.client.audio.transcriptions
              .createStream(_transcription())
              .listen((event) {
                expect(event, isA<TranscriptTextDeltaEvent>());
                delta.complete();
              });
          body.add(utf8.encode('data: ${jsonEncode(_delta)}\n\n'));
          await delta.future;
          await subscription.cancel().timeout(const Duration(seconds: 3));
          expect(canceled, 1);
          expect(fixture.owned.closes, owns ? 1 : 0);
          expect(fixture.borrowed.closes, 0);
          expect(fixture.borrowed.sends + fixture.owned.sends, 1);
          await body.close();
        },
      );
      test(
        'midstream abort settles ${owns ? 'owned' : 'borrowed'} without replay',
        () async {
          var canceled = 0;
          final body = StreamController<List<int>>(onCancel: () => canceled++);
          final fixture = _Fixture(
            (_, _) => http.StreamedResponse(
              body.stream,
              200,
              headers: const {'content-type': 'text/event-stream'},
            ),
            ownsStream: owns,
            maxRetries: 3,
          );
          addTearDown(fixture.client.close);
          final abort = Completer<void>();
          final delta = Completer<void>();
          final completed = Completer<void>();
          final errors = <Object>[];
          final events = <TranscriptionStreamEvent>[];
          final subscription = fixture.client.audio.transcriptions
              .createStream(_transcription(), abortTrigger: abort.future)
              .listen(
                (event) {
                  events.add(event);
                  delta.complete();
                },
                onError: errors.add,
                onDone: completed.complete,
              );
          body.add(utf8.encode('data: ${jsonEncode(_delta)}\n\n'));
          await delta.future;
          abort.complete();
          await completed.future.timeout(const Duration(seconds: 3));
          expect(errors, hasLength(1));
          expect(errors.single, isA<AbortedException>());
          expect(events, hasLength(1));
          expect(canceled, 1);
          expect(fixture.owned.closes, owns ? 1 : 0);
          expect(fixture.borrowed.closes, 0);
          expect(fixture.borrowed.sends + fixture.owned.sends, 1);
          await subscription.cancel();
          await body.close();
        },
      );
      test(
        'pending-header cancel retires ${owns ? 'owned' : 'borrowed'} and discards late response',
        () async {
          var canceled = 0;
          final headers = Completer<http.StreamedResponse>();
          final body = StreamController<List<int>>(onCancel: () => canceled++);
          final fixture = _Fixture((_, _) => headers.future, ownsStream: owns);
          addTearDown(fixture.client.close);
          final subscription = fixture.client.audio.transcriptions
              .createStream(_transcription())
              .listen((_) {});
          await (owns ? fixture.owned : fixture.borrowed).sent.future;
          await subscription.cancel().timeout(const Duration(seconds: 3));
          expect(fixture.owned.closes, owns ? 1 : 0);
          expect(fixture.borrowed.closes, 0);
          headers.complete(
            http.StreamedResponse(
              body.stream,
              200,
              headers: const {'content-type': 'text/event-stream'},
            ),
          );
          await Future<void>.delayed(Duration.zero);
          await Future<void>.delayed(Duration.zero);
          expect(canceled, 1);
          expect(fixture.borrowed.sends + fixture.owned.sends, 1);
          await body.close();
        },
      );
    }
    test(
      'concurrent subscriptions use isolated transports and cancel independently',
      () async {
        final transports = <_Transport>[];
        final bodies = <StreamController<List<int>>>[];
        final allocated = Completer<void>();
        final borrowed = _Transport(
          (_, _) => throw StateError('must not dispatch borrowed client'),
        );
        final client = OpenAIClient(
          config: _config(_Auth()),
          httpClient: borrowed,
          streamClientFactory: () {
            final body = StreamController<List<int>>();
            bodies.add(body);
            final transport = _Transport(
              (_, _) => http.StreamedResponse(
                body.stream,
                200,
                headers: const {'content-type': 'text/event-stream'},
              ),
            );
            transports.add(transport);
            if (transports.length == 2) allocated.complete();
            return transport;
          },
        );
        addTearDown(client.close);
        final first = client.audio.transcriptions
            .createStream(_transcription())
            .listen((_) {});
        final second = client.audio.transcriptions
            .createStream(_transcription())
            .toList();
        await allocated.future;
        await Future.wait(transports.map((transport) => transport.sent.future));
        await first.cancel();
        expect(transports[0].closes, 1);
        expect(transports[1].closes, 0);
        bodies[1].add(utf8.encode('data: ${jsonEncode(_done)}\n\n'));
        expect(await second.timeout(const Duration(seconds: 3)), hasLength(1));
        expect(transports[1].closes, 1);
        expect(transports.map((transport) => transport.sends), [1, 1]);
        expect(borrowed.sends, 0);
        expect(borrowed.closes, 0);
        await Future.wait(bodies.map((body) => body.close()));
      },
    );
    test(
      'stream multipart bytes and repeated fields snapshot before listen',
      () async {
        final fixture = _Fixture((_, _) => _sse([_done]));
        addTearDown(fixture.client.close);
        final file = Uint8List.fromList([0, 255, 128, 1]);
        final keywords = ['old'];
        final request = _transcription().copyWith(
          file: file,
          keywords: keywords,
        );
        final stream = fixture.client.audio.transcriptions.createStream(
          request,
        );
        file[1] = 7;
        keywords[0] = 'changed';
        await stream.drain<void>();
        final parts = _parts(
          fixture.owned.requests.single,
          fixture.owned.bodies.single,
        );
        expect(parts['file']!.single.bytes, [0, 255, 128, 1]);
        expect(_values(parts, 'keywords[]'), ['old']);
      },
    );
  });

  group('Existing Audio media and charset boundaries', () {
    for (final mode in _Mode.values) {
      test(
        '${mode.name} configured/provider media overrides cannot change mode or Unicode parts',
        () async {
          final auth = _ConflictingAuth();
          final fixture = _Fixture(
            (_, _) => _success(mode),
            authProvider: auth,
            defaultHeaders: const {
              'Accept': 'application/xml',
              'accept': 'application/invalid',
              'Content-Type': 'text/plain; charset=unknown-fixture-charset',
              'content-type': 'text/plain; charset=iso-8859-1',
            },
          );
          addTearDown(fixture.client.close);
          await _invoke(mode, fixture.client);
          final transport = mode.streaming ? fixture.owned : fixture.borrowed;
          final sent = transport.requests.single;
          expect(sent.headers['accept'], mode.accept);
          expect(
            sent.headers['content-type'],
            startsWith('multipart/form-data; boundary='),
          );
          expect(sent.headers['authorization'], 'Bearer fixture-credential');
          final parts = _parts(sent, transport.bodies.single);
          expect(_values(parts, 'prompt'), ['A Unicode café prompt']);
          expect(parts['file']!.single.bytes, [0, 255, 128, 1, 2]);
          expect(auth.lastHeaders['Accept'], 'application/xml');
          expect(
            auth.lastHeaders['content-type'],
            'text/plain; charset=unknown-fixture-charset',
          );
        },
      );
      test(
        '${mode.name} advertised Latin1 HTTP error keeps exact message',
        () async {
          final data = latin1.encode(
            '{"error":{"message":"café","type":"invalid_request_error"}}',
          );
          final fixture = _Fixture(
            (_, _) => _response(
              data,
              status: 400,
              contentType: 'application/json; charset=iso-8859-1',
            ),
          );
          addTearDown(fixture.client.close);
          final error = await _failure(_invoke(mode, fixture.client));
          expect(error, isA<BadRequestException>());
          expect((error as ApiException).message, 'café');
          expect(
            (error.cause! as http.Response).bodyBytes,
            orderedEquals(data),
          );
        },
      );
    }
    for (final mode in _Mode.values.where((m) => m.raw)) {
      test(
        '${mode.name} advertised Latin1 raw output keeps whitespace',
        () async {
          const text = ' \r\ncafé \r\n\r\n';
          final fixture = _Fixture(
            (_, _) => _response(
              latin1.encode(text),
              contentType: 'text/plain; charset=iso-8859-1',
            ),
          );
          addTearDown(fixture.client.close);
          expect(await _invoke(mode, fixture.client), text);
        },
      );
    }
  });
  group('Existing Audio method admission regressions', () {
    for (final mode in [
      _Mode.transcriptionJson,
      _Mode.transcriptionVerbose,
      _Mode.transcriptionDiarized,
      _Mode.transcriptionText,
    ]) {
      test('${mode.name} buffered stream=true fails before auth', () async {
        final fixture = _Fixture((_, _) => _success(mode));
        addTearDown(fixture.client.close);
        await expectLater(
          _invoke(
            mode,
            fixture.client,
            transcription: _transcription().copyWith(
              stream: true,
              responseFormat: AudioResponseFormat.fromJson(mode.format),
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
        expect(fixture.auth.calls, 0);
        expect(fixture.borrowed.sends, 0);
      });
    }
    for (final mode in [
      _Mode.transcriptionVerbose,
      _Mode.transcriptionDiarized,
      _Mode.transcriptionText,
    ]) {
      test(
        '${mode.name} original unknown include fails before mode change/auth',
        () async {
          final fixture = _Fixture((_, _) => _success(mode));
          addTearDown(fixture.client.close);
          await expectLater(
            _invoke(
              mode,
              fixture.client,
              transcription: _transcription().copyWith(
                include: const [TranscriptionInclude.unknown],
                responseFormat: AudioResponseFormat.fromJson(mode.format),
              ),
            ),
            throwsFormatException,
          );
          expect(fixture.auth.calls, 0);
          expect(fixture.borrowed.sends, 0);
        },
      );
    }
    for (final mode in [
      _Mode.transcriptionText,
      _Mode.translationVerbose,
      _Mode.translationText,
    ]) {
      test('${mode.name} original unknown format fails before auth', () async {
        final fixture = _Fixture((_, _) => _success(mode));
        addTearDown(fixture.client.close);
        await expectLater(
          _invoke(
            mode,
            fixture.client,
            transcription: _transcription().copyWith(
              responseFormat: AudioResponseFormat.unknown,
            ),
            translation: _translation().copyWith(
              responseFormat: TranslationResponseFormat.unknown,
            ),
          ),
          throwsFormatException,
        );
        expect(fixture.auth.calls, 0);
        expect(fixture.borrowed.sends, 0);
      });
    }
    for (final mode in [
      _Mode.transcriptionVerbose,
      _Mode.transcriptionDiarized,
    ]) {
      test(
        '${mode.name} still forces a valid supplied alternate format',
        () async {
          final fixture = _Fixture((_, _) => _success(mode));
          addTearDown(fixture.client.close);
          await _invoke(
            mode,
            fixture.client,
            transcription: _transcription().copyWith(
              responseFormat: AudioResponseFormat.text,
            ),
          );
          expect(
            _values(
              _parts(
                fixture.borrowed.requests.single,
                fixture.borrowed.bodies.single,
              ),
              'response_format',
            ),
            [mode.format],
          );
        },
      );
    }
    test(
      'gpt-transcribe has no invented 4096-character prompt limit',
      () async {
        final fixture = _Fixture((_, _) => _success(_Mode.transcriptionJson));
        addTearDown(fixture.client.close);
        final prompt = List.filled(5000, 'p').join();
        await fixture.client.audio.transcriptions.create(
          _transcription().copyWith(
            model: 'gpt-transcribe',
            languages: const ['en'],
            prompt: prompt,
          ),
        );
        expect(
          _values(
            _parts(
              fixture.borrowed.requests.single,
              fixture.borrowed.bodies.single,
            ),
            'prompt',
          ),
          [prompt],
        );
      },
    );
    test('keyword guide restrictions are scoped to gpt-transcribe', () async {
      final fixture = _Fixture((_, _) => _success(_Mode.transcriptionJson));
      addTearDown(fixture.client.close);
      await fixture.client.audio.transcriptions.create(
        _transcription().copyWith(
          keywords: const ['<allowed>\r\nphrase'],
          language: 'en',
          languages: const ['en'],
        ),
      );
      final parts = _parts(
        fixture.borrowed.requests.single,
        fixture.borrowed.bodies.single,
      );
      expect(_values(parts, 'keywords[]'), ['<allowed>\r\nphrase']);
      expect(_values(parts, 'language'), ['en']);
      expect(_values(parts, 'languages[]'), ['en']);
    });
  });
  group('Existing Audio provider header privacy', () {
    for (final mode in [
      _Mode.transcriptionJson,
      _Mode.translationJson,
      _Mode.translationText,
    ]) {
      test(
        '${mode.name} FINEST headers cannot echo private file/text',
        () async {
          final logs = await _captureLogs(() async {
            final fixture = _Fixture(
              (_, _) => _response(
                utf8.encode(mode.raw ? _rawText : 'not JSON $_privateText'),
                contentType: mode.raw
                    ? 'text/plain; charset=utf-8'
                    : 'application/json; charset=utf-8',
                headers: const {
                  'x-echo': _privateText,
                  'x-request-id': _privateText,
                  'content-disposition':
                      'attachment; filename="private-recording.ogg"',
                  'x-speaker-sample': 'data:audio/wav;base64,UFJJVkFURQ==',
                },
              ),
              logLevel: Level.FINEST,
            );
            addTearDown(fixture.client.close);
            if (mode.raw) {
              expect(await _invoke(mode, fixture.client), _rawText);
            } else {
              final error = await _failure(_invoke(mode, fixture.client));
              expect(error, isA<ParseException>());
              expect(
                (error as ParseException).responseBody,
                'not JSON $_privateText',
              );
            }
          });
          final text = logs
              .map((record) => '${record.message} ${record.error}')
              .join('\n');
          for (final private in [
            _privateText,
            'private-recording.ogg',
            'UFJJVkFURQ==',
          ]) {
            expect(text, isNot(contains(private)));
          }
        },
      );
    }
  });
  group('Existing Audio best-effort owned disposal', () {
    for (final outcome in ['success', 'HTTP', 'cancel']) {
      test(
        'throwing owned close preserves original $outcome and settles once',
        () async {
          final errors = await _captureUnhandled(() async {
            final response = Completer<http.StreamedResponse>();
            final fixture = _Fixture(
              (_, _) => outcome == 'cancel'
                  ? response.future
                  : outcome == 'HTTP'
                  ? _response(
                      utf8.encode('{"error":{"message":"fixture forbidden"}}'),
                      status: 403,
                    )
                  : _sse([_done]),
              throwingClose: true,
            );
            addTearDown(fixture.client.close);
            if (outcome == 'cancel') {
              final subscription = fixture.client.audio.transcriptions
                  .createStream(_transcription())
                  .listen((_) {});
              await fixture.owned.sent.future;
              await subscription.cancel().timeout(const Duration(seconds: 3));
              response.complete(_sse([_done]));
              await Future<void>.delayed(Duration.zero);
            } else if (outcome == 'HTTP') {
              expect(
                await _failure(
                  _invoke(_Mode.transcriptionStream, fixture.client),
                ),
                isA<PermissionDeniedException>(),
              );
            } else {
              expect(
                await _invoke(_Mode.transcriptionStream, fixture.client),
                hasLength(1),
              );
            }
            expect(fixture.owned.closes, 1);
            expect(fixture.borrowed.closes, 0);
          });
          expect(errors, isEmpty);
        },
      );
    }
  });
}

TranscriptionRequest _transcription() => TranscriptionRequest(
  file: Uint8List.fromList([0, 255, 128, 1, 2]),
  filename: 'recording.ogg',
  fileContentType: 'audio/ogg',
  model: 'future-transcription-model',
);
TranslationRequest _translation() => TranslationRequest(
  file: Uint8List.fromList([0, 255, 128, 1, 2]),
  filename: 'recording.ogg',
  fileContentType: 'audio/ogg',
  model: 'future-translation-model',
);

Future<Object?> _invoke(
  _Mode mode,
  OpenAIClient client, {
  TranscriptionRequest? transcription,
  TranslationRequest? translation,
  Future<void>? abort,
}) => Future<Object?>.sync(() {
  final tr =
      transcription ??
      _transcription().copyWith(
        prompt: 'A Unicode café prompt',
        temperature: 0.25,
        responseFormat: AudioResponseFormat.fromJson(mode.format),
      );
  final tl =
      translation ??
      _translation().copyWith(
        prompt: 'A Unicode café prompt',
        temperature: 0.25,
        responseFormat: TranslationResponseFormat.fromJson(mode.format),
      );
  return switch (mode) {
    _Mode.transcriptionJson => client.audio.transcriptions.create(
      tr,
      abortTrigger: abort,
    ),
    _Mode.transcriptionVerbose => client.audio.transcriptions.createVerbose(
      tr,
      abortTrigger: abort,
    ),
    _Mode.transcriptionDiarized => client.audio.transcriptions.createDiarized(
      tr,
      abortTrigger: abort,
    ),
    _Mode.transcriptionText ||
    _Mode.transcriptionSrt ||
    _Mode.transcriptionVtt => client.audio.transcriptions.createRaw(
      tr,
      abortTrigger: abort,
    ),
    _Mode.translationJson => client.audio.translations.create(
      tl,
      abortTrigger: abort,
    ),
    _Mode.translationVerbose => client.audio.translations.createVerbose(
      tl,
      abortTrigger: abort,
    ),
    _Mode.translationText || _Mode.translationSrt || _Mode.translationVtt =>
      client.audio.translations.createRaw(tl, abortTrigger: abort),
    _Mode.transcriptionStream =>
      client.audio.transcriptions
          .createStream(tr, abortTrigger: abort)
          .toList(),
  };
});

http.StreamedResponse _success(_Mode mode) {
  if (mode.streaming) return _sse([_delta, _done]);
  if (mode.raw) {
    return _response(
      utf8.encode(_rawText),
      contentType: 'text/plain; charset=utf-8',
    );
  }
  return _jsonResponse(switch (mode) {
    _Mode.transcriptionDiarized => _diarized,
    _Mode.transcriptionVerbose || _Mode.translationVerbose => _verbose,
    _ => {'text': _privateText},
  });
}

http.StreamedResponse _jsonResponse(Map<String, Object?> data) =>
    _response(utf8.encode(jsonEncode(data)));
http.StreamedResponse _sse(List<Map<String, Object?>> events) => _response(
  utf8.encode(events.map((event) => 'data: ${jsonEncode(event)}\n\n').join()),
  contentType: 'text/event-stream',
);
http.StreamedResponse _response(
  List<int> bytes, {
  int status = 200,
  String contentType = 'application/json; charset=utf-8',
  Map<String, String> headers = const {},
}) => http.StreamedResponse(
  Stream.value(bytes),
  status,
  headers: {'content-type': contentType, ...headers},
);
Future<Object> _failure(Future<Object?> result) async {
  try {
    await result;
  } catch (error) {
    return error;
  }
  throw StateError('Expected fixture failure.');
}

class _Part {
  _Part(this.headers, this.bytes);
  final String headers;
  final List<int> bytes;
  String get text => utf8.decode(bytes);
  String? get filename =>
      RegExp(r'filename="([^"]*)"').firstMatch(headers)?.group(1);
  String? get contentType => RegExp(
    r'content-type: ([^\r\n]*)',
    caseSensitive: false,
  ).firstMatch(headers)?.group(1);
}

Map<String, List<_Part>> _parts(http.BaseRequest request, List<int> body) {
  final boundary = RegExp(
    r'boundary=([^; ]+)',
  ).firstMatch(request.headers['content-type']!)!.group(1)!;
  final parts = <String, List<_Part>>{};
  for (final raw in latin1.decode(body).split('--$boundary').skip(1)) {
    if (raw.startsWith('--')) break;
    final separator = raw.indexOf('\r\n\r\n');
    final headers = raw.substring(2, separator);
    final name = RegExp(r'name="([^"]*)"').firstMatch(headers)!.group(1)!;
    final value = raw.substring(separator + 4, raw.length - 2);
    parts.putIfAbsent(name, () => []).add(_Part(headers, latin1.encode(value)));
  }
  return parts;
}

List<String> _values(Map<String, List<_Part>> parts, String name) =>
    parts[name]?.map((part) => part.text).toList() ?? [];

class _Auth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    return const {'Authorization': 'Bearer fixture-credential'};
  }
}

class _Transport extends http.BaseClient {
  _Transport(this.handler, {this.throwingClose = false});
  final bool throwingClose;
  final FutureOr<http.StreamedResponse> Function(http.BaseRequest, List<int>)
  handler;
  final requests = <http.BaseRequest>[];
  final bodies = <List<int>>[];
  final sent = Completer<void>();
  int sends = 0;
  int closes = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sends++;
    requests.add(request);
    final body = await request.finalize().toBytes();
    bodies.add(body);
    if (!sent.isCompleted) sent.complete();
    return handler(request, body);
  }

  @override
  void close() {
    closes++;
    if (throwingClose) throw StateError('private cleanup failure');
  }
}

class _Fixture {
  _Fixture(
    FutureOr<http.StreamedResponse> Function(http.BaseRequest, List<int>)
    handler, {
    bool ownsStream = true,
    int maxRetries = 0,
    Level? logLevel,
    bool throwingClose = false,
    _Auth? authProvider,
    Map<String, String> defaultHeaders = const {
      'x-fixture': 'present',
      'Accept': 'application/xml',
    },
  }) : auth = authProvider ?? _Auth() {
    borrowed = _Transport(handler);
    owned = _Transport(handler, throwingClose: throwingClose);
    client = OpenAIClient(
      config: OpenAIConfig(
        authProvider: auth,
        baseUrl: 'https://fixture.invalid/proxy/v1',
        project: 'project-fixture',
        defaultHeaders: defaultHeaders,
        retryPolicy: RetryPolicy(maxRetries: maxRetries),
        logLevel: logLevel,
      ),
      httpClient: borrowed,
      streamClientFactory: ownsStream
          ? () {
              factoryCalls++;
              return owned;
            }
          : null,
    );
  }
  final _Auth auth;
  late final _Transport borrowed;
  late final _Transport owned;
  late final OpenAIClient client;
  int factoryCalls = 0;
}

Future<List<LogRecord>> _captureLogs(Future<void> Function() action) async {
  final hierarchy = hierarchicalLoggingEnabled;
  hierarchicalLoggingEnabled = true;
  final rootLevel = Logger.root.level;
  final clientLevel = Logger('OpenAIClient').level;
  Logger.root.level = Level.ALL;
  final records = <LogRecord>[];
  final subscription = Logger.root.onRecord.listen(records.add);
  try {
    await action();
  } finally {
    await subscription.cancel();
    Logger.root.level = rootLevel;
    Logger('OpenAIClient').level = clientLevel;
    hierarchicalLoggingEnabled = hierarchy;
  }
  return records;
}

OpenAIConfig _config(_Auth auth) => OpenAIConfig(
  authProvider: auth,
  baseUrl: 'https://fixture.invalid/proxy/v1',
  retryPolicy: const RetryPolicy(maxRetries: 0),
);

class _ConflictingAuth extends _Auth {
  late Map<String, String> lastHeaders;
  @override
  Map<String, String> getHeaders() {
    lastHeaders = {
      ...super.getHeaders(),
      'Accept': 'application/xml',
      'content-type': 'text/plain; charset=unknown-fixture-charset',
    };
    return lastHeaders;
  }
}

Future<List<Object>> _captureUnhandled(Future<void> Function() action) async {
  final errors = <Object>[];
  final completed = Completer<void>();
  unawaited(
    runZonedGuarded<Future<void>>(() async {
      try {
        await action();
        await Future<void>.delayed(Duration.zero);
        completed.complete();
      } catch (error, stack) {
        completed.completeError(error, stack);
      }
    }, (error, stack) => errors.add(error)),
  );
  await completed.future.timeout(const Duration(seconds: 5));
  return errors;
}
