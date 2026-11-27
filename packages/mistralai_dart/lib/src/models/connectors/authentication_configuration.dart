import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'consumer_type.dart';
import 'credentials_status.dart';
import 'outbound_authentication_type.dart';

/// A configured authentication entry for a connector.
@immutable
class AuthenticationConfiguration {
  /// The name of the credential configuration.
  final String name;

  /// The authentication mechanism.
  final OutboundAuthenticationType authenticationType;

  /// The scope at which this configuration applies.
  final ConsumerType scope;

  /// The current status of the credential.
  final CredentialsStatus? status;

  /// Whether this is the default credential for its auth method.
  final bool isDefault;

  /// An optional human-readable title for the credential.
  final String? title;

  /// Creates an [AuthenticationConfiguration].
  const AuthenticationConfiguration({
    this.creatorId,
    required this.name,
    required this.authenticationType,
    required this.scope,
    this.status,
    this.isDefault = false,
    this.title,
  });

  /// Creates an [AuthenticationConfiguration] from JSON.
  factory AuthenticationConfiguration.fromJson(Map<String, dynamic> json) =>
      AuthenticationConfiguration(
        creatorId: json['creator_id'] as String?,
        name: json['name'] as String? ?? '',
        authenticationType: OutboundAuthenticationType.fromJson(
          json['authentication_type'] as String?,
        ),
        scope: ConsumerType.fromJson(json['scope'] as String?),
        status: json['status'] != null
            ? CredentialsStatus.fromJson(json['status'] as Map<String, dynamic>)
            : null,
        isDefault: json['is_default'] as bool? ?? false,
        title: json['title'] as String?,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    if (creatorId != null) 'creator_id': creatorId,
    'name': name,
    'authentication_type': authenticationType.toJson(),
    'scope': scope.toJson(),
    if (status != null) 'status': status!.toJson(),
    'is_default': isDefault,
    if (title != null) 'title': title,
  };

  /// Identifier of the principal that configured the credential.
  final String? creatorId;

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  AuthenticationConfiguration copyWith({
    Object? creatorId = unsetCopyWithValue,
    String? name,
    OutboundAuthenticationType? authenticationType,
    ConsumerType? scope,
    Object? status = unsetCopyWithValue,
    bool? isDefault,
    Object? title = unsetCopyWithValue,
  }) => AuthenticationConfiguration(
    creatorId: creatorId == unsetCopyWithValue
        ? this.creatorId
        : creatorId as String?,
    name: name ?? this.name,
    authenticationType: authenticationType ?? this.authenticationType,
    scope: scope ?? this.scope,
    status: status == unsetCopyWithValue
        ? this.status
        : status as CredentialsStatus?,
    isDefault: isDefault ?? this.isDefault,
    title: title == unsetCopyWithValue ? this.title : title as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthenticationConfiguration &&
          creatorId == other.creatorId &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          authenticationType == other.authenticationType &&
          scope == other.scope &&
          status == other.status &&
          isDefault == other.isDefault &&
          title == other.title;

  @override
  int get hashCode => Object.hashAll([
    name,
    authenticationType,
    scope,
    status,
    isDefault,
    title,
    creatorId,
  ]);

  @override
  String toString() =>
      'AuthenticationConfiguration(creatorId: $creatorId, '
      'name: $name, '
      'authenticationType: $authenticationType, '
      'scope: $scope, '
      'status: $status, '
      'isDefault: $isDefault, '
      'title: $title)';
}
