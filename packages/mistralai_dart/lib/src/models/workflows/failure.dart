import 'package:meta/meta.dart';

/// A failure description.
@immutable
class Failure {
  /// The failure message.
  final String message;

  /// Creates a [Failure].
  const Failure({required this.message});

  /// Creates a [Failure] from JSON.
  factory Failure.fromJson(Map<String, dynamic> json) =>
      Failure(message: json['message'] as String? ?? '');

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'message': message};

  /// Creates a copy with replaced values.
  Failure copyWith({String? message}) {
    return Failure(message: message ?? this.message);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Failure) return false;
    if (runtimeType != other.runtimeType) return false;
    return message == other.message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'Failure(message: $message)';
}
