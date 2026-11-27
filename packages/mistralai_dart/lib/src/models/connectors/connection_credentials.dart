import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'connector_oauth.dart';
import 'oauth2_token.dart';

/// The credential data attached to a connector connection.
@immutable
class ConnectionCredentials {
  /// OAuth2 token credentials for historical deployments.
  final OAuth2Token? oauth;

  /// Client credentials for the OAuth2 client credentials grant.
  final ConnectorOAuthClientCredentials? clientCredentials;

  /// Static query parameters to send to the connector.
  final Map<String, String>? queryParams;

  /// Static headers to send to the connector.
  final Map<String, String>? headers;

  /// A bearer token to send to the connector.
  final String? bearerToken;

  /// A GitHub App installation ID.
  final String? githubInstallationId;

  /// Creates a [ConnectionCredentials].
  const ConnectionCredentials({
    this.oauth,
    this.clientCredentials,
    this.queryParams,
    this.headers,
    this.bearerToken,
    this.githubInstallationId,
  });

  /// Creates a [ConnectionCredentials] from JSON.
  factory ConnectionCredentials.fromJson(Map<String, dynamic> json) {
    final oauth = json['oauth'] as Map<String, dynamic>?;
    final usesClientCredentials = oauth?['grant_type'] == 'client_credentials';
    return ConnectionCredentials(
      oauth: oauth == null || usesClientCredentials
          ? null
          : OAuth2Token.fromJson(oauth),
      clientCredentials: usesClientCredentials
          ? ConnectorOAuthClientCredentials.fromJson(oauth!)
          : null,
      headers: (json['headers'] as Map<Object?, Object?>?)
          ?.cast<String, String>(),
      queryParams: (json['query_params'] as Map<Object?, Object?>?)
          ?.cast<String, String>(),
      bearerToken: json['bearer_token'] as String?,
      githubInstallationId: json['github_installation_id'] as String?,
    );
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() {
    if (oauth != null && clientCredentials != null) {
      throw ArgumentError('Provide either oauth or clientCredentials');
    }
    final oauthJson = clientCredentials?.toJson() ?? oauth?.toJson();
    return {
      'oauth': ?oauthJson,
      'headers': ?headers,
      'query_params': ?queryParams,
      'bearer_token': ?bearerToken,
      'github_installation_id': ?githubInstallationId,
    };
  }

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  ConnectionCredentials copyWith({
    Object? oauth = unsetCopyWithValue,
    Object? clientCredentials = unsetCopyWithValue,
    Object? queryParams = unsetCopyWithValue,
    Object? headers = unsetCopyWithValue,
    Object? bearerToken = unsetCopyWithValue,
    Object? githubInstallationId = unsetCopyWithValue,
  }) => ConnectionCredentials(
    oauth: oauth == unsetCopyWithValue ? this.oauth : oauth as OAuth2Token?,
    clientCredentials: clientCredentials == unsetCopyWithValue
        ? this.clientCredentials
        : clientCredentials as ConnectorOAuthClientCredentials?,
    queryParams: queryParams == unsetCopyWithValue
        ? this.queryParams
        : (queryParams as Map<Object?, Object?>?)?.cast<String, String>(),
    headers: headers == unsetCopyWithValue
        ? this.headers
        : (headers as Map<Object?, Object?>?)?.cast<String, String>(),
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
          clientCredentials == other.clientCredentials &&
          mapsEqual(queryParams, other.queryParams) &&
          mapsEqual(headers, other.headers) &&
          bearerToken == other.bearerToken &&
          githubInstallationId == other.githubInstallationId;

  @override
  int get hashCode => Object.hash(
    oauth,
    clientCredentials,
    mapHash(headers),
    mapHash(queryParams),
    bearerToken,
    githubInstallationId,
  );

  @override
  String toString() =>
      'ConnectionCredentials('
      'oauth: $oauth, clientCredentials: $clientCredentials, '
      'queryParams: ${queryParams?.length}, '
      'headers: ${headers == null ? null : '[redacted]'}, '
      'bearerToken: ${bearerToken == null ? null : '[redacted]'}, '
      'githubInstallationId: $githubInstallationId)';
}
