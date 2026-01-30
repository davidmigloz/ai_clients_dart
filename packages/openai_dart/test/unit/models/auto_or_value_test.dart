import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AutoOrInt', () {
    test('auto() creates auto value', () {
      const value = AutoOrInt.auto();
      expect(value, isA<AutoOrIntAuto>());
      expect(value.isAuto, isTrue);
      expect(value.valueOrNull, isNull);
    });

    test('value() creates specific value', () {
      const value = AutoOrInt.value(5);
      expect(value, isA<AutoOrIntValue>());
      expect(value.isAuto, isFalse);
      expect(value.valueOrNull, 5);
    });

    test('fromJson parses "auto"', () {
      final value = AutoOrInt.fromJson('auto');
      expect(value, isA<AutoOrIntAuto>());
      expect(value.toJson(), 'auto');
    });

    test('fromJson parses int', () {
      final value = AutoOrInt.fromJson(10);
      expect(value, isA<AutoOrIntValue>());
      expect(value.toJson(), 10);
    });

    test('fromJson throws on invalid value', () {
      expect(() => AutoOrInt.fromJson('invalid'), throwsFormatException);
      expect(() => AutoOrInt.fromJson(1.5), throwsFormatException);
    });

    test('equality works correctly', () {
      expect(const AutoOrIntAuto(), equals(const AutoOrIntAuto()));
      expect(const AutoOrIntValue(5), equals(const AutoOrIntValue(5)));
      expect(const AutoOrIntValue(5), isNot(equals(const AutoOrIntValue(10))));
      expect(const AutoOrIntAuto(), isNot(equals(const AutoOrIntValue(5))));
    });

    test('toString returns readable string', () {
      expect(const AutoOrIntAuto().toString(), 'AutoOrInt.auto()');
      expect(const AutoOrIntValue(5).toString(), 'AutoOrInt.value(5)');
    });
  });

  group('AutoOrDouble', () {
    test('auto() creates auto value', () {
      const value = AutoOrDouble.auto();
      expect(value, isA<AutoOrDoubleAuto>());
      expect(value.isAuto, isTrue);
      expect(value.valueOrNull, isNull);
    });

    test('value() creates specific value', () {
      const value = AutoOrDouble.value(0.1);
      expect(value, isA<AutoOrDoubleValue>());
      expect(value.isAuto, isFalse);
      expect(value.valueOrNull, 0.1);
    });

    test('fromJson parses "auto"', () {
      final value = AutoOrDouble.fromJson('auto');
      expect(value, isA<AutoOrDoubleAuto>());
      expect(value.toJson(), 'auto');
    });

    test('fromJson parses double', () {
      final value = AutoOrDouble.fromJson(0.5);
      expect(value, isA<AutoOrDoubleValue>());
      expect(value.toJson(), 0.5);
    });

    test('fromJson parses int as double', () {
      final value = AutoOrDouble.fromJson(1);
      expect(value, isA<AutoOrDoubleValue>());
      expect(value.toJson(), 1.0);
    });

    test('fromJson throws on invalid value', () {
      expect(() => AutoOrDouble.fromJson('invalid'), throwsFormatException);
    });

    test('equality works correctly', () {
      expect(const AutoOrDoubleAuto(), equals(const AutoOrDoubleAuto()));
      expect(
        const AutoOrDoubleValue(0.5),
        equals(const AutoOrDoubleValue(0.5)),
      );
    });
  });

  group('InfOrInt', () {
    test('inf() creates infinity value', () {
      const value = InfOrInt.inf();
      expect(value, isA<InfOrIntInf>());
      expect(value.isInf, isTrue);
      expect(value.valueOrNull, isNull);
    });

    test('value() creates specific value', () {
      const value = InfOrInt.value(4096);
      expect(value, isA<InfOrIntValue>());
      expect(value.isInf, isFalse);
      expect(value.valueOrNull, 4096);
    });

    test('fromJson parses "inf"', () {
      final value = InfOrInt.fromJson('inf');
      expect(value, isA<InfOrIntInf>());
      expect(value.toJson(), 'inf');
    });

    test('fromJson parses int', () {
      final value = InfOrInt.fromJson(1024);
      expect(value, isA<InfOrIntValue>());
      expect(value.toJson(), 1024);
    });

    test('fromJson throws on invalid value', () {
      expect(() => InfOrInt.fromJson('invalid'), throwsFormatException);
      expect(() => InfOrInt.fromJson(1.5), throwsFormatException);
    });

    test('equality works correctly', () {
      expect(const InfOrIntInf(), equals(const InfOrIntInf()));
      expect(const InfOrIntValue(100), equals(const InfOrIntValue(100)));
      expect(const InfOrIntValue(100), isNot(equals(const InfOrIntValue(200))));
    });

    test('toString returns readable string', () {
      expect(const InfOrIntInf().toString(), 'InfOrInt.inf()');
      expect(const InfOrIntValue(4096).toString(), 'InfOrInt.value(4096)');
    });
  });
}
