// ignore_for_file: avoid_print

import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

/// Example: scheduling agent interactions with the Triggers API.
///
/// The Triggers API (experimental) lets you schedule an interaction request
/// template to run on a cron schedule, inspect its execution history, and
/// pause/resume or run it on demand.
Future<void> main() async {
  final apiKey = Platform.environment['GOOGLE_GENAI_API_KEY'];
  if (apiKey == null) {
    print('Set GOOGLE_GENAI_API_KEY to run this example.');
    return;
  }

  final client = GoogleAIClient.fromEnvironment();

  try {
    // 1. Create a trigger that runs a model interaction every hour.
    final trigger = await client.triggers.create(
      trigger: const TriggerCreateParams(
        interaction: CreateModelInteractionParams(
          model: 'gemini-3.5-flash',
          input: InteractionInput.text("Summarize today's AI news."),
        ),
        schedule: '0 * * * *',
        timeZone: 'UTC',
        displayName: 'Hourly AI news digest',
      ),
    );
    print('Created trigger: ${trigger.id} (${trigger.status})');

    // 2. List active triggers.
    final page = await client.triggers.list(
      filter: 'status=active',
      pageSize: 10,
    );
    for (final t in page.triggers ?? const <Trigger>[]) {
      print('- ${t.id}: ${t.displayName} (${t.schedule})');
    }

    // 3. Fetch a single trigger by id.
    final fetched = await client.triggers.get(trigger.id);
    print('Fetched trigger next run: ${fetched.nextRunTime}');

    // 4. Pause the trigger.
    final paused = await client.triggers.update(
      id: trigger.id,
      update: const TriggerUpdate(status: TriggerStatus.paused),
    );
    print('Trigger status: ${paused.status}');

    // 5. Run the trigger immediately, regardless of its schedule.
    final execution = await client.triggers.run(triggerId: trigger.id);
    print('Ran execution: ${execution.id} (${execution.status})');

    // 6. List the trigger's execution history.
    final executions = await client.triggers.listExecutions(
      triggerId: trigger.id,
      pageSize: 10,
    );
    for (final e
        in executions.triggerExecutions ?? const <TriggerExecution>[]) {
      print('- ${e.id}: ${e.status}');
    }

    // 7. Clean up.
    await client.triggers.delete(trigger.id);
    print('Deleted trigger ${trigger.id}.');
  } finally {
    client.close();
  }
}
