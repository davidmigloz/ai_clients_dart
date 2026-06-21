/// The authentication mechanism a connector uses for outbound requests.
enum OutboundAuthenticationType {
  /// OAuth 2.0.
  oauth2('oauth2'),

  /// Bearer token.
  bearer('bearer'),

  /// No authentication.
  none('none'),

  /// GitHub App authentication.
  githubApp('github_app'),

  /// Slack App authentication.
  slackApp('slack_app'),

  /// Unknown authentication type (forward-compatibility fallback).
  unknown('unknown');

  const OutboundAuthenticationType(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates an [OutboundAuthenticationType] from a JSON string value.
  static OutboundAuthenticationType fromJson(String? value) {
    if (value == null) return OutboundAuthenticationType.unknown;
    return OutboundAuthenticationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OutboundAuthenticationType.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
