import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';
import '../items/item.dart';
import '../misalignment_details.dart';
import '../multi_agent/agent_tag.dart';
import '../multi_agent/response_inject_event.dart' show ResponseInjectErrorCode;
import '../streaming/response_stream_event.dart';
import 'responses_steer_event.dart';
import 'responses_steer_required_input.dart';
import 'websocket_json_helpers.dart';

export '../misalignment_details.dart';

part 'responses_inject_server_events.dart';
part 'responses_steer_server_events.dart';

/// A server message on a persistent Responses WebSocket connection.
///
/// Ordinary messages wrap the existing SSE models. Errors retain the richer
/// WebSocket envelope. Steering acknowledgements retain submission identity and
/// rejected input. Injection acknowledgements retain full uncommitted input.
/// Future messages retain raw JSON. Completion does not
/// indicate connection completion.
///
/// Variants are [ResponsesStreamEvent] for ordinary shared events,
/// [ResponsesErrorEvent] for full WebSocket errors, and
/// [ResponsesSteerAcceptedEvent], [ResponsesSteerPendingEvent] and
/// [ResponsesSteerFailedEvent] for steering acknowledgements;
/// [ResponseInjectCreatedEvent] and [ResponseInjectFailedEvent] for beta injection
/// acknowledgements. Future messages use
/// [UnknownResponsesServerEvent].
@immutable
sealed class ResponsesServerEvent {
  /// Creates a server envelope.
  const ResponsesServerEvent();

  /// The server's discriminator.
  String get type;

  /// The originating named lane, or null for the default lane.
  ///
  /// Returned metadata is a string; request-side lane constraints are not
  /// imposed on server messages.
  String? get streamId;

  /// Original recursively immutable JSON when parsed from a server message.
  Map<String, dynamic> get rawJson;

  /// Parses a server message without changing the existing SSE dispatcher.
  factory ResponsesServerEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotResponsesJson(json, 'ResponsesServerEvent');
    final type = requireJsonString(
      snapshot['type'],
      'ResponsesServerEvent.type',
    );
    final streamId = optionalJsonString(
      snapshot,
      'stream_id',
      'ResponsesServerEvent',
    );
    if (type == 'error') return ResponsesErrorEvent.fromJson(snapshot);
    if (type == 'response.inject.created') {
      return ResponseInjectCreatedEvent.fromJson(snapshot);
    }
    if (type == 'response.inject.failed') {
      return ResponseInjectFailedEvent.fromJson(snapshot);
    }
    if (type == 'response.steer.accepted') {
      return ResponsesSteerAcceptedEvent.fromJson(snapshot);
    }
    if (type == 'response.steer.pending') {
      return ResponsesSteerPendingEvent.fromJson(snapshot);
    }
    if (type == 'response.steer.failed') {
      return ResponsesSteerFailedEvent.fromJson(snapshot);
    }
    if (!_sharedEventTypes.contains(type)) {
      return UnknownResponsesServerEvent(
        type: type,
        streamId: streamId,
        rawJson: snapshot,
      );
    }
    ResponseStreamEvent event;
    try {
      event = ResponseStreamEvent.fromJson(snapshot);
    } on FormatException {
      throw const FormatException(
        'ResponsesServerEvent.event: malformed shared Responses event',
      );
    } on TypeError {
      throw const FormatException(
        'ResponsesServerEvent.event: malformed shared Responses event',
      );
    }
    if (event is UnknownEvent) {
      return UnknownResponsesServerEvent(
        type: type,
        streamId: streamId,
        rawJson: snapshot,
      );
    }
    return ResponsesStreamEvent(
      event: event,
      streamId: streamId,
      rawJson: snapshot,
    );
  }

  /// Converts to JSON, retaining future metadata and typed field changes.
  Map<String, dynamic> toJson();
}

/// An ordinary shared Responses stream event with WebSocket lane metadata.
@immutable
class ResponsesStreamEvent extends ResponsesServerEvent {
  /// The shared typed event; its existing SSE contract remains unchanged.
  final ResponseStreamEvent event;

  @override
  final String? streamId;

  @override
  final Map<String, dynamic> rawJson;

  /// Creates an envelope. Caller-owned raw JSON retains const construction.
  const ResponsesStreamEvent({
    required this.event,
    this.streamId,
    this.rawJson = const {},
  });

  /// Parses an ordinary shared event, rejecting an error or future variant.
  factory ResponsesStreamEvent.fromJson(Map<String, dynamic> json) {
    final event = ResponsesServerEvent.fromJson(json);
    if (event is ResponsesStreamEvent) return event;
    throw const FormatException(
      'ResponsesStreamEvent.type: expected an ordinary shared event',
    );
  }

  @override
  String get type => event.type;

  @override
  Map<String, dynamic> toJson() {
    snapshotResponsesJson(rawJson, 'ResponsesStreamEvent');
    if (!_sharedEventTypes.contains(type) ||
        event is ErrorEvent ||
        event is UnknownEvent) {
      throw const FormatException(
        'ResponsesStreamEvent.event: expected an ordinary shared event; '
        'use ResponsesErrorEvent or UnknownResponsesServerEvent for other frames',
      );
    }
    return _valueJson();
  }

  Map<String, dynamic> _valueJson() {
    final typed = event.toJson();
    final json = overlayResponsesJson(rawJson, typed)..remove('stream_id');
    final typedResponse = typed['response'];
    final originalResponse = rawJson['response'];
    if (typedResponse is Map<String, dynamic> &&
        json['response'] is Map<String, dynamic>) {
      final response = json['response'] as Map<String, dynamic>;
      final originalError = originalResponse is Map<String, dynamic>
          ? originalResponse['error']
          : null;
      final typedError = typedResponse['error'];
      if (typedError is Map<String, dynamic>) {
        response['error'] = mergeResponsesModelJson(
          originalError,
          typedError,
          const {'type', 'code', 'message', 'param', 'misalignment'},
          childKeys: const {
            'misalignment': {
              'detailed_explanation',
              'error_type',
              'review_target',
              'steer',
            },
            'steer': {'message'},
          },
        );
      } else if (originalError is Map<String, dynamic>) {
        // Clearing a typed error must not restore its old parent snapshot.
        // Original nullable `error: null` remains untouched for compatibility.
        response.remove('error');
      }
    }
    if (streamId != null) json['stream_id'] = streamId;
    return json;
  }

  /// Copies the envelope, retaining nested future metadata on typed edits and
  /// removing cleared known fields. A different event type replaces its payload.
  ResponsesStreamEvent copyWith({
    ResponseStreamEvent? event,
    Object? streamId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    final retainedRaw = rawJson ?? this.rawJson;
    final newRaw = event == null || rawJson != null
        ? retainedRaw
        : event.runtimeType == this.event.runtimeType
        ? replaceResponsesTypedJson(
            retainedRaw,
            this.event.toJson(),
            event.toJson(),
          )
        : {
            for (final entry in retainedRaw.entries)
              if (!this.event.toJson().containsKey(entry.key))
                entry.key: entry.value,
          };
    return ResponsesStreamEvent(
      event: event ?? this.event,
      streamId: identical(streamId, unsetCopyWithValue)
          ? this.streamId
          : streamId as String?,
      rawJson: event != null && rawJson == null
          ? freezeJsonObject(newRaw)
          : newRaw,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesStreamEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));

  @override
  String toString() =>
      'ResponsesStreamEvent(event: present, '
      'streamId: ${responsesPresence(streamId)}, '
      'rawJson: ${rawJson.length} entries)';
}

/// A lossless envelope for server messages with future discriminators.
@immutable
class UnknownResponsesServerEvent extends ResponsesServerEvent {
  @override
  final String type;

  @override
  final String? streamId;

  @override
  final Map<String, dynamic> rawJson;

  /// Creates a lossless future-message envelope.
  const UnknownResponsesServerEvent({
    required this.type,
    required this.rawJson,
    this.streamId,
  });

  /// Parses a future variant without accepting malformed known events.
  factory UnknownResponsesServerEvent.fromJson(Map<String, dynamic> json) {
    final event = ResponsesServerEvent.fromJson(json);
    if (event is UnknownResponsesServerEvent) return event;
    throw const FormatException(
      'UnknownResponsesServerEvent.type: expected a future event',
    );
  }

  @override
  Map<String, dynamic> toJson() => mergeResponsesJson(
    rawJson,
    const {'type', 'stream_id'},
    {'type': type, if (streamId != null) 'stream_id': streamId},
  );

  /// Copies all fields; explicit null clears the lane.
  UnknownResponsesServerEvent copyWith({
    String? type,
    Object? streamId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => UnknownResponsesServerEvent(
    type: type ?? this.type,
    streamId: identical(streamId, unsetCopyWithValue)
        ? this.streamId
        : streamId as String?,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownResponsesServerEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      'UnknownResponsesServerEvent(type: [REDACTED], '
      'streamId: ${responsesPresence(streamId)}, '
      'rawJson: ${rawJson.length} entries)';
}

/// A request-scoped WebSocket error; other lanes can remain usable.
@immutable
class ResponsesErrorEvent extends ResponsesServerEvent {
  /// Complete nested error details.
  final ResponsesErrorPayload error;

  /// Optional HTTP-equivalent protocol status.
  final int? status;

  /// Optional position in the response stream.
  final int? sequenceNumber;

  @override
  final String? streamId;

  /// Optional beta multi-agent owner.
  final AgentTag? agent;

  /// Whether nullable beta agent metadata was present, including explicit null.
  final bool hasAgent;

  @override
  final Map<String, dynamic> rawJson;

  /// Creates a full WebSocket error envelope.
  const ResponsesErrorEvent({
    required this.error,
    this.status,
    this.sequenceNumber,
    this.streamId,
    this.agent,
    bool hasAgent = false,
    this.rawJson = const {},
  }) : hasAgent = hasAgent || agent != null;

  @override
  String get type => 'error';

  /// Parses the richer WebSocket contract, distinct from SSE [ErrorEvent].
  factory ResponsesErrorEvent.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'error', 'ResponsesErrorEvent');
    final snapshot = snapshotResponsesJson(json, 'ResponsesErrorEvent');
    AgentTag? agent;
    if (snapshot['agent'] != null) {
      final agentJson = requireJsonObject(
        snapshot['agent'],
        'ResponsesErrorEvent.agent',
      );
      agent = AgentTag(
        agentName: requireJsonString(
          agentJson['agent_name'],
          'ResponsesErrorEvent.agent.agent_name',
        ),
      );
    }
    return ResponsesErrorEvent(
      error: ResponsesErrorPayload.fromJson(
        requireJsonObject(snapshot['error'], 'ResponsesErrorEvent.error'),
      ),
      status: optionalJsonInt(snapshot, 'status', 'ResponsesErrorEvent'),
      sequenceNumber: optionalJsonInt(
        snapshot,
        'sequence_number',
        'ResponsesErrorEvent',
      ),
      streamId: optionalJsonString(
        snapshot,
        'stream_id',
        'ResponsesErrorEvent',
      ),
      agent: agent,
      hasAgent: snapshot.containsKey('agent'),
      rawJson: snapshot,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    snapshotResponsesJson(rawJson, 'ResponsesErrorEvent');
    error.misalignment?.toJson();
    return _valueJson();
  }

  Map<String, dynamic> _valueJson() => mergeResponsesJson(
    rawJson,
    const {'type', 'error', 'status', 'sequence_number', 'stream_id', 'agent'},
    {
      'type': type,
      'error': mergeResponsesModelJson(
        rawJson['error'],
        error._valueJson(),
        const {'type', 'message', 'code', 'param', 'headers', 'misalignment'},
        childKeys: const {
          'misalignment': {
            'detailed_explanation',
            'error_type',
            'review_target',
            'steer',
          },
          'steer': {'message'},
        },
      ),
      if (status != null) 'status': status,
      if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      if (streamId != null) 'stream_id': streamId,
      if (agent != null || hasAgent)
        'agent': agent == null
            ? null
            : overlayResponsesJson(
                rawJson['agent'] is Map<String, dynamic>
                    ? rawJson['agent'] as Map<String, dynamic>
                    : const {},
                agent!.toJson(),
              ),
    },
  );

  /// Copies all fields. `agent: null` retains an explicit nullable key;
  /// `hasAgent: false` with null agent restores omission.
  ResponsesErrorEvent copyWith({
    ResponsesErrorPayload? error,
    Object? status = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? streamId = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    bool? hasAgent,
    Map<String, dynamic>? rawJson,
  }) {
    final replacingAgent = !identical(agent, unsetCopyWithValue);
    final newAgent = replacingAgent ? agent as AgentTag? : this.agent;
    final replacingChild = error != null || replacingAgent;
    final retainedRaw = rawJson ?? this.rawJson;
    final reconciledRaw = !replacingChild || rawJson != null
        ? retainedRaw
        : replaceResponsesTypedJson(
            retainedRaw,
            {
              if (error != null) 'error': _valueJson()['error'],
              if (replacingAgent) 'agent': _valueJson()['agent'],
            },
            {
              if (error != null) 'error': error._valueJson(),
              if (replacingAgent && newAgent != null)
                'agent': newAgent.toJson(),
            },
          );
    return ResponsesErrorEvent(
      error: error ?? this.error,
      status: identical(status, unsetCopyWithValue)
          ? this.status
          : status as int?,
      sequenceNumber: identical(sequenceNumber, unsetCopyWithValue)
          ? this.sequenceNumber
          : sequenceNumber as int?,
      streamId: identical(streamId, unsetCopyWithValue)
          ? this.streamId
          : streamId as String?,
      agent: newAgent,
      hasAgent:
          hasAgent ?? (!identical(agent, unsetCopyWithValue) || this.hasAgent),
      rawJson: replacingChild && rawJson == null
          ? freezeJsonObject(reconciledRaw)
          : reconciledRaw,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesErrorEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));

  @override
  String toString() =>
      'ResponsesErrorEvent(error: present, status: $status, '
      'sequenceNumber: $sequenceNumber, '
      'streamId: ${responsesPresence(streamId)}, '
      'agent: ${responsesPresence(agent)}, hasAgent: $hasAgent, '
      'rawJson: ${rawJson.length} entries)';
}

/// Full error payload for Responses WebSocket requests.
///
/// Canonical `code`/`param` keys are nullable and required. For compatibility
/// with documented connection-limit/provider errors, parsing also accepts
/// omission and retains presence with [hasCode]/[hasParam]. New construction
/// defaults to canonical explicit nullable keys.
@immutable
class ResponsesErrorPayload {
  /// Open provider error type.
  final String type;

  /// Human-readable explanation, potentially containing sensitive data.
  final String message;

  /// Open nullable error code; future strings are preserved.
  final String? code;

  /// Open nullable parameter name.
  final String? param;

  /// Whether `code` is present rather than omitted.
  final bool hasCode;

  /// Whether `param` is present rather than omitted.
  final bool hasParam;

  /// Optional response headers, including possible sensitive values.
  final Map<String, String>? headers;

  /// Optional review/block metadata.
  final ResponsesMisalignmentDetails? misalignment;

  /// Original immutable payload after parsing, including future fields.
  final Map<String, dynamic> rawJson;

  /// Creates a payload, retaining const caller-owned collection construction.
  const ResponsesErrorPayload({
    required this.type,
    required this.message,
    this.code,
    this.param,
    bool hasCode = true,
    bool hasParam = true,
    this.headers,
    this.misalignment,
    this.rawJson = const {},
  }) : hasCode = hasCode || code != null,
       hasParam = hasParam || param != null;

  /// Parses exact nullable presence, headers and optional review details.
  factory ResponsesErrorPayload.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotResponsesJson(json, 'ResponsesErrorPayload');
    Map<String, String>? headers;
    if (snapshot.containsKey('headers')) {
      final object = requireJsonObject(
        snapshot['headers'],
        'ResponsesErrorPayload.headers',
      );
      headers = Map<String, String>.unmodifiable({
        for (final entry in object.entries)
          entry.key: requireJsonString(
            entry.value,
            'ResponsesErrorPayload.headers value',
          ),
      });
    }
    return ResponsesErrorPayload(
      type: requireJsonString(snapshot['type'], 'ResponsesErrorPayload.type'),
      message: requireJsonString(
        snapshot['message'],
        'ResponsesErrorPayload.message',
      ),
      code: optionalJsonString(
        snapshot,
        'code',
        'ResponsesErrorPayload',
        nullable: true,
      ),
      param: optionalJsonString(
        snapshot,
        'param',
        'ResponsesErrorPayload',
        nullable: true,
      ),
      hasCode: snapshot.containsKey('code'),
      hasParam: snapshot.containsKey('param'),
      headers: headers,
      misalignment: snapshot.containsKey('misalignment')
          ? ResponsesMisalignmentDetails.fromJson(
              requireJsonObject(
                snapshot['misalignment'],
                'ResponsesErrorPayload.misalignment',
              ),
            )
          : null,
      rawJson: snapshot,
    );
  }

  /// Converts to JSON without conflating absent and nullable keys.
  Map<String, dynamic> toJson() {
    snapshotResponsesJson(rawJson, 'ResponsesErrorPayload');
    misalignment?.toJson();
    return _valueJson();
  }

  Map<String, dynamic> _valueJson() => mergeResponsesJson(
    rawJson,
    const {'type', 'message', 'code', 'param', 'headers', 'misalignment'},
    {
      'type': type,
      'message': message,
      if (hasCode || code != null) 'code': code,
      if (hasParam || param != null) 'param': param,
      if (headers != null) 'headers': Map<String, String>.from(headers!),
      if (misalignment != null)
        'misalignment': mergeResponsesModelJson(
          rawJson['misalignment'],
          misalignment!.toJson(),
          const {
            'detailed_explanation',
            'error_type',
            'review_target',
            'steer',
          },
          childKeys: const {
            'steer': {'message'},
          },
        ),
    },
  );

  /// Copies all fields; explicit null emits nullable code/param. To restore
  /// omission, clear the value and set its corresponding presence flag false.
  ResponsesErrorPayload copyWith({
    String? type,
    String? message,
    Object? code = unsetCopyWithValue,
    Object? param = unsetCopyWithValue,
    bool? hasCode,
    bool? hasParam,
    Object? headers = unsetCopyWithValue,
    Object? misalignment = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    final replacingDetails = !identical(misalignment, unsetCopyWithValue);
    final details = identical(misalignment, unsetCopyWithValue)
        ? this.misalignment
        : misalignment as ResponsesMisalignmentDetails?;
    final retainedRaw = rawJson ?? this.rawJson;
    final reconciledRaw = !replacingDetails || rawJson != null
        ? retainedRaw
        : replaceResponsesTypedJson(
            retainedRaw,
            {
              if (this.misalignment != null)
                'misalignment': _valueJson()['misalignment'],
            },
            {if (details != null) 'misalignment': details.toJson()},
          );
    return ResponsesErrorPayload(
      type: type ?? this.type,
      message: message ?? this.message,
      code: identical(code, unsetCopyWithValue) ? this.code : code as String?,
      param: identical(param, unsetCopyWithValue)
          ? this.param
          : param as String?,
      hasCode:
          hasCode ?? (!identical(code, unsetCopyWithValue) || this.hasCode),
      hasParam:
          hasParam ?? (!identical(param, unsetCopyWithValue) || this.hasParam),
      headers: identical(headers, unsetCopyWithValue)
          ? this.headers
          : headers as Map<String, String>?,
      misalignment: identical(misalignment, unsetCopyWithValue)
          ? this.misalignment
          : misalignment as ResponsesMisalignmentDetails?,
      rawJson: replacingDetails && rawJson == null
          ? freezeJsonObject(reconciledRaw)
          : reconciledRaw,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesErrorPayload &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));

  @override
  String toString() =>
      'ResponsesErrorPayload(type: [REDACTED], message: [REDACTED], '
      'code: ${responsesPresence(code)}, param: ${responsesPresence(param)}, '
      'hasCode: $hasCode, hasParam: $hasParam, '
      'headers: ${headers == null ? 'null' : '${headers!.length} entries'}, '
      'misalignment: ${responsesPresence(misalignment)}, '
      'rawJson: ${rawJson.length} entries)';
}

// Kept in step with the shared SSE dispatcher; its 58 variants are
// independently exercised against canonical wire fixtures.
const _sharedEventTypes = <String>{
  'response.created',
  'response.queued',
  'response.in_progress',
  'response.completed',
  'response.failed',
  'response.incomplete',
  'response.output_item.added',
  'response.output_item.done',
  'response.content_part.added',
  'response.content_part.done',
  'response.output_text.delta',
  'response.output_text.done',
  'response.output_text.annotation.added',
  'response.refusal.delta',
  'response.refusal.done',
  'response.function_call_arguments.delta',
  'response.function_call_arguments.done',
  'response.reasoning_text.delta',
  'response.reasoning_text.done',
  'response.reasoning_summary_part.added',
  'response.reasoning_summary_part.done',
  'response.reasoning_summary_text.delta',
  'response.reasoning_summary_text.done',
  'response.compaction.compacting',
  'response.audio.delta',
  'response.audio.done',
  'response.audio.transcript.delta',
  'response.audio.transcript.done',
  'response.web_search_call.in_progress',
  'response.web_search_call.searching',
  'response.web_search_call.completed',
  'response.file_search_call.in_progress',
  'response.file_search_call.searching',
  'response.file_search_call.completed',
  'response.code_interpreter_call.in_progress',
  'response.code_interpreter_call.interpreting',
  'response.code_interpreter_call_code.delta',
  'response.code_interpreter_call_code.done',
  'response.code_interpreter_call.completed',
  'response.shell_call_command.added',
  'response.shell_call_command.delta',
  'response.shell_call_command.done',
  'response.shell_call_output_content.delta',
  'response.shell_call_output_content.done',
  'response.image_generation_call.in_progress',
  'response.image_generation_call.generating',
  'response.image_generation_call.partial_image',
  'response.image_generation_call.completed',
  'response.mcp_call.in_progress',
  'response.mcp_call.completed',
  'response.mcp_call.failed',
  'response.mcp_call_arguments.delta',
  'response.mcp_call_arguments.done',
  'response.mcp_list_tools.in_progress',
  'response.mcp_list_tools.completed',
  'response.mcp_list_tools.failed',
  'response.custom_tool_call_input.delta',
  'response.custom_tool_call_input.done',
};
