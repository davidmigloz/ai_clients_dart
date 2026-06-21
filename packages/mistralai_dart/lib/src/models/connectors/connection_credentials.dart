import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'oauth2_token.dart';

/// The credential data attached to a connector connection.
@immutable
class ConnectionCredentials {
  /// OAuth2 token credentials.
  final OAuth2Token? oauth;

  /// Static headers to send to the connector.
  final Map<String, String>? headers;

  /// A bearer token to send to the connector.
  final String? bearerToken;

  /// A GitHub App installation ID.
  final String? githubInstallationId;

  /// Creates a [ConnectionCredentials].
  const ConnectionCredentials({
    this.oauth,
    this.headers,
    this.bearerToken,
    this.githubInstallationId,
  });

  /// Creates a [ConnectionCredentials] from JSON.
  factory ConnectionCredentials.fromJson(Map<String, dynamic> json) =>
      ConnectionCredentials(
        oauth: json['oauth'] != null
            ? OAuth2Token.fromJson(json['oauth'] as Map<String, dynamic>)
            : null,
        headers: (json['headers'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as String),
        ),
        bearerToken: json['bearer_token'] as String?,
        githubInstallationId: json['github_installation_id'] as String?,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    if (oauth != null) 'oauth': oauth!.toJson(),
    if (headers != null) 'headers': headers,
    if (bearerToken != null) 'bearer_token': bearerToken,
    if (githubInstallationId != null)
      'github_installation_id': githubInstallationId,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  ConnectionCredentials copyWith({
    Object? oauth = unsetCopyWithValue,
    Object? headers = unsetCopyWithValue,
    Object? bearerToken = unsetCopyWithValue,
    Object? githubInstallationId = unsetCopyWithValue,
  }) => ConnectionCredentials(
    oauth: oauth == unsetCopyWithValue ? this.oauth : oauth as OAuth2Token?,
    headers: headers == unsetCopyWithValue
        ? this.headers
        : headers as Map<String, String>?,
    bearerToken: bearerToken == unsetCopyWithValue
        ? this.bearerToken
        : bearerToken as String?,
    githubInstallationId: githubInstallationId == unsetCopyWithValue
        ? this.githubInstallationId
        : githubInstallationId as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionCredentials &&
          runtimeType == other.runtimeType &&
          oauth == other.oauth &&
          mapsEqual(headers, other.headers) &&
          bearerToken == other.bearerToken &&
          githubInstallationId == other.githubInstallationId;

  @override
  int get hashCode =>
      Object.hash(oauth, mapHash(headers), bearerToken, githubInstallationId);

  @override
  String toString() =>
      'ConnectionCredentials('
      'oauth: $oauth, '
      'headers: ${headers == null ? null : '[redacted]'}, '
      'bearerToken: ${bearerToken == null ? null : '[redacted]'}, '
      'githubInstallationId: $githubInstallationId)';
}
