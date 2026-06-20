/// The scope at which a connector credential or preference applies.
enum ConsumerType {
  /// User scope.
  user('user'),

  /// Organization scope.
  org('org'),

  /// Workspace scope.
  workspace('workspace'),

  /// System scope.
  system('system'),

  /// Unknown consumer type (forward-compatibility fallback).
  unknown('unknown');

  const ConsumerType(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [ConsumerType] from a JSON string value.
  static ConsumerType fromJson(String? value) {
    if (value == null) return ConsumerType.unknown;
    return ConsumerType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ConsumerType.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
