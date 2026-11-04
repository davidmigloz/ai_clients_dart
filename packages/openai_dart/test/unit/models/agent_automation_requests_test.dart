import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _existing() => {
  'type': 'existing_session',
  'session_id': 'session_1',
  'instructions': 'PRIVATE instructions',
};
Map<String, dynamic> _newSession() => {
  'type': 'new_session',
  'agent_id': 'agent_1',
  'environment': {'type': 'none'},
  'input': [
    {
      'role': 'user',
      'content': [
        {'type': 'input_text', 'text': 'PRIVATE input'},
      ],
    },
  ],
};
Map<String, dynamic> _once() => {
  'type': 'once',
  'name': 'PRIVATE schedule',
  'target': _existing(),
  'run_at': 2000000000,
};
Map<String, dynamic> _periodic() => {
  'type': 'periodic',
  'name': 'PRIVATE schedule',
  'target': _newSession(),
  'expression': '0 9 * * *',
  'timezone': 'Europe/Madrid',
};

void main() {
  group('automation creation', () {
    test('both schedules and targets round-trip exact known wire forms', () {
      for (final json in [
        _once(),
        {..._once(), 'metadata': <String, String>{}},
        _periodic(),
        {
          ..._periodic(),
          'metadata': {'project': 'PRIVATE'},
        },
      ]) {
        final value = CreateAgentAutomationRequest.fromJson(json);
        expect(value.toJson(), json);
        expect(CreateAgentAutomationRequest.fromJson(value.toJson()), value);
        expect(
          CreateAgentAutomationRequest.fromJson(value.toJson()).hashCode,
          value.hashCode,
        );
        expect(value.toString(), isNot(contains('PRIVATE')));
      }
      final once = CreateAgentAutomationRequest.once(
        name: 'one',
        target: AgentAutomationTarget.existingSession(
          sessionId: '',
          instructions: '',
        ),
        runAt: 2000000000,
      );
      final periodic = CreateAgentAutomationRequest.periodic(
        name: 'periodic',
        target: AgentAutomationTarget.newSession(
          agent: AgentSessionAgentConfig(),
          environment: AgentSessionEnvironment.none(),
          input: const [],
        ),
        expression: '0 9 * * *',
        timezone: 'UTC',
      );
      expect(once, isA<CreateAgentAutomationOnceRequest>());
      expect(periodic, isA<CreateAgentAutomationPeriodicRequest>());
      expect((once as CreateAgentAutomationOnceRequest).copyWith(), once);
      expect(
        (periodic as CreateAgentAutomationPeriodicRequest).copyWith(),
        periodic,
      );
    });

    test('required discriminator and fields never default missing or null', () {
      for (final json in [_once(), _periodic()]) {
        for (final key in json.keys) {
          expect(
            () => CreateAgentAutomationRequest.fromJson({...json}..remove(key)),
            throwsFormatException,
          );
          expect(
            () => CreateAgentAutomationRequest.fromJson({...json, key: null}),
            throwsFormatException,
          );
        }
        expect(
          () => CreateAgentAutomationRequest.fromJson({
            ...json,
            'PRIVATE_extra': true,
          }),
          throwsFormatException,
        );
        expect(
          () => CreateAgentAutomationRequest.fromJson({
            ...json,
            'metadata': null,
          }),
          throwsFormatException,
        );
      }
      expect(
        () => CreateAgentAutomationOnceRequest.fromJson(_periodic()),
        throwsFormatException,
      );
      expect(
        () => CreateAgentAutomationPeriodicRequest.fromJson(_once()),
        throwsFormatException,
      );
      expect(
        () =>
            CreateAgentAutomationRequest.fromJson({..._once(), 'run_at': 1.5}),
        throwsFormatException,
      );
    });

    test('names, expressions and timezone enforce exact code-point bounds', () {
      final target = AgentAutomationTarget.fromJson(_existing());
      expect(
        CreateAgentAutomationRequest.once(
          name: '😀' * 256,
          target: target,
          runAt: 0,
        ).toJson()['name'],
        '😀' * 256,
      );
      expect(
        CreateAgentAutomationRequest.periodic(
          name: ' ',
          target: target,
          expression: 'x' * 256,
          timezone: 'x' * 128,
        ).toJson()['timezone'],
        'x' * 128,
      );
      for (final name in ['', '😀' * 257]) {
        expect(
          () => CreateAgentAutomationRequest.once(
            name: name,
            target: target,
            runAt: 0,
          ),
          throwsFormatException,
        );
        expect(
          () => CreateAgentAutomationRequest.periodic(
            name: name,
            target: target,
            expression: '* * * * *',
            timezone: 'UTC',
          ),
          throwsFormatException,
        );
      }
      for (final expression in ['', 'x' * 257]) {
        expect(
          () => CreateAgentAutomationRequest.periodic(
            name: 'n',
            target: target,
            expression: expression,
            timezone: 'UTC',
          ),
          throwsFormatException,
        );
      }
      for (final timezone in ['', 'x' * 129]) {
        expect(
          () => CreateAgentAutomationRequest.periodic(
            name: 'n',
            target: target,
            expression: '* * * * *',
            timezone: timezone,
          ),
          throwsFormatException,
        );
      }
    });

    test('all creation fields participate in copy and value semantics', () {
      final once = CreateAgentAutomationOnceRequest.fromJson(_once());
      for (final variant in [
        once.copyWith(name: 'changed'),
        once.copyWith(runAt: 2000000001),
        once.copyWith(target: AgentAutomationTarget.fromJson(_newSession())),
        once.copyWith(metadata: {}),
      ]) {
        expect(variant, isNot(once));
      }
      expect(
        once.copyWith(metadata: {'p': 'v'}).copyWith(metadata: null),
        once,
      );
      expect(once.copyWith(metadata: {}).metadata, isEmpty);
      final periodic = CreateAgentAutomationPeriodicRequest.fromJson(
        _periodic(),
      );
      for (final variant in [
        periodic.copyWith(name: 'changed'),
        periodic.copyWith(expression: '5 9 * * *'),
        periodic.copyWith(timezone: 'UTC'),
        periodic.copyWith(target: AgentAutomationTarget.fromJson(_existing())),
        periodic.copyWith(metadata: {}),
      ]) {
        expect(variant, isNot(periodic));
      }
      expect(
        periodic.copyWith(metadata: {'p': 'v'}).copyWith(metadata: null),
        periodic,
      );
      expect(
        () => periodic.copyWith(metadata: {'p': 1}),
        throwsFormatException,
      );
      expect(() => once.copyWith(name: ''), throwsFormatException);
    });

    test('metadata owns inputs and preserves omitted versus empty', () {
      final source = {'p': 'PRIVATE'};
      final request = CreateAgentAutomationOnceRequest(
        name: 'n',
        target: AgentAutomationTarget.fromJson(_existing()),
        runAt: 2000000000,
        metadata: source,
      );
      source.clear();
      expect(request.metadata, {'p': 'PRIVATE'});
      expect(() => request.metadata!.clear(), throwsUnsupportedError);
      expect(request.copyWith().hashCode, request.hashCode);
      expect(
        request.copyWith(metadata: const {}).toJson()['metadata'],
        isEmpty,
      );
      expect(
        request.copyWith(metadata: null).toJson().containsKey('metadata'),
        isFalse,
      );
    });

    test('future creation shapes remain immutable, private and unwritable', () {
      final json = <String, dynamic>{
        'type': 'future_schedule',
        'PRIVATE': <String>['PRIVATE'],
      };
      final future =
          CreateAgentAutomationRequest.fromJson(json)
              as UnknownCreateAgentAutomationRequest;
      (json['PRIVATE'] as List).clear();
      expect(future.toJson()['PRIVATE'], ['PRIVATE']);
      expect(future.copyWith(), future);
      expect(future.copyWith().hashCode, future.hashCode);
      expect(future.toString(), isNot(contains('PRIVATE')));
      expect(future.validate, throwsFormatException);
      expect(
        () => UnknownCreateAgentAutomationRequest.fromJson(_once()),
        throwsFormatException,
      );
      final cycle = <String, dynamic>{'type': 'future'};
      cycle['PRIVATE'] = cycle;
      expect(
        () => CreateAgentAutomationRequest.fromJson(cycle),
        throwsFormatException,
      );
    });
  });

  group('automation target', () {
    test(
      'new target reuses optional session-agent settings without a model rule',
      () {
        final json = {
          'type': 'new_session',
          'agent': {
            'compaction': {'async': null},
            'experimental': {'time_awareness': false},
            'service_tier': 'ultrafast',
          },
          'environment': {'type': 'none'},
          'input': <Object?>[],
        };
        final target = AgentAutomationNewSessionTarget.fromJson(json);
        expect(target.agent!.model, isNull);
        expect(target.toJson(), json);
        expect(target.input, isEmpty);
        expect(target.copyWith(), target);
        expect(target.copyWith().hashCode, target.hashCode);
        expect(
          target.copyWith(agent: null, agentId: 'agent_1').toJson()['agent_id'],
          'agent_1',
        );
        expect(
          target
              .copyWith(agent: null, agentId: 'agent_1')
              .copyWith(agentId: null, agent: target.agent),
          target,
        );
        expect(() => target.copyWith(agentId: 'both'), throwsFormatException);
        expect(() => target.copyWith(agent: null), throwsFormatException);
      },
    );

    test(
      'new target requires exactly one nonnull agent and every required field',
      () {
        final json = _newSession();
        for (final key in ['type', 'environment', 'input']) {
          expect(
            () => AgentAutomationTarget.fromJson({...json}..remove(key)),
            throwsFormatException,
          );
          expect(
            () => AgentAutomationTarget.fromJson({...json, key: null}),
            throwsFormatException,
          );
        }
        for (final extra in <Map<String, dynamic>>[
          {'agent_id': null},
          {'agent': null},
          {'agent': <String, Object?>{}},
          {'review': 'none'},
          {'stream': true},
        ]) {
          expect(
            () => AgentAutomationTarget.fromJson({...json, ...extra}),
            throwsFormatException,
          );
        }
        expect(
          () => AgentAutomationTarget.fromJson({...json}..remove('agent_id')),
          throwsFormatException,
        );
        expect(
          () => AgentAutomationTarget.fromJson({
            ...json,
            'input': 'not a message array',
          }),
          throwsFormatException,
        );
        expect(
          () => AgentAutomationTarget.fromJson({
            ...json,
            'input': const [
              {'role': 'assistant', 'content': <Object?>[]},
            ],
          }),
          throwsFormatException,
        );
        expect(
          () => AgentAutomationTarget.fromJson({
            ...json,
            'input': const [
              {
                'role': 'user',
                'content': [
                  {'type': 'output_text', 'text': 'x'},
                ],
              },
            ],
          }),
          throwsFormatException,
        );
      },
    );

    test(
      'target nullable lists/maps retain omitted, null and empty wire states',
      () {
        final omitted = AgentAutomationNewSessionTarget.fromJson(_newSession());
        for (final values in <Map<String, dynamic>>[
          {'vault_ids': null, 'metadata': null},
          {'vault_ids': <String>[], 'metadata': <String, String>{}},
          {
            'vault_ids': ['v'],
            'metadata': {'p': 'v'},
          },
        ]) {
          final json = {..._newSession(), ...values};
          final target = AgentAutomationNewSessionTarget.fromJson(json);
          expect(target.toJson(), json);
          expect(target.copyWith(), target);
          expect(target.copyWith().hashCode, target.hashCode);
          expect(target, isNot(omitted));
        }
        final nulled = omitted.copyWith(vaultIds: null, metadata: null);
        expect(nulled.clearVaultIds && nulled.clearMetadata, isTrue);
        expect(
          nulled.copyWith(clearVaultIds: false, clearMetadata: false),
          omitted,
        );
        final empty = nulled.copyWith(vaultIds: [], metadata: {});
        expect(empty.toJson()['vault_ids'], isEmpty);
        expect(empty.toJson()['metadata'], isEmpty);
        expect(empty.clearVaultIds || empty.clearMetadata, isFalse);
        expect(empty, isNot(nulled));
      },
    );

    test(
      'existing target bounds permit exact empty strings and reject extras',
      () {
        final target = AgentAutomationExistingSessionTarget(
          sessionId: '',
          instructions: '',
        );
        expect(target.toJson(), {
          'type': 'existing_session',
          'session_id': '',
          'instructions': '',
        });
        expect(target.copyWith(), target);
        expect(target.copyWith().hashCode, target.hashCode);
        expect(target.copyWith(sessionId: 's'), isNot(target));
        expect(target.copyWith(instructions: 'x'), isNot(target));
        expect(
          AgentAutomationExistingSessionTarget(
            sessionId: '😀' * 1048576,
            instructions: '😀' * 1048576,
          ).sessionId.runes.length,
          1048576,
        );
        expect(
          () => target.copyWith(sessionId: 'a' * 1048577),
          throwsFormatException,
        );
        expect(
          () => target.copyWith(instructions: 'a' * 1048577),
          throwsFormatException,
        );
        for (final key in ['type', 'session_id', 'instructions']) {
          expect(
            () => AgentAutomationTarget.fromJson({..._existing()}..remove(key)),
            throwsFormatException,
          );
          expect(
            () => AgentAutomationTarget.fromJson({..._existing(), key: null}),
            throwsFormatException,
          );
        }
        expect(
          () =>
              AgentAutomationTarget.fromJson({..._existing(), 'agent_id': 'a'}),
          throwsFormatException,
        );
      },
    );

    test(
      'new target list/ID limits and collection ownership match canonical',
      () {
        final input = <AgentSessionInputMessage>[
          AgentSessionInputMessage(content: const []),
        ];
        final vaults = <String>['PRIVATE'];
        final metadata = {'p': 'PRIVATE'};
        final target = AgentAutomationNewSessionTarget(
          agentId: '',
          environment: AgentSessionEnvironment.none(),
          input: input,
          vaultIds: vaults,
          metadata: metadata,
        );
        input.clear();
        vaults.clear();
        metadata.clear();
        expect(target.input.length, 1);
        expect(target.vaultIds, ['PRIVATE']);
        expect(target.metadata, {'p': 'PRIVATE'});
        expect(target.input.clear, throwsUnsupportedError);
        expect(() => target.vaultIds!.clear(), throwsUnsupportedError);
        expect(() => target.metadata!.clear(), throwsUnsupportedError);
        expect(target.toString(), isNot(contains('PRIVATE')));
        expect(target.copyWith(agentId: '😀' * 64).agentId!.runes.length, 64);
        expect(
          () => target.copyWith(agentId: '😀' * 65),
          throwsFormatException,
        );
        expect(
          target
              .copyWith(
                input: List.filled(
                  16384,
                  AgentSessionInputMessage(content: const []),
                ),
              )
              .input
              .length,
          16384,
        );
        expect(
          () => target.copyWith(
            input: List.filled(
              16385,
              AgentSessionInputMessage(content: const []),
            ),
          ),
          throwsFormatException,
        );
        expect(
          target.copyWith(vaultIds: List.filled(16384, '')).vaultIds!.length,
          16384,
        );
        expect(
          () => target.copyWith(vaultIds: List.filled(16385, '')),
          throwsFormatException,
        );
        expect(
          target
              .copyWith(vaultIds: ['😀' * 1048576])
              .vaultIds!
              .single
              .runes
              .length,
          1048576,
        );
        expect(
          () => target.copyWith(vaultIds: ['a' * 1048577]),
          throwsFormatException,
        );
        expect(() => target.copyWith(vaultIds: [1]), throwsFormatException);
      },
    );

    test(
      'future targets cannot be submitted through known creation or updates',
      () {
        final target =
            AgentAutomationTarget.fromJson(const {
                  'type': 'PRIVATE-future',
                  'value': {
                    'items': <String>['PRIVATE'],
                  },
                })
                as UnknownAgentAutomationTarget;
        expect(target.copyWith(), target);
        expect(target.copyWith().hashCode, target.hashCode);
        expect(target.toString(), isNot(contains('PRIVATE')));
        expect(target.validate, throwsFormatException);
        expect(
          () => CreateAgentAutomationOnceRequest(
            name: 'n',
            target: target,
            runAt: 2000000000,
          ),
          throwsFormatException,
        );
        expect(
          () => UpdateAgentAutomationRequest(target: target),
          throwsFormatException,
        );
        expect(
          () => UnknownAgentAutomationTarget.fromJson(_existing()),
          throwsFormatException,
        );
        expect(
          () => AgentAutomationTarget.fromJson(const {
            'type': 'future',
            'bad': double.infinity,
          }),
          throwsFormatException,
        );
      },
    );
  });

  group('automation updates', () {
    test(
      'all fields round-trip and copy independently with no discriminator',
      () {
        final json = {
          'name': 'PRIVATE name',
          'target': _existing(),
          'metadata': {'p': 'PRIVATE'},
          'expression': '0 9 * * *',
          'timezone': 'UTC',
          'run_at': 2000000000,
        };
        final update = UpdateAgentAutomationRequest.fromJson(json);
        expect(update.toJson(), json);
        expect(update.copyWith(), update);
        expect(update.copyWith().hashCode, update.hashCode);
        expect(update.toString(), isNot(contains('PRIVATE')));
        for (final variant in [
          update.copyWith(name: null),
          update.copyWith(target: null),
          update.copyWith(metadata: null),
          update.copyWith(expression: null),
          update.copyWith(timezone: null),
          update.copyWith(runAt: null),
        ]) {
          expect(variant, isNot(update));
        }
        expect(
          update
              .copyWith(
                name: null,
                target: null,
                metadata: null,
                expression: null,
                timezone: null,
                runAt: null,
              )
              .toJson(),
          isEmpty,
        );
        expect(UpdateAgentAutomationRequest().copyWith(metadata: {}).toJson(), {
          'metadata': <String, String>{},
        });
        expect(
          () => UpdateAgentAutomationRequest.fromJson(const {'type': 'once'}),
          throwsFormatException,
        );
      },
    );

    test('every optional update wire field is nonnullable and typed', () {
      for (final key in [
        'name',
        'target',
        'metadata',
        'expression',
        'timezone',
        'run_at',
      ]) {
        expect(
          () => UpdateAgentAutomationRequest.fromJson({key: null}),
          throwsFormatException,
        );
      }
      for (final json in <Map<String, dynamic>>[
        {'name': 1},
        {'target': false},
        {'metadata': false},
        {'expression': 1},
        {'timezone': 1},
        {'run_at': 1.5},
        {'run_at': double.nan},
      ]) {
        expect(
          () => UpdateAgentAutomationRequest.fromJson(json),
          throwsFormatException,
        );
      }
      expect(
        () => UpdateAgentAutomationRequest(name: ''),
        throwsFormatException,
      );
      expect(
        () => UpdateAgentAutomationRequest(expression: 'a' * 257),
        throwsFormatException,
      );
      expect(
        () => UpdateAgentAutomationRequest(timezone: 'a' * 129),
        throwsFormatException,
      );
      expect(
        () => UpdateAgentAutomationRequest().copyWith(runAt: 1.5),
        throwsFormatException,
      );
    });
  });

  test('metadata limits apply to create, update and new-session target', () {
    final target = AgentAutomationNewSessionTarget.fromJson(_newSession());
    final once = CreateAgentAutomationOnceRequest.fromJson(_once());
    final periodic = CreateAgentAutomationPeriodicRequest.fromJson(_periodic());
    final update = UpdateAgentAutomationRequest();
    final valid = {for (var n = 0; n < 16; n++) '$n': '😀' * 512};
    expect(once.copyWith(metadata: valid).metadata!.length, 16);
    expect(periodic.copyWith(metadata: {'😀' * 64: ''}).metadata!.length, 1);
    expect(target.copyWith(metadata: valid).metadata!.length, 16);
    expect(update.copyWith(metadata: valid).metadata!.length, 16);
    for (final invalid in <Map<String, String>>[
      {'': ''},
      {'a' * 65: ''},
      {'k': '😀' * 513},
      {for (var n = 0; n < 17; n++) '$n': ''},
    ]) {
      expect(() => once.copyWith(metadata: invalid), throwsFormatException);
      expect(() => periodic.copyWith(metadata: invalid), throwsFormatException);
      expect(() => target.copyWith(metadata: invalid), throwsFormatException);
      expect(() => update.copyWith(metadata: invalid), throwsFormatException);
    }
    for (final invalid in <Object>[
      {'p': true},
      {1: 'PRIVATE'},
      [],
    ]) {
      expect(() => once.copyWith(metadata: invalid), throwsFormatException);
      expect(() => target.copyWith(metadata: invalid), throwsFormatException);
    }
  });
}
