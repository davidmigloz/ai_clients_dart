import '../copy_with_sentinel.dart';
import 'webhook.dart';

/// Response message for `WebhookService.ListWebhooks`.
class ListWebhooksResponse {
  /// The webhooks.
  final List<Webhook>? webhooks;

  /// A token, which can be sent as `pageToken` to retrieve the next page.
  /// If absent, there are no subsequent pages.
  final String? nextPageToken;

  /// Creates a [ListWebhooksResponse] instance.
  const ListWebhooksResponse({this.webhooks, this.nextPageToken});

  /// Creates a [ListWebhooksResponse] from JSON.
  factory ListWebhooksResponse.fromJson(Map<String, dynamic> json) =>
      ListWebhooksResponse(
        webhooks: (json['webhooks'] as List<dynamic>?)
            ?.map((e) => Webhook.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextPageToken: json['next_page_token'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (webhooks != null) 'webhooks': webhooks!.map((e) => e.toJson()).toList(),
    if (nextPageToken != null) 'next_page_token': nextPageToken,
  };

  /// Creates a copy with replaced values.
  ListWebhooksResponse copyWith({
    Object? webhooks = unsetCopyWithValue,
    Object? nextPageToken = unsetCopyWithValue,
  }) {
    return ListWebhooksResponse(
      webhooks: webhooks == unsetCopyWithValue
          ? this.webhooks
          : webhooks as List<Webhook>?,
      nextPageToken: nextPageToken == unsetCopyWithValue
          ? this.nextPageToken
          : nextPageToken as String?,
    );
  }
}
