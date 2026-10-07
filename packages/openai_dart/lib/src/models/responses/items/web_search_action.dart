import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';

/// An action performed by the web search tool.
///
/// Variants are [WebSearchActionSearch], [WebSearchActionOpenPage],
/// [WebSearchActionFind], and [UnknownWebSearchAction] for future objects.
sealed class WebSearchAction {
  /// Creates a [WebSearchAction].
  const WebSearchAction();

  /// The action discriminator.
  String get type;

  /// Parses known actions, preserving future action objects.
  factory WebSearchAction.fromJson(
    Map<String, dynamic> json, {
    String context = 'WebSearchAction',
  }) {
    final type = requireJsonString(json['type'], '$context.type');
    return switch (type) {
      'search' => WebSearchActionSearch.fromJson(json, context: context),
      'open_page' => WebSearchActionOpenPage.fromJson(json, context: context),
      'find_in_page' => WebSearchActionFind.fromJson(json, context: context),
      _ => UnknownWebSearchAction(type: type, data: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A web search query or group of queries.
@immutable
class WebSearchActionSearch extends WebSearchAction {
  @override
  String get type => 'search';

  /// The queries sent to the search tool.
  final List<String>? queries;

  /// The legacy single query, deprecated upstream in favor of [queries].
  final String? query;

  /// Source URLs, when requested with `web_search_call.action.sources`.
  final List<WebSearchActionSource>? sources;

  /// Creates a search action, taking immutable snapshots of its lists.
  WebSearchActionSearch({
    List<String>? queries,
    this.query,
    List<WebSearchActionSource>? sources,
  }) : queries = queries == null ? null : List.unmodifiable(queries),
       sources = sources == null ? null : List.unmodifiable(sources);

  /// Creates a [WebSearchActionSearch] from JSON.
  factory WebSearchActionSearch.fromJson(
    Map<String, dynamic> json, {
    String context = 'WebSearchActionSearch',
  }) {
    requireJsonType(json, 'search', context);
    final rawQueries = json['queries'];
    if (json.containsKey('queries') && rawQueries is! List) {
      throw FormatException('$context.queries: expected an array');
    }
    final rawSources = json['sources'];
    if (json.containsKey('sources') && rawSources is! List) {
      throw FormatException('$context.sources: expected an array');
    }
    return WebSearchActionSearch(
      queries: rawQueries is List
          ? [
              for (var i = 0; i < rawQueries.length; i++)
                requireJsonString(rawQueries[i], '$context.queries[$i]'),
            ]
          : null,
      query: optionalJsonString(json, 'query', context),
      sources: rawSources is List
          ? [
              for (var i = 0; i < rawSources.length; i++)
                WebSearchActionSource.fromJson(
                  requireJsonObject(rawSources[i], '$context.sources[$i]'),
                  context: '$context.sources[$i]',
                ),
            ]
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (queries != null) 'queries': queries,
    if (query != null) 'query': query,
    if (sources != null) 'sources': sources!.map((e) => e.toJson()).toList(),
  };

  /// Copies every field; explicit null clears an optional value.
  WebSearchActionSearch copyWith({
    Object? queries = unsetCopyWithValue,
    Object? query = unsetCopyWithValue,
    Object? sources = unsetCopyWithValue,
  }) => WebSearchActionSearch(
    queries: queries == unsetCopyWithValue
        ? this.queries
        : queries as List<String>?,
    query: query == unsetCopyWithValue ? this.query : query as String?,
    sources: sources == unsetCopyWithValue
        ? this.sources
        : sources as List<WebSearchActionSource>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchActionSearch &&
          runtimeType == other.runtimeType &&
          listsEqual(queries, other.queries) &&
          query == other.query &&
          listsEqual(sources, other.sources);

  @override
  int get hashCode => Object.hash(listHash(queries), query, listHash(sources));

  @override
  String toString() =>
      'WebSearchActionSearch(type: $type, queries: ${queries == null ? 'null' : '${queries!.length} items'}, query: ${query == null ? 'null' : '${query!.length} chars'}, sources: ${sources == null ? 'null' : '${sources!.length} items'})';
}

/// A URL source used by a web search.
@immutable
class WebSearchActionSource {
  /// The fixed source discriminator.
  String get type => 'url';

  /// The URL of the source.
  final String url;

  /// Creates a URL source.
  const WebSearchActionSource({required this.url});

  /// Creates a [WebSearchActionSource] from JSON.
  factory WebSearchActionSource.fromJson(
    Map<String, dynamic> json, {
    String context = 'WebSearchActionSource',
  }) {
    requireJsonType(json, 'url', context);
    return WebSearchActionSource(
      url: requireJsonString(json['url'], '$context.url'),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'url': url};

  /// Copies the source URL.
  WebSearchActionSource copyWith({String? url}) =>
      WebSearchActionSource(url: url ?? this.url);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchActionSource &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() =>
      'WebSearchActionSource(type: $type, url: ${url.length} chars)';
}

/// An action that opens a page from search results.
@immutable
class WebSearchActionOpenPage extends WebSearchAction {
  @override
  String get type => 'open_page';

  /// The URL opened by the model, when provided.
  final String? url;

  /// Creates a page-opening action.
  const WebSearchActionOpenPage({this.url});

  /// Creates a [WebSearchActionOpenPage] from JSON.
  factory WebSearchActionOpenPage.fromJson(
    Map<String, dynamic> json, {
    String context = 'WebSearchActionOpenPage',
  }) {
    requireJsonType(json, 'open_page', context);
    return WebSearchActionOpenPage(
      url: optionalJsonString(json, 'url', context, nullable: true),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, if (url != null) 'url': url};

  /// Copies the URL; explicit null clears it.
  WebSearchActionOpenPage copyWith({Object? url = unsetCopyWithValue}) =>
      WebSearchActionOpenPage(
        url: url == unsetCopyWithValue ? this.url : url as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchActionOpenPage &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() =>
      'WebSearchActionOpenPage(type: $type, url: ${url == null ? 'null' : '${url!.length} chars'})';
}

/// An action that searches for a pattern within a loaded page.
@immutable
class WebSearchActionFind extends WebSearchAction {
  @override
  String get type => 'find_in_page';

  /// The page URL.
  final String url;

  /// The pattern or text searched for in the page.
  final String pattern;

  /// Creates a page-search action.
  const WebSearchActionFind({required this.url, required this.pattern});

  /// Creates a [WebSearchActionFind] from JSON.
  factory WebSearchActionFind.fromJson(
    Map<String, dynamic> json, {
    String context = 'WebSearchActionFind',
  }) {
    requireJsonType(json, 'find_in_page', context);
    return WebSearchActionFind(
      url: requireJsonString(json['url'], '$context.url'),
      pattern: requireJsonString(json['pattern'], '$context.pattern'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'url': url,
    'pattern': pattern,
  };

  /// Copies every field.
  WebSearchActionFind copyWith({String? url, String? pattern}) =>
      WebSearchActionFind(
        url: url ?? this.url,
        pattern: pattern ?? this.pattern,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchActionFind &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          pattern == other.pattern;

  @override
  int get hashCode => Object.hash(url, pattern);

  @override
  String toString() =>
      'WebSearchActionFind(type: $type, url: ${url.length} chars, pattern: ${pattern.length} chars)';
}

/// A future action preserved without interpreting its JSON fields.
@immutable
class UnknownWebSearchAction extends WebSearchAction {
  @override
  final String type;

  /// A recursively immutable snapshot of the original action JSON.
  final Map<String, dynamic> data;

  /// Creates an unknown action, taking a recursively immutable snapshot.
  UnknownWebSearchAction({
    required this.type,
    required Map<String, dynamic> data,
  }) : data = freezeJsonObject({...data, 'type': type});

  @override
  Map<String, dynamic> toJson() => {...data, 'type': type};

  /// Copies every field, taking a fresh immutable snapshot of [data].
  UnknownWebSearchAction copyWith({String? type, Map<String, dynamic>? data}) =>
      UnknownWebSearchAction(type: type ?? this.type, data: data ?? this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownWebSearchAction &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(data, other.data);

  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(data));

  @override
  String toString() =>
      'UnknownWebSearchAction(type: $type, data: ${data.length} entries)';
}
