import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EmbedInput', () {
    group('EmbedInputString', () {
      test('creates string input', () {
        const input = EmbedInput.string('Hello!');
        expect(input, isA<EmbedInputString>());
        expect((input as EmbedInputString).value, 'Hello!');
      });

      test('serializes to JSON as string', () {
        const input = EmbedInput.string('Hello!');
        expect(input.toJson(), 'Hello!');
      });

      test('deserializes from string', () {
        final input = EmbedInput.fromJson('Hello!');
        expect(input, isA<EmbedInputString>());
        expect((input as EmbedInputString).value, 'Hello!');
      });

      test('equality works correctly', () {
        const a = EmbedInput.string('Hello!');
        const b = EmbedInput.string('Hello!');
        const c = EmbedInput.string('Bye!');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
        expect(a, isNot(equals(c)));
      });

      test('toString returns readable string', () {
        const input = EmbedInput.string('Hello!');
        expect(input.toString(), 'EmbedInputString(Hello!)');
      });
    });

    group('EmbedInputList', () {
      test('creates list input', () {
        const input = EmbedInput.list(['Hello!', 'World!']);
        expect(input, isA<EmbedInputList>());
        expect((input as EmbedInputList).values, ['Hello!', 'World!']);
      });

      test('serializes to JSON as list', () {
        const input = EmbedInput.list(['a', 'b', 'c']);
        expect(input.toJson(), ['a', 'b', 'c']);
      });

      test('deserializes from list', () {
        final input = EmbedInput.fromJson(const ['Hello', 'World']);
        expect(input, isA<EmbedInputList>());
        expect((input as EmbedInputList).values, ['Hello', 'World']);
      });

      test('equality works correctly', () {
        const a = EmbedInput.list(['Hello', 'World']);
        const b = EmbedInput.list(['Hello', 'World']);
        const c = EmbedInput.list(['Different']);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
        expect(a, isNot(equals(c)));
      });

      test('equality fails for different length lists', () {
        const a = EmbedInput.list(['Hello']);
        const b = EmbedInput.list(['Hello', 'World']);

        expect(a, isNot(equals(b)));
      });

      test('toString returns readable string', () {
        const input = EmbedInput.list(['a', 'b', 'c']);
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
        const string = EmbedInput.string('Hello');
        const list = EmbedInput.list(['Hello']);
        expect(string, isNot(equals(list)));
      });
    });
  });
}
