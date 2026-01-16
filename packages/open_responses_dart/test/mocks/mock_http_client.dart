import 'dart:convert';

import 'package:http/http.dart' as http;

/// A mock response for testing.
class MockResponse {
  /// The response body.
  final String body;

  /// The HTTP status code.
  final int statusCode;

  /// Response headers.
  final Map<String, String> headers;

  /// Whether this is a streaming response.
  final bool isStreaming;

  /// Creates a [MockResponse].
  MockResponse({
    required this.body,
    this.statusCode = 200,
    this.headers = const {'content-type': 'application/json'},
    this.isStreaming = false,
  });
}

/// A mock HTTP client for testing.
class MockHttpClient extends http.BaseClient {
  final List<MockResponse> _responses = [];
  final List<http.BaseRequest> _requests = [];

  /// All requests made to this client.
  List<http.BaseRequest> get requests => List.unmodifiable(_requests);

  /// The last request made to this client.
  http.BaseRequest? get lastRequest =>
      _requests.isEmpty ? null : _requests.last;

  /// Queues a JSON response.
  void queueJsonResponse(Map<String, dynamic> json, {int statusCode = 200}) {
    _responses.add(
      MockResponse(body: jsonEncode(json), statusCode: statusCode),
    );
  }

  /// Queues a streaming response from SSE events.
  void queueStreamingResponse(List<Map<String, dynamic>> events) {
    final sseBody =
        '${events.map((event) {
          final type = event['type'] as String;
          return 'event: $type\ndata: ${jsonEncode(event)}\n\n';
        }).join()}data: [DONE]\n\n';
    _responses.add(
      MockResponse(
        body: sseBody,
        headers: {'content-type': 'text/event-stream'},
        isStreaming: true,
      ),
    );
  }

  /// Queues an error response.
  void queueErrorResponse(int statusCode, String message) {
    _responses.add(
      MockResponse(
        body: jsonEncode({
          'error': {'message': message, 'type': 'error', 'code': null},
        }),
        statusCode: statusCode,
      ),
    );
  }

  /// Resets the client state.
  void reset() {
    _responses.clear();
    _requests.clear();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    _requests.add(request);
    if (_responses.isEmpty) {
      throw StateError('No queued response for request: ${request.url}');
    }
    final response = _responses.removeAt(0);
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}
