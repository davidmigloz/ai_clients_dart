import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_agents/common/list_order.dart';
import '../models/managed_agents/sessions/create_session_params.dart';
import '../models/managed_agents/sessions/session.dart';
import '../models/managed_agents/sessions/session_list_response.dart';
import '../models/managed_agents/sessions/update_session_params.dart';
import 'base_resource.dart';
import 'session_events_resource.dart';
import 'session_resources_resource.dart';

/// Beta header for the Managed Agents API.
const _betaHeader = 'managed-agents-2026-04-01';

/// Resource for the Sessions API (Beta).
///
/// Sessions represent an interactive conversation between a user and
/// a managed agent. This is a beta feature and requires the
/// `anthropic-beta` header.
class SessionsResource extends ResourceBase {
  /// Creates a [SessionsResource].
  SessionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Returns a [SessionEventsResource] scoped to the given [sessionId].
  SessionEventsResource events(String sessionId) {
    return SessionEventsResource(
      sessionId: sessionId,
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Returns a [SessionResourcesResource] scoped to the given [sessionId].
  SessionResourcesResource resources(String sessionId) {
    return SessionResourcesResource(
      sessionId: sessionId,
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Creates a new session.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Session> create(
    CreateSessionParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/sessions');
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

    return Session.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Lists sessions.
  ///
  /// Parameters:
  /// - [agentId]: Filter sessions by agent ID.
  /// - [agentVersion]: Filter sessions by agent version.
  /// - [order]: Sort order.
  /// - [limit]: Maximum number of sessions to return.
  /// - [page]: Pagination token from a previous response.
  /// - [createdAtGt]: Filter sessions created after this ISO 8601 timestamp.
  /// - [createdAtGte]: Filter sessions created at or after this timestamp.
  /// - [createdAtLt]: Filter sessions created before this timestamp.
  /// - [createdAtLte]: Filter sessions created at or before this timestamp.
  /// - [includeArchived]: Whether to include archived sessions.
  /// - [abortTrigger]: Allows canceling the request.
  Future<ListSessionsResponse> list({
    String? agentId,
    int? agentVersion,
    ListOrder? order,
    int? limit,
    String? page,
    String? createdAtGt,
    String? createdAtGte,
    String? createdAtLt,
    String? createdAtLte,
    bool? includeArchived,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'agent_id': ?agentId,
      'agent_version': ?agentVersion?.toString(),
      'order': ?order?.toJson(),
      'limit': ?limit?.toString(),
      'page': ?page,
      'created_at[gt]': ?createdAtGt,
      'created_at[gte]': ?createdAtGte,
      'created_at[lt]': ?createdAtLt,
      'created_at[lte]': ?createdAtLte,
      'include_archived': ?includeArchived?.toString(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/sessions',
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

    return ListSessionsResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a specific session.
  ///
  /// Parameters:
  /// - [sessionId]: The ID of the session to retrieve.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Session> retrieve(
    String sessionId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/sessions/$sessionId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Session.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Updates a session.
  ///
  /// Parameters:
  /// - [sessionId]: The ID of the session to update.
  /// - [request]: The update parameters.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Session> update(
    String sessionId,
    UpdateSessionParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/sessions/$sessionId');
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

    return Session.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Deletes a session.
  ///
  /// Parameters:
  /// - [sessionId]: The ID of the session to delete.
  /// - [abortTrigger]: Allows canceling the request.
  Future<DeletedSession> delete(
    String sessionId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/sessions/$sessionId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return DeletedSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Archives a session.
  ///
  /// Parameters:
  /// - [sessionId]: The ID of the session to archive.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Session> archive(
    String sessionId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/sessions/$sessionId/archive');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Session.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
