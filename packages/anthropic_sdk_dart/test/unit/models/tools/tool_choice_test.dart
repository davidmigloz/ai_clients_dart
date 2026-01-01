import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ToolChoice', () {
    group('factory constructors', () {
      test('auto() creates ToolChoiceAuto', () {
        final choice = ToolChoice.auto();

        expect(choice, isA<ToolChoiceAuto>());
        expect((choice as ToolChoiceAuto).disableParallelToolUse, isNull);
      });

      test('auto() with disableParallelToolUse', () {
        final choice = ToolChoice.auto(disableParallelToolUse: true);

        expect((choice as ToolChoiceAuto).disableParallelToolUse, isTrue);
      });

      test('any() creates ToolChoiceAny', () {
        final choice = ToolChoice.any();

        expect(choice, isA<ToolChoiceAny>());
      });

      test('tool() creates ToolChoiceTool', () {
        final choice = ToolChoice.tool('get_weather');

        expect(choice, isA<ToolChoiceTool>());
        expect((choice as ToolChoiceTool).name, 'get_weather');
      });

      test('none() creates ToolChoiceNone', () {
        final choice = ToolChoice.none();

        expect(choice, isA<ToolChoiceNone>());
      });
    });

    group('fromJson', () {
      test('parses auto', () {
        final json = {'type': 'auto'};

        final choice = ToolChoice.fromJson(json);

        expect(choice, isA<ToolChoiceAuto>());
      });

      test('parses auto with disable_parallel_tool_use', () {
        final json = {'type': 'auto', 'disable_parallel_tool_use': true};

        final choice = ToolChoice.fromJson(json);

        expect((choice as ToolChoiceAuto).disableParallelToolUse, isTrue);
      });

      test('parses any', () {
        final json = {'type': 'any'};

        final choice = ToolChoice.fromJson(json);

        expect(choice, isA<ToolChoiceAny>());
      });

      test('parses tool', () {
        final json = {'type': 'tool', 'name': 'get_weather'};

        final choice = ToolChoice.fromJson(json);

        expect(choice, isA<ToolChoiceTool>());
        expect((choice as ToolChoiceTool).name, 'get_weather');
      });

      test('parses none', () {
        final json = {'type': 'none'};

        final choice = ToolChoice.fromJson(json);

        expect(choice, isA<ToolChoiceNone>());
      });

      test('throws on unknown type', () {
        final json = {'type': 'unknown'};

        expect(
          () => ToolChoice.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });

  group('ToolChoiceAuto', () {
    test('toJson without options', () {
      const choice = ToolChoiceAuto();

      final json = choice.toJson();

      expect(json['type'], 'auto');
      expect(json.containsKey('disable_parallel_tool_use'), isFalse);
    });

    test('toJson with disable_parallel_tool_use', () {
      const choice = ToolChoiceAuto(disableParallelToolUse: true);

      final json = choice.toJson();

      expect(json['type'], 'auto');
      expect(json['disable_parallel_tool_use'], isTrue);
    });

    test('copyWith modifies field', () {
      const original = ToolChoiceAuto();

      final modified = original.copyWith(disableParallelToolUse: true);

      expect(modified.disableParallelToolUse, isTrue);
    });

    test('copyWith can set to null', () {
      const original = ToolChoiceAuto(disableParallelToolUse: true);

      final modified = original.copyWith(disableParallelToolUse: null);

      expect(modified.disableParallelToolUse, isNull);
    });

    test('equality', () {
      const c1 = ToolChoiceAuto(disableParallelToolUse: true);
      const c2 = ToolChoiceAuto(disableParallelToolUse: true);
      const c3 = ToolChoiceAuto(disableParallelToolUse: false);

      expect(c1, equals(c2));
      expect(c1, isNot(equals(c3)));
    });
  });

  group('ToolChoiceAny', () {
    test('toJson', () {
      const choice = ToolChoiceAny();

      final json = choice.toJson();

      expect(json['type'], 'any');
    });

    test('copyWith', () {
      const original = ToolChoiceAny();

      final modified = original.copyWith(disableParallelToolUse: true);

      expect(modified.disableParallelToolUse, isTrue);
    });
  });

  group('ToolChoiceTool', () {
    test('stores name', () {
      const choice = ToolChoiceTool('my_tool');

      expect(choice.name, 'my_tool');
    });

    test('toJson includes name', () {
      const choice = ToolChoiceTool('my_tool');

      final json = choice.toJson();

      expect(json['type'], 'tool');
      expect(json['name'], 'my_tool');
    });

    test('fromJson parses name', () {
      final json = {'type': 'tool', 'name': 'get_weather'};

      final choice = ToolChoiceTool.fromJson(json);

      expect(choice.name, 'get_weather');
    });

    test('copyWith can change name', () {
      const original = ToolChoiceTool('old_tool');

      final modified = original.copyWith(name: 'new_tool');

      expect(modified.name, 'new_tool');
    });

    test('equality considers name', () {
      const c1 = ToolChoiceTool('tool_a');
      const c2 = ToolChoiceTool('tool_a');
      const c3 = ToolChoiceTool('tool_b');

      expect(c1, equals(c2));
      expect(c1, isNot(equals(c3)));
    });
  });

  group('ToolChoiceNone', () {
    test('toJson', () {
      const choice = ToolChoiceNone();

      final json = choice.toJson();

      expect(json, {'type': 'none'});
    });

    test('all instances are equal', () {
      const c1 = ToolChoiceNone();
      const c2 = ToolChoiceNone();

      expect(c1, equals(c2));
    });
  });
}
