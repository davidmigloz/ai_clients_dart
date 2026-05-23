import 'package:meta/meta.dart';

import '../../beta_timestamp.dart';
import '../../common/copy_with_sentinel.dart';

/// Overall result of validating a vault credential.
enum CredentialValidationStatus {
  /// The credential is valid and usable.
  valid('valid'),

  /// The credential is invalid.
  invalid('invalid'),

  /// The validation result could not be determined — also the fallback for
  /// unrecognized values.
  unknown('unknown');

  const CredentialValidationStatus(this.value);

  /// JSON value for this status.
  final String value;

  /// Parses a [CredentialValidationStatus] from JSON.
  static CredentialValidationStatus fromJson(String value) => switch (value) {
    'valid' => CredentialValidationStatus.valid,
    'invalid' => CredentialValidationStatus.invalid,
    _ => CredentialValidationStatus.unknown,
  };

  /// Converts this status to JSON.
  String toJson() => value;
}

/// Outcome of attempting to refresh a credential's access token.
enum CredentialRefreshStatus {
  /// The refresh succeeded.
  succeeded('succeeded'),

  /// The refresh attempt failed.
  failed('failed'),

  /// Could not connect to the token endpoint.
  connectError('connect_error'),

  /// No refresh token is available for this credential.
  noRefreshToken('no_refresh_token'),

  /// Unrecognized refresh status — fallback for forward compatibility.
  unknown('unknown');

  const CredentialRefreshStatus(this.value);

  /// JSON value for this status.
  final String value;

  /// Parses a [CredentialRefreshStatus] from JSON.
  static CredentialRefreshStatus fromJson(String value) => switch (value) {
    'succeeded' => CredentialRefreshStatus.succeeded,
    'failed' => CredentialRefreshStatus.failed,
    'connect_error' => CredentialRefreshStatus.connectError,
    'no_refresh_token' => CredentialRefreshStatus.noRefreshToken,
    _ => CredentialRefreshStatus.unknown,
  };

  /// Converts this status to JSON.
  String toJson() => value;
}

/// A captured HTTP response from a credential refresh or MCP probe.
///
/// Sensitive values are scrubbed and the body may be truncated.
@immutable
class RefreshHttpResponse {
  /// HTTP status code of the response.
  final int statusCode;

  /// Value of the response `Content-Type` header.
  final String contentType;

  /// Response body (may be truncated; sensitive values scrubbed).
  final String body;

  /// Whether [body] was truncated.
  final bool bodyTruncated;

  /// Creates a [RefreshHttpResponse].
  const RefreshHttpResponse({
    required this.statusCode,
    required this.contentType,
    required this.body,
    required this.bodyTruncated,
  });

  /// Creates a [RefreshHttpResponse] from JSON.
  factory RefreshHttpResponse.fromJson(Map<String, dynamic> json) {
    return RefreshHttpResponse(
      statusCode: json['status_code'] as int,
      contentType: json['content_type'] as String,
      body: json['body'] as String,
      bodyTruncated: json['body_truncated'] as bool,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'status_code': statusCode,
    'content_type': contentType,
    'body': body,
    'body_truncated': bodyTruncated,
  };

  /// Creates a copy with replaced values.
  RefreshHttpResponse copyWith({
    int? statusCode,
    String? contentType,
    String? body,
    bool? bodyTruncated,
  }) {
    return RefreshHttpResponse(
      statusCode: statusCode ?? this.statusCode,
      contentType: contentType ?? this.contentType,
      body: body ?? this.body,
      bodyTruncated: bodyTruncated ?? this.bodyTruncated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefreshHttpResponse &&
          runtimeType == other.runtimeType &&
          statusCode == other.statusCode &&
          contentType == other.contentType &&
          body == other.body &&
          bodyTruncated == other.bodyTruncated;

  @override
  int get hashCode => Object.hash(statusCode, contentType, body, bodyTruncated);

  @override
  String toString() =>
      'RefreshHttpResponse(statusCode: $statusCode, '
      'contentType: $contentType, body: $body, '
      'bodyTruncated: $bodyTruncated)';
}

/// Result of attempting to refresh a credential's access token during
/// validation.
@immutable
class RefreshObject {
  /// Outcome of the refresh attempt.
  final CredentialRefreshStatus status;

  /// Captured HTTP response. Populated only when [status] is
  /// [CredentialRefreshStatus.failed]; otherwise null.
  final RefreshHttpResponse? httpResponse;

  /// Creates a [RefreshObject].
  const RefreshObject({required this.status, this.httpResponse});

  /// Creates a [RefreshObject] from JSON.
  factory RefreshObject.fromJson(Map<String, dynamic> json) {
    return RefreshObject(
      status: CredentialRefreshStatus.fromJson(json['status'] as String),
      httpResponse: json['http_response'] != null
          ? RefreshHttpResponse.fromJson(
              json['http_response'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'status': status.toJson(),
    'http_response': httpResponse?.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// For the nullable [httpResponse], pass [unsetCopyWithValue] (or omit) to
  /// keep the original, or `null` explicitly to clear it.
  RefreshObject copyWith({
    CredentialRefreshStatus? status,
    Object? httpResponse = unsetCopyWithValue,
  }) {
    return RefreshObject(
      status: status ?? this.status,
      httpResponse: httpResponse == unsetCopyWithValue
          ? this.httpResponse
          : httpResponse as RefreshHttpResponse?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefreshObject &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          httpResponse == other.httpResponse;

  @override
  int get hashCode => Object.hash(status, httpResponse);

  @override
  String toString() =>
      'RefreshObject(status: $status, httpResponse: $httpResponse)';
}

/// Result of probing an MCP server with a credential during validation.
@immutable
class McpProbe {
  /// The MCP method that was probed (e.g. `initialize`, `tools/list`).
  final String method;

  /// Captured HTTP response from the probe. Null when no response was
  /// received.
  final RefreshHttpResponse? httpResponse;

  /// Creates an [McpProbe].
  const McpProbe({required this.method, this.httpResponse});

  /// Creates an [McpProbe] from JSON.
  factory McpProbe.fromJson(Map<String, dynamic> json) {
    return McpProbe(
      method: json['method'] as String,
      httpResponse: json['http_response'] != null
          ? RefreshHttpResponse.fromJson(
              json['http_response'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'method': method,
    'http_response': httpResponse?.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// For the nullable [httpResponse], pass [unsetCopyWithValue] (or omit) to
  /// keep the original, or `null` explicitly to clear it.
  McpProbe copyWith({
    String? method,
    Object? httpResponse = unsetCopyWithValue,
  }) {
    return McpProbe(
      method: method ?? this.method,
      httpResponse: httpResponse == unsetCopyWithValue
          ? this.httpResponse
          : httpResponse as RefreshHttpResponse?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpProbe &&
          runtimeType == other.runtimeType &&
          method == other.method &&
          httpResponse == other.httpResponse;

  @override
  int get hashCode => Object.hash(method, httpResponse);

  @override
  String toString() => 'McpProbe(method: $method, httpResponse: $httpResponse)';
}

/// Result of validating a vault credential against its MCP server.
///
/// Returned by the credential `mcp_oauth_validate` endpoint.
@immutable
class CredentialValidation {
  /// Object type. Always 'vault_credential_validation'.
  final String type;

  /// ID of the credential that was validated.
  final String credentialId;

  /// ID of the vault the credential belongs to.
  final String vaultId;

  /// Overall validation status.
  final CredentialValidationStatus status;

  /// When the validation was performed.
  final BetaTimestamp validatedAt;

  /// Whether the credential has a refresh token.
  final bool hasRefreshToken;

  /// Result of probing the MCP server. Null when no probe was performed.
  final McpProbe? mcpProbe;

  /// Result of attempting a token refresh. Null when no refresh was attempted.
  final RefreshObject? refresh;

  /// Creates a [CredentialValidation].
  const CredentialValidation({
    this.type = 'vault_credential_validation',
    required this.credentialId,
    required this.vaultId,
    required this.status,
    required this.validatedAt,
    required this.hasRefreshToken,
    this.mcpProbe,
    this.refresh,
  });

  /// Creates a [CredentialValidation] from JSON.
  factory CredentialValidation.fromJson(Map<String, dynamic> json) {
    return CredentialValidation(
      type: json['type'] as String? ?? 'vault_credential_validation',
      credentialId: json['credential_id'] as String,
      vaultId: json['vault_id'] as String,
      status: CredentialValidationStatus.fromJson(json['status'] as String),
      validatedAt: DateTime.parse(json['validated_at'] as String),
      hasRefreshToken: json['has_refresh_token'] as bool,
      mcpProbe: json['mcp_probe'] != null
          ? McpProbe.fromJson(json['mcp_probe'] as Map<String, dynamic>)
          : null,
      refresh: json['refresh'] != null
          ? RefreshObject.fromJson(json['refresh'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'credential_id': credentialId,
    'vault_id': vaultId,
    'status': status.toJson(),
    'validated_at': validatedAt.toUtc().toIso8601String(),
    'has_refresh_token': hasRefreshToken,
    'mcp_probe': mcpProbe?.toJson(),
    'refresh': refresh?.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// For the nullable [mcpProbe] and [refresh], pass [unsetCopyWithValue] (or
  /// omit) to keep the original, or `null` explicitly to clear it.
  CredentialValidation copyWith({
    String? type,
    String? credentialId,
    String? vaultId,
    CredentialValidationStatus? status,
    BetaTimestamp? validatedAt,
    bool? hasRefreshToken,
    Object? mcpProbe = unsetCopyWithValue,
    Object? refresh = unsetCopyWithValue,
  }) {
    return CredentialValidation(
      type: type ?? this.type,
      credentialId: credentialId ?? this.credentialId,
      vaultId: vaultId ?? this.vaultId,
      status: status ?? this.status,
      validatedAt: validatedAt ?? this.validatedAt,
      hasRefreshToken: hasRefreshToken ?? this.hasRefreshToken,
      mcpProbe: mcpProbe == unsetCopyWithValue
          ? this.mcpProbe
          : mcpProbe as McpProbe?,
      refresh: refresh == unsetCopyWithValue
          ? this.refresh
          : refresh as RefreshObject?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialValidation &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          credentialId == other.credentialId &&
          vaultId == other.vaultId &&
          status == other.status &&
          validatedAt == other.validatedAt &&
          hasRefreshToken == other.hasRefreshToken &&
          mcpProbe == other.mcpProbe &&
          refresh == other.refresh;

  @override
  int get hashCode => Object.hash(
    type,
    credentialId,
    vaultId,
    status,
    validatedAt,
    hasRefreshToken,
    mcpProbe,
    refresh,
  );

  @override
  String toString() =>
      'CredentialValidation(type: $type, credentialId: $credentialId, '
      'vaultId: $vaultId, status: $status, validatedAt: $validatedAt, '
      'hasRefreshToken: $hasRefreshToken, mcpProbe: $mcpProbe, '
      'refresh: $refresh)';
}
