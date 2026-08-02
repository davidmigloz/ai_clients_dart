import 'package:meta/meta.dart';

import 'register_vespa_index_request.dart';
import 'search_index_status.dart';

/// Request body for registering (or re-registering) a RAG search index
/// (beta).
///
/// Currently only Vespa-backed indexes are supported by the API, so [index]
/// is always a [RegisterVespaIndexRequest].
@immutable
class RegisterSearchIndexRequest {
  /// The human-readable name of the search index.
  final String name;

  /// The initial status of the search index.
  ///
  /// Defaults to [SearchIndexStatus.offline].
  final SearchIndexStatus status;

  /// The backend-specific information about the index.
  final RegisterVespaIndexRequest index;

  /// Creates a [RegisterSearchIndexRequest].
  const RegisterSearchIndexRequest({
    required this.name,
    this.status = SearchIndexStatus.offline,
    required this.index,
  });

  /// Creates a [RegisterSearchIndexRequest] from JSON.
  factory RegisterSearchIndexRequest.fromJson(Map<String, dynamic> json) =>
      RegisterSearchIndexRequest(
        name: json['name'] as String,
        status: json['status'] != null
            ? SearchIndexStatus.fromJson(json['status'] as String?)
            : SearchIndexStatus.offline,
        index: RegisterVespaIndexRequest.fromJson(
          json['index'] as Map<String, dynamic>,
        ),
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'status': status.toJson(),
    'index': index.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  RegisterSearchIndexRequest copyWith({
    String? name,
    SearchIndexStatus? status,
    RegisterVespaIndexRequest? index,
  }) => RegisterSearchIndexRequest(
    name: name ?? this.name,
    status: status ?? this.status,
    index: index ?? this.index,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterSearchIndexRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          status == other.status &&
          index == other.index;

  @override
  int get hashCode => Object.hash(name, status, index);

  @override
  String toString() =>
      'RegisterSearchIndexRequest(name: $name, status: $status, index: $index)';
}
