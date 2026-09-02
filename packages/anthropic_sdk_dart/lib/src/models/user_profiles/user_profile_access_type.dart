/// How the platform uses the API on behalf of the entity a user profile
/// represents.
enum UserProfileAccessType {
  /// The platform sells a product that uses the API behind the scenes, and
  /// the profile represents an individual end-user of that product.
  ///
  /// This is the default.
  application('application'),

  /// The platform resells raw inference, and the profile identifies the
  /// resold-to company.
  passthrough('passthrough'),

  /// Unknown access type — fallback for forward compatibility.
  unknown('unknown');

  const UserProfileAccessType(this.value);

  /// JSON value for this access type.
  final String value;

  /// Parses a [UserProfileAccessType] from JSON.
  static UserProfileAccessType fromJson(String value) => switch (value) {
    'application' => UserProfileAccessType.application,
    'passthrough' => UserProfileAccessType.passthrough,
    _ => UserProfileAccessType.unknown,
  };

  /// Converts this access type to JSON.
  String toJson() => value;
}
