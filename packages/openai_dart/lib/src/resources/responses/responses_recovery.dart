import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

import '../../models/common/copy_with_sentinel.dart';
import '../../models/common/equality_helpers.dart';
import '../../models/responses/websocket/websocket_json_helpers.dart';

/// Prepares an explicitly enabled reconnect attempt before its delay and dial.
///
/// Return a continuation decision or abort. A thrown error ends recovery.
/// Credential refresh and application history reconciliation remain separate.
typedef ResponsesReconnectPreparation =
    FutureOr<ResponsesReconnectDecision> Function(
      ResponsesReconnectContext context,
    );

/// Explicit socket recovery configuration; omission disables reconnection.
///
/// A callback is required so the application can reconcile connection-local
/// state. Defaults follow the official SDK: five attempts, 500 ms exponential
/// delay capped at eight seconds, with jitter between 0.75 and 1.0. The outgoing
/// queue holds only newly unsent frames and strictly enforces its byte budget,
/// including its first frame. Submitted work is never automatically replayed.
@immutable
class ResponsesReconnectOptions {
  /// Required preparation callback. Equality compares its identity.
  final ResponsesReconnectPreparation onReconnecting;

  /// Maximum attempts per interruption; zero disables reconnect attempts.
  final int maxAttempts;

  /// Initial delay before applying jitter; zero removes the initial delay.
  /// Fractional milliseconds truncate before jitter is applied.
  final Duration initialDelay;

  /// Exponential delay cap; zero removes every retry delay.
  /// Fractional milliseconds truncate before jitter is applied.
  final Duration maxDelay;

  /// UTF-8 byte limit for newly unsent frames; zero disables queuing entirely.
  final int maxQueueBytes;

  /// Creates const configuration, validated at connection setup.
  const ResponsesReconnectOptions({
    required this.onReconnecting,
    this.maxAttempts = 5,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 8),
    this.maxQueueBytes = 1048576,
  });

  /// Rejects negative or nonfinite values in release builds as well as debug.
  /// A cap below the initial delay is valid and still caps the first attempt.
  void validate() {
    if (!maxAttempts.isFinite || maxAttempts < 0) {
      throw ArgumentError('maxAttempts must be a finite nonnegative integer.');
    }
    if (!initialDelay.inMicroseconds.isFinite || initialDelay < Duration.zero) {
      throw ArgumentError('initialDelay must be finite and nonnegative.');
    }
    if (!maxDelay.inMicroseconds.isFinite || maxDelay < Duration.zero) {
      throw ArgumentError('maxDelay must be finite and nonnegative.');
    }
    if (!maxQueueBytes.isFinite || maxQueueBytes < 0) {
      throw ArgumentError(
        'maxQueueBytes must be a finite nonnegative integer.',
      );
    }
  }

  /// Copies all configuration, preserving the required callback.
  ResponsesReconnectOptions copyWith({
    ResponsesReconnectPreparation? onReconnecting,
    int? maxAttempts,
    Duration? initialDelay,
    Duration? maxDelay,
    int? maxQueueBytes,
  }) => ResponsesReconnectOptions(
    onReconnecting: onReconnecting ?? this.onReconnecting,
    maxAttempts: maxAttempts ?? this.maxAttempts,
    initialDelay: initialDelay ?? this.initialDelay,
    maxDelay: maxDelay ?? this.maxDelay,
    maxQueueBytes: maxQueueBytes ?? this.maxQueueBytes,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesReconnectOptions &&
          runtimeType == other.runtimeType &&
          identical(onReconnecting, other.onReconnecting) &&
          maxAttempts == other.maxAttempts &&
          initialDelay == other.initialDelay &&
          maxDelay == other.maxDelay &&
          maxQueueBytes == other.maxQueueBytes;
  @override
  int get hashCode => Object.hash(
    identityHashCode(onReconnecting),
    maxAttempts,
    initialDelay,
    maxDelay,
    maxQueueBytes,
  );
  @override
  String toString() =>
      'ResponsesReconnectOptions(onReconnecting: [REDACTED], maxAttempts: $maxAttempts, initialDelay: $initialDelay, maxDelay: $maxDelay, maxQueueBytes: $maxQueueBytes)';
}

/// Noncredential context for one reconnect preparation callback.
///
/// The application retains its own current query/header and conversation state.
@immutable
class ResponsesReconnectContext {
  /// One-based attempt number.
  final int attempt;

  /// Configured total attempts for this interruption.
  final int maxAttempts;

  /// Jittered delay before this attempt connects.
  final Duration delay;

  /// Close code that triggered recovery; a transport failure uses 1006.
  final int closeCode;

  /// Original transport reason when known; it can contain sensitive information.
  final String? closeReason;

  /// Creates immutable scalar attempt metadata.
  const ResponsesReconnectContext({
    required this.attempt,
    required this.maxAttempts,
    required this.delay,
    required this.closeCode,
    this.closeReason,
  });

  /// Copies every field; explicit null clears the optional transport reason.
  ResponsesReconnectContext copyWith({
    int? attempt,
    int? maxAttempts,
    Duration? delay,
    int? closeCode,
    Object? closeReason = unsetCopyWithValue,
  }) => ResponsesReconnectContext(
    attempt: attempt ?? this.attempt,
    maxAttempts: maxAttempts ?? this.maxAttempts,
    delay: delay ?? this.delay,
    closeCode: closeCode ?? this.closeCode,
    closeReason: identical(closeReason, unsetCopyWithValue)
        ? this.closeReason
        : closeReason as String?,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesReconnectContext &&
          runtimeType == other.runtimeType &&
          attempt == other.attempt &&
          maxAttempts == other.maxAttempts &&
          delay == other.delay &&
          closeCode == other.closeCode &&
          closeReason == other.closeReason;
  @override
  int get hashCode =>
      Object.hash(attempt, maxAttempts, delay, closeCode, closeReason);
  @override
  String toString() =>
      'ResponsesReconnectContext(attempt: $attempt, maxAttempts: $maxAttempts, delay: $delay, closeCode: $closeCode, closeReason: ${responsesPresence(closeReason)})';
}

/// Explicit continuation or abort decision returned by a preparation callback.
///
/// Nonnull maps replace the previous reconnect overrides and persist between
/// attempts. Null reuses those overrides; an empty map clears them. Headers are
/// overrides applied to freshly rebuilt defaults/auth, with beta opt-in last.
/// This does not restore a lost response cache or accepted steering.
@immutable
class ResponsesReconnectDecision {
  /// Whether recovery ends before the next delay or handshake.
  final bool isAborted;

  /// Replacement query overrides, or null to reuse the previous overrides.
  final Map<String, String>? queryParameters;

  /// Replacement header overrides, or null to reuse the previous overrides.
  final Map<String, String>? headers;

  /// Continues, retaining const caller-owned maps until [snapshot] captures them.
  const ResponsesReconnectDecision.continueWith({
    this.queryParameters,
    this.headers,
  }) : isAborted = false;

  /// Ends recovery without another dial. Never-attempted frames are reported.
  const ResponsesReconnectDecision.abort()
    : isAborted = true,
      queryParameters = null,
      headers = null;

  const ResponsesReconnectDecision._({
    required this.isAborted,
    required this.queryParameters,
    required this.headers,
  });

  /// Captures replacement maps immediately after the callback, before any await.
  ResponsesReconnectDecision snapshot() => ResponsesReconnectDecision._(
    isAborted: isAborted,
    queryParameters: queryParameters == null
        ? null
        : Map<String, String>.unmodifiable(queryParameters!),
    headers: headers == null
        ? null
        : Map<String, String>.unmodifiable(headers!),
  );

  /// Copies every field; explicit null removes an override map from this decision.
  /// On an aborted decision, overrides remain inspectable but are not applied.
  ResponsesReconnectDecision copyWith({
    bool? isAborted,
    Object? queryParameters = unsetCopyWithValue,
    Object? headers = unsetCopyWithValue,
  }) => ResponsesReconnectDecision._(
    isAborted: isAborted ?? this.isAborted,
    queryParameters: identical(queryParameters, unsetCopyWithValue)
        ? this.queryParameters
        : queryParameters as Map<String, String>?,
    headers: identical(headers, unsetCopyWithValue)
        ? this.headers
        : headers as Map<String, String>?,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesReconnectDecision &&
          runtimeType == other.runtimeType &&
          isAborted == other.isAborted &&
          mapsEqual(queryParameters, other.queryParameters) &&
          mapsEqual(headers, other.headers);
  @override
  int get hashCode =>
      Object.hash(isAborted, mapHash(queryParameters), mapHash(headers));
  @override
  String toString() =>
      'ResponsesReconnectDecision(isAborted: $isAborted, queryParameters: ${queryParameters == null ? 'null' : '${queryParameters!.length} entries'}, headers: ${headers == null ? 'null' : '${headers!.length} entries'})';
}

/// Exact serialized text of a frame whose socket write was never attempted.
///
/// Already-submitted frames and failed attempted writes are excluded. Inspect
/// [text] deliberately: it can contain credentials or user input. Its exact UTF-8
/// size is derived from the captured text and cannot diverge through mutation.
@immutable
class ResponsesUnsentMessage {
  /// Captured immutable wire text, without reserializing it during recovery.
  final String text;

  /// Exact UTF-8 byte length used for queue accounting.
  final int byteLength;

  const ResponsesUnsentMessage._(this.text, this.byteLength);

  /// Captures wire text and computes its UTF-8 size.
  factory ResponsesUnsentMessage.fromText(String text) =>
      ResponsesUnsentMessage._(text, utf8.encode(text).length);

  /// Decodes a JSON-object message into a recursively immutable snapshot.
  ///
  /// Raw text remains available even when it is not JSON. Such text throws a
  /// payload-redacted [FormatException] here rather than being coerced.
  Map<String, dynamic> get message {
    try {
      final value = jsonDecode(text);
      if (value is Map<String, dynamic>) {
        return snapshotResponsesJson(value, 'ResponsesUnsentMessage.message');
      }
    } catch (_) {
      // Decoder diagnostics can include raw input. Keep only a safe context.
    }
    throw const FormatException(
      'ResponsesUnsentMessage.message: expected a finite JSON object',
    );
  }

  /// Replaces text and recalculates its byte length atomically.
  ResponsesUnsentMessage copyWith({String? text}) =>
      ResponsesUnsentMessage.fromText(text ?? this.text);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesUnsentMessage &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          byteLength == other.byteLength;
  @override
  int get hashCode => Object.hash(text, byteLength);
  @override
  String toString() =>
      'ResponsesUnsentMessage(text: [REDACTED], byteLength: $byteLength)';
}

/// SDK recovery lifecycle, separate from server response events.
///
/// Variants are [ResponsesRecoveryReconnecting], [ResponsesRecoveryReconnected],
/// [ResponsesRecoveryClosed], [ResponsesRecoveryQueueOverflow], and
/// [ResponsesRecoveryDeliveryUnknown], plus [ResponsesRecoveryTransportError].
/// These records are not API wire schemas.
@immutable
sealed class ResponsesRecoveryEvent {
  /// Creates a lifecycle record.
  const ResponsesRecoveryEvent();

  /// Reports a scheduled attempt after preparation.
  const factory ResponsesRecoveryEvent.reconnecting(
    ResponsesReconnectContext context,
  ) = ResponsesRecoveryReconnecting;

  /// Reports that a replacement socket is open.
  const factory ResponsesRecoveryEvent.reconnected(int attempt) =
      ResponsesRecoveryReconnected;

  /// Reports terminal closure and only never-attempted frames.
  factory ResponsesRecoveryEvent.closed({
    int? code,
    String? reason,
    required String cause,
    List<ResponsesUnsentMessage> unsentMessages,
  }) = ResponsesRecoveryClosed;

  /// Reports a rejected frame while leaving recovery active.
  const factory ResponsesRecoveryEvent.queueOverflow({
    required int frameBytes,
    required int maxQueueBytes,
    required int queuedBytes,
  }) = ResponsesRecoveryQueueOverflow;

  /// Reports an attempted write whose delivery cannot be determined.
  const factory ResponsesRecoveryEvent.deliveryUnknown({
    required int frameBytes,
    required String operation,
  }) = ResponsesRecoveryDeliveryUnknown;

  /// Reports a redacted physical transport error, separate from close policy.
  const factory ResponsesRecoveryEvent.transportError({
    required String operation,
  }) = ResponsesRecoveryTransportError;
}

/// A physical transport error; the actual close code still controls recovery.
@immutable
class ResponsesRecoveryTransportError extends ResponsesRecoveryEvent {
  /// Failed operation, such as receive, handshake, close or cancel.
  final String operation;

  /// Creates an error record without retaining an exception or credentials.
  const ResponsesRecoveryTransportError({required this.operation});

  /// Copies the failed operation.
  ResponsesRecoveryTransportError copyWith({String? operation}) =>
      ResponsesRecoveryTransportError(operation: operation ?? this.operation);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesRecoveryTransportError &&
          runtimeType == other.runtimeType &&
          operation == other.operation;
  @override
  int get hashCode => operation.hashCode;
  @override
  String toString() => 'ResponsesRecoveryTransportError(operation: [REDACTED])';
}

/// Scheduled reconnect metadata; no response work has been replayed.
@immutable
class ResponsesRecoveryReconnecting extends ResponsesRecoveryEvent {
  /// Prepared attempt metadata, excluding credentials and conversation input.
  final ResponsesReconnectContext context;

  /// Creates an immutable record without retaining a payload or error cause.
  const ResponsesRecoveryReconnecting(this.context);

  /// Copies every field.
  ResponsesRecoveryReconnecting copyWith({
    ResponsesReconnectContext? context,
  }) => ResponsesRecoveryReconnecting(context ?? this.context);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesRecoveryReconnecting &&
          runtimeType == other.runtimeType &&
          context == other.context;
  @override
  int get hashCode => Object.hashAll([context]);
  @override
  String toString() => 'ResponsesRecoveryReconnecting(context: $context)';
}

/// A replacement socket opened; conversation state is not restored.
@immutable
class ResponsesRecoveryReconnected extends ResponsesRecoveryEvent {
  /// One-based attempt that opened the replacement socket.
  final int attempt;

  /// Creates an immutable record without retaining a payload or error cause.
  const ResponsesRecoveryReconnected(this.attempt);

  /// Copies every field.
  ResponsesRecoveryReconnected copyWith({int? attempt}) =>
      ResponsesRecoveryReconnected(attempt ?? this.attempt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesRecoveryReconnected &&
          runtimeType == other.runtimeType &&
          attempt == other.attempt;
  @override
  int get hashCode => Object.hashAll([attempt]);
  @override
  String toString() => 'ResponsesRecoveryReconnected(attempt: $attempt)';
}

/// A newly unsent frame exceeded the strict queue budget and was rejected.
@immutable
class ResponsesRecoveryQueueOverflow extends ResponsesRecoveryEvent {
  /// Exact UTF-8 byte length of the rejected or attempted frame.
  final int frameBytes;

  /// Configured strict byte budget for outgoing never-attempted frames.
  final int maxQueueBytes;

  /// Existing queued byte count when the new frame was rejected.
  final int queuedBytes;

  /// Creates an immutable record without retaining a payload or error cause.
  const ResponsesRecoveryQueueOverflow({
    required this.frameBytes,
    required this.maxQueueBytes,
    required this.queuedBytes,
  });

  /// Copies every field.
  ResponsesRecoveryQueueOverflow copyWith({
    int? frameBytes,
    int? maxQueueBytes,
    int? queuedBytes,
  }) => ResponsesRecoveryQueueOverflow(
    frameBytes: frameBytes ?? this.frameBytes,
    maxQueueBytes: maxQueueBytes ?? this.maxQueueBytes,
    queuedBytes: queuedBytes ?? this.queuedBytes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesRecoveryQueueOverflow &&
          runtimeType == other.runtimeType &&
          frameBytes == other.frameBytes &&
          maxQueueBytes == other.maxQueueBytes &&
          queuedBytes == other.queuedBytes;
  @override
  int get hashCode => Object.hashAll([frameBytes, maxQueueBytes, queuedBytes]);
  @override
  String toString() =>
      'ResponsesRecoveryQueueOverflow(frameBytes: $frameBytes, maxQueueBytes: $maxQueueBytes, queuedBytes: $queuedBytes)';
}

/// A socket write was attempted and failed; delivery is unknown.
@immutable
class ResponsesRecoveryDeliveryUnknown extends ResponsesRecoveryEvent {
  /// Exact UTF-8 byte length of the rejected or attempted frame.
  final int frameBytes;

  /// Failed write operation, such as send or flush.
  final String operation;

  /// Creates an immutable record without retaining a payload or error cause.
  const ResponsesRecoveryDeliveryUnknown({
    required this.frameBytes,
    required this.operation,
  });

  /// Copies every field.
  ResponsesRecoveryDeliveryUnknown copyWith({
    int? frameBytes,
    String? operation,
  }) => ResponsesRecoveryDeliveryUnknown(
    frameBytes: frameBytes ?? this.frameBytes,
    operation: operation ?? this.operation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesRecoveryDeliveryUnknown &&
          runtimeType == other.runtimeType &&
          frameBytes == other.frameBytes &&
          operation == other.operation;
  @override
  int get hashCode => Object.hashAll([frameBytes, operation]);
  @override
  String toString() =>
      'ResponsesRecoveryDeliveryUnknown(frameBytes: $frameBytes, operation: [REDACTED])';
}

/// Observable nonfatal queue rejection, including an oversized first frame.
@immutable
class ResponsesSendQueueOverflowException implements Exception {
  /// Exact UTF-8 byte length of the rejected or attempted frame.
  final int frameBytes;

  /// Configured strict byte budget for outgoing never-attempted frames.
  final int maxQueueBytes;

  /// Existing queued byte count when the new frame was rejected.
  final int queuedBytes;

  /// Creates an immutable record without retaining a payload or error cause.
  const ResponsesSendQueueOverflowException({
    required this.frameBytes,
    required this.maxQueueBytes,
    required this.queuedBytes,
  });

  /// Copies every field.
  ResponsesSendQueueOverflowException copyWith({
    int? frameBytes,
    int? maxQueueBytes,
    int? queuedBytes,
  }) => ResponsesSendQueueOverflowException(
    frameBytes: frameBytes ?? this.frameBytes,
    maxQueueBytes: maxQueueBytes ?? this.maxQueueBytes,
    queuedBytes: queuedBytes ?? this.queuedBytes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSendQueueOverflowException &&
          runtimeType == other.runtimeType &&
          frameBytes == other.frameBytes &&
          maxQueueBytes == other.maxQueueBytes &&
          queuedBytes == other.queuedBytes;
  @override
  int get hashCode => Object.hashAll([frameBytes, maxQueueBytes, queuedBytes]);
  @override
  String toString() =>
      'ResponsesSendQueueOverflowException(frameBytes: $frameBytes, maxQueueBytes: $maxQueueBytes, queuedBytes: $queuedBytes)';
}

/// Terminal attempted-write failure; the frame must never be requeued.
@immutable
class ResponsesDeliveryUnknownException implements Exception {
  /// Exact UTF-8 byte length of the rejected or attempted frame.
  final int frameBytes;

  /// Failed write operation, such as send or flush.
  final String operation;

  /// Creates an immutable record without retaining a payload or error cause.
  const ResponsesDeliveryUnknownException({
    required this.frameBytes,
    required this.operation,
  });

  /// Copies every field.
  ResponsesDeliveryUnknownException copyWith({
    int? frameBytes,
    String? operation,
  }) => ResponsesDeliveryUnknownException(
    frameBytes: frameBytes ?? this.frameBytes,
    operation: operation ?? this.operation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesDeliveryUnknownException &&
          runtimeType == other.runtimeType &&
          frameBytes == other.frameBytes &&
          operation == other.operation;
  @override
  int get hashCode => Object.hashAll([frameBytes, operation]);
  @override
  String toString() =>
      'ResponsesDeliveryUnknownException(frameBytes: $frameBytes, operation: [REDACTED])';
}

/// Terminal socket outcome and the immutable never-attempted remainder.
@immutable
class ResponsesRecoveryClosed extends ResponsesRecoveryEvent {
  /// Final logical close code, when known. This can be an observed physical
  /// code or the caller-requested/default code on explicit close.
  final int? code;

  /// Final logical reason, when known, including a caller-requested close reason.
  /// Diagnostics redact this potentially sensitive value.
  final String? reason;

  /// SDK terminal classification, not an API error-code enum.
  final String cause;

  /// FIFO frames whose writes were never attempted.
  final List<ResponsesUnsentMessage> unsentMessages;

  /// Snapshots the remainder so caller mutation cannot change the close report.
  ResponsesRecoveryClosed({
    this.code,
    this.reason,
    required this.cause,
    List<ResponsesUnsentMessage> unsentMessages = const [],
  }) : unsentMessages = List<ResponsesUnsentMessage>.unmodifiable(
         unsentMessages,
       );

  /// Copies all fields; explicit null clears the optional code and reason.
  ResponsesRecoveryClosed copyWith({
    Object? code = unsetCopyWithValue,
    Object? reason = unsetCopyWithValue,
    String? cause,
    List<ResponsesUnsentMessage>? unsentMessages,
  }) => ResponsesRecoveryClosed(
    code: identical(code, unsetCopyWithValue) ? this.code : code as int?,
    reason: identical(reason, unsetCopyWithValue)
        ? this.reason
        : reason as String?,
    cause: cause ?? this.cause,
    unsentMessages: unsentMessages ?? this.unsentMessages,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesRecoveryClosed &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          reason == other.reason &&
          cause == other.cause &&
          listsEqual(unsentMessages, other.unsentMessages);
  @override
  int get hashCode =>
      Object.hash(code, reason, cause, listHash(unsentMessages));
  @override
  String toString() =>
      'ResponsesRecoveryClosed(code: $code, reason: ${responsesPresence(reason)}, cause: [REDACTED], unsentMessages: ${unsentMessages.length} items)';
}
