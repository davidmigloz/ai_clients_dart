import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'auth_data.dart';
import 'connector_authentication_header.dart';
import 'connector_oauth.dart';
import 'outbound_authentication_type.dart';

/// An available authentication declaration for a connector.
///
/// New connectors use bearer, no authentication, or one of the two OAuth
/// grant types. An [ConnectorAuthMethodPatch] updates an existing method.
@immutable
sealed class ConnectorAuthMethod {
  const ConnectorAuthMethod();

  /// Creates an authentication declaration from its wire representation.
  factory ConnectorAuthMethod.fromJson(Map<String, dynamic> json) {
    final method = json['method_type'];
    if (json.containsKey('global_headers') ||
        json.containsKey('oauth2_metadata_secrets')) {
      return ConnectorAuthMethodPatch.fromJson(json);
    }
    return switch (method) {
      'bearer' => BearerConnectorAuthMethod.fromJson(json),
      'none' => NoneConnectorAuthMethod.fromJson(json),
      'oauth2' when json['grant_type'] == 'client_credentials' =>
        OAuthClientCredentialsConnectorAuthMethod.fromJson(json),
      'oauth2' when json.containsKey('auth_data') =>
        OAuthAuthorizationCodeConnectorAuthMethod.fromJson(json),
      _ => ConnectorAuthMethodPatch.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// The BearerAuthMethod wire payload.
@immutable
final class BearerConnectorAuthMethod extends ConnectorAuthMethod {
  /// Creates a [BearerConnectorAuthMethod].
  const BearerConnectorAuthMethod({this.headers});

  /// The fixed method_type discriminator.
  String get methodType => 'bearer';

  /// Optional additional headers sent with requests.
  final List<ConnectorAuthenticationHeader>? headers;

  /// Parses a [BearerConnectorAuthMethod] from JSON.
  factory BearerConnectorAuthMethod.fromJson(Map<String, dynamic> json) {
    if (json['method_type'] case final value? when value != 'bearer') {
      throw FormatException(
        'BearerConnectorAuthMethod: unexpected method_type $value',
      );
    }
    return BearerConnectorAuthMethod(
      headers: json['headers'] == null
          ? null
          : (json['headers'] as List<Object?>)
                .map(
                  (item) => ConnectorAuthenticationHeader.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'method_type': methodType,
    if (headers != null)
      'headers': headers!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  BearerConnectorAuthMethod copyWith({Object? headers = unsetCopyWithValue}) =>
      BearerConnectorAuthMethod(
        headers: headers == unsetCopyWithValue
            ? this.headers
            : (headers as List<Object?>?)
                  ?.cast<ConnectorAuthenticationHeader>(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BearerConnectorAuthMethod &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(headers, other.headers);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(headers)]);

  @override
  String toString() =>
      'BearerConnectorAuthMethod('
      'headers: ${headers?.length})';
}

/// The NoneAuthMethod wire payload.
@immutable
final class NoneConnectorAuthMethod extends ConnectorAuthMethod {
  /// Creates a [NoneConnectorAuthMethod].
  const NoneConnectorAuthMethod({this.headers});

  /// The fixed method_type discriminator.
  String get methodType => 'none';

  /// Headers whose values must be provided as credentials.
  final List<ConnectorAuthenticationHeader>? headers;

  /// Parses a [NoneConnectorAuthMethod] from JSON.
  factory NoneConnectorAuthMethod.fromJson(Map<String, dynamic> json) {
    if (json['method_type'] case final value? when value != 'none') {
      throw FormatException(
        'NoneConnectorAuthMethod: unexpected method_type $value',
      );
    }
    return NoneConnectorAuthMethod(
      headers: json['headers'] == null
          ? null
          : (json['headers'] as List<Object?>)
                .map(
                  (item) => ConnectorAuthenticationHeader.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'method_type': methodType,
    if (headers != null)
      'headers': headers!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  NoneConnectorAuthMethod copyWith({Object? headers = unsetCopyWithValue}) =>
      NoneConnectorAuthMethod(
        headers: headers == unsetCopyWithValue
            ? this.headers
            : (headers as List<Object?>?)
                  ?.cast<ConnectorAuthenticationHeader>(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoneConnectorAuthMethod &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(headers, other.headers);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(headers)]);

  @override
  String toString() =>
      'NoneConnectorAuthMethod('
      'headers: ${headers?.length})';
}

/// The OAuth2AuthorizationCodeAuthMethod wire payload.
@immutable
final class OAuthAuthorizationCodeConnectorAuthMethod
    extends ConnectorAuthMethod {
  /// Creates a [OAuthAuthorizationCodeConnectorAuthMethod].
  const OAuthAuthorizationCodeConnectorAuthMethod({
    required this.authData,
    this.headers,
    this.oauth2ServerMetadata,
  });

  /// The fixed grant_type discriminator.
  String get grantType => 'authorization_code';

  /// The fixed method_type discriminator.
  String get methodType => 'oauth2';

  /// OAuth2 client credentials (client_id required; client_secret optional for PKCE flows).
  final AuthData authData;

  /// Optional headers sent with requests for this auth method.
  final List<ConnectorAuthenticationHeader>? headers;

  /// OAuth2 authorization server metadata (endpoints, scopes_supported, ...).
  final ConnectorOAuthServerMetadata? oauth2ServerMetadata;

  /// Parses a [OAuthAuthorizationCodeConnectorAuthMethod] from JSON.
  factory OAuthAuthorizationCodeConnectorAuthMethod.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['grant_type'] case final value?
        when value != 'authorization_code') {
      throw FormatException(
        'OAuthAuthorizationCodeConnectorAuthMethod: unexpected grant_type $value',
      );
    }
    if (json['method_type'] case final value? when value != 'oauth2') {
      throw FormatException(
        'OAuthAuthorizationCodeConnectorAuthMethod: unexpected method_type $value',
      );
    }
    if (json['auth_data'] == null) {
      throw const FormatException(
        'OAuthAuthorizationCodeConnectorAuthMethod: missing auth_data',
      );
    }
    return OAuthAuthorizationCodeConnectorAuthMethod(
      authData: AuthData.fromJson(json['auth_data'] as Map<String, dynamic>),
      headers: json['headers'] == null
          ? null
          : (json['headers'] as List<Object?>)
                .map(
                  (item) => ConnectorAuthenticationHeader.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
      oauth2ServerMetadata: json['oauth2_server_metadata'] == null
          ? null
          : ConnectorOAuthServerMetadata.fromJson(
              json['oauth2_server_metadata'] as Map<String, dynamic>,
            ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'grant_type': grantType,
    'method_type': methodType,
    'auth_data': authData.toJson(),
    if (headers != null)
      'headers': headers!.map((item) => item.toJson()).toList(),
    if (oauth2ServerMetadata != null)
      'oauth2_server_metadata': oauth2ServerMetadata!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  OAuthAuthorizationCodeConnectorAuthMethod copyWith({
    AuthData? authData,
    Object? headers = unsetCopyWithValue,
    Object? oauth2ServerMetadata = unsetCopyWithValue,
  }) => OAuthAuthorizationCodeConnectorAuthMethod(
    authData: authData ?? this.authData,
    headers: headers == unsetCopyWithValue
        ? this.headers
        : (headers as List<Object?>?)?.cast<ConnectorAuthenticationHeader>(),
    oauth2ServerMetadata: oauth2ServerMetadata == unsetCopyWithValue
        ? this.oauth2ServerMetadata
        : oauth2ServerMetadata as ConnectorOAuthServerMetadata?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthAuthorizationCodeConnectorAuthMethod &&
          runtimeType == other.runtimeType &&
          authData == other.authData &&
          valuesDeepEqual(headers, other.headers) &&
          oauth2ServerMetadata == other.oauth2ServerMetadata;

  @override
  int get hashCode => Object.hashAll([
    authData,
    valueDeepHashCode(headers),
    oauth2ServerMetadata,
  ]);

  @override
  String toString() =>
      'OAuthAuthorizationCodeConnectorAuthMethod('
      'authData: $authData, '
      'headers: ${headers?.length}, '
      'oauth2ServerMetadata: $oauth2ServerMetadata)';
}

/// The OAuth2ClientCredentialsAuthMethod wire payload.
@immutable
final class OAuthClientCredentialsConnectorAuthMethod
    extends ConnectorAuthMethod {
  /// Creates a [OAuthClientCredentialsConnectorAuthMethod].
  const OAuthClientCredentialsConnectorAuthMethod({
    this.headers,
    required this.oauth2ServerMetadata,
    required this.tokenEndpointAuthMethod,
  });

  /// The fixed grant_type discriminator.
  String get grantType => 'client_credentials';

  /// The fixed method_type discriminator.
  String get methodType => 'oauth2';

  /// Optional headers sent with requests for this auth method.
  final List<ConnectorAuthenticationHeader>? headers;

  /// OAuth2 authorization server metadata (endpoints, scopes_supported, ...).
  final ConnectorOAuthServerMetadata oauth2ServerMetadata;

  /// The token_endpoint_auth_method field.
  final ConnectorOAuthTokenAuthMethod tokenEndpointAuthMethod;

  /// Parses a [OAuthClientCredentialsConnectorAuthMethod] from JSON.
  factory OAuthClientCredentialsConnectorAuthMethod.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['grant_type'] case final value?
        when value != 'client_credentials') {
      throw FormatException(
        'OAuthClientCredentialsConnectorAuthMethod: unexpected grant_type $value',
      );
    }
    if (json['method_type'] case final value? when value != 'oauth2') {
      throw FormatException(
        'OAuthClientCredentialsConnectorAuthMethod: unexpected method_type $value',
      );
    }
    if (json['oauth2_server_metadata'] == null) {
      throw const FormatException(
        'OAuthClientCredentialsConnectorAuthMethod: missing oauth2_server_metadata',
      );
    }
    if (json['token_endpoint_auth_method'] == null) {
      throw const FormatException(
        'OAuthClientCredentialsConnectorAuthMethod: missing token_endpoint_auth_method',
      );
    }
    return OAuthClientCredentialsConnectorAuthMethod(
      headers: json['headers'] == null
          ? null
          : (json['headers'] as List<Object?>)
                .map(
                  (item) => ConnectorAuthenticationHeader.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
      oauth2ServerMetadata: ConnectorOAuthServerMetadata.fromJson(
        json['oauth2_server_metadata'] as Map<String, dynamic>,
      ),
      tokenEndpointAuthMethod: ConnectorOAuthTokenAuthMethod.fromJson(
        json['token_endpoint_auth_method'] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'grant_type': grantType,
    'method_type': methodType,
    if (headers != null)
      'headers': headers!.map((item) => item.toJson()).toList(),
    'oauth2_server_metadata': oauth2ServerMetadata.toJson(),
    'token_endpoint_auth_method': tokenEndpointAuthMethod.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  OAuthClientCredentialsConnectorAuthMethod copyWith({
    Object? headers = unsetCopyWithValue,
    ConnectorOAuthServerMetadata? oauth2ServerMetadata,
    ConnectorOAuthTokenAuthMethod? tokenEndpointAuthMethod,
  }) => OAuthClientCredentialsConnectorAuthMethod(
    headers: headers == unsetCopyWithValue
        ? this.headers
        : (headers as List<Object?>?)?.cast<ConnectorAuthenticationHeader>(),
    oauth2ServerMetadata: oauth2ServerMetadata ?? this.oauth2ServerMetadata,
    tokenEndpointAuthMethod:
        tokenEndpointAuthMethod ?? this.tokenEndpointAuthMethod,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthClientCredentialsConnectorAuthMethod &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(headers, other.headers) &&
          oauth2ServerMetadata == other.oauth2ServerMetadata &&
          tokenEndpointAuthMethod == other.tokenEndpointAuthMethod;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(headers),
    oauth2ServerMetadata,
    tokenEndpointAuthMethod,
  ]);

  @override
  String toString() =>
      'OAuthClientCredentialsConnectorAuthMethod('
      'headers: ${headers?.length}, '
      'oauth2ServerMetadata: $oauth2ServerMetadata, '
      'tokenEndpointAuthMethod: $tokenEndpointAuthMethod)';
}

/// The AuthenticationMethodCreateOrUpdateRequest wire payload.
@immutable
final class ConnectorAuthMethodPatch extends ConnectorAuthMethod {
  /// Creates a [ConnectorAuthMethodPatch].
  const ConnectorAuthMethodPatch({
    this.globalHeaders,
    this.headers,
    required this.methodType,
    this.oauth2MetadataSecrets,
    this.oauth2ServerMetadata,
  });

  /// Connector-wide headers keyed by header name, applied to every credential. Secret values are encrypted at rest and never returned in clear.
  final Map<String, ConnectorGlobalHeader>? globalHeaders;

  /// Set of headers to connect to the connector
  final List<ConnectorAuthenticationHeader>? headers;

  /// The type of authentication method (e.g. oauth2, bearer, none).
  final OutboundAuthenticationType methodType;

  /// New OAuth2 client credentials (client_id and client_secret).
  final ConnectorOAuthMetadataSecrets? oauth2MetadataSecrets;

  /// New OAuth2 authorization server metadata.
  final ConnectorOAuthServerMetadata? oauth2ServerMetadata;

  /// Parses a [ConnectorAuthMethodPatch] from JSON.
  factory ConnectorAuthMethodPatch.fromJson(Map<String, dynamic> json) {
    if (json['method_type'] == null) {
      throw const FormatException(
        'ConnectorAuthMethodPatch: missing method_type',
      );
    }
    return ConnectorAuthMethodPatch(
      globalHeaders: json['global_headers'] == null
          ? null
          : (json['global_headers'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                ConnectorGlobalHeader.fromJson(item! as Map<String, dynamic>),
              ),
            ),
      headers: json['headers'] == null
          ? null
          : (json['headers'] as List<Object?>)
                .map(
                  (item) => ConnectorAuthenticationHeader.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
      methodType: OutboundAuthenticationType.fromJson(
        json['method_type'] as String,
      ),
      oauth2MetadataSecrets: json['oauth2_metadata_secrets'] == null
          ? null
          : ConnectorOAuthMetadataSecrets.fromJson(
              json['oauth2_metadata_secrets'] as Map<String, dynamic>,
            ),
      oauth2ServerMetadata: json['oauth2_server_metadata'] == null
          ? null
          : ConnectorOAuthServerMetadata.fromJson(
              json['oauth2_server_metadata'] as Map<String, dynamic>,
            ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    if (globalHeaders != null)
      'global_headers': globalHeaders!.map(
        (key, item) => MapEntry(key, item.toJson()),
      ),
    if (headers != null)
      'headers': headers!.map((item) => item.toJson()).toList(),
    'method_type': methodType.toJson(),
    if (oauth2MetadataSecrets != null)
      'oauth2_metadata_secrets': oauth2MetadataSecrets!.toJson(),
    if (oauth2ServerMetadata != null)
      'oauth2_server_metadata': oauth2ServerMetadata!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ConnectorAuthMethodPatch copyWith({
    Object? globalHeaders = unsetCopyWithValue,
    Object? headers = unsetCopyWithValue,
    OutboundAuthenticationType? methodType,
    Object? oauth2MetadataSecrets = unsetCopyWithValue,
    Object? oauth2ServerMetadata = unsetCopyWithValue,
  }) => ConnectorAuthMethodPatch(
    globalHeaders: globalHeaders == unsetCopyWithValue
        ? this.globalHeaders
        : (globalHeaders as Map?)?.cast<String, ConnectorGlobalHeader>(),
    headers: headers == unsetCopyWithValue
        ? this.headers
        : (headers as List<Object?>?)?.cast<ConnectorAuthenticationHeader>(),
    methodType: methodType ?? this.methodType,
    oauth2MetadataSecrets: oauth2MetadataSecrets == unsetCopyWithValue
        ? this.oauth2MetadataSecrets
        : oauth2MetadataSecrets as ConnectorOAuthMetadataSecrets?,
    oauth2ServerMetadata: oauth2ServerMetadata == unsetCopyWithValue
        ? this.oauth2ServerMetadata
        : oauth2ServerMetadata as ConnectorOAuthServerMetadata?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorAuthMethodPatch &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(globalHeaders, other.globalHeaders) &&
          valuesDeepEqual(headers, other.headers) &&
          methodType == other.methodType &&
          oauth2MetadataSecrets == other.oauth2MetadataSecrets &&
          oauth2ServerMetadata == other.oauth2ServerMetadata;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(globalHeaders),
    valueDeepHashCode(headers),
    methodType,
    oauth2MetadataSecrets,
    oauth2ServerMetadata,
  ]);

  @override
  String toString() =>
      'ConnectorAuthMethodPatch('
      'globalHeaders: ${globalHeaders?.length}, '
      'headers: ${headers?.length}, '
      'methodType: $methodType, '
      'oauth2MetadataSecrets: $oauth2MetadataSecrets, '
      'oauth2ServerMetadata: $oauth2ServerMetadata)';
}
