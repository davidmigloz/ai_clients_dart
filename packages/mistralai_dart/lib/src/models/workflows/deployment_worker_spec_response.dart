import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'deployment_backend_spec.dart';
import 'git_commit_metadata.dart';

/// Worker spec as reported by a managed workflow deployment.
@immutable
class DeploymentWorkerSpecResponse {
  /// The GitHub repository URL the worker was built from.
  final String githubUrl;

  /// The worker entrypoint.
  String? get entrypoint => switch (backendSpec) {
    DeploymentK8sBackendSpec(:final entrypoint) =>
      entrypoint ?? _legacyEntrypoint,
    _ => _legacyEntrypoint,
  };

  final String? _legacyEntrypoint;

  /// The Git revision that was built.
  final String? revision;

  /// The working directory within the repository.
  String? get workingDir => switch (backendSpec) {
    DeploymentK8sBackendSpec(:final workingDir) =>
      workingDir ?? _legacyWorkingDir,
    _ => _legacyWorkingDir,
  };

  final String? _legacyWorkingDir;

  /// The resolved commit SHA that was built.
  String? get commitSha => commit?.sha ?? _legacyCommitSha;

  final String? _legacyCommitSha;

  /// When the worker was last restarted.
  final String? restartedAt;

  /// The worker spec type (default `workflows_worker`).
  final String type;

  /// Repository URL on GitHub or the Mistral git server.
  final String? repositoryUrl;

  /// The archive ID to build from instead of a repository.
  final String? archiveId;

  /// Backend-specific deployment configuration.
  final DeploymentBackendSpec backendSpec;

  /// Additional runtime workspace roles. Send an empty list to remove existing extras.
  final List<String>? requestedRoles;

  /// Resolved commit details, when building from a repository.
  final GitCommitMetadata? commit;

  /// Creates a [DeploymentWorkerSpecResponse].
  const DeploymentWorkerSpecResponse({
    this.repositoryUrl,
    this.archiveId,
    this.backendSpec = const DeploymentMistralCloudBackendSpec(),
    this.requestedRoles,
    this.commit,
    required this.githubUrl,
    String? entrypoint,
    this.revision,
    String? workingDir,
    String? commitSha,
    this.restartedAt,
    this.type = 'workflows_worker',
  }) : _legacyEntrypoint = entrypoint,
       _legacyWorkingDir = workingDir,
       _legacyCommitSha = commitSha;

  /// Creates a [DeploymentWorkerSpecResponse] from JSON.
  factory DeploymentWorkerSpecResponse.fromJson(Map<String, dynamic> json) {
    final githubUrl = json['github_url'] as String?;
    if (githubUrl == null) {
      throw const FormatException(
        'DeploymentWorkerSpecResponse: missing required field "github_url"',
      );
    }
    return DeploymentWorkerSpecResponse(
      repositoryUrl: json['repository_url'] as String?,
      archiveId: json['archive_id'] as String?,
      backendSpec: json['backend_spec'] == null
          ? const DeploymentMistralCloudBackendSpec()
          : DeploymentBackendSpec.fromJson(
              json['backend_spec'] as Map<String, dynamic>,
            ),
      requestedRoles: (json['requested_roles'] as List<dynamic>?)
          ?.cast<String>(),
      commit: json['commit'] == null
          ? null
          : GitCommitMetadata.fromJson(json['commit'] as Map<String, dynamic>),
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
    if (repositoryUrl != null) 'repository_url': repositoryUrl,
    if (archiveId != null) 'archive_id': archiveId,
    'backend_spec': backendSpec.toJson(),
    if (requestedRoles != null) 'requested_roles': requestedRoles,
    if (commit != null) 'commit': commit!.toJson(),
    'github_url': githubUrl,
    if (_legacyEntrypoint != null) 'entrypoint': _legacyEntrypoint,
    if (revision != null) 'revision': revision,
    if (_legacyWorkingDir != null) 'working_dir': _legacyWorkingDir,
    if (_legacyCommitSha != null) 'commit_sha': _legacyCommitSha,
    if (restartedAt != null) 'restarted_at': restartedAt,
    'type': type,
  };

  /// Creates a copy with replaced values.
  DeploymentWorkerSpecResponse copyWith({
    Object? repositoryUrl = unsetCopyWithValue,
    Object? archiveId = unsetCopyWithValue,
    DeploymentBackendSpec? backendSpec,
    Object? requestedRoles = unsetCopyWithValue,
    Object? commit = unsetCopyWithValue,
    String? githubUrl,
    Object? entrypoint = unsetCopyWithValue,
    Object? revision = unsetCopyWithValue,
    Object? workingDir = unsetCopyWithValue,
    Object? commitSha = unsetCopyWithValue,
    Object? restartedAt = unsetCopyWithValue,
    String? type,
  }) {
    return DeploymentWorkerSpecResponse(
      repositoryUrl: repositoryUrl == unsetCopyWithValue
          ? this.repositoryUrl
          : repositoryUrl as String?,
      archiveId: archiveId == unsetCopyWithValue
          ? this.archiveId
          : archiveId as String?,
      backendSpec: backendSpec ?? this.backendSpec,
      requestedRoles: requestedRoles == unsetCopyWithValue
          ? this.requestedRoles
          : requestedRoles as List<String>?,
      commit: commit == unsetCopyWithValue
          ? this.commit
          : commit as GitCommitMetadata?,
      githubUrl: githubUrl ?? this.githubUrl,
      entrypoint: entrypoint == unsetCopyWithValue
          ? _legacyEntrypoint
          : entrypoint as String?,
      revision: revision == unsetCopyWithValue
          ? this.revision
          : revision as String?,
      workingDir: workingDir == unsetCopyWithValue
          ? _legacyWorkingDir
          : workingDir as String?,
      commitSha: commitSha == unsetCopyWithValue
          ? _legacyCommitSha
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
    return repositoryUrl == other.repositoryUrl &&
        archiveId == other.archiveId &&
        backendSpec == other.backendSpec &&
        listsEqual(requestedRoles, other.requestedRoles) &&
        commit == other.commit &&
        githubUrl == other.githubUrl &&
        _legacyEntrypoint == other._legacyEntrypoint &&
        revision == other.revision &&
        _legacyWorkingDir == other._legacyWorkingDir &&
        _legacyCommitSha == other._legacyCommitSha &&
        restartedAt == other.restartedAt &&
        type == other.type;
  }

  @override
  int get hashCode => Object.hashAll([
    githubUrl,
    _legacyEntrypoint,
    revision,
    _legacyWorkingDir,
    _legacyCommitSha,
    restartedAt,
    type,
    repositoryUrl,
    archiveId,
    backendSpec,
    listHash(requestedRoles),
    commit,
  ]);

  @override
  String toString() =>
      'DeploymentWorkerSpecResponse(repositoryUrl: $repositoryUrl, archiveId: $archiveId, backendSpec: $backendSpec, requestedRoles: ${requestedRoles?.length}, commit: $commit, '
      'githubUrl: $githubUrl, '
      'entrypoint: $entrypoint, '
      'revision: $revision, '
      'workingDir: $workingDir, '
      'commitSha: $commitSha, '
      'restartedAt: $restartedAt, '
      'type: $type'
      ')';
}
