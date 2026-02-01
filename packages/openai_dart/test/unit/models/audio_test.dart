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

  group('TranscriptionResponse', () {
    test('fromJson parses correctly', () {
      final json = {'text': 'Hello, this is a transcription.'};

      final response = TranscriptionResponse.fromJson(json);

      expect(response.text, 'Hello, this is a transcription.');
    });

    test('toJson serializes correctly', () {
      const response = TranscriptionResponse(text: 'Test transcription');

      final json = response.toJson();

      expect(json['text'], 'Test transcription');
    });
  });

  group('TranscriptionVerboseResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'task': 'transcribe',
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
          {
            'id': 1,
            'seek': 0,
            'start': 1.0,
            'end': 2.5,
            'text': ' world',
            'tokens': [4, 5],
            'temperature': 0.0,
            'avg_logprob': -0.4,
            'compression_ratio': 1.1,
            'no_speech_prob': 0.02,
          },
        ],
      };

      final response = TranscriptionVerboseResponse.fromJson(json);

      expect(response.task, 'transcribe');
      expect(response.language, 'en');
      expect(response.duration, 2.5);
      expect(response.text, 'Hello world');
      expect(response.segments?.length, 2);
      expect(response.segments?[0].text, 'Hello');
    });

    test('toJson serializes correctly', () {
      const response = TranscriptionVerboseResponse(
        task: 'transcribe',
        language: 'en',
        duration: 1.5,
        text: 'Test',
      );

      final json = response.toJson();

      expect(json['task'], 'transcribe');
      expect(json['language'], 'en');
      expect(json['duration'], 1.5);
      expect(json['text'], 'Test');
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

  group('TranscriptionResponseFormat', () {
    test('fromJson parses all values', () {
      expect(
        TranscriptionResponseFormat.fromJson('json'),
        TranscriptionResponseFormat.json,
      );
      expect(
        TranscriptionResponseFormat.fromJson('text'),
        TranscriptionResponseFormat.text,
      );
      expect(
        TranscriptionResponseFormat.fromJson('srt'),
        TranscriptionResponseFormat.srt,
      );
      expect(
        TranscriptionResponseFormat.fromJson('verbose_json'),
        TranscriptionResponseFormat.verboseJson,
      );
      expect(
        TranscriptionResponseFormat.fromJson('vtt'),
        TranscriptionResponseFormat.vtt,
      );
    });

    test('toJson returns correct string', () {
      expect(TranscriptionResponseFormat.json.toJson(), 'json');
      expect(TranscriptionResponseFormat.verboseJson.toJson(), 'verbose_json');
    });
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
}
