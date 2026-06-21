import 'package:meta/meta.dart';

/// An error payload delivered over a workflow log SSE stream.
@immutable
class StreamError {
  /// The error type or code.
  final String error;

  /// A human-readable reason for the error.
  final String reason;

  /// Creates a [StreamError].
  const StreamError({required this.error, required this.reason});

  /// Creates a [StreamError] from JSON.
  factory StreamError.fromJson(Map<String, dynamic> json) => StreamError(
    error: json['error'] as String? ?? '',
    reason: json['reason'] as String? ?? '',
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'error': error, 'reason': reason};

  /// Creates a copy with replaced values.
  StreamError copyWith({String? error, String? reason}) {
    return StreamError(
      error: error ?? this.error,
      reason: reason ?? this.reason,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StreamError) return false;
    if (runtimeType != other.runtimeType) return false;
    return error == other.error && reason == other.reason;
  }

  @override
  int get hashCode => Object.hash(error, reason);

  @override
  String toString() => 'StreamError(error: $error, reason: $reason)';
}
