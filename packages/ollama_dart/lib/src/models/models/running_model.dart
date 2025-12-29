import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Information about a currently running model.
@immutable
class RunningModel {
  /// Name of the running model.
  final String? model;

  /// Size of the model in bytes.
  final int? size;

  /// SHA256 digest of the model.
  final String? digest;

  /// Model details such as format and family.
  final Map<String, dynamic>? details;

  /// Time when the model will be unloaded.
  final String? expiresAt;

  /// VRAM usage in bytes.
  final int? sizeVram;

  /// Context length for the running model.
  final int? contextLength;

  /// Creates a [RunningModel].
  const RunningModel({
    this.model,
    this.size,
    this.digest,
    this.details,
    this.expiresAt,
    this.sizeVram,
    this.contextLength,
  });

  /// Creates a [RunningModel] from JSON.
  factory RunningModel.fromJson(Map<String, dynamic> json) => RunningModel(
    model: json['model'] as String?,
    size: json['size'] as int?,
    digest: json['digest'] as String?,
    details: json['details'] as Map<String, dynamic>?,
    expiresAt: json['expires_at'] as String?,
    sizeVram: json['size_vram'] as int?,
    contextLength: json['context_length'] as int?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (model != null) 'model': model,
    if (size != null) 'size': size,
    if (digest != null) 'digest': digest,
    if (details != null) 'details': details,
    if (expiresAt != null) 'expires_at': expiresAt,
    if (sizeVram != null) 'size_vram': sizeVram,
    if (contextLength != null) 'context_length': contextLength,
  };

  /// Creates a copy with replaced values.
  RunningModel copyWith({
    Object? model = unsetCopyWithValue,
    Object? size = unsetCopyWithValue,
    Object? digest = unsetCopyWithValue,
    Object? details = unsetCopyWithValue,
    Object? expiresAt = unsetCopyWithValue,
    Object? sizeVram = unsetCopyWithValue,
    Object? contextLength = unsetCopyWithValue,
  }) {
    return RunningModel(
      model: model == unsetCopyWithValue ? this.model : model as String?,
      size: size == unsetCopyWithValue ? this.size : size as int?,
      digest: digest == unsetCopyWithValue ? this.digest : digest as String?,
      details: details == unsetCopyWithValue
          ? this.details
          : details as Map<String, dynamic>?,
      expiresAt: expiresAt == unsetCopyWithValue
          ? this.expiresAt
          : expiresAt as String?,
      sizeVram: sizeVram == unsetCopyWithValue
          ? this.sizeVram
          : sizeVram as int?,
      contextLength: contextLength == unsetCopyWithValue
          ? this.contextLength
          : contextLength as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunningModel &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          digest == other.digest;

  @override
  int get hashCode => Object.hash(model, digest);

  @override
  String toString() => 'RunningModel(model: $model, sizeVram: $sizeVram)';
}
