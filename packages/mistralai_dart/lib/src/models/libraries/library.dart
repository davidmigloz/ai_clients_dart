import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import '../common/copy_with_sentinel.dart';

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
  });

  /// Creates a [Library] from JSON.
  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: json['created_at'] as int?,
      updatedAt: json['updated_at'] as int?,
      ownerId: json['owner_id'] as String?,
      ownerType: json['owner_type'] as String?,
      totalSize: json['total_size'] as int?,
      nbDocuments: json['nb_documents'] as int?,
    );
  }

  /// Converts this library to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (ownerId != null) 'owner_id': ownerId,
      if (ownerType != null) 'owner_type': ownerType,
      if (totalSize != null) 'total_size': totalSize,
      if (nbDocuments != null) 'nb_documents': nbDocuments,
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
    );
  }

  /// Whether this library has any documents.
  bool get hasDocuments => nbDocuments != null && nbDocuments! > 0;

  /// Whether this library is empty.
  bool get isEmpty => nbDocuments == null || nbDocuments == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Library && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Library(id: $id, name: $name, documents: ${nbDocuments ?? 0})';
}

/// A list of libraries returned from the API.
@immutable
class LibraryList {
  /// The object type, always "list".
  final String object;

  /// The list of libraries.
  final List<Library> data;

  /// The total number of libraries available.
  final int? total;

  /// Whether there are more libraries to fetch.
  final bool? hasMore;

  /// Creates a [LibraryList].
  const LibraryList({
    this.object = 'list',
    required this.data,
    this.total,
    this.hasMore,
  });

  /// Creates a [LibraryList] from JSON.
  factory LibraryList.fromJson(Map<String, dynamic> json) {
    return LibraryList(
      object: json['object'] as String? ?? 'list',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Library.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int?,
      hasMore: json['has_more'] as bool?,
    );
  }

  /// Converts this list to JSON.
  Map<String, dynamic> toJson() {
    return {
      'object': object,
      'data': data.map((e) => e.toJson()).toList(),
      if (total != null) 'total': total,
      if (hasMore != null) 'has_more': hasMore,
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
          listEquals(data, other.data) &&
          total == other.total &&
          hasMore == other.hasMore;

  @override
  int get hashCode => Object.hash(object, Object.hashAll(data), total, hasMore);

  @override
  String toString() => 'LibraryList(count: $length, total: $total)';
}
