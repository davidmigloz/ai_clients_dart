import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';
import '../items/item.dart';
import '../websocket/responses_server_event.dart' show ResponseInjectError;
import '../websocket/websocket_json_helpers.dart';

export '../websocket/responses_server_event.dart'
    show
        ResponseInjectCreatedEvent,
        ResponseInjectError,
        ResponseInjectFailedEvent;

/// Injects input into an active beta multi-agent Responses WebSocket response.
///
/// Exactly type, response_id and input are sent. The server currently admits
/// client-owned results that resume a waiting agent and commits them atomically.
/// This writable model retains the existing broad [Item] input surface; it does
/// not invent a tool whitelist or require a nonempty array. Transport opt-in is
/// the beta Responses connection, not an HTTP endpoint.
///
/// Parsing projects known frame fields, ignoring additional finite JSON members.
/// It uses the existing shared Item codec: unknown kinds are rejected,
/// extra known-item metadata may be trimmed, and nested ownership/defaults keep
/// that codec's existing behavior. Only the outer parsed list is snapshotted;
/// this model does not claim complete generated input-union or raw-item fidelity.
@immutable
class ResponseInjectEvent {
  /// Fixed event discriminator.
  String get type => 'response.inject';

  /// Actual active response ID received from response.created.
  final String responseId;

  /// Existing writable input items, at most 16,384. Empty input remains valid.
  final List<Item> input;

  /// Creates a const event with caller-owned item collections.
  const ResponseInjectEvent({required this.responseId, required this.input});

  /// Validates known frame fields and parses the existing broad Item surface.
  factory ResponseInjectEvent.fromJson(Map<String, dynamic> json) {
    const context = 'ResponseInjectEvent';
    requireJsonType(json, 'response.inject', context);
    final snapshot = snapshotResponsesJson(json, context);
    final values = snapshot['input'];
    if (values is! List<dynamic>) {
      throw const FormatException(
        'ResponseInjectEvent.input: expected an array',
      );
    }
    _validateInjectInputCount(values.length);
    final items = <Item>[];
    for (var index = 0; index < values.length; index++) {
      try {
        final item = requireJsonObject(values[index], '$context.input[$index]');
        requireJsonString(item['type'], '$context.input[$index].type');
        items.add(Item.fromJson(item));
      } catch (_) {
        // Shared codec errors can retain provider payloads or lack context.
        throw FormatException(
          '$context.input[$index]: malformed or unsupported item',
        );
      }
    }
    return ResponseInjectEvent(
      responseId: requireJsonString(
        snapshot['response_id'],
        '$context.response_id',
      ),
      input: List<Item>.unmodifiable(items),
    );
  }

  /// Serializes exactly three fields and validates count/finite JSON in release.
  Map<String, dynamic> toJson() {
    _validateInjectInputCount(input.length);
    final json = _valueJson();
    snapshotResponsesJson(json, 'ResponseInjectEvent');
    return json;
  }

  Map<String, dynamic> _valueJson() => {
    'type': type,
    'response_id': responseId,
    'input': input.map((item) => item.toJson()).toList(),
  };

  /// Copies both required fields, preserving constructor collection ownership.
  ResponseInjectEvent copyWith({String? responseId, List<Item>? input}) =>
      ResponseInjectEvent(
        responseId: responseId ?? this.responseId,
        input: input ?? this.input,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInjectEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));
  @override
  String toString() =>
      'ResponseInjectEvent(responseId: [REDACTED], input: ${input.length} items)';
}

void _validateInjectInputCount(int count) {
  if (count > 16384) {
    throw const FormatException(
      'ResponseInjectEvent.input: at most 16384 items',
    );
  }
}

/// Canonical injection failures: already completed or response not found.
///
/// The unknown enum member is a compatibility fallback, not a third canonical
/// value; [ResponseInjectError.rawCode] preserves future provider strings.
///
/// This belongs to the beta multi-agent WebSocket protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`).
enum ResponseInjectErrorCode {
  /// Unknown enum fallback. [ResponseInjectError.rawCode] retains the wire string.
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
