import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _editing = 'context-management-2025-06-27';
const _threshold = 'compact-2026-01-12';

const _context = ContextManagementConfig(
  edits: [
    ContextManagementEdit.clearToolUses(
      trigger: ContextEditTrigger.toolUses(5),
      keepToolUses: 0,
      minimumClearedInputTokens: 200,
      excludeTools: ['remember'],
      clearToolInputs: ClearToolInputs.only(['lookup']),
    ),
    ContextManagementEdit.clearThinking(keep: ThinkingTurnsToKeep.recent(2)),
  ],
);

const Map<String, dynamic> _contextJson = {
  'edits': [
    {
      'type': 'clear_tool_uses_20250919',
      'trigger': {'type': 'tool_uses', 'value': 5},
      'keep': {'type': 'tool_uses', 'value': 0},
      'clear_at_least': {'type': 'input_tokens', 'value': 200},
      'exclude_tools': ['remember'],
      'clear_tool_inputs': ['lookup'],
    },
    {
      'type': 'clear_thinking_20251015',
      'keep': {'type': 'thinking_turns', 'value': 2},
    },
  ],
};

const Map<String, dynamic> _applied = {
  'applied_edits': [
    {
      'type': 'clear_tool_uses_20250919',
      'cleared_tool_uses': 5,
      'cleared_input_tokens': 790,
    },
    {
      'type': 'clear_thinking_20251015',
      'cleared_thinking_turns': 2,
      'cleared_input_tokens': 420,
    },
  ],
};

void main() {
  late MockHttpClient transport;
  late AnthropicClient client;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('test-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
  });

  test(
    'preserves required null context reports without changing GA shapes',
    () async {
      final legacyMessage = MockResponses.message();
      final betaMessage = {...legacyMessage, 'context_management': null};
      expect(
        Message.fromJson(legacyMessage).toJson(),
        isNot(contains('context_management')),
      );
      expect(
        Message.fromJson(betaMessage).copyWith().toJson(),
        containsPair('context_management', null),
      );

      final betaTokens = TokenCountResponse.fromJson(const {
        'input_tokens': 42,
        'context_management': null,
      });
      expect(betaTokens.copyWith(inputTokens: 43).toJson(), {
        'input_tokens': 43,
        'context_management': null,
      });
      expect(const TokenCountResponse(inputTokens: 42).toJson(), {
        'input_tokens': 42,
      });

      final start = MockResponses.message()
        ..['content'] = <Object>[]
        ..['stop_reason'] = null;
      transport.queueStreamingResponse([
        {'type': 'message_start', 'message': start},
        {
          'type': 'message_delta',
          'delta': {'stop_reason': 'end_turn', 'stop_sequence': null},
          'usage': {'output_tokens': 4},
          'context_management': null,
        },
        {'type': 'message_stop'},
      ]);
      final events = await client.messages
          .createStream(_request(_context), betas: const [_editing])
          .toList();
      final delta = events.whereType<MessageDeltaEvent>().single;
      expect(
        delta.copyWith().toJson(),
        containsPair('context_management', null),
      );
      final result = await Stream.fromIterable(events).finalMessage();
      expect(result.toJson(), containsPair('context_management', null));
      expect(result.contextManagement, isNull);
    },
  );

  test(
    'Messages sends both edit types and decodes applied statistics',
    () async {
      transport.queueJsonResponse({
        ...MockResponses.message(),
        'context_management': _applied,
      });

      final result = await client.messages.create(
        _request(_context),
        betas: const [_editing],
      );

      final request = transport.lastRequest!;
      expect(request.method, 'POST');
      expect(request.url.path, '/v1/messages');
      expect(request.headers['anthropic-beta'], _editing);
      expect(_body(request)['context_management'], _contextJson);
      final edits = result.contextManagement!.appliedEdits;
      expect((edits[0] as ClearedToolUsesEdit).clearedToolUses, 5);
      expect((edits[1] as ClearedThinkingEdit).clearedThinkingTurns, 2);
      expect(result.toJson()['context_management'], _applied);
      expect(
        result.copyWith(contextManagement: null).contextManagement,
        isNull,
      );
    },
  );

  test('streamed context edits reach the final message', () async {
    final start = MockResponses.message()
      ..['content'] = <Object>[]
      ..['stop_reason'] = null;
    transport.queueStreamingResponse([
      {'type': 'message_start', 'message': start},
      {
        'type': 'message_delta',
        'delta': {'stop_reason': 'end_turn', 'stop_sequence': null},
        'usage': {'output_tokens': 4},
        'context_management': _applied,
      },
      {'type': 'message_stop'},
    ]);

    final events = await client.messages
        .createStream(_request(_context), betas: const [_editing])
        .toList();
    final delta = events.whereType<MessageDeltaEvent>().single;
    expect(delta.toJson()['context_management'], _applied);
    expect(delta.copyWith(contextManagement: null).contextManagement, isNull);
    final result = await Stream.fromIterable(events).finalMessage();
    expect(result.contextManagement, delta.contextManagement);
    expect(result.contextManagement!.appliedEdits, hasLength(2));
    final sent = transport.lastRequest!;
    expect(sent.headers['anthropic-beta'], _editing);
    expect(_body(sent)['context_management'], _contextJson);
    expect(_body(sent)['stream'], isTrue);
  });

  test(
    'token counting sends edits and reads the original input token count',
    () async {
      transport.queueJsonResponse({
        'input_tokens': 100,
        'context_management': {'original_input_tokens': 250},
      });
      final request = TokenCountRequest.fromMessageCreateRequest(
        _request(_context),
      );

      final result = await client.messages.countTokens(
        request,
        betas: const [_editing],
      );

      expect(result.inputTokens, 100);
      expect(result.contextManagement!.originalInputTokens, 250);
      expect(result.toJson()['context_management'], {
        'original_input_tokens': 250,
      });
      expect(
        result.copyWith(contextManagement: null).contextManagement,
        isNull,
      );
      final sent = transport.lastRequest!;
      expect(sent.url.path, '/v1/messages/count_tokens');
      expect(sent.headers['anthropic-beta'], _editing);
      expect(_body(sent)['context_management'], _contextJson);
    },
  );

  test('threshold compaction reaches the beta Messages request', () async {
    transport.queueJsonResponse(MockResponses.message());

    final result = await client.messages.create(
      _request(
        const ContextManagementConfig(
          edits: [
            ContextManagementEdit.thresholdCompaction(
              triggerInputTokens: 200000,
              pauseAfterCompaction: false,
              instructions: 'Keep the decisions.',
            ),
          ],
        ),
      ),
      betas: const [_threshold],
    );

    expect(result.stopReason, StopReason.endTurn);
    final sent = transport.lastRequest!;
    expect(sent.headers['anthropic-beta'], _threshold);
    expect(_body(sent), isNot(contains('compaction')));
    expect(_body(sent)['context_management'], {
      'edits': [
        {
          'type': 'compact_20260112',
          'trigger': {'type': 'input_tokens', 'value': 200000},
          'pause_after_compaction': false,
          'instructions': 'Keep the decisions.',
        },
      ],
    });
  });

  test('configuration round-trips and preserves unknown edit objects', () {
    final restored = ContextManagementConfig.fromJson(
      jsonDecode(jsonEncode(_context.toJson())) as Map<String, dynamic>,
    );
    expect(restored, _context);
    expect(restored.hashCode, _context.hashCode);
    expect(restored.toJson(), _contextJson);
    expect(restored.copyWith(edits: null).toJson(), isEmpty);
    expect(
      const ContextManagementConfig(edits: []).toJson(),
      containsPair('edits', isEmpty),
    );
    final request = _request(restored);
    final same = MessageCreateRequest.fromJson(request.toJson());
    expect(same, request);
    expect(same.hashCode, request.hashCode);
    expect(
      request.copyWith(contextManagement: null).toJson(),
      isNot(contains('context_management')),
    );
    final countRequest = TokenCountRequest.fromMessageCreateRequest(request);
    expect(TokenCountRequest.fromJson(countRequest.toJson()), countRequest);
    expect(
      countRequest.copyWith(contextManagement: null).toJson(),
      isNot(contains('context_management')),
    );

    const futureEdit = {
      'type': 'future_edit',
      'nested': {
        'list': [1],
      },
    };
    final unknown = ContextManagementEdit.fromJson(futureEdit);
    expect(unknown, isA<UnknownContextManagementEdit>());
    expect(unknown.toJson(), futureEdit);
    expect(AppliedContextEdit.fromJson(futureEdit).toJson(), futureEdit);
  });

  test('keeps scalar and object forms and rejects invalid trigger shapes', () {
    expect(
      ContextManagementEdit.fromJson(const {
        'type': 'clear_thinking_20251015',
        'keep': 'all',
      }).toJson()['keep'],
      'all',
    );
    expect(
      ContextManagementEdit.fromJson(const {
        'type': 'clear_thinking_20251015',
        'keep': {'type': 'all'},
      }).toJson()['keep'],
      {'type': 'all'},
    );
    expect(
      ContextManagementEdit.fromJson(const {
        'type': 'clear_tool_uses_20250919',
        'clear_tool_inputs': false,
      }).toJson()['clear_tool_inputs'],
      false,
    );
    expect(
      () => ContextManagementEdit.fromJson(const {
        'type': 'compact_20260112',
        'trigger': {'type': 'tool_uses', 'value': 10},
      }),
      throwsFormatException,
    );
    expect(
      () => AppliedContextEdit.fromJson(const {
        'type': 'clear_thinking_20251015',
      }),
      throwsFormatException,
    );
  });
}

MessageCreateRequest _request(ContextManagementConfig config) =>
    MessageCreateRequest(
      model: 'claude-sonnet-5-5',
      maxTokens: 256,
      messages: [
        InputMessage.user('Find the source.'),
        for (var index = 0; index < 6; index++) ...[
          InputMessage.assistantBlocks([
            InputContentBlock.thinking(
              thinking: 'Check the next source.',
              signature: 'fixture-signature-$index',
            ),
            InputContentBlock.toolUse(
              id: 'toolu_$index',
              name: 'lookup',
              input: {'index': index},
            ),
          ]),
          InputMessage.userBlocks([
            InputContentBlock.toolResultText(
              toolUseId: 'toolu_$index',
              text: 'Source $index',
            ),
          ]),
        ],
        InputMessage.user('Continue the conversation.'),
      ],
      contextManagement: config,
    );

Map<String, dynamic> _body(http.BaseRequest request) =>
    jsonDecode((request as http.Request).body) as Map<String, dynamic>;
