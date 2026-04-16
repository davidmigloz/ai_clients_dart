import 'package:meta/meta.dart';

/// Status of a trust grant on a user profile.
enum TrustGrantStatus {
  /// The trust grant is active.
  active('active'),

  /// The trust grant is pending enrollment.
  pending('pending'),

  /// The trust grant was rejected.
  rejected('rejected'),

  /// Unknown status — fallback for forward compatibility.
  unknown('unknown');

  const TrustGrantStatus(this.value);

  /// JSON value for this status.
  final String value;

  /// Parses a [TrustGrantStatus] from JSON.
  static TrustGrantStatus fromJson(String value) => switch (value) {
    'active' => TrustGrantStatus.active,
    'pending' => TrustGrantStatus.pending,
    'rejected' => TrustGrantStatus.rejected,
    _ => TrustGrantStatus.unknown,
  };

  /// Converts this status to JSON.
  String toJson() => value;
}

/// A trust grant on a user profile.
///
/// Trust grants are permissions for specific feature areas (e.g., "cyber")
/// that may be active, pending enrollment, or rejected.
@immutable
class UserProfileTrustGrant {
  /// Status of the trust grant.
  final TrustGrantStatus status;

  /// Creates a [UserProfileTrustGrant].
  const UserProfileTrustGrant({required this.status});

  /// Creates a [UserProfileTrustGrant] from JSON.
  factory UserProfileTrustGrant.fromJson(Map<String, dynamic> json) {
    return UserProfileTrustGrant(
      status: TrustGrantStatus.fromJson(json['status'] as String),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'status': status.toJson()};

  /// Creates a copy with replaced values.
  UserProfileTrustGrant copyWith({TrustGrantStatus? status}) {
    return UserProfileTrustGrant(status: status ?? this.status);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileTrustGrant &&
          runtimeType == other.runtimeType &&
          status == other.status;

  @override
  int get hashCode => status.hashCode;

  @override
  String toString() => 'UserProfileTrustGrant(status: $status)';
}
