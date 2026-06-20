/// The status of a RAG search index.
enum SearchIndexStatus {
  /// The index is online and serving queries.
  online('online'),

  /// The index is offline.
  offline('offline'),

  /// Unknown status (forward-compatibility fallback).
  unknown('unknown');

  const SearchIndexStatus(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [SearchIndexStatus] from a JSON string value.
  static SearchIndexStatus fromJson(String? value) {
    if (value == null) return SearchIndexStatus.unknown;
    return SearchIndexStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SearchIndexStatus.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
