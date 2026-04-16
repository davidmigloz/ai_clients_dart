/// Sort order for the `UserProfilesResource.list` endpoint.
enum UserProfileListOrder {
  /// Ascending order (oldest first).
  asc('asc'),

  /// Descending order (newest first).
  desc('desc'),

  /// Unknown order — fallback for forward compatibility.
  unknown('unknown');

  const UserProfileListOrder(this.value);

  /// JSON value for this order.
  final String value;

  /// Parses a [UserProfileListOrder] from JSON.
  static UserProfileListOrder fromJson(String value) => switch (value) {
    'asc' => UserProfileListOrder.asc,
    'desc' => UserProfileListOrder.desc,
    _ => UserProfileListOrder.unknown,
  };

  /// Converts this order to JSON.
  String toJson() => value;
}
