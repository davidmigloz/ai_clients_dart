/// State of a [Webhook] resource.
enum WebhookState {
  /// The webhook is enabled.
  enabled,

  /// The webhook is disabled by the user.
  disabled,

  /// The webhook is disabled due to failed deliveries.
  disabledDueToFailedDeliveries,
}

/// Converts a JSON string to a [WebhookState], or `null` if unrecognized
/// (forward-compatible).
WebhookState? webhookStateFromString(String? value) {
  return switch (value) {
    'enabled' => WebhookState.enabled,
    'disabled' => WebhookState.disabled,
    'disabled_due_to_failed_deliveries' =>
      WebhookState.disabledDueToFailedDeliveries,
    _ => null,
  };
}

/// Converts a [WebhookState] to its JSON string.
String webhookStateToString(WebhookState value) {
  return switch (value) {
    WebhookState.enabled => 'enabled',
    WebhookState.disabled => 'disabled',
    WebhookState.disabledDueToFailedDeliveries =>
      'disabled_due_to_failed_deliveries',
  };
}
