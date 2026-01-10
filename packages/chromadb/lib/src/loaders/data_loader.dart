/// Interface for loading data from URIs.
///
/// Implement this interface to load data (e.g., images, documents) from
/// URIs for embedding. This is useful for multimodal scenarios where
/// you want to store URIs in ChromaDB but load the actual content
/// dynamically for embedding.
///
/// Example:
/// ```dart
/// class ImageLoader implements DataLoader<List<String>> {
///   final http.Client client;
///
///   ImageLoader(this.client);
///
///   @override
///   Future<List<String>> call(List<String> uris) async {
///     final results = <String>[];
///     for (final uri in uris) {
///       final response = await client.get(Uri.parse(uri));
///       results.add(base64Encode(response.bodyBytes));
///     }
///     return results;
///   }
/// }
/// ```
abstract interface class DataLoader<T> {
  /// Loads data from the given URIs.
  ///
  /// [uris] - List of URIs to load data from.
  ///
  /// Returns the loaded data.
  Future<T> call(List<String> uris);
}

/// Type alias for loadable data (list of base64-encoded strings).
typedef Loadable = List<String>;
