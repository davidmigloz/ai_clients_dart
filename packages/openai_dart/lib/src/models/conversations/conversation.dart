import 'package:meta/meta.dart';

import '../responses/common/equality_helpers.dart';

/// A server-side conversation that stores messages for the Responses API.
///
/// Conversations provide persistent storage for conversation items without
/// the 30-day TTL that applies to stored responses. This is ideal for
/// long-running conversations that need to be continued over time.
///
/// ## Example
///
/// ```dart
/// final conversation = await client.conversations.create(
///   ConversationCreateRequest(
///     metadata: {'user_id': 'user_123'},
///   ),
/// );
///
/// // Use with Responses API
/// final response = await client.responses.create(
///   CreateResponseRequest(
///     model: 'gpt-4o',
///     input: 'Hello!',
///     conversation: ResponseConversation.id(conversation.id),
///   ),
/// );
/// ```
@immutable
class Conversation {
  /// The unique identifier for the conversation.
  final String id;

  /// The object type, always "conversation".
  final String object;

  /// The Unix timestamp (in seconds) for when the conversation was created.
  final int createdAt;

  /// Optional metadata associated with the conversation.
  ///
  /// Up to 16 key-value pairs can be stored, with keys up to 64 characters
  /// and values up to 512 characters.
  final Map<String, String>? metadata;

  /// Creates a [Conversation].
  const Conversation({
    required this.id,
    this.object = 'conversation',
    required this.createdAt,
    this.metadata,
  });

  /// Creates a [Conversation] from JSON.
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      object: json['object'] as String? ?? 'conversation',
      createdAt: json['created_at'] as int,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
    );
  }

  /// Converts this conversation to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created_at': createdAt,
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Conversation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          createdAt == other.createdAt &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(id, object, createdAt, metadata);

  @override
  String toString() =>
      'Conversation(id: $id, createdAt: $createdAt, metadata: $metadata)';
}
