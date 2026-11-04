import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Error information from a failed response or nested streaming error.
///
/// OpenResponses requires a string type in its streaming error payload. Nullable
/// type is accepted for OpenAI-compatible provider errors without replacing it
/// with a synthetic value. Omitted type retains the legacy 'error' read default,
/// with absence recorded by [hasType]. Optional presence flags preserve explicit
/// null code/param. Parsed and copied header maps are immutable; const constructor
/// header collections remain caller-owned for compatibility.
@immutable
class ErrorPayload {
  /// The original error type, or null when the provider recorded no type.
  final String? type;

  /// The error code, when recorded.
  final String? code;

  /// The error message.
  final String message;

  /// The parameter associated with the error.
  final String? param;

  /// Optional response headers.
  final Map<String, String>? headers;

  /// Whether type was present, including a provider's explicit null.
  final bool hasType;

  /// Whether code was present, including explicit null.
  final bool hasCode;

  /// Whether param was present, including explicit null.
  final bool hasParam;

  /// Creates an error while preserving const construction.
  const ErrorPayload({
    required this.type,
    this.code,
    required this.message,
    this.param,
    this.headers,
    this.hasType = true,
    bool? hasCode,
    bool? hasParam,
  }) : hasCode = hasCode ?? code != null,
       hasParam = hasParam ?? param != null;

  /// Parses exact nullable presence without normalizing an explicit null type.
  factory ErrorPayload.fromJson(Map<String, dynamic> json) {
    Map<String, String>? headers;
    if (json.containsKey('headers')) {
      final raw = json['headers'];
      if (raw is! Map<String, dynamic> || raw.values.any((v) => v is! String)) {
        throw const FormatException(
          'ErrorPayload.headers: expected string map',
        );
      }
      headers = Map<String, String>.unmodifiable(raw.cast<String, String>());
    }
    final message = json['message'];
    if (message is! String) {
      throw const FormatException('ErrorPayload.message: expected string');
    }
    String? nullableString(String key) {
      final value = json[key];
      if (value != null && value is! String) {
        throw FormatException('ErrorPayload.$key: expected string or null');
      }
      return value as String?;
    }

    return ErrorPayload(
      type: json.containsKey('type') ? nullableString('type') : 'error',
      code: nullableString('code'),
      message: message,
      param: nullableString('param'),
      headers: headers,
      hasType: json.containsKey('type'),
      hasCode: json.containsKey('code'),
      hasParam: json.containsKey('param'),
    );
  }

  /// Converts to JSON without dropping explicit nullable fields.
  Map<String, dynamic> toJson() => {
    if (hasType) 'type': type,
    if (hasCode) 'code': code,
    'message': message,
    if (hasParam) 'param': param,
    if (headers != null) 'headers': Map<String, String>.from(headers!),
  };

  /// Copies fields; explicit null retains a nullable key. Set its presence flag
  /// false as well to omit it. Replaced headers are snapshotted.
  ErrorPayload copyWith({
    Object? type = unsetCopyWithValue,
    Object? code = unsetCopyWithValue,
    String? message,
    Object? param = unsetCopyWithValue,
    Object? headers = unsetCopyWithValue,
    bool? hasType,
    bool? hasCode,
    bool? hasParam,
  }) {
    final newHeaders = identical(headers, unsetCopyWithValue)
        ? this.headers
        : headers as Map<String, String>?;
    return ErrorPayload(
      type: identical(type, unsetCopyWithValue) ? this.type : type as String?,
      code: identical(code, unsetCopyWithValue) ? this.code : code as String?,
      message: message ?? this.message,
      param: identical(param, unsetCopyWithValue)
          ? this.param
          : param as String?,
      headers: newHeaders == null
          ? null
          : Map<String, String>.unmodifiable(newHeaders),
      hasType:
          hasType ?? (!identical(type, unsetCopyWithValue) || this.hasType),
      hasCode:
          hasCode ?? (!identical(code, unsetCopyWithValue) || this.hasCode),
      hasParam:
          hasParam ?? (!identical(param, unsetCopyWithValue) || this.hasParam),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ErrorPayload &&
      runtimeType == other.runtimeType &&
      type == other.type &&
      code == other.code &&
      message == other.message &&
      param == other.param &&
      mapsEqual(headers, other.headers) &&
      hasType == other.hasType &&
      hasCode == other.hasCode &&
      hasParam == other.hasParam;

  @override
  int get hashCode => Object.hash(
    type,
    code,
    message,
    param,
    mapHash(headers),
    hasType,
    hasCode,
    hasParam,
  );

  @override
  String toString() =>
      'ErrorPayload(type: [REDACTED], code: [REDACTED], message: [REDACTED], param: [REDACTED], headers: ${headers == null ? null : "${headers!.length} entries"}, hasType: $hasType, hasCode: $hasCode, hasParam: $hasParam)';
}
