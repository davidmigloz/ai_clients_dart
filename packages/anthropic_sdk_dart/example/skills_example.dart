// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Skills API example.
///
/// This example demonstrates:
/// - Creating a skill from a set of files (a `SKILL.md` at minimum)
/// - Listing skills
/// - Retrieving skill details
/// - Managing skill versions
/// - Deleting skills and versions
///
/// Note: The Skills API is generally available and does not require an
/// anthropic-beta header.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Create a skill from an in-memory SKILL.md.
    //
    // All files must share one top-level directory that contains a
    // `SKILL.md` file at its root (e.g. `my-skill/SKILL.md`).
    print('=== Create Skill ===');

    const skillMdContent = '''
---
name: my-custom-skill
description: A demo skill created from the Dart SDK.
---

# My Custom Skill

This skill demonstrates the Skills API.
''';

    final skill = await client.skills.create(
      files: [
        SkillFile(
          path: 'my-custom-skill/SKILL.md',
          bytes: Uint8List.fromList(utf8.encode(skillMdContent)),
          mimeType: 'text/markdown',
        ),
      ],
      displayName: 'My Custom Skill',
    );

    print('Skill created:');
    print('  ID: ${skill.id}');
    print('  Display name: ${skill.displayName}');
    print('  Source: ${skill.source.type}');
    print('  Latest version: ${skill.latestVersionId}');

    // Example 2: List skills
    print('\n=== List Skills ===');
    final skillList = await client.skills.list(limit: 10);

    print('Skills (${skillList.data.length} total):');
    for (final s in skillList.data) {
      print('  - ${s.id}: ${s.displayName}');
    }
    print('Next page: ${skillList.nextPage}');

    // Example 3: Retrieve skill details
    print('\n=== Retrieve Skill ===');
    final retrievedSkill = await client.skills.retrieve(skillId: skill.id);

    print('Skill details:');
    print('  ID: ${retrievedSkill.id}');
    print('  Display name: ${retrievedSkill.displayName}');
    print('  Latest version: ${retrievedSkill.latestVersionId}');

    // Example 4: Create a new version
    print('\n=== Create Version ===');
    const updatedSkillMdContent = '''
---
name: my-custom-skill
description: A demo skill created from the Dart SDK (v2).
---

# My Custom Skill (v2)
''';
    final version = await client.skills.createVersion(
      skillId: skill.id,
      files: [
        SkillFile(
          path: 'my-custom-skill/SKILL.md',
          bytes: Uint8List.fromList(utf8.encode(updatedSkillMdContent)),
        ),
      ],
    );

    print('Version created:');
    print('  ID: ${version.id}');
    print('  Name: ${version.name}');
    print('  Description: ${version.description}');

    // Example 5: List versions
    print('\n=== List Versions ===');
    final versions = await client.skills.listVersions(skillId: skill.id);

    print('Versions:');
    for (final v in versions.data) {
      print('  - ${v.id}: ${v.description}');
    }

    // Example 6: Download a version's content (zip archive)
    print('\n=== Download Version Content ===');
    final contentBytes = await client.skills.downloadVersion(
      skillId: skill.id,
      version: version.id,
    );
    print('Downloaded ${contentBytes.length} bytes');
    await File('downloaded_skill.zip').writeAsBytes(contentBytes);

    // Example 7: Delete version
    print('\n=== Delete Version ===');
    final deletedVersion = await client.skills.deleteVersion(
      skillId: skill.id,
      version: version.id,
    );
    print('Version deleted: ${deletedVersion.id}');

    // Example 8: Delete skill
    print('\n=== Delete Skill ===');
    final deletedSkill = await client.skills.deleteSkill(skillId: skill.id);
    print('Skill deleted: ${deletedSkill.id}');

    // Example 9: List Anthropic-provided skills
    print('\n=== Anthropic Skills ===');
    final anthropicSkills = await client.skills.list(
      source: SkillSourceType.anthropic,
      limit: 10,
    );

    if (anthropicSkills.data.isEmpty) {
      print('No Anthropic skills available');
    } else {
      print('Anthropic-provided skills:');
      for (final s in anthropicSkills.data) {
        print('  - ${s.id}: ${s.displayName}');
      }
    }
  } finally {
    client.close();
  }
}
