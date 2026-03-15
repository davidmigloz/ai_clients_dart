import 'content/content.dart';

/// The result of a tool call.
///
/// Can represent different result formats:
/// - [ToolResultContentList] — a list of content items (typically
///   [TextContent] and/or [ImageContent])
/// - [ToolResultText] — a plain text string
/// - [ToolResultObject] — an arbitrary JSON object (fallback)
sealed class ToolResult {
  const ToolResult();

  /// Creates a [ToolResultContentList] with the given [items].
  const factory ToolResult.contentList(List<InteractionContent> items) =
      ToolResultContentList;

  /// Creates a [ToolResultText] with the given [text].
  const factory ToolResult.text(String text) = ToolResultText;

  /// Creates a [ToolResultObject] with the given [value].
  const factory ToolResult.object(Map<String, dynamic> value) =
      ToolResultObject;

  /// Creates a [ToolResult] from a JSON value.
  ///
  /// - A [String] is parsed as [ToolResultText].
  /// - A [List] is parsed as [ToolResultContentList] (each element parsed as
  ///   [InteractionContent]).
  /// - A [Map] is parsed as [ToolResultObject].
  factory ToolResult.fromJson(Object json) {
    if (json is String) {
      return ToolResultText(json);
    }
    if (json is List) {
      return ToolResultContentList(
        json
            .map((e) => InteractionContent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      return ToolResultObject(json);
    }
    throw ArgumentError('Unknown ToolResult format: ${json.runtimeType}');
  }

  /// Converts this result to its JSON representation.
  Object toJson();
}

/// A list of content items as a tool result.
///
/// Typically contains [TextContent] and/or [ImageContent] items.
class ToolResultContentList extends ToolResult {
  /// The content items.
  final List<InteractionContent> items;

  /// Creates a [ToolResultContentList].
  const ToolResultContentList(this.items);

  @override
  Object toJson() => items.map((e) => e.toJson()).toList();
}

/// A plain text string as a tool result.
class ToolResultText extends ToolResult {
  /// The text value.
  final String text;

  /// Creates a [ToolResultText].
  const ToolResultText(this.text);

  @override
  Object toJson() => text;
}

/// An arbitrary JSON object as a tool result (fallback).
class ToolResultObject extends ToolResult {
  /// The JSON object value.
  final Map<String, dynamic> value;

  /// Creates a [ToolResultObject].
  const ToolResultObject(this.value);

  @override
  Object toJson() => value;
}
