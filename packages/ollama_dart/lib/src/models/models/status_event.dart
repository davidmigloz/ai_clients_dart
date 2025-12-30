import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Streaming status event for model operations (create, pull, push).
@immutable
class StatusEvent {
  /// Human-readable status message.
  final String? status;

  /// Content digest associated with the status, if applicable.
  final String? digest;

  /// Total number of bytes expected for the operation.
  final int? total;

  /// Number of bytes transferred so far.
  final int? completed;

  /// Creates a [StatusEvent].
  const StatusEvent({this.status, this.digest, this.total, this.completed});

  /// Creates a [StatusEvent] from JSON.
  factory StatusEvent.fromJson(Map<String, dynamic> json) => StatusEvent(
    status: json['status'] as String?,
    digest: json['digest'] as String?,
    total: json['total'] as int?,
    completed: json['completed'] as int?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (status != null) 'status': status,
    if (digest != null) 'digest': digest,
    if (total != null) 'total': total,
    if (completed != null) 'completed': completed,
  };

  /// Creates a copy with replaced values.
  StatusEvent copyWith({
    Object? status = unsetCopyWithValue,
    Object? digest = unsetCopyWithValue,
    Object? total = unsetCopyWithValue,
    Object? completed = unsetCopyWithValue,
  }) {
    return StatusEvent(
      status: status == unsetCopyWithValue ? this.status : status as String?,
      digest: digest == unsetCopyWithValue ? this.digest : digest as String?,
      total: total == unsetCopyWithValue ? this.total : total as int?,
      completed: completed == unsetCopyWithValue
          ? this.completed
          : completed as int?,
    );
  }

  /// Progress as a fraction from 0.0 to 1.0, if total is available.
  double? get progress {
    if (total == null || total == 0) return null;
    return (completed ?? 0) / total!;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusEvent &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          digest == other.digest;

  @override
  int get hashCode => Object.hash(status, digest);

  @override
  String toString() =>
      'StatusEvent(status: $status, '
      'progress: ${progress != null ? '${(progress! * 100).toStringAsFixed(1)}%' : 'N/A'})';
}
