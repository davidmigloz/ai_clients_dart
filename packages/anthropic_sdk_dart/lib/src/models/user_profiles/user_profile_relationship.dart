/// How a user profile relates to the platform.
enum BetaUserProfileRelationship {
  /// An individual end-user (default).
  external('external'),

  /// A company the platform resells Claude access to.
  resold('resold'),

  /// The platform's own usage.
  internal('internal'),

  /// Unknown relationship — fallback for forward compatibility.
  unknown('unknown');

  const BetaUserProfileRelationship(this.value);

  /// JSON value for this relationship.
  final String value;

  /// Parses a [BetaUserProfileRelationship] from JSON.
  static BetaUserProfileRelationship fromJson(String value) => switch (value) {
    'external' => BetaUserProfileRelationship.external,
    'resold' => BetaUserProfileRelationship.resold,
    'internal' => BetaUserProfileRelationship.internal,
    _ => BetaUserProfileRelationship.unknown,
  };

  /// Converts this relationship to JSON.
  String toJson() => value;
}
