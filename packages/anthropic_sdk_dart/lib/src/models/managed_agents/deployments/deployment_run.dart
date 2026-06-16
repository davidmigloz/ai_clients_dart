import 'package:meta/meta.dart';

import '../../beta_timestamp.dart';
import '../../common/copy_with_sentinel.dart';
import '../agents/multiagent.dart' show AgentReference;
import 'run_error.dart';
import 'trigger_context.dart';

/// A persistent, append-only record of a single deployment execution.
///
/// Records session creation success or failure — no session lifecycle
/// tracking. Exactly one of [sessionId] or [error] is non-null.
@immutable
class DeploymentRun {
  /// Object type. Always "deployment_run".
  final String type;

  /// Unique identifier for this run (`drun_...`).
  final String id;

  /// ID of the deployment that produced this run.
  final String deploymentId;

  /// What triggered this run and trigger-specific metadata.
  final TriggerContext triggerContext;

  /// Populated on success. Null on creation failure. Exactly one of
  /// [sessionId] or [error] is non-null.
  final String? sessionId;

  /// Populated on creation failure. Null on success. Exactly one of
  /// [sessionId] or [error] is non-null.
  final RunError? error;

  /// Snapshot of the agent at fire time. Always fully resolved — deployments
  /// pin agent + version.
  final AgentReference agent;

  /// Time this run record was persisted.
  final BetaTimestamp createdAt;

  /// Creates a [DeploymentRun].
  const DeploymentRun({
    this.type = 'deployment_run',
    required this.id,
    required this.deploymentId,
    required this.triggerContext,
    required this.sessionId,
    required this.error,
    required this.agent,
    required this.createdAt,
  });

  /// Creates a [DeploymentRun] from JSON.
  factory DeploymentRun.fromJson(Map<String, dynamic> json) {
    return DeploymentRun(
      type: json['type'] as String? ?? 'deployment_run',
      id: json['id'] as String,
      deploymentId: json['deployment_id'] as String,
      triggerContext: TriggerContext.fromJson(
        json['trigger_context'] as Map<String, dynamic>,
      ),
      sessionId: json['session_id'] as String?,
      error: json['error'] != null
          ? RunError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      agent: AgentReference.fromJson(json['agent'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'deployment_id': deploymentId,
    'trigger_context': triggerContext.toJson(),
    'session_id': sessionId,
    'error': error?.toJson(),
    'agent': agent.toJson(),
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  DeploymentRun copyWith({
    String? type,
    String? id,
    String? deploymentId,
    TriggerContext? triggerContext,
    Object? sessionId = unsetCopyWithValue,
    Object? error = unsetCopyWithValue,
    AgentReference? agent,
    BetaTimestamp? createdAt,
  }) {
    return DeploymentRun(
      type: type ?? this.type,
      id: id ?? this.id,
      deploymentId: deploymentId ?? this.deploymentId,
      triggerContext: triggerContext ?? this.triggerContext,
      sessionId: sessionId == unsetCopyWithValue
          ? this.sessionId
          : sessionId as String?,
      error: error == unsetCopyWithValue ? this.error : error as RunError?,
      agent: agent ?? this.agent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentRun &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          deploymentId == other.deploymentId &&
          triggerContext == other.triggerContext &&
          sessionId == other.sessionId &&
          error == other.error &&
          agent == other.agent &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    type,
    id,
    deploymentId,
    triggerContext,
    sessionId,
    error,
    agent,
    createdAt,
  );

  @override
  String toString() =>
      'DeploymentRun('
      'type: $type, '
      'id: $id, '
      'deploymentId: $deploymentId, '
      'triggerContext: $triggerContext, '
      'sessionId: $sessionId, '
      'error: $error, '
      'agent: $agent, '
      'createdAt: $createdAt)';
}
