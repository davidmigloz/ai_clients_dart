import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('VoiceResponse', () {
    group('constructor', () {
      test('creates with required fields', () {
        final response = VoiceResponse(
          id: 'voice-1',
          name: 'Aria',
          createdAt: DateTime.utc(2024, 1, 15),
        );
        expect(response.id, 'voice-1');
        expect(response.name, 'Aria');
        expect(response.createdAt, DateTime.utc(2024, 1, 15));
        expect(response.userId, isNull);
        expect(response.slug, isNull);
        expect(response.gender, isNull);
        expect(response.age, isNull);
        expect(response.color, isNull);
        expect(response.languages, isEmpty);
        expect(response.tags, isNull);
        expect(response.retentionNotice, 30);
      });

      test('creates with all fields', () {
        final response = VoiceResponse(
          id: 'voice-2',
          name: 'Zephyr',
          createdAt: DateTime.utc(2024, 6, 1),
          userId: 'user-abc',
          slug: 'zephyr-v1',
          gender: 'male',
          age: 25,
          color: '#FF5733',
          languages: const ['en', 'fr'],
          tags: const ['custom', 'premium'],
          retentionNotice: 60,
        );
        expect(response.id, 'voice-2');
        expect(response.name, 'Zephyr');
        expect(response.createdAt, DateTime.utc(2024, 6, 1));
        expect(response.userId, 'user-abc');
        expect(response.slug, 'zephyr-v1');
        expect(response.gender, 'male');
        expect(response.age, 25);
        expect(response.color, '#FF5733');
        expect(response.languages, ['en', 'fr']);
        expect(response.tags, ['custom', 'premium']);
        expect(response.retentionNotice, 60);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'id': 'voice-3',
          'name': 'Luna',
          'created_at': '2024-01-15T00:00:00.000Z',
          'user_id': 'user-xyz',
          'slug': 'luna-v2',
          'gender': 'female',
          'age': 25,
          'color': '#00BFFF',
          'languages': ['en', 'fr'],
          'tags': ['custom'],
          'retention_notice': 30,
        };
        final response = VoiceResponse.fromJson(json);
        expect(response.id, 'voice-3');
        expect(response.name, 'Luna');
        expect(response.createdAt, DateTime.utc(2024, 1, 15));
        expect(response.userId, 'user-xyz');
        expect(response.slug, 'luna-v2');
        expect(response.gender, 'female');
        expect(response.age, 25);
        expect(response.color, '#00BFFF');
        expect(response.languages, ['en', 'fr']);
        expect(response.tags, ['custom']);
        expect(response.retentionNotice, 30);
      });

      test('deserializes required fields only with defaults', () {
        final json = <String, dynamic>{
          'id': 'voice-4',
          'name': 'Echo',
          'created_at': '2024-03-20T12:00:00.000Z',
        };
        final response = VoiceResponse.fromJson(json);
        expect(response.id, 'voice-4');
        expect(response.name, 'Echo');
        expect(response.createdAt, DateTime.utc(2024, 3, 20, 12));
        expect(response.userId, isNull);
        expect(response.slug, isNull);
        expect(response.gender, isNull);
        expect(response.age, isNull);
        expect(response.color, isNull);
        expect(response.languages, isEmpty);
        expect(response.tags, isNull);
        expect(response.retentionNotice, 30);
      });
    });

    group('toJson', () {
      test(
        'produces correct snake_case keys and omits null optional fields',
        () {
          final response = VoiceResponse(
            id: 'voice-5',
            name: 'Sage',
            createdAt: DateTime.utc(2024, 2, 10),
          );
          final json = response.toJson();
          expect(json['id'], 'voice-5');
          expect(json['name'], 'Sage');
          expect(json['created_at'], '2024-02-10T00:00:00.000Z');
          expect(json['languages'], <String>[]);
          expect(json['retention_notice'], 30);
          expect(json.containsKey('user_id'), isFalse);
          expect(json.containsKey('slug'), isFalse);
          expect(json.containsKey('gender'), isFalse);
          expect(json.containsKey('age'), isFalse);
          expect(json.containsKey('color'), isFalse);
          expect(json.containsKey('tags'), isFalse);
        },
      );

      test('includes all fields when set', () {
        final response = VoiceResponse(
          id: 'voice-6',
          name: 'Nova',
          createdAt: DateTime.utc(2024, 5, 1),
          userId: 'user-123',
          slug: 'nova-v1',
          gender: 'female',
          age: 30,
          color: '#9B59B6',
          languages: const ['en', 'es'],
          tags: const ['default'],
          retentionNotice: 90,
        );
        final json = response.toJson();
        expect(json['id'], 'voice-6');
        expect(json['name'], 'Nova');
        expect(json['created_at'], '2024-05-01T00:00:00.000Z');
        expect(json['user_id'], 'user-123');
        expect(json['slug'], 'nova-v1');
        expect(json['gender'], 'female');
        expect(json['age'], 30);
        expect(json['color'], '#9B59B6');
        expect(json['languages'], ['en', 'es']);
        expect(json['tags'], ['default']);
        expect(json['retention_notice'], 90);
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        final response1 = VoiceResponse(
          id: 'voice-eq',
          name: 'Test',
          createdAt: DateTime.utc(2024, 1, 1),
          userId: 'user-1',
          slug: 'test-slug',
          gender: 'male',
          age: 28,
          color: '#000',
          languages: const ['en'],
          tags: const ['tag1'],
          retentionNotice: 45,
        );
        final response2 = VoiceResponse(
          id: 'voice-eq',
          name: 'Test',
          createdAt: DateTime.utc(2024, 1, 1),
          userId: 'user-1',
          slug: 'test-slug',
          gender: 'male',
          age: 28,
          color: '#000',
          languages: const ['en'],
          tags: const ['tag1'],
          retentionNotice: 45,
        );
        expect(response1, equals(response2));
        expect(response1.hashCode, response2.hashCode);
      });

      test('not equal when fields differ', () {
        final response1 = VoiceResponse(
          id: 'voice-a',
          name: 'Voice A',
          createdAt: DateTime.utc(2024, 1, 1),
        );
        final response2 = VoiceResponse(
          id: 'voice-b',
          name: 'Voice B',
          createdAt: DateTime.utc(2024, 1, 1),
        );
        expect(response1, isNot(equals(response2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        final response = VoiceResponse(
          id: 'voice-str',
          name: 'StringVoice',
          createdAt: DateTime.utc(2024, 1, 15),
          gender: 'female',
        );
        final str = response.toString();
        expect(str, contains('VoiceResponse'));
        expect(str, contains('voice-str'));
        expect(str, contains('StringVoice'));
        expect(str, contains('female'));
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        final original = VoiceResponse(
          id: 'voice-rt',
          name: 'RoundTrip',
          createdAt: DateTime.utc(2024, 7, 4),
          userId: 'user-rt',
          slug: 'roundtrip-v1',
          gender: 'male',
          age: 35,
          color: '#123ABC',
          languages: const ['en', 'de', 'ja'],
          tags: const ['premium', 'custom'],
          retentionNotice: 7,
        );
        final json = original.toJson();
        final restored = VoiceResponse.fromJson(json);
        expect(restored, equals(original));
      });
    });
  });
}
