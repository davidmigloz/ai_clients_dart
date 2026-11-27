import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Value of a connector-wide header. ``value`` is plaintext in memory so create round-trips and encryption-at-rest keep the real value; secrets are redacted only on JSON serialization (API responses).
@immutable
class ConnectorGlobalHeader {
  /// Creates a [ConnectorGlobalHeader].
  const ConnectorGlobalHeader({this.isSecret, required this.value});

  /// The is_secret field.
  final bool? isSecret;

  /// The value field.
  final String value;

  /// Parses a [ConnectorGlobalHeader] from JSON.
  factory ConnectorGlobalHeader.fromJson(Map<String, dynamic> json) {
    if (json['value'] == null) {
      throw const FormatException('ConnectorGlobalHeader: missing value');
    }
    return ConnectorGlobalHeader(
      isSecret: json['is_secret'] == null ? null : json['is_secret'] as bool,
      value: json['value'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'is_secret': ?isSecret, 'value': value};

  /// Creates a copy with the given fields replaced.
  ConnectorGlobalHeader copyWith({
    Object? isSecret = unsetCopyWithValue,
    String? value,
  }) => ConnectorGlobalHeader(
    isSecret: isSecret == unsetCopyWithValue
        ? this.isSecret
        : isSecret as bool?,
    value: value ?? this.value,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorGlobalHeader &&
          runtimeType == other.runtimeType &&
          isSecret == other.isSecret &&
          value == other.value;

  @override
  int get hashCode => Object.hashAll([isSecret, value]);

  @override
  String toString() =>
      'ConnectorGlobalHeader('
      'isSecret: $isSecret, '
      'value: ${isSecret == true ? '[redacted]' : value})';
}

/// Values for ConnectorOAuthGrantType.
enum ConnectorOAuthGrantType {
  /// Represents authorization_code.
  authorizationCode('authorization_code'),

  /// Represents client_credentials.
  clientCredentials('client_credentials'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const ConnectorOAuthGrantType(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static ConnectorOAuthGrantType fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for ConnectorOAuthTokenAuthMethod.
enum ConnectorOAuthTokenAuthMethod {
  /// Represents client_secret_post.
  clientSecretPost('client_secret_post'),

  /// Represents client_secret_basic.
  clientSecretBasic('client_secret_basic'),

  /// Represents private_key_jwt.
  privateKeyJwt('private_key_jwt'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const ConnectorOAuthTokenAuthMethod(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static ConnectorOAuthTokenAuthMethod fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for ConnectorOAuthMetadataSource.
enum ConnectorOAuthMetadataSource {
  /// Represents autodiscovery.
  autodiscovery('autodiscovery'),

  /// Represents provided.
  provided('provided'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const ConnectorOAuthMetadataSource(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static ConnectorOAuthMetadataSource fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Custom superset of RFC 8414 OAuth 2.0 Authorization Server Metadata. Stored at connector creation time (provided for HTTP connectors, discovered via .well-known for MCP). Mirrors the shape of .well-known/oauth-authorization-server responses.
@immutable
class ConnectorOAuthServerMetadata {
  /// Creates a [ConnectorOAuthServerMetadata].
  const ConnectorOAuthServerMetadata({
    this.authorizationEndpoint,
    this.authorizationGrantProfilesSupported,
    this.authorizationResponseIssParameterSupported,
    this.clientIdMetadataDocumentSupported,
    this.codeChallengeMethodsSupported,
    this.grantTypesSupported,
    this.introspectionEndpoint,
    this.introspectionEndpointAuthMethodsSupported,
    this.introspectionEndpointAuthSigningAlgValuesSupported,
    required this.issuer,
    this.opPolicyUri,
    this.opTosUri,
    this.registrationEndpoint,
    this.responseModesSupported,
    this.responseTypesSupported,
    this.revocationEndpoint,
    this.revocationEndpointAuthMethodsSupported,
    this.revocationEndpointAuthSigningAlgValuesSupported,
    this.scopesSupported,
    this.serviceDocumentation,
    required this.tokenEndpoint,
    this.tokenEndpointAuthMethodsSupported,
    this.tokenEndpointAuthSigningAlgValuesSupported,
    this.uiLocalesSupported,
    this.xResourceUrl,
    this.xScope,
    this.xSource,
    this.extra = const {},
  });

  /// The authorization_endpoint field.
  final String? authorizationEndpoint;

  /// The authorization_grant_profiles_supported field.
  final List<String>? authorizationGrantProfilesSupported;

  /// The authorization_response_iss_parameter_supported field.
  final bool? authorizationResponseIssParameterSupported;

  /// The client_id_metadata_document_supported field.
  final bool? clientIdMetadataDocumentSupported;

  /// The code_challenge_methods_supported field.
  final List<String>? codeChallengeMethodsSupported;

  /// The grant_types_supported field.
  final List<String>? grantTypesSupported;

  /// The introspection_endpoint field.
  final String? introspectionEndpoint;

  /// The introspection_endpoint_auth_methods_supported field.
  final List<String>? introspectionEndpointAuthMethodsSupported;

  /// The introspection_endpoint_auth_signing_alg_values_supported field.
  final List<String>? introspectionEndpointAuthSigningAlgValuesSupported;

  /// The issuer field.
  final String issuer;

  /// The op_policy_uri field.
  final String? opPolicyUri;

  /// The op_tos_uri field.
  final String? opTosUri;

  /// The registration_endpoint field.
  final String? registrationEndpoint;

  /// The response_modes_supported field.
  final List<String>? responseModesSupported;

  /// The response_types_supported field.
  final List<String>? responseTypesSupported;

  /// The revocation_endpoint field.
  final String? revocationEndpoint;

  /// The revocation_endpoint_auth_methods_supported field.
  final List<String>? revocationEndpointAuthMethodsSupported;

  /// The revocation_endpoint_auth_signing_alg_values_supported field.
  final List<String>? revocationEndpointAuthSigningAlgValuesSupported;

  /// The scopes_supported field.
  final List<String>? scopesSupported;

  /// The service_documentation field.
  final String? serviceDocumentation;

  /// The token_endpoint field.
  final String tokenEndpoint;

  /// The token_endpoint_auth_methods_supported field.
  final List<String>? tokenEndpointAuthMethodsSupported;

  /// The token_endpoint_auth_signing_alg_values_supported field.
  final List<String>? tokenEndpointAuthSigningAlgValuesSupported;

  /// The ui_locales_supported field.
  final List<String>? uiLocalesSupported;

  /// The x_resource_url field.
  final String? xResourceUrl;

  /// The x_scope field.
  final String? xScope;

  /// The x_source field.
  final ConnectorOAuthMetadataSource? xSource;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ConnectorOAuthServerMetadata] from JSON.
  factory ConnectorOAuthServerMetadata.fromJson(Map<String, dynamic> json) {
    if (json['issuer'] == null) {
      throw const FormatException(
        'ConnectorOAuthServerMetadata: missing issuer',
      );
    }
    if (json['token_endpoint'] == null) {
      throw const FormatException(
        'ConnectorOAuthServerMetadata: missing token_endpoint',
      );
    }
    return ConnectorOAuthServerMetadata(
      authorizationEndpoint: json['authorization_endpoint'] == null
          ? null
          : json['authorization_endpoint'] as String,
      authorizationGrantProfilesSupported:
          json['authorization_grant_profiles_supported'] == null
          ? null
          : (json['authorization_grant_profiles_supported'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      authorizationResponseIssParameterSupported:
          json['authorization_response_iss_parameter_supported'] == null
          ? null
          : json['authorization_response_iss_parameter_supported'] as bool,
      clientIdMetadataDocumentSupported:
          json['client_id_metadata_document_supported'] == null
          ? null
          : json['client_id_metadata_document_supported'] as bool,
      codeChallengeMethodsSupported:
          json['code_challenge_methods_supported'] == null
          ? null
          : (json['code_challenge_methods_supported'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      grantTypesSupported: json['grant_types_supported'] == null
          ? null
          : (json['grant_types_supported'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      introspectionEndpoint: json['introspection_endpoint'] == null
          ? null
          : json['introspection_endpoint'] as String,
      introspectionEndpointAuthMethodsSupported:
          json['introspection_endpoint_auth_methods_supported'] == null
          ? null
          : (json['introspection_endpoint_auth_methods_supported']
                    as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      introspectionEndpointAuthSigningAlgValuesSupported:
          json['introspection_endpoint_auth_signing_alg_values_supported'] ==
              null
          ? null
          : (json['introspection_endpoint_auth_signing_alg_values_supported']
                    as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      issuer: json['issuer'] as String,
      opPolicyUri: json['op_policy_uri'] == null
          ? null
          : json['op_policy_uri'] as String,
      opTosUri: json['op_tos_uri'] == null
          ? null
          : json['op_tos_uri'] as String,
      registrationEndpoint: json['registration_endpoint'] == null
          ? null
          : json['registration_endpoint'] as String,
      responseModesSupported: json['response_modes_supported'] == null
          ? null
          : (json['response_modes_supported'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      responseTypesSupported: json['response_types_supported'] == null
          ? null
          : (json['response_types_supported'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      revocationEndpoint: json['revocation_endpoint'] == null
          ? null
          : json['revocation_endpoint'] as String,
      revocationEndpointAuthMethodsSupported:
          json['revocation_endpoint_auth_methods_supported'] == null
          ? null
          : (json['revocation_endpoint_auth_methods_supported']
                    as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      revocationEndpointAuthSigningAlgValuesSupported:
          json['revocation_endpoint_auth_signing_alg_values_supported'] == null
          ? null
          : (json['revocation_endpoint_auth_signing_alg_values_supported']
                    as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      scopesSupported: json['scopes_supported'] == null
          ? null
          : (json['scopes_supported'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      serviceDocumentation: json['service_documentation'] == null
          ? null
          : json['service_documentation'] as String,
      tokenEndpoint: json['token_endpoint'] as String,
      tokenEndpointAuthMethodsSupported:
          json['token_endpoint_auth_methods_supported'] == null
          ? null
          : (json['token_endpoint_auth_methods_supported'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      tokenEndpointAuthSigningAlgValuesSupported:
          json['token_endpoint_auth_signing_alg_values_supported'] == null
          ? null
          : (json['token_endpoint_auth_signing_alg_values_supported']
                    as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      uiLocalesSupported: json['ui_locales_supported'] == null
          ? null
          : (json['ui_locales_supported'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      xResourceUrl: json['x_resource_url'] == null
          ? null
          : json['x_resource_url'] as String,
      xScope: json['x_scope'] == null ? null : json['x_scope'] as String,
      xSource: json['x_source'] == null
          ? null
          : ConnectorOAuthMetadataSource.fromJson(json['x_source'] as String),
      extra: {
        for (final entry in json.entries)
          if (!const {
            'authorization_endpoint',
            'authorization_grant_profiles_supported',
            'authorization_response_iss_parameter_supported',
            'client_id_metadata_document_supported',
            'code_challenge_methods_supported',
            'grant_types_supported',
            'introspection_endpoint',
            'introspection_endpoint_auth_methods_supported',
            'introspection_endpoint_auth_signing_alg_values_supported',
            'issuer',
            'op_policy_uri',
            'op_tos_uri',
            'registration_endpoint',
            'response_modes_supported',
            'response_types_supported',
            'revocation_endpoint',
            'revocation_endpoint_auth_methods_supported',
            'revocation_endpoint_auth_signing_alg_values_supported',
            'scopes_supported',
            'service_documentation',
            'token_endpoint',
            'token_endpoint_auth_methods_supported',
            'token_endpoint_auth_signing_alg_values_supported',
            'ui_locales_supported',
            'x_resource_url',
            'x_scope',
            'x_source',
          }.contains(entry.key))
            entry.key: entry.value,
      },
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'authorization_endpoint': ?authorizationEndpoint,
    'authorization_grant_profiles_supported':
        ?authorizationGrantProfilesSupported,
    'authorization_response_iss_parameter_supported':
        ?authorizationResponseIssParameterSupported,
    'client_id_metadata_document_supported': ?clientIdMetadataDocumentSupported,
    'code_challenge_methods_supported': ?codeChallengeMethodsSupported,
    'grant_types_supported': ?grantTypesSupported,
    'introspection_endpoint': ?introspectionEndpoint,
    'introspection_endpoint_auth_methods_supported':
        ?introspectionEndpointAuthMethodsSupported,
    'introspection_endpoint_auth_signing_alg_values_supported':
        ?introspectionEndpointAuthSigningAlgValuesSupported,
    'issuer': issuer,
    'op_policy_uri': ?opPolicyUri,
    'op_tos_uri': ?opTosUri,
    'registration_endpoint': ?registrationEndpoint,
    'response_modes_supported': ?responseModesSupported,
    'response_types_supported': ?responseTypesSupported,
    'revocation_endpoint': ?revocationEndpoint,
    'revocation_endpoint_auth_methods_supported':
        ?revocationEndpointAuthMethodsSupported,
    'revocation_endpoint_auth_signing_alg_values_supported':
        ?revocationEndpointAuthSigningAlgValuesSupported,
    'scopes_supported': ?scopesSupported,
    'service_documentation': ?serviceDocumentation,
    'token_endpoint': tokenEndpoint,
    'token_endpoint_auth_methods_supported': ?tokenEndpointAuthMethodsSupported,
    'token_endpoint_auth_signing_alg_values_supported':
        ?tokenEndpointAuthSigningAlgValuesSupported,
    'ui_locales_supported': ?uiLocalesSupported,
    'x_resource_url': ?xResourceUrl,
    'x_scope': ?xScope,
    if (xSource != null) 'x_source': xSource!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ConnectorOAuthServerMetadata copyWith({
    Object? authorizationEndpoint = unsetCopyWithValue,
    Object? authorizationGrantProfilesSupported = unsetCopyWithValue,
    Object? authorizationResponseIssParameterSupported = unsetCopyWithValue,
    Object? clientIdMetadataDocumentSupported = unsetCopyWithValue,
    Object? codeChallengeMethodsSupported = unsetCopyWithValue,
    Object? grantTypesSupported = unsetCopyWithValue,
    Object? introspectionEndpoint = unsetCopyWithValue,
    Object? introspectionEndpointAuthMethodsSupported = unsetCopyWithValue,
    Object? introspectionEndpointAuthSigningAlgValuesSupported =
        unsetCopyWithValue,
    String? issuer,
    Object? opPolicyUri = unsetCopyWithValue,
    Object? opTosUri = unsetCopyWithValue,
    Object? registrationEndpoint = unsetCopyWithValue,
    Object? responseModesSupported = unsetCopyWithValue,
    Object? responseTypesSupported = unsetCopyWithValue,
    Object? revocationEndpoint = unsetCopyWithValue,
    Object? revocationEndpointAuthMethodsSupported = unsetCopyWithValue,
    Object? revocationEndpointAuthSigningAlgValuesSupported =
        unsetCopyWithValue,
    Object? scopesSupported = unsetCopyWithValue,
    Object? serviceDocumentation = unsetCopyWithValue,
    String? tokenEndpoint,
    Object? tokenEndpointAuthMethodsSupported = unsetCopyWithValue,
    Object? tokenEndpointAuthSigningAlgValuesSupported = unsetCopyWithValue,
    Object? uiLocalesSupported = unsetCopyWithValue,
    Object? xResourceUrl = unsetCopyWithValue,
    Object? xScope = unsetCopyWithValue,
    Object? xSource = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ConnectorOAuthServerMetadata(
    authorizationEndpoint: authorizationEndpoint == unsetCopyWithValue
        ? this.authorizationEndpoint
        : authorizationEndpoint as String?,
    authorizationGrantProfilesSupported:
        authorizationGrantProfilesSupported == unsetCopyWithValue
        ? this.authorizationGrantProfilesSupported
        : (authorizationGrantProfilesSupported as List<Object?>?)
              ?.cast<String>(),
    authorizationResponseIssParameterSupported:
        authorizationResponseIssParameterSupported == unsetCopyWithValue
        ? this.authorizationResponseIssParameterSupported
        : authorizationResponseIssParameterSupported as bool?,
    clientIdMetadataDocumentSupported:
        clientIdMetadataDocumentSupported == unsetCopyWithValue
        ? this.clientIdMetadataDocumentSupported
        : clientIdMetadataDocumentSupported as bool?,
    codeChallengeMethodsSupported:
        codeChallengeMethodsSupported == unsetCopyWithValue
        ? this.codeChallengeMethodsSupported
        : (codeChallengeMethodsSupported as List<Object?>?)?.cast<String>(),
    grantTypesSupported: grantTypesSupported == unsetCopyWithValue
        ? this.grantTypesSupported
        : (grantTypesSupported as List<Object?>?)?.cast<String>(),
    introspectionEndpoint: introspectionEndpoint == unsetCopyWithValue
        ? this.introspectionEndpoint
        : introspectionEndpoint as String?,
    introspectionEndpointAuthMethodsSupported:
        introspectionEndpointAuthMethodsSupported == unsetCopyWithValue
        ? this.introspectionEndpointAuthMethodsSupported
        : (introspectionEndpointAuthMethodsSupported as List<Object?>?)
              ?.cast<String>(),
    introspectionEndpointAuthSigningAlgValuesSupported:
        introspectionEndpointAuthSigningAlgValuesSupported == unsetCopyWithValue
        ? this.introspectionEndpointAuthSigningAlgValuesSupported
        : (introspectionEndpointAuthSigningAlgValuesSupported as List<Object?>?)
              ?.cast<String>(),
    issuer: issuer ?? this.issuer,
    opPolicyUri: opPolicyUri == unsetCopyWithValue
        ? this.opPolicyUri
        : opPolicyUri as String?,
    opTosUri: opTosUri == unsetCopyWithValue
        ? this.opTosUri
        : opTosUri as String?,
    registrationEndpoint: registrationEndpoint == unsetCopyWithValue
        ? this.registrationEndpoint
        : registrationEndpoint as String?,
    responseModesSupported: responseModesSupported == unsetCopyWithValue
        ? this.responseModesSupported
        : (responseModesSupported as List<Object?>?)?.cast<String>(),
    responseTypesSupported: responseTypesSupported == unsetCopyWithValue
        ? this.responseTypesSupported
        : (responseTypesSupported as List<Object?>?)?.cast<String>(),
    revocationEndpoint: revocationEndpoint == unsetCopyWithValue
        ? this.revocationEndpoint
        : revocationEndpoint as String?,
    revocationEndpointAuthMethodsSupported:
        revocationEndpointAuthMethodsSupported == unsetCopyWithValue
        ? this.revocationEndpointAuthMethodsSupported
        : (revocationEndpointAuthMethodsSupported as List<Object?>?)
              ?.cast<String>(),
    revocationEndpointAuthSigningAlgValuesSupported:
        revocationEndpointAuthSigningAlgValuesSupported == unsetCopyWithValue
        ? this.revocationEndpointAuthSigningAlgValuesSupported
        : (revocationEndpointAuthSigningAlgValuesSupported as List<Object?>?)
              ?.cast<String>(),
    scopesSupported: scopesSupported == unsetCopyWithValue
        ? this.scopesSupported
        : (scopesSupported as List<Object?>?)?.cast<String>(),
    serviceDocumentation: serviceDocumentation == unsetCopyWithValue
        ? this.serviceDocumentation
        : serviceDocumentation as String?,
    tokenEndpoint: tokenEndpoint ?? this.tokenEndpoint,
    tokenEndpointAuthMethodsSupported:
        tokenEndpointAuthMethodsSupported == unsetCopyWithValue
        ? this.tokenEndpointAuthMethodsSupported
        : (tokenEndpointAuthMethodsSupported as List<Object?>?)?.cast<String>(),
    tokenEndpointAuthSigningAlgValuesSupported:
        tokenEndpointAuthSigningAlgValuesSupported == unsetCopyWithValue
        ? this.tokenEndpointAuthSigningAlgValuesSupported
        : (tokenEndpointAuthSigningAlgValuesSupported as List<Object?>?)
              ?.cast<String>(),
    uiLocalesSupported: uiLocalesSupported == unsetCopyWithValue
        ? this.uiLocalesSupported
        : (uiLocalesSupported as List<Object?>?)?.cast<String>(),
    xResourceUrl: xResourceUrl == unsetCopyWithValue
        ? this.xResourceUrl
        : xResourceUrl as String?,
    xScope: xScope == unsetCopyWithValue ? this.xScope : xScope as String?,
    xSource: xSource == unsetCopyWithValue
        ? this.xSource
        : xSource as ConnectorOAuthMetadataSource?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorOAuthServerMetadata &&
          runtimeType == other.runtimeType &&
          authorizationEndpoint == other.authorizationEndpoint &&
          valuesDeepEqual(
            authorizationGrantProfilesSupported,
            other.authorizationGrantProfilesSupported,
          ) &&
          authorizationResponseIssParameterSupported ==
              other.authorizationResponseIssParameterSupported &&
          clientIdMetadataDocumentSupported ==
              other.clientIdMetadataDocumentSupported &&
          valuesDeepEqual(
            codeChallengeMethodsSupported,
            other.codeChallengeMethodsSupported,
          ) &&
          valuesDeepEqual(grantTypesSupported, other.grantTypesSupported) &&
          introspectionEndpoint == other.introspectionEndpoint &&
          valuesDeepEqual(
            introspectionEndpointAuthMethodsSupported,
            other.introspectionEndpointAuthMethodsSupported,
          ) &&
          valuesDeepEqual(
            introspectionEndpointAuthSigningAlgValuesSupported,
            other.introspectionEndpointAuthSigningAlgValuesSupported,
          ) &&
          issuer == other.issuer &&
          opPolicyUri == other.opPolicyUri &&
          opTosUri == other.opTosUri &&
          registrationEndpoint == other.registrationEndpoint &&
          valuesDeepEqual(
            responseModesSupported,
            other.responseModesSupported,
          ) &&
          valuesDeepEqual(
            responseTypesSupported,
            other.responseTypesSupported,
          ) &&
          revocationEndpoint == other.revocationEndpoint &&
          valuesDeepEqual(
            revocationEndpointAuthMethodsSupported,
            other.revocationEndpointAuthMethodsSupported,
          ) &&
          valuesDeepEqual(
            revocationEndpointAuthSigningAlgValuesSupported,
            other.revocationEndpointAuthSigningAlgValuesSupported,
          ) &&
          valuesDeepEqual(scopesSupported, other.scopesSupported) &&
          serviceDocumentation == other.serviceDocumentation &&
          tokenEndpoint == other.tokenEndpoint &&
          valuesDeepEqual(
            tokenEndpointAuthMethodsSupported,
            other.tokenEndpointAuthMethodsSupported,
          ) &&
          valuesDeepEqual(
            tokenEndpointAuthSigningAlgValuesSupported,
            other.tokenEndpointAuthSigningAlgValuesSupported,
          ) &&
          valuesDeepEqual(uiLocalesSupported, other.uiLocalesSupported) &&
          xResourceUrl == other.xResourceUrl &&
          xScope == other.xScope &&
          xSource == other.xSource &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    authorizationEndpoint,
    valueDeepHashCode(authorizationGrantProfilesSupported),
    authorizationResponseIssParameterSupported,
    clientIdMetadataDocumentSupported,
    valueDeepHashCode(codeChallengeMethodsSupported),
    valueDeepHashCode(grantTypesSupported),
    introspectionEndpoint,
    valueDeepHashCode(introspectionEndpointAuthMethodsSupported),
    valueDeepHashCode(introspectionEndpointAuthSigningAlgValuesSupported),
    issuer,
    opPolicyUri,
    opTosUri,
    registrationEndpoint,
    valueDeepHashCode(responseModesSupported),
    valueDeepHashCode(responseTypesSupported),
    revocationEndpoint,
    valueDeepHashCode(revocationEndpointAuthMethodsSupported),
    valueDeepHashCode(revocationEndpointAuthSigningAlgValuesSupported),
    valueDeepHashCode(scopesSupported),
    serviceDocumentation,
    tokenEndpoint,
    valueDeepHashCode(tokenEndpointAuthMethodsSupported),
    valueDeepHashCode(tokenEndpointAuthSigningAlgValuesSupported),
    valueDeepHashCode(uiLocalesSupported),
    xResourceUrl,
    xScope,
    xSource,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ConnectorOAuthServerMetadata('
      'authorizationEndpoint: $authorizationEndpoint, '
      'authorizationGrantProfilesSupported: ${authorizationGrantProfilesSupported?.length}, '
      'authorizationResponseIssParameterSupported: $authorizationResponseIssParameterSupported, '
      'clientIdMetadataDocumentSupported: $clientIdMetadataDocumentSupported, '
      'codeChallengeMethodsSupported: ${codeChallengeMethodsSupported?.length}, '
      'grantTypesSupported: ${grantTypesSupported?.length}, '
      'introspectionEndpoint: $introspectionEndpoint, '
      'introspectionEndpointAuthMethodsSupported: ${introspectionEndpointAuthMethodsSupported?.length}, '
      'introspectionEndpointAuthSigningAlgValuesSupported: ${introspectionEndpointAuthSigningAlgValuesSupported?.length}, '
      'issuer: $issuer, '
      'opPolicyUri: $opPolicyUri, '
      'opTosUri: $opTosUri, '
      'registrationEndpoint: $registrationEndpoint, '
      'responseModesSupported: ${responseModesSupported?.length}, '
      'responseTypesSupported: ${responseTypesSupported?.length}, '
      'revocationEndpoint: $revocationEndpoint, '
      'revocationEndpointAuthMethodsSupported: ${revocationEndpointAuthMethodsSupported?.length}, '
      'revocationEndpointAuthSigningAlgValuesSupported: ${revocationEndpointAuthSigningAlgValuesSupported?.length}, '
      'scopesSupported: ${scopesSupported?.length}, '
      'serviceDocumentation: $serviceDocumentation, '
      'tokenEndpoint: $tokenEndpoint, '
      'tokenEndpointAuthMethodsSupported: ${tokenEndpointAuthMethodsSupported?.length}, '
      'tokenEndpointAuthSigningAlgValuesSupported: ${tokenEndpointAuthSigningAlgValuesSupported?.length}, '
      'uiLocalesSupported: ${uiLocalesSupported?.length}, '
      'xResourceUrl: $xResourceUrl, '
      'xScope: $xScope, '
      'xSource: $xSource, '
      'extra: ${extra?.length})';
}

/// OAuth2 client credentials stored alongside a connector's authentication method. Used by OAuth2 and Slack App auth types for token exchange and refresh flows. Contains the client credentials obtained during OAuth2 Dynamic Client Registration or provided at connector creation time.
@immutable
class ConnectorOAuthMetadataSecrets {
  /// Creates a [ConnectorOAuthMetadataSecrets].
  const ConnectorOAuthMetadataSecrets({
    this.clientId,
    this.clientIdIssuedAt,
    this.clientSecret,
    this.clientSecretExpiresAt,
  });

  /// The client_id field.
  final String? clientId;

  /// The client_id_issued_at field.
  final int? clientIdIssuedAt;

  /// The client_secret field.
  final String? clientSecret;

  /// The client_secret_expires_at field.
  final int? clientSecretExpiresAt;

  /// Parses a [ConnectorOAuthMetadataSecrets] from JSON.
  factory ConnectorOAuthMetadataSecrets.fromJson(Map<String, dynamic> json) {
    return ConnectorOAuthMetadataSecrets(
      clientId: json['client_id'] == null ? null : json['client_id'] as String,
      clientIdIssuedAt: json['client_id_issued_at'] == null
          ? null
          : json['client_id_issued_at'] as int,
      clientSecret: json['client_secret'] == null
          ? null
          : json['client_secret'] as String,
      clientSecretExpiresAt: json['client_secret_expires_at'] == null
          ? null
          : json['client_secret_expires_at'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'client_id': ?clientId,
    'client_id_issued_at': ?clientIdIssuedAt,
    'client_secret': ?clientSecret,
    'client_secret_expires_at': ?clientSecretExpiresAt,
  };

  /// Creates a copy with the given fields replaced.
  ConnectorOAuthMetadataSecrets copyWith({
    Object? clientId = unsetCopyWithValue,
    Object? clientIdIssuedAt = unsetCopyWithValue,
    Object? clientSecret = unsetCopyWithValue,
    Object? clientSecretExpiresAt = unsetCopyWithValue,
  }) => ConnectorOAuthMetadataSecrets(
    clientId: clientId == unsetCopyWithValue
        ? this.clientId
        : clientId as String?,
    clientIdIssuedAt: clientIdIssuedAt == unsetCopyWithValue
        ? this.clientIdIssuedAt
        : clientIdIssuedAt as int?,
    clientSecret: clientSecret == unsetCopyWithValue
        ? this.clientSecret
        : clientSecret as String?,
    clientSecretExpiresAt: clientSecretExpiresAt == unsetCopyWithValue
        ? this.clientSecretExpiresAt
        : clientSecretExpiresAt as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorOAuthMetadataSecrets &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId &&
          clientIdIssuedAt == other.clientIdIssuedAt &&
          clientSecret == other.clientSecret &&
          clientSecretExpiresAt == other.clientSecretExpiresAt;

  @override
  int get hashCode => Object.hashAll([
    clientId,
    clientIdIssuedAt,
    clientSecret,
    clientSecretExpiresAt,
  ]);

  @override
  String toString() =>
      'ConnectorOAuthMetadataSecrets('
      'clientId: $clientId, '
      'clientIdIssuedAt: $clientIdIssuedAt, '
      'clientSecret: ${clientSecret == null ? null : '[redacted]'}, '
      'clientSecretExpiresAt: $clientSecretExpiresAt)';
}

/// The OAuth2ClientCredentialsInput wire payload.
@immutable
class ConnectorOAuthClientCredentials {
  /// Creates a [ConnectorOAuthClientCredentials].
  const ConnectorOAuthClientCredentials({
    this.clientCertificate,
    required this.clientId,
    this.clientPrivateKey,
    this.clientSecret,
  });

  /// The fixed grant_type discriminator.
  String get grantType => 'client_credentials';

  /// PEM X.509 certificate registered on the OAuth2 client, for private_key_jwt.
  final String? clientCertificate;

  /// The client_id field.
  final String clientId;

  /// Unencrypted PEM RSA private key matching client_certificate, for private_key_jwt.
  final String? clientPrivateKey;

  /// The client_secret field.
  final String? clientSecret;

  /// Parses a [ConnectorOAuthClientCredentials] from JSON.
  factory ConnectorOAuthClientCredentials.fromJson(Map<String, dynamic> json) {
    if (json['grant_type'] case final value?
        when value != 'client_credentials') {
      throw FormatException(
        'ConnectorOAuthClientCredentials: unexpected grant_type $value',
      );
    }
    if (json['client_id'] == null) {
      throw const FormatException(
        'ConnectorOAuthClientCredentials: missing client_id',
      );
    }
    return ConnectorOAuthClientCredentials(
      clientCertificate: json['client_certificate'] == null
          ? null
          : json['client_certificate'] as String,
      clientId: json['client_id'] as String,
      clientPrivateKey: json['client_private_key'] == null
          ? null
          : json['client_private_key'] as String,
      clientSecret: json['client_secret'] == null
          ? null
          : json['client_secret'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'grant_type': grantType,
    'client_certificate': ?clientCertificate,
    'client_id': clientId,
    'client_private_key': ?clientPrivateKey,
    'client_secret': ?clientSecret,
  };

  /// Creates a copy with the given fields replaced.
  ConnectorOAuthClientCredentials copyWith({
    Object? clientCertificate = unsetCopyWithValue,
    String? clientId,
    Object? clientPrivateKey = unsetCopyWithValue,
    Object? clientSecret = unsetCopyWithValue,
  }) => ConnectorOAuthClientCredentials(
    clientCertificate: clientCertificate == unsetCopyWithValue
        ? this.clientCertificate
        : clientCertificate as String?,
    clientId: clientId ?? this.clientId,
    clientPrivateKey: clientPrivateKey == unsetCopyWithValue
        ? this.clientPrivateKey
        : clientPrivateKey as String?,
    clientSecret: clientSecret == unsetCopyWithValue
        ? this.clientSecret
        : clientSecret as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorOAuthClientCredentials &&
          runtimeType == other.runtimeType &&
          clientCertificate == other.clientCertificate &&
          clientId == other.clientId &&
          clientPrivateKey == other.clientPrivateKey &&
          clientSecret == other.clientSecret;

  @override
  int get hashCode => Object.hashAll([
    clientCertificate,
    clientId,
    clientPrivateKey,
    clientSecret,
  ]);

  @override
  String toString() =>
      'ConnectorOAuthClientCredentials('
      'clientCertificate: $clientCertificate, '
      'clientId: $clientId, '
      'clientPrivateKey: ${clientPrivateKey == null ? null : '[redacted]'}, '
      'clientSecret: ${clientSecret == null ? null : '[redacted]'})';
}
