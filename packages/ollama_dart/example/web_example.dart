// ignore_for_file: avoid_print
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

/// Hosted web search and fetch require an Ollama API key.
/// Set OLLAMA_API_KEY before running this example.
Future<void> main() async {
  final apiKey = Platform.environment['OLLAMA_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('Set OLLAMA_API_KEY to use hosted web search and fetch.');
    exitCode = 64;
    return;
  }

  // The host is explicit: web methods use the configured client's base URL.
  final client = OllamaClient.withApiKey(apiKey, baseUrl: 'https://ollama.com');

  try {
    final response = await client.web.search(
      request: const WebSearchRequest(query: 'Dart isolates', maxResults: 3),
    );
    for (final result in response.results ?? <WebSearchResult>[]) {
      print('${result.title}: ${result.url}');
      print(result.content);
    }

    final page = await client.web.fetch(
      request: const WebFetchRequest(url: 'https://dart.dev'),
    );
    print('\nPage: ${page.title}');
    print(page.content);
    print('Links: ${page.links?.length ?? 0}');
  } finally {
    client.close();
  }
}
