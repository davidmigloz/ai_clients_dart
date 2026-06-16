import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../resources/session_resource_params.dart';
import '../sessions/create_session_params.dart' show AgentParams;
import 'deployment_initial_event_params.dart';
import 'schedule_params.dart';

/// Request parameters for creating a `deployment`.
@immutable
class CreateDeploymentParams {
  /// Agent to deploy. Accepts the `agent` ID string, which pins the latest
  /// version, or an `agent` object with both id and version specified. The
  /// agent must exist and not be archived.
  final AgentParams agent;

  /// ID of the `environment` defining the container configuration for sessions
  /// created from this deployment.
  final String environmentId;

  /// Human-readable name for the deployment.
  final String name;

  /// Events to send to each session immediately after creation. At least 1,
  /// maximum 50.
  final List<DeploymentInitialEventParams> initialEvents;

  /// Description of what the deployment does.
  final String? description;

  /// Arbitrary key-value metadata. Maximum 16 pairs, keys up to 64 chars,
  /// values up to 512 chars.
  final Map<String, String>? metadata;

  /// Resources (e.g. repositories, files) to mount into each session's
  /// container. Maximum 500.
  final List<SessionResourceParams>? resources;

  /// Optional recurring cron schedule. When present, the deployment fires
  /// automatically.
  final ScheduleParams? schedule;

  /// Vault IDs for stored credentials the agent can use during sessions created
  /// from this deployment. Maximum 50.
  final List<String>? vaultIds;

  /// Creates a [CreateDeploymentParams].
  const CreateDeploymentParams({
    required this.agent,
    required this.environmentId,
    required this.name,
    required this.initialEvents,
    this.description,
    this.metadata,
    this.resources,
    this.schedule,
    this.vaultIds,
  });

  /// Creates a [CreateDeploymentParams] from JSON.
  factory CreateDeploymentParams.fromJson(Map<String, dynamic> json) {
    return CreateDeploymentParams(
      agent: AgentParams.fromJson(json['agent'] as Object),
      environmentId: json['environment_id'] as String,
      name: json['name'] as String,
      initialEvents: (json['initial_events'] as List)
          .map(
            (e) => DeploymentInitialEventParams.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      description: json['description'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
      resources: (json['resources'] as List?)
          ?.map(
            (e) => SessionResourceParams.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      schedule: json['schedule'] != null
          ? ScheduleParams.fromJson(json['schedule'] as Map<String, dynamic>)
          : null,
      vaultIds: (json['vault_ids'] as List?)?.map((e) => e as String).toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'agent': agent.toJson(),
    'environment_id': environmentId,
    'name': name,
    'initial_events': initialEvents.map((e) => e.toJson()).toList(),
    if (description != null) 'description': description,
    if (metadata != null) 'metadata': metadata,
    if (resources != null)
      'resources': resources!.map((e) => e.toJson()).toList(),
    if (schedule != null) 'schedule': schedule!.toJson(),
    if (vaultIds != null) 'vault_ids': vaultIds,
  };

  /// Creates a copy with replaced values.
  CreateDeploymentParams copyWith({
    AgentParams? agent,
    String? environmentId,
    String? name,
    List<DeploymentInitialEventParams>? initialEvents,
    Object? description = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? resources = unsetCopyWithValue,
    Object? schedule = unsetCopyWithValue,
    Object? vaultIds = unsetCopyWithValue,
  }) {
    return CreateDeploymentParams(
      agent: agent ?? this.agent,
      environmentId: environmentId ?? this.environmentId,
      name: name ?? this.name,
      initialEvents: initialEvents ?? this.initialEvents,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
      resources: resources == unsetCopyWithValue
          ? this.resources
          : resources as List<SessionResourceParams>?,
      schedule: schedule == unsetCopyWithValue
          ? this.schedule
          : schedule as ScheduleParams?,
      vaultIds: vaultIds == unsetCopyWithValue
          ? this.vaultIds
          : vaultIds as List<String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateDeploymentParams &&
          runtimeType == other.runtimeType &&
          agent == other.agent &&
          environmentId == other.environmentId &&
          name == other.name &&
          listsEqual(initialEvents, other.initialEvents) &&
          description == other.description &&
          mapsEqual(metadata, other.metadata) &&
          listsEqual(resources, other.resources) &&
          schedule == other.schedule &&
          listsEqual(vaultIds, other.vaultIds);

  @override
  int get hashCode => Object.hash(
    agent,
    environmentId,
    name,
    listHash(initialEvents),
    description,
    mapHash(metadata),
    listHash(resources),
    schedule,
    listHash(vaultIds),
  );

  @override
  String toString() =>
      'CreateDeploymentParams('
      'agent: $agent, '
      'environmentId: $environmentId, '
      'name: $name, '
      'initialEvents: ${initialEvents.length} items, '
      'description: $description, '
      'metadata: $metadata, '
      'resources: $resources, '
      'schedule: $schedule, '
      'vaultIds: $vaultIds)';
}
