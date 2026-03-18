import 'package:meta/meta.dart';

import '../content/content_part.dart';

/// Content for a chat message.
///
/// Message content can be either:
/// - [MessageTextContent]: Simple text content
/// - [MessagePartsContent]: Multiple content parts (text, images)
///
/// ## Example
///
/// ```dart
/// // Simple text
/// final text = MessageContent.text('Hello!');
///
/// // Multiple parts with image
/// final parts = MessageContent.parts([
///   ContentPart.text('What is in this image?'),
///   ContentPart.imageUrl('https://example.com/image.jpg'),
/// ]);
/// ```
@immutable
sealed class MessageContent {
  const MessageContent();

  /// Creates [MessageContent] from JSON.
  ///
  /// Accepts either a [String] for text content or a [List] for parts.
  factory MessageContent.fromJson(Object json) {
    if (json is String) {
      return MessageTextContent(json);
    }
    if (json is List) {
      final parts = json
          .cast<Map<String, dynamic>>()
          .map(ContentPart.fromJson)
          .toList();
      return MessagePartsContent(parts);
    }
    throw FormatException(
      'Expected String or List for MessageContent, got ${json.runtimeType}',
    );
  }

  /// Creates text content.
  const factory MessageContent.text(String text) = MessageTextContent;

  /// Creates content with multiple parts.
  const factory MessageContent.parts(List<ContentPart> parts) =
      MessagePartsContent;

  /// Converts to JSON format expected by the API.
  Object toJson();
}

/// Simple text content for a message.
@immutable
class MessageTextContent extends MessageContent {
  /// Creates text content.
  const MessageTextContent(this.text);

  /// The text content.
  final String text;

  @override
  Object toJson() => text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'MessageTextContent($text)';
}

/// Multiple content parts for a message.
///
/// Used for multimodal messages that include images.
@immutable
class MessagePartsContent extends MessageContent {
  /// Creates content with multiple parts.
  const MessagePartsContent(this.parts);

  /// The content parts.
  final List<ContentPart> parts;

  @override
  Object toJson() => parts.map((p) => p.toJson()).toList();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MessagePartsContent) return false;
    if (parts.length != other.parts.length) return false;
    for (var i = 0; i < parts.length; i++) {
      if (parts[i] != other.parts[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(parts);

  @override
  String toString() => 'MessagePartsContent(${parts.length} parts)';
}
