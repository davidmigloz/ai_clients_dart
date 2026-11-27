import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../observability/pagination_info.dart';
import 'library_timestamp.dart';

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

  /// ID of the library containing this document.
  final String? libraryId;

  /// File extension of the document.
  final String? extension;

  /// Machine-readable status of the processing operation.
  final String? processStatus;

  /// Display label for the processing status.
  String get processingStatus => _processingStatus ?? status.value;

  final String? _processingStatus;

  /// ID of the uploader, when available.
  final String? uploadedById;

  /// Type of the uploader.
  final String? uploadedByType;

  /// ISO 8601 timestamp of the last processing operation.
  final String? lastProcessedAt;

  /// ISO 8601 timestamp when the document expires.
  final String? expiresAt;

  /// JSON attributes associated with the document.
  final Map<String, dynamic>? attributes;

  /// Source URL when supplied by the service.
  final String? url;

  /// Tokens for processing the main text.
  final int? tokensProcessingMainContent;

  /// Tokens for processing the summary.
  final int? tokensProcessingSummary;

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
    this.libraryId,
    this.extension,
    this.processStatus,
    this._processingStatus,
    this.uploadedById,
    this.uploadedByType,
    this.lastProcessedAt,
    this.expiresAt,
    this.attributes,
    this.url,
    this.tokensProcessingMainContent,
    this.tokensProcessingSummary,
  });

  /// Creates a [LibraryDocument] from JSON.
  factory LibraryDocument.fromJson(Map<String, dynamic> json) {
    return LibraryDocument(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      status: LibraryDocumentStatus.fromJson(
        json['process_status'] as String? ??
            json['processing_status'] as String? ??
            'unknown',
      ),
      mimeType: json['mime_type'] as String?,
      size: json['size'] as int?,
      hash: json['hash'] as String?,
      createdAt: parseLibraryTimestamp(json['created_at']),
      updatedAt: parseLibraryTimestamp(json['updated_at']),
      numberOfPages: json['number_of_pages'] as int?,
      summary: json['summary'] as String?,
      tokensProcessingTotal: json['tokens_processing_total'] as int?,
      libraryId: json['library_id'] as String?,
      extension: json['extension'] as String?,
      processStatus: json['process_status'] as String?,
      processingStatus: json['processing_status'] as String?,
      uploadedById: json['uploaded_by_id'] as String?,
      uploadedByType: json['uploaded_by_type'] as String?,
      lastProcessedAt: json['last_processed_at'] as String?,
      expiresAt: json['expires_at'] as String?,
      attributes: json['attributes'] as Map<String, dynamic>?,
      url: json['url'] as String?,
      tokensProcessingMainContent:
          json['tokens_processing_main_content'] as int?,
      tokensProcessingSummary: json['tokens_processing_summary'] as int?,
    );
  }

  /// Converts this document to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'processing_status': processingStatus,
      if (mimeType != null) 'mime_type': mimeType,
      if (size != null) 'size': size,
      if (hash != null) 'hash': hash,
      if (createdAt != null) 'created_at': formatLibraryTimestamp(createdAt!),
      if (updatedAt != null) 'updated_at': formatLibraryTimestamp(updatedAt!),
      if (numberOfPages != null) 'number_of_pages': numberOfPages,
      if (summary != null) 'summary': summary,
      if (tokensProcessingTotal != null)
        'tokens_processing_total': tokensProcessingTotal,
      'library_id': ?libraryId,
      'extension': ?extension,
      'process_status': ?processStatus,
      'uploaded_by_id': ?uploadedById,
      'uploaded_by_type': ?uploadedByType,
      'last_processed_at': ?lastProcessedAt,
      'expires_at': ?expiresAt,
      'attributes': ?attributes,
      'url': ?url,
      'tokens_processing_main_content': ?tokensProcessingMainContent,
      'tokens_processing_summary': ?tokensProcessingSummary,
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
    Object? libraryId = unsetCopyWithValue,
    Object? extension = unsetCopyWithValue,
    Object? processStatus = unsetCopyWithValue,
    Object? processingStatus = unsetCopyWithValue,
    Object? uploadedById = unsetCopyWithValue,
    Object? uploadedByType = unsetCopyWithValue,
    Object? lastProcessedAt = unsetCopyWithValue,
    Object? expiresAt = unsetCopyWithValue,
    Object? attributes = unsetCopyWithValue,
    Object? url = unsetCopyWithValue,
    Object? tokensProcessingMainContent = unsetCopyWithValue,
    Object? tokensProcessingSummary = unsetCopyWithValue,
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
      libraryId: libraryId == unsetCopyWithValue
          ? this.libraryId
          : libraryId as String?,
      extension: extension == unsetCopyWithValue
          ? this.extension
          : extension as String?,
      processStatus: processStatus == unsetCopyWithValue
          ? this.processStatus
          : processStatus as String?,
      processingStatus: processingStatus == unsetCopyWithValue
          ? _processingStatus
          : processingStatus as String?,
      uploadedById: uploadedById == unsetCopyWithValue
          ? this.uploadedById
          : uploadedById as String?,
      uploadedByType: uploadedByType == unsetCopyWithValue
          ? this.uploadedByType
          : uploadedByType as String?,
      lastProcessedAt: lastProcessedAt == unsetCopyWithValue
          ? this.lastProcessedAt
          : lastProcessedAt as String?,
      expiresAt: expiresAt == unsetCopyWithValue
          ? this.expiresAt
          : expiresAt as String?,
      attributes: attributes == unsetCopyWithValue
          ? this.attributes
          : attributes as Map<String, dynamic>?,
      url: url == unsetCopyWithValue ? this.url : url as String?,
      tokensProcessingMainContent:
          tokensProcessingMainContent == unsetCopyWithValue
          ? this.tokensProcessingMainContent
          : tokensProcessingMainContent as int?,
      tokensProcessingSummary: tokensProcessingSummary == unsetCopyWithValue
          ? this.tokensProcessingSummary
          : tokensProcessingSummary as int?,
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
          id == other.id &&
          name == other.name &&
          status == other.status &&
          mimeType == other.mimeType &&
          size == other.size &&
          hash == other.hash &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          numberOfPages == other.numberOfPages &&
          summary == other.summary &&
          tokensProcessingTotal == other.tokensProcessingTotal &&
          libraryId == other.libraryId &&
          extension == other.extension &&
          processStatus == other.processStatus &&
          processingStatus == other.processingStatus &&
          uploadedById == other.uploadedById &&
          uploadedByType == other.uploadedByType &&
          lastProcessedAt == other.lastProcessedAt &&
          expiresAt == other.expiresAt &&
          mapsDeepEqual(attributes, other.attributes) &&
          url == other.url &&
          tokensProcessingMainContent == other.tokensProcessingMainContent &&
          tokensProcessingSummary == other.tokensProcessingSummary;

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    status,
    mimeType,
    size,
    hash,
    createdAt,
    updatedAt,
    numberOfPages,
    summary,
    tokensProcessingTotal,
    libraryId,
    extension,
    processStatus,
    processingStatus,
    uploadedById,
    uploadedByType,
    lastProcessedAt,
    expiresAt,
    mapDeepHashCode(attributes),
    url,
    tokensProcessingMainContent,
    tokensProcessingSummary,
  ]);

  @override
  String toString() =>
      'LibraryDocument(id: $id, name: $name, status: $status, '
      'libraryId: $libraryId, processStatus: $processStatus)';
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
    final normalized = switch (value.toLowerCase()) {
      'todo' || 'in_progress' || 'waiting_for_capacity' => 'running',
      'done' || 'noop' || 'self_managed' => 'completed',
      'error' || 'missing_content' => 'failed',
      final String other => other,
    };
    return LibraryDocumentStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == normalized,
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

  /// Pagination details returned for an offset page.
  final PaginationInfo? pagination;

  /// Creates a [LibraryDocumentList].
  const LibraryDocumentList({
    this.object = 'list',
    required this.data,
    this.total,
    this.hasMore,
    this.pagination,
  });

  /// Creates a [LibraryDocumentList] from JSON.
  factory LibraryDocumentList.fromJson(Map<String, dynamic> json) {
    final paginationJson = json['pagination'] as Map<String, dynamic>?;
    final pagination = paginationJson == null
        ? null
        : PaginationInfo.fromJson(paginationJson);
    return LibraryDocumentList(
      object: json['object'] as String? ?? 'list',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => LibraryDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: pagination?.totalItems ?? json['total'] as int?,
      hasMore: pagination?.hasMore ?? json['has_more'] as bool?,
      pagination: pagination,
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
          listsEqual(data, other.data) &&
          total == other.total &&
          pagination == other.pagination &&
          hasMore == other.hasMore;

  @override
  int get hashCode =>
      Object.hash(object, Object.hashAll(data), total, hasMore, pagination);

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
          listsEqual(signedUrls, other.signedUrls);

  @override
  int get hashCode => Object.hash(text, listHash(signedUrls));

  @override
  String toString() => 'LibraryDocumentContent(text: ${text.length} chars)';
}
