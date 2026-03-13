part of 'tools.dart';

/// A tool that allows the model to search Google.
class GoogleSearchTool extends InteractionTool {
  @override
  String get type => 'google_search';

  /// The types of search grounding to enable.
  final List<String>? searchTypes;

  /// Creates a [GoogleSearchTool] instance.
  const GoogleSearchTool({this.searchTypes});

  /// Creates a [GoogleSearchTool] from JSON.
  factory GoogleSearchTool.fromJson(Map<String, dynamic> json) =>
      GoogleSearchTool(
        searchTypes: (json['search_types'] as List<dynamic>?)?.cast<String>(),
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (searchTypes != null) 'search_types': searchTypes,
  };
}
