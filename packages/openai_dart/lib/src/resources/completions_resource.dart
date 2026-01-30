import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../models/completions/completions.dart';
import '../utils/request_id.dart';
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
    final url = Uri.parse('${client.config.baseUrl}$_endpoint');
    final httpRequest = http.Request('POST', url);

    _addStreamHeaders(httpRequest);

    final streamRequest = request.toJson();
    streamRequest['stream'] = true;
    httpRequest.body = jsonEncode(streamRequest);

    final httpClient = http.Client();
    final requestId = httpRequest.headers['X-Request-ID']!;

    // Set up abort monitoring if provided
    if (abortTrigger != null) {
      // ignore: unawaited_futures
      abortTrigger.then((_) => httpClient.close());
    }

    try {
      final response = await httpClient.send(httpRequest);

      if (response.statusCode >= 400) {
        final body = await response.stream.bytesToString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final error = json['error'] as Map<String, dynamic>?;
        throw createApiException(
          statusCode: response.statusCode,
          message: error?['message'] as String? ?? 'Unknown error',
          type: error?['type'] as String?,
          code: error?['code'] as String?,
          requestId: requestId,
          body: json,
        );
      }

      const parser = SseParser();
      await for (final json in parser.parse(response.stream)) {
        yield json;
      }
    } on AbortedException {
      rethrow;
    } finally {
      httpClient.close();
    }
  }

  void _addStreamHeaders(http.Request request) {
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'text/event-stream';
    request.headers['X-Request-ID'] = generateRequestId();

    if (client.config.authProvider case final authProvider?) {
      request.headers.addAll(authProvider.getHeaders());
    }
    if (client.config.organization case final org?) {
      request.headers['OpenAI-Organization'] = org;
    }
    if (client.config.project case final proj?) {
      request.headers['OpenAI-Project'] = proj;
    }
    request.headers.addAll(client.config.defaultHeaders);
  }
}
