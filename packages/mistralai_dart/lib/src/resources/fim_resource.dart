import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/fim/fim_completion_request.dart';
import '../models/fim/fim_completion_response.dart';
import '../models/fim/fim_completion_stream_response.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Resource for the Fill-in-the-Middle (FIM) Completions API.
///
/// FIM allows you to define the starting point of code using a prompt,
/// and the ending point using an optional suffix. The model generates
/// the code that fits in between.
///
/// This is ideal for code completion tasks, especially with Codestral models.
///
/// Example usage:
/// ```dart
/// final response = await client.fim.create(
///   request: FimCompletionRequest(
///     model: 'codestral-latest',
///     prompt: 'def fibonacci(n):\n    if n <= 1:\n        return n\n    else:\n        return ',
///     suffix: '\n\nprint(fibonacci(10))',
///   ),
/// );
/// print(response.choices.first.message);
/// ```
class FimResource extends ResourceBase with StreamingResource {
  /// Creates a [FimResource].
  FimResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Generates a FIM completion.
  ///
  /// The [request] contains the model, prompt, suffix, and completion settings.
  ///
  /// Returns a [FimCompletionResponse] containing the generated code.
  ///
  /// Throws [MistralException] if the request fails.
  Future<FimCompletionResponse> create({
    required FimCompletionRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/fim/completions');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is false for non-streaming
    final requestData = request.copyWith(stream: false);

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return FimCompletionResponse.fromJson(responseBody);
  }

  /// Generates a FIM completion with streaming.
  ///
  /// The [request] contains the model, prompt, suffix, and completion settings.
  ///
  /// Returns a stream of [FimCompletionStreamResponse] chunks.
  ///
  /// Example:
  /// ```dart
  /// final stream = client.fim.createStream(
  ///   request: FimCompletionRequest(
  ///     model: 'codestral-latest',
  ///     prompt: 'function hello() {',
  ///     suffix: '}',
  ///   ),
  /// );
  ///
  /// await for (final chunk in stream) {
  ///   final content = chunk.choices.first.delta;
  ///   if (content != null) {
  ///     stdout.write(content);
  ///   }
  /// }
  /// ```
  Stream<FimCompletionStreamResponse> createStream({
    required FimCompletionRequest request,
  }) async* {
    final url = requestBuilder.buildUrl('/v1/fim/completions');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is true for streaming
    final requestData = request.copyWith(stream: true);

    var httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    // Use mixin methods for streaming request handling
    httpRequest = await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    // Parse SSE stream
    await for (final json in parseSSE(streamedResponse.stream)) {
      yield FimCompletionStreamResponse.fromJson(json);
    }
  }
}
