import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InputSchema', () {
    group('construction', () {
      test('defaults to object type with null fields', () {
        const schema = InputSchema();
        expect(schema.type, 'object');
        expect(schema.properties, isNull);
        expect(schema.required, isNull);
        expect(schema.extra, isNull);
      });

      test('accepts extra field', () {
        const schema = InputSchema(extra: {'additionalProperties': false});
        expect(schema.extra, {'additionalProperties': false});
      });

      test('const construction with extra works', () {
        const schema = InputSchema(
          properties: {
            'x': {'type': 'string'},
          },
          required: ['x'],
          extra: {'additionalProperties': false},
        );
        expect(schema.extra, {'additionalProperties': false});
      });
    });

    group('fromJson', () {
      test('collects unknown keys into extra', () {
        final json = {
          'type': 'object',
          'properties': {
            'x': {'type': 'string'},
          },
          'required': ['x'],
          'additionalProperties': false,
          'description': 'A schema',
        };

        final schema = InputSchema.fromJson(json);

        expect(schema.type, 'object');
        expect(schema.properties, {
          'x': {'type': 'string'},
        });
        expect(schema.required, ['x']);
        expect(schema.extra, {
          'additionalProperties': false,
          'description': 'A schema',
        });
      });

      test('returns null extra when only known keys present', () {
        final json = {
          'type': 'object',
          'properties': {
            'x': {'type': 'string'},
          },
          'required': ['x'],
        };

        final schema = InputSchema.fromJson(json);

        expect(schema.extra, isNull);
      });

      test('handles complex nested extra', () {
        final json = {
          'type': 'object',
          'properties': {
            'x': {'type': 'string'},
          },
          'anyOf': [
            {'type': 'string'},
            {'type': 'integer'},
          ],
          r'$defs': {
            'Foo': {
              'type': 'object',
              'properties': {
                'bar': {'type': 'string'},
              },
            },
          },
        };

        final schema = InputSchema.fromJson(json);

        expect(schema.extra, {
          'anyOf': [
            {'type': 'string'},
            {'type': 'integer'},
          ],
          r'$defs': {
            'Foo': {
              'type': 'object',
              'properties': {
                'bar': {'type': 'string'},
              },
            },
          },
        });
      });
    });

    group('toJson', () {
      test('includes extra fields as top-level keys', () {
        const schema = InputSchema(
          properties: {
            'x': {'type': 'string'},
          },
          required: ['x'],
          extra: {'additionalProperties': false, 'description': 'Test'},
        );

        final json = schema.toJson();

        expect(json['type'], 'object');
        expect(json['properties'], {
          'x': {'type': 'string'},
        });
        expect(json['required'], ['x']);
        expect(json['additionalProperties'], false);
        expect(json['description'], 'Test');
        // extra should NOT appear as a nested key
        expect(json.containsKey('extra'), isFalse);
      });

      test('produces no extra keys when extra is null', () {
        const schema = InputSchema(
          properties: {
            'x': {'type': 'string'},
          },
        );

        final json = schema.toJson();

        expect(json.keys, containsAll(['type', 'properties']));
        expect(json.containsKey('extra'), isFalse);
        expect(json.containsKey('additionalProperties'), isFalse);
      });

      test('known keys win on collision with extra', () {
        const schema = InputSchema(
          type: 'object',
          extra: {'type': 'array'}, // should be overwritten
        );

        final json = schema.toJson();

        expect(json['type'], 'object');
      });
    });

    group('round-trip', () {
      test('fromJson -> toJson preserves all keys', () {
        final original = {
          'type': 'object',
          'properties': {
            'x': {'type': 'string'},
          },
          'required': ['x'],
          'additionalProperties': false,
          'description': 'A schema',
        };

        final schema = InputSchema.fromJson(original);
        final roundTripped = schema.toJson();

        expect(roundTripped, original);
      });

      test('round-trips complex nested structures', () {
        final original = {
          'type': 'object',
          'properties': {
            'value': {'type': 'string'},
          },
          'anyOf': [
            {'type': 'string'},
            {'type': 'integer'},
          ],
        };

        final schema = InputSchema.fromJson(original);
        final roundTripped = schema.toJson();

        expect(roundTripped, original);
      });
    });

    group('copyWith', () {
      test('sets extra', () {
        const original = InputSchema();
        final copy = original.copyWith(extra: {'additionalProperties': false});
        expect(copy.extra, {'additionalProperties': false});
      });

      test('clears extra to null', () {
        const original = InputSchema(extra: {'additionalProperties': false});
        final copy = original.copyWith(extra: null);
        expect(copy.extra, isNull);
      });

      test('preserves extra when not specified', () {
        const original = InputSchema(extra: {'additionalProperties': false});
        final copy = original.copyWith(type: 'object');
        expect(copy.extra, {'additionalProperties': false});
      });
    });

    group('equality', () {
      test('schemas with same extra are equal', () {
        const a = InputSchema(extra: {'additionalProperties': false});
        const b = InputSchema(extra: {'additionalProperties': false});
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('schemas with different extra are not equal', () {
        const a = InputSchema(extra: {'additionalProperties': false});
        const b = InputSchema(extra: {'additionalProperties': true});
        expect(a, isNot(equals(b)));
      });

      test('schema with null extra differs from empty map extra', () {
        const a = InputSchema();
        const b = InputSchema(extra: {});
        // This is a known edge case: null != {}
        expect(a.extra, isNull);
        expect(b.extra, isNotNull);
      });

      test('deep nested extra equality works', () {
        const a = InputSchema(
          extra: {
            'anyOf': [
              {'type': 'string'},
              {'type': 'integer'},
            ],
          },
        );
        const b = InputSchema(
          extra: {
            'anyOf': [
              {'type': 'string'},
              {'type': 'integer'},
            ],
          },
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('toString', () {
      test('includes extra entry count', () {
        const schema = InputSchema(extra: {'additionalProperties': false});
        final str = schema.toString();
        expect(str, contains('extra: 1 entries'));
      });

      test('shows null for missing extra', () {
        const schema = InputSchema();
        final str = schema.toString();
        expect(str, contains('extra: null'));
      });
    });
  });
}
