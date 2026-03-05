/// The type of content to search for in web search.
enum SearchContentType {
  /// Unknown type (fallback for unrecognized values).
  unknown('unknown'),

  /// Text content.
  text('text'),

  /// Image content.
  image('image');

  /// The JSON value for this type.
  final String value;

  const SearchContentType(this.value);

  /// Creates a [SearchContentType] from a JSON value.
  factory SearchContentType.fromJson(String json) {
    return SearchContentType.values.firstWhere(
      (e) => e.value == json,
      orElse: () => SearchContentType.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
