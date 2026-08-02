/// Where a deployment runs.
enum LocationType {
  /// Runs locally.
  local('local'),

  /// Runs on a Kubernetes cluster.
  k8s('k8s'),

  /// Runs on Mistral-managed infrastructure.
  managed('managed'),

  /// Unknown location type (forward-compatibility fallback).
  unknown('unknown');

  const LocationType(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [LocationType] from a JSON string value.
  static LocationType fromJson(String? value) {
    if (value == null) return LocationType.unknown;
    return LocationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LocationType.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
