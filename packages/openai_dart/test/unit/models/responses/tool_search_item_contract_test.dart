import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

typedef _Case = ({
  String name,
  bool request,
  bool call,
  bool agent,
  Object Function(Map<String, dynamic>) parse,
});

const _cases = <_Case>[
  (
    name: 'ToolSearchCallItemParam',
    request: true,
    call: true,
    agent: true,
    parse: ToolSearchCallItemParam.fromJson,
  ),
  (
    name: 'ToolSearchOutputItemParam',
    request: true,
    call: false,
    agent: true,
    parse: ToolSearchOutputItemParam.fromJson,
  ),
  (
    name: 'ToolSearchCallOutputItem',
    request: false,
    call: true,
    agent: true,
    parse: ToolSearchCallOutputItem.fromJson,
  ),
  (
    name: 'ToolSearchOutputItem',
    request: false,
    call: false,
    agent: true,
    parse: ToolSearchOutputItem.fromJson,
  ),
  (
    name: 'ToolSearchCallResourceItem',
    request: false,
    call: true,
    agent: true,
    parse: ToolSearchCallResourceItem.fromJson,
  ),
  (
    name: 'ToolSearchOutputResourceItem',
    request: false,
    call: false,
    agent: true,
    parse: ToolSearchOutputResourceItem.fromJson,
  ),
  (
    name: 'ConversationToolSearchCallItem',
    request: false,
    call: true,
    agent: false,
    parse: ConversationToolSearchCallItem.fromJson,
  ),
  (
    name: 'ConversationToolSearchOutputItem',
    request: false,
    call: false,
    agent: false,
    parse: ConversationToolSearchOutputItem.fromJson,
  ),
];

Map<String, dynamic> _json(Object value) => switch (value) {
  final Item item => item.toJson(),
  final OutputItem item => item.toJson(),
  final ConversationItem item => item.toJson(),
  _ => throw ArgumentError('Unsupported test model'),
};

Map<String, dynamic> _fixture(_Case item, {bool minimal = false}) => {
  'type': item.call ? 'tool_search_call' : 'tool_search_output',
  if (!minimal || !item.request) 'id': 'search_id',
  if (!minimal || !item.request)
    'call_id': item.request ? 'original_call' : null,
  if (!minimal || !item.request) 'execution': 'client',
  if (item.call) 'arguments': <String, dynamic>{},
  if (!item.call) 'tools': <Object?>[],
  if (!minimal || !item.request) 'status': 'completed',
  if (!minimal && !item.request) 'created_by': 'creator_secret',
  if (!minimal && item.agent) 'agent': {'agent_name': 'agent_secret'},
};

Matcher _error(String context) => isA<FormatException>().having(
  (error) => error.message,
  'context',
  contains(context),
);

const _function = <String, dynamic>{
  'type': 'function',
  'name': 'plain_function',
  'description': 'function_secret',
  'parameters': {
    'type': 'object',
    'properties': {
      'city': {'type': 'string'},
    },
  },
  'strict': false,
  'defer_loading': true,
  'allowed_callers': ['direct'],
  'output_schema': {'type': 'string'},
  'async': false,
};

const _namespace = <String, dynamic>{
  'type': 'namespace',
  'name': 'discovered',
  'description': 'namespace_secret',
  'tools': [
    {'type': 'function', 'name': 'lookup.city'},
    {
      'type': 'function',
      'name': 'lookup.full',
      'description': 'nested_secret',
      'parameters': {
        'type': 'object',
        'properties': {
          'city': {'type': 'string'},
        },
      },
      'strict': true,
      'defer_loading': false,
      'allowed_callers': ['direct'],
      'output_schema': {
        'type': 'object',
        'properties': {
          'ok': {'type': 'boolean'},
        },
      },
      'async': true,
    },
    {
      'type': 'custom',
      'name': 'query',
      'description': 'custom_secret',
      'format': {'type': 'text'},
      'defer_loading': true,
      'allowed_callers': ['direct'],
      'async': false,
    },
    {
      'type': 'future_tool',
      'nested': {
        'opaque': ['future_secret', null],
      },
    },
  ],
};

void main() {
  for (final item in _cases) {
    group(item.name, () {
      test('public round-trip preserves every field and complete JSON', () {
        final json = _fixture(item);
        final value = item.parse(json);
        expect(_json(value), json);
        final restored = item.parse(_json(value));
        expect(restored, value);
        expect(restored.hashCode, value.hashCode);
      });
      test('minimum contract preserves omission and empty results', () {
        final json = _fixture(item, minimal: true);
        final value = item.parse(json);
        expect(_json(value), json);
        expect(item.parse(_json(value)), value);
      });
      for (final type in [null, 'wrong', 12]) {
        test('rejects supplied discriminator $type', () {
          final json = _fixture(item)..['type'] = type;
          expect(() => item.parse(json), throwsA(_error('${item.name}.type')));
        });
      }
      final required = [
        'type',
        if (!item.request) ...['id', 'call_id', 'execution', 'status'],
        if (item.call) 'arguments' else 'tools',
      ];
      for (final key in required) {
        test('rejects missing required $key', () {
          final json = _fixture(item)..remove(key);
          expect(() => item.parse(json), throwsA(_error('${item.name}.$key')));
        });
      }
      final malformed = <String, Object?>{
        'id': 1,
        'call_id': false,
        'execution': [],
        'status': {},
        if (!item.request) 'created_by': 1,
      };
      for (final entry in malformed.entries) {
        test('rejects ${entry.key} with wrong shape', () {
          final json = _fixture(item)..[entry.key] = entry.value;
          expect(
            () => item.parse(json),
            throwsA(_error('${item.name}.${entry.key}')),
          );
        });
      }
      for (final key in [
        'execution',
        if (!item.request) ...['id', 'status', 'created_by'],
      ]) {
        test('rejects explicit nonnullable null $key', () {
          final json = _fixture(item)..[key] = null;
          expect(() => item.parse(json), throwsA(_error('${item.name}.$key')));
        });
      }
      test('retains existing unknown enum fallbacks', () {
        final json = _fixture(item)
          ..['execution'] = 'future_execution'
          ..['status'] = 'future_status';
        final value = item.parse(json);
        expect(_json(value)['execution'], 'unknown');
        expect(_json(value)['status'], 'unknown');
      });
      if (item.request) {
        test('nullable request metadata is omitted when explicitly null', () {
          final json = _fixture(item, minimal: true)
            ..['id'] = null
            ..['call_id'] = null
            ..['status'] = null
            ..['agent'] = null;
          expect(_json(item.parse(json)), _fixture(item, minimal: true));
        });
      } else {
        test('required nullable call_id is emitted even when null', () {
          final json = _fixture(item)..['call_id'] = null;
          expect(_json(item.parse(json)), containsPair('call_id', null));
        });
      }
      if (item.agent) {
        for (final agent in [
          4,
          <Object?>[],
          <String, dynamic>{},
          {'agent_name': null},
          {'agent_name': 1},
        ]) {
          test('rejects malformed beta agent $agent', () {
            final json = _fixture(item)..['agent'] = agent;
            expect(
              () => item.parse(json),
              throwsA(_error('${item.name}.agent')),
            );
          });
        }
        if (!item.request) {
          test('rejects explicit null beta agent', () {
            final json = _fixture(item)..['agent'] = null;
            expect(
              () => item.parse(json),
              throwsA(_error('${item.name}.agent')),
            );
          });
        }
        test('normalizes a dynamically typed string-keyed beta agent', () {
          final json = _fixture(item)
            ..['agent'] = <Object?, Object?>{'agent_name': 'agent_secret'};
          expect(_json(item.parse(json))['agent'], {
            'agent_name': 'agent_secret',
          });
        });
      }
      test('safe diagnostics include all fields and hide payloads', () {
        final json = _fixture(item);
        if (item.call) {
          json['arguments'] = {'query': 'argument_secret'};
        } else {
          json['tools'] = [_function, _namespace];
        }
        final description = item.parse(json).toString();
        for (final field in [
          'id:',
          'callId:',
          'execution:',
          'status:',
          if (item.call) 'arguments:' else 'tools:',
          if (item.agent) 'agent:',
          if (!item.request) 'createdBy:',
        ]) {
          expect(description, contains(field));
        }
        for (final secret in [
          'argument_secret',
          'creator_secret',
          'agent_secret',
          'function_secret',
          'namespace_secret',
          'nested_secret',
          'custom_secret',
          'future_secret',
        ]) {
          expect(description, isNot(contains(secret)));
        }
      });
      if (item.call) {
        for (final arguments in [
          <Object?, Object?>{
            'query': 'search',
            'nested': <Object?, Object?>{
              'values': [1, null],
            },
          },
          <String, dynamic>{},
        ]) {
          test('normalizes object arguments $arguments', () {
            final json = _fixture(item)..['arguments'] = arguments;
            expect(_json(item.parse(json))['arguments'], arguments);
          });
        }
        final wrong = [
          DateTime(2026),
          double.nan,
          double.infinity,
          <Object?, Object?>{1: 'bad'},
          {
            'nested': <Object?, Object?>{2: 'bad'},
          },
          {
            'nested': [DateTime(2026)],
          },
          if (item.request) ...[null, 'scalar', 4, true, <Object?>[]],
        ];
        for (var index = 0; index < wrong.length; index++) {
          test('rejects malformed arguments shape $index', () {
            final json = _fixture(item)..['arguments'] = wrong[index];
            expect(
              () => item.parse(json),
              throwsA(_error('${item.name}.arguments')),
            );
          });
        }
        if (!item.request) {
          for (final arguments in [
            null,
            'scalar',
            9,
            3.25,
            false,
            <Object?>[],
            <Object?>[
              1,
              {
                'nested': [null, true],
              },
            ],
          ]) {
            test('preserves arbitrary returned arguments $arguments', () {
              final json = _fixture(item)..['arguments'] = arguments;
              final value = item.parse(json);
              expect(_json(value), json);
              expect(item.parse(_json(value)), value);
              expect(item.parse(_json(value)).hashCode, value.hashCode);
            });
          }
        }
        test(
          'nested object arguments compare and hash independent of map order',
          () {
            final first = _fixture(item)
              ..['arguments'] = {
                'a': [
                  1,
                  {'left': true, 'right': null},
                ],
                'b': {'z': 'value', 'y': <Object?>[]},
              };
            final second = _fixture(item)
              ..['arguments'] = <Object?, Object?>{
                'b': <Object?, Object?>{'y': <Object?>[], 'z': 'value'},
                'a': [
                  1,
                  <Object?, Object?>{'right': null, 'left': true},
                ],
              };
            final a = item.parse(first);
            final b = item.parse(second);
            expect(a, b);
            expect(a.hashCode, b.hashCode);
            expect({a, b}, hasLength(1));
            expect(
              item.parse(
                _fixture(item)
                  ..['arguments'] = {
                    'a': [
                      1,
                      {'left': false},
                    ],
                  },
              ),
              isNot(a),
            );
          },
        );
        if (!item.request) {
          test('parsed root-list arguments are deeply immutable snapshots', () {
            final nested = <String, dynamic>{'original': true};
            final source = <Object?>[nested];
            final value = item.parse(_fixture(item)..['arguments'] = source);
            source.add(null);
            nested['later'] = true;
            final parsed = _json(value)['arguments'] as List;
            expect(parsed, [
              {'original': true},
            ]);
            expect(parsed.clear, throwsUnsupportedError);
            expect(
              () => (parsed.first as Map)['later'] = false,
              throwsUnsupportedError,
            );
          });
          test(
            'nested list arguments compare and hash independent of map order',
            () {
              final first = item.parse(
                _fixture(item)
                  ..['arguments'] = [
                    {
                      'a': true,
                      'b': [null, 2],
                    },
                  ],
              );
              final second = item.parse(
                _fixture(item)
                  ..['arguments'] = [
                    <Object?, Object?>{
                      'b': [null, 2],
                      'a': true,
                    },
                  ],
              );
              expect(first, second);
              expect(first.hashCode, second.hashCode);
            },
          );
        }
        test('parsed arguments deeply snapshot caller input', () {
          final inner = <String, dynamic>{'value': 'original'};
          final list = <Object?>[inner];
          final source = <String, dynamic>{'nested': list};
          final json = _fixture(item)..['arguments'] = source;
          final value = item.parse(json);
          source['later'] = true;
          list.add(false);
          inner['value'] = 'modified';
          expect(_json(value)['arguments'], {
            'nested': [
              {'value': 'original'},
            ],
          });
          final args = _json(value)['arguments'] as Map<String, dynamic>;
          expect(() => args['later'] = 1, throwsUnsupportedError);
          final nested = args['nested'] as List;
          expect(() => nested.add(2), throwsUnsupportedError);
          expect(
            () => (nested.first as Map)['value'] = 3,
            throwsUnsupportedError,
          );
        });
      } else {
        for (final tools in [
          null,
          'bad',
          3,
          <Object?>[null],
          <Object?>[3],
          <Object?>[
            <Object?, Object?>{1: true},
          ],
        ]) {
          test('rejects malformed tools $tools', () {
            final json = _fixture(item)..['tools'] = tools;
            expect(
              () => item.parse(json),
              throwsA(_error('${item.name}.tools')),
            );
          });
        }
        test(
          'complete discovered tools preserve contextual definitions and future fallback',
          () {
            final json = _fixture(item)..['tools'] = [_function, _namespace];
            final value = item.parse(json);
            expect(_json(value), json);
            expect(item.parse(_json(value)), value);
            expect(item.parse(_json(value)).hashCode, value.hashCode);
          },
        );
        for (final key in ['parameters', 'strict']) {
          test('top-level functions require nullable $key', () {
            final function = <String, dynamic>{..._function}..remove(key);
            final json = _fixture(item)..['tools'] = [function];
            expect(
              () => item.parse(json),
              throwsA(_error('${item.name}.tools[0]')),
            );
          });
        }
        test(
          'top-level nullable function fields round-trip without invented values',
          () {
            final function = <String, dynamic>{
              'type': 'function',
              'name': 'minimal',
              'parameters': null,
              'strict': null,
            };
            final json = _fixture(item)..['tools'] = [function];
            expect(_json(item.parse(json)), json);
          },
        );
        for (final definition in [
          {'type': 'function', 'name': 1, 'parameters': null, 'strict': null},
          {'type': 'custom', 'name': 2},
          {
            'type': 'namespace',
            'name': 'found',
            'description': '',
            'tools': [
              {'type': 'function', 'name': 3},
            ],
          },
          {
            'type': 'namespace',
            'name': 'found',
            'description': '',
            'tools': [
              {'type': 'custom', 'name': 'ok', 'async': null},
            ],
          },
        ]) {
          test(
            'known malformed definitions stay indexed errors $definition',
            () {
              final json = _fixture(item)..['tools'] = [definition];
              expect(
                () => item.parse(json),
                throwsA(_error('${item.name}.tools[0]')),
              );
            },
          );
        }
        test(
          'parsed tool list snapshots caller input and forbids list mutation',
          () {
            final tools = <Object?>[
              <String, dynamic>{..._function},
            ];
            final json = _fixture(item)..['tools'] = tools;
            final value = item.parse(json);
            tools.clear();
            expect(_json(value)['tools'], [_function]);
            final parsedTools = switch (value) {
              final ToolSearchOutputItemParam item => item.tools,
              final ToolSearchOutputItem item => item.tools,
              final ToolSearchOutputResourceItem item => item.tools,
              final ConversationToolSearchOutputItem item => item.tools,
              _ => throw StateError('Output test expected'),
            };
            expect(parsedTools.clear, throwsUnsupportedError);
          },
        );
      }
    });
  }
  _copyAndValueTests();
  _resourceAndConstTests();
}

void _copyAndValueTests() {
  group('complete copy/clear and value contracts', () {
    test('input call all fields replace and nullable fields clear', () {
      final original = ToolSearchCallItemParam.fromJson(_fixture(_cases[0]));
      final changed = original.copyWith(
        id: 'new',
        agent: const AgentTag(agentName: 'new'),
        callId: 'new_call',
        execution: ToolSearchExecutionType.server,
        arguments: {
          'new': [1],
        },
        status: ItemStatus.incomplete,
      );
      expect(changed.toJson(), {
        'type': 'tool_search_call',
        'id': 'new',
        'agent': {'agent_name': 'new'},
        'call_id': 'new_call',
        'execution': 'server',
        'arguments': {
          'new': [1],
        },
        'status': 'incomplete',
      });
      expect(original.copyWith(), original);
      final cleared = changed.copyWith(
        id: null,
        agent: null,
        callId: null,
        execution: null,
        status: null,
      );
      expect(cleared.toJson(), {
        'type': 'tool_search_call',
        'arguments': {
          'new': [1],
        },
      });
      for (final value in [
        original.copyWith(id: 'new'),
        original.copyWith(agent: null),
        original.copyWith(callId: 'new_call'),
        original.copyWith(execution: ToolSearchExecutionType.server),
        original.copyWith(arguments: {'new': true}),
        original.copyWith(status: ItemStatus.incomplete),
      ]) {
        expect(value, isNot(original));
        expect(value.hashCode, isNot(original.hashCode));
      }
    });
    test('input output all fields replace and nullable fields clear', () {
      final original = ToolSearchOutputItemParam.fromJson(_fixture(_cases[1]));
      const newTools = <ResponseTool>[
        FunctionTool(name: 'new', parameters: {}, strict: false),
      ];
      final changed = original.copyWith(
        id: 'new',
        agent: const AgentTag(agentName: 'new'),
        callId: 'new_call',
        execution: ToolSearchExecutionType.server,
        tools: newTools,
        status: ItemStatus.incomplete,
      );
      expect(changed.toJson(), {
        'type': 'tool_search_output',
        'id': 'new',
        'agent': {'agent_name': 'new'},
        'call_id': 'new_call',
        'execution': 'server',
        'tools': [
          {
            'type': 'function',
            'name': 'new',
            'parameters': <String, dynamic>{},
            'strict': false,
          },
        ],
        'status': 'incomplete',
      });
      expect(original.copyWith(), original);
      expect(
        changed
            .copyWith(
              id: null,
              agent: null,
              callId: null,
              execution: null,
              status: null,
            )
            .toJson(),
        {
          'type': 'tool_search_output',
          'tools': [
            {
              'type': 'function',
              'name': 'new',
              'parameters': <String, dynamic>{},
              'strict': false,
            },
          ],
        },
      );
      for (final value in [
        original.copyWith(id: 'new'),
        original.copyWith(agent: null),
        original.copyWith(callId: 'new_call'),
        original.copyWith(execution: ToolSearchExecutionType.server),
        original.copyWith(tools: newTools),
        original.copyWith(status: ItemStatus.incomplete),
      ]) {
        expect(value, isNot(original));
        expect(value.hashCode, isNot(original.hashCode));
      }
    });
    test(
      'ToolSearchCallOutputItem all fields copy, clear and participate in values',
      () {
        final original = ToolSearchCallOutputItem.fromJson(_fixture(_cases[2]));
        final changed = original.copyWith(
          id: 'new',
          agent: const AgentTag(agentName: 'new'),
          callId: 'new_call',
          execution: ToolSearchExecutionType.server,
          arguments: <Object?>[
            {'a': 1},
          ],
          status: ItemStatus.incomplete,
          createdBy: 'new_creator',
        );
        final json = changed.toJson();
        expect(json['id'], 'new');
        expect(json['call_id'], 'new_call');
        expect(json['execution'], 'server');
        expect(json['status'], 'incomplete');
        expect(json['created_by'], 'new_creator');
        expect(json['agent'], {'agent_name': 'new'});
        expect(json['arguments'], [
          {'a': 1},
        ]);
        expect(original.copyWith(), original);
        final cleared = changed.copyWith(
          agent: null,
          callId: null,
          arguments: null,
          createdBy: null,
        );
        expect(cleared.toJson(), containsPair('call_id', null));
        expect(cleared.toJson().containsKey('created_by'), isFalse);
        expect(cleared.toJson().containsKey('agent'), isFalse);
        expect(cleared.toJson(), containsPair('arguments', null));
        for (final value in [
          original.copyWith(id: 'new'),
          original.copyWith(agent: null),
          original.copyWith(callId: 'new_call'),
          original.copyWith(execution: ToolSearchExecutionType.server),
          original.copyWith(
            arguments: <Object?>[
              {'a': 1},
            ],
          ),
          original.copyWith(status: ItemStatus.incomplete),
          original.copyWith(createdBy: null),
        ]) {
          expect(value, isNot(original));
          expect(value.hashCode, isNot(original.hashCode));
        }
      },
    );
    test(
      'ToolSearchOutputItem all fields copy, clear and participate in values',
      () {
        final original = ToolSearchOutputItem.fromJson(_fixture(_cases[3]));
        final changed = original.copyWith(
          id: 'new',
          agent: const AgentTag(agentName: 'new'),
          callId: 'new_call',
          execution: ToolSearchExecutionType.server,
          tools: const <ResponseTool>[
            FunctionTool(name: 'new', parameters: {}, strict: false),
          ],
          status: FunctionCallOutputStatus.incomplete,
          createdBy: 'new_creator',
        );
        final json = changed.toJson();
        expect(json['id'], 'new');
        expect(json['call_id'], 'new_call');
        expect(json['execution'], 'server');
        expect(json['status'], 'incomplete');
        expect(json['created_by'], 'new_creator');
        expect(json['agent'], {'agent_name': 'new'});
        expect(json['tools'], [
          {
            'type': 'function',
            'name': 'new',
            'parameters': <String, dynamic>{},
            'strict': false,
          },
        ]);
        expect(original.copyWith(), original);
        final cleared = changed.copyWith(
          agent: null,
          callId: null,
          createdBy: null,
        );
        expect(cleared.toJson(), containsPair('call_id', null));
        expect(cleared.toJson().containsKey('created_by'), isFalse);
        expect(cleared.toJson().containsKey('agent'), isFalse);
        for (final value in [
          original.copyWith(id: 'new'),
          original.copyWith(agent: null),
          original.copyWith(callId: 'new_call'),
          original.copyWith(execution: ToolSearchExecutionType.server),
          original.copyWith(
            tools: const <ResponseTool>[
              FunctionTool(name: 'new', parameters: {}, strict: false),
            ],
          ),
          original.copyWith(status: FunctionCallOutputStatus.incomplete),
          original.copyWith(createdBy: null),
        ]) {
          expect(value, isNot(original));
          expect(value.hashCode, isNot(original.hashCode));
        }
      },
    );
    test(
      'ToolSearchCallResourceItem all fields copy, clear and participate in values',
      () {
        final original = ToolSearchCallResourceItem.fromJson(
          _fixture(_cases[4]),
        );
        final changed = original.copyWith(
          id: 'new',
          agent: const AgentTag(agentName: 'new'),
          callId: 'new_call',
          execution: ToolSearchExecutionType.server,
          arguments: <Object?>[
            {'a': 1},
          ],
          status: ItemStatus.incomplete,
          createdBy: 'new_creator',
        );
        final json = changed.toJson();
        expect(json['id'], 'new');
        expect(json['call_id'], 'new_call');
        expect(json['execution'], 'server');
        expect(json['status'], 'incomplete');
        expect(json['created_by'], 'new_creator');
        expect(json['agent'], {'agent_name': 'new'});
        expect(json['arguments'], [
          {'a': 1},
        ]);
        expect(original.copyWith(), original);
        final cleared = changed.copyWith(
          agent: null,
          callId: null,
          arguments: null,
          createdBy: null,
        );
        expect(cleared.toJson(), containsPair('call_id', null));
        expect(cleared.toJson().containsKey('created_by'), isFalse);
        expect(cleared.toJson().containsKey('agent'), isFalse);
        expect(cleared.toJson(), containsPair('arguments', null));
        for (final value in [
          original.copyWith(id: 'new'),
          original.copyWith(agent: null),
          original.copyWith(callId: 'new_call'),
          original.copyWith(execution: ToolSearchExecutionType.server),
          original.copyWith(
            arguments: <Object?>[
              {'a': 1},
            ],
          ),
          original.copyWith(status: ItemStatus.incomplete),
          original.copyWith(createdBy: null),
        ]) {
          expect(value, isNot(original));
          expect(value.hashCode, isNot(original.hashCode));
        }
      },
    );
    test(
      'ToolSearchOutputResourceItem all fields copy, clear and participate in values',
      () {
        final original = ToolSearchOutputResourceItem.fromJson(
          _fixture(_cases[5]),
        );
        final changed = original.copyWith(
          id: 'new',
          agent: const AgentTag(agentName: 'new'),
          callId: 'new_call',
          execution: ToolSearchExecutionType.server,
          tools: const <ResponseTool>[
            FunctionTool(name: 'new', parameters: {}, strict: false),
          ],
          status: FunctionCallOutputStatus.incomplete,
          createdBy: 'new_creator',
        );
        final json = changed.toJson();
        expect(json['id'], 'new');
        expect(json['call_id'], 'new_call');
        expect(json['execution'], 'server');
        expect(json['status'], 'incomplete');
        expect(json['created_by'], 'new_creator');
        expect(json['agent'], {'agent_name': 'new'});
        expect(json['tools'], [
          {
            'type': 'function',
            'name': 'new',
            'parameters': <String, dynamic>{},
            'strict': false,
          },
        ]);
        expect(original.copyWith(), original);
        final cleared = changed.copyWith(
          agent: null,
          callId: null,
          createdBy: null,
        );
        expect(cleared.toJson(), containsPair('call_id', null));
        expect(cleared.toJson().containsKey('created_by'), isFalse);
        expect(cleared.toJson().containsKey('agent'), isFalse);
        for (final value in [
          original.copyWith(id: 'new'),
          original.copyWith(agent: null),
          original.copyWith(callId: 'new_call'),
          original.copyWith(execution: ToolSearchExecutionType.server),
          original.copyWith(
            tools: const <ResponseTool>[
              FunctionTool(name: 'new', parameters: {}, strict: false),
            ],
          ),
          original.copyWith(status: FunctionCallOutputStatus.incomplete),
          original.copyWith(createdBy: null),
        ]) {
          expect(value, isNot(original));
          expect(value.hashCode, isNot(original.hashCode));
        }
      },
    );
    test(
      'ConversationToolSearchCallItem all fields copy, clear and participate in values',
      () {
        final original = ConversationToolSearchCallItem.fromJson(
          _fixture(_cases[6]),
        );
        final changed = original.copyWith(
          id: 'new',
          callId: 'new_call',
          execution: ToolSearchExecutionType.server,
          arguments: <Object?>[
            {'a': 1},
          ],
          status: ItemStatus.incomplete,
          createdBy: 'new_creator',
        );
        final json = changed.toJson();
        expect(json['id'], 'new');
        expect(json['call_id'], 'new_call');
        expect(json['execution'], 'server');
        expect(json['status'], 'incomplete');
        expect(json['created_by'], 'new_creator');
        expect(json['arguments'], [
          {'a': 1},
        ]);
        expect(original.copyWith(), original);
        final cleared = changed.copyWith(
          callId: null,
          arguments: null,
          createdBy: null,
        );
        expect(cleared.toJson(), containsPair('call_id', null));
        expect(cleared.toJson().containsKey('created_by'), isFalse);
        expect(cleared.toJson(), containsPair('arguments', null));
        for (final value in [
          original.copyWith(id: 'new'),
          original.copyWith(callId: 'new_call'),
          original.copyWith(execution: ToolSearchExecutionType.server),
          original.copyWith(
            arguments: <Object?>[
              {'a': 1},
            ],
          ),
          original.copyWith(status: ItemStatus.incomplete),
          original.copyWith(createdBy: null),
        ]) {
          expect(value, isNot(original));
          expect(value.hashCode, isNot(original.hashCode));
        }
      },
    );
    test(
      'ConversationToolSearchOutputItem all fields copy, clear and participate in values',
      () {
        final original = ConversationToolSearchOutputItem.fromJson(
          _fixture(_cases[7]),
        );
        final changed = original.copyWith(
          id: 'new',
          callId: 'new_call',
          execution: ToolSearchExecutionType.server,
          tools: const <ResponseTool>[
            FunctionTool(name: 'new', parameters: {}, strict: false),
          ],
          status: ItemStatus.incomplete,
          createdBy: 'new_creator',
        );
        final json = changed.toJson();
        expect(json['id'], 'new');
        expect(json['call_id'], 'new_call');
        expect(json['execution'], 'server');
        expect(json['status'], 'incomplete');
        expect(json['created_by'], 'new_creator');
        expect(json['tools'], [
          {
            'type': 'function',
            'name': 'new',
            'parameters': <String, dynamic>{},
            'strict': false,
          },
        ]);
        expect(original.copyWith(), original);
        final cleared = changed.copyWith(callId: null, createdBy: null);
        expect(cleared.toJson(), containsPair('call_id', null));
        expect(cleared.toJson().containsKey('created_by'), isFalse);
        for (final value in [
          original.copyWith(id: 'new'),
          original.copyWith(callId: 'new_call'),
          original.copyWith(execution: ToolSearchExecutionType.server),
          original.copyWith(
            tools: const <ResponseTool>[
              FunctionTool(name: 'new', parameters: {}, strict: false),
            ],
          ),
          original.copyWith(status: ItemStatus.incomplete),
          original.copyWith(createdBy: null),
        ]) {
          expect(value, isNot(original));
          expect(value.hashCode, isNot(original.hashCode));
        }
      },
    );
  });
}

void _resourceAndConstTests() {
  group('public resource routing and replay', () {
    test('input-items returned call factory preserves arbitrary JSON', () {
      final json = _fixture(_cases[4])..['arguments'] = [null, 'scalar'];
      final item = Item.fromResourceJson(json);
      expect(item, isA<ToolSearchCallResourceItem>());
      expect(item.toJson(), json);
      expect(
        () => Item.fromJson(json),
        throwsA(_error('ToolSearchCallItemParam.arguments')),
      );
      expect(ResponseInput.fromOutputItems([json]).toJson(), [json]);
    });
    test('input-items returned output factory retains creator metadata', () {
      final json = _fixture(_cases[5])..['tools'] = [_function, _namespace];
      final item = Item.fromResourceJson(json);
      expect(item, isA<ToolSearchOutputResourceItem>());
      expect(item.toJson(), json);
      expect(Item.fromJson(json), isA<ToolSearchOutputItemParam>());
    });
    test(
      'stored calls convert only object-shaped arguments to typed input',
      () {
        final original = ToolSearchCallResourceItem.fromJson(
          _fixture(_cases[4])
            ..['arguments'] = {
              'nested': [1, null],
            },
        );
        final input = original.toToolSearchCallItemParam();
        expect(input.toJson(), {
          'type': 'tool_search_call',
          'id': 'search_id',
          'execution': 'client',
          'arguments': {
            'nested': [1, null],
          },
          'status': 'completed',
          'agent': {'agent_name': 'agent_secret'},
        });
        expect(input.toJson().containsKey('created_by'), isFalse);
        expect(Item.fromJson(input.toJson()), input);
      },
    );
    for (final arguments in [null, false, 'scalar', 2, <Object?>[]]) {
      test('stored call conversion rejects nonobject $arguments', () {
        final original = ToolSearchCallResourceItem.fromJson(
          _fixture(_cases[4])..['arguments'] = arguments,
        );
        expect(original.toToolSearchCallItemParam, throwsStateError);
        expect(ResponseInput.fromOutputItems([original.toJson()]).toJson(), [
          original.toJson(),
        ]);
      });
    }
    test(
      'stored output conversion retains complete tools and optional metadata',
      () {
        final original = ToolSearchOutputResourceItem.fromJson(
          _fixture(_cases[5])
            ..['call_id'] = 'original_call'
            ..['tools'] = [_function, _namespace],
        );
        final input = original.toToolSearchOutputItemParam();
        final expected = original.toJson()..remove('created_by');
        expect(input.toJson(), expected);
        expect(Item.fromJson(input.toJson()), input);
      },
    );
  });
  group('const construction and caller collection compatibility', () {
    const values = <Object>[
      ToolSearchCallItemParam(arguments: {}),
      ToolSearchOutputItemParam(tools: []),
      ToolSearchCallOutputItem(
        id: 'id',
        callId: null,
        execution: ToolSearchExecutionType.server,
        arguments: null,
        status: ItemStatus.completed,
      ),
      ToolSearchOutputItem(
        id: 'id',
        callId: null,
        execution: ToolSearchExecutionType.server,
        tools: [],
        status: FunctionCallOutputStatus.completed,
      ),
      ToolSearchCallResourceItem(
        id: 'id',
        callId: null,
        execution: ToolSearchExecutionType.server,
        arguments: null,
        status: ItemStatus.completed,
      ),
      ToolSearchOutputResourceItem(
        id: 'id',
        callId: null,
        execution: ToolSearchExecutionType.server,
        tools: [],
        status: FunctionCallOutputStatus.completed,
      ),
      ConversationToolSearchCallItem(
        id: 'id',
        callId: null,
        execution: ToolSearchExecutionType.server,
        arguments: null,
        status: ItemStatus.completed,
      ),
      ConversationToolSearchOutputItem(
        id: 'id',
        callId: null,
        execution: ToolSearchExecutionType.server,
        tools: [],
        status: ItemStatus.completed,
      ),
    ];
    for (var index = 0; index < values.length; index++) {
      test('${_cases[index].name} remains const constructible', () {
        final value = values[index];
        expect(_cases[index].parse(_json(value)), value);
      });
    }
    test(
      'caller argument maps retain const constructor ownership semantics',
      () {
        final arguments = <String, dynamic>{'original': true};
        final values = <Object>[
          ToolSearchCallItemParam(arguments: arguments),
          ToolSearchCallOutputItem(
            id: 'id',
            callId: null,
            execution: ToolSearchExecutionType.server,
            arguments: arguments,
            status: ItemStatus.completed,
          ),
          ToolSearchCallResourceItem(
            id: 'id',
            callId: null,
            execution: ToolSearchExecutionType.server,
            arguments: arguments,
            status: ItemStatus.completed,
          ),
          ConversationToolSearchCallItem(
            id: 'id',
            callId: null,
            execution: ToolSearchExecutionType.server,
            arguments: arguments,
            status: ItemStatus.completed,
          ),
        ];
        for (final value in values) {
          expect(identical(_json(value)['arguments'], arguments), isTrue);
        }
      },
    );
    test('caller tool lists retain const constructor ownership semantics', () {
      final tools = <ResponseTool>[];
      final values = <Object>[
        ToolSearchOutputItemParam(tools: tools),
        ToolSearchOutputItem(
          id: 'id',
          callId: null,
          execution: ToolSearchExecutionType.server,
          tools: tools,
          status: FunctionCallOutputStatus.completed,
        ),
        ToolSearchOutputResourceItem(
          id: 'id',
          callId: null,
          execution: ToolSearchExecutionType.server,
          tools: tools,
          status: FunctionCallOutputStatus.completed,
        ),
        ConversationToolSearchOutputItem(
          id: 'id',
          callId: null,
          execution: ToolSearchExecutionType.server,
          tools: tools,
          status: ItemStatus.completed,
        ),
      ];
      tools.add(const FunctionTool(name: 'first'));
      for (final value in values) {
        expect(_json(value)['tools'], hasLength(1));
      }
    });
  });
  group('concrete subtype equality guards', () {
    const children = <Object>[
      _InputCall(),
      _InputOutput(),
      _OutputCall(),
      _OutputOutput(),
      _ResourceCall(),
      _ResourceOutput(),
      _ConversationCall(),
      _ConversationOutput(),
    ];
    for (var index = 0; index < children.length; index++) {
      test(
        '${_cases[index].name} rejects subclass equality in both directions',
        () {
          final child = children[index];
          final parent = _cases[index].parse(_json(child));
          expect(parent == child, isFalse);
          expect(child == parent, isFalse);
        },
      );
    }
  });
  test('fixture JSON survives encoding with required null fields', () {
    final json = _fixture(_cases[2])..['arguments'] = null;
    expect(
      jsonDecode(jsonEncode(ToolSearchCallOutputItem.fromJson(json).toJson())),
      json,
    );
  });
}

class _InputCall extends ToolSearchCallItemParam {
  const _InputCall() : super(arguments: const {});
}

class _InputOutput extends ToolSearchOutputItemParam {
  const _InputOutput() : super(tools: const []);
}

class _OutputCall extends ToolSearchCallOutputItem {
  const _OutputCall()
    : super(
        id: 'id',
        callId: null,
        execution: ToolSearchExecutionType.server,
        arguments: null,
        status: ItemStatus.completed,
      );
}

class _OutputOutput extends ToolSearchOutputItem {
  const _OutputOutput()
    : super(
        id: 'id',
        callId: null,
        execution: ToolSearchExecutionType.server,
        tools: const [],
        status: FunctionCallOutputStatus.completed,
      );
}

class _ResourceCall extends ToolSearchCallResourceItem {
  const _ResourceCall()
    : super(
        id: 'id',
        callId: null,
        execution: ToolSearchExecutionType.server,
        arguments: null,
        status: ItemStatus.completed,
      );
}

class _ResourceOutput extends ToolSearchOutputResourceItem {
  const _ResourceOutput()
    : super(
        id: 'id',
        callId: null,
        execution: ToolSearchExecutionType.server,
        tools: const [],
        status: FunctionCallOutputStatus.completed,
      );
}

class _ConversationCall extends ConversationToolSearchCallItem {
  const _ConversationCall()
    : super(
        id: 'id',
        callId: null,
        execution: ToolSearchExecutionType.server,
        arguments: null,
        status: ItemStatus.completed,
      );
}

class _ConversationOutput extends ConversationToolSearchOutputItem {
  const _ConversationOutput()
    : super(
        id: 'id',
        callId: null,
        execution: ToolSearchExecutionType.server,
        tools: const [],
        status: ItemStatus.completed,
      );
}
