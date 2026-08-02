import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'user_identity_api_key.dart';
import 'user_identity_organization.dart';
import 'user_identity_workspace.dart';

/// Identity of the currently authenticated user.
@immutable
class UserIdentity {
  /// Unique identifier of the user.
  final String id;

  /// Email address of the user.
  final String? email;

  /// First name of the user.
  final String? firstName;

  /// Last name of the user.
  final String? lastName;

  /// The API key used to authenticate the current request, if any.
  final UserIdentityApiKey? apiKey;

  /// The organization the user belongs to, if any.
  final UserIdentityOrganization? organization;

  /// The workspace the user belongs to, if any.
  final UserIdentityWorkspace? workspace;

  /// Creates a [UserIdentity].
  const UserIdentity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.apiKey,
    this.organization,
    this.workspace,
  });

  /// Creates a [UserIdentity] from JSON.
  ///
  /// Throws a [FormatException] if [id] is missing or null.
  factory UserIdentity.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) {
      throw FormatException('Missing or invalid "id" field: $json');
    }
    return UserIdentity(
      id: id,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      apiKey: json['api_key'] != null
          ? UserIdentityApiKey.fromJson(json['api_key'] as Map<String, dynamic>)
          : null,
      organization: json['organization'] != null
          ? UserIdentityOrganization.fromJson(
              json['organization'] as Map<String, dynamic>,
            )
          : null,
      workspace: json['workspace'] != null
          ? UserIdentityWorkspace.fromJson(
              json['workspace'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    if (apiKey != null) 'api_key': apiKey!.toJson(),
    if (organization != null) 'organization': organization!.toJson(),
    if (workspace != null) 'workspace': workspace!.toJson(),
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  UserIdentity copyWith({
    String? id,
    Object? email = unsetCopyWithValue,
    Object? firstName = unsetCopyWithValue,
    Object? lastName = unsetCopyWithValue,
    Object? apiKey = unsetCopyWithValue,
    Object? organization = unsetCopyWithValue,
    Object? workspace = unsetCopyWithValue,
  }) => UserIdentity(
    id: id ?? this.id,
    email: email == unsetCopyWithValue ? this.email : email as String?,
    firstName: firstName == unsetCopyWithValue
        ? this.firstName
        : firstName as String?,
    lastName: lastName == unsetCopyWithValue
        ? this.lastName
        : lastName as String?,
    apiKey: apiKey == unsetCopyWithValue
        ? this.apiKey
        : apiKey as UserIdentityApiKey?,
    organization: organization == unsetCopyWithValue
        ? this.organization
        : organization as UserIdentityOrganization?,
    workspace: workspace == unsetCopyWithValue
        ? this.workspace
        : workspace as UserIdentityWorkspace?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserIdentity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          apiKey == other.apiKey &&
          organization == other.organization &&
          workspace == other.workspace;

  @override
  int get hashCode => Object.hash(
    id,
    email,
    firstName,
    lastName,
    apiKey,
    organization,
    workspace,
  );

  @override
  String toString() =>
      'UserIdentity(id: $id, email: $email, firstName: $firstName, '
      'lastName: $lastName, apiKey: $apiKey, organization: $organization, '
      'workspace: $workspace)';
}
