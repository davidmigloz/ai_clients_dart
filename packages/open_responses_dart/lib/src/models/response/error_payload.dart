import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Error information from a failed response.
@immutable
class ErrorPayload {
  /// The error type.
  final String type;

  /// The error code (can be null).
  final String? code;

  /// The error message.
  final String message;

  /// The parameter associated with the error (can be null).
  final String? param;

  /// Response headers from the error, if any.
  ///
  /// **Note:** This is an extension field not present in the official
  /// OpenResponses spec. It is included for compatibility with providers
  /// that include headers in error responses.
  final Map<String, String>? headers;

  /// Creates an [ErrorPayload].
  const ErrorPayload({
    required this.type,
    this.code,
    required this.message,
    this.param,
    this.headers,
  });

  /// Creates an [ErrorPayload] from JSON.
  ///
  /// While the spec requires `type`, some providers may omit it in certain
  /// error responses (e.g., streaming rate limit errors). In such cases,
  /// defaults to `'error'`.
  factory ErrorPayload.fromJson(Map<String, dynamic> json) {
    return ErrorPayload(
      type: json['type'] as String? ?? 'error',
      code: json['code'] as String?,
      message: json['message'] as String,
      param: json['param'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (code != null) 'code': code,
    'message': message,
    if (param != null) 'param': param,
    if (headers != null) 'headers': headers,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorPayload &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          code == other.code &&
          message == other.message &&
          param == other.param &&
          mapsEqual(headers, other.headers);

  @override
  int get hashCode => Object.hash(type, code, message, param, headers);

  @override
  String toString() =>
      'ErrorPayload(type: $type, code: $code, message: $message, param: $param, headers: $headers)';
}
