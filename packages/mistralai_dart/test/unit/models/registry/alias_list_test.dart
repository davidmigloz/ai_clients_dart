import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AliasList', () {
    group('fromJson', () {
      test('parses values', () {
        final aliases = AliasList.fromJson(const {
          'values': ['prod', 'latest'],
        });

        expect(aliases.values, ['prod', 'latest']);
      });

      test('parses empty values (explicit clear)', () {
        final aliases = AliasList.fromJson(const {'values': <String>[]});

        expect(aliases.values, isEmpty);
      });

      test('parses missing values as null (unchanged)', () {
        final aliases = AliasList.fromJson(const {});

        expect(aliases.values, isNull);
      });
    });

    group('toJson', () {
      test('serializes values', () {
        const aliases = AliasList(values: ['a', 'b']);

        expect(aliases.toJson(), {
          'values': ['a', 'b'],
        });
      });

      test('omits values when null', () {
        const aliases = AliasList();

        expect(aliases.toJson(), <String, dynamic>{});
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        const original = AliasList(values: ['x', 'y']);

        final roundTripped = AliasList.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces values', () {
        const original = AliasList(values: ['a']);

        final copy = original.copyWith(values: ['b']);

        expect(copy.values, ['b']);
      });

      test('clears values when null is passed explicitly', () {
        const original = AliasList(values: ['a']);

        final copy = original.copyWith(values: null);

        expect(copy.values, isNull);
      });

      test('preserves values when not specified', () {
        const original = AliasList(values: ['a']);

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when values match', () {
        const a = AliasList(values: ['a', 'b']);
        const b = AliasList(values: ['a', 'b']);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when values differ', () {
        const a = AliasList(values: ['a']);
        const b = AliasList(values: ['b']);

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes values', () {
      const aliases = AliasList(values: ['a']);

      expect(aliases.toString(), contains('AliasList'));
      expect(aliases.toString(), contains('[a]'));
    });
  });
}
