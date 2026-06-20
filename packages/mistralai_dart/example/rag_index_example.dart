// ignore_for_file: avoid_print, unreachable_from_main
import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating the RAG API (Beta).
///
/// The RAG API lets you configure document ingestion pipelines and manage the
/// search indexes used for retrieval.
///
/// This example shows how to:
/// - List and register ingestion pipeline configurations
/// - Update the run info of a configuration
/// - Inspect and register search indexes
///
/// Before running:
/// 1. Get your API key from https://console.mistral.ai/
/// 2. Set environment variable: export MISTRAL_API_KEY=your_api_key
void main() async {
  final client = MistralClient.fromEnvironment();

  try {
    await ingestionPipelineExample(client);
    await searchIndexExample(client);
  } finally {
    client.close();
  }
}

/// Demonstrates ingestion pipeline configuration operations.
Future<void> ingestionPipelineExample(MistralClient client) async {
  print('=== Ingestion Pipeline Configurations Example ===\n');

  // List existing configurations.
  final configs = await client.rag.ingestionPipelineConfigurations.list();
  print('Found ${configs.length} ingestion pipeline configurations.');

  // Register a new configuration.
  final config = await client.rag.ingestionPipelineConfigurations.register(
    request: const CreateIngestionPipelineConfigurationRequest(
      name: 'My ingestion pipeline',
      pipelineComposition: {'chunking': 'fixed_size'},
    ),
  );
  print('Registered configuration ${config.id} (${config.name}).');

  // Update the run info after a pipeline run.
  final updated = await client.rag.ingestionPipelineConfigurations
      .updateRunInfo(
        id: config.id,
        request: UpdateRunInfo(
          executionTime: DateTime.now().toUtc(),
          chunksCount: 128,
        ),
      );
  print('Last run produced ${updated.lastRunChunksCount} chunks.\n');
}

/// Demonstrates search index operations.
Future<void> searchIndexExample(MistralClient client) async {
  print('=== Search Index Example ===\n');

  // Inspect the registered search indexes.
  final indexes = await client.rag.searchIndexes.list();
  for (final index in indexes) {
    print(
      'Index ${index.name}: ${index.documentCount} documents '
      '(${index.status.value}).',
    );
  }

  // Register (or re-register) a search index.
  final index = await client.rag.searchIndexes.register(
    request: const CreateSearchIndexInfoRequest(
      name: 'My search index',
      status: SearchIndexStatus.offline,
      index: CreateVespaSearchIndexInfoRequest(
        k8sCluster: 'cluster',
        k8sNamespace: 'namespace',
        vespaInstanceName: 'instance',
        schemas: [CreateVespaSchemaRequest(name: 'documents')],
      ),
    ),
  );
  print('Registered search index ${index.id} (${index.name}).');
}
