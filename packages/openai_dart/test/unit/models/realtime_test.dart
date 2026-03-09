import 'package:openai_dart/openai_dart.dart' show InfOrIntInf, InfOrIntValue;
import 'package:openai_dart/openai_dart_realtime.dart';
import 'package:test/test.dart';

void main() {
  group('RealtimeVoice', () {
    test('fromJson parses all values', () {
      expect(RealtimeVoice.fromJson('alloy'), RealtimeVoice.alloy);
      expect(RealtimeVoice.fromJson('ash'), RealtimeVoice.ash);
      expect(RealtimeVoice.fromJson('ballad'), RealtimeVoice.ballad);
      expect(RealtimeVoice.fromJson('coral'), RealtimeVoice.coral);
      expect(RealtimeVoice.fromJson('echo'), RealtimeVoice.echo);
      expect(RealtimeVoice.fromJson('sage'), RealtimeVoice.sage);
      expect(RealtimeVoice.fromJson('shimmer'), RealtimeVoice.shimmer);
      expect(RealtimeVoice.fromJson('verse'), RealtimeVoice.verse);
    });

    test('toJson returns correct string', () {
      expect(RealtimeVoice.alloy.toJson(), 'alloy');
      expect(RealtimeVoice.shimmer.toJson(), 'shimmer');
    });

    test('fromJson throws on unknown value', () {
      expect(() => RealtimeVoice.fromJson('unknown'), throwsFormatException);
    });
  });

  group('RealtimeAudioFormat', () {
    test('fromJson parses all values', () {
      expect(RealtimeAudioFormat.fromJson('pcm16'), RealtimeAudioFormat.pcm16);
      expect(
        RealtimeAudioFormat.fromJson('g711_ulaw'),
        RealtimeAudioFormat.g711Ulaw,
      );
      expect(
        RealtimeAudioFormat.fromJson('g711_alaw'),
        RealtimeAudioFormat.g711Alaw,
      );
    });

    test('toJson returns correct string', () {
      expect(RealtimeAudioFormat.pcm16.toJson(), 'pcm16');
      expect(RealtimeAudioFormat.g711Ulaw.toJson(), 'g711_ulaw');
    });
  });

  group('TurnDetectionType', () {
    test('fromJson parses all values', () {
      expect(
        TurnDetectionType.fromJson('server_vad'),
        TurnDetectionType.serverVad,
      );
      expect(TurnDetectionType.fromJson('none'), TurnDetectionType.none);
    });

    test('toJson returns correct string', () {
      expect(TurnDetectionType.serverVad.toJson(), 'server_vad');
      expect(TurnDetectionType.none.toJson(), 'none');
    });
  });

  group('RealtimeToolChoice', () {
    test('auto() creates auto choice', () {
      const choice = RealtimeToolChoice.auto();
      expect(choice, isA<RealtimeToolChoiceAuto>());
      expect(choice.toJson(), 'auto');
    });

    test('none() creates none choice', () {
      const choice = RealtimeToolChoice.none();
      expect(choice, isA<RealtimeToolChoiceNone>());
      expect(choice.toJson(), 'none');
    });

    test('required() creates required choice', () {
      const choice = RealtimeToolChoice.required();
      expect(choice, isA<RealtimeToolChoiceRequired>());
      expect(choice.toJson(), 'required');
    });

    test('function() creates function choice', () {
      const choice = RealtimeToolChoice.function('get_weather');
      expect(choice, isA<RealtimeToolChoiceFunction>());
      expect(choice.toJson(), {
        'type': 'function',
        'function': {'name': 'get_weather'},
      });
    });

    test('fromJson parses string choices', () {
      expect(
        RealtimeToolChoice.fromJson('auto'),
        isA<RealtimeToolChoiceAuto>(),
      );
      expect(
        RealtimeToolChoice.fromJson('none'),
        isA<RealtimeToolChoiceNone>(),
      );
      expect(
        RealtimeToolChoice.fromJson('required'),
        isA<RealtimeToolChoiceRequired>(),
      );
    });

    test('fromJson parses function choice', () {
      final choice = RealtimeToolChoice.fromJson({
        'type': 'function',
        'function': {'name': 'my_func'},
      });
      expect(choice, isA<RealtimeToolChoiceFunction>());
      expect((choice as RealtimeToolChoiceFunction).name, 'my_func');
    });

    test('equality works correctly', () {
      expect(
        const RealtimeToolChoiceAuto(),
        equals(const RealtimeToolChoiceAuto()),
      );
      expect(
        const RealtimeToolChoiceFunction('test'),
        equals(const RealtimeToolChoiceFunction('test')),
      );
      expect(
        const RealtimeToolChoiceFunction('a'),
        isNot(equals(const RealtimeToolChoiceFunction('b'))),
      );
    });
  });

  group('RealtimeSession', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'sess_abc123',
        'object': 'realtime.session',
        'model': 'gpt-realtime-1.5',
        'modalities': ['text', 'audio'],
        'instructions': 'You are a helpful assistant.',
        'voice': 'alloy',
        'input_audio_format': 'pcm16',
        'output_audio_format': 'pcm16',
        'turn_detection': {
          'type': 'server_vad',
          'threshold': 0.5,
          'prefix_padding_ms': 300,
          'silence_duration_ms': 500,
        },
        'tool_choice': 'auto',
        'temperature': 0.7,
        'max_response_output_tokens': 'inf',
      };

      final session = RealtimeSession.fromJson(json);

      expect(session.id, 'sess_abc123');
      expect(session.model, 'gpt-realtime-1.5');
      expect(session.modalities, ['text', 'audio']);
      expect(session.voice, RealtimeVoice.alloy);
      expect(session.inputAudioFormat, RealtimeAudioFormat.pcm16);
      expect(session.outputAudioFormat, RealtimeAudioFormat.pcm16);
      expect(session.turnDetection?.type, TurnDetectionType.serverVad);
      expect(session.turnDetection?.threshold, 0.5);
      expect(session.toolChoice, isA<RealtimeToolChoiceAuto>());
      expect(session.temperature, 0.7);
      expect(session.maxResponseOutputTokens, isA<InfOrIntInf>());
    });

    test('fromJson parses numeric max tokens', () {
      final json = {
        'id': 'sess_abc123',
        'object': 'realtime.session',
        'model': 'gpt-realtime-1.5',
        'max_response_output_tokens': 4096,
      };

      final session = RealtimeSession.fromJson(json);

      expect(session.maxResponseOutputTokens, isA<InfOrIntValue>());
      expect((session.maxResponseOutputTokens! as InfOrIntValue).value, 4096);
    });

    test('toJson serializes correctly', () {
      const session = RealtimeSession(
        id: 'sess_abc123',
        object: 'realtime.session',
        model: 'gpt-realtime-1.5',
        voice: RealtimeVoice.shimmer,
        inputAudioFormat: RealtimeAudioFormat.g711Ulaw,
        toolChoice: RealtimeToolChoiceRequired(),
        maxResponseOutputTokens: InfOrIntValue(2048),
      );

      final json = session.toJson();

      expect(json['id'], 'sess_abc123');
      expect(json['voice'], 'shimmer');
      expect(json['input_audio_format'], 'g711_ulaw');
      expect(json['tool_choice'], 'required');
      expect(json['max_response_output_tokens'], 2048);
    });
  });

  group('SessionUpdateConfig', () {
    test('fromJson parses correctly', () {
      final json = {
        'voice': 'coral',
        'temperature': 0.8,
        'tool_choice': 'none',
        'max_response_output_tokens': 'inf',
      };

      final config = SessionUpdateConfig.fromJson(json);

      expect(config.voice, RealtimeVoice.coral);
      expect(config.temperature, 0.8);
      expect(config.toolChoice, isA<RealtimeToolChoiceNone>());
      expect(config.maxResponseOutputTokens, isA<InfOrIntInf>());
    });

    test('toJson serializes correctly', () {
      const config = SessionUpdateConfig(
        voice: RealtimeVoice.sage,
        toolChoice: RealtimeToolChoiceFunction('search'),
        maxResponseOutputTokens: InfOrIntInf(),
      );

      final json = config.toJson();

      expect(json['voice'], 'sage');
      expect(json['tool_choice'], {
        'type': 'function',
        'function': {'name': 'search'},
      });
      expect(json['max_response_output_tokens'], 'inf');
    });
  });

  group('TurnDetection', () {
    test('fromJson parses correctly', () {
      final json = {
        'type': 'server_vad',
        'threshold': 0.5,
        'prefix_padding_ms': 300,
        'silence_duration_ms': 500,
        'create_response': true,
      };

      final detection = TurnDetection.fromJson(json);

      expect(detection.type, TurnDetectionType.serverVad);
      expect(detection.threshold, 0.5);
      expect(detection.prefixPaddingMs, 300);
      expect(detection.silenceDurationMs, 500);
      expect(detection.createResponse, isTrue);
    });

    test('toJson serializes correctly', () {
      const detection = TurnDetection(
        type: TurnDetectionType.serverVad,
        threshold: 0.6,
      );

      final json = detection.toJson();

      expect(json['type'], 'server_vad');
      expect(json['threshold'], 0.6);
    });
  });
}
