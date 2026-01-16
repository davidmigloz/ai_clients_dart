import 'package:meta/meta.dart';

/// Error information from a failed response.
@immutable
class ErrorPayload {
  /// The error code.
  final String code;

  /// The error message.
  final String message;

  /// Creates an [ErrorPayload].
  const ErrorPayload({required this.code, required this.message});

  /// Creates an [ErrorPayload] from JSON.
  factory ErrorPayload.fromJson(Map<String, dynamic> json) {
    return ErrorPayload(
      code: json['code'] as String,
      message: json['message'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'code': code, 'message': message};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorPayload &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message;

  @override
  int get hashCode => Object.hash(code, message);

  @override
  String toString() => 'ErrorPayload(code: $code, message: $message)';
}
