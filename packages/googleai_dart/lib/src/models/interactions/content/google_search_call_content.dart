part of 'content.dart';

/// A Google Search call content block.
class GoogleSearchCallContent extends InteractionContent {
  @override
  String get type => 'google_search_call';

  /// A unique ID for this specific tool call.
  final String id;

  /// Web search queries for the following-up web search.
  final List<String>? queries;

  /// The type of search grounding enabled.
  final String? searchType;

  /// The signature of the Google Search call.
  final String? signature;

  /// Creates a [GoogleSearchCallContent] instance.
  const GoogleSearchCallContent({
    required this.id,
    this.queries,
    this.searchType,
    this.signature,
  });

  /// Creates a [GoogleSearchCallContent] from JSON.
  ///
  /// The [id] field defaults to `''` when absent (e.g. content.start events).
  factory GoogleSearchCallContent.fromJson(Map<String, dynamic> json) {
    final arguments = json['arguments'] as Map<String, dynamic>?;
    return GoogleSearchCallContent(
      id: json['id'] as String? ?? '',
      queries: (arguments?['queries'] as List<dynamic>?)?.cast<String>(),
      searchType: json['search_type'] as String?,
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'arguments': {if (queries != null) 'queries': queries},
    if (searchType != null) 'search_type': searchType,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  GoogleSearchCallContent copyWith({
    Object? id = unsetCopyWithValue,
    Object? queries = unsetCopyWithValue,
    Object? searchType = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return GoogleSearchCallContent(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      queries: queries == unsetCopyWithValue
          ? this.queries
          : queries as List<String>?,
      searchType: searchType == unsetCopyWithValue
          ? this.searchType
          : searchType as String?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
