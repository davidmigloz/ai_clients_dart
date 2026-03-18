import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EmbedInput', () {
    group('EmbedInputString', () {
      test('creates string input', () {
        final input = EmbedInput.string('Hello!');
        expect(input, isA<EmbedInputString>());
        expect((input as EmbedInputString).value, 'Hello!');
      });

      test('serializes to JSON as string', () {
        final input = EmbedInput.string('Hello!');
        expect(input.toJson(), 'Hello!');
      });

      test('deserializes from string', () {
        final input = EmbedInput.fromJson('Hello!');
        expect(input, isA<EmbedInputString>());
        expect((input as EmbedInputString).value, 'Hello!');
      });

      test('equality works correctly', () {
        final a = EmbedInput.string('Hello!');
        final b = EmbedInput.string('Hello!');
        final c = EmbedInput.string('Bye!');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
        expect(a, isNot(equals(c)));
      });

      test('toString returns readable string', () {
        final input = EmbedInput.string('Hello!');
        expect(input.toString(), 'EmbedInputString(Hello!)');
      });
    });

    group('EmbedInputList', () {
      test('creates list input', () {
        final input = EmbedInput.list(['Hello!', 'World!']);
        expect(input, isA<EmbedInputList>());
        expect((input as EmbedInputList).values, ['Hello!', 'World!']);
      });

      test('serializes to JSON as list', () {
        final input = EmbedInput.list(['a', 'b', 'c']);
        expect(input.toJson(), ['a', 'b', 'c']);
      });

      test('deserializes from list', () {
        final input = EmbedInput.fromJson(const ['Hello', 'World']);
        expect(input, isA<EmbedInputList>());
        expect((input as EmbedInputList).values, ['Hello', 'World']);
      });

      test('equality works correctly', () {
        final a = EmbedInput.list(['Hello', 'World']);
        final b = EmbedInput.list(['Hello', 'World']);
        final c = EmbedInput.list(['Different']);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
        expect(a, isNot(equals(c)));
      });

      test('equality fails for different length lists', () {
        final a = EmbedInput.list(['Hello']);
        final b = EmbedInput.list(['Hello', 'World']);

        expect(a, isNot(equals(b)));
      });

      test('toString returns readable string', () {
        final input = EmbedInput.list(['a', 'b', 'c']);
        expect(input.toString(), 'EmbedInputList(3 values)');
      });
    });

    group('fromJson', () {
      test('throws FormatException for invalid type', () {
        expect(() => EmbedInput.fromJson(42), throwsA(isA<FormatException>()));
      });

      test('handles empty string', () {
        final input = EmbedInput.fromJson('');
        expect(input, isA<EmbedInputString>());
        expect((input as EmbedInputString).value, '');
      });

      test('handles empty list', () {
        final input = EmbedInput.fromJson(const <dynamic>[]);
        expect(input, isA<EmbedInputList>());
        expect((input as EmbedInputList).values, isEmpty);
      });
    });

    group('cross-type equality', () {
      test('string and list are not equal', () {
        final string = EmbedInput.string('Hello');
        final list = EmbedInput.list(['Hello']);
        expect(string, isNot(equals(list)));
      });
    });
  });
}
