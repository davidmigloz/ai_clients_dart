import '../client/openai_client.dart';
import '../models/chatkit/chatkit.dart';
import 'beta_base_resource.dart';

/// The beta version header value for ChatKit API.
const _chatkitBetaVersion = 'chatkit_beta=v1';

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
class ChatkitResource extends BetaBaseResource {
  /// Creates a [ChatkitResource] with the given client.
  ChatkitResource(super.client);

  @override
  String get betaVersion => _chatkitBetaVersion;

  ChatkitSessionsResource? _sessions;

  /// ChatKit sessions sub-resource.
  ChatkitSessionsResource get sessions =>
      _sessions ??= ChatkitSessionsResource(client);

  ChatkitThreadsResource? _threads;

  /// ChatKit threads sub-resource.
  ChatkitThreadsResource get threads =>
      _threads ??= ChatkitThreadsResource(client);
}

/// Resource for ChatKit session operations.
///
/// Sessions provide ephemeral access tokens for ChatKit workflows.
class ChatkitSessionsResource extends BetaBaseResource {
  /// Creates a [ChatkitSessionsResource] with the given client.
  ChatkitSessionsResource(super.client);

  @override
  String get betaVersion => _chatkitBetaVersion;

  static const _endpoint = '/chatkit/sessions';

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
    final json = await postJson(_endpoint, body: request.toJson());
    return ChatSession.fromJson(json);
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
    final json = await postJson('$_endpoint/$sessionId/cancel', body: {});
    return ChatSession.fromJson(json);
  }
}

/// Resource for ChatKit thread operations.
///
/// Threads represent conversation histories within ChatKit.
class ChatkitThreadsResource extends BetaBaseResource {
  /// Creates a [ChatkitThreadsResource] with the given client.
  ChatkitThreadsResource(super.client);

  @override
  String get betaVersion => _chatkitBetaVersion;

  static const _endpoint = '/chatkit/threads';

  ChatkitThreadItemsResource? _items;

  /// Thread items sub-resource.
  ChatkitThreadItemsResource get items =>
      _items ??= ChatkitThreadItemsResource(client);

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
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final json = await getJson(
      _endpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return ChatkitThreadList.fromJson(json);
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
    final json = await getJson('$_endpoint/$threadId');
    return ChatkitThread.fromJson(json);
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
    final json = await deleteJson('$_endpoint/$threadId');
    return DeleteChatkitThreadResponse.fromJson(json);
  }
}

/// Resource for ChatKit thread item operations.
///
/// Thread items represent messages and other content within a thread.
class ChatkitThreadItemsResource extends BetaBaseResource {
  /// Creates a [ChatkitThreadItemsResource] with the given client.
  ChatkitThreadItemsResource(super.client);

  @override
  String get betaVersion => _chatkitBetaVersion;

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
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final json = await getJson(
      '/chatkit/threads/$threadId/items',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return ThreadItemList.fromJson(json);
  }
}
