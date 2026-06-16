import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../resources/session_resource_params.dart';
import '../sessions/create_session_params.dart' show AgentParams;
import 'deployment_initial_event_params.dart';
import 'schedule_params.dart';

/// Private sentinel to distinguish "not provided" from explicit `null`.
const Object _notSet = Object();

/// Request parameters for updating a `deployment`.
///
/// Omit a field to preserve its current value.
///
/// The non-clearable fields ([agent], [environmentId], [name],
/// [initialEvents]) accept a value or "not provided" — they cannot be cleared.
/// The clearable fields ([description], [metadata], [resources], [schedule],
/// [vaultIds]) additionally accept explicit `null` to clear the value on the
/// server.
@immutable
class UpdateDeploymentParams {
  /// Agent to deploy. Accepts the `agent` ID string, which re-pins to the
  /// latest version, or an `agent` object with both id and version specified.
  /// Omit to preserve. Cannot be cleared.
  final AgentParams? agent;

  /// ID of the `environment` where sessions run. Omit to preserve. Cannot be
  /// cleared.
  final String? environmentId;

  /// Human-readable name. Must be non-empty. Omit to preserve. Cannot be
  /// cleared.
  final String? name;

  /// Initial events. Full replacement. Omit to preserve. Cannot be cleared. At
  /// least 1, maximum 50.
  final List<DeploymentInitialEventParams>? initialEvents;

  /// Description. Omit to preserve; send empty string or null to clear.
  String? get description =>
      _description == _notSet ? null : _description as String?;
  final Object? _description;

  /// Metadata patch. Set a key to a string to upsert it, or to null to delete
  /// it. Omit the field to preserve; send null to clear.
  Map<String, String?>? get metadata =>
      _metadata == _notSet ? null : _metadata as Map<String, String?>?;
  final Object? _metadata;

  /// Session resources. Full replacement. Omit to preserve; send empty array or
  /// null to clear. Maximum 500.
  List<SessionResourceParams>? get resources =>
      _resources == _notSet ? null : _resources as List<SessionResourceParams>?;
  final Object? _resources;

  /// Cron schedule. Full replacement. Omit to preserve; send null to clear
  /// (revert to manual-only).
  ScheduleParams? get schedule =>
      _schedule == _notSet ? null : _schedule as ScheduleParams?;
  final Object? _schedule;

  /// Vault IDs. Full replacement. Omit to preserve; send empty array or null to
  /// clear. Maximum 50.
  List<String>? get vaultIds =>
      _vaultIds == _notSet ? null : _vaultIds as List<String>?;
  final Object? _vaultIds;

  /// Creates an [UpdateDeploymentParams].
  ///
  /// Omit a field to preserve its current value on the server.
  /// Pass `null` explicitly to clear a clearable field.
  const UpdateDeploymentParams({
    this.agent,
    this.environmentId,
    this.name,
    this.initialEvents,
    Object? description = _notSet,
    Object? metadata = _notSet,
    Object? resources = _notSet,
    Object? schedule = _notSet,
    Object? vaultIds = _notSet,
  }) : _description = description,
       _metadata = metadata,
       _resources = resources,
       _schedule = schedule,
       _vaultIds = vaultIds;

  /// Creates an [UpdateDeploymentParams] from JSON.
  factory UpdateDeploymentParams.fromJson(Map<String, dynamic> json) {
    return UpdateDeploymentParams(
      agent: json['agent'] != null
          ? AgentParams.fromJson(json['agent'] as Object)
          : null,
      environmentId: json['environment_id'] as String?,
      name: json['name'] as String?,
      initialEvents: (json['initial_events'] as List?)
          ?.map(
            (e) => DeploymentInitialEventParams.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      description: json.containsKey('description')
          ? json['description'] as String?
          : _notSet,
      metadata: json.containsKey('metadata')
          ? (json['metadata'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as String?),
            )
          : _notSet,
      resources: json.containsKey('resources')
          ? (json['resources'] as List?)
                ?.map(
                  (e) =>
                      SessionResourceParams.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : _notSet,
      schedule: json.containsKey('schedule')
          ? (json['schedule'] != null
                ? ScheduleParams.fromJson(
                    json['schedule'] as Map<String, dynamic>,
                  )
                : null)
          : _notSet,
      vaultIds: json.containsKey('vault_ids')
          ? (json['vault_ids'] as List?)?.map((e) => e as String).toList()
          : _notSet,
    );
  }

  /// Converts to JSON.
  ///
  /// Non-clearable fields are emitted only when a value is provided. Clearable
  /// fields that were not set are omitted; when explicitly set to `null` they
  /// are included as `null` to clear the value on the server.
  Map<String, dynamic> toJson() => {
    if (agent != null) 'agent': agent!.toJson(),
    if (environmentId != null) 'environment_id': environmentId,
    if (name != null) 'name': name,
    if (initialEvents != null)
      'initial_events': initialEvents!.map((e) => e.toJson()).toList(),
    if (_description != _notSet) 'description': _description,
    if (_metadata != _notSet) 'metadata': _metadata,
    if (_resources != _notSet)
      'resources': (_resources as List<SessionResourceParams>?)
          ?.map((e) => e.toJson())
          .toList(),
    if (_schedule != _notSet)
      'schedule': (_schedule as ScheduleParams?)?.toJson(),
    if (_vaultIds != _notSet) 'vault_ids': _vaultIds,
  };

  /// Creates a copy with replaced values.
  UpdateDeploymentParams copyWith({
    Object? agent = unsetCopyWithValue,
    Object? environmentId = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? initialEvents = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? resources = unsetCopyWithValue,
    Object? schedule = unsetCopyWithValue,
    Object? vaultIds = unsetCopyWithValue,
  }) {
    return UpdateDeploymentParams(
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentParams?,
      environmentId: environmentId == unsetCopyWithValue
          ? this.environmentId
          : environmentId as String?,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      initialEvents: initialEvents == unsetCopyWithValue
          ? this.initialEvents
          : initialEvents as List<DeploymentInitialEventParams>?,
      description: description == unsetCopyWithValue
          ? _description
          : description,
      metadata: metadata == unsetCopyWithValue ? _metadata : metadata,
      resources: resources == unsetCopyWithValue ? _resources : resources,
      schedule: schedule == unsetCopyWithValue ? _schedule : schedule,
      vaultIds: vaultIds == unsetCopyWithValue ? _vaultIds : vaultIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateDeploymentParams &&
          runtimeType == other.runtimeType &&
          agent == other.agent &&
          environmentId == other.environmentId &&
          name == other.name &&
          listsEqual(initialEvents, other.initialEvents) &&
          _description == other._description &&
          _mapsEqualOrBothSentinel(_metadata, other._metadata) &&
          _listsEqualOrBothSentinel(_resources, other._resources) &&
          _schedule == other._schedule &&
          _listsEqualOrBothSentinel(_vaultIds, other._vaultIds);

  @override
  int get hashCode => Object.hash(
    agent,
    environmentId,
    name,
    listHash(initialEvents),
    _description,
    _metadata == _notSet ? _notSet : mapHash(metadata),
    _resources == _notSet ? _notSet : listHash(resources),
    _schedule,
    _vaultIds == _notSet ? _notSet : listHash(vaultIds),
  );

  @override
  String toString() =>
      'UpdateDeploymentParams('
      'agent: $agent, '
      'environmentId: $environmentId, '
      'name: $name, '
      'initialEvents: ${initialEvents == null ? null : '${initialEvents!.length} items'}, '
      'description: $description, '
      'metadata: $metadata, '
      'resources: $resources, '
      'schedule: $schedule, '
      'vaultIds: $vaultIds)';
}

bool _listsEqualOrBothSentinel(Object? a, Object? b) {
  if (identical(a, _notSet) && identical(b, _notSet)) return true;
  if (identical(a, _notSet) || identical(b, _notSet)) return false;
  return listsEqual(a as List?, b as List?);
}

bool _mapsEqualOrBothSentinel(Object? a, Object? b) {
  if (identical(a, _notSet) && identical(b, _notSet)) return true;
  if (identical(a, _notSet) || identical(b, _notSet)) return false;
  return mapsEqual(a as Map?, b as Map?);
}
