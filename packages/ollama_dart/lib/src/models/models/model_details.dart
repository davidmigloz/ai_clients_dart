import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

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

  /// Creates a [ModelDetails].
  const ModelDetails({
    this.format,
    this.family,
    this.families,
    this.parameterSize,
    this.quantizationLevel,
    this.parentModel,
  });

  /// Creates a [ModelDetails] from JSON.
  factory ModelDetails.fromJson(Map<String, dynamic> json) => ModelDetails(
    format: json['format'] as String?,
    family: json['family'] as String?,
    families: (json['families'] as List?)?.cast<String>(),
    parameterSize: json['parameter_size'] as String?,
    quantizationLevel: json['quantization_level'] as String?,
    parentModel: json['parent_model'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (format != null) 'format': format,
    if (family != null) 'family': family,
    if (families != null) 'families': families,
    if (parameterSize != null) 'parameter_size': parameterSize,
    if (quantizationLevel != null) 'quantization_level': quantizationLevel,
    if (parentModel != null) 'parent_model': parentModel,
  };

  /// Creates a copy with replaced values.
  ModelDetails copyWith({
    Object? format = unsetCopyWithValue,
    Object? family = unsetCopyWithValue,
    Object? families = unsetCopyWithValue,
    Object? parameterSize = unsetCopyWithValue,
    Object? quantizationLevel = unsetCopyWithValue,
    Object? parentModel = unsetCopyWithValue,
  }) {
    return ModelDetails(
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
          family == other.family;

  @override
  int get hashCode => Object.hash(format, family);

  @override
  String toString() =>
      'ModelDetails(format: $format, family: $family, parameterSize: $parameterSize)';
}
