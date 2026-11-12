import '../../models/common/copy_with_sentinel.dart';
import '../../models/organization/organization_page.dart';
import '../../models/organization/organization_rbac.dart';
import 'organization_transport.dart';

/// Lists and manages organization role-based access groups.
final class OrganizationRbacGroupsResource {
  /// Creates the RBAC group resource.
  const OrganizationRbacGroupsResource(this._transport);

  final OrganizationTransport _transport;

  /// Lists directly managed and synchronized groups.
  Future<OrganizationCursorPage<OrganizationRbacGroup>> list({
    String? page,
    int? limit,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/rbac_groups',
    (json) => OrganizationCursorPage.fromJson(
      json,
      OrganizationRbacGroup.fromJson,
      requireHasMore: true,
    ),
    query: organizationCursorQuery(page, limit),
    abortTrigger: abortTrigger,
  );

  /// Creates a directly managed group.
  Future<OrganizationRbacGroup> create({
    required String name,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '/rbac_groups',
    OrganizationRbacGroup.fromJson,
    body: {'name': name},
    abortTrigger: abortTrigger,
  );

  /// Retrieves an existing group.
  Future<OrganizationRbacGroup> retrieve(
    String groupId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _group(groupId),
    OrganizationRbacGroup.fromJson,
    abortTrigger: abortTrigger,
  );

  /// Updates the name of a directly managed group.
  Future<OrganizationRbacGroup> update(
    String groupId, {
    Object? name = unsetCopyWithValue,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _group(groupId),
    OrganizationRbacGroup.fromJson,
    body: {if (name != unsetCopyWithValue) 'name': name as String?},
    abortTrigger: abortTrigger,
  );

  /// Deletes a directly managed group.
  Future<DeletedOrganizationRbacGroup> delete(
    String groupId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    _group(groupId),
    DeletedOrganizationRbacGroup.fromJson,
    abortTrigger: abortTrigger,
  );

  /// Lists members of a group.
  Future<OrganizationCursorPage<OrganizationRbacGroupMember>> listMembers(
    String groupId, {
    String? page,
    int? limit,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '${_group(groupId)}/members',
    (json) => OrganizationCursorPage.fromJson(
      json,
      OrganizationRbacGroupMember.fromJson,
      requireHasMore: true,
    ),
    query: organizationCursorQuery(page, limit),
    abortTrigger: abortTrigger,
  );

  /// Adds a user to a directly managed group.
  Future<OrganizationRbacGroupMember> addMember(
    String groupId,
    String userId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_group(groupId)}/members',
    OrganizationRbacGroupMember.fromJson,
    body: {'user_id': userId},
    abortTrigger: abortTrigger,
  );

  /// Removes a user from a directly managed group.
  Future<DeletedOrganizationRbacGroupMember> removeMember(
    String groupId,
    String userId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    '${_group(groupId)}/members/${organizationIdSegment(userId, 'userId')}',
    DeletedOrganizationRbacGroupMember.fromJson,
    abortTrigger: abortTrigger,
  );

  static String _group(String id) =>
      '/rbac_groups/${organizationIdSegment(id, 'groupId')}';
}

/// Reads the organization's custom roles and their permissions.
final class OrganizationRbacRolesResource {
  /// Creates the RBAC roles resource.
  const OrganizationRbacRolesResource(this._transport);

  final OrganizationTransport _transport;

  /// Lists custom roles.
  Future<OrganizationCursorPage<OrganizationRbacRole>> list({
    String? page,
    int? limit,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/rbac_roles',
    (json) => OrganizationCursorPage.fromJson(
      json,
      OrganizationRbacRole.fromJson,
      requireHasMore: true,
    ),
    query: organizationCursorQuery(page, limit),
    abortTrigger: abortTrigger,
  );

  /// Retrieves a custom role.
  Future<OrganizationRbacRole> retrieve(
    String roleId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _role(roleId),
    OrganizationRbacRole.fromJson,
    abortTrigger: abortTrigger,
  );

  /// Lists permissions assigned to the role.
  Future<OrganizationCursorPage<OrganizationRbacRolePermission>>
  listPermissions(
    String roleId, {
    String? page,
    int? limit,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '${_role(roleId)}/permissions',
    (json) => OrganizationCursorPage.fromJson(
      json,
      OrganizationRbacRolePermission.fromJson,
      requireHasMore: true,
    ),
    query: organizationCursorQuery(page, limit),
    abortTrigger: abortTrigger,
  );

  static String _role(String id) =>
      '/rbac_roles/${organizationIdSegment(id, 'roleId')}';
}
