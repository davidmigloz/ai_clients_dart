// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Creates a GitHub event source and a trigger for a deployed workflow.
Future<void> main(List<String> args) async {
  if (args.isEmpty || args.contains('--help')) {
    print(
      'Usage: dart run example/workflow_trigger_example.dart <workflow-id>',
    );
    print('Set MISTRAL_API_KEY and GITHUB_WEBHOOK_SECRET before registering.');
    return;
  }

  final secret = Platform.environment['GITHUB_WEBHOOK_SECRET'];
  if (secret == null || secret.isEmpty) {
    throw StateError(
      'Set GITHUB_WEBHOOK_SECRET to the provider signing secret.',
    );
  }
  final client = MistralClient.fromEnvironment();
  try {
    final webhook = await client.webhooks.create(
      request: CreateWebhookRequest(
        provider: WebhookProvider.github,
        name: 'GitHub workflow events',
        ownerType: TriggerOwnerType.workspace,
        secret: secret,
      ),
    );
    final trigger = await client.triggers.create(
      request: CreateTriggerRequest(
        eventSourceId: webhook.id,
        handler: TriggerHandler.workflows,
        action: TriggerAction(
          primitiveId: args.first,
          type: TriggerActionType.startWorkflow,
        ),
        ownerType: TriggerOwnerType.workspace,
        title: 'Start from a GitHub push',
        filters: "event_type == 'push'",
      ),
    );
    print('Configure the webhook URL in GitHub: ${webhook.url}');
    print('Trigger ID: ${trigger.id}');
    final events = await client.triggers.listEvents(triggerId: trigger.id);
    print('${events.data.length} recent trigger events');
  } finally {
    client.close();
  }
}
