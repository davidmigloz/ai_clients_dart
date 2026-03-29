part of 'content.dart';

/// A text content block.
class TextContent extends InteractionContent {
  @override
  String get type => 'text';

  /// The text content.
  final String text;

  /// Citation information for model-generated content.
  final List<Annotation>? annotations;

  /// Creates a [TextContent] instance.
  const TextContent({required this.text, this.annotations});

  /// Creates a [TextContent] from JSON.
  ///
  /// The [text] field defaults to `''` when absent (e.g. content.start events).
  factory TextContent.fromJson(Map<String, dynamic> json) => TextContent(
    text: json['text'] as String? ?? '',
    annotations: (json['annotations'] as List<dynamic>?)
        ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'text': text,
    if (annotations != null)
      'annotations': annotations!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  TextContent copyWith({
    Object? text = unsetCopyWithValue,
    Object? annotations = unsetCopyWithValue,
  }) {
    return TextContent(
      text: text == unsetCopyWithValue ? this.text : text! as String,
      annotations: annotations == unsetCopyWithValue
          ? this.annotations
          : annotations as List<Annotation>?,
    );
  }
}
