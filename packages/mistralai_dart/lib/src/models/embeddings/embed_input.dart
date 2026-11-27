import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../content/content_part.dart';

/// Input for an embedding request.
///
/// Use [EmbedInputString] or [EmbedInputList] for text. A single
/// [EmbedInputImage] or [EmbedInputAudio] can be sent to a multimodal model,
/// and [EmbedInputBatch] can combine supported input types.
///
/// ## Example
///
/// ```dart
/// // Single string
/// final single = EmbedInput.string('Hello!');
///
/// // Multiple strings
/// final batch = EmbedInput.list(['Hello!', 'World!']);
/// ```
@immutable
sealed class EmbedInput {
  const EmbedInput();

  /// Decodes one supported input or a batch of supported inputs.
  /// A text-only array is decoded as an [EmbedInputList].
  factory EmbedInput.fromJson(Object json) {
    if (json is List<Object?>) {
      if (json.every((value) => value is String)) {
        return EmbedInputList(json.cast<String>());
      }
      return EmbedInputBatch(json.map(EmbedInputItem.fromJson).toList());
    }
    return EmbedInputItem.fromJson(json);
  }

  /// Creates input from a single string.
  const factory EmbedInput.string(String value) = EmbedInputString;

  /// Creates input from a list of strings.
  const factory EmbedInput.list(List<String> values) = EmbedInputList;

  /// Creates input from a single image URL or an image data URL.
  const factory EmbedInput.image(ImageUrlContentPart image) = EmbedInputImage;

  /// Creates input from a single audio chunk.
  const factory EmbedInput.audio(AudioContentPart audio) = EmbedInputAudio;

  /// Creates a batch of image, audio, or text inputs.
  const factory EmbedInput.batch(List<EmbedInputItem> items) = EmbedInputBatch;

  /// Converts to JSON format expected by the API.
  Object toJson();
}

/// A single text, image, or audio input in a multimodal embedding request.
sealed class EmbedInputItem extends EmbedInput {
  const EmbedInputItem();

  /// Creates a single supported input from its JSON representation.
  factory EmbedInputItem.fromJson(Object? json) => switch (json) {
    final String text => EmbedInputString(text),
    final Map<String, dynamic> part when part['type'] == 'image_url' =>
      EmbedInputImage(ImageUrlContentPart.fromJson(part)),
    final Map<String, dynamic> part when part['type'] == 'input_audio' =>
      EmbedInputAudio(AudioContentPart.fromJson(part)),
    _ => throw const FormatException(
      'Expected a text, image, or audio embedding input',
    ),
  };
}

/// Single string input for embeddings.
@immutable
class EmbedInputString extends EmbedInputItem {
  /// Creates a single string input.
  const EmbedInputString(this.value);

  /// The input text.
  final String value;

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbedInputString &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'EmbedInputString($value)';
}

/// List of string inputs for batch embeddings.
@immutable
class EmbedInputList extends EmbedInput {
  /// Creates a list input.
  const EmbedInputList(this.values);

  /// The input texts.
  final List<String> values;

  @override
  Object toJson() => values;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EmbedInputList && listsEqual(values, other.values);
  }

  @override
  int get hashCode => listHash(values);

  @override
  String toString() => 'EmbedInputList(${values.length} values)';
}

/// Single image input for multimodal embeddings.
@immutable
class EmbedInputImage extends EmbedInputItem {
  /// The image URL chunk to embed.
  final ImageUrlContentPart image;

  /// Creates an image input.
  const EmbedInputImage(this.image);

  @override
  Object toJson() => image.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbedInputImage && image == other.image;

  @override
  int get hashCode => image.hashCode;

  @override
  String toString() => 'EmbedInputImage(detail: ${image.detail})';
}

/// Single audio input for multimodal embeddings.
@immutable
class EmbedInputAudio extends EmbedInputItem {
  /// The audio chunk to embed.
  final AudioContentPart audio;

  /// Creates an audio input.
  const EmbedInputAudio(this.audio);

  @override
  Object toJson() => audio.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbedInputAudio && audio == other.audio;

  @override
  int get hashCode => audio.hashCode;

  @override
  String toString() => 'EmbedInputAudio(audio: $audio)';
}

/// Multiple inputs that may mix text, images, and audio.
@immutable
class EmbedInputBatch extends EmbedInput {
  /// Inputs in the order sent to the embedding model.
  final List<EmbedInputItem> items;

  /// Creates a multimodal batch.
  const EmbedInputBatch(this.items);

  @override
  Object toJson() => items.map((item) => item.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbedInputBatch && listsEqual(items, other.items);

  @override
  int get hashCode => listHash(items);

  @override
  String toString() => 'EmbedInputBatch(${items.length} inputs)';
}
