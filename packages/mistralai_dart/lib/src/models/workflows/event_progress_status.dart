/// Status of event progress.
enum EventProgressStatus {
  /// Event is currently running.
  running('RUNNING'),

  /// Event completed successfully.
  completed('COMPLETED'),

  /// Event failed.
  failed('FAILED'),

  /// Unknown status (forward-compatibility fallback).
  unknown('unknown');

  const EventProgressStatus(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [EventProgressStatus] from a JSON string value.
  static EventProgressStatus fromJson(String? value) {
    if (value == null) return EventProgressStatus.unknown;
    return EventProgressStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventProgressStatus.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
