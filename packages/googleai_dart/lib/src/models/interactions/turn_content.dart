import 'content/content.dart';

/// The content of a conversation turn.
///
/// Can represent:
/// - [TurnTextContent] — a simple text string
/// - [TurnContentList] — a list of [InteractionContent] items
sealed class TurnContent {
  const TurnContent();

  /// Creates a [TurnTextContent] with the given [text].
  const factory TurnContent.text(String text) = TurnTextContent;

  /// Creates a [TurnContentList] with the given [content] list.
  const factory TurnContent.contentList(List<InteractionContent> content) =
      TurnContentList;

  /// Creates a [TurnContent] from a JSON value.
  ///
  /// - A [String] is parsed as [TurnTextContent].
  /// - A [List] is parsed as [TurnContentList].
  factory TurnContent.fromJson(Object json) {
    if (json is String) {
      return TurnTextContent(json);
    }
    if (json is List) {
      return TurnContentList(
        json
            .map((e) => InteractionContent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw ArgumentError('Unknown TurnContent format: ${json.runtimeType}');
  }

  /// Converts this content to its JSON representation.
  Object toJson();
}

/// Simple text content for a turn.
class TurnTextContent extends TurnContent {
  /// The text value.
  final String text;

  /// Creates a [TurnTextContent].
  const TurnTextContent(this.text);

  @override
  Object toJson() => text;
}

/// A list of [InteractionContent] items for a turn.
class TurnContentList extends TurnContent {
  /// The content items.
  final List<InteractionContent> content;

  /// Creates a [TurnContentList].
  const TurnContentList(this.content);

  @override
  Object toJson() => content.map((c) => c.toJson()).toList();
}
