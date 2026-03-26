import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('VoiceUpdateRequest', () {
    group('constructor', () {
      test('creates with no fields (all optional)', () {
        const request = VoiceUpdateRequest();
        expect(request.name, isNull);
        expect(request.gender, isNull);
        expect(request.age, isNull);
        expect(request.languages, isNull);
        expect(request.tags, isNull);
      });

      test('creates with all fields', () {
        const request = VoiceUpdateRequest(
          name: 'Updated Voice',
          gender: 'female',
          age: 30,
          languages: ['en', 'fr', 'de'],
          tags: ['premium', 'verified'],
        );
        expect(request.name, 'Updated Voice');
        expect(request.gender, 'female');
        expect(request.age, 30);
        expect(request.languages, ['en', 'fr', 'de']);
        expect(request.tags, ['premium', 'verified']);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'name': 'JSON Voice',
          'gender': 'male',
          'age': 45,
          'languages': ['es', 'pt'],
          'tags': ['custom'],
        };
        final request = VoiceUpdateRequest.fromJson(json);
        expect(request.name, 'JSON Voice');
        expect(request.gender, 'male');
        expect(request.age, 45);
        expect(request.languages, ['es', 'pt']);
        expect(request.tags, ['custom']);
      });

      test('deserializes empty JSON', () {
        final request = VoiceUpdateRequest.fromJson(const <String, dynamic>{});
        expect(request.name, isNull);
        expect(request.gender, isNull);
        expect(request.age, isNull);
        expect(request.languages, isNull);
        expect(request.tags, isNull);
      });
    });

    group('toJson', () {
      test('produces correct keys when all fields set', () {
        const request = VoiceUpdateRequest(
          name: 'Full Update',
          gender: 'female',
          age: 28,
          languages: ['en'],
          tags: ['tag1', 'tag2'],
        );
        final json = request.toJson();
        expect(json['name'], 'Full Update');
        expect(json['gender'], 'female');
        expect(json['age'], 28);
        expect(json['languages'], ['en']);
        expect(json['tags'], ['tag1', 'tag2']);
      });

      test('omits null fields', () {
        const request = VoiceUpdateRequest(name: 'Only Name');
        final json = request.toJson();
        expect(json['name'], 'Only Name');
        expect(json.containsKey('gender'), isFalse);
        expect(json.containsKey('age'), isFalse);
        expect(json.containsKey('languages'), isFalse);
        expect(json.containsKey('tags'), isFalse);
      });

      test('produces empty map when all fields are null', () {
        const request = VoiceUpdateRequest();
        final json = request.toJson();
        expect(json, isEmpty);
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        const original = VoiceUpdateRequest(
          name: 'RoundTrip',
          gender: 'male',
          age: 50,
          languages: ['en', 'zh', 'ar'],
          tags: ['rt-tag'],
        );
        final json = original.toJson();
        final restored = VoiceUpdateRequest.fromJson(json);
        expect(restored, equals(original));
      });

      test('preserves empty request through round-trip', () {
        const original = VoiceUpdateRequest();
        final json = original.toJson();
        final restored = VoiceUpdateRequest.fromJson(json);
        expect(restored, equals(original));
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        const original = VoiceUpdateRequest(
          name: 'Original',
          gender: 'male',
          age: 25,
        );
        final updated = original.copyWith(name: 'New Name', age: 30);
        expect(updated.name, 'New Name');
        expect(updated.gender, 'male');
        expect(updated.age, 30);
        expect(updated.languages, isNull);
        expect(updated.tags, isNull);
      });

      test('copies adding new fields', () {
        const original = VoiceUpdateRequest(name: 'Base');
        final updated = original.copyWith(
          gender: 'female',
          languages: ['en', 'fr'],
          tags: ['new-tag'],
        );
        expect(updated.name, 'Base');
        expect(updated.gender, 'female');
        expect(updated.languages, ['en', 'fr']);
        expect(updated.tags, ['new-tag']);
      });

      test('sets fields to null using sentinel pattern', () {
        const original = VoiceUpdateRequest(
          name: 'Has Name',
          gender: 'male',
          age: 40,
          languages: ['en'],
          tags: ['tag'],
        );
        final updated = original.copyWith(
          name: null,
          gender: null,
          age: null,
          languages: null,
          tags: null,
        );
        expect(updated.name, isNull);
        expect(updated.gender, isNull);
        expect(updated.age, isNull);
        expect(updated.languages, isNull);
        expect(updated.tags, isNull);
      });

      test('preserves fields when not specified', () {
        const original = VoiceUpdateRequest(
          name: 'Keep',
          gender: 'female',
          age: 33,
          languages: ['ja'],
          tags: ['preserve'],
        );
        final updated = original.copyWith();
        expect(updated, equals(original));
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        const request1 = VoiceUpdateRequest(
          name: 'Same',
          gender: 'male',
          age: 20,
          languages: ['en'],
          tags: ['t1'],
        );
        const request2 = VoiceUpdateRequest(
          name: 'Same',
          gender: 'male',
          age: 20,
          languages: ['en'],
          tags: ['t1'],
        );
        expect(request1, equals(request2));
        expect(request1.hashCode, request2.hashCode);
      });

      test('equal when both empty', () {
        const request1 = VoiceUpdateRequest();
        const request2 = VoiceUpdateRequest();
        expect(request1, equals(request2));
        expect(request1.hashCode, request2.hashCode);
      });

      test('not equal when fields differ', () {
        const request1 = VoiceUpdateRequest(name: 'A', age: 20);
        const request2 = VoiceUpdateRequest(name: 'B', age: 25);
        expect(request1, isNot(equals(request2)));
      });
    });
  });
}
