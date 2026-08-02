/// Visibility options available to public API callers.
///
/// Excludes `shared_global`, which is reserved for system-owned connectors.
enum PublicResourceVisibility {
  /// Shared with the organization.
  sharedOrg('shared_org'),

  /// Shared with the workspace.
  sharedWorkspace('shared_workspace'),

  /// Private to the owner.
  private('private'),

  /// Unknown visibility (forward-compatibility fallback).
  unknown('unknown');

  const PublicResourceVisibility(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [PublicResourceVisibility] from a JSON string value.
  static PublicResourceVisibility fromJson(String? value) {
    if (value == null) return PublicResourceVisibility.unknown;
    return PublicResourceVisibility.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PublicResourceVisibility.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
