import 'package:meta/meta.dart';

/// A future execution scheduled for a workflow.
@immutable
class ScheduleFutureExecution {
  /// Time the execution is scheduled to run.
  final String scheduledAt;

  /// Creates a [ScheduleFutureExecution].
  const ScheduleFutureExecution({required this.scheduledAt});

  /// Creates a [ScheduleFutureExecution] from JSON.
  factory ScheduleFutureExecution.fromJson(Map<String, dynamic> json) =>
      ScheduleFutureExecution(
        scheduledAt: json['scheduled_at'] as String? ?? '',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'scheduled_at': scheduledAt};

  /// Creates a copy with replaced values.
  ScheduleFutureExecution copyWith({String? scheduledAt}) =>
      ScheduleFutureExecution(scheduledAt: scheduledAt ?? this.scheduledAt);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleFutureExecution) return false;
    if (runtimeType != other.runtimeType) return false;
    return scheduledAt == other.scheduledAt;
  }

  @override
  int get hashCode => scheduledAt.hashCode;

  @override
  String toString() => 'ScheduleFutureExecution(scheduledAt: $scheduledAt)';
}
