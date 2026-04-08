import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

// ============================================================================
// Response types — returned from the API
// ============================================================================

/// Authentication details for a credential (response).
///
/// Variants:
/// - [McpOauthAuthResponse] — OAuth credential (type: "mcp_oauth")
/// - [StaticBearerAuthResponse] — Static bearer token (type: "static_bearer")
/// - [UnknownCredentialAuth] — Unrecognized type (preserves raw JSON)
sealed class CredentialAuth {
  const CredentialAuth();

  /// Creates a [CredentialAuth] from JSON.
  factory CredentialAuth.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'mcp_oauth' => McpOauthAuthResponse.fromJson(json),
      'static_bearer' => StaticBearerAuthResponse.fromJson(json),
      _ => UnknownCredentialAuth.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// OAuth credential details for an MCP server.
@immutable
class McpOauthAuthResponse extends CredentialAuth {
  /// The type discriminator. Always `mcp_oauth`.
  final String type;

  /// URL of the MCP server this credential authenticates against.
  final String mcpServerUrl;

  /// When the access token expires.
  final DateTime? expiresAt;

  /// Refresh token configuration, if the credential supports token refresh.
  final McpOauthRefreshResponse? refresh;

  /// Creates a [McpOauthAuthResponse].
  const McpOauthAuthResponse({
    this.type = 'mcp_oauth',
    required this.mcpServerUrl,
    this.expiresAt,
    this.refresh,
  });

  /// Creates a [McpOauthAuthResponse] from JSON.
  factory McpOauthAuthResponse.fromJson(Map<String, dynamic> json) {
    return McpOauthAuthResponse(
      type: json['type'] as String? ?? 'mcp_oauth',
      mcpServerUrl: json['mcp_server_url'] as String,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      refresh: json['refresh'] != null
          ? McpOauthRefreshResponse.fromJson(
              json['refresh'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'mcp_server_url': mcpServerUrl,
    if (expiresAt != null) 'expires_at': expiresAt!.toUtc().toIso8601String(),
    if (refresh != null) 'refresh': refresh!.toJson(),
  };

  /// Creates a copy with replaced values.
  McpOauthAuthResponse copyWith({
    String? type,
    String? mcpServerUrl,
    Object? expiresAt = unsetCopyWithValue,
    Object? refresh = unsetCopyWithValue,
  }) {
    return McpOauthAuthResponse(
      type: type ?? this.type,
      mcpServerUrl: mcpServerUrl ?? this.mcpServerUrl,
      expiresAt: expiresAt == unsetCopyWithValue
          ? this.expiresAt
          : expiresAt as DateTime?,
      refresh: refresh == unsetCopyWithValue
          ? this.refresh
          : refresh as McpOauthRefreshResponse?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpOauthAuthResponse &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mcpServerUrl == other.mcpServerUrl &&
          expiresAt == other.expiresAt &&
          refresh == other.refresh;

  @override
  int get hashCode => Object.hash(type, mcpServerUrl, expiresAt, refresh);

  @override
  String toString() =>
      'McpOauthAuthResponse('
      'type: $type, '
      'mcpServerUrl: $mcpServerUrl, '
      'expiresAt: $expiresAt, '
      'refresh: $refresh)';
}

/// Static bearer token credential details for an MCP server.
@immutable
class StaticBearerAuthResponse extends CredentialAuth {
  /// The type discriminator. Always `static_bearer`.
  final String type;

  /// URL of the MCP server this credential authenticates against.
  final String mcpServerUrl;

  /// Creates a [StaticBearerAuthResponse].
  const StaticBearerAuthResponse({
    this.type = 'static_bearer',
    required this.mcpServerUrl,
  });

  /// Creates a [StaticBearerAuthResponse] from JSON.
  factory StaticBearerAuthResponse.fromJson(Map<String, dynamic> json) {
    return StaticBearerAuthResponse(
      type: json['type'] as String? ?? 'static_bearer',
      mcpServerUrl: json['mcp_server_url'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'mcp_server_url': mcpServerUrl,
  };

  /// Creates a copy with replaced values.
  StaticBearerAuthResponse copyWith({String? type, String? mcpServerUrl}) {
    return StaticBearerAuthResponse(
      type: type ?? this.type,
      mcpServerUrl: mcpServerUrl ?? this.mcpServerUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaticBearerAuthResponse &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mcpServerUrl == other.mcpServerUrl;

  @override
  int get hashCode => Object.hash(type, mcpServerUrl);

  @override
  String toString() =>
      'StaticBearerAuthResponse(type: $type, mcpServerUrl: $mcpServerUrl)';
}

/// Unrecognized credential auth type (preserves raw JSON).
@immutable
class UnknownCredentialAuth extends CredentialAuth {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownCredentialAuth].
  const UnknownCredentialAuth({required this.rawJson});

  /// Creates an [UnknownCredentialAuth] from JSON.
  factory UnknownCredentialAuth.fromJson(Map<String, dynamic> json) {
    return UnknownCredentialAuth(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownCredentialAuth &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownCredentialAuth(rawJson: $rawJson)';
}

// ============================================================================
// McpOauthRefreshResponse
// ============================================================================

/// OAuth refresh token configuration returned in credential responses.
@immutable
class McpOauthRefreshResponse {
  /// OAuth client ID.
  final String clientId;

  /// Token endpoint URL used to refresh the access token.
  final String tokenEndpoint;

  /// Token endpoint authentication method.
  final TokenEndpointAuthResponse tokenEndpointAuth;

  /// OAuth resource indicator.
  final String? resource;

  /// OAuth scope for the refresh request.
  final String? scope;

  /// Creates a [McpOauthRefreshResponse].
  const McpOauthRefreshResponse({
    required this.clientId,
    required this.tokenEndpoint,
    required this.tokenEndpointAuth,
    this.resource,
    this.scope,
  });

  /// Creates a [McpOauthRefreshResponse] from JSON.
  factory McpOauthRefreshResponse.fromJson(Map<String, dynamic> json) {
    return McpOauthRefreshResponse(
      clientId: json['client_id'] as String,
      tokenEndpoint: json['token_endpoint'] as String,
      tokenEndpointAuth: TokenEndpointAuthResponse.fromJson(
        json['token_endpoint_auth'] as Map<String, dynamic>,
      ),
      resource: json['resource'] as String?,
      scope: json['scope'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'client_id': clientId,
    'token_endpoint': tokenEndpoint,
    'token_endpoint_auth': tokenEndpointAuth.toJson(),
    if (resource != null) 'resource': resource,
    if (scope != null) 'scope': scope,
  };

  /// Creates a copy with replaced values.
  McpOauthRefreshResponse copyWith({
    String? clientId,
    String? tokenEndpoint,
    TokenEndpointAuthResponse? tokenEndpointAuth,
    Object? resource = unsetCopyWithValue,
    Object? scope = unsetCopyWithValue,
  }) {
    return McpOauthRefreshResponse(
      clientId: clientId ?? this.clientId,
      tokenEndpoint: tokenEndpoint ?? this.tokenEndpoint,
      tokenEndpointAuth: tokenEndpointAuth ?? this.tokenEndpointAuth,
      resource: resource == unsetCopyWithValue
          ? this.resource
          : resource as String?,
      scope: scope == unsetCopyWithValue ? this.scope : scope as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpOauthRefreshResponse &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId &&
          tokenEndpoint == other.tokenEndpoint &&
          tokenEndpointAuth == other.tokenEndpointAuth &&
          resource == other.resource &&
          scope == other.scope;

  @override
  int get hashCode =>
      Object.hash(clientId, tokenEndpoint, tokenEndpointAuth, resource, scope);

  @override
  String toString() =>
      'McpOauthRefreshResponse('
      'clientId: $clientId, '
      'tokenEndpoint: $tokenEndpoint, '
      'tokenEndpointAuth: $tokenEndpointAuth, '
      'resource: $resource, '
      'scope: $scope)';
}

// ============================================================================
// TokenEndpointAuthResponse — sealed
// ============================================================================

/// Token endpoint authentication method (response).
///
/// Variants:
/// - [TokenEndpointAuthNoneResponse] — No authentication (type: "none")
/// - [TokenEndpointAuthBasicResponse] — HTTP Basic (type: "client_secret_basic")
/// - [TokenEndpointAuthPostResponse] — POST body (type: "client_secret_post")
/// - [UnknownTokenEndpointAuthResponse] — Unrecognized type
sealed class TokenEndpointAuthResponse {
  const TokenEndpointAuthResponse();

  /// Creates a [TokenEndpointAuthResponse] from JSON.
  factory TokenEndpointAuthResponse.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'none' => TokenEndpointAuthNoneResponse.fromJson(json),
      'client_secret_basic' => TokenEndpointAuthBasicResponse.fromJson(json),
      'client_secret_post' => TokenEndpointAuthPostResponse.fromJson(json),
      _ => UnknownTokenEndpointAuthResponse.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Token endpoint requires no client authentication.
@immutable
class TokenEndpointAuthNoneResponse extends TokenEndpointAuthResponse {
  /// The type discriminator. Always `none`.
  final String type;

  /// Creates a [TokenEndpointAuthNoneResponse].
  const TokenEndpointAuthNoneResponse({this.type = 'none'});

  /// Creates a [TokenEndpointAuthNoneResponse] from JSON.
  factory TokenEndpointAuthNoneResponse.fromJson(Map<String, dynamic> json) {
    return TokenEndpointAuthNoneResponse(
      type: json['type'] as String? ?? 'none',
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates a copy with replaced values.
  TokenEndpointAuthNoneResponse copyWith({String? type}) {
    return TokenEndpointAuthNoneResponse(type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenEndpointAuthNoneResponse &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'TokenEndpointAuthNoneResponse(type: $type)';
}

/// Token endpoint uses HTTP Basic authentication with client credentials.
@immutable
class TokenEndpointAuthBasicResponse extends TokenEndpointAuthResponse {
  /// The type discriminator. Always `client_secret_basic`.
  final String type;

  /// Creates a [TokenEndpointAuthBasicResponse].
  const TokenEndpointAuthBasicResponse({this.type = 'client_secret_basic'});

  /// Creates a [TokenEndpointAuthBasicResponse] from JSON.
  factory TokenEndpointAuthBasicResponse.fromJson(Map<String, dynamic> json) {
    return TokenEndpointAuthBasicResponse(
      type: json['type'] as String? ?? 'client_secret_basic',
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates a copy with replaced values.
  TokenEndpointAuthBasicResponse copyWith({String? type}) {
    return TokenEndpointAuthBasicResponse(type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenEndpointAuthBasicResponse &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'TokenEndpointAuthBasicResponse(type: $type)';
}

/// Token endpoint uses POST body authentication with client credentials.
@immutable
class TokenEndpointAuthPostResponse extends TokenEndpointAuthResponse {
  /// The type discriminator. Always `client_secret_post`.
  final String type;

  /// Creates a [TokenEndpointAuthPostResponse].
  const TokenEndpointAuthPostResponse({this.type = 'client_secret_post'});

  /// Creates a [TokenEndpointAuthPostResponse] from JSON.
  factory TokenEndpointAuthPostResponse.fromJson(Map<String, dynamic> json) {
    return TokenEndpointAuthPostResponse(
      type: json['type'] as String? ?? 'client_secret_post',
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates a copy with replaced values.
  TokenEndpointAuthPostResponse copyWith({String? type}) {
    return TokenEndpointAuthPostResponse(type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenEndpointAuthPostResponse &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'TokenEndpointAuthPostResponse(type: $type)';
}

/// Unrecognized token endpoint auth type (preserves raw JSON).
@immutable
class UnknownTokenEndpointAuthResponse extends TokenEndpointAuthResponse {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownTokenEndpointAuthResponse].
  const UnknownTokenEndpointAuthResponse({required this.rawJson});

  /// Creates an [UnknownTokenEndpointAuthResponse] from JSON.
  factory UnknownTokenEndpointAuthResponse.fromJson(Map<String, dynamic> json) {
    return UnknownTokenEndpointAuthResponse(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownTokenEndpointAuthResponse &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownTokenEndpointAuthResponse(rawJson: $rawJson)';
}

// ============================================================================
// Create types — sent to API
// ============================================================================

/// Authentication details for creating a credential.
///
/// Variants:
/// - [McpOauthCreateParams] — OAuth credential (type: "mcp_oauth")
/// - [StaticBearerCreateParams] — Static bearer token (type: "static_bearer")
/// - [UnknownCredentialCreateAuth] — Unrecognized type (preserves raw JSON)
sealed class CredentialCreateAuth {
  const CredentialCreateAuth();

  /// Creates a [CredentialCreateAuth] from JSON.
  factory CredentialCreateAuth.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'mcp_oauth' => McpOauthCreateParams.fromJson(json),
      'static_bearer' => StaticBearerCreateParams.fromJson(json),
      _ => UnknownCredentialCreateAuth.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Parameters for creating an MCP OAuth credential.
@immutable
class McpOauthCreateParams extends CredentialCreateAuth {
  /// The type discriminator. Always `mcp_oauth`.
  final String type;

  /// OAuth access token.
  final String accessToken;

  /// URL of the MCP server this credential authenticates against.
  final String mcpServerUrl;

  /// When the access token expires.
  final DateTime? expiresAt;

  /// Refresh token configuration, if the credential supports token refresh.
  final McpOauthRefreshParams? refresh;

  /// Creates a [McpOauthCreateParams].
  const McpOauthCreateParams({
    this.type = 'mcp_oauth',
    required this.accessToken,
    required this.mcpServerUrl,
    this.expiresAt,
    this.refresh,
  });

  /// Creates a [McpOauthCreateParams] from JSON.
  factory McpOauthCreateParams.fromJson(Map<String, dynamic> json) {
    return McpOauthCreateParams(
      type: json['type'] as String? ?? 'mcp_oauth',
      accessToken: json['access_token'] as String,
      mcpServerUrl: json['mcp_server_url'] as String,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      refresh: json['refresh'] != null
          ? McpOauthRefreshParams.fromJson(
              json['refresh'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'access_token': accessToken,
    'mcp_server_url': mcpServerUrl,
    if (expiresAt != null) 'expires_at': expiresAt!.toUtc().toIso8601String(),
    if (refresh != null) 'refresh': refresh!.toJson(),
  };

  /// Creates a copy with replaced values.
  McpOauthCreateParams copyWith({
    String? type,
    String? accessToken,
    String? mcpServerUrl,
    Object? expiresAt = unsetCopyWithValue,
    Object? refresh = unsetCopyWithValue,
  }) {
    return McpOauthCreateParams(
      type: type ?? this.type,
      accessToken: accessToken ?? this.accessToken,
      mcpServerUrl: mcpServerUrl ?? this.mcpServerUrl,
      expiresAt: expiresAt == unsetCopyWithValue
          ? this.expiresAt
          : expiresAt as DateTime?,
      refresh: refresh == unsetCopyWithValue
          ? this.refresh
          : refresh as McpOauthRefreshParams?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpOauthCreateParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          accessToken == other.accessToken &&
          mcpServerUrl == other.mcpServerUrl &&
          expiresAt == other.expiresAt &&
          refresh == other.refresh;

  @override
  int get hashCode =>
      Object.hash(type, accessToken, mcpServerUrl, expiresAt, refresh);

  @override
  String toString() =>
      'McpOauthCreateParams('
      'type: $type, '
      'accessToken: $accessToken, '
      'mcpServerUrl: $mcpServerUrl, '
      'expiresAt: $expiresAt, '
      'refresh: $refresh)';
}

/// Parameters for creating a static bearer token credential.
@immutable
class StaticBearerCreateParams extends CredentialCreateAuth {
  /// The type discriminator. Always `static_bearer`.
  final String type;

  /// Static bearer token value.
  final String token;

  /// URL of the MCP server this credential authenticates against.
  final String mcpServerUrl;

  /// Creates a [StaticBearerCreateParams].
  const StaticBearerCreateParams({
    this.type = 'static_bearer',
    required this.token,
    required this.mcpServerUrl,
  });

  /// Creates a [StaticBearerCreateParams] from JSON.
  factory StaticBearerCreateParams.fromJson(Map<String, dynamic> json) {
    return StaticBearerCreateParams(
      type: json['type'] as String? ?? 'static_bearer',
      token: json['token'] as String,
      mcpServerUrl: json['mcp_server_url'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'token': token,
    'mcp_server_url': mcpServerUrl,
  };

  /// Creates a copy with replaced values.
  StaticBearerCreateParams copyWith({
    String? type,
    String? token,
    String? mcpServerUrl,
  }) {
    return StaticBearerCreateParams(
      type: type ?? this.type,
      token: token ?? this.token,
      mcpServerUrl: mcpServerUrl ?? this.mcpServerUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaticBearerCreateParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          token == other.token &&
          mcpServerUrl == other.mcpServerUrl;

  @override
  int get hashCode => Object.hash(type, token, mcpServerUrl);

  @override
  String toString() =>
      'StaticBearerCreateParams('
      'type: $type, '
      'token: $token, '
      'mcpServerUrl: $mcpServerUrl)';
}

/// Unrecognized credential create auth type (preserves raw JSON).
@immutable
class UnknownCredentialCreateAuth extends CredentialCreateAuth {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownCredentialCreateAuth].
  const UnknownCredentialCreateAuth({required this.rawJson});

  /// Creates an [UnknownCredentialCreateAuth] from JSON.
  factory UnknownCredentialCreateAuth.fromJson(Map<String, dynamic> json) {
    return UnknownCredentialCreateAuth(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownCredentialCreateAuth &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownCredentialCreateAuth(rawJson: $rawJson)';
}

// ============================================================================
// McpOauthRefreshParams
// ============================================================================

/// OAuth refresh token parameters for creating a credential with refresh
/// support.
@immutable
class McpOauthRefreshParams {
  /// OAuth client ID.
  final String clientId;

  /// OAuth refresh token.
  final String refreshToken;

  /// Token endpoint URL used to refresh the access token.
  final String tokenEndpoint;

  /// Token endpoint authentication method.
  final TokenEndpointAuthParam tokenEndpointAuth;

  /// OAuth resource indicator.
  final String? resource;

  /// OAuth scope for the refresh request.
  final String? scope;

  /// Creates a [McpOauthRefreshParams].
  const McpOauthRefreshParams({
    required this.clientId,
    required this.refreshToken,
    required this.tokenEndpoint,
    required this.tokenEndpointAuth,
    this.resource,
    this.scope,
  });

  /// Creates a [McpOauthRefreshParams] from JSON.
  factory McpOauthRefreshParams.fromJson(Map<String, dynamic> json) {
    return McpOauthRefreshParams(
      clientId: json['client_id'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenEndpoint: json['token_endpoint'] as String,
      tokenEndpointAuth: TokenEndpointAuthParam.fromJson(
        json['token_endpoint_auth'] as Map<String, dynamic>,
      ),
      resource: json['resource'] as String?,
      scope: json['scope'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'client_id': clientId,
    'refresh_token': refreshToken,
    'token_endpoint': tokenEndpoint,
    'token_endpoint_auth': tokenEndpointAuth.toJson(),
    if (resource != null) 'resource': resource,
    if (scope != null) 'scope': scope,
  };

  /// Creates a copy with replaced values.
  McpOauthRefreshParams copyWith({
    String? clientId,
    String? refreshToken,
    String? tokenEndpoint,
    TokenEndpointAuthParam? tokenEndpointAuth,
    Object? resource = unsetCopyWithValue,
    Object? scope = unsetCopyWithValue,
  }) {
    return McpOauthRefreshParams(
      clientId: clientId ?? this.clientId,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenEndpoint: tokenEndpoint ?? this.tokenEndpoint,
      tokenEndpointAuth: tokenEndpointAuth ?? this.tokenEndpointAuth,
      resource: resource == unsetCopyWithValue
          ? this.resource
          : resource as String?,
      scope: scope == unsetCopyWithValue ? this.scope : scope as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpOauthRefreshParams &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId &&
          refreshToken == other.refreshToken &&
          tokenEndpoint == other.tokenEndpoint &&
          tokenEndpointAuth == other.tokenEndpointAuth &&
          resource == other.resource &&
          scope == other.scope;

  @override
  int get hashCode => Object.hash(
    clientId,
    refreshToken,
    tokenEndpoint,
    tokenEndpointAuth,
    resource,
    scope,
  );

  @override
  String toString() =>
      'McpOauthRefreshParams('
      'clientId: $clientId, '
      'refreshToken: $refreshToken, '
      'tokenEndpoint: $tokenEndpoint, '
      'tokenEndpointAuth: $tokenEndpointAuth, '
      'resource: $resource, '
      'scope: $scope)';
}

// ============================================================================
// TokenEndpointAuthParam — sealed
// ============================================================================

/// Token endpoint authentication method (create params).
///
/// Variants:
/// - [TokenEndpointAuthNoneParam] — No authentication (type: "none")
/// - [TokenEndpointAuthBasicParam] — HTTP Basic (type: "client_secret_basic")
/// - [TokenEndpointAuthPostParam] — POST body (type: "client_secret_post")
/// - [UnknownTokenEndpointAuthParam] — Unrecognized type
sealed class TokenEndpointAuthParam {
  const TokenEndpointAuthParam();

  /// Creates a [TokenEndpointAuthParam] from JSON.
  factory TokenEndpointAuthParam.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'none' => TokenEndpointAuthNoneParam.fromJson(json),
      'client_secret_basic' => TokenEndpointAuthBasicParam.fromJson(json),
      'client_secret_post' => TokenEndpointAuthPostParam.fromJson(json),
      _ => UnknownTokenEndpointAuthParam.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Token endpoint requires no client authentication.
@immutable
class TokenEndpointAuthNoneParam extends TokenEndpointAuthParam {
  /// The type discriminator. Always `none`.
  final String type;

  /// Creates a [TokenEndpointAuthNoneParam].
  const TokenEndpointAuthNoneParam({this.type = 'none'});

  /// Creates a [TokenEndpointAuthNoneParam] from JSON.
  factory TokenEndpointAuthNoneParam.fromJson(Map<String, dynamic> json) {
    return TokenEndpointAuthNoneParam(type: json['type'] as String? ?? 'none');
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates a copy with replaced values.
  TokenEndpointAuthNoneParam copyWith({String? type}) {
    return TokenEndpointAuthNoneParam(type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenEndpointAuthNoneParam &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'TokenEndpointAuthNoneParam(type: $type)';
}

/// Token endpoint uses HTTP Basic authentication with client credentials.
@immutable
class TokenEndpointAuthBasicParam extends TokenEndpointAuthParam {
  /// The type discriminator. Always `client_secret_basic`.
  final String type;

  /// OAuth client secret.
  final String clientSecret;

  /// Creates a [TokenEndpointAuthBasicParam].
  const TokenEndpointAuthBasicParam({
    this.type = 'client_secret_basic',
    required this.clientSecret,
  });

  /// Creates a [TokenEndpointAuthBasicParam] from JSON.
  factory TokenEndpointAuthBasicParam.fromJson(Map<String, dynamic> json) {
    return TokenEndpointAuthBasicParam(
      type: json['type'] as String? ?? 'client_secret_basic',
      clientSecret: json['client_secret'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'client_secret': clientSecret,
  };

  /// Creates a copy with replaced values.
  TokenEndpointAuthBasicParam copyWith({String? type, String? clientSecret}) {
    return TokenEndpointAuthBasicParam(
      type: type ?? this.type,
      clientSecret: clientSecret ?? this.clientSecret,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenEndpointAuthBasicParam &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          clientSecret == other.clientSecret;

  @override
  int get hashCode => Object.hash(type, clientSecret);

  @override
  String toString() =>
      'TokenEndpointAuthBasicParam(type: $type, clientSecret: $clientSecret)';
}

/// Token endpoint uses POST body authentication with client credentials.
@immutable
class TokenEndpointAuthPostParam extends TokenEndpointAuthParam {
  /// The type discriminator. Always `client_secret_post`.
  final String type;

  /// OAuth client secret.
  final String clientSecret;

  /// Creates a [TokenEndpointAuthPostParam].
  const TokenEndpointAuthPostParam({
    this.type = 'client_secret_post',
    required this.clientSecret,
  });

  /// Creates a [TokenEndpointAuthPostParam] from JSON.
  factory TokenEndpointAuthPostParam.fromJson(Map<String, dynamic> json) {
    return TokenEndpointAuthPostParam(
      type: json['type'] as String? ?? 'client_secret_post',
      clientSecret: json['client_secret'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'client_secret': clientSecret,
  };

  /// Creates a copy with replaced values.
  TokenEndpointAuthPostParam copyWith({String? type, String? clientSecret}) {
    return TokenEndpointAuthPostParam(
      type: type ?? this.type,
      clientSecret: clientSecret ?? this.clientSecret,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenEndpointAuthPostParam &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          clientSecret == other.clientSecret;

  @override
  int get hashCode => Object.hash(type, clientSecret);

  @override
  String toString() =>
      'TokenEndpointAuthPostParam(type: $type, clientSecret: $clientSecret)';
}

/// Unrecognized token endpoint auth type (preserves raw JSON).
@immutable
class UnknownTokenEndpointAuthParam extends TokenEndpointAuthParam {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownTokenEndpointAuthParam].
  const UnknownTokenEndpointAuthParam({required this.rawJson});

  /// Creates an [UnknownTokenEndpointAuthParam] from JSON.
  factory UnknownTokenEndpointAuthParam.fromJson(Map<String, dynamic> json) {
    return UnknownTokenEndpointAuthParam(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownTokenEndpointAuthParam &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownTokenEndpointAuthParam(rawJson: $rawJson)';
}

// ============================================================================
// Update types — sent for updates
// ============================================================================

/// Updated authentication details for a credential.
///
/// Variants:
/// - [McpOauthUpdateParams] — OAuth credential (type: "mcp_oauth")
/// - [StaticBearerUpdateParams] — Static bearer token (type: "static_bearer")
/// - [UnknownCredentialUpdateAuth] — Unrecognized type (preserves raw JSON)
sealed class CredentialUpdateAuth {
  const CredentialUpdateAuth();

  /// Creates a [CredentialUpdateAuth] from JSON.
  factory CredentialUpdateAuth.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'mcp_oauth' => McpOauthUpdateParams.fromJson(json),
      'static_bearer' => StaticBearerUpdateParams.fromJson(json),
      _ => UnknownCredentialUpdateAuth.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Parameters for updating an MCP OAuth credential.
///
/// The `mcp_server_url` is immutable.
@immutable
class McpOauthUpdateParams extends CredentialUpdateAuth {
  /// The type discriminator. Always `mcp_oauth`.
  final String type;

  /// Updated OAuth access token.
  final String? accessToken;

  /// Updated expiration time.
  final DateTime? expiresAt;

  /// Updated refresh token configuration.
  final McpOauthRefreshUpdateParams? refresh;

  /// Creates a [McpOauthUpdateParams].
  const McpOauthUpdateParams({
    this.type = 'mcp_oauth',
    this.accessToken,
    this.expiresAt,
    this.refresh,
  });

  /// Creates a [McpOauthUpdateParams] from JSON.
  factory McpOauthUpdateParams.fromJson(Map<String, dynamic> json) {
    return McpOauthUpdateParams(
      type: json['type'] as String? ?? 'mcp_oauth',
      accessToken: json['access_token'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      refresh: json['refresh'] != null
          ? McpOauthRefreshUpdateParams.fromJson(
              json['refresh'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (accessToken != null) 'access_token': accessToken,
    if (expiresAt != null) 'expires_at': expiresAt!.toUtc().toIso8601String(),
    if (refresh != null) 'refresh': refresh!.toJson(),
  };

  /// Creates a copy with replaced values.
  McpOauthUpdateParams copyWith({
    String? type,
    Object? accessToken = unsetCopyWithValue,
    Object? expiresAt = unsetCopyWithValue,
    Object? refresh = unsetCopyWithValue,
  }) {
    return McpOauthUpdateParams(
      type: type ?? this.type,
      accessToken: accessToken == unsetCopyWithValue
          ? this.accessToken
          : accessToken as String?,
      expiresAt: expiresAt == unsetCopyWithValue
          ? this.expiresAt
          : expiresAt as DateTime?,
      refresh: refresh == unsetCopyWithValue
          ? this.refresh
          : refresh as McpOauthRefreshUpdateParams?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpOauthUpdateParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          accessToken == other.accessToken &&
          expiresAt == other.expiresAt &&
          refresh == other.refresh;

  @override
  int get hashCode => Object.hash(type, accessToken, expiresAt, refresh);

  @override
  String toString() =>
      'McpOauthUpdateParams('
      'type: $type, '
      'accessToken: $accessToken, '
      'expiresAt: $expiresAt, '
      'refresh: $refresh)';
}

/// Parameters for updating a static bearer token credential.
///
/// The `mcp_server_url` is immutable.
@immutable
class StaticBearerUpdateParams extends CredentialUpdateAuth {
  /// The type discriminator. Always `static_bearer`.
  final String type;

  /// Updated static bearer token value.
  final String? token;

  /// Creates a [StaticBearerUpdateParams].
  const StaticBearerUpdateParams({this.type = 'static_bearer', this.token});

  /// Creates a [StaticBearerUpdateParams] from JSON.
  factory StaticBearerUpdateParams.fromJson(Map<String, dynamic> json) {
    return StaticBearerUpdateParams(
      type: json['type'] as String? ?? 'static_bearer',
      token: json['token'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (token != null) 'token': token,
  };

  /// Creates a copy with replaced values.
  StaticBearerUpdateParams copyWith({
    String? type,
    Object? token = unsetCopyWithValue,
  }) {
    return StaticBearerUpdateParams(
      type: type ?? this.type,
      token: token == unsetCopyWithValue ? this.token : token as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaticBearerUpdateParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          token == other.token;

  @override
  int get hashCode => Object.hash(type, token);

  @override
  String toString() => 'StaticBearerUpdateParams(type: $type, token: $token)';
}

/// Unrecognized credential update auth type (preserves raw JSON).
@immutable
class UnknownCredentialUpdateAuth extends CredentialUpdateAuth {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownCredentialUpdateAuth].
  const UnknownCredentialUpdateAuth({required this.rawJson});

  /// Creates an [UnknownCredentialUpdateAuth] from JSON.
  factory UnknownCredentialUpdateAuth.fromJson(Map<String, dynamic> json) {
    return UnknownCredentialUpdateAuth(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownCredentialUpdateAuth &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownCredentialUpdateAuth(rawJson: $rawJson)';
}

// ============================================================================
// McpOauthRefreshUpdateParams
// ============================================================================

/// Parameters for updating OAuth refresh token configuration.
@immutable
class McpOauthRefreshUpdateParams {
  /// Updated OAuth refresh token.
  final String? refreshToken;

  /// Updated OAuth scope for the refresh request.
  final String? scope;

  /// Updated token endpoint authentication method.
  final TokenEndpointAuthUpdateParam? tokenEndpointAuth;

  /// Creates a [McpOauthRefreshUpdateParams].
  const McpOauthRefreshUpdateParams({
    this.refreshToken,
    this.scope,
    this.tokenEndpointAuth,
  });

  /// Creates a [McpOauthRefreshUpdateParams] from JSON.
  factory McpOauthRefreshUpdateParams.fromJson(Map<String, dynamic> json) {
    return McpOauthRefreshUpdateParams(
      refreshToken: json['refresh_token'] as String?,
      scope: json['scope'] as String?,
      tokenEndpointAuth: json['token_endpoint_auth'] != null
          ? TokenEndpointAuthUpdateParam.fromJson(
              json['token_endpoint_auth'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (refreshToken != null) 'refresh_token': refreshToken,
    if (scope != null) 'scope': scope,
    if (tokenEndpointAuth != null)
      'token_endpoint_auth': tokenEndpointAuth!.toJson(),
  };

  /// Creates a copy with replaced values.
  McpOauthRefreshUpdateParams copyWith({
    Object? refreshToken = unsetCopyWithValue,
    Object? scope = unsetCopyWithValue,
    Object? tokenEndpointAuth = unsetCopyWithValue,
  }) {
    return McpOauthRefreshUpdateParams(
      refreshToken: refreshToken == unsetCopyWithValue
          ? this.refreshToken
          : refreshToken as String?,
      scope: scope == unsetCopyWithValue ? this.scope : scope as String?,
      tokenEndpointAuth: tokenEndpointAuth == unsetCopyWithValue
          ? this.tokenEndpointAuth
          : tokenEndpointAuth as TokenEndpointAuthUpdateParam?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpOauthRefreshUpdateParams &&
          runtimeType == other.runtimeType &&
          refreshToken == other.refreshToken &&
          scope == other.scope &&
          tokenEndpointAuth == other.tokenEndpointAuth;

  @override
  int get hashCode => Object.hash(refreshToken, scope, tokenEndpointAuth);

  @override
  String toString() =>
      'McpOauthRefreshUpdateParams('
      'refreshToken: $refreshToken, '
      'scope: $scope, '
      'tokenEndpointAuth: $tokenEndpointAuth)';
}

// ============================================================================
// TokenEndpointAuthUpdateParam — sealed
// ============================================================================

/// Token endpoint authentication method (update params).
///
/// Variants:
/// - [TokenEndpointAuthBasicUpdateParam] — HTTP Basic (type: "client_secret_basic")
/// - [TokenEndpointAuthPostUpdateParam] — POST body (type: "client_secret_post")
/// - [UnknownTokenEndpointAuthUpdateParam] — Unrecognized type
sealed class TokenEndpointAuthUpdateParam {
  const TokenEndpointAuthUpdateParam();

  /// Creates a [TokenEndpointAuthUpdateParam] from JSON.
  factory TokenEndpointAuthUpdateParam.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'client_secret_basic' => TokenEndpointAuthBasicUpdateParam.fromJson(json),
      'client_secret_post' => TokenEndpointAuthPostUpdateParam.fromJson(json),
      _ => UnknownTokenEndpointAuthUpdateParam.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Updated HTTP Basic authentication parameters for the token endpoint.
@immutable
class TokenEndpointAuthBasicUpdateParam extends TokenEndpointAuthUpdateParam {
  /// Updated OAuth client secret.
  final String? clientSecret;

  /// Creates a [TokenEndpointAuthBasicUpdateParam].
  const TokenEndpointAuthBasicUpdateParam({this.clientSecret});

  /// Creates a [TokenEndpointAuthBasicUpdateParam] from JSON.
  factory TokenEndpointAuthBasicUpdateParam.fromJson(
    Map<String, dynamic> json,
  ) {
    return TokenEndpointAuthBasicUpdateParam(
      clientSecret: json['client_secret'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'client_secret_basic',
    if (clientSecret != null) 'client_secret': clientSecret,
  };

  /// Creates a copy with replaced values.
  TokenEndpointAuthBasicUpdateParam copyWith({
    Object? clientSecret = unsetCopyWithValue,
  }) {
    return TokenEndpointAuthBasicUpdateParam(
      clientSecret: clientSecret == unsetCopyWithValue
          ? this.clientSecret
          : clientSecret as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenEndpointAuthBasicUpdateParam &&
          runtimeType == other.runtimeType &&
          clientSecret == other.clientSecret;

  @override
  int get hashCode => clientSecret.hashCode;

  @override
  String toString() =>
      'TokenEndpointAuthBasicUpdateParam(clientSecret: $clientSecret)';
}

/// Updated POST body authentication parameters for the token endpoint.
@immutable
class TokenEndpointAuthPostUpdateParam extends TokenEndpointAuthUpdateParam {
  /// Updated OAuth client secret.
  final String? clientSecret;

  /// Creates a [TokenEndpointAuthPostUpdateParam].
  const TokenEndpointAuthPostUpdateParam({this.clientSecret});

  /// Creates a [TokenEndpointAuthPostUpdateParam] from JSON.
  factory TokenEndpointAuthPostUpdateParam.fromJson(Map<String, dynamic> json) {
    return TokenEndpointAuthPostUpdateParam(
      clientSecret: json['client_secret'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'client_secret_post',
    if (clientSecret != null) 'client_secret': clientSecret,
  };

  /// Creates a copy with replaced values.
  TokenEndpointAuthPostUpdateParam copyWith({
    Object? clientSecret = unsetCopyWithValue,
  }) {
    return TokenEndpointAuthPostUpdateParam(
      clientSecret: clientSecret == unsetCopyWithValue
          ? this.clientSecret
          : clientSecret as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenEndpointAuthPostUpdateParam &&
          runtimeType == other.runtimeType &&
          clientSecret == other.clientSecret;

  @override
  int get hashCode => clientSecret.hashCode;

  @override
  String toString() =>
      'TokenEndpointAuthPostUpdateParam(clientSecret: $clientSecret)';
}

/// Unrecognized token endpoint auth update type (preserves raw JSON).
@immutable
class UnknownTokenEndpointAuthUpdateParam extends TokenEndpointAuthUpdateParam {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownTokenEndpointAuthUpdateParam].
  const UnknownTokenEndpointAuthUpdateParam({required this.rawJson});

  /// Creates an [UnknownTokenEndpointAuthUpdateParam] from JSON.
  factory UnknownTokenEndpointAuthUpdateParam.fromJson(
    Map<String, dynamic> json,
  ) {
    return UnknownTokenEndpointAuthUpdateParam(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownTokenEndpointAuthUpdateParam &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownTokenEndpointAuthUpdateParam(rawJson: $rawJson)';
}
