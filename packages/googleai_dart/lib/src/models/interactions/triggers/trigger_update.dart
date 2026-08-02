part of 'triggers.dart';

/// Represents the fields of a [Trigger] that can be updated.
class TriggerUpdate {
  /// Optional. The display name of the trigger.
  final String? displayName;

  /// Optional. The status of the trigger.
  final TriggerStatus? status;

  /// Creates a [TriggerUpdate].
  const TriggerUpdate({this.displayName, this.status});

  /// Creates a [TriggerUpdate] from JSON.
  factory TriggerUpdate.fromJson(Map<String, dynamic> json) => TriggerUpdate(
    displayName: json['display_name'] as String?,
    status: triggerStatusFromString(json['status'] as String?),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (displayName != null) 'display_name': displayName,
    if (status != null) 'status': triggerStatusToString(status!),
  };

  /// Creates a copy with replaced values.
  TriggerUpdate copyWith({
    Object? displayName = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
  }) {
    return TriggerUpdate(
      displayName: displayName == unsetCopyWithValue
          ? this.displayName
          : displayName as String?,
      status: status == unsetCopyWithValue
          ? this.status
          : status as TriggerStatus?,
    );
  }
}
