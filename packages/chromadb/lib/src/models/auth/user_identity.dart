import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';
import '../../utils/equality_helpers.dart';

/// Response from the auth identity endpoint.
///
/// Contains information about the current authenticated user,
/// including their tenant and accessible databases.
@immutable
class UserIdentity {
  /// The user's unique identifier.
  final String? userId;

  /// The tenant associated with this user.
  final String? tenant;

  /// The databases this user has access to.
  final List<String>? databases;

  /// Creates a user identity.
  const UserIdentity({this.userId, this.tenant, this.databases});

  /// Creates a user identity from JSON.
  factory UserIdentity.fromJson(Map<String, dynamic> json) {
    return UserIdentity(
      userId: json['user_id'] as String?,
      tenant: json['tenant'] as String?,
      databases: (json['databases'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Converts this identity to JSON.
  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      if (tenant != null) 'tenant': tenant,
      if (databases != null) 'databases': databases,
    };
  }

  /// Creates a copy of this identity with optional modifications.
  UserIdentity copyWith({
    Object? userId = unsetCopyWithValue,
    Object? tenant = unsetCopyWithValue,
    Object? databases = unsetCopyWithValue,
  }) {
    return UserIdentity(
      userId: userId == unsetCopyWithValue ? this.userId : userId as String?,
      tenant: tenant == unsetCopyWithValue ? this.tenant : tenant as String?,
      databases: databases == unsetCopyWithValue
          ? this.databases
          : databases as List<String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserIdentity &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          tenant == other.tenant &&
          listsEqual(databases, other.databases);

  @override
  int get hashCode => Object.hash(
    userId,
    tenant,
    databases == null ? null : Object.hashAll(databases!),
  );

  @override
  String toString() =>
      'UserIdentity(userId: $userId, tenant: $tenant, databases: $databases)';
}
