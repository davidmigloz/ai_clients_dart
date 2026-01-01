import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import '../common/copy_with_sentinel.dart';

/// A document within a library.
@immutable
class LibraryDocument {
  /// The unique identifier for this document.
  final String id;

  /// The name of the document.
  final String name;

  /// The processing status of the document.
  final LibraryDocumentStatus status;

  /// The MIME type of the document.
  final String? mimeType;

  /// The size of the document in bytes.
  final int? size;

  /// The hash of the document content.
  final String? hash;

  /// When this document was created (Unix timestamp).
  final int? createdAt;

  /// When this document was last updated (Unix timestamp).
  final int? updatedAt;

  /// Number of pages in the document.
  final int? numberOfPages;

  /// A summary of the document content.
  final String? summary;

  /// Total tokens used for processing.
  final int? tokensProcessingTotal;

  /// Creates a [LibraryDocument].
  const LibraryDocument({
    required this.id,
    required this.name,
    required this.status,
    this.mimeType,
    this.size,
    this.hash,
    this.createdAt,
    this.updatedAt,
    this.numberOfPages,
    this.summary,
    this.tokensProcessingTotal,
  });

  /// Creates a [LibraryDocument] from JSON.
  factory LibraryDocument.fromJson(Map<String, dynamic> json) {
    return LibraryDocument(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      status: LibraryDocumentStatus.fromJson(
        json['processing_status'] as String? ?? 'unknown',
      ),
      mimeType: json['mime_type'] as String?,
      size: json['size'] as int?,
      hash: json['hash'] as String?,
      createdAt: json['created_at'] as int?,
      updatedAt: json['updated_at'] as int?,
      numberOfPages: json['number_of_pages'] as int?,
      summary: json['summary'] as String?,
      tokensProcessingTotal: json['tokens_processing_total'] as int?,
    );
  }

  /// Converts this document to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'processing_status': status.value,
      if (mimeType != null) 'mime_type': mimeType,
      if (size != null) 'size': size,
      if (hash != null) 'hash': hash,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (numberOfPages != null) 'number_of_pages': numberOfPages,
      if (summary != null) 'summary': summary,
      if (tokensProcessingTotal != null)
        'tokens_processing_total': tokensProcessingTotal,
    };
  }

  /// Creates a copy with the given fields replaced.
  ///
  /// Optional nullable fields can be explicitly set to null by passing `null`.
  /// To keep the original value, omit the parameter.
  LibraryDocument copyWith({
    String? id,
    String? name,
    LibraryDocumentStatus? status,
    Object? mimeType = unsetCopyWithValue,
    Object? size = unsetCopyWithValue,
    Object? hash = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? updatedAt = unsetCopyWithValue,
    Object? numberOfPages = unsetCopyWithValue,
    Object? summary = unsetCopyWithValue,
    Object? tokensProcessingTotal = unsetCopyWithValue,
  }) {
    return LibraryDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as String?,
      size: size == unsetCopyWithValue ? this.size : size as int?,
      hash: hash == unsetCopyWithValue ? this.hash : hash as String?,
      createdAt: createdAt == unsetCopyWithValue
          ? this.createdAt
          : createdAt as int?,
      updatedAt: updatedAt == unsetCopyWithValue
          ? this.updatedAt
          : updatedAt as int?,
      numberOfPages: numberOfPages == unsetCopyWithValue
          ? this.numberOfPages
          : numberOfPages as int?,
      summary: summary == unsetCopyWithValue
          ? this.summary
          : summary as String?,
      tokensProcessingTotal: tokensProcessingTotal == unsetCopyWithValue
          ? this.tokensProcessingTotal
          : tokensProcessingTotal as int?,
    );
  }

  /// Whether the document is still being processed.
  bool get isProcessing => status == LibraryDocumentStatus.running;

  /// Whether the document processing is complete.
  bool get isCompleted => status == LibraryDocumentStatus.completed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryDocument &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'LibraryDocument(id: $id, name: $name, status: $status)';
}

/// Processing status of a library document.
enum LibraryDocumentStatus {
  /// Document is being processed.
  running('Running'),

  /// Document processing is complete.
  completed('Completed'),

  /// Document processing failed.
  failed('Failed'),

  /// Unknown status.
  unknown('unknown');

  /// The string value of this status.
  final String value;

  const LibraryDocumentStatus(this.value);

  /// Creates a [LibraryDocumentStatus] from a JSON string.
  factory LibraryDocumentStatus.fromJson(String value) {
    return LibraryDocumentStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => LibraryDocumentStatus.unknown,
    );
  }
}

/// A list of documents in a library.
@immutable
class LibraryDocumentList {
  /// The object type, always "list".
  final String object;

  /// The list of documents.
  final List<LibraryDocument> data;

  /// The total number of documents available.
  final int? total;

  /// Whether there are more documents to fetch.
  final bool? hasMore;

  /// Creates a [LibraryDocumentList].
  const LibraryDocumentList({
    this.object = 'list',
    required this.data,
    this.total,
    this.hasMore,
  });

  /// Creates a [LibraryDocumentList] from JSON.
  factory LibraryDocumentList.fromJson(Map<String, dynamic> json) {
    return LibraryDocumentList(
      object: json['object'] as String? ?? 'list',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => LibraryDocument.fromJson(e as Map<String, dynamic>))
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

  /// The number of documents in this page.
  int get length => data.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryDocumentList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          listEquals(data, other.data) &&
          total == other.total &&
          hasMore == other.hasMore;

  @override
  int get hashCode => Object.hash(object, Object.hashAll(data), total, hasMore);

  @override
  String toString() => 'LibraryDocumentList(count: $length, total: $total)';
}

/// Text content extracted from a library document.
@immutable
class LibraryDocumentContent {
  /// The extracted text content.
  final String text;

  /// Signed URLs for accessing document resources.
  final List<String>? signedUrls;

  /// Creates a [LibraryDocumentContent].
  const LibraryDocumentContent({required this.text, this.signedUrls});

  /// Creates a [LibraryDocumentContent] from JSON.
  factory LibraryDocumentContent.fromJson(Map<String, dynamic> json) {
    return LibraryDocumentContent(
      text: json['text'] as String? ?? '',
      signedUrls: (json['signed_urls'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Converts this content to JSON.
  Map<String, dynamic> toJson() {
    return {'text': text, if (signedUrls != null) 'signed_urls': signedUrls};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryDocumentContent &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          listEquals(signedUrls, other.signedUrls);

  @override
  int get hashCode => Object.hash(text, Object.hashAll(signedUrls ?? []));

  @override
  String toString() => 'LibraryDocumentContent(text: ${text.length} chars)';
}
