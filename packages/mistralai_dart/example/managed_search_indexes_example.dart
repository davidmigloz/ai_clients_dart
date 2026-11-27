// ignore_for_file: avoid_print
import 'package:mistralai_dart/mistralai_dart.dart';

/// Searches a ready Mistral-hosted index using a workspace API key.
Future<void> main(List<String> args) async {
  if (args.length != 2 || args.contains('--help')) {
    print(
      'Usage: dart run example/managed_search_indexes_example.dart '
      '<index name> <query>',
    );
    print('Set MISTRAL_API_KEY to a key with access to the index.');
    return;
  }

  final client = MistralClient.fromEnvironment();
  try {
    final index = await client.managedSearchIndexes.get(indexName: args[0]);
    if (index.status != ManagedSearchIndexStatus.ready) {
      print('Index is ${index.status.value}.');
      return;
    }
    final result = await client.managedSearchIndexes.search(
      indexName: index.name,
      request: ManagedSearchRequest(
        retriever: KeywordRetriever(query: args[1], topK: 5),
      ),
    );
    for (final hit in result.hits) {
      print('${hit.score} ${hit.chunk.content}');
    }
  } finally {
    client.close();
  }
}
