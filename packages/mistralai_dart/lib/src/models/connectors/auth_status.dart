/// The validity status of a connector credential.
enum AuthStatus {
  /// The credential is valid.
  valid('valid'),

  /// The credential is invalid.
  invalid('invalid'),

  /// An error occurred while checking the credential.
  error('error'),

  /// Unknown status (forward-compatibility fallback).
  unknown('unknown');

  const AuthStatus(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates an [AuthStatus] from a JSON string value.
  static AuthStatus fromJson(String? value) {
    if (value == null) return AuthStatus.unknown;
    return AuthStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AuthStatus.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
