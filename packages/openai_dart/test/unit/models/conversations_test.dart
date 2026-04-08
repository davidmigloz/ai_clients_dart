import 'package:openai_dart/src/models/conversations/conversations.dart';
import 'package:openai_dart/src/models/responses/config/item_status.dart';
import 'package:openai_dart/src/models/responses/config/message_phase.dart';
import 'package:openai_dart/src/models/responses/config/tool_search_execution_type.dart';
import 'package:openai_dart/src/models/responses/items/item.dart';
import 'package:openai_dart/src/models/responses/tools/response_tool.dart';
import 'package:test/test.dart';

void main() {
  group('Conversation', () {
    test('deserializes from JSON', () {
      final json = {
        'id': 'conv_abc123',
        'object': 'conversation',
        'created_at': 1234567890,
        'metadata': {'user_id': 'user_123'},
      };

      final conversation = Conversation.fromJson(json);

      expect(conversation.id, equals('conv_abc123'));
      expect(conversation.object, equals('conversation'));
      expect(conversation.createdAt, equals(1234567890));
      expect(conversation.metadata, equals({'user_id': 'user_123'}));
    });

    test('serializes to JSON', () {
      const conversation = Conversation(
        id: 'conv_abc123',
        createdAt: 1234567890,
        metadata: {'status': 'active'},
      );

      final json = conversation.toJson();

      expect(json['id'], equals('conv_abc123'));
      expect(json['object'], equals('conversation'));
      expect(json['created_at'], equals(1234567890));
      expect(json['metadata'], equals({'status': 'active'}));
    });

    test('roundtrip serialization', () {
      const conversation = Conversation(
        id: 'conv_xyz789',
        createdAt: 9876543210,
        metadata: {'key': 'value'},
      );

      final json = conversation.toJson();
      final restored = Conversation.fromJson(json);

      expect(restored, equals(conversation));
    });

    test('equality', () {
      const conv1 = Conversation(
        id: 'conv_abc123',
        createdAt: 1234567890,
        metadata: {'key': 'value'},
      );
      const conv2 = Conversation(
        id: 'conv_abc123',
        createdAt: 1234567890,
        metadata: {'key': 'value'},
      );
      const conv3 = Conversation(id: 'conv_different', createdAt: 1234567890);

      expect(conv1, equals(conv2));
      expect(conv1, isNot(equals(conv3)));
    });

    test('handles null metadata', () {
      final json = {
        'id': 'conv_abc123',
        'object': 'conversation',
        'created_at': 1234567890,
      };

      final conversation = Conversation.fromJson(json);

      expect(conversation.metadata, isNull);
    });
  });

  group('ConversationDeletedResource', () {
    test('deserializes from JSON', () {
      final json = {
        'id': 'conv_abc123',
        'deleted': true,
        'object': 'conversation.deleted',
      };

      final deleted = ConversationDeletedResource.fromJson(json);

      expect(deleted.id, equals('conv_abc123'));
      expect(deleted.deleted, isTrue);
      expect(deleted.object, equals('conversation.deleted'));
    });

    test('serializes to JSON', () {
      const deleted = ConversationDeletedResource(
        id: 'conv_abc123',
        deleted: true,
      );

      final json = deleted.toJson();

      expect(json['id'], equals('conv_abc123'));
      expect(json['deleted'], isTrue);
      expect(json['object'], equals('conversation.deleted'));
    });

    test('equality', () {
      const del1 = ConversationDeletedResource(id: 'conv_abc', deleted: true);
      const del2 = ConversationDeletedResource(id: 'conv_abc', deleted: true);
      const del3 = ConversationDeletedResource(id: 'conv_abc', deleted: false);

      expect(del1, equals(del2));
      expect(del1, isNot(equals(del3)));
    });
  });

  group('ConversationCreateRequest', () {
    test('creates empty request', () {
      const request = ConversationCreateRequest();

      expect(request.items, isNull);
      expect(request.metadata, isNull);
    });

    test('creates with items', () {
      final request = ConversationCreateRequest(
        items: [
          MessageItem.userText('Hello!'),
          MessageItem.assistantText('Hi there!'),
        ],
      );

      expect(request.items?.length, equals(2));
    });

    test('creates with metadata', () {
      const request = ConversationCreateRequest(
        metadata: {'user_id': 'user_123'},
      );

      expect(request.metadata, equals({'user_id': 'user_123'}));
    });

    test('serializes to JSON', () {
      final request = ConversationCreateRequest(
        items: [MessageItem.userText('Hello!')],
        metadata: const {'key': 'value'},
      );

      final json = request.toJson();

      expect(json['items'], isList);
      expect(json['metadata'], equals({'key': 'value'}));
    });

    test('empty request serializes to empty JSON', () {
      const request = ConversationCreateRequest();

      final json = request.toJson();

      expect(json.containsKey('items'), isFalse);
      expect(json.containsKey('metadata'), isFalse);
    });

    test('deserializes from JSON', () {
      final json = {
        'items': [
          {
            'type': 'message',
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': 'Hello!'},
            ],
          },
        ],
        'metadata': {'key': 'value'},
      };

      final request = ConversationCreateRequest.fromJson(json);

      expect(request.items?.length, equals(1));
      expect(request.metadata, equals({'key': 'value'}));
    });
  });

  group('ConversationUpdateRequest', () {
    test('creates with metadata', () {
      const request = ConversationUpdateRequest(
        metadata: {'status': 'resolved'},
      );

      expect(request.metadata, equals({'status': 'resolved'}));
    });

    test('serializes to JSON', () {
      const request = ConversationUpdateRequest(metadata: {'key': 'value'});

      final json = request.toJson();

      expect(json['metadata'], equals({'key': 'value'}));
    });

    test('empty request serializes to empty JSON', () {
      const request = ConversationUpdateRequest();

      final json = request.toJson();

      expect(json.containsKey('metadata'), isFalse);
    });
  });

  group('ItemsCreateRequest', () {
    test('creates with items', () {
      final request = ItemsCreateRequest(
        items: [MessageItem.userText('Hello!')],
      );

      expect(request.items.length, equals(1));
    });

    test('serializes to JSON', () {
      final request = ItemsCreateRequest(
        items: [
          MessageItem.userText('Hello!'),
          MessageItem.assistantText('Hi!'),
        ],
      );

      final json = request.toJson();

      expect(json['items'], isList);
      expect((json['items'] as List).length, equals(2));
    });

    test('deserializes from JSON', () {
      final json = {
        'items': [
          {
            'type': 'message',
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': 'Test'},
            ],
          },
        ],
      };

      final request = ItemsCreateRequest.fromJson(json);

      expect(request.items.length, equals(1));
    });
  });

  group('ConversationItemList', () {
    test('deserializes from JSON', () {
      final json = {
        'data': [
          {
            'type': 'message',
            'id': 'item_123',
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': 'Hello!'},
            ],
          },
        ],
        'object': 'list',
        'has_more': true,
        'first_id': 'item_123',
        'last_id': 'item_123',
      };

      final list = ConversationItemList.fromJson(json);

      expect(list.data.length, equals(1));
      expect(list.object, equals('list'));
      expect(list.hasMore, isTrue);
      expect(list.firstId, equals('item_123'));
      expect(list.lastId, equals('item_123'));
    });

    test('serializes to JSON', () {
      const list = ConversationItemList(
        data: [],
        hasMore: false,
        firstId: 'item_first',
        lastId: 'item_last',
      );

      final json = list.toJson();

      expect(json['data'], isEmpty);
      expect(json['object'], equals('list'));
      expect(json['has_more'], isFalse);
      expect(json['first_id'], equals('item_first'));
      expect(json['last_id'], equals('item_last'));
    });

    test('handles null pagination IDs', () {
      final json = {'data': <dynamic>[], 'object': 'list', 'has_more': false};

      final list = ConversationItemList.fromJson(json);

      expect(list.firstId, isNull);
      expect(list.lastId, isNull);
    });
  });

  group('ConversationItem', () {
    test('deserializes message item', () {
      final json = {
        'type': 'message',
        'id': 'item_123',
        'role': 'user',
        'content': [
          {'type': 'input_text', 'text': 'Hello!'},
        ],
        'status': 'completed',
      };

      final item = ConversationItem.fromJson(json);

      expect(item, isA<ConversationMessageItem>());
      final message = item as ConversationMessageItem;
      expect(message.id, equals('item_123'));
      expect(message.role.value, equals('user'));
      expect(message.status, equals(ItemStatus.completed));
    });

    test('deserializes function call item', () {
      final json = {
        'type': 'function_call',
        'id': 'item_456',
        'call_id': 'call_123',
        'name': 'get_weather',
        'arguments': '{"location": "Paris"}',
      };

      final item = ConversationItem.fromJson(json);

      expect(item, isA<ConversationFunctionCallItem>());
      final funcCall = item as ConversationFunctionCallItem;
      expect(funcCall.id, equals('item_456'));
      expect(funcCall.callId, equals('call_123'));
      expect(funcCall.name, equals('get_weather'));
      expect(funcCall.arguments, equals('{"location": "Paris"}'));
    });

    test('deserializes function call output item', () {
      final json = {
        'type': 'function_call_output',
        'id': 'item_789',
        'call_id': 'call_123',
        'output': '{"temperature": 20}',
      };

      final item = ConversationItem.fromJson(json);

      expect(item, isA<ConversationFunctionCallOutputItem>());
      final output = item as ConversationFunctionCallOutputItem;
      expect(output.id, equals('item_789'));
      expect(output.callId, equals('call_123'));
    });

    test('deserializes reasoning item', () {
      final json = {
        'type': 'reasoning',
        'id': 'item_reasoning',
        'summary': [
          {'type': 'summary_text', 'text': 'Thinking about the problem...'},
        ],
      };

      final item = ConversationItem.fromJson(json);

      expect(item, isA<ConversationReasoningItem>());
      final reasoning = item as ConversationReasoningItem;
      expect(reasoning.id, equals('item_reasoning'));
      expect(reasoning.summary.length, equals(1));
      expect(
        reasoning.summary.first.text,
        equals('Thinking about the problem...'),
      );
    });

    test('deserializes image generation call item', () {
      final json = {
        'type': 'image_generation_call',
        'id': 'item_img',
        'prompt': 'A cat wearing a hat',
        'revised_prompt': 'A cute cat wearing a top hat',
        'status': 'completed',
      };

      final item = ConversationItem.fromJson(json);

      expect(item, isA<ConversationImageGenerationCallItem>());
      final imgCall = item as ConversationImageGenerationCallItem;
      expect(imgCall.prompt, equals('A cat wearing a hat'));
      expect(imgCall.revisedPrompt, equals('A cute cat wearing a top hat'));
    });

    test('deserializes web search call item', () {
      final json = {
        'type': 'web_search_call',
        'id': 'item_ws',
        'status': 'completed',
      };

      final item = ConversationItem.fromJson(json);

      expect(item, isA<ConversationWebSearchCallItem>());
    });

    test('deserializes file search call item', () {
      final json = {
        'type': 'file_search_call',
        'id': 'item_fs',
        'queries': ['search query'],
        'status': 'completed',
      };

      final item = ConversationItem.fromJson(json);

      expect(item, isA<ConversationFileSearchCallItem>());
      final fsCall = item as ConversationFileSearchCallItem;
      expect(fsCall.queries, equals(['search query']));
    });

    test('deserializes computer call item', () {
      final json = {
        'type': 'computer_call',
        'id': 'item_comp',
        'call_id': 'call_comp',
        'action': {'type': 'click', 'x': 100, 'y': 200},
      };

      final item = ConversationItem.fromJson(json);

      expect(item, isA<ConversationComputerCallItem>());
      final compCall = item as ConversationComputerCallItem;
      expect(compCall.action?['type'], equals('click'));
    });

    test('deserializes code interpreter call item', () {
      final json = {
        'type': 'code_interpreter_call',
        'id': 'item_ci',
        'code': 'print("hello")',
        'language': 'python',
      };

      final item = ConversationItem.fromJson(json);

      expect(item, isA<ConversationCodeInterpreterCallItem>());
      final ciCall = item as ConversationCodeInterpreterCallItem;
      expect(ciCall.code, equals('print("hello")'));
      expect(ciCall.language, equals('python'));
    });

    test('deserializes MCP call item', () {
      final json = {
        'type': 'mcp_call',
        'id': 'item_mcp',
        'call_id': 'call_mcp',
        'server_label': 'my_server',
        'name': 'read_file',
        'arguments': '{"path": "/tmp/file.txt"}',
      };

      final item = ConversationItem.fromJson(json);

      expect(item, isA<ConversationMcpCallItem>());
      final mcpCall = item as ConversationMcpCallItem;
      expect(mcpCall.serverLabel, equals('my_server'));
      expect(mcpCall.name, equals('read_file'));
    });

    test('deserializes unknown item type', () {
      final json = {
        'type': 'future_type',
        'id': 'item_future',
        'some_field': 'some_value',
      };

      final item = ConversationItem.fromJson(json);

      expect(item, isA<ConversationUnknownItem>());
      final unknown = item as ConversationUnknownItem;
      expect(unknown.type, equals('future_type'));
    });
  });

  group('ConversationContent', () {
    test('deserializes input text content', () {
      final json = {'type': 'input_text', 'text': 'Hello!'};

      final content = ConversationContent.fromJson(json);

      expect(content, isA<ConversationInputTextContent>());
      expect((content as ConversationInputTextContent).text, equals('Hello!'));
    });

    test('deserializes input image content', () {
      final json = {
        'type': 'input_image',
        'image_url': 'https://example.com/img.png',
        'detail': 'high',
      };

      final content = ConversationContent.fromJson(json);

      expect(content, isA<ConversationInputImageContent>());
      final imgContent = content as ConversationInputImageContent;
      expect(imgContent.imageUrl, equals('https://example.com/img.png'));
      expect(imgContent.detail, equals('high'));
    });

    test('deserializes input file content', () {
      final json = {
        'type': 'input_file',
        'file_id': 'file_123',
        'filename': 'document.pdf',
      };

      final content = ConversationContent.fromJson(json);

      expect(content, isA<ConversationInputFileContent>());
      final fileContent = content as ConversationInputFileContent;
      expect(fileContent.fileId, equals('file_123'));
      expect(fileContent.filename, equals('document.pdf'));
    });

    test('deserializes output text content', () {
      final json = {'type': 'output_text', 'text': 'Response text'};

      final content = ConversationContent.fromJson(json);

      expect(content, isA<ConversationOutputTextContent>());
      expect(
        (content as ConversationOutputTextContent).text,
        equals('Response text'),
      );
    });

    test('deserializes refusal content', () {
      final json = {'type': 'refusal', 'refusal': 'Cannot comply'};

      final content = ConversationContent.fromJson(json);

      expect(content, isA<ConversationRefusalContent>());
      expect(
        (content as ConversationRefusalContent).refusal,
        equals('Cannot comply'),
      );
    });

    test('deserializes summary text content', () {
      final json = {'type': 'summary_text', 'text': 'Summary of reasoning'};

      final content = ConversationContent.fromJson(json);

      expect(content, isA<ConversationSummaryTextContent>());
      expect(
        (content as ConversationSummaryTextContent).text,
        equals('Summary of reasoning'),
      );
    });

    test('deserializes reasoning text content', () {
      final json = {'type': 'reasoning_text', 'text': 'Thinking...'};

      final content = ConversationContent.fromJson(json);

      expect(content, isA<ConversationReasoningTextContent>());
      expect(
        (content as ConversationReasoningTextContent).text,
        equals('Thinking...'),
      );
    });

    test('deserializes unknown content type', () {
      final json = {'type': 'future_content', 'data': 'some_data'};

      final content = ConversationContent.fromJson(json);

      expect(content, isA<ConversationUnknownContent>());
    });

    test('serializes input text content', () {
      const content = ConversationInputTextContent(text: 'Hello!');

      final json = content.toJson();

      expect(json['type'], equals('input_text'));
      expect(json['text'], equals('Hello!'));
    });

    test('serializes output text content', () {
      const content = ConversationOutputTextContent(text: 'Response');

      final json = content.toJson();

      expect(json['type'], equals('output_text'));
      expect(json['text'], equals('Response'));
    });
  });

  group('ConversationRole', () {
    test('creates standard roles', () {
      expect(ConversationRole.user.value, equals('user'));
      expect(ConversationRole.assistant.value, equals('assistant'));
      expect(ConversationRole.system.value, equals('system'));
      expect(ConversationRole.developer.value, equals('developer'));
      expect(ConversationRole.tool.value, equals('tool'));
    });

    test('creates extended roles', () {
      expect(ConversationRole.unknown.value, equals('unknown'));
      expect(ConversationRole.critic.value, equals('critic'));
      expect(ConversationRole.discriminator.value, equals('discriminator'));
    });

    test('deserializes from JSON', () {
      expect(ConversationRole.fromJson('user'), equals(ConversationRole.user));
      expect(
        ConversationRole.fromJson('assistant'),
        equals(ConversationRole.assistant),
      );
      expect(
        ConversationRole.fromJson('critic'),
        equals(ConversationRole.critic),
      );
    });

    test('handles unknown role', () {
      final role = ConversationRole.fromJson('future_role');

      expect(role.value, equals('future_role'));
    });

    test('serializes to JSON', () {
      expect(ConversationRole.user.toJson(), equals('user'));
      expect(ConversationRole.assistant.toJson(), equals('assistant'));
    });

    test('equality', () {
      expect(ConversationRole.user, equals(ConversationRole.user));
      expect(ConversationRole.user, isNot(equals(ConversationRole.assistant)));
    });
  });

  group('ConversationMessageItem', () {
    test('serializes to JSON', () {
      const item = ConversationMessageItem(
        id: 'item_123',
        role: ConversationRole.user,
        content: [ConversationInputTextContent(text: 'Hello!')],
        status: ItemStatus.completed,
      );

      final json = item.toJson();

      expect(json['type'], equals('message'));
      expect(json['id'], equals('item_123'));
      expect(json['role'], equals('user'));
      expect(json['content'], isList);
      expect(json['status'], equals('completed'));
    });

    test('equality', () {
      const item1 = ConversationMessageItem(
        id: 'item_123',
        role: ConversationRole.user,
        content: [ConversationInputTextContent(text: 'Hello!')],
      );
      const item2 = ConversationMessageItem(
        id: 'item_123',
        role: ConversationRole.user,
        content: [ConversationInputTextContent(text: 'Hello!')],
      );
      const item3 = ConversationMessageItem(
        id: 'item_different',
        role: ConversationRole.user,
        content: [ConversationInputTextContent(text: 'Hello!')],
      );

      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
    });

    test('round-trip with phase', () {
      final json = {
        'type': 'message',
        'id': 'item_456',
        'role': 'assistant',
        'content': [
          {'type': 'output_text', 'text': 'Hello!'},
        ],
        'status': 'completed',
        'phase': 'commentary',
      };

      final item = ConversationMessageItem.fromJson(json);
      expect(item.phase, equals(MessagePhase.commentary));

      final output = item.toJson();
      expect(output['phase'], equals('commentary'));
    });

    test('phase omitted when null', () {
      const item = ConversationMessageItem(
        id: 'item_789',
        role: ConversationRole.user,
        content: [ConversationInputTextContent(text: 'Hi')],
      );

      final json = item.toJson();
      expect(json.containsKey('phase'), isFalse);
    });
  });

  group('ConversationToolSearchCallItem', () {
    test('round-trip', () {
      final json = {
        'type': 'tool_search_call',
        'id': 'tsc_1',
        'call_id': 'call_1',
        'execution': 'server',
        'arguments': {'query': 'test'},
        'status': 'completed',
      };

      final item = ConversationItem.fromJson(json);
      expect(item, isA<ConversationToolSearchCallItem>());
      final tsc = item as ConversationToolSearchCallItem;
      expect(tsc.id, 'tsc_1');
      expect(tsc.callId, 'call_1');
      expect(tsc.execution, ToolSearchExecutionType.server);

      final restored = ConversationItem.fromJson(tsc.toJson());
      expect(restored, equals(tsc));
    });

    test('round-trip with null callId', () {
      final json = {
        'type': 'tool_search_call',
        'id': 'tsc_2',
        'execution': 'server',
      };

      final item = ConversationItem.fromJson(json);
      expect(item, isA<ConversationToolSearchCallItem>());
      final tsc = item as ConversationToolSearchCallItem;
      expect(tsc.callId, isNull);

      final restored = ConversationItem.fromJson(tsc.toJson());
      expect(restored, equals(tsc));
    });

    test('equality is deep for arguments map', () {
      final json = {
        'type': 'tool_search_call',
        'id': 'tsc_3',
        'call_id': 'call_3',
        'execution': 'client',
        'arguments': {
          'query': 'search',
          'filters': {'lang': 'dart'},
        },
        'status': 'completed',
      };
      final a =
          ConversationItem.fromJson(json) as ConversationToolSearchCallItem;
      final b =
          ConversationItem.fromJson(json) as ConversationToolSearchCallItem;
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('ConversationToolSearchOutputItem', () {
    test('round-trip', () {
      final json = {
        'type': 'tool_search_output',
        'id': 'tso_1',
        'call_id': 'call_1',
        'execution': 'client',
        'tools': [
          {'type': 'function', 'name': 'func1'},
        ],
        'status': 'completed',
      };

      final item = ConversationItem.fromJson(json);
      expect(item, isA<ConversationToolSearchOutputItem>());
      final tso = item as ConversationToolSearchOutputItem;
      expect(tso.id, 'tso_1');
      expect(tso.tools, hasLength(1));
      expect(tso.tools!.first, isA<FunctionTool>());

      final restored = ConversationItem.fromJson(tso.toJson());
      expect(restored, equals(tso));
    });

    test('round-trip with null callId', () {
      final json = {
        'type': 'tool_search_output',
        'id': 'tso_2',
        'execution': 'client',
        'tools': [
          {'type': 'function', 'name': 'func1'},
        ],
      };

      final item = ConversationItem.fromJson(json);
      expect(item, isA<ConversationToolSearchOutputItem>());
      final tso = item as ConversationToolSearchOutputItem;
      expect(tso.callId, isNull);

      final restored = ConversationItem.fromJson(tso.toJson());
      expect(restored, equals(tso));
    });

    test('equality uses deep comparison of tools list', () {
      final json = {
        'type': 'tool_search_output',
        'id': 'tso_3',
        'call_id': 'call_3',
        'execution': 'server',
        'tools': [
          {'type': 'function', 'name': 'func1'},
        ],
        'status': 'completed',
      };
      final a =
          ConversationItem.fromJson(json) as ConversationToolSearchOutputItem;
      final b =
          ConversationItem.fromJson(json) as ConversationToolSearchOutputItem;
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('instances with different tools are not equal', () {
      const a = ConversationToolSearchOutputItem(
        id: 'tso_4',
        callId: 'call_4',
        execution: ToolSearchExecutionType.server,
        tools: [FunctionTool(name: 'func1')],
        status: ItemStatus.completed,
      );
      const b = ConversationToolSearchOutputItem(
        id: 'tso_4',
        callId: 'call_4',
        execution: ToolSearchExecutionType.server,
        tools: [FunctionTool(name: 'func2')],
        status: ItemStatus.completed,
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('ConversationCompactionItem', () {
    test('round-trip JSON serialization', () {
      final json = {
        'type': 'compaction',
        'id': 'comp_1',
        'encrypted_content': 'encrypted_data_here',
        'created_by': 'agent_1',
      };
      final item =
          ConversationItem.fromJson(json) as ConversationCompactionItem;
      expect(item.id, 'comp_1');
      expect(item.encryptedContent, 'encrypted_data_here');
      expect(item.createdBy, 'agent_1');
      expect(item.toJson(), json);
    });

    test('equality', () {
      final json = {
        'type': 'compaction',
        'id': 'comp_2',
        'encrypted_content': 'data',
      };
      final a = ConversationItem.fromJson(json) as ConversationCompactionItem;
      final b = ConversationItem.fromJson(json) as ConversationCompactionItem;
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('ConversationCustomToolCallItem', () {
    test('round-trip JSON serialization', () {
      final json = {
        'type': 'custom_tool_call',
        'id': 'ct_1',
        'call_id': 'call_ct1',
        'name': 'my_tool',
        'input': '{"key": "value"}',
        'namespace': 'ns1',
        'status': 'completed',
      };
      final item =
          ConversationItem.fromJson(json) as ConversationCustomToolCallItem;
      expect(item.id, 'ct_1');
      expect(item.callId, 'call_ct1');
      expect(item.name, 'my_tool');
      expect(item.input, '{"key": "value"}');
      expect(item.namespace, 'ns1');
      expect(item.status, ItemStatus.completed);
      expect(item.toJson(), json);
    });

    test('round-trip without optional fields', () {
      final json = {
        'type': 'custom_tool_call',
        'call_id': 'call_ct2',
        'name': 'tool2',
        'input': 'data',
      };
      final item =
          ConversationItem.fromJson(json) as ConversationCustomToolCallItem;
      expect(item.id, isNull);
      expect(item.namespace, isNull);
      expect(item.status, isNull);
      expect(item.toJson(), json);
    });

    test('equality', () {
      final json = {
        'type': 'custom_tool_call',
        'id': 'ct_3',
        'call_id': 'call_ct3',
        'name': 'tool3',
        'input': 'data',
        'status': 'in_progress',
      };
      final a =
          ConversationItem.fromJson(json) as ConversationCustomToolCallItem;
      final b =
          ConversationItem.fromJson(json) as ConversationCustomToolCallItem;
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('ConversationCustomToolCallOutputItem', () {
    test('round-trip JSON serialization with string output', () {
      final json = {
        'type': 'custom_tool_call_output',
        'id': 'cto_1',
        'call_id': 'call_cto1',
        'output': 'result string',
        'status': 'completed',
      };
      final item =
          ConversationItem.fromJson(json)
              as ConversationCustomToolCallOutputItem;
      expect(item.id, 'cto_1');
      expect(item.callId, 'call_cto1');
      expect(item.output, isA<FunctionCallOutputString>());
      expect(item.status, ItemStatus.completed);
      expect(item.toJson(), json);
    });

    test('round-trip without optional id', () {
      final json = {
        'type': 'custom_tool_call_output',
        'call_id': 'call_cto2',
        'output': 'data',
      };
      final item =
          ConversationItem.fromJson(json)
              as ConversationCustomToolCallOutputItem;
      expect(item.id, isNull);
      expect(item.status, isNull);
      expect(item.toJson(), json);
    });

    test('equality with string output', () {
      final json = {
        'type': 'custom_tool_call_output',
        'id': 'cto_3',
        'call_id': 'call_cto3',
        'output': 'same result',
        'status': 'in_progress',
      };
      final a =
          ConversationItem.fromJson(json)
              as ConversationCustomToolCallOutputItem;
      final b =
          ConversationItem.fromJson(json)
              as ConversationCustomToolCallOutputItem;
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
