import '../interactions/content/content.dart';

const _decisionContentTypes = {'audio', 'document', 'image', 'text', 'video'};

/// Shared context evaluated against every question in a decision request.
///
/// The wire forms are [DecisionTextInput], [DecisionSingleContentInput], and
/// [DecisionContentListInput].
sealed class DecisionInput {
  const DecisionInput();

  /// Uses a plain text string as the shared context.
  const factory DecisionInput.text(String text) = DecisionTextInput;

  /// Uses one text, image, audio, video, or PDF content block.
  const factory DecisionInput.singleContent(InteractionContent content) =
      DecisionSingleContentInput;

  /// Uses an ordered list of content blocks, which may mix modalities.
  const factory DecisionInput.contentList(List<InteractionContent> content) =
      DecisionContentListInput;

  /// Parses the wire representation of the shared context.
  factory DecisionInput.fromJson(Object? json) => switch (json) {
    final String text when text.isNotEmpty => DecisionTextInput(text),
    final Map<String, dynamic> content => DecisionSingleContentInput(
      _parseContent(content),
    ),
    final List<dynamic> content when content.isNotEmpty =>
      DecisionContentListInput(content.map(_parseContent).toList()),
    _ => throw const FormatException(
      'DecisionInput: expected a string, content block, or list of blocks with at least one item',
    ),
  };

  static InteractionContent _parseContent(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('DecisionInput: expected a content block');
    }
    final type = json['type'];
    if (!_decisionContentTypes.contains(type)) {
      throw const FormatException('DecisionInput: invalid content type');
    }
    return type == 'text'
        ? _parseDecisionTextContent(json)
        : InteractionContent.fromJson(json);
  }

  /// Converts the shared context to its wire representation.
  Object toJson();
}

/// Shared context expressed as a string.
final class DecisionTextInput extends DecisionInput {
  /// The string to evaluate.
  final String text;

  /// Creates text input.
  const DecisionTextInput(this.text);

  @override
  String toJson() {
    if (text.isEmpty) {
      throw ArgumentError.value(text, 'text', 'Input cannot be empty');
    }
    return text;
  }
}

/// Shared context expressed as one content block.
final class DecisionSingleContentInput extends DecisionInput {
  /// The content block to evaluate.
  final InteractionContent content;

  /// Creates input with one content block.
  const DecisionSingleContentInput(this.content);

  @override
  Map<String, dynamic> toJson() => _decisionContentToJson(content);
}

/// Shared context expressed as an ordered list of content blocks.
final class DecisionContentListInput extends DecisionInput {
  /// The content blocks to evaluate.
  final List<InteractionContent> content;

  /// Creates input with a list of content blocks.
  const DecisionContentListInput(this.content);

  @override
  List<Map<String, dynamic>> toJson() {
    if (content.isEmpty) {
      throw ArgumentError('Decision input requires a content block');
    }
    return content.map(_decisionContentToJson).toList();
  }
}

/// Text-only instructions for a decision question.
///
/// The wire forms are [DecisionPlainTextInstructions],
/// [DecisionSingleContentInstructions], and [DecisionContentListInstructions].
sealed class DecisionInstructions {
  const DecisionInstructions();

  /// Uses a plain text string as instructions.
  const factory DecisionInstructions.text(String text) =
      DecisionPlainTextInstructions;

  /// Uses one text content block as instructions.
  const factory DecisionInstructions.singleContent(TextContent content) =
      DecisionSingleContentInstructions;

  /// Uses an ordered list of text content blocks as instructions.
  const factory DecisionInstructions.contentList(List<TextContent> content) =
      DecisionContentListInstructions;

  /// Parses the wire representation of the instructions.
  factory DecisionInstructions.fromJson(Object? json) => switch (json) {
    final String text => DecisionPlainTextInstructions(text),
    final Map<String, dynamic> content => DecisionSingleContentInstructions(
      _parseDecisionTextContent(content),
    ),
    final List<dynamic> content when content.isNotEmpty =>
      DecisionContentListInstructions(
        content.map(_parseDecisionTextContent).toList(),
      ),
    _ => throw const FormatException(
      'DecisionInstructions: expected a string, text block, or list of blocks with at least one item',
    ),
  };

  /// Converts the instructions to their wire representation.
  Object toJson();
}

/// Instructions expressed as a string.
final class DecisionPlainTextInstructions extends DecisionInstructions {
  /// The instruction text.
  final String text;

  /// Creates instructions from text.
  const DecisionPlainTextInstructions(this.text);

  @override
  String toJson() => text;
}

/// Instructions expressed as one text content block.
final class DecisionSingleContentInstructions extends DecisionInstructions {
  /// The instruction text block.
  final TextContent content;

  /// Creates instructions with one text block.
  const DecisionSingleContentInstructions(this.content);

  @override
  Map<String, dynamic> toJson() => content.toJson();
}

/// Instructions expressed as a list of text content blocks.
final class DecisionContentListInstructions extends DecisionInstructions {
  /// The ordered instruction text blocks.
  final List<TextContent> content;

  /// Creates instructions with a list of text blocks.
  const DecisionContentListInstructions(this.content);

  @override
  List<Map<String, dynamic>> toJson() {
    if (content.isEmpty) {
      throw ArgumentError('Decision instructions require a text block');
    }
    return [for (final block in content) block.toJson()];
  }
}

Map<String, dynamic> _decisionContentToJson(InteractionContent content) {
  if (!_decisionContentTypes.contains(content.type)) {
    throw ArgumentError.value(
      content.type,
      'type',
      'Invalid Decisions content type',
    );
  }
  return content.toJson();
}

TextContent _parseDecisionTextContent(Object? json) {
  if (json is! Map<String, dynamic> ||
      json['type'] != 'text' ||
      json['text'] is! String) {
    throw const FormatException('Expected a Decisions text content block');
  }
  return TextContent.fromJson(json);
}
