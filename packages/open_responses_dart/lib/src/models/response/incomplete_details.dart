import 'package:meta/meta.dart';

/// Details about why a response was incomplete.
@immutable
class IncompleteDetails {
  /// The reason for incompleteness.
  final String reason;

  /// Creates an [IncompleteDetails].
  const IncompleteDetails({required this.reason});

  /// Creates an [IncompleteDetails] from JSON.
  factory IncompleteDetails.fromJson(Map<String, dynamic> json) {
    return IncompleteDetails(reason: json['reason'] as String);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'reason': reason};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncompleteDetails &&
          runtimeType == other.runtimeType &&
          reason == other.reason;

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() => 'IncompleteDetails(reason: $reason)';
}
