import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('VoiceListResponse', () {
    final sampleVoice1 = VoiceResponse(
      id: 'voice-1',
      name: 'Aria',
      createdAt: DateTime.utc(2024, 1, 10),
    );
    final sampleVoice2 = VoiceResponse(
      id: 'voice-2',
      name: 'Zephyr',
      createdAt: DateTime.utc(2024, 2, 20),
      gender: 'male',
    );

    group('constructor', () {
      test('creates with all fields', () {
        final response = VoiceListResponse(
          items: [sampleVoice1, sampleVoice2],
          total: 50,
          page: 1,
          pageSize: 10,
          totalPages: 5,
        );
        expect(response.items, hasLength(2));
        expect(response.items[0].id, 'voice-1');
        expect(response.items[1].id, 'voice-2');
        expect(response.total, 50);
        expect(response.page, 1);
        expect(response.pageSize, 10);
        expect(response.totalPages, 5);
      });
    });

    group('fromJson', () {
      test('deserializes items array with VoiceResponse JSON objects', () {
        final json = <String, dynamic>{
          'items': [
            {
              'id': 'voice-10',
              'name': 'Luna',
              'created_at': '2024-03-01T00:00:00.000Z',
              'gender': 'female',
            },
            {
              'id': 'voice-11',
              'name': 'Echo',
              'created_at': '2024-04-15T08:30:00.000Z',
              'languages': ['en', 'fr'],
            },
          ],
          'total': 2,
          'page': 0,
          'page_size': 20,
          'total_pages': 1,
        };
        final response = VoiceListResponse.fromJson(json);
        expect(response.items, hasLength(2));
        expect(response.items[0].id, 'voice-10');
        expect(response.items[0].name, 'Luna');
        expect(response.items[0].gender, 'female');
        expect(response.items[1].id, 'voice-11');
        expect(response.items[1].languages, ['en', 'fr']);
        expect(response.total, 2);
        expect(response.page, 0);
        expect(response.pageSize, 20);
        expect(response.totalPages, 1);
      });

      test('deserializes empty items', () {
        final json = <String, dynamic>{
          'items': <dynamic>[],
          'total': 0,
          'page': 0,
          'page_size': 10,
          'total_pages': 0,
        };
        final response = VoiceListResponse.fromJson(json);
        expect(response.items, isEmpty);
        expect(response.total, 0);
        expect(response.totalPages, 0);
      });

      test('handles missing items as empty list', () {
        final json = <String, dynamic>{
          'total': 0,
          'page': 0,
          'page_size': 10,
          'total_pages': 0,
        };
        final response = VoiceListResponse.fromJson(json);
        expect(response.items, isEmpty);
      });
    });

    group('toJson', () {
      test('produces correct snake_case keys', () {
        final response = VoiceListResponse(
          items: [sampleVoice1],
          total: 1,
          page: 0,
          pageSize: 25,
          totalPages: 1,
        );
        final json = response.toJson();
        expect(json['items'], isList);
        expect(json['items'] as List<dynamic>, hasLength(1));
        expect(json['total'], 1);
        expect(json['page'], 0);
        expect(json['page_size'], 25);
        expect(json['total_pages'], 1);
        expect(json.containsKey('pageSize'), isFalse);
        expect(json.containsKey('totalPages'), isFalse);
      });
    });

    group('convenience getters', () {
      test('isEmpty returns true for empty list', () {
        const response = VoiceListResponse(
          items: [],
          total: 0,
          page: 0,
          pageSize: 10,
          totalPages: 0,
        );
        expect(response.isEmpty, isTrue);
        expect(response.isNotEmpty, isFalse);
        expect(response.length, 0);
      });

      test('isNotEmpty returns true for non-empty list', () {
        final response = VoiceListResponse(
          items: [sampleVoice1],
          total: 1,
          page: 0,
          pageSize: 10,
          totalPages: 1,
        );
        expect(response.isEmpty, isFalse);
        expect(response.isNotEmpty, isTrue);
        expect(response.length, 1);
      });

      test('length returns item count', () {
        final response = VoiceListResponse(
          items: [sampleVoice1, sampleVoice2],
          total: 100,
          page: 0,
          pageSize: 10,
          totalPages: 10,
        );
        expect(response.length, 2);
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        final response1 = VoiceListResponse(
          items: [sampleVoice1],
          total: 1,
          page: 0,
          pageSize: 10,
          totalPages: 1,
        );
        final response2 = VoiceListResponse(
          items: [sampleVoice1],
          total: 1,
          page: 0,
          pageSize: 10,
          totalPages: 1,
        );
        expect(response1, equals(response2));
        expect(response1.hashCode, response2.hashCode);
      });

      test('not equal when items differ', () {
        final response1 = VoiceListResponse(
          items: [sampleVoice1],
          total: 1,
          page: 0,
          pageSize: 10,
          totalPages: 1,
        );
        final response2 = VoiceListResponse(
          items: [sampleVoice2],
          total: 1,
          page: 0,
          pageSize: 10,
          totalPages: 1,
        );
        expect(response1, isNot(equals(response2)));
      });

      test('not equal when pagination differs', () {
        final response1 = VoiceListResponse(
          items: [sampleVoice1],
          total: 1,
          page: 0,
          pageSize: 10,
          totalPages: 1,
        );
        final response2 = VoiceListResponse(
          items: [sampleVoice1],
          total: 1,
          page: 1,
          pageSize: 10,
          totalPages: 1,
        );
        expect(response1, isNot(equals(response2)));
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        final original = VoiceListResponse(
          items: [sampleVoice1, sampleVoice2],
          total: 50,
          page: 2,
          pageSize: 25,
          totalPages: 2,
        );
        final json = original.toJson();
        final restored = VoiceListResponse.fromJson(json);
        expect(restored, equals(original));
      });
    });
  });
}
