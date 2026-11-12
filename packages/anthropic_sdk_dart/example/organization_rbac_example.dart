import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Reads RBAC groups, group members, roles and permissions.
///
/// Set ANTHROPIC_ADMIN_KEY to an Enterprise key with read:rbac_groups and
/// read:members, or read:org_audit.
Future<void> main() async {
  final adminKey = Platform.environment['ANTHROPIC_ADMIN_KEY'];
  if (adminKey == null || adminKey.isEmpty) {
    stderr.writeln('Set ANTHROPIC_ADMIN_KEY.');
    exitCode = 64;
    return;
  }

  final client = AnthropicClient.withApiKey(adminKey);
  try {
    final groups = await client.organization.rbacGroups.list(limit: 10);
    for (final group in groups.data) {
      final members = await client.organization.rbacGroups.listMembers(
        group.id,
        limit: 10,
      );
      stdout.writeln(
        '${group.name}: ${members.data.length} members on the first page',
      );
    }

    final roles = await client.organization.rbacRoles.list(limit: 10);
    for (final role in roles.data) {
      final permissions = await client.organization.rbacRoles.listPermissions(
        role.id,
        limit: 10,
      );
      stdout.writeln(
        '${role.displayName}: ${permissions.data.length} permissions on the first page',
      );
    }
  } finally {
    client.close();
  }
}
