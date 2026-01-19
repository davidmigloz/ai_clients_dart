import 'package:open_responses_dart/open_responses_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ToolChoiceMode', () {
    test('fromJson parses none', () {
      expect(ToolChoiceMode.fromJson('none'), ToolChoiceMode.none);
    });

    test('fromJson parses auto', () {
      expect(ToolChoiceMode.fromJson('auto'), ToolChoiceMode.auto);
    });

    test('fromJson parses required', () {
      expect(ToolChoiceMode.fromJson('required'), ToolChoiceMode.required);
    });

    test('fromJson throws on unknown value', () {
      expect(
        () => ToolChoiceMode.fromJson('unknown_mode'),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson returns correct value', () {
      expect(ToolChoiceMode.none.toJson(), 'none');
      expect(ToolChoiceMode.auto.toJson(), 'auto');
      expect(ToolChoiceMode.required.toJson(), 'required');
    });

    test('round-trip serialization', () {
      for (final mode in ToolChoiceMode.values) {
        final json = mode.toJson();
        final parsed = ToolChoiceMode.fromJson(json);
        expect(parsed, mode);
      }
    });
  });

  group('SpecificFunctionChoice', () {
    test('fromJson parses correctly', () {
      final choice = SpecificFunctionChoice.fromJson(const {
        'type': 'function',
        'name': 'get_weather',
      });
      expect(choice.name, 'get_weather');
    });

    test('toJson returns correct map', () {
      const choice = SpecificFunctionChoice(name: 'get_weather');
      expect(choice.toJson(), {'type': 'function', 'name': 'get_weather'});
    });

    test('equality works correctly', () {
      const a = SpecificFunctionChoice(name: 'get_weather');
      const b = SpecificFunctionChoice(name: 'get_weather');
      const c = SpecificFunctionChoice(name: 'get_time');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is consistent with equality', () {
      const a = SpecificFunctionChoice(name: 'get_weather');
      const b = SpecificFunctionChoice(name: 'get_weather');

      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes name', () {
      const choice = SpecificFunctionChoice(name: 'get_weather');
      expect(choice.toString(), contains('get_weather'));
    });

    test('round-trip serialization', () {
      const original = SpecificFunctionChoice(name: 'search');
      final json = original.toJson();
      final parsed = SpecificFunctionChoice.fromJson(json);
      expect(parsed, equals(original));
    });
  });

  group('SpecificToolChoice', () {
    test('fromJson dispatches to SpecificFunctionChoice', () {
      final choice = SpecificToolChoice.fromJson(const {
        'type': 'function',
        'name': 'calculate',
      });
      expect(choice, isA<SpecificFunctionChoice>());
      expect((choice as SpecificFunctionChoice).name, 'calculate');
    });

    test('fromJson throws on unknown type', () {
      expect(
        () => SpecificToolChoice.fromJson(const {'type': 'unknown'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ToolChoice', () {
    group('string variants', () {
      test('fromJson parses none string', () {
        final choice = ToolChoice.fromJson('none');
        expect(choice, isA<ToolChoiceNone>());
      });

      test('fromJson parses auto string', () {
        final choice = ToolChoice.fromJson('auto');
        expect(choice, isA<ToolChoiceAuto>());
      });

      test('fromJson parses required string', () {
        final choice = ToolChoice.fromJson('required');
        expect(choice, isA<ToolChoiceRequired>());
      });

      test('fromJson throws on unknown string', () {
        expect(
          () => ToolChoice.fromJson('invalid'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('ToolChoiceNone', () {
      test('toJson returns none string', () {
        const choice = ToolChoiceNone();
        expect(choice.toJson(), 'none');
      });

      test('equality works correctly', () {
        const a = ToolChoiceNone();
        const b = ToolChoiceNone();
        expect(a, equals(b));
      });

      test('toString returns expected value', () {
        const choice = ToolChoiceNone();
        expect(choice.toString(), 'ToolChoiceNone()');
      });
    });

    group('ToolChoiceAuto', () {
      test('toJson returns auto string', () {
        const choice = ToolChoiceAuto();
        expect(choice.toJson(), 'auto');
      });

      test('equality works correctly', () {
        const a = ToolChoiceAuto();
        const b = ToolChoiceAuto();
        expect(a, equals(b));
      });

      test('toString returns expected value', () {
        const choice = ToolChoiceAuto();
        expect(choice.toString(), 'ToolChoiceAuto()');
      });
    });

    group('ToolChoiceRequired', () {
      test('toJson returns required string', () {
        const choice = ToolChoiceRequired();
        expect(choice.toJson(), 'required');
      });

      test('equality works correctly', () {
        const a = ToolChoiceRequired();
        const b = ToolChoiceRequired();
        expect(a, equals(b));
      });

      test('toString returns expected value', () {
        const choice = ToolChoiceRequired();
        expect(choice.toString(), 'ToolChoiceRequired()');
      });
    });

    group('ToolChoiceFunction', () {
      test('fromJson parses correctly', () {
        final choice = ToolChoice.fromJson(const {
          'type': 'function',
          'name': 'my_function',
        });
        expect(choice, isA<ToolChoiceFunction>());
        expect((choice as ToolChoiceFunction).name, 'my_function');
      });

      test('toJson returns correct map', () {
        const choice = ToolChoiceFunction(name: 'my_function');
        expect(choice.toJson(), {'type': 'function', 'name': 'my_function'});
      });

      test('equality works correctly', () {
        const a = ToolChoiceFunction(name: 'func1');
        const b = ToolChoiceFunction(name: 'func1');
        const c = ToolChoiceFunction(name: 'func2');

        expect(a, equals(b));
        expect(a, isNot(equals(c)));
      });

      test('hashCode is consistent with equality', () {
        const a = ToolChoiceFunction(name: 'func1');
        const b = ToolChoiceFunction(name: 'func1');
        expect(a.hashCode, equals(b.hashCode));
      });

      test('toString includes name', () {
        const choice = ToolChoiceFunction(name: 'my_function');
        expect(choice.toString(), contains('my_function'));
      });

      test('round-trip serialization', () {
        const original = ToolChoiceFunction(name: 'test_func');
        final json = original.toJson() as Map<String, dynamic>;
        final parsed = ToolChoice.fromJson(json);
        expect(parsed, equals(original));
      });
    });

    group('ToolChoiceAllowedTools', () {
      test('fromJson parses correctly with mode', () {
        final choice = ToolChoice.fromJson(const {
          'type': 'allowed_tools',
          'tools': [
            {'type': 'function', 'name': 'func1'},
            {'type': 'function', 'name': 'func2'},
          ],
          'mode': 'auto',
        });
        expect(choice, isA<ToolChoiceAllowedTools>());
        final allowed = choice as ToolChoiceAllowedTools;
        expect(allowed.tools.length, 2);
        expect(allowed.mode, ToolChoiceMode.auto);
      });

      test('fromJson parses correctly without mode', () {
        final choice = ToolChoice.fromJson(const {
          'type': 'allowed_tools',
          'tools': [
            {'type': 'function', 'name': 'func1'},
          ],
        });
        expect(choice, isA<ToolChoiceAllowedTools>());
        final allowed = choice as ToolChoiceAllowedTools;
        expect(allowed.tools.length, 1);
        expect(allowed.mode, isNull);
      });

      test('toJson returns correct map with mode', () {
        const choice = ToolChoiceAllowedTools(
          tools: [
            SpecificFunctionChoice(name: 'func1'),
          ],
          mode: ToolChoiceMode.required,
        );
        expect(choice.toJson(), {
          'type': 'allowed_tools',
          'tools': [
            {'type': 'function', 'name': 'func1'},
          ],
          'mode': 'required',
        });
      });

      test('toJson omits mode when null', () {
        const choice = ToolChoiceAllowedTools(
          tools: [SpecificFunctionChoice(name: 'func1')],
        );
        final json = choice.toJson() as Map<String, dynamic>;
        expect(json.containsKey('mode'), isFalse);
      });

      test('equality works correctly', () {
        const a = ToolChoiceAllowedTools(
          tools: [SpecificFunctionChoice(name: 'func1')],
          mode: ToolChoiceMode.auto,
        );
        const b = ToolChoiceAllowedTools(
          tools: [SpecificFunctionChoice(name: 'func1')],
          mode: ToolChoiceMode.auto,
        );
        const c = ToolChoiceAllowedTools(
          tools: [SpecificFunctionChoice(name: 'func2')],
          mode: ToolChoiceMode.auto,
        );
        const d = ToolChoiceAllowedTools(
          tools: [SpecificFunctionChoice(name: 'func1')],
          mode: ToolChoiceMode.required,
        );

        expect(a, equals(b));
        expect(a, isNot(equals(c)));
        expect(a, isNot(equals(d)));
      });

      test('hashCode is consistent with equality', () {
        const a = ToolChoiceAllowedTools(
          tools: [SpecificFunctionChoice(name: 'func1')],
          mode: ToolChoiceMode.auto,
        );
        const b = ToolChoiceAllowedTools(
          tools: [SpecificFunctionChoice(name: 'func1')],
          mode: ToolChoiceMode.auto,
        );
        expect(a.hashCode, equals(b.hashCode));
      });

      test('toString includes tools and mode', () {
        const choice = ToolChoiceAllowedTools(
          tools: [SpecificFunctionChoice(name: 'func1')],
          mode: ToolChoiceMode.auto,
        );
        final str = choice.toString();
        expect(str, contains('func1'));
        expect(str, contains('auto'));
      });

      test('round-trip serialization', () {
        const original = ToolChoiceAllowedTools(
          tools: [
            SpecificFunctionChoice(name: 'search'),
            SpecificFunctionChoice(name: 'calculate'),
          ],
          mode: ToolChoiceMode.none,
        );
        final json = original.toJson() as Map<String, dynamic>;
        final parsed = ToolChoice.fromJson(json);
        expect(parsed, equals(original));
      });
    });

    test('fromJson throws on invalid format', () {
      expect(
        () => ToolChoice.fromJson(123),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromJson throws on unknown object type', () {
      expect(
        () => ToolChoice.fromJson(const {'type': 'unknown'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
