import 'package:meta/meta.dart';

/// An error that occurred during batch processing.
@immutable
class BatchError {
  /// Error code.
  final String? code;

  /// Error message.
  final String? message;

  /// Number of occurrences.
  final int? count;

  /// Creates a [BatchError].
  const BatchError({this.code, this.message, this.count});

  /// Creates a [BatchError] from JSON.
  factory BatchError.fromJson(Map<String, dynamic> json) => BatchError(
    code: json['code'] as String?,
    message: json['message'] as String?,
    count: json['count'] as int?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (code != null) 'code': code,
    if (message != null) 'message': message,
    if (count != null) 'count': count,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          count == other.count;

  @override
  int get hashCode => Object.hash(code, message, count);

  @override
  String toString() => 'BatchError(code: $code, message: $message)';
}
