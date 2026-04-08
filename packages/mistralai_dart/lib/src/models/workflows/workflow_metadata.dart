import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Metadata for a workflow.
@immutable
class WorkflowMetadata {
  /// The shared namespace.
  final String? sharedNamespace;

  /// Creates a [WorkflowMetadata].
  const WorkflowMetadata({this.sharedNamespace});

  /// Creates a [WorkflowMetadata] from JSON.
  factory WorkflowMetadata.fromJson(Map<String, dynamic> json) =>
      WorkflowMetadata(sharedNamespace: json['shared_namespace'] as String?);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (sharedNamespace != null) 'shared_namespace': sharedNamespace,
  };

  /// Creates a copy with replaced values.
  WorkflowMetadata copyWith({Object? sharedNamespace = unsetCopyWithValue}) {
    return WorkflowMetadata(
      sharedNamespace: sharedNamespace == unsetCopyWithValue
          ? this.sharedNamespace
          : sharedNamespace as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowMetadata) return false;
    if (runtimeType != other.runtimeType) return false;
    return sharedNamespace == other.sharedNamespace;
  }

  @override
  int get hashCode => sharedNamespace.hashCode;

  @override
  String toString() => 'WorkflowMetadata(sharedNamespace: $sharedNamespace)';
}
