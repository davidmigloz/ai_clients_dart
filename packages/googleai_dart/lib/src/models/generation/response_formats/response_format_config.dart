import '../../copy_with_sentinel.dart';
import 'audio_response_format.dart';
import 'image_response_format.dart';
import 'text_response_format.dart';

/// Configuration for the response output format.
///
/// Allows specifying output configuration per modality (text, audio, image)
/// in a flat structure.
class ResponseFormatConfig {
  /// Text output format configuration.
  final TextResponseFormat? text;

  /// Audio output format configuration.
  final AudioResponseFormat? audio;

  /// Image output format configuration.
  final ImageResponseFormat? image;

  /// Creates a [ResponseFormatConfig].
  const ResponseFormatConfig({this.text, this.audio, this.image});

  /// Creates a [ResponseFormatConfig] from JSON.
  factory ResponseFormatConfig.fromJson(
    Map<String, dynamic> json,
  ) => ResponseFormatConfig(
    text: json['text'] != null
        ? TextResponseFormat.fromJson(json['text'] as Map<String, dynamic>)
        : null,
    audio: json['audio'] != null
        ? AudioResponseFormat.fromJson(json['audio'] as Map<String, dynamic>)
        : null,
    image: json['image'] != null
        ? ImageResponseFormat.fromJson(json['image'] as Map<String, dynamic>)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (text != null) 'text': text!.toJson(),
    if (audio != null) 'audio': audio!.toJson(),
    if (image != null) 'image': image!.toJson(),
  };

  /// Creates a copy with replaced values.
  ResponseFormatConfig copyWith({
    Object? text = unsetCopyWithValue,
    Object? audio = unsetCopyWithValue,
    Object? image = unsetCopyWithValue,
  }) {
    return ResponseFormatConfig(
      text: text == unsetCopyWithValue
          ? this.text
          : text as TextResponseFormat?,
      audio: audio == unsetCopyWithValue
          ? this.audio
          : audio as AudioResponseFormat?,
      image: image == unsetCopyWithValue
          ? this.image
          : image as ImageResponseFormat?,
    );
  }
}
