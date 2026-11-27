import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/deep_unmodifiable_json.dart';
import '../common/equality_helpers.dart';
import 'user_identity_workspace.dart';

/// The authenticated principal returned by the identity endpoint.
///
/// [WhoamiUserPrincipal], [WhoamiServiceAccountPrincipal], or [UnknownWhoamiPrincipal].
@immutable
sealed class WhoamiPrincipal {
  const WhoamiPrincipal();

  /// Parses an API payload.
  factory WhoamiPrincipal.fromJson(Map<String, dynamic> json) =>
      switch (json['principal_type']) {
        'user' => WhoamiUserPrincipal.fromJson(json),
        'service_account' => WhoamiServiceAccountPrincipal.fromJson(json),
        _ => UnknownWhoamiPrincipal(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future WhoamiPrincipal value.
@immutable
final class UnknownWhoamiPrincipal extends WhoamiPrincipal {
  /// Creates a fallback from the original payload.
  UnknownWhoamiPrincipal(Map<String, dynamic> json)
    : raw = deepUnmodifiableJson(json)! as Map<String, dynamic>;

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownWhoamiPrincipal && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// Principal identity and session context for the authenticated caller.
@immutable
class WhoamiResponse {
  /// Creates a [WhoamiResponse].
  const WhoamiResponse({
    this.customerId,
    this.organization,
    required this.principal,
    this.workspace,
  });

  /// The billing customer identifier from the authenticated session. Identifies the billing account, not the organization (organization.id); the IDs are not interchangeable. Null when no customer is selected.
  final String? customerId;

  /// The organization the caller's session is scoped to, when set.
  final WhoamiOrganization? organization;

  /// The authenticated principal: either a user or a service account.
  final WhoamiPrincipal principal;

  /// The workspace the caller's session is scoped to, when set.
  final UserIdentityWorkspace? workspace;

  /// Parses a [WhoamiResponse] from JSON.
  factory WhoamiResponse.fromJson(Map<String, dynamic> json) {
    if (json['principal'] == null) {
      throw const FormatException('WhoamiResponse: missing principal');
    }
    return WhoamiResponse(
      customerId: json['customer_id'] == null
          ? null
          : json['customer_id'] as String,
      organization: json['organization'] == null
          ? null
          : WhoamiOrganization.fromJson(
              json['organization'] as Map<String, dynamic>,
            ),
      principal: WhoamiPrincipal.fromJson(
        json['principal'] as Map<String, dynamic>,
      ),
      workspace: json['workspace'] == null
          ? null
          : UserIdentityWorkspace.fromJson(
              json['workspace'] as Map<String, dynamic>,
            ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'customer_id': ?customerId,
    if (organization != null) 'organization': organization!.toJson(),
    'principal': principal.toJson(),
    if (workspace != null) 'workspace': workspace!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  WhoamiResponse copyWith({
    Object? customerId = unsetCopyWithValue,
    Object? organization = unsetCopyWithValue,
    WhoamiPrincipal? principal,
    Object? workspace = unsetCopyWithValue,
  }) => WhoamiResponse(
    customerId: customerId == unsetCopyWithValue
        ? this.customerId
        : customerId as String?,
    organization: organization == unsetCopyWithValue
        ? this.organization
        : organization as WhoamiOrganization?,
    principal: principal ?? this.principal,
    workspace: workspace == unsetCopyWithValue
        ? this.workspace
        : workspace as UserIdentityWorkspace?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WhoamiResponse &&
          runtimeType == other.runtimeType &&
          customerId == other.customerId &&
          organization == other.organization &&
          principal == other.principal &&
          workspace == other.workspace;

  @override
  int get hashCode =>
      Object.hashAll([customerId, organization, principal, workspace]);

  @override
  String toString() =>
      'WhoamiResponse('
      'customerId: $customerId, '
      'organization: $organization, '
      'principal: $principal, '
      'workspace: $workspace)';
}

/// Organization identity and context for the authenticated caller.
@immutable
class WhoamiOrganization {
  /// Creates a [WhoamiOrganization].
  const WhoamiOrganization({
    required this.id,
    this.internal,
    this.kind,
    required this.name,
    this.orgTier,
  });

  /// The organization's unique identifier.
  final String id;

  /// Whether this is a Mistral-internal organization.
  final bool? internal;

  /// The organization kind (e.g. 'S' standard, 'C' company internal, 'D' dogfooding).
  final String? kind;

  /// The organization's display name.
  final String name;

  /// The organization's billing tier (e.g. 'E' for Enterprise). Null when not set.
  final String? orgTier;

  /// Parses a [WhoamiOrganization] from JSON.
  factory WhoamiOrganization.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw const FormatException('WhoamiOrganization: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('WhoamiOrganization: missing name');
    }
    return WhoamiOrganization(
      id: json['id'] as String,
      internal: json['internal'] == null ? null : json['internal'] as bool,
      kind: json['kind'] == null ? null : json['kind'] as String,
      name: json['name'] as String,
      orgTier: json['org_tier'] == null ? null : json['org_tier'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'id': id,
    'internal': ?internal,
    'kind': ?kind,
    'name': name,
    'org_tier': ?orgTier,
  };

  /// Creates a copy with the given fields replaced.
  WhoamiOrganization copyWith({
    String? id,
    Object? internal = unsetCopyWithValue,
    Object? kind = unsetCopyWithValue,
    String? name,
    Object? orgTier = unsetCopyWithValue,
  }) => WhoamiOrganization(
    id: id ?? this.id,
    internal: internal == unsetCopyWithValue
        ? this.internal
        : internal as bool?,
    kind: kind == unsetCopyWithValue ? this.kind : kind as String?,
    name: name ?? this.name,
    orgTier: orgTier == unsetCopyWithValue ? this.orgTier : orgTier as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WhoamiOrganization &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          internal == other.internal &&
          kind == other.kind &&
          name == other.name &&
          orgTier == other.orgTier;

  @override
  int get hashCode => Object.hashAll([id, internal, kind, name, orgTier]);

  @override
  String toString() =>
      'WhoamiOrganization('
      'id: $id, '
      'internal: $internal, '
      'kind: $kind, '
      'name: $name, '
      'orgTier: $orgTier)';
}

/// Identity and profile fields for a human user principal.
@immutable
class WhoamiUserPrincipal extends WhoamiPrincipal {
  /// Creates a [WhoamiUserPrincipal].
  const WhoamiUserPrincipal({
    this.email,
    this.firstName,
    required this.id,
    this.lastName,
  });

  /// The fixed principal_type discriminator.
  String get principalType => 'user';

  /// The user's email address, when known.
  final String? email;

  /// The user's first name, when known.
  final String? firstName;

  /// The user's unique identifier.
  final String id;

  /// The user's last name, when known.
  final String? lastName;

  /// Parses a [WhoamiUserPrincipal] from JSON.
  factory WhoamiUserPrincipal.fromJson(Map<String, dynamic> json) {
    if (json['principal_type'] case final value? when value != 'user') {
      throw FormatException(
        'WhoamiUserPrincipal: unexpected principal_type $value',
      );
    }
    if (json['id'] == null) {
      throw const FormatException('WhoamiUserPrincipal: missing id');
    }
    return WhoamiUserPrincipal(
      email: json['email'] == null ? null : json['email'] as String,
      firstName: json['first_name'] == null
          ? null
          : json['first_name'] as String,
      id: json['id'] as String,
      lastName: json['last_name'] == null ? null : json['last_name'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'principal_type': principalType,
    'email': ?email,
    'first_name': ?firstName,
    'id': id,
    'last_name': ?lastName,
  };

  /// Creates a copy with the given fields replaced.
  WhoamiUserPrincipal copyWith({
    Object? email = unsetCopyWithValue,
    Object? firstName = unsetCopyWithValue,
    String? id,
    Object? lastName = unsetCopyWithValue,
  }) => WhoamiUserPrincipal(
    email: email == unsetCopyWithValue ? this.email : email as String?,
    firstName: firstName == unsetCopyWithValue
        ? this.firstName
        : firstName as String?,
    id: id ?? this.id,
    lastName: lastName == unsetCopyWithValue
        ? this.lastName
        : lastName as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WhoamiUserPrincipal &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          firstName == other.firstName &&
          id == other.id &&
          lastName == other.lastName;

  @override
  int get hashCode => Object.hashAll([email, firstName, id, lastName]);

  @override
  String toString() =>
      'WhoamiUserPrincipal('
      'email: $email, '
      'firstName: $firstName, '
      'id: $id, '
      'lastName: $lastName)';
}

/// Identity and display name for a service account principal.
@immutable
class WhoamiServiceAccountPrincipal extends WhoamiPrincipal {
  /// Creates a [WhoamiServiceAccountPrincipal].
  const WhoamiServiceAccountPrincipal({
    this.name,
    required this.serviceAccountId,
  });

  /// The fixed principal_type discriminator.
  String get principalType => 'service_account';

  /// The service account's display name, when known.
  final String? name;

  /// The service account's unique identifier.
  final String serviceAccountId;

  /// Parses a [WhoamiServiceAccountPrincipal] from JSON.
  factory WhoamiServiceAccountPrincipal.fromJson(Map<String, dynamic> json) {
    if (json['principal_type'] case final value?
        when value != 'service_account') {
      throw FormatException(
        'WhoamiServiceAccountPrincipal: unexpected principal_type $value',
      );
    }
    if (json['service_account_id'] == null) {
      throw const FormatException(
        'WhoamiServiceAccountPrincipal: missing service_account_id',
      );
    }
    return WhoamiServiceAccountPrincipal(
      name: json['name'] == null ? null : json['name'] as String,
      serviceAccountId: json['service_account_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'principal_type': principalType,
    'name': ?name,
    'service_account_id': serviceAccountId,
  };

  /// Creates a copy with the given fields replaced.
  WhoamiServiceAccountPrincipal copyWith({
    Object? name = unsetCopyWithValue,
    String? serviceAccountId,
  }) => WhoamiServiceAccountPrincipal(
    name: name == unsetCopyWithValue ? this.name : name as String?,
    serviceAccountId: serviceAccountId ?? this.serviceAccountId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WhoamiServiceAccountPrincipal &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          serviceAccountId == other.serviceAccountId;

  @override
  int get hashCode => Object.hashAll([name, serviceAccountId]);

  @override
  String toString() =>
      'WhoamiServiceAccountPrincipal('
      'name: $name, '
      'serviceAccountId: $serviceAccountId)';
}
