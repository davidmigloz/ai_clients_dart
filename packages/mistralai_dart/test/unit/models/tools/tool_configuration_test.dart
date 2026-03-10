import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ToolConfiguration', () {
    group('constructor', () {
      test('creates with no parameters', () {
        const config = ToolConfiguration();
        expect(config.exclude, isNull);
        expect(config.include, isNull);
        expect(config.requiresConfirmation, isNull);
      });

      test('creates with all parameters', () {
        const config = ToolConfiguration(
          exclude: ['func_a'],
          include: ['func_b', 'func_c'],
          requiresConfirmation: ['func_d'],
        );
        expect(config.exclude, ['func_a']);
        expect(config.include, ['func_b', 'func_c']);
        expect(config.requiresConfirmation, ['func_d']);
      });
    });

    group('toJson', () {
      test('serializes empty config to empty map', () {
        const config = ToolConfiguration();
        final json = config.toJson();
        expect(json, isEmpty);
        expect(json.containsKey('exclude'), isFalse);
        expect(json.containsKey('include'), isFalse);
        expect(json.containsKey('requires_confirmation'), isFalse);
      });

      test('serializes all fields', () {
        const config = ToolConfiguration(
          exclude: ['func_a'],
          include: ['func_b'],
          requiresConfirmation: ['func_c'],
        );
        final json = config.toJson();
        expect(json['exclude'], ['func_a']);
        expect(json['include'], ['func_b']);
        expect(json['requires_confirmation'], ['func_c']);
      });

      test('omits null fields', () {
        const config = ToolConfiguration(include: ['func_b']);
        final json = config.toJson();
        expect(json.containsKey('exclude'), isFalse);
        expect(json['include'], ['func_b']);
        expect(json.containsKey('requires_confirmation'), isFalse);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'exclude': ['func_a'],
          'include': ['func_b', 'func_c'],
          'requires_confirmation': ['func_d'],
        };
        final config = ToolConfiguration.fromJson(json);
        expect(config.exclude, ['func_a']);
        expect(config.include, ['func_b', 'func_c']);
        expect(config.requiresConfirmation, ['func_d']);
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{};
        final config = ToolConfiguration.fromJson(json);
        expect(config.exclude, isNull);
        expect(config.include, isNull);
        expect(config.requiresConfirmation, isNull);
      });

      test('handles partial fields', () {
        final json = <String, dynamic>{
          'include': ['func_b'],
        };
        final config = ToolConfiguration.fromJson(json);
        expect(config.exclude, isNull);
        expect(config.include, ['func_b']);
        expect(config.requiresConfirmation, isNull);
      });
    });

    group('equality', () {
      test('equals with same values', () {
        const config1 = ToolConfiguration(
          exclude: ['a'],
          include: ['b'],
          requiresConfirmation: ['c'],
        );
        const config2 = ToolConfiguration(
          exclude: ['a'],
          include: ['b'],
          requiresConfirmation: ['c'],
        );
        expect(config1, equals(config2));
        expect(config1.hashCode, equals(config2.hashCode));
      });

      test('not equals with different values', () {
        const config1 = ToolConfiguration(include: ['a']);
        const config2 = ToolConfiguration(include: ['b']);
        expect(config1, isNot(equals(config2)));
      });

      test('equals when both have no fields', () {
        const config1 = ToolConfiguration();
        const config2 = ToolConfiguration();
        expect(config1, equals(config2));
        expect(config1.hashCode, equals(config2.hashCode));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const config = ToolConfiguration(
          exclude: ['a'],
          include: ['b'],
          requiresConfirmation: ['c'],
        );
        final str = config.toString();
        expect(str, contains('ToolConfiguration'));
        expect(str, contains('exclude'));
        expect(str, contains('include'));
        expect(str, contains('requiresConfirmation'));
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        const original = ToolConfiguration(
          exclude: ['func_a', 'func_b'],
          include: ['func_c'],
          requiresConfirmation: ['func_d', 'func_e'],
        );
        final json = original.toJson();
        final restored = ToolConfiguration.fromJson(json);
        expect(restored, equals(original));
      });

      test('preserves empty config through JSON round-trip', () {
        const original = ToolConfiguration();
        final json = original.toJson();
        final restored = ToolConfiguration.fromJson(json);
        expect(restored, equals(original));
      });
    });
  });
}
