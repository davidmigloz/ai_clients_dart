import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';

/// Request to detach a function from a collection.
@immutable
class DetachFunctionRequest {
  /// Whether to delete the output collection when detaching.
  final bool? deleteOutput;

  /// Creates a detach function request.
  const DetachFunctionRequest({this.deleteOutput});

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() {
    return {if (deleteOutput != null) 'delete_output': deleteOutput};
  }

  /// Creates a copy with replaced values.
  DetachFunctionRequest copyWith({Object? deleteOutput = unsetCopyWithValue}) {
    return DetachFunctionRequest(
      deleteOutput: deleteOutput == unsetCopyWithValue
          ? this.deleteOutput
          : deleteOutput as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetachFunctionRequest &&
          runtimeType == other.runtimeType &&
          deleteOutput == other.deleteOutput;

  @override
  int get hashCode => deleteOutput.hashCode;

  @override
  String toString() => 'DetachFunctionRequest(deleteOutput: $deleteOutput)';
}
