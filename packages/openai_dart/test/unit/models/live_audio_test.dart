import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE_LIVE_PAYLOAD';

Map<String, dynamic> _object(String value) =>
    jsonDecode(value) as Map<String, dynamic>;

Matcher _safeError(String context) => isA<FormatException>()
    .having((error) => error.message, 'context', contains(context))
    .having((error) => error.source, 'source', isNull)
    .having((error) => error.offset, 'offset', isNull)
    .having((error) => error.toString(), 'privacy', isNot(contains(_private)));

void main() {
  group('LiveSessionAudioFormatPCMParam', () {
    Map<String, dynamic> fixture() =>
        _object('{"type": "audio/pcm", "rate": 16000}');
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveSessionAudioFormatPCMParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveSessionAudioFormatPCMParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.rate, fixture()['rate']);
      expect(model.toString(), contains('rate:'));
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveSessionAudioFormatPCMParam.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('future metadata remains finite, immutable and value-significant', () {
      final future = <String, dynamic>{
        _private: <String, dynamic>{
          'list': <Object?>[_private, null, false, 1.5],
        },
      };
      final model = LiveSessionAudioFormatPCMParam.fromJson({
        ...fixture(),
        ...future,
      });
      (future[_private] as Map<String, dynamic>)['list'] = 'changed';
      expect(model.toJson()[_private], {
        'list': [_private, null, false, 1.5],
      });
      expect(
        () => (model.rawJson[_private] as Map<String, dynamic>)['list'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson[_private] as Map<String, dynamic>)['list']
                    as List<Object?>)
                .add(null),
        throwsUnsupportedError,
      );
      final equal = LiveSessionAudioFormatPCMParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveSessionAudioFormatPCMParam.fromJson(fixture())));
      expect(model.toString(), isNot(contains(_private)));
      expect(model.copyWith(rawJson: const {}).toJson(), fixture());
    });
    test('malformed private overflow never leaks', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      for (final value in <Object?>[
        double.nan,
        double.infinity,
        Object(),
        cycle,
        <Object, Object>{1: _private},
      ]) {
        expect(
          () => LiveSessionAudioFormatPCMParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveSessionAudioFormatPCMParam')),
        );
      }
    });
    test('rate rejects wrong known values contextually', () {
      expect(
        () => LiveSessionAudioFormatPCMParam.fromJson({
          ...fixture(),
          'rate': _private,
        }),
        throwsA(_safeError('LiveSessionAudioFormatPCMParam.rate')),
      );
    });
    test('rate is required and rejects null', () {
      expect(
        () =>
            LiveSessionAudioFormatPCMParam.fromJson(fixture()..remove('rate')),
        throwsA(_safeError('LiveSessionAudioFormatPCMParam.rate')),
      );
      expect(
        () => LiveSessionAudioFormatPCMParam.fromJson({
          ...fixture(),
          'rate': null,
        }),
        throwsA(_safeError('LiveSessionAudioFormatPCMParam.rate')),
      );
    });
    test('rate typed copy wins over stale raw JSON', () {
      final model = LiveSessionAudioFormatPCMParam.fromJson(fixture());
      final copied = model.copyWith(rate: 24000);
      expect(copied.toJson()['rate'], jsonDecode('24000'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () =>
            LiveSessionAudioFormatPCMParam.fromJson({...fixture(), 'type': 42}),
        throwsA(_safeError('LiveSessionAudioFormatPCMParam.type')),
      );
    });
    test('type is required and rejects null', () {
      expect(
        () =>
            LiveSessionAudioFormatPCMParam.fromJson(fixture()..remove('type')),
        throwsA(_safeError('LiveSessionAudioFormatPCMParam.type')),
      );
      expect(
        () => LiveSessionAudioFormatPCMParam.fromJson({
          ...fixture(),
          'type': null,
        }),
        throwsA(_safeError('LiveSessionAudioFormatPCMParam.type')),
      );
    });
  });

  group('LiveSessionAudioFormatPCMAParam', () {
    Map<String, dynamic> fixture() =>
        _object('{"type": "audio/pcma", "rate": 8000}');
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveSessionAudioFormatPCMAParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveSessionAudioFormatPCMAParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.rate, fixture()['rate']);
      expect(model.toString(), contains('rate:'));
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveSessionAudioFormatPCMAParam.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('future metadata remains finite, immutable and value-significant', () {
      final future = <String, dynamic>{
        _private: <String, dynamic>{
          'list': <Object?>[_private, null, false, 1.5],
        },
      };
      final model = LiveSessionAudioFormatPCMAParam.fromJson({
        ...fixture(),
        ...future,
      });
      (future[_private] as Map<String, dynamic>)['list'] = 'changed';
      expect(model.toJson()[_private], {
        'list': [_private, null, false, 1.5],
      });
      expect(
        () => (model.rawJson[_private] as Map<String, dynamic>)['list'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson[_private] as Map<String, dynamic>)['list']
                    as List<Object?>)
                .add(null),
        throwsUnsupportedError,
      );
      final equal = LiveSessionAudioFormatPCMAParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveSessionAudioFormatPCMAParam.fromJson(fixture())));
      expect(model.toString(), isNot(contains(_private)));
      expect(model.copyWith(rawJson: const {}).toJson(), fixture());
    });
    test('malformed private overflow never leaks', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      for (final value in <Object?>[
        double.nan,
        double.infinity,
        Object(),
        cycle,
        <Object, Object>{1: _private},
      ]) {
        expect(
          () => LiveSessionAudioFormatPCMAParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveSessionAudioFormatPCMAParam')),
        );
      }
    });
    test('rate rejects wrong known values contextually', () {
      expect(
        () => LiveSessionAudioFormatPCMAParam.fromJson({
          ...fixture(),
          'rate': _private,
        }),
        throwsA(_safeError('LiveSessionAudioFormatPCMAParam.rate')),
      );
    });
    test('rate is required and rejects null', () {
      expect(
        () =>
            LiveSessionAudioFormatPCMAParam.fromJson(fixture()..remove('rate')),
        throwsA(_safeError('LiveSessionAudioFormatPCMAParam.rate')),
      );
      expect(
        () => LiveSessionAudioFormatPCMAParam.fromJson({
          ...fixture(),
          'rate': null,
        }),
        throwsA(_safeError('LiveSessionAudioFormatPCMAParam.rate')),
      );
    });
    test('rate typed copy wins over stale raw JSON', () {
      final model = LiveSessionAudioFormatPCMAParam.fromJson(fixture());
      final copied = model.copyWith(rate: 8000);
      expect(copied.toJson()['rate'], jsonDecode('8000'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () => LiveSessionAudioFormatPCMAParam.fromJson({
          ...fixture(),
          'type': 42,
        }),
        throwsA(_safeError('LiveSessionAudioFormatPCMAParam.type')),
      );
    });
    test('type is required and rejects null', () {
      expect(
        () =>
            LiveSessionAudioFormatPCMAParam.fromJson(fixture()..remove('type')),
        throwsA(_safeError('LiveSessionAudioFormatPCMAParam.type')),
      );
      expect(
        () => LiveSessionAudioFormatPCMAParam.fromJson({
          ...fixture(),
          'type': null,
        }),
        throwsA(_safeError('LiveSessionAudioFormatPCMAParam.type')),
      );
    });
  });

  group('LiveSessionAudioFormatPCMUParam', () {
    Map<String, dynamic> fixture() =>
        _object('{"type": "audio/pcmu", "rate": 8000}');
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveSessionAudioFormatPCMUParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveSessionAudioFormatPCMUParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.rate, fixture()['rate']);
      expect(model.toString(), contains('rate:'));
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveSessionAudioFormatPCMUParam.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('future metadata remains finite, immutable and value-significant', () {
      final future = <String, dynamic>{
        _private: <String, dynamic>{
          'list': <Object?>[_private, null, false, 1.5],
        },
      };
      final model = LiveSessionAudioFormatPCMUParam.fromJson({
        ...fixture(),
        ...future,
      });
      (future[_private] as Map<String, dynamic>)['list'] = 'changed';
      expect(model.toJson()[_private], {
        'list': [_private, null, false, 1.5],
      });
      expect(
        () => (model.rawJson[_private] as Map<String, dynamic>)['list'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson[_private] as Map<String, dynamic>)['list']
                    as List<Object?>)
                .add(null),
        throwsUnsupportedError,
      );
      final equal = LiveSessionAudioFormatPCMUParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveSessionAudioFormatPCMUParam.fromJson(fixture())));
      expect(model.toString(), isNot(contains(_private)));
      expect(model.copyWith(rawJson: const {}).toJson(), fixture());
    });
    test('malformed private overflow never leaks', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      for (final value in <Object?>[
        double.nan,
        double.infinity,
        Object(),
        cycle,
        <Object, Object>{1: _private},
      ]) {
        expect(
          () => LiveSessionAudioFormatPCMUParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveSessionAudioFormatPCMUParam')),
        );
      }
    });
    test('rate rejects wrong known values contextually', () {
      expect(
        () => LiveSessionAudioFormatPCMUParam.fromJson({
          ...fixture(),
          'rate': _private,
        }),
        throwsA(_safeError('LiveSessionAudioFormatPCMUParam.rate')),
      );
    });
    test('rate is required and rejects null', () {
      expect(
        () =>
            LiveSessionAudioFormatPCMUParam.fromJson(fixture()..remove('rate')),
        throwsA(_safeError('LiveSessionAudioFormatPCMUParam.rate')),
      );
      expect(
        () => LiveSessionAudioFormatPCMUParam.fromJson({
          ...fixture(),
          'rate': null,
        }),
        throwsA(_safeError('LiveSessionAudioFormatPCMUParam.rate')),
      );
    });
    test('rate typed copy wins over stale raw JSON', () {
      final model = LiveSessionAudioFormatPCMUParam.fromJson(fixture());
      final copied = model.copyWith(rate: 8000);
      expect(copied.toJson()['rate'], jsonDecode('8000'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () => LiveSessionAudioFormatPCMUParam.fromJson({
          ...fixture(),
          'type': 42,
        }),
        throwsA(_safeError('LiveSessionAudioFormatPCMUParam.type')),
      );
    });
    test('type is required and rejects null', () {
      expect(
        () =>
            LiveSessionAudioFormatPCMUParam.fromJson(fixture()..remove('type')),
        throwsA(_safeError('LiveSessionAudioFormatPCMUParam.type')),
      );
      expect(
        () => LiveSessionAudioFormatPCMUParam.fromJson({
          ...fixture(),
          'type': null,
        }),
        throwsA(_safeError('LiveSessionAudioFormatPCMUParam.type')),
      );
    });
  });

  group('LiveCustomVoiceParam', () {
    Map<String, dynamic> fixture() => _object('{"id": "PRIVATE_LIVE_PAYLOAD"}');
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveCustomVoiceParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveCustomVoiceParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.id, fixture()['id']);
      expect(model.toString(), contains('id:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveCustomVoiceParam.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('future metadata remains finite, immutable and value-significant', () {
      final future = <String, dynamic>{
        _private: <String, dynamic>{
          'list': <Object?>[_private, null, false, 1.5],
        },
      };
      final model = LiveCustomVoiceParam.fromJson({...fixture(), ...future});
      (future[_private] as Map<String, dynamic>)['list'] = 'changed';
      expect(model.toJson()[_private], {
        'list': [_private, null, false, 1.5],
      });
      expect(
        () => (model.rawJson[_private] as Map<String, dynamic>)['list'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson[_private] as Map<String, dynamic>)['list']
                    as List<Object?>)
                .add(null),
        throwsUnsupportedError,
      );
      final equal = LiveCustomVoiceParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveCustomVoiceParam.fromJson(fixture())));
      expect(model.toString(), isNot(contains(_private)));
      expect(model.copyWith(rawJson: const {}).toJson(), fixture());
    });
    test('malformed private overflow never leaks', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      for (final value in <Object?>[
        double.nan,
        double.infinity,
        Object(),
        cycle,
        <Object, Object>{1: _private},
      ]) {
        expect(
          () => LiveCustomVoiceParam.fromJson({...fixture(), _private: value}),
          throwsA(_safeError('LiveCustomVoiceParam')),
        );
      }
    });
    test('id rejects wrong known values contextually', () {
      expect(
        () => LiveCustomVoiceParam.fromJson({...fixture(), 'id': 42}),
        throwsA(_safeError('LiveCustomVoiceParam.id')),
      );
    });
    test('id is required and rejects null', () {
      expect(
        () => LiveCustomVoiceParam.fromJson(fixture()..remove('id')),
        throwsA(_safeError('LiveCustomVoiceParam.id')),
      );
      expect(
        () => LiveCustomVoiceParam.fromJson({...fixture(), 'id': null}),
        throwsA(_safeError('LiveCustomVoiceParam.id')),
      );
    });
    test('id typed copy wins over stale raw JSON', () {
      final model = LiveCustomVoiceParam.fromJson(fixture());
      final copied = model.copyWith(id: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['id'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
  });

  group('LiveInitialSessionAudioOutputParam', () {
    Map<String, dynamic> fixture() =>
        _object('{"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}}');
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveInitialSessionAudioOutputParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveInitialSessionAudioOutputParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.voice?.toJson(), fixture()['voice']);
      expect(model.toString(), contains('voice:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveInitialSessionAudioOutputParam.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('future metadata remains finite, immutable and value-significant', () {
      final future = <String, dynamic>{
        _private: <String, dynamic>{
          'list': <Object?>[_private, null, false, 1.5],
        },
      };
      final model = LiveInitialSessionAudioOutputParam.fromJson({
        ...fixture(),
        ...future,
      });
      (future[_private] as Map<String, dynamic>)['list'] = 'changed';
      expect(model.toJson()[_private], {
        'list': [_private, null, false, 1.5],
      });
      expect(
        () => (model.rawJson[_private] as Map<String, dynamic>)['list'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson[_private] as Map<String, dynamic>)['list']
                    as List<Object?>)
                .add(null),
        throwsUnsupportedError,
      );
      final equal = LiveInitialSessionAudioOutputParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(
        model,
        isNot(LiveInitialSessionAudioOutputParam.fromJson(fixture())),
      );
      expect(model.toString(), isNot(contains(_private)));
      expect(model.copyWith(rawJson: const {}).toJson(), fixture());
    });
    test('malformed private overflow never leaks', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      for (final value in <Object?>[
        double.nan,
        double.infinity,
        Object(),
        cycle,
        <Object, Object>{1: _private},
      ]) {
        expect(
          () => LiveInitialSessionAudioOutputParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveInitialSessionAudioOutputParam')),
        );
      }
    });
    test('voice rejects wrong known values contextually', () {
      expect(
        () => LiveInitialSessionAudioOutputParam.fromJson({
          ...fixture(),
          'voice': 42,
        }),
        throwsA(_safeError('LiveInitialSessionAudioOutputParam.voice')),
      );
    });
    test('voice omission, null and clearing follow schema', () {
      final absent = LiveInitialSessionAudioOutputParam.fromJson(
        fixture()..remove('voice'),
      );
      expect(absent.voice, isNull);
      expect(absent.toJson().containsKey('voice'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveInitialSessionAudioOutputParam.fromJson({
          ...fixture(),
          'voice': null,
        }),
        throwsA(_safeError('LiveInitialSessionAudioOutputParam.voice')),
      );
      expect(
        LiveInitialSessionAudioOutputParam.fromJson(
          fixture(),
        ).copyWith(voice: null).toJson().containsKey('voice'),
        isFalse,
      );
    });
    test('voice typed copy wins over stale raw JSON', () {
      final model = LiveInitialSessionAudioOutputParam.fromJson(fixture());
      final copied = model.copyWith(
        voice: LiveVoice.fromJson('future_named_voice'),
      );
      expect(copied.toJson()['voice'], jsonDecode('"future_named_voice"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(voice: Object()),
        throwsA(_safeError('LiveInitialSessionAudioOutputParam.voice')),
      );
    });
  });

  group('LiveInitialSessionAudioParam', () {
    Map<String, dynamic> fixture() => _object(
      '{"format": {"type": "audio/pcm", "rate": 16000}, "output": {"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}}}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveInitialSessionAudioParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveInitialSessionAudioParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.format?.toJson(), fixture()['format']);
      expect(model.toString(), contains('format:'));
      expect(model.output?.toJson(), fixture()['output']);
      expect(model.toString(), contains('output:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveInitialSessionAudioParam.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('future metadata remains finite, immutable and value-significant', () {
      final future = <String, dynamic>{
        _private: <String, dynamic>{
          'list': <Object?>[_private, null, false, 1.5],
        },
      };
      final model = LiveInitialSessionAudioParam.fromJson({
        ...fixture(),
        ...future,
      });
      (future[_private] as Map<String, dynamic>)['list'] = 'changed';
      expect(model.toJson()[_private], {
        'list': [_private, null, false, 1.5],
      });
      expect(
        () => (model.rawJson[_private] as Map<String, dynamic>)['list'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson[_private] as Map<String, dynamic>)['list']
                    as List<Object?>)
                .add(null),
        throwsUnsupportedError,
      );
      final equal = LiveInitialSessionAudioParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveInitialSessionAudioParam.fromJson(fixture())));
      expect(model.toString(), isNot(contains(_private)));
      expect(model.copyWith(rawJson: const {}).toJson(), fixture());
    });
    test('malformed private overflow never leaks', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      for (final value in <Object?>[
        double.nan,
        double.infinity,
        Object(),
        cycle,
        <Object, Object>{1: _private},
      ]) {
        expect(
          () => LiveInitialSessionAudioParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveInitialSessionAudioParam')),
        );
      }
    });
    test('format rejects wrong known values contextually', () {
      expect(
        () =>
            LiveInitialSessionAudioParam.fromJson({...fixture(), 'format': 42}),
        throwsA(_safeError('LiveInitialSessionAudioParam.format')),
      );
    });
    test('format omission, null and clearing follow schema', () {
      final absent = LiveInitialSessionAudioParam.fromJson(
        fixture()..remove('format'),
      );
      expect(absent.format, isNull);
      expect(absent.toJson().containsKey('format'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveInitialSessionAudioParam.fromJson({
          ...fixture(),
          'format': null,
        }),
        throwsA(_safeError('LiveInitialSessionAudioParam.format')),
      );
      expect(
        LiveInitialSessionAudioParam.fromJson(
          fixture(),
        ).copyWith(format: null).toJson().containsKey('format'),
        isFalse,
      );
    });
    test('format typed copy wins over stale raw JSON', () {
      final model = LiveInitialSessionAudioParam.fromJson(fixture());
      final copied = model.copyWith(
        format: LiveAudioFormat.fromJson(
          _object('{"type": "audio/pcmu", "rate": 8000}'),
        ),
      );
      expect(
        copied.toJson()['format'],
        jsonDecode('{"type": "audio/pcmu", "rate": 8000}'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(format: Object()),
        throwsA(_safeError('LiveInitialSessionAudioParam.format')),
      );
    });
    test('output rejects wrong known values contextually', () {
      expect(
        () =>
            LiveInitialSessionAudioParam.fromJson({...fixture(), 'output': 42}),
        throwsA(_safeError('LiveInitialSessionAudioParam.output')),
      );
    });
    test('output omission, null and clearing follow schema', () {
      final absent = LiveInitialSessionAudioParam.fromJson(
        fixture()..remove('output'),
      );
      expect(absent.output, isNull);
      expect(absent.toJson().containsKey('output'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveInitialSessionAudioParam.fromJson({
          ...fixture(),
          'output': null,
        }),
        throwsA(_safeError('LiveInitialSessionAudioParam.output')),
      );
      expect(
        LiveInitialSessionAudioParam.fromJson(
          fixture(),
        ).copyWith(output: null).toJson().containsKey('output'),
        isFalse,
      );
    });
    test('output typed copy wins over stale raw JSON', () {
      final model = LiveInitialSessionAudioParam.fromJson(fixture());
      final copied = model.copyWith(
        output: LiveInitialSessionAudioOutputParam.fromJson(
          _object(
            '{"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}, "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['output'],
        jsonDecode(
          '{"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}, "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(output: Object()),
        throwsA(_safeError('LiveInitialSessionAudioParam.output')),
      );
    });
  });

  group('LiveMediaSessionAudioParam', () {
    Map<String, dynamic> fixture() =>
        _object('{"output": {"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}}}');
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveMediaSessionAudioParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveMediaSessionAudioParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.output?.toJson(), fixture()['output']);
      expect(model.toString(), contains('output:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveMediaSessionAudioParam.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('closed writable extras reject without disclosing keys', () {
      expect(
        () =>
            LiveMediaSessionAudioParam.fromJson({...fixture(), _private: true}),
        throwsA(_safeError('LiveMediaSessionAudioParam')),
      );
      expect(
        () => LiveMediaSessionAudioParam.fromJson(
          fixture(),
        ).copyWith(rawJson: {_private: true}),
        throwsA(_safeError('LiveMediaSessionAudioParam')),
      );
    });
    test('output rejects wrong known values contextually', () {
      expect(
        () => LiveMediaSessionAudioParam.fromJson({...fixture(), 'output': 42}),
        throwsA(_safeError('LiveMediaSessionAudioParam.output')),
      );
    });
    test('output omission, null and clearing follow schema', () {
      final absent = LiveMediaSessionAudioParam.fromJson(
        fixture()..remove('output'),
      );
      expect(absent.output, isNull);
      expect(absent.toJson().containsKey('output'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () =>
            LiveMediaSessionAudioParam.fromJson({...fixture(), 'output': null}),
        throwsA(_safeError('LiveMediaSessionAudioParam.output')),
      );
      expect(
        LiveMediaSessionAudioParam.fromJson(
          fixture(),
        ).copyWith(output: null).toJson().containsKey('output'),
        isFalse,
      );
    });
    test('output typed copy wins over stale raw JSON', () {
      final model = LiveMediaSessionAudioParam.fromJson(fixture());
      final copied = model.copyWith(
        output: LiveInitialSessionAudioOutputParam.fromJson(
          _object(
            '{"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}, "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['output'],
        jsonDecode(
          '{"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}, "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(output: Object()),
        throwsA(_safeError('LiveMediaSessionAudioParam.output')),
      );
    });
  });

  group('LiveForkAudioParam', () {
    Map<String, dynamic> fixture() =>
        _object('{"format": {"type": "audio/pcmu", "rate": 8000}}');
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveForkAudioParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveForkAudioParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.format?.toJson(), fixture()['format']);
      expect(model.toString(), contains('format:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveForkAudioParam.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('future metadata remains finite, immutable and value-significant', () {
      final future = <String, dynamic>{
        _private: <String, dynamic>{
          'list': <Object?>[_private, null, false, 1.5],
        },
      };
      final model = LiveForkAudioParam.fromJson({...fixture(), ...future});
      (future[_private] as Map<String, dynamic>)['list'] = 'changed';
      expect(model.toJson()[_private], {
        'list': [_private, null, false, 1.5],
      });
      expect(
        () => (model.rawJson[_private] as Map<String, dynamic>)['list'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson[_private] as Map<String, dynamic>)['list']
                    as List<Object?>)
                .add(null),
        throwsUnsupportedError,
      );
      final equal = LiveForkAudioParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveForkAudioParam.fromJson(fixture())));
      expect(model.toString(), isNot(contains(_private)));
      expect(model.copyWith(rawJson: const {}).toJson(), fixture());
    });
    test('malformed private overflow never leaks', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      for (final value in <Object?>[
        double.nan,
        double.infinity,
        Object(),
        cycle,
        <Object, Object>{1: _private},
      ]) {
        expect(
          () => LiveForkAudioParam.fromJson({...fixture(), _private: value}),
          throwsA(_safeError('LiveForkAudioParam')),
        );
      }
    });
    test('format rejects wrong known values contextually', () {
      expect(
        () => LiveForkAudioParam.fromJson({...fixture(), 'format': 42}),
        throwsA(_safeError('LiveForkAudioParam.format')),
      );
    });
    test('format omission, null and clearing follow schema', () {
      final absent = LiveForkAudioParam.fromJson(fixture()..remove('format'));
      expect(absent.format, isNull);
      expect(absent.toJson().containsKey('format'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveForkAudioParam.fromJson({...fixture(), 'format': null}),
        throwsA(_safeError('LiveForkAudioParam.format')),
      );
      expect(
        LiveForkAudioParam.fromJson(
          fixture(),
        ).copyWith(format: null).toJson().containsKey('format'),
        isFalse,
      );
    });
    test('format typed copy wins over stale raw JSON', () {
      final model = LiveForkAudioParam.fromJson(fixture());
      final copied = model.copyWith(
        format: LiveAudioFormat.fromJson(
          _object('{"type": "audio/pcmu", "rate": 8000}'),
        ),
      );
      expect(
        copied.toJson()['format'],
        jsonDecode('{"type": "audio/pcmu", "rate": 8000}'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(format: Object()),
        throwsA(_safeError('LiveForkAudioParam.format')),
      );
    });
  });
}
