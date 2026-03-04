import 'package:meta/meta.dart';

import '../responses/common/equality_helpers.dart';

/// Request to update an existing conversation.
///
/// Currently, only metadata can be updated on a conversation.
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
@immutable
class ConversationUpdateRequest {
  /// Updated metadata for the conversation.
  ///
  /// Up to 16 key-value pairs can be stored, with keys up to 64 characters
  /// and values up to 512 characters.
  final Map<String, String>? metadata;

  /// Creates a [ConversationUpdateRequest].
  const ConversationUpdateRequest({this.metadata});

  /// Creates a [ConversationUpdateRequest] from JSON.
  factory ConversationUpdateRequest.fromJson(Map<String, dynamic> json) {
    return ConversationUpdateRequest(
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
    );
  }

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() => {if (metadata != null) 'metadata': metadata};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationUpdateRequest &&
          runtimeType == other.runtimeType &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => mapHashCode(metadata);

  @override
  String toString() => 'ConversationUpdateRequest(metadata: $metadata)';
}
