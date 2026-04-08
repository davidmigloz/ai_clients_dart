import 'package:meta/meta.dart';

import 'chat_completion_event_preview.dart';
import 'paginated_result.dart';

/// Response containing selected events for a campaign.
@immutable
class CampaignSelectedEvents {
  /// The paginated completion events.
  final PaginatedResult<ChatCompletionEventPreview> completionEvents;

  /// Creates a [CampaignSelectedEvents].
  const CampaignSelectedEvents({required this.completionEvents});

  /// Creates a [CampaignSelectedEvents] from JSON.
  factory CampaignSelectedEvents.fromJson(Map<String, dynamic> json) =>
      CampaignSelectedEvents(
        completionEvents: PaginatedResult.fromJson(
          json['completion_events'] as Map<String, dynamic>? ?? {},
          ChatCompletionEventPreview.fromJson,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'completion_events': completionEvents.toJson((e) => e.toJson()),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CampaignSelectedEvents) return false;
    if (runtimeType != other.runtimeType) return false;
    return completionEvents == other.completionEvents;
  }

  @override
  int get hashCode => completionEvents.hashCode;

  @override
  String toString() =>
      'CampaignSelectedEvents(completionEvents: $completionEvents)';
}
