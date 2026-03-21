import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Error details for a failed response.
@immutable
class ResponseError {
  /// The error type (e.g., `'server_error'`, `'invalid_request_error'`).
  final String type;

  /// The error code, if any.
  final String? code;

  /// The error message.
  final String message;

  /// The parameter associated with the error, if any.
  final String? param;

  /// Creates a [ResponseError].
  const ResponseError({
    required this.type,
    this.code,
    required this.message,
    this.param,
  });

  /// Creates a [ResponseError] from JSON.
  ///
  /// This follows the OpenAI / OpenResponses error payload shape where
  /// `message` is required, `type` may be omitted and defaults to `'error'`,
  /// and `code` / `param` may be null or absent.
  factory ResponseError.fromJson(Map<String, dynamic> json) {
    return ResponseError(
      type: json['type'] as String? ?? 'error',
      code: json['code'] as String?,
      message: json['message'] as String,
      param: json['param'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (code != null) 'code': code,
    'message': message,
    if (param != null) 'param': param,
  };

  /// Creates a copy with replaced values.
  ResponseError copyWith({
    String? type,
    Object? code = unsetCopyWithValue,
    String? message,
    Object? param = unsetCopyWithValue,
  }) {
    return ResponseError(
      type: type ?? this.type,
      code: code == unsetCopyWithValue ? this.code : code as String?,
      message: message ?? this.message,
      param: param == unsetCopyWithValue ? this.param : param as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          code == other.code &&
          message == other.message &&
          param == other.param;

  @override
  int get hashCode => Object.hash(type, code, message, param);

  @override
  String toString() =>
      'ResponseError(type: $type, code: $code, message: $message, param: $param)';
}
