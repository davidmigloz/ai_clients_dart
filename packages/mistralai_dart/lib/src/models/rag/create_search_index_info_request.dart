import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'create_vespa_search_index_info_request.dart';
import 'search_index_status.dart';

/// Request body to register (or re-register) a RAG search index (beta).
@immutable
class CreateSearchIndexInfoRequest {
  /// The human-readable name of the search index.
  final String name;

  /// The backend-specific information about the index.
  ///
  /// Currently only Vespa indexes are supported.
  final CreateVespaSearchIndexInfoRequest index;

  /// The desired status of the search index.
  ///
  /// Defaults to [SearchIndexStatus.offline].
  final SearchIndexStatus status;

  /// The number of documents in the search index, or `null` if unknown.
  final int? documentCount;

  /// Creates a [CreateSearchIndexInfoRequest].
  const CreateSearchIndexInfoRequest({
    required this.name,
    required this.index,
    this.status = SearchIndexStatus.offline,
    this.documentCount,
  });

  /// Creates a [CreateSearchIndexInfoRequest] from JSON.
  factory CreateSearchIndexInfoRequest.fromJson(Map<String, dynamic> json) =>
      CreateSearchIndexInfoRequest(
        name: json['name'] as String,
        index: CreateVespaSearchIndexInfoRequest.fromJson(
          json['index'] as Map<String, dynamic>,
        ),
        status: json['status'] != null
            ? SearchIndexStatus.fromJson(json['status'] as String?)
            : SearchIndexStatus.offline,
        documentCount: json['document_count'] as int?,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'index': index.toJson(),
    'status': status.toJson(),
    if (documentCount != null) 'document_count': documentCount,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  CreateSearchIndexInfoRequest copyWith({
    String? name,
    CreateVespaSearchIndexInfoRequest? index,
    SearchIndexStatus? status,
    Object? documentCount = unsetCopyWithValue,
  }) => CreateSearchIndexInfoRequest(
    name: name ?? this.name,
    index: index ?? this.index,
    status: status ?? this.status,
    documentCount: documentCount == unsetCopyWithValue
        ? this.documentCount
        : documentCount as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateSearchIndexInfoRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          index == other.index &&
          status == other.status &&
          documentCount == other.documentCount;

  @override
  int get hashCode => Object.hash(name, index, status, documentCount);

  @override
  String toString() =>
      'CreateSearchIndexInfoRequest('
      'name: $name, index: $index, status: $status, '
      'documentCount: $documentCount)';
}
