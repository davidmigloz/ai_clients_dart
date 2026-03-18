import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import '../common/copy_with_sentinel.dart';
import 'embed_input.dart';
import 'embedding_dtype.dart';

/// Request for generating embeddings.
@immutable
class EmbeddingRequest {
  /// The model to use for generating embeddings.
  final String model;

  /// The input text(s) to generate embeddings for.
  ///
  /// Can be a single string ([EmbedInputString]) or a list of strings
  /// ([EmbedInputList]).
  final EmbedInput input;

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

  /// Optional metadata for the request.
  final Map<String, dynamic>? metadata;

  /// Creates an [EmbeddingRequest].
  const EmbeddingRequest({
    required this.model,
    required this.input,
    this.encodingFormat,
    this.outputDimension,
    this.outputDtype,
    this.metadata,
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
    input: EmbedInput.string(input),
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
    input: EmbedInput.list(input),
    encodingFormat: encodingFormat,
    outputDimension: outputDimension,
    outputDtype: outputDtype,
  );

  /// Creates an [EmbeddingRequest] from JSON.
  factory EmbeddingRequest.fromJson(Map<String, dynamic> json) =>
      EmbeddingRequest(
        model: json['model'] as String? ?? '',
        input: EmbedInput.fromJson(json['input'] as Object),
        encodingFormat: json['encoding_format'] as String?,
        outputDimension: json['output_dimension'] as int?,
        outputDtype: json['output_dtype'] != null
            ? EmbeddingDtype.fromString(json['output_dtype'] as String?)
            : null,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'input': input.toJson(),
    if (encodingFormat != null) 'encoding_format': encodingFormat,
    if (outputDimension != null) 'output_dimension': outputDimension,
    if (outputDtype != null) 'output_dtype': outputDtype!.value,
    if (metadata != null) 'metadata': metadata,
  };

  /// Creates a copy with replaced values.
  EmbeddingRequest copyWith({
    String? model,
    EmbedInput? input,
    Object? encodingFormat = unsetCopyWithValue,
    Object? outputDimension = unsetCopyWithValue,
    Object? outputDtype = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
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
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddingRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          input == other.input &&
          encodingFormat == other.encodingFormat &&
          outputDimension == other.outputDimension &&
          outputDtype == other.outputDtype &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(
    model,
    input,
    encodingFormat,
    outputDimension,
    outputDtype,
    mapHash(metadata),
  );

  @override
  String toString() =>
      'EmbeddingRequest(model: $model, input: $input, '
      'encodingFormat: $encodingFormat, outputDimension: $outputDimension, '
      'outputDtype: $outputDtype, metadata: $metadata)';
}
