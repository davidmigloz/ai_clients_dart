import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

void main() {
  group('MessagePhase', () {
    test('serializes commentary and final_answer values', () {
      expect(MessagePhase.commentary.toJson(), 'commentary');
      expect(MessagePhase.finalAnswer.toJson(), 'final_answer');
    });

    test('parses known values', () {
      expect(MessagePhase.fromJson('commentary'), MessagePhase.commentary);
      expect(MessagePhase.fromJson('final_answer'), MessagePhase.finalAnswer);
    });

    test('falls back to unknown for unrecognized values', () {
      expect(MessagePhase.fromJson('mystery_phase'), MessagePhase.unknown);
    });
  });

  group('AssistantMessageItem.phase', () {
    test('serializes phase when set', () {
      final item = MessageItem.assistantText(
        'Final answer here',
        id: 'msg_1',
        phase: MessagePhase.finalAnswer,
      );
      final json = item.toJson();
      expect(json['phase'], 'final_answer');
    });

    test('omits phase when null', () {
      final item = MessageItem.assistantText('Some text', id: 'msg_1');
      expect(item.toJson().containsKey('phase'), isFalse);
    });

    test('round-trips through JSON', () {
      final original = MessageItem.assistantText(
        'Thinking out loud',
        id: 'msg_2',
        phase: MessagePhase.commentary,
      );
      final restored =
          MessageItem.fromJson(original.toJson()) as AssistantMessageItem;
      expect(restored.phase, MessagePhase.commentary);
    });

    test('copyWith replaces phase', () {
      final original = MessageItem.assistantText('Hi') as AssistantMessageItem;
      final modified = original.copyWith(phase: MessagePhase.commentary);
      expect(modified.phase, MessagePhase.commentary);
    });

    test('copyWith clears phase with explicit null', () {
      final original =
          MessageItem.assistantText('Hi', phase: MessagePhase.finalAnswer)
              as AssistantMessageItem;
      final modified = original.copyWith(phase: null);
      expect(modified.phase, isNull);
    });
  });

  group('MessageOutputItem.phase', () {
    test('round-trips through JSON', () {
      final json = {
        'type': 'message',
        'id': 'msg_1',
        'role': 'assistant',
        'content': [
          {'type': 'output_text', 'text': 'Hello'},
        ],
        'phase': 'final_answer',
      };
      final item = OutputItem.fromJson(json) as MessageOutputItem;
      expect(item.phase, MessagePhase.finalAnswer);
      expect(item.toJson()['phase'], 'final_answer');
    });
  });

  group('CompactionItem (input)', () {
    test('serializes with required fields', () {
      const item = CompactionItem(
        id: 'cmp_123',
        encryptedContent: 'gAAAAAB...',
      );
      expect(item.toJson(), {
        'type': 'compaction',
        'id': 'cmp_123',
        'encrypted_content': 'gAAAAAB...',
      });
    });

    test('omits id when null', () {
      const item = CompactionItem(encryptedContent: 'gAAAAAB...');
      final json = item.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json['type'], 'compaction');
    });

    test('round-trips via Item.fromJson', () {
      const original = CompactionItem(id: 'cmp_1', encryptedContent: 'enc');
      final restored = Item.fromJson(original.toJson());
      expect(restored, equals(original));
    });

    test('copyWith clears id with explicit null', () {
      const original = CompactionItem(id: 'cmp_1', encryptedContent: 'enc');
      final modified = original.copyWith(id: null);
      expect(modified.id, isNull);
    });
  });

  group('CompactionOutputItem', () {
    test('parses from JSON', () {
      final json = {
        'type': 'compaction',
        'id': 'cmp_001',
        'encrypted_content': 'gAAAAABpM0Yj-...',
      };
      final item = OutputItem.fromJson(json);
      expect(item, isA<CompactionOutputItem>());
      final compaction = item as CompactionOutputItem;
      expect(compaction.id, 'cmp_001');
      expect(compaction.encryptedContent, 'gAAAAABpM0Yj-...');
    });

    test('round-trips through JSON', () {
      const item = CompactionOutputItem(
        id: 'cmp_001',
        encryptedContent: 'enc-data',
        createdBy: 'system',
      );
      expect(OutputItem.fromJson(item.toJson()), equals(item));
    });

    test('toCompactionItem converts to input variant', () {
      const item = CompactionOutputItem(id: 'cmp_1', encryptedContent: 'enc');
      expect(
        item.toCompactionItem(),
        const CompactionItem(id: 'cmp_1', encryptedContent: 'enc'),
      );
    });
  });

  group('CompactResource', () {
    test('parses example payload (matches CompactResource spec example)', () {
      // Matches the OpenAPI example for CompactResource: a user message with
      // input_text content alongside a compaction output item.
      final json = {
        'id': 'resp_001',
        'object': 'response.compaction',
        'created_at': 1764967971,
        'output': [
          {
            'type': 'message',
            'id': 'msg_000',
            'role': 'user',
            'content': [
              {
                'type': 'input_text',
                'text': 'Create a simple landing page for a dog petting cafe.',
              },
            ],
            'status': 'completed',
          },
          {
            'type': 'compaction',
            'id': 'cmp_001',
            'encrypted_content': 'gAAAAABpM0Yj-...=',
          },
        ],
        'usage': {
          'input_tokens': 139,
          'output_tokens': 438,
          'total_tokens': 577,
        },
      };
      final resource = CompactResource.fromJson(json);
      expect(resource.id, 'resp_001');
      expect(resource.object, 'response.compaction');
      expect(resource.createdAt, 1764967971);
      expect(resource.output, hasLength(2));
      expect(resource.output[0], isA<MessageOutputItem>());
      final msg = resource.output[0] as MessageOutputItem;
      expect(msg.content, hasLength(1));
      expect(msg.content.first, isA<InputTextContent>());
      expect(resource.output[1], isA<CompactionOutputItem>());
      expect(resource.usage.totalTokens, 577);
    });

    test('round-trips a payload mixing input and output content parts', () {
      const original = CompactResource(
        id: 'resp_002',
        createdAt: 1764967971,
        output: [
          MessageOutputItem(
            id: 'msg_user',
            role: MessageRole.user,
            content: [InputTextContent(text: 'Hello')],
            status: ItemStatus.completed,
          ),
          MessageOutputItem(
            id: 'msg_assistant',
            role: MessageRole.assistant,
            content: [OutputTextContent(text: 'Hi there')],
            status: ItemStatus.completed,
          ),
        ],
        usage: Usage(inputTokens: 1, outputTokens: 1, totalTokens: 2),
      );
      expect(CompactResource.fromJson(original.toJson()), equals(original));
    });
  });

  group('MessageOutputItem with mixed content', () {
    test('parses input_text in user-role message', () {
      final json = {
        'type': 'message',
        'id': 'msg_user',
        'role': 'user',
        'content': [
          {'type': 'input_text', 'text': 'Hello'},
        ],
        'status': 'completed',
      };
      final item = OutputItem.fromJson(json) as MessageOutputItem;
      expect(item.role, MessageRole.user);
      expect(item.content.first, isA<InputTextContent>());
      expect((item.content.first as InputTextContent).text, 'Hello');
    });

    test('parses input_image in user-role message', () {
      final json = {
        'type': 'message',
        'id': 'msg_user',
        'role': 'user',
        'content': [
          {'type': 'input_image', 'image_url': 'https://example.com/img.png'},
        ],
        'status': 'completed',
      };
      final item = OutputItem.fromJson(json) as MessageOutputItem;
      expect(item.content.first, isA<InputImageContent>());
    });

    test('parses output_text in assistant-role message', () {
      final json = {
        'type': 'message',
        'id': 'msg_asst',
        'role': 'assistant',
        'content': [
          {'type': 'output_text', 'text': 'Hi'},
        ],
        'status': 'completed',
      };
      final item = OutputItem.fromJson(json) as MessageOutputItem;
      expect(item.content.first, isA<OutputTextContent>());
      expect(item.text, 'Hi');
    });

    test('text getter includes input_text from user messages', () {
      const item = MessageOutputItem(
        id: 'msg_user',
        role: MessageRole.user,
        content: [InputTextContent(text: 'Hello world')],
        status: ItemStatus.completed,
      );
      expect(item.text, 'Hello world');
    });

    test('text getter combines input_text and output_text parts', () {
      const item = MessageOutputItem(
        id: 'msg_mixed',
        role: MessageRole.user,
        content: [
          InputTextContent(text: 'in '),
          OutputTextContent(text: 'out'),
        ],
        status: ItemStatus.completed,
      );
      expect(item.text, 'in out');
    });

    test('text getter returns null when no text parts exist', () {
      const item = MessageOutputItem(
        id: 'msg_image_only',
        role: MessageRole.user,
        content: [InputImageContent.url('https://example.com/img.png')],
        status: ItemStatus.completed,
      );
      expect(item.text, isNull);
    });
  });

  group('FunctionCallOutputResponseItem', () {
    test('parses from JSON', () {
      final json = {
        'type': 'function_call_output',
        'id': 'fco_001',
        'call_id': 'call_abc',
        'output': '{"result":"ok"}',
        'status': 'completed',
      };
      final item = OutputItem.fromJson(json);
      expect(item, isA<FunctionCallOutputResponseItem>());
      final fco = item as FunctionCallOutputResponseItem;
      expect(fco.id, 'fco_001');
      expect(fco.callId, 'call_abc');
      expect(fco.output, isA<FunctionCallOutputString>());
      expect(fco.status, FunctionCallStatus.completed);
    });

    test('round-trips through JSON', () {
      const item = FunctionCallOutputResponseItem(
        id: 'fco_001',
        callId: 'call_abc',
        output: FunctionCallOutputString('{"result":"ok"}'),
        status: FunctionCallStatus.completed,
      );
      expect(OutputItem.fromJson(item.toJson()), equals(item));
    });

    test('toFunctionCallOutputItem converts to input variant', () {
      const item = FunctionCallOutputResponseItem(
        id: 'fco_1',
        callId: 'call_1',
        output: FunctionCallOutputString('value'),
        status: FunctionCallStatus.completed,
      );
      final input = item.toFunctionCallOutputItem();
      expect(input.id, 'fco_1');
      expect(input.callId, 'call_1');
      expect(input.output, isA<FunctionCallOutputString>());
      expect(input.status, FunctionCallStatus.completed);
    });
  });

  group('CompactResponseRequest', () {
    test('serializes with only required fields', () {
      const request = CompactResponseRequest(model: 'gpt-5');
      expect(request.toJson(), {'model': 'gpt-5'});
    });

    test('serializes with all fields', () {
      final request = CompactResponseRequest(
        model: 'gpt-5',
        input: ResponseInput.text('summarize this'),
        instructions: 'be concise',
        previousResponseId: 'resp_prev',
        promptCacheKey: 'cache-key',
      );
      expect(request.toJson(), {
        'model': 'gpt-5',
        'input': 'summarize this',
        'instructions': 'be concise',
        'previous_response_id': 'resp_prev',
        'prompt_cache_key': 'cache-key',
      });
    });

    test('round-trips through JSON', () {
      final request = CompactResponseRequest(
        model: 'gpt-5',
        input: ResponseInput.items(const [
          CompactionItem(id: 'cmp_prev', encryptedContent: 'enc'),
        ]),
        previousResponseId: 'resp_prev',
      );
      final restored = CompactResponseRequest.fromJson(request.toJson());
      expect(restored, equals(request));
    });
  });
}
