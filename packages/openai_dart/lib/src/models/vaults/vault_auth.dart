part of 'vault_models.dart';

/// Configuration for refreshing the access token of an MCP OAuth credential.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateVaultMcpOauthRefresh extends AgentJsonModel {
  /// Creates a validated [CreateVaultMcpOauthRefresh].
  CreateVaultMcpOauthRefresh({
    required this.clientId,
    required this.refreshToken,
    String? resource,
    bool clearResource = false,
    String? scope,
    bool clearScope = false,
    required this.tokenEndpoint,
    required this.tokenEndpointAuth,
  }) : clearResource = clearResource,
       resource = clearResource ? null : resource,
       clearScope = clearScope,
       scope = clearScope ? null : scope {
    validate();
  }

  /// The OAuth client ID used when requesting a new access token.
  final String clientId;

  /// The refresh token to store. This secret is never returned in credential resources.
  final String refreshToken;

  /// The resource URI to send to the OAuth token endpoint during refresh, if required.
  final String? resource;

  /// Sends `resource: null`, rather than omitting it.
  final bool clearResource;

  /// Space-separated OAuth scopes to request during refresh, if required.
  final String? scope;

  /// Sends `scope: null`, rather than omitting it.
  final bool clearScope;

  /// The HTTPS OAuth token endpoint used to exchange the refresh token for a new access token.
  final String tokenEndpoint;

  /// How the OAuth client authenticates to the token endpoint.
  final CreateVaultTokenEndpointAuth tokenEndpointAuth;

  /// Parses [CreateVaultMcpOauthRefresh] with contextual, payload-free errors.
  factory CreateVaultMcpOauthRefresh.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'client_id',
      'refresh_token',
      'resource',
      'scope',
      'token_endpoint',
      'token_endpoint_auth',
    ], 'CreateVaultMcpOauthRefresh');
    return CreateVaultMcpOauthRefresh(
      clientId: requiredAgentValue(
        json,
        'client_id',
        'CreateVaultMcpOauthRefresh.clientId',
        requireAgentString,
        nullable: false,
      )!,
      refreshToken: requiredAgentValue(
        json,
        'refresh_token',
        'CreateVaultMcpOauthRefresh.refreshToken',
        requireAgentString,
        nullable: false,
      )!,
      resource: optionalAgentValue(
        json,
        'resource',
        'CreateVaultMcpOauthRefresh.resource',
        requireAgentString,
        nullable: true,
      ),
      clearResource: json.containsKey('resource') && json['resource'] == null,
      scope: optionalAgentValue(
        json,
        'scope',
        'CreateVaultMcpOauthRefresh.scope',
        requireAgentString,
        nullable: true,
      ),
      clearScope: json.containsKey('scope') && json['scope'] == null,
      tokenEndpoint: requiredAgentValue(
        json,
        'token_endpoint',
        'CreateVaultMcpOauthRefresh.tokenEndpoint',
        requireAgentString,
        nullable: false,
      )!,
      tokenEndpointAuth: requiredAgentValue(
        json,
        'token_endpoint_auth',
        'CreateVaultMcpOauthRefresh.tokenEndpointAuth',
        (value, context) => CreateVaultTokenEndpointAuth.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      clientId,
      'CreateVaultMcpOauthRefresh.clientId',
      min: 0,
      max: 1048576,
    );
    validateAgentLength(
      refreshToken,
      'CreateVaultMcpOauthRefresh.refreshToken',
      min: 0,
      max: 1048576,
    );
    if (resource != null) {
      validateAgentLength(
        resource!,
        'CreateVaultMcpOauthRefresh.resource',
        min: 0,
        max: 1048576,
      );
    }
    if (scope != null) {
      validateAgentLength(
        scope!,
        'CreateVaultMcpOauthRefresh.scope',
        min: 0,
        max: 1048576,
      );
    }
    validateAgentLength(
      tokenEndpoint,
      'CreateVaultMcpOauthRefresh.tokenEndpoint',
      min: 0,
      max: 1048576,
    );
    tokenEndpointAuth.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    'client_id': clientId,
    'refresh_token': refreshToken,
    if (clearResource) 'resource': null else 'resource': ?resource,
    if (clearScope) 'scope': null else 'scope': ?scope,
    'token_endpoint': tokenEndpoint,
    'token_endpoint_auth': tokenEndpointAuth.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  CreateVaultMcpOauthRefresh copyWith({
    String? clientId,
    String? refreshToken,
    Object? resource = unsetCopyWithValue,
    bool? clearResource,
    Object? scope = unsetCopyWithValue,
    bool? clearScope,
    String? tokenEndpoint,
    CreateVaultTokenEndpointAuth? tokenEndpointAuth,
  }) => CreateVaultMcpOauthRefresh(
    clientId: clientId ?? this.clientId,
    refreshToken: refreshToken ?? this.refreshToken,
    resource: copyAgentValue<String>(
      resource,
      this.resource,
      'CreateVaultMcpOauthRefresh.resource',
    ),
    clearResource:
        clearResource ??
        (identical(resource, unsetCopyWithValue)
            ? this.clearResource
            : resource == null),
    scope: copyAgentValue<String>(
      scope,
      this.scope,
      'CreateVaultMcpOauthRefresh.scope',
    ),
    clearScope:
        clearScope ??
        (identical(scope, unsetCopyWithValue)
            ? this.clearScope
            : scope == null),
    tokenEndpoint: tokenEndpoint ?? this.tokenEndpoint,
    tokenEndpointAuth: tokenEndpointAuth ?? this.tokenEndpointAuth,
  );
}

/// Variants: [CreateVaultTokenEndpointClientSecretBasic], [CreateVaultTokenEndpointClientSecretPost], [CreateVaultTokenEndpointNone].
/// Client authentication credentials for OAuth token refresh.
///
/// Variants: [CreateVaultTokenEndpointClientSecretBasic], [CreateVaultTokenEndpointClientSecretPost], [CreateVaultTokenEndpointNone] and [UnknownCreateVaultTokenEndpointAuth].
sealed class CreateVaultTokenEndpointAuth extends AgentJsonModel {
  const CreateVaultTokenEndpointAuth();

  /// Parses known variants strictly and retains future received variants.
  factory CreateVaultTokenEndpointAuth.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(
        json['type'],
        'CreateVaultTokenEndpointAuth.type',
      )) {
        'client_secret_basic' =>
          CreateVaultTokenEndpointClientSecretBasic.fromJson(json),
        'client_secret_post' =>
          CreateVaultTokenEndpointClientSecretPost.fromJson(json),
        'none' => CreateVaultTokenEndpointNone.fromJson(json),
        _ => UnknownCreateVaultTokenEndpointAuth.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `client_secret_basic` variant.
  factory CreateVaultTokenEndpointAuth.clientSecretBasic({
    required String clientSecret,
  }) = CreateVaultTokenEndpointClientSecretBasic;

  /// Creates the `client_secret_post` variant.
  factory CreateVaultTokenEndpointAuth.clientSecretPost({
    required String clientSecret,
  }) = CreateVaultTokenEndpointClientSecretPost;

  /// Creates the `none` variant.
  factory CreateVaultTokenEndpointAuth.none() = CreateVaultTokenEndpointNone;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownCreateVaultTokenEndpointAuth
    extends CreateVaultTokenEndpointAuth {
  const UnknownCreateVaultTokenEndpointAuth._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownCreateVaultTokenEndpointAuth.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = requireAgentString(
      json['type'],
      'UnknownCreateVaultTokenEndpointAuth.type',
    );
    if (const [
      'client_secret_basic',
      'client_secret_post',
      'none',
    ].contains(type)) {
      throw const FormatException(
        'UnknownCreateVaultTokenEndpointAuth: expected a future type',
      );
    }
    return UnknownCreateVaultTokenEndpointAuth._(
      snapshotAgentJson(json, 'UnknownCreateVaultTokenEndpointAuth'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownCreateVaultTokenEndpointAuth copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownCreateVaultTokenEndpointAuth.fromJson(rawJson ?? this.rawJson);

  @override
  void validate() => throw const FormatException(
    'UnknownCreateVaultTokenEndpointAuth: future credential configuration is not writable',
  );
}

/// Sends the client ID and secret using HTTP Basic authentication.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateVaultTokenEndpointClientSecretBasic
    extends CreateVaultTokenEndpointAuth {
  /// Creates a validated [CreateVaultTokenEndpointClientSecretBasic].
  CreateVaultTokenEndpointClientSecretBasic({required this.clientSecret}) {
    validate();
  }

  /// The OAuth client secret to store. Never returned in credential resources.
  final String clientSecret;

  /// The type of the object. Always `client_secret_basic`.
  @override
  String get type => 'client_secret_basic';

  /// Parses [CreateVaultTokenEndpointClientSecretBasic] with contextual, payload-free errors.
  factory CreateVaultTokenEndpointClientSecretBasic.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'client_secret',
      'type',
    ], 'CreateVaultTokenEndpointClientSecretBasic');
    requireAgentTag(
      json,
      'type',
      'client_secret_basic',
      'CreateVaultTokenEndpointClientSecretBasic',
    );
    return CreateVaultTokenEndpointClientSecretBasic(
      clientSecret: requiredAgentValue(
        json,
        'client_secret',
        'CreateVaultTokenEndpointClientSecretBasic.clientSecret',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      clientSecret,
      'CreateVaultTokenEndpointClientSecretBasic.clientSecret',
      min: 0,
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'client_secret': clientSecret,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  CreateVaultTokenEndpointClientSecretBasic copyWith({String? clientSecret}) =>
      CreateVaultTokenEndpointClientSecretBasic(
        clientSecret: clientSecret ?? this.clientSecret,
      );
}

/// Sends the client ID and secret in the token request body.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateVaultTokenEndpointClientSecretPost
    extends CreateVaultTokenEndpointAuth {
  /// Creates a validated [CreateVaultTokenEndpointClientSecretPost].
  CreateVaultTokenEndpointClientSecretPost({required this.clientSecret}) {
    validate();
  }

  /// The OAuth client secret to store. Never returned in credential resources.
  final String clientSecret;

  /// The type of the object. Always `client_secret_post`.
  @override
  String get type => 'client_secret_post';

  /// Parses [CreateVaultTokenEndpointClientSecretPost] with contextual, payload-free errors.
  factory CreateVaultTokenEndpointClientSecretPost.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'client_secret',
      'type',
    ], 'CreateVaultTokenEndpointClientSecretPost');
    requireAgentTag(
      json,
      'type',
      'client_secret_post',
      'CreateVaultTokenEndpointClientSecretPost',
    );
    return CreateVaultTokenEndpointClientSecretPost(
      clientSecret: requiredAgentValue(
        json,
        'client_secret',
        'CreateVaultTokenEndpointClientSecretPost.clientSecret',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      clientSecret,
      'CreateVaultTokenEndpointClientSecretPost.clientSecret',
      min: 0,
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'client_secret': clientSecret,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  CreateVaultTokenEndpointClientSecretPost copyWith({String? clientSecret}) =>
      CreateVaultTokenEndpointClientSecretPost(
        clientSecret: clientSecret ?? this.clientSecret,
      );
}

/// Sends the client ID without a client secret.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateVaultTokenEndpointNone extends CreateVaultTokenEndpointAuth {
  /// Creates a validated [CreateVaultTokenEndpointNone].
  CreateVaultTokenEndpointNone() {
    validate();
  }

  /// The type of the object. Always `none`.
  @override
  String get type => 'none';

  /// Parses [CreateVaultTokenEndpointNone] with contextual, payload-free errors.
  factory CreateVaultTokenEndpointNone.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'type',
    ], 'CreateVaultTokenEndpointNone');
    requireAgentTag(json, 'type', 'none', 'CreateVaultTokenEndpointNone');
    return CreateVaultTokenEndpointNone();
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  CreateVaultTokenEndpointNone copyWith() => CreateVaultTokenEndpointNone();
}

/// Variants: [CreateVaultEnvironmentVariableAuth], [CreateVaultMcpOauthAuth], [CreateVaultStaticBearerAuth].
/// Authentication credentials for an MCP server or an OpenAI-hosted environment.
///
/// Variants: [CreateVaultEnvironmentVariableAuth], [CreateVaultMcpOauthAuth], [CreateVaultStaticBearerAuth] and [UnknownCreateVaultCredentialAuth].
sealed class CreateVaultCredentialAuth extends AgentJsonModel {
  const CreateVaultCredentialAuth();

  /// Parses known variants strictly and retains future received variants.
  factory CreateVaultCredentialAuth.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(
        json['type'],
        'CreateVaultCredentialAuth.type',
      )) {
        'environment_variable' => CreateVaultEnvironmentVariableAuth.fromJson(
          json,
        ),
        'mcp_oauth' => CreateVaultMcpOauthAuth.fromJson(json),
        'static_bearer' => CreateVaultStaticBearerAuth.fromJson(json),
        _ => UnknownCreateVaultCredentialAuth.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `environment_variable` variant.
  factory CreateVaultCredentialAuth.environmentVariable({
    required VaultCredentialNetworking networking,
    required String secretName,
    required String secretValue,
  }) = CreateVaultEnvironmentVariableAuth;

  /// Creates the `mcp_oauth` variant.
  factory CreateVaultCredentialAuth.mcpOauth({
    required String accessToken,
    String? expiresAt,
    bool clearExpiresAt,
    required String mcpServerUrl,
    CreateVaultMcpOauthRefresh? refresh,
    bool clearRefresh,
  }) = CreateVaultMcpOauthAuth;

  /// Creates the `static_bearer` variant.
  factory CreateVaultCredentialAuth.staticBearer({
    required String mcpServerUrl,
    required String token,
  }) = CreateVaultStaticBearerAuth;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownCreateVaultCredentialAuth extends CreateVaultCredentialAuth {
  const UnknownCreateVaultCredentialAuth._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownCreateVaultCredentialAuth.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownCreateVaultCredentialAuth.type',
    );
    if (const [
      'environment_variable',
      'mcp_oauth',
      'static_bearer',
    ].contains(type)) {
      throw const FormatException(
        'UnknownCreateVaultCredentialAuth: expected a future type',
      );
    }
    return UnknownCreateVaultCredentialAuth._(
      snapshotAgentJson(json, 'UnknownCreateVaultCredentialAuth'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownCreateVaultCredentialAuth copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownCreateVaultCredentialAuth.fromJson(rawJson ?? this.rawJson);

  @override
  void validate() => throw const FormatException(
    'UnknownCreateVaultCredentialAuth: future credential configuration is not writable',
  );
}

/// An HTTP credential for OpenAI-hosted environments only. The sandbox receives an environment variable containing a placeholder, not the secret. Use the placeholder unchanged in outgoing requests. The egress proxy replaces the placeholder with the secret for allowed HTTPS destinations on ports 443 and 8443. Sandbox code cannot read the real secret or use it for local computation, such as signing a request.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateVaultEnvironmentVariableAuth
    extends CreateVaultCredentialAuth {
  /// Creates a validated [CreateVaultEnvironmentVariableAuth].
  CreateVaultEnvironmentVariableAuth({
    required this.networking,
    required this.secretName,
    required this.secretValue,
  }) {
    validate();
  }

  /// The destinations where the proxy can substitute this secret. The environment network policy must also allow them.
  final VaultCredentialNetworking networking;

  /// The environment variable name that receives the placeholder, such as `SERVICE_API_KEY`. Use ASCII letters, digits, and underscores, starting with a letter or underscore. Names starting with `CODEX_` and managed proxy or certificate variable names are reserved.
  final String secretName;

  /// The write-only secret to store. Never returned in credential resources or supplied directly to sandbox code. Must be nonempty and must not contain carriage returns, newlines, or NUL bytes.
  final String secretValue;

  /// The type of the object. Always `environment_variable`.
  @override
  String get type => 'environment_variable';

  /// Parses [CreateVaultEnvironmentVariableAuth] with contextual, payload-free errors.
  factory CreateVaultEnvironmentVariableAuth.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'networking',
      'secret_name',
      'secret_value',
      'type',
    ], 'CreateVaultEnvironmentVariableAuth');
    requireAgentTag(
      json,
      'type',
      'environment_variable',
      'CreateVaultEnvironmentVariableAuth',
    );
    return CreateVaultEnvironmentVariableAuth(
      networking: requiredAgentValue(
        json,
        'networking',
        'CreateVaultEnvironmentVariableAuth.networking',
        (value, context) => VaultCredentialNetworking.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      secretName: requiredAgentValue(
        json,
        'secret_name',
        'CreateVaultEnvironmentVariableAuth.secretName',
        requireAgentString,
        nullable: false,
      )!,
      secretValue: requiredAgentValue(
        json,
        'secret_value',
        'CreateVaultEnvironmentVariableAuth.secretValue',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    _validateVaultSecretName(
      secretName,
      'CreateVaultEnvironmentVariableAuth.secretName',
    );
    _validateVaultSecretValue(
      secretValue,
      'CreateVaultEnvironmentVariableAuth.secretValue',
    );
    networking.validate();
    validateAgentLength(
      secretName,
      'CreateVaultEnvironmentVariableAuth.secretName',
      min: 1,
      max: 1048576,
    );
    validateAgentLength(
      secretValue,
      'CreateVaultEnvironmentVariableAuth.secretValue',
      min: 1,
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'networking': networking.toJson(),
    'secret_name': secretName,
    'secret_value': secretValue,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  CreateVaultEnvironmentVariableAuth copyWith({
    VaultCredentialNetworking? networking,
    String? secretName,
    String? secretValue,
  }) => CreateVaultEnvironmentVariableAuth(
    networking: networking ?? this.networking,
    secretName: secretName ?? this.secretName,
    secretValue: secretValue ?? this.secretValue,
  );
}

/// An OAuth credential for an HTTPS MCP destination.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateVaultMcpOauthAuth extends CreateVaultCredentialAuth {
  /// Creates a validated [CreateVaultMcpOauthAuth].
  CreateVaultMcpOauthAuth({
    required this.accessToken,
    String? expiresAt,
    bool clearExpiresAt = false,
    required this.mcpServerUrl,
    CreateVaultMcpOauthRefresh? refresh,
    bool clearRefresh = false,
  }) : clearExpiresAt = clearExpiresAt,
       expiresAt = clearExpiresAt ? null : expiresAt,
       clearRefresh = clearRefresh,
       refresh = clearRefresh ? null : refresh {
    validate();
  }

  /// A write-only OAuth access token; never returned by credential resources.
  final String accessToken;

  /// When the OAuth access token expires, as an RFC 3339 timestamp, if known.
  final String? expiresAt;

  /// Sends `expires_at: null`, rather than omitting it.
  final bool clearExpiresAt;

  /// The HTTPS MCP server URL authorized by this credential.
  final String mcpServerUrl;

  /// Optional refresh configuration for an HTTPS OAuth token endpoint.
  final CreateVaultMcpOauthRefresh? refresh;

  /// Sends `refresh: null`, rather than omitting it.
  final bool clearRefresh;

  /// The type of the object. Always `mcp_oauth`.
  @override
  String get type => 'mcp_oauth';

  /// Parses [CreateVaultMcpOauthAuth] with contextual, payload-free errors.
  factory CreateVaultMcpOauthAuth.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'access_token',
      'expires_at',
      'mcp_server_url',
      'refresh',
      'type',
    ], 'CreateVaultMcpOauthAuth');
    requireAgentTag(json, 'type', 'mcp_oauth', 'CreateVaultMcpOauthAuth');
    return CreateVaultMcpOauthAuth(
      accessToken: requiredAgentValue(
        json,
        'access_token',
        'CreateVaultMcpOauthAuth.accessToken',
        requireAgentString,
        nullable: false,
      )!,
      expiresAt: optionalAgentValue(
        json,
        'expires_at',
        'CreateVaultMcpOauthAuth.expiresAt',
        requireAgentString,
        nullable: true,
      ),
      clearExpiresAt:
          json.containsKey('expires_at') && json['expires_at'] == null,
      mcpServerUrl: requiredAgentValue(
        json,
        'mcp_server_url',
        'CreateVaultMcpOauthAuth.mcpServerUrl',
        requireAgentString,
        nullable: false,
      )!,
      refresh: optionalAgentValue(
        json,
        'refresh',
        'CreateVaultMcpOauthAuth.refresh',
        (value, context) => CreateVaultMcpOauthRefresh.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearRefresh: json.containsKey('refresh') && json['refresh'] == null,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      accessToken,
      'CreateVaultMcpOauthAuth.accessToken',
      min: 0,
      max: 1048576,
    );
    if (expiresAt != null) {
      validateAgentLength(
        expiresAt!,
        'CreateVaultMcpOauthAuth.expiresAt',
        min: 0,
        max: 1048576,
      );
    }
    validateAgentLength(
      mcpServerUrl,
      'CreateVaultMcpOauthAuth.mcpServerUrl',
      min: 0,
      max: 1048576,
    );
    if (refresh != null) {
      refresh!.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    if (clearExpiresAt) 'expires_at': null else 'expires_at': ?expiresAt,
    'mcp_server_url': mcpServerUrl,
    if (clearRefresh)
      'refresh': null
    else if (refresh != null)
      'refresh': refresh!.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  CreateVaultMcpOauthAuth copyWith({
    String? accessToken,
    Object? expiresAt = unsetCopyWithValue,
    bool? clearExpiresAt,
    String? mcpServerUrl,
    Object? refresh = unsetCopyWithValue,
    bool? clearRefresh,
  }) => CreateVaultMcpOauthAuth(
    accessToken: accessToken ?? this.accessToken,
    expiresAt: copyAgentValue<String>(
      expiresAt,
      this.expiresAt,
      'CreateVaultMcpOauthAuth.expiresAt',
    ),
    clearExpiresAt:
        clearExpiresAt ??
        (identical(expiresAt, unsetCopyWithValue)
            ? this.clearExpiresAt
            : expiresAt == null),
    mcpServerUrl: mcpServerUrl ?? this.mcpServerUrl,
    refresh: copyAgentValue<CreateVaultMcpOauthRefresh>(
      refresh,
      this.refresh,
      'CreateVaultMcpOauthAuth.refresh',
    ),
    clearRefresh:
        clearRefresh ??
        (identical(refresh, unsetCopyWithValue)
            ? this.clearRefresh
            : refresh == null),
  );
}

/// A bearer token for an MCP server, without automatic OAuth refresh.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateVaultStaticBearerAuth extends CreateVaultCredentialAuth {
  /// Creates a validated [CreateVaultStaticBearerAuth].
  CreateVaultStaticBearerAuth({
    required this.mcpServerUrl,
    required this.token,
  }) {
    validate();
  }

  /// The HTTPS MCP server URL authorized by this credential.
  final String mcpServerUrl;

  /// The bearer token to store. This secret is never returned in credential resources.
  final String token;

  /// The type of the object. Always `static_bearer`.
  @override
  String get type => 'static_bearer';

  /// Parses [CreateVaultStaticBearerAuth] with contextual, payload-free errors.
  factory CreateVaultStaticBearerAuth.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'mcp_server_url',
      'token',
      'type',
    ], 'CreateVaultStaticBearerAuth');
    requireAgentTag(
      json,
      'type',
      'static_bearer',
      'CreateVaultStaticBearerAuth',
    );
    return CreateVaultStaticBearerAuth(
      mcpServerUrl: requiredAgentValue(
        json,
        'mcp_server_url',
        'CreateVaultStaticBearerAuth.mcpServerUrl',
        requireAgentString,
        nullable: false,
      )!,
      token: requiredAgentValue(
        json,
        'token',
        'CreateVaultStaticBearerAuth.token',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      mcpServerUrl,
      'CreateVaultStaticBearerAuth.mcpServerUrl',
      min: 0,
      max: 1048576,
    );
    validateAgentLength(
      token,
      'CreateVaultStaticBearerAuth.token',
      min: 0,
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'mcp_server_url': mcpServerUrl,
    'token': token,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  CreateVaultStaticBearerAuth copyWith({String? mcpServerUrl, String? token}) =>
      CreateVaultStaticBearerAuth(
        mcpServerUrl: mcpServerUrl ?? this.mcpServerUrl,
        token: token ?? this.token,
      );
}

/// Configuration used to refresh an MCP OAuth access token, excluding secret values.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class VaultMcpOauthRefresh extends AgentJsonModel {
  /// Creates a validated [VaultMcpOauthRefresh].
  VaultMcpOauthRefresh({
    required this.clientId,
    required this.resource,
    required this.scope,
    required this.tokenEndpoint,
    required this.tokenEndpointAuth,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _vaultReceivedExtras(rawJson, const [
         'client_id',
         'resource',
         'scope',
         'token_endpoint',
         'token_endpoint_auth',
       ], 'VaultMcpOauthRefresh') {
    validate();
  }

  /// The OAuth client ID used when requesting a new access token.
  final String clientId;

  /// The resource URI sent to the OAuth token endpoint during refresh, if configured.
  final String? resource;

  /// Space-separated OAuth scopes requested during refresh, if configured.
  final String? scope;

  /// The HTTPS OAuth token endpoint used for refresh.
  final String tokenEndpoint;

  /// How the OAuth client authenticates to the token endpoint, excluding its client secret.
  final VaultTokenEndpointAuth tokenEndpointAuth;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [VaultMcpOauthRefresh] with contextual, payload-free errors.
  factory VaultMcpOauthRefresh.fromJson(Map<String, dynamic> json) {
    return VaultMcpOauthRefresh(
      clientId: requiredAgentValue(
        json,
        'client_id',
        'VaultMcpOauthRefresh.clientId',
        requireAgentString,
        nullable: false,
      )!,
      resource: requiredAgentValue(
        json,
        'resource',
        'VaultMcpOauthRefresh.resource',
        requireAgentString,
        nullable: true,
      ),
      scope: requiredAgentValue(
        json,
        'scope',
        'VaultMcpOauthRefresh.scope',
        requireAgentString,
        nullable: true,
      ),
      tokenEndpoint: requiredAgentValue(
        json,
        'token_endpoint',
        'VaultMcpOauthRefresh.tokenEndpoint',
        requireAgentString,
        nullable: false,
      )!,
      tokenEndpointAuth: requiredAgentValue(
        json,
        'token_endpoint_auth',
        'VaultMcpOauthRefresh.tokenEndpointAuth',
        (value, context) =>
            VaultTokenEndpointAuth.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'client_id',
            'resource',
            'scope',
            'token_endpoint',
            'token_endpoint_auth',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(clientId, 'VaultMcpOauthRefresh.clientId', min: 0);
    if (resource != null) {
      validateAgentLength(resource!, 'VaultMcpOauthRefresh.resource', min: 0);
    }
    if (scope != null) {
      validateAgentLength(scope!, 'VaultMcpOauthRefresh.scope', min: 0);
    }
    validateAgentLength(
      tokenEndpoint,
      'VaultMcpOauthRefresh.tokenEndpoint',
      min: 0,
    );
    tokenEndpointAuth.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'client_id': clientId,
    'resource': resource,
    'scope': scope,
    'token_endpoint': tokenEndpoint,
    'token_endpoint_auth': tokenEndpointAuth.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  VaultMcpOauthRefresh copyWith({
    String? clientId,
    Object? resource = unsetCopyWithValue,
    Object? scope = unsetCopyWithValue,
    String? tokenEndpoint,
    VaultTokenEndpointAuth? tokenEndpointAuth,
    Map<String, dynamic>? rawJson,
  }) => VaultMcpOauthRefresh(
    clientId: clientId ?? this.clientId,
    resource: copyAgentValue<String>(
      resource,
      this.resource,
      'VaultMcpOauthRefresh.resource',
    ),
    scope: copyAgentValue<String>(
      scope,
      this.scope,
      'VaultMcpOauthRefresh.scope',
    ),
    tokenEndpoint: tokenEndpoint ?? this.tokenEndpoint,
    tokenEndpointAuth: tokenEndpointAuth ?? this.tokenEndpointAuth,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Variants: [VaultTokenEndpointClientSecretBasic], [VaultTokenEndpointClientSecretPost], [VaultTokenEndpointNone].
/// The client authentication method used for OAuth token refresh.
///
/// Variants: [VaultTokenEndpointClientSecretBasic], [VaultTokenEndpointClientSecretPost], [VaultTokenEndpointNone] and [UnknownVaultTokenEndpointAuth].
sealed class VaultTokenEndpointAuth extends AgentJsonModel {
  const VaultTokenEndpointAuth();

  /// Parses known variants strictly and retains future received variants.
  factory VaultTokenEndpointAuth.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(json['type'], 'VaultTokenEndpointAuth.type')) {
        'client_secret_basic' => VaultTokenEndpointClientSecretBasic.fromJson(
          json,
        ),
        'client_secret_post' => VaultTokenEndpointClientSecretPost.fromJson(
          json,
        ),
        'none' => VaultTokenEndpointNone.fromJson(json),
        _ => UnknownVaultTokenEndpointAuth.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `client_secret_basic` variant.
  factory VaultTokenEndpointAuth.clientSecretBasic({
    Map<String, dynamic> rawJson,
  }) = VaultTokenEndpointClientSecretBasic;

  /// Creates the `client_secret_post` variant.
  factory VaultTokenEndpointAuth.clientSecretPost({
    Map<String, dynamic> rawJson,
  }) = VaultTokenEndpointClientSecretPost;

  /// Creates the `none` variant.
  factory VaultTokenEndpointAuth.none({Map<String, dynamic> rawJson}) =
      VaultTokenEndpointNone;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownVaultTokenEndpointAuth extends VaultTokenEndpointAuth {
  const UnknownVaultTokenEndpointAuth._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownVaultTokenEndpointAuth.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownVaultTokenEndpointAuth.type',
    );
    if (const [
      'client_secret_basic',
      'client_secret_post',
      'none',
    ].contains(type)) {
      throw const FormatException(
        'UnknownVaultTokenEndpointAuth: expected a future type',
      );
    }
    _rejectVaultReadbackKeys(json, 'UnknownVaultTokenEndpointAuth');
    return UnknownVaultTokenEndpointAuth._(
      snapshotAgentJson(json, 'UnknownVaultTokenEndpointAuth'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownVaultTokenEndpointAuth copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownVaultTokenEndpointAuth.fromJson(rawJson ?? this.rawJson);
}

/// Sends the client ID and secret using HTTP Basic authentication.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class VaultTokenEndpointClientSecretBasic extends VaultTokenEndpointAuth {
  /// Creates a validated [VaultTokenEndpointClientSecretBasic].
  VaultTokenEndpointClientSecretBasic({Map<String, dynamic> rawJson = const {}})
    : rawJson = _vaultReceivedExtras(rawJson, const [
        'type',
      ], 'VaultTokenEndpointClientSecretBasic') {
    validate();
  }

  /// The type of the object. Always `client_secret_basic`.
  @override
  String get type => 'client_secret_basic';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [VaultTokenEndpointClientSecretBasic] with contextual, payload-free errors.
  factory VaultTokenEndpointClientSecretBasic.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'client_secret_basic',
      'VaultTokenEndpointClientSecretBasic',
    );
    return VaultTokenEndpointClientSecretBasic(
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type'].contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  VaultTokenEndpointClientSecretBasic copyWith({
    Map<String, dynamic>? rawJson,
  }) => VaultTokenEndpointClientSecretBasic(rawJson: rawJson ?? this.rawJson);
}

/// Sends the client ID and secret in the token request body.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class VaultTokenEndpointClientSecretPost extends VaultTokenEndpointAuth {
  /// Creates a validated [VaultTokenEndpointClientSecretPost].
  VaultTokenEndpointClientSecretPost({Map<String, dynamic> rawJson = const {}})
    : rawJson = _vaultReceivedExtras(rawJson, const [
        'type',
      ], 'VaultTokenEndpointClientSecretPost') {
    validate();
  }

  /// The type of the object. Always `client_secret_post`.
  @override
  String get type => 'client_secret_post';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [VaultTokenEndpointClientSecretPost] with contextual, payload-free errors.
  factory VaultTokenEndpointClientSecretPost.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'client_secret_post',
      'VaultTokenEndpointClientSecretPost',
    );
    return VaultTokenEndpointClientSecretPost(
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type'].contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  VaultTokenEndpointClientSecretPost copyWith({
    Map<String, dynamic>? rawJson,
  }) => VaultTokenEndpointClientSecretPost(rawJson: rawJson ?? this.rawJson);
}

/// Sends the client ID without a client secret.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class VaultTokenEndpointNone extends VaultTokenEndpointAuth {
  /// Creates a validated [VaultTokenEndpointNone].
  VaultTokenEndpointNone({Map<String, dynamic> rawJson = const {}})
    : rawJson = _vaultReceivedExtras(rawJson, const [
        'type',
      ], 'VaultTokenEndpointNone') {
    validate();
  }

  /// The type of the object. Always `none`.
  @override
  String get type => 'none';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [VaultTokenEndpointNone] with contextual, payload-free errors.
  factory VaultTokenEndpointNone.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'none', 'VaultTokenEndpointNone');
    return VaultTokenEndpointNone(
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type'].contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  VaultTokenEndpointNone copyWith({Map<String, dynamic>? rawJson}) =>
      VaultTokenEndpointNone(rawJson: rawJson ?? this.rawJson);
}

/// Updates to an MCP credential's existing OAuth refresh configuration.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class RotateVaultMcpOauthRefresh extends AgentJsonModel {
  /// Creates a validated [RotateVaultMcpOauthRefresh].
  RotateVaultMcpOauthRefresh({
    String? refreshToken,
    bool clearRefreshToken = false,
    String? scope,
    bool clearScope = false,
    RotateVaultTokenEndpointAuth? tokenEndpointAuth,
    bool clearTokenEndpointAuth = false,
  }) : clearRefreshToken = clearRefreshToken,
       refreshToken = clearRefreshToken ? null : refreshToken,
       clearScope = clearScope,
       scope = clearScope ? null : scope,
       clearTokenEndpointAuth = clearTokenEndpointAuth,
       tokenEndpointAuth = clearTokenEndpointAuth ? null : tokenEndpointAuth {
    validate();
  }

  /// The replacement refresh token. Omit or pass `null` to keep the stored token. This secret is never returned in resources.
  final String? refreshToken;

  /// Sends `refresh_token: null`, rather than omitting it.
  final bool clearRefreshToken;

  /// Replacement space-separated OAuth scopes for refresh requests. Omit to keep the scopes, or pass `null` to stop sending a scope parameter.
  final String? scope;

  /// Sends `scope: null`, rather than omitting it.
  final bool clearScope;

  /// Client-secret updates for the existing token endpoint authentication method.
  final RotateVaultTokenEndpointAuth? tokenEndpointAuth;

  /// Sends `token_endpoint_auth: null`, rather than omitting it.
  final bool clearTokenEndpointAuth;

  /// Parses [RotateVaultMcpOauthRefresh] with contextual, payload-free errors.
  factory RotateVaultMcpOauthRefresh.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'refresh_token',
      'scope',
      'token_endpoint_auth',
    ], 'RotateVaultMcpOauthRefresh');
    return RotateVaultMcpOauthRefresh(
      refreshToken: optionalAgentValue(
        json,
        'refresh_token',
        'RotateVaultMcpOauthRefresh.refreshToken',
        requireAgentString,
        nullable: true,
      ),
      clearRefreshToken:
          json.containsKey('refresh_token') && json['refresh_token'] == null,
      scope: optionalAgentValue(
        json,
        'scope',
        'RotateVaultMcpOauthRefresh.scope',
        requireAgentString,
        nullable: true,
      ),
      clearScope: json.containsKey('scope') && json['scope'] == null,
      tokenEndpointAuth: optionalAgentValue(
        json,
        'token_endpoint_auth',
        'RotateVaultMcpOauthRefresh.tokenEndpointAuth',
        (value, context) => RotateVaultTokenEndpointAuth.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearTokenEndpointAuth:
          json.containsKey('token_endpoint_auth') &&
          json['token_endpoint_auth'] == null,
    );
  }
  @override
  void validate() {
    if (refreshToken != null) {
      validateAgentLength(
        refreshToken!,
        'RotateVaultMcpOauthRefresh.refreshToken',
        min: 0,
        max: 1048576,
      );
    }
    if (scope != null) {
      validateAgentLength(
        scope!,
        'RotateVaultMcpOauthRefresh.scope',
        min: 0,
        max: 1048576,
      );
    }
    if (tokenEndpointAuth != null) {
      tokenEndpointAuth!.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearRefreshToken)
      'refresh_token': null
    else
      'refresh_token': ?refreshToken,
    if (clearScope) 'scope': null else 'scope': ?scope,
    if (clearTokenEndpointAuth)
      'token_endpoint_auth': null
    else if (tokenEndpointAuth != null)
      'token_endpoint_auth': tokenEndpointAuth!.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  RotateVaultMcpOauthRefresh copyWith({
    Object? refreshToken = unsetCopyWithValue,
    bool? clearRefreshToken,
    Object? scope = unsetCopyWithValue,
    bool? clearScope,
    Object? tokenEndpointAuth = unsetCopyWithValue,
    bool? clearTokenEndpointAuth,
  }) => RotateVaultMcpOauthRefresh(
    refreshToken: copyAgentValue<String>(
      refreshToken,
      this.refreshToken,
      'RotateVaultMcpOauthRefresh.refreshToken',
    ),
    clearRefreshToken:
        clearRefreshToken ??
        (identical(refreshToken, unsetCopyWithValue)
            ? this.clearRefreshToken
            : refreshToken == null),
    scope: copyAgentValue<String>(
      scope,
      this.scope,
      'RotateVaultMcpOauthRefresh.scope',
    ),
    clearScope:
        clearScope ??
        (identical(scope, unsetCopyWithValue)
            ? this.clearScope
            : scope == null),
    tokenEndpointAuth: copyAgentValue<RotateVaultTokenEndpointAuth>(
      tokenEndpointAuth,
      this.tokenEndpointAuth,
      'RotateVaultMcpOauthRefresh.tokenEndpointAuth',
    ),
    clearTokenEndpointAuth:
        clearTokenEndpointAuth ??
        (identical(tokenEndpointAuth, unsetCopyWithValue)
            ? this.clearTokenEndpointAuth
            : tokenEndpointAuth == null),
  );
}

/// Variants: [RotateVaultTokenEndpointClientSecretBasic], [RotateVaultTokenEndpointClientSecretPost].
/// Client-secret updates that preserve the credential's OAuth authentication method.
///
/// Variants: [RotateVaultTokenEndpointClientSecretBasic], [RotateVaultTokenEndpointClientSecretPost] and [UnknownRotateVaultTokenEndpointAuth].
sealed class RotateVaultTokenEndpointAuth extends AgentJsonModel {
  const RotateVaultTokenEndpointAuth();

  /// Parses known variants strictly and retains future received variants.
  factory RotateVaultTokenEndpointAuth.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(
        json['type'],
        'RotateVaultTokenEndpointAuth.type',
      )) {
        'client_secret_basic' =>
          RotateVaultTokenEndpointClientSecretBasic.fromJson(json),
        'client_secret_post' =>
          RotateVaultTokenEndpointClientSecretPost.fromJson(json),
        _ => UnknownRotateVaultTokenEndpointAuth.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `client_secret_basic` variant.
  factory RotateVaultTokenEndpointAuth.clientSecretBasic({
    String? clientSecret,
    bool clearClientSecret,
  }) = RotateVaultTokenEndpointClientSecretBasic;

  /// Creates the `client_secret_post` variant.
  factory RotateVaultTokenEndpointAuth.clientSecretPost({
    String? clientSecret,
    bool clearClientSecret,
  }) = RotateVaultTokenEndpointClientSecretPost;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownRotateVaultTokenEndpointAuth
    extends RotateVaultTokenEndpointAuth {
  const UnknownRotateVaultTokenEndpointAuth._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownRotateVaultTokenEndpointAuth.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = requireAgentString(
      json['type'],
      'UnknownRotateVaultTokenEndpointAuth.type',
    );
    if (const ['client_secret_basic', 'client_secret_post'].contains(type)) {
      throw const FormatException(
        'UnknownRotateVaultTokenEndpointAuth: expected a future type',
      );
    }
    return UnknownRotateVaultTokenEndpointAuth._(
      snapshotAgentJson(json, 'UnknownRotateVaultTokenEndpointAuth'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownRotateVaultTokenEndpointAuth copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownRotateVaultTokenEndpointAuth.fromJson(rawJson ?? this.rawJson);

  @override
  void validate() => throw const FormatException(
    'UnknownRotateVaultTokenEndpointAuth: future credential configuration is not writable',
  );
}

/// Updates credentials sent using HTTP Basic authentication.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class RotateVaultTokenEndpointClientSecretBasic
    extends RotateVaultTokenEndpointAuth {
  /// Creates a validated [RotateVaultTokenEndpointClientSecretBasic].
  RotateVaultTokenEndpointClientSecretBasic({
    String? clientSecret,
    bool clearClientSecret = false,
  }) : clearClientSecret = clearClientSecret,
       clientSecret = clearClientSecret ? null : clientSecret {
    validate();
  }

  /// The replacement OAuth client secret. Omit or pass `null` to keep the stored secret. This secret is never returned in resources.
  final String? clientSecret;

  /// Sends `client_secret: null`, rather than omitting it.
  final bool clearClientSecret;

  /// The type of the object. Always `client_secret_basic`.
  @override
  String get type => 'client_secret_basic';

  /// Parses [RotateVaultTokenEndpointClientSecretBasic] with contextual, payload-free errors.
  factory RotateVaultTokenEndpointClientSecretBasic.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'client_secret',
      'type',
    ], 'RotateVaultTokenEndpointClientSecretBasic');
    requireAgentTag(
      json,
      'type',
      'client_secret_basic',
      'RotateVaultTokenEndpointClientSecretBasic',
    );
    return RotateVaultTokenEndpointClientSecretBasic(
      clientSecret: optionalAgentValue(
        json,
        'client_secret',
        'RotateVaultTokenEndpointClientSecretBasic.clientSecret',
        requireAgentString,
        nullable: true,
      ),
      clearClientSecret:
          json.containsKey('client_secret') && json['client_secret'] == null,
    );
  }
  @override
  void validate() {
    if (clientSecret != null) {
      validateAgentLength(
        clientSecret!,
        'RotateVaultTokenEndpointClientSecretBasic.clientSecret',
        min: 0,
        max: 1048576,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearClientSecret)
      'client_secret': null
    else
      'client_secret': ?clientSecret,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  RotateVaultTokenEndpointClientSecretBasic copyWith({
    Object? clientSecret = unsetCopyWithValue,
    bool? clearClientSecret,
  }) => RotateVaultTokenEndpointClientSecretBasic(
    clientSecret: copyAgentValue<String>(
      clientSecret,
      this.clientSecret,
      'RotateVaultTokenEndpointClientSecretBasic.clientSecret',
    ),
    clearClientSecret:
        clearClientSecret ??
        (identical(clientSecret, unsetCopyWithValue)
            ? this.clearClientSecret
            : clientSecret == null),
  );
}

/// Updates credentials sent in the token request body.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class RotateVaultTokenEndpointClientSecretPost
    extends RotateVaultTokenEndpointAuth {
  /// Creates a validated [RotateVaultTokenEndpointClientSecretPost].
  RotateVaultTokenEndpointClientSecretPost({
    String? clientSecret,
    bool clearClientSecret = false,
  }) : clearClientSecret = clearClientSecret,
       clientSecret = clearClientSecret ? null : clientSecret {
    validate();
  }

  /// The replacement OAuth client secret. Omit or pass `null` to keep the stored secret. This secret is never returned in resources.
  final String? clientSecret;

  /// Sends `client_secret: null`, rather than omitting it.
  final bool clearClientSecret;

  /// The type of the object. Always `client_secret_post`.
  @override
  String get type => 'client_secret_post';

  /// Parses [RotateVaultTokenEndpointClientSecretPost] with contextual, payload-free errors.
  factory RotateVaultTokenEndpointClientSecretPost.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'client_secret',
      'type',
    ], 'RotateVaultTokenEndpointClientSecretPost');
    requireAgentTag(
      json,
      'type',
      'client_secret_post',
      'RotateVaultTokenEndpointClientSecretPost',
    );
    return RotateVaultTokenEndpointClientSecretPost(
      clientSecret: optionalAgentValue(
        json,
        'client_secret',
        'RotateVaultTokenEndpointClientSecretPost.clientSecret',
        requireAgentString,
        nullable: true,
      ),
      clearClientSecret:
          json.containsKey('client_secret') && json['client_secret'] == null,
    );
  }
  @override
  void validate() {
    if (clientSecret != null) {
      validateAgentLength(
        clientSecret!,
        'RotateVaultTokenEndpointClientSecretPost.clientSecret',
        min: 0,
        max: 1048576,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearClientSecret)
      'client_secret': null
    else
      'client_secret': ?clientSecret,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  RotateVaultTokenEndpointClientSecretPost copyWith({
    Object? clientSecret = unsetCopyWithValue,
    bool? clearClientSecret,
  }) => RotateVaultTokenEndpointClientSecretPost(
    clientSecret: copyAgentValue<String>(
      clientSecret,
      this.clientSecret,
      'RotateVaultTokenEndpointClientSecretPost.clientSecret',
    ),
    clearClientSecret:
        clearClientSecret ??
        (identical(clientSecret, unsetCopyWithValue)
            ? this.clearClientSecret
            : clientSecret == null),
  );
}

/// Variants: [RotateVaultEnvironmentVariableAuth], [RotateVaultMcpOauthAuth], [RotateVaultStaticBearerAuth].
/// Updates to a vault credential without changing its authentication method or destination configuration.
///
/// Variants: [RotateVaultEnvironmentVariableAuth], [RotateVaultMcpOauthAuth], [RotateVaultStaticBearerAuth] and [UnknownRotateVaultCredentialAuth].
sealed class RotateVaultCredentialAuth extends AgentJsonModel {
  const RotateVaultCredentialAuth();

  /// Parses known variants strictly and retains future received variants.
  factory RotateVaultCredentialAuth.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(
        json['type'],
        'RotateVaultCredentialAuth.type',
      )) {
        'environment_variable' => RotateVaultEnvironmentVariableAuth.fromJson(
          json,
        ),
        'mcp_oauth' => RotateVaultMcpOauthAuth.fromJson(json),
        'static_bearer' => RotateVaultStaticBearerAuth.fromJson(json),
        _ => UnknownRotateVaultCredentialAuth.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `environment_variable` variant.
  factory RotateVaultCredentialAuth.environmentVariable({
    required String secretValue,
  }) = RotateVaultEnvironmentVariableAuth;

  /// Creates the `mcp_oauth` variant.
  factory RotateVaultCredentialAuth.mcpOauth({
    String? accessToken,
    bool clearAccessToken,
    String? expiresAt,
    bool clearExpiresAt,
    RotateVaultMcpOauthRefresh? refresh,
    bool clearRefresh,
  }) = RotateVaultMcpOauthAuth;

  /// Creates the `static_bearer` variant.
  factory RotateVaultCredentialAuth.staticBearer({required String token}) =
      RotateVaultStaticBearerAuth;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownRotateVaultCredentialAuth extends RotateVaultCredentialAuth {
  const UnknownRotateVaultCredentialAuth._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownRotateVaultCredentialAuth.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownRotateVaultCredentialAuth.type',
    );
    if (const [
      'environment_variable',
      'mcp_oauth',
      'static_bearer',
    ].contains(type)) {
      throw const FormatException(
        'UnknownRotateVaultCredentialAuth: expected a future type',
      );
    }
    return UnknownRotateVaultCredentialAuth._(
      snapshotAgentJson(json, 'UnknownRotateVaultCredentialAuth'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownRotateVaultCredentialAuth copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownRotateVaultCredentialAuth.fromJson(rawJson ?? this.rawJson);

  @override
  void validate() => throw const FormatException(
    'UnknownRotateVaultCredentialAuth: future credential configuration is not writable',
  );
}

/// Replace the secret for an OpenAI-hosted environment credential. The environment variable name and networking configuration remain unchanged.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class RotateVaultEnvironmentVariableAuth
    extends RotateVaultCredentialAuth {
  /// Creates a validated [RotateVaultEnvironmentVariableAuth].
  RotateVaultEnvironmentVariableAuth({required this.secretValue}) {
    validate();
  }

  /// The write-only replacement secret. Never returned in credential resources or supplied directly to sandbox code. Must be nonempty and must not contain carriage returns, newlines, or NUL bytes.
  final String secretValue;

  /// The type of the object. Always `environment_variable`.
  @override
  String get type => 'environment_variable';

  /// Parses [RotateVaultEnvironmentVariableAuth] with contextual, payload-free errors.
  factory RotateVaultEnvironmentVariableAuth.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'secret_value',
      'type',
    ], 'RotateVaultEnvironmentVariableAuth');
    requireAgentTag(
      json,
      'type',
      'environment_variable',
      'RotateVaultEnvironmentVariableAuth',
    );
    return RotateVaultEnvironmentVariableAuth(
      secretValue: requiredAgentValue(
        json,
        'secret_value',
        'RotateVaultEnvironmentVariableAuth.secretValue',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    _validateVaultSecretValue(
      secretValue,
      'RotateVaultEnvironmentVariableAuth.secretValue',
    );
    validateAgentLength(
      secretValue,
      'RotateVaultEnvironmentVariableAuth.secretValue',
      min: 1,
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'secret_value': secretValue, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  RotateVaultEnvironmentVariableAuth copyWith({String? secretValue}) =>
      RotateVaultEnvironmentVariableAuth(
        secretValue: secretValue ?? this.secretValue,
      );
}

/// Rotate an OAuth credential for an HTTPS MCP destination.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class RotateVaultMcpOauthAuth extends RotateVaultCredentialAuth {
  /// Creates a validated [RotateVaultMcpOauthAuth].
  RotateVaultMcpOauthAuth({
    String? accessToken,
    bool clearAccessToken = false,
    String? expiresAt,
    bool clearExpiresAt = false,
    RotateVaultMcpOauthRefresh? refresh,
    bool clearRefresh = false,
  }) : clearAccessToken = clearAccessToken,
       accessToken = clearAccessToken ? null : accessToken,
       clearExpiresAt = clearExpiresAt,
       expiresAt = clearExpiresAt ? null : expiresAt,
       clearRefresh = clearRefresh,
       refresh = clearRefresh ? null : refresh {
    validate();
  }

  /// A write-only replacement OAuth access token.
  final String? accessToken;

  /// Sends `access_token: null`, rather than omitting it.
  final bool clearAccessToken;

  /// The replacement expiry as an RFC 3339 timestamp, or `null` to clear it. Omitting this field preserves the expiry unless a new access token is supplied, in which case the expiry is cleared.
  final String? expiresAt;

  /// Sends `expires_at: null`, rather than omitting it.
  final bool clearExpiresAt;

  /// Optional write-only refresh-token and client-secret updates.
  final RotateVaultMcpOauthRefresh? refresh;

  /// Sends `refresh: null`, rather than omitting it.
  final bool clearRefresh;

  /// The type of the object. Always `mcp_oauth`.
  @override
  String get type => 'mcp_oauth';

  /// Parses [RotateVaultMcpOauthAuth] with contextual, payload-free errors.
  factory RotateVaultMcpOauthAuth.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'access_token',
      'expires_at',
      'refresh',
      'type',
    ], 'RotateVaultMcpOauthAuth');
    requireAgentTag(json, 'type', 'mcp_oauth', 'RotateVaultMcpOauthAuth');
    return RotateVaultMcpOauthAuth(
      accessToken: optionalAgentValue(
        json,
        'access_token',
        'RotateVaultMcpOauthAuth.accessToken',
        requireAgentString,
        nullable: true,
      ),
      clearAccessToken:
          json.containsKey('access_token') && json['access_token'] == null,
      expiresAt: optionalAgentValue(
        json,
        'expires_at',
        'RotateVaultMcpOauthAuth.expiresAt',
        requireAgentString,
        nullable: true,
      ),
      clearExpiresAt:
          json.containsKey('expires_at') && json['expires_at'] == null,
      refresh: optionalAgentValue(
        json,
        'refresh',
        'RotateVaultMcpOauthAuth.refresh',
        (value, context) => RotateVaultMcpOauthRefresh.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearRefresh: json.containsKey('refresh') && json['refresh'] == null,
    );
  }
  @override
  void validate() {
    if (accessToken != null) {
      validateAgentLength(
        accessToken!,
        'RotateVaultMcpOauthAuth.accessToken',
        min: 0,
        max: 1048576,
      );
    }
    if (expiresAt != null) {
      validateAgentLength(
        expiresAt!,
        'RotateVaultMcpOauthAuth.expiresAt',
        min: 0,
        max: 1048576,
      );
    }
    if (refresh != null) {
      refresh!.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearAccessToken)
      'access_token': null
    else
      'access_token': ?accessToken,
    if (clearExpiresAt) 'expires_at': null else 'expires_at': ?expiresAt,
    if (clearRefresh)
      'refresh': null
    else if (refresh != null)
      'refresh': refresh!.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  RotateVaultMcpOauthAuth copyWith({
    Object? accessToken = unsetCopyWithValue,
    bool? clearAccessToken,
    Object? expiresAt = unsetCopyWithValue,
    bool? clearExpiresAt,
    Object? refresh = unsetCopyWithValue,
    bool? clearRefresh,
  }) => RotateVaultMcpOauthAuth(
    accessToken: copyAgentValue<String>(
      accessToken,
      this.accessToken,
      'RotateVaultMcpOauthAuth.accessToken',
    ),
    clearAccessToken:
        clearAccessToken ??
        (identical(accessToken, unsetCopyWithValue)
            ? this.clearAccessToken
            : accessToken == null),
    expiresAt: copyAgentValue<String>(
      expiresAt,
      this.expiresAt,
      'RotateVaultMcpOauthAuth.expiresAt',
    ),
    clearExpiresAt:
        clearExpiresAt ??
        (identical(expiresAt, unsetCopyWithValue)
            ? this.clearExpiresAt
            : expiresAt == null),
    refresh: copyAgentValue<RotateVaultMcpOauthRefresh>(
      refresh,
      this.refresh,
      'RotateVaultMcpOauthAuth.refresh',
    ),
    clearRefresh:
        clearRefresh ??
        (identical(refresh, unsetCopyWithValue)
            ? this.clearRefresh
            : refresh == null),
  );
}

/// Replace the bearer token for the credential's MCP server.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class RotateVaultStaticBearerAuth extends RotateVaultCredentialAuth {
  /// Creates a validated [RotateVaultStaticBearerAuth].
  RotateVaultStaticBearerAuth({required this.token}) {
    validate();
  }

  /// The replacement bearer token. This secret is never returned in credential resources.
  final String token;

  /// The type of the object. Always `static_bearer`.
  @override
  String get type => 'static_bearer';

  /// Parses [RotateVaultStaticBearerAuth] with contextual, payload-free errors.
  factory RotateVaultStaticBearerAuth.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'token',
      'type',
    ], 'RotateVaultStaticBearerAuth');
    requireAgentTag(
      json,
      'type',
      'static_bearer',
      'RotateVaultStaticBearerAuth',
    );
    return RotateVaultStaticBearerAuth(
      token: requiredAgentValue(
        json,
        'token',
        'RotateVaultStaticBearerAuth.token',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      token,
      'RotateVaultStaticBearerAuth.token',
      min: 0,
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'token': token, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  RotateVaultStaticBearerAuth copyWith({String? token}) =>
      RotateVaultStaticBearerAuth(token: token ?? this.token);
}

/// Variants: [VaultEnvironmentVariableAuth], [VaultMcpOauthAuth], [VaultStaticBearerAuth].
/// The authentication configuration of a vault credential, excluding secrets.
///
/// Variants: [VaultEnvironmentVariableAuth], [VaultMcpOauthAuth], [VaultStaticBearerAuth] and [UnknownVaultCredentialAuth].
sealed class VaultCredentialAuth extends AgentJsonModel {
  const VaultCredentialAuth();

  /// Parses known variants strictly and retains future received variants.
  factory VaultCredentialAuth.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(json['type'], 'VaultCredentialAuth.type')) {
        'environment_variable' => VaultEnvironmentVariableAuth.fromJson(json),
        'mcp_oauth' => VaultMcpOauthAuth.fromJson(json),
        'static_bearer' => VaultStaticBearerAuth.fromJson(json),
        _ => UnknownVaultCredentialAuth.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `environment_variable` variant.
  factory VaultCredentialAuth.environmentVariable({
    required VaultCredentialNetworkingResource networking,
    required String secretName,
    Map<String, dynamic> rawJson,
  }) = VaultEnvironmentVariableAuth;

  /// Creates the `mcp_oauth` variant.
  factory VaultCredentialAuth.mcpOauth({
    required String? expiresAt,
    required String mcpServerUrl,
    required VaultMcpOauthRefresh? refresh,
    Map<String, dynamic> rawJson,
  }) = VaultMcpOauthAuth;

  /// Creates the `static_bearer` variant.
  factory VaultCredentialAuth.staticBearer({
    required String mcpServerUrl,
    Map<String, dynamic> rawJson,
  }) = VaultStaticBearerAuth;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownVaultCredentialAuth extends VaultCredentialAuth {
  const UnknownVaultCredentialAuth._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownVaultCredentialAuth.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownVaultCredentialAuth.type',
    );
    if (const [
      'environment_variable',
      'mcp_oauth',
      'static_bearer',
    ].contains(type)) {
      throw const FormatException(
        'UnknownVaultCredentialAuth: expected a future type',
      );
    }
    _rejectVaultReadbackKeys(json, 'UnknownVaultCredentialAuth');
    return UnknownVaultCredentialAuth._(
      snapshotAgentJson(json, 'UnknownVaultCredentialAuth'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownVaultCredentialAuth copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownVaultCredentialAuth.fromJson(rawJson ?? this.rawJson);
}

/// Metadata for an HTTP credential used only in OpenAI-hosted environments. Sandbox code receives a placeholder. The proxy substitutes the secret for allowed HTTPS destinations on ports 443 and 8443. The real secret is not available to sandbox code for local computation and is never returned in this resource.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class VaultEnvironmentVariableAuth extends VaultCredentialAuth {
  /// Creates a validated [VaultEnvironmentVariableAuth].
  VaultEnvironmentVariableAuth({
    required this.networking,
    required this.secretName,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _vaultReceivedExtras(rawJson, const [
         'networking',
         'secret_name',
         'type',
       ], 'VaultEnvironmentVariableAuth') {
    validate();
  }

  /// The destinations where the proxy can substitute the secret, subject to the environment network policy.
  final VaultCredentialNetworkingResource networking;

  /// The environment variable name that receives the placeholder in the sandbox.
  final String secretName;

  /// The type of the object. Always `environment_variable`.
  @override
  String get type => 'environment_variable';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [VaultEnvironmentVariableAuth] with contextual, payload-free errors.
  factory VaultEnvironmentVariableAuth.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'environment_variable',
      'VaultEnvironmentVariableAuth',
    );
    return VaultEnvironmentVariableAuth(
      networking: requiredAgentValue(
        json,
        'networking',
        'VaultEnvironmentVariableAuth.networking',
        (value, context) => VaultCredentialNetworkingResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      secretName: requiredAgentValue(
        json,
        'secret_name',
        'VaultEnvironmentVariableAuth.secretName',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['networking', 'secret_name', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    networking.validate();
    validateAgentLength(
      secretName,
      'VaultEnvironmentVariableAuth.secretName',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'networking': networking.toJson(),
    'secret_name': secretName,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  VaultEnvironmentVariableAuth copyWith({
    VaultCredentialNetworkingResource? networking,
    String? secretName,
    Map<String, dynamic>? rawJson,
  }) => VaultEnvironmentVariableAuth(
    networking: networking ?? this.networking,
    secretName: secretName ?? this.secretName,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Public metadata for an OAuth credential; tokens and client secrets are never returned.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class VaultMcpOauthAuth extends VaultCredentialAuth {
  /// Creates a validated [VaultMcpOauthAuth].
  VaultMcpOauthAuth({
    required this.expiresAt,
    required this.mcpServerUrl,
    required this.refresh,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _vaultReceivedExtras(rawJson, const [
         'expires_at',
         'mcp_server_url',
         'refresh',
         'type',
       ], 'VaultMcpOauthAuth') {
    validate();
  }

  /// When the OAuth access token expires, as an RFC 3339 timestamp, if known.
  final String? expiresAt;

  /// The HTTPS MCP server URL authorized by this credential.
  final String mcpServerUrl;

  /// Public refresh metadata without refresh tokens or OAuth client secrets.
  final VaultMcpOauthRefresh? refresh;

  /// The type of the object. Always `mcp_oauth`.
  @override
  String get type => 'mcp_oauth';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [VaultMcpOauthAuth] with contextual, payload-free errors.
  factory VaultMcpOauthAuth.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'mcp_oauth', 'VaultMcpOauthAuth');
    return VaultMcpOauthAuth(
      expiresAt: requiredAgentValue(
        json,
        'expires_at',
        'VaultMcpOauthAuth.expiresAt',
        requireAgentString,
        nullable: true,
      ),
      mcpServerUrl: requiredAgentValue(
        json,
        'mcp_server_url',
        'VaultMcpOauthAuth.mcpServerUrl',
        requireAgentString,
        nullable: false,
      )!,
      refresh: requiredAgentValue(
        json,
        'refresh',
        'VaultMcpOauthAuth.refresh',
        (value, context) =>
            VaultMcpOauthRefresh.fromJson(requireAgentObject(value, context)),
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'expires_at',
            'mcp_server_url',
            'refresh',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (expiresAt != null) {
      validateAgentLength(expiresAt!, 'VaultMcpOauthAuth.expiresAt', min: 0);
    }
    validateAgentLength(mcpServerUrl, 'VaultMcpOauthAuth.mcpServerUrl', min: 0);
    if (refresh != null) {
      refresh!.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'expires_at': expiresAt,
    'mcp_server_url': mcpServerUrl,
    'refresh': refresh?.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  VaultMcpOauthAuth copyWith({
    Object? expiresAt = unsetCopyWithValue,
    String? mcpServerUrl,
    Object? refresh = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => VaultMcpOauthAuth(
    expiresAt: copyAgentValue<String>(
      expiresAt,
      this.expiresAt,
      'VaultMcpOauthAuth.expiresAt',
    ),
    mcpServerUrl: mcpServerUrl ?? this.mcpServerUrl,
    refresh: copyAgentValue<VaultMcpOauthRefresh>(
      refresh,
      this.refresh,
      'VaultMcpOauthAuth.refresh',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Metadata for a bearer-token credential, without automatic OAuth refresh.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class VaultStaticBearerAuth extends VaultCredentialAuth {
  /// Creates a validated [VaultStaticBearerAuth].
  VaultStaticBearerAuth({
    required this.mcpServerUrl,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _vaultReceivedExtras(rawJson, const [
         'mcp_server_url',
         'type',
       ], 'VaultStaticBearerAuth') {
    validate();
  }

  /// The HTTPS MCP server URL authorized by this credential.
  final String mcpServerUrl;

  /// The type of the object. Always `static_bearer`.
  @override
  String get type => 'static_bearer';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [VaultStaticBearerAuth] with contextual, payload-free errors.
  factory VaultStaticBearerAuth.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'static_bearer', 'VaultStaticBearerAuth');
    return VaultStaticBearerAuth(
      mcpServerUrl: requiredAgentValue(
        json,
        'mcp_server_url',
        'VaultStaticBearerAuth.mcpServerUrl',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['mcp_server_url', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      mcpServerUrl,
      'VaultStaticBearerAuth.mcpServerUrl',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'mcp_server_url': mcpServerUrl,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  VaultStaticBearerAuth copyWith({
    String? mcpServerUrl,
    Map<String, dynamic>? rawJson,
  }) => VaultStaticBearerAuth(
    mcpServerUrl: mcpServerUrl ?? this.mcpServerUrl,
    rawJson: rawJson ?? this.rawJson,
  );
}
