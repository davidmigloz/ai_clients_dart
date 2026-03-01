import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chatkit/chatkit.dart';
import 'base_resource.dart';

/// Resource for ChatKit operations.
///
/// ChatKit provides a UI toolkit for building chat interfaces powered
/// by OpenAI's workflows.
///
/// Access this resource through [OpenAIClient.chatkit].
///
/// ## Example
///
/// ```dart
/// // Create a session
/// final session = await client.chatkit.sessions.create(
///   CreateChatSessionRequest(
///     workflow: WorkflowParam(id: 'workflow-abc'),
///     user: 'user-123',
///   ),
/// );
///
/// // Use the client secret for client-side authentication
/// print('Client secret: ${session.clientSecret}');
///
/// // List threads for this user
/// final threads = await client.chatkit.threads.list();
///
/// // Get thread items
/// final items = await client.chatkit.threads.items.list(threads.data.first.id);
/// ```
class ChatkitResource extends ResourceBase {
  /// Creates a [ChatkitResource].
  ChatkitResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  ChatkitSessionsResource? _sessions;

  /// ChatKit sessions sub-resource.
  ChatkitSessionsResource get sessions => _sessions ??= ChatkitSessionsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );

  ChatkitThreadsResource? _threads;

  /// ChatKit threads sub-resource.
  ChatkitThreadsResource get threads => _threads ??= ChatkitThreadsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );
}

/// Resource for ChatKit session operations.
///
/// Sessions provide ephemeral access tokens for ChatKit workflows.
class ChatkitSessionsResource extends ResourceBase {
  /// Creates a [ChatkitSessionsResource].
  ChatkitSessionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/chatkit/sessions';
  static const _betaFeature = 'chatkit_beta=v1';

  /// Creates a new ChatKit session.
  ///
  /// ## Parameters
  ///
  /// - [request] - The session creation request.
  ///
  /// ## Returns
  ///
  /// A [ChatSession] with the client secret for authentication.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final session = await client.chatkit.sessions.create(
  ///   CreateChatSessionRequest(
  ///     workflow: WorkflowParam(id: 'workflow-abc'),
  ///     user: 'user-123',
  ///     expiresAfter: 600, // 10 minutes
  ///     rateLimits: RateLimitsParam(maxRequestsPer1Minute: 20),
  ///   ),
  /// );
  ///
  /// print('Session ID: ${session.id}');
  /// print('Expires: ${session.expiresAtDateTime}');
  /// ```
  Future<ChatSession> create(CreateChatSessionRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return ChatSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Cancels an active ChatKit session.
  ///
  /// ## Parameters
  ///
  /// - [sessionId] - The ID of the session to cancel.
  ///
  /// ## Returns
  ///
  /// The cancelled [ChatSession].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final session = await client.chatkit.sessions.cancel('sess-abc123');
  /// print('Status: ${session.status}'); // cancelled
  /// ```
  Future<ChatSession> cancel(String sessionId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$sessionId/cancel');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});
    final response = await interceptorChain.execute(httpRequest);
    return ChatSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

/// Resource for ChatKit thread operations.
///
/// Threads represent conversation histories within ChatKit.
class ChatkitThreadsResource extends ResourceBase {
  /// Creates a [ChatkitThreadsResource].
  ChatkitThreadsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/chatkit/threads';
  static const _betaFeature = 'chatkit_beta=v1';

  ChatkitThreadItemsResource? _items;

  /// Thread items sub-resource.
  ChatkitThreadItemsResource get items => _items ??= ChatkitThreadItemsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );

  /// Lists ChatKit threads.
  ///
  /// ## Parameters
  ///
  /// - [limit] - Maximum number of threads to return.
  /// - [order] - Sort order (asc or desc).
  /// - [after] - Cursor for pagination (get threads after this ID).
  /// - [before] - Cursor for pagination (get threads before this ID).
  ///
  /// ## Returns
  ///
  /// A [ChatkitThreadList] containing the threads.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final threads = await client.chatkit.threads.list(limit: 10);
  ///
  /// for (final thread in threads.data) {
  ///   print('${thread.title ?? 'Untitled'}: ${thread.status.type}');
  /// }
  /// ```
  Future<ChatkitThreadList> list({
    int? limit,
    String? order,
    String? after,
    String? before,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final url = requestBuilder.buildUrl(
      _endpoint,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return ChatkitThreadList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a ChatKit thread.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread to retrieve.
  ///
  /// ## Returns
  ///
  /// A [ChatkitThread] with the thread details.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final thread = await client.chatkit.threads.retrieve('thread-abc123');
  /// print('Title: ${thread.title}');
  /// print('User: ${thread.user}');
  /// ```
  Future<ChatkitThread> retrieve(String threadId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$threadId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return ChatkitThread.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Deletes a ChatKit thread.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread to delete.
  ///
  /// ## Returns
  ///
  /// A [DeleteChatkitThreadResponse] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.chatkit.threads.delete('thread-abc123');
  /// print('Deleted: ${result.deleted}');
  /// ```
  Future<DeleteChatkitThreadResponse> delete(String threadId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$threadId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return DeleteChatkitThreadResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

/// Resource for ChatKit thread item operations.
///
/// Thread items represent messages and other content within a thread.
class ChatkitThreadItemsResource extends ResourceBase {
  /// Creates a [ChatkitThreadItemsResource].
  ChatkitThreadItemsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _betaFeature = 'chatkit_beta=v1';

  /// Lists items in a ChatKit thread.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread.
  /// - [limit] - Maximum number of items to return.
  /// - [order] - Sort order (asc or desc).
  /// - [after] - Cursor for pagination (get items after this ID).
  /// - [before] - Cursor for pagination (get items before this ID).
  ///
  /// ## Returns
  ///
  /// A [ThreadItemList] containing the thread items.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final items = await client.chatkit.threads.items.list(
  ///   'thread-abc123',
  ///   limit: 50,
  /// );
  ///
  /// for (final item in items.data) {
  ///   print('${item.type}: ${item.id}');
  /// }
  /// ```
  Future<ThreadItemList> list(
    String threadId, {
    int? limit,
    String? order,
    String? after,
    String? before,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final url = requestBuilder.buildUrl(
      '/chatkit/threads/$threadId/items',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return ThreadItemList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
