import 'content/content.dart';

/// A summary content item within a thought.
///
/// This is a sealed class with 2 subtypes: [ThoughtSummaryContentText] and
/// [ThoughtSummaryContentImage], wrapping the matching [TextContent] and
/// [ImageContent] variants from the [InteractionContent] family.
sealed class ThoughtSummaryContent {
  /// The type discriminator for this thought summary item.
  String get type;

  const ThoughtSummaryContent();

  /// Creates a [ThoughtSummaryContent] from JSON.
  factory ThoughtSummaryContent.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'text' => ThoughtSummaryContentText(TextContent.fromJson(json)),
      'image' => ThoughtSummaryContentImage(ImageContent.fromJson(json)),
      _ => throw ArgumentError(
        'Unknown thought summary content type: ${json['type']}',
      ),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A [TextContent] used as a thought summary item.
class ThoughtSummaryContentText extends ThoughtSummaryContent {
  @override
  String get type => 'text';

  /// The wrapped text content.
  final TextContent content;

  /// Creates a [ThoughtSummaryContentText] wrapping [content].
  const ThoughtSummaryContentText(this.content);

  @override
  Map<String, dynamic> toJson() => content.toJson();
}

/// An [ImageContent] used as a thought summary item.
class ThoughtSummaryContentImage extends ThoughtSummaryContent {
  @override
  String get type => 'image';

  /// The wrapped image content.
  final ImageContent content;

  /// Creates a [ThoughtSummaryContentImage] wrapping [content].
  const ThoughtSummaryContentImage(this.content);

  @override
  Map<String, dynamic> toJson() => content.toJson();
}
