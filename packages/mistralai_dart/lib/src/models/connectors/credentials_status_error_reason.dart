/// A human-readable reason describing why a connector credential is in an
/// error state.
enum CredentialsStatusErrorReason {
  /// The OAuth2 token has expired.
  oauthExpired('oauth expired'),

  /// The OAuth2 token is near expiry.
  oauthNearExpiry('oauth near expiry'),

  /// No credentials have been configured.
  emptyCredentials('empty credentials'),

  /// The stored credentials could not be parsed.
  unparsableCredentials('unparsable credentials'),

  /// The user needs to reconnect their account.
  youNeedToReconnect('you need to reconnect'),

  /// Refreshing the OAuth2 token failed.
  oauthRefreshError('oauth refresh error'),

  /// The MCP server could not be reached.
  mcpServerUnreachable('MCP server unreachable'),

  /// The MCP server timed out.
  mcpServerTimedOut('MCP server timed out'),

  /// The MCP server returned an error.
  mcpServerError('MCP server error'),

  /// An unknown error occurred (as reported by the server).
  unknownError('unknown error'),

  /// Unknown error reason (forward-compatibility fallback).
  unknown('unknown');

  const CredentialsStatusErrorReason(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [CredentialsStatusErrorReason] from a JSON string value.
  static CredentialsStatusErrorReason fromJson(String? value) {
    if (value == null) return CredentialsStatusErrorReason.unknown;
    return CredentialsStatusErrorReason.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CredentialsStatusErrorReason.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
