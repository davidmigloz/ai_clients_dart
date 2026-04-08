import 'package:meta/meta.dart';

/// Request to import dataset records from a campaign.
@immutable
class PostDatasetImportFromCampaignInSchema {
  /// The campaign ID to import from.
  final String campaignId;

  /// Creates a [PostDatasetImportFromCampaignInSchema].
  const PostDatasetImportFromCampaignInSchema({required this.campaignId});

  /// Creates a [PostDatasetImportFromCampaignInSchema] from JSON.
  factory PostDatasetImportFromCampaignInSchema.fromJson(
    Map<String, dynamic> json,
  ) => PostDatasetImportFromCampaignInSchema(
    campaignId: json['campaign_id'] as String? ?? '',
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'campaign_id': campaignId};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDatasetImportFromCampaignInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return campaignId == other.campaignId;
  }

  @override
  int get hashCode => campaignId.hashCode;

  @override
  String toString() =>
      'PostDatasetImportFromCampaignInSchema(campaignId: $campaignId)';
}
