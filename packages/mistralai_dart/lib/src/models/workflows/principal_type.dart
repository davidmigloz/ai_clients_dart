/// Type of credential principal a managed deployment runs as.
enum PrincipalType {
  /// An API key.
  apiKey('api_key'),

  /// A service account.
  serviceAccount('service_account'),

  /// A user.
  user('user'),

  /// Unrecognized wire value.
  unknown('unknown');

  const PrincipalType(this.value);

  /// Wire value.
  final String value;

  /// Decodes the wire value.
  static PrincipalType? fromJson(String? value) => switch (value) {
    null => null,
    'api_key' => apiKey,
    'service_account' => serviceAccount,
    'user' => user,
    _ => unknown,
  };
}
