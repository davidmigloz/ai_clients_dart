import '../models/threads/threads.dart';
import 'beta_base_resource.dart';

/// Resource for Messages API operations (Beta).
///
/// Messages are the content within a thread conversation.
///
/// Access this resource through [OpenAIClient.beta.threads.messages].
///
/// ## Example
///
/// ```dart
/// // Create a message
/// final message = await client.beta.threads.messages.create(
///   'thread_abc123',
///   CreateMessageRequest(
///     role: 'user',
///     content: 'What is 2 + 2?',
///   ),
/// );
///
/// // List messages
/// final messages = await client.beta.threads.messages.list('thread_abc123');
/// ```
class MessagesResource extends BetaBaseResource {
  /// Creates a [MessagesResource] with the given client.
  MessagesResource(super.client);

  String _endpoint(String threadId) => '/threads/$threadId/messages';

  /// Creates a new message in a thread.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread.
  /// - [request] - The message creation request.
  ///
  /// ## Returns
  ///
  /// A [Message] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final message = await client.beta.threads.messages.create(
  ///   'thread_abc123',
  ///   CreateMessageRequest(
  ///     role: 'user',
  ///     content: 'How do I solve this equation?',
  ///     attachments: [
  ///       MessageAttachment(fileId: 'file_123'),
  ///     ],
  ///   ),
  /// );
  /// ```
  Future<Message> create(String threadId, CreateMessageRequest request) async {
    final json = await postJson(_endpoint(threadId), body: request.toJson());
    return Message.fromJson(json);
  }

  /// Lists messages in a thread.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread.
  /// - [limit] - Maximum number of messages to return (1-100, default 20).
  /// - [order] - Sort order ('asc' or 'desc', default 'desc').
  /// - [after] - Cursor for pagination.
  /// - [before] - Cursor for pagination.
  /// - [runId] - Filter by run ID.
  ///
  /// ## Returns
  ///
  /// A [MessageList] containing the messages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final messages = await client.beta.threads.messages.list(
  ///   'thread_abc123',
  ///   order: 'asc',
  /// );
  ///
  /// for (final message in messages.data) {
  ///   print('${message.role}: ${message.content}');
  /// }
  /// ```
  Future<MessageList> list(
    String threadId, {
    int? limit,
    String? order,
    String? after,
    String? before,
    String? runId,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;
    if (runId != null) queryParams['run_id'] = runId;

    final json = await getJson(
      _endpoint(threadId),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return MessageList.fromJson(json);
  }

  /// Retrieves a message by ID.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread.
  /// - [messageId] - The ID of the message to retrieve.
  ///
  /// ## Returns
  ///
  /// A [Message] with the message information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final message = await client.beta.threads.messages.retrieve(
  ///   'thread_abc123',
  ///   'msg_xyz789',
  /// );
  /// print('Content: ${message.content}');
  /// ```
  Future<Message> retrieve(String threadId, String messageId) async {
    final json = await getJson('${_endpoint(threadId)}/$messageId');
    return Message.fromJson(json);
  }

  /// Modifies a message.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread.
  /// - [messageId] - The ID of the message to modify.
  /// - [request] - The modification request.
  ///
  /// ## Returns
  ///
  /// A [Message] with the updated information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = await client.beta.threads.messages.update(
  ///   'thread_abc123',
  ///   'msg_xyz789',
  ///   ModifyMessageRequest(
  ///     metadata: {'reviewed': 'true'},
  ///   ),
  /// );
  /// ```
  Future<Message> update(
    String threadId,
    String messageId,
    ModifyMessageRequest request,
  ) async {
    final json = await postJson(
      '${_endpoint(threadId)}/$messageId',
      body: request.toJson(),
    );
    return Message.fromJson(json);
  }

  /// Deletes a message.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread.
  /// - [messageId] - The ID of the message to delete.
  ///
  /// ## Returns
  ///
  /// A [DeleteMessageResponse] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.beta.threads.messages.delete(
  ///   'thread_abc123',
  ///   'msg_xyz789',
  /// );
  /// print('Deleted: ${result.deleted}');
  /// ```
  Future<DeleteMessageResponse> delete(
    String threadId,
    String messageId,
  ) async {
    final json = await deleteJson('${_endpoint(threadId)}/$messageId');
    return DeleteMessageResponse.fromJson(json);
  }
}
