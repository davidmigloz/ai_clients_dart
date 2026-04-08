import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/observability/chat_completion_event.dart';
import '../../models/observability/chat_completion_event_ids.dart';
import '../../models/observability/chat_completion_events.dart';
import '../../models/observability/get_chat_completion_event_ids_in_schema.dart';
import '../../models/observability/get_chat_completion_events_in_schema.dart';
import '../../models/observability/judge_output.dart';
import '../../models/observability/post_chat_completion_event_judging_in_schema.dart';
import '../base_resource.dart';

/// Resource for chat completion event operations.
///
/// Provides access to search, retrieve, and judge chat completion events
/// captured by the observability system.
///
/// Example usage:
/// ```dart
/// // Search events
/// final events = await client.observability.chatCompletionEvents.search(
///   request: GetChatCompletionEventsInSchema(
///     searchParams: FilterPayload(),
///   ),
/// );
///
/// // Get a specific event
/// final event = await client.observability.chatCompletionEvents.get(
///   eventId: 'event-123',
/// );
/// ```
class ChatCompletionEventsResource extends ResourceBase {
  /// Creates a [ChatCompletionEventsResource].
  ChatCompletionEventsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Searches for chat completion events.
  Future<ChatCompletionEvents> search({
    required GetChatCompletionEventsInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/chat-completion-events/search',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ChatCompletionEvents.fromJson(responseBody);
  }

  /// Searches for chat completion event IDs.
  ///
  /// Alternative to [search] that returns only event IDs and can return
  /// many IDs at once.
  Future<ChatCompletionEventIds> searchIds({
    required GetChatCompletionEventIdsInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/chat-completion-events/search-ids',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ChatCompletionEventIds.fromJson(responseBody);
  }

  /// Gets a specific chat completion event by ID.
  Future<ChatCompletionEvent> get({required String eventId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/chat-completion-events/$eventId',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ChatCompletionEvent.fromJson(responseBody);
  }

  /// Runs a judge on a chat completion event.
  Future<JudgeOutput> liveJudging({
    required String eventId,
    required PostChatCompletionEventJudgingInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/chat-completion-events/$eventId/live-judging',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return JudgeOutput.fromJson(responseBody);
  }

  /// Gets events similar to the given event.
  Future<ChatCompletionEvents> getSimilarEvents({
    required String eventId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/chat-completion-events/$eventId/similar-events',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ChatCompletionEvents.fromJson(responseBody);
  }
}
