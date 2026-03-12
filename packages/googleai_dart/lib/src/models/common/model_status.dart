import '../copy_with_sentinel.dart';
import 'model_stage.dart';

/// Status of a model.
class ModelStatus {
  /// Optional. A message describing the status.
  final String? message;

  /// Optional. The current stage of the model.
  final ModelStage? modelStage;

  /// Optional. The time when the model will be retired.
  final DateTime? retirementTime;

  /// Creates a [ModelStatus].
  const ModelStatus({this.message, this.modelStage, this.retirementTime});

  /// Creates a [ModelStatus] from JSON.
  factory ModelStatus.fromJson(Map<String, dynamic> json) => ModelStatus(
    message: json['message'] as String?,
    modelStage: json['modelStage'] != null
        ? modelStageFromString(json['modelStage'] as String)
        : null,
    retirementTime: json['retirementTime'] != null
        ? DateTime.parse(json['retirementTime'] as String)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (message != null) 'message': message,
    if (modelStage != null) 'modelStage': modelStageToString(modelStage!),
    if (retirementTime != null)
      'retirementTime': retirementTime!.toIso8601String(),
  };

  /// Creates a copy with replaced values.
  ModelStatus copyWith({
    Object? message = unsetCopyWithValue,
    Object? modelStage = unsetCopyWithValue,
    Object? retirementTime = unsetCopyWithValue,
  }) {
    return ModelStatus(
      message: message == unsetCopyWithValue
          ? this.message
          : message as String?,
      modelStage: modelStage == unsetCopyWithValue
          ? this.modelStage
          : modelStage as ModelStage?,
      retirementTime: retirementTime == unsetCopyWithValue
          ? this.retirementTime
          : retirementTime as DateTime?,
    );
  }

  @override
  String toString() =>
      'ModelStatus(message: $message, modelStage: $modelStage, retirementTime: ${retirementTime?.toIso8601String()})';
}
