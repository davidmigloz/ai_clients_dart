import 'package:meta/meta.dart';

/// Response for a workflow signal.
@immutable
class SignalWorkflowResponse {
  /// The response message.
  final String message;

  /// Creates a [SignalWorkflowResponse].
  const SignalWorkflowResponse({this.message = 'Signal accepted'});

  /// Creates a [SignalWorkflowResponse] from JSON.
  factory SignalWorkflowResponse.fromJson(Map<String, dynamic> json) =>
      SignalWorkflowResponse(
        message: json['message'] as String? ?? 'Signal accepted',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'message': message};

  /// Creates a copy with replaced values.
  SignalWorkflowResponse copyWith({String? message}) {
    return SignalWorkflowResponse(message: message ?? this.message);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignalWorkflowResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return message == other.message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'SignalWorkflowResponse(message: $message)';
}
