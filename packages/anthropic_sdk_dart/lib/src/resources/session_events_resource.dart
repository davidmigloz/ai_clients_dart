import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_agents/common/list_order.dart';
import '../models/managed_agents/events/send_event_params.dart';
import '../models/managed_agents/events/session_event.dart';
import '../models/managed_agents/events/session_event_list_response.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Beta header for the Managed Agents API.
const _betaHeader = 'managed-agents-2026-04-01';

/// Resource for session events (Beta).
///
/// Events represent the messages, tool calls, and status changes in a session.
class SessionEventsResource extends ResourceBase with StreamingResource {
  /// The session ID this resource is scoped to.
  final String sessionId;

  /// Creates a [SessionEventsResource].
  SessionEventsResource({
    required this.sessionId,
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists events for the session.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of events to return.
  /// - [order]: Sort order.
  /// - [page]: Pagination token from a previous response.
  /// - [abortTrigger]: Allows canceling the request.
  Future<ListSessionEventsResponse> list({
    int? limit,
    ListOrder? order,
    String? page,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'order': ?order?.toJson(),
      'page': ?page,
    };

    final url = requestBuilder.buildUrl(
      '/v1/sessions/$sessionId/events',
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

  /// Sends events to the session.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<SendSessionEventsResponse> send(
    SendSessionEventsParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/sessions/$sessionId/events');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return SendSessionEventsResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Streams events from the session via SSE.
  ///
  /// Parameters:
  /// - [lastEventId]: Resume streaming from after this event ID.
  /// - [abortTrigger]: Allows canceling the stream.
  Stream<SessionEvent> stream({
    String? lastEventId,
    Future<void>? abortTrigger,
  }) async* {
    final queryParams = <String, dynamic>{'last_event_id': ?lastEventId};

    final eventStream = getStream(
      '/v1/sessions/$sessionId/events/stream',
      queryParams: queryParams.isEmpty ? null : queryParams,
      headers: {'anthropic-beta': _betaHeader},
      abortTrigger: abortTrigger,
    );

    await for (final event in eventStream) {
      yield SessionEvent.fromJson(event);
    }
  }
}
