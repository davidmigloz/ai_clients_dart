import '../copy_with_sentinel.dart';

/// Grounding tool type associated with a [GroundingToolCount].
enum GroundingToolType {
  /// Grounding with Google Web Search and Image Search, & Web Grounding for
  /// Enterprise.
  googleSearch,

  /// Grounding with Google Maps.
  googleMaps,

  /// Grounding with customer's data, for example, VertexAISearch.
  retrieval,
}

/// Converts a JSON string to a [GroundingToolType], or `null` if unrecognized
/// (forward-compatible).
GroundingToolType? groundingToolTypeFromString(String? value) {
  return switch (value) {
    'google_search' => GroundingToolType.googleSearch,
    'google_maps' => GroundingToolType.googleMaps,
    'retrieval' => GroundingToolType.retrieval,
    _ => null,
  };
}

/// Converts a [GroundingToolType] to its JSON string.
String groundingToolTypeToString(GroundingToolType value) {
  return switch (value) {
    GroundingToolType.googleSearch => 'google_search',
    GroundingToolType.googleMaps => 'google_maps',
    GroundingToolType.retrieval => 'retrieval',
  };
}

/// The number of grounding tool counts.
class GroundingToolCount {
  /// The number of grounding tool counts.
  final int? count;

  /// The grounding tool type associated with the count.
  final GroundingToolType? type;

  /// Creates a [GroundingToolCount] instance.
  const GroundingToolCount({this.count, this.type});

  /// Creates a [GroundingToolCount] from JSON.
  factory GroundingToolCount.fromJson(Map<String, dynamic> json) =>
      GroundingToolCount(
        count: json['count'] as int?,
        type: groundingToolTypeFromString(json['type'] as String?),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (count != null) 'count': count,
    if (type != null) 'type': groundingToolTypeToString(type!),
  };

  /// Creates a copy with replaced values.
  GroundingToolCount copyWith({
    Object? count = unsetCopyWithValue,
    Object? type = unsetCopyWithValue,
  }) {
    return GroundingToolCount(
      count: count == unsetCopyWithValue ? this.count : count as int?,
      type: type == unsetCopyWithValue ? this.type : type as GroundingToolType?,
    );
  }
}
