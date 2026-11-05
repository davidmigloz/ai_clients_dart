import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Input for an embedding request.
///
/// Embed input can be:
/// - [EmbedInputString]: A single text string
/// - [EmbedInputList]: A list of text strings
/// - [EmbedInputMultimodal]: One item containing text, image, or audio
/// - [EmbedInputBatch]: A batch of text and multimodal items
///
/// Images and audio use base64-encoded file contents. Multimodal input requires
/// a model and Ollama server that support the supplied media.
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

  /// Creates [EmbedInput] from JSON.
  ///
  /// Accepts a string, a multimodal object, or a batch of either shape.
  factory EmbedInput.fromJson(Object json) {
    if (json is String) return EmbedInputString(json);
    if (json is Map<String, dynamic>) {
      return EmbedInputMultimodal.fromJson(json);
    }
    if (json is List) {
      if (json.every((item) => item is String)) {
        return EmbedInputList(List<String>.unmodifiable(json.cast<String>()));
      }
      return EmbedInputBatch([
        for (final item in json)
          if (item is String)
            EmbedInputString(item)
          else if (item is Map<String, dynamic>)
            EmbedInputMultimodal.fromJson(item)
          else
            throw FormatException(
              'Expected a string or multimodal object in EmbedInput batch, '
              'got ${item.runtimeType}',
            ),
      ]);
    }
    throw FormatException(
      'Expected a string, multimodal object, or list for EmbedInput, '
      'got ${json.runtimeType}',
    );
  }

  /// Creates input from a single string.
  const factory EmbedInput.string(String value) = EmbedInputString;

  /// Creates input from a list of strings.
  const factory EmbedInput.list(List<String> values) = EmbedInputList;

  /// Creates one multimodal item with optional text and base64-encoded media.
  const factory EmbedInput.multimodal({
    String? text,
    String? image,
    String? audio,
  }) = EmbedInputMultimodal;

  /// Creates a batch of string and multimodal items.
  ///
  /// Each item owns its media. Nested batches and [EmbedInputList] items are
  /// not accepted; add their individual strings instead.
  factory EmbedInput.batch(List<EmbedInput> values) = EmbedInputBatch;

  /// Converts to JSON format expected by the API.
  Object toJson();
}

/// Single string input for embeddings.
@immutable
class EmbedInputString extends EmbedInput {
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
    if (identical(this, other)) return true;
    if (other is! EmbedInputList || runtimeType != other.runtimeType) {
      return false;
    }
    if (values.length != other.values.length) return false;
    for (var i = 0; i < values.length; i++) {
      if (values[i] != other.values[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(values);

  @override
  String toString() => 'EmbedInputList(${values.length} values)';
}

/// One multimodal embedding item containing text, image, or audio.
///
/// [image] and [audio] contain base64-encoded file contents, without a data URL
/// prefix. Input content and model capability validation are left to the server.
@immutable
class EmbedInputMultimodal extends EmbedInput {
  /// Creates a multimodal input.
  const EmbedInputMultimodal({this.text, this.image, this.audio});

  /// Creates a multimodal input from JSON.
  factory EmbedInputMultimodal.fromJson(Map<String, dynamic> json) {
    for (final entry in json.entries) {
      if (!const {'text', 'image', 'audio'}.contains(entry.key)) {
        throw FormatException('Unknown embedding input field "${entry.key}"');
      }
      if (entry.value is! String) {
        throw FormatException('Embedding input.${entry.key} must be a string');
      }
    }
    return EmbedInputMultimodal(
      text: json['text'] as String?,
      image: json['image'] as String?,
      audio: json['audio'] as String?,
    );
  }

  /// Text accompanying the media, or text embedded on its own.
  final String? text;

  /// Base64-encoded image file contents.
  final String? image;

  /// Base64-encoded audio file contents.
  final String? audio;

  @override
  Map<String, dynamic> toJson() => {
    if (text != null) 'text': text,
    if (image != null) 'image': image,
    if (audio != null) 'audio': audio,
  };

  /// Creates a copy with replaced or cleared fields.
  EmbedInputMultimodal copyWith({
    Object? text = unsetCopyWithValue,
    Object? image = unsetCopyWithValue,
    Object? audio = unsetCopyWithValue,
  }) => EmbedInputMultimodal(
    text: text == unsetCopyWithValue ? this.text : text as String?,
    image: image == unsetCopyWithValue ? this.image : image as String?,
    audio: audio == unsetCopyWithValue ? this.audio : audio as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbedInputMultimodal &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          image == other.image &&
          audio == other.audio;

  @override
  int get hashCode => Object.hash(text, image, audio);

  @override
  String toString() =>
      'EmbedInputMultimodal(text: $text, '
      'image: ${image == null ? null : '${image!.length} chars'}, '
      'audio: ${audio == null ? null : '${audio!.length} chars'})';
}

/// Batch of individual text and multimodal embedding inputs.
@immutable
class EmbedInputBatch extends EmbedInput {
  /// Creates an immutable batch of string and multimodal items.
  EmbedInputBatch(List<EmbedInput> values)
    : values = List<EmbedInput>.unmodifiable(values) {
    if (values.any(
      (item) => item is! EmbedInputString && item is! EmbedInputMultimodal,
    )) {
      throw ArgumentError.value(
        values,
        'values',
        'Expected only string and multimodal items; nested batches are invalid',
      );
    }
  }

  /// Individual inputs in batch order.
  final List<EmbedInput> values;

  @override
  List<Object> toJson() => values.map((item) => item.toJson()).toList();

  /// Creates a copy with replaced inputs.
  EmbedInputBatch copyWith({List<EmbedInput>? values}) =>
      EmbedInputBatch(values ?? this.values);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbedInputBatch &&
          runtimeType == other.runtimeType &&
          listsEqual(values, other.values);

  @override
  int get hashCode => listHash(values);

  @override
  String toString() => 'EmbedInputBatch(values: ${values.length} items)';
}
