/// Source of workflow events.
enum EventSource {
  /// Events from the database.
  database('DATABASE'),

  /// Live events.
  live('LIVE'),

  /// Unknown event source (forward-compatibility fallback).
  unknown('unknown');

  const EventSource(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [EventSource] from a JSON string value.
  static EventSource fromJson(String? value) {
    if (value == null) return EventSource.unknown;
    return EventSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventSource.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
