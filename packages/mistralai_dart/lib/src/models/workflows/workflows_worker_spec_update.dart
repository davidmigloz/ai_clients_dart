import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'deployment_backend_spec.dart';

/// Partial worker spec update for a managed workflow deployment.
///
/// All fields are optional; only the provided fields are updated.
@immutable
class WorkflowsWorkerSpecUpdate {
  /// Legacy worker entrypoint. Configure this in the Dockerfile.
  final String? entrypoint;

  /// Legacy GitHub repository URL. Prefer [repositoryUrl].
  final String? githubUrl;

  /// The Git revision to build.
  final String? revision;

  /// Legacy working directory. Use the Dockerfile for the working directory.
  final String? workingDir;

  /// Repository URL on GitHub or the Mistral git server.
  final String? repositoryUrl;

  /// The archive ID to build from instead of a repository.
  final String? archiveId;

  /// Backend-specific deployment configuration.
  final DeploymentMistralCloudBackendSpec? backendSpec;

  /// Additional runtime workspace roles. Send an empty list to remove existing extras.
  final List<String>? requestedRoles;

  /// Creates a [WorkflowsWorkerSpecUpdate].
  const WorkflowsWorkerSpecUpdate({
    this.repositoryUrl,
    this.archiveId,
    this.backendSpec,
    this.requestedRoles,
    this.entrypoint,
    this.githubUrl,
    this.revision,
    this.workingDir,
  });

  /// Creates a [WorkflowsWorkerSpecUpdate] from JSON.
  factory WorkflowsWorkerSpecUpdate.fromJson(Map<String, dynamic> json) =>
      WorkflowsWorkerSpecUpdate(
        repositoryUrl: json['repository_url'] as String?,
        archiveId: json['archive_id'] as String?,
        backendSpec: json['backend_spec'] == null
            ? null
            : DeploymentMistralCloudBackendSpec.fromJson(
                json['backend_spec'] as Map<String, dynamic>,
              ),
        requestedRoles: (json['requested_roles'] as List<dynamic>?)
            ?.cast<String>(),
        entrypoint: json['entrypoint'] as String?,
        githubUrl: json['github_url'] as String?,
        revision: json['revision'] as String?,
        workingDir: json['working_dir'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    final hasRepository = repositoryUrl != null || githubUrl != null;
    if (repositoryUrl != null && githubUrl != null) {
      throw ArgumentError('Use only repositoryUrl for a GitHub repository');
    }
    if (archiveId != null && hasRepository) {
      throw ArgumentError('Use either a repository or a deployment archive');
    }
    if (archiveId != null && backendSpec?.buildDirectory != null) {
      throw ArgumentError('The archive is the whole build directory');
    }
    return {
      if (repositoryUrl != null) 'repository_url': repositoryUrl,
      if (archiveId != null) 'archive_id': archiveId,
      if (backendSpec != null) 'backend_spec': backendSpec!.toJson(),
      if (requestedRoles != null) 'requested_roles': requestedRoles,
      if (githubUrl != null) 'github_url': githubUrl,
      if (revision != null && archiveId == null) 'revision': revision,
    };
  }

  /// Creates a copy with replaced values.
  WorkflowsWorkerSpecUpdate copyWith({
    Object? repositoryUrl = unsetCopyWithValue,
    Object? archiveId = unsetCopyWithValue,
    Object? backendSpec = unsetCopyWithValue,
    Object? requestedRoles = unsetCopyWithValue,
    Object? entrypoint = unsetCopyWithValue,
    Object? githubUrl = unsetCopyWithValue,
    Object? revision = unsetCopyWithValue,
    Object? workingDir = unsetCopyWithValue,
  }) {
    return WorkflowsWorkerSpecUpdate(
      repositoryUrl: repositoryUrl == unsetCopyWithValue
          ? this.repositoryUrl
          : repositoryUrl as String?,
      archiveId: archiveId == unsetCopyWithValue
          ? this.archiveId
          : archiveId as String?,
      backendSpec: backendSpec == unsetCopyWithValue
          ? this.backendSpec
          : backendSpec as DeploymentMistralCloudBackendSpec?,
      requestedRoles: requestedRoles == unsetCopyWithValue
          ? this.requestedRoles
          : requestedRoles as List<String>?,
      entrypoint: entrypoint == unsetCopyWithValue
          ? this.entrypoint
          : entrypoint as String?,
      githubUrl: githubUrl == unsetCopyWithValue
          ? this.githubUrl
          : githubUrl as String?,
      revision: revision == unsetCopyWithValue
          ? this.revision
          : revision as String?,
      workingDir: workingDir == unsetCopyWithValue
          ? this.workingDir
          : workingDir as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowsWorkerSpecUpdate) return false;
    if (runtimeType != other.runtimeType) return false;
    return repositoryUrl == other.repositoryUrl &&
        archiveId == other.archiveId &&
        backendSpec == other.backendSpec &&
        listsEqual(requestedRoles, other.requestedRoles) &&
        entrypoint == other.entrypoint &&
        githubUrl == other.githubUrl &&
        revision == other.revision &&
        workingDir == other.workingDir;
  }

  @override
  int get hashCode => Object.hashAll([
    entrypoint,
    githubUrl,
    revision,
    workingDir,
    repositoryUrl,
    archiveId,
    backendSpec,
    listHash(requestedRoles),
  ]);

  @override
  String toString() =>
      'WorkflowsWorkerSpecUpdate(repositoryUrl: $repositoryUrl, archiveId: $archiveId, backendSpec: $backendSpec, requestedRoles: ${requestedRoles?.length}, '
      'entrypoint: $entrypoint, '
      'githubUrl: $githubUrl, '
      'revision: $revision, '
      'workingDir: $workingDir'
      ')';
}
