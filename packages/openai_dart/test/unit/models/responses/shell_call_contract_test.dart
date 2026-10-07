import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _call({bool metadata = true}) => {
  'type': 'shell_call',
  'id': 'sh_1',
  'call_id': 'call_1',
  'action': {
    'commands': ['secret-command'],
    'timeout_ms': null,
    'max_output_length': null,
  },
  'status': 'completed',
  'environment': {'type': 'container_reference', 'container_id': 'cntr_1'},
  if (metadata) 'agent': {'agent_name': 'worker'},
  if (metadata) 'caller': {'type': 'program', 'caller_id': 'program_1'},
  if (metadata) 'created_by': 'secret-creator',
};

Map<String, dynamic> _result({bool metadata = true}) => {
  'type': 'shell_call_output',
  'id': 'sho_1',
  'call_id': 'call_1',
  'status': 'completed',
  'max_output_length': null,
  'output': [
    {
      'stdout': 'secret-stdout',
      'stderr': 'secret-stderr',
      'outcome': {'type': 'exit', 'exit_code': 0},
      if (metadata) 'created_by': 'secret-chunk-creator',
    },
    {
      'stdout': '',
      'stderr': '',
      'outcome': {'type': 'timeout'},
    },
  ],
  if (metadata) 'agent': {'agent_name': 'worker'},
  if (metadata) 'caller': {'type': 'program', 'caller_id': 'program_1'},
  if (metadata) 'created_by': 'secret-creator',
};

Matcher _bad(String field) => throwsA(
  isA<FormatException>().having(
    (error) => error.message,
    'field context',
    contains(field),
  ),
);

void _returned<T>(
  String name,
  T Function(Map<String, dynamic>) parse,
  Map<String, dynamic> Function(T) write,
  List<T> Function(T) copies,
  T Function(T) clear, {
  required bool result,
  bool nullableAgent = false,
}) {
  final fixture = result ? _result : _call;
  group(name, () {
    test('complete equality/hash and exact round-trip', () {
      final a = parse(fixture());
      final b = parse(fixture());
      expect(write(a), fixture());
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(parse(write(a)), a);
      expect(parse(write(a)).hashCode, a.hashCode);
      expect(a.toString(), isNot(contains('secret')));
    });
    test('copy includes every field and clears optional metadata', () {
      final value = parse(fixture());
      final changed = copies(value);
      for (final copy in changed) {
        expect(copy, isNot(value));
        expect(parse(write(copy)), copy);
        expect(parse(write(copy)).hashCode, copy.hashCode);
      }
      final cleared = write(clear(value));
      expect(cleared.containsKey('agent'), isFalse);
      expect(cleared.containsKey('caller'), isFalse);
      expect(cleared.containsKey('created_by'), isFalse);
      expect(cleared[result ? 'max_output_length' : 'environment'], isNull);
      expect(
        cleared.containsKey(result ? 'max_output_length' : 'environment'),
        isTrue,
      );
    });
    for (final field in [
      'type',
      'id',
      'call_id',
      'status',
      if (result) 'output' else 'action',
      if (result) 'max_output_length' else 'environment',
    ]) {
      test('rejects omitted required $field', () {
        final json = fixture()..remove(field);
        expect(() => parse(json), _bad(field));
      });
    }
    for (final field in [
      'type',
      'id',
      'call_id',
      'status',
      if (result) 'output' else 'action',
    ]) {
      for (final invalid in [
        null,
        12,
        true,
        <Object?>[],
        <String, Object?>{},
      ]) {
        if (field == 'output' && invalid is List) continue;
        test('rejects invalid $field ${invalid.runtimeType}', () {
          final json = fixture()..[field] = invalid;
          expect(() => parse(json), _bad(field));
        });
      }
    }
    test(
      'required nullable key preserves null and unknown status fallback',
      () {
        final json = fixture(metadata: false)
          ..[result ? 'max_output_length' : 'environment'] = null;
        final value = parse(json);
        expect(write(value), json);
        expect(
          parse({...json, 'status': 'future'}),
          parse({...json, 'status': 'unknown'}),
        );
      },
    );
    for (final field in ['created_by', 'agent', 'caller']) {
      for (final invalid in [false, 12, <Object?>[]]) {
        test('rejects malformed optional $field ${invalid.runtimeType}', () {
          expect(() => parse({...fixture(), field: invalid}), _bad(field));
        });
      }
    }
    test(
      'optional created_by rejects null',
      () => expect(
        () => parse({...fixture(), 'created_by': null}),
        _bad('created_by'),
      ),
    );
    test(
      'caller null normalizes to omission',
      () => expect(
        write(parse({...fixture(), 'caller': null})).containsKey('caller'),
        isFalse,
      ),
    );
    test('agent null follows directional policy', () {
      final json = {...fixture(), 'agent': null};
      if (nullableAgent) {
        expect(write(parse(json)).containsKey('agent'), isFalse);
      } else {
        expect(() => parse(json), _bad('agent'));
      }
    });
    test('nested agent/caller fields have contextual errors', () {
      expect(
        () => parse({
          ...fixture(),
          'agent': {'agent_name': null},
        }),
        _bad('agent.agent_name'),
      );
      expect(
        () => parse({
          ...fixture(),
          'caller': {'type': 'program', 'caller_id': null},
        }),
        _bad('caller.caller_id'),
      );
    });
    test(
      'optional metadata omission',
      () => expect(
        write(parse(fixture(metadata: false))),
        fixture(metadata: false),
      ),
    );
    if (result) {
      test('parsed output is immutable, empty output remains present', () {
        final json = fixture()..['output'] = <Object?>[];
        expect(write(parse(json))['output'], isEmpty);
      });
      test('result output and length errors are contextual', () {
        expect(
          () => parse({
            ...fixture(),
            'output': [null],
          }),
          _bad('output[0]'),
        );
        expect(
          () => parse({
            ...fixture(),
            'output': [
              {
                'stdout': 12,
                'stderr': '',
                'outcome': {'type': 'timeout'},
              },
            ],
          }),
          _bad('output[0].stdout'),
        );
        expect(
          () => parse({...fixture(), 'max_output_length': 1.5}),
          _bad('max_output_length'),
        );
      });
    } else {
      test('returned environment rejects auto and malformed known shapes', () {
        expect(
          () => parse({
            ...fixture(),
            'environment': {'type': 'container_auto'},
          }),
          _bad('environment.type'),
        );
        expect(
          () => parse({
            ...fixture(),
            'environment': {
              'type': 'container_reference',
              'container_id': null,
            },
          }),
          _bad('environment.container_id'),
        );
        expect(
          () => parse({...fixture(), 'environment': <Object?>[]}),
          _bad('environment'),
        );
      });
      test(
        'returned local has no skills and future environment retains payload',
        () {
          expect(
            write(
              parse({
                ...fixture(),
                'environment': {'type': 'local'},
              }),
            )['environment'],
            {'type': 'local'},
          );
          final future = {
            'type': 'future',
            'nested': {
              'items': [1, 2],
            },
          };
          expect(
            write(parse({...fixture(), 'environment': future}))['environment'],
            future,
          );
        },
      );
    }
  });
}

void main() {
  test('local environment equality distinguishes derived instances', () {
    expect(
      const LocalShellEnvironment(),
      isNot(const _DerivedLocalEnvironment()),
    );
    expect(
      const _DerivedLocalEnvironment(),
      isNot(const LocalShellEnvironment()),
    );
    expect(const LocalShellEnvironment(), const LocalShellEnvironment());
    expect(
      const LocalShellEnvironment().hashCode,
      const LocalShellEnvironment().copyWith().hashCode,
    );
  });
  test('timeout outcome equality distinguishes derived instances', () {
    expect(
      const ShellCallTimeoutOutcome(),
      isNot(const _DerivedTimeoutOutcome()),
    );
    expect(
      const _DerivedTimeoutOutcome(),
      isNot(const ShellCallTimeoutOutcome()),
    );
    expect(const ShellCallTimeoutOutcome(), const ShellCallTimeoutOutcome());
    expect(
      const ShellCallTimeoutOutcome().hashCode,
      const ShellCallTimeoutOutcome().copyWith().hashCode,
    );
  });
  test('exit outcome retains exact-runtime equality', () {
    expect(
      const ShellCallExitOutcome(exitCode: 3),
      isNot(const _DerivedExitOutcome()),
    );
    expect(
      const _DerivedExitOutcome(),
      isNot(const ShellCallExitOutcome(exitCode: 3)),
    );
    expect(
      const ShellCallExitOutcome(exitCode: 3),
      const ShellCallExitOutcome(exitCode: 3),
    );
    expect(
      const ShellCallExitOutcome(exitCode: 3).hashCode,
      const ShellCallExitOutcome(exitCode: 3).copyWith().hashCode,
    );
  });
  _returned<ShellCallOutputItem>(
    'ShellCallOutputItem',
    ShellCallOutputItem.fromJson,
    (value) => value.toJson(),
    (value) => [
      value.copyWith(id: 'different'),
      value.copyWith(agent: const AgentTag(agentName: 'other')),
      value.copyWith(callId: 'different'),
      value.copyWith(status: ItemStatus.inProgress),
      value.copyWith(caller: const DirectToolCallCaller()),
      value.copyWith(createdBy: 'different'),
      value.copyWith(action: value.action.copyWith(commands: ['different'])),
      value.copyWith(environment: const LocalShellEnvironment()),
    ],
    (value) => value.copyWith(
      agent: null,
      caller: null,
      createdBy: null,
      environment: null,
    ),
    result: false,
    nullableAgent: true,
  );
  _returned<ShellCallResourceItem>(
    'ShellCallResourceItem',
    ShellCallResourceItem.fromJson,
    (value) => value.toJson(),
    (value) => [
      value.copyWith(id: 'different'),
      value.copyWith(agent: const AgentTag(agentName: 'other')),
      value.copyWith(callId: 'different'),
      value.copyWith(status: ItemStatus.inProgress),
      value.copyWith(caller: const DirectToolCallCaller()),
      value.copyWith(createdBy: 'different'),
      value.copyWith(action: value.action.copyWith(commands: ['different'])),
      value.copyWith(environment: const LocalShellEnvironment()),
    ],
    (value) => value.copyWith(
      agent: null,
      caller: null,
      createdBy: null,
      environment: null,
    ),
    result: false,
    nullableAgent: false,
  );
  _returned<ConversationShellCallItem>(
    'ConversationShellCallItem',
    ConversationShellCallItem.fromJson,
    (value) => value.toJson(),
    (value) => [
      value.copyWith(id: 'different'),
      value.copyWith(agent: const AgentTag(agentName: 'other')),
      value.copyWith(callId: 'different'),
      value.copyWith(status: ItemStatus.inProgress),
      value.copyWith(caller: const DirectToolCallCaller()),
      value.copyWith(createdBy: 'different'),
      value.copyWith(action: value.action.copyWith(commands: ['different'])),
      value.copyWith(environment: const LocalShellEnvironment()),
    ],
    (value) => value.copyWith(
      agent: null,
      caller: null,
      createdBy: null,
      environment: null,
    ),
    result: false,
    nullableAgent: false,
  );
  _returned<ShellCallOutputResultItem>(
    'ShellCallOutputResultItem',
    ShellCallOutputResultItem.fromJson,
    (value) => value.toJson(),
    (value) => [
      value.copyWith(id: 'different'),
      value.copyWith(agent: const AgentTag(agentName: 'other')),
      value.copyWith(callId: 'different'),
      value.copyWith(status: ItemStatus.inProgress),
      value.copyWith(caller: const DirectToolCallCaller()),
      value.copyWith(createdBy: 'different'),
      value.copyWith(output: []),
      value.copyWith(maxOutputLength: 10),
    ],
    (value) => value.copyWith(
      agent: null,
      caller: null,
      createdBy: null,
      maxOutputLength: null,
    ),
    result: true,
    nullableAgent: true,
  );
  _returned<ShellCallOutputResourceItem>(
    'ShellCallOutputResourceItem',
    ShellCallOutputResourceItem.fromJson,
    (value) => value.toJson(),
    (value) => [
      value.copyWith(id: 'different'),
      value.copyWith(agent: const AgentTag(agentName: 'other')),
      value.copyWith(callId: 'different'),
      value.copyWith(status: ItemStatus.inProgress),
      value.copyWith(caller: const DirectToolCallCaller()),
      value.copyWith(createdBy: 'different'),
      value.copyWith(output: []),
      value.copyWith(maxOutputLength: 10),
    ],
    (value) => value.copyWith(
      agent: null,
      caller: null,
      createdBy: null,
      maxOutputLength: null,
    ),
    result: true,
    nullableAgent: false,
  );
  _returned<ConversationShellCallOutputItem>(
    'ConversationShellCallOutputItem',
    ConversationShellCallOutputItem.fromJson,
    (value) => value.toJson(),
    (value) => [
      value.copyWith(id: 'different'),
      value.copyWith(agent: const AgentTag(agentName: 'other')),
      value.copyWith(callId: 'different'),
      value.copyWith(status: ItemStatus.inProgress),
      value.copyWith(caller: const DirectToolCallCaller()),
      value.copyWith(createdBy: 'different'),
      value.copyWith(output: []),
      value.copyWith(maxOutputLength: 10),
    ],
    (value) => value.copyWith(
      agent: null,
      caller: null,
      createdBy: null,
      maxOutputLength: null,
    ),
    result: true,
    nullableAgent: false,
  );

  group('directional factories and conversion', () {
    test(
      'input/resource/conversation dispatch selects exact directional models',
      () {
        expect(Item.fromJson(_call()), isA<ShellCallInputItem>());
        expect(Item.fromResourceJson(_call()), isA<ShellCallResourceItem>());
        expect(OutputItem.fromJson(_call()), isA<ShellCallOutputItem>());
        expect(
          ConversationItem.fromJson(_call()),
          isA<ConversationShellCallItem>(),
        );
        expect(Item.fromJson(_result()), isA<ShellCallOutputInputItem>());
        expect(
          Item.fromResourceJson(_result()),
          isA<ShellCallOutputResourceItem>(),
        );
        expect(
          OutputItem.fromJson(_result()),
          isA<ShellCallOutputResultItem>(),
        );
        expect(
          ConversationItem.fromJson(_result()),
          isA<ConversationShellCallOutputItem>(),
        );
      },
    );
    test(
      'all call replay helpers preserve supported metadata and omit creator',
      () {
        final input = ShellCallInputItem.fromJson(_call());
        final values = [
          ShellCallOutputItem.fromJson(_call()).toShellCallInputItem(),
          ShellCallResourceItem.fromJson(_call()).toShellCallInputItem(),
          ConversationShellCallItem.fromJson(_call()).toShellCallInputItem(),
        ];
        for (final value in values) {
          expect(value, input);
          expect(value.hashCode, input.hashCode);
          expect(value.toJson().containsKey('created_by'), isFalse);
          expect(value.action.toJson().containsKey('timeout_ms'), isFalse);
        }
      },
    );
    test(
      'all result replay helpers preserve supported metadata and omit creators',
      () {
        final input = ShellCallOutputInputItem.fromJson(_result());
        final values = [
          ShellCallOutputResultItem.fromJson(
            _result(),
          ).toShellCallOutputInputItem(),
          ShellCallOutputResourceItem.fromJson(
            _result(),
          ).toShellCallOutputInputItem(),
          ConversationShellCallOutputItem.fromJson(
            _result(),
          ).toShellCallOutputInputItem(),
        ];
        for (final value in values) {
          expect(value, input);
          expect(value.hashCode, input.hashCode);
          expect(value.toJson().containsKey('created_by'), isFalse);
          expect(
            (value.toJson()['output'] as List).first,
            isNot(contains('created_by')),
          );
          expect(value.toJson().containsKey('max_output_length'), isFalse);
        }
      },
    );
    test(
      'returned action and content leaf bridges omit only returned metadata',
      () {
        const action = ShellCallAction(
          commands: ['cmd'],
          timeoutMs: 10,
          maxOutputLength: 20,
        );
        expect(action.toInput().toJson(), action.toJson());
        const content = ShellCallOutputContent(
          stdout: 'out',
          stderr: '',
          outcome: ShellCallTimeoutOutcome(),
          createdBy: 'creator',
        );
        expect(content.toInput().toJson(), {
          'stdout': 'out',
          'stderr': '',
          'outcome': {'type': 'timeout'},
        });
      },
    );
    test('local and unknown environment replay is directional', () {
      final local = ShellCallOutputItem.fromJson({
        ..._call(),
        'environment': const {'type': 'local'},
      }).toShellCallInputItem();
      expect(local.environment, LocalShellToolEnvironment());
      final future = {
        'type': 'future',
        'options': {
          'items': [1, 2],
        },
      };
      expect(
        ShellCallOutputItem.fromJson({
          ..._call(),
          'environment': future,
        }).toShellCallInputItem().toJson()['environment'],
        future,
      );
    });
  });

  group('writable shell input', () {
    final minimal = {
      'type': 'shell_call',
      'call_id': 'call_1',
      'action': {
        'commands': ['secret-command'],
      },
    };
    test('minimal and full input preserve writable fields only', () {
      expect(ShellCallInputItem.fromJson(minimal).toJson(), minimal);
      final value = ShellCallInputItem.fromJson(_call());
      final roundtrip = ShellCallInputItem.fromJson(value.toJson());
      expect(roundtrip, value);
      expect(roundtrip.hashCode, value.hashCode);
      expect(value.toString(), isNot(contains('secret-command')));
      expect(value.toJson().containsKey('created_by'), isFalse);
    });
    test('nullable request fields normalize null to omission', () {
      final json = {
        ...minimal,
        'id': null,
        'agent': null,
        'status': null,
        'environment': null,
        'caller': null,
        'action': {
          'commands': ['secret-command'],
          'timeout_ms': null,
          'max_output_length': null,
        },
      };
      expect(ShellCallInputItem.fromJson(json).toJson(), minimal);
    });
    test('local skill request environment survives replay and snapshots', () {
      final environment = LocalShellToolEnvironment(
        skills: const [
          ShellLocalSkill(
            name: 'skill',
            description: 'desc',
            path: '/skills/path',
          ),
        ],
      );
      final value = ShellCallInputItem(
        callId: 'call',
        action: ShellCallActionInput(commands: const []),
        environment: environment,
      );
      expect(ShellCallInputItem.fromJson(value.toJson()), value);
      expect((value.toJson()['environment'] as Map)['skills'], [
        {'name': 'skill', 'description': 'desc', 'path': '/skills/path'},
      ]);
    });
    test(
      'container auto is rejected on parsing and constructed serialization',
      () {
        expect(
          () => ShellCallInputItem.fromJson({
            ...minimal,
            'environment': const {'type': 'container_auto'},
          }),
          _bad('environment.type'),
        );
        final value = ShellCallInputItem(
          callId: 'call',
          action: ShellCallActionInput(commands: const []),
          environment: ContainerAutoShellToolEnvironment(),
        );
        expect(value.toJson, throwsArgumentError);
      },
    );
    test('input nullable fields copy and clear independently', () {
      final value = ShellCallInputItem.fromJson(_call());
      final copies = [
        value.copyWith(id: 'other'),
        value.copyWith(agent: const AgentTag(agentName: 'other')),
        value.copyWith(callId: 'other'),
        value.copyWith(action: ShellCallActionInput(commands: const [])),
        value.copyWith(status: ItemStatus.inProgress),
        value.copyWith(environment: LocalShellToolEnvironment()),
        value.copyWith(caller: const DirectToolCallCaller()),
      ];
      expect(value.copyWith(), value);
      for (final copy in copies) {
        expect(copy, isNot(value));
        expect(ShellCallInputItem.fromJson(copy.toJson()), copy);
      }
      final cleared = value.copyWith(
        id: null,
        agent: null,
        status: null,
        environment: null,
        caller: null,
      );
      expect(cleared.toJson(), minimal);
    });
    for (final field in ['type', 'call_id', 'action']) {
      test(
        'input rejects omitted required $field',
        () => expect(
          () => ShellCallInputItem.fromJson({...minimal}..remove(field)),
          _bad(field),
        ),
      );
      for (final invalid in [null, false, 12, <Object?>[]]) {
        test(
          'input rejects malformed $field ${invalid.runtimeType}',
          () => expect(
            () => ShellCallInputItem.fromJson({...minimal, field: invalid}),
            _bad(field),
          ),
        );
      }
    }
    for (final field in ['id', 'status', 'agent', 'caller', 'environment']) {
      test(
        'input rejects malformed $field',
        () => expect(
          () => ShellCallInputItem.fromJson({...minimal, field: 12}),
          _bad(field),
        ),
      );
    }
    test('nested input environment errors include full path', () {
      expect(
        () => ShellCallInputItem.fromJson({
          ...minimal,
          'environment': const {
            'type': 'container_reference',
            'container_id': null,
          },
        }),
        _bad('environment'),
      );
      expect(
        () => ShellCallInputItem.fromJson({
          ...minimal,
          'environment': const {'type': 'local', 'skills': null},
        }),
        _bad('environment'),
      );
    });
  });

  group('writable shell results', () {
    final minimal = {
      'type': 'shell_call_output',
      'call_id': 'call_1',
      'output': <Object?>[],
    };
    test('minimal, full, empty and optional-null result fields', () {
      expect(ShellCallOutputInputItem.fromJson(minimal).toJson(), minimal);
      expect(
        ShellCallOutputInputItem.fromJson({
          ...minimal,
          'id': null,
          'agent': null,
          'status': null,
          'caller': null,
          'max_output_length': null,
        }).toJson(),
        minimal,
      );
      final value = ShellCallOutputInputItem.fromJson(_result());
      expect(ShellCallOutputInputItem.fromJson(value.toJson()), value);
      expect(
        ShellCallOutputInputItem.fromJson(value.toJson()).hashCode,
        value.hashCode,
      );
      expect(value.toString(), isNot(contains('secret')));
    });
    test(
      'input result snapshots output and supports copy/clear for every field',
      () {
        final chunks = [
          const ShellCallOutputContentInput(
            stdout: 'out',
            stderr: '',
            outcome: ShellCallExitOutcome(exitCode: 0),
          ),
        ];
        final snapshot = ShellCallOutputInputItem(
          callId: 'call',
          output: chunks,
        );
        chunks.clear();
        expect(snapshot.output, hasLength(1));
        expect(snapshot.output.clear, throwsUnsupportedError);
        final value = ShellCallOutputInputItem.fromJson(
          _result(),
        ).copyWith(maxOutputLength: 10);
        final copies = [
          value.copyWith(id: 'other'),
          value.copyWith(agent: const AgentTag(agentName: 'other')),
          value.copyWith(callId: 'other'),
          value.copyWith(status: ItemStatus.inProgress),
          value.copyWith(output: []),
          value.copyWith(maxOutputLength: 20),
          value.copyWith(caller: const DirectToolCallCaller()),
        ];
        expect(value.copyWith(), value);
        for (final copy in copies) {
          expect(copy, isNot(value));
          expect(ShellCallOutputInputItem.fromJson(copy.toJson()), copy);
          expect(
            ShellCallOutputInputItem.fromJson(copy.toJson()).hashCode,
            copy.hashCode,
          );
        }
        final cleared = value.copyWith(
          id: null,
          agent: null,
          status: null,
          caller: null,
          maxOutputLength: null,
        );
        expect(
          cleared.toJson().keys,
          unorderedEquals(['type', 'call_id', 'output']),
        );
      },
    );
    for (final field in ['type', 'call_id', 'output']) {
      test(
        'result input rejects omitted required $field',
        () => expect(
          () => ShellCallOutputInputItem.fromJson({...minimal}..remove(field)),
          _bad(field),
        ),
      );
      for (final invalid in [null, false, 12, <String, Object?>{}]) {
        test(
          'result input rejects malformed $field ${invalid.runtimeType}',
          () => expect(
            () =>
                ShellCallOutputInputItem.fromJson({...minimal, field: invalid}),
            _bad(field),
          ),
        );
      }
    }
    for (final field in [
      'id',
      'agent',
      'status',
      'caller',
      'max_output_length',
    ]) {
      test(
        'result input rejects malformed optional $field',
        () => expect(
          () => ShellCallOutputInputItem.fromJson({...minimal, field: false}),
          _bad(field),
        ),
      );
    }
  });

  group('actions', () {
    test(
      'returned required-nullable keys and input optional limits differ',
      () {
        const action = ShellCallAction(
          commands: ['cmd'],
          timeoutMs: null,
          maxOutputLength: null,
        );
        expect(action.toJson(), {
          'commands': ['cmd'],
          'timeout_ms': null,
          'max_output_length': null,
        });
        expect(action.toInput().toJson(), {
          'commands': ['cmd'],
        });
        expect(ShellCallActionInput.fromJson(action.toJson()).toJson(), {
          'commands': ['cmd'],
        });
        expect(action.copyWith(), action);
      },
    );
    test('action copies change every field and clear limits', () {
      const value = ShellCallAction(
        commands: ['cmd'],
        timeoutMs: 1,
        maxOutputLength: 2,
      );
      final input = value.toInput();
      for (final copy in [
        value.copyWith(commands: []),
        value.copyWith(timeoutMs: 3),
        value.copyWith(maxOutputLength: 4),
      ]) {
        expect(copy, isNot(value));
        expect(ShellCallAction.fromJson(copy.toJson()), copy);
        expect(ShellCallAction.fromJson(copy.toJson()).hashCode, copy.hashCode);
      }
      for (final copy in [
        input.copyWith(commands: []),
        input.copyWith(timeoutMs: 3),
        input.copyWith(maxOutputLength: 4),
      ]) {
        expect(copy, isNot(input));
        expect(ShellCallActionInput.fromJson(copy.toJson()), copy);
        expect(
          ShellCallActionInput.fromJson(copy.toJson()).hashCode,
          copy.hashCode,
        );
      }
      expect(value.copyWith(timeoutMs: null, maxOutputLength: null).toJson(), {
        'commands': ['cmd'],
        'timeout_ms': null,
        'max_output_length': null,
      });
      expect(input.copyWith(timeoutMs: null, maxOutputLength: null).toJson(), {
        'commands': ['cmd'],
      });
    });
    test(
      'parsed returned commands immutable; input constructor snapshots commands',
      () {
        final returned = ShellCallAction.fromJson(const {
          'commands': ['cmd'],
          'timeout_ms': null,
          'max_output_length': null,
        });
        expect(() => returned.commands.add('x'), throwsUnsupportedError);
        final commands = ['cmd'];
        final input = ShellCallActionInput(commands: commands);
        commands.clear();
        expect(input.commands, ['cmd']);
        expect(input.commands.clear, throwsUnsupportedError);
        expect(input.copyWith(), input);
      },
    );
    for (final key in ['commands', 'timeout_ms', 'max_output_length']) {
      test(
        'returned action rejects missing $key',
        () => expect(
          () => ShellCallAction.fromJson(
            {
              'commands': <String>[],
              'timeout_ms': null,
              'max_output_length': null,
            }..remove(key),
          ),
          _bad(key),
        ),
      );
      test('both actions reject malformed $key', () {
        final json = {
          'commands': <Object?>[],
          'timeout_ms': null,
          'max_output_length': null,
          key: false,
        };
        expect(() => ShellCallAction.fromJson(json), _bad(key));
        expect(() => ShellCallActionInput.fromJson(json), _bad(key));
      });
    }
    test('array members have contextual validation', () {
      expect(
        () => ShellCallAction.fromJson(const {
          'commands': [null],
          'timeout_ms': null,
          'max_output_length': null,
        }),
        _bad('commands[0]'),
      );
      expect(
        () => ShellCallActionInput.fromJson(const {
          'commands': [12],
        }),
        _bad('commands[0]'),
      );
    });
  });

  group('content and outcomes', () {
    test('returned content copies every field and clears creator', () {
      const value = ShellCallOutputContent(
        stdout: 'secret-out',
        stderr: 'secret-error',
        outcome: ShellCallExitOutcome(exitCode: 0),
        createdBy: 'secret-creator',
      );
      expect(value.copyWith(), value);
      for (final copy in [
        value.copyWith(stdout: 'different'),
        value.copyWith(stderr: 'different'),
        value.copyWith(outcome: const ShellCallTimeoutOutcome()),
        value.copyWith(createdBy: 'different'),
      ]) {
        expect(copy, isNot(value));
        expect(ShellCallOutputContent.fromJson(copy.toJson()), copy);
        expect(
          ShellCallOutputContent.fromJson(copy.toJson()).hashCode,
          copy.hashCode,
        );
      }
      expect(
        value.copyWith(createdBy: null).toJson().containsKey('created_by'),
        isFalse,
      );
      expect(value.toString(), isNot(contains('secret')));
      expect(value.toInput().toString(), isNot(contains('secret')));
      final input = value.toInput();
      expect(input.copyWith(), input);
      for (final copy in [
        input.copyWith(stdout: 'different'),
        input.copyWith(stderr: 'different'),
        input.copyWith(outcome: const ShellCallTimeoutOutcome()),
      ]) {
        expect(copy, isNot(input));
        expect(ShellCallOutputContentInput.fromJson(copy.toJson()), copy);
        expect(
          ShellCallOutputContentInput.fromJson(copy.toJson()).hashCode,
          copy.hashCode,
        );
      }
    });
    for (final key in ['stdout', 'stderr', 'outcome']) {
      for (final invalid in [null, 12, false]) {
        test(
          'both content shapes reject malformed $key ${invalid.runtimeType}',
          () {
            final json = {
              'stdout': '',
              'stderr': '',
              'outcome': {'type': 'timeout'},
              key: invalid,
            };
            expect(() => ShellCallOutputContent.fromJson(json), _bad(key));
            expect(() => ShellCallOutputContentInput.fromJson(json), _bad(key));
          },
        );
      }
    }
    test('creator explicit null rejected and input drops returned creator', () {
      final json = {
        'stdout': '',
        'stderr': '',
        'outcome': {'type': 'timeout'},
        'created_by': null,
      };
      expect(() => ShellCallOutputContent.fromJson(json), _bad('created_by'));
      expect(
        ShellCallOutputContentInput.fromJson(
          json,
        ).toJson().containsKey('created_by'),
        isFalse,
      );
    });
    test(
      'all outcome variants round-trip; direct known factories reject bad type',
      () {
        const exit = ShellCallExitOutcome(exitCode: 2);
        expect(const ShellCallOutcome.exit(exitCode: 2), exit);
        const timeout = ShellCallTimeoutOutcome();
        expect(const ShellCallOutcome.timeout(), timeout);
        expect(ShellCallOutcome.fromJson(exit.toJson()), exit);
        expect(ShellCallOutcome.fromJson(timeout.toJson()), timeout);
        expect(exit.copyWith(), exit);
        expect(exit.copyWith(exitCode: 3), isNot(exit));
        expect(timeout.copyWith(), timeout);
        expect(
          () => ShellCallExitOutcome.fromJson(const {
            'type': 'timeout',
            'exit_code': 0,
          }),
          _bad('type'),
        );
        expect(
          () => ShellCallTimeoutOutcome.fromJson(const {'type': 'exit'}),
          _bad('type'),
        );
        expect(() => ShellCallOutcome.fromJson({}), _bad('type'));
        for (final invalid in [null, true, 1.5, '2']) {
          expect(
            () => ShellCallOutcome.fromJson({
              'type': 'exit',
              'exit_code': invalid,
            }),
            _bad('exit_code'),
          );
        }
      },
    );
    test(
      'future outcome snapshots nested metadata and honors copied discriminator',
      () {
        final raw = {
          'type': 'future',
          'metadata': {
            'secret': ['payload'],
          },
        };
        final value = ShellCallOutcome.fromJson(raw) as UnknownShellCallOutcome;
        ((raw['metadata']! as Map)['secret'] as List).clear();
        expect((value.rawJson['metadata'] as Map)['secret'] as List, [
          'payload',
        ]);
        expect(
          () => (value.rawJson['metadata'] as Map)['secret'] = <Object?>[],
          throwsUnsupportedError,
        );
        expect(
          () => ((value.rawJson['metadata'] as Map)['secret'] as List).clear(),
          throwsUnsupportedError,
        );
        final other = UnknownShellCallOutcome(
          type: 'future',
          rawJson: const {
            'metadata': {
              'secret': ['payload'],
            },
            'type': 'future',
          },
        );
        expect(value, other);
        expect(value.hashCode, other.hashCode);
        final changed = value.copyWith(type: 'future2');
        expect(changed, isNot(value));
        expect(ShellCallOutcome.fromJson(changed.toJson()), changed);
        expect(
          ShellCallOutcome.fromJson(changed.toJson()).hashCode,
          changed.hashCode,
        );
        expect(value.copyWith(rawJson: {'other': 1}), isNot(value));
        expect(value.toString(), isNot(contains('payload')));
      },
    );
  });

  group('returned environments', () {
    test(
      'known variants exact direct type validation and copy/value semantics',
      () {
        const local = LocalShellEnvironment();
        expect(const ShellEnvironment.local(), local);
        const ref = ContainerReferenceEnvironment(containerId: 'cntr_1');
        expect(
          const ShellEnvironment.containerReference(containerId: 'cntr_1'),
          ref,
        );
        expect(ShellEnvironment.fromJson(local.toJson()), local);
        expect(ShellEnvironment.fromJson(ref.toJson()), ref);
        expect(local.copyWith(), local);
        expect(ref.copyWith(), ref);
        expect(ref.copyWith(containerId: 'other'), isNot(ref));
        expect(
          ShellEnvironment.fromJson(
            ref.copyWith(containerId: 'other').toJson(),
          ).hashCode,
          ref.copyWith(containerId: 'other').hashCode,
        );
        expect(
          () => LocalShellEnvironment.fromJson(const {'type': 'wrong'}),
          _bad('type'),
        );
        expect(
          () => ContainerReferenceEnvironment.fromJson(const {
            'type': 'wrong',
            'container_id': 'id',
          }),
          _bad('type'),
        );
        expect(
          () => ShellEnvironment.fromJson({'type': 'container_reference'}),
          _bad('container_id'),
        );
        expect(
          () => ShellEnvironment.fromJson({'type': 'container_auto'}),
          _bad('type'),
        );
      },
    );
    test(
      'future environment immutable deep equality and copied discriminator',
      () {
        final raw = {
          'type': 'future',
          'settings': {
            'secret': ['payload'],
          },
        };
        final value = ShellEnvironment.fromJson(raw) as UnknownShellEnvironment;
        ((raw['settings']! as Map)['secret'] as List).clear();
        expect((value.rawJson['settings'] as Map)['secret'] as List, [
          'payload',
        ]);
        expect(
          () => ((value.rawJson['settings'] as Map)['secret'] as List).clear(),
          throwsUnsupportedError,
        );
        final other = UnknownShellEnvironment(
          type: 'future',
          rawJson: const {
            'settings': {
              'secret': ['payload'],
            },
          },
        );
        expect(value, other);
        expect(value.hashCode, other.hashCode);
        final changed = value.copyWith(type: 'future2');
        expect(changed, isNot(value));
        expect(ShellEnvironment.fromJson(changed.toJson()), changed);
        expect(
          ShellEnvironment.fromJson(changed.toJson()).hashCode,
          changed.hashCode,
        );
        expect(value.copyWith(rawJson: {'other': 1}), isNot(value));
        expect(value.toString(), isNot(contains('payload')));
      },
    );
    test('future environment wrapper cannot emit unsupported auto', () {
      expect(
        () =>
            UnknownShellEnvironment(type: 'container_auto', rawJson: const {}),
        throwsArgumentError,
      );
      final future = UnknownShellEnvironment(type: 'future', rawJson: const {});
      expect(
        () => future.copyWith(type: 'container_auto'),
        throwsArgumentError,
      );
    });
    test(
      'returned parsed output lists immutable and existing const list ownership retained',
      () {
        final result = ShellCallOutputResultItem.fromJson(_result());
        expect(result.output.clear, throwsUnsupportedError);
        final resource = ShellCallOutputResourceItem.fromJson(_result());
        expect(resource.output.clear, throwsUnsupportedError);
        final conversation = ConversationShellCallOutputItem.fromJson(
          _result(),
        );
        expect(conversation.output.clear, throwsUnsupportedError);
        const action = ShellCallAction(
          commands: ['cmd'],
          timeoutMs: null,
          maxOutputLength: null,
        );
        const call = ShellCallOutputItem(
          id: 'id',
          callId: 'call',
          action: action,
          status: ItemStatus.completed,
          environment: null,
        );
        const chunks = [
          ShellCallOutputContent(
            stdout: '',
            stderr: '',
            outcome: ShellCallTimeoutOutcome(),
          ),
        ];
        const resultValue = ShellCallOutputResultItem(
          id: 'id',
          callId: 'call',
          status: ItemStatus.completed,
          output: chunks,
          maxOutputLength: null,
        );
        expect(call.action, same(action));
        expect(resultValue.output, same(chunks));
      },
    );
  });
}

class _DerivedLocalEnvironment extends LocalShellEnvironment {
  const _DerivedLocalEnvironment();
}

class _DerivedTimeoutOutcome extends ShellCallTimeoutOutcome {
  const _DerivedTimeoutOutcome();
}

class _DerivedExitOutcome extends ShellCallExitOutcome {
  const _DerivedExitOutcome() : super(exitCode: 3);
}
