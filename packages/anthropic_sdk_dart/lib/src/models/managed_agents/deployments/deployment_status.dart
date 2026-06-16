/// Lifecycle status of a deployment.
enum DeploymentStatus {
  /// Unknown status (forward compatibility for unrecognized values).
  unknown('unknown'),

  /// The deployment is active and its schedule fires runs.
  active('active'),

  /// The deployment is paused and its schedule does not fire runs.
  paused('paused');

  const DeploymentStatus(this.value);

  /// JSON value for this status.
  final String value;

  /// Creates a [DeploymentStatus] from a JSON value.
  factory DeploymentStatus.fromJson(String json) {
    return DeploymentStatus.values.firstWhere(
      (e) => e.value == json,
      orElse: () => DeploymentStatus.unknown,
    );
  }

  /// Converts to JSON string.
  String toJson() => value;
}
