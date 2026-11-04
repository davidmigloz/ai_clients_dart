import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/models/live/live_json_helpers.dart'
    show liveUnset;
import 'package:test/test.dart';

const _private = 'PRIVATE audio/correlation';

void main() {
  for (final type in [
    'session.output_audio.fixture.playing',
    'session.output_audio.fixture.played',
  ]) {
    group(type, () {
      test(
        'dispatches on primary and sideband without invented media facts',
        () {
          final wire = {'type': type, 'event_id': _private};
          final event = LiveServerEvent.fromJson(wire);
          expect(
            event,
            type.endsWith('playing')
                ? isA<LiveOutputAudioFixturePlaying>()
                : isA<LiveOutputAudioFixturePlayed>(),
          );
          expect(event.eventId, _private);
          expect(event.toJson(), wire);
          event
            ..validateForChannel('primary')
            ..validateForChannel('sideband');
          expect(event.toString(), isNot(contains('PRIVATE')));
          expect(
            () => UnknownLiveServerEvent(type: type),
            throwsFormatException,
          );
        },
      );

      for (final field in ['type', 'event_id']) {
        for (final corruption in ['missing', 'null', 'wrong']) {
          test('rejects $corruption required $field', () {
            final wire = <String, dynamic>{'type': type, 'event_id': _private};
            if (corruption == 'missing') {
              wire.remove(field);
            } else {
              wire[field] = corruption == 'null' ? null : false;
            }
            expect(
              () => _parse(type, wire),
              throwsA(
                isA<FormatException>().having(
                  (e) => e.message,
                  'field',
                  contains(field),
                ),
              ),
            );
          });
        }
      }

      test('client correlation is optional nonnull and copies can omit it', () {
        final absent = _parse(type, {'type': type, 'event_id': _private});
        final present = _parse(type, {
          'type': type,
          'event_id': _private,
          'client_event_id': 'caller',
        });
        expect(_copy(present), present);
        expect(_copy(present).hashCode, present.hashCode);
        expect(_copy(present, clear: true), absent);
        expect(
          _copy(present, clear: true).toJson().containsKey('client_event_id'),
          isFalse,
        );
        expect(_copy(present, clientEventId: 'different'), isNot(present));
        expect(_copy(present, eventId: 'different'), isNot(present));
        expect(
          () => _copy(present, clientEventId: null),
          throwsFormatException,
        );
        expect(() => _copy(present, eventId: null), throwsFormatException);
        expect(
          () => _parse(type, {
            'type': type,
            'event_id': _private,
            'client_event_id': null,
          }),
          throwsFormatException,
        );
        expect(
          () => _parse(type, {
            'type': type,
            'event_id': _private,
            'client_event_id': 1,
          }),
          throwsFormatException,
        );
      });

      test('constructor/copy preserve finite immutable future metadata', () {
        final child = <String, dynamic>{'audio': _private};
        final wire = <String, dynamic>{
          'type': type,
          'event_id': _private,
          'future': [child],
        };
        final event = _parse(type, wire);
        child.clear();
        expect(event.toJson()['future'], [
          {'audio': _private},
        ]);
        expect(event.rawJson.clear, throwsUnsupportedError);
        expect(
          () => (event.rawJson['future'] as List).clear(),
          throwsUnsupportedError,
        );
        expect(_copy(event).toJson(), event.toJson());
        expect(
          _copy(event, eventId: 'new').toJson()['future'],
          event.toJson()['future'],
        );
        final constructed = type.endsWith('playing')
            ? LiveOutputAudioFixturePlaying(
                eventId: _private,
                clientEventId: 'caller',
              )
            : LiveOutputAudioFixturePlayed(
                eventId: _private,
                clientEventId: 'caller',
              );
        expect(constructed.toJson(), {
          'type': type,
          'event_id': _private,
          'client_event_id': 'caller',
        });
        expect(
          () => _parse(type, {...wire, 'future': double.nan}),
          throwsFormatException,
        );
        wire['future'] = wire;
        expect(() => _parse(type, wire), throwsFormatException);
      });
    });
  }

  for (final type in ['transport.dtmf.received', 'transport.dtmf.sent']) {
    test('$type is sideband-only while bare decoding remains available', () {
      final wire = {'type': type, 'event_id': _private, 'event': '#'};
      final event = LiveServerEvent.fromJson(wire);
      expect(event.toJson(), wire);
      event.validateForChannel('sideband');
      expect(
        () => event.validateForChannel('primary'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'channel',
            contains('channel'),
          ),
        ),
      );
      expect(() => event.validateForChannel('fork'), throwsFormatException);
    });
  }
  test('sent delivery correlation does not become a client command', () {
    final event = LiveTransportDTMFSent.fromJson(const {
      'type': 'transport.dtmf.sent',
      'event_id': _private,
      'event': 'A',
      'client_event_id': 'command',
    });
    expect(event.type, 'transport.dtmf.sent');
    expect(event.clientEventId, 'command');
    expect(
      event
          .copyWith(clearClientEventId: true)
          .toJson()
          .containsKey('client_event_id'),
      isFalse,
    );
    expect(() => event.copyWith(clientEventId: null), throwsFormatException);
    expect(
      () => UnknownLiveServerEvent(type: event.type),
      throwsFormatException,
    );
    expect(
      () => LiveServerEvent.fromJson({
        'type': event.type,
        'event_id': _private,
        'event': 'AB',
      }),
      throwsFormatException,
    );
  });
  test(
    'legacy received send remains finite immutable Unknown without lying about delivery',
    () {
      final child = <String, dynamic>{'value': _private};
      final wire = <String, dynamic>{
        'type': 'transport.dtmf.send',
        'event_id': _private,
        'event': '#',
        'client_event_id': 'command',
        'saved': child,
      };
      final event = LiveServerEvent.fromJson(wire);
      expect(event, isA<UnknownLiveServerEvent>());
      expect(event.type, 'transport.dtmf.send');
      expect(event.toJson(), wire);
      child.clear();
      expect(event.rawJson['saved'], {'value': _private});
      expect(event.rawJson.clear, throwsUnsupportedError);
      expect(
        () => LiveServerEvent.fromJson({...wire, 'future': double.infinity}),
        throwsFormatException,
      );
      expect(event.toString(), isNot(contains('PRIVATE')));
    },
  );
  test(
    'sideband reflection is retained separately from mixer/mute acknowledgments',
    () {
      final input = LiveServerEvent.fromJson({
        'type': 'session.input_audio.append',
        'audio': 'AA==',
      });
      final output = LiveServerEvent.fromJson({
        'type': 'session.output_audio.delta',
        'delta': 'AA==',
        'start_ms': 0,
        'end_ms': 1,
      });
      expect(input, isA<LiveInputAudioAppend>());
      expect(output, isA<LiveOutputAudioDelta>());
      input.validateForChannel('sideband');
      output.validateForChannel('sideband');
      expect(input.eventId, isNull);
      expect(output.eventId, isNull);
    },
  );
  test(
    'mixer and independent mute acknowledgments preserve received order',
    () {
      final types = [
        'session.input_audio.muted',
        'session.output_audio.fixture.playing',
        'session.input_audio.unmuted',
        'session.output_audio.fixture.played',
      ];
      final events = [
        for (final type in types)
          LiveServerEvent.fromJson({'type': type, 'event_id': type}),
      ];
      expect(events.map((event) => event.type), types);
      expect(events.whereType<LiveInputAudioMuted>(), hasLength(1));
      expect(events.whereType<LiveInputAudioUnmuted>(), hasLength(1));
      expect(events.whereType<LiveOutputAudioFixturePlaying>(), hasLength(1));
      expect(events.whereType<LiveOutputAudioFixturePlayed>(), hasLength(1));
    },
  );
}

LiveServerEvent _parse(String type, Map<String, dynamic> wire) =>
    type.endsWith('playing')
    ? LiveOutputAudioFixturePlaying.fromJson(wire)
    : LiveOutputAudioFixturePlayed.fromJson(wire);
const _unset = Object();
LiveServerEvent _copy(
  LiveServerEvent event, {
  Object? eventId = _unset,
  Object? clientEventId = _unset,
  bool clear = false,
}) => switch (event) {
  final LiveOutputAudioFixturePlaying event => event.copyWith(
    eventId: identical(eventId, _unset) ? event.eventId : eventId,
    clientEventId: identical(clientEventId, _unset)
        ? event.clientEventId ?? liveUnset
        : clientEventId,
    clearClientEventId: clear,
  ),
  final LiveOutputAudioFixturePlayed event => event.copyWith(
    eventId: identical(eventId, _unset) ? event.eventId : eventId,
    clientEventId: identical(clientEventId, _unset)
        ? event.clientEventId ?? liveUnset
        : clientEventId,
    clearClientEventId: clear,
  ),
  _ => throw StateError('Unexpected fixture event'),
};
