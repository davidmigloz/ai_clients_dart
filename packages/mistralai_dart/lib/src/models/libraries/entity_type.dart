/// Entity type for library sharing.
///
/// Defines the type of entity to share a library with.
enum EntityType {
  /// Individual user.
  user('User'),

  /// Workspace.
  workspace('Workspace'),

  /// Organization.
  org('Org');

  const EntityType(this.value);

  /// The string value used in the API.
  final String value;

  /// Creates from a JSON string value.
  static EntityType fromString(String? value) {
    return EntityType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EntityType.user,
    );
  }
}
