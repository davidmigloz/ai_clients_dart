import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Body for resetting a workflow execution.
@immutable
class ResetInvocationBody {
  /// The event ID to reset to.
  final int eventId;

  /// Whether to exclude signals.
  final bool excludeSignals;

  /// Whether to exclude updates.
  final bool excludeUpdates;

  /// The reason for the reset.
  final String? reason;

  /// Creates a [ResetInvocationBody].
  const ResetInvocationBody({
    required this.eventId,
    this.excludeSignals = false,
    this.excludeUpdates = false,
    this.reason,
  });

  /// Creates a [ResetInvocationBody] from JSON.
  factory ResetInvocationBody.fromJson(Map<String, dynamic> json) =>
      ResetInvocationBody(
        eventId: json['event_id'] as int? ?? 0,
        excludeSignals: json['exclude_signals'] as bool? ?? false,
        excludeUpdates: json['exclude_updates'] as bool? ?? false,
        reason: json['reason'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'event_id': eventId,
    'exclude_signals': excludeSignals,
    'exclude_updates': excludeUpdates,
    if (reason != null) 'reason': reason,
  };

  /// Creates a copy with replaced values.
  ResetInvocationBody copyWith({
    int? eventId,
    bool? excludeSignals,
    bool? excludeUpdates,
    Object? reason = unsetCopyWithValue,
  }) {
    return ResetInvocationBody(
      eventId: eventId ?? this.eventId,
      excludeSignals: excludeSignals ?? this.excludeSignals,
      excludeUpdates: excludeUpdates ?? this.excludeUpdates,
      reason: reason == unsetCopyWithValue ? this.reason : reason as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResetInvocationBody) return false;
    if (runtimeType != other.runtimeType) return false;
    return eventId == other.eventId &&
        excludeSignals == other.excludeSignals &&
        excludeUpdates == other.excludeUpdates &&
        reason == other.reason;
  }

  @override
  int get hashCode =>
      Object.hash(eventId, excludeSignals, excludeUpdates, reason);

  @override
  String toString() =>
      'ResetInvocationBody('
      'eventId: $eventId, '
      'excludeSignals: $excludeSignals, '
      'excludeUpdates: $excludeUpdates, '
      'reason: $reason'
      ')';
}
