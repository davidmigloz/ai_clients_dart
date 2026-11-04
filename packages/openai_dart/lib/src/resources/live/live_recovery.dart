import '../websocket_recovery.dart';

/// Explicit recovery for a Live socket, without restoring its server session.
///
/// A replacement primary/fork socket requires a new explicit startup and its
/// acknowledgment. Pending commands remain held until [WebSocketRecovery.flushPending]
/// is called after state reconciliation. The default zero-byte queue rejects
/// disconnected work; set a finite budget to retain newly unsent commands.
/// Callback maps replace previous reconnect overrides, layered above the
/// immutable initial per-call query/headers and freshly rebuilt defaults/auth.
/// An empty map clears reconnect overrides while preserving initial options.
class LiveReconnectOptions extends WebSocketReconnectOptions {
  /// Creates bounded opt-in recovery; omission on connect disables recovery.
  const LiveReconnectOptions({
    required super.onReconnecting,
    super.maxAttempts = 5,
    super.initialDelay = const Duration(milliseconds: 500),
    super.maxDelay = const Duration(seconds: 8),
    super.maxQueueBytes = 0,
    super.maxQueueMessages = 1024,
  });

  @override
  LiveReconnectOptions copyWith({
    WebSocketReconnectPreparation? onReconnecting,
    int? maxAttempts,
    Duration? initialDelay,
    Duration? maxDelay,
    int? maxQueueBytes,
    int? maxQueueMessages,
  }) => LiveReconnectOptions(
    onReconnecting: onReconnecting ?? this.onReconnecting,
    maxAttempts: maxAttempts ?? this.maxAttempts,
    initialDelay: initialDelay ?? this.initialDelay,
    maxDelay: maxDelay ?? this.maxDelay,
    maxQueueBytes: maxQueueBytes ?? this.maxQueueBytes,
    maxQueueMessages: maxQueueMessages ?? this.maxQueueMessages,
  );

  @override
  String toString() =>
      'LiveReconnectOptions(onReconnecting: [REDACTED], '
      'maxAttempts: $maxAttempts, initialDelay: $initialDelay, '
      'maxDelay: $maxDelay, maxQueueBytes: $maxQueueBytes, '
      'maxQueueMessages: $maxQueueMessages)';
}
