// ignore_for_file: avoid_print, unused_local_variable
/// Example demonstrating the Skills API.
///
/// Skills allow uploading and managing reusable skill packages.
///
/// Run with: dart run example/skills_example.dart
library;

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    // List skills
    print('=== List Skills ===\n');

    final skills = await client.skills.list(limit: 10);
    print('Found ${skills.data.length} skill(s):');

    for (final skill in skills.data) {
      print('  - ${skill.id}: ${skill.name}');
    }
    print('');

    // Retrieve a specific skill (if any exist)
    if (skills.data.isNotEmpty) {
      final skillId = skills.data.first.id;

      print('=== Retrieve Skill ===\n');
      final skill = await client.skills.retrieve(skillId);
      print('Skill: ${skill.name}');
      print('  ID: ${skill.id}');
      print('');

      // List skill versions
      print('=== List Skill Versions ===\n');
      final versions = await client.skills.versions.list(skillId);
      print('Found ${versions.data.length} version(s):');

      for (final version in versions.data) {
        print('  - ${version.id}');
      }
      print('');
    }
  } on OpenAIException catch (e) {
    print('OpenAI error: ${e.message}');
    if (e is ApiException) {
      print('Status: ${e.statusCode}');
    }
  } finally {
    client.close();
    print('Done!');
  }
}
