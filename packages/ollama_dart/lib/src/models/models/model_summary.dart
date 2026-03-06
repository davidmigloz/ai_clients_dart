import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'model_details.dart';

/// Summary information for a locally available model.
@immutable
class ModelSummary {
  /// Display name including tag (e.g., `llama3.2:latest`).
  final String? name;

  /// Model identifier used in API requests.
  final String? model;

  /// Remote model name when routed through a remote Ollama instance.
  final String? remoteModel;

  /// Remote host address when routed through a remote Ollama instance.
  final String? remoteHost;

  /// Last modified timestamp in ISO 8601 format.
  final String? modifiedAt;

  /// Total size of the model on disk in bytes.
  final int? size;

  /// SHA256 digest identifier of the model contents.
  final String? digest;

  /// Additional information about the model's format and family.
  final ModelDetails? details;

  /// Creates a [ModelSummary].
  const ModelSummary({
    this.name,
    this.model,
    this.remoteModel,
    this.remoteHost,
    this.modifiedAt,
    this.size,
    this.digest,
    this.details,
  });

  /// Creates a [ModelSummary] from JSON.
  factory ModelSummary.fromJson(Map<String, dynamic> json) => ModelSummary(
    name: json['name'] as String?,
    model: json['model'] as String?,
    remoteModel: json['remote_model'] as String?,
    remoteHost: json['remote_host'] as String?,
    modifiedAt: json['modified_at'] as String?,
    size: json['size'] as int?,
    digest: json['digest'] as String?,
    details: json['details'] != null
        ? ModelDetails.fromJson(json['details'] as Map<String, dynamic>)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (model != null) 'model': model,
    if (remoteModel != null) 'remote_model': remoteModel,
    if (remoteHost != null) 'remote_host': remoteHost,
    if (modifiedAt != null) 'modified_at': modifiedAt,
    if (size != null) 'size': size,
    if (digest != null) 'digest': digest,
    if (details != null) 'details': details!.toJson(),
  };

  /// Creates a copy with replaced values.
  ModelSummary copyWith({
    Object? name = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? remoteModel = unsetCopyWithValue,
    Object? remoteHost = unsetCopyWithValue,
    Object? modifiedAt = unsetCopyWithValue,
    Object? size = unsetCopyWithValue,
    Object? digest = unsetCopyWithValue,
    Object? details = unsetCopyWithValue,
  }) {
    return ModelSummary(
      name: name == unsetCopyWithValue ? this.name : name as String?,
      model: model == unsetCopyWithValue ? this.model : model as String?,
      remoteModel: remoteModel == unsetCopyWithValue
          ? this.remoteModel
          : remoteModel as String?,
      remoteHost: remoteHost == unsetCopyWithValue
          ? this.remoteHost
          : remoteHost as String?,
      modifiedAt: modifiedAt == unsetCopyWithValue
          ? this.modifiedAt
          : modifiedAt as String?,
      size: size == unsetCopyWithValue ? this.size : size as int?,
      digest: digest == unsetCopyWithValue ? this.digest : digest as String?,
      details: details == unsetCopyWithValue
          ? this.details
          : details as ModelDetails?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelSummary &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          digest == other.digest;

  @override
  int get hashCode => Object.hash(name, digest);

  @override
  String toString() => 'ModelSummary(name: $name, size: $size)';
}
