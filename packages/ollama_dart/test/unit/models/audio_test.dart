import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  test('unknown audio formats use explicit fallbacks', () {
    expect(
      SpeechResponseFormat.fromJson('future-format'),
      SpeechResponseFormat.unknown,
    );
    expect(
      AudioTextResponseFormat.fromJson('future-format'),
      AudioTextResponseFormat.unknown,
    );
    expect(
      SpeechRequest.fromJson(const {
        'model': 'm',
        'input': 'hello',
        'response_format': 'future-format',
      }).responseFormat,
      SpeechResponseFormat.unknown,
    );
  });

  test('required audio fields reject missing or malformed values', () {
    for (final value in [null, 42, true, <String, dynamic>{}]) {
      expect(
        () => SpeechRequest.fromJson({'model': value, 'input': 'hello'}),
        throwsFormatException,
      );
      expect(
        () => SpeechRequest.fromJson({'model': 'm', 'input': value}),
        throwsFormatException,
      );
      expect(
        () => TranscriptionResponse.fromJson({'text': value}),
        throwsFormatException,
      );
      expect(
        () => TranscriptTextDelta.fromJson({
          'type': 'transcript.text.delta',
          'delta': value,
        }),
        throwsFormatException,
      );
      expect(
        () => TranscriptTextDone.fromJson({
          'type': 'transcript.text.done',
          'text': value,
        }),
        throwsFormatException,
      );
    }
    expect(() => AudioFile.fromJson(const {}), throwsFormatException);
    expect(
      () => AudioFile.fromJson(const {
        'bytes': [1, 'wrong'],
      }),
      throwsFormatException,
    );
    expect(
      () => AudioFile.fromJson(const {
        'bytes': [1],
        'filename': 42,
      }),
      throwsFormatException,
    );
    expect(
      () => TranscriptionRequest.fromJson(const {'model': 'm'}),
      throwsFormatException,
    );
    expect(
      () => TranslationRequest.fromJson(const {
        'model': 1,
        'file': {
          'bytes': [1],
        },
      }),
      throwsFormatException,
    );
    expect(
      () => TranscriptionSegment.fromJson(const {
        'id': 0,
        'start': null,
        'end': 1,
        'text': 'hello',
      }),
      throwsFormatException,
    );
  });

  test('speech preserves all wire fields and omitted server defaults', () {
    const minimal = SpeechRequest(model: 'phonon', input: 'Hello');
    expect(minimal.toJson(), {'model': 'phonon', 'input': 'Hello'});
    const full = SpeechRequest(
      model: 'phonon',
      input: 'Hello',
      voice: 'Zoey',
      responseFormat: SpeechResponseFormat.pcm,
      speed: 1,
      instructions: '',
      streamFormat: 'audio',
    );
    expect(full.toJson(), {
      'model': 'phonon',
      'input': 'Hello',
      'voice': 'Zoey',
      'response_format': 'pcm',
      'speed': 1.0,
      'instructions': '',
      'stream_format': 'audio',
    });
    final roundTrip = SpeechRequest.fromJson(full.toJson());
    expect(roundTrip, full);
    expect(roundTrip.hashCode, full.hashCode);
    expect(full.copyWith(), full);
    expect(full.copyWith(speed: 1), full);
    expect(
      full.copyWith(
        voice: null,
        responseFormat: null,
        speed: null,
        instructions: null,
        streamFormat: null,
      ),
      minimal,
    );
    expect(full.copyWith(model: 'other'), isNot(full));
    for (final field in [
      'model:',
      'input:',
      'voice:',
      'responseFormat:',
      'speed:',
      'instructions:',
      'streamFormat:',
    ]) {
      expect(full.toString(), contains(field));
    }
    for (final format in SpeechResponseFormat.values) {
      expect(SpeechResponseFormat.fromJson(format.toJson()), format);
    }
  });

  test('audio file snapshots bytes and uses value equality', () {
    final bytes = [0, 255, 128];
    final file = AudioFile(bytes: bytes, filename: 'recording.wav');
    bytes[0] = 42;
    expect(file.bytes, [0, 255, 128]);
    expect(() => file.bytes.add(1), throwsUnsupportedError);
    final copy = AudioFile.fromJson(file.toJson());
    expect(copy, file);
    expect(copy.hashCode, file.hashCode);
    expect(file.copyWith(), file);
    expect(file.copyWith(filename: 'different.wav'), isNot(file));
    expect(file.toString(), contains('3 bytes'));
  });

  test('transcription request round trip, multipart fields and clearing', () {
    final file = AudioFile(bytes: const [0, 255]);
    final request = TranscriptionRequest(
      model: 'audio-model',
      file: file,
      language: 'French',
      prompt: 'Context',
      responseFormat: AudioTextResponseFormat.verboseJson,
      temperature: 0.2,
      stream: true,
    );
    final copy = TranscriptionRequest.fromJson(request.toJson());
    expect(copy, request);
    expect(copy.hashCode, request.hashCode);
    expect(request.toFields(streamOverride: false), {
      'model': 'audio-model',
      'language': 'French',
      'prompt': 'Context',
      'response_format': 'verbose_json',
      'temperature': '0.2',
      'stream': 'false',
    });
    expect(request.copyWith(), request);
    expect(request.copyWith(temperature: 1).temperature, 1.0);
    final minimal = TranscriptionRequest(model: 'audio-model', file: file);
    expect(
      request.copyWith(
        language: null,
        prompt: null,
        responseFormat: null,
        temperature: null,
        stream: null,
      ),
      minimal,
    );
    expect(minimal.toFields(), {'model': 'audio-model'});
  });

  test('translation preserves and clears target language', () {
    final file = AudioFile(bytes: const [1]);
    final request = TranslationRequest(
      model: 'audio-model',
      file: file,
      language: 'fr',
      toLanguage: 'de',
      prompt: 'Context',
      responseFormat: AudioTextResponseFormat.text,
      temperature: 0,
      stream: false,
    );
    final copy = TranslationRequest.fromJson(request.toJson());
    expect(copy, request);
    expect(copy.hashCode, request.hashCode);
    expect(request.toFields()['to_language'], 'de');
    expect(request.copyWith(), request);
    expect(request.copyWith(toLanguage: 'en'), isNot(request));
    expect(
      request.copyWith(
        language: null,
        toLanguage: null,
        prompt: null,
        responseFormat: null,
        temperature: null,
        stream: null,
      ),
      TranslationRequest(model: 'audio-model', file: file),
    );
    expect(request.toString(), contains('toLanguage: de'));
    for (final format in AudioTextResponseFormat.values) {
      expect(AudioTextResponseFormat.fromJson(format.toJson()), format);
    }
  });

  test('verbose metadata round trips and collections are immutable', () {
    const segment = TranscriptionSegment(
      id: 0,
      start: 0,
      end: 1.5,
      text: 'Hello',
    );
    final segments = [segment];
    final response = TranscriptionResponse(
      text: 'Hello',
      task: 'translate',
      language: 'english',
      duration: 1.5,
      segments: segments,
    );
    segments.clear();
    final copy = TranscriptionResponse.fromJson(response.toJson());
    expect(copy, response);
    expect(copy.hashCode, response.hashCode);
    expect(response.segments, [segment]);
    expect(() => response.segments!.clear(), throwsUnsupportedError);
    expect(response.copyWith(), response);
    expect(response.copyWith(duration: 1).duration, 1.0);
    expect(
      response.copyWith(
        task: null,
        language: null,
        duration: null,
        segments: null,
      ),
      TranscriptionResponse(text: 'Hello'),
    );
    expect(segment.copyWith(), segment);
    expect(segment.copyWith(text: 'World'), isNot(segment));
    expect(segment.toString(), contains('end: 1.5'));
    expect(response.toString(), contains('1 items'));
  });

  test('transcript event variants preserve content and unknown JSON', () {
    const events = <TranscriptionStreamEvent>[
      TranscriptTextDelta(delta: 'Hello'),
      TranscriptTextDone(text: 'Hello'),
    ];
    for (final event in events) {
      final copy = TranscriptionStreamEvent.fromJson(event.toJson());
      expect(copy, event);
      expect(copy.hashCode, event.hashCode);
    }
    expect(
      const TranscriptTextDelta(delta: 'Hi').copyWith(delta: 'Bye'),
      const TranscriptTextDelta(delta: 'Bye'),
    );
    expect(
      const TranscriptTextDone(text: 'Hi').copyWith(text: 'Bye'),
      const TranscriptTextDone(text: 'Bye'),
    );
    expect(
      () => TranscriptTextDone.fromJson(const {'type': 'other'}),
      throwsFormatException,
    );
    expect(
      () => TranscriptTextDelta.fromJson(const {'type': 'other'}),
      throwsFormatException,
    );
    final json = <String, dynamic>{
      'type': 'future.event',
      'nested': {
        'items': [1, 2],
      },
    };
    final unknown = TranscriptionStreamEvent.fromJson(json);
    final copy = TranscriptionStreamEvent.fromJson(unknown.toJson());
    expect(unknown, isA<UnknownTranscriptionEvent>());
    expect(copy, unknown);
    expect(copy.hashCode, unknown.hashCode);
    expect(unknown.toJson(), json);
  });
}
