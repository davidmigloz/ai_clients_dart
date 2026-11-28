import '../copy_with_sentinel.dart';

/// Request message for PredictLongRunning operation.
///
/// Used for asynchronous prediction requests that return a long-running operation,
/// typically for video generation with Veo.
class PredictLongRunningRequest {
  /// Required. The instances that are the input to the prediction call.
  final List<dynamic> instances;

  /// Optional. The parameters that govern the prediction call.
  final dynamic parameters;

  /// Optional user-defined request metadata.
  ///
  /// Declared by Gemini Developer API `v1beta` discovery and supported by
  /// Vertex AI Veo on regional endpoints. Keys and values follow Cloud label
  /// requirements.
  final Map<String, String>? labels;

  /// Creates a [PredictLongRunningRequest].
  const PredictLongRunningRequest({
    required this.instances,
    this.parameters,
    this.labels,
  });

  /// Creates a [PredictLongRunningRequest] from JSON.
  factory PredictLongRunningRequest.fromJson(Map<String, dynamic> json) =>
      PredictLongRunningRequest(
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
  PredictLongRunningRequest copyWith({
    Object? instances = unsetCopyWithValue,
    Object? parameters = unsetCopyWithValue,
    Object? labels = unsetCopyWithValue,
  }) {
    return PredictLongRunningRequest(
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
