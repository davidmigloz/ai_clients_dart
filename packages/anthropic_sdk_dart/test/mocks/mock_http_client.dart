import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// A mock HTTP client for testing purposes.
class MockHttpClient extends http.BaseClient {
  final List<MockResponse> _responses = [];
  final List<http.BaseRequest> _requests = [];

  /// All requests made to this client.
  List<http.BaseRequest> get requests => List.unmodifiable(_requests);

  /// The last request made to this client.
  http.BaseRequest? get lastRequest =>
      _requests.isEmpty ? null : _requests.last;

  /// Queues a response to be returned by the next request.
  void queueResponse(MockResponse response) {
    _responses.add(response);
  }

  /// Queues a JSON response.
  void queueJsonResponse(
    Map<String, dynamic> json, {
    int statusCode = 200,
    Map<String, String>? headers,
  }) {
    queueResponse(
      MockResponse(
        body: jsonEncode(json),
        statusCode: statusCode,
        headers: {'content-type': 'application/json', ...?headers},
      ),
    );
  }

  /// Queues an error response.
  void queueErrorResponse({
    required int statusCode,
    required String errorType,
    required String message,
  }) {
    queueJsonResponse({
      'type': 'error',
      'error': {'type': errorType, 'message': message},
    }, statusCode: statusCode);
  }

  /// Queues a streaming response (SSE).
  void queueStreamingResponse(
    List<Map<String, dynamic>> events, {
    int statusCode = 200,
  }) {
    final sseBody = events.map((event) {
      final eventType = event['type'] as String? ?? 'message';
      final data = jsonEncode(event);
      return 'event: $eventType\ndata: $data\n\n';
    }).join();

    queueResponse(
      MockResponse(
        body: sseBody,
        statusCode: statusCode,
        headers: {'content-type': 'text/event-stream'},
        isStreaming: true,
      ),
    );
  }

  /// Clears all queued responses and recorded requests.
  void reset() {
    _responses.clear();
    _requests.clear();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    _requests.add(request);

    if (_responses.isEmpty) {
      throw StateError('No mock response queued for request: ${request.url}');
    }

    final mockResponse = _responses.removeAt(0);
    return mockResponse.toStreamedResponse();
  }
}

/// A mock HTTP response.
class MockResponse {
  /// The response body.
  final String body;

  /// The HTTP status code.
  final int statusCode;

  /// The response headers.
  final Map<String, String> headers;

  /// Whether this is a streaming response.
  final bool isStreaming;

  /// Creates a [MockResponse].
  const MockResponse({
    this.body = '',
    this.statusCode = 200,
    this.headers = const {},
    this.isStreaming = false,
  });

  /// Converts this to an [http.StreamedResponse].
  http.StreamedResponse toStreamedResponse() {
    final bytes = utf8.encode(body);
    final stream = isStreaming
        ? _createChunkedStream(bytes)
        : Stream.value(bytes);

    return http.StreamedResponse(stream, statusCode, headers: headers);
  }

  /// Creates a chunked stream that emits data in small chunks.
  Stream<List<int>> _createChunkedStream(List<int> bytes) async* {
    const chunkSize = 64;
    for (var i = 0; i < bytes.length; i += chunkSize) {
      final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      yield bytes.sublist(i, end);
      // Small delay to simulate streaming
      await Future<void>.delayed(Duration.zero);
    }
  }
}

/// Helper functions for creating common mock responses.
class MockResponses {
  MockResponses._();

  /// Creates a successful message response.
  static Map<String, dynamic> message({
    String id = 'msg_test123',
    String model = 'claude-sonnet-4-20250514',
    String text = 'Hello! How can I help you?',
    String stopReason = 'end_turn',
    int inputTokens = 10,
    int outputTokens = 20,
  }) {
    return {
      'id': id,
      'type': 'message',
      'role': 'assistant',
      'model': model,
      'content': [
        {'type': 'text', 'text': text},
      ],
      'stop_reason': stopReason,
      'stop_sequence': null,
      'usage': {'input_tokens': inputTokens, 'output_tokens': outputTokens},
    };
  }

  /// Creates streaming events for a message.
  static List<Map<String, dynamic>> streamingEvents({
    String id = 'msg_test123',
    String model = 'claude-sonnet-4-20250514',
    String text = 'Hello!',
    int inputTokens = 10,
    int outputTokens = 5,
  }) {
    return [
      {
        'type': 'message_start',
        'message': {
          'id': id,
          'type': 'message',
          'role': 'assistant',
          'model': model,
          'content': <Map<String, dynamic>>[],
          'stop_reason': null,
          'stop_sequence': null,
          'usage': {'input_tokens': inputTokens, 'output_tokens': 0},
        },
      },
      {
        'type': 'content_block_start',
        'index': 0,
        'content_block': {'type': 'text', 'text': ''},
      },
      {
        'type': 'content_block_delta',
        'index': 0,
        'delta': {'type': 'text_delta', 'text': text},
      },
      {'type': 'content_block_stop', 'index': 0},
      {
        'type': 'message_delta',
        'delta': {'stop_reason': 'end_turn', 'stop_sequence': null},
        'usage': {'output_tokens': outputTokens},
      },
      {'type': 'message_stop'},
    ];
  }

  /// Creates a model list response.
  static Map<String, dynamic> modelList({List<Map<String, dynamic>>? models}) {
    return {
      'object': 'list',
      'data':
          models ??
          [
            {
              'id': 'claude-sonnet-4-20250514',
              'type': 'model',
              'display_name': 'Claude Sonnet 4',
              'created_at': '2025-05-14T00:00:00Z',
            },
            {
              'id': 'claude-3-5-haiku-20241022',
              'type': 'model',
              'display_name': 'Claude 3.5 Haiku',
              'created_at': '2024-10-22T00:00:00Z',
            },
          ],
      'has_more': false,
      'first_id': 'claude-sonnet-4-20250514',
      'last_id': 'claude-3-5-haiku-20241022',
    };
  }

  /// Creates a message batch response.
  static Map<String, dynamic> messageBatch({
    String id = 'batch_test123',
    String processingStatus = 'in_progress',
    int processing = 10,
    int succeeded = 5,
    int errored = 0,
    int canceled = 0,
    int expired = 0,
  }) {
    return {
      'id': id,
      'type': 'message_batch',
      'processing_status': processingStatus,
      'request_counts': {
        'processing': processing,
        'succeeded': succeeded,
        'errored': errored,
        'canceled': canceled,
        'expired': expired,
      },
      'ended_at': null,
      'created_at': '2024-01-01T00:00:00Z',
      'expires_at': '2024-01-02T00:00:00Z',
      'archived_at': null,
      'cancel_initiated_at': null,
      'results_url': null,
    };
  }

  /// Creates a token count response.
  static Map<String, dynamic> tokenCount({int inputTokens = 50}) {
    return {'input_tokens': inputTokens};
  }
}
