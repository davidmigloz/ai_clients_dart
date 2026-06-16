import 'package:meta/meta.dart';

import '../../beta_timestamp.dart';
import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../agents/multiagent.dart' show AgentReference;
import 'deployment_initial_event.dart';
import 'deployment_paused_reason.dart';
import 'deployment_status.dart';
import 'schedule.dart';
import 'session_resource_config.dart';

/// A configured instance of an agent that binds it to everything needed to run
/// autonomously: an environment, credentials, initial events, and an optional
/// schedule.
@immutable
class Deployment {
  /// Object type. Always "deployment".
  final String type;

  /// Unique identifier for this deployment.
  final String id;

  /// Human-readable name.
  final String name;

  /// Description of what the deployment does. Null if unset.
  final String? description;

  /// Reference to the agent this deployment runs, resolved to a concrete
  /// version.
  final AgentReference agent;

  /// ID of the `environment` where sessions run.
  final String environmentId;

  /// Vault IDs supplying stored credentials for sessions created from this
  /// deployment.
  final List<String> vaultIds;

  /// Events sent to each session immediately after creation.
  final List<DeploymentInitialEvent> initialEvents;

  /// Resources attached to sessions created from this deployment. Echoes the
  /// input minus write-only credentials.
  final List<SessionResourceConfig> resources;

  /// Arbitrary key-value metadata. Maximum 16 pairs.
  final Map<String, String> metadata;

  /// Recurring cron schedule. Presence enables scheduled execution; null means
  /// manual-only. Includes computed timestamps (next fire times, last run) on
  /// the cron variant.
  final Schedule? schedule;

  /// Computed status of the deployment: `active` or `paused`. Archived
  /// deployments report `active` with `archived_at` set.
  final DeploymentStatus status;

  /// Why the deployment is paused. Non-null exactly when status is paused; null
  /// otherwise.
  final DeploymentPausedReason? pausedReason;

  /// Time the deployment was created.
  final BetaTimestamp createdAt;

  /// Time the deployment was last updated.
  final BetaTimestamp updatedAt;

  /// Time the deployment was archived. Null if not archived.
  final BetaTimestamp? archivedAt;

  /// Creates a [Deployment].
  const Deployment({
    this.type = 'deployment',
    required this.id,
    required this.name,
    required this.description,
    required this.agent,
    required this.environmentId,
    required this.vaultIds,
    required this.initialEvents,
    required this.resources,
    required this.metadata,
    required this.schedule,
    required this.status,
    required this.pausedReason,
    required this.createdAt,
    required this.updatedAt,
    required this.archivedAt,
  });

  /// Creates a [Deployment] from JSON.
  factory Deployment.fromJson(Map<String, dynamic> json) {
    return Deployment(
      type: json['type'] as String? ?? 'deployment',
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      agent: AgentReference.fromJson(json['agent'] as Map<String, dynamic>),
      environmentId: json['environment_id'] as String,
      vaultIds: (json['vault_ids'] as List).map((e) => e as String).toList(),
      initialEvents: (json['initial_events'] as List)
          .map(
            (e) => DeploymentInitialEvent.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      resources: (json['resources'] as List)
          .map((e) => SessionResourceConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: (json['metadata'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v as String),
      ),
      schedule: json['schedule'] != null
          ? Schedule.fromJson(json['schedule'] as Map<String, dynamic>)
          : null,
      status: DeploymentStatus.fromJson(json['status'] as String),
      pausedReason: json['paused_reason'] != null
          ? DeploymentPausedReason.fromJson(
              json['paused_reason'] as Map<String, dynamic>,
            )
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'description': description,
    'agent': agent.toJson(),
    'environment_id': environmentId,
    'vault_ids': vaultIds,
    'initial_events': initialEvents.map((e) => e.toJson()).toList(),
    'resources': resources.map((e) => e.toJson()).toList(),
    'metadata': metadata,
    'schedule': schedule?.toJson(),
    'status': status.toJson(),
    'paused_reason': pausedReason?.toJson(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'archived_at': archivedAt?.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  Deployment copyWith({
    String? type,
    String? id,
    String? name,
    Object? description = unsetCopyWithValue,
    AgentReference? agent,
    String? environmentId,
    List<String>? vaultIds,
    List<DeploymentInitialEvent>? initialEvents,
    List<SessionResourceConfig>? resources,
    Map<String, String>? metadata,
    Object? schedule = unsetCopyWithValue,
    DeploymentStatus? status,
    Object? pausedReason = unsetCopyWithValue,
    BetaTimestamp? createdAt,
    BetaTimestamp? updatedAt,
    Object? archivedAt = unsetCopyWithValue,
  }) {
    return Deployment(
      type: type ?? this.type,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      agent: agent ?? this.agent,
      environmentId: environmentId ?? this.environmentId,
      vaultIds: vaultIds ?? this.vaultIds,
      initialEvents: initialEvents ?? this.initialEvents,
      resources: resources ?? this.resources,
      metadata: metadata ?? this.metadata,
      schedule: schedule == unsetCopyWithValue
          ? this.schedule
          : schedule as Schedule?,
      status: status ?? this.status,
      pausedReason: pausedReason == unsetCopyWithValue
          ? this.pausedReason
          : pausedReason as DeploymentPausedReason?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt == unsetCopyWithValue
          ? this.archivedAt
          : archivedAt as BetaTimestamp?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Deployment &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          agent == other.agent &&
          environmentId == other.environmentId &&
          listsEqual(vaultIds, other.vaultIds) &&
          listsEqual(initialEvents, other.initialEvents) &&
          listsEqual(resources, other.resources) &&
          mapsEqual(metadata, other.metadata) &&
          schedule == other.schedule &&
          status == other.status &&
          pausedReason == other.pausedReason &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          archivedAt == other.archivedAt;

  @override
  int get hashCode => Object.hash(
    type,
    id,
    name,
    description,
    agent,
    environmentId,
    listHash(vaultIds),
    listHash(initialEvents),
    listHash(resources),
    mapHash(metadata),
    schedule,
    status,
    pausedReason,
    createdAt,
    updatedAt,
    archivedAt,
  );

  @override
  String toString() =>
      'Deployment('
      'type: $type, '
      'id: $id, '
      'name: $name, '
      'description: $description, '
      'agent: $agent, '
      'environmentId: $environmentId, '
      'vaultIds: ${vaultIds.length} items, '
      'initialEvents: ${initialEvents.length} items, '
      'resources: ${resources.length} items, '
      'metadata: ${metadata.length} entries, '
      'schedule: $schedule, '
      'status: $status, '
      'pausedReason: $pausedReason, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'archivedAt: $archivedAt)';
}
