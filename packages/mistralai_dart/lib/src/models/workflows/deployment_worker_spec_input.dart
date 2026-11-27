import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'deployment_backend_spec.dart';

/// Worker spec input for creating a managed workflow deployment.
@immutable
class DeploymentWorkerSpecInput {
  /// Legacy GitHub repository URL. Prefer [repositoryUrl].
  final String githubUrl;

  /// Legacy worker entrypoint. Configure this in the Dockerfile.
  final String? entrypoint;

  /// The Git revision to build (default `main`).
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

  /// Creates a [DeploymentWorkerSpecInput].
  const DeploymentWorkerSpecInput({
    this.repositoryUrl,
    this.archiveId,
    this.backendSpec,
    this.requestedRoles,
    this.githubUrl = '',
    this.entrypoint = 'worker:main',
    this.revision = 'main',
    this.workingDir,
  });

  /// Creates a [DeploymentWorkerSpecInput] from JSON.
  factory DeploymentWorkerSpecInput.fromJson(Map<String, dynamic> json) {
    final spec = DeploymentWorkerSpecInput(
      repositoryUrl: json['repository_url'] as String?,
      archiveId: json['archive_id'] as String?,
      backendSpec: json['backend_spec'] == null
          ? null
          : DeploymentMistralCloudBackendSpec.fromJson(
              json['backend_spec'] as Map<String, dynamic>,
            ),
      requestedRoles: (json['requested_roles'] as List<dynamic>?)
          ?.cast<String>(),
      githubUrl: json['github_url'] as String? ?? '',
      entrypoint: json['entrypoint'] as String? ?? 'worker:main',
      revision: json['revision'] as String? ?? 'main',
      workingDir: json['working_dir'] as String?,
    );
    if (spec.githubUrl.isEmpty &&
        spec.repositoryUrl == null &&
        spec.archiveId == null) {
      throw const FormatException(
        'Expected a deployment repository or archive ID',
      );
    }
    return spec;
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    final hasRepository = repositoryUrl != null || githubUrl.isNotEmpty;
    if (!hasRepository && archiveId == null) {
      throw ArgumentError('Expected a deployment repository or archive ID');
    }
    if (repositoryUrl != null && githubUrl.isNotEmpty) {
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
      if (githubUrl.isNotEmpty) 'github_url': githubUrl,
      if (revision != null && archiveId == null) 'revision': revision,
    };
  }

  /// Creates a copy with replaced values.
  DeploymentWorkerSpecInput copyWith({
    Object? repositoryUrl = unsetCopyWithValue,
    Object? archiveId = unsetCopyWithValue,
    Object? backendSpec = unsetCopyWithValue,
    Object? requestedRoles = unsetCopyWithValue,
    String? githubUrl,
    Object? entrypoint = unsetCopyWithValue,
    Object? revision = unsetCopyWithValue,
    Object? workingDir = unsetCopyWithValue,
  }) {
    return DeploymentWorkerSpecInput(
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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentWorkerSpecInput) return false;
    if (runtimeType != other.runtimeType) return false;
    return repositoryUrl == other.repositoryUrl &&
        archiveId == other.archiveId &&
        backendSpec == other.backendSpec &&
        listsEqual(requestedRoles, other.requestedRoles) &&
        githubUrl == other.githubUrl &&
        entrypoint == other.entrypoint &&
        revision == other.revision &&
        workingDir == other.workingDir;
  }

  @override
  int get hashCode => Object.hashAll([
    githubUrl,
    entrypoint,
    revision,
    workingDir,
    repositoryUrl,
    archiveId,
    backendSpec,
    listHash(requestedRoles),
  ]);

  @override
  String toString() =>
      'DeploymentWorkerSpecInput(repositoryUrl: $repositoryUrl, archiveId: $archiveId, backendSpec: $backendSpec, requestedRoles: ${requestedRoles?.length}, '
      'githubUrl: $githubUrl, '
      'entrypoint: $entrypoint, '
      'revision: $revision, '
      'workingDir: $workingDir'
      ')';
}
