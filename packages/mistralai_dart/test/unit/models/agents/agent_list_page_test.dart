@TestOn('vm')
library;

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AgentListPage', () {
    test('round-trips through JSON', () {
      final json = {
        'data': [
          {
            'id': 'agent-1',
            'name': 'My Agent',
            'model': 'mistral-large-latest',
            'instructions': 'Be helpful',
          },
        ],
        'next_page_token': 'cursor-1',
        'object': 'list',
      };
      final page = AgentListPage.fromJson(json);
      expect(page.data, hasLength(1));
      expect(page.data.first.id, 'agent-1');
      expect(page.nextPageToken, 'cursor-1');
      expect(page.object, 'list');
      expect(page.isNotEmpty, isTrue);
      expect(page.length, 1);

      expect(AgentListPage.fromJson(page.toJson()), page);
    });

    test('defaults object to "list" and nextPageToken to null', () {
      final page = AgentListPage.fromJson(const {'data': <dynamic>[]});
      expect(page.object, 'list');
      expect(page.nextPageToken, isNull);
      expect(page.isEmpty, isTrue);
      expect(page.toJson().containsKey('next_page_token'), isFalse);
    });

    test('copyWith clears nextPageToken with explicit null', () {
      final page = AgentListPage.fromJson(const {
        'data': <dynamic>[],
        'next_page_token': 'cursor-1',
      });
      final cleared = page.copyWith(nextPageToken: null);
      expect(cleared.nextPageToken, isNull);
    });

    test('equality is value-based', () {
      final json = {'data': <dynamic>[], 'next_page_token': 'cursor-1'};
      expect(AgentListPage.fromJson(json), AgentListPage.fromJson(json));
      expect(
        AgentListPage.fromJson(json).hashCode,
        AgentListPage.fromJson(json).hashCode,
      );
    });

    test('toString includes object', () {
      final page = AgentListPage.fromJson(const {
        'data': <dynamic>[],
        'object': 'list',
      });
      expect(page.toString(), contains('object: list'));
    });
  });
}
