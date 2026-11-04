// ignore_for_file: avoid_print
/// Offline per-breakpoint caching and hosted-tool usage.
///
/// Run: dart run example/responses_cache_usage_example.dart
/// One mock POST; no API key, hosted tools or API charges.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  var sends = 0;
  final transport = MockClient((request) async {
    sends++;
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    final items = body['input'] as List<dynamic>;
    final content =
        (items.single as Map<String, dynamic>)['content'] as List<dynamic>;
    final marker =
        (content.first as Map<String, dynamic>)['prompt_cache_breakpoint']
            as Map<String, dynamic>;
    if (request.url.path != '/v1/responses' || marker['ttl'] != '12h') {
      throw StateError('Expected the shared-prefix breakpoint override.');
    }
    return http.Response(
      jsonEncode({
        'access_programs': null,
        'id': 'resp_example',
        'object': 'response',
        'created_at': 0,
        'status': 'completed',
        'model': 'gpt-6-luna',
        'error': null,
        'incomplete_details': null,
        'instructions': null,
        'tools': <Object>[],
        'output': <Object>[],
        'parallel_tool_calls': false,
        'metadata': <String, String>{},
        'tool_choice': 'auto',
        'temperature': 1.0,
        'top_p': 1.0,
        'usage': {
          'input_tokens': 100,
          'output_tokens': 2,
          'total_tokens': 102,
          'input_tokens_details': {
            'cached_tokens': 0,
            'cache_write_tokens': 100,
          },
          'output_tokens_details': {'reasoning_tokens': 0},
        },
        'tool_usage': {
          'image_gen': {
            'input_tokens': 10,
            'output_tokens': 20,
            'total_tokens': 30,
            'input_tokens_details': {'text_tokens': 3, 'image_tokens': 7},
          },
          'web_search': {'num_requests': 1},
        },
      }),
      200,
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/v1',
      authProvider: ApiKeyProvider('synthetic-key'),
    ),
    httpClient: transport,
  );
  try {
    final response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-6-luna',
        input: ResponseInput.items([
          MessageItem.user(const [
            InputTextContent(
              'Stable reference material reused throughout the day.',
              promptCacheBreakpoint: PromptCacheBreakpointConfig(
                ttl: PromptCacheBreakpointTtl.hours12,
              ),
            ),
            InputTextContent(
              'Session context changes more often.',
              promptCacheBreakpoint: PromptCacheBreakpointConfig(),
            ),
            InputTextContent('Current question, after the last cached prefix.'),
          ]),
        ]),
        // The pinned top-level schema/SDK only allow 30m. The breakpoint above
        // independently supports the documented 12h override. Decisions has its
        // own cache type and does not accept a TTL override on its markers.
        promptCacheOptions: const ResponsePromptCacheOptionsParam(
          ttl: PromptCacheTtl.minutes30,
          mode: PromptCacheMode.explicit,
        ),
      ),
    );
    if (sends != 1) throw StateError('Expected one mock POST.');
    print('Base-model input tokens: ${response.usage?.inputTokens}');
    final tools = response.toolUsage;
    if (tools != null) {
      print('Hosted image tokens: ${tools.imageGen.totalTokens}');
      print(
        'Image cache count: ${tools.imageGen.cachedTokens?.toString() ?? 'unknown'}',
      );
      print('Billable web searches: ${tools.webSearch.numRequests}');
    }
    print('Synthetic counts only; one offline request, no API charges.');
  } finally {
    client.close();
    transport.close();
  }
}
