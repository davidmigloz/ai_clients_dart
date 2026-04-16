@TestOn('vm')
library;

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
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: mockHttpClient,
    );
  });

  tearDown(() {
    client.close();
  });

  group('StreamingResource', () {
    test('postStream sends request and yields SSE events', () async {
      mockHttpClient.queueStreamingResponse(
        MockResponses.streamingEvents(text: 'Hello world!'),
      );

      final events = await client.messages
          .createStream(
            MessageCreateRequest(
              model: 'claude-sonnet-4-6',
              maxTokens: 256,
              messages: [InputMessage.user('Hi!')],
            ),
          )
          .toList();

      expect(events, isNotEmpty);
      // Verify the stream contains expected event types
      expect(events.first, isA<MessageStartEvent>());
      expect(events.last, isA<MessageStopEvent>());

      // Verify request was sent correctly
      expect(mockHttpClient.requests, hasLength(1));
      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/messages');
      expect(request.method, 'POST');
    });

    test(
      'prepareStreamingRequest applies auth from config.authProvider',
      () async {
        mockHttpClient.queueStreamingResponse(
          MockResponses.streamingEvents(text: 'Authenticated!'),
        );

        await client.messages
            .createStream(
              MessageCreateRequest(
                model: 'claude-sonnet-4-6',
                maxTokens: 256,
                messages: [InputMessage.user('Hi!')],
              ),
            )
            .toList();

        // Verify auth header was applied via config.authProvider
        final request = mockHttpClient.lastRequest!;
        expect(request.headers['x-api-key'], 'test-api-key');
      },
    );

    test('postStream throws exception for 400+ status', () async {
      mockHttpClient.queueStreamingResponse([
        {
          'type': 'error',
          'error': {
            'type': 'invalid_request_error',
            'message': 'Invalid model',
          },
        },
      ], statusCode: 400);

      await expectLater(
        client.messages
            .createStream(
              MessageCreateRequest(
                model: 'invalid-model',
                maxTokens: 256,
                messages: [InputMessage.user('Hi!')],
              ),
            )
            .toList(),
        throwsA(isA<ApiException>()),
      );
    });

    test('postStream calls ensureNotClosed', () async {
      client.close();

      await expectLater(
        client.messages
            .createStream(
              MessageCreateRequest(
                model: 'claude-sonnet-4-6',
                maxTokens: 256,
                messages: [InputMessage.user('Hi!')],
              ),
            )
            .toList(),
        throwsA(isA<StateError>()),
      );
    });
  });
}
