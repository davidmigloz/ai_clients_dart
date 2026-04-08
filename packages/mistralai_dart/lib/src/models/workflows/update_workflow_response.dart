import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Response for a workflow execution update.
@immutable
class UpdateWorkflowResponse {
  /// The update name.
  final String updateName;

  /// The update result.
  final Object result;

  /// Creates a [UpdateWorkflowResponse].
  const UpdateWorkflowResponse({
    required this.updateName,
    required this.result,
  });

  /// Creates a [UpdateWorkflowResponse] from JSON.
  factory UpdateWorkflowResponse.fromJson(Map<String, dynamic> json) =>
      UpdateWorkflowResponse(
        updateName: json['update_name'] as String? ?? '',
        result: json['result'] ?? const <String, dynamic>{},
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'update_name': updateName,
    'result': result,
  };

  /// Creates a copy with replaced values.
  UpdateWorkflowResponse copyWith({String? updateName, Object? result}) {
    return UpdateWorkflowResponse(
      updateName: updateName ?? this.updateName,
      result: result ?? this.result,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UpdateWorkflowResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return updateName == other.updateName &&
        valuesDeepEqual(result, other.result);
  }

  @override
  int get hashCode => Object.hash(updateName, valueDeepHashCode(result));

  @override
  String toString() =>
      'UpdateWorkflowResponse(updateName: $updateName, result: $result)';
}
