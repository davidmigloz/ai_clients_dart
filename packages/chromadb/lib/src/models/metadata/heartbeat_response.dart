import 'package:meta/meta.dart';

/// Response from the heartbeat endpoint.
///
/// Contains the server's current timestamp for checking liveness.
@immutable
class HeartbeatResponse {
  /// The server's current timestamp in nanoseconds.
  final int nanosecondHeartbeat;

  /// Creates a heartbeat response.
  const HeartbeatResponse({required this.nanosecondHeartbeat});

  /// Creates a heartbeat response from JSON.
  factory HeartbeatResponse.fromJson(Map<String, dynamic> json) {
    return HeartbeatResponse(
      nanosecondHeartbeat: json['nanosecond heartbeat'] as int,
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() => {
    'nanosecond heartbeat': nanosecondHeartbeat,
  };

  /// Creates a copy of this response with optional modifications.
  HeartbeatResponse copyWith({int? nanosecondHeartbeat}) {
    return HeartbeatResponse(
      nanosecondHeartbeat: nanosecondHeartbeat ?? this.nanosecondHeartbeat,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeartbeatResponse &&
          runtimeType == other.runtimeType &&
          nanosecondHeartbeat == other.nanosecondHeartbeat;

  @override
  int get hashCode => nanosecondHeartbeat.hashCode;

  @override
  String toString() =>
      'HeartbeatResponse(nanosecondHeartbeat: $nanosecondHeartbeat)';
}
