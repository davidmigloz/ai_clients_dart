import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('StopSequence', () {
    group('fromJson', () {
      test('parses string as StopString', () {
        final result = StopSequence.fromJson('\n');
        expect(result, isA<StopString>());
        expect((result! as StopString).value, '\n');
      });

      test('parses list as StopList', () {
        final result = StopSequence.fromJson(['\n', 'END']);
        expect(result, isA<StopList>());
        expect((result! as StopList).values, ['\n', 'END']);
      });

      test('parses empty list as StopList', () {
        final result = StopSequence.fromJson(<dynamic>[]);
        expect(result, isA<StopList>());
        expect((result! as StopList).values, isEmpty);
      });

      test('returns null for null', () {
        expect(StopSequence.fromJson(null), isNull);
      });

      test('returns null for unsupported type', () {
        expect(StopSequence.fromJson(42), isNull);
      });
    });

    group('toJson', () {
      test('StopString serializes to string', () {
        const stop = StopString('\n');
        expect(stop.toJson(), '\n');
      });

      test('StopList serializes to list', () {
        const stop = StopList(['\n', 'END']);
        expect(stop.toJson(), ['\n', 'END']);
      });
    });

    group('round-trip', () {
      test('string round-trips correctly', () {
        final original = StopSequence.fromJson('STOP');
        final json = original!.toJson();
        final restored = StopSequence.fromJson(json);
        expect(restored, original);
      });

      test('list round-trips correctly', () {
        final original = StopSequence.fromJson(['STOP', 'END']);
        final json = original!.toJson();
        final restored = StopSequence.fromJson(json);
        expect(restored, original);
      });
    });

    group('equality', () {
      test('equal StopString instances are equal', () {
        const a = StopString('\n');
        const b = StopString('\n');
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('different StopString instances are not equal', () {
        const a = StopString('\n');
        const b = StopString('END');
        expect(a, isNot(b));
      });

      test('equal StopList instances are equal', () {
        const a = StopList(['\n', 'END']);
        const b = StopList(['\n', 'END']);
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('different StopList instances are not equal', () {
        const a = StopList(['\n']);
        const b = StopList(['\n', 'END']);
        expect(a, isNot(b));
      });

      test('StopString and StopList are not equal', () {
        const a = StopString('\n');
        const b = StopList(['\n']);
        expect(a, isNot(b));
      });
    });

    group('const factory constructors', () {
      test('StopSequence.string creates StopString', () {
        const stop = StopSequence.string('\n');
        expect(stop, isA<StopString>());
        expect((stop as StopString).value, '\n');
      });

      test('StopSequence.list creates StopList', () {
        const stop = StopSequence.list(['\n', 'END']);
        expect(stop, isA<StopList>());
        expect((stop as StopList).values, ['\n', 'END']);
      });
    });
  });
}
