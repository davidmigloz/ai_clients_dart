import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Details the platform supplied about the end customer.
@immutable
class UserProfileExternalUserDetails {
  /// The platform’s own reference for the end customer.
  final String? referenceId;

  /// When the end customer opened their account.
  final DateTime? onboardedAt;

  /// The platform account status, such as active, suspended or blocked.
  final String? accountStatus;

  /// Entity kind, such as individual, business, non_profit or government.
  final String? entityType;

  /// ISO 3166-1 alpha-2 country code.
  final String? country;

  /// The hash of the entity’s name.
  final String? nameHash;

  /// The hash of the entity’s email address.
  final String? emailHash;

  /// Creates a [UserProfileExternalUserDetails].
  const UserProfileExternalUserDetails({
    this.referenceId,
    this.onboardedAt,
    this.accountStatus,
    this.entityType,
    this.country,
    this.nameHash,
    this.emailHash,
  });

  /// Parses a [UserProfileExternalUserDetails] from JSON.
  factory UserProfileExternalUserDetails.fromJson(Map<String, dynamic> json) {
    final onboardedAtJson = json['onboarded_at'] as String?;
    return UserProfileExternalUserDetails(
      referenceId: json['reference_id'] as String?,
      onboardedAt: onboardedAtJson == null
          ? null
          : DateTime.parse(onboardedAtJson),
      accountStatus: json['account_status'] as String?,
      entityType: json['entity_type'] as String?,
      country: json['country'] as String?,
      nameHash: json['name_hash'] as String?,
      emailHash: json['email_hash'] as String?,
    );
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'reference_id': referenceId,
    'onboarded_at': onboardedAt?.toUtc().toIso8601String(),
    'account_status': accountStatus,
    'entity_type': entityType,
    'country': country,
    'name_hash': nameHash,
    'email_hash': emailHash,
  };

  /// Creates a copy with replaced values.
  UserProfileExternalUserDetails copyWith({
    Object? referenceId = unsetCopyWithValue,
    Object? onboardedAt = unsetCopyWithValue,
    Object? accountStatus = unsetCopyWithValue,
    Object? entityType = unsetCopyWithValue,
    Object? country = unsetCopyWithValue,
    Object? nameHash = unsetCopyWithValue,
    Object? emailHash = unsetCopyWithValue,
  }) => UserProfileExternalUserDetails(
    referenceId: referenceId == unsetCopyWithValue
        ? this.referenceId
        : referenceId as String?,
    onboardedAt: onboardedAt == unsetCopyWithValue
        ? this.onboardedAt
        : onboardedAt as DateTime?,
    accountStatus: accountStatus == unsetCopyWithValue
        ? this.accountStatus
        : accountStatus as String?,
    entityType: entityType == unsetCopyWithValue
        ? this.entityType
        : entityType as String?,
    country: country == unsetCopyWithValue ? this.country : country as String?,
    nameHash: nameHash == unsetCopyWithValue
        ? this.nameHash
        : nameHash as String?,
    emailHash: emailHash == unsetCopyWithValue
        ? this.emailHash
        : emailHash as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is UserProfileExternalUserDetails &&
      referenceId == other.referenceId &&
      onboardedAt == other.onboardedAt &&
      accountStatus == other.accountStatus &&
      entityType == other.entityType &&
      country == other.country &&
      nameHash == other.nameHash &&
      emailHash == other.emailHash;

  @override
  int get hashCode => Object.hashAll([
    referenceId,
    onboardedAt,
    accountStatus,
    entityType,
    country,
    nameHash,
    emailHash,
  ]);

  @override
  String toString() => 'UserProfileExternalUserDetails()';

  /// Parses details for a create or update request.
  ///
  /// With [updating], a stored detail cannot be cleared with null.
  /// A null `onboarded_at` is invalid for both operations. Other null
  /// values on create are treated as omitted.
  factory UserProfileExternalUserDetails.fromRequestJson(
    Map<String, dynamic> json, {
    bool updating = false,
  }) {
    for (final key in const [
      'reference_id',
      'onboarded_at',
      'account_status',
      'entity_type',
      'country',
      'name_hash',
      'email_hash',
    ]) {
      if ((updating || key == 'onboarded_at') &&
          json.containsKey(key) &&
          json[key] == null) {
        throw FormatException('external_user_details.$key cannot be null');
      }
    }
    return UserProfileExternalUserDetails.fromJson(json);
  }

  /// Serializes a request, omitting all unset details.
  Map<String, dynamic> toRequestJson() => {
    if (referenceId != null) 'reference_id': referenceId,
    if (onboardedAt != null)
      'onboarded_at': onboardedAt!.toUtc().toIso8601String(),
    if (accountStatus != null) 'account_status': accountStatus,
    if (entityType != null) 'entity_type': entityType,
    if (country != null) 'country': country,
    if (nameHash != null) 'name_hash': nameHash,
    if (emailHash != null) 'email_hash': emailHash,
  };
}
