import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('BatchRequest', () {
    group('constructor', () {
      test('creates with required fields only', () {
        const request = BatchRequest(
          body: {'model': 'mistral-large-latest', 'prompt': 'Hello'},
        );
        expect(request.body, {
          'model': 'mistral-large-latest',
          'prompt': 'Hello',
        });
        expect(request.customId, isNull);
      });

      test('creates with all fields', () {
        const request = BatchRequest(
          body: {'model': 'mistral-large-latest'},
          customId: 'req-001',
        );
        expect(request.body, {'model': 'mistral-large-latest'});
        expect(request.customId, 'req-001');
      });
    });

    group('toJson', () {
      test('serializes required fields only', () {
        const request = BatchRequest(body: {'model': 'mistral-large-latest'});
        final json = request.toJson();
        expect(json['body'], {'model': 'mistral-large-latest'});
        expect(json.containsKey('custom_id'), isFalse);
      });

      test('serializes all fields', () {
        const request = BatchRequest(
          body: {'model': 'mistral-large-latest'},
          customId: 'req-001',
        );
        final json = request.toJson();
        expect(json['body'], {'model': 'mistral-large-latest'});
        expect(json['custom_id'], 'req-001');
      });

      test('omits null customId', () {
        const request = BatchRequest(body: {'key': 'value'});
        final json = request.toJson();
        expect(json.containsKey('custom_id'), isFalse);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'body': {'model': 'mistral-large-latest', 'prompt': 'Hi'},
          'custom_id': 'req-001',
        };
        final request = BatchRequest.fromJson(json);
        expect(request.body['model'], 'mistral-large-latest');
        expect(request.body['prompt'], 'Hi');
        expect(request.customId, 'req-001');
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{
          'body': {'model': 'mistral-large-latest'},
        };
        final request = BatchRequest.fromJson(json);
        expect(request.body, {'model': 'mistral-large-latest'});
        expect(request.customId, isNull);
      });

      test('handles missing body with default empty map', () {
        final json = <String, dynamic>{};
        final request = BatchRequest.fromJson(json);
        expect(request.body, isEmpty);
        expect(request.customId, isNull);
      });
    });

    group('equality', () {
      test('equals with same customId and body', () {
        const r1 = BatchRequest(body: {'a': 1}, customId: 'req-001');
        const r2 = BatchRequest(body: {'a': 1}, customId: 'req-001');
        expect(r1, equals(r2));
        expect(r1.hashCode, equals(r2.hashCode));
      });

      test('not equals with different customId', () {
        const r1 = BatchRequest(body: {'a': 1}, customId: 'req-001');
        const r2 = BatchRequest(body: {'a': 1}, customId: 'req-002');
        expect(r1, isNot(equals(r2)));
      });

      test('not equals with different body', () {
        const r1 = BatchRequest(body: {'a': 1}, customId: 'req-001');
        const r2 = BatchRequest(body: {'b': 2}, customId: 'req-001');
        expect(r1, isNot(equals(r2)));
      });

      test('equals with both null customId and same body', () {
        const r1 = BatchRequest(body: {'a': 1});
        const r2 = BatchRequest(body: {'a': 1});
        expect(r1, equals(r2));
        expect(r1.hashCode, equals(r2.hashCode));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const request = BatchRequest(
          body: {'model': 'mistral-large-latest'},
          customId: 'req-001',
        );
        final str = request.toString();
        expect(str, contains('BatchRequest'));
        expect(str, contains('req-001'));
      });

      test('returns descriptive string without customId', () {
        const request = BatchRequest(body: {'model': 'test'});
        final str = request.toString();
        expect(str, contains('BatchRequest'));
        expect(str, contains('null'));
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        const original = BatchRequest(
          body: {
            'model': 'mistral-large-latest',
            'messages': [
              {'role': 'user', 'content': 'Hello'},
            ],
          },
          customId: 'req-roundtrip',
        );
        final json = original.toJson();
        final restored = BatchRequest.fromJson(json);
        expect(restored.body, original.body);
        expect(restored.customId, original.customId);
        expect(restored, equals(original));
      });

      test('preserves required-only data through JSON round-trip', () {
        const original = BatchRequest(body: {'key': 'value'});
        final json = original.toJson();
        final restored = BatchRequest.fromJson(json);
        expect(restored.body, original.body);
        expect(restored.customId, isNull);
      });
    });
  });
}
