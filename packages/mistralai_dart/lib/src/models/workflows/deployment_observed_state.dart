import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'deployment_build_state.dart';

/// The observed runtime state of a managed workflow deployment.
@immutable
class DeploymentObservedState {
  /// The number of available replicas.
  final int availableReplicas;

  /// The current build state, if a build is in progress or has run.
  final DeploymentBuildState? buildState;

  /// The revision currently deployed.
  final String? deployedRevision;

  /// The endpoint the deployment is reachable at.
  final String? endpoint;

  /// The observed generation.
  final int? generation;

  /// When the deployment was last seen alive.
  final String? lastSeen;

  /// A human-readable status message.
  final String? message;

  /// The deployment phase.
  final String? phase;

  /// The number of ready replicas.
  final int readyReplicas;

  /// Creates a [DeploymentObservedState].
  const DeploymentObservedState({
    this.availableReplicas = 0,
    this.buildState,
    this.deployedRevision,
    this.endpoint,
    this.generation,
    this.lastSeen,
    this.message,
    this.phase,
    this.readyReplicas = 0,
  });

  /// Creates a [DeploymentObservedState] from JSON.
  factory DeploymentObservedState.fromJson(Map<String, dynamic> json) =>
      DeploymentObservedState(
        availableReplicas: json['available_replicas'] as int? ?? 0,
        buildState: json['build_state'] != null
            ? DeploymentBuildState.fromJson(
                json['build_state'] as Map<String, dynamic>,
              )
            : null,
        deployedRevision: json['deployed_revision'] as String?,
        endpoint: json['endpoint'] as String?,
        generation: json['generation'] as int?,
        lastSeen: json['last_seen'] as String?,
        message: json['message'] as String?,
        phase: json['phase'] as String?,
        readyReplicas: json['ready_replicas'] as int? ?? 0,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'available_replicas': availableReplicas,
    if (buildState != null) 'build_state': buildState!.toJson(),
    if (deployedRevision != null) 'deployed_revision': deployedRevision,
    if (endpoint != null) 'endpoint': endpoint,
    if (generation != null) 'generation': generation,
    if (lastSeen != null) 'last_seen': lastSeen,
    if (message != null) 'message': message,
    if (phase != null) 'phase': phase,
    'ready_replicas': readyReplicas,
  };

  /// Creates a copy with replaced values.
  DeploymentObservedState copyWith({
    int? availableReplicas,
    Object? buildState = unsetCopyWithValue,
    Object? deployedRevision = unsetCopyWithValue,
    Object? endpoint = unsetCopyWithValue,
    Object? generation = unsetCopyWithValue,
    Object? lastSeen = unsetCopyWithValue,
    Object? message = unsetCopyWithValue,
    Object? phase = unsetCopyWithValue,
    int? readyReplicas,
  }) {
    return DeploymentObservedState(
      availableReplicas: availableReplicas ?? this.availableReplicas,
      buildState: buildState == unsetCopyWithValue
          ? this.buildState
          : buildState as DeploymentBuildState?,
      deployedRevision: deployedRevision == unsetCopyWithValue
          ? this.deployedRevision
          : deployedRevision as String?,
      endpoint: endpoint == unsetCopyWithValue
          ? this.endpoint
          : endpoint as String?,
      generation: generation == unsetCopyWithValue
          ? this.generation
          : generation as int?,
      lastSeen: lastSeen == unsetCopyWithValue
          ? this.lastSeen
          : lastSeen as String?,
      message: message == unsetCopyWithValue
          ? this.message
          : message as String?,
      phase: phase == unsetCopyWithValue ? this.phase : phase as String?,
      readyReplicas: readyReplicas ?? this.readyReplicas,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentObservedState) return false;
    if (runtimeType != other.runtimeType) return false;
    return availableReplicas == other.availableReplicas &&
        buildState == other.buildState &&
        deployedRevision == other.deployedRevision &&
        endpoint == other.endpoint &&
        generation == other.generation &&
        lastSeen == other.lastSeen &&
        message == other.message &&
        phase == other.phase &&
        readyReplicas == other.readyReplicas;
  }

  @override
  int get hashCode => Object.hash(
    availableReplicas,
    buildState,
    deployedRevision,
    endpoint,
    generation,
    lastSeen,
    message,
    phase,
    readyReplicas,
  );

  @override
  String toString() =>
      'DeploymentObservedState('
      'availableReplicas: $availableReplicas, '
      'buildState: $buildState, '
      'deployedRevision: $deployedRevision, '
      'endpoint: $endpoint, '
      'generation: $generation, '
      'lastSeen: $lastSeen, '
      'message: $message, '
      'phase: $phase, '
      'readyReplicas: $readyReplicas'
      ')';
}
