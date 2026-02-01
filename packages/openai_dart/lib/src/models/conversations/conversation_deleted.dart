import 'package:meta/meta.dart';

/// The result of deleting a conversation.
///
/// ## Example
///
/// ```dart
/// final result = await client.conversations.delete('conv_abc123');
/// if (result.deleted) {
///   print('Conversation ${result.id} was deleted');
/// }
/// ```
@immutable
class ConversationDeletedResource {
  /// The ID of the deleted conversation.
  final String id;

  /// Whether the conversation was successfully deleted.
  final bool deleted;

  /// The object type, always "conversation.deleted".
  final String object;

  /// Creates a [ConversationDeletedResource].
  const ConversationDeletedResource({
    required this.id,
    required this.deleted,
    this.object = 'conversation.deleted',
  });

  /// Creates a [ConversationDeletedResource] from JSON.
  factory ConversationDeletedResource.fromJson(Map<String, dynamic> json) {
    return ConversationDeletedResource(
      id: json['id'] as String,
      deleted: json['deleted'] as bool,
      object: json['object'] as String? ?? 'conversation.deleted',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'deleted': deleted,
    'object': object,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationDeletedResource &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deleted == other.deleted &&
          object == other.object;

  @override
  int get hashCode => Object.hash(id, deleted, object);

  @override
  String toString() =>
      'ConversationDeletedResource(id: $id, deleted: $deleted)';
}
