/// A short-lived token scoped to one Genie interaction.
class GenieAuthToken {
  /// The credential to pass back when connecting to that interaction.
  final String authToken;

  /// When the token expires, if returned by the server.
  final DateTime? expiresAt;

  /// Creates a scoped credential.
  const GenieAuthToken({required this.authToken, this.expiresAt});

  /// Parses the response from the interaction-scoped token endpoint.
  factory GenieAuthToken.fromJson(Map<String, dynamic> json) {
    final token = json['auth_token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException(
        'The Genie token response is missing auth_token.',
      );
    }
    final expiration = json['expires_at'];
    final expiresAt = expiration is String
        ? DateTime.tryParse(expiration)
        : null;
    if (expiration != null && expiresAt == null) {
      throw const FormatException(
        'The Genie token response has an invalid expires_at.',
      );
    }
    return GenieAuthToken(authToken: token, expiresAt: expiresAt);
  }
}
