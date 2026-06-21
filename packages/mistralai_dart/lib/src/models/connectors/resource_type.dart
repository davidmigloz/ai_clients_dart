/// Type of the owner of a connector resource.
///
/// Represented in the API as an integer code.
enum ResourceType {
  /// User-owned resource.
  user(1),

  /// Organization-owned resource.
  org(2),

  /// Workspace-owned resource.
  workspace(3),

  /// System-owned resource.
  system(4),

  /// Unknown resource type (forward-compatibility fallback).
  unknown(0);

  const ResourceType(this.value);

  /// The integer value of this enum member.
  final int value;

  /// Creates a [ResourceType] from a JSON integer value.
  static ResourceType fromJson(int? value) {
    if (value == null) return ResourceType.unknown;
    return ResourceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ResourceType.unknown,
    );
  }

  /// Returns the integer value for JSON serialization.
  int toJson() => value;
}
