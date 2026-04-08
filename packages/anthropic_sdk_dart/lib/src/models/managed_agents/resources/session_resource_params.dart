import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

// ============================================================================
// SessionResourceParams — sealed
// ============================================================================

/// Request parameters for adding a resource to a session.
///
/// Variants:
/// - [FileResourceParams] — Mount a file (type: "file")
/// - [GitHubRepositoryResourceParams] — Mount a GitHub repo (type: "github_repository")
/// - [UnknownSessionResourceParams] — Unrecognized type (preserves raw JSON)
sealed class SessionResourceParams {
  const SessionResourceParams();

  /// Creates a [SessionResourceParams] from JSON.
  factory SessionResourceParams.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'file' => FileResourceParams.fromJson(json),
      'github_repository' => GitHubRepositoryResourceParams.fromJson(json),
      _ => UnknownSessionResourceParams.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Mount a file uploaded via the Files API into the session.
@immutable
class FileResourceParams extends SessionResourceParams {
  /// The type discriminator. Always `file`.
  final String type;

  /// ID of a previously uploaded file.
  final String fileId;

  /// Mount path in the container.
  final String? mountPath;

  /// Creates a [FileResourceParams].
  const FileResourceParams({
    this.type = 'file',
    required this.fileId,
    this.mountPath,
  });

  /// Creates a [FileResourceParams] from JSON.
  factory FileResourceParams.fromJson(Map<String, dynamic> json) {
    return FileResourceParams(
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
  FileResourceParams copyWith({
    String? type,
    String? fileId,
    Object? mountPath = unsetCopyWithValue,
  }) {
    return FileResourceParams(
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
      other is FileResourceParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          fileId == other.fileId &&
          mountPath == other.mountPath;

  @override
  int get hashCode => Object.hash(type, fileId, mountPath);

  @override
  String toString() =>
      'FileResourceParams(type: $type, fileId: $fileId, mountPath: $mountPath)';
}

/// Mount a GitHub repository into the session's container.
@immutable
class GitHubRepositoryResourceParams extends SessionResourceParams {
  /// The type discriminator. Always `github_repository`.
  final String type;

  /// GitHub URL of the repository.
  final String url;

  /// GitHub authorization token used to clone the repository.
  final String authorizationToken;

  /// Mount path in the container.
  final String? mountPath;

  /// Branch or commit to check out.
  final RepositoryCheckout? checkout;

  /// Creates a [GitHubRepositoryResourceParams].
  const GitHubRepositoryResourceParams({
    this.type = 'github_repository',
    required this.url,
    required this.authorizationToken,
    this.mountPath,
    this.checkout,
  });

  /// Creates a [GitHubRepositoryResourceParams] from JSON.
  factory GitHubRepositoryResourceParams.fromJson(Map<String, dynamic> json) {
    return GitHubRepositoryResourceParams(
      type: json['type'] as String? ?? 'github_repository',
      url: json['url'] as String,
      authorizationToken: json['authorization_token'] as String,
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
    'authorization_token': authorizationToken,
    if (mountPath != null) 'mount_path': mountPath,
    if (checkout != null) 'checkout': checkout!.toJson(),
  };

  /// Creates a copy with replaced values.
  GitHubRepositoryResourceParams copyWith({
    String? type,
    String? url,
    String? authorizationToken,
    Object? mountPath = unsetCopyWithValue,
    Object? checkout = unsetCopyWithValue,
  }) {
    return GitHubRepositoryResourceParams(
      type: type ?? this.type,
      url: url ?? this.url,
      authorizationToken: authorizationToken ?? this.authorizationToken,
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
      other is GitHubRepositoryResourceParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          url == other.url &&
          authorizationToken == other.authorizationToken &&
          mountPath == other.mountPath &&
          checkout == other.checkout;

  @override
  int get hashCode =>
      Object.hash(type, url, authorizationToken, mountPath, checkout);

  @override
  String toString() =>
      'GitHubRepositoryResourceParams('
      'type: $type, '
      'url: $url, '
      'authorizationToken: $authorizationToken, '
      'mountPath: $mountPath, '
      'checkout: $checkout)';
}

/// Unrecognized session resource params type (preserves raw JSON).
@immutable
class UnknownSessionResourceParams extends SessionResourceParams {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownSessionResourceParams].
  const UnknownSessionResourceParams({required this.rawJson});

  /// Creates an [UnknownSessionResourceParams] from JSON.
  factory UnknownSessionResourceParams.fromJson(Map<String, dynamic> json) {
    return UnknownSessionResourceParams(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownSessionResourceParams &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownSessionResourceParams(rawJson: $rawJson)';
}

// ============================================================================
// UpdateSessionResourceParams
// ============================================================================

/// Request parameters for updating a session resource.
@immutable
class UpdateSessionResourceParams {
  /// New authorization token for the resource.
  ///
  /// Currently only `github_repository` resources support token rotation.
  final String authorizationToken;

  /// Creates an [UpdateSessionResourceParams].
  const UpdateSessionResourceParams({required this.authorizationToken});

  /// Creates an [UpdateSessionResourceParams] from JSON.
  factory UpdateSessionResourceParams.fromJson(Map<String, dynamic> json) {
    return UpdateSessionResourceParams(
      authorizationToken: json['authorization_token'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'authorization_token': authorizationToken};

  /// Creates a copy with replaced values.
  UpdateSessionResourceParams copyWith({String? authorizationToken}) {
    return UpdateSessionResourceParams(
      authorizationToken: authorizationToken ?? this.authorizationToken,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateSessionResourceParams &&
          runtimeType == other.runtimeType &&
          authorizationToken == other.authorizationToken;

  @override
  int get hashCode => authorizationToken.hashCode;

  @override
  String toString() =>
      'UpdateSessionResourceParams('
      'authorizationToken: $authorizationToken)';
}

// ============================================================================
// RepositoryCheckout — sealed
// ============================================================================

/// Branch or commit checkout configuration.
///
/// Variants:
/// - [BranchCheckout] — Check out a branch (type: "branch")
/// - [CommitCheckout] — Check out a commit (type: "commit")
/// - [UnknownRepositoryCheckout] — Unrecognized type (preserves raw JSON)
sealed class RepositoryCheckout {
  const RepositoryCheckout();

  /// Creates a [RepositoryCheckout] from JSON.
  factory RepositoryCheckout.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'branch' => BranchCheckout.fromJson(json),
      'commit' => CommitCheckout.fromJson(json),
      _ => UnknownRepositoryCheckout.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Check out a branch.
@immutable
class BranchCheckout extends RepositoryCheckout {
  /// The type discriminator. Always `branch`.
  final String type;

  /// Branch name to check out.
  final String name;

  /// Creates a [BranchCheckout].
  const BranchCheckout({this.type = 'branch', required this.name});

  /// Creates a [BranchCheckout] from JSON.
  factory BranchCheckout.fromJson(Map<String, dynamic> json) {
    return BranchCheckout(
      type: json['type'] as String? ?? 'branch',
      name: json['name'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'name': name};

  /// Creates a copy with replaced values.
  BranchCheckout copyWith({String? type, String? name}) {
    return BranchCheckout(type: type ?? this.type, name: name ?? this.name);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchCheckout &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name;

  @override
  int get hashCode => Object.hash(type, name);

  @override
  String toString() => 'BranchCheckout(type: $type, name: $name)';
}

/// Check out a specific commit.
@immutable
class CommitCheckout extends RepositoryCheckout {
  /// The type discriminator. Always `commit`.
  final String type;

  /// Full commit SHA to check out.
  final String sha;

  /// Creates a [CommitCheckout].
  const CommitCheckout({this.type = 'commit', required this.sha});

  /// Creates a [CommitCheckout] from JSON.
  factory CommitCheckout.fromJson(Map<String, dynamic> json) {
    return CommitCheckout(
      type: json['type'] as String? ?? 'commit',
      sha: json['sha'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'sha': sha};

  /// Creates a copy with replaced values.
  CommitCheckout copyWith({String? type, String? sha}) {
    return CommitCheckout(type: type ?? this.type, sha: sha ?? this.sha);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommitCheckout &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          sha == other.sha;

  @override
  int get hashCode => Object.hash(type, sha);

  @override
  String toString() => 'CommitCheckout(type: $type, sha: $sha)';
}

/// Unrecognized repository checkout type (preserves raw JSON).
@immutable
class UnknownRepositoryCheckout extends RepositoryCheckout {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownRepositoryCheckout].
  const UnknownRepositoryCheckout({required this.rawJson});

  /// Creates an [UnknownRepositoryCheckout] from JSON.
  factory UnknownRepositoryCheckout.fromJson(Map<String, dynamic> json) {
    return UnknownRepositoryCheckout(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownRepositoryCheckout &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownRepositoryCheckout(rawJson: $rawJson)';
}
