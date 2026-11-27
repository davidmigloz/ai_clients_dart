import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// An organization the authenticated user belongs to.
@immutable
class UserOrganization {
  /// Creates a [UserOrganization].
  const UserOrganization({required this.id, required this.name});

  /// The organization's unique identifier.
  final String id;

  /// The organization's display name.
  final String name;

  /// Parses a [UserOrganization] from JSON.
  factory UserOrganization.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw const FormatException('UserOrganization: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('UserOrganization: missing name');
    }
    return UserOrganization(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  /// Creates a copy with the given fields replaced.
  UserOrganization copyWith({String? id, String? name}) =>
      UserOrganization(id: id ?? this.id, name: name ?? this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserOrganization &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([id, name]);

  @override
  String toString() =>
      'UserOrganization('
      'id: $id, '
      'name: $name)';
}

/// A workspace the authenticated user belongs to.
@immutable
class UserWorkspace {
  /// Creates a [UserWorkspace].
  const UserWorkspace({
    required this.id,
    required this.name,
    required this.organizationId,
  });

  /// The workspace's unique identifier.
  final String id;

  /// The workspace's display name.
  final String name;

  /// The identifier of the organization this workspace belongs to.
  final String organizationId;

  /// Parses a [UserWorkspace] from JSON.
  factory UserWorkspace.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw const FormatException('UserWorkspace: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('UserWorkspace: missing name');
    }
    if (json['organization_id'] == null) {
      throw const FormatException('UserWorkspace: missing organization_id');
    }
    return UserWorkspace(
      id: json['id'] as String,
      name: json['name'] as String,
      organizationId: json['organization_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'organization_id': organizationId,
  };

  /// Creates a copy with the given fields replaced.
  UserWorkspace copyWith({String? id, String? name, String? organizationId}) =>
      UserWorkspace(
        id: id ?? this.id,
        name: name ?? this.name,
        organizationId: organizationId ?? this.organizationId,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserWorkspace &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          organizationId == other.organizationId;

  @override
  int get hashCode => Object.hashAll([id, name, organizationId]);

  @override
  String toString() =>
      'UserWorkspace('
      'id: $id, '
      'name: $name, '
      'organizationId: $organizationId)';
}

/// An offset-paginated page of user organizations.
@immutable
class UserOrganizations {
  /// Creates a [UserOrganizations].
  const UserOrganizations({required this.organizations});

  /// The organizations the authenticated user is a member of.
  final List<UserOrganization> organizations;

  /// Parses a [UserOrganizations] from JSON.
  factory UserOrganizations.fromJson(Map<String, dynamic> json) {
    if (json['organizations'] == null) {
      throw const FormatException('UserOrganizations: missing organizations');
    }
    return UserOrganizations(
      organizations: (json['organizations'] as List)
          .map(
            (item) => UserOrganization.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'organizations': organizations.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  UserOrganizations copyWith({List<UserOrganization>? organizations}) =>
      UserOrganizations(organizations: organizations ?? this.organizations);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserOrganizations &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(organizations, other.organizations);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(organizations)]);

  @override
  String toString() =>
      'UserOrganizations('
      'organizations: ${organizations.length})';
}

/// An offset-paginated page of user workspaces.
@immutable
class UserWorkspaces {
  /// Creates a [UserWorkspaces].
  const UserWorkspaces({required this.workspaces});

  /// The workspaces the authenticated user is a member of, each tagged with the organization it belongs to.
  final List<UserWorkspace> workspaces;

  /// Parses a [UserWorkspaces] from JSON.
  factory UserWorkspaces.fromJson(Map<String, dynamic> json) {
    if (json['workspaces'] == null) {
      throw const FormatException('UserWorkspaces: missing workspaces');
    }
    return UserWorkspaces(
      workspaces: (json['workspaces'] as List)
          .map((item) => UserWorkspace.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'workspaces': workspaces.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  UserWorkspaces copyWith({List<UserWorkspace>? workspaces}) =>
      UserWorkspaces(workspaces: workspaces ?? this.workspaces);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserWorkspaces &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(workspaces, other.workspaces);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(workspaces)]);

  @override
  String toString() =>
      'UserWorkspaces('
      'workspaces: ${workspaces.length})';
}
