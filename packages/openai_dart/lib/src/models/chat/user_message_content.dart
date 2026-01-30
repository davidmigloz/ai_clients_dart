import 'package:meta/meta.dart';

import 'content_part.dart';

/// Content for a user message.
///
/// User message content can be either:
/// - [UserTextContent]: Simple text content
/// - [UserPartsContent]: Multiple content parts (text, images, audio)
///
/// ## Example
///
/// ```dart
/// // Simple text
/// final text = UserMessageContent.text('Hello!');
///
/// // Multiple parts with image
/// final parts = UserMessageContent.parts([
///   ContentPart.text('What is in this image?'),
///   ContentPart.imageUrl('https://example.com/image.jpg'),
/// ]);
/// ```
@immutable
sealed class UserMessageContent {
  const UserMessageContent();

  /// Creates [UserMessageContent] from JSON.
  ///
  /// Accepts either a [String] for text content or a [List] for parts.
  factory UserMessageContent.fromJson(Object json) {
    if (json is String) {
      return UserTextContent(json);
    }
    if (json is List) {
      final parts = json
          .cast<Map<String, dynamic>>()
          .map(ContentPart.fromJson)
          .toList();
      return UserPartsContent(parts);
    }
    throw FormatException('Invalid user message content: $json');
  }

  /// Creates text content.
  static UserMessageContent text(String text) => UserTextContent(text);

  /// Creates content with multiple parts.
  static UserMessageContent parts(List<ContentPart> parts) =>
      UserPartsContent(parts);

  /// Converts to JSON format expected by the API.
  Object toJson();
}

/// Simple text content for a user message.
@immutable
class UserTextContent extends UserMessageContent {
  /// Creates text content.
  const UserTextContent(this.text);

  /// The text content.
  final String text;

  @override
  Object toJson() => text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'UserTextContent($text)';
}

/// Multiple content parts for a user message.
///
/// Used for multimodal messages that include images or audio.
@immutable
class UserPartsContent extends UserMessageContent {
  /// Creates content with multiple parts.
  const UserPartsContent(this.parts);

  /// The content parts.
  final List<ContentPart> parts;

  @override
  Object toJson() => parts.map((p) => p.toJson()).toList();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserPartsContent) return false;
    if (parts.length != other.parts.length) return false;
    for (var i = 0; i < parts.length; i++) {
      if (parts[i] != other.parts[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(parts);

  @override
  String toString() => 'UserPartsContent(${parts.length} parts)';
}
