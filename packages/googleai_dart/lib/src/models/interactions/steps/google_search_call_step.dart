part of 'steps.dart';

/// The type of search grounding enabled by [GoogleSearchCallStep].
enum GoogleSearchType {
  /// Web search. Only text results are returned.
  webSearch,

  /// Image search. Image bytes are returned.
  imageSearch,

  /// Enterprise web search.
  enterpriseWebSearch,
}

/// Converts a JSON string to a [GoogleSearchType], or `null` if unrecognized
/// (forward-compatible).
GoogleSearchType? googleSearchTypeFromString(String? value) {
  return switch (value) {
    'web_search' => GoogleSearchType.webSearch,
    'image_search' => GoogleSearchType.imageSearch,
    'enterprise_web_search' => GoogleSearchType.enterpriseWebSearch,
    _ => null,
  };
}

/// Converts a [GoogleSearchType] to its JSON string.
String googleSearchTypeToString(GoogleSearchType value) {
  return switch (value) {
    GoogleSearchType.webSearch => 'web_search',
    GoogleSearchType.imageSearch => 'image_search',
    GoogleSearchType.enterpriseWebSearch => 'enterprise_web_search',
  };
}

/// A Google Search tool call step.
class GoogleSearchCallStep extends InteractionStep {
  @override
  String get type => 'google_search_call';

  /// A unique ID for this specific tool call.
  final String id;

  /// The arguments to pass to Google Search.
  final GoogleSearchCallStepArguments arguments;

  /// The type of search grounding enabled.
  final GoogleSearchType? searchType;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [GoogleSearchCallStep] instance.
  const GoogleSearchCallStep({
    required this.id,
    required this.arguments,
    this.searchType,
    this.signature,
  });

  /// Creates a [GoogleSearchCallStep] from JSON.
  factory GoogleSearchCallStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'google_search_call') {
      throw FormatException(
        'Expected type "google_search_call" but got "${json['type']}"',
      );
    }
    final id = json['id'];
    if (id is! String) {
      throw const FormatException(
        'GoogleSearchCallStep: missing required "id"',
      );
    }
    // In streaming `step.start`, the step arrives as a partial skeleton and
    // `arguments` is populated later via `step.delta`; default to empty when
    // absent.
    final argumentsJson = json['arguments'];
    final arguments = argumentsJson is Map<String, dynamic>
        ? GoogleSearchCallStepArguments.fromJson(argumentsJson)
        : const GoogleSearchCallStepArguments();
    return GoogleSearchCallStep(
      id: id,
      arguments: arguments,
      searchType: googleSearchTypeFromString(json['search_type'] as String?),
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'arguments': arguments.toJson(),
    if (searchType != null)
      'search_type': googleSearchTypeToString(searchType!),
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  GoogleSearchCallStep copyWith({
    Object? id = unsetCopyWithValue,
    Object? arguments = unsetCopyWithValue,
    Object? searchType = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return GoogleSearchCallStep(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      arguments: arguments == unsetCopyWithValue
          ? this.arguments
          : arguments! as GoogleSearchCallStepArguments,
      searchType: searchType == unsetCopyWithValue
          ? this.searchType
          : searchType as GoogleSearchType?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}

/// The arguments to pass to Google Search.
class GoogleSearchCallStepArguments {
  /// Web search queries for the following-up web search.
  final List<String>? queries;

  /// Creates a [GoogleSearchCallStepArguments] instance.
  const GoogleSearchCallStepArguments({this.queries});

  /// Creates from JSON.
  factory GoogleSearchCallStepArguments.fromJson(Map<String, dynamic> json) =>
      GoogleSearchCallStepArguments(
        queries: (json['queries'] as List<dynamic>?)?.cast<String>(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (queries != null) 'queries': queries};

  /// Creates a copy with replaced values.
  GoogleSearchCallStepArguments copyWith({
    Object? queries = unsetCopyWithValue,
  }) {
    return GoogleSearchCallStepArguments(
      queries: queries == unsetCopyWithValue
          ? this.queries
          : queries as List<String>?,
    );
  }
}
