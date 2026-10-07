import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> functionJson() => {
    'type': 'function',
    'name': 'fetch_weather',
    'description': 'Read a private weather source',
    'parameters': {
      'type': 'object',
      'properties': {
        'cities': {
          'type': 'array',
          'items': {'type': 'string'},
        },
      },
      'required': ['cities'],
      'additionalProperties': false,
    },
    'strict': true,
    'defer_loading': true,
    'allowed_callers': ['direct', 'programmatic'],
    'output_schema': {
      'type': 'object',
      'properties': {
        'forecasts': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'city': {'type': 'string'},
            },
          },
        },
      },
    },
    'async': true,
  };

  Map<String, dynamic> customJson() => {
    'type': 'custom',
    'name': 'lookup',
    'description': 'Read a private lookup source',
    'format': {
      'type': 'grammar',
      'syntax': 'lark',
      'definition': 'start: "private grammar literal"',
      'provider_extension': {
        'tokens': ['first', 'second'],
      },
    },
    'defer_loading': true,
    'allowed_callers': ['direct', 'programmatic'],
    'async': false,
  };

  group('Async definition wire values', () {
    for (final type in ['function', 'custom']) {
      for (final value in <bool?>[null, false, true]) {
        test('$type preserves ${value ?? 'omitted'} async', () {
          final json = type == 'function' ? functionJson() : customJson();
          if (value == null) {
            json.remove('async');
          } else {
            json['async'] = value;
          }
          final tool = ResponseTool.fromJson(json);

          expect(tool.toJson(), json);
          expect(switch (tool) {
            final FunctionTool tool => tool.async,
            final CustomTool tool => tool.async,
            _ => fail('Expected a callable definition'),
          }, value);
        });
      }

      for (final value in <Object?>[null, 0, 'true', [], {}]) {
        test('$type rejects supplied $value async', () {
          final json = type == 'function' ? functionJson() : customJson();
          json['async'] = value;

          expect(
            () => ResponseTool.fromJson(json),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'context',
                contains(
                  type == 'function'
                      ? 'FunctionTool.async'
                      : 'CustomTool.async',
                ),
              ),
            ),
          );
        });
      }
    }

    test('function convenience forwards every existing and new option', () {
      final json = functionJson();
      final tool = ResponseTool.function(
        name: json['name'] as String,
        description: json['description'] as String,
        parameters: json['parameters'] as Map<String, dynamic>,
        strict: true,
        deferLoading: true,
        allowedCallers: const [
          CallableToolAllowedCaller.direct,
          CallableToolAllowedCaller.programmatic,
        ],
        outputSchema: json['output_schema'] as Map<String, dynamic>,
        async: true,
      );

      expect(tool.toJson(), json);
    });

    test('custom convenience forwards every existing and new option', () {
      final json = customJson();
      final tool = ResponseTool.custom(
        name: json['name'] as String,
        description: json['description'] as String,
        format: json['format'] as Map<String, dynamic>,
        deferLoading: true,
        allowedCallers: const [
          CallableToolAllowedCaller.direct,
          CallableToolAllowedCaller.programmatic,
        ],
        async: false,
      );

      expect(tool.toJson(), json);
    });

    test('minimal const definitions omit async and remain const', () {
      const function = FunctionTool(name: 'f');
      const custom = CustomTool(name: 'c');

      expect(function.toJson(), {'type': 'function', 'name': 'f'});
      expect(custom.toJson(), {'type': 'custom', 'name': 'c'});
      expect(function.type, 'function');
      expect(custom.type, 'custom');
      expect(function.async, isNull);
      expect(custom.async, isNull);
    });

    test('existing nullable optional fields retain parsing tolerance', () {
      final function = FunctionTool.fromJson(const {
        'type': 'function',
        'name': 'f',
        'description': null,
        'parameters': null,
        'strict': null,
        'defer_loading': null,
        'allowed_callers': null,
        'output_schema': null,
      });
      final custom = CustomTool.fromJson(const {
        'type': 'custom',
        'name': 'c',
        'description': null,
        'format': null,
        'defer_loading': null,
        'allowed_callers': null,
      });

      expect(function.toJson(), {'type': 'function', 'name': 'f'});
      expect(custom.toJson(), {'type': 'custom', 'name': 'c'});
    });

    test('nested deferred namespaces retain both definition async values', () {
      final json = {
        'type': 'namespace',
        'name': 'external',
        'description': 'Deferred external tools',
        'tools': [functionJson(), customJson()],
      };
      final namespace = ResponseTool.fromJson(json) as NamespaceTool;
      final restored = ResponseTool.fromJson(
        jsonDecode(jsonEncode(namespace.toJson())) as Map<String, dynamic>,
      );

      expect(namespace.toJson(), json);
      expect((namespace.tools[0] as FunctionTool).async, isTrue);
      expect((namespace.tools[1] as CustomTool).async, isFalse);
      expect((namespace.tools[0] as FunctionTool).deferLoading, isTrue);
      expect((namespace.tools[1] as CustomTool).deferLoading, isTrue);
      expect(restored, namespace);
      expect(restored.hashCode, namespace.hashCode);
    });
  });

  group('Callable definition required fields', () {
    for (final type in ['function', 'custom']) {
      final model = type == 'function' ? 'FunctionTool' : 'CustomTool';
      final ResponseTool Function(Map<String, dynamic>) parse =
          type == 'function' ? FunctionTool.fromJson : CustomTool.fromJson;
      for (final key in ['type', 'name']) {
        test('$model rejects missing $key with field context', () {
          final json = (type == 'function' ? functionJson() : customJson())
            ..remove(key);

          expect(
            () => parse(json),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'field context',
                contains('$model.$key'),
              ),
            ),
          );
        });
        for (final value in <Object?>[null, false, 0, [], {}]) {
          test('$model rejects $value $key with field context', () {
            final json = type == 'function' ? functionJson() : customJson();
            json[key] = value;

            expect(
              () => parse(json),
              throwsA(
                isA<FormatException>().having(
                  (e) => e.message,
                  'field context',
                  contains('$model.$key'),
                ),
              ),
            );
          });
        }
      }
      test('$model rejects a mismatched discriminator', () {
        final json = type == 'function' ? functionJson() : customJson();
        json['type'] = type == 'function' ? 'custom' : 'function';

        expect(
          () => parse(json),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'discriminator context',
              contains('$model.type'),
            ),
          ),
        );
      });
    }
  });

  group('FunctionTool complete value and copy contracts', () {
    test('independent nested schemas compare and hash by content', () {
      final tool = FunctionTool.fromJson(functionJson());
      final reordered = functionJson();
      reordered['parameters'] = {
        'additionalProperties': false,
        'required': ['cities'],
        'properties': {
          'cities': {
            'items': {'type': 'string'},
            'type': 'array',
          },
        },
        'type': 'object',
      };
      final independent = FunctionTool.fromJson(reordered);

      expect(independent, tool);
      expect(independent.hashCode, tool.hashCode);
      expect({tool}, contains(independent));
      expect(tool.toJson(), functionJson());
    });

    test(
      'omitted copy parameters retain every value and collection identity',
      () {
        final tool = FunctionTool.fromJson(functionJson());
        final copy = tool.copyWith();

        expect(copy.toJson(), functionJson());
        expect(copy, tool);
        expect(copy.hashCode, tool.hashCode);
        expect(copy.parameters, same(tool.parameters));
        expect(copy.outputSchema, same(tool.outputSchema));
        expect(copy.allowedCallers, same(tool.allowedCallers));
        expect(tool.copyWith(name: null).name, tool.name);
      },
    );

    final clears = <String, FunctionTool Function(FunctionTool)>{
      'description': (tool) => tool.copyWith(description: null),
      'parameters': (tool) => tool.copyWith(parameters: null),
      'strict': (tool) => tool.copyWith(strict: null),
      'defer_loading': (tool) => tool.copyWith(deferLoading: null),
      'allowed_callers': (tool) => tool.copyWith(allowedCallers: null),
      'output_schema': (tool) => tool.copyWith(outputSchema: null),
      'async': (tool) => tool.copyWith(async: null),
    };
    for (final entry in clears.entries) {
      test('copy clears only ${entry.key}', () {
        final tool = FunctionTool.fromJson(functionJson());
        final expected = functionJson()..remove(entry.key);
        final changed = entry.value(tool);

        expect(changed.toJson(), expected);
        expect(changed, isNot(tool));
        expect({tool}, isNot(contains(changed)));
        expect(tool.toJson(), functionJson());
      });
    }

    final replacements = <String, FunctionTool Function(FunctionTool)>{
      'name': (tool) => tool.copyWith(name: 'changed'),
      'description': (tool) => tool.copyWith(description: 'changed'),
      'parameters': (tool) => tool.copyWith(parameters: <String, dynamic>{}),
      'strict': (tool) => tool.copyWith(strict: false),
      'defer_loading': (tool) => tool.copyWith(deferLoading: false),
      'allowed_callers': (tool) =>
          tool.copyWith(allowedCallers: <CallableToolAllowedCaller>[]),
      'output_schema': (tool) =>
          tool.copyWith(outputSchema: <String, dynamic>{}),
      'async': (tool) => tool.copyWith(async: false),
    };
    final replacementValues = <String, Object>{
      'name': 'changed',
      'description': 'changed',
      'parameters': <String, dynamic>{},
      'strict': false,
      'defer_loading': false,
      'allowed_callers': <String>[],
      'output_schema': <String, dynamic>{},
      'async': false,
    };
    for (final entry in replacements.entries) {
      test('copy replaces only ${entry.key} and equality includes it', () {
        final tool = FunctionTool.fromJson(functionJson());
        final expected = functionJson()
          ..[entry.key] = replacementValues[entry.key];
        final changed = entry.value(tool);
        final independent = FunctionTool.fromJson(expected);

        expect(changed.toJson(), expected);
        expect(changed, isNot(tool));
        expect(changed, independent);
        expect(changed.hashCode, independent.hashCode);
        expect({tool}, isNot(contains(changed)));
        expect(tool.toJson(), functionJson());
      });
    }

    test(
      'diagnostics include all fields without schema/description payloads',
      () {
        final tool = FunctionTool.fromJson(functionJson());
        final diagnostic = tool.toString();
        for (final field in [
          'name:',
          'description:',
          'parameters:',
          'strict:',
          'deferLoading:',
          'allowedCallers:',
          'outputSchema:',
          'async: true',
        ]) {
          expect(diagnostic, contains(field));
        }
        expect(diagnostic, isNot(contains('private weather')));
        expect(diagnostic, isNot(contains('forecasts')));
        expect(diagnostic, isNot(contains('cities')));
        expect(
          const FunctionTool(name: 'f').toString(),
          contains('description: null, parameters: null'),
        );
        expect(
          const FunctionTool(name: 'f').toString(),
          contains('async: null'),
        );
      },
    );
  });

  group('CustomTool complete value and copy contracts', () {
    test('independent nested formats compare and hash by content', () {
      final tool = CustomTool.fromJson(customJson());
      final reordered = customJson();
      reordered['format'] = {
        'provider_extension': {
          'tokens': ['first', 'second'],
        },
        'definition': 'start: "private grammar literal"',
        'syntax': 'lark',
        'type': 'grammar',
      };
      final independent = CustomTool.fromJson(reordered);

      expect(independent, tool);
      expect(independent.hashCode, tool.hashCode);
      expect({tool}, contains(independent));
      expect(tool.toJson(), customJson());
    });

    test(
      'omitted copy parameters retain every value and collection identity',
      () {
        final tool = CustomTool.fromJson(customJson());
        final copy = tool.copyWith();

        expect(copy.toJson(), customJson());
        expect(copy, tool);
        expect(copy.hashCode, tool.hashCode);
        expect(copy.format, same(tool.format));
        expect(copy.allowedCallers, same(tool.allowedCallers));
        expect(tool.copyWith(name: null).name, tool.name);
      },
    );

    final clears = <String, CustomTool Function(CustomTool)>{
      'description': (tool) => tool.copyWith(description: null),
      'format': (tool) => tool.copyWith(format: null),
      'defer_loading': (tool) => tool.copyWith(deferLoading: null),
      'allowed_callers': (tool) => tool.copyWith(allowedCallers: null),
      'async': (tool) => tool.copyWith(async: null),
    };
    for (final entry in clears.entries) {
      test('copy clears only ${entry.key}', () {
        final tool = CustomTool.fromJson(customJson());
        final expected = customJson()..remove(entry.key);
        final changed = entry.value(tool);

        expect(changed.toJson(), expected);
        expect(changed, isNot(tool));
        expect({tool}, isNot(contains(changed)));
        expect(tool.toJson(), customJson());
      });
    }

    final replacements = <String, CustomTool Function(CustomTool)>{
      'name': (tool) => tool.copyWith(name: 'changed'),
      'description': (tool) => tool.copyWith(description: 'changed'),
      'format': (tool) => tool.copyWith(format: <String, dynamic>{}),
      'defer_loading': (tool) => tool.copyWith(deferLoading: false),
      'allowed_callers': (tool) =>
          tool.copyWith(allowedCallers: <CallableToolAllowedCaller>[]),
      'async': (tool) => tool.copyWith(async: true),
    };
    final replacementValues = <String, Object>{
      'name': 'changed',
      'description': 'changed',
      'format': <String, dynamic>{},
      'defer_loading': false,
      'allowed_callers': <String>[],
      'async': true,
    };
    for (final entry in replacements.entries) {
      test('copy replaces only ${entry.key} and equality includes it', () {
        final tool = CustomTool.fromJson(customJson());
        final expected = customJson()
          ..[entry.key] = replacementValues[entry.key];
        final changed = entry.value(tool);
        final independent = CustomTool.fromJson(expected);

        expect(changed.toJson(), expected);
        expect(changed, isNot(tool));
        expect(changed, independent);
        expect(changed.hashCode, independent.hashCode);
        expect({tool}, isNot(contains(changed)));
        expect(tool.toJson(), customJson());
      });
    }

    test(
      'diagnostics include all fields without grammar/description payloads',
      () {
        final diagnostic = CustomTool.fromJson(customJson()).toString();
        for (final field in [
          'name:',
          'description:',
          'format:',
          'deferLoading:',
          'allowedCallers:',
          'async: false',
        ]) {
          expect(diagnostic, contains(field));
        }
        expect(diagnostic, isNot(contains('private lookup')));
        expect(diagnostic, isNot(contains('private grammar')));
        expect(diagnostic, isNot(contains('provider_extension')));
        expect(
          const CustomTool(name: 'c').toString(),
          contains('description: null, format: null'),
        );
        expect(const CustomTool(name: 'c').toString(), contains('async: null'));
      },
    );
  });

  test('definitions preserve caller-owned collection references', () {
    final schema = <String, dynamic>{'type': 'object'};
    final output = <String, dynamic>{'type': 'string'};
    final format = <String, dynamic>{'type': 'text'};
    final callers = [CallableToolAllowedCaller.direct];
    final function = FunctionTool(
      name: 'f',
      parameters: schema,
      outputSchema: output,
      allowedCallers: callers,
      async: true,
    );
    final custom = CustomTool(
      name: 'c',
      format: format,
      allowedCallers: callers,
      async: true,
    );

    expect(function.parameters, same(schema));
    expect(function.outputSchema, same(output));
    expect(function.allowedCallers, same(callers));
    expect(custom.format, same(format));
    expect(custom.allowedCallers, same(callers));
    expect(function.copyWith().parameters, same(schema));
    expect(custom.copyWith().format, same(format));
    schema['additionalProperties'] = false;
    format['provider_extension'] = 'retained';
    callers.add(CallableToolAllowedCaller.programmatic);
    expect(function.toJson()['parameters'], schema);
    expect(function.toJson()['allowed_callers'], ['direct', 'programmatic']);
    expect(custom.toJson()['format'], format);
    expect(custom.toJson()['allowed_callers'], ['direct', 'programmatic']);
  });
}
