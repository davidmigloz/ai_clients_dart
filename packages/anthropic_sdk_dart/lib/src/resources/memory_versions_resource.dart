import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_agents/memory_stores/memory_version.dart';
import '../models/managed_agents/memory_stores/memory_version_list_response.dart';
import '../models/managed_agents/memory_stores/memory_view.dart';
import 'base_resource.dart';

/// Beta header for the Managed Agents API.
const _betaHeader = 'managed-agents-2026-04-01';

/// Resource for memory versions within a single [MemoryStore] (Beta).
///
/// Obtain via `client.memoryStores.memoryVersions(memoryStoreId)`.
class MemoryVersionsResource extends ResourceBase {
  /// The memory store ID this resource is scoped to.
  final String memoryStoreId;

  /// Creates a [MemoryVersionsResource].
  MemoryVersionsResource({
    required this.memoryStoreId,
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists memory versions in this store.
  ///
  /// Parameters:
  /// - [memoryId]: Filter to versions of a specific memory.
  /// - [sessionId]: Filter to versions created by a specific session.
  /// - [apiKeyId]: Filter to versions created by a specific API key.
  /// - [operation]: Filter by operation (created/modified/deleted).
  /// - [createdAtGte]: Lower bound (inclusive) ISO 8601 timestamp.
  /// - [createdAtLte]: Upper bound (inclusive) ISO 8601 timestamp.
  /// - [limit]: Maximum number of items to return.
  /// - [page]: Pagination token from a previous response.
  /// - [view]: How much of each version's content to return.
  /// - [abortTrigger]: Allows canceling the request.
  Future<MemoryVersionListResponse> list({
    String? memoryId,
    String? sessionId,
    String? apiKeyId,
    MemoryVersionOperation? operation,
    String? createdAtGte,
    String? createdAtLte,
    int? limit,
    String? page,
    MemoryView? view,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'memory_id': ?memoryId,
      'session_id': ?sessionId,
      'api_key_id': ?apiKeyId,
      'operation': ?operation?.toJson(),
      'created_at[gte]': ?createdAtGte,
      'created_at[lte]': ?createdAtLte,
      'limit': ?limit?.toString(),
      'page': ?page,
      'view': ?view?.toJson(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/memory_stores/$memoryStoreId/memory_versions',
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

    return MemoryVersionListResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a single memory version.
  ///
  /// Parameters:
  /// - [memoryVersionId]: The ID of the memory version to retrieve.
  /// - [view]: How much of the version's content to return.
  /// - [abortTrigger]: Allows canceling the request.
  Future<MemoryVersion> retrieve(
    String memoryVersionId, {
    MemoryView? view,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{'view': ?view?.toJson()};

    final url = requestBuilder.buildUrl(
      '/v1/memory_stores/$memoryStoreId/memory_versions/$memoryVersionId',
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

    return MemoryVersion.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Redacts a memory version, removing its content while preserving the
  /// version record.
  ///
  /// Parameters:
  /// - [memoryVersionId]: The ID of the memory version to redact.
  /// - [abortTrigger]: Allows canceling the request.
  Future<MemoryVersion> redact(
    String memoryVersionId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/memory_stores/$memoryStoreId/memory_versions/$memoryVersionId/redact',
    );
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

    return MemoryVersion.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
