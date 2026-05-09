import 'package:openai_dart/openai_dart_realtime.dart';
import 'package:test/test.dart';

void main() {
  group('RealtimeTranslationClientSecretCreateRequest', () {
    test('roundtrips spec example payload', () {
      final json = <String, dynamic>{
        'expires_after': {'anchor': 'created_at', 'seconds': 600},
        'session': {
          'model': 'gpt-realtime-translate',
          'audio': {
            'input': {
              'transcription': {'model': 'gpt-realtime-whisper'},
            },
            'output': {'language': 'es'},
          },
        },
      };

      final parsed = RealtimeTranslationClientSecretCreateRequest.fromJson(
        json,
      );
      expect(parsed.session.model, 'gpt-realtime-translate');
      expect(
        parsed.session.audio?.input?.transcription?.model,
        'gpt-realtime-whisper',
      );
      expect(parsed.session.audio?.output?.language, 'es');
      expect(parsed.expiresAfter?.seconds, 600);

      expect(parsed.toJson(), json);
    });

    test('fromJson throws on missing required session', () {
      expect(
        () => RealtimeTranslationClientSecretCreateRequest.fromJson(const {}),
        throwsFormatException,
      );
    });
  });

  group('RealtimeTranslationClientSecretCreateResponse', () {
    test('roundtrips spec example payload', () {
      final json = <String, dynamic>{
        'value': 'ek_68af296e8e408191a1120ab6383263c2',
        'expires_at': 1756310470,
        'session': {
          'id': 'sess_C9CiUVUzUzYIssh3ELY1d',
          'type': 'translation',
          'expires_at': 1756310470,
          'model': 'gpt-realtime-translate',
          'audio': {
            'input': <String, dynamic>{},
            'output': {'language': 'es'},
          },
        },
      };

      final parsed = RealtimeTranslationClientSecretCreateResponse.fromJson(
        json,
      );
      expect(parsed.value.startsWith('ek_'), isTrue);
      expect(parsed.expiresAt, 1756310470);
      expect(parsed.session.id, 'sess_C9CiUVUzUzYIssh3ELY1d');
      expect(parsed.session.type, 'translation');

      expect(parsed.toJson(), json);
    });
  });

  group('RealtimeTranslationClientEvent variants', () {
    test('session.update roundtrips', () {
      final json = <String, dynamic>{
        'type': 'session.update',
        'session': {
          'audio': {
            'input': {
              'transcription': {'model': 'gpt-realtime-whisper'},
            },
            'output': {'language': 'es'},
          },
        },
      };
      final parsed = RealtimeTranslationClientEvent.fromJson(json);
      expect(parsed, isA<RealtimeTranslationSessionUpdateEvent>());
      expect(parsed.toJson(), json);
    });

    test('session.input_audio_buffer.append roundtrips', () {
      final json = <String, dynamic>{
        'type': 'session.input_audio_buffer.append',
        'audio': 'BASE64AUDIO',
        'event_id': 'evt_1',
      };
      final parsed = RealtimeTranslationClientEvent.fromJson(json);
      expect(parsed, isA<RealtimeTranslationInputAudioBufferAppendEvent>());
      expect(parsed.eventId, 'evt_1');
      expect(parsed.toJson(), json);
    });

    test('session.close roundtrips', () {
      final json = <String, dynamic>{
        'type': 'session.close',
        'event_id': 'evt_close',
      };
      final parsed = RealtimeTranslationClientEvent.fromJson(json);
      expect(parsed, isA<RealtimeTranslationSessionCloseEvent>());
      expect(parsed.eventId, 'evt_close');
      expect(parsed.toJson(), json);
    });

    test('unknown discriminator yields Unknown variant', () {
      final json = <String, dynamic>{
        'type': 'session.future',
        'event_id': 'evt_zz',
        'extra': 'preserved',
      };
      final parsed = RealtimeTranslationClientEvent.fromJson(json);
      expect(parsed, isA<UnknownRealtimeTranslationClientEvent>());
      expect(parsed.toJson(), json);
    });
  });

  group('RealtimeTranslationServerEvent variants', () {
    test('error roundtrips', () {
      final json = <String, dynamic>{
        'type': 'error',
        'event_id': 'evt_err',
        'error': {'type': 'invalid_request_error', 'message': 'bad input'},
      };
      final parsed = RealtimeTranslationServerEvent.fromJson(json);
      expect(parsed, isA<RealtimeTranslationErrorEvent>());
      expect(parsed.toJson(), json);
    });

    test('session.created roundtrips', () {
      final json = <String, dynamic>{
        'type': 'session.created',
        'event_id': 'evt_1',
        'session': {
          'id': 'sess_x',
          'type': 'translation',
          'expires_at': 1714857600,
          'model': 'gpt-realtime-translate',
          'audio': {
            'input': {
              'transcription': {'model': 'gpt-realtime-whisper'},
            },
            'output': {'language': 'fr'},
          },
        },
      };
      final parsed = RealtimeTranslationServerEvent.fromJson(json);
      expect(parsed, isA<RealtimeTranslationSessionCreatedEvent>());
      expect(parsed.toJson(), json);
    });

    test('session.updated roundtrips', () {
      final json = <String, dynamic>{
        'type': 'session.updated',
        'event_id': 'evt_2',
        'session': {
          'id': 'sess_x',
          'type': 'translation',
          'expires_at': 1714857600,
          'model': 'gpt-realtime-translate',
          'audio': {
            'input': <String, dynamic>{},
            'output': {'language': 'es'},
          },
        },
      };
      final parsed = RealtimeTranslationServerEvent.fromJson(json);
      expect(parsed, isA<RealtimeTranslationSessionUpdatedEvent>());
      expect(parsed.toJson(), json);
    });

    test('session.closed roundtrips', () {
      final json = <String, dynamic>{
        'type': 'session.closed',
        'event_id': 'evt_close',
      };
      final parsed = RealtimeTranslationServerEvent.fromJson(json);
      expect(parsed, isA<RealtimeTranslationSessionClosedEvent>());
      expect(parsed.toJson(), json);
    });

    test('session.input_transcript.delta roundtrips', () {
      final json = <String, dynamic>{
        'type': 'session.input_transcript.delta',
        'event_id': 'evt_3',
        'delta': ' hear',
        'elapsed_ms': 1200,
      };
      final parsed = RealtimeTranslationServerEvent.fromJson(json);
      expect(parsed, isA<RealtimeTranslationInputTranscriptDeltaEvent>());
      expect(parsed.toJson(), json);
    });

    test('session.output_transcript.delta roundtrips', () {
      final json = <String, dynamic>{
        'type': 'session.output_transcript.delta',
        'event_id': 'evt_4',
        'delta': ' escuch',
        'elapsed_ms': 1200,
      };
      final parsed = RealtimeTranslationServerEvent.fromJson(json);
      expect(parsed, isA<RealtimeTranslationOutputTranscriptDeltaEvent>());
      expect(parsed.toJson(), json);
    });

    test('session.output_audio.delta roundtrips with base64 payload', () {
      final json = <String, dynamic>{
        'type': 'session.output_audio.delta',
        'event_id': 'evt_5',
        'delta': 'Base64EncodedAudioDelta',
        'sample_rate': 24000,
        'channels': 1,
        'format': 'pcm16',
      };
      final parsed = RealtimeTranslationServerEvent.fromJson(json);
      expect(parsed, isA<RealtimeTranslationOutputAudioDeltaEvent>());
      final delta = parsed as RealtimeTranslationOutputAudioDeltaEvent;
      expect(delta.delta, 'Base64EncodedAudioDelta');
      expect(parsed.toJson(), json);
    });

    test('discriminator dispatch returns the correct subclass', () {
      final cases = <String, Type>{
        'error': RealtimeTranslationErrorEvent,
        'session.created': RealtimeTranslationSessionCreatedEvent,
        'session.updated': RealtimeTranslationSessionUpdatedEvent,
        'session.closed': RealtimeTranslationSessionClosedEvent,
        'session.input_transcript.delta':
            RealtimeTranslationInputTranscriptDeltaEvent,
        'session.output_transcript.delta':
            RealtimeTranslationOutputTranscriptDeltaEvent,
        'session.output_audio.delta': RealtimeTranslationOutputAudioDeltaEvent,
      };
      for (final entry in cases.entries) {
        final json = <String, dynamic>{
          'type': entry.key,
          'event_id': 'evt',
          if (entry.key.contains('transcript.delta')) 'delta': '',
          if (entry.key == 'session.output_audio.delta') 'delta': '',
          if (entry.key == 'error') 'error': {'type': 't', 'message': 'm'},
          if (entry.key.startsWith('session.created') ||
              entry.key.startsWith('session.updated'))
            'session': {
              'id': 's',
              'type': 'translation',
              'expires_at': 0,
              'model': 'gpt-realtime-translate',
              'audio': <String, dynamic>{
                'input': <String, dynamic>{},
                'output': <String, dynamic>{},
              },
            },
        };
        final parsed = RealtimeTranslationServerEvent.fromJson(json);
        expect(
          parsed.runtimeType,
          entry.value,
          reason: 'for type ${entry.key}',
        );
      }
    });

    test('unknown discriminator yields Unknown variant', () {
      final json = <String, dynamic>{
        'type': 'session.future',
        'event_id': 'evt_zz',
      };
      final parsed = RealtimeTranslationServerEvent.fromJson(json);
      expect(parsed, isA<UnknownRealtimeTranslationServerEvent>());
      expect(parsed.toJson(), json);
    });
  });
}
