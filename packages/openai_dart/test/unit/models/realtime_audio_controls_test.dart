import 'package:openai_dart/openai_dart_realtime.dart';
import 'package:test/test.dart';

void main() {
  group('Realtime noise reduction strength', () {
    for (final strength in [0, 0.25, 1]) {
      test('accepts $strength without replacing or rounding it', () {
        final json = {'type': 'near_field', 'strength': strength};
        final realtime = AudioInputNoiseReduction.fromJson(json);
        final translation = RealtimeTranslationNoiseReduction.fromJson(json);
        expect(realtime.strength, strength);
        expect(translation.strength, strength);
        expect(realtime.toJson(), json);
        expect(translation.toJson(), json);
        expect(realtime.copyWith(), realtime);
        expect(realtime.copyWith().hashCode, realtime.hashCode);
        expect(translation.copyWith(), translation);
        expect(translation.copyWith().hashCode, translation.hashCode);
      });
    }

    for (final value in [
      null,
      '0.5',
      true,
      <Object?>[],
      <String, Object?>{},
      -0.001,
      1.001,
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      test('rejects malformed/out-of-range strength ${value.runtimeType}', () {
        final json = {'type': 'near_field', 'strength': value};
        expect(
          () => AudioInputNoiseReduction.fromJson(json),
          throwsFormatException,
        );
        expect(
          () => RealtimeTranslationNoiseReduction.fromJson(json),
          throwsFormatException,
        );
      });
    }

    test('omission never invents the first-enable default', () {
      const realtime = AudioInputNoiseReduction();
      const translation = RealtimeTranslationNoiseReduction(
        type: NoiseReductionType.nearField,
      );
      expect(realtime.toJson(), isEmpty);
      expect(translation.toJson(), {'type': 'near_field'});
      expect(AudioInputNoiseReduction.fromJson(const {}).toJson(), isEmpty);
      expect(realtime.copyWith().strength, isNull);
      expect(translation.copyWith().strength, isNull);
    });

    test('copy preserves, replaces, and explicitly omits strength', () {
      const realtime = AudioInputNoiseReduction(strength: 0.3);
      const translation = RealtimeTranslationNoiseReduction(
        type: NoiseReductionType.farField,
        strength: 0.3,
      );
      expect(realtime.copyWith().strength, 0.3);
      expect(realtime.copyWith(strength: 1).strength, 1);
      expect(realtime.copyWith(clearStrength: true).toJson(), isEmpty);
      expect(translation.copyWith().strength, 0.3);
      expect(translation.copyWith(strength: 0).strength, 0);
      expect(translation.copyWith(clearStrength: true).toJson(), {
        'type': 'far_field',
      });
      expect(realtime, isNot(realtime.copyWith(strength: 0.5)));
      expect(translation, isNot(translation.copyWith(strength: 0.5)));
      expect(realtime.toString(), contains('0.3'));
      expect(translation.toString(), contains('0.3'));
      for (final value in [null, -1, 2, double.nan, '0.5']) {
        expect(() => realtime.copyWith(strength: value), throwsFormatException);
        expect(
          () => translation.copyWith(strength: value),
          throwsFormatException,
        );
      }
      expect(
        () => realtime.copyWith(strength: 1, clearStrength: true),
        throwsFormatException,
      );
      expect(
        () => translation.copyWith(strength: 1, clearStrength: true),
        throwsFormatException,
      );
    });

    test('GA type remains optional while translation type is required', () {
      expect(
        AudioInputNoiseReduction.fromJson(const {'strength': 0.4}).toJson(),
        {'strength': 0.4},
      );
      for (final json in [
        {'strength': 0.4},
        {'type': null, 'strength': 0.4},
      ]) {
        expect(
          () => RealtimeTranslationNoiseReduction.fromJson(json),
          throwsFormatException,
        );
      }
    });

    test('nested update preserves absent, configured and disabled states', () {
      const omitted = RealtimeAudioConfigInput();
      const configured = RealtimeAudioConfigInput(
        noiseReduction: AudioInputNoiseReduction(strength: 0.6),
      );
      const disabled = RealtimeAudioConfigInput(clearNoiseReduction: true);
      for (final input in [omitted, configured, disabled]) {
        final json = input.toJson();
        expect(RealtimeAudioConfigInput.fromJson(json), input);
      }
      expect(omitted.toJson(), isEmpty);
      expect(configured.toJson(), {
        'noise_reduction': {'strength': 0.6},
      });
      expect(disabled.toJson(), {'noise_reduction': null});
      expect(
        configured
            .copyWith(
              noiseReduction: configured.noiseReduction!.copyWith(
                clearStrength: true,
              ),
            )
            .toJson(),
        {'noise_reduction': <String, dynamic>{}},
      );

      const translation = RealtimeTranslationSessionAudioInput(
        noiseReduction: RealtimeTranslationNoiseReduction(
          type: NoiseReductionType.farField,
          strength: 0.6,
        ),
      );
      const update = RealtimeTranslationSessionUpdateRequest(
        audio: RealtimeTranslationSessionAudio(input: translation),
      );
      expect(
        RealtimeTranslationSessionUpdateRequest.fromJson(update.toJson()),
        update,
      );
      expect(
        const RealtimeTranslationSessionAudioInput(
          clearNoiseReduction: true,
        ).toJson(),
        {'noise_reduction': null},
      );
      expect(const RealtimeTranslationSessionAudioInput().toJson(), isEmpty);
    });

    test(
      'GA session and transcription create/receive share the exact leaf',
      () {
        final audio = <String, dynamic>{
          'input': {
            'noise_reduction': {'type': 'near_field', 'strength': 0.7},
            'transcription': {
              'model': 'future-transcribe-model',
              'keywords': ['OpenAI', 'café'],
            },
          },
        };
        final realtime = {'model': 'gpt-realtime-2.1-mini', 'audio': audio};
        expect(
          RealtimeSessionCreateRequest.fromJson(realtime).toJson(),
          realtime,
        );
        final received = {
          'id': 'session-one',
          'object': 'realtime.session',
          'type': 'realtime',
          ...realtime,
        };
        expect(
          RealtimeSessionCreateResponse.fromJson(received).toJson(),
          received,
        );
        expect(RealtimeSession.fromJson(received).toJson(), received);
        final transcription = {'audio': audio};
        expect(
          RealtimeTranscriptionSessionCreateRequest.fromJson(
            transcription,
          ).toJson(),
          transcription,
        );
        final transcriptionReceived = {
          'id': 'transcription-one',
          'object': 'realtime.transcription_session',
          'type': 'transcription',
          'expires_at': 100,
          ...transcription,
        };
        final parsed = RealtimeTranscriptionSessionCreateResponse.fromJson(
          transcriptionReceived,
        );
        expect(parsed.toJson(), transcriptionReceived);
        expect(parsed.audio!.input!.transcription!.keywords, [
          'OpenAI',
          'café',
        ]);
        expect(
          parsed.audio!.input!.transcription!.model,
          'future-transcribe-model',
        );
        expect(
          InputAudioTranscription.fromJson(const {
            'keywords': <String>[],
          }).toJson(),
          {'keywords': <String>[]},
        );
        expect(const InputAudioTranscription().toJson(), isEmpty);
      },
    );

    test(
      'translation create, update and returned session preserve strength',
      () {
        final audio = {
          'input': {
            'noise_reduction': {'type': 'far_field', 'strength': 0.8},
          },
        };
        final create = {'model': 'gpt-realtime-translate', 'audio': audio};
        expect(
          RealtimeTranslationSessionCreateRequest.fromJson(create).toJson(),
          create,
        );
        expect(
          RealtimeTranslationSessionUpdateRequest.fromJson({
            'audio': audio,
          }).toJson(),
          {'audio': audio},
        );
        final received = {
          'id': 'translation-one',
          'type': 'translation',
          'expires_at': 100,
          ...create,
        };
        expect(
          RealtimeTranslationSession.fromJson(received).toJson(),
          received,
        );
      },
    );
  });

  group('Realtime output audio voice union', () {
    test('existing strings and typed named selections are wire equivalent', () {
      const existing = RealtimeAudioConfigOutput(voice: 'future-named-voice');
      const typed = RealtimeAudioConfigOutput(
        voiceSelection: AudioVoice.named('future-named-voice'),
      );
      expect(existing.toJson(), {'voice': 'future-named-voice'});
      expect(
        RealtimeAudioConfigOutput.fromJson(existing.toJson()).voice,
        'future-named-voice',
      );
      expect(typed, existing);
      expect(typed.hashCode, existing.hashCode);
    });

    test('custom voice roundtrip and copy retain an opaque ID reference', () {
      const output = RealtimeAudioConfigOutput(
        voiceSelection: AudioVoice.custom('voice-private-id'),
      );
      final wire = {
        'voice': {'id': 'voice-private-id'},
      };
      expect(output.toJson(), wire);
      expect(RealtimeAudioConfigOutput.fromJson(wire), output);
      expect(output.copyWith(), output);
      expect(output.copyWith().hashCode, output.hashCode);
      expect(output.copyWith(voiceSelection: null).toJson(), isEmpty);
      expect(output.copyWith(voiceSelection: null, voice: 'cedar').toJson(), {
        'voice': 'cedar',
      });
      expect(output.toString(), isNot(contains('voice-private-id')));
      expect(output.toString(), contains('voiceSelection: [REDACTED]'));
      expect(
        const RealtimeAudioConfigOutput().toString(),
        contains('voiceSelection: absent'),
      );
      const named = RealtimeAudioConfigOutput(voice: 'cedar');
      expect(
        named.copyWith(
          voice: null,
          voiceSelection: const AudioVoice.custom('voice-private-id'),
        ),
        output,
      );
    });

    for (final value in [
      null,
      1,
      <Object?>[],
      <String, Object?>{},
      {'id': null},
      {'id': 3},
      {'id': 'voice-id', 'type': 'custom'},
    ]) {
      test('rejects malformed custom voice ${value.runtimeType}', () {
        expect(
          () => RealtimeAudioConfigOutput.fromJson({'voice': value}),
          throwsFormatException,
        );
      });
    }

    test(
      'validates caller-defined voice implementations before serialization',
      () {
        const output = RealtimeAudioConfigOutput(
          voiceSelection: _InvalidVoice(),
        );
        expect(output.toJson, throwsFormatException);
      },
    );
  });
}

final class _InvalidVoice implements AudioVoice {
  const _InvalidVoice();

  @override
  Object toJson() => {'id': 'private', 'extra': true};
}
