import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

// ============================================================================
// DeploymentPausedReasonError — sealed
// ============================================================================

/// The error that triggered an auto-pause.
///
/// Matches the failed run's `error.type`. Unlike [RunError] variants, these
/// carry only the `type` discriminator (no `message`).
///
/// Variants:
/// - [AgentArchivedDeploymentPausedReasonError] — type: "agent_archived_error"
/// - [EnvironmentArchivedDeploymentPausedReasonError] —
///   type: "environment_archived_error"
/// - [EnvironmentNotFoundDeploymentPausedReasonError] —
///   type: "environment_not_found_error"
/// - [FileNotFoundDeploymentPausedReasonError] — type: "file_not_found_error"
/// - [McpEgressBlockedDeploymentPausedReasonError] —
///   type: "mcp_egress_blocked_error"
/// - [MemoryStoreArchivedDeploymentPausedReasonError] —
///   type: "memory_store_archived_error"
/// - [OrganizationDisabledDeploymentPausedReasonError] —
///   type: "organization_disabled_error"
/// - [SelfHostedResourcesUnsupportedDeploymentPausedReasonError] —
///   type: "self_hosted_resources_unsupported_error"
/// - [SessionResourceNotFoundDeploymentPausedReasonError] —
///   type: "session_resource_not_found_error"
/// - [SkillNotFoundDeploymentPausedReasonError] — type: "skill_not_found_error"
/// - [UnknownDeploymentPausedReasonError] — type: "unknown_error"
/// - [VaultArchivedDeploymentPausedReasonError] — type: "vault_archived_error"
/// - [VaultNotFoundDeploymentPausedReasonError] — type: "vault_not_found_error"
/// - [WorkspaceArchivedDeploymentPausedReasonError] —
///   type: "workspace_archived_error"
/// - [UnrecognizedDeploymentPausedReasonError] — unrecognized type (preserves
///   raw JSON)
sealed class DeploymentPausedReasonError {
  const DeploymentPausedReasonError();

  /// Creates a [DeploymentPausedReasonError] from JSON.
  factory DeploymentPausedReasonError.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'agent_archived_error' =>
        AgentArchivedDeploymentPausedReasonError.fromJson(json),
      'environment_archived_error' =>
        EnvironmentArchivedDeploymentPausedReasonError.fromJson(json),
      'environment_not_found_error' =>
        EnvironmentNotFoundDeploymentPausedReasonError.fromJson(json),
      'file_not_found_error' =>
        FileNotFoundDeploymentPausedReasonError.fromJson(json),
      'mcp_egress_blocked_error' =>
        McpEgressBlockedDeploymentPausedReasonError.fromJson(json),
      'memory_store_archived_error' =>
        MemoryStoreArchivedDeploymentPausedReasonError.fromJson(json),
      'organization_disabled_error' =>
        OrganizationDisabledDeploymentPausedReasonError.fromJson(json),
      'self_hosted_resources_unsupported_error' =>
        SelfHostedResourcesUnsupportedDeploymentPausedReasonError.fromJson(
          json,
        ),
      'session_resource_not_found_error' =>
        SessionResourceNotFoundDeploymentPausedReasonError.fromJson(json),
      'skill_not_found_error' =>
        SkillNotFoundDeploymentPausedReasonError.fromJson(json),
      'unknown_error' => UnknownDeploymentPausedReasonError.fromJson(json),
      'vault_archived_error' =>
        VaultArchivedDeploymentPausedReasonError.fromJson(json),
      'vault_not_found_error' =>
        VaultNotFoundDeploymentPausedReasonError.fromJson(json),
      'workspace_archived_error' =>
        WorkspaceArchivedDeploymentPausedReasonError.fromJson(json),
      _ => UnrecognizedDeploymentPausedReasonError.fromJson(json),
    };
  }

  /// The type discriminator.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// The deployment's agent was archived.
@immutable
class AgentArchivedDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates an [AgentArchivedDeploymentPausedReasonError].
  const AgentArchivedDeploymentPausedReasonError();

  /// Creates an [AgentArchivedDeploymentPausedReasonError] from JSON.
  factory AgentArchivedDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'agent_archived_error') {
      throw FormatException(
        'AgentArchivedDeploymentPausedReasonError: expected type '
        '"agent_archived_error", got "$type"',
      );
    }
    return const AgentArchivedDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `agent_archived_error`.
  @override
  String get type => 'agent_archived_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentArchivedDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'AgentArchivedDeploymentPausedReasonError(type: $type)';
}

/// The deployment's environment was archived.
@immutable
class EnvironmentArchivedDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates an [EnvironmentArchivedDeploymentPausedReasonError].
  const EnvironmentArchivedDeploymentPausedReasonError();

  /// Creates an [EnvironmentArchivedDeploymentPausedReasonError] from JSON.
  factory EnvironmentArchivedDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'environment_archived_error') {
      throw FormatException(
        'EnvironmentArchivedDeploymentPausedReasonError: expected type '
        '"environment_archived_error", got "$type"',
      );
    }
    return const EnvironmentArchivedDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `environment_archived_error`.
  @override
  String get type => 'environment_archived_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentArchivedDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() =>
      'EnvironmentArchivedDeploymentPausedReasonError(type: $type)';
}

/// The deployment's environment no longer exists.
@immutable
class EnvironmentNotFoundDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates an [EnvironmentNotFoundDeploymentPausedReasonError].
  const EnvironmentNotFoundDeploymentPausedReasonError();

  /// Creates an [EnvironmentNotFoundDeploymentPausedReasonError] from JSON.
  factory EnvironmentNotFoundDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'environment_not_found_error') {
      throw FormatException(
        'EnvironmentNotFoundDeploymentPausedReasonError: expected type '
        '"environment_not_found_error", got "$type"',
      );
    }
    return const EnvironmentNotFoundDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `environment_not_found_error`.
  @override
  String get type => 'environment_not_found_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentNotFoundDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() =>
      'EnvironmentNotFoundDeploymentPausedReasonError(type: $type)';
}

/// A file resource referenced by the deployment no longer exists.
@immutable
class FileNotFoundDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates a [FileNotFoundDeploymentPausedReasonError].
  const FileNotFoundDeploymentPausedReasonError();

  /// Creates a [FileNotFoundDeploymentPausedReasonError] from JSON.
  factory FileNotFoundDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'file_not_found_error') {
      throw FormatException(
        'FileNotFoundDeploymentPausedReasonError: expected type '
        '"file_not_found_error", got "$type"',
      );
    }
    return const FileNotFoundDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `file_not_found_error`.
  @override
  String get type => 'file_not_found_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileNotFoundDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'FileNotFoundDeploymentPausedReasonError(type: $type)';
}

/// An MCP server host used by the deployment's agent is blocked by the
/// environment's network policy.
@immutable
class McpEgressBlockedDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates a [McpEgressBlockedDeploymentPausedReasonError].
  const McpEgressBlockedDeploymentPausedReasonError();

  /// Creates a [McpEgressBlockedDeploymentPausedReasonError] from JSON.
  factory McpEgressBlockedDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'mcp_egress_blocked_error') {
      throw FormatException(
        'McpEgressBlockedDeploymentPausedReasonError: expected type '
        '"mcp_egress_blocked_error", got "$type"',
      );
    }
    return const McpEgressBlockedDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `mcp_egress_blocked_error`.
  @override
  String get type => 'mcp_egress_blocked_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpEgressBlockedDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() =>
      'McpEgressBlockedDeploymentPausedReasonError(type: $type)';
}

/// A memory store referenced by the deployment is archived.
@immutable
class MemoryStoreArchivedDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates a [MemoryStoreArchivedDeploymentPausedReasonError].
  const MemoryStoreArchivedDeploymentPausedReasonError();

  /// Creates a [MemoryStoreArchivedDeploymentPausedReasonError] from JSON.
  factory MemoryStoreArchivedDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'memory_store_archived_error') {
      throw FormatException(
        'MemoryStoreArchivedDeploymentPausedReasonError: expected type '
        '"memory_store_archived_error", got "$type"',
      );
    }
    return const MemoryStoreArchivedDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `memory_store_archived_error`.
  @override
  String get type => 'memory_store_archived_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryStoreArchivedDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() =>
      'MemoryStoreArchivedDeploymentPausedReasonError(type: $type)';
}

/// The deployment's organization is disabled.
@immutable
class OrganizationDisabledDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates an [OrganizationDisabledDeploymentPausedReasonError].
  const OrganizationDisabledDeploymentPausedReasonError();

  /// Creates an [OrganizationDisabledDeploymentPausedReasonError] from JSON.
  factory OrganizationDisabledDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'organization_disabled_error') {
      throw FormatException(
        'OrganizationDisabledDeploymentPausedReasonError: expected type '
        '"organization_disabled_error", got "$type"',
      );
    }
    return const OrganizationDisabledDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `organization_disabled_error`.
  @override
  String get type => 'organization_disabled_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationDisabledDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() =>
      'OrganizationDisabledDeploymentPausedReasonError(type: $type)';
}

/// The deployment configures resources, but its environment is self-hosted and
/// cannot mount them.
@immutable
class SelfHostedResourcesUnsupportedDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates a [SelfHostedResourcesUnsupportedDeploymentPausedReasonError].
  const SelfHostedResourcesUnsupportedDeploymentPausedReasonError();

  /// Creates a [SelfHostedResourcesUnsupportedDeploymentPausedReasonError]
  /// from JSON.
  factory SelfHostedResourcesUnsupportedDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'self_hosted_resources_unsupported_error') {
      throw FormatException(
        'SelfHostedResourcesUnsupportedDeploymentPausedReasonError: expected '
        'type "self_hosted_resources_unsupported_error", got "$type"',
      );
    }
    return const SelfHostedResourcesUnsupportedDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `self_hosted_resources_unsupported_error`.
  @override
  String get type => 'self_hosted_resources_unsupported_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelfHostedResourcesUnsupportedDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() =>
      'SelfHostedResourcesUnsupportedDeploymentPausedReasonError(type: $type)';
}

/// A referenced resource no longer exists and its kind was not reported.
@immutable
class SessionResourceNotFoundDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates a [SessionResourceNotFoundDeploymentPausedReasonError].
  const SessionResourceNotFoundDeploymentPausedReasonError();

  /// Creates a [SessionResourceNotFoundDeploymentPausedReasonError] from JSON.
  factory SessionResourceNotFoundDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'session_resource_not_found_error') {
      throw FormatException(
        'SessionResourceNotFoundDeploymentPausedReasonError: expected type '
        '"session_resource_not_found_error", got "$type"',
      );
    }
    return const SessionResourceNotFoundDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `session_resource_not_found_error`.
  @override
  String get type => 'session_resource_not_found_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionResourceNotFoundDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() =>
      'SessionResourceNotFoundDeploymentPausedReasonError(type: $type)';
}

/// A skill referenced by the deployment's agent no longer exists.
@immutable
class SkillNotFoundDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates a [SkillNotFoundDeploymentPausedReasonError].
  const SkillNotFoundDeploymentPausedReasonError();

  /// Creates a [SkillNotFoundDeploymentPausedReasonError] from JSON.
  factory SkillNotFoundDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'skill_not_found_error') {
      throw FormatException(
        'SkillNotFoundDeploymentPausedReasonError: expected type '
        '"skill_not_found_error", got "$type"',
      );
    }
    return const SkillNotFoundDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `skill_not_found_error`.
  @override
  String get type => 'skill_not_found_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillNotFoundDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'SkillNotFoundDeploymentPausedReasonError(type: $type)';
}

/// An unrecognized error auto-paused the deployment.
///
/// A fallback variant; matches a run whose `error.type` is `unknown_error`.
@immutable
class UnknownDeploymentPausedReasonError extends DeploymentPausedReasonError {
  /// Creates an [UnknownDeploymentPausedReasonError].
  const UnknownDeploymentPausedReasonError();

  /// Creates an [UnknownDeploymentPausedReasonError] from JSON.
  factory UnknownDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'unknown_error') {
      throw FormatException(
        'UnknownDeploymentPausedReasonError: expected type "unknown_error", '
        'got "$type"',
      );
    }
    return const UnknownDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `unknown_error`.
  @override
  String get type => 'unknown_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'UnknownDeploymentPausedReasonError(type: $type)';
}

/// A vault referenced by the deployment is archived.
@immutable
class VaultArchivedDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates a [VaultArchivedDeploymentPausedReasonError].
  const VaultArchivedDeploymentPausedReasonError();

  /// Creates a [VaultArchivedDeploymentPausedReasonError] from JSON.
  factory VaultArchivedDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'vault_archived_error') {
      throw FormatException(
        'VaultArchivedDeploymentPausedReasonError: expected type '
        '"vault_archived_error", got "$type"',
      );
    }
    return const VaultArchivedDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `vault_archived_error`.
  @override
  String get type => 'vault_archived_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultArchivedDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'VaultArchivedDeploymentPausedReasonError(type: $type)';
}

/// A vault referenced by the deployment no longer exists.
@immutable
class VaultNotFoundDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates a [VaultNotFoundDeploymentPausedReasonError].
  const VaultNotFoundDeploymentPausedReasonError();

  /// Creates a [VaultNotFoundDeploymentPausedReasonError] from JSON.
  factory VaultNotFoundDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'vault_not_found_error') {
      throw FormatException(
        'VaultNotFoundDeploymentPausedReasonError: expected type '
        '"vault_not_found_error", got "$type"',
      );
    }
    return const VaultNotFoundDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `vault_not_found_error`.
  @override
  String get type => 'vault_not_found_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultNotFoundDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'VaultNotFoundDeploymentPausedReasonError(type: $type)';
}

/// The deployment's workspace was archived.
@immutable
class WorkspaceArchivedDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates a [WorkspaceArchivedDeploymentPausedReasonError].
  const WorkspaceArchivedDeploymentPausedReasonError();

  /// Creates a [WorkspaceArchivedDeploymentPausedReasonError] from JSON.
  factory WorkspaceArchivedDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'workspace_archived_error') {
      throw FormatException(
        'WorkspaceArchivedDeploymentPausedReasonError: expected type '
        '"workspace_archived_error", got "$type"',
      );
    }
    return const WorkspaceArchivedDeploymentPausedReasonError();
  }

  /// The type discriminator. Always `workspace_archived_error`.
  @override
  String get type => 'workspace_archived_error';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceArchivedDeploymentPausedReasonError &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() =>
      'WorkspaceArchivedDeploymentPausedReasonError(type: $type)';
}

/// Unrecognized deployment-paused-reason error type (preserves raw JSON for
/// forward compatibility).
///
/// Returned by [DeploymentPausedReasonError.fromJson] when the `type`
/// discriminator does not match any known variant. Distinct from
/// [UnknownDeploymentPausedReasonError], which is the spec's typed
/// `unknown_error` variant.
@immutable
class UnrecognizedDeploymentPausedReasonError
    extends DeploymentPausedReasonError {
  /// Creates an [UnrecognizedDeploymentPausedReasonError].
  const UnrecognizedDeploymentPausedReasonError({required this.rawJson});

  /// Creates an [UnrecognizedDeploymentPausedReasonError] from JSON.
  factory UnrecognizedDeploymentPausedReasonError.fromJson(
    Map<String, dynamic> json,
  ) {
    return UnrecognizedDeploymentPausedReasonError(rawJson: json);
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
      other is UnrecognizedDeploymentPausedReasonError &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() =>
      'UnrecognizedDeploymentPausedReasonError(rawJson: $rawJson)';
}
