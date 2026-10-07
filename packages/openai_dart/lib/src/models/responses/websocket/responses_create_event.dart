import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/json_helpers.dart';
import '../config/context_management.dart';
import '../config/include.dart';
import '../create_response_request.dart';
import '../items/item.dart';
import '../response_input.dart';
import '../tools/response_tool.dart';
import 'websocket_json_helpers.dart';

/// Creates a response over a persistent Responses WebSocket connection.
///
/// The ordinary HTTP request is composed with WebSocket-only routing metadata.
/// [streamId] selects a FIFO lane; the request's `previousResponseId` selects
/// ancestry. [generate] can be false for a documented cache warm-up. Neither
/// field is added to the HTTP request. `stream` is implicit and omitted;
/// `background: true` is unsupported. `stream_options` is retained.
@immutable
class ResponsesCreateEvent {
  /// The ordinary Responses request.
  final CreateResponseRequest request;

  /// Optional named lane, consisting of 1–256 ASCII letters, digits, `_`, `.`,
  /// or `-`. Omission selects the default lane.
  final String? streamId;

  /// Whether the server should generate output; false requests a warm-up.
  ///
  /// This guide-supported WebSocket extension is absent from the canonical
  /// create schema and does not change the HTTP request model.
  final bool? generate;

  /// Creates a [ResponsesCreateEvent].
  ///
  /// Validation runs when serializing so this constructor remains const.
  const ResponsesCreateEvent({
    required this.request,
    this.streamId,
    this.generate,
  });

  /// The fixed client event discriminator.
  String get type => 'response.create';

  /// Parses an event using the ordinary request's existing field contracts.
  factory ResponsesCreateEvent.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'response.create', 'ResponsesCreateEvent');
    final snapshot = snapshotResponsesJson(json, 'ResponsesCreateEvent');
    final streamId = optionalJsonString(
      snapshot,
      'stream_id',
      'ResponsesCreateEvent',
    );
    final generate = optionalJsonBool(
      snapshot,
      'generate',
      'ResponsesCreateEvent',
    );
    final background = snapshot['background'] == null
        ? null
        : optionalJsonBool(snapshot, 'background', 'ResponsesCreateEvent');
    _validateCreate(streamId, background);
    if (snapshot['stream'] != null) {
      optionalJsonBool(snapshot, 'stream', 'ResponsesCreateEvent');
    }
    CreateResponseRequest request;
    try {
      final body = Map<String, dynamic>.from(snapshot)
        ..remove('type')
        ..remove('stream_id')
        ..remove('generate')
        ..remove('stream')
        ..remove('background');
      request = CreateResponseRequest.fromJson(body);
    } on FormatException {
      throw const FormatException(
        'ResponsesCreateEvent.request: malformed response request',
      );
    } on TypeError {
      throw const FormatException(
        'ResponsesCreateEvent.request: malformed response request',
      );
    }
    // These lists are constructed by the shared request parser. Snapshot the
    // outer collections without changing const caller-owned HTTP construction.
    request = request.copyWith(
      input: request.input is ResponseInputItems
          ? ResponseInput.items(
              List<Item>.unmodifiable(
                (request.input as ResponseInputItems).items,
              ),
            )
          : request.input,
      tools: request.tools == null
          ? null
          : List<ResponseTool>.unmodifiable(request.tools!),
      contextManagement: request.contextManagement == null
          ? null
          : List<ContextManagement>.unmodifiable(request.contextManagement!),
      include: request.include == null
          ? null
          : List<Include>.unmodifiable(request.include!),
      metadata: request.metadata == null
          ? null
          : freezeJsonObject(request.metadata!),
    );
    return ResponsesCreateEvent(
      request: request,
      streamId: streamId,
      generate: generate,
    );
  }

  /// Converts to a validated WebSocket frame without changing [request].
  Map<String, dynamic> toJson() {
    _validateCreate(streamId, request.background);
    final body = request.toJson()
      ..remove('stream')
      ..remove('background');
    return {
      ...body,
      'type': type,
      if (streamId != null) 'stream_id': streamId,
      if (generate != null) 'generate': generate,
    };
  }

  /// Copies the event; explicit null clears nullable metadata.
  ResponsesCreateEvent copyWith({
    CreateResponseRequest? request,
    Object? streamId = unsetCopyWithValue,
    Object? generate = unsetCopyWithValue,
  }) => ResponsesCreateEvent(
    request: request ?? this.request,
    streamId: identical(streamId, unsetCopyWithValue)
        ? this.streamId
        : streamId as String?,
    generate: identical(generate, unsetCopyWithValue)
        ? this.generate
        : generate as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesCreateEvent &&
          request == other.request &&
          streamId == other.streamId &&
          generate == other.generate;

  @override
  int get hashCode => Object.hash(request, streamId, generate);

  @override
  String toString() =>
      'ResponsesCreateEvent(request: present, '
      'streamId: ${responsesPresence(streamId)}, generate: $generate)';
}

final _createLanePattern = RegExp(r'^[A-Za-z0-9_.-]+$');

void _validateCreate(String? streamId, bool? background) {
  if (background == true) {
    throw const FormatException(
      'ResponsesCreateEvent.request.background: true is unsupported',
    );
  }
  if (streamId != null &&
      (streamId.isEmpty ||
          streamId.length > 256 ||
          !_createLanePattern.hasMatch(streamId) ||
          streamId.codeUnits.any(
            (unit) => unit > 127 || unit == 10 || unit == 13,
          ))) {
    throw const FormatException(
      'ResponsesCreateEvent.stream_id: expected 1–256 ASCII letters, digits, '
      'underscores, dots or hyphens',
    );
  }
}
