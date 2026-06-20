import 'package:meta/meta.dart';

/// A simple message response returned by several connector operations.
@immutable
class MessageResponse {
  /// The human-readable message.
  final String message;

  /// Creates a [MessageResponse].
  const MessageResponse({required this.message});

  /// Creates a [MessageResponse] from JSON.
  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      MessageResponse(message: json['message'] as String? ?? '');

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() => {'message': message};

  /// Creates a copy with the given fields replaced.
  MessageResponse copyWith({String? message}) =>
      MessageResponse(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageResponse &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'MessageResponse(message: $message)';
}
