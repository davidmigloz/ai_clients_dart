// ignore_for_file: avoid_print, unreachable_from_main
import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating the Prompts API (Beta).
///
/// Prompts are versioned templates that can be shared across a workspace and
/// referenced by alias or version number.
///
/// This example shows how to:
/// - Create a prompt and list existing ones
/// - Retrieve a prompt and its versions
/// - Create a new version and update its alias
/// - Delete a prompt
///
/// Before running:
/// 1. Get your API key from https://console.mistral.ai/
/// 2. Set environment variable: export MISTRAL_API_KEY=your_api_key
void main() async {
  final client = MistralClient.fromEnvironment();

  try {
    await promptLifecycleExample(client);
  } finally {
    client.close();
  }
}

/// Demonstrates the full lifecycle of a prompt.
Future<void> promptLifecycleExample(MistralClient client) async {
  print('=== Prompts Example ===\n');

  // Create a prompt.
  print('Creating a prompt...');
  final prompt = await client.prompts.create(
    request: const CreatePromptRequest(
      name: 'greeting',
      title: 'Greeting Prompt',
      definition: PromptDefinition(content: 'Hello, {{name}}!'),
    ),
  );
  print('Created prompt ${prompt.id} (version ${prompt.version})');
  print('');

  try {
    // List prompts.
    print('Listing prompts...');
    final prompts = await client.prompts.list(pageSize: 10);
    print('Found ${prompts.data?.length ?? 0} prompt(s)');
    print('');

    // Retrieve the latest version.
    print('Retrieving prompt...');
    final retrieved = await client.prompts.retrieve(promptId: prompt.id);
    print('Content: ${retrieved.definition?.content}');
    print('');

    // Create a new version.
    print('Creating a new version...');
    final newVersion = await client.prompts.createVersion(
      promptId: prompt.id,
      request: const CreatePromptVersionRequest(
        definition: PromptDefinition(content: 'Hi there, {{name}}!'),
        notes: 'Friendlier tone',
      ),
    );
    print('Created version ${newVersion.version}');
    print('');

    // List versions.
    print('Listing versions...');
    final versions = await client.prompts.listVersions(promptId: prompt.id);
    print('Found ${versions.data?.length ?? 0} version(s)');
    print('');

    // Point an alias at the new version.
    print('Updating alias on the new version...');
    await client.prompts.updateVersion(
      promptId: prompt.id,
      version: newVersion.version ?? 2,
      request: const UpdatePromptVersionRequest(
        aliases: AliasList(values: ['production']),
      ),
    );
    print('Alias "production" now points to version ${newVersion.version}');
    print('');

    // Retrieve by alias.
    print('Retrieving by alias...');
    final byAlias = await client.prompts.retrieve(
      promptId: prompt.id,
      alias: 'production',
    );
    print('Content via alias: ${byAlias.definition?.content}');
    print('');
  } finally {
    // Delete the prompt (cleanup).
    print('Deleting prompt...');
    await client.prompts.delete(promptId: prompt.id);
    print('Prompt deleted successfully');
  }
}
