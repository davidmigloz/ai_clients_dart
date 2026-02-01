// ignore_for_file: deprecated_member_use_from_same_package
import 'package:openai_dart/openai_dart_assistants.dart';
import 'package:test/test.dart';

void main() {
  group('Thread', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'thread_abc123',
        'object': 'thread',
        'created_at': 1699472000,
        'metadata': {'key': 'value'},
      };

      final thread = Thread.fromJson(json);

      expect(thread.id, 'thread_abc123');
      expect(thread.object, 'thread');
      expect(thread.createdAt, 1699472000);
      expect(thread.metadata['key'], 'value');
    });

    test('fromJson handles tool_resources', () {
      final json = {
        'id': 'thread_abc123',
        'object': 'thread',
        'created_at': 1699472000,
        'metadata': <String, dynamic>{},
        'tool_resources': {
          'code_interpreter': {
            'file_ids': ['file-1', 'file-2'],
          },
        },
      };

      final thread = Thread.fromJson(json);

      expect(thread.toolResources?.codeInterpreter?.fileIds, [
        'file-1',
        'file-2',
      ]);
    });

    test('toJson serializes correctly', () {
      const thread = Thread(
        id: 'thread_abc123',
        object: 'thread',
        createdAt: 1699472000,
        metadata: {'key': 'value'},
      );

      final json = thread.toJson();

      expect(json['id'], 'thread_abc123');
      expect(json['object'], 'thread');
      expect(json['created_at'], 1699472000);
      expect((json['metadata'] as Map)['key'], 'value');
    });
  });

  group('CreateThreadRequest', () {
    test('fromJson parses correctly', () {
      final json = {
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'metadata': {'key': 'value'},
      };

      final request = CreateThreadRequest.fromJson(json);

      expect(request.messages?.length, 1);
      expect(request.metadata?['key'], 'value');
    });

    test('toJson serializes correctly', () {
      final request = CreateThreadRequest(
        messages: [ThreadMessage.user('Hello')],
        metadata: const {'key': 'value'},
      );

      final json = request.toJson();

      expect((json['messages'] as List).length, 1);
      expect(((json['messages'] as List)[0] as Map)['role'], 'user');
      expect((json['metadata'] as Map)['key'], 'value');
    });
  });

  group('Message', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'msg_abc123',
        'object': 'thread.message',
        'created_at': 1699472000,
        'thread_id': 'thread_xyz',
        'status': 'completed',
        'role': 'assistant',
        'content': [
          {
            'type': 'text',
            'text': {
              'value': 'Hello, how can I help?',
              'annotations': <dynamic>[],
            },
          },
        ],
        'assistant_id': 'asst_abc',
        'run_id': 'run_xyz',
        'attachments': <dynamic>[],
        'metadata': <String, dynamic>{},
      };

      final message = Message.fromJson(json);

      expect(message.id, 'msg_abc123');
      expect(message.object, 'thread.message');
      expect(message.threadId, 'thread_xyz');
      expect(message.role, 'assistant');
      expect(message.isAssistant, isTrue);
      expect(message.content.length, 1);
      expect(message.assistantId, 'asst_abc');
      expect(message.runId, 'run_xyz');
    });

    test('text getter returns combined text content', () {
      final json = {
        'id': 'msg_abc123',
        'object': 'thread.message',
        'created_at': 1699472000,
        'thread_id': 'thread_xyz',
        'status': 'completed',
        'role': 'assistant',
        'content': [
          {
            'type': 'text',
            'text': {'value': 'Hello', 'annotations': <dynamic>[]},
          },
          {
            'type': 'text',
            'text': {'value': ' World', 'annotations': <dynamic>[]},
          },
        ],
        'attachments': <dynamic>[],
        'metadata': <String, dynamic>{},
      };

      final message = Message.fromJson(json);

      expect(message.text, 'Hello World');
    });

    test('toJson serializes correctly', () {
      const message = Message(
        id: 'msg_abc123',
        object: 'thread.message',
        createdAt: 1699472000,
        threadId: 'thread_xyz',
        status: MessageStatus.completed,
        role: 'user',
        content: [
          TextMessageContent(
            text: TextContent(value: 'Test message', annotations: []),
          ),
        ],
        attachments: [],
        metadata: {},
      );

      final json = message.toJson();

      expect(json['id'], 'msg_abc123');
      expect(json['role'], 'user');
      expect(((json['content'] as List)[0] as Map)['type'], 'text');
    });
  });

  group('CreateMessageRequest', () {
    test('toJson serializes text content', () {
      const request = CreateMessageRequest(role: 'user', content: 'Hello');

      final json = request.toJson();

      expect(json['role'], 'user');
      expect(json['content'], 'Hello');
    });

    test('user factory creates user message', () {
      final request = CreateMessageRequest.user('Hello');

      expect(request.role, 'user');
      expect(request.content, 'Hello');
    });
  });

  group('MessageStatus', () {
    test('fromJson parses all values', () {
      expect(MessageStatus.fromJson('in_progress'), MessageStatus.inProgress);
      expect(MessageStatus.fromJson('incomplete'), MessageStatus.incomplete);
      expect(MessageStatus.fromJson('completed'), MessageStatus.completed);
    });

    test('toJson returns correct string', () {
      expect(MessageStatus.inProgress.toJson(), 'in_progress');
      expect(MessageStatus.completed.toJson(), 'completed');
    });
  });

  group('DeleteThreadResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'thread_abc123',
        'object': 'thread.deleted',
        'deleted': true,
      };

      final response = DeleteThreadResponse.fromJson(json);

      expect(response.id, 'thread_abc123');
      expect(response.deleted, isTrue);
    });
  });

  group('DeleteMessageResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'msg_abc123',
        'object': 'thread.message.deleted',
        'deleted': true,
      };

      final response = DeleteMessageResponse.fromJson(json);

      expect(response.id, 'msg_abc123');
      expect(response.deleted, isTrue);
    });
  });

  group('ThreadMessage', () {
    test('user factory creates user message', () {
      final message = ThreadMessage.user('Hello');

      expect(message.role, 'user');
      expect(message.content, 'Hello');
    });

    test('assistant factory creates assistant message', () {
      final message = ThreadMessage.assistant('Hi there!');

      expect(message.role, 'assistant');
      expect(message.content, 'Hi there!');
    });

    test('toJson serializes correctly', () {
      final message = ThreadMessage.user('Test');

      final json = message.toJson();

      expect(json['role'], 'user');
      expect(json['content'], 'Test');
    });
  });
}
