import '../../../metadata/modality_token_count.dart';
import '../../../metadata/usage_metadata.dart';

/// Usage reported at the top level of a Live server message.
///
/// The Developer API names the generated counts `responseTokenCount` and
/// `responseTokensDetails`. Vertex AI calls them `candidatesTokenCount`
/// and `candidatesTokensDetails`. Both are exposed as response counts here.
class LiveUsageMetadata {
  /// The token counts and modality details, normalized to the shared model.
  final UsageMetadata counts;

  /// The Vertex AI traffic type, when reported.
  final String? trafficType;

  final Map<String, dynamic>? _wireJson;

  /// Creates Live usage metadata using the Developer API's wire field names.
  const LiveUsageMetadata({required this.counts, this.trafficType})
    : _wireJson = null;

  LiveUsageMetadata._(this.counts, this.trafficType, this._wireJson);

  /// Parses Developer API or Vertex AI usage metadata.
  factory LiveUsageMetadata.fromJson(Map<String, dynamic> json) {
    return LiveUsageMetadata._(
      UsageMetadata.fromJson({
        ...json,
        'candidatesTokenCount':
            json['responseTokenCount'] ?? json['candidatesTokenCount'],
        'candidatesTokensDetails':
            json['responseTokensDetails'] ?? json['candidatesTokensDetails'],
      }),
      json['trafficType'] as String?,
      Map.unmodifiable(json),
    );
  }

  /// Tokens generated in the response.
  int? get responseTokenCount => counts.candidatesTokenCount;

  /// Response tokens broken down by modality.
  List<ModalityTokenCount>? get responseTokensDetails =>
      counts.candidatesTokensDetails;

  /// Converts to JSON, preserving the original API field names when parsed.
  Map<String, dynamic> toJson() {
    final wireJson = _wireJson;
    if (wireJson != null) return Map.of(wireJson);

    final json = counts.toJson();
    final count = json.remove('candidatesTokenCount');
    final details = json.remove('candidatesTokensDetails');
    return {
      ...json,
      'responseTokenCount': ?count,
      'responseTokensDetails': ?details,
      if (trafficType != null) 'trafficType': trafficType,
    };
  }

  @override
  String toString() =>
      'LiveUsageMetadata(counts: $counts, trafficType: $trafficType)';
}
