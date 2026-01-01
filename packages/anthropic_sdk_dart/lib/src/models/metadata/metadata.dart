import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Metadata about the request.
@immutable
class Metadata {
  /// An external identifier for the user who is associated with the request.
  ///
  /// This should be a uuid, hash value, or other opaque identifier.
  /// Anthropic may use this id to help detect abuse.
  /// Do not include any identifying information such as name, email address,
  /// or phone number.
  final String? userId;

  /// Creates a [Metadata].
  const Metadata({this.userId});

  /// Creates a [Metadata] from JSON.
  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(userId: json['user_id'] as String?);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (userId != null) 'user_id': userId};

  /// Creates a copy with replaced values.
  Metadata copyWith({Object? userId = unsetCopyWithValue}) {
    return Metadata(
      userId: userId == unsetCopyWithValue ? this.userId : userId as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Metadata &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() => 'Metadata(userId: $userId)';
}
