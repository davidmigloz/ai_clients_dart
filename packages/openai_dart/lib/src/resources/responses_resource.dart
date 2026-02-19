import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

import '../errors/exceptions.dart';
import '../models/responses/responses.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';
import 'input_tokens_resource.dart';

/// Resource for responses operations.
///
/// The Responses API is OpenAI's next-generation interface that unifies
/// chat completions, reasoning, and tool use into a single API with
/// support for multi-turn conversations, built-in tools, and background
/// processing.
///
/// ## Example
///
/// ```dart
/// // Basic text response
/// final response = await client.responses.create(
///   CreateResponseRequest(
///     model: 'gpt-4o',
///     input: ResponseInput.text('Hello, how are you?'),
///   ),
/// );
/// print(response.outputText);
///
/// // Streaming response
/// final stream = client.responses.createStream(
///   CreateResponseRequest(
///     model: 'gpt-4o',
///     input: ResponseInput.text('Tell me a story'),
///   ),
/// );
///
/// await for (final event in stream) {
///   if (event is OutputTextDeltaEvent) {
///     stdout.write(event.delta);
///   }
/// }
///
/// // With tools
/// final response = await client.responses.create(
///   CreateResponseRequest(
///     model: 'gpt-4o',
///     input: ResponseInput.text('What is the weather in Paris?'),
///     tools: [
///       ResponseTool.function(
///         name: 'get_weather',
///         description: 'Get the current weather',
///         parameters: {
///           'type': 'object',
///           'properties': {
///             'location': {'type': 'string'},
///           },
///           'required': ['location'],
///         },
///       ),
///     ],
///   ),
/// );
/// ```
class ResponsesResource extends BaseResource {
  /// Creates a [ResponsesResource] with the given client.
  ResponsesResource(super.client);

  static const _endpoint = '/responses';

  ResponseInputItemsResource? _inputItems;
  InputTokensResource? _inputTokens;

  /// Access to response input items operations.
  ResponseInputItemsResource get inputItems =>
      _inputItems ??= ResponseInputItemsResource(client);

  /// Access to input tokens counting operations.
  ///
  /// Allows you to calculate token usage before sending a request.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final tokenCount = await client.responses.inputTokens.count(
  ///   model: 'gpt-4o',
  ///   input: ResponseInput.text('Hello, how are you?'),
  /// );
  /// print('Input tokens: ${tokenCount.inputTokens}');
  /// ```
  InputTokensResource get inputTokens =>
      _inputTokens ??= InputTokensResource(client);

  /// Creates a response.
  ///
  /// ## Parameters
  ///
  /// - [request] - The response creation request parameters.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// A [Response] containing the model's output.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response = await client.responses.create(
  ///   CreateResponseRequest(
  ///     model: 'gpt-4o',
  ///     input: ResponseInput.text('Explain quantum computing in simple terms.'),
  ///   ),
  /// );
  /// print(response.outputText);
  /// ```
  Future<Response> create(
    CreateResponseRequest request, {
    Future<void>? abortTrigger,
  }) async {
    final json = await postJson(
      _endpoint,
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );
    return Response.fromJson(json);
  }

  /// Creates a streaming response.
  ///
  /// Returns a stream of [ResponseStreamEvent] objects as the model generates
  /// the response. This is useful for long responses where you want to
  /// display output incrementally.
  ///
  /// ## Parameters
  ///
  /// - [request] - The response creation request parameters.
  /// - [abortTrigger] - Optional future that cancels the stream when completed.
  ///
  /// ## Returns
  ///
  /// A [Stream] of [ResponseStreamEvent] objects.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = client.responses.createStream(
  ///   CreateResponseRequest(
  ///     model: 'gpt-4o',
  ///     input: ResponseInput.text('Write a poem about the ocean.'),
  ///   ),
  /// );
  ///
  /// await for (final event in stream) {
  ///   switch (event) {
  ///     case OutputTextDeltaEvent(:final delta):
  ///       stdout.write(delta);
  ///     case ResponseCompletedEvent(:final response):
  ///       print('\nDone! Used ${response.usage?.totalTokens} tokens');
  ///   }
  /// }
  /// ```
  Stream<ResponseStreamEvent> createStream(
    CreateResponseRequest request, {
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
        yield ResponseStreamEvent.fromJson(json);
      }
    } on AbortedException {
      rethrow;
    }
  }

  /// Creates a streaming response with accumulated events.
  ///
  /// Similar to [createStream], but wraps events in a [ResponseStreamAccumulator]
  /// that provides access to the accumulated state, making it easier to
  /// reconstruct the full response.
  ///
  /// ## Parameters
  ///
  /// - [request] - The response creation request parameters.
  /// - [abortTrigger] - Optional future that cancels the stream when completed.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = client.responses.createStreamWithAccumulator(
  ///   CreateResponseRequest(
  ///     model: 'gpt-4o',
  ///     input: ResponseInput.text('Hello!'),
  ///   ),
  /// );
  ///
  /// await for (final accumulator in stream) {
  ///   print('Current text: ${accumulator.text}');
  /// }
  /// ```
  Stream<ResponseStreamAccumulator> createStreamWithAccumulator(
    CreateResponseRequest request, {
    Future<void>? abortTrigger,
  }) {
    final accumulator = ResponseStreamAccumulator();
    return createStream(request, abortTrigger: abortTrigger).map((event) {
      accumulator.add(event);
      return accumulator;
    });
  }

  /// Retrieves a response by ID.
  ///
  /// ## Parameters
  ///
  /// - [responseId] - The ID of the response to retrieve.
  /// - [include] - Additional data to include in the response.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// The [Response] with the specified ID.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response = await client.responses.retrieve('resp_abc123');
  /// print(response.status);
  /// ```
  Future<Response> retrieve(
    String responseId, {
    List<Include>? include,
    Future<void>? abortTrigger,
  }) async {
    final json = await getJsonWithRepeatedParams(
      '$_endpoint/$responseId',
      queryParametersAll: _buildIncludeParams(include),
      abortTrigger: abortTrigger,
    );
    return Response.fromJson(json);
  }

  /// Converts include values to repeated query parameters format.
  Map<String, List<String>>? _buildIncludeParams(List<Include>? include) {
    if (include == null || include.isEmpty) {
      return null;
    }
    return {'include[]': include.map((e) => e.toJson()).toList()};
  }

  /// Lists responses.
  ///
  /// **Note:** This endpoint requires a session key that can only be obtained
  /// from a browser context. It cannot be used with standard API keys in
  /// server-side or CLI applications. Attempting to use a standard API key
  /// will result in an [AuthenticationException].
  ///
  /// ## Parameters
  ///
  /// - [after] - A cursor for pagination (response ID to start after).
  /// - [limit] - Maximum number of responses to return (1-100, default 20).
  /// - [order] - Sort order: 'asc' or 'desc' (default 'desc').
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// A [ResponseList] containing the responses.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final responses = await client.responses.list(limit: 10);
  /// for (final response in responses.data) {
  ///   print('${response.id}: ${response.status}');
  /// }
  /// ```
  Future<ResponseList> list({
    String? after,
    int? limit,
    String? order,
    Future<void>? abortTrigger,
  }) async {
    final queryParameters = <String, String>{};
    if (after != null) queryParameters['after'] = after;
    if (limit != null) queryParameters['limit'] = limit.toString();
    if (order != null) queryParameters['order'] = order;

    final json = await getJson(
      _endpoint,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      abortTrigger: abortTrigger,
    );
    return ResponseList.fromJson(json);
  }

  /// Deletes a response.
  ///
  /// ## Parameters
  ///
  /// - [responseId] - The ID of the response to delete.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// A [DeleteResponseResult] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.responses.delete('resp_abc123');
  /// print('Deleted: ${result.deleted}');
  /// ```
  Future<DeleteResponseResult> delete(
    String responseId, {
    Future<void>? abortTrigger,
  }) async {
    final json = await deleteJson(
      '$_endpoint/$responseId',
      abortTrigger: abortTrigger,
    );
    return DeleteResponseResult.fromJson(json);
  }

  /// Cancels a background response.
  ///
  /// This can only be used on responses that were created with `background: true`
  /// and are still in progress.
  ///
  /// ## Parameters
  ///
  /// - [responseId] - The ID of the response to cancel.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// The cancelled [Response].
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Create a background response
  /// final response = await client.responses.create(
  ///   CreateResponseRequest(
  ///     model: 'gpt-4o',
  ///     input: ResponseInput.text('Write a very long essay...'),
  ///     background: true,
  ///   ),
  /// );
  ///
  /// // Cancel it
  /// final cancelled = await client.responses.cancel(response.id);
  /// print('Status: ${cancelled.status}'); // cancelled
  /// ```
  Future<Response> cancel(
    String responseId, {
    Future<void>? abortTrigger,
  }) async {
    final json = await postJson(
      '$_endpoint/$responseId/cancel',
      body: {},
      abortTrigger: abortTrigger,
    );
    return Response.fromJson(json);
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
        param: error?['param'] as String?,
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

/// Resource for response input items operations.
///
/// Provides access to the input items of a stored response.
class ResponseInputItemsResource extends BaseResource {
  /// Creates a [ResponseInputItemsResource] with the given client.
  ResponseInputItemsResource(super.client);

  /// Lists input items for a response.
  ///
  /// ## Parameters
  ///
  /// - [responseId] - The ID of the response.
  /// - [after] - A cursor for pagination.
  /// - [before] - A cursor for pagination.
  /// - [limit] - Maximum number of items to return (1-100, default 20).
  /// - [order] - Sort order: 'asc' or 'desc' (default 'asc').
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// An [InputItemList] containing the input items.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final items = await client.responses.inputItems.list('resp_abc123');
  /// for (final item in items.data) {
  ///   print(item);
  /// }
  /// ```
  Future<InputItemList> list(
    String responseId, {
    String? after,
    String? before,
    int? limit,
    String? order,
    Future<void>? abortTrigger,
  }) async {
    final queryParameters = <String, String>{};
    if (after != null) queryParameters['after'] = after;
    if (before != null) queryParameters['before'] = before;
    if (limit != null) queryParameters['limit'] = limit.toString();
    if (order != null) queryParameters['order'] = order;

    final json = await getJson(
      '/responses/$responseId/input_items',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      abortTrigger: abortTrigger,
    );
    return InputItemList.fromJson(json);
  }
}

/// A list of input items with pagination.
@immutable
class InputItemList {
  /// The list of input items.
  final List<Item> data;

  /// The object type, always 'list'.
  final String object;

  /// Whether there are more items to fetch.
  final bool hasMore;

  /// The ID of the first item in the list.
  final String? firstId;

  /// The ID of the last item in the list.
  final String? lastId;

  /// Creates an [InputItemList].
  const InputItemList({
    required this.data,
    required this.object,
    required this.hasMore,
    this.firstId,
    this.lastId,
  });

  /// Creates an [InputItemList] from JSON.
  factory InputItemList.fromJson(Map<String, dynamic> json) {
    return InputItemList(
      data: (json['data'] as List)
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
      object: json['object'] as String,
      hasMore: json['has_more'] as bool,
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'object': object,
    'has_more': hasMore,
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
  };

  @override
  String toString() =>
      'InputItemList(data: ${data.length} items, hasMore: $hasMore)';
}
