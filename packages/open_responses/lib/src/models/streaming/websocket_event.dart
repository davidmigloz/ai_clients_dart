import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../request/create_response_request.dart';

/// WebSocket error envelope returned for Responses WebSocket mode failures.
@immutable
class WebSocketErrorEvent {
  /// The event type. Always `error`.
  String get type => 'error';

  /// The HTTP-style status code for the WebSocket error.
  final int status;

  /// The WebSocket error payload.
  ///
  /// The spec guarantees `code` and `message` keys; `param` and `type` are
  /// optional. Additional provider-specific keys may also be present, so the
  /// payload is kept as a raw map.
  final Map<String, dynamic> error;

  /// Creates a [WebSocketErrorEvent].
  const WebSocketErrorEvent({required this.status, required this.error});

  /// Creates a [WebSocketErrorEvent] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is missing or not
  /// `"error"`, since the spec requires it and silently accepting mismatches
  /// would hide caller mistakes.
  factory WebSocketErrorEvent.fromJson(Map<String, dynamic> json) {
    final jsonType = json['type'];
    if (jsonType != 'error') {
      throw FormatException(
        'Invalid WebSocketErrorEvent type: expected "error", got $jsonType',
      );
    }
    return WebSocketErrorEvent(
      status: json['status'] as int,
      error: Map<String, dynamic>.from(json['error'] as Map),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'error',
    'status': status,
    'error': error,
  };

  /// Creates a copy with replaced values.
  WebSocketErrorEvent copyWith({int? status, Map<String, dynamic>? error}) {
    return WebSocketErrorEvent(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSocketErrorEvent &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          mapsDeepEqual(error, other.error);

  @override
  int get hashCode => Object.hash(status, mapDeepHashCode(error));

  @override
  String toString() => 'WebSocketErrorEvent(status: $status, error: $error)';
}

/// A client-sent WebSocket event that starts a Responses turn.
///
/// Wraps a [CreateResponseRequest] with a required `type: "response.create"`
/// discriminator. The HTTP-only fields `background`, `stream`, and
/// `stream_options` are disallowed by the spec in WebSocket mode and are
/// stripped from [toJson] if present on the wrapped request.
@immutable
class WebSocketResponseCreateEvent {
  /// The client event type. Always `response.create`.
  String get type => 'response.create';

  /// The response creation request body.
  final CreateResponseRequest request;

  /// Creates a [WebSocketResponseCreateEvent].
  const WebSocketResponseCreateEvent({required this.request});

  /// Creates a [WebSocketResponseCreateEvent] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is missing or not
  /// `"response.create"`, since the spec requires it and silently accepting
  /// mismatches would hide caller mistakes.
  factory WebSocketResponseCreateEvent.fromJson(Map<String, dynamic> json) {
    final jsonType = json['type'];
    if (jsonType != 'response.create') {
      throw FormatException(
        'Invalid WebSocketResponseCreateEvent type: expected '
        '"response.create", got $jsonType',
      );
    }
    final body = Map<String, dynamic>.from(json)..remove('type');
    return WebSocketResponseCreateEvent(
      request: CreateResponseRequest.fromJson(body),
    );
  }

  /// Converts to JSON.
  ///
  /// The `type` discriminator is spread last so it always wins, defending
  /// against a future [CreateResponseRequest.toJson] gaining a `type` key.
  Map<String, dynamic> toJson() {
    final json = request.toJson()
      ..remove('background')
      ..remove('stream')
      ..remove('stream_options');
    return {...json, 'type': 'response.create'};
  }

  /// Creates a copy with replaced values.
  WebSocketResponseCreateEvent copyWith({CreateResponseRequest? request}) {
    return WebSocketResponseCreateEvent(request: request ?? this.request);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSocketResponseCreateEvent &&
          runtimeType == other.runtimeType &&
          request == other.request;

  @override
  int get hashCode => request.hashCode;

  @override
  String toString() => 'WebSocketResponseCreateEvent(request: $request)';
}
