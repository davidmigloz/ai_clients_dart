import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Administrative roles.
@immutable
class AdminRoles {
  /// Creates a [AdminRoles].
  const AdminRoles({
    required this.organizationRoles,
    required this.workspaceRoles,
  });

  /// Organization roles available to the Organization.
  final List<AdminRole> organizationRoles;

  /// Workspace roles available to the Organization.
  final List<AdminRole> workspaceRoles;

  /// Parses a [AdminRoles] from JSON.
  factory AdminRoles.fromJson(Map<String, dynamic> json) {
    if (json['organization_roles'] == null) {
      throw const FormatException('AdminRoles: missing organization_roles');
    }
    if (json['workspace_roles'] == null) {
      throw const FormatException('AdminRoles: missing workspace_roles');
    }
    return AdminRoles(
      organizationRoles: (json['organization_roles'] as List)
          .map((item) => AdminRole.fromJson(item as Map<String, dynamic>))
          .toList(),
      workspaceRoles: (json['workspace_roles'] as List)
          .map((item) => AdminRole.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'organization_roles': organizationRoles
        .map((item) => item.toJson())
        .toList(),
    'workspace_roles': workspaceRoles.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  AdminRoles copyWith({
    List<AdminRole>? organizationRoles,
    List<AdminRole>? workspaceRoles,
  }) => AdminRoles(
    organizationRoles: organizationRoles ?? this.organizationRoles,
    workspaceRoles: workspaceRoles ?? this.workspaceRoles,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminRoles &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(organizationRoles, other.organizationRoles) &&
          valuesDeepEqual(workspaceRoles, other.workspaceRoles);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(organizationRoles),
    valueDeepHashCode(workspaceRoles),
  ]);

  @override
  String toString() =>
      'AdminRoles('
      'organizationRoles: ${organizationRoles.length}, '
      'workspaceRoles: ${workspaceRoles.length})';
}

/// Administrative role.
@immutable
class AdminRole {
  /// Creates a [AdminRole].
  const AdminRole({
    required this.description,
    required this.isCustomRole,
    required this.name,
    required this.uuid,
  });

  /// Short description of the role.
  final String description;

  /// Whether this role is custom-defined.
  final bool isCustomRole;

  /// Role name.
  final String name;

  /// Role UUID.
  final String uuid;

  /// Parses a [AdminRole] from JSON.
  factory AdminRole.fromJson(Map<String, dynamic> json) {
    if (json['description'] == null) {
      throw const FormatException('AdminRole: missing description');
    }
    if (json['is_custom_role'] == null) {
      throw const FormatException('AdminRole: missing is_custom_role');
    }
    if (json['name'] == null) {
      throw const FormatException('AdminRole: missing name');
    }
    if (json['uuid'] == null) {
      throw const FormatException('AdminRole: missing uuid');
    }
    return AdminRole(
      description: json['description'] as String,
      isCustomRole: json['is_custom_role'] as bool,
      name: json['name'] as String,
      uuid: json['uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'description': description,
    'is_custom_role': isCustomRole,
    'name': name,
    'uuid': uuid,
  };

  /// Creates a copy with the given fields replaced.
  AdminRole copyWith({
    String? description,
    bool? isCustomRole,
    String? name,
    String? uuid,
  }) => AdminRole(
    description: description ?? this.description,
    isCustomRole: isCustomRole ?? this.isCustomRole,
    name: name ?? this.name,
    uuid: uuid ?? this.uuid,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminRole &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          isCustomRole == other.isCustomRole &&
          name == other.name &&
          uuid == other.uuid;

  @override
  int get hashCode => Object.hashAll([description, isCustomRole, name, uuid]);

  @override
  String toString() =>
      'AdminRole('
      'description: $description, '
      'isCustomRole: $isCustomRole, '
      'name: $name, '
      'uuid: $uuid)';
}
