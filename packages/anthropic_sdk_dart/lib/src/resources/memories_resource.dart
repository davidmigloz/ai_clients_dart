import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/response_error.dart';
import '../models/managed_agents/common/list_order.dart';
import '../models/managed_agents/memory_stores/create_memory_params.dart';
import '../models/managed_agents/memory_stores/memory.dart';
import '../models/managed_agents/memory_stores/memory_list_response.dart';
import '../models/managed_agents/memory_stores/memory_view.dart';
import '../models/managed_agents/memory_stores/update_memory_params.dart';
import '../utils/path_segment.dart';
import 'base_resource.dart';

/// Beta header for the Agent Memory API.
const _betaHeader = 'agent-memory-2026-07-22';
final _unsupportedPathCharacters = RegExp(
  r'[\p{Cc}\p{Cf}\u2028\u2029]',
  unicode: true,
);

/// Resource for memories within a single [MemoryStore] (Beta).
///
/// Obtain via `client.memoryStores.memories(memoryStoreId)`.
class MemoriesResource extends ResourceBase {
  /// The memory store ID this resource is scoped to.
  final String memoryStoreId;

  /// Creates a [MemoriesResource].
  MemoriesResource({
    required this.memoryStoreId,
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a new memory in this store.
  ///
  /// Parameters:
  /// - [request]: The create parameters.
  /// - [view]: How much of the memory's content to return in the response.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Memory> create(
    CreateMemoryParams request, {
    MemoryView? view,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    _validatePath(request.path);
    final queryParams = <String, dynamic>{'view': ?view?.toJson()};

    final url = requestBuilder.buildUrl(
      '/v1/memory_stores/${encodePathSegment(memoryStoreId, 'memoryStoreId')}/memories',
      queryParams: queryParams.isEmpty ? null : queryParams,
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

    return decodeApiJsonResponse(response, Memory.fromJson);
  }

  /// Lists memories in this store, optionally rolled up by path prefix.
  ///
  /// Parameters:
  /// - [pathPrefix]: Restrict results to memories whose path starts with this
  ///   prefix. Must end with `/` and matches whole path segments.
  /// - [depth]: Roll up entries deeper than this into [MemoryPrefix] items.
  ///   Only `0`, `1`, or omitted are accepted.
  /// - [orderBy]: Field to sort by (e.g., `path`, `updated_at`). Ignored by
  ///   the server — results are returned in a stable, server-defined order.
  /// - [order]: Sort order. Ignored by the server — results are returned in
  ///   a stable, server-defined order.
  /// - [limit]: Maximum number of items to return.
  /// - [page]: Pagination token from a previous response. Cursors issued
  ///   under the `managed-agents-2026-04-01` header are not valid — restart
  ///   from the first page.
  /// - [view]: How much of each memory's content to return.
  /// - [abortTrigger]: Allows canceling the request.
  Future<MemoryListResponse> list({
    String? pathPrefix,
    int? depth,
    String? orderBy,
    ListOrder? order,
    int? limit,
    String? page,
    MemoryView? view,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    if (pathPrefix != null && !pathPrefix.endsWith('/')) {
      throw ArgumentError('Memory path prefixes must end with /');
    }
    if (depth != null && depth != 0 && depth != 1) {
      throw ArgumentError.value(depth, 'depth', 'Expected 0 or 1');
    }
    final queryParams = <String, dynamic>{
      'path_prefix': ?pathPrefix,
      'depth': ?depth?.toString(),
      'order_by': ?orderBy,
      'order': ?order?.toJson(),
      'limit': ?limit?.toString(),
      'page': ?page,
      'view': ?view?.toJson(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/memory_stores/${encodePathSegment(memoryStoreId, 'memoryStoreId')}/memories',
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

    return decodeApiJsonResponse(response, MemoryListResponse.fromJson);
  }

  /// Retrieves a single memory.
  ///
  /// Parameters:
  /// - [memoryId]: The ID of the memory to retrieve.
  /// - [view]: How much of the memory's content to return.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Memory> retrieve(
    String memoryId, {
    MemoryView? view,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{'view': ?view?.toJson()};

    final url = requestBuilder.buildUrl(
      '/v1/memory_stores/${encodePathSegment(memoryStoreId, 'memoryStoreId')}'
      '/memories/${encodePathSegment(memoryId, 'memoryId')}',
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

    return decodeApiJsonResponse(response, Memory.fromJson);
  }

  /// Updates a memory.
  ///
  /// Parameters:
  /// - [memoryId]: The ID of the memory to update.
  /// - [request]: The update parameters.
  /// - [view]: How much of the memory's content to return in the response.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Memory> update(
    String memoryId,
    UpdateMemoryParams request, {
    MemoryView? view,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    if (request.path case final path?) _validatePath(path);
    final queryParams = <String, dynamic>{'view': ?view?.toJson()};

    final url = requestBuilder.buildUrl(
      '/v1/memory_stores/${encodePathSegment(memoryStoreId, 'memoryStoreId')}'
      '/memories/${encodePathSegment(memoryId, 'memoryId')}',
      queryParams: queryParams.isEmpty ? null : queryParams,
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

    return decodeApiJsonResponse(response, Memory.fromJson);
  }

  /// Deletes a memory.
  ///
  /// Parameters:
  /// - [memoryId]: The ID of the memory to delete.
  /// - [expectedContentSha256]: If set, the delete only succeeds when the
  ///   memory's current content SHA-256 matches.
  /// - [abortTrigger]: Allows canceling the request.
  Future<DeletedMemory> delete(
    String memoryId, {
    String? expectedContentSha256,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'expected_content_sha256': ?expectedContentSha256,
    };

    final url = requestBuilder.buildUrl(
      '/v1/memory_stores/${encodePathSegment(memoryStoreId, 'memoryStoreId')}'
      '/memories/${encodePathSegment(memoryId, 'memoryId')}',
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return decodeApiJsonResponse(response, DeletedMemory.fromJson);
  }
}

void _validatePath(String path) {
  final segments = path.split('/').skip(1);
  if (!path.startsWith('/') ||
      segments.isEmpty ||
      segments.length > 20 ||
      segments.any((s) => s.isEmpty || s == '.' || s == '..') ||
      utf8.encode(path).length > 1024 ||
      _unsupportedPathCharacters.hasMatch(path)) {
    throw ArgumentError(
      'Memory paths must contain 1 to 20 nonempty segments, start with /, '
      'fit in 1024 UTF-8 bytes, and use no dot segments or control characters',
    );
  }
}
