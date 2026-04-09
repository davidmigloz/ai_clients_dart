import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'session_resource_params.dart';

/// A resource attached to a session.
///
/// Variants:
/// - [FileResource] — A file resource (type: "file")
/// - [GitHubRepositoryResource] — A GitHub repository (type: "github_repository")
/// - [UnknownSessionResource] — Unrecognized type (preserves raw JSON)
sealed class SessionResource {
  const SessionResource();

  /// Creates a [SessionResource] from JSON.
  factory SessionResource.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'file' => FileResource.fromJson(json),
      'github_repository' => GitHubRepositoryResource.fromJson(json),
      _ => UnknownSessionResource.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A file resource attached to a session.
@immutable
class FileResource extends SessionResource {
  /// The type discriminator. Always `file`.
  final String type;

  /// Unique identifier for this resource.
  final String id;

  /// ID of the uploaded file.
  final String fileId;

  /// Mount path in the container.
  final String mountPath;

  /// ISO 8601 timestamp of when the resource was created.
  final DateTime createdAt;

  /// ISO 8601 timestamp of when the resource was last updated.
  final DateTime updatedAt;

  /// Creates a [FileResource].
  const FileResource({
    this.type = 'file',
    required this.id,
    required this.fileId,
    required this.mountPath,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [FileResource] from JSON.
  factory FileResource.fromJson(Map<String, dynamic> json) {
    return FileResource(
      type: json['type'] as String? ?? 'file',
      id: json['id'] as String,
      fileId: json['file_id'] as String,
      mountPath: json['mount_path'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'file_id': fileId,
    'mount_path': mountPath,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  FileResource copyWith({
    String? type,
    String? id,
    String? fileId,
    String? mountPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FileResource(
      type: type ?? this.type,
      id: id ?? this.id,
      fileId: fileId ?? this.fileId,
      mountPath: mountPath ?? this.mountPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileResource &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          fileId == other.fileId &&
          mountPath == other.mountPath &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      Object.hash(type, id, fileId, mountPath, createdAt, updatedAt);

  @override
  String toString() =>
      'FileResource('
      'type: $type, '
      'id: $id, '
      'fileId: $fileId, '
      'mountPath: $mountPath, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt)';
}

/// A GitHub repository resource attached to a session.
@immutable
class GitHubRepositoryResource extends SessionResource {
  /// The type discriminator. Always `github_repository`.
  final String type;

  /// Unique identifier for this resource.
  final String id;

  /// GitHub URL of the repository.
  final String url;

  /// Mount path in the container.
  final String mountPath;

  /// Branch or commit checkout configuration.
  final RepositoryCheckout? checkout;

  /// ISO 8601 timestamp of when the resource was created.
  final DateTime createdAt;

  /// ISO 8601 timestamp of when the resource was last updated.
  final DateTime updatedAt;

  /// Creates a [GitHubRepositoryResource].
  const GitHubRepositoryResource({
    this.type = 'github_repository',
    required this.id,
    required this.url,
    required this.mountPath,
    this.checkout,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [GitHubRepositoryResource] from JSON.
  factory GitHubRepositoryResource.fromJson(Map<String, dynamic> json) {
    return GitHubRepositoryResource(
      type: json['type'] as String? ?? 'github_repository',
      id: json['id'] as String,
      url: json['url'] as String,
      mountPath: json['mount_path'] as String,
      checkout: json['checkout'] != null
          ? RepositoryCheckout.fromJson(
              json['checkout'] as Map<String, dynamic>,
            )
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'url': url,
    'mount_path': mountPath,
    if (checkout != null) 'checkout': checkout!.toJson(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  GitHubRepositoryResource copyWith({
    String? type,
    String? id,
    String? url,
    String? mountPath,
    Object? checkout = unsetCopyWithValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GitHubRepositoryResource(
      type: type ?? this.type,
      id: id ?? this.id,
      url: url ?? this.url,
      mountPath: mountPath ?? this.mountPath,
      checkout: checkout == unsetCopyWithValue
          ? this.checkout
          : checkout as RepositoryCheckout?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitHubRepositoryResource &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          url == other.url &&
          mountPath == other.mountPath &&
          checkout == other.checkout &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      Object.hash(type, id, url, mountPath, checkout, createdAt, updatedAt);

  @override
  String toString() =>
      'GitHubRepositoryResource('
      'type: $type, '
      'id: $id, '
      'url: $url, '
      'mountPath: $mountPath, '
      'checkout: $checkout, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt)';
}

/// Unrecognized session resource type (preserves raw JSON).
@immutable
class UnknownSessionResource extends SessionResource {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownSessionResource].
  const UnknownSessionResource({required this.rawJson});

  /// Creates an [UnknownSessionResource] from JSON.
  factory UnknownSessionResource.fromJson(Map<String, dynamic> json) {
    return UnknownSessionResource(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownSessionResource &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownSessionResource(rawJson: $rawJson)';
}

/// Confirmation of resource deletion.
@immutable
class DeletedSessionResource {
  /// Unique identifier of the deleted resource.
  final String id;

  /// Object type. Always "session_resource_deleted".
  final String type;

  /// Creates a [DeletedSessionResource].
  const DeletedSessionResource({
    required this.id,
    this.type = 'session_resource_deleted',
  });

  /// Creates a [DeletedSessionResource] from JSON.
  factory DeletedSessionResource.fromJson(Map<String, dynamic> json) {
    return DeletedSessionResource(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'session_resource_deleted',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'type': type};

  /// Creates a copy with replaced values.
  DeletedSessionResource copyWith({String? id, String? type}) {
    return DeletedSessionResource(id: id ?? this.id, type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedSessionResource &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() => 'DeletedSessionResource(id: $id, type: $type)';
}

/// Paginated list of resources attached to a session.
@immutable
class ListSessionResourcesResponse {
  /// Resources for the session, ordered by `created_at`.
  final List<SessionResource> data;

  /// Opaque cursor for the next page. Null when no more results.
  final String? nextPage;

  /// Creates a [ListSessionResourcesResponse].
  const ListSessionResourcesResponse({required this.data, this.nextPage});

  /// Creates a [ListSessionResourcesResponse] from JSON.
  factory ListSessionResourcesResponse.fromJson(Map<String, dynamic> json) {
    return ListSessionResourcesResponse(
      data:
          (json['data'] as List?)
              ?.map((e) => SessionResource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nextPage: json['next_page'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    if (nextPage != null) 'next_page': nextPage,
  };

  /// Creates a copy with replaced values.
  ListSessionResourcesResponse copyWith({
    List<SessionResource>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return ListSessionResourcesResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListSessionResourcesResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'ListSessionResourcesResponse(data: $data, nextPage: $nextPage)';
}
