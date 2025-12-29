import 'package:meta/meta.dart';

/// Error response from the Ollama API.
@immutable
class ErrorResponse {
  /// Error message describing what went wrong.
  final String? error;

  /// Creates an [ErrorResponse].
  const ErrorResponse({this.error});

  /// Creates an [ErrorResponse] from JSON.
  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      ErrorResponse(error: json['error'] as String?);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (error != null) 'error': error};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorResponse &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'ErrorResponse(error: $error)';
}
