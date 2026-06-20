/// Visibility of a connector or connector resource.
enum ResourceVisibility {
  /// Shared with everyone globally.
  sharedGlobal('shared_global'),

  /// Shared with the organization.
  sharedOrg('shared_org'),

  /// Shared with the workspace.
  sharedWorkspace('shared_workspace'),

  /// Private to the owner.
  private('private'),

  /// Unknown visibility (forward-compatibility fallback).
  unknown('unknown');

  const ResourceVisibility(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [ResourceVisibility] from a JSON string value.
  static ResourceVisibility fromJson(String? value) {
    if (value == null) return ResourceVisibility.unknown;
    return ResourceVisibility.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ResourceVisibility.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
