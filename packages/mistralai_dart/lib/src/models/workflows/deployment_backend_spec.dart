import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/deep_unmodifiable_json.dart';
import '../common/equality_helpers.dart';

/// Binds a workspace secret reference to an environment variable.
@immutable
class DeploymentSecretBinding {
  /// Name of the environment variable available to the worker.
  final String envVarName;

  /// Workspace secret reference in the form `secret:workspace:NAME`.
  final String reference;

  /// Creates a [DeploymentSecretBinding].
  const DeploymentSecretBinding({
    required this.envVarName,
    required this.reference,
  });

  /// Creates a [DeploymentSecretBinding] from JSON.
  factory DeploymentSecretBinding.fromJson(Map<String, dynamic> json) {
    final envVarName = json['env_var_name'] as String?;
    final reference = json['reference'] as String?;
    if (envVarName == null) {
      throw const FormatException(
        'DeploymentSecretBinding: missing required "env_var_name"',
      );
    }
    if (reference == null) {
      throw const FormatException(
        'DeploymentSecretBinding: missing required "reference"',
      );
    }
    return DeploymentSecretBinding(
      envVarName: envVarName,
      reference: reference,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'env_var_name': envVarName,
    'reference': reference,
  };

  /// Creates a copy with the given fields replaced.
  DeploymentSecretBinding copyWith({String? envVarName, String? reference}) =>
      DeploymentSecretBinding(
        envVarName: envVarName ?? this.envVarName,
        reference: reference ?? this.reference,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentSecretBinding &&
          envVarName == other.envVarName &&
          reference == other.reference;

  @override
  int get hashCode => Object.hash(envVarName, reference);

  @override
  String toString() =>
      'DeploymentSecretBinding(envVarName: $envVarName, reference: [redacted])';
}

/// Configuration specific to a deployment's backend.
///
/// Implementations include [DeploymentMistralCloudBackendSpec],
/// [DeploymentK8sBackendSpec], and [UnknownDeploymentBackendSpec].
sealed class DeploymentBackendSpec {
  const DeploymentBackendSpec();

  /// The backend discriminator.
  String get type;

  /// Decodes a backend while keeping unknown backend payloads available.
  factory DeploymentBackendSpec.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'mistral_cloud' ||
        'koyeb' => DeploymentMistralCloudBackendSpec.fromJson(json),
        'kubernetes' => DeploymentK8sBackendSpec.fromJson(json),
        _ => UnknownDeploymentBackendSpec(json),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Mistral Cloud build configuration.
@immutable
class DeploymentMistralCloudBackendSpec extends DeploymentBackendSpec {
  /// Relative path to the Dockerfile that builds the worker.
  final String? dockerfilePath;

  /// Build context relative to the repository root.
  ///
  /// Omit when building from a deployment archive, which is the whole context.
  final String? buildDirectory;

  /// References to workspace secrets available to the worker.
  final List<DeploymentSecretBinding>? secrets;

  @override
  final String type;

  /// Creates a Mistral Cloud build configuration.
  const DeploymentMistralCloudBackendSpec({
    this.dockerfilePath,
    this.buildDirectory,
    this.secrets,
    this.type = 'mistral_cloud',
  });

  /// Creates a [DeploymentMistralCloudBackendSpec] from JSON.
  factory DeploymentMistralCloudBackendSpec.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'] as String? ?? 'mistral_cloud';
    if (type != 'mistral_cloud' && type != 'koyeb') {
      throw const FormatException('Expected a Mistral Cloud backend');
    }
    return DeploymentMistralCloudBackendSpec(
      type: type,
      dockerfilePath: json['dockerfile_path'] as String?,
      buildDirectory: json['build_directory'] as String?,
      secrets: (json['secrets'] as List<dynamic>?)
          ?.map(
            (value) =>
                DeploymentSecretBinding.fromJson(value as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    if (type != 'mistral_cloud' && type != 'koyeb') {
      throw ArgumentError.value(type, 'type', 'Expected Mistral Cloud');
    }
    return {
      'type': type,
      if (dockerfilePath != null) 'dockerfile_path': dockerfilePath,
      if (buildDirectory != null) 'build_directory': buildDirectory,
      if (secrets != null)
        'secrets': secrets!.map((secret) => secret.toJson()).toList(),
    };
  }

  /// Creates a copy with replaced values.
  DeploymentMistralCloudBackendSpec copyWith({
    String? type,
    Object? dockerfilePath = unsetCopyWithValue,
    Object? buildDirectory = unsetCopyWithValue,
    Object? secrets = unsetCopyWithValue,
  }) => DeploymentMistralCloudBackendSpec(
    type: type ?? this.type,
    dockerfilePath: dockerfilePath == unsetCopyWithValue
        ? this.dockerfilePath
        : dockerfilePath as String?,
    buildDirectory: buildDirectory == unsetCopyWithValue
        ? this.buildDirectory
        : buildDirectory as String?,
    secrets: secrets == unsetCopyWithValue
        ? this.secrets
        : secrets == null
        ? null
        : List<DeploymentSecretBinding>.from(secrets as Iterable<Object?>),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentMistralCloudBackendSpec &&
          type == other.type &&
          dockerfilePath == other.dockerfilePath &&
          buildDirectory == other.buildDirectory &&
          listsEqual(secrets, other.secrets);

  @override
  int get hashCode =>
      Object.hash(type, dockerfilePath, buildDirectory, listHash(secrets));

  @override
  String toString() =>
      'DeploymentMistralCloudBackendSpec(type: $type, '
      'dockerfilePath: $dockerfilePath, buildDirectory: $buildDirectory, '
      'secrets: ${secrets?.length})';
}

/// Backend details for deployments that already run on Kubernetes.
@immutable
class DeploymentK8sBackendSpec extends DeploymentBackendSpec {
  /// Kubernetes worker entrypoint.
  final String? entrypoint;

  /// Kubernetes worker working directory.
  final String? workingDir;

  @override
  String get type => 'kubernetes';

  /// Creates a Kubernetes backend description.
  const DeploymentK8sBackendSpec({this.entrypoint, this.workingDir});

  /// Creates a [DeploymentK8sBackendSpec] from JSON.
  factory DeploymentK8sBackendSpec.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('type') && json['type'] != 'kubernetes') {
      throw const FormatException('Expected a Kubernetes backend');
    }
    return DeploymentK8sBackendSpec(
      entrypoint: json['entrypoint'] as String?,
      workingDir: json['working_dir'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (entrypoint != null) 'entrypoint': entrypoint,
    if (workingDir != null) 'working_dir': workingDir,
  };

  /// Creates a copy with replaced values.
  DeploymentK8sBackendSpec copyWith({
    Object? entrypoint = unsetCopyWithValue,
    Object? workingDir = unsetCopyWithValue,
  }) => DeploymentK8sBackendSpec(
    entrypoint: entrypoint == unsetCopyWithValue
        ? this.entrypoint
        : entrypoint as String?,
    workingDir: workingDir == unsetCopyWithValue
        ? this.workingDir
        : workingDir as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentK8sBackendSpec &&
          entrypoint == other.entrypoint &&
          workingDir == other.workingDir;

  @override
  int get hashCode => Object.hash(entrypoint, workingDir);

  @override
  String toString() =>
      'DeploymentK8sBackendSpec(entrypoint: $entrypoint, workingDir: $workingDir)';
}

/// Payload for a backend type this version of the client does not recognize.
@immutable
class UnknownDeploymentBackendSpec extends DeploymentBackendSpec {
  /// Raw JSON for the backend.
  final Map<String, dynamic> rawJson;

  /// Creates an unknown backend with preserved wire data.
  UnknownDeploymentBackendSpec(Map<String, dynamic> rawJson)
    : rawJson = deepUnmodifiableJson(rawJson)! as Map<String, dynamic>;

  @override
  String get type => rawJson['type'] as String? ?? 'unknown';

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownDeploymentBackendSpec &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownDeploymentBackendSpec(type: $type)';
}
