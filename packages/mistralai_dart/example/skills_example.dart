// ignore_for_file: avoid_print, unreachable_from_main
import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating the Skills API (Beta).
///
/// Skills are versioned, reusable model instructions (with optional file
/// assets) that can be shared across a workspace and referenced by alias or
/// version number.
///
/// This example shows how to:
/// - Create a skill (with a text asset) and list existing ones
/// - Retrieve a skill and its versions
/// - Create a new version and update its alias
/// - Delete a skill
///
/// Before running:
/// 1. Get your API key from https://console.mistral.ai/
/// 2. Set environment variable: export MISTRAL_API_KEY=your_api_key
void main() async {
  final client = MistralClient.fromEnvironment();

  try {
    await skillLifecycleExample(client);
  } finally {
    client.close();
  }
}

/// Demonstrates the full lifecycle of a skill.
Future<void> skillLifecycleExample(MistralClient client) async {
  print('=== Skills Example ===\n');

  // Create a skill with a text asset.
  print('Creating a skill...');
  final skill = await client.skills.create(
    request: const CreateSkillRequest(
      name: 'summarizer',
      definition: SkillDefinition(
        description: 'Summarizes long documents.',
        body: 'Summarize the input in three bullet points.',
        assets: {
          'style_guide.txt': SkillAssetContent.text(
            textContent: 'Use concise, plain language.',
          ),
        },
      ),
    ),
  );
  print('Created skill ${skill.id} (version ${skill.version})');
  print('');

  try {
    // List skills.
    print('Listing skills...');
    final skills = await client.skills.list(pageSize: 10);
    print('Found ${skills.data?.length ?? 0} skill(s)');
    print('');

    // Retrieve the latest version.
    print('Retrieving skill...');
    final retrieved = await client.skills.retrieve(skillId: skill.id);
    print('Body: ${retrieved.definition?.body}');
    print('');

    // Create a new version.
    print('Creating a new version...');
    final newVersion = await client.skills.createVersion(
      skillId: skill.id,
      request: const CreateSkillVersionRequest(
        definition: SkillDefinition(
          description: 'Summarizes long documents concisely.',
          body: 'Summarize the input in three short bullet points.',
        ),
        notes: 'Tightened instructions',
      ),
    );
    print('Created version ${newVersion.version}');
    print('');

    // List versions.
    print('Listing versions...');
    final versions = await client.skills.listVersions(skillId: skill.id);
    print('Found ${versions.data?.length ?? 0} version(s)');
    print('');

    // Point an alias at the new version.
    print('Updating alias on the new version...');
    await client.skills.updateVersion(
      skillId: skill.id,
      version: newVersion.version ?? 2,
      request: const UpdateSkillVersionRequest(
        aliases: AliasList(values: ['production']),
      ),
    );
    print('Alias "production" now points to version ${newVersion.version}');
    print('');

    // Retrieve by alias.
    print('Retrieving by alias...');
    final byAlias = await client.skills.retrieve(
      skillId: skill.id,
      alias: 'production',
    );
    print('Body via alias: ${byAlias.definition?.body}');
    print('');
  } finally {
    // Delete the skill (cleanup).
    print('Deleting skill...');
    await client.skills.delete(skillId: skill.id);
    print('Skill deleted successfully');
  }
}
