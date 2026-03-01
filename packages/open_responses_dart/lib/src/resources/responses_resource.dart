import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/response_stream.dart';
import '../models/request/create_response_request.dart';
import '../models/response/response_resource.dart';
import '../models/streaming/streaming_event.dart';
import '../utils/sse_parser.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Resource for the Responses API.
class ResponsesResource extends ResourceBase with StreamingResource {
  /// Creates a [ResponsesResource].
  ResponsesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a response (non-streaming).
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<ResponseResource> create(
    CreateResponseRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();

    // Ensure stream is false
    final requestToSend = (request.stream ?? false)
        ? request.copyWith(stream: false)
        : request;

    final url = requestBuilder.buildUrl('/responses');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestToSend.toJson());

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return ResponseResource.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Creates a streaming response.
  ///
  /// Returns a stream of [StreamingEvent] objects.
  /// The optional [abortTrigger] allows canceling the request.
  Stream<StreamingEvent> createStream(
    CreateResponseRequest request, {
    Future<void>? abortTrigger,
  }) async* {
    ensureNotClosed?.call();
    // Ensure stream is true
    final requestToSend = request.stream != true
        ? request.copyWith(stream: true)
        : request;

    final uri = requestBuilder.buildUrl('/responses');
    final httpRequest = http.Request('POST', uri)
      ..headers.addAll(requestBuilder.buildHeaders())
      ..body = jsonEncode(requestToSend.toJson());

    // Apply authentication and send streaming request
    await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    final parser = SseParser();
    await for (final json in parser.parse(streamedResponse.stream)) {
      final cleaned = json.withoutEventType();
      // Use event type from SSE or fall back to type field
      final eventType = json.sseEventType ?? cleaned['type'] as String?;
      if (eventType != null) {
        cleaned['type'] = eventType;
      }
      yield StreamingEvent.fromJson(cleaned);
    }
  }

  /// Creates a streaming response with builder pattern.
  ///
  /// Returns a [ResponseStream] that allows registering callbacks
  /// and accessing the final response.
  ///
  /// Example:
  /// ```dart
  /// final runner = client.responses.stream(request)
  ///   ..onTextDelta((delta) => stdout.write(delta));
  ///
  /// final response = await runner.finalResponse;
  /// print('\nFinal: ${response?.outputText}');
  /// ```
  ResponseStream stream(
    CreateResponseRequest request, {
    Future<void>? abortTrigger,
  }) {
    return ResponseStream(createStream(request, abortTrigger: abortTrigger));
  }
}
