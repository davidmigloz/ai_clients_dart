/// Sort field for the `UserProfilesResource.list` endpoint.
enum UserProfileListOrderBy {
  /// Sort by creation time (default).
  createdAt('created_at'),

  /// Sort by name, case-insensitive. Profiles without a name sort last.
  name('name'),

  /// Unknown sort field — fallback for forward compatibility.
  unknown('unknown');

  const UserProfileListOrderBy(this.value);

  /// JSON value for this sort field.
  final String value;

  /// Parses a [UserProfileListOrderBy] from JSON.
  static UserProfileListOrderBy fromJson(String value) => switch (value) {
    'created_at' => UserProfileListOrderBy.createdAt,
    'name' => UserProfileListOrderBy.name,
    _ => UserProfileListOrderBy.unknown,
  };

  /// Converts this sort field to JSON.
  String toJson() => value;
}
