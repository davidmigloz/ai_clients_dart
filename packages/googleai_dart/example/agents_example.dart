// ignore_for_file: avoid_print

import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

/// Example: managing reusable agents and environments for the Interactions API.
///
/// The Agents API (experimental) lets you define reusable agents — a base
/// agent, an environment (sandbox), a system instruction, and a set of tools —
/// that can then be referenced when creating interactions.
Future<void> main() async {
  final apiKey = Platform.environment['GOOGLE_GENAI_API_KEY'];
  if (apiKey == null) {
    print('Set GOOGLE_GENAI_API_KEY to run this example.');
    return;
  }

  final client = GoogleAIClient.withApiKey(apiKey);

  try {
    // 1. Create an agent with a remote environment and a couple of tools.
    final agent = await client.agents.create(
      agent: const Agent(
        baseAgent: 'deep-research-pro-preview-12-2025',
        description: 'Research assistant with web access',
        systemInstruction: 'You are a meticulous research assistant.',
        baseEnvironment: EnvironmentConfigOrId.config(
          EnvironmentConfig(
            sources: [
              Source(
                type: SourceType.gcs,
                source: 'gs://my-bucket/knowledge',
                target: '/mnt/knowledge',
              ),
            ],
            network: EnvironmentNetworkAllowlist(
              allowlist: [
                AllowlistEntry(domain: 'wikipedia.org'),
                AllowlistEntry(
                  domain: 'api.example.com',
                  transform: [
                    {'x-goog-api-key': 'REDACTED'},
                  ],
                ),
              ],
            ),
          ),
        ),
        tools: [GoogleSearchTool(), UrlContextTool()],
      ),
    );
    print('Created agent: ${agent.id}');

    // 2. List agents.
    final page = await client.agents.list(pageSize: 10);
    for (final a in page.agents ?? const <Agent>[]) {
      print('- ${a.id}: ${a.description}');
    }

    // 3. Fetch a single agent by id.
    final fetched = await client.agents.get(agent.id!);
    print('Fetched agent base: ${fetched.baseAgent}');

    // 4. Create an interaction that reuses the agent by id.
    final interaction = await client.interactions.createWithAgent(
      agent: agent.id!,
      input: const InteractionInput.text("Summarize today's AI news."),
    );
    print('Interaction id: ${interaction.id}');

    // 5. Clean up.
    await client.agents.delete(agent.id!);
    print('Deleted agent ${agent.id}.');
  } finally {
    client.close();
  }
}
