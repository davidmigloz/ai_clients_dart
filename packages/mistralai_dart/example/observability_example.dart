// ignore_for_file: avoid_print
// Observability API (Beta)
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating the Observability API (Beta).
///
/// This example shows how to:
/// - Create and list datasets
/// - List campaigns
/// - List judges
/// - Search chat completion events
///
/// Before running:
/// 1. Get your API key from https://console.mistral.ai/
/// 2. Set environment variable: export MISTRAL_API_KEY=your_api_key
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // --- Datasets ---
    print('=== Create Dataset ===\n');

    final dataset = await client.observability.datasets.create(
      request: const PostDatasetInSchema(
        name: 'Example Dataset',
        description: 'A dataset created from the Dart example',
      ),
    );

    print('Created dataset:');
    print('  ID: ${dataset.id}');
    print('  Name: ${dataset.name}');
    print('  Description: ${dataset.description}');
    print('  Created: ${dataset.createdAt}');

    print('\n=== List Datasets ===\n');

    final datasets = await client.observability.datasets.list();
    final datasetResults = datasets.datasets.results;

    if (datasetResults.isEmpty) {
      print('No datasets found.');
    } else {
      print('Found ${datasets.datasets.count} dataset(s):');
      for (final ds in datasetResults) {
        print('  - ${ds.name} (${ds.id})');
        print('    Description: ${ds.description}');
      }
    }

    // Clean up the created dataset
    await client.observability.datasets.delete(datasetId: dataset.id);
    print('\nDeleted example dataset.');

    // --- Campaigns ---
    print('\n=== List Campaigns ===\n');

    final campaigns = await client.observability.campaigns.list();
    final campaignResults = campaigns.campaigns.results;

    if (campaignResults.isEmpty) {
      print('No campaigns found.');
    } else {
      print('Found ${campaigns.campaigns.count} campaign(s):');
      for (final campaign in campaignResults) {
        print('  - ${campaign.name} (${campaign.id})');
        print('    Description: ${campaign.description}');
        print('    Max events: ${campaign.maxNbEvents}');
      }
    }

    // --- Judges ---
    print('\n=== List Judges ===\n');

    final judges = await client.observability.judges.list();
    final judgeResults = judges.judges.results;

    if (judgeResults.isEmpty) {
      print('No judges found.');
    } else {
      print('Found ${judges.judges.count} judge(s):');
      for (final judge in judgeResults) {
        print('  - ${judge.name} (${judge.id})');
        print('    Model: ${judge.modelName}');
        print('    Description: ${judge.description}');
      }
    }

    // --- Chat Completion Events ---
    print('\n=== Search Chat Completion Events ===\n');

    // Search with no filters (returns recent events)
    final events = await client.observability.chatCompletionEvents.search(
      request: GetChatCompletionEventsInSchema(
        searchParams: const FilterPayload(),
      ),
    );

    final eventResults = events.completionEvents.results;

    if (eventResults.isEmpty) {
      print('No chat completion events found.');
    } else {
      print('Found ${eventResults.length} event(s):');
      for (final event in eventResults.take(5)) {
        print('  - Event: ${event.eventId}');
        print('    Created: ${event.createdAt}');
        print('    Input tokens: ${event.nbInputTokens}');
        print('    Output tokens: ${event.nbOutputTokens}');
      }
    }

    // Search with a filter (e.g., filter by model)
    print('\n=== Search Events with Filter ===\n');

    final filteredEvents = await client.observability.chatCompletionEvents
        .search(
          request: GetChatCompletionEventsInSchema(
            searchParams: const FilterPayload(
              filters: FilterCondition(
                field: 'model',
                op: 'eq',
                value: 'mistral-small-latest',
              ),
            ),
          ),
        );

    final filteredResults = filteredEvents.completionEvents.results;

    if (filteredResults.isEmpty) {
      print('No events found matching the filter.');
    } else {
      print('Found ${filteredResults.length} filtered event(s):');
      for (final event in filteredResults.take(3)) {
        print('  - Event: ${event.eventId}');
        print('    Input tokens: ${event.nbInputTokens}');
        print('    Output tokens: ${event.nbOutputTokens}');
      }
    }
  } finally {
    client.close();
  }
}
