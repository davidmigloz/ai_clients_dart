import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_agents/sessions/session_thread.dart';
import '../models/managed_agents/sessions/session_thread_list_response.dart';
import 'base_resource.dart';
import 'session_thread_events_resource.dart';

/// Beta header for the Managed Agents API.
const _betaHeader = 'managed-agents-2026-04-01';

/// Resource for session threads (Beta).
///
/// A session may be segmented into multiple threads — for example, a parent
/// orchestrator agent and one or more sub-agent threads. Each thread carries
/// its own status, usage, and stats independent of the parent session.
class SessionThreadsResource extends ResourceBase {
  /// The session ID this resource is scoped to.
  final String sessionId;

  /// Creates a [SessionThreadsResource].
  SessionThreadsResource({
    required this.sessionId,
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Returns a [SessionThreadEventsResource] scoped to the given [threadId].
  SessionThreadEventsResource events(String threadId) {
    return SessionThreadEventsResource(
      sessionId: sessionId,
      threadId: threadId,
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Retrieves a single thread by ID.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<SessionThread> retrieve(
    String threadId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/sessions/$sessionId/threads/$threadId',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return SessionThread.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists threads under the session.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of threads to return.
  /// - [page]: Pagination token from a previous response.
  /// - [abortTrigger]: Allows canceling the request.
  Future<ListSessionThreadsResponse> list({
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
      '/v1/sessions/$sessionId/threads',
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

    return ListSessionThreadsResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Archives a thread. Returns the updated thread with `archivedAt` set.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<SessionThread> archive(
    String threadId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/sessions/$sessionId/threads/$threadId/archive',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return SessionThread.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
