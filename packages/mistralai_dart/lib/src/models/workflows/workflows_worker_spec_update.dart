import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Partial worker spec update for a managed workflow deployment.
///
/// All fields are optional; only the provided fields are updated.
@immutable
class WorkflowsWorkerSpecUpdate {
  /// The worker entrypoint.
  final String? entrypoint;

  /// The GitHub repository URL to build the worker from.
  final String? githubUrl;

  /// The Git revision to build.
  final String? revision;

  /// The working directory within the repository.
  final String? workingDir;

  /// Creates a [WorkflowsWorkerSpecUpdate].
  const WorkflowsWorkerSpecUpdate({
    this.entrypoint,
    this.githubUrl,
    this.revision,
    this.workingDir,
  });

  /// Creates a [WorkflowsWorkerSpecUpdate] from JSON.
  factory WorkflowsWorkerSpecUpdate.fromJson(Map<String, dynamic> json) =>
      WorkflowsWorkerSpecUpdate(
        entrypoint: json['entrypoint'] as String?,
        githubUrl: json['github_url'] as String?,
        revision: json['revision'] as String?,
        workingDir: json['working_dir'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (entrypoint != null) 'entrypoint': entrypoint,
    if (githubUrl != null) 'github_url': githubUrl,
    if (revision != null) 'revision': revision,
    if (workingDir != null) 'working_dir': workingDir,
  };

  /// Creates a copy with replaced values.
  WorkflowsWorkerSpecUpdate copyWith({
    Object? entrypoint = unsetCopyWithValue,
    Object? githubUrl = unsetCopyWithValue,
    Object? revision = unsetCopyWithValue,
    Object? workingDir = unsetCopyWithValue,
  }) {
    return WorkflowsWorkerSpecUpdate(
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
    return entrypoint == other.entrypoint &&
        githubUrl == other.githubUrl &&
        revision == other.revision &&
        workingDir == other.workingDir;
  }

  @override
  int get hashCode => Object.hash(entrypoint, githubUrl, revision, workingDir);

  @override
  String toString() =>
      'WorkflowsWorkerSpecUpdate('
      'entrypoint: $entrypoint, '
      'githubUrl: $githubUrl, '
      'revision: $revision, '
      'workingDir: $workingDir'
      ')';
}
