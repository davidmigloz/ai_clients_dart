/// Access granted to members of a workspace for a registry object.
enum RegistryShareRelation {
  /// Let the service choose the access.
  unspecified('share_relation_unspecified'),

  /// Members can read the object.
  reader('reader'),

  /// Members can read and change the object.
  writer('writer');

  const RegistryShareRelation(this.value);

  /// The value sent to the API.
  final String value;

  /// Parses a wire value. Returns null for absent or unrecognized values.
  static RegistryShareRelation? fromString(String? value) => switch (value) {
    'share_relation_unspecified' => unspecified,
    'reader' => reader,
    'writer' => writer,
    _ => null,
  };
}
