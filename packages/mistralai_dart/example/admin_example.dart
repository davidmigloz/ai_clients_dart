import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Reads organization roles and the first page of workspaces.
Future<void> main(List<String> args) async {
  if (args.contains('--help')) {
    stdout
      ..writeln('Usage: dart run example/admin_example.dart')
      ..writeln('Set MISTRAL_ADMIN_API_KEY to an organization Admin key.');
    return;
  }
  final key = Platform.environment['MISTRAL_ADMIN_API_KEY'];
  if (key == null || key.trim().isEmpty) {
    stderr.writeln('Set MISTRAL_ADMIN_API_KEY to an organization Admin key.');
    exitCode = 64;
    return;
  }
  final admin = MistralAdminClient.withApiKey(key);
  try {
    final roles = await admin.roles.list();
    for (final role in roles.organizationRoles) {
      stdout.writeln('Organization role: ${role.name}');
    }
    final workspaces = await admin.workspaces.list(page: 1, pageSize: 10);
    stdout.writeln('Workspace count: ${workspaces.total}');
    for (final workspace in workspaces.items) {
      stdout.writeln(workspace.name);
    }
  } finally {
    admin.close();
  }
}
