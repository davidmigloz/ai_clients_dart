import 'content/content.dart';
import 'tools/tools.dart';

/// A subcontent item within a function or MCP server tool result.
///
/// Supports [FunctionResultSubcontentText], [FunctionResultSubcontentImage],
/// [FunctionResultSubcontentAudio], [FunctionResultSubcontentDocument],
/// [FunctionResultSubcontentVideo], and [FunctionResultSubcontentFunction].
/// [UnknownFunctionResultSubcontent] retains future variants.
sealed class FunctionResultSubcontent {
  /// The type discriminator for this subcontent.
  String get type;

  const FunctionResultSubcontent();

  /// Creates a [FunctionResultSubcontent] from JSON.
  factory FunctionResultSubcontent.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'text' => FunctionResultSubcontentText(TextContent.fromJson(json)),
      'image' => FunctionResultSubcontentImage(ImageContent.fromJson(json)),
      'audio' => FunctionResultSubcontentAudio(AudioContent.fromJson(json)),
      'document' => FunctionResultSubcontentDocument(
        DocumentContent.fromJson(json),
      ),
      'video' => FunctionResultSubcontentVideo(VideoContent.fromJson(json)),
      'function' => FunctionResultSubcontentFunction(
        FunctionTool.fromJson(json),
      ),
      _ => UnknownFunctionResultSubcontent(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A [TextContent] used as function result subcontent.
class FunctionResultSubcontentText extends FunctionResultSubcontent {
  @override
  String get type => 'text';

  /// The wrapped text content.
  final TextContent content;

  /// Creates a [FunctionResultSubcontentText] wrapping [content].
  const FunctionResultSubcontentText(this.content);

  @override
  Map<String, dynamic> toJson() => content.toJson();
}

/// An [ImageContent] used as function result subcontent.
class FunctionResultSubcontentImage extends FunctionResultSubcontent {
  @override
  String get type => 'image';

  /// The wrapped image content.
  final ImageContent content;

  /// Creates a [FunctionResultSubcontentImage] wrapping [content].
  const FunctionResultSubcontentImage(this.content);

  @override
  Map<String, dynamic> toJson() => content.toJson();
}

/// A function declaration returned for a client-side tool search.
class FunctionResultSubcontentFunction extends FunctionResultSubcontent {
  @override
  String get type => 'function';

  /// The matching function declaration.
  final FunctionTool function;

  /// Creates a tool result item containing [function].
  const FunctionResultSubcontentFunction(this.function);

  @override
  Map<String, dynamic> toJson() => function.toJson();
}

/// An [AudioContent] item used in a function or MCP tool result.
class FunctionResultSubcontentAudio extends FunctionResultSubcontent {
  @override
  String get type => 'audio';

  /// The wrapped audio content.
  final AudioContent content;

  /// Creates a result item containing audio.
  const FunctionResultSubcontentAudio(this.content);

  @override
  Map<String, dynamic> toJson() => content.toJson();
}

/// A [DocumentContent] item used in a function or MCP tool result.
class FunctionResultSubcontentDocument extends FunctionResultSubcontent {
  @override
  String get type => 'document';

  /// The wrapped document content.
  final DocumentContent content;

  /// Creates a result item containing a document.
  const FunctionResultSubcontentDocument(this.content);

  @override
  Map<String, dynamic> toJson() => content.toJson();
}

/// A [VideoContent] item used in a function or MCP tool result.
class FunctionResultSubcontentVideo extends FunctionResultSubcontent {
  @override
  String get type => 'video';

  /// The wrapped video content.
  final VideoContent content;

  /// Creates a result item containing video.
  const FunctionResultSubcontentVideo(this.content);

  @override
  Map<String, dynamic> toJson() => content.toJson();
}

/// Function result subcontent using an unrecognized wire discriminator.
class UnknownFunctionResultSubcontent extends FunctionResultSubcontent {
  @override
  String get type => rawJson['type']?.toString() ?? 'unknown';

  /// The original content block.
  final Map<String, dynamic> rawJson;

  /// Preserves an unrecognized result item.
  UnknownFunctionResultSubcontent(Map<String, dynamic> json)
    : rawJson = Map<String, dynamic>.unmodifiable(json);

  @override
  Map<String, dynamic> toJson() => {...rawJson};
}
