import '../content/content.dart';
import '../copy_with_sentinel.dart';
import 'attribution_source_id.dart';

/// Attribution for a source that contributed to an answer.
///
/// This is populated for `GenerateAnswer` calls.
class GroundingAttribution {
  /// Grounding source content that makes up this attribution.
  final Content? content;

  /// Output only. Identifier for the source contributing to this attribution.
  final AttributionSourceId? sourceId;

  /// Creates a [GroundingAttribution].
  const GroundingAttribution({this.content, this.sourceId});

  /// Creates a [GroundingAttribution] from JSON.
  factory GroundingAttribution.fromJson(Map<String, dynamic> json) {
    return GroundingAttribution(
      content: json['content'] != null
          ? Content.fromJson(json['content'] as Map<String, dynamic>)
          : null,
      sourceId: json['sourceId'] != null
          ? AttributionSourceId.fromJson(
              json['sourceId'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (content != null) 'content': content!.toJson(),
    if (sourceId != null) 'sourceId': sourceId!.toJson(),
  };

  /// Creates a copy with replaced values.
  GroundingAttribution copyWith({
    Object? content = unsetCopyWithValue,
    Object? sourceId = unsetCopyWithValue,
  }) {
    return GroundingAttribution(
      content: content == unsetCopyWithValue
          ? this.content
          : content as Content?,
      sourceId: sourceId == unsetCopyWithValue
          ? this.sourceId
          : sourceId as AttributionSourceId?,
    );
  }
}
