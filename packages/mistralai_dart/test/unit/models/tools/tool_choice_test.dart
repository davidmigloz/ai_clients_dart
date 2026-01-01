import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ToolChoice', () {
    group('ToolChoiceAuto', () {
      test('creates with factory', () {
        const choice = ToolChoice.auto;
        expect(choice, isA<ToolChoiceAuto>());
      });

      test('serializes to JSON', () {
        const choice = ToolChoice.auto;
        expect(choice.toJson(), 'auto');
      });

      test('deserializes from JSON', () {
        final choice = ToolChoice.fromJson('auto');
        expect(choice, isA<ToolChoiceAuto>());
      });
    });

    group('ToolChoiceNone', () {
      test('creates with factory', () {
        const choice = ToolChoice.none;
        expect(choice, isA<ToolChoiceNone>());
      });

      test('serializes to JSON', () {
        const choice = ToolChoice.none;
        expect(choice.toJson(), 'none');
      });

      test('deserializes from JSON', () {
        final choice = ToolChoice.fromJson('none');
        expect(choice, isA<ToolChoiceNone>());
      });
    });

    group('ToolChoiceAny', () {
      test('creates with factory', () {
        const choice = ToolChoice.any;
        expect(choice, isA<ToolChoiceAny>());
      });

      test('serializes to JSON', () {
        const choice = ToolChoice.any;
        expect(choice.toJson(), 'any');
      });

      test('deserializes from JSON', () {
        final choice = ToolChoice.fromJson('any');
        expect(choice, isA<ToolChoiceAny>());
      });
    });

    group('ToolChoiceRequired', () {
      test('creates with factory', () {
        const choice = ToolChoice.required;
        expect(choice, isA<ToolChoiceRequired>());
      });

      test('serializes to JSON', () {
        const choice = ToolChoice.required;
        expect(choice.toJson(), 'required');
      });

      test('deserializes from JSON', () {
        final choice = ToolChoice.fromJson('required');
        expect(choice, isA<ToolChoiceRequired>());
      });
    });

    group('ToolChoiceFunction', () {
      test('creates with factory', () {
        final choice = ToolChoice.function('get_weather');
        expect(choice, isA<ToolChoiceFunction>());
        expect(choice.name, 'get_weather');
      });

      test('serializes to JSON', () {
        final choice = ToolChoice.function('my_func');
        final json = choice.toJson();

        expect(json, isA<Map<String, dynamic>>());
        final map = json as Map<String, dynamic>;
        expect(map['type'], 'function');
        expect(map['function'], isA<Map<String, dynamic>>());
        expect((map['function'] as Map)['name'], 'my_func');
      });

      test('deserializes from JSON', () {
        final json = {
          'type': 'function',
          'function': {'name': 'test_func'},
        };
        final choice = ToolChoice.fromJson(json);

        expect(choice, isA<ToolChoiceFunction>());
        expect((choice as ToolChoiceFunction).name, 'test_func');
      });
    });

    group('fromJson', () {
      test('throws for unknown string', () {
        expect(
          () => ToolChoice.fromJson('unknown'),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
