import '../copy_with_sentinel.dart';
import 'image_search.dart';
import 'web_search.dart';

/// Search types configuration.
class SearchTypes {
  /// Optional. Image search configuration.
  final ImageSearch? imageSearch;

  /// Optional. Web search configuration.
  final WebSearch? webSearch;

  /// Creates a [SearchTypes].
  const SearchTypes({this.imageSearch, this.webSearch});

  /// Creates a [SearchTypes] from JSON.
  factory SearchTypes.fromJson(Map<String, dynamic> json) => SearchTypes(
    imageSearch: json['imageSearch'] != null
        ? ImageSearch.fromJson(json['imageSearch'] as Map<String, dynamic>)
        : null,
    webSearch: json['webSearch'] != null
        ? WebSearch.fromJson(json['webSearch'] as Map<String, dynamic>)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (imageSearch != null) 'imageSearch': imageSearch!.toJson(),
    if (webSearch != null) 'webSearch': webSearch!.toJson(),
  };

  /// Creates a copy with replaced values.
  SearchTypes copyWith({
    Object? imageSearch = unsetCopyWithValue,
    Object? webSearch = unsetCopyWithValue,
  }) {
    return SearchTypes(
      imageSearch: imageSearch == unsetCopyWithValue
          ? this.imageSearch
          : imageSearch as ImageSearch?,
      webSearch: webSearch == unsetCopyWithValue
          ? this.webSearch
          : webSearch as WebSearch?,
    );
  }

  @override
  String toString() =>
      'SearchTypes(imageSearch: $imageSearch, webSearch: $webSearch)';
}
