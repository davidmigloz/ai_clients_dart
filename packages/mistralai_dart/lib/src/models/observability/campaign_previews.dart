import 'package:meta/meta.dart';

import 'campaign_preview.dart';
import 'paginated_result.dart';

/// Response containing a paginated list of campaign previews.
@immutable
class CampaignPreviews {
  /// The paginated campaigns.
  final PaginatedResult<CampaignPreview> campaigns;

  /// Creates a [CampaignPreviews].
  const CampaignPreviews({required this.campaigns});

  /// Creates a [CampaignPreviews] from JSON.
  factory CampaignPreviews.fromJson(Map<String, dynamic> json) =>
      CampaignPreviews(
        campaigns: PaginatedResult.fromJson(
          json['campaigns'] as Map<String, dynamic>? ?? {},
          CampaignPreview.fromJson,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'campaigns': campaigns.toJson((e) => e.toJson()),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CampaignPreviews) return false;
    if (runtimeType != other.runtimeType) return false;
    return campaigns == other.campaigns;
  }

  @override
  int get hashCode => campaigns.hashCode;

  @override
  String toString() => 'CampaignPreviews(campaigns: $campaigns)';
}
