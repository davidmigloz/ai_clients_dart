import 'dart:convert';

import '../errors/exceptions.dart';
import '../models/completions/completions.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';

/// Resource for Completions API operations (Legacy).
///
/// **Note:** This API is deprecated. Use chat completions for new applications.
///
/// Access this resource through [OpenAIClient.completions].
///
/// ## Example
///
/// ```dart
/// final completion = await client.completions.create(
///   CompletionRequest(
///     model: 'gpt-3.5-turbo-instruct',
///     prompt: 'Say this is a test',
///     maxTokens: 10,
///   ),
/// );
/// print(completion.text);
/// ```
class CompletionsResource extends BaseResource {
  /// Creates a [CompletionsResource] with the given client.
  CompletionsResource(super.client);

  static const _endpoint = '/completions';

  /// Creates a completion (legacy).
  ///
  /// **Note:** This API is deprecated. Use [ChatResource] for new applications.
  ///
  /// ## Parameters
  ///
  /// - [request] - The completion request.
  ///
  /// ## Returns
  ///
  /// A [Completion] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final completion = await client.completions.create(
  ///   CompletionRequest(
  ///     model: 'gpt-3.5-turbo-instruct',
  ///     prompt: 'Once upon a time',
  ///     maxTokens: 50,
  ///   ),
  /// );
  /// print(completion.text);
  /// ```
  Future<Completion> create(
    CompletionRequest request, {
    Future<void>? abortTrigger,
  }) async {
    final json = await postJson(
      _endpoint,
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );
    return Completion.fromJson(json);
  }

  /// Creates a streaming completion (legacy).
  ///
  /// **Note:** This API is deprecated. Use [ChatResource] for new applications.
  ///
  /// ## Parameters
  ///
  /// - [request] - The completion request.
  /// - [abortTrigger] - Optional future that cancels the stream when completed.
  ///
  /// ## Returns
  ///
  /// A stream of completion chunks as JSON maps.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = client.completions.createStream(
  ///   CompletionRequest(
  ///     model: 'gpt-3.5-turbo-instruct',
  ///     prompt: 'Once upon a time',
  ///     maxTokens: 50,
  ///   ),
  /// );
  ///
  /// await for (final chunk in stream) {
  ///   final text = chunk['choices'][0]['text'];
  ///   stdout.write(text);
  /// }
  /// ```
  Stream<Map<String, dynamic>> createStream(
    CompletionRequest request, {
    Future<void>? abortTrigger,
  }) async* {
    // Ensure stream is enabled in the request body
    final requestBody = request.toJson();
    requestBody['stream'] = true;

    final response = await client.sendStream(
      endpoint: _endpoint,
      body: requestBody,
      abortTrigger: abortTrigger,
    );

    // Extract request ID from response headers for error reporting
    final requestId =
        response.headers['x-request-id'] ??
        response.request?.headers['X-Request-ID'] ??
        'unknown';

    try {
      if (response.statusCode >= 400) {
        final body = await response.stream.bytesToString();
        throw _parseStreamError(response.statusCode, body, requestId);
      }

      const parser = SseParser();
      await for (final json in parser.parse(response.stream)) {
        yield json;
      }
    } on AbortedException {
      rethrow;
    }
  }

  /// Parses an error response from a streaming request.
  ApiException _parseStreamError(
    int statusCode,
    String body,
    String requestId,
  ) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      return createApiException(
        statusCode: statusCode,
        message: error?['message'] as String? ?? 'Unknown error',
        type: error?['type'] as String?,
        code: error?['code'] as String?,
        requestId: requestId,
        body: json,
      );
    } catch (_) {
      return ApiException(
        message: body.isNotEmpty ? body : 'HTTP $statusCode error',
        statusCode: statusCode,
        requestId: requestId,
      );
    }
  }
}
