// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Scheduled deployments example (Beta).
///
/// A deployment runs an agent session on a cron schedule (or on demand)
/// without you managing your own scheduler. Each firing produces a
/// "deployment run". Requires the `anthropic-beta: managed-agents-2026-04-01`
/// header (sent automatically).
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Create an agent to deploy.
    final agent = await client.agents.create(
      const CreateAgentParams(
        name: 'Daily Summarizer',
        model: ModelParamsId(id: 'claude-sonnet-4-6'),
      ),
    );

    // Create a deployment that fires the agent every morning (cron schedule).
    final deployment = await client.deployments.create(
      CreateDeploymentParams(
        agent: AgentParamsId(id: agent.id),
        environmentId: 'default',
        name: 'Daily standup digest',
        schedule: const CronScheduleParams(
          expression: '0 9 * * *',
          timezone: 'America/New_York',
        ),
        initialEvents: const [
          DeploymentInitialEventParams.userMessage(
            UserMessageEventParams(
              content: [
                {'type': 'text', 'text': 'Summarize the latest commits.'},
              ],
            ),
          ),
        ],
      ),
    );
    print(
      'Created deployment ${deployment.id} '
      '(status: ${deployment.status.value})',
    );

    // Pause then resume the schedule.
    await client.deployments.pause(deployment.id);
    await client.deployments.unpause(deployment.id);

    // Trigger a run now instead of waiting for the next scheduled firing.
    final run = await client.deployments.run(deployment.id);
    print('Triggered run ${run.id} -> session ${run.sessionId}');

    // List active deployments.
    final deployments = await client.deployments.list(
      status: DeploymentStatus.active,
    );
    print('Active deployments: ${deployments.data.length}');

    // List runs for this deployment.
    final runs = await client.deploymentRuns.list(deploymentId: deployment.id);
    for (final r in runs.data) {
      print('Run ${r.id}: ${r.error == null ? 'ok' : 'error'}');
    }

    // Retrieve a single run.
    if (runs.data.isNotEmpty) {
      final detail = await client.deploymentRuns.retrieve(runs.data.first.id);
      print('Run ${detail.id} trigger: ${detail.triggerContext}');
    }

    // Archive the deployment when no longer needed.
    await client.deployments.archive(deployment.id);
  } finally {
    client.close();
  }
}
