/// The status of an interaction.
enum InteractionStatus {
  /// The interaction is in progress.
  inProgress,

  /// The interaction requires action from the user.
  requiresAction,

  /// The interaction has completed successfully.
  completed,

  /// The interaction has failed.
  failed,

  /// The interaction was cancelled.
  cancelled,

  /// The interaction is incomplete.
  incomplete,

  /// The interaction was halted because the token budget was exceeded.
  budgetExceeded;

  /// Creates an [InteractionStatus] from a JSON string.
  static InteractionStatus fromString(String? value) {
    return switch (value) {
      'in_progress' => InteractionStatus.inProgress,
      'requires_action' => InteractionStatus.requiresAction,
      'completed' => InteractionStatus.completed,
      'failed' => InteractionStatus.failed,
      'cancelled' => InteractionStatus.cancelled,
      'incomplete' => InteractionStatus.incomplete,
      'budget_exceeded' => InteractionStatus.budgetExceeded,
      _ => InteractionStatus.inProgress,
    };
  }

  /// Converts to a JSON string.
  String toJson() {
    return switch (this) {
      InteractionStatus.inProgress => 'in_progress',
      InteractionStatus.requiresAction => 'requires_action',
      InteractionStatus.completed => 'completed',
      InteractionStatus.failed => 'failed',
      InteractionStatus.cancelled => 'cancelled',
      InteractionStatus.incomplete => 'incomplete',
      InteractionStatus.budgetExceeded => 'budget_exceeded',
    };
  }
}

/// Converts a string to [InteractionStatus].
@Deprecated('Use InteractionStatus.fromString instead')
InteractionStatus interactionStatusFromString(String? value) {
  return InteractionStatus.fromString(value);
}

/// Converts [InteractionStatus] to a string.
@Deprecated('Use InteractionStatus.toJson instead')
String interactionStatusToString(InteractionStatus status) {
  return status.toJson();
}
