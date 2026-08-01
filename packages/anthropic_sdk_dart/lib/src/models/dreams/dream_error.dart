import 'package:meta/meta.dart';

/// Failure detail for a Dream whose `status` is `failed`.
@immutable
class DreamError {
  /// Machine-readable error type.
  final String type;

  /// Human-readable error message.
  final String message;

  /// Creates a [DreamError].
  const DreamError({required this.type, required this.message});

  /// Creates a [DreamError] from JSON.
  factory DreamError.fromJson(Map<String, dynamic> json) {
    return DreamError(
      type: json['type'] as String,
      message: json['message'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'message': message};

  /// Creates a copy with replaced values.
  DreamError copyWith({String? type, String? message}) {
    return DreamError(
      type: type ?? this.type,
      message: message ?? this.message,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DreamError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message;

  @override
  int get hashCode => Object.hash(type, message);

  @override
  String toString() => 'DreamError(type: $type, message: $message)';
}
