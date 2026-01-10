import 'package:meta/meta.dart' show immutable;

/// Response from detaching a function from a collection.
@immutable
class DetachFunctionResponse {
  /// Whether the detach operation was successful.
  final bool success;

  /// Creates a detach function response.
  const DetachFunctionResponse({required this.success});

  /// Creates a response from JSON.
  factory DetachFunctionResponse.fromJson(Map<String, dynamic> json) {
    return DetachFunctionResponse(success: json['success'] as bool);
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return {'success': success};
  }

  /// Creates a copy with replaced values.
  DetachFunctionResponse copyWith({bool? success}) {
    return DetachFunctionResponse(success: success ?? this.success);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetachFunctionResponse &&
          runtimeType == other.runtimeType &&
          success == other.success;

  @override
  int get hashCode => success.hashCode;

  @override
  String toString() => 'DetachFunctionResponse(success: $success)';
}
