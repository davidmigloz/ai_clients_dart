// ignore_for_file: avoid_print

import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

/// Example: managing webhook subscriptions for the Interactions API.
///
/// The Webhooks API (experimental) lets you register HTTPS endpoints that
/// receive delivery events for batches, interactions, and video generation.
Future<void> main() async {
  final apiKey = Platform.environment['GOOGLE_GENAI_API_KEY'];
  if (apiKey == null) {
    print('Set GOOGLE_GENAI_API_KEY to run this example.');
    return;
  }

  final client = GoogleAIClient.withApiKey(apiKey);

  try {
    // 1. Create a webhook subscription.
    final webhook = await client.webhooks.create(
      webhook: const Webhook(
        uri: 'https://example.com/gemini-webhooks',
        subscribedEvents: [
          'interaction.completed',
          'interaction.failed',
          'video.generated',
        ],
        name: 'Production webhook',
      ),
    );
    print('Created webhook: ${webhook.id}');
    print('Signing secret: ${webhook.newSigningSecret}');

    // 2. List webhooks.
    final page = await client.webhooks.list(pageSize: 10);
    for (final w in page.webhooks ?? const <Webhook>[]) {
      print('- ${w.id}: ${w.uri} (state: ${w.state})');
    }

    // 3. Send a test ping to verify the endpoint.
    await client.webhooks.ping(webhook.id!);
    print('Ping sent.');

    // 4. Update the webhook (rename and pause it).
    await client.webhooks.update(
      id: webhook.id!,
      update: const WebhookUpdate(
        name: 'Production webhook (paused)',
        state: WebhookState.disabled,
      ),
      updateMask: 'name,state',
    );

    // 5. Rotate signing secret with a 24-hour grace period.
    final rotated = await client.webhooks.rotateSigningSecret(
      id: webhook.id!,
      request: const RotateSigningSecretRequest(
        revocationBehavior:
            SigningSecretRevocationBehavior.revokePreviousSecretsAfterH24,
      ),
    );
    print('New signing secret: ${rotated.secret}');

    // 6. Per-interaction override: attach inline webhook URIs.
    final interaction = await client.interactions.create(
      model: 'gemini-3.5-flash',
      input: const InteractionInput.text('Generate a haiku.'),
      webhookConfig: const WebhookConfig(
        uris: ['https://example.com/one-off-hook'],
        userMetadata: {'campaign_id': 'abc-123'},
      ),
    );
    print('Interaction id: ${interaction.id}');

    // 7. Parse an incoming webhook delivery body.
    final deliveryJson = <String, dynamic>{
      'type': 'interaction.completed',
      'version': 'v1',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'data': {'id': interaction.id},
    };
    final event = WebhookEvent.fromJson(deliveryJson);
    switch (event) {
      case WebhookInteractionCompletedEvent(:final id):
        print('Interaction $id completed.');
      case WebhookInteractionFailedEvent(:final id, :final errorMessage):
        print('Interaction $id failed: $errorMessage');
      case WebhookVideoGeneratedEvent(:final id, :final outputFileUri):
        print('Video $id ready at $outputFileUri');
      default:
        print('Other event: ${event.type}');
    }

    // 8. Clean up.
    await client.webhooks.delete(webhook.id!);
    print('Deleted webhook ${webhook.id}.');
  } finally {
    client.close();
  }
}
