import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request to pause or resume a workflow schedule.
@immutable
class WorkflowSchedulePauseRequest {
  /// Optional note recorded in Temporal when pausing or resuming a schedule.
  final String? note;

  /// Creates a [WorkflowSchedulePauseRequest].
  const WorkflowSchedulePauseRequest({this.note});

  /// Creates a [WorkflowSchedulePauseRequest] from JSON.
  factory WorkflowSchedulePauseRequest.fromJson(Map<String, dynamic> json) =>
      WorkflowSchedulePauseRequest(note: json['note'] as String?);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (note != null) 'note': note};

  /// Creates a copy with replaced values.
  WorkflowSchedulePauseRequest copyWith({Object? note = unsetCopyWithValue}) {
    return WorkflowSchedulePauseRequest(
      note: note == unsetCopyWithValue ? this.note : note as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowSchedulePauseRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return note == other.note;
  }

  @override
  int get hashCode => note.hashCode;

  @override
  String toString() => 'WorkflowSchedulePauseRequest(note: $note)';
}
