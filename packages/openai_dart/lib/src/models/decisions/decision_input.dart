import 'dart:convert';

import 'package:meta/meta.dart';

import '../chat/content_part.dart' show ImageDetail;
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'decision_cache.dart';
import 'decision_helpers.dart';

part 'decision_history.dart';
part 'decision_json.dart';

/// Shared text, images, JSON, messages, and tool history for Decisions.
///
/// Variants are [TextDecisionInput] and [MessagesDecisionInput]. Empty text,
/// history lists, and message part lists are valid representations.
@immutable
sealed class DecisionInput {
  const DecisionInput();

  /// Creates simple text input.
  const factory DecisionInput.text(String text) = TextDecisionInput;

  /// Creates input from messages and tool history, copying the supplied list.
  factory DecisionInput.messages(List<DecisionInputItem> messages) =
      MessagesDecisionInput;

  /// Creates ordered conversation and tool history.
  factory DecisionInput.items(List<DecisionInputItem> items) =
      MessagesDecisionInput;

  /// Reads a string or an array of Decisions input items.
  factory DecisionInput.fromJson(Object? json) {
    if (json is String) return TextDecisionInput(json);
    if (json is List) {
      return MessagesDecisionInput(
        parseDecisionObjects(
          json,
          DecisionInputItem.fromJson,
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

/// Ordered message and tool-history input for Decisions.
@immutable
class MessagesDecisionInput extends DecisionInput {
  /// Creates message input with an unmodifiable copy of [messages].
  MessagesDecisionInput(List<DecisionInputItem> messages)
    : messages = List.unmodifiable(messages);

  /// The ordered messages and tool-history items.
  final List<DecisionInputItem> messages;

  /// The ordered history, also available under the legacy [messages] name.
  List<DecisionInputItem> get items => messages;

  /// Reads message input from JSON.
  factory MessagesDecisionInput.fromJson(Object? json) => MessagesDecisionInput(
    parseDecisionObjects(
      json,
      DecisionInputItem.fromJson,
      'MessagesDecisionInput.messages',
    ),
  );

  @override
  List<Map<String, dynamic>> toJson() => [
    for (final message in messages) message.toJson(),
  ];

  /// Creates a copy with replaced messages.
  MessagesDecisionInput copyWith({List<DecisionInputItem>? messages}) =>
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

/// A Decisions user message containing text, image, or JSON parts.
@immutable
class DecisionInputMessage extends DecisionInputItem {
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
  @override
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
  @override
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

/// String or ordered text/image/JSON content in a Decisions user message.
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

/// Ordered text and image parts in a Decisions user message.
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

/// Text, image, or JSON evidence in a Decisions user message.
///
/// [DecisionEvidencePart] contains [TextDecisionInputPart] and
/// [ImageDecisionInputPart]; [JsonDecisionInputPart] holds structured evidence.
@immutable
sealed class DecisionInputPart {
  const DecisionInputPart();

  /// Creates an `input_text` part.
  const factory DecisionInputPart.text(
    String text, {
    DecisionPromptCacheBreakpoint? promptCacheBreakpoint,
  }) = TextDecisionInputPart;

  /// Creates finite structured JSON evidence, taking an immutable snapshot.
  factory DecisionInputPart.json(Object data) = JsonDecisionInputPart;

  /// Creates an image from a data URL or publicly accessible HTTP(S) URL.
  ///
  /// [imageUrl] must begin with `data:`, `http://`, or `https://`, with the
  /// original spelling retained. The server validates the image and URL
  /// accessibility. File IDs are unsupported. Omitting [detail] lets the server
  /// apply its `auto` default. At most 128 images are allowed per request.
  factory DecisionInputPart.image({
    required String imageUrl,
    ImageDetail? detail,
    DecisionPromptCacheBreakpoint? promptCacheBreakpoint,
  }) = ImageDecisionInputPart;

  /// Creates an inline image data URL from [bytes] and its MIME [mediaType].
  factory DecisionInputPart.imageBytes(
    List<int> bytes, {
    required String mediaType,
    ImageDetail? detail,
    DecisionPromptCacheBreakpoint? promptCacheBreakpoint,
  }) => ImageDecisionInputPart(
    imageUrl: 'data:$mediaType;base64,${base64Encode(bytes)}',
    detail: detail,
    promptCacheBreakpoint: promptCacheBreakpoint,
  );

  /// Reads a supported text/image/JSON part, rejecting unknown discriminators.
  factory DecisionInputPart.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'input_text' => TextDecisionInputPart.fromJson(json),
        'input_image' => ImageDecisionInputPart.fromJson(json),
        'input_json' => JsonDecisionInputPart.fromJson(json),
        _ => throw const FormatException(
          'DecisionInputPart: expected input_text, input_image, or input_json',
        ),
      };

  /// The part discriminator.
  String get type;

  /// Converts the part to JSON.
  Map<String, dynamic> toJson();
}

/// An `input_text` Decisions part.
@immutable
class TextDecisionInputPart extends DecisionEvidencePart {
  /// Creates a text part.
  const TextDecisionInputPart(this.text, {this.promptCacheBreakpoint});

  /// The text evidence.
  final String text;

  /// An optional explicit shared-input cache boundary.
  final DecisionPromptCacheBreakpoint? promptCacheBreakpoint;

  @override
  String get type => 'input_text';

  /// Reads a text part with the required discriminator and text.
  factory TextDecisionInputPart.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'input_text', 'TextDecisionInputPart');
    return TextDecisionInputPart(
      requireDecisionString(json['text'], 'TextDecisionInputPart.text'),
      promptCacheBreakpoint: json['prompt_cache_breakpoint'] == null
          ? null
          : DecisionPromptCacheBreakpoint.fromJson(
              requireDecisionMap(
                json['prompt_cache_breakpoint'],
                'TextDecisionInputPart.prompt_cache_breakpoint',
              ),
            ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'text': text,
    if (promptCacheBreakpoint != null)
      'prompt_cache_breakpoint': promptCacheBreakpoint!.toJson(),
  };

  /// Creates a copy with replaced text.
  TextDecisionInputPart copyWith({
    String? text,
    Object? promptCacheBreakpoint = unsetCopyWithValue,
  }) => TextDecisionInputPart(
    text ?? this.text,
    promptCacheBreakpoint: identical(promptCacheBreakpoint, unsetCopyWithValue)
        ? this.promptCacheBreakpoint
        : promptCacheBreakpoint as DecisionPromptCacheBreakpoint?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextDecisionInputPart &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          promptCacheBreakpoint == other.promptCacheBreakpoint;

  @override
  int get hashCode => Object.hash(runtimeType, text, promptCacheBreakpoint);

  @override
  String toString() =>
      'TextDecisionInputPart(type: $type, text: ${text.length} chars, promptCacheBreakpoint: $promptCacheBreakpoint)';
}

/// An `input_image` Decisions part containing a data URL or public HTTP(S) URL.
@immutable
class ImageDecisionInputPart extends DecisionEvidencePart {
  /// Creates an image part, requiring a supported URL prefix at runtime.
  ///
  /// Supports `data:`, `http://`, and `https://` without normalizing their
  /// contents. The server validates image data and public URL accessibility.
  ImageDecisionInputPart({
    required String imageUrl,
    this.detail,
    this.promptCacheBreakpoint,
  }) : imageUrl = _validateImageUrl(imageUrl);

  /// A base64-encoded image in a data URL or a public HTTP(S) image URL.
  final String imageUrl;

  /// The image detail level; omitted or null uses the server's `auto` default.
  final ImageDetail? detail;

  /// An optional explicit shared-input cache boundary.
  final DecisionPromptCacheBreakpoint? promptCacheBreakpoint;

  @override
  String get type => 'input_image';

  /// Reads an image part, rejecting unsupported URL prefixes and detail values.
  factory ImageDecisionInputPart.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'input_image', 'ImageDecisionInputPart');
    final imageUrl = requireDecisionString(
      json['image_url'],
      'ImageDecisionInputPart.image_url',
    );
    if (!_hasSupportedImageUrlPrefix(imageUrl)) {
      throw const FormatException(
        'ImageDecisionInputPart.image_url: expected a data URL or HTTP(S) URL',
      );
    }
    final detail = json['detail'];
    return ImageDecisionInputPart(
      imageUrl: imageUrl,
      promptCacheBreakpoint: json['prompt_cache_breakpoint'] == null
          ? null
          : DecisionPromptCacheBreakpoint.fromJson(
              requireDecisionMap(
                json['prompt_cache_breakpoint'],
                'ImageDecisionInputPart.prompt_cache_breakpoint',
              ),
            ),
      detail: detail == null
          ? null
          : ImageDetail.fromJson(
              requireDecisionString(detail, 'ImageDecisionInputPart.detail'),
            ),
    );
  }

  static String _validateImageUrl(String imageUrl) {
    if (!_hasSupportedImageUrlPrefix(imageUrl)) {
      throw ArgumentError(
        'Decision image URLs must begin with "data:", "http://", or "https://"',
      );
    }
    return imageUrl;
  }

  static bool _hasSupportedImageUrlPrefix(String imageUrl) =>
      imageUrl.startsWith('data:') ||
      imageUrl.startsWith('http://') ||
      imageUrl.startsWith('https://');

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'image_url': imageUrl,
    if (detail != null) 'detail': detail!.toJson(),
    if (promptCacheBreakpoint != null)
      'prompt_cache_breakpoint': promptCacheBreakpoint!.toJson(),
  };

  /// Creates a copy with a replaced image URL or detail.
  ///
  /// Passing null for [detail] clears the explicit detail setting.
  ImageDecisionInputPart copyWith({
    String? imageUrl,
    Object? detail = unsetCopyWithValue,
    Object? promptCacheBreakpoint = unsetCopyWithValue,
  }) => ImageDecisionInputPart(
    imageUrl: imageUrl ?? this.imageUrl,
    promptCacheBreakpoint: identical(promptCacheBreakpoint, unsetCopyWithValue)
        ? this.promptCacheBreakpoint
        : promptCacheBreakpoint as DecisionPromptCacheBreakpoint?,
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
          detail == other.detail &&
          promptCacheBreakpoint == other.promptCacheBreakpoint;

  @override
  int get hashCode =>
      Object.hash(runtimeType, imageUrl, detail, promptCacheBreakpoint);

  @override
  String toString() =>
      'ImageDecisionInputPart(type: $type, '
      'imageUrl: [${imageUrl.length} chars], detail: $detail, promptCacheBreakpoint: $promptCacheBreakpoint)';
}

/// Text or image parts permitted in tool outputs as well as shared user input.
///
/// Variants are [TextDecisionInputPart] and [ImageDecisionInputPart].
@immutable
sealed class DecisionEvidencePart extends DecisionInputPart {
  const DecisionEvidencePart();

  /// Reads an evidence part, rejecting user-only JSON parts.
  factory DecisionEvidencePart.fromJson(Map<String, dynamic> json) {
    final part = DecisionInputPart.fromJson(json);
    if (part is DecisionEvidencePart) return part;
    throw const FormatException('DecisionEvidencePart: expected text or image');
  }
}
