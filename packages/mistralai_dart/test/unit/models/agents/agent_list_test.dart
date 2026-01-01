import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AgentList', () {
    group('constructor', () {
      test('creates with required data parameter', () {
        const list = AgentList(data: []);
        expect(list.data, isEmpty);
        expect(list.object, 'list');
        expect(list.total, isNull);
        expect(list.hasMore, isNull);
      });

      test('creates with all parameters', () {
        const agents = [
          Agent(id: 'agent-1', name: 'Agent 1', model: 'model-a'),
          Agent(id: 'agent-2', name: 'Agent 2', model: 'model-b'),
        ];
        const list = AgentList(
          object: 'list',
          data: agents,
          total: 10,
          hasMore: true,
        );
        expect(list.data, hasLength(2));
        expect(list.total, 10);
        expect(list.hasMore, true);
      });
    });

    group('toJson', () {
      test('serializes empty list', () {
        const list = AgentList(data: []);
        final json = list.toJson();
        expect(json['object'], 'list');
        expect(json['data'], isEmpty);
        expect(json.containsKey('total'), isFalse);
        expect(json.containsKey('has_more'), isFalse);
      });

      test('serializes with agents', () {
        const list = AgentList(
          data: [Agent(id: 'agent-1', name: 'Agent 1', model: 'model-a')],
          total: 5,
          hasMore: false,
        );
        final json = list.toJson();
        expect(json['object'], 'list');
        expect(json['data'], hasLength(1));
        expect(json['total'], 5);
        expect(json['has_more'], false);
      });
    });

    group('fromJson', () {
      test('deserializes empty list', () {
        final json = <String, dynamic>{'object': 'list', 'data': <dynamic>[]};
        final list = AgentList.fromJson(json);
        expect(list.data, isEmpty);
        expect(list.object, 'list');
      });

      test('deserializes with agents', () {
        final json = <String, dynamic>{
          'object': 'list',
          'data': [
            {'id': 'agent-1', 'name': 'Agent 1', 'model': 'model-a'},
            {'id': 'agent-2', 'name': 'Agent 2', 'model': 'model-b'},
          ],
          'total': 2,
          'has_more': false,
        };
        final list = AgentList.fromJson(json);
        expect(list.data, hasLength(2));
        expect(list.data[0].id, 'agent-1');
        expect(list.data[1].id, 'agent-2');
        expect(list.total, 2);
        expect(list.hasMore, false);
      });

      test('handles missing data with default', () {
        final json = <String, dynamic>{'object': 'list'};
        final list = AgentList.fromJson(json);
        expect(list.data, isEmpty);
      });
    });

    group('convenience getters', () {
      test('isEmpty returns true for empty list', () {
        const list = AgentList(data: []);
        expect(list.isEmpty, isTrue);
        expect(list.isNotEmpty, isFalse);
      });

      test('isNotEmpty returns true for non-empty list', () {
        const list = AgentList(
          data: [Agent(id: 'agent-1', name: 'Agent', model: 'model')],
        );
        expect(list.isEmpty, isFalse);
        expect(list.isNotEmpty, isTrue);
      });

      test('length returns count of agents', () {
        const list = AgentList(
          data: [
            Agent(id: 'agent-1', name: 'Agent 1', model: 'model'),
            Agent(id: 'agent-2', name: 'Agent 2', model: 'model'),
            Agent(id: 'agent-3', name: 'Agent 3', model: 'model'),
          ],
        );
        expect(list.length, 3);
      });
    });

    group('equality', () {
      test('equals with same data', () {
        const list1 = AgentList(
          data: [Agent(id: 'agent-1', name: 'Agent', model: 'model')],
        );
        const list2 = AgentList(
          data: [
            Agent(id: 'agent-1', name: 'Other', model: 'model'),
          ], // Same id
        );
        expect(list1, equals(list2));
      });

      test('not equals with different data', () {
        const list1 = AgentList(
          data: [Agent(id: 'agent-1', name: 'Agent', model: 'model')],
        );
        const list2 = AgentList(
          data: [
            Agent(id: 'agent-2', name: 'Agent', model: 'model'),
          ], // Different id
        );
        expect(list1, isNot(equals(list2)));
      });

      test('not equals with different length', () {
        const list1 = AgentList(
          data: [Agent(id: 'agent-1', name: 'Agent', model: 'model')],
        );
        const list2 = AgentList(data: []);
        expect(list1, isNot(equals(list2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const list = AgentList(
          data: [Agent(id: 'agent-1', name: 'Agent', model: 'model')],
          total: 10,
        );
        expect(list.toString(), 'AgentList(count: 1, total: 10)');
      });

      test('handles null total', () {
        const list = AgentList(data: []);
        expect(list.toString(), 'AgentList(count: 0, total: null)');
      });
    });
  });
}
