import '../models/threads/threads.dart';
import 'beta_base_resource.dart';
import 'messages_resource.dart';
import 'runs_resource.dart';

/// Resource for Threads API operations (Beta).
///
/// Threads represent conversations with an assistant.
///
/// Access this resource through [OpenAIClient.beta.threads].
///
/// ## Example
///
/// ```dart
/// // Create a thread
/// final thread = await client.beta.threads.create();
///
/// // Create with initial messages
/// final thread = await client.beta.threads.create(
///   CreateThreadRequest(
///     messages: [
///       ThreadMessage(role: 'user', content: 'Hello!'),
///     ],
///   ),
/// );
/// ```
class ThreadsResource extends BetaBaseResource {
  /// Creates a [ThreadsResource] with the given client.
  ThreadsResource(super.client);

  static const _endpoint = '/threads';

  MessagesResource? _messages;
  RunsResource? _runs;

  /// Access to thread messages.
  MessagesResource get messages => _messages ??= MessagesResource(client);

  /// Access to thread runs.
  RunsResource get runs => _runs ??= RunsResource(client);

  /// Creates a new thread.
  ///
  /// ## Parameters
  ///
  /// - [request] - Optional creation request with initial messages.
  ///
  /// ## Returns
  ///
  /// A [Thread] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Empty thread
  /// final thread = await client.beta.threads.create();
  ///
  /// // Thread with initial messages
  /// final thread = await client.beta.threads.create(
  ///   CreateThreadRequest(
  ///     messages: [
  ///       ThreadMessage(role: 'user', content: 'Help me with math'),
  ///     ],
  ///     metadata: {'user_id': '123'},
  ///   ),
  /// );
  /// ```
  Future<Thread> create([CreateThreadRequest? request]) async {
    final json = await postJson(_endpoint, body: request?.toJson() ?? {});
    return Thread.fromJson(json);
  }

  /// Retrieves a thread by ID.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread to retrieve.
  ///
  /// ## Returns
  ///
  /// A [Thread] with the thread information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final thread = await client.beta.threads.retrieve('thread_abc123');
  /// print('Created: ${thread.createdAt}');
  /// ```
  Future<Thread> retrieve(String threadId) async {
    final json = await getJson('$_endpoint/$threadId');
    return Thread.fromJson(json);
  }

  /// Modifies a thread.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread to modify.
  /// - [request] - The modification request.
  ///
  /// ## Returns
  ///
  /// A [Thread] with the updated information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = await client.beta.threads.update(
  ///   'thread_abc123',
  ///   ModifyThreadRequest(
  ///     metadata: {'status': 'active'},
  ///   ),
  /// );
  /// ```
  Future<Thread> update(String threadId, ModifyThreadRequest request) async {
    final json = await postJson('$_endpoint/$threadId', body: request.toJson());
    return Thread.fromJson(json);
  }

  /// Deletes a thread.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread to delete.
  ///
  /// ## Returns
  ///
  /// A [DeleteThreadResponse] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.beta.threads.delete('thread_abc123');
  /// print('Deleted: ${result.deleted}');
  /// ```
  Future<DeleteThreadResponse> delete(String threadId) async {
    final json = await deleteJson('$_endpoint/$threadId');
    return DeleteThreadResponse.fromJson(json);
  }
}
