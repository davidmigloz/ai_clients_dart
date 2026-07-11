import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../items/item.dart';

/// A client-sent event that injects additional input into an active response.
///
/// This belongs to the beta multi-agent WebSocket protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). The OpenAPI spec defines no HTTP
/// path for this event — it is only ever sent over the WebSocket connection
/// used by that protocol. This package does not wire up any transport for it;
/// it is provided as a model for users implementing the WebSocket protocol
/// themselves.
@immutable
class ResponseInjectEvent {
  /// The type of the event. Always `response.inject`.
  String get type => 'response.inject';

  /// The ID of the active response that should receive the input.
  final String responseId;

  /// Input items to inject into the active response.
  ///
  /// Limited to a maximum of 16384 items.
  final List<Item> input;

  /// Creates a [ResponseInjectEvent].
  const ResponseInjectEvent({required this.responseId, required this.input});

  /// Creates a [ResponseInjectEvent] from JSON.
  factory ResponseInjectEvent.fromJson(Map<String, dynamic> json) {
    return ResponseInjectEvent(
      responseId: json['response_id'] as String,
      input: (json['input'] as List)
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'response_id': responseId,
    'input': input.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInjectEvent &&
          runtimeType == other.runtimeType &&
          responseId == other.responseId &&
          listsEqual(input, other.input);

  @override
  int get hashCode => Object.hash(responseId, listHash(input));

  /// Creates a copy with replaced values.
  ResponseInjectEvent copyWith({String? responseId, List<Item>? input}) {
    return ResponseInjectEvent(
      responseId: responseId ?? this.responseId,
      input: input ?? this.input,
    );
  }

  @override
  String toString() =>
      'ResponseInjectEvent(responseId: $responseId, input: $input)';
}

/// A server-sent event confirming that injected input was accepted.
///
/// This belongs to the beta multi-agent WebSocket protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). The OpenAPI spec defines no HTTP
/// path for this event — it is only ever received over the WebSocket
/// connection used by that protocol. This package does not wire up any
/// transport for it; it is provided as a model for users implementing the
/// WebSocket protocol themselves.
@immutable
class ResponseInjectCreatedEvent {
  /// The type of the event. Always `response.inject.created`.
  String get type => 'response.inject.created';

  /// The ID of the response that accepted the input.
  final String responseId;

  /// The sequence number of this event.
  final int sequenceNumber;

  /// The multiplexed WebSocket stream that emitted the event.
  ///
  /// This field is present only when WebSocket multiplexing is enabled
  /// separately.
  final String? streamId;

  /// Creates a [ResponseInjectCreatedEvent].
  const ResponseInjectCreatedEvent({
    required this.responseId,
    required this.sequenceNumber,
    this.streamId,
  });

  /// Creates a [ResponseInjectCreatedEvent] from JSON.
  factory ResponseInjectCreatedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseInjectCreatedEvent(
      responseId: json['response_id'] as String,
      sequenceNumber: json['sequence_number'] as int,
      streamId: json['stream_id'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'response_id': responseId,
    'sequence_number': sequenceNumber,
    if (streamId != null) 'stream_id': streamId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInjectCreatedEvent &&
          runtimeType == other.runtimeType &&
          responseId == other.responseId &&
          sequenceNumber == other.sequenceNumber &&
          streamId == other.streamId;

  @override
  int get hashCode => Object.hash(responseId, sequenceNumber, streamId);

  /// Creates a copy with replaced values.
  ResponseInjectCreatedEvent copyWith({
    String? responseId,
    int? sequenceNumber,
    Object? streamId = unsetCopyWithValue,
  }) {
    return ResponseInjectCreatedEvent(
      responseId: responseId ?? this.responseId,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      streamId: streamId == unsetCopyWithValue
          ? this.streamId
          : streamId as String?,
    );
  }

  @override
  String toString() =>
      'ResponseInjectCreatedEvent(responseId: $responseId, '
      'sequenceNumber: $sequenceNumber, streamId: $streamId)';
}

/// A server-sent event indicating injected input was rejected.
///
/// This belongs to the beta multi-agent WebSocket protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). The OpenAPI spec defines no HTTP
/// path for this event — it is only ever received over the WebSocket
/// connection used by that protocol. This package does not wire up any
/// transport for it; it is provided as a model for users implementing the
/// WebSocket protocol themselves.
@immutable
class ResponseInjectFailedEvent {
  /// The type of the event. Always `response.inject.failed`.
  String get type => 'response.inject.failed';

  /// The ID of the response that rejected the input.
  final String responseId;

  /// The raw input items that were not committed.
  final List<Item> input;

  /// The error describing why the input was rejected.
  final ResponseInjectError error;

  /// The sequence number of this event.
  final int sequenceNumber;

  /// The multiplexed WebSocket stream that emitted the event.
  ///
  /// This field is present only when WebSocket multiplexing is enabled
  /// separately.
  final String? streamId;

  /// Creates a [ResponseInjectFailedEvent].
  const ResponseInjectFailedEvent({
    required this.responseId,
    required this.input,
    required this.error,
    required this.sequenceNumber,
    this.streamId,
  });

  /// Creates a [ResponseInjectFailedEvent] from JSON.
  factory ResponseInjectFailedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseInjectFailedEvent(
      responseId: json['response_id'] as String,
      input: (json['input'] as List)
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
      error: ResponseInjectError.fromJson(
        json['error'] as Map<String, dynamic>,
      ),
      sequenceNumber: json['sequence_number'] as int,
      streamId: json['stream_id'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'response_id': responseId,
    'input': input.map((e) => e.toJson()).toList(),
    'error': error.toJson(),
    'sequence_number': sequenceNumber,
    if (streamId != null) 'stream_id': streamId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInjectFailedEvent &&
          runtimeType == other.runtimeType &&
          responseId == other.responseId &&
          listsEqual(input, other.input) &&
          error == other.error &&
          sequenceNumber == other.sequenceNumber &&
          streamId == other.streamId;

  @override
  int get hashCode =>
      Object.hash(responseId, listHash(input), error, sequenceNumber, streamId);

  /// Creates a copy with replaced values.
  ResponseInjectFailedEvent copyWith({
    String? responseId,
    List<Item>? input,
    ResponseInjectError? error,
    int? sequenceNumber,
    Object? streamId = unsetCopyWithValue,
  }) {
    return ResponseInjectFailedEvent(
      responseId: responseId ?? this.responseId,
      input: input ?? this.input,
      error: error ?? this.error,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      streamId: streamId == unsetCopyWithValue
          ? this.streamId
          : streamId as String?,
    );
  }

  @override
  String toString() =>
      'ResponseInjectFailedEvent(responseId: $responseId, input: $input, '
      'error: $error, sequenceNumber: $sequenceNumber, streamId: $streamId)';
}

/// The error describing why an injected input was rejected.
///
/// This belongs to the beta multi-agent WebSocket protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`).
@immutable
class ResponseInjectError {
  /// The error code.
  final ResponseInjectErrorCode code;

  /// A human-readable message describing the error.
  final String message;

  /// Creates a [ResponseInjectError].
  const ResponseInjectError({required this.code, required this.message});

  /// Creates a [ResponseInjectError] from JSON.
  factory ResponseInjectError.fromJson(Map<String, dynamic> json) {
    return ResponseInjectError(
      code: ResponseInjectErrorCode.fromJson(json['code'] as String),
      message: json['message'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'code': code.toJson(), 'message': message};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInjectError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message;

  @override
  int get hashCode => Object.hash(code, message);

  /// Creates a copy with replaced values.
  ResponseInjectError copyWith({
    ResponseInjectErrorCode? code,
    String? message,
  }) {
    return ResponseInjectError(
      code: code ?? this.code,
      message: message ?? this.message,
    );
  }

  @override
  String toString() => 'ResponseInjectError(code: $code, message: $message)';
}

/// The reason an injected input was rejected.
///
/// This belongs to the beta multi-agent WebSocket protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`).
enum ResponseInjectErrorCode {
  /// Unknown error code (fallback for unrecognized values).
  unknown('unknown'),

  /// The response had already completed when the input was received.
  responseAlreadyCompleted('response_already_completed'),

  /// No active response with the given ID was found.
  responseNotFound('response_not_found');

  /// The JSON value for this error code.
  final String value;

  const ResponseInjectErrorCode(this.value);

  /// Creates a [ResponseInjectErrorCode] from a JSON value.
  factory ResponseInjectErrorCode.fromJson(String json) {
    return ResponseInjectErrorCode.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ResponseInjectErrorCode.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
