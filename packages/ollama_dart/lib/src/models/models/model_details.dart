import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Additional information about the model's format and family.
@immutable
class ModelDetails {
  /// Model file format (e.g., `gguf`).
  final String? format;

  /// Primary model family (e.g., `llama`).
  final String? family;

  /// All families the model belongs to, when applicable.
  final List<String>? families;

  /// Approximate parameter count label (e.g., `7B`, `13B`).
  final String? parameterSize;

  /// Quantization level used (e.g., `Q4_0`).
  final String? quantizationLevel;

  /// Parent model name, if applicable.
  final String? parentModel;

  /// Maximum context length advertised by the model, when available.
  final int? contextLength;

  /// Embedding vector length advertised by the model, when available.
  final int? embeddingLength;

  /// Creates a [ModelDetails].
  const ModelDetails({
    this.format,
    this.family,
    this.families,
    this.parameterSize,
    this.quantizationLevel,
    this.parentModel,
    this.contextLength,
    this.embeddingLength,
  });

  /// Creates a [ModelDetails] from JSON.
  factory ModelDetails.fromJson(Map<String, dynamic> json) => ModelDetails(
    contextLength: json['context_length'] as int?,
    embeddingLength: json['embedding_length'] as int?,
    format: json['format'] as String?,
    family: json['family'] as String?,
    families: (json['families'] as List?)?.cast<String>(),
    parameterSize: json['parameter_size'] as String?,
    quantizationLevel: json['quantization_level'] as String?,
    parentModel: json['parent_model'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (contextLength != null) 'context_length': contextLength,
    if (embeddingLength != null) 'embedding_length': embeddingLength,
    if (format != null) 'format': format,
    if (family != null) 'family': family,
    if (families != null) 'families': families,
    if (parameterSize != null) 'parameter_size': parameterSize,
    if (quantizationLevel != null) 'quantization_level': quantizationLevel,
    if (parentModel != null) 'parent_model': parentModel,
  };

  /// Creates a copy with replaced values.
  ModelDetails copyWith({
    Object? contextLength = unsetCopyWithValue,
    Object? embeddingLength = unsetCopyWithValue,
    Object? format = unsetCopyWithValue,
    Object? family = unsetCopyWithValue,
    Object? families = unsetCopyWithValue,
    Object? parameterSize = unsetCopyWithValue,
    Object? quantizationLevel = unsetCopyWithValue,
    Object? parentModel = unsetCopyWithValue,
  }) {
    return ModelDetails(
      contextLength: identical(contextLength, unsetCopyWithValue)
          ? this.contextLength
          : contextLength as int?,
      embeddingLength: identical(embeddingLength, unsetCopyWithValue)
          ? this.embeddingLength
          : embeddingLength as int?,
      format: format == unsetCopyWithValue ? this.format : format as String?,
      family: family == unsetCopyWithValue ? this.family : family as String?,
      families: families == unsetCopyWithValue
          ? this.families
          : families as List<String>?,
      parameterSize: parameterSize == unsetCopyWithValue
          ? this.parameterSize
          : parameterSize as String?,
      quantizationLevel: quantizationLevel == unsetCopyWithValue
          ? this.quantizationLevel
          : quantizationLevel as String?,
      parentModel: parentModel == unsetCopyWithValue
          ? this.parentModel
          : parentModel as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelDetails &&
          runtimeType == other.runtimeType &&
          format == other.format &&
          family == other.family &&
          listsEqual(families, other.families) &&
          parameterSize == other.parameterSize &&
          quantizationLevel == other.quantizationLevel &&
          parentModel == other.parentModel &&
          contextLength == other.contextLength &&
          embeddingLength == other.embeddingLength;

  @override
  int get hashCode => Object.hashAll([
    format,
    family,
    listHash(families),
    parameterSize,
    quantizationLevel,
    parentModel,
    contextLength,
    embeddingLength,
  ]);

  @override
  String toString() =>
      'ModelDetails('
      'format: $format, '
      'family: $family, '
      'families: $families, '
      'parameterSize: $parameterSize, '
      'quantizationLevel: $quantizationLevel, '
      'parentModel: $parentModel, '
      'contextLength: $contextLength, '
      'embeddingLength: $embeddingLength)';
}
