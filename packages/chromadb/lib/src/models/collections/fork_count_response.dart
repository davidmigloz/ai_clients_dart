import 'package:meta/meta.dart';

/// Response containing the fork count for a collection.
@immutable
class ForkCountResponse {
  /// The number of forks for this collection.
  final int count;

  /// Creates a fork count response.
  const ForkCountResponse({required this.count});

  /// Creates a fork count response from JSON.
  factory ForkCountResponse.fromJson(Map<String, dynamic> json) {
    return ForkCountResponse(count: json['count'] as int);
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() => {'count': count};

  /// Creates a copy of this response with optional modifications.
  ForkCountResponse copyWith({int? count}) {
    return ForkCountResponse(count: count ?? this.count);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForkCountResponse &&
          runtimeType == other.runtimeType &&
          count == other.count;

  @override
  int get hashCode => count.hashCode;

  @override
  String toString() => 'ForkCountResponse(count: $count)';
}
