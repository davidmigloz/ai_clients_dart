import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/models/responses/websocket/responses_server_event.dart'
    as legacy;
import 'package:test/test.dart';

Map<String, dynamic> _details() => {
  'detailed_explanation': 'sensitive explanation',
  'error_type': 'future_sensitive_classification',
  'review_target': 'opaque_sensitive:review',
  'steer': {
    'message': 'sensitive instruction',
    'future_steer': {
      'values': <dynamic>[true, null, 1],
    },
  },
  'future_detail': {
    'values': <dynamic>[false, 2],
  },
};

Map<String, dynamic> _failure() => {
  'code': 'misalignment_policy_violation',
  'message': 'sensitive failure',
  'misalignment': _details(),
  'future_error': {
    'values': <dynamic>[3],
  },
};

void _sameValue(Object original, Object parsed) {
  expect(parsed, original);
  expect(parsed.hashCode, original.hashCode);
}

Matcher _safeFailure(String context) => isA<FormatException>()
    .having((error) => error.message, 'context', contains(context))
    .having(
      (error) => error.toString(),
      'redacted',
      isNot(contains('sensitive')),
    )
    .having((error) => error.source, 'no source', isNull);

void main() {
  group('Shared Responses monitoring details', () {
    test('old direct WS import preserves exact public types and const API', () {
      const details = ResponsesMisalignmentDetails(
        steer: legacy.ResponsesMisalignmentSteer(message: 'opaque'),
      );
      expect(details.steer, isA<ResponsesMisalignmentSteer>());
      _sameValue(
        details,
        ResponsesMisalignmentDetails.fromJson(details.toJson()),
      );
    });

    test(
      'all fields and open classification round-trip without normalization',
      () {
        final json = _details();
        final value = ResponsesMisalignmentDetails.fromJson(json);
        expect(value.detailedExplanation, json['detailed_explanation']);
        expect(value.errorType, json['error_type']);
        expect(value.reviewTarget, json['review_target']);
        expect(value.hasReviewTarget, isTrue);
        expect(value.steer!.message, 'sensitive instruction');
        expect(value.toJson(), json);
        _sameValue(
          value,
          ResponsesMisalignmentDetails.fromJson(value.toJson()),
        );
        _sameValue(
          value.steer!,
          ResponsesMisalignmentSteer.fromJson(value.steer!.toJson()),
        );
      },
    );

    for (final state in ['absent', 'null', 'value']) {
      test('review_target retains $state presence', () {
        final json = <String, dynamic>{
          if (state != 'absent')
            'review_target': state == 'null' ? null : 'A_1:~.-',
        };
        final value = ResponsesMisalignmentDetails.fromJson(json);
        expect(value.hasReviewTarget, state != 'absent');
        expect(value.toJson(), json);
        _sameValue(
          value,
          ResponsesMisalignmentDetails.fromJson(value.toJson()),
        );
      });
    }

    for (final target in ['A', 'a' * 96, 'AZaz09._~:-']) {
      test('accepts exact review token boundary ${target.length}', () {
        expect(
          ResponsesMisalignmentDetails.fromJson({
            'review_target': target,
          }).reviewTarget,
          target,
        );
        expect(
          ResponsesMisalignmentDetails(
            reviewTarget: target,
          ).toJson()['review_target'],
          target,
        );
      });
    }

    for (final target in [
      '',
      'a' * 97,
      'token\n',
      'token\r',
      'token\r\n',
      'white space',
      'slash/',
      'percent%',
      'é',
      '😀',
      '\u0000',
      'token=',
    ]) {
      test(
        'rejects invalid token ${jsonEncode(target)} on parsing and output',
        () {
          expect(
            () => ResponsesMisalignmentDetails.fromJson({
              'review_target': target,
            }),
            throwsA(_safeFailure('review_target')),
          );
          expect(
            () => ResponsesMisalignmentDetails(reviewTarget: target).toJson(),
            throwsA(_safeFailure('review_target')),
          );
        },
      );
    }

    for (final field in ['detailed_explanation', 'error_type', 'steer']) {
      for (final bad in <Object?>[null, false, 1, <dynamic>[]]) {
        test('$field rejects supplied ${bad.runtimeType} contextually', () {
          expect(
            () => ResponsesMisalignmentDetails.fromJson({field: bad}),
            throwsA(_safeFailure(field)),
          );
        });
      }
    }
    for (final json in <Map<String, dynamic>>[
      {},
      {'message': null},
      {'message': 1},
      {'message': false},
      {'message': <dynamic>[]},
    ]) {
      test('steer requires a string message ${jsonEncode(json)}', () {
        expect(
          () => ResponsesMisalignmentSteer.fromJson(json),
          throwsA(_safeFailure('message')),
        );
      });
    }

    test(
      'copies every field and clears optional values without stale raw data',
      () {
        final original = ResponsesMisalignmentDetails.fromJson(_details());
        final changed = original.copyWith(
          detailedExplanation: 'changed',
          errorType: 'changed',
          reviewTarget: 'changed',
          steer: const ResponsesMisalignmentSteer(message: 'changed'),
        );
        expect(changed.detailedExplanation, 'changed');
        expect(changed.errorType, 'changed');
        expect(changed.reviewTarget, 'changed');
        expect(changed.steer!.message, 'changed');
        for (final value in [
          original.copyWith(detailedExplanation: 'changed'),
          original.copyWith(errorType: 'changed'),
          original.copyWith(reviewTarget: 'changed'),
          original.copyWith(
            steer: const ResponsesMisalignmentSteer(message: 'changed'),
          ),
          original.copyWith(rawJson: const {}),
        ]) {
          expect(value, isNot(original));
          _sameValue(
            value,
            ResponsesMisalignmentDetails.fromJson(value.toJson()),
          );
        }
        final cleared = original.copyWith(
          detailedExplanation: null,
          errorType: null,
          reviewTarget: null,
          steer: null,
        );
        expect(cleared.toJson(), {
          'review_target': null,
          'future_detail': original.rawJson['future_detail'],
        });
        expect(
          cleared
              .copyWith(hasReviewTarget: false)
              .toJson()
              .containsKey('review_target'),
          isFalse,
        );
        _sameValue(
          cleared,
          ResponsesMisalignmentDetails.fromJson(cleared.toJson()),
        );
      },
    );

    for (final fresh in [false, true]) {
      test(
        'nested steer ${fresh ? 'fresh replacement' : 'raw clear'} drops old future metadata',
        () {
          final original = ResponsesMisalignmentDetails.fromJson(_details());
          final child = fresh
              ? const ResponsesMisalignmentSteer(message: 'new')
              : original.steer!.copyWith(rawJson: {});
          final changed = original.copyWith(steer: child);
          expect(changed.toJson()['steer'], child.toJson());
          expect(changed.rawJson.clear, throwsUnsupportedError);
          expect(
            changed.toJson()['future_detail'],
            original.toJson()['future_detail'],
          );
          _sameValue(
            changed,
            ResponsesMisalignmentDetails.fromJson(changed.toJson()),
          );
        },
      );
    }

    test('explicit parent raw override retains its future child metadata', () {
      final original = ResponsesMisalignmentDetails.fromJson(_details());
      final raw = <String, dynamic>{
        'steer': {'parent_override': true},
        'replacement_parent': true,
      };
      final changed = original.copyWith(
        steer: const ResponsesMisalignmentSteer(message: 'new'),
        rawJson: raw,
      );
      expect(identical(changed.rawJson, raw), isTrue);
      expect(changed.toJson()['steer'], {
        'parent_override': true,
        'message': 'new',
      });
      expect(changed.toJson().containsKey('future_detail'), isFalse);
      _sameValue(
        changed,
        ResponsesMisalignmentDetails.fromJson(changed.toJson()),
      );
    });

    test(
      'steer copies both fields with effective equality and redacted output',
      () {
        final value = ResponsesMisalignmentSteer.fromJson(const {
          'message': 'sensitive instruction',
          'future': {
            'nested': <dynamic>[1],
          },
        });
        expect(value.copyWith(message: 'new').message, 'new');
        expect(value.copyWith(rawJson: {}).toJson(), {
          'message': value.message,
        });
        expect(value.copyWith(message: 'new'), isNot(value));
        expect(value.copyWith(rawJson: {}), isNot(value));
        expect(
          value.toString(),
          allOf(
            contains('message'),
            contains('rawJson'),
            isNot(contains('sensitive')),
          ),
        );
        _sameValue(value, ResponsesMisalignmentSteer.fromJson(value.toJson()));
      },
    );

    test('details diagnostics describe all fields without their contents', () {
      final value = ResponsesMisalignmentDetails.fromJson(_details());
      final text = value.toString();
      for (final field in [
        'detailedExplanation',
        'errorType',
        'reviewTarget',
        'hasReviewTarget',
        'steer',
        'rawJson',
      ]) {
        expect(text, contains(field));
      }
      expect(text, isNot(contains('sensitive')));
      expect(text, isNot(contains('future_detail')));
    });
  });

  group('Failed ResponseError canonical and legacy input', () {
    test('canonical shape omits invented legacy type and parameter', () {
      final value = ResponseError.fromJson(_failure());
      expect(value.type, 'error');
      expect(value.hasType, isFalse);
      expect(value.hasCode, isTrue);
      expect(value.hasParam, isFalse);
      expect(value.misalignment!.errorType, 'future_sensitive_classification');
      expect(value.toJson(), _failure());
      expect(value.toJson().containsKey('headers'), isFalse);
      _sameValue(value, ResponseError.fromJson(value.toJson()));
      const constructed = ResponseError(
        code: 'server_error',
        message: 'failure',
      );
      expect(constructed.toJson(), {
        'code': 'server_error',
        'message': 'failure',
      });
    });

    for (final field in ['code', 'param']) {
      for (final state in ['absent', 'null', 'value']) {
        test('legacy $field retains $state presence', () {
          final json = <String, dynamic>{
            'message': 'failure',
            if (state != 'absent')
              field: state == 'null' ? null : 'future_value',
          };
          final value = ResponseError.fromJson(json);
          expect(value.toJson(), json);
          expect(
            field == 'code' ? value.hasCode : value.hasParam,
            state != 'absent',
          );
          _sameValue(value, ResponseError.fromJson(value.toJson()));
        });
      }
    }

    test(
      'legacy explicit type and old const constructor retain their shape',
      () {
        const old = ResponseError(
          type: 'server_error',
          code: 'legacy_code',
          message: 'legacy_message',
          param: 'legacy_param',
        );
        expect(old.toJson(), {
          'type': 'server_error',
          'code': 'legacy_code',
          'message': 'legacy_message',
          'param': 'legacy_param',
        });
        _sameValue(old, ResponseError.fromJson(old.toJson()));
        expect(
          ResponseError.fromJson(const {
            'type': null,
            'message': 'legacy',
          }).type,
          'error',
        );
      },
    );

    test(
      'legacy missing code remains distinct from canonical explicit null',
      () {
        final absent = ResponseError.fromJson(const {'message': 'failure'});
        final present = ResponseError.fromJson(const {
          'message': 'failure',
          'code': null,
        });
        expect(absent, isNot(present));
        expect(absent.toJson().containsKey('code'), isFalse);
        expect(present.toJson()['code'], isNull);
        expect(present.toJson().containsKey('code'), isTrue);
        expect(absent.copyWith(code: null), present);
        expect(present.copyWith(code: null, hasCode: false), absent);
      },
    );

    test('nonnull code and param cannot be hidden by presence flags', () {
      const error = ResponseError(
        message: 'failure',
        code: 'server_error',
        param: 'input',
        hasCode: false,
        hasParam: false,
      );
      expect(error.hasCode, isTrue);
      expect(error.hasParam, isTrue);
      expect(error.toJson()['code'], 'server_error');
      expect(error.toJson()['param'], 'input');
      final copied = error.copyWith(hasCode: false, hasParam: false);
      _sameValue(error, copied);
      final cleared = error.copyWith(
        code: null,
        param: null,
        hasCode: false,
        hasParam: false,
      );
      expect(cleared.toJson().containsKey('code'), isFalse);
      expect(cleared.toJson().containsKey('param'), isFalse);
      expect(cleared.hasType, isFalse);
      _sameValue(cleared, ResponseError.fromJson(cleared.toJson()));
    });

    for (final field in ['type', 'code', 'message', 'param', 'misalignment']) {
      for (final bad in <Object?>[false, 1, <dynamic>[]]) {
        test(
          '$field malformed ${bad.runtimeType} remains contextual and redacted',
          () {
            expect(
              () => ResponseError.fromJson(_failure()..[field] = bad),
              throwsA(_safeFailure(field)),
            );
          },
        );
      }
    }
    for (final field in ['message', 'misalignment']) {
      test('$field rejects explicit null', () {
        expect(
          () => ResponseError.fromJson(_failure()..[field] = null),
          throwsA(_safeFailure(field)),
        );
      });
    }
    test('required message rejects omission', () {
      expect(
        () => ResponseError.fromJson(_failure()..remove('message')),
        throwsA(_safeFailure('message')),
      );
    });

    test(
      'copies all old and new fields with presence clears and safe diagnostics',
      () {
        final original = ResponseError.fromJson(_failure());
        final changed = original.copyWith(
          type: 'legacy',
          code: 'new_code',
          message: 'new_message',
          param: 'new_param',
          misalignment: const ResponsesMisalignmentDetails(errorType: 'new'),
          rawJson: {},
        );
        expect(changed.type, 'legacy');
        expect(changed.code, 'new_code');
        expect(changed.message, 'new_message');
        expect(changed.param, 'new_param');
        expect(changed.misalignment!.errorType, 'new');
        expect(changed.rawJson, isEmpty);
        _sameValue(changed, ResponseError.fromJson(changed.toJson()));
        for (final value in [
          original.copyWith(type: 'changed'),
          original.copyWith(code: 'changed'),
          original.copyWith(message: 'changed'),
          original.copyWith(param: 'changed'),
          original.copyWith(misalignment: null),
          original.copyWith(rawJson: {}),
        ]) {
          expect(value, isNot(original));
          _sameValue(value, ResponseError.fromJson(value.toJson()));
        }
        final legacy = ResponseError.fromJson(const {
          'type': 'legacy',
          'code': 'legacy',
          'param': 'legacy',
          'message': 'failure',
        });
        expect(
          legacy
              .copyWith(
                hasType: false,
                code: null,
                hasCode: false,
                param: null,
                hasParam: false,
              )
              .toJson(),
          {'message': 'failure'},
        );
        final text = original.toString();
        for (final field in [
          'type',
          'code',
          'message',
          'param',
          'hasType',
          'hasCode',
          'hasParam',
          'misalignment',
          'rawJson',
        ]) {
          expect(text, contains(field));
        }
        expect(text, isNot(contains('sensitive')));
        expect(text, isNot(contains('future_error')));
      },
    );

    for (final fresh in [false, true]) {
      test(
        'misalignment ${fresh ? 'fresh replacement' : 'raw clear'} drops stale child data',
        () {
          final original = ResponseError.fromJson(_failure());
          final child = fresh
              ? const ResponsesMisalignmentDetails(errorType: 'future')
              : original.misalignment!.copyWith(rawJson: {}, steer: null);
          final changed = original.copyWith(misalignment: child);
          expect(changed.toJson()['misalignment'], child.toJson());
          expect(
            changed.toJson()['future_error'],
            original.toJson()['future_error'],
          );
          expect(changed.rawJson.clear, throwsUnsupportedError);
          _sameValue(changed, ResponseError.fromJson(changed.toJson()));
        },
      );
    }

    test(
      'parent raw override priority retains metadata while typed fields win',
      () {
        final original = ResponseError.fromJson(_failure());
        final raw = <String, dynamic>{
          'misalignment': {
            'parent_override': true,
            'steer': {'parent_steer': true},
          },
          'replacement_parent': true,
        };
        final changed = original.copyWith(
          misalignment: const ResponsesMisalignmentDetails(
            steer: ResponsesMisalignmentSteer(message: 'new'),
          ),
          rawJson: raw,
        );
        expect(identical(changed.rawJson, raw), isTrue);
        expect(changed.toJson()['misalignment'], {
          'parent_override': true,
          'steer': {'parent_steer': true, 'message': 'new'},
        });
        expect(changed.toJson().containsKey('future_error'), isFalse);
        _sameValue(changed, ResponseError.fromJson(changed.toJson()));
      },
    );
  });

  group('Finite immutable monitoring ownership', () {
    final parsers = <String, Object Function(Map<String, dynamic>)>{
      'details': ResponsesMisalignmentDetails.fromJson,
      'steer': ResponsesMisalignmentSteer.fromJson,
      'failure': ResponseError.fromJson,
    };
    for (final entry in parsers.entries) {
      Map<String, dynamic> fixture() => switch (entry.key) {
        'details' => _details(),
        'steer' => {'message': 'sensitive instruction'},
        _ => _failure(),
      };
      test('${entry.key} snapshots deep lists and maps', () {
        final source = fixture()
          ..['future'] = {
            'nested': <dynamic>[1],
          };
        final parsed = entry.value(source);
        final raw = switch (parsed) {
          ResponsesMisalignmentDetails() => parsed.rawJson,
          ResponsesMisalignmentSteer() => parsed.rawJson,
          ResponseError() => parsed.rawJson,
          _ => throw StateError('unexpected fixture'),
        };
        (source['future'] as Map<String, dynamic>)['nested'] = <dynamic>[9];
        expect(raw['future'], {
          'nested': <dynamic>[1],
        });
        expect(raw.clear, throwsUnsupportedError);
        expect(
          () => (raw['future'] as Map<String, dynamic>).clear(),
          throwsUnsupportedError,
        );
        expect(
          () =>
              ((raw['future'] as Map<String, dynamic>)['nested']
                      as List<dynamic>)
                  .clear(),
          throwsUnsupportedError,
        );
      });
      for (final bad in [
        double.infinity,
        double.negativeInfinity,
        double.nan,
        Object(),
        <dynamic, dynamic>{1: 'sensitive value'},
      ]) {
        test('${entry.key} rejects non-JSON ${bad.runtimeType}', () {
          expect(
            () => entry.value(fixture()..['sensitive key'] = bad),
            throwsA(_safeFailure('Response')),
          );
        });
      }
      test('${entry.key} rejects recursive map and list safely', () {
        final map = fixture();
        map['future'] = map;
        expect(() => entry.value(map), throwsA(_safeFailure('Response')));
        final list = <dynamic>[];
        list.add(list);
        expect(
          () => entry.value(fixture()..['future'] = list),
          throwsA(_safeFailure('Response')),
        );
      });
      test('${entry.key} accepts shared acyclic references', () {
        final shared = <String, dynamic>{
          'list': <dynamic>[1, null],
        };
        expect(
          () => entry.value(
            fixture()..addAll({'first': shared, 'second': shared}),
          ),
          returnsNormally,
        );
      });
    }
    test('old const caller-owned raw collections retain compatibility', () {
      final raw = <String, dynamic>{'future': true};
      final value = ResponsesMisalignmentDetails(rawJson: raw);
      raw['future'] = false;
      expect(value.toJson()['future'], isFalse);
      expect(identical(value.rawJson, raw), isTrue);
    });
  });
}
