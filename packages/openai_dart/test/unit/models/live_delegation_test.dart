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
  group('LiveClientDelegationParam', () {
    Map<String, dynamic> fixture() => _object('{"type": "client"}');
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveClientDelegationParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveClientDelegationParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveClientDelegationParam.fromJson(input);
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
      final model = LiveClientDelegationParam.fromJson({
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
      final equal = LiveClientDelegationParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveClientDelegationParam.fromJson(fixture())));
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
          () => LiveClientDelegationParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveClientDelegationParam')),
        );
      }
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () => LiveClientDelegationParam.fromJson({...fixture(), 'type': 42}),
        throwsA(_safeError('LiveClientDelegationParam.type')),
      );
    });
    test('type is required and rejects null', () {
      expect(
        () => LiveClientDelegationParam.fromJson(fixture()..remove('type')),
        throwsA(_safeError('LiveClientDelegationParam.type')),
      );
      expect(
        () => LiveClientDelegationParam.fromJson({...fixture(), 'type': null}),
        throwsA(_safeError('LiveClientDelegationParam.type')),
      );
    });
  });

  group('LiveResponsesDelegationParam', () {
    Map<String, dynamic> fixture() => _object(
      '{"type": "responses", "responses": {"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveResponsesDelegationParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveResponsesDelegationParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.responses.toJson(), fixture()['responses']);
      expect(model.toString(), contains('responses:'));
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveResponsesDelegationParam.fromJson(input);
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
      final model = LiveResponsesDelegationParam.fromJson({
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
      final equal = LiveResponsesDelegationParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveResponsesDelegationParam.fromJson(fixture())));
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
          () => LiveResponsesDelegationParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveResponsesDelegationParam')),
        );
      }
    });
    test('responses rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationParam.fromJson({
          ...fixture(),
          'responses': 42,
        }),
        throwsA(_safeError('LiveResponsesDelegationParam.responses')),
      );
    });
    test('responses is required and rejects null', () {
      expect(
        () => LiveResponsesDelegationParam.fromJson(
          fixture()..remove('responses'),
        ),
        throwsA(_safeError('LiveResponsesDelegationParam.responses')),
      );
      expect(
        () => LiveResponsesDelegationParam.fromJson({
          ...fixture(),
          'responses': null,
        }),
        throwsA(_safeError('LiveResponsesDelegationParam.responses')),
      );
    });
    test('responses typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationParam.fromJson(fixture());
      final copied = model.copyWith(
        responses: LiveResponsesDelegationSettingsInputParam.fromJson(
          _object(
            '{"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}], "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['responses'],
        jsonDecode(
          '{"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}], "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationParam.fromJson({...fixture(), 'type': 42}),
        throwsA(_safeError('LiveResponsesDelegationParam.type')),
      );
    });
    test('type is required and rejects null', () {
      expect(
        () => LiveResponsesDelegationParam.fromJson(fixture()..remove('type')),
        throwsA(_safeError('LiveResponsesDelegationParam.type')),
      );
      expect(
        () =>
            LiveResponsesDelegationParam.fromJson({...fixture(), 'type': null}),
        throwsA(_safeError('LiveResponsesDelegationParam.type')),
      );
    });
  });

  group('LiveResponsesDelegationUpdateParam', () {
    Map<String, dynamic> fixture() => _object(
      '{"type": "responses", "responses": {"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveResponsesDelegationUpdateParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveResponsesDelegationUpdateParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.responses?.toJson(), fixture()['responses']);
      expect(model.toString(), contains('responses:'));
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveResponsesDelegationUpdateParam.fromJson(input);
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
      final model = LiveResponsesDelegationUpdateParam.fromJson({
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
      final equal = LiveResponsesDelegationUpdateParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(
        model,
        isNot(LiveResponsesDelegationUpdateParam.fromJson(fixture())),
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
          () => LiveResponsesDelegationUpdateParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveResponsesDelegationUpdateParam')),
        );
      }
    });
    test('responses rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationUpdateParam.fromJson({
          ...fixture(),
          'responses': 42,
        }),
        throwsA(_safeError('LiveResponsesDelegationUpdateParam.responses')),
      );
    });
    test('responses omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationUpdateParam.fromJson(
        fixture()..remove('responses'),
      );
      expect(absent.responses, isNull);
      expect(absent.toJson().containsKey('responses'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveResponsesDelegationUpdateParam.fromJson({
          ...fixture(),
          'responses': null,
        }),
        throwsA(_safeError('LiveResponsesDelegationUpdateParam.responses')),
      );
      expect(
        LiveResponsesDelegationUpdateParam.fromJson(
          fixture(),
        ).copyWith(responses: null).toJson().containsKey('responses'),
        isFalse,
      );
    });
    test('responses typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationUpdateParam.fromJson(fixture());
      final copied = model.copyWith(
        responses: LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
          _object(
            '{"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}], "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['responses'],
        jsonDecode(
          '{"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}], "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(responses: Object()),
        throwsA(_safeError('LiveResponsesDelegationUpdateParam.responses')),
      );
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationUpdateParam.fromJson({
          ...fixture(),
          'type': 42,
        }),
        throwsA(_safeError('LiveResponsesDelegationUpdateParam.type')),
      );
    });
    test('type is required and rejects null', () {
      expect(
        () => LiveResponsesDelegationUpdateParam.fromJson(
          fixture()..remove('type'),
        ),
        throwsA(_safeError('LiveResponsesDelegationUpdateParam.type')),
      );
      expect(
        () => LiveResponsesDelegationUpdateParam.fromJson({
          ...fixture(),
          'type': null,
        }),
        throwsA(_safeError('LiveResponsesDelegationUpdateParam.type')),
      );
    });
  });

  group('LiveDelegationReasoningInputParam', () {
    Map<String, dynamic> fixture() =>
        _object('{"effort": "high", "summary": "detailed"}');
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveDelegationReasoningInputParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveDelegationReasoningInputParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.effort?.toJson(), fixture()['effort']);
      expect(model.toString(), contains('effort:'));
      expect(model.hasEffort, isTrue);
      expect(model.summary?.toJson(), fixture()['summary']);
      expect(model.toString(), contains('summary:'));
      expect(model.hasSummary, isTrue);
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveDelegationReasoningInputParam.fromJson(input);
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
      final model = LiveDelegationReasoningInputParam.fromJson({
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
      final equal = LiveDelegationReasoningInputParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(
        model,
        isNot(LiveDelegationReasoningInputParam.fromJson(fixture())),
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
          () => LiveDelegationReasoningInputParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveDelegationReasoningInputParam')),
        );
      }
    });
    test('effort rejects wrong known values contextually', () {
      expect(
        () => LiveDelegationReasoningInputParam.fromJson({
          ...fixture(),
          'effort': 42,
        }),
        throwsA(_safeError('LiveDelegationReasoningInputParam.effort')),
      );
    });
    test('effort omission, null and clearing follow schema', () {
      final absent = LiveDelegationReasoningInputParam.fromJson(
        fixture()..remove('effort'),
      );
      expect(absent.effort, isNull);
      expect(absent.toJson().containsKey('effort'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasEffort, isFalse);
      final explicit = absent.copyWith(effort: null);
      expect(explicit.hasEffort, isTrue);
      expect(explicit.toJson().containsKey('effort'), isTrue);
      expect(explicit.toJson()['effort'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearEffort: true);
      expect(cleared.hasEffort, isFalse);
      expect(cleared, absent);
      expect(
        LiveDelegationReasoningInputParam.fromJson({
          ...fixture(),
          'effort': null,
        }).toJson()['effort'],
        isNull,
      );
    });
    test('effort typed copy wins over stale raw JSON', () {
      final model = LiveDelegationReasoningInputParam.fromJson(fixture());
      final copied = model.copyWith(
        effort: LiveReasoningEffort.fromJson('none'),
      );
      expect(copied.toJson()['effort'], jsonDecode('"none"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(effort: Object()),
        throwsA(_safeError('LiveDelegationReasoningInputParam.effort')),
      );
    });
    test('summary rejects wrong known values contextually', () {
      expect(
        () => LiveDelegationReasoningInputParam.fromJson({
          ...fixture(),
          'summary': 42,
        }),
        throwsA(_safeError('LiveDelegationReasoningInputParam.summary')),
      );
    });
    test('summary omission, null and clearing follow schema', () {
      final absent = LiveDelegationReasoningInputParam.fromJson(
        fixture()..remove('summary'),
      );
      expect(absent.summary, isNull);
      expect(absent.toJson().containsKey('summary'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasSummary, isFalse);
      final explicit = absent.copyWith(summary: null);
      expect(explicit.hasSummary, isTrue);
      expect(explicit.toJson().containsKey('summary'), isTrue);
      expect(explicit.toJson()['summary'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearSummary: true);
      expect(cleared.hasSummary, isFalse);
      expect(cleared, absent);
      expect(
        LiveDelegationReasoningInputParam.fromJson({
          ...fixture(),
          'summary': null,
        }).toJson()['summary'],
        isNull,
      );
    });
    test('summary typed copy wins over stale raw JSON', () {
      final model = LiveDelegationReasoningInputParam.fromJson(fixture());
      final copied = model.copyWith(
        summary: LiveReasoningSummary.fromJson('concise'),
      );
      expect(copied.toJson()['summary'], jsonDecode('"concise"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(summary: Object()),
        throwsA(_safeError('LiveDelegationReasoningInputParam.summary')),
      );
    });
  });

  group('LiveDelegationTextInputParam', () {
    Map<String, dynamic> fixture() => _object('{"verbosity": "high"}');
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveDelegationTextInputParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveDelegationTextInputParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.verbosity?.toJson(), fixture()['verbosity']);
      expect(model.toString(), contains('verbosity:'));
      expect(model.hasVerbosity, isTrue);
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveDelegationTextInputParam.fromJson(input);
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
      final model = LiveDelegationTextInputParam.fromJson({
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
      final equal = LiveDelegationTextInputParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveDelegationTextInputParam.fromJson(fixture())));
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
          () => LiveDelegationTextInputParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveDelegationTextInputParam')),
        );
      }
    });
    test('verbosity rejects wrong known values contextually', () {
      expect(
        () => LiveDelegationTextInputParam.fromJson({
          ...fixture(),
          'verbosity': 42,
        }),
        throwsA(_safeError('LiveDelegationTextInputParam.verbosity')),
      );
    });
    test('verbosity omission, null and clearing follow schema', () {
      final absent = LiveDelegationTextInputParam.fromJson(
        fixture()..remove('verbosity'),
      );
      expect(absent.verbosity, isNull);
      expect(absent.toJson().containsKey('verbosity'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasVerbosity, isFalse);
      final explicit = absent.copyWith(verbosity: null);
      expect(explicit.hasVerbosity, isTrue);
      expect(explicit.toJson().containsKey('verbosity'), isTrue);
      expect(explicit.toJson()['verbosity'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearVerbosity: true);
      expect(cleared.hasVerbosity, isFalse);
      expect(cleared, absent);
      expect(
        LiveDelegationTextInputParam.fromJson({
          ...fixture(),
          'verbosity': null,
        }).toJson()['verbosity'],
        isNull,
      );
    });
    test('verbosity typed copy wins over stale raw JSON', () {
      final model = LiveDelegationTextInputParam.fromJson(fixture());
      final copied = model.copyWith(
        verbosity: LiveTextVerbosity.fromJson('low'),
      );
      expect(copied.toJson()['verbosity'], jsonDecode('"low"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(verbosity: Object()),
        throwsA(_safeError('LiveDelegationTextInputParam.verbosity')),
      );
    });
  });

  group('LiveResponsesDelegationSettingsInputParam', () {
    Map<String, dynamic> fixture() => _object(
      '{"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture(),
      );
      expect(model.toJson(), fixture());
      final equal = LiveResponsesDelegationSettingsInputParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.instructions, fixture()['instructions']);
      expect(model.toString(), contains('instructions:'));
      expect(model.hasInstructions, isTrue);
      expect(model.maxOutputTokens, fixture()['max_output_tokens']);
      expect(model.toString(), contains('maxOutputTokens:'));
      expect(model.hasMaxOutputTokens, isTrue);
      expect(model.model, fixture()['model']);
      expect(model.toString(), contains('model:'));
      expect(model.parallelToolCalls, fixture()['parallel_tool_calls']);
      expect(model.toString(), contains('parallelToolCalls:'));
      expect(model.hasParallelToolCalls, isTrue);
      expect(model.reasoning?.toJson(), fixture()['reasoning']);
      expect(model.toString(), contains('reasoning:'));
      expect(model.hasReasoning, isTrue);
      expect(model.serviceTier?.toJson(), fixture()['service_tier']);
      expect(model.toString(), contains('serviceTier:'));
      expect(model.hasServiceTier, isTrue);
      expect(model.text?.toJson(), fixture()['text']);
      expect(model.toString(), contains('text:'));
      expect(model.hasText, isTrue);
      expect(model.toolChoice?.toJson(), fixture()['tool_choice']);
      expect(model.toString(), contains('toolChoice:'));
      expect(
        model.tools?.map((item) => item.toJson()).toList(),
        fixture()['tools'],
      );
      expect(model.toString(), contains('tools:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveResponsesDelegationSettingsInputParam.fromJson(input);
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
      final model = LiveResponsesDelegationSettingsInputParam.fromJson({
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
      final equal = LiveResponsesDelegationSettingsInputParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(
        model,
        isNot(LiveResponsesDelegationSettingsInputParam.fromJson(fixture())),
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
          () => LiveResponsesDelegationSettingsInputParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveResponsesDelegationSettingsInputParam')),
        );
      }
    });
    test('instructions rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'instructions': 42,
        }),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsInputParam.instructions'),
        ),
      );
    });
    test('instructions omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture()..remove('instructions'),
      );
      expect(absent.instructions, isNull);
      expect(absent.toJson().containsKey('instructions'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasInstructions, isFalse);
      final explicit = absent.copyWith(instructions: null);
      expect(explicit.hasInstructions, isTrue);
      expect(explicit.toJson().containsKey('instructions'), isTrue);
      expect(explicit.toJson()['instructions'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearInstructions: true);
      expect(cleared.hasInstructions, isFalse);
      expect(cleared, absent);
      expect(
        LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'instructions': null,
        }).toJson()['instructions'],
        isNull,
      );
    });
    test('instructions typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(instructions: 'ALTERNATE_LIVE_VALUE');
      expect(
        copied.toJson()['instructions'],
        jsonDecode('"ALTERNATE_LIVE_VALUE"'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(instructions: Object()),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsInputParam.instructions'),
        ),
      );
    });
    test('max_output_tokens rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'max_output_tokens': _private,
        }),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsInputParam.max_output_tokens',
          ),
        ),
      );
    });
    test('max_output_tokens omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture()..remove('max_output_tokens'),
      );
      expect(absent.maxOutputTokens, isNull);
      expect(absent.toJson().containsKey('max_output_tokens'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasMaxOutputTokens, isFalse);
      final explicit = absent.copyWith(maxOutputTokens: null);
      expect(explicit.hasMaxOutputTokens, isTrue);
      expect(explicit.toJson().containsKey('max_output_tokens'), isTrue);
      expect(explicit.toJson()['max_output_tokens'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearMaxOutputTokens: true);
      expect(cleared.hasMaxOutputTokens, isFalse);
      expect(cleared, absent);
      expect(
        LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'max_output_tokens': null,
        }).toJson()['max_output_tokens'],
        isNull,
      );
    });
    test('max_output_tokens typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(maxOutputTokens: 32);
      expect(copied.toJson()['max_output_tokens'], jsonDecode('32'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(maxOutputTokens: Object()),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsInputParam.max_output_tokens',
          ),
        ),
      );
    });
    test('model rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'model': 42,
        }),
        throwsA(_safeError('LiveResponsesDelegationSettingsInputParam.model')),
      );
    });
    test('model is required and rejects null', () {
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson(
          fixture()..remove('model'),
        ),
        throwsA(_safeError('LiveResponsesDelegationSettingsInputParam.model')),
      );
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'model': null,
        }),
        throwsA(_safeError('LiveResponsesDelegationSettingsInputParam.model')),
      );
    });
    test('model typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(model: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['model'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('parallel_tool_calls rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'parallel_tool_calls': 42,
        }),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsInputParam.parallel_tool_calls',
          ),
        ),
      );
    });
    test('parallel_tool_calls omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture()..remove('parallel_tool_calls'),
      );
      expect(absent.parallelToolCalls, isNull);
      expect(absent.toJson().containsKey('parallel_tool_calls'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasParallelToolCalls, isFalse);
      final explicit = absent.copyWith(parallelToolCalls: null);
      expect(explicit.hasParallelToolCalls, isTrue);
      expect(explicit.toJson().containsKey('parallel_tool_calls'), isTrue);
      expect(explicit.toJson()['parallel_tool_calls'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearParallelToolCalls: true);
      expect(cleared.hasParallelToolCalls, isFalse);
      expect(cleared, absent);
      expect(
        LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'parallel_tool_calls': null,
        }).toJson()['parallel_tool_calls'],
        isNull,
      );
    });
    test('parallel_tool_calls typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(parallelToolCalls: true);
      expect(copied.toJson()['parallel_tool_calls'], jsonDecode('true'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(parallelToolCalls: Object()),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsInputParam.parallel_tool_calls',
          ),
        ),
      );
    });
    test('reasoning rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'reasoning': 42,
        }),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsInputParam.reasoning'),
        ),
      );
    });
    test('reasoning omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture()..remove('reasoning'),
      );
      expect(absent.reasoning, isNull);
      expect(absent.toJson().containsKey('reasoning'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasReasoning, isFalse);
      final explicit = absent.copyWith(reasoning: null);
      expect(explicit.hasReasoning, isTrue);
      expect(explicit.toJson().containsKey('reasoning'), isTrue);
      expect(explicit.toJson()['reasoning'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearReasoning: true);
      expect(cleared.hasReasoning, isFalse);
      expect(cleared, absent);
      expect(
        LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'reasoning': null,
        }).toJson()['reasoning'],
        isNull,
      );
    });
    test('reasoning typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(
        reasoning: LiveDelegationReasoningInputParam.fromJson(
          _object(
            '{"effort": "high", "summary": "detailed", "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['reasoning'],
        jsonDecode(
          '{"effort": "high", "summary": "detailed", "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(reasoning: Object()),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsInputParam.reasoning'),
        ),
      );
    });
    test('service_tier rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'service_tier': 42,
        }),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsInputParam.service_tier'),
        ),
      );
    });
    test('service_tier omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture()..remove('service_tier'),
      );
      expect(absent.serviceTier, isNull);
      expect(absent.toJson().containsKey('service_tier'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasServiceTier, isFalse);
      final explicit = absent.copyWith(serviceTier: null);
      expect(explicit.hasServiceTier, isTrue);
      expect(explicit.toJson().containsKey('service_tier'), isTrue);
      expect(explicit.toJson()['service_tier'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearServiceTier: true);
      expect(cleared.hasServiceTier, isFalse);
      expect(cleared, absent);
      expect(
        LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'service_tier': null,
        }).toJson()['service_tier'],
        isNull,
      );
    });
    test('service_tier typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(
        serviceTier: LiveResponsesServiceTier.fromJson('auto'),
      );
      expect(copied.toJson()['service_tier'], jsonDecode('"auto"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(serviceTier: Object()),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsInputParam.service_tier'),
        ),
      );
    });
    test('text rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'text': 42,
        }),
        throwsA(_safeError('LiveResponsesDelegationSettingsInputParam.text')),
      );
    });
    test('text omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture()..remove('text'),
      );
      expect(absent.text, isNull);
      expect(absent.toJson().containsKey('text'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasText, isFalse);
      final explicit = absent.copyWith(text: null);
      expect(explicit.hasText, isTrue);
      expect(explicit.toJson().containsKey('text'), isTrue);
      expect(explicit.toJson()['text'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearText: true);
      expect(cleared.hasText, isFalse);
      expect(cleared, absent);
      expect(
        LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'text': null,
        }).toJson()['text'],
        isNull,
      );
    });
    test('text typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(
        text: LiveDelegationTextInputParam.fromJson(
          _object('{"verbosity": "high", "alternate_metadata": {"ok": true}}'),
        ),
      );
      expect(
        copied.toJson()['text'],
        jsonDecode('{"verbosity": "high", "alternate_metadata": {"ok": true}}'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(text: Object()),
        throwsA(_safeError('LiveResponsesDelegationSettingsInputParam.text')),
      );
    });
    test('tool_choice rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'tool_choice': 42,
        }),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsInputParam.tool_choice'),
        ),
      );
    });
    test('tool_choice omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture()..remove('tool_choice'),
      );
      expect(absent.toolChoice, isNull);
      expect(absent.toJson().containsKey('tool_choice'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'tool_choice': null,
        }),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsInputParam.tool_choice'),
        ),
      );
      expect(
        LiveResponsesDelegationSettingsInputParam.fromJson(
          fixture(),
        ).copyWith(toolChoice: null).toJson().containsKey('tool_choice'),
        isFalse,
      );
    });
    test('tool_choice typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(
        toolChoice: LiveToolChoice.fromJson('required'),
      );
      expect(copied.toJson()['tool_choice'], jsonDecode('"required"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(toolChoice: Object()),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsInputParam.tool_choice'),
        ),
      );
    });
    test('tools rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'tools': 42,
        }),
        throwsA(_safeError('LiveResponsesDelegationSettingsInputParam.tools')),
      );
    });
    test('tools omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture()..remove('tools'),
      );
      expect(absent.tools, isNull);
      expect(absent.toJson().containsKey('tools'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson({
          ...fixture(),
          'tools': null,
        }),
        throwsA(_safeError('LiveResponsesDelegationSettingsInputParam.tools')),
      );
      expect(
        LiveResponsesDelegationSettingsInputParam.fromJson(
          fixture(),
        ).copyWith(tools: null).toJson().containsKey('tools'),
        isFalse,
      );
    });
    test('tools typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(tools: <LiveTool>[]);
      expect(copied.toJson()['tools'], jsonDecode('[]'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(tools: Object()),
        throwsA(_safeError('LiveResponsesDelegationSettingsInputParam.tools')),
      );
    });
  });

  group('LiveResponsesDelegationSettingsUpdateInputParam', () {
    Map<String, dynamic> fixture() => _object(
      '{"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture(),
      );
      expect(model.toJson(), fixture());
      final equal = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.instructions, fixture()['instructions']);
      expect(model.toString(), contains('instructions:'));
      expect(model.hasInstructions, isTrue);
      expect(model.maxOutputTokens, fixture()['max_output_tokens']);
      expect(model.toString(), contains('maxOutputTokens:'));
      expect(model.hasMaxOutputTokens, isTrue);
      expect(model.model, fixture()['model']);
      expect(model.toString(), contains('model:'));
      expect(model.parallelToolCalls, fixture()['parallel_tool_calls']);
      expect(model.toString(), contains('parallelToolCalls:'));
      expect(model.hasParallelToolCalls, isTrue);
      expect(model.reasoning?.toJson(), fixture()['reasoning']);
      expect(model.toString(), contains('reasoning:'));
      expect(model.hasReasoning, isTrue);
      expect(model.serviceTier?.toJson(), fixture()['service_tier']);
      expect(model.toString(), contains('serviceTier:'));
      expect(model.hasServiceTier, isTrue);
      expect(model.text?.toJson(), fixture()['text']);
      expect(model.toString(), contains('text:'));
      expect(model.hasText, isTrue);
      expect(model.toolChoice?.toJson(), fixture()['tool_choice']);
      expect(model.toString(), contains('toolChoice:'));
      expect(
        model.tools?.map((item) => item.toJson()).toList(),
        fixture()['tools'],
      );
      expect(model.toString(), contains('tools:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        input,
      );
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
      final model = LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
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
      final equal = LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(
        model,
        isNot(
          LiveResponsesDelegationSettingsUpdateInputParam.fromJson(fixture()),
        ),
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
          () => LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(
            _safeError('LiveResponsesDelegationSettingsUpdateInputParam'),
          ),
        );
      }
    });
    test('instructions rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'instructions': 42,
        }),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsUpdateInputParam.instructions',
          ),
        ),
      );
    });
    test('instructions omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture()..remove('instructions'),
      );
      expect(absent.instructions, isNull);
      expect(absent.toJson().containsKey('instructions'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasInstructions, isFalse);
      final explicit = absent.copyWith(instructions: null);
      expect(explicit.hasInstructions, isTrue);
      expect(explicit.toJson().containsKey('instructions'), isTrue);
      expect(explicit.toJson()['instructions'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearInstructions: true);
      expect(cleared.hasInstructions, isFalse);
      expect(cleared, absent);
      expect(
        LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'instructions': null,
        }).toJson()['instructions'],
        isNull,
      );
    });
    test('instructions typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(instructions: 'ALTERNATE_LIVE_VALUE');
      expect(
        copied.toJson()['instructions'],
        jsonDecode('"ALTERNATE_LIVE_VALUE"'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(instructions: Object()),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsUpdateInputParam.instructions',
          ),
        ),
      );
    });
    test('max_output_tokens rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'max_output_tokens': _private,
        }),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsUpdateInputParam.max_output_tokens',
          ),
        ),
      );
    });
    test('max_output_tokens omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture()..remove('max_output_tokens'),
      );
      expect(absent.maxOutputTokens, isNull);
      expect(absent.toJson().containsKey('max_output_tokens'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasMaxOutputTokens, isFalse);
      final explicit = absent.copyWith(maxOutputTokens: null);
      expect(explicit.hasMaxOutputTokens, isTrue);
      expect(explicit.toJson().containsKey('max_output_tokens'), isTrue);
      expect(explicit.toJson()['max_output_tokens'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearMaxOutputTokens: true);
      expect(cleared.hasMaxOutputTokens, isFalse);
      expect(cleared, absent);
      expect(
        LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'max_output_tokens': null,
        }).toJson()['max_output_tokens'],
        isNull,
      );
    });
    test('max_output_tokens typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(maxOutputTokens: 32);
      expect(copied.toJson()['max_output_tokens'], jsonDecode('32'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(maxOutputTokens: Object()),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsUpdateInputParam.max_output_tokens',
          ),
        ),
      );
    });
    test('model rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'model': 42,
        }),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsUpdateInputParam.model'),
        ),
      );
    });
    test('model omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture()..remove('model'),
      );
      expect(absent.model, isNull);
      expect(absent.toJson().containsKey('model'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'model': null,
        }),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsUpdateInputParam.model'),
        ),
      );
      expect(
        LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
          fixture(),
        ).copyWith(model: null).toJson().containsKey('model'),
        isFalse,
      );
    });
    test('model typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(model: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['model'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(model: Object()),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsUpdateInputParam.model'),
        ),
      );
    });
    test('parallel_tool_calls rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'parallel_tool_calls': 42,
        }),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsUpdateInputParam.parallel_tool_calls',
          ),
        ),
      );
    });
    test('parallel_tool_calls omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture()..remove('parallel_tool_calls'),
      );
      expect(absent.parallelToolCalls, isNull);
      expect(absent.toJson().containsKey('parallel_tool_calls'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasParallelToolCalls, isFalse);
      final explicit = absent.copyWith(parallelToolCalls: null);
      expect(explicit.hasParallelToolCalls, isTrue);
      expect(explicit.toJson().containsKey('parallel_tool_calls'), isTrue);
      expect(explicit.toJson()['parallel_tool_calls'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearParallelToolCalls: true);
      expect(cleared.hasParallelToolCalls, isFalse);
      expect(cleared, absent);
      expect(
        LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'parallel_tool_calls': null,
        }).toJson()['parallel_tool_calls'],
        isNull,
      );
    });
    test('parallel_tool_calls typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(parallelToolCalls: true);
      expect(copied.toJson()['parallel_tool_calls'], jsonDecode('true'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(parallelToolCalls: Object()),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsUpdateInputParam.parallel_tool_calls',
          ),
        ),
      );
    });
    test('reasoning rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'reasoning': 42,
        }),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsUpdateInputParam.reasoning',
          ),
        ),
      );
    });
    test('reasoning omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture()..remove('reasoning'),
      );
      expect(absent.reasoning, isNull);
      expect(absent.toJson().containsKey('reasoning'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasReasoning, isFalse);
      final explicit = absent.copyWith(reasoning: null);
      expect(explicit.hasReasoning, isTrue);
      expect(explicit.toJson().containsKey('reasoning'), isTrue);
      expect(explicit.toJson()['reasoning'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearReasoning: true);
      expect(cleared.hasReasoning, isFalse);
      expect(cleared, absent);
      expect(
        LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'reasoning': null,
        }).toJson()['reasoning'],
        isNull,
      );
    });
    test('reasoning typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(
        reasoning: LiveDelegationReasoningInputParam.fromJson(
          _object(
            '{"effort": "high", "summary": "detailed", "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['reasoning'],
        jsonDecode(
          '{"effort": "high", "summary": "detailed", "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(reasoning: Object()),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsUpdateInputParam.reasoning',
          ),
        ),
      );
    });
    test('service_tier rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'service_tier': 42,
        }),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsUpdateInputParam.service_tier',
          ),
        ),
      );
    });
    test('service_tier omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture()..remove('service_tier'),
      );
      expect(absent.serviceTier, isNull);
      expect(absent.toJson().containsKey('service_tier'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasServiceTier, isFalse);
      final explicit = absent.copyWith(serviceTier: null);
      expect(explicit.hasServiceTier, isTrue);
      expect(explicit.toJson().containsKey('service_tier'), isTrue);
      expect(explicit.toJson()['service_tier'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearServiceTier: true);
      expect(cleared.hasServiceTier, isFalse);
      expect(cleared, absent);
      expect(
        LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'service_tier': null,
        }).toJson()['service_tier'],
        isNull,
      );
    });
    test('service_tier typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(
        serviceTier: LiveResponsesServiceTier.fromJson('auto'),
      );
      expect(copied.toJson()['service_tier'], jsonDecode('"auto"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(serviceTier: Object()),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsUpdateInputParam.service_tier',
          ),
        ),
      );
    });
    test('text rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'text': 42,
        }),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsUpdateInputParam.text'),
        ),
      );
    });
    test('text omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture()..remove('text'),
      );
      expect(absent.text, isNull);
      expect(absent.toJson().containsKey('text'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasText, isFalse);
      final explicit = absent.copyWith(text: null);
      expect(explicit.hasText, isTrue);
      expect(explicit.toJson().containsKey('text'), isTrue);
      expect(explicit.toJson()['text'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearText: true);
      expect(cleared.hasText, isFalse);
      expect(cleared, absent);
      expect(
        LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'text': null,
        }).toJson()['text'],
        isNull,
      );
    });
    test('text typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(
        text: LiveDelegationTextInputParam.fromJson(
          _object('{"verbosity": "high", "alternate_metadata": {"ok": true}}'),
        ),
      );
      expect(
        copied.toJson()['text'],
        jsonDecode('{"verbosity": "high", "alternate_metadata": {"ok": true}}'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(text: Object()),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsUpdateInputParam.text'),
        ),
      );
    });
    test('tool_choice rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'tool_choice': 42,
        }),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsUpdateInputParam.tool_choice',
          ),
        ),
      );
    });
    test('tool_choice omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture()..remove('tool_choice'),
      );
      expect(absent.toolChoice, isNull);
      expect(absent.toJson().containsKey('tool_choice'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'tool_choice': null,
        }),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsUpdateInputParam.tool_choice',
          ),
        ),
      );
      expect(
        LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
          fixture(),
        ).copyWith(toolChoice: null).toJson().containsKey('tool_choice'),
        isFalse,
      );
    });
    test('tool_choice typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(
        toolChoice: LiveToolChoice.fromJson('required'),
      );
      expect(copied.toJson()['tool_choice'], jsonDecode('"required"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(toolChoice: Object()),
        throwsA(
          _safeError(
            'LiveResponsesDelegationSettingsUpdateInputParam.tool_choice',
          ),
        ),
      );
    });
    test('tools rejects wrong known values contextually', () {
      expect(
        () => LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'tools': 42,
        }),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsUpdateInputParam.tools'),
        ),
      );
    });
    test('tools omission, null and clearing follow schema', () {
      final absent = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture()..remove('tools'),
      );
      expect(absent.tools, isNull);
      expect(absent.toJson().containsKey('tools'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveResponsesDelegationSettingsUpdateInputParam.fromJson({
          ...fixture(),
          'tools': null,
        }),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsUpdateInputParam.tools'),
        ),
      );
      expect(
        LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
          fixture(),
        ).copyWith(tools: null).toJson().containsKey('tools'),
        isFalse,
      );
    });
    test('tools typed copy wins over stale raw JSON', () {
      final model = LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
        fixture(),
      );
      final copied = model.copyWith(tools: <LiveTool>[]);
      expect(copied.toJson()['tools'], jsonDecode('[]'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(tools: Object()),
        throwsA(
          _safeError('LiveResponsesDelegationSettingsUpdateInputParam.tools'),
        ),
      );
    });
  });

  group('LiveReasoningEffort', () {
    final wires = ['none', 'minimal', 'low', 'medium', 'high', 'xhigh'];
    for (final wire in wires) {
      test('canonical $wire round-trip', () {
        final value = LiveReasoningEffort.fromJson(wire);
        expect(value.toJson(), wire);
        expect(value, LiveReasoningEffort.fromJson(wire));
        expect(value.hashCode, LiveReasoningEffort.fromJson(wire).hashCode);
      });
    }
    test('closed values reject unknown input privately', () {
      expect(
        () => LiveReasoningEffort.fromJson(_private),
        throwsA(_safeError('LiveReasoningEffort')),
      );
    });
  });
  group('LiveReasoningSummary', () {
    final wires = ['concise', 'detailed', 'auto'];
    for (final wire in wires) {
      test('canonical $wire round-trip', () {
        final value = LiveReasoningSummary.fromJson(wire);
        expect(value.toJson(), wire);
        expect(value, LiveReasoningSummary.fromJson(wire));
        expect(value.hashCode, LiveReasoningSummary.fromJson(wire).hashCode);
      });
    }
    test('closed values reject unknown input privately', () {
      expect(
        () => LiveReasoningSummary.fromJson(_private),
        throwsA(_safeError('LiveReasoningSummary')),
      );
    });
  });
  group('LiveTextVerbosity', () {
    final wires = ['low', 'medium', 'high'];
    for (final wire in wires) {
      test('canonical $wire round-trip', () {
        final value = LiveTextVerbosity.fromJson(wire);
        expect(value.toJson(), wire);
        expect(value, LiveTextVerbosity.fromJson(wire));
        expect(value.hashCode, LiveTextVerbosity.fromJson(wire).hashCode);
      });
    }
    test('closed values reject unknown input privately', () {
      expect(
        () => LiveTextVerbosity.fromJson(_private),
        throwsA(_safeError('LiveTextVerbosity')),
      );
    });
  });
  group('LiveResponsesServiceTier', () {
    final wires = [
      'auto',
      'default',
      'fast_tier_temp_pilot',
      'flex',
      'priority',
      'ultrafast',
    ];
    for (final wire in wires) {
      test('canonical $wire round-trip', () {
        final value = LiveResponsesServiceTier.fromJson(wire);
        expect(value.toJson(), wire);
        expect(value, LiveResponsesServiceTier.fromJson(wire));
        expect(
          value.hashCode,
          LiveResponsesServiceTier.fromJson(wire).hashCode,
        );
      });
    }
    test('closed values reject unknown input privately', () {
      expect(
        () => LiveResponsesServiceTier.fromJson(_private),
        throwsA(_safeError('LiveResponsesServiceTier')),
      );
    });
  });
  group('LiveToolChoiceEnum', () {
    final wires = ['auto', 'none', 'required'];
    for (final wire in wires) {
      test('canonical $wire round-trip', () {
        final value = LiveToolChoiceEnum.fromJson(wire);
        expect(value.toJson(), wire);
        expect(value, LiveToolChoiceEnum.fromJson(wire));
        expect(value.hashCode, LiveToolChoiceEnum.fromJson(wire).hashCode);
      });
    }
    test('closed values reject unknown input privately', () {
      expect(
        () => LiveToolChoiceEnum.fromJson(_private),
        throwsA(_safeError('LiveToolChoiceEnum')),
      );
    });
  });
}
