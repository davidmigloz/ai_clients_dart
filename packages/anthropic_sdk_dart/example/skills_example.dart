// ignore_for_file: avoid_print
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Skills API example (Beta).
///
/// This example demonstrates:
/// - Creating a skill from a ZIP archive
/// - Listing skills
/// - Retrieving skill details
/// - Managing skill versions
/// - Deleting skills
///
/// Note: The Skills API is a beta feature and requires the anthropic-beta header.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider:
          ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Create a skill
    print('=== Create Skill ===');

    // In a real scenario, you would load a ZIP file containing your skill
    const skillPath = 'example/sample_skill.zip';
    final skillFile = File(skillPath);

    if (skillFile.existsSync()) {
      final skillBytes = await skillFile.readAsBytes();
      final skill = await client.skills.create(
        skillBytes: skillBytes,
        displayTitle: 'My Custom Skill',
      );

      print('Skill created:');
      print('  ID: ${skill.id}');
      print('  Display title: ${skill.displayTitle}');
      print('  Source: ${skill.source}');
      print('  Latest version: ${skill.latestVersion}');

      // Example 2: List skills
      print('\n=== List Skills ===');
      final skillList = await client.skills.list(limit: 10);

      print('Skills (${skillList.data.length} total):');
      for (final s in skillList.data) {
        print('  - ${s.id}: ${s.displayTitle ?? "untitled"}');
      }
      print('Has more: ${skillList.hasMore}');

      // Example 3: Retrieve skill details
      print('\n=== Retrieve Skill ===');
      final retrievedSkill = await client.skills.retrieve(skillId: skill.id);

      print('Skill details:');
      print('  ID: ${retrievedSkill.id}');
      print('  Display title: ${retrievedSkill.displayTitle}');
      print('  Latest version: ${retrievedSkill.latestVersion}');

      // Example 4: Create a new version
      print('\n=== Create Version ===');
      final newVersionBytes =
          await skillFile.readAsBytes(); // In practice, different content
      final version = await client.skills.createVersion(
        skillId: skill.id,
        versionBytes: newVersionBytes,
      );

      print('Version created:');
      print('  Version: ${version.version}');
      print('  Description: ${version.description}');

      // Example 5: List versions
      print('\n=== List Versions ===');
      final versions = await client.skills.listVersions(skillId: skill.id);

      print('Versions:');
      for (final v in versions.data) {
        print('  - ${v.version}: ${v.description}');
      }

      // Example 6: Delete version
      print('\n=== Delete Version ===');
      await client.skills.deleteVersion(
        skillId: skill.id,
        version: version.version,
      );
      print('Version deleted');

      // Example 7: Delete skill
      print('\n=== Delete Skill ===');
      await client.skills.deleteSkill(skillId: skill.id);
      print('Skill deleted');
    } else {
      print('No sample skill file found at $skillPath');
      print('To test skill creation:');
      print('1. Create a ZIP archive containing your skill files');
      print('2. Place it at $skillPath');
      print('3. Run this example again');

      print('\nDemonstrating list operation instead...');

      // List existing skills
      print('\n=== List Skills ===');
      final skillList = await client.skills.list(limit: 10);

      if (skillList.data.isEmpty) {
        print('No skills found');
      } else {
        print('Skills:');
        for (final s in skillList.data) {
          print('  - ${s.id}: ${s.displayTitle ?? "untitled"}');
        }
      }

      // List Anthropic-provided skills
      print('\n=== Anthropic Skills ===');
      final anthropicSkills = await client.skills.list(
        source: 'anthropic',
        limit: 10,
      );

      if (anthropicSkills.data.isEmpty) {
        print('No Anthropic skills available');
      } else {
        print('Anthropic-provided skills:');
        for (final s in anthropicSkills.data) {
          print('  - ${s.id}: ${s.displayTitle ?? "untitled"}');
        }
      }
    }
  } finally {
    client.close();
  }
}
