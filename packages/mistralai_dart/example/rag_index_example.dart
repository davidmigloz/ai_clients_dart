// ignore_for_file: avoid_print, unreachable_from_main
import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating the RAG API (Beta).
///
/// The RAG API lets you configure document ingestion pipelines and manage the
/// Vespa-backed search indexes used for retrieval.
///
/// This example shows how to:
/// - List and register ingestion pipeline configurations
/// - Update the run info of a configuration
/// - Register a search index and inspect its details
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

/// Demonstrates search index registration and inspection.
Future<void> searchIndexExample(MistralClient client) async {
  print('=== Search Index Example ===\n');

  // Register (or re-register) a Vespa-backed search index.
  final registered = await client.rag.searchIndexes.register(
    request: const RegisterSearchIndexRequest(
      name: 'My search index',
      status: SearchIndexStatus.offline,
      index: RegisterVespaIndexRequest(
        k8sCluster: 'cluster',
        k8sNamespace: 'namespace',
        vespaInstanceName: 'instance',
        vespaVersion: '8.0.0',
        queryUrl: 'https://vespa.example.com',
        schemas: [
          RegisterVespaSchemaRequest(
            name: 'documents',
            sd: 'schema documents { document documents { } }',
            fields: [
              RegisterVespaSchemaFieldRequest(
                name: 'embedding',
                type: SchemaFieldDataType.embedding,
                storage: SchemaFieldStorage.inMemory,
                ranking: SchemaFieldRankingType.embedding,
                indexType: SchemaFieldIndex.ann,
                multidimensional: true,
              ),
            ],
          ),
        ],
      ),
    ),
  );
  print('Registered search index ${registered.id}.');

  // Fetch detailed information about the index.
  final detail = await client.rag.searchIndexes.getDetail(
    indexId: registered.id,
  );
  print(
    'Index ${detail.name}: ${detail.documentCount} documents '
    '(${detail.status.value}).',
  );

  // List summaries of all registered search indexes.
  final summaries = await client.rag.searchIndexes.listSummaries();
  for (final summary in summaries) {
    print('  - ${summary.name} (${summary.status.value})');
  }

  // Unregister the search index (cleanup).
  await client.rag.searchIndexes.unregister(indexId: registered.id);
  print('Unregistered search index ${registered.id}.');
}
