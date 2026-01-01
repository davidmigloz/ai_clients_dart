import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late AnthropicClient client;

  setUp(() {
    mockHttpClient = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('test-api-key'),
      ),
      httpClient: mockHttpClient,
    );
  });

  tearDown(() {
    client.close();
  });

  group('MessagesResource', () {
    test('create sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(
        MockResponses.message(id: 'msg_test', text: 'Hello from Claude!'),
      );

      final response = await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 1024,
          messages: [InputMessage.user('Hello!')],
        ),
      );

      expect(response.id, 'msg_test');
      expect(response.content, hasLength(1));
      expect((response.content.first as TextBlock).text, 'Hello from Claude!');
      expect(response.stopReason, StopReason.endTurn);

      // Verify request
      expect(mockHttpClient.requests, hasLength(1));
      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/messages');
      expect(request.method, 'POST');
      expect(request.headers['x-api-key'], 'test-api-key');
      expect(request.headers['content-type'], 'application/json');
    });

    test('create handles tool use response', () async {
      mockHttpClient.queueJsonResponse({
        'id': 'msg_tools',
        'type': 'message',
        'role': 'assistant',
        'model': 'claude-sonnet-4-20250514',
        'content': [
          {'type': 'text', 'text': 'Let me check the weather.'},
          {
            'type': 'tool_use',
            'id': 'tu_123',
            'name': 'get_weather',
            'input': {'city': 'San Francisco'},
          },
        ],
        'stop_reason': 'tool_use',
        'stop_sequence': null,
        'usage': {'input_tokens': 10, 'output_tokens': 20},
      });

      final response = await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 1024,
          messages: [InputMessage.user('What is the weather in SF?')],
        ),
      );

      expect(response.stopReason, StopReason.toolUse);
      expect(response.content, hasLength(2));
      expect(response.content[1], isA<ToolUseBlock>());

      final toolUse = response.content[1] as ToolUseBlock;
      expect(toolUse.name, 'get_weather');
      expect(toolUse.input['city'], 'San Francisco');
    });

    test('countTokens returns token count', () async {
      mockHttpClient.queueJsonResponse(
        MockResponses.tokenCount(inputTokens: 42),
      );

      final response = await client.messages.countTokens(
        TokenCountRequest(
          model: 'claude-sonnet-4-20250514',
          messages: [InputMessage.user('Count my tokens!')],
        ),
      );

      expect(response.inputTokens, 42);
    });

    test('create throws ApiException on error', () {
      mockHttpClient.queueErrorResponse(
        statusCode: 400,
        errorType: 'invalid_request_error',
        message: 'Invalid model specified',
      );

      expect(
        () => client.messages.create(
          MessageCreateRequest(
            model: 'invalid-model',
            maxTokens: 1024,
            messages: [InputMessage.user('Hello')],
          ),
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('create throws AuthenticationException on 401', () {
      mockHttpClient.queueErrorResponse(
        statusCode: 401,
        errorType: 'authentication_error',
        message: 'Invalid API key',
      );

      expect(
        () => client.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 1024,
            messages: [InputMessage.user('Hello')],
          ),
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('create throws RateLimitException on 429', () {
      mockHttpClient.queueErrorResponse(
        statusCode: 429,
        errorType: 'rate_limit_error',
        message: 'Rate limit exceeded',
      );

      expect(
        () => client.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 1024,
            messages: [InputMessage.user('Hello')],
          ),
        ),
        throwsA(isA<RateLimitException>()),
      );
    });
  });

  group('ModelsResource', () {
    test('list returns model list', () async {
      mockHttpClient.queueJsonResponse(MockResponses.modelList());

      final response = await client.models.list();

      expect(response.data, hasLength(2));
      expect(response.data.first.id, 'claude-sonnet-4-20250514');
      expect(response.data.first.displayName, 'Claude Sonnet 4');
    });

    test('retrieve returns single model', () async {
      mockHttpClient.queueJsonResponse({
        'id': 'claude-sonnet-4-20250514',
        'type': 'model',
        'display_name': 'Claude Sonnet 4',
        'created_at': '2025-05-14T00:00:00Z',
      });

      final response = await client.models.retrieve('claude-sonnet-4-20250514');

      expect(response.id, 'claude-sonnet-4-20250514');
      expect(response.displayName, 'Claude Sonnet 4');
    });
  });

  group('MessageBatchesResource', () {
    test('create returns batch', () async {
      mockHttpClient.queueJsonResponse(
        MockResponses.messageBatch(
          id: 'batch_123',
          processingStatus: 'in_progress',
        ),
      );

      final response = await client.messages.batches.create(
        MessageBatchCreateRequest(
          requests: [
            BatchRequestItem(
              customId: 'req_1',
              params: MessageCreateRequest(
                model: 'claude-sonnet-4-20250514',
                maxTokens: 100,
                messages: [InputMessage.user('Hello')],
              ),
            ),
          ],
        ),
      );

      expect(response.id, 'batch_123');
      expect(response.processingStatus, ProcessingStatus.inProgress);
    });

    test('retrieve returns batch status', () async {
      mockHttpClient.queueJsonResponse(
        MockResponses.messageBatch(
          id: 'batch_456',
          processingStatus: 'ended',
          succeeded: 10,
          errored: 0,
        ),
      );

      final response = await client.messages.batches.retrieve('batch_456');

      expect(response.id, 'batch_456');
      expect(response.processingStatus, ProcessingStatus.ended);
      expect(response.requestCounts.succeeded, 10);
    });
  });
}
