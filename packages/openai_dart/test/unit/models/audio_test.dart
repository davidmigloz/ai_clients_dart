// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SpeechRequest', () {
    test('toJson serializes correctly', () {
      const request = SpeechRequest(
        model: 'tts-1',
        input: 'Hello, world!',
        voice: SpeechVoice.alloy,
        responseFormat: SpeechResponseFormat.mp3,
        speed: 1.0,
      );

      final json = request.toJson();

      expect(json['model'], 'tts-1');
      expect(json['input'], 'Hello, world!');
      expect(json['voice'], 'alloy');
      expect(json['response_format'], 'mp3');
      expect(json['speed'], 1.0);
    });

    test('toJson omits null fields', () {
      const request = SpeechRequest(
        model: 'tts-1',
        input: 'Hello',
        voice: SpeechVoice.nova,
      );

      final json = request.toJson();

      expect(json['model'], 'tts-1');
      expect(json['input'], 'Hello');
      expect(json['voice'], 'nova');
      expect(json.containsKey('response_format'), isFalse);
      expect(json.containsKey('speed'), isFalse);
    });
  });

  group('SpeechVoice', () {
    test('toJson returns correct string', () {
      expect(SpeechVoice.alloy.toJson(), 'alloy');
      expect(SpeechVoice.echo.toJson(), 'echo');
      expect(SpeechVoice.fable.toJson(), 'fable');
      expect(SpeechVoice.onyx.toJson(), 'onyx');
      expect(SpeechVoice.nova.toJson(), 'nova');
      expect(SpeechVoice.shimmer.toJson(), 'shimmer');
    });
  });

  group('SpeechResponseFormat', () {
    test('toJson returns correct string', () {
      expect(SpeechResponseFormat.mp3.toJson(), 'mp3');
      expect(SpeechResponseFormat.opus.toJson(), 'opus');
      expect(SpeechResponseFormat.aac.toJson(), 'aac');
      expect(SpeechResponseFormat.flac.toJson(), 'flac');
      expect(SpeechResponseFormat.wav.toJson(), 'wav');
      expect(SpeechResponseFormat.pcm.toJson(), 'pcm');
    });
  });

  group('TranscriptionRequest', () {
    Uint8List file() => Uint8List.fromList([1, 2, 3, 4]);

    test('copyWith replaces every field', () {
      final original = TranscriptionRequest(
        file: file(),
        filename: 'a.mp3',
        model: 'whisper-1',
      );
      final updated = original.copyWith(
        file: Uint8List.fromList([9]),
        filename: 'b.mp3',
        model: 'gpt-4o-transcribe',
        chunkingStrategy: const TranscriptionChunkingStrategy.auto(),
        include: const [TranscriptionInclude.logprobs],
        keywords: const ['a'],
        knownSpeakerNames: const ['agent'],
        knownSpeakerReferences: const ['data:audio/wav;base64,AAAA'],
        language: 'en',
        languages: const ['en', 'es'],
        prompt: 'prompt',
        responseFormat: AudioResponseFormat.verboseJson,
        stream: true,
        temperature: 0.5,
        timestampGranularities: const [TimestampGranularity.word],
      );

      expect(updated.file, Uint8List.fromList([9]));
      expect(updated.filename, 'b.mp3');
      expect(updated.model, 'gpt-4o-transcribe');
      expect(
        updated.chunkingStrategy,
        const TranscriptionChunkingStrategy.auto(),
      );
      expect(updated.include, [TranscriptionInclude.logprobs]);
      expect(updated.keywords, ['a']);
      expect(updated.knownSpeakerNames, ['agent']);
      expect(updated.knownSpeakerReferences, ['data:audio/wav;base64,AAAA']);
      expect(updated.language, 'en');
      expect(updated.languages, ['en', 'es']);
      expect(updated.prompt, 'prompt');
      expect(updated.responseFormat, AudioResponseFormat.verboseJson);
      expect(updated.stream, true);
      expect(updated.temperature, 0.5);
      expect(updated.timestampGranularities, [TimestampGranularity.word]);
    });

    test('copyWith with no arguments keeps existing values', () {
      final original = TranscriptionRequest(
        file: file(),
        filename: 'a.mp3',
        model: 'whisper-1',
        language: 'en',
      );
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('copyWith null-clears nullable fields', () {
      final original = TranscriptionRequest(
        file: file(),
        filename: 'a.mp3',
        model: 'whisper-1',
        chunkingStrategy: const TranscriptionChunkingStrategy.auto(),
        include: const [TranscriptionInclude.logprobs],
        keywords: const ['a'],
        knownSpeakerNames: const ['agent'],
        knownSpeakerReferences: const ['data:audio/wav;base64,AAAA'],
        language: 'en',
        languages: const ['en'],
        prompt: 'prompt',
        responseFormat: AudioResponseFormat.json,
        stream: false,
        temperature: 0.2,
        timestampGranularities: const [TimestampGranularity.word],
      );

      final cleared = original.copyWith(
        chunkingStrategy: null,
        include: null,
        keywords: null,
        knownSpeakerNames: null,
        knownSpeakerReferences: null,
        language: null,
        languages: null,
        prompt: null,
        responseFormat: null,
        stream: null,
        temperature: null,
        timestampGranularities: null,
      );

      expect(cleared.chunkingStrategy, isNull);
      expect(cleared.include, isNull);
      expect(cleared.keywords, isNull);
      expect(cleared.knownSpeakerNames, isNull);
      expect(cleared.knownSpeakerReferences, isNull);
      expect(cleared.language, isNull);
      expect(cleared.languages, isNull);
      expect(cleared.prompt, isNull);
      expect(cleared.responseFormat, isNull);
      expect(cleared.stream, isNull);
      expect(cleared.temperature, isNull);
      expect(cleared.timestampGranularities, isNull);
      // Required fields untouched.
      expect(cleared.filename, 'a.mp3');
      expect(cleared.model, 'whisper-1');
    });

    test('toString references every field', () {
      final request = TranscriptionRequest(
        file: file(),
        filename: 'a.mp3',
        model: 'gpt-4o-transcribe',
        chunkingStrategy: const TranscriptionChunkingStrategy.auto(),
        include: const [TranscriptionInclude.logprobs],
        keywords: const ['a'],
        knownSpeakerNames: const ['agent'],
        knownSpeakerReferences: const ['data:audio/wav;base64,AAAA'],
        language: 'en',
        languages: const ['en'],
        prompt: 'prompt',
        responseFormat: AudioResponseFormat.diarizedJson,
        stream: true,
        temperature: 0.5,
        timestampGranularities: const [TimestampGranularity.word],
      );
      final s = request.toString();
      // file is summarized as a byte count, not dumped.
      expect(s, contains('${request.file.length} bytes'));
      expect(s, contains('a.mp3'));
      expect(s, contains('gpt-4o-transcribe'));
      expect(s, contains('TranscriptionChunkingStrategy.auto()'));
      // Nullable lists are summarized as '<n> items', not dumped.
      expect(s, contains('include: 1 items'));
      expect(s, contains('keywords: 1 items'));
      expect(s, contains('knownSpeakerNames: 1 items'));
      expect(s, contains('knownSpeakerReferences: 1 items'));
      expect(s, contains('language: en'));
      expect(s, contains('languages: 1 items'));
      expect(s, contains('prompt'));
      expect(s, contains('diarized_json'));
      expect(s, contains('stream: true'));
      expect(s, contains('temperature: 0.5'));
      expect(s, contains('timestampGranularities: 1 items'));
    });

    test('toString prints null for absent nullable list fields', () {
      final request = TranscriptionRequest(
        file: file(),
        filename: 'a.mp3',
        model: 'whisper-1',
      );
      final s = request.toString();
      expect(s, contains('include: null'));
      expect(s, contains('keywords: null'));
      expect(s, contains('knownSpeakerNames: null'));
      expect(s, contains('knownSpeakerReferences: null'));
      expect(s, contains('languages: null'));
      expect(s, contains('timestampGranularities: null'));
    });

    test('== and hashCode cover every field', () {
      TranscriptionRequest build() => TranscriptionRequest(
        file: Uint8List.fromList([1, 2]),
        filename: 'a.mp3',
        model: 'whisper-1',
        chunkingStrategy: const TranscriptionChunkingStrategy.auto(),
        include: const [TranscriptionInclude.logprobs],
        keywords: const ['a'],
        knownSpeakerNames: const ['agent'],
        knownSpeakerReferences: const ['data:audio/wav;base64,AAAA'],
        language: 'en',
        languages: const ['en'],
        prompt: 'prompt',
        responseFormat: AudioResponseFormat.json,
        stream: false,
        temperature: 0.2,
        timestampGranularities: const [TimestampGranularity.word],
      );

      final a = build();
      final b = build();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      // Each field individually distinguishes equality — regression test
      // against partial ==/hashCode (see feedback_partial_equality_extension).
      expect(a, isNot(equals(b.copyWith(filename: 'other.mp3'))));
      expect(a, isNot(equals(b.copyWith(model: 'gpt-4o-transcribe'))));
      expect(
        a,
        isNot(
          equals(
            b.copyWith(
              chunkingStrategy: const TranscriptionChunkingStrategy.serverVad(
                TranscriptionVadConfig(),
              ),
            ),
          ),
        ),
      );
      expect(a, isNot(equals(b.copyWith(include: null))));
      expect(a, isNot(equals(b.copyWith(keywords: const ['b']))));
      expect(a, isNot(equals(b.copyWith(knownSpeakerNames: const ['other']))));
      expect(
        a,
        isNot(equals(b.copyWith(knownSpeakerReferences: const ['other']))),
      );
      expect(a, isNot(equals(b.copyWith(language: 'fr'))));
      expect(a, isNot(equals(b.copyWith(languages: const ['fr']))));
      expect(a, isNot(equals(b.copyWith(prompt: 'other'))));
      expect(
        a,
        isNot(equals(b.copyWith(responseFormat: AudioResponseFormat.text))),
      );
      expect(a, isNot(equals(b.copyWith(stream: true))));
      expect(a, isNot(equals(b.copyWith(temperature: 0.9))));
      expect(
        a,
        isNot(
          equals(
            b.copyWith(
              timestampGranularities: const [TimestampGranularity.segment],
            ),
          ),
        ),
      );
    });
  });

  group('AudioResponseFormat', () {
    test('fromJson parses all spec values', () {
      expect(AudioResponseFormat.fromJson('json'), AudioResponseFormat.json);
      expect(AudioResponseFormat.fromJson('text'), AudioResponseFormat.text);
      expect(AudioResponseFormat.fromJson('srt'), AudioResponseFormat.srt);
      expect(
        AudioResponseFormat.fromJson('verbose_json'),
        AudioResponseFormat.verboseJson,
      );
      expect(AudioResponseFormat.fromJson('vtt'), AudioResponseFormat.vtt);
      expect(
        AudioResponseFormat.fromJson('diarized_json'),
        AudioResponseFormat.diarizedJson,
      );
    });

    test('fromJson falls back to unknown instead of throwing', () {
      expect(
        AudioResponseFormat.fromJson('some_future_format'),
        AudioResponseFormat.unknown,
      );
    });

    test('toJson returns correct string', () {
      expect(AudioResponseFormat.json.toJson(), 'json');
      expect(AudioResponseFormat.verboseJson.toJson(), 'verbose_json');
      expect(AudioResponseFormat.diarizedJson.toJson(), 'diarized_json');
    });

    test(
      'TranscriptionResponseFormat is a deprecated alias for AudioResponseFormat',
      () {
        expect(
          TranscriptionResponseFormat.fromJson('json'),
          AudioResponseFormat.json,
        );
        expect(TranscriptionResponseFormat.json, AudioResponseFormat.json);
      },
    );
  });

  group('TimestampGranularity', () {
    test('fromJson parses all values', () {
      expect(TimestampGranularity.fromJson('word'), TimestampGranularity.word);
      expect(
        TimestampGranularity.fromJson('segment'),
        TimestampGranularity.segment,
      );
    });

    test('toJson returns correct string', () {
      expect(TimestampGranularity.word.toJson(), 'word');
      expect(TimestampGranularity.segment.toJson(), 'segment');
    });
  });

  group('TranscriptionInclude', () {
    test('fromJson parses the known value', () {
      expect(
        TranscriptionInclude.fromJson('logprobs'),
        TranscriptionInclude.logprobs,
      );
    });

    test('fromJson falls back to unknown instead of throwing', () {
      expect(
        TranscriptionInclude.fromJson('something_new'),
        TranscriptionInclude.unknown,
      );
    });

    test('toJson returns correct string', () {
      expect(TranscriptionInclude.logprobs.toJson(), 'logprobs');
    });
  });

  group('TranscriptionChunkingStrategy', () {
    test('auto produces the literal string form field', () {
      const strategy = TranscriptionChunkingStrategy.auto();
      expect(strategy.toFormFields(), {'chunking_strategy': 'auto'});
    });

    test('serverVad produces bracket-per-property form fields', () {
      const strategy = TranscriptionChunkingStrategy.serverVad(
        TranscriptionVadConfig(
          prefixPaddingMs: 100,
          silenceDurationMs: 50,
          threshold: 0.4,
        ),
      );
      expect(strategy.toFormFields(), {
        'chunking_strategy[type]': 'server_vad',
        'chunking_strategy[prefix_padding_ms]': '100',
        'chunking_strategy[silence_duration_ms]': '50',
        'chunking_strategy[threshold]': '0.4',
      });
    });

    test('serverVad omits unset optional fields', () {
      const strategy = TranscriptionChunkingStrategy.serverVad(
        TranscriptionVadConfig(),
      );
      expect(strategy.toFormFields(), {
        'chunking_strategy[type]': 'server_vad',
      });
    });

    test('auto instances are equal; different variants are not', () {
      expect(
        const TranscriptionChunkingStrategy.auto(),
        equals(const TranscriptionChunkingStrategy.auto()),
      );
      expect(
        const TranscriptionChunkingStrategy.auto(),
        isNot(
          equals(
            const TranscriptionChunkingStrategy.serverVad(
              TranscriptionVadConfig(),
            ),
          ),
        ),
      );
    });
  });

  group('TranscriptionVadConfig', () {
    test('copyWith null-clears fields', () {
      const config = TranscriptionVadConfig(
        prefixPaddingMs: 100,
        silenceDurationMs: 50,
        threshold: 0.4,
      );
      final cleared = config.copyWith(
        prefixPaddingMs: null,
        silenceDurationMs: null,
        threshold: null,
      );
      expect(cleared.prefixPaddingMs, isNull);
      expect(cleared.silenceDurationMs, isNull);
      expect(cleared.threshold, isNull);
    });

    test('toString reports all fields', () {
      const config = TranscriptionVadConfig(
        prefixPaddingMs: 100,
        silenceDurationMs: 50,
        threshold: 0.4,
      );
      final s = config.toString();
      expect(s, contains('100'));
      expect(s, contains('50'));
      expect(s, contains('0.4'));
    });

    test('== and hashCode cover every field', () {
      const a = TranscriptionVadConfig(
        prefixPaddingMs: 100,
        silenceDurationMs: 50,
        threshold: 0.4,
      );
      const b = TranscriptionVadConfig(
        prefixPaddingMs: 100,
        silenceDurationMs: 50,
        threshold: 0.4,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(a.copyWith(prefixPaddingMs: 1))));
      expect(a, isNot(equals(a.copyWith(silenceDurationMs: 1))));
      expect(a, isNot(equals(a.copyWith(threshold: 0.9))));
    });
  });

  group('TranscriptionResponse', () {
    test('fromJson parses the minimal shape', () {
      final json = {'text': 'Hello, this is a transcription.'};

      final response = TranscriptionResponse.fromJson(json);

      expect(response.text, 'Hello, this is a transcription.');
      expect(response.languages, isNull);
      expect(response.logprobs, isNull);
      expect(response.usage, isNull);
    });

    test('fromJson round-trips the full shape with a tokens usage', () {
      final json = {
        'text': 'Imagine the wildest idea.',
        'languages': [
          {'code': 'en'},
        ],
        'logprobs': [
          {
            'token': 'Im',
            'bytes': [73, 109],
            'logprob': -0.1,
          },
        ],
        'usage': {
          'type': 'tokens',
          'input_tokens': 14,
          'output_tokens': 101,
          'total_tokens': 115,
          'input_token_details': {'text_tokens': 10, 'audio_tokens': 4},
        },
      };

      final response = TranscriptionResponse.fromJson(json);

      expect(response.text, 'Imagine the wildest idea.');
      expect(response.languages, [const TranscriptionLanguage(code: 'en')]);
      expect(response.logprobs!.single.token, 'Im');
      expect(response.logprobs!.single.bytes, [73, 109]);
      expect(response.usage, isA<TranscriptTextUsageTokens>());
      final usage = response.usage! as TranscriptTextUsageTokens;
      expect(usage.inputTokens, 14);
      expect(usage.outputTokens, 101);
      expect(usage.totalTokens, 115);
      expect(usage.inputTokenDetails!.textTokens, 10);
      expect(usage.inputTokenDetails!.audioTokens, 4);

      expect(
        TranscriptionResponse.fromJson(response.toJson()),
        equals(response),
      );
    });

    test('fromJson round-trips a duration usage', () {
      final json = {
        'text': 'Hello',
        'usage': {'type': 'duration', 'seconds': 9},
      };
      final response = TranscriptionResponse.fromJson(json);
      expect(response.usage, isA<TranscriptTextUsageDuration>());
      expect((response.usage! as TranscriptTextUsageDuration).seconds, 9.0);
      expect(
        TranscriptionResponse.fromJson(response.toJson()),
        equals(response),
      );
    });

    test('copyWith null-clears optional fields', () {
      const response = TranscriptionResponse(
        text: 'Hello',
        languages: [TranscriptionLanguage(code: 'en')],
        logprobs: [TranscriptionLogprob(token: 'Hi')],
        usage: TranscriptTextUsageDuration(seconds: 1),
      );
      final cleared = response.copyWith(
        languages: null,
        logprobs: null,
        usage: null,
      );
      expect(cleared.languages, isNull);
      expect(cleared.logprobs, isNull);
      expect(cleared.usage, isNull);
      expect(cleared.text, 'Hello');
    });

    test('toString references every field', () {
      const withData = TranscriptionResponse(
        text: 'Test transcription',
        languages: [TranscriptionLanguage(code: 'en')],
        logprobs: [TranscriptionLogprob(token: 'Hi')],
        usage: TranscriptTextUsageDuration(seconds: 1),
      );
      final s = withData.toString();
      expect(s, contains('18 chars'));
      expect(s, contains('languages: 1 items'));
      expect(s, contains('logprobs: 1 items'));
      expect(s, contains('usage: TranscriptTextUsageDuration'));

      const withoutData = TranscriptionResponse(text: 'Hi');
      final s2 = withoutData.toString();
      expect(s2, contains('languages: null'));
      expect(s2, contains('logprobs: null'));
      expect(s2, contains('usage: null'));
    });

    test('== and hashCode cover every field', () {
      const a = TranscriptionResponse(
        text: 'Hello',
        languages: [TranscriptionLanguage(code: 'en')],
        logprobs: [TranscriptionLogprob(token: 'Hi')],
        usage: TranscriptTextUsageDuration(seconds: 1),
      );
      const b = TranscriptionResponse(
        text: 'Hello',
        languages: [TranscriptionLanguage(code: 'en')],
        logprobs: [TranscriptionLogprob(token: 'Hi')],
        usage: TranscriptTextUsageDuration(seconds: 1),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(a.copyWith(text: 'Other'))));
      expect(a, isNot(equals(a.copyWith(languages: null))));
      expect(a, isNot(equals(a.copyWith(logprobs: null))));
      expect(a, isNot(equals(a.copyWith(usage: null))));
    });
  });

  group('TranscriptionVerboseResponse', () {
    test('fromJson parses correctly and tolerates a missing task', () {
      final json = {
        'language': 'en',
        'duration': 2.5,
        'text': 'Hello world',
        'segments': [
          {
            'id': 0,
            'seek': 0,
            'start': 0.0,
            'end': 1.0,
            'text': 'Hello',
            'tokens': [1, 2, 3],
            'temperature': 0.0,
            'avg_logprob': -0.5,
            'compression_ratio': 1.2,
            'no_speech_prob': 0.01,
          },
        ],
        'usage': {'type': 'duration', 'seconds': 9},
      };

      final response = TranscriptionVerboseResponse.fromJson(json);

      expect(response.task, isNull);
      expect(response.language, 'en');
      expect(response.duration, 2.5);
      expect(response.text, 'Hello world');
      expect(response.segments?.length, 1);
      expect(response.usage?.seconds, 9.0);
    });

    test('fromJson keeps task when present', () {
      final json = {
        'task': 'transcribe',
        'language': 'en',
        'duration': 1.0,
        'text': 'Hi',
      };
      expect(TranscriptionVerboseResponse.fromJson(json).task, 'transcribe');
    });

    test('toJson round-trips', () {
      const response = TranscriptionVerboseResponse(
        task: 'transcribe',
        language: 'en',
        duration: 1.5,
        text: 'Test',
        usage: TranscriptTextUsageDuration(seconds: 2),
      );
      expect(
        TranscriptionVerboseResponse.fromJson(response.toJson()),
        equals(response),
      );
    });

    test('copyWith null-clears optional fields, including task', () {
      const response = TranscriptionVerboseResponse(
        task: 'transcribe',
        language: 'en',
        duration: 1.5,
        text: 'Test',
        segments: [],
        words: [],
        usage: TranscriptTextUsageDuration(seconds: 2),
      );
      final cleared = response.copyWith(
        task: null,
        segments: null,
        words: null,
        usage: null,
      );
      expect(cleared.task, isNull);
      expect(cleared.segments, isNull);
      expect(cleared.words, isNull);
      expect(cleared.usage, isNull);
    });

    test('toString references every field', () {
      const withData = TranscriptionVerboseResponse(
        task: 'transcribe',
        language: 'en',
        duration: 1.5,
        text: 'Test',
        segments: [],
        words: [],
        usage: TranscriptTextUsageDuration(seconds: 2),
      );
      final s = withData.toString();
      expect(s, contains('task: transcribe'));
      expect(s, contains('language: en'));
      expect(s, contains('duration: 1.5'));
      expect(s, contains('4 chars'));
      expect(s, contains('segments: 0 items'));
      expect(s, contains('words: 0 items'));
      expect(s, contains('usage: TranscriptTextUsageDuration'));

      const withoutData = TranscriptionVerboseResponse(
        language: 'en',
        duration: 1.5,
        text: 'Test',
      );
      final s2 = withoutData.toString();
      expect(s2, contains('task: null'));
      expect(s2, contains('segments: null'));
      expect(s2, contains('words: null'));
      expect(s2, contains('usage: null'));
    });

    test('== and hashCode cover every field', () {
      const a = TranscriptionVerboseResponse(
        task: 'transcribe',
        language: 'en',
        duration: 1.5,
        text: 'Test',
        usage: TranscriptTextUsageDuration(seconds: 2),
      );
      const b = TranscriptionVerboseResponse(
        task: 'transcribe',
        language: 'en',
        duration: 1.5,
        text: 'Test',
        usage: TranscriptTextUsageDuration(seconds: 2),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(a.copyWith(task: null))));
      expect(a, isNot(equals(a.copyWith(language: 'fr'))));
      expect(a, isNot(equals(a.copyWith(duration: 9))));
      expect(a, isNot(equals(a.copyWith(text: 'Other'))));
      expect(a, isNot(equals(a.copyWith(usage: null))));
    });
  });

  group('TranscriptionDiarizedResponse', () {
    final json = {
      'task': 'transcribe',
      'duration': 42.7,
      'text': 'Agent: hi.\nCustomer: hello.',
      'segments': [
        {
          'type': 'transcript.text.segment',
          'id': 'seg_001',
          'start': 0.0,
          'end': 5.2,
          'text': 'hi.',
          'speaker': 'agent',
        },
      ],
      'usage': {'type': 'duration', 'seconds': 43},
    };

    test('fromJson parses correctly', () {
      final response = TranscriptionDiarizedResponse.fromJson(json);
      expect(response.task, 'transcribe');
      expect(response.duration, 42.7);
      expect(response.segments.single.speaker, 'agent');
      expect(response.usage, isA<TranscriptTextUsageDuration>());
    });

    test('fromJson throws FormatException on a mismatched task', () {
      expect(
        () =>
            TranscriptionDiarizedResponse.fromJson({...json, 'task': 'other'}),
        throwsFormatException,
      );
    });

    test('round-trips through toJson', () {
      final response = TranscriptionDiarizedResponse.fromJson(json);
      expect(
        TranscriptionDiarizedResponse.fromJson(response.toJson()),
        equals(response),
      );
    });

    test('copyWith null-clears usage', () {
      final response = TranscriptionDiarizedResponse.fromJson(json);
      expect(response.copyWith(usage: null).usage, isNull);
    });

    test('toString references every field', () {
      final response = TranscriptionDiarizedResponse.fromJson(json);
      final s = response.toString();
      expect(s, contains('task: transcribe'));
      expect(s, contains('duration: 42.7'));
      expect(s, contains('1 segments'));
      expect(s, contains('usage: TranscriptTextUsageDuration'));
    });

    test('== and hashCode cover every field', () {
      final a = TranscriptionDiarizedResponse.fromJson(json);
      final b = TranscriptionDiarizedResponse.fromJson(json);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(a.copyWith(text: 'other'))));
      expect(a, isNot(equals(a.copyWith(duration: 1))));
      expect(a, isNot(equals(a.copyWith(segments: []))));
      expect(a, isNot(equals(a.copyWith(usage: null))));
    });
  });

  group('TranscriptionDiarizedSegment', () {
    const json = {
      'type': 'transcript.text.segment',
      'id': 'seg_002',
      'start': 5.2,
      'end': 12.8,
      'text': 'Hi, I need help.',
      'speaker': 'A',
    };

    test('fromJson parses correctly and exposes a fixed type', () {
      final segment = TranscriptionDiarizedSegment.fromJson(json);
      expect(segment.type, 'transcript.text.segment');
      expect(segment.id, 'seg_002');
      expect(segment.start, 5.2);
      expect(segment.end, 12.8);
      expect(segment.speaker, 'A');
    });

    test('fromJson throws FormatException on a mismatched type', () {
      const mismatched = {
        'type': 'other',
        'id': 'seg_002',
        'start': 5.2,
        'end': 12.8,
        'text': 'Hi, I need help.',
        'speaker': 'A',
      };
      expect(
        () => TranscriptionDiarizedSegment.fromJson(mismatched),
        throwsFormatException,
      );
    });

    test('toJson always emits the fixed type', () {
      final segment = TranscriptionDiarizedSegment.fromJson(json);
      expect(segment.toJson()['type'], 'transcript.text.segment');
    });

    test('toString references every field', () {
      final segment = TranscriptionDiarizedSegment.fromJson(json);
      final s = segment.toString();
      expect(s, contains('id: seg_002'));
      expect(s, contains('speaker: A'));
      expect(s, contains('5.2-12.8'));
      expect(s, contains('${segment.text.length} chars'));
    });

    test('== and hashCode cover every field', () {
      final a = TranscriptionDiarizedSegment.fromJson(json);
      final b = TranscriptionDiarizedSegment.fromJson(json);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(a.copyWith(id: 'other'))));
      expect(a, isNot(equals(a.copyWith(start: 0))));
      expect(a, isNot(equals(a.copyWith(end: 0))));
      expect(a, isNot(equals(a.copyWith(text: 'other'))));
      expect(a, isNot(equals(a.copyWith(speaker: 'B'))));
    });
  });

  group('TranscriptionStreamEvent', () {
    test('dispatches all three known variants', () {
      final segment = TranscriptionStreamEvent.fromJson(const {
        'type': 'transcript.text.segment',
        'id': 'seg_002',
        'start': 5.2,
        'end': 12.8,
        'text': 'Hi, I need help with diarization.',
        'speaker': 'A',
      });
      expect(segment, isA<TranscriptTextSegmentEvent>());

      final delta = TranscriptionStreamEvent.fromJson(const {
        'type': 'transcript.text.delta',
        'delta': ' wonderful',
        'segment_id': 'seg_001',
      });
      expect(delta, isA<TranscriptTextDeltaEvent>());
      expect((delta as TranscriptTextDeltaEvent).segmentId, 'seg_001');

      final done = TranscriptionStreamEvent.fromJson(const {
        'type': 'transcript.text.done',
        'text': 'I see skies of blue.',
        'usage': {
          'type': 'tokens',
          'input_tokens': 14,
          'output_tokens': 31,
          'total_tokens': 45,
        },
      });
      expect(done, isA<TranscriptTextDoneEvent>());
      expect((done as TranscriptTextDoneEvent).usage?.totalTokens, 45);

      // Round-trip each variant.
      expect(
        TranscriptionStreamEvent.fromJson(segment.toJson()),
        equals(segment),
      );
      expect(TranscriptionStreamEvent.fromJson(delta.toJson()), equals(delta));
      expect(TranscriptionStreamEvent.fromJson(done.toJson()), equals(done));
    });

    test('unknown discriminator falls back without throwing', () {
      const json = {
        'type': 'transcript.text.some_future_event',
        'something_new': 'value',
      };
      final event = TranscriptionStreamEvent.fromJson(json);
      expect(event, isA<TranscriptTextUnknownEvent>());
      expect(event.type, 'transcript.text.some_future_event');
      expect(event.toJson()['something_new'], 'value');
    });

    test('TranscriptTextUnknownEvent implements deep value equality', () {
      final a = TranscriptTextUnknownEvent.fromJson(const {
        'type': 'transcript.text.future',
        'nested': {
          'arr': [1, 2, 3],
        },
      });
      final b = TranscriptTextUnknownEvent.fromJson(const {
        'type': 'transcript.text.future',
        'nested': {
          'arr': [1, 2, 3],
        },
      });
      final c = TranscriptTextUnknownEvent.fromJson(const {
        'type': 'transcript.text.future',
        'nested': {
          'arr': [1, 2, 4],
        },
      });
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('each typed variant throws FormatException on the wrong type', () {
      expect(
        () => TranscriptTextSegmentEvent.fromJson(const {'type': 'wrong'}),
        throwsFormatException,
      );
      expect(
        () => TranscriptTextDeltaEvent.fromJson(const {'type': 'wrong'}),
        throwsFormatException,
      );
      expect(
        () => TranscriptTextDoneEvent.fromJson(const {'type': 'wrong'}),
        throwsFormatException,
      );
    });

    test('TranscriptTextSegmentEvent copyWith and toString', () {
      const event = TranscriptTextSegmentEvent(
        id: 'seg_002',
        start: 5.2,
        end: 12.8,
        text: 'Hi, I need help.',
        speaker: 'A',
      );
      final updated = event.copyWith(
        id: 'seg_003',
        start: 0,
        end: 1,
        text: 'Bye',
        speaker: 'B',
      );
      expect(updated.id, 'seg_003');
      expect(updated.start, 0);
      expect(updated.end, 1);
      expect(updated.text, 'Bye');
      expect(updated.speaker, 'B');
      expect(event.copyWith(), equals(event));

      final s = event.toString();
      expect(s, contains('id: seg_002'));
      expect(s, contains('speaker: A'));
      expect(s, contains('5.2-12.8'));
      expect(s, contains('${event.text.length} chars'));
    });

    test('TranscriptTextDeltaEvent copyWith null-clears nullable fields', () {
      const event = TranscriptTextDeltaEvent(
        delta: 'Hello',
        logprobs: [TranscriptionLogprob(token: 'He')],
        segmentId: 'seg_1',
      );
      final cleared = event.copyWith(logprobs: null, segmentId: null);
      expect(cleared.delta, 'Hello');
      expect(cleared.logprobs, isNull);
      expect(cleared.segmentId, isNull);
      expect(event.copyWith(), equals(event));

      final s = event.toString();
      expect(s, contains('delta: Hello'));
      expect(s, contains('logprobs: 1 items'));
      expect(s, contains('segmentId: seg_1'));
      expect(cleared.toString(), contains('logprobs: null'));
      expect(cleared.toString(), contains('segmentId: null'));
    });

    test('TranscriptTextDoneEvent copyWith null-clears nullable fields', () {
      const event = TranscriptTextDoneEvent(
        text: 'Hello world',
        languages: [TranscriptionLanguage(code: 'en')],
        logprobs: [TranscriptionLogprob(token: 'He')],
        usage: TranscriptTextUsageTokens(
          inputTokens: 1,
          outputTokens: 2,
          totalTokens: 3,
        ),
      );
      final cleared = event.copyWith(
        languages: null,
        logprobs: null,
        usage: null,
      );
      expect(cleared.text, 'Hello world');
      expect(cleared.languages, isNull);
      expect(cleared.logprobs, isNull);
      expect(cleared.usage, isNull);
      expect(event.copyWith(), equals(event));

      final s = event.toString();
      expect(s, contains('11 chars'));
      expect(s, contains('languages: 1 items'));
      expect(s, contains('logprobs: 1 items'));
      expect(s, contains('usage: TranscriptTextUsageTokens'));
      expect(cleared.toString(), contains('languages: null'));
      expect(cleared.toString(), contains('logprobs: null'));
      expect(cleared.toString(), contains('usage: null'));
    });
  });

  group('TranscriptUsage', () {
    test('dispatches tokens and duration variants', () {
      final tokens = TranscriptUsage.fromJson(const {
        'type': 'tokens',
        'input_tokens': 1,
        'output_tokens': 2,
        'total_tokens': 3,
      });
      expect(tokens, isA<TranscriptTextUsageTokens>());

      final duration = TranscriptUsage.fromJson(const {
        'type': 'duration',
        'seconds': 4,
      });
      expect(duration, isA<TranscriptTextUsageDuration>());
    });

    test('unknown discriminator falls back without throwing', () {
      final usage = TranscriptUsage.fromJson(const {
        'type': 'credits',
        'amount': 5,
      });
      expect(usage, isA<TranscriptUsageUnknown>());
      expect(usage.type, 'credits');
      expect(usage.toJson()['amount'], 5);
    });

    test('TranscriptUsageUnknown implements deep value equality', () {
      final a = TranscriptUsageUnknown.fromJson(const {
        'type': 'credits',
        'nested': {'a': 1},
      });
      final b = TranscriptUsageUnknown.fromJson(const {
        'type': 'credits',
        'nested': {'a': 1},
      });
      final c = TranscriptUsageUnknown.fromJson(const {
        'type': 'credits',
        'nested': {'a': 2},
      });
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('TranscriptTextUsageTokens == and hashCode cover every field', () {
      const a = TranscriptTextUsageTokens(
        inputTokens: 1,
        outputTokens: 2,
        totalTokens: 3,
        inputTokenDetails: TranscriptUsageInputTokenDetails(
          audioTokens: 1,
          textTokens: 2,
        ),
      );
      const b = TranscriptTextUsageTokens(
        inputTokens: 1,
        outputTokens: 2,
        totalTokens: 3,
        inputTokenDetails: TranscriptUsageInputTokenDetails(
          audioTokens: 1,
          textTokens: 2,
        ),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(
        a,
        isNot(
          equals(
            const TranscriptTextUsageTokens(
              inputTokens: 9,
              outputTokens: 2,
              totalTokens: 3,
            ),
          ),
        ),
      );
      expect(
        a,
        isNot(
          equals(
            const TranscriptTextUsageTokens(
              inputTokens: 1,
              outputTokens: 9,
              totalTokens: 3,
            ),
          ),
        ),
      );
      expect(
        a,
        isNot(
          equals(
            const TranscriptTextUsageTokens(
              inputTokens: 1,
              outputTokens: 2,
              totalTokens: 9,
            ),
          ),
        ),
      );
      expect(
        a,
        isNot(
          equals(
            const TranscriptTextUsageTokens(
              inputTokens: 1,
              outputTokens: 2,
              totalTokens: 3,
            ),
          ),
        ),
      );
    });

    test(
      'TranscriptTextUsageTokens copyWith null-clears inputTokenDetails',
      () {
        const usage = TranscriptTextUsageTokens(
          inputTokens: 1,
          outputTokens: 2,
          totalTokens: 3,
          inputTokenDetails: TranscriptUsageInputTokenDetails(audioTokens: 1),
        );
        final updated = usage.copyWith(
          inputTokens: 9,
          outputTokens: 8,
          totalTokens: 7,
        );
        expect(updated.inputTokens, 9);
        expect(updated.outputTokens, 8);
        expect(updated.totalTokens, 7);
        expect(updated.inputTokenDetails, usage.inputTokenDetails);

        final cleared = usage.copyWith(inputTokenDetails: null);
        expect(cleared.inputTokenDetails, isNull);
        expect(usage.copyWith(), equals(usage));
      },
    );

    test('TranscriptTextUsageTokens toString references every field', () {
      const usage = TranscriptTextUsageTokens(
        inputTokens: 1,
        outputTokens: 2,
        totalTokens: 3,
        inputTokenDetails: TranscriptUsageInputTokenDetails(audioTokens: 4),
      );
      final s = usage.toString();
      expect(s, contains('input: 1'));
      expect(s, contains('output: 2'));
      expect(s, contains('total: 3'));
      expect(
        s,
        contains('inputTokenDetails: TranscriptUsageInputTokenDetails'),
      );
    });

    test('TranscriptTextUsageDuration copyWith', () {
      const usage = TranscriptTextUsageDuration(seconds: 1);
      expect(usage.copyWith(seconds: 2).seconds, 2);
      expect(usage.copyWith(), equals(usage));
    });

    test('TranscriptTextUsageTokens.fromJson throws on mismatched type', () {
      expect(
        () => TranscriptTextUsageTokens.fromJson(const {
          'type': 'duration',
          'input_tokens': 1,
          'output_tokens': 2,
          'total_tokens': 3,
        }),
        throwsFormatException,
      );
    });

    test('TranscriptTextUsageDuration.fromJson throws on mismatched type', () {
      expect(
        () => TranscriptTextUsageDuration.fromJson(const {
          'type': 'tokens',
          'seconds': 1,
        }),
        throwsFormatException,
      );
    });

    test('TranscriptUsageInputTokenDetails copyWith null-clears fields', () {
      const details = TranscriptUsageInputTokenDetails(
        audioTokens: 1,
        textTokens: 2,
      );
      final cleared = details.copyWith(audioTokens: null, textTokens: null);
      expect(cleared.audioTokens, isNull);
      expect(cleared.textTokens, isNull);
    });
  });

  group('TranscriptionLanguage', () {
    test('round-trips through JSON', () {
      const language = TranscriptionLanguage(code: 'en');
      expect(
        TranscriptionLanguage.fromJson(language.toJson()),
        equals(language),
      );
    });

    test('== and hashCode compare by code', () {
      expect(
        const TranscriptionLanguage(code: 'en'),
        equals(const TranscriptionLanguage(code: 'en')),
      );
      expect(
        const TranscriptionLanguage(code: 'en'),
        isNot(equals(const TranscriptionLanguage(code: 'fr'))),
      );
    });
  });

  group('TranscriptionLogprob', () {
    test('fromJson tolerates all-null fields', () {
      final logprob = TranscriptionLogprob.fromJson(const {});
      expect(logprob.token, isNull);
      expect(logprob.bytes, isNull);
      expect(logprob.logprob, isNull);
    });

    test('fromJson casts bytes defensively regardless of int/double', () {
      final logprob = TranscriptionLogprob.fromJson(const {
        'token': 'Hi',
        'bytes': [72, 105],
        'logprob': -0.2,
      });
      expect(logprob.bytes, [72, 105]);
    });

    test('copyWith null-clears fields', () {
      const logprob = TranscriptionLogprob(
        token: 'Hi',
        bytes: [1],
        logprob: -0.1,
      );
      final cleared = logprob.copyWith(token: null, bytes: null, logprob: null);
      expect(cleared.token, isNull);
      expect(cleared.bytes, isNull);
      expect(cleared.logprob, isNull);
    });

    test('== and hashCode cover every field', () {
      const a = TranscriptionLogprob(token: 'Hi', bytes: [1], logprob: -0.1);
      const b = TranscriptionLogprob(token: 'Hi', bytes: [1], logprob: -0.1);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(a.copyWith(token: 'Bye'))));
      expect(a, isNot(equals(a.copyWith(bytes: [2]))));
      expect(a, isNot(equals(a.copyWith(logprob: -0.9))));
    });
  });

  group('TranscriptionSegment', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 0,
        'seek': 0,
        'start': 0.5,
        'end': 2.5,
        'text': 'Hello world',
        'tokens': [1, 2, 3],
        'temperature': 0.0,
        'avg_logprob': -0.5,
        'compression_ratio': 1.2,
        'no_speech_prob': 0.01,
      };

      final segment = TranscriptionSegment.fromJson(json);

      expect(segment.id, 0);
      expect(segment.start, 0.5);
      expect(segment.end, 2.5);
      expect(segment.text, 'Hello world');
      expect(segment.tokens, [1, 2, 3]);
      expect(segment.noSpeechProb, 0.01);
    });
  });

  group('TranslationResponse', () {
    test('fromJson parses correctly', () {
      final json = {'text': 'This is translated text.'};

      final response = TranslationResponse.fromJson(json);

      expect(response.text, 'This is translated text.');
    });

    test('toJson serializes correctly', () {
      const response = TranslationResponse(text: 'Translated content');

      final json = response.toJson();

      expect(json['text'], 'Translated content');
    });
  });

  group('TranslationResponseFormat', () {
    test('fromJson parses all values', () {
      expect(
        TranslationResponseFormat.fromJson('json'),
        TranslationResponseFormat.json,
      );
      expect(
        TranslationResponseFormat.fromJson('text'),
        TranslationResponseFormat.text,
      );
      expect(
        TranslationResponseFormat.fromJson('srt'),
        TranslationResponseFormat.srt,
      );
      expect(
        TranslationResponseFormat.fromJson('verbose_json'),
        TranslationResponseFormat.verboseJson,
      );
      expect(
        TranslationResponseFormat.fromJson('vtt'),
        TranslationResponseFormat.vtt,
      );
    });

    test('fromJson falls back to unknown instead of throwing', () {
      expect(
        TranslationResponseFormat.fromJson('diarized_json'),
        TranslationResponseFormat.unknown,
      );
    });

    test('toJson returns correct string', () {
      expect(TranslationResponseFormat.json.toJson(), 'json');
      expect(TranslationResponseFormat.verboseJson.toJson(), 'verbose_json');
    });
  });

  group('TranslationRequest', () {
    test(
      'accepts a TranslationResponseFormat (decoupled from transcriptions)',
      () {
        final request = TranslationRequest(
          file: Uint8List.fromList([1, 2, 3, 4]),
          filename: 'audio.mp3',
          model: 'whisper-1',
          responseFormat: TranslationResponseFormat.srt,
        );
        expect(request.responseFormat, TranslationResponseFormat.srt);
      },
    );
  });
}
