import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> function({String name = 'lookup'}) => {
    'type': 'function',
    'name': name,
  };
  Map<String, dynamic> namespace({List<Object?>? tools}) => {
    'type': 'namespace',
    'name': 'crm',
    'description': '',
    'tools': tools ?? [function()],
  };
  final parseDefinitions =
      <String, ResponseTool Function(Map<String, dynamic>)>{
        'ordinary': NamespaceTool.fromJson,
        'discovered': ResponseTool.fromToolSearchOutputJson,
      };
  Matcher fieldError(String field) => isA<FormatException>().having(
    (error) => error.message,
    'field context',
    contains(field),
  );

  group('contextual function definitions', () {
    test('top-level search functions require nullable schema keys', () {
      final json = {...function(), 'parameters': null, 'strict': null};
      final tool = ResponseTool.fromToolSearchOutputJson(json) as FunctionTool;
      expect(tool.parameters, isNull);
      expect(tool.strict, isNull);
      expect(tool.toToolSearchOutputJson(), json);
      expect(tool.toJson(), function());
      expect(
        ResponseTool.fromToolSearchOutputJson(tool.toToolSearchOutputJson()),
        tool,
      );
    });
    for (final key in ['parameters', 'strict']) {
      test('top-level function rejects missing $key', () {
        final json = {...function(), 'parameters': null, 'strict': null}
          ..remove(key);
        expect(
          () => ResponseTool.fromToolSearchOutputJson(json),
          throwsA(fieldError('ToolSearchOutputTool.$key')),
        );
      });
    }
    test('existing constructors and ordinary parsers stay optional', () {
      const tool = FunctionTool(name: 'lookup');
      const FunctionTool Function(Map<String, dynamic>) parse =
          FunctionTool.fromJson;
      const ResponseTool Function(Map<String, dynamic>) parseBase =
          ResponseTool.fromJson;
      expect(parse(function()), tool);
      expect(parseBase(function()), tool);
      expect(tool.toJson(), function());
      expect(tool.toToolSearchOutputJson(), {
        ...function(),
        'parameters': null,
        'strict': null,
      });
    });
    test('nested discovered functions preserve all existing options', () {
      final json = namespace(
        tools: [
          {
            ...function(name: 'crm.contacts.lookup'),
            'description': '',
            'parameters': {'type': 'object', 'properties': <String, dynamic>{}},
            'strict': false,
            'defer_loading': false,
            'allowed_callers': ['direct', 'programmatic'],
            'output_schema': {
              'type': 'object',
              'required': ['result'],
            },
            'async': true,
          },
          {
            'type': 'custom',
            'name': 'crm.query',
            'description': '',
            'format': {
              'type': 'grammar',
              'syntax': 'lark',
              'definition': 'start: "lookup"',
            },
            'defer_loading': true,
            'allowed_callers': ['direct'],
            'async': false,
          },
        ],
      );
      final tool = ResponseTool.fromToolSearchOutputJson(json) as NamespaceTool;
      expect(tool.toToolSearchOutputJson(), json);
      expect(tool.toJson(), json);
      final callable = tool.tools.first as FunctionTool;
      expect(callable.name, 'crm.contacts.lookup');
      expect(callable.async, isTrue);
      expect(callable.deferLoading, isFalse);
      expect(callable.strict, isFalse);
      expect(callable.allowedCallers, [
        CallableToolAllowedCaller.direct,
        CallableToolAllowedCaller.programmatic,
      ]);
      expect(callable.outputSchema, {
        'type': 'object',
        'required': ['result'],
      });
      expect(tool.tools.last, isA<CustomTool>());
    });
    for (final parser in parseDefinitions.entries) {
      test(
        '${parser.key} nested minimal function has no top-level defaults',
        () {
          final json = namespace();
          final tool = parser.value(json) as NamespaceTool;
          expect(tool.toJson(), json);
          expect((tool.tools.single as FunctionTool).parameters, isNull);
          expect((tool.tools.single as FunctionTool).strict, isNull);
        },
      );
      test(
        '${parser.key} nested nullable options parse without new defaults',
        () {
          final tool =
              parser.value(
                    namespace(
                      tools: [
                        {
                          ...function(),
                          'description': null,
                          'parameters': null,
                          'strict': null,
                          'allowed_callers': null,
                          'output_schema': null,
                        },
                      ],
                    ),
                  )
                  as NamespaceTool;
          final nested = tool.tools.single as FunctionTool;
          expect(nested.toJson(), function());
          expect(nested.async, isNull);
          expect(nested.deferLoading, isNull);
          expect(nested.allowedCallers, isNull);
        },
      );
    }
    test('ordinary names reject dots but discovered names accept them', () {
      final json = namespace(tools: [function(name: 'crm.lookup')]);
      expect(
        () => NamespaceTool.fromJson(json),
        throwsA(fieldError('NamespaceTool.tools[0].name')),
      );
      final tool = ResponseTool.fromToolSearchOutputJson(json) as NamespaceTool;
      expect((tool.tools.single as FunctionTool).name, 'crm.lookup');
      expect(tool.toToolSearchOutputJson(), json);
      // Other ordinary FunctionTool contexts retain their existing behavior.
      expect(
        FunctionTool.fromJson(function(name: 'crm.lookup')).name,
        'crm.lookup',
      );
    });
    for (final invalidName in [
      '',
      'lookup\r',
      'lookup\n',
      'with space',
      'with/slash',
      'x' * 129,
    ]) {
      for (final parser in parseDefinitions.entries) {
        test(
          '${parser.key} rejects invalid nested name ${jsonEncode(invalidName)}',
          () {
            expect(
              () =>
                  parser.value(namespace(tools: [function(name: invalidName)])),
              throwsA(fieldError('tools[0].name')),
            );
          },
        );
      }
    }
    for (final parser in parseDefinitions.entries) {
      test('${parser.key} permits the maximum nested name length', () {
        final json = namespace(tools: [function(name: 'a' * 128)]);
        expect(parser.value(json).toJson(), json);
      });
    }
    test('search top-level function name follows its own string contract', () {
      final json = {...function(name: ''), 'parameters': null, 'strict': null};
      expect(
        ResponseTool.fromToolSearchOutputJson(json).toToolSearchOutputJson(),
        json,
      );
    });
    test('top-level returned allowed callers may be empty', () {
      final json = {
        ...function(),
        'parameters': null,
        'strict': null,
        'allowed_callers': <String>[],
      };
      expect(
        ResponseTool.fromToolSearchOutputJson(json).toToolSearchOutputJson(),
        json,
      );
    });
    for (final parser in parseDefinitions.entries) {
      test('${parser.key} indexed caller errors include the owner', () {
        expect(
          () => parser.value(
            namespace(
              tools: [
                {
                  ...function(),
                  'allowed_callers': ['direct', null],
                },
              ],
            ),
          ),
          throwsA(fieldError('tools[0].allowed_callers[1]')),
        );
      });
      test(
        '${parser.key} schema objects reject non-string nested keys contextually',
        () {
          expect(
            () => parser.value(
              namespace(
                tools: [
                  {
                    ...function(),
                    'parameters': {
                      'properties': <dynamic, dynamic>{1: 'invalid'},
                    },
                  },
                ],
              ),
            ),
            throwsA(fieldError('tools[0].parameters')),
          );
        },
      );
      test('${parser.key} unknown payload errors include member context', () {
        expect(
          () => parser.value(
            namespace(
              tools: [
                {
                  'type': 'future',
                  'payload': <dynamic, dynamic>{1: 'invalid'},
                },
              ],
            ),
          ),
          throwsA(fieldError('tools[0]')),
        );
      });
      test('${parser.key} custom format and caller lists are snapshots', () {
        final format = <dynamic, dynamic>{
          'type': 'future',
          'nested': ['value'],
        };
        final callers = ['direct'];
        final tool =
            parser.value(
                  namespace(
                    tools: [
                      {
                        'type': 'custom',
                        'name': 'query',
                        'format': format,
                        'allowed_callers': callers,
                      },
                    ],
                  ),
                )
                as NamespaceTool;
        final custom = tool.tools.single as CustomTool;
        (format['nested'] as List).add('later');
        callers.add('programmatic');
        expect(custom.format, {
          'type': 'future',
          'nested': ['value'],
        });
        expect(custom.allowedCallers, [CallableToolAllowedCaller.direct]);
        expect(() => custom.format!.clear(), throwsUnsupportedError);
        expect(
          () => (custom.format!['nested'] as List).clear(),
          throwsUnsupportedError,
        );
        expect(() => custom.allowedCallers!.clear(), throwsUnsupportedError);
      });
    }
    test('search top-level parameters accept dynamically typed objects', () {
      final json = {
        ...function(),
        'parameters': <dynamic, dynamic>{
          'nested': <dynamic, dynamic>{
            'list': [1, null, false],
          },
        },
        'strict': false,
      };
      final tool = ResponseTool.fromToolSearchOutputJson(json) as FunctionTool;
      expect(tool.toToolSearchOutputJson(), json);
      expect(tool.parameters, isA<Map<String, dynamic>>());
    });
    for (final malformed in <String, Object?>{
      'name': null,
      'description': 2,
      'parameters': [],
      'strict': 'false',
      'defer_loading': null,
      'allowed_callers': false,
      'output_schema': [],
      'async': null,
    }.entries) {
      test(
        'top-level discovered function rejects malformed ${malformed.key}',
        () {
          expect(
            () => ResponseTool.fromToolSearchOutputJson({
              ...function(),
              'parameters': null,
              'strict': null,
              malformed.key: malformed.value,
            }),
            throwsA(fieldError('ToolSearchOutputTool.${malformed.key}')),
          );
        },
      );
    }
  });

  group('namespace contract', () {
    for (final parser in parseDefinitions.entries) {
      for (final field in ['type', 'name', 'description', 'tools']) {
        test('${parser.key} rejects missing $field', () {
          final json = namespace()..remove(field);
          expect(() => parser.value(json), throwsA(fieldError(field)));
        });
        test('${parser.key} rejects null $field', () {
          expect(
            () => parser.value({...namespace(), field: null}),
            throwsA(fieldError(field)),
          );
        });
      }
      for (final entry in <String, Object?>{
        'name': '',
        'description': 1,
        'tools': [],
      }.entries) {
        test('${parser.key} rejects invalid ${entry.key}', () {
          expect(
            () => parser.value({...namespace(), entry.key: entry.value}),
            throwsA(fieldError(entry.key)),
          );
        });
      }
      for (final member in <Object?>[
        null,
        1,
        [],
        {'type': null},
        <dynamic, dynamic>{1: 'function'},
      ]) {
        test(
          '${parser.key} rejects malformed member ${member.runtimeType}',
          () {
            expect(
              () => parser.value(namespace(tools: [function(), member])),
              throwsA(fieldError('tools[1]')),
            );
          },
        );
      }
      for (final malformed in <String, Object?>{
        'name': false,
        'description': [],
        'parameters': 'schema',
        'strict': 1,
        'defer_loading': null,
        'allowed_callers': [],
        'output_schema': 2,
        'async': 'yes',
      }.entries) {
        test('${parser.key} rejects known function ${malformed.key}', () {
          expect(
            () => parser.value(
              namespace(
                tools: [
                  function(),
                  {...function(), malformed.key: malformed.value},
                ],
              ),
            ),
            throwsA(fieldError('tools[1].${malformed.key}')),
          );
        });
      }
      for (final malformed in <String, Object?>{
        'name': null,
        'description': null,
        'format': [],
        'defer_loading': null,
        'allowed_callers': ['direct', null],
        'async': null,
      }.entries) {
        test('${parser.key} rejects known custom ${malformed.key}', () {
          expect(
            () => parser.value(
              namespace(
                tools: [
                  {
                    'type': 'custom',
                    'name': 'query',
                    malformed.key: malformed.value,
                  },
                ],
              ),
            ),
            throwsA(fieldError('tools[0].${malformed.key}')),
          );
        });
      }
      test('${parser.key} takes immutable nested snapshots', () {
        final mutable = <dynamic, dynamic>{
          'nested': ['a'],
        };
        final raw = namespace(
          tools: [
            {
              ...function(),
              'parameters': mutable,
              'allowed_callers': ['direct'],
            },
          ],
        );
        final tool = parser.value(raw) as NamespaceTool;
        (raw['tools'] as List).clear();
        (mutable['nested'] as List).add('b');
        expect(tool.tools, hasLength(1));
        final nested = tool.tools.single as FunctionTool;
        expect(nested.parameters, {
          'nested': ['a'],
        });
        expect(tool.tools.clear, throwsUnsupportedError);
        expect(() => nested.parameters!['a'] = 1, throwsUnsupportedError);
        expect(
          () => (nested.parameters!['nested'] as List).clear(),
          throwsUnsupportedError,
        );
        expect(() => nested.allowedCallers!.clear(), throwsUnsupportedError);
      });
    }
    test('subtype parser rejects wrong discriminator contextually', () {
      expect(
        () => NamespaceTool.fromJson({...namespace(), 'type': 'tool_search'}),
        throwsA(fieldError('NamespaceTool.type')),
      );
    });
    test('caller-owned construction and copy stay compatible and const', () {
      const constant = NamespaceTool(
        name: 'crm',
        description: '',
        tools: [FunctionTool(name: 'lookup')],
      );
      final tools = <NamespaceAllowedTool>[const FunctionTool(name: 'lookup')];
      final tool = NamespaceTool(name: 'crm', description: '', tools: tools);
      expect(tool, constant);
      expect(identical(tool.tools, tools), isTrue);
      expect(identical(tool.copyWith().tools, tools), isTrue);
      tools.add(const CustomTool(name: 'query'));
      expect(tool.tools, hasLength(2));
    });
    test('copy, value and hash contracts cover each namespace field', () {
      final tool = NamespaceTool.fromJson(namespace());
      final equal = NamespaceTool.fromJson(namespace());
      expect(tool, equal);
      expect(tool.hashCode, equal.hashCode);
      expect(tool.copyWith(), tool);
      for (final changed in [
        tool.copyWith(name: 'erp'),
        tool.copyWith(description: 'Different'),
        tool.copyWith(tools: [const CustomTool(name: 'query')]),
      ]) {
        expect(changed, isNot(tool));
        expect(changed.toJson(), isNot(tool.toJson()));
      }
      expect(tool, isNot('namespace'));
    });
    test('diagnostics summarize description and nested tool payloads', () {
      const tool = NamespaceTool(
        name: 'crm',
        description: 'description-secret',
        tools: [
          FunctionTool(name: 'payload-secret', parameters: {'secret': 'value'}),
        ],
      );
      expect(tool.toString(), contains('name: crm'));
      expect(tool.toString(), contains('description: 18 chars'));
      expect(tool.toString(), contains('tools: 1 items'));
      expect(tool.toString(), isNot(contains('secret')));
    });
  });

  group('tool-search configuration', () {
    test(
      'optional nullable fields accept null while omission stays omitted',
      () {
        expect(
          ToolSearchTool.fromJson(const {
            'type': 'tool_search',
            'description': null,
            'parameters': null,
          }),
          const ToolSearchTool(),
        );
        expect(const ToolSearchTool().toJson(), {'type': 'tool_search'});
      },
    );
    test(
      'empty description and parameters survive without execution default',
      () {
        final json = {
          'type': 'tool_search',
          'description': '',
          'parameters': <String, dynamic>{},
        };
        final tool = ToolSearchTool.fromJson(json);
        expect(tool.execution, isNull);
        expect(tool.toJson(), json);
        expect(ResponseTool.fromJson(json), tool);
        expect(ResponseTool.fromToolSearchOutputJson(json), tool);
      },
    );
    for (final execution in ToolSearchExecutionType.values) {
      test('execution $execution round trips', () {
        final json = {'type': 'tool_search', 'execution': execution.toJson()};
        final tool = ToolSearchTool.fromJson(json);
        expect(tool.execution, execution);
        expect(tool.toJson(), json);
      });
    }
    test('future execution values retain existing enum fallback', () {
      expect(
        ToolSearchTool.fromJson(const {
          'type': 'tool_search',
          'execution': 'future',
        }).execution,
        ToolSearchExecutionType.unknown,
      );
    });
    for (final entry in <String, Object?>{
      'type': 'search',
      'execution': null,
      'description': false,
      'parameters': [],
    }.entries) {
      test('rejects malformed ${entry.key}', () {
        expect(
          () => ToolSearchTool.fromJson({
            'type': 'tool_search',
            entry.key: entry.value,
          }),
          throwsA(fieldError('ToolSearchTool.${entry.key}')),
        );
      });
    }
    test('rejects missing discriminator', () {
      expect(
        () => ToolSearchTool.fromJson(const {}),
        throwsA(fieldError('ToolSearchTool.type')),
      );
    });
    test('takes a deep immutable parameters snapshot', () {
      final parameters = <dynamic, dynamic>{
        'nested': <dynamic, dynamic>{
          'values': [1],
        },
      };
      final tool = ToolSearchTool.fromJson({
        'type': 'tool_search',
        'parameters': parameters,
      });
      ((parameters['nested'] as Map)['values'] as List).add(2);
      expect(tool.parameters, {
        'nested': {
          'values': [1],
        },
      });
      expect(() => tool.parameters!.clear(), throwsUnsupportedError);
      expect(
        () => ((tool.parameters!['nested'] as Map)['values'] as List).clear(),
        throwsUnsupportedError,
      );
    });
    test('constructor, copy and parser tear-off compatibility remain', () {
      const constant = ToolSearchTool(parameters: {'type': 'object'});
      final parameters = <String, dynamic>{'type': 'object'};
      final tool = ToolSearchTool(parameters: parameters);
      const ToolSearchTool Function(Map<String, dynamic>) parse =
          ToolSearchTool.fromJson;
      expect(parse(constant.toJson()), constant);
      expect(identical(tool.parameters, parameters), isTrue);
      expect(identical(tool.copyWith().parameters, parameters), isTrue);
    });
    test('copy with updates and clears all optional fields', () {
      const tool = ToolSearchTool(
        execution: ToolSearchExecutionType.client,
        description: 'lookup',
        parameters: {'query': 'string'},
      );
      expect(tool.copyWith(), tool);
      expect(
        tool.copyWith(execution: ToolSearchExecutionType.server).execution,
        ToolSearchExecutionType.server,
      );
      expect(tool.copyWith(description: '').description, '');
      expect(
        tool.copyWith(parameters: <String, dynamic>{}).parameters,
        isEmpty,
      );
      expect(
        tool.copyWith(execution: null, description: null, parameters: null),
        const ToolSearchTool(),
      );
    });
    test(
      'deep equality and map-order independent hashing cover parameters',
      () {
        const a = ToolSearchTool(
          description: 'search',
          parameters: {
            'nested': {
              'a': [1, null],
              'b': false,
            },
          },
        );
        const b = ToolSearchTool(
          description: 'search',
          parameters: {
            'nested': {
              'b': false,
              'a': [1, null],
            },
          },
        );
        expect(a, b);
        expect(a.hashCode, b.hashCode);
        expect(
          a.copyWith(
            parameters: {
              'nested': {
                'a': [1],
                'b': false,
              },
            },
          ),
          isNot(a),
        );
        expect(a.copyWith(description: null), isNot(a));
        expect(a.copyWith(execution: ToolSearchExecutionType.client), isNot(a));
        expect(
          const ToolSearchTool(parameters: {'a': null}),
          isNot(const ToolSearchTool(parameters: {'b': null})),
        );
      },
    );
    test('diagnostics list all fields without description/schema payload', () {
      const tool = ToolSearchTool(
        execution: ToolSearchExecutionType.client,
        description: 'secret',
        parameters: {
          'secret': ['secret'],
        },
      );
      final diagnostic = tool.toString();
      expect(diagnostic, contains('execution: ToolSearchExecutionType.client'));
      expect(diagnostic, contains('description: 6 chars'));
      expect(diagnostic, contains('parameters: 1 keys'));
      expect(diagnostic, isNot(contains('secret')));
      expect(
        const ToolSearchTool().toString(),
        contains('description: null, parameters: null'),
      );
    });
  });

  group('runtime type value symmetry', () {
    test('namespace and subclass are unequal in both directions', () {
      const base = NamespaceTool(
        name: 'crm',
        description: '',
        tools: [FunctionTool(name: 'lookup')],
      );
      const child = _NamespaceSubtype();
      expect(base == child, isFalse);
      expect(child == base, isFalse);
    });
    test('tool-search configuration and subclass are unequal both ways', () {
      const base = ToolSearchTool();
      const child = _ToolSearchSubtype();
      expect(base == child, isFalse);
      expect(child == base, isFalse);
    });
    test('unknown definition and subclass are unequal in both directions', () {
      const base = UnknownNamespaceTool({'type': 'future'});
      const child = _UnknownNamespaceSubtype();
      expect(base == child, isFalse);
      expect(child == base, isFalse);
    });
  });

  group('unknown namespace definitions', () {
    for (final parser in parseDefinitions.entries) {
      test('${parser.key} future definitions round trip with deep values', () {
        final data = {
          'type': 'future',
          'nested': {
            'values': [
              1,
              null,
              {'secret': 'payload'},
            ],
          },
        };
        final tool = parser.value(namespace(tools: [data])) as NamespaceTool;
        final unknown = tool.tools.single as UnknownNamespaceTool;
        expect(unknown.toJson(), data);
        expect(tool.toJson(), namespace(tools: [data]));
        expect(unknown.toString(), 'UnknownNamespaceTool(data: 2 keys)');
        expect(unknown.data.clear, throwsUnsupportedError);
        expect(
          () => ((unknown.data['nested'] as Map)['values'] as List).clear(),
          throwsUnsupportedError,
        );
      });
    }
    test('raw deep equality/hash/copy include all payload fields', () {
      const a = UnknownNamespaceTool({
        'type': 'future',
        'payload': {
          'a': [1, null],
          'b': false,
        },
      });
      const b = UnknownNamespaceTool({
        'payload': {
          'b': false,
          'a': [1, null],
        },
        'type': 'future',
      });
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.copyWith(), a);
      expect(a.copyWith(data: {'type': 'other'}).toJson(), {'type': 'other'});
      expect(a.copyWith(data: {}), isNot(a));
      expect(a, isNot('future'));
      expect(
        const UnknownNamespaceTool({'a': null}),
        isNot(const UnknownNamespaceTool({'b': null})),
      );
    });
    test('explicit constructor remains const and caller-owned', () {
      const constant = UnknownNamespaceTool({'type': 'future'});
      final data = <String, dynamic>{'type': 'future'};
      final tool = UnknownNamespaceTool(data);
      expect(tool, constant);
      expect(identical(tool.data, data), isTrue);
      expect(identical(tool.copyWith().data, data), isTrue);
      data['extra'] = true;
      expect(tool.toJson(), {'type': 'future', 'extra': true});
    });
    test('future top-level definitions retain existing rejection', () {
      expect(
        () => ResponseTool.fromToolSearchOutputJson({'type': 'future'}),
        throwsFormatException,
      );
    });
  });
}

class _NamespaceSubtype extends NamespaceTool {
  const _NamespaceSubtype()
    : super(
        name: 'crm',
        description: '',
        tools: const [FunctionTool(name: 'lookup')],
      );
}

class _ToolSearchSubtype extends ToolSearchTool {
  const _ToolSearchSubtype();
}

class _UnknownNamespaceSubtype extends UnknownNamespaceTool {
  const _UnknownNamespaceSubtype() : super(const {'type': 'future'});
}
