import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'connector_authentication_header.dart';
import 'connector_oauth.dart';
import 'outbound_authentication_type.dart';

/// Public view of an authentication method, without secrets.
@immutable
class PublicAuthenticationMethod {
  /// The authentication mechanism.
  final OutboundAuthenticationType methodType;

  /// Whether the connector has default credentials for this method.
  final bool hasDefaultCredentials;

  /// The headers required by this authentication method.
  final List<ConnectorAuthenticationHeader>? headers;

  /// Connector-wide headers for this method.
  final Map<String, ConnectorGlobalHeader>? globalHeaders;

  /// The OAuth grant type when applicable.
  final ConnectorOAuthGrantType? grantType;

  /// OAuth authorization server metadata.
  final ConnectorOAuthServerMetadata? oauth2ServerMetadata;

  /// Method used to authenticate with the token endpoint.
  final ConnectorOAuthTokenAuthMethod? tokenEndpointAuthMethod;

  /// Creates a [PublicAuthenticationMethod].
  const PublicAuthenticationMethod({
    this.globalHeaders,
    this.grantType,
    this.oauth2ServerMetadata,
    this.tokenEndpointAuthMethod,
    required this.methodType,
    required this.hasDefaultCredentials,
    this.headers,
  });

  /// Creates a [PublicAuthenticationMethod] from JSON.
  factory PublicAuthenticationMethod.fromJson(
    Map<String, dynamic> json,
  ) => PublicAuthenticationMethod(
    globalHeaders: (json['global_headers'] as Map<String, dynamic>?)?.map(
      (name, value) => MapEntry(
        name,
        ConnectorGlobalHeader.fromJson(value as Map<String, dynamic>),
      ),
    ),
    grantType: json['grant_type'] == null
        ? null
        : ConnectorOAuthGrantType.fromJson(json['grant_type'] as String),
    oauth2ServerMetadata: json['oauth2_server_metadata'] == null
        ? null
        : ConnectorOAuthServerMetadata.fromJson(
            json['oauth2_server_metadata'] as Map<String, dynamic>,
          ),
    tokenEndpointAuthMethod: json['token_endpoint_auth_method'] == null
        ? null
        : ConnectorOAuthTokenAuthMethod.fromJson(
            json['token_endpoint_auth_method'] as String,
          ),
    methodType: OutboundAuthenticationType.fromJson(
      json['method_type'] as String?,
    ),
    hasDefaultCredentials: json['has_default_credentials'] as bool? ?? false,
    headers: (json['headers'] as List<dynamic>?)
        ?.map(
          (e) =>
              ConnectorAuthenticationHeader.fromJson(e as Map<String, dynamic>),
        )
        .toList(),
  );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    if (globalHeaders != null)
      'global_headers': globalHeaders!.map(
        (name, value) => MapEntry(name, value.toJson()),
      ),
    if (grantType != null) 'grant_type': grantType!.toJson(),
    if (oauth2ServerMetadata != null)
      'oauth2_server_metadata': oauth2ServerMetadata!.toJson(),
    if (tokenEndpointAuthMethod != null)
      'token_endpoint_auth_method': tokenEndpointAuthMethod!.toJson(),
    'method_type': methodType.toJson(),
    'has_default_credentials': hasDefaultCredentials,
    if (headers != null) 'headers': headers!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for [headers] to clear it explicitly; omit to keep.
  PublicAuthenticationMethod copyWith({
    Object? globalHeaders = unsetCopyWithValue,
    Object? grantType = unsetCopyWithValue,
    Object? oauth2ServerMetadata = unsetCopyWithValue,
    Object? tokenEndpointAuthMethod = unsetCopyWithValue,
    OutboundAuthenticationType? methodType,
    bool? hasDefaultCredentials,
    Object? headers = unsetCopyWithValue,
  }) => PublicAuthenticationMethod(
    globalHeaders: globalHeaders == unsetCopyWithValue
        ? this.globalHeaders
        : (globalHeaders as Map<Object?, Object?>?)
              ?.cast<String, ConnectorGlobalHeader>(),
    grantType: grantType == unsetCopyWithValue
        ? this.grantType
        : grantType as ConnectorOAuthGrantType?,
    oauth2ServerMetadata: oauth2ServerMetadata == unsetCopyWithValue
        ? this.oauth2ServerMetadata
        : oauth2ServerMetadata as ConnectorOAuthServerMetadata?,
    tokenEndpointAuthMethod: tokenEndpointAuthMethod == unsetCopyWithValue
        ? this.tokenEndpointAuthMethod
        : tokenEndpointAuthMethod as ConnectorOAuthTokenAuthMethod?,
    methodType: methodType ?? this.methodType,
    hasDefaultCredentials: hasDefaultCredentials ?? this.hasDefaultCredentials,
    headers: headers == unsetCopyWithValue
        ? this.headers
        : (headers as List<Object?>?)?.cast<ConnectorAuthenticationHeader>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicAuthenticationMethod &&
          mapsEqual(globalHeaders, other.globalHeaders) &&
          grantType == other.grantType &&
          oauth2ServerMetadata == other.oauth2ServerMetadata &&
          tokenEndpointAuthMethod == other.tokenEndpointAuthMethod &&
          runtimeType == other.runtimeType &&
          methodType == other.methodType &&
          hasDefaultCredentials == other.hasDefaultCredentials &&
          listsEqual(headers, other.headers);

  @override
  int get hashCode => Object.hashAll([
    methodType,
    hasDefaultCredentials,
    listHash(headers),
    mapHash(globalHeaders),
    grantType,
    oauth2ServerMetadata,
    tokenEndpointAuthMethod,
  ]);

  @override
  String toString() =>
      'PublicAuthenticationMethod(globalHeaders: ${globalHeaders?.length}, grantType: $grantType, oauth2ServerMetadata: $oauth2ServerMetadata, tokenEndpointAuthMethod: $tokenEndpointAuthMethod, '
      'methodType: $methodType, '
      'hasDefaultCredentials: $hasDefaultCredentials, '
      'headers: ${headers == null ? 'null' : '${headers!.length} items'})';
}
