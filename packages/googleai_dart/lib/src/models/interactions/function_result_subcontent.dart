import 'content/content.dart';
import 'tools/tools.dart';

/// A subcontent item within a function or MCP server tool result.
///
/// Variants include [FunctionResultSubcontentText],
/// [FunctionResultSubcontentImage], and [FunctionResultSubcontentFunction].
sealed class FunctionResultSubcontent {
  /// The type discriminator for this subcontent.
  String get type;

  const FunctionResultSubcontent();

  /// Creates a [FunctionResultSubcontent] from JSON.
  factory FunctionResultSubcontent.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'text' => FunctionResultSubcontentText(TextContent.fromJson(json)),
      'image' => FunctionResultSubcontentImage(ImageContent.fromJson(json)),
      'function' => FunctionResultSubcontentFunction(
        FunctionTool.fromJson(json),
      ),
      _ => throw ArgumentError(
        'Unknown function result subcontent type: ${json['type']}',
      ),
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
