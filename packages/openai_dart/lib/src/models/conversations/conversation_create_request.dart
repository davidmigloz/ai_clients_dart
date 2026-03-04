import 'package:meta/meta.dart';

import '../responses/common/equality_helpers.dart';
import '../responses/items/item.dart';

/// Request to create a new conversation.
///
/// ## Example
///
/// ```dart
/// // Create empty conversation
/// final conversation = await client.conversations.create(
///   ConversationCreateRequest(),
/// );
///
/// // Create with initial items
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
@immutable
class ConversationCreateRequest {
  /// Initial items to add to the conversation.
  ///
  /// Up to 20 items can be provided.
  final List<Item>? items;

  /// Optional metadata to associate with the conversation.
  ///
  /// Up to 16 key-value pairs can be stored, with keys up to 64 characters
  /// and values up to 512 characters.
  final Map<String, String>? metadata;

  /// Creates a [ConversationCreateRequest].
  const ConversationCreateRequest({this.items, this.metadata});

  /// Creates a [ConversationCreateRequest] from JSON.
  factory ConversationCreateRequest.fromJson(Map<String, dynamic> json) {
    return ConversationCreateRequest(
      items: (json['items'] as List?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
    );
  }

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() => {
    if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationCreateRequest &&
          runtimeType == other.runtimeType &&
          listsEqual(items, other.items) &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(
    items != null ? Object.hashAll(items!) : null,
    mapHashCode(metadata),
  );

  @override
  String toString() =>
      'ConversationCreateRequest(items: $items, metadata: $metadata)';
}
