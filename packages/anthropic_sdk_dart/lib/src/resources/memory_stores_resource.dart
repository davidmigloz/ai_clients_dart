import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_agents/memory_stores/create_memory_store_params.dart';
import '../models/managed_agents/memory_stores/memory_store.dart';
import '../models/managed_agents/memory_stores/memory_store_list_response.dart';
import '../models/managed_agents/memory_stores/update_memory_store_params.dart';
import 'base_resource.dart';
import 'memories_resource.dart';
import 'memory_versions_resource.dart';

/// Beta header for the Managed Agents API.
const _betaHeader = 'managed-agents-2026-04-01';

/// Resource for the Memory Stores API (Beta).
///
/// Memory stores are containers for [Memory] objects that can be mounted into
/// agent sessions. This is a beta feature and requires the `anthropic-beta`
/// header (sent automatically by every method on this resource).
class MemoryStoresResource extends ResourceBase {
  /// Creates a [MemoryStoresResource].
  MemoryStoresResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Returns a [MemoriesResource] scoped to the given memory store.
  MemoriesResource memories(String memoryStoreId) {
    return MemoriesResource(
      memoryStoreId: memoryStoreId,
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Returns a [MemoryVersionsResource] scoped to the given memory store.
  MemoryVersionsResource memoryVersions(String memoryStoreId) {
    return MemoryVersionsResource(
      memoryStoreId: memoryStoreId,
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Creates a new memory store.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<MemoryStore> create(
    CreateMemoryStoreParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/memory_stores');
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

    return MemoryStore.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists memory stores.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of stores to return.
  /// - [page]: Pagination token from a previous response.
  /// - [includeArchived]: Whether to include archived stores.
  /// - [createdAtGte]: Lower bound (inclusive) ISO 8601 timestamp.
  /// - [createdAtLte]: Upper bound (inclusive) ISO 8601 timestamp.
  /// - [abortTrigger]: Allows canceling the request.
  Future<MemoryStoreListResponse> list({
    int? limit,
    String? page,
    bool? includeArchived,
    String? createdAtGte,
    String? createdAtLte,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
      'include_archived': ?includeArchived?.toString(),
      'created_at[gte]': ?createdAtGte,
      'created_at[lte]': ?createdAtLte,
    };

    final url = requestBuilder.buildUrl(
      '/v1/memory_stores',
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

    return MemoryStoreListResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a single memory store.
  ///
  /// Parameters:
  /// - [memoryStoreId]: The ID of the memory store to retrieve.
  /// - [abortTrigger]: Allows canceling the request.
  Future<MemoryStore> retrieve(
    String memoryStoreId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/memory_stores/$memoryStoreId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return MemoryStore.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Updates a memory store.
  ///
  /// Parameters:
  /// - [memoryStoreId]: The ID of the memory store to update.
  /// - [request]: The update parameters.
  /// - [abortTrigger]: Allows canceling the request.
  Future<MemoryStore> update(
    String memoryStoreId,
    UpdateMemoryStoreParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/memory_stores/$memoryStoreId');
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

    return MemoryStore.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Deletes a memory store.
  ///
  /// Parameters:
  /// - [memoryStoreId]: The ID of the memory store to delete.
  /// - [abortTrigger]: Allows canceling the request.
  Future<DeletedMemoryStore> delete(
    String memoryStoreId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/memory_stores/$memoryStoreId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return DeletedMemoryStore.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Archives a memory store.
  ///
  /// Parameters:
  /// - [memoryStoreId]: The ID of the memory store to archive.
  /// - [abortTrigger]: Allows canceling the request.
  Future<MemoryStore> archive(
    String memoryStoreId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/memory_stores/$memoryStoreId/archive',
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

    return MemoryStore.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
