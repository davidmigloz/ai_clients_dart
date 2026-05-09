import 'package:openai_dart/openai_dart.dart' show InfOrInt;
import 'package:openai_dart/openai_dart_realtime.dart';
import 'package:test/test.dart';

void main() {
  group('RealtimeSessionCreateRequest', () {
    test('minimal payload roundtrip omits type discriminator', () {
      const request = RealtimeSessionCreateRequest(model: 'gpt-realtime');
      final json = request.toJson();
      // The bare `/realtime/sessions` endpoint rejects unknown parameters,
      // so `type` must be omitted unless the caller (or the
      // `/realtime/client_secrets` wrapper) sets it explicitly.
      expect(json, {'model': 'gpt-realtime'});

      final parsed = RealtimeSessionCreateRequest.fromJson(json);
      expect(parsed.model, request.model);
      expect(parsed.toJson(), json);
    });

    test('explicit type discriminator is preserved on the wire', () {
      const request = RealtimeSessionCreateRequest(
        model: 'gpt-realtime',
        type: 'realtime',
      );
      expect(request.toJson(), {'type': 'realtime', 'model': 'gpt-realtime'});
    });

    test('client-secret wrapper injects the type discriminator', () {
      const wrapped = RealtimeClientSecretCreateRequest(
        session: RealtimeSessionCreateRequest(model: 'gpt-realtime-2'),
      );
      final json = wrapped.toJson();
      // The bare session does not emit `type`, but the wrapper must.
      expect((json['session'] as Map<String, dynamic>)['type'], 'realtime');
    });

    test('exhaustive payload roundtrip', () {
      // Mirrors the Python SDK
      // tests/api_resources/realtime/test_client_secrets.py
      // ::test_method_create_with_all_params fixture, minus `prompt`.
      final json = <String, dynamic>{
        'type': 'realtime',
        'model': 'gpt-realtime',
        'audio': {
          'input': {
            'format': {'type': 'audio/pcm', 'rate': 24000},
            'noise_reduction': {'type': 'near_field'},
            'transcription': {
              'delay': 'minimal',
              'language': 'en',
              'model': 'whisper-1',
              'prompt': 'expect words about the weather',
            },
            'turn_detection': {
              'type': 'server_vad',
              'create_response': true,
              'idle_timeout_ms': 5000,
              'interrupt_response': true,
              'prefix_padding_ms': 300,
              'silence_duration_ms': 500,
              'threshold': 0.5,
            },
          },
          'output': {
            'format': {'type': 'audio/pcm', 'rate': 24000},
            'speed': 0.25,
            'voice': 'alloy',
          },
        },
        'output_modalities': ['text'],
        'instructions': 'instructions',
        'tools': [
          {
            'type': 'function',
            'name': 'get_weather',
            'description': 'Get the weather',
            'parameters': {
              'type': 'object',
              'properties': {
                'location': {'type': 'string'},
              },
            },
          },
        ],
        'tool_choice': 'none',
        'max_output_tokens': 'inf',
        'parallel_tool_calls': true,
        'reasoning': {'effort': 'minimal'},
        'tracing': 'auto',
        'truncation': 'auto',
        'include': ['item.input_audio_transcription.logprobs'],
      };

      final parsed = RealtimeSessionCreateRequest.fromJson(json);
      expect(parsed.toJson(), json);

      // Spot-check a few field types to catch typos.
      expect(parsed.audio?.input?.format, const AudioPcm(rate: 24000));
      expect(
        parsed.audio?.input?.transcription?.delay,
        AudioTranscriptionDelay.minimal,
      );
      expect(
        parsed.audio?.input?.turnDetection,
        isA<ServerVad>().having((v) => v.idleTimeoutMs, 'idleTimeoutMs', 5000),
      );
      expect(parsed.maxOutputTokens, isA<InfOrInt>());
      expect(parsed.maxOutputTokens?.toJson(), 'inf');
      expect(parsed.parallelToolCalls, true);
      expect(parsed.reasoning?.effort, RealtimeReasoningEffort.minimal);
      expect(parsed.tracing, isA<TracingAuto>());
      expect(parsed.truncation, isA<TruncationAuto>());
    });

    test('format variant: AudioPcmu', () {
      const request = RealtimeSessionCreateRequest(
        model: 'gpt-realtime-2',
        audio: RealtimeAudioConfig(
          input: RealtimeAudioConfigInput(format: AudioPcmu()),
        ),
      );
      final json = request.toJson();
      expect((json['audio'] as Map)['input'], {
        'format': {'type': 'audio/pcmu'},
      });
      final parsed = RealtimeSessionCreateRequest.fromJson(json);
      expect(parsed.audio?.input?.format, const AudioPcmu());
    });

    test('format variant: AudioPcma', () {
      const request = RealtimeSessionCreateRequest(
        model: 'gpt-realtime-2',
        audio: RealtimeAudioConfig(
          output: RealtimeAudioConfigOutput(format: AudioPcma()),
        ),
      );
      final json = request.toJson();
      expect((json['audio'] as Map)['output'], {
        'format': {'type': 'audio/pcma'},
      });
      final parsed = RealtimeSessionCreateRequest.fromJson(json);
      expect(parsed.audio?.output?.format, const AudioPcma());
    });

    test('turn_detection semantic_vad variant', () {
      final json = <String, dynamic>{
        'type': 'realtime',
        'model': 'gpt-realtime-2',
        'audio': {
          'input': {
            'turn_detection': {
              'type': 'semantic_vad',
              'eagerness': 'auto',
              'interrupt_response': true,
            },
          },
        },
      };
      final parsed = RealtimeSessionCreateRequest.fromJson(json);
      expect(parsed.audio?.input?.turnDetection, isA<SemanticVad>());
      expect(parsed.toJson(), json);
    });

    test('truncation retention_ratio variant', () {
      final json = <String, dynamic>{
        'type': 'realtime',
        'model': 'gpt-realtime-2',
        'truncation': {'type': 'retention_ratio', 'retention_ratio': 0.8},
      };
      final parsed = RealtimeSessionCreateRequest.fromJson(json);
      expect(parsed.truncation, isA<TruncationRetentionRatio>());
      expect(
        (parsed.truncation! as TruncationRetentionRatio).retentionRatio,
        0.8,
      );
      expect(parsed.toJson(), json);
    });

    test('truncation retention_ratio with token_limits', () {
      final json = <String, dynamic>{
        'type': 'realtime',
        'model': 'gpt-realtime-2',
        'truncation': {
          'type': 'retention_ratio',
          'retention_ratio': 0.5,
          'token_limits': {'post_instructions': 5000},
        },
      };
      final parsed = RealtimeSessionCreateRequest.fromJson(json);
      expect(
        (parsed.truncation! as TruncationRetentionRatio)
            .postInstructionsTokenLimit,
        5000,
      );
      expect(parsed.toJson(), json);
    });

    test('truncation disabled variant', () {
      final json = <String, dynamic>{
        'type': 'realtime',
        'model': 'gpt-realtime-2',
        'truncation': 'disabled',
      };
      final parsed = RealtimeSessionCreateRequest.fromJson(json);
      expect(parsed.truncation, isA<TruncationDisabled>());
      expect(parsed.toJson(), json);
    });

    test('tracing TracingConfiguration variant', () {
      final json = <String, dynamic>{
        'type': 'realtime',
        'model': 'gpt-realtime-2',
        'tracing': {
          'group_id': 'g-123',
          'workflow_name': 'demo',
          'metadata': {'env': 'staging'},
        },
      };
      final parsed = RealtimeSessionCreateRequest.fromJson(json);
      expect(parsed.tracing, isA<TracingConfiguration>());
      final cfg = parsed.tracing! as TracingConfiguration;
      expect(cfg.groupId, 'g-123');
      expect(cfg.workflowName, 'demo');
      expect(cfg.metadata, {'env': 'staging'});
      expect(parsed.toJson(), json);
    });

    test('max_output_tokens integer variant', () {
      final json = <String, dynamic>{
        'type': 'realtime',
        'model': 'gpt-realtime-2',
        'max_output_tokens': 4096,
      };
      final parsed = RealtimeSessionCreateRequest.fromJson(json);
      expect(parsed.maxOutputTokens?.toJson(), 4096);
      expect(parsed.toJson(), json);
    });

    test('include omitted yields null and stays null on roundtrip', () {
      const request = RealtimeSessionCreateRequest(model: 'gpt-realtime-2');
      expect(request.include, isNull);
      final parsed = RealtimeSessionCreateRequest.fromJson(request.toJson());
      expect(parsed.include, isNull);
    });

    test('copyWith updates and clears nullable fields', () {
      const request = RealtimeSessionCreateRequest(
        model: 'gpt-realtime-2',
        instructions: 'be helpful',
        parallelToolCalls: true,
      );
      final updated = request.copyWith(instructions: 'be terse');
      expect(updated.instructions, 'be terse');
      expect(updated.parallelToolCalls, true);

      final cleared = request.copyWith(instructions: null);
      expect(cleared.instructions, isNull);
      expect(cleared.parallelToolCalls, true);
    });

    test('toString includes key fields', () {
      const request = RealtimeSessionCreateRequest(
        model: 'gpt-realtime-2',
        instructions: 'hi',
        parallelToolCalls: true,
      );
      final str = request.toString();
      expect(str, contains('gpt-realtime-2'));
      expect(str, contains('hi'));
      expect(str, contains('parallelToolCalls: true'));
    });
  });

  group('RealtimeSessionCreateResponse', () {
    test('response roundtrip omits client_secret', () {
      final json = <String, dynamic>{
        'id': 'sess_abc123',
        'object': 'realtime.session',
        'type': 'realtime',
        'model': 'gpt-realtime-2',
        'expires_at': 1714857600,
        'audio': {
          'output': {'voice': 'alloy'},
        },
      };
      final parsed = RealtimeSessionCreateResponse.fromJson(json);
      expect(parsed.id, 'sess_abc123');
      expect(parsed.type, 'realtime');
      expect(parsed.expiresAt, 1714857600);
      expect(parsed.audio?.output?.voice, 'alloy');

      final encoded = parsed.toJson();
      expect(encoded, json);
      // Regression guard: the response shape does not have `client_secret`
      // nested on the session object.
      expect(encoded.containsKey('client_secret'), isFalse);
    });

    test('fromJson throws FormatException on missing required fields', () {
      expect(
        () => RealtimeSessionCreateResponse.fromJson(const {
          'object': 'realtime.session',
          'type': 'realtime',
          'model': 'gpt-realtime-2',
          'expires_at': 0,
        }),
        throwsFormatException,
      );
    });
  });

  group('InputAudioTranscription', () {
    test('roundtrips delay xhigh + gpt-realtime-whisper model', () {
      const transcription = InputAudioTranscription(
        delay: AudioTranscriptionDelay.xhigh,
        model: 'gpt-realtime-whisper',
      );
      final json = transcription.toJson();
      expect(json, {'delay': 'xhigh', 'model': 'gpt-realtime-whisper'});

      final parsed = InputAudioTranscription.fromJson(json);
      expect(parsed, transcription);
    });

    test('omits null delay', () {
      const transcription = InputAudioTranscription(model: 'whisper-1');
      expect(transcription.toJson(), {'model': 'whisper-1'});

      final parsed = InputAudioTranscription.fromJson(transcription.toJson());
      expect(parsed.delay, isNull);
    });

    test('copyWith clears delay', () {
      const transcription = InputAudioTranscription(
        model: 'gpt-realtime-whisper',
        delay: AudioTranscriptionDelay.high,
      );
      final cleared = transcription.copyWith(delay: null);
      expect(cleared.delay, isNull);
      expect(cleared.model, 'gpt-realtime-whisper');
    });

    test('toString includes all fields', () {
      const transcription = InputAudioTranscription(
        delay: AudioTranscriptionDelay.medium,
        language: 'en',
        model: 'whisper-1',
        prompt: 'guidance',
      );
      final str = transcription.toString();
      expect(str, contains('medium'));
      expect(str, contains('en'));
      expect(str, contains('whisper-1'));
      expect(str, contains('guidance'));
    });
  });

  group('AudioTranscriptionDelay', () {
    test('all values roundtrip', () {
      for (final value in AudioTranscriptionDelay.values) {
        expect(AudioTranscriptionDelay.fromJson(value.toJson()), value);
      }
    });

    test('throws on unknown value', () {
      expect(
        () => AudioTranscriptionDelay.fromJson('zzz'),
        throwsFormatException,
      );
    });
  });

  group('NoiseReductionType', () {
    test('values roundtrip', () {
      expect(
        NoiseReductionType.fromJson('near_field'),
        NoiseReductionType.nearField,
      );
      expect(
        NoiseReductionType.fromJson('far_field'),
        NoiseReductionType.farField,
      );
      expect(NoiseReductionType.nearField.toJson(), 'near_field');
    });

    test('throws on unknown value', () {
      expect(
        () => NoiseReductionType.fromJson('on_axis'),
        throwsFormatException,
      );
    });
  });

  group('RealtimeToolChoice', () {
    test('string variants roundtrip', () {
      expect(
        RealtimeToolChoice.fromJson('auto'),
        const RealtimeToolChoiceAuto(),
      );
      expect(
        RealtimeToolChoice.fromJson('none'),
        const RealtimeToolChoiceNone(),
      );
      expect(
        RealtimeToolChoice.fromJson('required'),
        const RealtimeToolChoiceRequired(),
      );
      expect(const RealtimeToolChoiceAuto().toJson(), 'auto');
    });

    test('function variant roundtrips', () {
      const choice = RealtimeToolChoice.function('get_weather');
      final json = choice.toJson();
      expect(json, {
        'type': 'function',
        'function': {'name': 'get_weather'},
      });
      expect(
        RealtimeToolChoice.fromJson(json),
        const RealtimeToolChoiceFunction('get_weather'),
      );
    });

    test('throws on invalid payload', () {
      expect(() => RealtimeToolChoice.fromJson(42), throwsFormatException);
    });
  });

  group('RealtimeAudioConfigInput tri-state serialization', () {
    test('omits keys when fields are null and clear flags are false', () {
      const input = RealtimeAudioConfigInput();
      expect(input.toJson(), isEmpty);
    });

    test('emits explicit JSON null when clear flag is true', () {
      const input = RealtimeAudioConfigInput(
        clearNoiseReduction: true,
        clearTranscription: true,
        clearTurnDetection: true,
      );
      final json = input.toJson();
      expect(json, containsPair('noise_reduction', null));
      expect(json, containsPair('transcription', null));
      expect(json, containsPair('turn_detection', null));
    });

    test('value wins over clear flag', () {
      const input = RealtimeAudioConfigInput(
        transcription: InputAudioTranscription(model: 'whisper-1'),
        clearTranscription: true,
      );
      final json = input.toJson();
      expect(json['transcription'], isA<Map<String, dynamic>>());
    });

    test('roundtrips explicit JSON null back to clear flag = true', () {
      final json = <String, dynamic>{
        'noise_reduction': null,
        'transcription': null,
        'turn_detection': null,
      };
      final parsed = RealtimeAudioConfigInput.fromJson(json);
      expect(parsed.noiseReduction, isNull);
      expect(parsed.transcription, isNull);
      expect(parsed.turnDetection, isNull);
      expect(parsed.clearNoiseReduction, isTrue);
      expect(parsed.clearTranscription, isTrue);
      expect(parsed.clearTurnDetection, isTrue);
      // Round-trip shape preserved.
      expect(parsed.toJson(), equals(json));
    });

    test('absent keys parse with clear flag = false', () {
      final parsed = RealtimeAudioConfigInput.fromJson(const {});
      expect(parsed.clearNoiseReduction, isFalse);
      expect(parsed.clearTranscription, isFalse);
      expect(parsed.clearTurnDetection, isFalse);
    });
  });

  group('Sealed Unknown-variant fallbacks', () {
    test(
      'RealtimeEvent.fromJson unrecognised type roundtrips through Unknown',
      () {
        final json = <String, dynamic>{
          'type': 'session.future_event',
          'event_id': 'evt_123',
          'extra': <String, dynamic>{'nested': true},
        };
        final parsed = RealtimeEvent.fromJson(json);
        expect(parsed, isA<UnknownRealtimeEvent>());
        expect(parsed.type, 'session.future_event');
        expect(parsed.eventId, 'evt_123');
        // Round-trip preserves unknown keys including nested maps.
        expect(parsed.toJson(), equals(json));

        // Equality is content-based and deep.
        final twin = RealtimeEvent.fromJson(<String, dynamic>{
          'type': 'session.future_event',
          'event_id': 'evt_123',
          'extra': <String, dynamic>{'nested': true},
        });
        expect(parsed, equals(twin));
        expect(parsed.hashCode, twin.hashCode);
      },
    );

    test('RealtimeAudioInputTurnDetection.fromJson unknown discriminator '
        'roundtrips', () {
      final json = <String, dynamic>{
        'type': 'experimental_vad',
        'threshold': 0.7,
      };
      final parsed = RealtimeAudioInputTurnDetection.fromJson(json);
      expect(parsed, isA<UnknownRealtimeAudioInputTurnDetection>());
      expect(parsed.type, 'experimental_vad');
      expect(parsed.toJson(), equals(json));

      // Deep equality + hash consistency.
      final twin = RealtimeAudioInputTurnDetection.fromJson(<String, dynamic>{
        'type': 'experimental_vad',
        'threshold': 0.7,
      });
      expect(parsed, equals(twin));
      expect(parsed.hashCode, twin.hashCode);
    });

    test('RealtimeTracingConfig.fromJson non-map non-auto value yields '
        'UnknownRealtimeTracingConfig', () {
      // Maps always parse into [TracingConfiguration] (any keys are valid
      // — they're all optional). The Unknown fallback only triggers for
      // non-map values that aren't the literal `'auto'` string, e.g. if
      // a future spec allows `'enabled'`/`'disabled'` strings.
      final parsed = RealtimeTracingConfig.fromJson('enabled');
      expect(parsed, isA<UnknownRealtimeTracingConfig>());
      expect(parsed.toJson(), equals('enabled'));
    });

    test('RealtimeTruncation.fromJson unknown discriminator roundtrips', () {
      final json = <String, dynamic>{
        'type': 'experimental',
        'config': <String, dynamic>{'mode': 'aggressive'},
      };
      final parsed = RealtimeTruncation.fromJson(json);
      expect(parsed, isA<UnknownRealtimeTruncation>());
      expect(parsed.toJson(), equals(json));

      // Deep-equality semantics on nested maps.
      final twin = RealtimeTruncation.fromJson(<String, dynamic>{
        'type': 'experimental',
        'config': <String, dynamic>{'mode': 'aggressive'},
      });
      expect(parsed, equals(twin));
      expect(parsed.hashCode, twin.hashCode);
    });
  });
}
