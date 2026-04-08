import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_agents/resources/session_resource.dart';
import '../models/managed_agents/resources/session_resource_params.dart';
import 'base_resource.dart';

/// Beta header for the Managed Agents API.
const _betaHeader = 'managed-agents-2026-04-01';

/// Resource for session resources (Beta).
///
/// Session resources represent files and repositories mounted into a
/// session's container.
class SessionResourcesResource extends ResourceBase {
  /// The session ID this resource is scoped to.
  final String sessionId;

  /// Creates a [SessionResourcesResource].
  SessionResourcesResource({
    required this.sessionId,
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a new resource in the session.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<SessionResource> create(
    SessionResourceParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/sessions/$sessionId/resources');
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

    return SessionResource.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists resources in the session.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of resources to return.
  /// - [page]: Pagination token from a previous response.
  /// - [abortTrigger]: Allows canceling the request.
  Future<ListSessionResourcesResponse> list({
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
      '/v1/sessions/$sessionId/resources',
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

    return ListSessionResourcesResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a specific resource.
  ///
  /// Parameters:
  /// - [resourceId]: The ID of the resource to retrieve.
  /// - [abortTrigger]: Allows canceling the request.
  Future<SessionResource> retrieve(
    String resourceId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/sessions/$sessionId/resources/$resourceId',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return SessionResource.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Updates a resource.
  ///
  /// Parameters:
  /// - [resourceId]: The ID of the resource to update.
  /// - [request]: The update parameters.
  /// - [abortTrigger]: Allows canceling the request.
  Future<SessionResource> update(
    String resourceId,
    UpdateSessionResourceParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/sessions/$sessionId/resources/$resourceId',
    );
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

    return SessionResource.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Deletes a resource.
  ///
  /// Parameters:
  /// - [resourceId]: The ID of the resource to delete.
  /// - [abortTrigger]: Allows canceling the request.
  Future<DeletedSessionResource> delete(
    String resourceId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/sessions/$sessionId/resources/$resourceId',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return DeletedSessionResource.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
