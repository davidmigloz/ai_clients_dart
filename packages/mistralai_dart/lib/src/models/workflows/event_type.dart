/// Type of trace event.
enum EventType {
  /// A standard trace event.
  event('EVENT'),

  /// A progress trace event.
  eventProgress('EVENT_PROGRESS'),

  /// Unknown event type (forward-compatibility fallback).
  unknown('unknown');

  const EventType(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [EventType] from a JSON string value.
  static EventType fromJson(String? value) {
    if (value == null) return EventType.unknown;
    return EventType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventType.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
