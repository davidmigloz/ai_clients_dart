import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _questionJson() => {
  'type': 'predicate',
  'instructions': 'PRIVATE question',
};
LiveDecisionQuestion _question() =>
    LiveDecisionQuestion.fromJson(_questionJson());
Map<String, dynamic> _triggerJson([bool output = false]) => {
  'type': 'decisions',
  'event_type': output
      ? 'session.output_transcript.delta'
      : 'session.input_transcript.delta',
  'decisions': {
    'questions': [_questionJson()],
  },
};
LiveDecisionTriggerInputParam _trigger([bool output = false]) =>
    LiveDecisionTriggerInputParam.fromJson(_triggerJson(output));
Map<String, dynamic> _settingsJson() => {
  'model': 'PRIVATE future Decisions model',
  'questions': [_questionJson()],
};
Map<String, dynamic> _base(String name) => {
  if (name != 'update') 'model': 'PRIVATE Live model',
  if (name == 'resolved') ...{
    'id': 'PRIVATE session',
    'status': 'active',
    'expires_at': 0,
  },
  if (name == 'accept') 'type': 'live',
};
final _parsers = <String, LiveJsonModel Function(Map<String, dynamic>)>{
  'primary': LiveSessionCreateParams.fromJson,
  'media': LiveMediaSessionCreateParams.fromJson,
  'resolved': LiveSessionResourceParam.fromJson,
  'accept': LiveCallAcceptSession.fromJson,
  'update': LiveSessionUpdateParams.fromJson,
};
Map<String, dynamic> _json(LiveJsonModel model) =>
    model.toJson() as Map<String, dynamic>;
LiveJsonModel _copyTriggers(LiveJsonModel model, Object? triggers) =>
    switch (model) {
      final LiveSessionCreateParams value => value.copyWith(triggers: triggers),
      final LiveMediaSessionCreateParams value => value.copyWith(
        triggers: triggers,
      ),
      final LiveSessionResourceParam value => value.copyWith(
        triggers: triggers,
      ),
      final LiveCallAcceptSession value => value.copyWith(triggers: triggers),
      final LiveSessionUpdateParams value => value.copyWith(triggers: triggers),
      _ => throw StateError('Unexpected model'),
    };
List<LiveDecisionTriggerInputParam>? _triggers(LiveJsonModel model) =>
    switch (model) {
      final LiveSessionCreateParams value => value.triggers,
      final LiveMediaSessionCreateParams value => value.triggers,
      final LiveSessionResourceParam value => value.triggers,
      final LiveCallAcceptSession value => value.triggers,
      final LiveSessionUpdateParams value => value.triggers,
      _ => throw StateError('Unexpected model'),
    };
Map<String, dynamic> _delegationJson(String name) => {
  'type': name.startsWith('client')
      ? 'client'
      : name.startsWith('responses')
      ? 'responses'
      : 'decisions',
  if (name == 'responses') 'responses': {'model': 'PRIVATE Responses model'},
  if (name == 'decisions') 'decisions': _settingsJson(),
};
final _delegationParsers =
    <String, LiveJsonModel Function(Map<String, dynamic>)>{
      'client': LiveClientDelegationParam.fromJson,
      'responses': LiveResponsesDelegationParam.fromJson,
      'responses_update': LiveResponsesDelegationUpdateParam.fromJson,
      'decisions': LiveDecisionsDelegationParam.fromJson,
      'decisions_update': LiveDecisionsDelegationUpdateParam.fromJson,
    };
LiveJsonModel _copyDelay(LiveJsonModel model, Object? value) => switch (model) {
  final LiveClientDelegationParam model => model.copyWith(
    acknowledgementDelayMs: value,
  ),
  final LiveResponsesDelegationParam model => model.copyWith(
    acknowledgementDelayMs: value,
  ),
  final LiveResponsesDelegationUpdateParam model => model.copyWith(
    acknowledgementDelayMs: value,
  ),
  final LiveDecisionsDelegationParam model => model.copyWith(
    acknowledgementDelayMs: value,
  ),
  final LiveDecisionsDelegationUpdateParam model => model.copyWith(
    acknowledgementDelayMs: value,
  ),
  _ => throw StateError('Unexpected delegation'),
};
Matcher _invalid([String? field]) => throwsA(
  isA<FormatException>()
      .having(
        (e) => e.message,
        'context',
        field == null ? isNotEmpty : contains(field),
      )
      .having((e) => e.source, 'safe source', isNull)
      .having(
        (e) => e.toString(),
        'safe diagnostic',
        isNot(contains('PRIVATE')),
      ),
);

void main() {
  group('acknowledgment delay across delegation owners', () {
    for (final entry in _delegationParsers.entries) {
      test('${entry.key} omission, bounds, copy and canonical null policy', () {
        final wire = _delegationJson(entry.key);
        final omitted = entry.value(wire);
        expect(_json(omitted).containsKey('acknowledgement_delay_ms'), isFalse);
        for (final delay in [0, 800]) {
          final model = entry.value({
            ...wire,
            'acknowledgement_delay_ms': delay,
          });
          expect(_json(model)['acknowledgement_delay_ms'], delay);
          expect(entry.value(_json(model)), model);
          expect(entry.value(_json(model)).hashCode, model.hashCode);
          expect(_copyDelay(model, delay), model);
          final cleared = _copyDelay(model, null);
          expect(
            _json(cleared).containsKey('acknowledgement_delay_ms'),
            isFalse,
          );
          expect(cleared, omitted);
          expect(_copyDelay(model, delay == 0 ? 800 : 0), isNot(model));
          expect(model.toString(), isNot(contains('PRIVATE')));
        }
        for (final delay in [null, -1, 801, 1.5, true, 'PRIVATE delay']) {
          expect(
            () => entry.value({...wire, 'acknowledgement_delay_ms': delay}),
            _invalid('acknowledgement_delay_ms'),
          );
        }
        expect(
          () => _copyDelay(omitted, -1),
          _invalid('acknowledgement_delay_ms'),
        );
        expect(
          () => _copyDelay(omitted, 'PRIVATE bad'),
          _invalid('acknowledgement_delay_ms'),
        );
      });
    }
  });

  group('Decisions delegation settings and startup/update separation', () {
    test(
      'startup parses required fields and preserves future metadata safely',
      () {
        final raw = <String, dynamic>{
          ..._settingsJson(),
          'future': <String, dynamic>{
            'nested': <dynamic>[1],
          },
        };
        final settings = LiveDecisionsSettingsInputParam.fromJson(raw);
        (raw['future'] as Map<String, dynamic>)['nested'] = [
          'PRIVATE mutation',
        ];
        expect(settings.toJson()['future'], {
          'nested': [1],
        });
        expect(
          () => settings.questions.add(_question()),
          throwsUnsupportedError,
        );
        expect(
          () => settings.rawJson['changed'] = true,
          throwsUnsupportedError,
        );
        expect(settings.copyWith(), settings);
        expect(settings.copyWith().hashCode, settings.hashCode);
        expect(settings.copyWith(model: 'different'), isNot(settings));
        expect(settings.toString(), isNot(contains('PRIVATE')));
        expect(
          LiveDecisionsSettingsInputParam.fromJson(settings.toJson()),
          settings,
        );
        for (final field in ['model', 'questions']) {
          for (final wire in [
            _settingsJson()..remove(field),
            _settingsJson()..[field] = null,
            _settingsJson()..[field] = true,
          ]) {
            expect(
              () => LiveDecisionsSettingsInputParam.fromJson(wire),
              _invalid(field),
            );
          }
        }
      },
    );

    test('Live groups use 1–64 questions in both startup and update', () {
      for (final count in [1, 64]) {
        final questions = List.generate(count, (_) => _question());
        final startup = LiveDecisionsSettingsInputParam(
          model: 'future-model',
          questions: questions,
        );
        final update = LiveDecisionsSettingsUpdateParam(questions: questions);
        expect(startup.questions, hasLength(count));
        expect(update.questions, hasLength(count));
        questions.clear();
        expect(startup.questions, hasLength(count));
        expect(update.questions, hasLength(count));
      }
      for (final count in [0, 65, 400]) {
        final questions = List.generate(count, (_) => _question());
        expect(
          () => LiveDecisionsSettingsInputParam(
            model: 'model',
            questions: questions,
          ),
          _invalid('questions'),
        );
        expect(
          () => LiveDecisionsSettingsUpdateParam(questions: questions),
          _invalid('questions'),
        );
      }
    });

    test(
      'partial update supports omission and copy clearing without JSON null',
      () {
        final empty = LiveDecisionsSettingsUpdateParam();
        expect(empty.toJson(), isEmpty);
        final update = LiveDecisionsSettingsUpdateParam.fromJson(
          _settingsJson(),
        );
        expect(update.copyWith(), update);
        expect(update.copyWith().hashCode, update.hashCode);
        expect(update.copyWith(model: null, questions: null), empty);
        expect(
          update.copyWith(model: 'future-model').toJson()['model'],
          'future-model',
        );
        expect(update.toString(), isNot(contains('PRIVATE')));
        for (final field in ['model', 'questions']) {
          expect(
            () => LiveDecisionsSettingsUpdateParam.fromJson({field: null}),
            _invalid(field),
          );
        }
        expect(() => update.copyWith(model: ''), _invalid('model'));
        expect(() => update.copyWith(questions: []), _invalid('questions'));
        expect(
          () => update.copyWith(questions: ['PRIVATE invalid']),
          _invalid('questions'),
        );
      },
    );

    test(
      'startup and update owner unions select distinct Decisions settings',
      () {
        final startup = LiveDelegation.fromJson({
          'type': 'decisions',
          'decisions': _settingsJson(),
        });
        final update = LiveDelegationUpdate.fromJson({'type': 'decisions'});
        expect(startup, isA<LiveDecisionsDelegationParam>());
        expect(update, isA<LiveDecisionsDelegationUpdateParam>());
        final original = (startup as LiveDecisionsDelegationParam).copyWith(
          acknowledgementDelayMs: 400,
        );
        expect(original.copyWith(), original);
        final replacement = (update as LiveDecisionsDelegationUpdateParam)
            .copyWith(
              decisions: LiveDecisionsSettingsUpdateParam(model: 'new'),
            );
        expect(replacement.copyWith(decisions: null), update);
        for (final wire in [
          <String, dynamic>{},
          {'type': 'client'},
          {'type': null},
          {'type': 'decisions', 'decisions': null},
        ]) {
          expect(() => LiveDecisionsDelegationParam.fromJson(wire), _invalid());
        }
        expect(
          () => LiveDecisionsDelegationUpdateParam.fromJson(const {
            'type': 'decisions',
            'decisions': null,
          }),
          _invalid('decisions'),
        );
      },
    );
  });

  group('native transcript trigger DTO', () {
    test('fixed discriminator, event names and owned questions round-trip', () {
      final input = _trigger();
      final output = input.copyWith(
        eventType: 'session.output_transcript.delta',
      );
      expect(input.type, 'decisions');
      expect(input.toJson(), _triggerJson());
      expect(output.toJson(), _triggerJson(true));
      expect(input.copyWith(), input);
      expect(input.copyWith().hashCode, input.hashCode);
      expect(output, isNot(input));
      expect(LiveDecisionTriggerInputParam.fromJson(input.toJson()), input);
      expect(input.toString(), isNot(contains('PRIVATE')));
      for (final field in ['type', 'event_type', 'decisions']) {
        for (final wire in [
          _triggerJson()..remove(field),
          _triggerJson()..[field] = null,
          _triggerJson()..[field] = true,
        ]) {
          expect(
            () => LiveDecisionTriggerInputParam.fromJson(wire),
            _invalid(field),
          );
        }
      }
      expect(
        () => input.copyWith(eventType: 'PRIVATE future event'),
        _invalid('event_type'),
      );
      expect(
        () => LiveDecisionTriggerInputParam.fromJson(
          _triggerJson()..['PRIVATE unknown'] = true,
        ),
        _invalid(),
      );
      expect(
        () => input.copyWith(rawJson: {'PRIVATE unknown': true}),
        _invalid(),
      );
    });
  });

  group('consistent trigger configuration across all five parents', () {
    for (final entry in _parsers.entries) {
      test(
        '${entry.key} omission, explicit empty disable, copies and snapshots',
        () {
          final base = _base(entry.key);
          final omitted = entry.value(base);
          expect(_json(omitted).containsKey('triggers'), isFalse);
          final raw = {
            ...base,
            'triggers': [_triggerJson(), _triggerJson(true)],
          };
          final configured = entry.value(raw);
          (raw['triggers'] as List).clear();
          expect(_triggers(configured), hasLength(2));
          expect(() => _triggers(configured)!.clear(), throwsUnsupportedError);
          expect(entry.value(_json(configured)), configured);
          expect(entry.value(_json(configured)).hashCode, configured.hashCode);
          expect(_copyTriggers(configured, _triggers(configured)), configured);
          final cleared = _copyTriggers(configured, null);
          expect(_json(cleared).containsKey('triggers'), isFalse);
          expect(cleared, omitted);
          final disabled = _copyTriggers(configured, []);
          expect(_json(disabled)['triggers'], isEmpty);
          expect(disabled, isNot(omitted));
          expect(entry.value({...base, 'triggers': <dynamic>[]}), disabled);
          expect(configured.toString(), isNot(contains('PRIVATE')));
          expect(
            () => entry.value({...base, 'triggers': null}),
            _invalid('triggers'),
          );
          expect(
            () => entry.value({...base, 'triggers': true}),
            _invalid('triggers'),
          );
          expect(
            () => _copyTriggers(configured, ['PRIVATE invalid']),
            _invalid('triggers'),
          );
        },
      );

      test('${entry.key} trigger count and event uniqueness are bounded', () {
        final base = _base(entry.key);
        expect(
          () => entry.value({
            ...base,
            'triggers': [_triggerJson(), _triggerJson()],
          }),
          _invalid('triggers'),
        );
        expect(
          () => entry.value({
            ...base,
            'triggers': [_triggerJson(), _triggerJson(true), _triggerJson()],
          }),
          _invalid('triggers'),
        );
      });
    }

    test('triggers remain independent of all delegation owners on update', () {
      final update = LiveSessionUpdateParams(triggers: [_trigger()]);
      for (final delegation in [
        null,
        {'type': 'client'},
        {
          'type': 'responses',
          'responses': {'model': 'model'},
        },
        {'type': 'decisions', 'decisions': _settingsJson()},
      ]) {
        final snapshot = LiveSessionResourceParam.fromJson({
          ..._base('resolved'),
          'delegation': delegation,
        });
        update.validateForSession(snapshot);
        final requested = LiveSessionUpdateParams.fromJson(const {
          'delegation': {'type': 'decisions'},
        });
        if (snapshot.delegation?.type == 'decisions') {
          requested.validateForSession(snapshot);
        } else {
          expect(
            () => requested.validateForSession(snapshot),
            _invalid('delegation'),
          );
        }
      }
    });

    test(
      'nullable delegation presence remains separate from nonnull triggers',
      () {
        final settings = LiveSessionCreateParams.fromJson(const {
          'model': 'live',
          'delegation': null,
          'triggers': <dynamic>[],
        });
        expect(settings.hasDelegation, isTrue);
        expect(settings.toJson()['delegation'], isNull);
        expect(settings.toJson()['triggers'], isEmpty);
        final cleared = settings.copyWith(clearDelegation: true);
        expect(cleared.toJson().containsKey('delegation'), isFalse);
        expect(cleared.triggers, isEmpty);
      },
    );

    test(
      'fork override contracts remain Responses-only and exclude triggers',
      () {
        for (final wire in [
          {
            'triggers': [_triggerJson()],
          },
          {
            'delegation': {'type': 'decisions'},
          },
        ]) {
          expect(() => LiveForkSessionConfigParam.fromJson(wire), _invalid());
          expect(() => LiveMediaSessionForkParams.fromJson(wire), _invalid());
        }
      },
    );
  });
}
