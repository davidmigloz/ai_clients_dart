// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Start a session that can run a dynamic workflow and follow its progress.
///
/// Run with ANTHROPIC_API_KEY in the environment. This creates an agent and a
/// session using Managed Agents beta and may incur usage charges.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();
  try {
    final agent = await client.agents.create(
      const CreateAgentParams(
        name: 'Workflow example',
        model: ModelParamsId(id: 'claude-sonnet-5'),
        system: 'Use a dynamic workflow for multi-stage research tasks.',
        multiagent: Multiagent20261001Params(
          workflows: MultiagentWorkersParams.enabled(),
        ),
      ),
    );

    final session = await client.sessions.create(
      CreateSessionParams(
        agent: AgentParamsId(id: agent.id),
        environmentId: 'default',
        initialEvents: const [
          SessionInitialEventParams.userMessage(
            UserMessageEventParams(
              content: [
                {
                  'type': 'text',
                  'text':
                      'Use a dynamic workflow to draft, independently '
                      'review, and revise a checklist for moving an API.',
                },
              ],
            ),
          ),
        ],
      ),
    );

    // The initial message can start work before a live stream connects.
    // Read the event history so an early workflow event is included.
    final events = client.sessions.events(session.id);
    final openRuns = <String>{};
    final seen = <String>{};
    final deadline = DateTime.now().add(const Duration(minutes: 5));

    while (DateTime.now().isBefore(deadline)) {
      String? page;
      do {
        final history = await events.list(order: ListOrder.asc, page: page);
        page = history.nextPage;
        for (final event in history.data) {
          switch (event) {
            case WorkflowRunEvent() when seen.add(event.id):
              final runId = event.workflowRunId;
              switch (event.kind) {
                case WorkflowRunEventKind.created:
                  openRuns.add(runId!);
                  print('Started workflow ${event.name} ($runId)');
                case WorkflowRunEventKind.phaseStarted:
                  print('Started phase ${event.workflowRunPhaseId}');
                case WorkflowRunEventKind.ended:
                  openRuns.remove(runId);
                  print('Workflow $runId ended with ${event.result?.type}');
                case WorkflowRunEventKind.error:
                  print(
                    'Workflow error: ${event.error?.message ?? event.error?.type}',
                  );
                case _:
                  break;
              }
            case SessionStatusIdleEvent() when seen.add(event.id):
              if (event.stopReason is SessionEndTurn && openRuns.isEmpty) {
                print('Session completed.');
                return;
              }
              if (event.stopReason is! SessionEndTurn) {
                print('Session paused or stopped: ${event.stopReason}');
                return;
              }
            case SessionStatusTerminatedEvent():
              print('Session terminated.');
              return;
            case AgentMessageEvent() when seen.add(event.id):
              for (final block in event.content) {
                print(block.toJson());
              }
            case _:
              break;
          }
        }
      } while (page != null);

      await Future<void>.delayed(const Duration(seconds: 3));
    }
    print('Timed out following session ${session.id}.');
  } finally {
    client.close();
  }
}
