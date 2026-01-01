import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Conversation', () {
    group('constructor', () {
      test('creates with required id', () {
        const conversation = Conversation(id: 'conv-123');
        expect(conversation.id, 'conv-123');
        expect(conversation.object, 'conversation');
        expect(conversation.model, isNull);
        expect(conversation.agentId, isNull);
        expect(conversation.entries, isNull);
      });

      test('creates with all parameters', () {
        const conversation = Conversation(
          id: 'conv-456',
          object: 'conversation',
          model: 'mistral-large-latest',
          agentId: 'agent-123',
          createdAt: 1705312800,
          updatedAt: 1705313800,
          metadata: {'key': 'value'},
          entries: [
            MessageInputEntry(content: 'Hello'),
            MessageOutputEntry(content: 'Hi there'),
          ],
        );
        expect(conversation.id, 'conv-456');
        expect(conversation.model, 'mistral-large-latest');
        expect(conversation.agentId, 'agent-123');
        expect(conversation.createdAt, 1705312800);
        expect(conversation.updatedAt, 1705313800);
        expect(conversation.metadata?['key'], 'value');
        expect(conversation.entries, hasLength(2));
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const conversation = Conversation(id: 'conv-123');
        final json = conversation.toJson();
        expect(json['id'], 'conv-123');
        expect(json['object'], 'conversation');
        expect(json.containsKey('model'), isFalse);
        expect(json.containsKey('agent_id'), isFalse);
      });

      test('serializes all fields', () {
        const conversation = Conversation(
          id: 'conv-full',
          model: 'mistral-small-latest',
          agentId: 'agent-1',
          createdAt: 1705312800,
          updatedAt: 1705313000,
          metadata: {'env': 'test'},
          entries: [MessageInputEntry(content: 'Test')],
        );
        final json = conversation.toJson();
        expect(json['id'], 'conv-full');
        expect(json['model'], 'mistral-small-latest');
        expect(json['agent_id'], 'agent-1');
        expect(json['created_at'], 1705312800);
        expect(json['updated_at'], 1705313000);
        expect(json['metadata'], {'env': 'test'});
        expect(json['entries'], hasLength(1));
      });
    });

    group('fromJson', () {
      test('deserializes required fields', () {
        final json = <String, dynamic>{
          'id': 'conv-789',
          'object': 'conversation',
        };
        final conversation = Conversation.fromJson(json);
        expect(conversation.id, 'conv-789');
        expect(conversation.object, 'conversation');
      });

      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'id': 'conv-full',
          'object': 'conversation',
          'model': 'mistral-large-latest',
          'agent_id': 'agent-2',
          'created_at': 1705312800,
          'updated_at': 1705314000,
          'metadata': {'source': 'api'},
          'entries': [
            {'type': 'message.input', 'content': 'Hi', 'role': 'user'},
            {'type': 'message.output', 'content': 'Hello', 'role': 'assistant'},
          ],
        };
        final conversation = Conversation.fromJson(json);
        expect(conversation.id, 'conv-full');
        expect(conversation.model, 'mistral-large-latest');
        expect(conversation.agentId, 'agent-2');
        expect(conversation.createdAt, 1705312800);
        expect(conversation.updatedAt, 1705314000);
        expect(conversation.metadata?['source'], 'api');
        expect(conversation.entries, hasLength(2));
        expect(conversation.entries![0], isA<MessageInputEntry>());
        expect(conversation.entries![1], isA<MessageOutputEntry>());
      });

      test('handles missing fields', () {
        final json = <String, dynamic>{};
        final conversation = Conversation.fromJson(json);
        expect(conversation.id, '');
        expect(conversation.object, 'conversation');
        expect(conversation.entries, isNull);
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        const original = Conversation(
          id: 'conv-1',
          model: 'mistral-large-latest',
        );
        final copy = original.copyWith();
        expect(copy.id, 'conv-1');
        expect(copy.model, 'mistral-large-latest');
      });

      test('copies with changes', () {
        const original = Conversation(
          id: 'conv-1',
          model: 'mistral-small-latest',
        );
        final copy = original.copyWith(
          model: 'mistral-large-latest',
          agentId: 'agent-1',
        );
        expect(copy.id, 'conv-1');
        expect(copy.model, 'mistral-large-latest');
        expect(copy.agentId, 'agent-1');
      });
    });

    group('convenience getters', () {
      test('entryCount returns number of entries', () {
        const conv1 = Conversation(
          id: 'conv-1',
          entries: [
            MessageInputEntry(content: 'A'),
            MessageOutputEntry(content: 'B'),
          ],
        );
        expect(conv1.entryCount, 2);

        const conv2 = Conversation(id: 'conv-2');
        expect(conv2.entryCount, 0);
      });

      test('hasEntries returns true when entries exist', () {
        const conv1 = Conversation(
          id: 'conv-1',
          entries: [MessageInputEntry(content: 'A')],
        );
        expect(conv1.hasEntries, isTrue);

        const conv2 = Conversation(id: 'conv-2', entries: []);
        expect(conv2.hasEntries, isFalse);

        const conv3 = Conversation(id: 'conv-3');
        expect(conv3.hasEntries, isFalse);
      });

      test('isAgentConversation returns true when agentId is set', () {
        const conv1 = Conversation(id: 'conv-1', agentId: 'agent-1');
        expect(conv1.isAgentConversation, isTrue);

        const conv2 = Conversation(id: 'conv-2', model: 'mistral-large-latest');
        expect(conv2.isAgentConversation, isFalse);
      });

      test('isModelConversation returns true for model-based conversation', () {
        const conv1 = Conversation(id: 'conv-1', model: 'mistral-large-latest');
        expect(conv1.isModelConversation, isTrue);

        const conv2 = Conversation(
          id: 'conv-2',
          model: 'mistral-large-latest',
          agentId: 'agent-1',
        );
        expect(conv2.isModelConversation, isFalse);
      });
    });

    group('equality', () {
      test('equals with same id', () {
        const conv1 = Conversation(id: 'conv-123');
        const conv2 = Conversation(id: 'conv-123', model: 'different');
        expect(conv1, equals(conv2));
        expect(conv1.hashCode, conv2.hashCode);
      });

      test('not equals with different id', () {
        const conv1 = Conversation(id: 'conv-123');
        const conv2 = Conversation(id: 'conv-456');
        expect(conv1, isNot(equals(conv2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const conversation = Conversation(
          id: 'conv-123',
          entries: [
            MessageInputEntry(content: 'A'),
            MessageOutputEntry(content: 'B'),
          ],
        );
        expect(
          conversation.toString(),
          'Conversation(id: conv-123, entries: 2)',
        );
      });
    });
  });

  group('ConversationList', () {
    group('constructor', () {
      test('creates with required data', () {
        const list = ConversationList(data: []);
        expect(list.data, isEmpty);
        expect(list.object, 'list');
        expect(list.total, isNull);
        expect(list.hasMore, isNull);
      });

      test('creates with all parameters', () {
        const list = ConversationList(
          object: 'list',
          data: [
            Conversation(id: 'conv-1'),
            Conversation(id: 'conv-2'),
          ],
          total: 10,
          hasMore: true,
        );
        expect(list.data, hasLength(2));
        expect(list.total, 10);
        expect(list.hasMore, true);
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        const list = ConversationList(
          data: [Conversation(id: 'conv-1')],
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
      test('deserializes correctly', () {
        final json = <String, dynamic>{
          'object': 'list',
          'data': [
            {'id': 'conv-1'},
            {'id': 'conv-2'},
          ],
          'total': 2,
          'has_more': false,
        };
        final list = ConversationList.fromJson(json);
        expect(list.data, hasLength(2));
        expect(list.data[0].id, 'conv-1');
        expect(list.total, 2);
        expect(list.hasMore, false);
      });

      test('handles missing data', () {
        final json = <String, dynamic>{'object': 'list'};
        final list = ConversationList.fromJson(json);
        expect(list.data, isEmpty);
      });
    });

    group('convenience getters', () {
      test('isEmpty and isNotEmpty work correctly', () {
        const empty = ConversationList(data: []);
        expect(empty.isEmpty, isTrue);
        expect(empty.isNotEmpty, isFalse);

        const nonEmpty = ConversationList(data: [Conversation(id: 'conv-1')]);
        expect(nonEmpty.isEmpty, isFalse);
        expect(nonEmpty.isNotEmpty, isTrue);
      });

      test('length returns count', () {
        const list = ConversationList(
          data: [
            Conversation(id: 'conv-1'),
            Conversation(id: 'conv-2'),
          ],
        );
        expect(list.length, 2);
      });
    });

    group('equality', () {
      test('equals with same data', () {
        const list1 = ConversationList(data: [Conversation(id: 'conv-1')]);
        const list2 = ConversationList(
          data: [Conversation(id: 'conv-1', model: 'different')], // Same id
        );
        expect(list1, equals(list2));
      });

      test('not equals with different data', () {
        const list1 = ConversationList(data: [Conversation(id: 'conv-1')]);
        const list2 = ConversationList(
          data: [Conversation(id: 'conv-2')],
        ); // Different id
        expect(list1, isNot(equals(list2)));
      });

      test('not equals with different length', () {
        const list1 = ConversationList(data: [Conversation(id: 'conv-1')]);
        const list2 = ConversationList(data: []);
        expect(list1, isNot(equals(list2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const list = ConversationList(
          data: [Conversation(id: 'conv-1')],
          total: 10,
        );
        expect(list.toString(), 'ConversationList(count: 1, total: 10)');
      });
    });
  });
}
