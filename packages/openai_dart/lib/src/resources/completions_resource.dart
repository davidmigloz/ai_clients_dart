import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/completions/completions.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

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
class CompletionsResource extends ResourceBase with StreamingResource {
  /// Creates a [CompletionsResource].
  CompletionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

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
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return Completion.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
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
  /// A stream of [Completion] chunks.
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
  /// await for (final completion in stream) {
  ///   stdout.write(completion.text);
  /// }
  /// ```
  Stream<Completion> createStream(
    CompletionRequest request, {
    Future<void>? abortTrigger,
  }) {
    // Ensure stream is enabled in the request body
    final requestBody = request.toJson();
    requestBody['stream'] = true;

    return streamSseEvents(
      endpoint: _endpoint,
      body: requestBody,
      abortTrigger: abortTrigger,
    ).map((json) {
      final sseEvent = json['_event'] as String?;
      final error = json['error'];
      if (sseEvent == 'error' || error != null) {
        throwInlineStreamError(json, sseEvent, error);
      }
      return Completion.fromJson(json);
    });
  }
}
