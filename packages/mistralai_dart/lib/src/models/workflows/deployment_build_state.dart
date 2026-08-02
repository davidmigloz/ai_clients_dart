import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// The build state of a managed workflow deployment.
@immutable
class DeploymentBuildState {
  /// The commit SHA being built.
  final String? commitSha;

  /// When the build finished.
  final String? finishedAt;

  /// The built container image reference.
  final String? image;

  /// A human-readable build status message.
  final String? message;

  /// The build phase.
  final String? phase;

  /// When the build started.
  final String? startedAt;

  /// Creates a [DeploymentBuildState].
  const DeploymentBuildState({
    this.commitSha,
    this.finishedAt,
    this.image,
    this.message,
    this.phase,
    this.startedAt,
  });

  /// Creates a [DeploymentBuildState] from JSON.
  factory DeploymentBuildState.fromJson(Map<String, dynamic> json) =>
      DeploymentBuildState(
        commitSha: json['commit_sha'] as String?,
        finishedAt: json['finished_at'] as String?,
        image: json['image'] as String?,
        message: json['message'] as String?,
        phase: json['phase'] as String?,
        startedAt: json['started_at'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (commitSha != null) 'commit_sha': commitSha,
    if (finishedAt != null) 'finished_at': finishedAt,
    if (image != null) 'image': image,
    if (message != null) 'message': message,
    if (phase != null) 'phase': phase,
    if (startedAt != null) 'started_at': startedAt,
  };

  /// Creates a copy with replaced values.
  DeploymentBuildState copyWith({
    Object? commitSha = unsetCopyWithValue,
    Object? finishedAt = unsetCopyWithValue,
    Object? image = unsetCopyWithValue,
    Object? message = unsetCopyWithValue,
    Object? phase = unsetCopyWithValue,
    Object? startedAt = unsetCopyWithValue,
  }) {
    return DeploymentBuildState(
      commitSha: commitSha == unsetCopyWithValue
          ? this.commitSha
          : commitSha as String?,
      finishedAt: finishedAt == unsetCopyWithValue
          ? this.finishedAt
          : finishedAt as String?,
      image: image == unsetCopyWithValue ? this.image : image as String?,
      message: message == unsetCopyWithValue
          ? this.message
          : message as String?,
      phase: phase == unsetCopyWithValue ? this.phase : phase as String?,
      startedAt: startedAt == unsetCopyWithValue
          ? this.startedAt
          : startedAt as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentBuildState) return false;
    if (runtimeType != other.runtimeType) return false;
    return commitSha == other.commitSha &&
        finishedAt == other.finishedAt &&
        image == other.image &&
        message == other.message &&
        phase == other.phase &&
        startedAt == other.startedAt;
  }

  @override
  int get hashCode =>
      Object.hash(commitSha, finishedAt, image, message, phase, startedAt);

  @override
  String toString() =>
      'DeploymentBuildState('
      'commitSha: $commitSha, '
      'finishedAt: $finishedAt, '
      'image: $image, '
      'message: $message, '
      'phase: $phase, '
      'startedAt: $startedAt'
      ')';
}
