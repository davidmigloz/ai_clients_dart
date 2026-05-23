import '../copy_with_sentinel.dart';

/// Webhook configuration for an interaction request.
///
/// Used to override the registered webhooks for a specific interaction and
/// optionally attach user metadata to outgoing webhook deliveries.
class WebhookConfig {
  /// If set, these webhook URIs will be used for webhook events instead of
  /// the registered webhooks.
  final List<String>? uris;

  /// User metadata that will be returned on each event emission to the
  /// webhooks.
  final Map<String, dynamic>? userMetadata;

  /// Creates a [WebhookConfig] instance.
  const WebhookConfig({this.uris, this.userMetadata});

  /// Creates a [WebhookConfig] from JSON.
  factory WebhookConfig.fromJson(Map<String, dynamic> json) => WebhookConfig(
    uris: (json['uris'] as List<dynamic>?)?.cast<String>(),
    userMetadata: json['user_metadata'] as Map<String, dynamic>?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (uris != null) 'uris': uris,
    if (userMetadata != null) 'user_metadata': userMetadata,
  };

  /// Creates a copy with replaced values.
  WebhookConfig copyWith({
    Object? uris = unsetCopyWithValue,
    Object? userMetadata = unsetCopyWithValue,
  }) {
    return WebhookConfig(
      uris: uris == unsetCopyWithValue ? this.uris : uris as List<String>?,
      userMetadata: userMetadata == unsetCopyWithValue
          ? this.userMetadata
          : userMetadata as Map<String, dynamic>?,
    );
  }
}
