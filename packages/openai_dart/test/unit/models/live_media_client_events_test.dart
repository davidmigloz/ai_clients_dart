import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE media or key correlation';
Map<String, dynamic> _fixture() => {
  'type': 'session.output_audio.fixture.play',
  'audio': 'AAAAAA==',
};
Map<String, dynamic> _dtmf() => {'type': 'transport.dtmf.send', 'event': '#'};
Matcher _safe([String context = 'Live']) => throwsA(
  isA<FormatException>()
      .having((error) => error.message, 'context', contains(context))
      .having((error) => error.source, 'safe source', isNull)
      .having((error) => error.offset, 'safe offset', isNull)
      .having(
        (error) => error.toString(),
        'private values',
        isNot(contains(_private)),
      ),
);
Map<String, dynamic> _extras() => {
  'PRIVATE future key': <String, dynamic>{
    'nested': <dynamic>[_private, null],
  },
};

void main() {
  group('native Live fixture play command', () {
    test('primary, fork and sideband parse identical fixed wire shape', () {
      final wire = _fixture();
      final model = LiveOutputAudioFixturePlayParam.fromJson(wire);
      expect(model.type, 'session.output_audio.fixture.play');
      expect(model.audio, 'AAAAAA==');
      expect(model.toJson(), wire);
      expect(LiveClientEvent.fromJson(wire), model);
      expect(LiveClientEvent.fromForkJson(wire), model);
      expect(LiveSidebandClientEvent.fromJson(wire), model);
      expect(
        LiveOutputAudioFixturePlayParam.fromJson(model.toJson()).hashCode,
        model.hashCode,
      );
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toJson().keys.toSet(), {'type', 'audio'});
    });

    test('byte factory snapshots only the provided raw PCM view', () {
      final storage = Uint8List.fromList([255, 1, 2, 3, 4, 254]);
      final view = Uint8List.sublistView(storage, 1, 5);
      final model = LiveOutputAudioFixturePlayParam.fromBytes(
        view,
        eventId: _private,
      );
      storage.fillRange(0, storage.length, 0);
      expect(base64Decode(model.audio), [1, 2, 3, 4]);
      expect(model.eventId, _private);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.toString(), isNot(contains(model.audio)));
      expect(LiveOutputAudioFixturePlayParam.fromJson(model.toJson()), model);
    });

    test(
      'correlation preserves omission/null/value and authoritative clear',
      () {
        final absent = LiveOutputAudioFixturePlayParam.fromJson(_fixture());
        expect(absent.hasEventId, isFalse);
        expect(absent.toJson().containsKey('event_id'), isFalse);
        final nullable = absent.copyWith(eventId: null);
        expect(nullable.hasEventId, isTrue);
        expect(nullable.toJson().containsKey('event_id'), isTrue);
        expect(nullable.toJson()['event_id'], isNull);
        expect(nullable, isNot(absent));
        expect(
          LiveOutputAudioFixturePlayParam.fromJson(nullable.toJson()),
          nullable,
        );
        expect(nullable.copyWith(clearEventId: true), absent);
        final value = LiveOutputAudioFixturePlayParam.fromJson({
          ..._fixture(),
          'event_id': _private,
        });
        expect(value.copyWith(clearEventId: true), absent);
        final unicode = value.copyWith(eventId: '😀' * 512);
        expect(unicode.eventId!.runes.length, 512);
        expect(() => unicode.copyWith(eventId: '😀' * 513), _safe('event_id'));
        expect(() => value.copyWith(eventId: 42), _safe('event_id'));
        expect(value.copyWith(audio: 'AAA='), isNot(value));
        expect(value.copyWith(audio: 'AAA=').toJson()['audio'], 'AAA=');
      },
    );

    test('required fields and fixed tag reject malformed values privately', () {
      for (final field in ['type', 'audio']) {
        for (final wire in [
          _fixture()..remove(field),
          _fixture()..[field] = null,
          _fixture()..[field] = true,
        ]) {
          expect(
            () => LiveOutputAudioFixturePlayParam.fromJson(wire),
            _safe(field),
          );
        }
      }
      for (final type in [
        _private,
        'session.output_audio.fixture.playing',
        'session.output_audio.fixture.played',
      ]) {
        expect(
          () => LiveOutputAudioFixturePlayParam.fromJson(
            _fixture()..['type'] = type,
          ),
          _safe('type'),
        );
      }
      expect(
        () => LiveOutputAudioFixturePlayParam.fromJson(
          _fixture()..['event_id'] = false,
        ),
        _safe('event_id'),
      );
    });

    test(
      'finite future metadata detaches deeply and copies keep known authority',
      () {
        final wire = {..._fixture(), ..._extras()};
        final model = LiveOutputAudioFixturePlayParam.fromJson(wire);
        (wire['PRIVATE future key'] as Map<String, dynamic>)['nested'] = [
          'mutated',
        ];
        expect(model.toJson()['PRIVATE future key'], {
          'nested': [_private, null],
        });
        expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
        final extra =
            model.rawJson['PRIVATE future key'] as Map<String, dynamic>;
        expect(
          () => (extra['nested'] as List<dynamic>).add(1),
          throwsUnsupportedError,
        );
        expect(model.copyWith(rawJson: {}).toJson(), _fixture());
        expect(model.copyWith(rawJson: {}), isNot(model));
        expect(model.toString(), isNot(contains('PRIVATE')));
        final cycle = <String, dynamic>{};
        cycle['PRIVATE cyclic'] = cycle;
        for (final invalid in [
          cycle,
          double.nan,
          double.infinity,
          Object(),
          {1: true},
        ]) {
          expect(
            () => model.copyWith(rawJson: {'PRIVATE extra': invalid}),
            _safe(),
          );
        }
      },
    );

    test(
      'PCM fixture bounds admit exactly 30 seconds and reject oversized bytes/text',
      () {
        final bytes = Uint8List(LiveOutputAudioFixturePlayParam.maxAudioBytes);
        final model = LiveOutputAudioFixturePlayParam.fromBytes(bytes);
        expect(bytes.length, 1440000);
        expect(model.audio.length, 1920000);
        expect(
          model.audio.length,
          LiveOutputAudioFixturePlayParam.maxEncodedAudioLength,
        );
        model.validate();
        expect(
          () => LiveOutputAudioFixturePlayParam.fromBytes(
            Uint8List(bytes.length + 2),
          ),
          _safe('audio'),
        );
        expect(() => model.copyWith(audio: '${model.audio}A'), _safe('audio'));
        expect(
          () => LiveOutputAudioFixturePlayParam.fromBytes(Uint8List(0)),
          _safe('audio'),
        );
        expect(
          () => LiveOutputAudioFixturePlayParam.fromBytes(Uint8List(1)),
          _safe('audio'),
        );
        expect(
          () => LiveOutputAudioFixturePlayParam.fromBytes(Uint8List(3)),
          _safe('audio'),
        );
      },
    );

    test(
      'base64 syntax, sample alignment and ordinary alphabet are checked',
      () {
        for (final audio in [
          '',
          'AA==',
          'AAAA',
          'A',
          'AA=A',
          'AAA===',
          'AA--',
          'AA__',
          'AAA%3D',
          'AA A=',
          'AAA=\n',
          'AAA=\t',
          'data:audio/pcm;base64,AAA=',
          _private,
        ]) {
          expect(
            () => LiveOutputAudioFixturePlayParam(audio: audio),
            _safe('audio'),
          );
        }
        for (final audio in ['AAA=', 'AAAAAA==']) {
          final model = LiveOutputAudioFixturePlayParam(audio: audio);
          expect(model.audio, audio);
          expect(model.toJson()['audio'], audio);
        }
      },
    );

    for (final riff in ['RIFF', 'RIFX', 'RF64', 'BW64']) {
      test('$riff WAV header is rejected without converting a container', () {
        final bytes = Uint8List(44)
          ..setRange(0, 4, ascii.encode(riff))
          ..setRange(8, 12, ascii.encode('WAVE'));
        expect(
          () => LiveOutputAudioFixturePlayParam.fromBytes(bytes),
          _safe('WAV'),
        );
        expect(
          () => LiveOutputAudioFixturePlayParam(audio: base64Encode(bytes)),
          _safe('WAV'),
        );
      });
    }

    test(
      'validation does not infer session format, channel count or amplitude',
      () {
        final arbitrarySamples = Uint8List.fromList([255, 127, 0, 128]);
        final fixture = LiveOutputAudioFixturePlayParam.fromBytes(
          arbitrarySamples,
        );
        expect(base64Decode(fixture.audio), arbitrarySamples);
        final noHeader = Uint8List(12)
          ..setRange(0, 4, ascii.encode('RIFF'))
          ..setRange(8, 12, ascii.encode('NONE'));
        expect(
          base64Decode(
            LiveOutputAudioFixturePlayParam.fromBytes(noHeader).audio,
          ),
          noHeader,
        );
        // Append remains its independent negotiated-format command without the
        // fixture's 24 kHz PCM alignment or 30-second quota.
        expect(LiveInputAudioAppendEvent(audio: 'AA==').audio, 'AA==');
        expect(
          LiveInputAudioAppendEvent(audio: 'not-inspected-here').audio,
          'not-inspected-here',
        );
      },
    );
  });

  group('SIP-only sideband DTMF send command', () {
    for (final key in '0123456789ABCD*#'.split('')) {
      test('single canonical key $key is preserved', () {
        final model = LiveTransportDTMFSendParam(event: key);
        expect(model.type, 'transport.dtmf.send');
        expect(model.toJson(), {'type': 'transport.dtmf.send', 'event': key});
        expect(LiveSidebandClientEvent.fromJson(model.toJson()), model);
        expect(model.copyWith(), model);
        expect(model.copyWith().hashCode, model.hashCode);
      });
    }

    test('valid DTMF never enters the primary/fork client union', () {
      final wire = _dtmf();
      final model = LiveTransportDTMFSendParam.fromJson(wire);
      expect(LiveSidebandClientEvent.fromJson(wire), model);
      expect(() => LiveClientEvent.fromJson(wire), _safe('type'));
      expect(() => LiveClientEvent.fromForkJson(wire), _safe('type'));
      for (final tag in [
        'transport.dtmf.sent',
        'transport.dtmf.received',
        _private,
      ]) {
        expect(
          () => LiveTransportDTMFSendParam.fromJson({...wire, 'type': tag}),
          _safe('type'),
        );
      }
    });

    test(
      'keypress sequences, lowercase and noncanonical values are rejected',
      () {
        for (final key in [
          '',
          '12',
          'a',
          'b',
          'c',
          'd',
          'E',
          ' ',
          '# ',
          '1\n',
          '😀',
          _private,
        ]) {
          expect(() => LiveTransportDTMFSendParam(event: key), _safe('event'));
        }
        for (final field in ['type', 'event']) {
          for (final wire in [
            _dtmf()..remove(field),
            _dtmf()..[field] = null,
            _dtmf()..[field] = false,
          ]) {
            expect(
              () => LiveTransportDTMFSendParam.fromJson(wire),
              _safe(field),
            );
          }
        }
      },
    );

    test('nullable correlation and copies preserve every wire field', () {
      final absent = LiveTransportDTMFSendParam.fromJson(_dtmf());
      final nullable = absent.copyWith(eventId: null);
      expect(absent.hasEventId, isFalse);
      expect(nullable.hasEventId, isTrue);
      expect(nullable.toJson().containsKey('event_id'), isTrue);
      expect(nullable.toJson()['event_id'], isNull);
      expect(nullable, isNot(absent));
      expect(nullable.copyWith(clearEventId: true), absent);
      final original = LiveTransportDTMFSendParam.fromJson({
        ..._dtmf(),
        'event_id': _private,
        ..._extras(),
      });
      expect(original.eventId, _private);
      expect(
        original.copyWith(clearEventId: true).toJson().containsKey('event_id'),
        isFalse,
      );
      expect(original.copyWith(event: '1').toJson()['event'], '1');
      expect(original.copyWith(event: '1'), isNot(original));
      expect(
        original
            .copyWith(rawJson: {})
            .toJson()
            .containsKey('PRIVATE future key'),
        isFalse,
      );
      expect(
        LiveSidebandClientEvent.fromJson(original.toJson()).hashCode,
        original.hashCode,
      );
      expect(original.toString(), isNot(contains(_private)));
      expect(() => original.rawJson['new'] = true, throwsUnsupportedError);
      final bounded = original.copyWith(eventId: '😀' * 512);
      expect(bounded.eventId!.runes.length, 512);
      expect(() => bounded.copyWith(eventId: '😀' * 513), _safe('event_id'));
      expect(() => original.copyWith(eventId: false), _safe('event_id'));
      expect(() => original.copyWith(event: 'private-invalid'), _safe('event'));
    });
  });
}
