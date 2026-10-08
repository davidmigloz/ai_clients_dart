part of 'responses_server_event.dart';

/// Accepted, atomically committed input for an active beta response.
///
/// It remains a normal socket message even after a response completion; reading
/// continues until the application's outstanding acknowledgements are resolved.
@immutable
class ResponseInjectCreatedEvent extends ResponsesServerEvent {
  /// Response which accepted the input.
  final String responseId;

  /// Required event sequence number.
  final int sequenceNumber;
  @override
  final String? streamId;
  @override
  final Map<String, dynamic> rawJson;

  /// Creates a const acknowledgement with caller-owned raw metadata.
  const ResponseInjectCreatedEvent({
    required this.responseId,
    required this.sequenceNumber,
    this.streamId,
    this.rawJson = const {},
  });
  @override
  String get type => 'response.inject.created';

  /// Validates exact required fields and captures future metadata immutably.
  factory ResponseInjectCreatedEvent.fromJson(Map<String, dynamic> json) {
    const context = 'ResponseInjectCreatedEvent';
    requireJsonType(json, 'response.inject.created', context);
    final snapshot = snapshotResponsesJson(json, context);
    return ResponseInjectCreatedEvent(
      responseId: requireJsonString(
        snapshot['response_id'],
        '$context.response_id',
      ),
      sequenceNumber: requireJsonInt(
        snapshot['sequence_number'],
        '$context.sequence_number',
      ),
      streamId: optionalJsonString(snapshot, 'stream_id', context),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    final json = _valueJson();
    snapshotResponsesJson(json, 'ResponseInjectCreatedEvent');
    return json;
  }

  Map<String, dynamic> _valueJson() => mergeResponsesJson(
    rawJson,
    const {'type', 'response_id', 'sequence_number', 'stream_id'},
    {
      'type': type,
      'response_id': responseId,
      'sequence_number': sequenceNumber,
      if (streamId != null) 'stream_id': streamId,
    },
  );

  /// Copies every field; explicit null clears the optional lane.
  ResponseInjectCreatedEvent copyWith({
    String? responseId,
    int? sequenceNumber,
    Object? streamId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => ResponseInjectCreatedEvent(
    responseId: responseId ?? this.responseId,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    streamId: identical(streamId, unsetCopyWithValue)
        ? this.streamId
        : streamId as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInjectCreatedEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));
  @override
  String toString() =>
      'ResponseInjectCreatedEvent(responseId: [REDACTED], sequenceNumber: $sequenceNumber, streamId: ${responsesPresence(streamId)}, rawJson: ${rawJson.length} entries)';
}

/// Uncommitted injection input returned by the beta WebSocket service.
///
/// [input] is a required raw array so malformed and future values survive. It is
/// not coerced through the writable Item codec. Parsed nested JSON is immutable;
/// old `List<Item>` constructions still serialize by converting top-level items.
@immutable
class ResponseInjectFailedEvent extends ResponsesServerEvent {
  /// Target response which rejected the input.
  final String responseId;

  /// Original uncommitted raw array. May contain malformed items or scalars.
  ///
  /// This getter is widened from `List<Item>`; inspect raw values before replay.
  final List<Object?> input;

  /// Required failure metadata.
  final ResponseInjectError error;

  /// Required event sequence number.
  final int sequenceNumber;
  @override
  final String? streamId;
  @override
  final Map<String, dynamic> rawJson;

  /// Creates a const failure with caller-owned collections. Top-level Item
  /// values remain accepted for existing constructor callers.
  const ResponseInjectFailedEvent({
    required this.responseId,
    required this.input,
    required this.error,
    required this.sequenceNumber,
    this.streamId,
    this.rawJson = const {},
  });
  @override
  String get type => 'response.inject.failed';

  /// Requires an array and captures its exact finite JSON without item coercion.
  factory ResponseInjectFailedEvent.fromJson(Map<String, dynamic> json) {
    const context = 'ResponseInjectFailedEvent';
    requireJsonType(json, 'response.inject.failed', context);
    final snapshot = snapshotResponsesJson(json, context);
    final values = snapshot['input'];
    if (values is! List<dynamic>) {
      throw const FormatException(
        'ResponseInjectFailedEvent.input: expected an array',
      );
    }
    return ResponseInjectFailedEvent(
      responseId: requireJsonString(
        snapshot['response_id'],
        '$context.response_id',
      ),
      input: List<Object?>.unmodifiable(values),
      error: ResponseInjectError.fromJson(
        requireJsonObject(snapshot['error'], '$context.error'),
      ),
      sequenceNumber: requireJsonInt(
        snapshot['sequence_number'],
        '$context.sequence_number',
      ),
      streamId: optionalJsonString(snapshot, 'stream_id', context),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    error.toJson();
    final json = _valueJson();
    snapshotResponsesJson(json, 'ResponseInjectFailedEvent');
    return json;
  }

  Map<String, dynamic> _valueJson() => mergeResponsesJson(
    rawJson,
    const {
      'type',
      'response_id',
      'input',
      'error',
      'sequence_number',
      'stream_id',
    },
    {
      'type': type,
      'response_id': responseId,
      'input': input
          .map((value) => value is Item ? value.toJson() : value)
          .toList(),
      'error': _errorValueJson(),
      'sequence_number': sequenceNumber,
      if (streamId != null) 'stream_id': streamId,
    },
  );

  Map<String, dynamic> _errorValueJson() => mergeResponsesJson(
    rawJson['error'] is Map<String, dynamic>
        ? rawJson['error'] as Map<String, dynamic>
        : const {},
    const {'code', 'message'},
    error._valueJson(),
  );

  /// Copies every field; explicit null clears only the optional lane.
  /// Replacing [error] reconciles its metadata, including explicit nested clears.
  ResponseInjectFailedEvent copyWith({
    String? responseId,
    List<Object?>? input,
    ResponseInjectError? error,
    int? sequenceNumber,
    Object? streamId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    final retainedRaw = rawJson ?? this.rawJson;
    final reconciledRaw = error == null || rawJson != null
        ? retainedRaw
        : replaceResponsesTypedJson(
            retainedRaw,
            {'error': _errorValueJson()},
            {'error': error._valueJson()},
          );
    return ResponseInjectFailedEvent(
      responseId: responseId ?? this.responseId,
      input: input ?? this.input,
      error: error ?? this.error,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      streamId: identical(streamId, unsetCopyWithValue)
          ? this.streamId
          : streamId as String?,
      rawJson: error != null && rawJson == null
          ? freezeJsonObject(reconciledRaw)
          : reconciledRaw,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInjectFailedEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));
  @override
  String toString() =>
      'ResponseInjectFailedEvent(responseId: [REDACTED], input: ${input.length} items, error: present, sequenceNumber: $sequenceNumber, streamId: ${responsesPresence(streamId)}, rawJson: ${rawJson.length} entries)';
}

/// Required injection failure code/message plus retained future metadata.
///
/// The canonical code enum contains two known values. An unrecognized wire code
/// maps to the existing unknown enum and is retained in [rawCode] as explicit
/// forward compatibility. When supplied, rawCode overrides the enum on the wire
/// and must resolve to the same enum; conflicting const states reject on toJson.
@immutable
class ResponseInjectError {
  /// Existing two-value enum and unknown compatibility fallback.
  final ResponseInjectErrorCode code;

  /// Required human-readable message, potentially containing sensitive input.
  final String message;

  /// Original unrecognized provider string, or a redundant matching known code.
  final String? rawCode;

  /// Original deeply immutable JSON after parsing, including future keys.
  final Map<String, dynamic> rawJson;

  /// Preserves existing const construction; raw metadata is caller-owned.
  const ResponseInjectError({
    required this.code,
    required this.message,
    this.rawCode,
    this.rawJson = const {},
  });

  /// Parses exact required types while preserving unknown strings and metadata.
  factory ResponseInjectError.fromJson(Map<String, dynamic> json) {
    const context = 'ResponseInjectError';
    final snapshot = snapshotResponsesJson(json, context);
    final value = requireJsonString(snapshot['code'], '$context.code');
    final code = ResponseInjectErrorCode.fromJson(value);
    return ResponseInjectError(
      code: code,
      message: requireJsonString(snapshot['message'], '$context.message'),
      rawCode: code == ResponseInjectErrorCode.unknown ? value : null,
      rawJson: snapshot,
    );
  }

  /// Serializes retained metadata and the consistent effective wire code.
  Map<String, dynamic> toJson() {
    if (rawCode != null && ResponseInjectErrorCode.fromJson(rawCode!) != code) {
      throw const FormatException(
        'ResponseInjectError.rawCode: conflicts with code',
      );
    }
    final json = _valueJson();
    snapshotResponsesJson(json, 'ResponseInjectError');
    return json;
  }

  Map<String, dynamic> _valueJson() => mergeResponsesJson(
    rawJson,
    const {'code', 'message'},
    {'code': rawCode ?? code.toJson(), 'message': message},
  );

  /// Copies every field. Selecting an enum code clears an old wire override
  /// unless rawCode is explicitly supplied; explicit null clears the override.
  ResponseInjectError copyWith({
    ResponseInjectErrorCode? code,
    String? message,
    Object? rawCode = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => ResponseInjectError(
    code: code ?? this.code,
    message: message ?? this.message,
    rawCode: identical(rawCode, unsetCopyWithValue)
        ? (code == null ? this.rawCode : null)
        : rawCode as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInjectError &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));
  @override
  String toString() =>
      'ResponseInjectError(code: $code, message: [REDACTED], rawCode: ${responsesPresence(rawCode)}, rawJson: ${rawJson.length} entries)';
}
