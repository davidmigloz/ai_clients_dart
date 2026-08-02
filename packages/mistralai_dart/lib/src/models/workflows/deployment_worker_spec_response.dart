import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Worker spec as reported by a managed workflow deployment.
@immutable
class DeploymentWorkerSpecResponse {
  /// The GitHub repository URL the worker was built from.
  final String githubUrl;

  /// The worker entrypoint.
  final String? entrypoint;

  /// The Git revision that was built.
  final String? revision;

  /// The working directory within the repository.
  final String? workingDir;

  /// The resolved commit SHA that was built.
  final String? commitSha;

  /// When the worker was last restarted.
  final String? restartedAt;

  /// The worker spec type (default `workflows_worker`).
  final String type;

  /// Creates a [DeploymentWorkerSpecResponse].
  const DeploymentWorkerSpecResponse({
    required this.githubUrl,
    this.entrypoint,
    this.revision,
    this.workingDir,
    this.commitSha,
    this.restartedAt,
    this.type = 'workflows_worker',
  });

  /// Creates a [DeploymentWorkerSpecResponse] from JSON.
  factory DeploymentWorkerSpecResponse.fromJson(Map<String, dynamic> json) {
    final githubUrl = json['github_url'] as String?;
    if (githubUrl == null) {
      throw const FormatException(
        'DeploymentWorkerSpecResponse: missing required field "github_url"',
      );
    }
    return DeploymentWorkerSpecResponse(
      githubUrl: githubUrl,
      entrypoint: json['entrypoint'] as String?,
      revision: json['revision'] as String?,
      workingDir: json['working_dir'] as String?,
      commitSha: json['commit_sha'] as String?,
      restartedAt: json['restarted_at'] as String?,
      type: json['type'] as String? ?? 'workflows_worker',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'github_url': githubUrl,
    if (entrypoint != null) 'entrypoint': entrypoint,
    if (revision != null) 'revision': revision,
    if (workingDir != null) 'working_dir': workingDir,
    if (commitSha != null) 'commit_sha': commitSha,
    if (restartedAt != null) 'restarted_at': restartedAt,
    'type': type,
  };

  /// Creates a copy with replaced values.
  DeploymentWorkerSpecResponse copyWith({
    String? githubUrl,
    Object? entrypoint = unsetCopyWithValue,
    Object? revision = unsetCopyWithValue,
    Object? workingDir = unsetCopyWithValue,
    Object? commitSha = unsetCopyWithValue,
    Object? restartedAt = unsetCopyWithValue,
    String? type,
  }) {
    return DeploymentWorkerSpecResponse(
      githubUrl: githubUrl ?? this.githubUrl,
      entrypoint: entrypoint == unsetCopyWithValue
          ? this.entrypoint
          : entrypoint as String?,
      revision: revision == unsetCopyWithValue
          ? this.revision
          : revision as String?,
      workingDir: workingDir == unsetCopyWithValue
          ? this.workingDir
          : workingDir as String?,
      commitSha: commitSha == unsetCopyWithValue
          ? this.commitSha
          : commitSha as String?,
      restartedAt: restartedAt == unsetCopyWithValue
          ? this.restartedAt
          : restartedAt as String?,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentWorkerSpecResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return githubUrl == other.githubUrl &&
        entrypoint == other.entrypoint &&
        revision == other.revision &&
        workingDir == other.workingDir &&
        commitSha == other.commitSha &&
        restartedAt == other.restartedAt &&
        type == other.type;
  }

  @override
  int get hashCode => Object.hash(
    githubUrl,
    entrypoint,
    revision,
    workingDir,
    commitSha,
    restartedAt,
    type,
  );

  @override
  String toString() =>
      'DeploymentWorkerSpecResponse('
      'githubUrl: $githubUrl, '
      'entrypoint: $entrypoint, '
      'revision: $revision, '
      'workingDir: $workingDir, '
      'commitSha: $commitSha, '
      'restartedAt: $restartedAt, '
      'type: $type'
      ')';
}
