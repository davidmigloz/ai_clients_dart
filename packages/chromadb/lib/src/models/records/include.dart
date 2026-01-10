/// Fields to include in record responses.
///
/// Use these values to control which fields are returned in
/// get, query, and search operations.
enum Include {
  /// Include document content.
  documents('documents'),

  /// Include embedding vectors.
  embeddings('embeddings'),

  /// Include metadata.
  metadatas('metadatas'),

  /// Include distances from query (query/search only).
  distances('distances'),

  /// Include URIs.
  uris('uris'),

  /// Include loaded data (from DataLoader).
  data('data');

  /// The API value for this include option.
  final String value;

  const Include(this.value);

  /// Converts a list of Include values to their API string representations.
  static List<String> toApiList(List<Include> includes) {
    return includes.map((i) => i.value).toList();
  }

  /// Creates an Include from its API string value.
  ///
  /// Returns null if the value is not recognized.
  static Include? fromValue(String value) {
    return switch (value) {
      'documents' => Include.documents,
      'embeddings' => Include.embeddings,
      'metadatas' => Include.metadatas,
      'distances' => Include.distances,
      'uris' => Include.uris,
      'data' => Include.data,
      _ => null,
    };
  }

  /// Parses a list of Include values from API strings.
  ///
  /// Unrecognized values are skipped.
  static List<Include> fromApiList(List<dynamic> values) {
    return values
        .map((v) => fromValue(v as String))
        .whereType<Include>()
        .toList();
  }

  /// Default includes for get operations.
  static const List<Include> defaultGet = [
    Include.documents,
    Include.metadatas,
  ];

  /// Default includes for query operations.
  static const List<Include> defaultQuery = [
    Include.documents,
    Include.metadatas,
    Include.distances,
  ];
}
