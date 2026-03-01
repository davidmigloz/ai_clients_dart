import 'dart:convert';

import 'package:http/http.dart' as http;

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
class ConversationsResource extends ResourceBase {
  /// Creates a [ConversationsResource].
  ConversationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/conversations';

  ConversationItemsResource? _items;

  /// Access to conversation items operations.
  ConversationItemsResource get items => _items ??= ConversationItemsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );

  /// Creates a new conversation.
  Future<Conversation> create(
    ConversationCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return Conversation.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a conversation by ID.
  Future<Conversation> retrieve(
    String conversationId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$conversationId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return Conversation.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Updates a conversation.
  Future<Conversation> update(
    String conversationId,
    ConversationUpdateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$conversationId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return Conversation.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Deletes a conversation.
  Future<ConversationDeletedResource> delete(
    String conversationId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$conversationId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return ConversationDeletedResource.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

/// Resource for conversation items operations.
class ConversationItemsResource extends ResourceBase {
  /// Creates a [ConversationItemsResource].
  ConversationItemsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Adds items to a conversation.
  Future<ConversationItemList> create(
    String conversationId,
    ItemsCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/conversations/$conversationId/items');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return ConversationItemList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists items in a conversation.
  Future<ConversationItemList> list(
    String conversationId, {
    String? after,
    int? limit,
    String? order,
    List<String>? include,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParameters = <String, String>{};
    if (after != null) queryParameters['after'] = after;
    if (limit != null) queryParameters['limit'] = limit.toString();
    if (order != null) queryParameters['order'] = order;

    final url = requestBuilder.buildUrlWithQueryAll(
      '/conversations/$conversationId/items',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      queryParametersAll: _buildIncludeParams(include),
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return ConversationItemList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a specific item from a conversation.
  Future<ConversationItem> retrieve(
    String conversationId,
    String itemId, {
    List<String>? include,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrlWithQueryAll(
      '/conversations/$conversationId/items/$itemId',
      queryParametersAll: _buildIncludeParams(include),
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return ConversationItem.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Deletes an item from a conversation.
  Future<Conversation> delete(
    String conversationId,
    String itemId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/conversations/$conversationId/items/$itemId',
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return Conversation.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Converts include values to repeated query parameters format.
  Map<String, List<String>>? _buildIncludeParams(List<String>? include) {
    if (include == null || include.isEmpty) {
      return null;
    }
    return {'include[]': include};
  }
}
