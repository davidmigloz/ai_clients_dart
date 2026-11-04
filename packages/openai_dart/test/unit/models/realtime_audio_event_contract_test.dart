import 'package:openai_dart/openai_dart_realtime.dart';
import 'package:test/test.dart';

void main() {
  const type = 'conversation.item.input_audio_transcription.delta';
  const requiredFields = {'type': type, 'event_id': 'e1', 'item_id': 'i1'};
  group('transcription delta native fields', () {
    test(
      'optional nonnullable fields may be omitted with no invented defaults',
      () {
        final event =
            RealtimeEvent.fromJson(requiredFields)
                as InputAudioTranscriptionDeltaEvent;
        expect(event.contentIndex, isNull);
        expect(event.delta, isNull);
        expect(event.hasLogprobs, isFalse);
        expect(event.toJson(), requiredFields);
        for (final field in ['content_index', 'delta']) {
          expect(
            () => RealtimeEvent.fromJson({...requiredFields, field: null}),
            throwsFormatException,
          );
        }
        expect(
          () =>
              RealtimeEvent.fromJson({...requiredFields, 'content_index': 0.5}),
          throwsFormatException,
        );
        expect(
          () => RealtimeEvent.fromJson({...requiredFields, 'delta': 1}),
          throwsFormatException,
        );
      },
    );

    test(
      'logprobs retain omitted, nullable, empty and populated wire forms',
      () {
        for (final value in [
          null,
          <Object?>[],
          [
            {'token': '', 'logprob': 0, 'bytes': <int>[]},
            {
              'token': 'hello',
              'logprob': -0.5,
              'bytes': [104, 105],
            },
          ],
        ]) {
          final json = {
            ...requiredFields,
            'content_index': 0,
            'delta': '',
            'logprobs': value,
            'obfuscation': 'random',
          };
          final event =
              RealtimeEvent.fromJson(json) as InputAudioTranscriptionDeltaEvent;
          expect(event.hasLogprobs, isTrue);
          expect(event.toJson(), json);
          expect(event.copyWith(), event);
          expect(event.copyWith().hashCode, event.hashCode);
          expect(
            event
                .copyWith(clearLogprobs: true)
                .toJson()
                .containsKey('logprobs'),
            isFalse,
          );
        }
        final plain = InputAudioTranscriptionDeltaEvent.fromJson(
          requiredFields,
        );
        expect(
          plain.copyWith(logprobs: null).toJson().containsKey('logprobs'),
          isTrue,
        );
        expect(plain.copyWith(logprobs: null), isNot(plain));
      },
    );

    test(
      'token logprobs reject missing, nullable, nonfinite and fractional bytes',
      () {
        final good = {
          'token': 't',
          'logprob': -1.0,
          'bytes': [1],
        };
        for (final field in good.keys) {
          expect(
            () =>
                RealtimeTranscriptionLogprob.fromJson({...good}..remove(field)),
            throwsFormatException,
          );
          expect(
            () => RealtimeTranscriptionLogprob.fromJson({...good, field: null}),
            throwsFormatException,
          );
        }
        for (final invalid in <Map<String, dynamic>>[
          {...good, 'token': 1},
          {...good, 'logprob': double.nan},
          {...good, 'logprob': double.infinity},
          {
            ...good,
            'bytes': [1.5],
          },
          {
            ...good,
            'bytes': ['1'],
          },
          {
            ...good,
            'bytes': [null],
          },
        ]) {
          expect(
            () => RealtimeTranscriptionLogprob.fromJson(invalid),
            throwsFormatException,
          );
        }
        expect(
          RealtimeTranscriptionLogprob(
            token: '',
            logprob: -1,
            bytes: const [-1, 256],
          ).bytes,
          [-1, 256],
        );
        expect(
          () => RealtimeTranscriptionLogprob(
            token: '',
            logprob: double.nan,
            bytes: const [],
          ),
          throwsFormatException,
        );
        expect(
          () => RealtimeEvent.fromJson({
            ...requiredFields,
            'logprobs': <String, Object?>{},
          }),
          throwsFormatException,
        );
      },
    );

    test(
      'typed fields control copied raw data and snapshots remain immutable',
      () {
        const private = 'PRIVATE_TRANSCRIPT';
        final tokenJson = <String, dynamic>{
          'token': private,
          'logprob': -2,
          'bytes': [1, 2],
          'future': {
            'list': [private],
          },
        };
        final originalJson = <String, dynamic>{
          ...requiredFields,
          'content_index': 1,
          'delta': private,
          'logprobs': [tokenJson],
          'future': {
            'list': [private],
          },
        };
        final event = InputAudioTranscriptionDeltaEvent.fromJson(originalJson);
        (tokenJson['bytes'] as List).clear();
        (originalJson['future'] as Map)['list'] = <String>[];
        expect(event.logprobs!.single.bytes, [1, 2]);
        expect(event.rawJson['future'], {
          'list': [private],
        });
        expect(() => event.logprobs!.clear(), throwsUnsupportedError);
        expect(
          () => event.logprobs!.single.bytes.clear(),
          throwsUnsupportedError,
        );
        expect(
          () => (event.rawJson['future'] as Map).clear(),
          throwsUnsupportedError,
        );
        final copy = event.copyWith(
          contentIndex: null,
          delta: null,
          obfuscation: null,
          clearLogprobs: true,
        );
        expect(copy.toJson().containsKey('delta'), isFalse);
        expect(copy.toJson().containsKey('content_index'), isFalse);
        expect(copy.toJson().containsKey('logprobs'), isFalse);
        expect(copy.rawJson['future'], {
          'list': [private],
        });
        expect(
          event.logprobs!.single.copyWith(token: 'new').toJson()['token'],
          'new',
        );
        expect(event.toString(), isNot(contains(private)));
        expect(event.logprobs!.single.toString(), isNot(contains(private)));
        expect(() => event.copyWith(contentIndex: 0.5), throwsFormatException);
        expect(() => event.copyWith(delta: 1), throwsFormatException);
        final cycle = <String, dynamic>{};
        cycle['cycle'] = cycle;
        expect(
          () => InputAudioTranscriptionDeltaEvent(
            eventId: '',
            itemId: '',
            rawJson: cycle,
          ),
          throwsFormatException,
        );
      },
    );

    test('all added values participate in equality', () {
      final event = InputAudioTranscriptionDeltaEvent(
        eventId: 'e',
        itemId: 'i',
        contentIndex: 0,
        delta: 'x',
      );
      for (final variant in [
        event.copyWith(itemId: 'j'),
        event.copyWith(contentIndex: 1),
        event.copyWith(delta: 'y'),
        event.copyWith(obfuscation: 'z'),
        event.copyWith(logprobs: []),
        event.copyWith(logprobs: null),
      ]) {
        expect(variant, isNot(event));
      }
      final a = RealtimeTranscriptionLogprob(
        token: 'a',
        logprob: -1,
        bytes: const [1],
      );
      expect(a.copyWith(token: 'b'), isNot(a));
      expect(a.copyWith(logprob: -2), isNot(a));
      expect(a.copyWith(bytes: [2]), isNot(a));
    });
  });

  test('GA and beta response.created/done preserve status error messages', () {
    for (final eventType in ['response.created', 'response.done']) {
      for (final beta in [false, true]) {
        final json = {
          'type': eventType,
          'event_id': 'event_1',
          'response': {
            'id': 'response_1',
            'object': 'realtime.response',
            if (beta) 'modalities': ['text'] else 'output_modalities': ['text'],
            'status': 'failed',
            'status_details': {
              'type': 'failed',
              'error': {
                'type': 'server_error',
                'code': 'bad_request',
                'message': 'Failure description',
              },
            },
          },
        };
        final event = RealtimeEvent.fromJson(json);
        expect(event.toJson(), json);
      }
    }
  });

  test(
    'DTMF and retrieved-item source examples preserve future raw fields',
    () {
      for (final json in <Map<String, dynamic>>[
        {
          'type': 'input_audio_buffer.dtmf_event_received',
          'event': '#',
          'received_at': 1721234567890,
        },
        {
          'type': 'conversation.item.retrieved',
          'event_id': 'event_1',
          'item': {
            'id': 'item_1',
            'type': 'message',
            'role': 'user',
            'content': [
              {'type': 'input_audio', 'audio': 'AA==', 'transcript': 'Hello'},
            ],
          },
        },
      ]) {
        final event = RealtimeEvent.fromJson(json);
        expect(event, isA<UnknownRealtimeEvent>());
        expect(event.toJson(), json);
      }
    },
  );
}
