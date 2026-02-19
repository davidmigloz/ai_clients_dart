import '../models/conversations/conversations.dart';
import 'base_resource.dart';

/// Resource for conversations operations.
///
/// The Conversations API provides server-side conversation state management
/// for the Responses API. This allows creating, storing, and retrieving
/// conversation items without the 30-day TTL.
///
/// ## Example
///
/// ```dart
/// // Create a conversation
/// final conversation = await client.conversations.create(
///   ConversationCreateRequest(
///     items: [MessageItem.userText('Hello!')],
///     metadata: {'user_id': 'user_123'},
///   ),
/// );
///
/// // Use with Responses API
/// final response = await client.responses.create(
///   CreateResponseRequest(
///     model: 'gpt-4o',
///     input: ResponseInput.text('Continue our conversation'),
///   ),
/// );
///
/// // Add items to the conversation
/// await client.conversations.items.create(
///   conversation.id,
///   ItemsCreateRequest(items: [
///     MessageItem.userText('What is the weather?'),
///   ]),
/// );
///
/// // List conversation items
/// final items = await client.conversations.items.list(conversation.id);
///
/// // Clean up
/// await client.conversations.delete(conversation.id);
/// ```
class ConversationsResource extends BaseResource {
  /// Creates a [ConversationsResource] with the given client.
  ConversationsResource(super.client);

  static const _endpoint = '/conversations';

  ConversationItemsResource? _items;

  /// Access to conversation items operations.
  ///
  /// Use this to add, list, retrieve, and delete items within a conversation.
  ConversationItemsResource get items =>
      _items ??= ConversationItemsResource(client);

  /// Creates a new conversation.
  ///
  /// ## Parameters
  ///
  /// - [request] - The conversation creation request parameters.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// A [Conversation] containing the created conversation details.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Create empty conversation
  /// final conversation = await client.conversations.create(
  ///   ConversationCreateRequest(),
  /// );
  ///
  /// // Create with initial items and metadata
  /// final conversation = await client.conversations.create(
  ///   ConversationCreateRequest(
  ///     items: [
  ///       MessageItem.userText('Hello!'),
  ///       MessageItem.assistantText('Hi there!'),
  ///     ],
  ///     metadata: {'user_id': 'user_123'},
  ///   ),
  /// );
  /// ```
  Future<Conversation> create(
    ConversationCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    final json = await postJson(
      _endpoint,
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );
    return Conversation.fromJson(json);
  }

  /// Retrieves a conversation by ID.
  ///
  /// ## Parameters
  ///
  /// - [conversationId] - The ID of the conversation to retrieve.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// The [Conversation] with the specified ID.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final conversation = await client.conversations.retrieve('conv_abc123');
  /// print('Created at: ${conversation.createdAt}');
  /// ```
  Future<Conversation> retrieve(
    String conversationId, {
    Future<void>? abortTrigger,
  }) async {
    final json = await getJson(
      '$_endpoint/$conversationId',
      abortTrigger: abortTrigger,
    );
    return Conversation.fromJson(json);
  }

  /// Updates a conversation.
  ///
  /// Currently, only metadata can be updated on a conversation.
  ///
  /// ## Parameters
  ///
  /// - [conversationId] - The ID of the conversation to update.
  /// - [request] - The update request parameters.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// The updated [Conversation].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = await client.conversations.update(
  ///   'conv_abc123',
  ///   ConversationUpdateRequest(
  ///     metadata: {'status': 'resolved'},
  ///   ),
  /// );
  /// ```
  Future<Conversation> update(
    String conversationId,
    ConversationUpdateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    final json = await postJson(
      '$_endpoint/$conversationId',
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );
    return Conversation.fromJson(json);
  }

  /// Deletes a conversation.
  ///
  /// ## Parameters
  ///
  /// - [conversationId] - The ID of the conversation to delete.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// A [ConversationDeletedResource] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.conversations.delete('conv_abc123');
  /// print('Deleted: ${result.deleted}');
  /// ```
  Future<ConversationDeletedResource> delete(
    String conversationId, {
    Future<void>? abortTrigger,
  }) async {
    final json = await deleteJson(
      '$_endpoint/$conversationId',
      abortTrigger: abortTrigger,
    );
    return ConversationDeletedResource.fromJson(json);
  }
}

/// Resource for conversation items operations.
///
/// Provides access to add, list, retrieve, and delete items within a
/// conversation.
class ConversationItemsResource extends BaseResource {
  /// Creates a [ConversationItemsResource] with the given client.
  ConversationItemsResource(super.client);

  /// Adds items to a conversation.
  ///
  /// ## Parameters
  ///
  /// - [conversationId] - The ID of the conversation.
  /// - [request] - The items to add.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// A [ConversationItemList] containing the added items.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.conversations.items.create(
  ///   'conv_abc123',
  ///   ItemsCreateRequest(
  ///     items: [
  ///       MessageItem.userText('What is the weather?'),
  ///     ],
  ///   ),
  /// );
  /// ```
  Future<ConversationItemList> create(
    String conversationId,
    ItemsCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    final json = await postJson(
      '/conversations/$conversationId/items',
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );
    return ConversationItemList.fromJson(json);
  }

  /// Lists items in a conversation.
  ///
  /// ## Parameters
  ///
  /// - [conversationId] - The ID of the conversation.
  /// - [after] - A cursor for pagination (item ID to start after).
  /// - [limit] - Maximum number of items to return (1-100, default 20).
  /// - [order] - Sort order: 'asc' or 'desc' (default 'asc').
  /// - [include] - Additional data to include (e.g., ['file_search_call.results']).
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// A [ConversationItemList] containing the items.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final items = await client.conversations.items.list(
  ///   'conv_abc123',
  ///   limit: 50,
  ///   order: 'desc',
  /// );
  ///
  /// for (final item in items.data) {
  ///   print(item);
  /// }
  ///
  /// // Paginate
  /// if (items.hasMore) {
  ///   final moreItems = await client.conversations.items.list(
  ///     'conv_abc123',
  ///     after: items.lastId,
  ///   );
  /// }
  /// ```
  Future<ConversationItemList> list(
    String conversationId, {
    String? after,
    int? limit,
    String? order,
    List<String>? include,
    Future<void>? abortTrigger,
  }) async {
    final queryParameters = <String, String>{};
    if (after != null) queryParameters['after'] = after;
    if (limit != null) queryParameters['limit'] = limit.toString();
    if (order != null) queryParameters['order'] = order;

    final json = await getJsonWithRepeatedParams(
      '/conversations/$conversationId/items',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      queryParametersAll: _buildIncludeParams(include),
      abortTrigger: abortTrigger,
    );
    return ConversationItemList.fromJson(json);
  }

  /// Retrieves a specific item from a conversation.
  ///
  /// ## Parameters
  ///
  /// - [conversationId] - The ID of the conversation.
  /// - [itemId] - The ID of the item to retrieve.
  /// - [include] - Additional data to include.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// The [ConversationItem] with the specified ID.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final item = await client.conversations.items.retrieve(
  ///   'conv_abc123',
  ///   'item_xyz789',
  /// );
  /// ```
  Future<ConversationItem> retrieve(
    String conversationId,
    String itemId, {
    List<String>? include,
    Future<void>? abortTrigger,
  }) async {
    final json = await getJsonWithRepeatedParams(
      '/conversations/$conversationId/items/$itemId',
      queryParametersAll: _buildIncludeParams(include),
      abortTrigger: abortTrigger,
    );
    return ConversationItem.fromJson(json);
  }

  /// Deletes an item from a conversation.
  ///
  /// ## Parameters
  ///
  /// - [conversationId] - The ID of the conversation.
  /// - [itemId] - The ID of the item to delete.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// The updated [Conversation] after the item is deleted.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final conversation = await client.conversations.items.delete(
  ///   'conv_abc123',
  ///   'item_xyz789',
  /// );
  /// ```
  Future<Conversation> delete(
    String conversationId,
    String itemId, {
    Future<void>? abortTrigger,
  }) async {
    final json = await deleteJson(
      '/conversations/$conversationId/items/$itemId',
      abortTrigger: abortTrigger,
    );
    return Conversation.fromJson(json);
  }

  /// Converts include values to repeated query parameters format.
  Map<String, List<String>>? _buildIncludeParams(List<String>? include) {
    if (include == null || include.isEmpty) {
      return null;
    }
    return {'include[]': include};
  }
}
