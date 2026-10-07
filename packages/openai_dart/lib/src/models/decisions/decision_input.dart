import 'dart:convert';

import 'package:meta/meta.dart';

import '../chat/content_part.dart' show ImageDetail;
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'decision_helpers.dart';

/// Shared text or inline image evidence for a Decisions request.
///
/// Only user messages with text and inline images are supported. Empty text,
/// message lists, and part lists are valid representations.
@immutable
sealed class DecisionInput {
  const DecisionInput();

  /// Creates simple text input.
  const factory DecisionInput.text(String text) = TextDecisionInput;

  /// Creates input from user messages, copying the supplied list.
  factory DecisionInput.messages(List<DecisionInputMessage> messages) =
      MessagesDecisionInput;

  /// Reads a string or an array of Decisions user messages.
  factory DecisionInput.fromJson(Object? json) {
    if (json is String) return TextDecisionInput(json);
    if (json is List) {
      return MessagesDecisionInput(
        parseDecisionObjects(
          json,
          DecisionInputMessage.fromJson,
          'DecisionInput.messages',
        ),
      );
    }
    throw const FormatException('DecisionInput: expected a string or array');
  }

  /// Converts input to a JSON string or array.
  Object toJson();
}

/// Simple text input for Decisions.
@immutable
class TextDecisionInput extends DecisionInput {
  /// Creates text input.
  const TextDecisionInput(this.text);

  /// The evidence to evaluate.
  final String text;

  /// Reads text input from JSON.
  factory TextDecisionInput.fromJson(Object? json) =>
      TextDecisionInput(requireDecisionString(json, 'TextDecisionInput.text'));

  @override
  String toJson() => text;

  /// Creates a copy with replaced text.
  TextDecisionInput copyWith({String? text}) =>
      TextDecisionInput(text ?? this.text);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextDecisionInput &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => Object.hash(runtimeType, text);

  @override
  String toString() => 'TextDecisionInput(text: ${text.length} chars)';
}

/// User-message input for Decisions.
@immutable
class MessagesDecisionInput extends DecisionInput {
  /// Creates message input with an unmodifiable copy of [messages].
  MessagesDecisionInput(List<DecisionInputMessage> messages)
    : messages = List.unmodifiable(messages);

  /// The ordered user messages.
  final List<DecisionInputMessage> messages;

  /// Reads message input from JSON.
  factory MessagesDecisionInput.fromJson(Object? json) => MessagesDecisionInput(
    parseDecisionObjects(
      json,
      DecisionInputMessage.fromJson,
      'MessagesDecisionInput.messages',
    ),
  );

  @override
  List<Map<String, dynamic>> toJson() => [
    for (final message in messages) message.toJson(),
  ];

  /// Creates a copy with replaced messages.
  MessagesDecisionInput copyWith({List<DecisionInputMessage>? messages}) =>
      MessagesDecisionInput(messages ?? this.messages);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessagesDecisionInput &&
          runtimeType == other.runtimeType &&
          listsEqual(messages, other.messages);

  @override
  int get hashCode => Object.hash(runtimeType, listHash(messages));

  @override
  String toString() =>
      'MessagesDecisionInput(messages: ${messages.length} items)';
}

/// A Decisions user message containing text or inline image parts.
@immutable
class DecisionInputMessage {
  /// Creates a message with the fixed `user` role and `message` type.
  const DecisionInputMessage({required this.content});

  /// Creates a user message with string content.
  factory DecisionInputMessage.text(String text) =>
      DecisionInputMessage(content: TextDecisionContent(text));

  /// The text evidence or ordered content parts.
  final DecisionContent content;

  /// The role. Always `user`.
  String get role => 'user';

  /// The type. Always `message`.
  String get type => 'message';

  /// Reads a user message, rejecting unsupported roles and types.
  factory DecisionInputMessage.fromJson(Map<String, dynamic> json) {
    requireDecisionType(
      json,
      'message',
      'DecisionInputMessage',
      optional: true,
    );
    if (json['role'] != 'user') {
      throw const FormatException('DecisionInputMessage: expected role "user"');
    }
    return DecisionInputMessage(
      content: DecisionContent.fromJson(json['content']),
    );
  }

  /// Converts the message to JSON, including its fixed role and type.
  Map<String, dynamic> toJson() => {
    'type': type,
    'role': role,
    'content': content.toJson(),
  };

  /// Creates a copy with replaced content.
  DecisionInputMessage copyWith({DecisionContent? content}) =>
      DecisionInputMessage(content: content ?? this.content);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionInputMessage &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => Object.hash(runtimeType, content);

  @override
  String toString() =>
      'DecisionInputMessage(type: $type, role: $role, content: $content)';
}

/// String or ordered text/image content in a Decisions user message.
@immutable
sealed class DecisionContent {
  const DecisionContent();

  /// Creates string message content.
  const factory DecisionContent.text(String text) = TextDecisionContent;

  /// Creates ordered content parts, copying the supplied list.
  factory DecisionContent.parts(List<DecisionInputPart> parts) =
      PartsDecisionContent;

  /// Reads string content or an array of supported text/image parts.
  factory DecisionContent.fromJson(Object? json) {
    if (json is String) return TextDecisionContent(json);
    if (json is List) {
      return PartsDecisionContent(
        parseDecisionObjects(
          json,
          DecisionInputPart.fromJson,
          'DecisionContent.parts',
        ),
      );
    }
    throw const FormatException('DecisionContent: expected a string or array');
  }

  /// Converts content to a JSON string or array.
  Object toJson();
}

/// String content in a Decisions user message.
@immutable
class TextDecisionContent extends DecisionContent {
  /// Creates string content.
  const TextDecisionContent(this.text);

  /// The text evidence.
  final String text;

  /// Reads string content from JSON.
  factory TextDecisionContent.fromJson(Object? json) => TextDecisionContent(
    requireDecisionString(json, 'TextDecisionContent.text'),
  );

  @override
  String toJson() => text;

  /// Creates a copy with replaced text.
  TextDecisionContent copyWith({String? text}) =>
      TextDecisionContent(text ?? this.text);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextDecisionContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => Object.hash(runtimeType, text);

  @override
  String toString() => 'TextDecisionContent(text: ${text.length} chars)';
}

/// Ordered text and inline image parts in a Decisions user message.
@immutable
class PartsDecisionContent extends DecisionContent {
  /// Creates content with an unmodifiable copy of [parts].
  PartsDecisionContent(List<DecisionInputPart> parts)
    : parts = List.unmodifiable(parts);

  /// The ordered content parts.
  final List<DecisionInputPart> parts;

  /// Reads content parts from JSON.
  factory PartsDecisionContent.fromJson(Object? json) => PartsDecisionContent(
    parseDecisionObjects(
      json,
      DecisionInputPart.fromJson,
      'PartsDecisionContent.parts',
    ),
  );

  @override
  List<Map<String, dynamic>> toJson() => [
    for (final part in parts) part.toJson(),
  ];

  /// Creates a copy with replaced parts.
  PartsDecisionContent copyWith({List<DecisionInputPart>? parts}) =>
      PartsDecisionContent(parts ?? this.parts);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartsDecisionContent &&
          runtimeType == other.runtimeType &&
          listsEqual(parts, other.parts);

  @override
  int get hashCode => Object.hash(runtimeType, listHash(parts));

  @override
  String toString() => 'PartsDecisionContent(parts: ${parts.length} items)';
}

/// Text or inline image evidence in a Decisions message.
@immutable
sealed class DecisionInputPart {
  const DecisionInputPart();

  /// Creates an `input_text` part.
  const factory DecisionInputPart.text(String text) = TextDecisionInputPart;

  /// Creates an inline image, requiring [imageUrl] to begin with `data:`.
  ///
  /// Omitting [detail] lets the server apply its `auto` default. External URLs
  /// and file IDs are unsupported. At most 128 images are allowed per request.
  factory DecisionInputPart.image({
    required String imageUrl,
    ImageDetail? detail,
  }) = ImageDecisionInputPart;

  /// Creates an inline image data URL from [bytes] and its MIME [mediaType].
  factory DecisionInputPart.imageBytes(
    List<int> bytes, {
    required String mediaType,
    ImageDetail? detail,
  }) => ImageDecisionInputPart(
    imageUrl: 'data:$mediaType;base64,${base64Encode(bytes)}',
    detail: detail,
  );

  /// Reads a supported text/image part, rejecting unknown discriminators.
  factory DecisionInputPart.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'input_text' => TextDecisionInputPart.fromJson(json),
        'input_image' => ImageDecisionInputPart.fromJson(json),
        _ => throw const FormatException(
          'DecisionInputPart: expected type "input_text" or "input_image"',
        ),
      };

  /// The part discriminator.
  String get type;

  /// Converts the part to JSON.
  Map<String, dynamic> toJson();
}

/// An `input_text` Decisions part.
@immutable
class TextDecisionInputPart extends DecisionInputPart {
  /// Creates a text part.
  const TextDecisionInputPart(this.text);

  /// The text evidence.
  final String text;

  @override
  String get type => 'input_text';

  /// Reads a text part with the required discriminator and text.
  factory TextDecisionInputPart.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'input_text', 'TextDecisionInputPart');
    return TextDecisionInputPart(
      requireDecisionString(json['text'], 'TextDecisionInputPart.text'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};

  /// Creates a copy with replaced text.
  TextDecisionInputPart copyWith({String? text}) =>
      TextDecisionInputPart(text ?? this.text);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextDecisionInputPart &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => Object.hash(runtimeType, text);

  @override
  String toString() =>
      'TextDecisionInputPart(type: $type, text: ${text.length} chars)';
}

/// An `input_image` Decisions part containing an inline data URL.
@immutable
class ImageDecisionInputPart extends DecisionInputPart {
  /// Creates an image part, rejecting external URLs and file IDs at runtime.
  ImageDecisionInputPart({required String imageUrl, this.detail})
    : imageUrl = _validateImageUrl(imageUrl);

  /// A base64-encoded image in a data URL.
  final String imageUrl;

  /// The image detail level; omitted or null uses the server's `auto` default.
  final ImageDetail? detail;

  @override
  String get type => 'input_image';

  /// Reads an inline image part, rejecting invalid references and detail values.
  factory ImageDecisionInputPart.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'input_image', 'ImageDecisionInputPart');
    final imageUrl = requireDecisionString(
      json['image_url'],
      'ImageDecisionInputPart.image_url',
    );
    if (!imageUrl.startsWith('data:')) {
      throw const FormatException(
        'ImageDecisionInputPart.image_url: expected an inline data URL',
      );
    }
    final detail = json['detail'];
    return ImageDecisionInputPart(
      imageUrl: imageUrl,
      detail: detail == null
          ? null
          : ImageDetail.fromJson(
              requireDecisionString(detail, 'ImageDecisionInputPart.detail'),
            ),
    );
  }

  static String _validateImageUrl(String imageUrl) {
    if (!imageUrl.startsWith('data:')) {
      throw ArgumentError('Decision image URLs must begin with "data:"');
    }
    return imageUrl;
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'image_url': imageUrl,
    if (detail != null) 'detail': detail!.toJson(),
  };

  /// Creates a copy with replaced image data or detail.
  ///
  /// Passing null for [detail] clears the explicit detail setting.
  ImageDecisionInputPart copyWith({
    String? imageUrl,
    Object? detail = unsetCopyWithValue,
  }) => ImageDecisionInputPart(
    imageUrl: imageUrl ?? this.imageUrl,
    detail: identical(detail, unsetCopyWithValue)
        ? this.detail
        : detail as ImageDetail?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageDecisionInputPart &&
          runtimeType == other.runtimeType &&
          imageUrl == other.imageUrl &&
          detail == other.detail;

  @override
  int get hashCode => Object.hash(runtimeType, imageUrl, detail);

  @override
  String toString() =>
      'ImageDecisionInputPart(type: $type, '
      'imageUrl: [${imageUrl.length} chars], detail: $detail)';
}
