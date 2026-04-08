import 'package:meta/meta.dart';

import 'filter_payload.dart';

/// Request to create a new campaign.
@immutable
class PostCampaignInSchema {
  /// Search parameters for selecting events.
  final FilterPayload searchParams;

  /// ID of the judge to use.
  final String judgeId;

  /// Campaign name (5-50 characters).
  final String name;

  /// Campaign description.
  final String description;

  /// Maximum number of events to evaluate (> 0, max 10000).
  final int maxNbEvents;

  /// Creates a [PostCampaignInSchema].
  const PostCampaignInSchema({
    required this.searchParams,
    required this.judgeId,
    required this.name,
    required this.description,
    required this.maxNbEvents,
  });

  /// Creates a [PostCampaignInSchema] from JSON.
  factory PostCampaignInSchema.fromJson(Map<String, dynamic> json) =>
      PostCampaignInSchema(
        searchParams: FilterPayload.fromJson(
          json['search_params'] as Map<String, dynamic>? ?? {},
        ),
        judgeId: json['judge_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        maxNbEvents: json['max_nb_events'] as int? ?? 0,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'search_params': searchParams.toJson(),
    'judge_id': judgeId,
    'name': name,
    'description': description,
    'max_nb_events': maxNbEvents,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostCampaignInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return searchParams == other.searchParams &&
        judgeId == other.judgeId &&
        name == other.name &&
        description == other.description &&
        maxNbEvents == other.maxNbEvents;
  }

  @override
  int get hashCode =>
      Object.hash(searchParams, judgeId, name, description, maxNbEvents);

  @override
  String toString() =>
      'PostCampaignInSchema(name: $name, judgeId: $judgeId, '
      'maxNbEvents: $maxNbEvents)';
}
