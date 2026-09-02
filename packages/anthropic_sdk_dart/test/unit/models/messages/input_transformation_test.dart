import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InputTransformationReason', () {
    test('fromJson parses known reasons', () {
      expect(
        InputTransformationReason.fromJson('model_binding_mismatch'),
        InputTransformationReason.modelBindingMismatch,
      );
      expect(
        InputTransformationReason.fromJson('prefix_binding_mismatch'),
        InputTransformationReason.prefixBindingMismatch,
      );
      expect(
        InputTransformationReason.fromJson('organization_binding_mismatch'),
        InputTransformationReason.organizationBindingMismatch,
      );
      expect(
        InputTransformationReason.fromJson('end_user_binding_mismatch'),
        InputTransformationReason.endUserBindingMismatch,
      );
    });

    test('fromJson falls back to unknown for unrecognized values', () {
      expect(
        InputTransformationReason.fromJson('some_new_reason'),
        InputTransformationReason.unknown,
      );
    });

    test('toJson serializes the wire value', () {
      expect(
        InputTransformationReason.modelBindingMismatch.toJson(),
        'model_binding_mismatch',
      );
      expect(InputTransformationReason.unknown.toJson(), 'unknown');
    });
  });

  group('InputTransformation.fromJson', () {
    test('dispatches thinking_dropped', () {
      final transformation = InputTransformation.fromJson({
        'type': 'thinking_dropped',
        'path': 'messages.0.content.1',
        'reason': 'prefix_binding_mismatch',
      });

      expect(transformation, isA<ThinkingDroppedInputTransformation>());
    });

    test('falls back to UnknownInputTransformation for unrecognized types', () {
      final transformation = InputTransformation.fromJson({
        'type': 'something_new',
        'extra': 'data',
      });

      expect(transformation, isA<UnknownInputTransformation>());
      expect(
        (transformation as UnknownInputTransformation).type,
        'something_new',
      );
    });
  });

  group('ThinkingDroppedInputTransformation', () {
    test('fromJson parses required fields', () {
      final transformation = ThinkingDroppedInputTransformation.fromJson(const {
        'type': 'thinking_dropped',
        'path': 'messages.2.content.0',
        'reason': 'model_binding_mismatch',
      });

      expect(transformation.path, 'messages.2.content.0');
      expect(
        transformation.reason,
        InputTransformationReason.modelBindingMismatch,
      );
    });

    test('fromJson throws FormatException when path is missing', () {
      expect(
        () => ThinkingDroppedInputTransformation.fromJson(const {
          'type': 'thinking_dropped',
          'reason': 'model_binding_mismatch',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromJson throws FormatException when reason is missing', () {
      expect(
        () => ThinkingDroppedInputTransformation.fromJson(const {
          'type': 'thinking_dropped',
          'path': 'messages.0.content.0',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson round-trips', () {
      const transformation = ThinkingDroppedInputTransformation(
        path: 'messages.0.content.0',
        reason: InputTransformationReason.organizationBindingMismatch,
      );

      final json = transformation.toJson();

      expect(json, {
        'type': 'thinking_dropped',
        'path': 'messages.0.content.0',
        'reason': 'organization_binding_mismatch',
      });
      expect(ThinkingDroppedInputTransformation.fromJson(json), transformation);
    });

    test('copyWith creates modified copy', () {
      const original = ThinkingDroppedInputTransformation(
        path: 'messages.0.content.0',
        reason: InputTransformationReason.modelBindingMismatch,
      );

      final modified = original.copyWith(
        reason: InputTransformationReason.endUserBindingMismatch,
      );

      expect(modified.path, original.path);
      expect(modified.reason, InputTransformationReason.endUserBindingMismatch);
    });

    test('equality and hashCode', () {
      const t1 = ThinkingDroppedInputTransformation(
        path: 'messages.0.content.0',
        reason: InputTransformationReason.modelBindingMismatch,
      );
      const t2 = ThinkingDroppedInputTransformation(
        path: 'messages.0.content.0',
        reason: InputTransformationReason.modelBindingMismatch,
      );
      const t3 = ThinkingDroppedInputTransformation(
        path: 'messages.1.content.0',
        reason: InputTransformationReason.modelBindingMismatch,
      );

      expect(t1, equals(t2));
      expect(t1.hashCode, t2.hashCode);
      expect(t1, isNot(equals(t3)));
    });

    test('toString includes path and reason', () {
      const transformation = ThinkingDroppedInputTransformation(
        path: 'messages.0.content.0',
        reason: InputTransformationReason.modelBindingMismatch,
      );

      expect(transformation.toString(), contains('messages.0.content.0'));
      expect(transformation.toString(), contains('modelBindingMismatch'));
    });
  });

  group('UnknownInputTransformation', () {
    test('preserves raw JSON', () {
      final raw = {'type': 'future_transformation', 'foo': 'bar'};

      final transformation = UnknownInputTransformation.fromJson(raw);

      expect(transformation.type, 'future_transformation');
      expect(transformation.toJson(), raw);
    });

    test('raw map is deeply unmodifiable', () {
      final raw = {
        'type': 'future_transformation',
        'nested': {'a': 1},
      };
      final transformation = UnknownInputTransformation.fromJson(raw);

      expect(
        () => (transformation.raw['nested'] as Map)['a'] = 2,
        throwsUnsupportedError,
      );
    });

    test('equality uses deep map comparison', () {
      final t1 = UnknownInputTransformation.fromJson(const {
        'type': 'x',
        'nested': {'a': 1},
      });
      final t2 = UnknownInputTransformation.fromJson(const {
        'type': 'x',
        'nested': {'a': 1},
      });
      final t3 = UnknownInputTransformation.fromJson(const {
        'type': 'x',
        'nested': {'a': 2},
      });

      expect(t1, equals(t2));
      expect(t1.hashCode, t2.hashCode);
      expect(t1, isNot(equals(t3)));
    });

    test('type getter falls back when missing', () {
      final transformation = UnknownInputTransformation.fromJson(const {
        'foo': 'bar',
      });

      expect(transformation.type, 'unknown');
    });
  });
}
