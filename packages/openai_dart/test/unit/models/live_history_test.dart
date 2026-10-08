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
  group('LiveInitialInputTextContentPartParam', () {
    Map<String, dynamic> fixture() =>
        _object('{"type": "input_text", "text": "PRIVATE_LIVE_PAYLOAD"}');
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveInitialInputTextContentPartParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveInitialInputTextContentPartParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.text, fixture()['text']);
      expect(model.toString(), contains('text:'));
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveInitialInputTextContentPartParam.fromJson(input);
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
      final model = LiveInitialInputTextContentPartParam.fromJson({
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
      final equal = LiveInitialInputTextContentPartParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(
        model,
        isNot(LiveInitialInputTextContentPartParam.fromJson(fixture())),
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
          () => LiveInitialInputTextContentPartParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveInitialInputTextContentPartParam')),
        );
      }
    });
    test('text rejects wrong known values contextually', () {
      expect(
        () => LiveInitialInputTextContentPartParam.fromJson({
          ...fixture(),
          'text': 42,
        }),
        throwsA(_safeError('LiveInitialInputTextContentPartParam.text')),
      );
    });
    test('text is required and rejects null', () {
      expect(
        () => LiveInitialInputTextContentPartParam.fromJson(
          fixture()..remove('text'),
        ),
        throwsA(_safeError('LiveInitialInputTextContentPartParam.text')),
      );
      expect(
        () => LiveInitialInputTextContentPartParam.fromJson({
          ...fixture(),
          'text': null,
        }),
        throwsA(_safeError('LiveInitialInputTextContentPartParam.text')),
      );
    });
    test('text typed copy wins over stale raw JSON', () {
      final model = LiveInitialInputTextContentPartParam.fromJson(fixture());
      final copied = model.copyWith(text: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['text'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () => LiveInitialInputTextContentPartParam.fromJson({
          ...fixture(),
          'type': 42,
        }),
        throwsA(_safeError('LiveInitialInputTextContentPartParam.type')),
      );
    });
    test('type omission and optional fixed presence survive copying', () {
      final absent = LiveInitialInputTextContentPartParam.fromJson(
        fixture()..remove('type'),
      );
      expect(absent.hasType, isFalse);
      expect(absent.toJson().containsKey('type'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.copyWith(hasType: true).toJson()['type'], 'input_text');
      expect(
        () => LiveInitialInputTextContentPartParam.fromJson({
          ...fixture(),
          'type': null,
        }),
        throwsA(_safeError('LiveInitialInputTextContentPartParam.type')),
      );
    });
  });

  group('LiveInitialTextContentPartParam', () {
    Map<String, dynamic> fixture() =>
        _object('{"type": "text", "text": "PRIVATE_LIVE_PAYLOAD"}');
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveInitialTextContentPartParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveInitialTextContentPartParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.text, fixture()['text']);
      expect(model.toString(), contains('text:'));
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveInitialTextContentPartParam.fromJson(input);
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
      final model = LiveInitialTextContentPartParam.fromJson({
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
      final equal = LiveInitialTextContentPartParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveInitialTextContentPartParam.fromJson(fixture())));
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
          () => LiveInitialTextContentPartParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveInitialTextContentPartParam')),
        );
      }
    });
    test('text rejects wrong known values contextually', () {
      expect(
        () => LiveInitialTextContentPartParam.fromJson({
          ...fixture(),
          'text': 42,
        }),
        throwsA(_safeError('LiveInitialTextContentPartParam.text')),
      );
    });
    test('text is required and rejects null', () {
      expect(
        () =>
            LiveInitialTextContentPartParam.fromJson(fixture()..remove('text')),
        throwsA(_safeError('LiveInitialTextContentPartParam.text')),
      );
      expect(
        () => LiveInitialTextContentPartParam.fromJson({
          ...fixture(),
          'text': null,
        }),
        throwsA(_safeError('LiveInitialTextContentPartParam.text')),
      );
    });
    test('text typed copy wins over stale raw JSON', () {
      final model = LiveInitialTextContentPartParam.fromJson(fixture());
      final copied = model.copyWith(text: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['text'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () => LiveInitialTextContentPartParam.fromJson({
          ...fixture(),
          'type': 42,
        }),
        throwsA(_safeError('LiveInitialTextContentPartParam.type')),
      );
    });
    test('type omission and optional fixed presence survive copying', () {
      final absent = LiveInitialTextContentPartParam.fromJson(
        fixture()..remove('type'),
      );
      expect(absent.hasType, isFalse);
      expect(absent.toJson().containsKey('type'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.copyWith(hasType: true).toJson()['type'], 'text');
      expect(
        () => LiveInitialTextContentPartParam.fromJson({
          ...fixture(),
          'type': null,
        }),
        throwsA(_safeError('LiveInitialTextContentPartParam.type')),
      );
    });
  });

  group('LiveInitialOutputTextContentPartParam', () {
    Map<String, dynamic> fixture() =>
        _object('{"type": "output_text", "text": "PRIVATE_LIVE_PAYLOAD"}');
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveInitialOutputTextContentPartParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveInitialOutputTextContentPartParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.text, fixture()['text']);
      expect(model.toString(), contains('text:'));
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveInitialOutputTextContentPartParam.fromJson(input);
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
      final model = LiveInitialOutputTextContentPartParam.fromJson({
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
      final equal = LiveInitialOutputTextContentPartParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(
        model,
        isNot(LiveInitialOutputTextContentPartParam.fromJson(fixture())),
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
          () => LiveInitialOutputTextContentPartParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveInitialOutputTextContentPartParam')),
        );
      }
    });
    test('text rejects wrong known values contextually', () {
      expect(
        () => LiveInitialOutputTextContentPartParam.fromJson({
          ...fixture(),
          'text': 42,
        }),
        throwsA(_safeError('LiveInitialOutputTextContentPartParam.text')),
      );
    });
    test('text is required and rejects null', () {
      expect(
        () => LiveInitialOutputTextContentPartParam.fromJson(
          fixture()..remove('text'),
        ),
        throwsA(_safeError('LiveInitialOutputTextContentPartParam.text')),
      );
      expect(
        () => LiveInitialOutputTextContentPartParam.fromJson({
          ...fixture(),
          'text': null,
        }),
        throwsA(_safeError('LiveInitialOutputTextContentPartParam.text')),
      );
    });
    test('text typed copy wins over stale raw JSON', () {
      final model = LiveInitialOutputTextContentPartParam.fromJson(fixture());
      final copied = model.copyWith(text: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['text'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () => LiveInitialOutputTextContentPartParam.fromJson({
          ...fixture(),
          'type': 42,
        }),
        throwsA(_safeError('LiveInitialOutputTextContentPartParam.type')),
      );
    });
    test('type is required and rejects null', () {
      expect(
        () => LiveInitialOutputTextContentPartParam.fromJson(
          fixture()..remove('type'),
        ),
        throwsA(_safeError('LiveInitialOutputTextContentPartParam.type')),
      );
      expect(
        () => LiveInitialOutputTextContentPartParam.fromJson({
          ...fixture(),
          'type': null,
        }),
        throwsA(_safeError('LiveInitialOutputTextContentPartParam.type')),
      );
    });
  });

  group('LiveInitialDeveloperMessageItemParam', () {
    Map<String, dynamic> fixture() => _object(
      '{"role": "developer", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "input_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveInitialDeveloperMessageItemParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveInitialDeveloperMessageItemParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model.content.map((item) => item.toJson()).toList(),
        fixture()['content'],
      );
      expect(model.toString(), contains('content:'));
      expect(model.id, fixture()['id']);
      expect(model.toString(), contains('id:'));
      expect(model.hasId, isTrue);
      expect(model.role, fixture()['role']);
      expect(model.toString(), contains('role:'));
      expect(model.status?.toJson(), fixture()['status']);
      expect(model.toString(), contains('status:'));
      expect(model.hasStatus, isTrue);
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveInitialDeveloperMessageItemParam.fromJson(input);
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
      final model = LiveInitialDeveloperMessageItemParam.fromJson({
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
      final equal = LiveInitialDeveloperMessageItemParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(
        model,
        isNot(LiveInitialDeveloperMessageItemParam.fromJson(fixture())),
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
          () => LiveInitialDeveloperMessageItemParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveInitialDeveloperMessageItemParam')),
        );
      }
    });
    test('content rejects wrong known values contextually', () {
      expect(
        () => LiveInitialDeveloperMessageItemParam.fromJson({
          ...fixture(),
          'content': 42,
        }),
        throwsA(_safeError('LiveInitialDeveloperMessageItemParam.content')),
      );
    });
    test('content is required and rejects null', () {
      expect(
        () => LiveInitialDeveloperMessageItemParam.fromJson(
          fixture()..remove('content'),
        ),
        throwsA(_safeError('LiveInitialDeveloperMessageItemParam.content')),
      );
      expect(
        () => LiveInitialDeveloperMessageItemParam.fromJson({
          ...fixture(),
          'content': null,
        }),
        throwsA(_safeError('LiveInitialDeveloperMessageItemParam.content')),
      );
    });
    test('content typed copy wins over stale raw JSON', () {
      final model = LiveInitialDeveloperMessageItemParam.fromJson(fixture());
      final copied = model.copyWith(
        content: [
          LiveInitialInputTextContentPartParam.fromJson(
            _object('{"type": "input_text", "text": "ALTERNATE_LIVE_VALUE"}'),
          ),
        ],
      );
      expect(
        copied.toJson()['content'],
        jsonDecode('[{"type": "input_text", "text": "ALTERNATE_LIVE_VALUE"}]'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('id rejects wrong known values contextually', () {
      expect(
        () => LiveInitialDeveloperMessageItemParam.fromJson({
          ...fixture(),
          'id': 42,
        }),
        throwsA(_safeError('LiveInitialDeveloperMessageItemParam.id')),
      );
    });
    test('id omission, null and clearing follow schema', () {
      final absent = LiveInitialDeveloperMessageItemParam.fromJson(
        fixture()..remove('id'),
      );
      expect(absent.id, isNull);
      expect(absent.toJson().containsKey('id'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasId, isFalse);
      final explicit = absent.copyWith(id: null);
      expect(explicit.hasId, isTrue);
      expect(explicit.toJson().containsKey('id'), isTrue);
      expect(explicit.toJson()['id'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearId: true);
      expect(cleared.hasId, isFalse);
      expect(cleared, absent);
      expect(
        LiveInitialDeveloperMessageItemParam.fromJson({
          ...fixture(),
          'id': null,
        }).toJson()['id'],
        isNull,
      );
    });
    test('id typed copy wins over stale raw JSON', () {
      final model = LiveInitialDeveloperMessageItemParam.fromJson(fixture());
      final copied = model.copyWith(id: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['id'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(id: Object()),
        throwsA(_safeError('LiveInitialDeveloperMessageItemParam.id')),
      );
    });
    test('role rejects wrong known values contextually', () {
      expect(
        () => LiveInitialDeveloperMessageItemParam.fromJson({
          ...fixture(),
          'role': 42,
        }),
        throwsA(_safeError('LiveInitialDeveloperMessageItemParam.role')),
      );
    });
    test('role is required and rejects null', () {
      expect(
        () => LiveInitialDeveloperMessageItemParam.fromJson(
          fixture()..remove('role'),
        ),
        throwsA(_safeError('LiveInitialDeveloperMessageItemParam.role')),
      );
      expect(
        () => LiveInitialDeveloperMessageItemParam.fromJson({
          ...fixture(),
          'role': null,
        }),
        throwsA(_safeError('LiveInitialDeveloperMessageItemParam.role')),
      );
    });
    test('status rejects wrong known values contextually', () {
      expect(
        () => LiveInitialDeveloperMessageItemParam.fromJson({
          ...fixture(),
          'status': 42,
        }),
        throwsA(_safeError('LiveInitialDeveloperMessageItemParam.status')),
      );
    });
    test('status omission, null and clearing follow schema', () {
      final absent = LiveInitialDeveloperMessageItemParam.fromJson(
        fixture()..remove('status'),
      );
      expect(absent.status, isNull);
      expect(absent.toJson().containsKey('status'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasStatus, isFalse);
      final explicit = absent.copyWith(status: null);
      expect(explicit.hasStatus, isTrue);
      expect(explicit.toJson().containsKey('status'), isTrue);
      expect(explicit.toJson()['status'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearStatus: true);
      expect(cleared.hasStatus, isFalse);
      expect(cleared, absent);
      expect(
        LiveInitialDeveloperMessageItemParam.fromJson({
          ...fixture(),
          'status': null,
        }).toJson()['status'],
        isNull,
      );
    });
    test('status typed copy wins over stale raw JSON', () {
      final model = LiveInitialDeveloperMessageItemParam.fromJson(fixture());
      final copied = model.copyWith(
        status: LiveInitialMessageStatus.fromJson('incomplete'),
      );
      expect(copied.toJson()['status'], jsonDecode('"incomplete"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(status: Object()),
        throwsA(_safeError('LiveInitialDeveloperMessageItemParam.status')),
      );
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () => LiveInitialDeveloperMessageItemParam.fromJson({
          ...fixture(),
          'type': 42,
        }),
        throwsA(_safeError('LiveInitialDeveloperMessageItemParam.type')),
      );
    });
    test('type omission and optional fixed presence survive copying', () {
      final absent = LiveInitialDeveloperMessageItemParam.fromJson(
        fixture()..remove('type'),
      );
      expect(absent.hasType, isFalse);
      expect(absent.toJson().containsKey('type'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.copyWith(hasType: true).toJson()['type'], 'message');
      expect(
        () => LiveInitialDeveloperMessageItemParam.fromJson({
          ...fixture(),
          'type': null,
        }),
        throwsA(_safeError('LiveInitialDeveloperMessageItemParam.type')),
      );
    });
  });

  group('LiveInitialUserMessageItemParam', () {
    Map<String, dynamic> fixture() => _object(
      '{"role": "user", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "input_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveInitialUserMessageItemParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveInitialUserMessageItemParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model.content.map((item) => item.toJson()).toList(),
        fixture()['content'],
      );
      expect(model.toString(), contains('content:'));
      expect(model.id, fixture()['id']);
      expect(model.toString(), contains('id:'));
      expect(model.hasId, isTrue);
      expect(model.role, fixture()['role']);
      expect(model.toString(), contains('role:'));
      expect(model.status?.toJson(), fixture()['status']);
      expect(model.toString(), contains('status:'));
      expect(model.hasStatus, isTrue);
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveInitialUserMessageItemParam.fromJson(input);
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
      final model = LiveInitialUserMessageItemParam.fromJson({
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
      final equal = LiveInitialUserMessageItemParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveInitialUserMessageItemParam.fromJson(fixture())));
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
          () => LiveInitialUserMessageItemParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveInitialUserMessageItemParam')),
        );
      }
    });
    test('content rejects wrong known values contextually', () {
      expect(
        () => LiveInitialUserMessageItemParam.fromJson({
          ...fixture(),
          'content': 42,
        }),
        throwsA(_safeError('LiveInitialUserMessageItemParam.content')),
      );
    });
    test('content is required and rejects null', () {
      expect(
        () => LiveInitialUserMessageItemParam.fromJson(
          fixture()..remove('content'),
        ),
        throwsA(_safeError('LiveInitialUserMessageItemParam.content')),
      );
      expect(
        () => LiveInitialUserMessageItemParam.fromJson({
          ...fixture(),
          'content': null,
        }),
        throwsA(_safeError('LiveInitialUserMessageItemParam.content')),
      );
    });
    test('content typed copy wins over stale raw JSON', () {
      final model = LiveInitialUserMessageItemParam.fromJson(fixture());
      final copied = model.copyWith(
        content: [
          LiveInitialInputTextContentPartParam.fromJson(
            _object('{"type": "input_text", "text": "ALTERNATE_LIVE_VALUE"}'),
          ),
        ],
      );
      expect(
        copied.toJson()['content'],
        jsonDecode('[{"type": "input_text", "text": "ALTERNATE_LIVE_VALUE"}]'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('id rejects wrong known values contextually', () {
      expect(
        () =>
            LiveInitialUserMessageItemParam.fromJson({...fixture(), 'id': 42}),
        throwsA(_safeError('LiveInitialUserMessageItemParam.id')),
      );
    });
    test('id omission, null and clearing follow schema', () {
      final absent = LiveInitialUserMessageItemParam.fromJson(
        fixture()..remove('id'),
      );
      expect(absent.id, isNull);
      expect(absent.toJson().containsKey('id'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasId, isFalse);
      final explicit = absent.copyWith(id: null);
      expect(explicit.hasId, isTrue);
      expect(explicit.toJson().containsKey('id'), isTrue);
      expect(explicit.toJson()['id'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearId: true);
      expect(cleared.hasId, isFalse);
      expect(cleared, absent);
      expect(
        LiveInitialUserMessageItemParam.fromJson({
          ...fixture(),
          'id': null,
        }).toJson()['id'],
        isNull,
      );
    });
    test('id typed copy wins over stale raw JSON', () {
      final model = LiveInitialUserMessageItemParam.fromJson(fixture());
      final copied = model.copyWith(id: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['id'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(id: Object()),
        throwsA(_safeError('LiveInitialUserMessageItemParam.id')),
      );
    });
    test('role rejects wrong known values contextually', () {
      expect(
        () => LiveInitialUserMessageItemParam.fromJson({
          ...fixture(),
          'role': 42,
        }),
        throwsA(_safeError('LiveInitialUserMessageItemParam.role')),
      );
    });
    test('role is required and rejects null', () {
      expect(
        () =>
            LiveInitialUserMessageItemParam.fromJson(fixture()..remove('role')),
        throwsA(_safeError('LiveInitialUserMessageItemParam.role')),
      );
      expect(
        () => LiveInitialUserMessageItemParam.fromJson({
          ...fixture(),
          'role': null,
        }),
        throwsA(_safeError('LiveInitialUserMessageItemParam.role')),
      );
    });
    test('status rejects wrong known values contextually', () {
      expect(
        () => LiveInitialUserMessageItemParam.fromJson({
          ...fixture(),
          'status': 42,
        }),
        throwsA(_safeError('LiveInitialUserMessageItemParam.status')),
      );
    });
    test('status omission, null and clearing follow schema', () {
      final absent = LiveInitialUserMessageItemParam.fromJson(
        fixture()..remove('status'),
      );
      expect(absent.status, isNull);
      expect(absent.toJson().containsKey('status'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasStatus, isFalse);
      final explicit = absent.copyWith(status: null);
      expect(explicit.hasStatus, isTrue);
      expect(explicit.toJson().containsKey('status'), isTrue);
      expect(explicit.toJson()['status'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearStatus: true);
      expect(cleared.hasStatus, isFalse);
      expect(cleared, absent);
      expect(
        LiveInitialUserMessageItemParam.fromJson({
          ...fixture(),
          'status': null,
        }).toJson()['status'],
        isNull,
      );
    });
    test('status typed copy wins over stale raw JSON', () {
      final model = LiveInitialUserMessageItemParam.fromJson(fixture());
      final copied = model.copyWith(
        status: LiveInitialMessageStatus.fromJson('incomplete'),
      );
      expect(copied.toJson()['status'], jsonDecode('"incomplete"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(status: Object()),
        throwsA(_safeError('LiveInitialUserMessageItemParam.status')),
      );
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () => LiveInitialUserMessageItemParam.fromJson({
          ...fixture(),
          'type': 42,
        }),
        throwsA(_safeError('LiveInitialUserMessageItemParam.type')),
      );
    });
    test('type omission and optional fixed presence survive copying', () {
      final absent = LiveInitialUserMessageItemParam.fromJson(
        fixture()..remove('type'),
      );
      expect(absent.hasType, isFalse);
      expect(absent.toJson().containsKey('type'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.copyWith(hasType: true).toJson()['type'], 'message');
      expect(
        () => LiveInitialUserMessageItemParam.fromJson({
          ...fixture(),
          'type': null,
        }),
        throwsA(_safeError('LiveInitialUserMessageItemParam.type')),
      );
    });
  });

  group('LiveInitialAssistantMessageItemParam', () {
    Map<String, dynamic> fixture() => _object(
      '{"role": "assistant", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "output_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveInitialAssistantMessageItemParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveInitialAssistantMessageItemParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model.content.map((item) => item.toJson()).toList(),
        fixture()['content'],
      );
      expect(model.toString(), contains('content:'));
      expect(model.id, fixture()['id']);
      expect(model.toString(), contains('id:'));
      expect(model.hasId, isTrue);
      expect(model.role, fixture()['role']);
      expect(model.toString(), contains('role:'));
      expect(model.status?.toJson(), fixture()['status']);
      expect(model.toString(), contains('status:'));
      expect(model.hasStatus, isTrue);
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveInitialAssistantMessageItemParam.fromJson(input);
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
      final model = LiveInitialAssistantMessageItemParam.fromJson({
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
      final equal = LiveInitialAssistantMessageItemParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(
        model,
        isNot(LiveInitialAssistantMessageItemParam.fromJson(fixture())),
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
          () => LiveInitialAssistantMessageItemParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveInitialAssistantMessageItemParam')),
        );
      }
    });
    test('content rejects wrong known values contextually', () {
      expect(
        () => LiveInitialAssistantMessageItemParam.fromJson({
          ...fixture(),
          'content': 42,
        }),
        throwsA(_safeError('LiveInitialAssistantMessageItemParam.content')),
      );
    });
    test('content is required and rejects null', () {
      expect(
        () => LiveInitialAssistantMessageItemParam.fromJson(
          fixture()..remove('content'),
        ),
        throwsA(_safeError('LiveInitialAssistantMessageItemParam.content')),
      );
      expect(
        () => LiveInitialAssistantMessageItemParam.fromJson({
          ...fixture(),
          'content': null,
        }),
        throwsA(_safeError('LiveInitialAssistantMessageItemParam.content')),
      );
    });
    test('content typed copy wins over stale raw JSON', () {
      final model = LiveInitialAssistantMessageItemParam.fromJson(fixture());
      final copied = model.copyWith(
        content: [
          LiveInitialAssistantContentPart.fromJson(
            _object('{"type": "output_text", "text": "ALTERNATE_LIVE_VALUE"}'),
          ),
        ],
      );
      expect(
        copied.toJson()['content'],
        jsonDecode('[{"type": "output_text", "text": "ALTERNATE_LIVE_VALUE"}]'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('id rejects wrong known values contextually', () {
      expect(
        () => LiveInitialAssistantMessageItemParam.fromJson({
          ...fixture(),
          'id': 42,
        }),
        throwsA(_safeError('LiveInitialAssistantMessageItemParam.id')),
      );
    });
    test('id omission, null and clearing follow schema', () {
      final absent = LiveInitialAssistantMessageItemParam.fromJson(
        fixture()..remove('id'),
      );
      expect(absent.id, isNull);
      expect(absent.toJson().containsKey('id'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasId, isFalse);
      final explicit = absent.copyWith(id: null);
      expect(explicit.hasId, isTrue);
      expect(explicit.toJson().containsKey('id'), isTrue);
      expect(explicit.toJson()['id'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearId: true);
      expect(cleared.hasId, isFalse);
      expect(cleared, absent);
      expect(
        LiveInitialAssistantMessageItemParam.fromJson({
          ...fixture(),
          'id': null,
        }).toJson()['id'],
        isNull,
      );
    });
    test('id typed copy wins over stale raw JSON', () {
      final model = LiveInitialAssistantMessageItemParam.fromJson(fixture());
      final copied = model.copyWith(id: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['id'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(id: Object()),
        throwsA(_safeError('LiveInitialAssistantMessageItemParam.id')),
      );
    });
    test('role rejects wrong known values contextually', () {
      expect(
        () => LiveInitialAssistantMessageItemParam.fromJson({
          ...fixture(),
          'role': 42,
        }),
        throwsA(_safeError('LiveInitialAssistantMessageItemParam.role')),
      );
    });
    test('role is required and rejects null', () {
      expect(
        () => LiveInitialAssistantMessageItemParam.fromJson(
          fixture()..remove('role'),
        ),
        throwsA(_safeError('LiveInitialAssistantMessageItemParam.role')),
      );
      expect(
        () => LiveInitialAssistantMessageItemParam.fromJson({
          ...fixture(),
          'role': null,
        }),
        throwsA(_safeError('LiveInitialAssistantMessageItemParam.role')),
      );
    });
    test('status rejects wrong known values contextually', () {
      expect(
        () => LiveInitialAssistantMessageItemParam.fromJson({
          ...fixture(),
          'status': 42,
        }),
        throwsA(_safeError('LiveInitialAssistantMessageItemParam.status')),
      );
    });
    test('status omission, null and clearing follow schema', () {
      final absent = LiveInitialAssistantMessageItemParam.fromJson(
        fixture()..remove('status'),
      );
      expect(absent.status, isNull);
      expect(absent.toJson().containsKey('status'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasStatus, isFalse);
      final explicit = absent.copyWith(status: null);
      expect(explicit.hasStatus, isTrue);
      expect(explicit.toJson().containsKey('status'), isTrue);
      expect(explicit.toJson()['status'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearStatus: true);
      expect(cleared.hasStatus, isFalse);
      expect(cleared, absent);
      expect(
        LiveInitialAssistantMessageItemParam.fromJson({
          ...fixture(),
          'status': null,
        }).toJson()['status'],
        isNull,
      );
    });
    test('status typed copy wins over stale raw JSON', () {
      final model = LiveInitialAssistantMessageItemParam.fromJson(fixture());
      final copied = model.copyWith(
        status: LiveInitialMessageStatus.fromJson('incomplete'),
      );
      expect(copied.toJson()['status'], jsonDecode('"incomplete"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(status: Object()),
        throwsA(_safeError('LiveInitialAssistantMessageItemParam.status')),
      );
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () => LiveInitialAssistantMessageItemParam.fromJson({
          ...fixture(),
          'type': 42,
        }),
        throwsA(_safeError('LiveInitialAssistantMessageItemParam.type')),
      );
    });
    test('type omission and optional fixed presence survive copying', () {
      final absent = LiveInitialAssistantMessageItemParam.fromJson(
        fixture()..remove('type'),
      );
      expect(absent.hasType, isFalse);
      expect(absent.toJson().containsKey('type'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.copyWith(hasType: true).toJson()['type'], 'message');
      expect(
        () => LiveInitialAssistantMessageItemParam.fromJson({
          ...fixture(),
          'type': null,
        }),
        throwsA(_safeError('LiveInitialAssistantMessageItemParam.type')),
      );
    });
  });

  group('LiveInitialMessageStatus', () {
    final wires = ['incomplete', 'completed'];
    for (final wire in wires) {
      test('canonical $wire round-trip', () {
        final value = LiveInitialMessageStatus.fromJson(wire);
        expect(value.toJson(), wire);
        expect(value, LiveInitialMessageStatus.fromJson(wire));
        expect(
          value.hashCode,
          LiveInitialMessageStatus.fromJson(wire).hashCode,
        );
      });
    }
    test('closed values reject unknown input privately', () {
      expect(
        () => LiveInitialMessageStatus.fromJson(_private),
        throwsA(_safeError('LiveInitialMessageStatus')),
      );
    });
  });
}
