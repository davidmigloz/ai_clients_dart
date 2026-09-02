// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Search result content blocks example (RAG / agentic search citations).
///
/// This example demonstrates how to supply your own cited `search_result`
/// content blocks so Claude can ground its answer in them and return
/// `search_result_location` citations pointing back at the exact blocks it used.
///
/// Use this when you run your own retrieval/RAG system and want Claude to cite
/// the passages you provide (rather than the built-in web search tool).
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Build a search_result block from passages your retrieval system returned.
    // Each passage is a citable TextInputBlock; set `citations.enabled` so the
    // model is allowed to cite this result.
    final searchResult = InputContentBlock.searchResult(
      source: 'kb://astronomy/solar-system',
      title: 'Solar System Facts',
      citations: const RequestCitationsConfig(enabled: true),
      content: const [
        TextInputBlock('Earth is the third planet from the Sun.'),
        TextInputBlock(
          'Earth completes one orbit of the Sun every 365.25 days.',
        ),
        TextInputBlock("The Moon is Earth's only natural satellite."),
      ],
    );

    print('=== Request: search_result content block ===');
    print(searchResult.toJson());

    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5',
        maxTokens: 1024,
        messages: [
          InputMessage.userBlocks([
            searchResult,
            InputContentBlock.text('How long is one Earth year?'),
          ]),
        ],
      ),
    );

    // Read the answer and any citations Claude attached to its text.
    print('\n=== Response ===');
    for (final block in response.content) {
      if (block is TextBlock) {
        print(block.text);
        for (final citation in block.citations ?? const <Citation>[]) {
          if (citation is SearchResultLocationCitation) {
            print(
              '  ↳ cited "${citation.citedText}" from '
              '${citation.source} (blocks '
              '${citation.startBlockIndex}..${citation.endBlockIndex})',
            );
          }
        }
      }
    }

    // You can also pre-attach per-citation locations to text you send — for
    // example, when replaying an earlier turn. These use the request-side
    // citation types (the `InputCitation` family):
    print('\n=== Supplying your own per-citation locations ===');
    const citedText = TextInputBlock(
      'Earth completes one orbit of the Sun every 365.25 days.',
      citations: [
        SearchResultLocationInputCitation(
          citedText: 'Earth completes one orbit of the Sun every 365.25 days.',
          searchResultIndex: 0,
          source: 'kb://astronomy/solar-system',
          title: 'Solar System Facts',
          startBlockIndex: 1,
          endBlockIndex: 2,
        ),
      ],
    );
    print(citedText.toJson());
  } finally {
    client.close();
  }
}
