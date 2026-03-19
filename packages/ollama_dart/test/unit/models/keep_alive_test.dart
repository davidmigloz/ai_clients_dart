import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('KeepAlive', () {
    group('fromJson', () {
      test('parses string as KeepAliveDuration', () {
        final result = KeepAlive.fromJson('5m');
        expect(result, isA<KeepAliveDuration>());
        expect((result! as KeepAliveDuration).value, '5m');
      });

      test('parses int as KeepAliveNumber', () {
        final result = KeepAlive.fromJson(0);
        expect(result, isA<KeepAliveNumber>());
        expect((result! as KeepAliveNumber).value, 0);
      });

      test('parses double as KeepAliveNumber', () {
        final result = KeepAlive.fromJson(3.5);
        expect(result, isA<KeepAliveNumber>());
        expect((result! as KeepAliveNumber).value, 3.5);
      });

      test('returns null for null', () {
        expect(KeepAlive.fromJson(null), isNull);
      });

      test('returns null for unsupported type', () {
        expect(KeepAlive.fromJson(true), isNull);
      });
    });

    group('toJson', () {
      test('KeepAliveDuration serializes to string', () {
        const keepAlive = KeepAliveDuration('5m');
        expect(keepAlive.toJson(), '5m');
      });

      test('KeepAliveNumber serializes to number', () {
        const keepAlive = KeepAliveNumber(0);
        expect(keepAlive.toJson(), 0);
      });

      test('KeepAliveNumber serializes double', () {
        const keepAlive = KeepAliveNumber(3.5);
        expect(keepAlive.toJson(), 3.5);
      });
    });

    group('round-trip', () {
      test('string round-trips correctly', () {
        final original = KeepAlive.fromJson('1h');
        final json = original!.toJson();
        final restored = KeepAlive.fromJson(json);
        expect(restored, original);
      });

      test('int round-trips correctly', () {
        final original = KeepAlive.fromJson(0);
        final json = original!.toJson();
        final restored = KeepAlive.fromJson(json);
        expect(restored, original);
      });

      test('double round-trips correctly', () {
        final original = KeepAlive.fromJson(2.5);
        final json = original!.toJson();
        final restored = KeepAlive.fromJson(json);
        expect(restored, original);
      });
    });

    group('equality', () {
      test('equal KeepAliveDuration instances are equal', () {
        const a = KeepAliveDuration('5m');
        const b = KeepAliveDuration('5m');
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('different KeepAliveDuration instances are not equal', () {
        const a = KeepAliveDuration('5m');
        const b = KeepAliveDuration('10m');
        expect(a, isNot(b));
      });

      test('equal KeepAliveNumber instances are equal', () {
        const a = KeepAliveNumber(0);
        const b = KeepAliveNumber(0);
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('different KeepAliveNumber instances are not equal', () {
        const a = KeepAliveNumber(0);
        const b = KeepAliveNumber(5);
        expect(a, isNot(b));
      });

      test('KeepAliveDuration and KeepAliveNumber are not equal', () {
        const a = KeepAliveDuration('0');
        const b = KeepAliveNumber(0);
        expect(a, isNot(b));
      });
    });

    group('const factory constructors', () {
      test('KeepAlive.duration creates KeepAliveDuration', () {
        const keepAlive = KeepAlive.duration('5m');
        expect(keepAlive, isA<KeepAliveDuration>());
        expect((keepAlive as KeepAliveDuration).value, '5m');
      });

      test('KeepAlive.number creates KeepAliveNumber', () {
        const keepAlive = KeepAlive.number(0);
        expect(keepAlive, isA<KeepAliveNumber>());
        expect((keepAlive as KeepAliveNumber).value, 0);
      });
    });
  });
}
