import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _alertJson() => {
  'id': 'alert-id-private',
  'object': 'safety.alert',
  'created_at': -7,
  'request_id': 'request-id-private',
  'response_id': 'response-id-private',
  'model': 'model-private',
  'request_paused': false,
  'error_type': 'potentially_unintended_data_transfer',
  'reason': 'reason-private',
};

Map<String, dynamic> _caseJson() => {
  'id': 'case-id-private',
  'object': 'safety.case',
  'created_at': -7,
  'entity_identifier': 'application-entity-private',
  'reason': 'reason-private',
  'notice': {'type': 'warning'},
};

class _Adapter {
  const _Adapter({
    required this.fixture,
    required this.parse,
    required this.json,
    required this.copy,
    required this.withRaw,
    required this.badFields,
    required this.knownFields,
  });

  final Map<String, dynamic> Function() fixture;
  final Object Function(Map<String, dynamic>) parse;
  final Map<String, dynamic> Function(Object) json;
  final Object Function(Object) copy;
  final Object Function(Object, Map<String, dynamic>) withRaw;
  final Map<String, Object?> badFields;
  final Set<String> knownFields;
}

void main() {
  final adapters = <String, _Adapter>{
    'SafetyAlert': _Adapter(
      fixture: _alertJson,
      parse: SafetyAlert.fromJson,
      json: (value) => (value as SafetyAlert).toJson(),
      copy: (value) => (value as SafetyAlert).copyWith(),
      withRaw: (value, raw) => (value as SafetyAlert).copyWith(rawJson: raw),
      badFields: {
        'id': {'private-value': true},
        'object': 'private-wrong-object',
        'created_at': 1.5,
        'request_id': ['private-value'],
        'response_id': false,
        'model': 1,
        'request_paused': 'private-wrong-boolean',
        'error_type': ['private-value'],
        'reason': {'private-value': true},
      },
      knownFields: {..._alertJson().keys, 'detailed_explanation'},
    ),
    'SafetyCase': _Adapter(
      fixture: _caseJson,
      parse: SafetyCase.fromJson,
      json: (value) => (value as SafetyCase).toJson(),
      copy: (value) => (value as SafetyCase).copyWith(),
      withRaw: (value, raw) => (value as SafetyCase).copyWith(rawJson: raw),
      badFields: {
        'id': ['private-value'],
        'object': 'private-wrong-object',
        'created_at': 1.5,
        'entity_identifier': {'private-value': true},
        'reason': false,
        'notice': 'private-wrong-object',
      },
      knownFields: _caseJson().keys.toSet(),
    ),
    'SafetyCaseNotice': _Adapter(
      fixture: () => {'type': 'warning'},
      parse: SafetyCaseNotice.fromJson,
      json: (value) => (value as SafetyCaseNotice).toJson(),
      copy: (value) => (value as SafetyCaseNotice).copyWith(),
      withRaw: (value, raw) =>
          (value as SafetyCaseNotice).copyWith(rawJson: raw),
      badFields: {
        'type': ['private-value'],
      },
      knownFields: const {'type'},
    ),
  };

  for (final entry in adapters.entries) {
    final name = entry.key;
    final adapter = entry.value;
    group(name, () {
      test(
        'canonical fixture round-trips with full copy and equality/hash',
        () {
          final json = adapter.fixture();
          final value = adapter.parse(json);
          final reparsed = adapter.parse(adapter.json(value));
          final copied = adapter.copy(value);
          expect(adapter.json(value), json);
          expect(value, reparsed);
          expect(value.hashCode, reparsed.hashCode);
          expect(copied, value);
          expect(copied.hashCode, value.hashCode);
          expect(value == Object(), isFalse);
          expect({value: true}[reparsed], isTrue);
        },
      );

      for (final field in adapter.badFields.entries) {
        test('required ${field.key} rejects absence', () {
          final json = adapter.fixture()..remove(field.key);
          expect(
            () => adapter.parse(json),
            throwsA(
              isA<FormatException>().having(
                (error) => error.message,
                'field context',
                contains('$name.${field.key}'),
              ),
            ),
          );
        });

        if (field.key != 'reason') {
          test('nonnullable ${field.key} rejects explicit null', () {
            final json = adapter.fixture()..[field.key] = null;
            expect(() => adapter.parse(json), throwsFormatException);
          });
        }

        test('${field.key} rejects malformed type with safe context', () {
          final json = adapter.fixture()..[field.key] = field.value;
          try {
            adapter.parse(json);
            fail('Expected a contextual FormatException');
          } on FormatException catch (error) {
            expect(error.message, contains('$name.${field.key}'));
            expect(error.source, isNull);
            expect(error.offset, isNull);
            expect(error.toString(), isNot(contains('private-')));
          }
        });
      }

      test('future metadata is owned deeply and survives copies', () {
        final metadata = <String, dynamic>{
          'items': <Object?>[
            <String, dynamic>{'private-key': 'private-value'},
            null,
            1.25,
            true,
          ],
        };
        final json = adapter.fixture()..['future-private'] = metadata;
        final value = adapter.parse(json);
        final expected = jsonDecode(jsonEncode(json));
        (metadata['items'] as List<Object?>)[0] = 'changed';
        json['future-private'] = false;
        expect(adapter.json(value), expected);
        expect(adapter.json(adapter.copy(value)), expected);
        final frozen = adapter.json(value);
        expect(() => frozen['x'] = true, throwsUnsupportedError);
        final frozenMetadata = frozen['future-private'] as Map<String, dynamic>;
        expect(() => frozenMetadata['x'] = true, throwsUnsupportedError);
        final frozenItems = frozenMetadata['items'] as List<Object?>;
        expect(() => frozenItems.add(true), throwsUnsupportedError);
        expect(
          () => (frozenItems.first! as Map<String, dynamic>)['x'] = true,
          throwsUnsupportedError,
        );
        expect(value.toString(), isNot(contains('private-')));
      });

      test('constructor copy owns raw metadata and supports clearing it', () {
        final value = adapter.parse(adapter.fixture());
        final nested = <String, dynamic>{
          'items': <Object?>['private-value'],
        };
        final raw = <String, dynamic>{'future': nested};
        final extended = adapter.withRaw(value, raw);
        (nested['items'] as List<Object?>).add(true);
        raw.clear();
        expect(adapter.json(extended)['future'], {
          'items': ['private-value'],
        });
        final cleared = adapter.withRaw(extended, {});
        expect(cleared, value);
        expect(cleared.hashCode, value.hashCode);
      });

      test(
        'typed fields win over stale known raw fields in effective value',
        () {
          final value = adapter.parse(adapter.fixture());
          final stale = <String, dynamic>{
            for (final key in adapter.knownFields) key: 'private-stale-value',
          };
          final copied = adapter.withRaw(value, stale);
          expect(copied, value);
          expect(copied.hashCode, value.hashCode);
          expect(adapter.json(copied), adapter.json(value));
        },
      );

      test('future nested metadata participates in equality and hashing', () {
        final value = adapter.parse(adapter.fixture());
        final first = adapter.withRaw(value, {
          'b': 2,
          'a': {
            'items': [1, null, true],
          },
        });
        final same = adapter.withRaw(value, {
          'a': {
            'items': [1, null, true],
          },
          'b': 2,
        });
        final different = adapter.withRaw(value, {
          'a': {
            'items': [1, null, false],
          },
          'b': 2,
        });
        expect(first, same);
        expect(first.hashCode, same.hashCode);
        expect(first, isNot(different));
        expect({first: true}[same], isTrue);
      });

      final invalidMetadata = <String, Object?>{
        'nonfinite NaN': double.nan,
        'nonfinite positive infinity': double.infinity,
        'nonfinite negative infinity': double.negativeInfinity,
        'non-JSON object': Object(),
        'nonstring map key': <Object, Object?>{1: 'private-value'},
      };
      for (final invalid in invalidMetadata.entries) {
        test('rejects ${invalid.key} in parsed and constructed metadata', () {
          final json = adapter.fixture()..['future-private'] = invalid.value;
          expect(() => adapter.parse(json), throwsFormatException);
          final value = adapter.parse(adapter.fixture());
          expect(
            () => adapter.withRaw(value, {'future-private': invalid.value}),
            throwsFormatException,
          );
        });
      }

      for (final listCycle in [false, true]) {
        test('rejects ${listCycle ? 'list' : 'map'} cycle safely', () {
          final cyclic = <String, dynamic>{};
          if (listCycle) {
            final children = <Object?>[cyclic];
            cyclic['private-key'] = children;
          } else {
            cyclic['private-key'] = cyclic;
          }
          final json = adapter.fixture()..['future-private'] = cyclic;
          expect(
            () => adapter.parse(json),
            throwsA(
              isA<FormatException>().having(
                (error) => error.toString(),
                'safe diagnostics',
                isNot(contains('private-')),
              ),
            ),
          );
          final value = adapter.parse(adapter.fixture());
          expect(() => adapter.withRaw(value, cyclic), throwsFormatException);
        });
      }

      test(
        'shared acyclic metadata is accepted without false cycle errors',
        () {
          final shared = <String, dynamic>{
            'items': <Object?>[1, null],
          };
          final json = adapter.fixture()
            ..['first'] = shared
            ..['second'] = shared;
          final value = adapter.parse(json);
          expect(adapter.json(value), json);
        },
      );

      test(
        'diagnostics include every field without disclosing opaque values',
        () {
          final value = adapter.parse(adapter.fixture());
          final description = value.toString();
          for (final field in switch (name) {
            'SafetyAlert' => [
              'id',
              'object',
              'createdAt',
              'requestId',
              'responseId',
              'model',
              'requestPaused',
              'errorType',
              'rawErrorType',
              'reason',
              'detailedExplanation',
              'hasDetailedExplanation',
              'rawJson',
            ],
            'SafetyCase' => [
              'id',
              'object',
              'createdAt',
              'entityIdentifier',
              'reason',
              'notice',
              'rawJson',
            ],
            _ => ['type', 'rawType', 'rawJson'],
          }) {
            expect(description, contains('$field:'));
          }
          expect(description, isNot(contains('private-')));
        },
      );
    });
  }

  group('SafetyAlert optional nullable explanations', () {
    final states = <String, ({bool present, String? value})>{
      'absent': (present: false, value: null),
      'explicit null': (present: true, value: null),
      'empty string': (present: true, value: ''),
      'text': (present: true, value: 'explanation-private'),
      'Unicode': (present: true, value: '説明-private-😀'),
    };
    for (final entry in states.entries) {
      test('${entry.key} preserves wire presence and effective value', () {
        final state = entry.value;
        final json = _alertJson();
        if (state.present) json['detailed_explanation'] = state.value;
        final value = SafetyAlert.fromJson(json);
        final constructed = _constructAlert({
          if (state.present) #detailedExplanation: state.value,
        });
        expect(value.hasDetailedExplanation, state.present);
        expect(value.detailedExplanation, state.value);
        expect(value.toJson(), json);
        expect(constructed, value);
        expect(constructed.hashCode, value.hashCode);
        expect(value.copyWith(), value);
        expect(value.copyWith().hashCode, value.hashCode);
        final roundtrip = SafetyAlert.fromJson(value.toJson());
        expect(roundtrip, value);
        expect(roundtrip.hashCode, value.hashCode);
        expect({value: true}[roundtrip], isTrue);
        final description = value.toString();
        expect(
          description,
          contains('hasDetailedExplanation: ${state.present}'),
        );
        expect(
          description,
          contains(
            'detailedExplanation: ${!state.present
                ? 'absent'
                : state.value == null
                ? 'null'
                : '[redacted]'}',
          ),
        );
        expect(description, isNot(contains('private')));
      });

      test('${entry.key} copy supports preserve, null, replace and remove', () {
        final state = entry.value;
        final json = _alertJson();
        if (state.present) json['detailed_explanation'] = state.value;
        final value = SafetyAlert.fromJson(json);
        final retained = value.copyWith(
          rawJson: {'detailed_explanation': 'stale-private'},
        );
        expect(retained, value);
        expect(retained.hashCode, value.hashCode);
        expect(retained.toJson(), json);

        final nullCopy = value.copyWith(detailedExplanation: null);
        expect(nullCopy.hasDetailedExplanation, isTrue);
        expect(nullCopy.detailedExplanation, isNull);
        expect(
          nullCopy.toJson(),
          _alertJson()..['detailed_explanation'] = null,
        );
        final replaced = value.copyWith(
          detailedExplanation: 'replacement-private',
        );
        expect(replaced.hasDetailedExplanation, isTrue);
        expect(replaced.detailedExplanation, 'replacement-private');
        expect(
          replaced.toJson(),
          _alertJson()..['detailed_explanation'] = 'replacement-private',
        );
        final cleared = value.copyWith(hasDetailedExplanation: false);
        expect(cleared.hasDetailedExplanation, isFalse);
        expect(cleared.detailedExplanation, isNull);
        expect(cleared.toJson(), _alertJson());
        expect(cleared.copyWith(), cleared);
        expect(
          cleared.copyWith(
            rawJson: {'detailed_explanation': 'resurrection-private'},
          ),
          cleared,
        );
        expect(cleared.copyWith().hashCode, cleared.hashCode);
        final reinstatedNull = cleared.copyWith(hasDetailedExplanation: true);
        expect(reinstatedNull, nullCopy);
        expect(reinstatedNull.hashCode, nullCopy.hashCode);
      });
    }

    test('all explanation states are distinct in equality and hash keys', () {
      final values = [
        for (final state in states.values)
          _constructAlert({
            if (state.present) #detailedExplanation: state.value,
          }),
      ];
      expect(values.toSet(), hasLength(states.length));
      expect({
        for (final value in values) value: true,
      }, hasLength(states.length));
      for (final value in values) {
        final restored = SafetyAlert.fromJson(value.toJson());
        expect(restored, value);
        expect(restored.hashCode, value.hashCode);
      }
    });

    for (final value in <String?>[null, '', 'raw-private']) {
      test(
        'raw-only construction adopts valid ${value == null
            ? 'null'
            : value.isEmpty
            ? 'empty string'
            : 'text'}',
        () {
          final raw = <String, dynamic>{'detailed_explanation': value};
          final alert = _constructAlert({#rawJson: raw});
          expect(alert.hasDetailedExplanation, isTrue);
          expect(alert.detailedExplanation, value);
          expect(
            alert.toJson(),
            _alertJson()..['detailed_explanation'] = value,
          );
          raw['detailed_explanation'] = 'mutated-private';
          expect(alert.detailedExplanation, value);
          expect(alert.rawJson['detailed_explanation'], value);
          expect(alert.copyWith(rawJson: {}), alert);
        },
      );
    }

    test('explicit construction controls win over valid known raw values', () {
      final raw = <String, dynamic>{'detailed_explanation': 'raw-private'};
      final explicit = _constructAlert({
        #rawJson: raw,
        #detailedExplanation: 'typed-private',
      });
      expect(explicit.detailedExplanation, 'typed-private');
      expect(explicit.toJson()['detailed_explanation'], 'typed-private');
      final explicitNull = _constructAlert({
        #rawJson: raw,
        #detailedExplanation: null,
      });
      expect(explicitNull.hasDetailedExplanation, isTrue);
      expect(explicitNull.detailedExplanation, isNull);
      expect(explicitNull.toJson()['detailed_explanation'], isNull);
      final presenceNull = _constructAlert({
        #rawJson: raw,
        #hasDetailedExplanation: true,
      });
      expect(presenceNull, explicitNull);
      final absent = _constructAlert({
        #rawJson: raw,
        #hasDetailedExplanation: false,
      });
      expect(absent.detailedExplanation, isNull);
      expect(absent.hasDetailedExplanation, isFalse);
      expect(absent.toJson(), _alertJson());
      expect(absent.copyWith(rawJson: raw), absent);
    });

    test('false presence cannot conceal an explicit nonnull explanation', () {
      for (final action in <void Function()>[
        () => _constructAlert({
          #detailedExplanation: 'value-private',
          #hasDetailedExplanation: false,
        }),
        () => SafetyAlert.fromJson(_alertJson()).copyWith(
          detailedExplanation: 'value-private',
          hasDetailedExplanation: false,
        ),
      ]) {
        expect(action, _privateExplanationError());
      }
      final absent = _constructAlert({
        #detailedExplanation: null,
        #hasDetailedExplanation: false,
      });
      expect(absent.toJson(), _alertJson());
    });

    final malformed = <String, Object?>{
      'integer': 7,
      'fraction': 1.5,
      'boolean': false,
      'array': ['value-private'],
      'object': {'key-private': 'value-private'},
    };
    for (final entry in malformed.entries) {
      test(
        '${entry.key} explanation fails parsing, construction and copies privately',
        () {
          final good = _constructAlert({#detailedExplanation: 'typed-private'});
          for (final action in <void Function()>[
            () => SafetyAlert.fromJson(
              _alertJson()..['detailed_explanation'] = entry.value,
            ),
            () => _constructAlert({#detailedExplanation: entry.value}),
            () => good.copyWith(detailedExplanation: entry.value),
            () => _constructAlert({
              #detailedExplanation: null,
              #hasDetailedExplanation: false,
              #rawJson: {'detailed_explanation': entry.value},
            }),
            () => _constructAlert({
              #detailedExplanation: 'typed-private',
              #rawJson: {'detailed_explanation': entry.value},
            }),
            () => good.copyWith(rawJson: {'detailed_explanation': entry.value}),
            () => good.copyWith(
              hasDetailedExplanation: false,
              rawJson: {'detailed_explanation': entry.value},
            ),
          ]) {
            expect(action, _privateExplanationError());
          }
        },
      );
    }

    test(
      'explanation edits retain owned finite future data and required reason',
      () {
        final future = <String, dynamic>{
          'items': <Object?>['metadata-private'],
        };
        final json = _alertJson()
          ..['reason'] = null
          ..['detailed_explanation'] = 'explanation-private'
          ..['future'] = future;
        final alert = SafetyAlert.fromJson(json);
        (future['items'] as List<Object?>).clear();
        json['detailed_explanation'] = 'mutated-private';
        final cleared = alert.copyWith(hasDetailedExplanation: false);
        expect(alert.detailedExplanation, 'explanation-private');
        expect(cleared.reason, isNull);
        expect(cleared.toJson().containsKey('reason'), isTrue);
        expect(cleared.toJson()['future'], {
          'items': ['metadata-private'],
        });
        expect(() => alert.rawJson['future'] = null, throwsUnsupportedError);
        expect(
          () =>
              (alert.rawJson['future'] as Map<String, dynamic>)['items'] = null,
          throwsUnsupportedError,
        );
        expect(
          () =>
              ((alert.rawJson['future'] as Map<String, dynamic>)['items']
                      as List)
                  .clear(),
          throwsUnsupportedError,
        );
        expect(cleared.toString(), isNot(contains('private')));
        expect(
          () => SafetyAlert.fromJson({...alert.toJson()}..remove('reason')),
          throwsFormatException,
        );
      },
    );
  });

  group('SafetyAlert required values and enum choices', () {
    final choices = <String, SafetyAlertErrorType>{
      'potentially_unintended_data_transfer':
          SafetyAlertErrorType.potentiallyUnintendedDataTransfer,
      'potentially_unintended_data_access':
          SafetyAlertErrorType.potentiallyUnintendedDataAccess,
      'potentially_unintended_destructive_activity':
          SafetyAlertErrorType.potentiallyUnintendedDestructiveActivity,
      'other': SafetyAlertErrorType.other,
    };
    for (final choice in choices.entries) {
      test(
        'known error type ${choice.key} round-trips without raw fallback',
        () {
          expect(SafetyAlertErrorType.fromJson(choice.key), choice.value);
          expect(choice.value.toJson(), choice.key);
          final json = _alertJson()..['error_type'] = choice.key;
          final value = SafetyAlert.fromJson(json);
          expect(value.errorType, choice.value);
          expect(value.rawErrorType, isNull);
          expect(value.toJson(), json);
          final reparsed = SafetyAlert.fromJson(value.toJson());
          expect(reparsed, value);
          expect(reparsed.hashCode, value.hashCode);
        },
      );
    }

    test('required null reason and false requestPaused remain explicit', () {
      final json = _alertJson()..['reason'] = null;
      final value = SafetyAlert.fromJson(json);
      expect(value.reason, isNull);
      expect(value.requestPaused, isFalse);
      expect(value.toJson().containsKey('reason'), isTrue);
      expect(value.toJson()['reason'], isNull);
      expect(value.toJson()['request_paused'], isFalse);
      expect(value.toJson(), json);
      expect(value.toString(), contains('reason: null'));
    });

    for (final raw in ['future-private-category', '', 'unknown']) {
      test('unknown error value "$raw" is preserved without normalization', () {
        final json = _alertJson()..['error_type'] = raw;
        final value = SafetyAlert.fromJson(json);
        expect(
          SafetyAlertErrorType.fromJson(raw),
          SafetyAlertErrorType.unknown,
        );
        expect(value.errorType, SafetyAlertErrorType.unknown);
        expect(value.rawErrorType, raw);
        expect(value.toJson()['error_type'], raw);
        expect(value.toJson(), json);
        expect(value.toString(), isNot(contains('future-private-category')));
        expect(SafetyAlert.fromJson(value.toJson()), value);
        expect(value.copyWith(), value);
      });
    }

    test(
      'unknown error type replacement is distinct and known transition clears raw',
      () {
        final first = SafetyAlert.fromJson(
          _alertJson()..['error_type'] = 'future-private-category',
        );
        final second = first.copyWith(rawErrorType: 'another-private-category');
        expect(second, isNot(first));
        expect(second.toJson()['error_type'], 'another-private-category');
        final known = first.copyWith(errorType: SafetyAlertErrorType.other);
        expect(known.rawErrorType, isNull);
        expect(known.toJson()['error_type'], 'other');
        final back = known.copyWith(
          errorType: SafetyAlertErrorType.unknown,
          rawErrorType: 'future-private-category',
        );
        expect(back, first);
        expect(back.hashCode, first.hashCode);
        expect(
          first.copyWith(
            errorType: SafetyAlertErrorType.other,
            rawErrorType: null,
          ),
          known,
        );
      },
    );

    test('raw error companion rejects incoherent choices with safe errors', () {
      final known = SafetyAlert.fromJson(_alertJson());
      final unknown = known.copyWith(
        errorType: SafetyAlertErrorType.unknown,
        rawErrorType: 'future-private-category',
      );
      for (final action in <void Function()>[
        () => known.copyWith(errorType: SafetyAlertErrorType.unknown),
        () => known.copyWith(rawErrorType: 'private-wrong-companion'),
        () => unknown.copyWith(rawErrorType: null),
        () => unknown.copyWith(rawErrorType: 'other'),
        () => unknown.copyWith(rawErrorType: false),
      ]) {
        expect(
          action,
          throwsA(
            isA<FormatException>().having(
              (error) => error.toString(),
              'safe diagnostics',
              isNot(contains('private-')),
            ),
          ),
        );
      }
    });

    test('all alert fields can be replaced without stale raw values', () {
      final base = SafetyAlert.fromJson(_alertJson());
      final variants = <String, (SafetyAlert, Object?)>{
        'id': (base.copyWith(id: 'new-id'), 'new-id'),
        'created_at': (base.copyWith(createdAt: 42), 42),
        'request_id': (base.copyWith(requestId: 'new-request'), 'new-request'),
        'response_id': (
          base.copyWith(responseId: 'new-response'),
          'new-response',
        ),
        'model': (base.copyWith(model: 'new-model'), 'new-model'),
        'request_paused': (base.copyWith(requestPaused: true), true),
        'error_type': (
          base.copyWith(errorType: SafetyAlertErrorType.other),
          'other',
        ),
        'reason': (base.copyWith(reason: 'new-reason'), 'new-reason'),
        'detailed_explanation': (
          base.copyWith(detailedExplanation: 'new-explanation'),
          'new-explanation',
        ),
      };
      for (final entry in variants.entries) {
        final (copy, replacement) = entry.value;
        final expected = _alertJson()..[entry.key] = replacement;
        expect(copy.toJson(), expected);
        expect(copy, isNot(base));
        expect(SafetyAlert.fromJson(copy.toJson()), copy);
        expect(SafetyAlert.fromJson(copy.toJson()).hashCode, copy.hashCode);
      }
      final cleared = base.copyWith(reason: null);
      expect(cleared.reason, isNull);
      expect(cleared.toJson(), _alertJson()..['reason'] = null);
      expect(() => base.copyWith(reason: false), throwsFormatException);
    });

    test('DTO IDs have no invented grammar or resource-path length bound', () {
      for (final id in ['', '.', '..', 'any /%?# identifier', '😀' * 129]) {
        final value = SafetyAlert.fromJson(_alertJson()..['id'] = id);
        expect(value.id, id);
        expect(value.toJson()['id'], id);
      }
    });
  });

  group('SafetyCaseNotice enum choices and replacement', () {
    for (final type in [
      SafetyCaseNoticeType.warning,
      SafetyCaseNoticeType.deactivation,
    ]) {
      test('known ${type.value} notice round-trips without raw fallback', () {
        expect(SafetyCaseNoticeType.fromJson(type.value), type);
        expect(type.toJson(), type.value);
        final json = <String, dynamic>{'type': type.value};
        final notice = SafetyCaseNotice.fromJson(json);
        expect(notice.type, type);
        expect(notice.rawType, isNull);
        expect(notice.toJson(), json);
        expect(notice.copyWith(), notice);
        expect(
          SafetyCaseNotice.fromJson(notice.toJson()).hashCode,
          notice.hashCode,
        );
      });
    }

    for (final raw in ['future-private-notice', '', 'unknown']) {
      test(
        'unknown notice "$raw" preserves raw value and safe diagnostics',
        () {
          final json = <String, dynamic>{'type': raw};
          final notice = SafetyCaseNotice.fromJson(json);
          expect(
            SafetyCaseNoticeType.fromJson(raw),
            SafetyCaseNoticeType.unknown,
          );
          expect(notice.type, SafetyCaseNoticeType.unknown);
          expect(notice.rawType, raw);
          expect(notice.toJson(), json);
          expect(notice.copyWith(), notice);
          expect(SafetyCaseNotice.fromJson(notice.toJson()), notice);
          expect(notice.toString(), isNot(contains('future-private-notice')));
        },
      );
    }

    test(
      'notice raw replacement and known transition preserve coherent state',
      () {
        final first = SafetyCaseNotice.fromJson(const {
          'type': 'future-private-notice',
        });
        final second = first.copyWith(rawType: 'another-private-notice');
        expect(second, isNot(first));
        expect(second.toJson(), {'type': 'another-private-notice'});
        final known = first.copyWith(type: SafetyCaseNoticeType.deactivation);
        expect(known.rawType, isNull);
        expect(known.toJson(), {'type': 'deactivation'});
        final back = known.copyWith(
          type: SafetyCaseNoticeType.unknown,
          rawType: 'future-private-notice',
        );
        expect(back, first);
        expect(back.hashCode, first.hashCode);
        expect(
          first.copyWith(
            type: SafetyCaseNoticeType.deactivation,
            rawType: null,
          ),
          known,
        );
      },
    );

    test(
      'notice raw companion rejects incoherent state without leaking values',
      () {
        final known = SafetyCaseNotice(type: SafetyCaseNoticeType.warning);
        final unknown = known.copyWith(
          type: SafetyCaseNoticeType.unknown,
          rawType: 'future-private-notice',
        );
        for (final action in <void Function()>[
          () => known.copyWith(type: SafetyCaseNoticeType.unknown),
          () => known.copyWith(rawType: 'private-wrong-companion'),
          () => unknown.copyWith(rawType: null),
          () => unknown.copyWith(rawType: 'warning'),
          () => unknown.copyWith(rawType: false),
        ]) {
          expect(
            action,
            throwsA(
              isA<FormatException>().having(
                (error) => error.toString(),
                'safe diagnostics',
                isNot(contains('private-')),
              ),
            ),
          );
        }
      },
    );
  });

  group('SafetyCase required nullable fields and child replacement', () {
    test('required nullable reason remains explicit', () {
      final json = _caseJson()..['reason'] = null;
      final value = SafetyCase.fromJson(json);
      expect(value.reason, isNull);
      expect(value.toJson().containsKey('reason'), isTrue);
      expect(value.toJson(), json);
      expect(value.toString(), contains('reason: null'));
    });

    for (final malformed in <Object?>[
      null,
      false,
      1,
      'private-notice',
      [],
      {},
    ]) {
      test('nested notice rejects malformed ${malformed.runtimeType}', () {
        expect(
          () => SafetyCase.fromJson(_caseJson()..['notice'] = malformed),
          throwsFormatException,
        );
      });
    }

    test('nested notice required type rejects null or malformed values', () {
      for (final malformed in <Object?>[null, false, 1, [], {}]) {
        expect(
          () => SafetyCase.fromJson(
            _caseJson()..['notice'] = {'type': malformed},
          ),
          throwsFormatException,
        );
      }
    });

    test(
      'replacement child uses full new JSON and drops old child metadata',
      () {
        final json = _caseJson()
          ..['notice'] = {
            'type': 'warning',
            'old-private-property': {
              'items': <Object?>[1],
            },
          }
          ..['future-private-parent'] = true;
        final base = SafetyCase.fromJson(json);
        final replacement = SafetyCaseNotice.fromJson(const {
          'type': 'future-private-notice',
          'new-private-property': {
            'items': <Object?>[2, null],
          },
        });
        final copied = base.copyWith(notice: replacement);
        expect(copied.notice, replacement);
        expect(copied.toJson()['notice'], replacement.toJson());
        expect(
          (copied.toJson()['notice'] as Map<String, dynamic>).containsKey(
            'old-private-property',
          ),
          isFalse,
        );
        expect(copied.toJson()['future-private-parent'], isTrue);
        expect(copied, isNot(base));
        expect(SafetyCase.fromJson(copied.toJson()), copied);
        expect(SafetyCase.fromJson(copied.toJson()).hashCode, copied.hashCode);
        expect(copied.toString(), isNot(contains('private-')));
      },
    );

    test('all case fields can be replaced without stale raw values', () {
      final base = SafetyCase.fromJson(_caseJson());
      final variants = <String, (SafetyCase, Object?)>{
        'id': (base.copyWith(id: 'new-id'), 'new-id'),
        'created_at': (base.copyWith(createdAt: 42), 42),
        'entity_identifier': (
          base.copyWith(entityIdentifier: 'new-entity'),
          'new-entity',
        ),
        'reason': (base.copyWith(reason: 'new-reason'), 'new-reason'),
        'notice': (
          base.copyWith(
            notice: SafetyCaseNotice(type: SafetyCaseNoticeType.deactivation),
          ),
          {'type': 'deactivation'},
        ),
      };
      for (final entry in variants.entries) {
        final (copy, replacement) = entry.value;
        final expected = _caseJson()..[entry.key] = replacement;
        expect(copy.toJson(), expected);
        expect(copy, isNot(base));
        expect(SafetyCase.fromJson(copy.toJson()), copy);
        expect(SafetyCase.fromJson(copy.toJson()).hashCode, copy.hashCode);
      }
      final cleared = base.copyWith(reason: null);
      expect(cleared.reason, isNull);
      expect(cleared.toJson(), _caseJson()..['reason'] = null);
      expect(() => base.copyWith(reason: false), throwsFormatException);
    });

    test('case IDs and entities remain distinct arbitrary strings', () {
      for (final id in ['', '.', '..', 'any /%?# identifier', '😀' * 129]) {
        final value = SafetyCase.fromJson(_caseJson()..['id'] = id);
        expect(value.id, id);
        expect(value.entityIdentifier, 'application-entity-private');
        expect(value.toJson()['id'], id);
      }
    });
  });
}

SafetyAlert _constructAlert(Map<Symbol, Object?> fields) =>
    Function.apply(SafetyAlert.new, const [], <Symbol, Object?>{
          #id: 'alert-id-private',
          #createdAt: -7,
          #requestId: 'request-id-private',
          #responseId: 'response-id-private',
          #model: 'model-private',
          #requestPaused: false,
          #errorType: SafetyAlertErrorType.potentiallyUnintendedDataTransfer,
          #reason: 'reason-private',
          ...fields,
        })
        as SafetyAlert;

Matcher _privateExplanationError() => throwsA(
  isA<FormatException>()
      .having(
        (error) => error.message,
        'Safety context',
        contains('SafetyAlert'),
      )
      .having(
        (error) => error.message,
        'explanation field',
        anyOf(
          contains('detailedExplanation'),
          contains('detailed_explanation'),
        ),
      )
      .having((error) => error.source, 'source', isNull)
      .having((error) => error.offset, 'offset', isNull)
      .having(
        (error) => error.toString(),
        'private values',
        isNot(contains('private')),
      ),
);
