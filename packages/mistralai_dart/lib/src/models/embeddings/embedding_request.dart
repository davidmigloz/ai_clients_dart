import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import '../common/copy_with_sentinel.dart';
import 'embedding_dtype.dart';

/// Request for generating embeddings.
@immutable
class EmbeddingRequest {
  /// The model to use for generating embeddings.
  final String model;

  /// The input text(s) to generate embeddings for.
  ///
  /// Can be a single string or a list of strings.
  final Object input;

  /// The format to return embeddings in.
  ///
  /// Can be "float" (default) or "base64".
  final String? encodingFormat;

  /// The number of dimensions for the output embeddings.
  ///
  /// When specified, the model truncates the embedding vectors to this
  /// dimension. Useful for reducing storage size while maintaining
  /// semantic quality.
  final int? outputDimension;

  /// The data type for the output embeddings.
  ///
  /// Controls the format of the embedding vectors. Options include:
  /// - [EmbeddingDtype.float] - Full precision (default)
  /// - [EmbeddingDtype.int8] - 8-bit signed integer quantization
  /// - [EmbeddingDtype.uint8] - 8-bit unsigned integer quantization
  /// - [EmbeddingDtype.binary] - Binary quantization
  /// - [EmbeddingDtype.ubinary] - Unsigned binary quantization
  final EmbeddingDtype? outputDtype;

  /// Creates an [EmbeddingRequest].
  const EmbeddingRequest({
    required this.model,
    required this.input,
    this.encodingFormat,
    this.outputDimension,
    this.outputDtype,
  });

  /// Creates an [EmbeddingRequest] for a single input.
  factory EmbeddingRequest.single({
    required String model,
    required String input,
    String? encodingFormat,
    int? outputDimension,
    EmbeddingDtype? outputDtype,
  }) => EmbeddingRequest(
    model: model,
    input: input,
    encodingFormat: encodingFormat,
    outputDimension: outputDimension,
    outputDtype: outputDtype,
  );

  /// Creates an [EmbeddingRequest] for multiple inputs.
  factory EmbeddingRequest.batch({
    required String model,
    required List<String> input,
    String? encodingFormat,
    int? outputDimension,
    EmbeddingDtype? outputDtype,
  }) => EmbeddingRequest(
    model: model,
    input: input,
    encodingFormat: encodingFormat,
    outputDimension: outputDimension,
    outputDtype: outputDtype,
  );

  /// Creates an [EmbeddingRequest] from JSON.
  factory EmbeddingRequest.fromJson(Map<String, dynamic> json) =>
      EmbeddingRequest(
        model: json['model'] as String? ?? '',
        input: json['input'] as Object,
        encodingFormat: json['encoding_format'] as String?,
        outputDimension: json['output_dimension'] as int?,
        outputDtype: json['output_dtype'] != null
            ? EmbeddingDtype.fromString(json['output_dtype'] as String?)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'input': input,
    if (encodingFormat != null) 'encoding_format': encodingFormat,
    if (outputDimension != null) 'output_dimension': outputDimension,
    if (outputDtype != null) 'output_dtype': outputDtype!.value,
  };

  /// Creates a copy with replaced values.
  EmbeddingRequest copyWith({
    String? model,
    Object? input,
    Object? encodingFormat = unsetCopyWithValue,
    Object? outputDimension = unsetCopyWithValue,
    Object? outputDtype = unsetCopyWithValue,
  }) {
    return EmbeddingRequest(
      model: model ?? this.model,
      input: input ?? this.input,
      encodingFormat: encodingFormat == unsetCopyWithValue
          ? this.encodingFormat
          : encodingFormat as String?,
      outputDimension: outputDimension == unsetCopyWithValue
          ? this.outputDimension
          : outputDimension as int?,
      outputDtype: outputDtype == unsetCopyWithValue
          ? this.outputDtype
          : outputDtype as EmbeddingDtype?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddingRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          _inputEquals(input, other.input) &&
          encodingFormat == other.encodingFormat &&
          outputDimension == other.outputDimension &&
          outputDtype == other.outputDtype;

  /// Compares input fields which can be String or `List<String>`.
  static bool _inputEquals(Object a, Object b) {
    if (identical(a, b)) return true;
    if (a is String && b is String) return a == b;
    if (a is List && b is List) return listEquals(a, b);
    return false;
  }

  @override
  int get hashCode =>
      Object.hash(model, input, encodingFormat, outputDimension, outputDtype);

  @override
  String toString() =>
      'EmbeddingRequest(model: $model, input: $input, '
      'encodingFormat: $encodingFormat, outputDimension: $outputDimension, '
      'outputDtype: $outputDtype)';
}
