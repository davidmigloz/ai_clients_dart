import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CustomToolInputSchema (open object)', () {
    test('captures undeclared keys in extra and re-emits them', () {
      final input = {
        'type': 'object',
        'properties': {
          'x': {'type': 'string'},
        },
        'required': ['x'],
        'title': 'My schema',
        'additionalProperties': false,
      };
      final schema = CustomToolInputSchema.fromJson(input);
      expect(schema.extra, {
        'title': 'My schema',
        'additionalProperties': false,
      });

      final json = schema.toJson();
      expect(json['title'], 'My schema');
      expect(json['additionalProperties'], false);
      // Round-trips with no key loss.
      expect(CustomToolInputSchema.fromJson(json), schema);
    });

    test('extra never emits a declared key when its typed field is null', () {
      // A declared key smuggled into `extra` must not leak when the typed
      // field is absent — `extra` is for undeclared keys only.
      const schema = CustomToolInputSchema(
        extra: {
          'required': ['leaked'],
          'keep': 1,
        },
      );
      final json = schema.toJson();
      expect(json.containsKey('required'), isFalse);
      expect(json['keep'], 1);
    });
  });
}
