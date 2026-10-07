/// The status of a web search call.
enum WebSearchCallStatus {
  /// Fallback for an unrecognized status.
  unknown('unknown'),

  /// The call is being prepared.
  inProgress('in_progress'),

  /// The search is executing.
  searching('searching'),

  /// The call completed.
  completed('completed'),

  /// The call failed.
  failed('failed'),

  /// The call did not complete.
  incomplete('incomplete');

  /// The wire value.
  final String value;

  const WebSearchCallStatus(this.value);

  /// Parses a wire value, retaining forward compatibility for new statuses.
  factory WebSearchCallStatus.fromJson(String json) =>
      WebSearchCallStatus.values.firstWhere(
        (value) => value.value == json,
        orElse: () => WebSearchCallStatus.unknown,
      );

  /// Converts to the wire value.
  String toJson() => value;
}
