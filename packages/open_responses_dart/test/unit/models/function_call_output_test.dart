import 'package:open_responses_dart/open_responses_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FunctionCallOutput', () {
    test('fromJson parses string format', () {
      final output = FunctionCallOutput.fromJson('result');
      expect(output, isA<FunctionCallOutputString>());
      expect((output as FunctionCallOutputString).value, 'result');
    });

    test('fromJson parses list format', () {
      final output = FunctionCallOutput.fromJson([
        {'type': 'input_text', 'text': 'Hello'},
      ]);
      expect(output, isA<FunctionCallOutputContent>());
      final content = (output as FunctionCallOutputContent).content;
      expect(content.length, 1);
      expect(content.first, isA<InputTextContent>());
    });

    test('fromJson throws on invalid format', () {
      expect(
        () => FunctionCallOutput.fromJson(123),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => FunctionCallOutput.fromJson({'invalid': 'format'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('FunctionCallOutputString', () {
    test('toJson returns string value', () {
      const output = FunctionCallOutputString('test result');
      expect(output.toJson(), 'test result');
    });

    test('equality works correctly', () {
      const a = FunctionCallOutputString('result');
      const b = FunctionCallOutputString('result');
      const c = FunctionCallOutputString('other');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is consistent with equality', () {
      const a = FunctionCallOutputString('result');
      const b = FunctionCallOutputString('result');

      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes value', () {
      const output = FunctionCallOutputString('test');
      expect(output.toString(), contains('test'));
    });

    test('round-trip serialization', () {
      const original = FunctionCallOutputString('function output');
      final json = original.toJson();
      final parsed = FunctionCallOutput.fromJson(json);

      expect(parsed, equals(original));
    });
  });

  group('FunctionCallOutputContent', () {
    test('toJson returns list of content', () {
      const output = FunctionCallOutputContent([
        InputTextContent(text: 'Hello'),
      ]);
      final json = output.toJson() as List;
      expect(json.length, 1);
      expect((json.first as Map)['type'], 'input_text');
      expect((json.first as Map)['text'], 'Hello');
    });

    test('equality works correctly', () {
      const a = FunctionCallOutputContent([InputTextContent(text: 'Hello')]);
      const b = FunctionCallOutputContent([InputTextContent(text: 'Hello')]);
      const c = FunctionCallOutputContent([InputTextContent(text: 'World')]);
      const d = FunctionCallOutputContent([]);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a, isNot(equals(d)));
    });

    test('hashCode is consistent with equality', () {
      const a = FunctionCallOutputContent([InputTextContent(text: 'Hello')]);
      const b = FunctionCallOutputContent([InputTextContent(text: 'Hello')]);

      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes content', () {
      const output = FunctionCallOutputContent([
        InputTextContent(text: 'test'),
      ]);
      final str = output.toString();
      expect(str, contains('FunctionCallOutputContent'));
    });

    test('round-trip serialization', () {
      const original = FunctionCallOutputContent([
        InputTextContent(text: 'Hello'),
        InputTextContent(text: 'World'),
      ]);
      final json = original.toJson();
      final parsed = FunctionCallOutput.fromJson(json);

      expect(parsed, equals(original));
    });

    test('handles empty list', () {
      const output = FunctionCallOutputContent([]);
      final json = output.toJson() as List;
      expect(json, isEmpty);

      final parsed = FunctionCallOutput.fromJson(<dynamic>[]);
      expect(parsed, isA<FunctionCallOutputContent>());
      expect((parsed as FunctionCallOutputContent).content, isEmpty);
    });
  });

  group('FunctionCallOutputString vs FunctionCallOutputContent', () {
    test('different types are not equal', () {
      const stringOutput = FunctionCallOutputString('Hello');
      const contentOutput = FunctionCallOutputContent([
        InputTextContent(text: 'Hello'),
      ]);

      expect(stringOutput, isNot(equals(contentOutput)));
    });
  });
}
