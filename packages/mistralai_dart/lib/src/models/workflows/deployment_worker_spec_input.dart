import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Worker spec input for creating a managed workflow deployment.
@immutable
class DeploymentWorkerSpecInput {
  /// The GitHub repository URL to build the worker from.
  final String githubUrl;

  /// The worker entrypoint (default `worker:main`).
  final String? entrypoint;

  /// The Git revision to build (default `main`).
  final String? revision;

  /// The working directory within the repository.
  final String? workingDir;

  /// Creates a [DeploymentWorkerSpecInput].
  const DeploymentWorkerSpecInput({
    required this.githubUrl,
    this.entrypoint = 'worker:main',
    this.revision = 'main',
    this.workingDir,
  });

  /// Creates a [DeploymentWorkerSpecInput] from JSON.
  factory DeploymentWorkerSpecInput.fromJson(Map<String, dynamic> json) {
    final githubUrl = json['github_url'] as String?;
    if (githubUrl == null) {
      throw const FormatException(
        'DeploymentWorkerSpecInput: missing required field "github_url"',
      );
    }
    return DeploymentWorkerSpecInput(
      githubUrl: githubUrl,
      entrypoint: json['entrypoint'] as String? ?? 'worker:main',
      revision: json['revision'] as String? ?? 'main',
      workingDir: json['working_dir'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'github_url': githubUrl,
    if (entrypoint != null) 'entrypoint': entrypoint,
    if (revision != null) 'revision': revision,
    if (workingDir != null) 'working_dir': workingDir,
  };

  /// Creates a copy with replaced values.
  DeploymentWorkerSpecInput copyWith({
    String? githubUrl,
    Object? entrypoint = unsetCopyWithValue,
    Object? revision = unsetCopyWithValue,
    Object? workingDir = unsetCopyWithValue,
  }) {
    return DeploymentWorkerSpecInput(
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
    return githubUrl == other.githubUrl &&
        entrypoint == other.entrypoint &&
        revision == other.revision &&
        workingDir == other.workingDir;
  }

  @override
  int get hashCode => Object.hash(githubUrl, entrypoint, revision, workingDir);

  @override
  String toString() =>
      'DeploymentWorkerSpecInput('
      'githubUrl: $githubUrl, '
      'entrypoint: $entrypoint, '
      'revision: $revision, '
      'workingDir: $workingDir'
      ')';
}
