import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../observability/pagination_info.dart';
import 'library_timestamp.dart';

/// A document library for RAG (Retrieval-Augmented Generation).
///
/// Libraries store documents that can be accessed by agents through
/// the document_library tool for context-aware responses.
@immutable
class Library {
  /// The unique identifier for this library.
  final String id;

  /// The name of the library.
  final String name;

  /// A description of the library contents.
  final String? description;

  /// When this library was created (Unix timestamp).
  final int? createdAt;

  /// When this library was last updated (Unix timestamp).
  final int? updatedAt;

  /// The ID of the library owner.
  final String? ownerId;

  /// The type of owner (e.g., "user", "org").
  final String? ownerType;

  /// Total size of documents in the library (in bytes).
  final int? totalSize;

  /// Number of documents in the library.
  final int? nbDocuments;

  /// Size in tokens of document chunks.
  final int? chunkSize;

  /// Emoji associated with the library.
  final String? emoji;

  /// Number of users with explicit access.
  final int? explicitUserMembersCount;

  /// Number of workspaces with explicit access.
  final int? explicitWorkspaceMembersCount;

  /// Generated description of the library.
  final String? generatedDescription;

  /// Generated name of the library.
  final String? generatedName;

  /// Default sharing role for the organization.
  final String? orgSharingRole;

  /// Creates a [Library].
  const Library({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.ownerId,
    this.ownerType,
    this.totalSize,
    this.nbDocuments,
    this.chunkSize,
    this.emoji,
    this.explicitUserMembersCount,
    this.explicitWorkspaceMembersCount,
    this.generatedDescription,
    this.generatedName,
    this.orgSharingRole,
  });

  /// Creates a [Library] from JSON.
  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: parseLibraryTimestamp(json['created_at']),
      updatedAt: parseLibraryTimestamp(json['updated_at']),
      ownerId: json['owner_id'] as String?,
      ownerType: json['owner_type'] as String?,
      totalSize: json['total_size'] as int?,
      nbDocuments: json['nb_documents'] as int?,
      chunkSize: json['chunk_size'] as int?,
      emoji: json['emoji'] as String?,
      explicitUserMembersCount: json['explicit_user_members_count'] as int?,
      explicitWorkspaceMembersCount:
          json['explicit_workspace_members_count'] as int?,
      generatedDescription: json['generated_description'] as String?,
      generatedName: json['generated_name'] as String?,
      orgSharingRole: json['org_sharing_role'] as String?,
    );
  }

  /// Converts this library to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': formatLibraryTimestamp(createdAt!),
      if (updatedAt != null) 'updated_at': formatLibraryTimestamp(updatedAt!),
      if (ownerId != null) 'owner_id': ownerId,
      if (ownerType != null) 'owner_type': ownerType,
      if (totalSize != null) 'total_size': totalSize,
      if (nbDocuments != null) 'nb_documents': nbDocuments,
      'chunk_size': ?chunkSize,
      'emoji': ?emoji,
      'explicit_user_members_count': ?explicitUserMembersCount,
      'explicit_workspace_members_count': ?explicitWorkspaceMembersCount,
      'generated_description': ?generatedDescription,
      'generated_name': ?generatedName,
      'org_sharing_role': ?orgSharingRole,
    };
  }

  /// Creates a copy with the given fields replaced.
  ///
  /// Optional nullable fields can be explicitly set to null by passing `null`.
  /// To keep the original value, omit the parameter.
  Library copyWith({
    String? id,
    String? name,
    Object? description = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? updatedAt = unsetCopyWithValue,
    Object? ownerId = unsetCopyWithValue,
    Object? ownerType = unsetCopyWithValue,
    Object? totalSize = unsetCopyWithValue,
    Object? nbDocuments = unsetCopyWithValue,
    Object? chunkSize = unsetCopyWithValue,
    Object? emoji = unsetCopyWithValue,
    Object? explicitUserMembersCount = unsetCopyWithValue,
    Object? explicitWorkspaceMembersCount = unsetCopyWithValue,
    Object? generatedDescription = unsetCopyWithValue,
    Object? generatedName = unsetCopyWithValue,
    Object? orgSharingRole = unsetCopyWithValue,
  }) {
    return Library(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      createdAt: createdAt == unsetCopyWithValue
          ? this.createdAt
          : createdAt as int?,
      updatedAt: updatedAt == unsetCopyWithValue
          ? this.updatedAt
          : updatedAt as int?,
      ownerId: ownerId == unsetCopyWithValue
          ? this.ownerId
          : ownerId as String?,
      ownerType: ownerType == unsetCopyWithValue
          ? this.ownerType
          : ownerType as String?,
      totalSize: totalSize == unsetCopyWithValue
          ? this.totalSize
          : totalSize as int?,
      nbDocuments: nbDocuments == unsetCopyWithValue
          ? this.nbDocuments
          : nbDocuments as int?,
      chunkSize: chunkSize == unsetCopyWithValue
          ? this.chunkSize
          : chunkSize as int?,
      emoji: emoji == unsetCopyWithValue ? this.emoji : emoji as String?,
      explicitUserMembersCount: explicitUserMembersCount == unsetCopyWithValue
          ? this.explicitUserMembersCount
          : explicitUserMembersCount as int?,
      explicitWorkspaceMembersCount:
          explicitWorkspaceMembersCount == unsetCopyWithValue
          ? this.explicitWorkspaceMembersCount
          : explicitWorkspaceMembersCount as int?,
      generatedDescription: generatedDescription == unsetCopyWithValue
          ? this.generatedDescription
          : generatedDescription as String?,
      generatedName: generatedName == unsetCopyWithValue
          ? this.generatedName
          : generatedName as String?,
      orgSharingRole: orgSharingRole == unsetCopyWithValue
          ? this.orgSharingRole
          : orgSharingRole as String?,
    );
  }

  /// Whether this library has any documents.
  bool get hasDocuments => nbDocuments != null && nbDocuments! > 0;

  /// Whether this library is empty.
  bool get isEmpty => nbDocuments == null || nbDocuments == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Library &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          ownerId == other.ownerId &&
          ownerType == other.ownerType &&
          totalSize == other.totalSize &&
          nbDocuments == other.nbDocuments &&
          chunkSize == other.chunkSize &&
          emoji == other.emoji &&
          explicitUserMembersCount == other.explicitUserMembersCount &&
          explicitWorkspaceMembersCount ==
              other.explicitWorkspaceMembersCount &&
          generatedDescription == other.generatedDescription &&
          generatedName == other.generatedName &&
          orgSharingRole == other.orgSharingRole;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    createdAt,
    updatedAt,
    ownerId,
    ownerType,
    totalSize,
    nbDocuments,
    chunkSize,
    emoji,
    explicitUserMembersCount,
    explicitWorkspaceMembersCount,
    generatedDescription,
    generatedName,
    orgSharingRole,
  );

  @override
  String toString() =>
      'Library(id: $id, name: $name, documents: ${nbDocuments ?? 0}, '
      'chunkSize: $chunkSize)';
}

/// A list of libraries returned from the API.
@immutable
class LibraryList {
  /// The object type, always "list".
  final String object;

  /// The list of libraries.
  final List<Library> data;

  /// The total number of libraries available.
  ///
  /// Deprecated: this offset-pagination metadata is only populated for
  /// callers using the deprecated `page` parameter. Use [nextPageToken]
  /// instead.
  final int? total;

  /// Whether there are more libraries to fetch.
  ///
  /// Deprecated: this offset-pagination metadata is only populated for
  /// callers using the deprecated `page` parameter. Use [nextPageToken]
  /// instead.
  final bool? hasMore;

  /// Pagination details returned for an offset page.
  final PaginationInfo? pagination;

  /// Opaque continuation token for the next page.
  ///
  /// Pass it back as `page_token` to fetch the next page. Null when there
  /// are no more results. Prefer this over the deprecated offset `page`
  /// parameter.
  final String? nextPageToken;

  /// Creates a [LibraryList].
  const LibraryList({
    this.object = 'list',
    required this.data,
    this.total,
    this.hasMore,
    this.pagination,
    this.nextPageToken,
  });

  /// Creates a [LibraryList] from JSON.
  factory LibraryList.fromJson(Map<String, dynamic> json) {
    final paginationJson = json['pagination'] as Map<String, dynamic>?;
    final pagination = paginationJson == null
        ? null
        : PaginationInfo.fromJson(paginationJson);
    return LibraryList(
      object: json['object'] as String? ?? 'list',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Library.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: pagination?.totalItems ?? json['total'] as int?,
      hasMore: pagination?.hasMore ?? json['has_more'] as bool?,
      pagination: pagination,
      nextPageToken: json['next_page_token'] as String?,
    );
  }

  /// Converts this list to JSON.
  Map<String, dynamic> toJson() {
    return {
      'object': object,
      'data': data.map((e) => e.toJson()).toList(),
      if (pagination != null) 'pagination': pagination!.toJson(),
      if (pagination == null && total != null) 'total': total,
      if (pagination == null && hasMore != null) 'has_more': hasMore,
      if (nextPageToken != null) 'next_page_token': nextPageToken,
    };
  }

  /// Whether the list is empty.
  bool get isEmpty => data.isEmpty;

  /// Whether the list is not empty.
  bool get isNotEmpty => data.isNotEmpty;

  /// The number of libraries in this page.
  int get length => data.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          listsEqual(data, other.data) &&
          total == other.total &&
          pagination == other.pagination &&
          hasMore == other.hasMore &&
          nextPageToken == other.nextPageToken;

  @override
  int get hashCode => Object.hash(
    object,
    Object.hashAll(data),
    total,
    hasMore,
    pagination,
    nextPageToken,
  );

  @override
  String toString() =>
      'LibraryList(count: $length, total: $total, '
      'nextPageToken: $nextPageToken)';
}
