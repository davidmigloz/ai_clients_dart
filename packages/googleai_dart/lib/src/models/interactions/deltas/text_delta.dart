part of 'deltas.dart';

/// A text delta update.
class TextDelta extends InteractionDelta {
  @override
  String get type => 'text';

  /// The text content.
  final String? text;

  /// Creates a [TextDelta] instance.
  const TextDelta({this.text});

  /// Creates a [TextDelta] from JSON.
  factory TextDelta.fromJson(Map<String, dynamic> json) =>
      TextDelta(text: json['text'] as String?);

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (text != null) 'text': text,
  };
}
