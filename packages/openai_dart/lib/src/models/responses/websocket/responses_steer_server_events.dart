part of 'responses_server_event.dart';

/// Identity shared by accepted and pending steering acknowledgements.
@immutable
class ResponsesSteerIdentity {
  /// Server-assigned steering submission identity.
  final String id;

  /// The targeted response.
  final String previousResponseId;

  /// Immutable original nested object after parsing, including future fields.
  final Map<String, dynamic> rawJson;

  /// Creates an identity, preserving const caller-owned JSON.
  const ResponsesSteerIdentity({
    required this.id,
    required this.previousResponseId,
    this.rawJson = const {},
  });

  /// Parses both required string identities.
  factory ResponsesSteerIdentity.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotResponsesJson(json, 'ResponsesSteerIdentity');
    return ResponsesSteerIdentity(
      id: requireJsonString(snapshot['id'], 'ResponsesSteerIdentity.id'),
      previousResponseId: requireJsonString(
        snapshot['previous_response_id'],
        'ResponsesSteerIdentity.previous_response_id',
      ),
      rawJson: snapshot,
    );
  }

  /// Serializes typed identities with retained future nested metadata.
  Map<String, dynamic> toJson() => mergeResponsesJson(
    rawJson,
    const {'id', 'previous_response_id'},
    {'id': id, 'previous_response_id': previousResponseId},
  );

  /// Copies both identities and raw metadata.
  ResponsesSteerIdentity copyWith({
    String? id,
    String? previousResponseId,
    Map<String, dynamic>? rawJson,
  }) => ResponsesSteerIdentity(
    id: id ?? this.id,
    previousResponseId: previousResponseId ?? this.previousResponseId,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerIdentity &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));
  @override
  String toString() =>
      'ResponsesSteerIdentity(id: [REDACTED], previousResponseId: [REDACTED], rawJson: ${rawJson.length} entries)';
}

/// Original rejected or uncommitted input; its invalid shape must survive.
@immutable
class ResponsesFailedSteer {
  /// The targeted response.
  final String previousResponseId;

  /// Original raw JSON input, including invalid objects, scalars or null.
  ///
  /// This intentionally does not use the narrower outbound [ResponsesSteerInput].
  /// It is a compatibility choice for reporting rejected input, not a claim that
  /// these shapes are accepted for steering.
  final Object? input;

  /// Steering ID if the server allocated one; absent before allocation.
  final String? id;

  /// Original deeply immutable nested JSON after parsing.
  final Map<String, dynamic> rawJson;

  /// Creates rejected input, preserving const caller-owned JSON construction.
  const ResponsesFailedSteer({
    required this.previousResponseId,
    required this.input,
    this.id,
    this.rawJson = const {},
  });

  /// Parses required presence while preserving arbitrary valid JSON input.
  factory ResponsesFailedSteer.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotResponsesJson(json, 'ResponsesFailedSteer');
    if (!snapshot.containsKey('input')) {
      throw const FormatException(
        'ResponsesFailedSteer.input: required original input is missing',
      );
    }
    return ResponsesFailedSteer(
      previousResponseId: requireJsonString(
        snapshot['previous_response_id'],
        'ResponsesFailedSteer.previous_response_id',
      ),
      input: snapshot['input'],
      id: optionalJsonString(snapshot, 'id', 'ResponsesFailedSteer'),
      rawJson: snapshot,
    );
  }

  /// Converts to JSON, always retaining input even when explicitly null.
  Map<String, dynamic> toJson() {
    snapshotResponsesJson({'input': input}, 'ResponsesFailedSteer.input');
    return _valueJson();
  }

  Map<String, dynamic> _valueJson() => mergeResponsesJson(
    rawJson,
    const {'id', 'previous_response_id', 'input'},
    {
      'previous_response_id': previousResponseId,
      'input': input,
      if (id != null) 'id': id,
    },
  );

  /// Copies all fields; explicit null clears the optional ID and replaces raw
  /// input with null while retaining its required key.
  ResponsesFailedSteer copyWith({
    String? previousResponseId,
    Object? input = unsetCopyWithValue,
    Object? id = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => ResponsesFailedSteer(
    previousResponseId: previousResponseId ?? this.previousResponseId,
    input: identical(input, unsetCopyWithValue) ? this.input : input,
    id: identical(id, unsetCopyWithValue) ? this.id : id as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesFailedSteer &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));
  @override
  String toString() =>
      'ResponsesFailedSteer(previousResponseId: [REDACTED], input: ${input == null ? 'null' : '[REDACTED]'}, id: ${responsesPresence(id)}, rawJson: ${rawJson.length} entries)';
}

/// Failure metadata for a steering submission, with an open provider code.
@immutable
class ResponsesSteerError {
  /// Machine-readable error code; unknown strings remain intact.
  final String code;

  /// Human-readable error text, which may contain sensitive user input.
  final String message;

  /// Immutable original JSON after parsing, including future fields.
  final Map<String, dynamic> rawJson;

  /// Creates failure details.
  const ResponsesSteerError({
    required this.code,
    required this.message,
    this.rawJson = const {},
  });

  /// The fixed error type.
  String get type => 'invalid_request_error';

  /// Parses fixed type plus required nonnullable strings.
  factory ResponsesSteerError.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'invalid_request_error', 'ResponsesSteerError');
    final snapshot = snapshotResponsesJson(json, 'ResponsesSteerError');
    return ResponsesSteerError(
      code: requireJsonString(snapshot['code'], 'ResponsesSteerError.code'),
      message: requireJsonString(
        snapshot['message'],
        'ResponsesSteerError.message',
      ),
      rawJson: snapshot,
    );
  }

  /// Converts to JSON, retaining future error metadata.
  Map<String, dynamic> toJson() => mergeResponsesJson(
    rawJson,
    const {'type', 'code', 'message'},
    {'type': type, 'code': code, 'message': message},
  );

  /// Copies every field while retaining the fixed error type.
  ResponsesSteerError copyWith({
    String? code,
    String? message,
    Map<String, dynamic>? rawJson,
  }) => ResponsesSteerError(
    code: code ?? this.code,
    message: message ?? this.message,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerError &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));
  @override
  String toString() =>
      'ResponsesSteerError(code: [REDACTED], message: [REDACTED], rawJson: ${rawJson.length} entries)';
}

/// A `response.steer.accepted` acknowledgement. It does not close the connection.
@immutable
class ResponsesSteerAcceptedEvent extends ResponsesServerEvent {
  /// Required ordering sequence.
  final int sequenceNumber;

  /// Required `steer` acknowledgement data.
  final ResponsesSteerIdentity steer;
  @override
  final String? streamId;
  @override
  final Map<String, dynamic> rawJson;

  /// Creates an acknowledgement with const caller-owned collections.
  const ResponsesSteerAcceptedEvent({
    required this.sequenceNumber,
    required this.steer,
    this.streamId,
    this.rawJson = const {},
  });
  @override
  String get type => 'response.steer.accepted';

  /// Parses required members, optional lane and future raw metadata.
  factory ResponsesSteerAcceptedEvent.fromJson(Map<String, dynamic> json) {
    const context = 'ResponsesSteerAcceptedEvent';
    requireJsonType(json, 'response.steer.accepted', context);
    final snapshot = snapshotResponsesJson(json, context);
    return ResponsesSteerAcceptedEvent(
      sequenceNumber: requireJsonInt(
        snapshot['sequence_number'],
        '$context.sequence_number',
      ),
      steer: ResponsesSteerIdentity.fromJson(
        requireJsonObject(snapshot['steer'], '$context.steer'),
      ),
      streamId: optionalJsonString(snapshot, 'stream_id', context),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return _valueJson();
  }

  Map<String, dynamic> _valueJson() => mergeResponsesJson(
    rawJson,
    const {'type', 'sequence_number', 'stream_id', 'steer'},
    {
      'type': type,
      'sequence_number': sequenceNumber,
      if (streamId != null) 'stream_id': streamId,
      'steer': _mergeSteerNestedJson(rawJson['steer'], steer.toJson(), const {
        'id',
        'previous_response_id',
      }),
    },
  );

  /// Copies all members; explicit null clears only the optional lane.
  /// Replacing [steer] reconciles its metadata, including explicit nested clears.
  ResponsesSteerAcceptedEvent copyWith({
    int? sequenceNumber,
    ResponsesSteerIdentity? steer,
    Object? streamId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    final retainedRaw = rawJson ?? this.rawJson;
    final reconciledRaw = steer == null || rawJson != null
        ? retainedRaw
        : replaceResponsesTypedJson(
            retainedRaw,
            {'steer': _valueJson()['steer']},
            {'steer': steer.toJson()},
          );
    return ResponsesSteerAcceptedEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      steer: steer ?? this.steer,
      streamId: identical(streamId, unsetCopyWithValue)
          ? this.streamId
          : streamId as String?,
      rawJson: steer != null && rawJson == null
          ? freezeJsonObject(reconciledRaw)
          : reconciledRaw,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerAcceptedEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));
  @override
  String toString() =>
      'ResponsesSteerAcceptedEvent(sequenceNumber: $sequenceNumber, steer: present, streamId: ${responsesPresence(streamId)}, rawJson: ${rawJson.length} entries)';
}

/// A `response.steer.pending` acknowledgement. It does not close the connection.
@immutable
class ResponsesSteerPendingEvent extends ResponsesServerEvent {
  /// Required ordering sequence.
  final int sequenceNumber;

  /// Required `steer` acknowledgement data.
  final ResponsesSteerIdentity steer;

  /// Required `reason` acknowledgement data.
  final String reason;

  /// Required `required_input` acknowledgement data.
  final List<ResponsesSteerRequiredInput> requiredInput;
  @override
  final String? streamId;
  @override
  final Map<String, dynamic> rawJson;

  /// Creates an acknowledgement with const caller-owned collections.
  const ResponsesSteerPendingEvent({
    required this.sequenceNumber,
    required this.steer,
    required this.reason,
    required this.requiredInput,
    this.streamId,
    this.rawJson = const {},
  });
  @override
  String get type => 'response.steer.pending';

  /// Parses required members, optional lane and future raw metadata.
  factory ResponsesSteerPendingEvent.fromJson(Map<String, dynamic> json) {
    const context = 'ResponsesSteerPendingEvent';
    requireJsonType(json, 'response.steer.pending', context);
    final snapshot = snapshotResponsesJson(json, context);
    final requiredInput = _parseSteerRequiredInput(
      snapshot['required_input'],
      '$context.required_input',
    );
    return ResponsesSteerPendingEvent(
      sequenceNumber: requireJsonInt(
        snapshot['sequence_number'],
        '$context.sequence_number',
      ),
      steer: ResponsesSteerIdentity.fromJson(
        requireJsonObject(snapshot['steer'], '$context.steer'),
      ),
      reason: requireJsonString(snapshot['reason'], '$context.reason'),
      requiredInput: requiredInput,
      streamId: optionalJsonString(snapshot, 'stream_id', context),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    if (requiredInput.isEmpty) {
      throw const FormatException(
        'ResponsesSteerPendingEvent.required_input: expected a nonempty list',
      );
    }
    for (final stub in requiredInput) {
      stub.toJson();
    }
    return _valueJson();
  }

  Map<String, dynamic> _valueJson() => mergeResponsesJson(
    rawJson,
    const {
      'type',
      'sequence_number',
      'stream_id',
      'steer',
      'reason',
      'required_input',
    },
    {
      'type': type,
      'sequence_number': sequenceNumber,
      if (streamId != null) 'stream_id': streamId,
      'steer': _mergeSteerNestedJson(rawJson['steer'], steer.toJson(), const {
        'id',
        'previous_response_id',
      }),
      'reason': reason,
      'required_input': _steerRequiredInputJson(
        rawJson['required_input'],
        requiredInput,
      ),
    },
  );

  /// Copies all members; explicit null clears only the optional lane.
  /// Nested replacements reconcile owned metadata, including explicit clears.
  /// Copy a stub to preserve its metadata; a fresh replacement carries its own.
  ResponsesSteerPendingEvent copyWith({
    int? sequenceNumber,
    ResponsesSteerIdentity? steer,
    String? reason,
    List<ResponsesSteerRequiredInput>? requiredInput,
    Object? streamId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    final retainedRaw = rawJson ?? this.rawJson;
    final replacingChild = steer != null || requiredInput != null;
    final reconciledRaw = !replacingChild || rawJson != null
        ? retainedRaw
        : replaceResponsesTypedJson(
            retainedRaw,
            {
              if (steer != null) 'steer': _valueJson()['steer'],
              if (requiredInput != null)
                'required_input': _steerRequiredInputJson(
                  retainedRaw['required_input'],
                  this.requiredInput,
                ),
            },
            {
              if (steer != null) 'steer': steer.toJson(),
              if (requiredInput != null)
                'required_input': _steerRequiredInputJson(null, requiredInput),
            },
          );
    return ResponsesSteerPendingEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      steer: steer ?? this.steer,
      reason: reason ?? this.reason,
      requiredInput: requiredInput ?? this.requiredInput,
      streamId: identical(streamId, unsetCopyWithValue)
          ? this.streamId
          : streamId as String?,
      rawJson: replacingChild && rawJson == null
          ? freezeJsonObject(reconciledRaw)
          : reconciledRaw,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerPendingEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));
  @override
  String toString() =>
      'ResponsesSteerPendingEvent(sequenceNumber: $sequenceNumber, steer: present, reason: [REDACTED], requiredInput: ${requiredInput.length} items, streamId: ${responsesPresence(streamId)}, rawJson: ${rawJson.length} entries)';
}

/// A `response.steer.failed` acknowledgement. It does not close the connection.
@immutable
class ResponsesSteerFailedEvent extends ResponsesServerEvent {
  /// Required ordering sequence.
  final int sequenceNumber;

  /// Required `steer` acknowledgement data.
  final ResponsesFailedSteer steer;

  /// Required `error` acknowledgement data.
  final ResponsesSteerError error;
  @override
  final String? streamId;
  @override
  final Map<String, dynamic> rawJson;

  /// Creates an acknowledgement with const caller-owned collections.
  const ResponsesSteerFailedEvent({
    required this.sequenceNumber,
    required this.steer,
    required this.error,
    this.streamId,
    this.rawJson = const {},
  });
  @override
  String get type => 'response.steer.failed';

  /// Parses required members, optional lane and future raw metadata.
  factory ResponsesSteerFailedEvent.fromJson(Map<String, dynamic> json) {
    const context = 'ResponsesSteerFailedEvent';
    requireJsonType(json, 'response.steer.failed', context);
    final snapshot = snapshotResponsesJson(json, context);
    return ResponsesSteerFailedEvent(
      sequenceNumber: requireJsonInt(
        snapshot['sequence_number'],
        '$context.sequence_number',
      ),
      steer: ResponsesFailedSteer.fromJson(
        requireJsonObject(snapshot['steer'], '$context.steer'),
      ),
      error: ResponsesSteerError.fromJson(
        requireJsonObject(snapshot['error'], '$context.error'),
      ),
      streamId: optionalJsonString(snapshot, 'stream_id', context),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    steer.toJson();
    return _valueJson();
  }

  Map<String, dynamic> _valueJson() => mergeResponsesJson(
    rawJson,
    const {'type', 'sequence_number', 'stream_id', 'steer', 'error'},
    {
      'type': type,
      'sequence_number': sequenceNumber,
      if (streamId != null) 'stream_id': streamId,
      'steer': _mergeSteerNestedJson(
        rawJson['steer'],
        steer._valueJson(),
        const {'id', 'previous_response_id', 'input'},
      ),
      'error': _mergeSteerNestedJson(rawJson['error'], error.toJson(), const {
        'type',
        'code',
        'message',
      }),
    },
  );

  /// Copies all members; explicit null clears only the optional lane.
  /// Replacing nested models reconciles metadata, including explicit clears.
  ResponsesSteerFailedEvent copyWith({
    int? sequenceNumber,
    ResponsesFailedSteer? steer,
    ResponsesSteerError? error,
    Object? streamId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    final retainedRaw = rawJson ?? this.rawJson;
    final replacingChild = steer != null || error != null;
    final reconciledRaw = !replacingChild || rawJson != null
        ? retainedRaw
        : replaceResponsesTypedJson(
            retainedRaw,
            {
              if (steer != null) 'steer': _valueJson()['steer'],
              if (error != null) 'error': _valueJson()['error'],
            },
            {
              if (steer != null) 'steer': steer._valueJson(),
              if (error != null) 'error': error.toJson(),
            },
          );
    return ResponsesSteerFailedEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      steer: steer ?? this.steer,
      error: error ?? this.error,
      streamId: identical(streamId, unsetCopyWithValue)
          ? this.streamId
          : streamId as String?,
      rawJson: replacingChild && rawJson == null
          ? freezeJsonObject(reconciledRaw)
          : reconciledRaw,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerFailedEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));
  @override
  String toString() =>
      'ResponsesSteerFailedEvent(sequenceNumber: $sequenceNumber, steer: present, error: present, streamId: ${responsesPresence(streamId)}, rawJson: ${rawJson.length} entries)';
}

List<ResponsesSteerRequiredInput> _parseSteerRequiredInput(
  Object? value,
  String context,
) {
  if (value is! List<dynamic> || value.isEmpty) {
    throw FormatException(
      '$context: expected a nonempty identifying stub list',
    );
  }
  final stubs = <ResponsesSteerRequiredInput>[];
  for (var index = 0; index < value.length; index++) {
    try {
      stubs.add(
        ResponsesSteerRequiredInput.fromJson(
          requireJsonObject(value[index], '$context[$index]'),
        ),
      );
    } on FormatException catch (error) {
      throw FormatException('$context[$index]: ${error.message}');
    }
  }
  return List<ResponsesSteerRequiredInput>.unmodifiable(stubs);
}

// Retain future metadata for an edit to the same submission, while replacing
// known members in full so a nullable clear cannot resurrect stale raw fields.
Map<String, dynamic> _mergeSteerNestedJson(
  Object? original,
  Map<String, dynamic> typed,
  Set<String> knownKeys,
) {
  if (original is! Map<String, dynamic>) return typed;
  for (final key in const [
    'type',
    'id',
    'previous_response_id',
    'call_id',
    'approval_request_id',
  ]) {
    if (original.containsKey(key) &&
        typed.containsKey(key) &&
        original[key] != typed[key]) {
      return typed;
    }
  }
  return mergeResponsesJson(original, knownKeys, typed);
}

List<Map<String, dynamic>> _steerRequiredInputJson(
  Object? original,
  List<ResponsesSteerRequiredInput> stubs,
) => [
  for (var index = 0; index < stubs.length; index++)
    if (stubs[index] is UnknownResponsesSteerRequiredInput)
      _mergeSteerNestedJson(
        original is List<dynamic> && index < original.length
            ? original[index]
            : null,
        {
          ...(stubs[index] as UnknownResponsesSteerRequiredInput).rawJson,
          'type': stubs[index].type,
        },
        const {'type', 'id', 'call_id', 'approval_request_id'},
      )
    else
      stubs[index].toJson(),
];
