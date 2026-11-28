import '../copy_with_sentinel.dart';

/// Request message for Predict operation.
///
/// Used for synchronous prediction requests.
class PredictRequest {
  /// Required. The instances that are the input to the prediction call.
  final List<dynamic> instances;

  /// Optional. The parameters that govern the prediction call.
  final dynamic parameters;

  /// Optional user-defined request metadata.
  ///
  /// Declared by Gemini Developer API `v1beta` discovery. Vertex AI uses
  /// these labels for Imagen billing. Keys and values follow Cloud label
  /// requirements.
  final Map<String, String>? labels;

  /// Creates a [PredictRequest].
  const PredictRequest({required this.instances, this.parameters, this.labels});

  /// Creates a [PredictRequest] from JSON.
  factory PredictRequest.fromJson(Map<String, dynamic> json) => PredictRequest(
    instances: json['instances'] as List<dynamic>? ?? [],
    parameters: json['parameters'],
    labels: (json['labels'] as Map?)?.cast<String, String>(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'instances': instances,
    if (parameters != null) 'parameters': parameters,
    'labels': ?labels,
  };

  /// Creates a copy with replaced values.
  PredictRequest copyWith({
    Object? instances = unsetCopyWithValue,
    Object? parameters = unsetCopyWithValue,
    Object? labels = unsetCopyWithValue,
  }) {
    return PredictRequest(
      instances: instances == unsetCopyWithValue
          ? this.instances
          : instances! as List<dynamic>,
      parameters: parameters == unsetCopyWithValue
          ? this.parameters
          : parameters,
      labels: labels == unsetCopyWithValue
          ? this.labels
          : labels as Map<String, String>?,
    );
  }
}
