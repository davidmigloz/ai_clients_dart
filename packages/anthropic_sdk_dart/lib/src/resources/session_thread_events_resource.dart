import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_agents/events/session_event.dart';
import '../models/managed_agents/events/session_event_list_response.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Beta header for the Managed Agents API.
const _betaHeader = 'managed-agents-2026-04-01';

/// Resource for events scoped to a specific session thread (Beta).
///
/// Events represent the messages, tool calls, and status changes within a
/// thread. Access either via paginated `list()` or live SSE `stream()`.
class SessionThreadEventsResource extends ResourceBase with StreamingResource {
  /// The session ID this resource is scoped to.
  final String sessionId;

  /// The thread ID this resource is scoped to.
  final String threadId;

  /// Creates a [SessionThreadEventsResource].
  SessionThreadEventsResource({
    required this.sessionId,
    required this.threadId,
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists events for the thread.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of events to return.
  /// - [page]: Pagination token from a previous response.
  /// - [abortTrigger]: Allows canceling the request.
  Future<ListSessionEventsResponse> list({
    int? limit,
    String? page,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
    };

    final url = requestBuilder.buildUrl(
      '/v1/sessions/$sessionId/threads/$threadId/events',
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return ListSessionEventsResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Streams events from the thread via SSE.
  ///
  /// Parameters:
  /// - [lastEventId]: Resume streaming from after this event ID.
  /// - [abortTrigger]: Allows canceling the stream.
  ///
  /// Uses the eager-guard wrapper pattern so `ensureNotClosed()` runs at call
  /// time rather than on `.listen()`.
  Stream<SessionEvent> stream({
    String? lastEventId,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _streamImpl(lastEventId: lastEventId, abortTrigger: abortTrigger);
  }

  Stream<SessionEvent> _streamImpl({
    String? lastEventId,
    Future<void>? abortTrigger,
  }) async* {
    final queryParams = <String, dynamic>{'last_event_id': ?lastEventId};

    final eventStream = getStream(
      '/v1/sessions/$sessionId/threads/$threadId/stream',
      queryParams: queryParams.isEmpty ? null : queryParams,
      headers: {'anthropic-beta': _betaHeader},
      abortTrigger: abortTrigger,
    );

    await for (final event in eventStream) {
      yield SessionEvent.fromJson(event);
    }
  }
}
