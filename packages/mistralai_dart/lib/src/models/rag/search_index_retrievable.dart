import 'package:meta/meta.dart';

import '../common/deep_unmodifiable_json.dart';
import '../common/equality_helpers.dart';

/// A single retrievable document stored within a RAG search index (beta).
///
/// [fields] is arbitrary JSON (`additionalProperties: true` in the spec), so
/// it is stored deeply unmodifiable (nested maps/lists included) and
/// compared/hashed deeply to account for nested maps and lists.
@immutable
class SearchIndexRetrievable {
  /// The native ID of the document in the underlying index.
  final String id;

  /// The fields stored for this document.
  final Map<String, dynamic> fields;

  /// Creates a [SearchIndexRetrievable].
  SearchIndexRetrievable({
    required this.id,
    required Map<String, dynamic> fields,
  }) : fields = deepUnmodifiableJson(fields)! as Map<String, dynamic>;

  /// Creates a [SearchIndexRetrievable] from JSON.
  factory SearchIndexRetrievable.fromJson(Map<String, dynamic> json) =>
      SearchIndexRetrievable(
        id: json['id'] as String,
        fields: json['fields'] as Map<String, dynamic>,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'fields': fields};

  /// Creates a copy with the given fields replaced.
  SearchIndexRetrievable copyWith({String? id, Map<String, dynamic>? fields}) =>
      SearchIndexRetrievable(id: id ?? this.id, fields: fields ?? this.fields);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchIndexRetrievable &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mapsDeepEqual(fields, other.fields);

  @override
  int get hashCode => Object.hash(id, mapDeepHashCode(fields));

  @override
  String toString() =>
      'SearchIndexRetrievable(id: $id, fields: ${fields.length} items)';
}
