part of 'deltas.dart';

/// A text annotation delta update containing citation information.
class TextAnnotationDelta extends InteractionDelta {
  @override
  String get type => 'text_annotation';

  /// Citation information for model-generated content.
  final List<Annotation>? annotations;

  /// Creates a [TextAnnotationDelta] instance.
  const TextAnnotationDelta({this.annotations});

  /// Creates a [TextAnnotationDelta] from JSON.
  factory TextAnnotationDelta.fromJson(Map<String, dynamic> json) =>
      TextAnnotationDelta(
        annotations: (json['annotations'] as List<dynamic>?)
            ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (annotations != null)
      'annotations': annotations!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  TextAnnotationDelta copyWith({Object? annotations = unsetCopyWithValue}) {
    return TextAnnotationDelta(
      annotations: annotations == unsetCopyWithValue
          ? this.annotations
          : annotations as List<Annotation>?,
    );
  }
}
