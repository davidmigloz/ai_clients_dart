/// A paginator for iterating through page-based API results.
///
/// Mistral uses page-based pagination with `page` and `page_size` parameters.
/// This utility simplifies iterating through all pages of results.
///
/// Example (files):
/// ```dart
/// final paginator = Paginator<FileList, FileObject>(
///   fetcher: (page, pageSize) => client.files.list(
///     page: page,
///     pageSize: pageSize,
///   ),
///   getItems: (response) => response.data,
///   hasMore: (response, page, size) => response.data.length == size,
/// );
///
/// await for (final file in paginator.items()) {
///   print('File: ${file.filename}');
/// }
/// ```
///
/// Type parameters:
/// - [R]: The response type containing the page of items
/// - [T]: The individual item type
class Paginator<R, T> {
  /// Fetches a page of results.
  ///
  /// Parameters:
  /// - `page`: The page number
  /// - `pageSize`: The number of items per page
  final Future<R> Function(int page, int pageSize) fetcher;

  /// Extracts the list of items from a response.
  // ignore: unsafe_variance
  final List<T> Function(R response) getItems;

  /// Determines if there are more pages to fetch.
  ///
  /// Parameters:
  /// - `response`: The current response
  /// - `currentPage`: The current page number
  /// - `pageSize`: The page size used
  // ignore: unsafe_variance
  final bool Function(R response, int currentPage, int pageSize)? hasMore;

  /// Number of items per page.
  final int pageSize;

  /// Starting page number (typically 0 or 1).
  final int startPage;

  /// Creates a [Paginator].
  ///
  /// The [hasMore] function defaults to checking if the returned items
  /// count equals the page size.
  const Paginator({
    required this.fetcher,
    required this.getItems,
    this.hasMore,
    this.pageSize = 100,
    this.startPage = 0,
  });

  /// Streams all items from all pages.
  ///
  /// This is the recommended way to iterate through paginated results.
  ///
  /// Example:
  /// ```dart
  /// await for (final item in paginator.items()) {
  ///   print(item);
  /// }
  /// ```
  Stream<T> items() async* {
    var currentPage = startPage;
    var hasMorePages = true;

    while (hasMorePages) {
      final response = await fetcher(currentPage, pageSize);
      final pageItems = getItems(response);

      for (final item in pageItems) {
        yield item;
      }

      // Check if there are more pages
      hasMorePages = hasMore != null
          ? hasMore!(response, currentPage, pageSize)
          : pageItems.length == pageSize;

      currentPage++;
    }
  }

  /// Streams pages of results.
  ///
  /// Use this when you need access to the full response metadata.
  ///
  /// Example:
  /// ```dart
  /// await for (final page in paginator.pages()) {
  ///   print('Page with ${paginator.getItems(page).length} items');
  /// }
  /// ```
  Stream<R> pages() async* {
    var currentPage = startPage;
    var hasMorePages = true;

    while (hasMorePages) {
      final response = await fetcher(currentPage, pageSize);
      yield response;

      final pageItems = getItems(response);

      // Check if there are more pages
      hasMorePages = hasMore != null
          ? hasMore!(response, currentPage, pageSize)
          : pageItems.length == pageSize;

      currentPage++;
    }
  }

  /// Collects all items from all pages into a list.
  ///
  /// Note: This loads all items into memory. For large datasets,
  /// prefer using [items] to stream results.
  ///
  /// Example:
  /// ```dart
  /// final allItems = await paginator.collect();
  /// print('Total items: ${allItems.length}');
  /// ```
  Future<List<T>> collect() => items().toList();

  /// Collects all items up to a maximum count.
  ///
  /// Parameters:
  /// - [maxItems]: Maximum number of items to collect
  ///
  /// Example:
  /// ```dart
  /// final first100 = await paginator.take(100);
  /// ```
  Future<List<T>> take(int maxItems) => items().take(maxItems).toList();

  /// Finds the first item matching a predicate.
  ///
  /// Returns `null` if no item matches.
  ///
  /// Example:
  /// ```dart
  /// final file = await paginator.firstWhere((f) => f.filename == 'data.jsonl');
  /// ```
  Future<T?> firstWhere(bool Function(T item) predicate) async {
    await for (final item in items()) {
      if (predicate(item)) return item;
    }
    return null;
  }

  /// Counts all items across all pages.
  ///
  /// Note: This iterates through all pages, which may be slow
  /// for large datasets.
  ///
  /// Example:
  /// ```dart
  /// final count = await paginator.count();
  /// ```
  Future<int> count() => items().length;

  /// Checks if any item matches a predicate.
  ///
  /// Example:
  /// ```dart
  /// final hasPending = await paginator.any((job) => job.status == 'pending');
  /// ```
  Future<bool> any(bool Function(T item) predicate) => items().any(predicate);

  /// Checks if all items match a predicate.
  ///
  /// Example:
  /// ```dart
  /// final allComplete = await paginator.every((job) => job.status == 'complete');
  /// ```
  Future<bool> every(bool Function(T item) predicate) =>
      items().every(predicate);

  /// Transforms items as they are streamed.
  ///
  /// Example:
  /// ```dart
  /// final filenames = paginator.map((file) => file.filename);
  /// await for (final name in filenames) {
  ///   print(name);
  /// }
  /// ```
  Stream<U> map<U>(U Function(T item) transform) => items().map(transform);

  /// Filters items as they are streamed.
  ///
  /// Example:
  /// ```dart
  /// final jsonlFiles = paginator.where((file) => file.filename.endsWith('.jsonl'));
  /// await for (final file in jsonlFiles) {
  ///   print(file);
  /// }
  /// ```
  Stream<T> where(bool Function(T item) predicate) => items().where(predicate);
}
