import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';
import '../events/telemetry.dart';

/// Error types reported by a Managed Agents session.
enum SessionErrorKind {
  /// The provider could not identify the error.
  unknownError('unknown_error'),

  /// The model is temporarily overloaded.
  modelOverloaded('model_overloaded_error'),

  /// The model request exceeded a rate limit.
  modelRateLimited('model_rate_limited_error'),

  /// The model request failed.
  modelRequestFailed('model_request_failed_error'),

  /// The MCP server could not be reached.
  mcpConnectionFailed('mcp_connection_failed_error'),

  /// The MCP server rejected authentication.
  mcpAuthenticationFailed('mcp_authentication_failed_error'),

  /// Billing prevented the session from proceeding.
  billing('billing_error'),

  /// The environment could not reach a credential's allowed host.
  credentialHostUnreachable('credential_host_unreachable_error'),

  /// The agent reached its tool-use limit.
  toolUseLimitReached('tool_use_limit_reached_error'),

  /// The agent reached its context-compaction limit.
  compactionLimitReached('compaction_limit_reached_error'),

  /// The repository rejected authentication.
  repositoryAuthentication('repository_authentication_error'),

  /// The repository rejected access.
  repositoryForbidden('repository_forbidden_error'),

  /// The repository could not be found.
  repositoryNotFound('repository_not_found_error'),

  /// The requested ref could not be checked out.
  repositoryCheckout('repository_checkout_error'),

  /// The repository could not be cloned.
  repositoryClone('repository_clone_error'),

  /// A future or unspecified error type.
  unrecognized(null);

  const SessionErrorKind(this.value);

  /// The wire discriminator for known errors.
  final String? value;

  /// Parses a discriminator, preserving unknown types in [SessionErrorDetails].
  static SessionErrorKind fromJson(String? value) => values.firstWhere(
    (kind) => kind.value == value,
    orElse: () => unrecognized,
  );
}

/// Typed access to Managed Agents error payloads, including future fields.
@immutable
final class SessionErrorDetails {
  final Map<String, dynamic> _raw;

  /// Original provider discriminator, when present.
  String? get type => _stringField('type');

  /// The recognized error kind.
  SessionErrorKind get kind => SessionErrorKind.fromJson(type);

  /// Human-readable provider message.
  String? get message => _stringField('message');

  /// Whether the server is retrying or the request cannot proceed.
  RetryStatus? get retryStatus => switch (_raw['retry_status']) {
    final Map<String, dynamic> json when json['type'] is String =>
      RetryStatus.fromJson(json),
    _ => null,
  };

  /// Repository URL for a repository error, when available.
  String? get repositoryUrl => _stringField('repository_url');

  /// Server name for an MCP connection or authentication error.
  String? get mcpServerName => _stringField('mcp_server_name');

  /// ID of the affected vault for a credential error.
  String? get vaultId => _stringField('vault_id');

  /// ID of the affected credential.
  String? get credentialId => _stringField('credential_id');

  /// Creates typed error details from a JSON payload.
  SessionErrorDetails.fromJson(Map<String, dynamic> json)
    : _raw = deepUnmodifiableMap(json);

  String? _stringField(String key) => switch (_raw[key]) {
    final String value => value,
    _ => null,
  };

  /// Converts to JSON and preserves additional fields.
  Map<String, dynamic> toJson() => Map.of(_raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionErrorDetails && mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => mapDeepHashCode(_raw);

  @override
  String toString() => 'SessionErrorDetails(type: $type)';
}
