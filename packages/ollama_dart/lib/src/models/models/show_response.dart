import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Response containing model details.
@immutable
class ShowResponse {
  /// Model parameter settings serialized as text.
  final String? parameters;

  /// The license of the model.
  final String? license;

  /// Last modified timestamp in ISO 8601 format.
  final String? modifiedAt;

  /// High-level model details.
  final Map<String, dynamic>? details;

  /// The template used by the model to render prompts.
  final String? template;

  /// List of supported features.
  final List<String>? capabilities;

  /// Additional model metadata.
  final Map<String, dynamic>? modelInfo;

  /// Creates a [ShowResponse].
  const ShowResponse({
    this.parameters,
    this.license,
    this.modifiedAt,
    this.details,
    this.template,
    this.capabilities,
    this.modelInfo,
  });

  /// Creates a [ShowResponse] from JSON.
  factory ShowResponse.fromJson(Map<String, dynamic> json) => ShowResponse(
    parameters: json['parameters'] as String?,
    license: json['license'] as String?,
    modifiedAt: json['modified_at'] as String?,
    details: json['details'] as Map<String, dynamic>?,
    template: json['template'] as String?,
    capabilities: (json['capabilities'] as List?)?.cast<String>(),
    modelInfo: json['model_info'] as Map<String, dynamic>?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (parameters != null) 'parameters': parameters,
    if (license != null) 'license': license,
    if (modifiedAt != null) 'modified_at': modifiedAt,
    if (details != null) 'details': details,
    if (template != null) 'template': template,
    if (capabilities != null) 'capabilities': capabilities,
    if (modelInfo != null) 'model_info': modelInfo,
  };

  /// Creates a copy with replaced values.
  ShowResponse copyWith({
    Object? parameters = unsetCopyWithValue,
    Object? license = unsetCopyWithValue,
    Object? modifiedAt = unsetCopyWithValue,
    Object? details = unsetCopyWithValue,
    Object? template = unsetCopyWithValue,
    Object? capabilities = unsetCopyWithValue,
    Object? modelInfo = unsetCopyWithValue,
  }) {
    return ShowResponse(
      parameters: parameters == unsetCopyWithValue
          ? this.parameters
          : parameters as String?,
      license: license == unsetCopyWithValue
          ? this.license
          : license as String?,
      modifiedAt: modifiedAt == unsetCopyWithValue
          ? this.modifiedAt
          : modifiedAt as String?,
      details: details == unsetCopyWithValue
          ? this.details
          : details as Map<String, dynamic>?,
      template: template == unsetCopyWithValue
          ? this.template
          : template as String?,
      capabilities: capabilities == unsetCopyWithValue
          ? this.capabilities
          : capabilities as List<String>?,
      modelInfo: modelInfo == unsetCopyWithValue
          ? this.modelInfo
          : modelInfo as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShowResponse &&
          runtimeType == other.runtimeType &&
          parameters == other.parameters &&
          license == other.license &&
          modifiedAt == other.modifiedAt &&
          template == other.template;

  @override
  int get hashCode => Object.hash(parameters, license, modifiedAt, template);

  @override
  String toString() => 'ShowResponse(capabilities: $capabilities)';
}
