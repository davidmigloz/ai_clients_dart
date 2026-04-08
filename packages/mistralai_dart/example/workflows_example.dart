// ignore_for_file: avoid_print
// Workflows API (Beta)
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating the Workflows API (Beta).
///
/// This example shows how to:
/// - List registered workflows
/// - Execute a workflow asynchronously
/// - Check execution status
/// - List workflow schedules
///
/// Before running:
/// 1. Get your API key from https://console.mistral.ai/
/// 2. Set environment variable: export MISTRAL_API_KEY=your_api_key
/// 3. Create a workflow in the Mistral console
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // --- List Workflows ---
    print('=== List Workflows ===\n');

    final workflowList = await client.workflows.core.list();
    final registrations = workflowList.workflowRegistrations;

    if (registrations.isEmpty) {
      print('No workflows found.');
      print('Create a workflow in the Mistral console to get started.');
    } else {
      print('Found ${registrations.length} registration(s):');
      for (final reg in registrations) {
        print('  - Registration ID: ${reg.id}');
        print('    Workflow ID: ${reg.workflowId}');
        print('    Task queue: ${reg.taskQueue}');
        if (reg.workflow != null) {
          print('    Name: ${reg.workflow!.displayName}');
          if (reg.workflow!.description != null) {
            print('    Description: ${reg.workflow!.description}');
          }
        }
      }
    }

    // --- Execute a Workflow ---
    print('\n=== Execute Workflow (Example) ===\n');

    print('To execute a workflow asynchronously:');
    print(r'''
final execution = await client.workflows.core.executeAsync(
  workflowIdentifier: 'your-workflow-id',
  request: WorkflowExecutionRequest(
    input: {'prompt': 'Summarize the latest AI news'},
  ),
);
print('Execution ID: ${execution.executionId}');
print('Status: ${execution.status?.value}');
''');

    print('To execute a workflow and wait for the result:');
    print(r'''
final result = await client.workflows.core.executeSync(
  workflowIdentifier: 'your-workflow-id',
  request: WorkflowExecutionRequest(
    input: {'prompt': 'Summarize the latest AI news'},
    timeoutSeconds: 60,
  ),
);
print('Result: ${result.result}');
''');

    // --- Get Execution Status ---
    print('=== Get Execution Status (Example) ===\n');

    // List recent runs to find an execution ID
    final runs = await client.workflows.runs.list(pageSize: 5);

    if (runs.executions.isEmpty) {
      print('No workflow runs found.');
    } else {
      print('Recent workflow runs:');
      for (final run in runs.executions) {
        print('  - ${run.workflowName}');
        print('    Execution ID: ${run.executionId}');
        print('    Status: ${run.status?.value ?? 'unknown'}');
        print('    Started: ${run.startTime}');
        if (run.endTime != null) {
          print('    Ended: ${run.endTime}');
        }
        if (run.totalDurationMs != null) {
          print('    Duration: ${run.totalDurationMs}ms');
        }
      }

      // Get detailed status for the first run
      final firstRun = runs.executions.first;
      print('\nDetailed execution status:');

      final execution = await client.workflows.executions.get(
        executionId: firstRun.executionId,
      );

      print('  Workflow: ${execution.workflowName}');
      print('  Execution ID: ${execution.executionId}');
      print('  Status: ${execution.status?.value ?? 'unknown'}');
      print('  Start time: ${execution.startTime}');
      print('  End time: ${execution.endTime ?? 'still running'}');
      print('  Result: ${execution.result ?? 'N/A'}');
    }

    // --- Workflow Schedules ---
    print('\n=== List Workflow Schedules ===\n');

    final scheduleList = await client.workflows.schedules.list();
    final schedules = scheduleList.schedules;

    if (schedules.isEmpty) {
      print('No workflow schedules found.');
    } else {
      print('Found ${schedules.length} schedule(s):');
      for (final schedule in schedules) {
        print('  - Schedule ID: ${schedule.scheduleId}');
        if (schedule.cronExpressions != null &&
            schedule.cronExpressions!.isNotEmpty) {
          print('    Cron: ${schedule.cronExpressions!.join(', ')}');
        }
        if (schedule.timeZoneName != null) {
          print('    Timezone: ${schedule.timeZoneName}');
        }
        if (schedule.startAt != null) {
          print('    Start: ${schedule.startAt}');
        }
        if (schedule.endAt != null) {
          print('    End: ${schedule.endAt}');
        }
      }
    }

    // --- Streaming Execution Events (Example) ---
    print('\n=== Stream Execution Events (Example) ===\n');

    print('To stream real-time events from a workflow execution:');
    print(r'''
final stream = client.workflows.executions.stream(
  executionId: 'your-execution-id',
);

await for (final event in stream) {
  print('Event: ${event.type}');
  print('Data: ${event.data}');
}
''');

    print('To cancel a running execution:');
    print(r'''
await client.workflows.executions.cancel(
  executionId: 'your-execution-id',
);
''');
  } finally {
    client.close();
  }
}
