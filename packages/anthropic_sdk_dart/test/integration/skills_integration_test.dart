// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  AnthropicClient? client;

  setUpAll(() {
    apiKey = Platform.environment['ANTHROPIC_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('ANTHROPIC_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = AnthropicClient(
        config: AnthropicConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Skills API - Integration', () {
    test(
      'lists available skills',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.skills.list(limit: 10);

        // Should return a list (may be empty if no skills exist)
        expect(response.data, isA<List<Skill>>());
        expect(response.hasMore, isA<bool>());
      },
    );

    test(
      'lists skills with source filter',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // List only anthropic-provided skills
        final anthropicSkills = await client!.skills.list(
          limit: 10,
          source: 'anthropic',
        );

        // All returned skills should be from anthropic
        for (final skill in anthropicSkills.data) {
          expect(skill.source, 'anthropic');
        }

        // List only custom skills
        final customSkills = await client!.skills.list(
          limit: 10,
          source: 'custom',
        );

        // All returned skills should be custom
        for (final skill in customSkills.data) {
          expect(skill.source, 'custom');
        }
      },
    );

    // Note: Creating/uploading skills requires a valid skill ZIP file,
    // which is complex to generate in a test. These tests would require
    // a pre-built test skill file to be included.

    test(
      'handles pagination correctly',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Get first page with small limit
        final firstPage = await client!.skills.list(limit: 2);

        expect(firstPage.data, isA<List<Skill>>());

        // If there are more pages, get the next one
        if (firstPage.hasMore && firstPage.nextPage != null) {
          final secondPage = await client!.skills.list(
            limit: 2,
            page: firstPage.nextPage,
          );

          expect(secondPage.data, isA<List<Skill>>());

          // Skills in second page should be different from first page
          if (firstPage.data.isNotEmpty && secondPage.data.isNotEmpty) {
            final firstPageIds = firstPage.data.map((s) => s.id).toSet();
            for (final skill in secondPage.data) {
              expect(firstPageIds.contains(skill.id), isFalse);
            }
          }
        }
      },
    );

    test(
      'retrieves skill by id',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // First, list skills to get a valid ID
        final listResponse = await client!.skills.list(limit: 1);

        if (listResponse.data.isEmpty) {
          print('No skills available to test retrieve');
          return;
        }

        final skillId = listResponse.data.first.id;

        // Retrieve the skill
        final skill = await client!.skills.retrieve(skillId: skillId);

        expect(skill.id, skillId);
        expect(skill.displayTitle, isNotEmpty);
        expect(skill.source, anyOf('custom', 'anthropic'));
      },
    );

    test(
      'lists skill versions',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // First, list skills to get a valid ID
        final listResponse = await client!.skills.list(limit: 1);

        if (listResponse.data.isEmpty) {
          print('No skills available to test version listing');
          return;
        }

        final skillId = listResponse.data.first.id;

        // List versions
        final versionsResponse = await client!.skills.listVersions(
          skillId: skillId,
          limit: 10,
        );

        expect(versionsResponse.data, isA<List<SkillVersion>>());

        // Each version should have proper fields
        for (final version in versionsResponse.data) {
          expect(version.id, isNotEmpty);
          expect(version.skillId, skillId);
          expect(version.version, isNotEmpty);
          expect(version.name, isNotEmpty);
        }
      },
    );

    test(
      'retrieves specific skill version',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // First, list skills to get a valid ID
        final skillsResponse = await client!.skills.list(limit: 1);

        if (skillsResponse.data.isEmpty) {
          print('No skills available to test version retrieval');
          return;
        }

        final skill = skillsResponse.data.first;

        // List versions to get a version ID
        final versionsResponse = await client!.skills.listVersions(
          skillId: skill.id,
          limit: 1,
        );

        if (versionsResponse.data.isEmpty) {
          print('No versions available for skill ${skill.id}');
          return;
        }

        final versionId = versionsResponse.data.first.version;

        // Retrieve specific version
        final version = await client!.skills.retrieveVersion(
          skillId: skill.id,
          version: versionId,
        );

        expect(version.skillId, skill.id);
        expect(version.version, versionId);
      },
    );
  });
}
