import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _dreamJson() {
  return {
    'type': 'dream',
    'id': 'dream_test123',
    'inputs': <Map<String, dynamic>>[],
    'outputs': <Map<String, dynamic>>[],
    'status': 'completed',
    'created_at': '2026-04-25T00:00:00.000Z',
    'ended_at': '2026-04-25T01:00:00.000Z',
    'archived_at': null,
    'error': null,
    'model': {'id': 'claude-opus-4-7'},
    'instructions': null,
    'session_id': null,
    'usage': {
      'input_tokens': 1,
      'output_tokens': 1,
      'cache_read_input_tokens': 0,
      'cache_creation_input_tokens': 0,
    },
  };
}

void main() {
  group('ListDreamsResponse', () {
    test('fromJson/toJson round-trip with a next page', () {
      final json = {
        'data': [_dreamJson()],
        'next_page': 'cursor123',
      };
      final response = ListDreamsResponse.fromJson(json);
      expect(response.data, hasLength(1));
      expect(response.nextPage, 'cursor123');
      expect(response.toJson(), json);
    });

    test('next_page key is always emitted, even when null', () {
      final response = ListDreamsResponse.fromJson(const {
        'data': <Map<String, dynamic>>[],
        'next_page': null,
      });
      expect(response.nextPage, isNull);
      final body = response.toJson();
      expect(body.containsKey('next_page'), isTrue);
      expect(body['next_page'], isNull);
    });

    test('copyWith replaces and clears nextPage', () {
      final response = ListDreamsResponse.fromJson(const {
        'data': <Map<String, dynamic>>[],
        'next_page': 'a',
      });
      expect(response.copyWith(nextPage: 'b').nextPage, 'b');
      expect(response.copyWith(nextPage: null).nextPage, isNull);
      expect(response.copyWith().nextPage, 'a');
    });

    test('equality and hashCode', () {
      final a = ListDreamsResponse.fromJson({
        'data': [_dreamJson()],
        'next_page': null,
      });
      final b = ListDreamsResponse.fromJson({
        'data': [_dreamJson()],
        'next_page': null,
      });
      final c = ListDreamsResponse.fromJson(const {
        'data': <Map<String, dynamic>>[],
        'next_page': null,
      });
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString includes data count', () {
      final response = ListDreamsResponse.fromJson({
        'data': [_dreamJson()],
        'next_page': null,
      });
      expect(response.toString(), contains('data: 1 items'));
    });
  });
}
