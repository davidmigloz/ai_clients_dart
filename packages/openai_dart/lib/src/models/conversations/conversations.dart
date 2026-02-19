/// Models for the OpenAI Conversations API.
///
/// The Conversations API provides server-side conversation state management
/// for the Responses API. This allows creating, storing, and retrieving
/// conversation items without the 30-day TTL, making it ideal for
/// long-running conversations.
///
/// ## Key Classes
///
/// - [Conversation] - A conversation with optional metadata
/// - [ConversationItem] - Items stored in a conversation
/// - [ConversationCreateRequest] - Request to create a conversation
/// - [ConversationUpdateRequest] - Request to update conversation metadata
/// - [ItemsCreateRequest] - Request to add items to a conversation
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
/// // Add more items
/// await client.conversations.items.create(
///   conversation.id,
///   ItemsCreateRequest(items: [
///     MessageItem.userText('What is the weather like?'),
///   ]),
/// );
///
/// // List items
/// final items = await client.conversations.items.list(conversation.id);
/// ```
library;

export 'conversation.dart';
export 'conversation_content.dart';
export 'conversation_create_request.dart';
export 'conversation_deleted.dart';
export 'conversation_item.dart';
export 'conversation_item_list.dart';
export 'conversation_message.dart';
export 'conversation_update_request.dart';
export 'items_create_request.dart';
