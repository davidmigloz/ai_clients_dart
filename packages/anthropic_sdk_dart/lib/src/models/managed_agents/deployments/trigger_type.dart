/// What triggered a deployment run.
enum TriggerType {
  /// Unknown trigger (forward compatibility for unrecognized values).
  unknown('unknown'),

  /// The run was fired by the deployment's cron schedule.
  schedule('schedule'),

  /// The run was started manually.
  manual('manual');

  const TriggerType(this.value);

  /// JSON value for this trigger type.
  final String value;

  /// Creates a [TriggerType] from a JSON value.
  factory TriggerType.fromJson(String json) {
    return TriggerType.values.firstWhere(
      (e) => e.value == json,
      orElse: () => TriggerType.unknown,
    );
  }

  /// Converts to JSON string.
  String toJson() => value;
}
