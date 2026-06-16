import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

// ============================================================================
// RunError — sealed
// ============================================================================

/// Why a scheduled run failed to create a session.
///
/// The `type` identifies the failure; `message` is human-readable detail.
///
/// Variants:
/// - [AgentArchivedRunError] — type: "agent_archived_error"
/// - [EnvironmentArchivedRunError] — type: "environment_archived_error"
/// - [EnvironmentNotFoundRunError] — type: "environment_not_found_error"
/// - [FileNotFoundRunError] — type: "file_not_found_error"
/// - [McpEgressBlockedRunError] — type: "mcp_egress_blocked_error"
/// - [MemoryStoreArchivedRunError] — type: "memory_store_archived_error"
/// - [OrganizationDisabledRunError] — type: "organization_disabled_error"
/// - [SelfHostedResourcesUnsupportedRunError] —
///   type: "self_hosted_resources_unsupported_error"
/// - [SessionCreationRejectedRunError] — type: "session_creation_rejected_error"
/// - [SessionRateLimitedRunError] — type: "session_rate_limited_error"
/// - [SessionResourceNotFoundRunError] — type: "session_resource_not_found_error"
/// - [SkillNotFoundRunError] — type: "skill_not_found_error"
/// - [UnknownRunError] — type: "unknown_error"
/// - [VaultArchivedRunError] — type: "vault_archived_error"
/// - [VaultNotFoundRunError] — type: "vault_not_found_error"
/// - [WorkspaceArchivedRunError] — type: "workspace_archived_error"
/// - [UnrecognizedRunError] — unrecognized type (preserves raw JSON)
sealed class RunError {
  const RunError();

  /// Creates a [RunError] from JSON.
  factory RunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'agent_archived_error' => AgentArchivedRunError.fromJson(json),
      'environment_archived_error' => EnvironmentArchivedRunError.fromJson(
        json,
      ),
      'environment_not_found_error' => EnvironmentNotFoundRunError.fromJson(
        json,
      ),
      'file_not_found_error' => FileNotFoundRunError.fromJson(json),
      'mcp_egress_blocked_error' => McpEgressBlockedRunError.fromJson(json),
      'memory_store_archived_error' => MemoryStoreArchivedRunError.fromJson(
        json,
      ),
      'organization_disabled_error' => OrganizationDisabledRunError.fromJson(
        json,
      ),
      'self_hosted_resources_unsupported_error' =>
        SelfHostedResourcesUnsupportedRunError.fromJson(json),
      'session_creation_rejected_error' =>
        SessionCreationRejectedRunError.fromJson(json),
      'session_rate_limited_error' => SessionRateLimitedRunError.fromJson(json),
      'session_resource_not_found_error' =>
        SessionResourceNotFoundRunError.fromJson(json),
      'skill_not_found_error' => SkillNotFoundRunError.fromJson(json),
      'unknown_error' => UnknownRunError.fromJson(json),
      'vault_archived_error' => VaultArchivedRunError.fromJson(json),
      'vault_not_found_error' => VaultNotFoundRunError.fromJson(json),
      'workspace_archived_error' => WorkspaceArchivedRunError.fromJson(json),
      _ => UnrecognizedRunError.fromJson(json),
    };
  }

  /// The type discriminator.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// The deployment's agent was archived.
@immutable
class AgentArchivedRunError extends RunError {
  /// Creates an [AgentArchivedRunError].
  const AgentArchivedRunError({required this.message});

  /// Creates an [AgentArchivedRunError] from JSON.
  factory AgentArchivedRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'agent_archived_error') {
      throw FormatException(
        'AgentArchivedRunError: expected type "agent_archived_error", '
        'got "$type"',
      );
    }
    return AgentArchivedRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `agent_archived_error`.
  @override
  String get type => 'agent_archived_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  AgentArchivedRunError copyWith({String? message}) =>
      AgentArchivedRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentArchivedRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'AgentArchivedRunError(type: $type, message: $message)';
}

/// The deployment's environment was archived.
@immutable
class EnvironmentArchivedRunError extends RunError {
  /// Creates an [EnvironmentArchivedRunError].
  const EnvironmentArchivedRunError({required this.message});

  /// Creates an [EnvironmentArchivedRunError] from JSON.
  factory EnvironmentArchivedRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'environment_archived_error') {
      throw FormatException(
        'EnvironmentArchivedRunError: expected type '
        '"environment_archived_error", got "$type"',
      );
    }
    return EnvironmentArchivedRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `environment_archived_error`.
  @override
  String get type => 'environment_archived_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  EnvironmentArchivedRunError copyWith({String? message}) =>
      EnvironmentArchivedRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentArchivedRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() =>
      'EnvironmentArchivedRunError(type: $type, message: $message)';
}

/// The deployment's environment no longer exists.
@immutable
class EnvironmentNotFoundRunError extends RunError {
  /// Creates an [EnvironmentNotFoundRunError].
  const EnvironmentNotFoundRunError({required this.message});

  /// Creates an [EnvironmentNotFoundRunError] from JSON.
  factory EnvironmentNotFoundRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'environment_not_found_error') {
      throw FormatException(
        'EnvironmentNotFoundRunError: expected type '
        '"environment_not_found_error", got "$type"',
      );
    }
    return EnvironmentNotFoundRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `environment_not_found_error`.
  @override
  String get type => 'environment_not_found_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  EnvironmentNotFoundRunError copyWith({String? message}) =>
      EnvironmentNotFoundRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentNotFoundRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() =>
      'EnvironmentNotFoundRunError(type: $type, message: $message)';
}

/// A file resource referenced by the deployment no longer exists.
@immutable
class FileNotFoundRunError extends RunError {
  /// Creates a [FileNotFoundRunError].
  const FileNotFoundRunError({required this.message});

  /// Creates a [FileNotFoundRunError] from JSON.
  factory FileNotFoundRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'file_not_found_error') {
      throw FormatException(
        'FileNotFoundRunError: expected type "file_not_found_error", '
        'got "$type"',
      );
    }
    return FileNotFoundRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `file_not_found_error`.
  @override
  String get type => 'file_not_found_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  FileNotFoundRunError copyWith({String? message}) =>
      FileNotFoundRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileNotFoundRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'FileNotFoundRunError(type: $type, message: $message)';
}

/// An MCP server host used by the deployment's agent is blocked by the
/// environment's network policy.
@immutable
class McpEgressBlockedRunError extends RunError {
  /// Creates a [McpEgressBlockedRunError].
  const McpEgressBlockedRunError({required this.message});

  /// Creates a [McpEgressBlockedRunError] from JSON.
  factory McpEgressBlockedRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'mcp_egress_blocked_error') {
      throw FormatException(
        'McpEgressBlockedRunError: expected type "mcp_egress_blocked_error", '
        'got "$type"',
      );
    }
    return McpEgressBlockedRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `mcp_egress_blocked_error`.
  @override
  String get type => 'mcp_egress_blocked_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  McpEgressBlockedRunError copyWith({String? message}) =>
      McpEgressBlockedRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpEgressBlockedRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() =>
      'McpEgressBlockedRunError(type: $type, message: $message)';
}

/// A memory store referenced by the deployment is archived.
@immutable
class MemoryStoreArchivedRunError extends RunError {
  /// Creates a [MemoryStoreArchivedRunError].
  const MemoryStoreArchivedRunError({required this.message});

  /// Creates a [MemoryStoreArchivedRunError] from JSON.
  factory MemoryStoreArchivedRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'memory_store_archived_error') {
      throw FormatException(
        'MemoryStoreArchivedRunError: expected type '
        '"memory_store_archived_error", got "$type"',
      );
    }
    return MemoryStoreArchivedRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `memory_store_archived_error`.
  @override
  String get type => 'memory_store_archived_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  MemoryStoreArchivedRunError copyWith({String? message}) =>
      MemoryStoreArchivedRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryStoreArchivedRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() =>
      'MemoryStoreArchivedRunError(type: $type, message: $message)';
}

/// The deployment's organization is disabled.
@immutable
class OrganizationDisabledRunError extends RunError {
  /// Creates an [OrganizationDisabledRunError].
  const OrganizationDisabledRunError({required this.message});

  /// Creates an [OrganizationDisabledRunError] from JSON.
  factory OrganizationDisabledRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'organization_disabled_error') {
      throw FormatException(
        'OrganizationDisabledRunError: expected type '
        '"organization_disabled_error", got "$type"',
      );
    }
    return OrganizationDisabledRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `organization_disabled_error`.
  @override
  String get type => 'organization_disabled_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  OrganizationDisabledRunError copyWith({String? message}) =>
      OrganizationDisabledRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationDisabledRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() =>
      'OrganizationDisabledRunError(type: $type, message: $message)';
}

/// The deployment configures resources, but its environment is self-hosted and
/// cannot mount them.
@immutable
class SelfHostedResourcesUnsupportedRunError extends RunError {
  /// Creates a [SelfHostedResourcesUnsupportedRunError].
  const SelfHostedResourcesUnsupportedRunError({required this.message});

  /// Creates a [SelfHostedResourcesUnsupportedRunError] from JSON.
  factory SelfHostedResourcesUnsupportedRunError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'self_hosted_resources_unsupported_error') {
      throw FormatException(
        'SelfHostedResourcesUnsupportedRunError: expected type '
        '"self_hosted_resources_unsupported_error", got "$type"',
      );
    }
    return SelfHostedResourcesUnsupportedRunError(
      message: json['message'] as String,
    );
  }

  /// The type discriminator. Always `self_hosted_resources_unsupported_error`.
  @override
  String get type => 'self_hosted_resources_unsupported_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  SelfHostedResourcesUnsupportedRunError copyWith({String? message}) =>
      SelfHostedResourcesUnsupportedRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelfHostedResourcesUnsupportedRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() =>
      'SelfHostedResourcesUnsupportedRunError(type: $type, message: $message)';
}

/// The session create request was rejected with a non-retryable validation
/// error.
@immutable
class SessionCreationRejectedRunError extends RunError {
  /// Creates a [SessionCreationRejectedRunError].
  const SessionCreationRejectedRunError({required this.message});

  /// Creates a [SessionCreationRejectedRunError] from JSON.
  factory SessionCreationRejectedRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'session_creation_rejected_error') {
      throw FormatException(
        'SessionCreationRejectedRunError: expected type '
        '"session_creation_rejected_error", got "$type"',
      );
    }
    return SessionCreationRejectedRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `session_creation_rejected_error`.
  @override
  String get type => 'session_creation_rejected_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  SessionCreationRejectedRunError copyWith({String? message}) =>
      SessionCreationRejectedRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionCreationRejectedRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() =>
      'SessionCreationRejectedRunError(type: $type, message: $message)';
}

/// Session creation was rejected due to rate limiting. The schedule keeps
/// firing; subsequent runs may succeed.
@immutable
class SessionRateLimitedRunError extends RunError {
  /// Creates a [SessionRateLimitedRunError].
  const SessionRateLimitedRunError({required this.message});

  /// Creates a [SessionRateLimitedRunError] from JSON.
  factory SessionRateLimitedRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'session_rate_limited_error') {
      throw FormatException(
        'SessionRateLimitedRunError: expected type '
        '"session_rate_limited_error", got "$type"',
      );
    }
    return SessionRateLimitedRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `session_rate_limited_error`.
  @override
  String get type => 'session_rate_limited_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  SessionRateLimitedRunError copyWith({String? message}) =>
      SessionRateLimitedRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionRateLimitedRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() =>
      'SessionRateLimitedRunError(type: $type, message: $message)';
}

/// A referenced resource no longer exists and its kind was not reported.
@immutable
class SessionResourceNotFoundRunError extends RunError {
  /// Creates a [SessionResourceNotFoundRunError].
  const SessionResourceNotFoundRunError({required this.message});

  /// Creates a [SessionResourceNotFoundRunError] from JSON.
  factory SessionResourceNotFoundRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'session_resource_not_found_error') {
      throw FormatException(
        'SessionResourceNotFoundRunError: expected type '
        '"session_resource_not_found_error", got "$type"',
      );
    }
    return SessionResourceNotFoundRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `session_resource_not_found_error`.
  @override
  String get type => 'session_resource_not_found_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  SessionResourceNotFoundRunError copyWith({String? message}) =>
      SessionResourceNotFoundRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionResourceNotFoundRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() =>
      'SessionResourceNotFoundRunError(type: $type, message: $message)';
}

/// A skill referenced by the deployment's agent no longer exists.
@immutable
class SkillNotFoundRunError extends RunError {
  /// Creates a [SkillNotFoundRunError].
  const SkillNotFoundRunError({required this.message});

  /// Creates a [SkillNotFoundRunError] from JSON.
  factory SkillNotFoundRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'skill_not_found_error') {
      throw FormatException(
        'SkillNotFoundRunError: expected type "skill_not_found_error", '
        'got "$type"',
      );
    }
    return SkillNotFoundRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `skill_not_found_error`.
  @override
  String get type => 'skill_not_found_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  SkillNotFoundRunError copyWith({String? message}) =>
      SkillNotFoundRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillNotFoundRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'SkillNotFoundRunError(type: $type, message: $message)';
}

/// An unknown or unexpected error caused the run to fail.
///
/// A fallback variant; clients that do not recognize a new error type can
/// match on message alone.
@immutable
class UnknownRunError extends RunError {
  /// Creates an [UnknownRunError].
  const UnknownRunError({required this.message});

  /// Creates an [UnknownRunError] from JSON.
  factory UnknownRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'unknown_error') {
      throw FormatException(
        'UnknownRunError: expected type "unknown_error", got "$type"',
      );
    }
    return UnknownRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `unknown_error`.
  @override
  String get type => 'unknown_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  UnknownRunError copyWith({String? message}) =>
      UnknownRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'UnknownRunError(type: $type, message: $message)';
}

/// A vault referenced by the deployment is archived.
@immutable
class VaultArchivedRunError extends RunError {
  /// Creates a [VaultArchivedRunError].
  const VaultArchivedRunError({required this.message});

  /// Creates a [VaultArchivedRunError] from JSON.
  factory VaultArchivedRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'vault_archived_error') {
      throw FormatException(
        'VaultArchivedRunError: expected type "vault_archived_error", '
        'got "$type"',
      );
    }
    return VaultArchivedRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `vault_archived_error`.
  @override
  String get type => 'vault_archived_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  VaultArchivedRunError copyWith({String? message}) =>
      VaultArchivedRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultArchivedRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'VaultArchivedRunError(type: $type, message: $message)';
}

/// A vault referenced by the deployment no longer exists.
@immutable
class VaultNotFoundRunError extends RunError {
  /// Creates a [VaultNotFoundRunError].
  const VaultNotFoundRunError({required this.message});

  /// Creates a [VaultNotFoundRunError] from JSON.
  factory VaultNotFoundRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'vault_not_found_error') {
      throw FormatException(
        'VaultNotFoundRunError: expected type "vault_not_found_error", '
        'got "$type"',
      );
    }
    return VaultNotFoundRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `vault_not_found_error`.
  @override
  String get type => 'vault_not_found_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  VaultNotFoundRunError copyWith({String? message}) =>
      VaultNotFoundRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultNotFoundRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'VaultNotFoundRunError(type: $type, message: $message)';
}

/// The deployment's workspace was archived.
@immutable
class WorkspaceArchivedRunError extends RunError {
  /// Creates a [WorkspaceArchivedRunError].
  const WorkspaceArchivedRunError({required this.message});

  /// Creates a [WorkspaceArchivedRunError] from JSON.
  factory WorkspaceArchivedRunError.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'workspace_archived_error') {
      throw FormatException(
        'WorkspaceArchivedRunError: expected type "workspace_archived_error", '
        'got "$type"',
      );
    }
    return WorkspaceArchivedRunError(message: json['message'] as String);
  }

  /// The type discriminator. Always `workspace_archived_error`.
  @override
  String get type => 'workspace_archived_error';

  /// Human-readable error description.
  final String message;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  WorkspaceArchivedRunError copyWith({String? message}) =>
      WorkspaceArchivedRunError(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceArchivedRunError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() =>
      'WorkspaceArchivedRunError(type: $type, message: $message)';
}

/// Unrecognized run error type (preserves raw JSON for forward compatibility).
///
/// Returned by [RunError.fromJson] when the `type` discriminator does not match
/// any known variant. Distinct from [UnknownRunError], which is the spec's
/// typed `unknown_error` variant.
@immutable
class UnrecognizedRunError extends RunError {
  /// Creates an [UnrecognizedRunError].
  const UnrecognizedRunError({required this.rawJson});

  /// Creates an [UnrecognizedRunError] from JSON.
  factory UnrecognizedRunError.fromJson(Map<String, dynamic> json) {
    return UnrecognizedRunError(rawJson: json);
  }

  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// The type discriminator, read from the raw JSON if present.
  @override
  String get type => rawJson['type'] as String? ?? 'unrecognized';

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnrecognizedRunError &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnrecognizedRunError(rawJson: $rawJson)';
}
