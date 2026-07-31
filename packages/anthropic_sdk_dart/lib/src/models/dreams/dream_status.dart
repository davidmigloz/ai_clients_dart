/// Lifecycle status of a Dream.
enum DreamStatus {
  /// The dream has not started processing yet.
  pending('pending'),

  /// The dream is actively processing.
  running('running'),

  /// The dream finished successfully.
  completed('completed'),

  /// The dream failed. See the dream's `error` field for details.
  failed('failed'),

  /// The dream was canceled before completion.
  canceled('canceled'),

  /// Unknown status — fallback for unrecognized values.
  unknown('unknown');

  const DreamStatus(this.value);

  /// JSON value for this status.
  final String value;

  /// Parses a [DreamStatus] from JSON.
  static DreamStatus fromJson(String value) => switch (value) {
    'pending' => DreamStatus.pending,
    'running' => DreamStatus.running,
    'completed' => DreamStatus.completed,
    'failed' => DreamStatus.failed,
    'canceled' => DreamStatus.canceled,
    _ => DreamStatus.unknown,
  };

  /// Converts this status to JSON.
  String toJson() => value;
}
