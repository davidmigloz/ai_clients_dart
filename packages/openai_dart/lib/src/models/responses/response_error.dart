import 'package:meta/meta.dart';

/// Error details for a failed response.
@immutable
class ResponseError {
  /// The error code.
  final String code;

  /// The error message.
  final String message;

  /// Creates a [ResponseError].
  const ResponseError({required this.code, required this.message});

  /// Creates a [ResponseError] from JSON.
  factory ResponseError.fromJson(Map<String, dynamic> json) {
    return ResponseError(
      code: json['code'] as String,
      message: json['message'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'code': code, 'message': message};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message;

  @override
  int get hashCode => Object.hash(code, message);

  @override
  String toString() => 'ResponseError(code: $code, message: $message)';
}
