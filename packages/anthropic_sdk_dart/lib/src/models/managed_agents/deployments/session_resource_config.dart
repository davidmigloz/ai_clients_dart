import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../memory_stores/mount_mode.dart';
import '../resources/session_resource_params.dart' show RepositoryCheckout;

/// A configured session resource on a deployment. Echoes the input minus
/// write-only credentials.
///
/// Variants:
/// - [GitHubRepositoryResourceConfig] — A GitHub repository
///   (type: "github_repository")
/// - [FileResourceConfig] — A mounted file (type: "file")
/// - [MemoryStoreResourceConfig] — A mounted memory store (type: "memory_store")
/// - [UnknownSessionResourceConfig] — Unrecognized type (preserves raw JSON)
sealed class SessionResourceConfig {
  const SessionResourceConfig();

  /// Creates a [SessionResourceConfig] from JSON.
  factory SessionResourceConfig.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'github_repository' => GitHubRepositoryResourceConfig.fromJson(json),
      'file' => FileResourceConfig.fromJson(json),
      'memory_store' => MemoryStoreResourceConfig.fromJson(json),
      _ => UnknownSessionResourceConfig.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A GitHub repository mounted into each session's container.
///
/// The authorization token is write-only and never returned.
@immutable
class GitHubRepositoryResourceConfig extends SessionResourceConfig {
  /// The type discriminator. Always `github_repository`.
  final String type;

  /// GitHub URL of the repository.
  final String url;

  /// Mount path in the container. Defaults to `/workspace/<repo-name>`.
  final String? mountPath;

  /// Branch or commit to check out. Defaults to the repository's default
  /// branch.
  final RepositoryCheckout? checkout;

  /// Creates a [GitHubRepositoryResourceConfig].
  const GitHubRepositoryResourceConfig({
    this.type = 'github_repository',
    required this.url,
    this.mountPath,
    this.checkout,
  });

  /// Creates a [GitHubRepositoryResourceConfig] from JSON.
  factory GitHubRepositoryResourceConfig.fromJson(Map<String, dynamic> json) {
    return GitHubRepositoryResourceConfig(
      type: json['type'] as String? ?? 'github_repository',
      url: json['url'] as String,
      mountPath: json['mount_path'] as String?,
      checkout: json['checkout'] != null
          ? RepositoryCheckout.fromJson(
              json['checkout'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'url': url,
    if (mountPath != null) 'mount_path': mountPath,
    if (checkout != null) 'checkout': checkout!.toJson(),
  };

  /// Creates a copy with replaced values.
  GitHubRepositoryResourceConfig copyWith({
    String? type,
    String? url,
    Object? mountPath = unsetCopyWithValue,
    Object? checkout = unsetCopyWithValue,
  }) {
    return GitHubRepositoryResourceConfig(
      type: type ?? this.type,
      url: url ?? this.url,
      mountPath: mountPath == unsetCopyWithValue
          ? this.mountPath
          : mountPath as String?,
      checkout: checkout == unsetCopyWithValue
          ? this.checkout
          : checkout as RepositoryCheckout?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitHubRepositoryResourceConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          url == other.url &&
          mountPath == other.mountPath &&
          checkout == other.checkout;

  @override
  int get hashCode => Object.hash(type, url, mountPath, checkout);

  @override
  String toString() =>
      'GitHubRepositoryResourceConfig('
      'type: $type, '
      'url: $url, '
      'mountPath: $mountPath, '
      'checkout: $checkout)';
}

/// A file mounted into each session's container.
@immutable
class FileResourceConfig extends SessionResourceConfig {
  /// The type discriminator. Always `file`.
  final String type;

  /// ID of a previously uploaded file.
  final String fileId;

  /// Mount path in the container. Defaults to
  /// `/mnt/session/uploads/<file_id>`.
  final String? mountPath;

  /// Creates a [FileResourceConfig].
  const FileResourceConfig({
    this.type = 'file',
    required this.fileId,
    this.mountPath,
  });

  /// Creates a [FileResourceConfig] from JSON.
  factory FileResourceConfig.fromJson(Map<String, dynamic> json) {
    return FileResourceConfig(
      type: json['type'] as String? ?? 'file',
      fileId: json['file_id'] as String,
      mountPath: json['mount_path'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'file_id': fileId,
    if (mountPath != null) 'mount_path': mountPath,
  };

  /// Creates a copy with replaced values.
  FileResourceConfig copyWith({
    String? type,
    String? fileId,
    Object? mountPath = unsetCopyWithValue,
  }) {
    return FileResourceConfig(
      type: type ?? this.type,
      fileId: fileId ?? this.fileId,
      mountPath: mountPath == unsetCopyWithValue
          ? this.mountPath
          : mountPath as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileResourceConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          fileId == other.fileId &&
          mountPath == other.mountPath;

  @override
  int get hashCode => Object.hash(type, fileId, mountPath);

  @override
  String toString() =>
      'FileResourceConfig('
      'type: $type, '
      'fileId: $fileId, '
      'mountPath: $mountPath)';
}

/// A memory store attached to each session created from this deployment.
@immutable
class MemoryStoreResourceConfig extends SessionResourceConfig {
  /// The type discriminator. Always `memory_store`.
  final String type;

  /// The memory store ID (`memstore_...`). Must belong to the caller's
  /// organization and workspace.
  final String memoryStoreId;

  /// Per-attachment guidance for the agent on how to use this store. Rendered
  /// into the memory section of the system prompt. Max 4096 chars.
  final String? instructions;

  /// Access mode for the mounted store. Defaults to `read_write`. `read_only`
  /// mounts the store as a read-only filesystem.
  final MountMode? access;

  /// Creates a [MemoryStoreResourceConfig].
  const MemoryStoreResourceConfig({
    this.type = 'memory_store',
    required this.memoryStoreId,
    this.instructions,
    this.access,
  });

  /// Creates a [MemoryStoreResourceConfig] from JSON.
  factory MemoryStoreResourceConfig.fromJson(Map<String, dynamic> json) {
    return MemoryStoreResourceConfig(
      type: json['type'] as String? ?? 'memory_store',
      memoryStoreId: json['memory_store_id'] as String,
      instructions: json['instructions'] as String?,
      access: json['access'] != null
          ? MountMode.fromJson(json['access'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'memory_store_id': memoryStoreId,
    if (instructions != null) 'instructions': instructions,
    if (access != null) 'access': access!.toJson(),
  };

  /// Creates a copy with replaced values.
  MemoryStoreResourceConfig copyWith({
    String? type,
    String? memoryStoreId,
    Object? instructions = unsetCopyWithValue,
    Object? access = unsetCopyWithValue,
  }) {
    return MemoryStoreResourceConfig(
      type: type ?? this.type,
      memoryStoreId: memoryStoreId ?? this.memoryStoreId,
      instructions: instructions == unsetCopyWithValue
          ? this.instructions
          : instructions as String?,
      access: access == unsetCopyWithValue ? this.access : access as MountMode?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryStoreResourceConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          memoryStoreId == other.memoryStoreId &&
          instructions == other.instructions &&
          access == other.access;

  @override
  int get hashCode => Object.hash(type, memoryStoreId, instructions, access);

  @override
  String toString() =>
      'MemoryStoreResourceConfig('
      'type: $type, '
      'memoryStoreId: $memoryStoreId, '
      'instructions: $instructions, '
      'access: $access)';
}

/// Unrecognized session resource config type (preserves raw JSON).
@immutable
class UnknownSessionResourceConfig extends SessionResourceConfig {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownSessionResourceConfig].
  const UnknownSessionResourceConfig({required this.rawJson});

  /// Creates an [UnknownSessionResourceConfig] from JSON.
  factory UnknownSessionResourceConfig.fromJson(Map<String, dynamic> json) {
    return UnknownSessionResourceConfig(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownSessionResourceConfig &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownSessionResourceConfig(rawJson: $rawJson)';
}
