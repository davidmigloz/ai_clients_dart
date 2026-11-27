import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// A managed Search SearchDocumentResult variant.
///
/// [AcceptedSearchDocument], [RejectedSearchDocument], or [UnknownSearchDocumentResult].
@immutable
sealed class SearchDocumentResult {
  const SearchDocumentResult();

  /// Parses an API payload.
  factory SearchDocumentResult.fromJson(Map<String, dynamic> json) =>
      switch (json['status']) {
        'accepted' => AcceptedSearchDocument.fromJson(json),
        'rejected' => RejectedSearchDocument.fromJson(json),
        _ => UnknownSearchDocumentResult(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future SearchDocumentResult value.
@immutable
final class UnknownSearchDocumentResult extends SearchDocumentResult {
  /// Creates a fallback from the original payload.
  UnknownSearchDocumentResult(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownSearchDocumentResult && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// The IngestDocumentsRequest wire payload.
@immutable
class IngestSearchDocumentsRequest {
  /// Creates a [IngestSearchDocumentsRequest].
  const IngestSearchDocumentsRequest({required this.documents});

  /// The documents field.
  final List<Map<String, dynamic>> documents;

  /// Parses a [IngestSearchDocumentsRequest] from JSON.
  factory IngestSearchDocumentsRequest.fromJson(Map<String, dynamic> json) {
    if (json['documents'] == null) {
      throw const FormatException(
        'IngestSearchDocumentsRequest: missing documents',
      );
    }
    return IngestSearchDocumentsRequest(
      documents: (json['documents'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'documents': documents};

  /// Creates a copy with the given fields replaced.
  IngestSearchDocumentsRequest copyWith({
    List<Map<String, dynamic>>? documents,
  }) => IngestSearchDocumentsRequest(documents: documents ?? this.documents);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngestSearchDocumentsRequest &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(documents, other.documents);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(documents)]);

  @override
  String toString() =>
      'IngestSearchDocumentsRequest('
      'documents: ${documents.length})';
}

/// The IngestDocumentsResponse wire payload.
@immutable
class IngestSearchDocumentsResponse {
  /// Creates a [IngestSearchDocumentsResponse].
  const IngestSearchDocumentsResponse({
    required this.accepted,
    required this.rejected,
    required this.results,
  });

  /// The accepted field.
  final int accepted;

  /// The rejected field.
  final int rejected;

  /// The results field.
  final List<SearchDocumentResult> results;

  /// Parses a [IngestSearchDocumentsResponse] from JSON.
  factory IngestSearchDocumentsResponse.fromJson(Map<String, dynamic> json) {
    if (json['accepted'] == null) {
      throw const FormatException(
        'IngestSearchDocumentsResponse: missing accepted',
      );
    }
    if (json['rejected'] == null) {
      throw const FormatException(
        'IngestSearchDocumentsResponse: missing rejected',
      );
    }
    if (json['results'] == null) {
      throw const FormatException(
        'IngestSearchDocumentsResponse: missing results',
      );
    }
    return IngestSearchDocumentsResponse(
      accepted: json['accepted'] as int,
      rejected: json['rejected'] as int,
      results: (json['results'] as List)
          .map(
            (item) =>
                SearchDocumentResult.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'accepted': accepted,
    'rejected': rejected,
    'results': results.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  IngestSearchDocumentsResponse copyWith({
    int? accepted,
    int? rejected,
    List<SearchDocumentResult>? results,
  }) => IngestSearchDocumentsResponse(
    accepted: accepted ?? this.accepted,
    rejected: rejected ?? this.rejected,
    results: results ?? this.results,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngestSearchDocumentsResponse &&
          runtimeType == other.runtimeType &&
          accepted == other.accepted &&
          rejected == other.rejected &&
          valuesDeepEqual(results, other.results);

  @override
  int get hashCode =>
      Object.hashAll([accepted, rejected, valueDeepHashCode(results)]);

  @override
  String toString() =>
      'IngestSearchDocumentsResponse('
      'accepted: $accepted, '
      'rejected: $rejected, '
      'results: ${results.length})';
}

/// The AcceptedDocumentResponse wire payload.
@immutable
class AcceptedSearchDocument extends SearchDocumentResult {
  /// Creates a [AcceptedSearchDocument].
  const AcceptedSearchDocument({
    required this.chunkCount,
    required this.documentId,
    required this.position,
  });

  /// The fixed status discriminator.
  String get status => 'accepted';

  /// The chunk_count field.
  final int chunkCount;

  /// The document_id field.
  final String documentId;

  /// The position field.
  final int position;

  /// Parses a [AcceptedSearchDocument] from JSON.
  factory AcceptedSearchDocument.fromJson(Map<String, dynamic> json) {
    if (json['status'] case final value? when value != 'accepted') {
      throw FormatException('AcceptedSearchDocument: unexpected status $value');
    }
    if (json['chunk_count'] == null) {
      throw const FormatException(
        'AcceptedSearchDocument: missing chunk_count',
      );
    }
    if (json['document_id'] == null) {
      throw const FormatException(
        'AcceptedSearchDocument: missing document_id',
      );
    }
    if (json['position'] == null) {
      throw const FormatException('AcceptedSearchDocument: missing position');
    }
    return AcceptedSearchDocument(
      chunkCount: json['chunk_count'] as int,
      documentId: json['document_id'] as String,
      position: json['position'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'status': status,
    'chunk_count': chunkCount,
    'document_id': documentId,
    'position': position,
  };

  /// Creates a copy with the given fields replaced.
  AcceptedSearchDocument copyWith({
    int? chunkCount,
    String? documentId,
    int? position,
  }) => AcceptedSearchDocument(
    chunkCount: chunkCount ?? this.chunkCount,
    documentId: documentId ?? this.documentId,
    position: position ?? this.position,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcceptedSearchDocument &&
          runtimeType == other.runtimeType &&
          chunkCount == other.chunkCount &&
          documentId == other.documentId &&
          position == other.position;

  @override
  int get hashCode => Object.hashAll([chunkCount, documentId, position]);

  @override
  String toString() =>
      'AcceptedSearchDocument('
      'chunkCount: $chunkCount, '
      'documentId: $documentId, '
      'position: $position)';
}

/// The RejectedDocumentResponse wire payload.
@immutable
class RejectedSearchDocument extends SearchDocumentResult {
  /// Creates a [RejectedSearchDocument].
  const RejectedSearchDocument({required this.errors, required this.position});

  /// The fixed status discriminator.
  String get status => 'rejected';

  /// The errors field.
  final List<SearchDocumentFieldError> errors;

  /// The position field.
  final int position;

  /// Parses a [RejectedSearchDocument] from JSON.
  factory RejectedSearchDocument.fromJson(Map<String, dynamic> json) {
    if (json['status'] case final value? when value != 'rejected') {
      throw FormatException('RejectedSearchDocument: unexpected status $value');
    }
    if (json['errors'] == null) {
      throw const FormatException('RejectedSearchDocument: missing errors');
    }
    if (json['position'] == null) {
      throw const FormatException('RejectedSearchDocument: missing position');
    }
    return RejectedSearchDocument(
      errors: (json['errors'] as List)
          .map(
            (item) =>
                SearchDocumentFieldError.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      position: json['position'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'status': status,
    'errors': errors.map((item) => item.toJson()).toList(),
    'position': position,
  };

  /// Creates a copy with the given fields replaced.
  RejectedSearchDocument copyWith({
    List<SearchDocumentFieldError>? errors,
    int? position,
  }) => RejectedSearchDocument(
    errors: errors ?? this.errors,
    position: position ?? this.position,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RejectedSearchDocument &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(errors, other.errors) &&
          position == other.position;

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(errors), position]);

  @override
  String toString() =>
      'RejectedSearchDocument('
      'errors: ${errors.length}, '
      'position: $position)';
}

/// A single field-level validation failure within a rejected document.
@immutable
class SearchDocumentFieldError {
  /// Creates a [SearchDocumentFieldError].
  const SearchDocumentFieldError({
    required this.location,
    required this.message,
    required this.type,
  });

  /// The location field.
  final List<Object> location;

  /// The message field.
  final String message;

  /// The type field.
  final String type;

  /// Parses a [SearchDocumentFieldError] from JSON.
  factory SearchDocumentFieldError.fromJson(Map<String, dynamic> json) {
    if (json['location'] == null) {
      throw const FormatException('SearchDocumentFieldError: missing location');
    }
    if (json['message'] == null) {
      throw const FormatException('SearchDocumentFieldError: missing message');
    }
    if (json['type'] == null) {
      throw const FormatException('SearchDocumentFieldError: missing type');
    }
    return SearchDocumentFieldError(
      location: (json['location'] as List)
          .map((item) => item as Object)
          .toList(),
      message: json['message'] as String,
      type: json['type'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'location': location,
    'message': message,
    'type': type,
  };

  /// Creates a copy with the given fields replaced.
  SearchDocumentFieldError copyWith({
    List<Object>? location,
    String? message,
    String? type,
  }) => SearchDocumentFieldError(
    location: location ?? this.location,
    message: message ?? this.message,
    type: type ?? this.type,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchDocumentFieldError &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(location, other.location) &&
          message == other.message &&
          type == other.type;

  @override
  int get hashCode =>
      Object.hashAll([valueDeepHashCode(location), message, type]);

  @override
  String toString() =>
      'SearchDocumentFieldError('
      'location: ${location.length}, '
      'message: $message, '
      'type: $type)';
}

/// The DeleteDocumentsRequest wire payload.
@immutable
class DeleteSearchDocumentsRequest {
  /// Creates a [DeleteSearchDocumentsRequest].
  const DeleteSearchDocumentsRequest({required this.documentIds});

  /// The document_ids field.
  final List<String> documentIds;

  /// Parses a [DeleteSearchDocumentsRequest] from JSON.
  factory DeleteSearchDocumentsRequest.fromJson(Map<String, dynamic> json) {
    if (json['document_ids'] == null) {
      throw const FormatException(
        'DeleteSearchDocumentsRequest: missing document_ids',
      );
    }
    return DeleteSearchDocumentsRequest(
      documentIds: (json['document_ids'] as List)
          .map((item) => item as String)
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'document_ids': documentIds};

  /// Creates a copy with the given fields replaced.
  DeleteSearchDocumentsRequest copyWith({List<String>? documentIds}) =>
      DeleteSearchDocumentsRequest(
        documentIds: documentIds ?? this.documentIds,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteSearchDocumentsRequest &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(documentIds, other.documentIds);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(documentIds)]);

  @override
  String toString() =>
      'DeleteSearchDocumentsRequest('
      'documentIds: ${documentIds.length})';
}

/// The DeleteDocumentsResponse wire payload.
@immutable
class DeleteSearchDocumentsResponse {
  /// Creates a [DeleteSearchDocumentsResponse].
  const DeleteSearchDocumentsResponse({
    required this.deletedDocumentIds,
    required this.missing,
  });

  /// The deleted_document_ids field.
  final List<String> deletedDocumentIds;

  /// The missing field.
  final List<String> missing;

  /// Parses a [DeleteSearchDocumentsResponse] from JSON.
  factory DeleteSearchDocumentsResponse.fromJson(Map<String, dynamic> json) {
    if (json['deleted_document_ids'] == null) {
      throw const FormatException(
        'DeleteSearchDocumentsResponse: missing deleted_document_ids',
      );
    }
    if (json['missing'] == null) {
      throw const FormatException(
        'DeleteSearchDocumentsResponse: missing missing',
      );
    }
    return DeleteSearchDocumentsResponse(
      deletedDocumentIds: (json['deleted_document_ids'] as List)
          .map((item) => item as String)
          .toList(),
      missing: (json['missing'] as List).map((item) => item as String).toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'deleted_document_ids': deletedDocumentIds,
    'missing': missing,
  };

  /// Creates a copy with the given fields replaced.
  DeleteSearchDocumentsResponse copyWith({
    List<String>? deletedDocumentIds,
    List<String>? missing,
  }) => DeleteSearchDocumentsResponse(
    deletedDocumentIds: deletedDocumentIds ?? this.deletedDocumentIds,
    missing: missing ?? this.missing,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteSearchDocumentsResponse &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(deletedDocumentIds, other.deletedDocumentIds) &&
          valuesDeepEqual(missing, other.missing);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(deletedDocumentIds),
    valueDeepHashCode(missing),
  ]);

  @override
  String toString() =>
      'DeleteSearchDocumentsResponse('
      'deletedDocumentIds: ${deletedDocumentIds.length}, '
      'missing: ${missing.length})';
}

/// Unranked chunk list in reading order (ascending start_offset).
@immutable
class SearchNavigationResponse {
  /// Creates a [SearchNavigationResponse].
  const SearchNavigationResponse({required this.chunks});

  /// The chunks field.
  final List<SearchNavigationChunk> chunks;

  /// Parses a [SearchNavigationResponse] from JSON.
  factory SearchNavigationResponse.fromJson(Map<String, dynamic> json) {
    if (json['chunks'] == null) {
      throw const FormatException('SearchNavigationResponse: missing chunks');
    }
    return SearchNavigationResponse(
      chunks: (json['chunks'] as List)
          .map(
            (item) =>
                SearchNavigationChunk.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'chunks': chunks.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  SearchNavigationResponse copyWith({List<SearchNavigationChunk>? chunks}) =>
      SearchNavigationResponse(chunks: chunks ?? this.chunks);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchNavigationResponse &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(chunks, other.chunks);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(chunks)]);

  @override
  String toString() =>
      'SearchNavigationResponse('
      'chunks: ${chunks.length})';
}

/// Wire chunk for navigation: same atom fields as search, no rank fields.
@immutable
class SearchNavigationChunk {
  /// Creates a [SearchNavigationChunk].
  const SearchNavigationChunk({
    required this.chunkType,
    required this.content,
    required this.endOffset,
    required this.id,
    required this.locator,
    this.metadata,
    this.parentRef,
    required this.sourceId,
    required this.startOffset,
    this.extra,
  });

  /// The chunk_type field.
  final String chunkType;

  /// The content field.
  final String content;

  /// The end_offset field.
  final int? endOffset;

  /// The id field.
  final String id;

  /// The locator field.
  final String locator;

  /// The metadata field.
  final Map<String, dynamic>? metadata;

  /// The parent_ref field.
  final String? parentRef;

  /// The source_id field.
  final String sourceId;

  /// The start_offset field.
  final int? startOffset;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [SearchNavigationChunk] from JSON.
  factory SearchNavigationChunk.fromJson(Map<String, dynamic> json) {
    if (json['chunk_type'] == null) {
      throw const FormatException('SearchNavigationChunk: missing chunk_type');
    }
    if (json['content'] == null) {
      throw const FormatException('SearchNavigationChunk: missing content');
    }
    if (!json.containsKey('end_offset')) {
      throw const FormatException('SearchNavigationChunk: missing end_offset');
    }
    if (json['id'] == null) {
      throw const FormatException('SearchNavigationChunk: missing id');
    }
    if (json['locator'] == null) {
      throw const FormatException('SearchNavigationChunk: missing locator');
    }
    if (json['source_id'] == null) {
      throw const FormatException('SearchNavigationChunk: missing source_id');
    }
    if (!json.containsKey('start_offset')) {
      throw const FormatException(
        'SearchNavigationChunk: missing start_offset',
      );
    }
    return SearchNavigationChunk(
      chunkType: json['chunk_type'] as String,
      content: json['content'] as String,
      endOffset: json['end_offset'] == null ? null : json['end_offset'] as int,
      id: json['id'] as String,
      locator: json['locator'] as String,
      metadata: json['metadata'] == null
          ? null
          : json['metadata'] as Map<String, dynamic>,
      parentRef: json['parent_ref'] == null
          ? null
          : json['parent_ref'] as String,
      sourceId: json['source_id'] as String,
      startOffset: json['start_offset'] == null
          ? null
          : json['start_offset'] as int,
      extra: {
        for (final entry in json.entries)
          if (!const {
            'chunk_type',
            'content',
            'end_offset',
            'id',
            'locator',
            'metadata',
            'parent_ref',
            'source_id',
            'start_offset',
          }.contains(entry.key))
            entry.key: entry.value,
      },
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'chunk_type': chunkType,
    'content': content,
    'end_offset': endOffset,
    'id': id,
    'locator': locator,
    'metadata': ?metadata,
    'parent_ref': ?parentRef,
    'source_id': sourceId,
    'start_offset': startOffset,
  };

  /// Creates a copy with the given fields replaced.
  SearchNavigationChunk copyWith({
    String? chunkType,
    String? content,
    Object? endOffset = unsetCopyWithValue,
    String? id,
    String? locator,
    Object? metadata = unsetCopyWithValue,
    Object? parentRef = unsetCopyWithValue,
    String? sourceId,
    Object? startOffset = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => SearchNavigationChunk(
    chunkType: chunkType ?? this.chunkType,
    content: content ?? this.content,
    endOffset: endOffset == unsetCopyWithValue
        ? this.endOffset
        : endOffset as int?,
    id: id ?? this.id,
    locator: locator ?? this.locator,
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : metadata as Map<String, dynamic>?,
    parentRef: parentRef == unsetCopyWithValue
        ? this.parentRef
        : parentRef as String?,
    sourceId: sourceId ?? this.sourceId,
    startOffset: startOffset == unsetCopyWithValue
        ? this.startOffset
        : startOffset as int?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : extra as Map<String, dynamic>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchNavigationChunk &&
          runtimeType == other.runtimeType &&
          chunkType == other.chunkType &&
          content == other.content &&
          endOffset == other.endOffset &&
          id == other.id &&
          locator == other.locator &&
          valuesDeepEqual(metadata, other.metadata) &&
          parentRef == other.parentRef &&
          sourceId == other.sourceId &&
          startOffset == other.startOffset &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    chunkType,
    content,
    endOffset,
    id,
    locator,
    valueDeepHashCode(metadata),
    parentRef,
    sourceId,
    startOffset,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'SearchNavigationChunk('
      'chunkType: $chunkType, '
      'content: $content, '
      'endOffset: $endOffset, '
      'id: $id, '
      'locator: $locator, '
      'metadata: ${metadata?.length}, '
      'parentRef: $parentRef, '
      'sourceId: $sourceId, '
      'startOffset: $startOffset, '
      'extra: ${extra?.length})';
}

/// The GrepRequest wire payload.
@immutable
class SearchGrepRequest {
  /// Creates a [SearchGrepRequest].
  const SearchGrepRequest({
    this.contentType,
    this.mode,
    required this.pattern,
    required this.sourceId,
    this.topK,
  });

  /// The content_type field.
  final String? contentType;

  /// The mode field.
  final SearchGrepMode? mode;

  /// The pattern field.
  final String pattern;

  /// The source_id field.
  final String sourceId;

  /// The top_k field.
  final int? topK;

  /// Parses a [SearchGrepRequest] from JSON.
  factory SearchGrepRequest.fromJson(Map<String, dynamic> json) {
    if (json['pattern'] == null) {
      throw const FormatException('SearchGrepRequest: missing pattern');
    }
    if (json['source_id'] == null) {
      throw const FormatException('SearchGrepRequest: missing source_id');
    }
    return SearchGrepRequest(
      contentType: json['content_type'] == null
          ? null
          : json['content_type'] as String,
      mode: json['mode'] == null
          ? null
          : SearchGrepMode.fromJson(json['mode'] as String),
      pattern: json['pattern'] as String,
      sourceId: json['source_id'] as String,
      topK: json['top_k'] == null ? null : json['top_k'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'content_type': ?contentType,
    if (mode != null) 'mode': mode!.toJson(),
    'pattern': pattern,
    'source_id': sourceId,
    'top_k': ?topK,
  };

  /// Creates a copy with the given fields replaced.
  SearchGrepRequest copyWith({
    Object? contentType = unsetCopyWithValue,
    Object? mode = unsetCopyWithValue,
    String? pattern,
    String? sourceId,
    Object? topK = unsetCopyWithValue,
  }) => SearchGrepRequest(
    contentType: contentType == unsetCopyWithValue
        ? this.contentType
        : contentType as String?,
    mode: mode == unsetCopyWithValue ? this.mode : mode as SearchGrepMode?,
    pattern: pattern ?? this.pattern,
    sourceId: sourceId ?? this.sourceId,
    topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchGrepRequest &&
          runtimeType == other.runtimeType &&
          contentType == other.contentType &&
          mode == other.mode &&
          pattern == other.pattern &&
          sourceId == other.sourceId &&
          topK == other.topK;

  @override
  int get hashCode =>
      Object.hashAll([contentType, mode, pattern, sourceId, topK]);

  @override
  String toString() =>
      'SearchGrepRequest('
      'contentType: $contentType, '
      'mode: $mode, '
      'pattern: $pattern, '
      'sourceId: $sourceId, '
      'topK: $topK)';
}

/// Values for SearchGrepMode.
enum SearchGrepMode {
  /// Represents phrase.
  phrase('phrase'),

  /// Represents term.
  term('term'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const SearchGrepMode(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static SearchGrepMode fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The NavigateRequest wire payload.
@immutable
class SearchNavigateRequest {
  /// Creates a [SearchNavigateRequest].
  const SearchNavigateRequest({
    this.contentType,
    required this.direction,
    required this.endOffset,
    required this.sourceId,
    required this.startOffset,
    this.topK,
  });

  /// The content_type field.
  final String? contentType;

  /// The direction field.
  final SearchNavigationDirection direction;

  /// The end_offset field.
  final int endOffset;

  /// The source_id field.
  final String sourceId;

  /// The start_offset field.
  final int startOffset;

  /// The top_k field.
  final int? topK;

  /// Parses a [SearchNavigateRequest] from JSON.
  factory SearchNavigateRequest.fromJson(Map<String, dynamic> json) {
    if (json['direction'] == null) {
      throw const FormatException('SearchNavigateRequest: missing direction');
    }
    if (json['end_offset'] == null) {
      throw const FormatException('SearchNavigateRequest: missing end_offset');
    }
    if (json['source_id'] == null) {
      throw const FormatException('SearchNavigateRequest: missing source_id');
    }
    if (json['start_offset'] == null) {
      throw const FormatException(
        'SearchNavigateRequest: missing start_offset',
      );
    }
    return SearchNavigateRequest(
      contentType: json['content_type'] == null
          ? null
          : json['content_type'] as String,
      direction: SearchNavigationDirection.fromJson(
        json['direction'] as String,
      ),
      endOffset: json['end_offset'] as int,
      sourceId: json['source_id'] as String,
      startOffset: json['start_offset'] as int,
      topK: json['top_k'] == null ? null : json['top_k'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'content_type': ?contentType,
    'direction': direction.toJson(),
    'end_offset': endOffset,
    'source_id': sourceId,
    'start_offset': startOffset,
    'top_k': ?topK,
  };

  /// Creates a copy with the given fields replaced.
  SearchNavigateRequest copyWith({
    Object? contentType = unsetCopyWithValue,
    SearchNavigationDirection? direction,
    int? endOffset,
    String? sourceId,
    int? startOffset,
    Object? topK = unsetCopyWithValue,
  }) => SearchNavigateRequest(
    contentType: contentType == unsetCopyWithValue
        ? this.contentType
        : contentType as String?,
    direction: direction ?? this.direction,
    endOffset: endOffset ?? this.endOffset,
    sourceId: sourceId ?? this.sourceId,
    startOffset: startOffset ?? this.startOffset,
    topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchNavigateRequest &&
          runtimeType == other.runtimeType &&
          contentType == other.contentType &&
          direction == other.direction &&
          endOffset == other.endOffset &&
          sourceId == other.sourceId &&
          startOffset == other.startOffset &&
          topK == other.topK;

  @override
  int get hashCode => Object.hashAll([
    contentType,
    direction,
    endOffset,
    sourceId,
    startOffset,
    topK,
  ]);

  @override
  String toString() =>
      'SearchNavigateRequest('
      'contentType: $contentType, '
      'direction: $direction, '
      'endOffset: $endOffset, '
      'sourceId: $sourceId, '
      'startOffset: $startOffset, '
      'topK: $topK)';
}

/// Values for SearchNavigationDirection.
enum SearchNavigationDirection {
  /// Represents next.
  next('next'),

  /// Represents previous.
  previous('previous'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const SearchNavigationDirection(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static SearchNavigationDirection fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The ReadRequest wire payload.
@immutable
class SearchReadRequest {
  /// Creates a [SearchReadRequest].
  const SearchReadRequest({
    this.contentType,
    this.endOffset,
    required this.sourceId,
    this.startOffset,
    this.topK,
  });

  /// The content_type field.
  final String? contentType;

  /// The end_offset field.
  final int? endOffset;

  /// The source_id field.
  final String sourceId;

  /// The start_offset field.
  final int? startOffset;

  /// The top_k field.
  final int? topK;

  /// Parses a [SearchReadRequest] from JSON.
  factory SearchReadRequest.fromJson(Map<String, dynamic> json) {
    if (json['source_id'] == null) {
      throw const FormatException('SearchReadRequest: missing source_id');
    }
    return SearchReadRequest(
      contentType: json['content_type'] == null
          ? null
          : json['content_type'] as String,
      endOffset: json['end_offset'] == null ? null : json['end_offset'] as int,
      sourceId: json['source_id'] as String,
      startOffset: json['start_offset'] == null
          ? null
          : json['start_offset'] as int,
      topK: json['top_k'] == null ? null : json['top_k'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'content_type': ?contentType,
    'end_offset': ?endOffset,
    'source_id': sourceId,
    'start_offset': ?startOffset,
    'top_k': ?topK,
  };

  /// Creates a copy with the given fields replaced.
  SearchReadRequest copyWith({
    Object? contentType = unsetCopyWithValue,
    Object? endOffset = unsetCopyWithValue,
    String? sourceId,
    Object? startOffset = unsetCopyWithValue,
    Object? topK = unsetCopyWithValue,
  }) => SearchReadRequest(
    contentType: contentType == unsetCopyWithValue
        ? this.contentType
        : contentType as String?,
    endOffset: endOffset == unsetCopyWithValue
        ? this.endOffset
        : endOffset as int?,
    sourceId: sourceId ?? this.sourceId,
    startOffset: startOffset == unsetCopyWithValue
        ? this.startOffset
        : startOffset as int?,
    topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchReadRequest &&
          runtimeType == other.runtimeType &&
          contentType == other.contentType &&
          endOffset == other.endOffset &&
          sourceId == other.sourceId &&
          startOffset == other.startOffset &&
          topK == other.topK;

  @override
  int get hashCode =>
      Object.hashAll([contentType, endOffset, sourceId, startOffset, topK]);

  @override
  String toString() =>
      'SearchReadRequest('
      'contentType: $contentType, '
      'endOffset: $endOffset, '
      'sourceId: $sourceId, '
      'startOffset: $startOffset, '
      'topK: $topK)';
}
