import 'package:meta/meta.dart';

/// A server frame on a realtime audio connection.
///
/// [session] is present for session frames, [data] for audio or transcription
/// output, and [error] for API errors. Unknown frame types remain available
/// as [rawJson].
@immutable
final class RealtimeEvent<S, D> {
  /// Creates an event from a decoded frame.
  RealtimeEvent(
    Map<String, dynamic> json, {
    required this.type,
    this.session,
    this.data,
    this.error,
  }) : rawJson = Map.unmodifiable(json);

  /// The wire event type.
  final String type;

  /// Updated session state, if returned.
  final S? session;

  /// Realtime output data, if returned.
  final D? data;

  /// A protocol-level API error.
  final RealtimeError? error;

  /// Original frame data, including fields from newer server versions.
  final Map<String, dynamic> rawJson;

  /// Encodes the received frame.
  Map<String, dynamic> toJson() => Map.of(rawJson);

  @override
  String toString() => 'RealtimeEvent(type: $type, error: $error)';
}

/// An API error received over the realtime socket.
@immutable
final class RealtimeError {
  /// Creates a server error with its code and details.
  const RealtimeError({required this.code, required this.message});

  /// Internal error code.
  final int code;

  /// Human-readable message or structured detail object supplied by the API.
  final Object message;

  /// Decodes the error body from a frame.
  factory RealtimeError.fromJson(Map<String, dynamic> json) {
    final message = json['message'];
    if (message is! String && message is! Map<String, dynamic>) {
      throw const FormatException('Expected a realtime error message.');
    }
    return RealtimeError(code: json['code'] as int, message: message as Object);
  }

  /// Encodes the error.
  Map<String, dynamic> toJson() => {'code': code, 'message': message};

  @override
  String toString() => 'RealtimeError(code: $code)';
}

/// An error opening, configuring, or transporting a realtime audio session.
final class RealtimeConnectionException implements Exception {
  /// Creates a connection exception. [apiError] is available for API rejections.
  const RealtimeConnectionException(this.message, {this.apiError});

  /// Details of the problem, without credentials or frame contents.
  final String message;

  /// Optional server error when the API rejects the operation.
  final RealtimeError? apiError;

  @override
  String toString() =>
      'RealtimeConnectionException: $message${apiError == null ? '' : ' ($apiError)'}';
}
