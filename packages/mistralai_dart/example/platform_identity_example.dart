// ignore_for_file: avoid_print
import 'package:mistralai_dart/mistralai_dart.dart';

/// Reads caller identity, billing settings, or workspace service accounts.
Future<void> main(List<String> args) async {
  if (args.isEmpty || args.contains('--help')) {
    print(
      'Usage: dart run example/platform_identity_example.dart '
      '<whoami|memberships|billing|service-accounts> [workspace-id]',
    );
    print(
      'Set MISTRAL_API_KEY to a credential permitted for the selected API.',
    );
    return;
  }

  final client = MistralClient.fromEnvironment();
  try {
    switch (args[0]) {
      case 'whoami':
        final identity = await client.users.whoami();
        switch (identity.principal) {
          case WhoamiUserPrincipal(:final id):
            print('User: $id');
          case WhoamiServiceAccountPrincipal(:final serviceAccountId):
            print('Service account: $serviceAccountId');
          case UnknownWhoamiPrincipal():
            print('The API returned a new principal type.');
        }
        print('Workspace: ${identity.workspace?.name}');
      case 'memberships':
        final organizations = await client.users.listOrganizations(limit: 10);
        for (final organization in organizations.organizations) {
          final workspaces = await client.users.listWorkspaces(
            organizationId: organization.id,
            limit: 10,
          );
          print(
            '${organization.name}: ${workspaces.workspaces.length} workspaces',
          );
        }
      case 'billing':
        final budget = await client.billing.getBudget();
        final subscription = await client.billing.getSubscription();
        print(
          '${subscription.planName}: ${budget.apiBudget.usagePercentage}% API usage',
        );
      case 'service-accounts':
        if (args.length < 2) throw ArgumentError('Provide a workspace ID.');
        final workspaceId = args[1];
        final accounts = await client.serviceAccounts.list(
          workspaceId: workspaceId,
          limit: 25,
        );
        final roles = await client.serviceAccounts.listAssignableRoles(
          workspaceId: workspaceId,
        );
        print(
          '${accounts.items.length} accounts and ${roles.items.length} roles',
        );
      default:
        throw ArgumentError('Unknown command ${args[0]}. Run with --help.');
    }
  } finally {
    client.close();
  }
}
