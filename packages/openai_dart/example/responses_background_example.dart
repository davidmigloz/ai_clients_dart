// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

/// Schedules a discounted response and inspects its result with a mock HTTP
/// transport. This example makes no live calls.
Future<void> main() async {
  final transport = MockClient((request) async {
    final queued = request.method == 'POST';
    if (queued) {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      print('Scheduling options: ${body['background_options']}');
    }
    return http.Response(
      jsonEncode({
        'id': 'resp_example',
        'object': 'response',
        'created_at': 1,
        'status': queued ? 'queued' : 'completed',
        'background': true,
        'output': <Object>[],
        if (!queued) ...{
          'input_transformations': [
            {
              'type': 'reasoning',
              'action': 'removed',
              'id': 'rs_example',
              'reason': 'model_mismatch',
            },
          ],
          'usage': {
            'input_tokens': 12,
            'output_tokens': 1,
            'total_tokens': 13,
            'input_tokens_details': {
              'cached_tokens': 0,
              'cache_write_tokens': 10,
              'cache_write_tokens_details': {
                'ttl_30m_tokens': 0,
                'ttl_12h_tokens': 10,
              },
            },
          },
        },
      }),
      200,
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(authProvider: ApiKeyProvider('fixture')),
    httpClient: transport,
  );
  try {
    final queued = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-6.2-sol',
        input: ResponseInput.text('Summarize the release notes.'),
        serviceTier: ServiceTier.defaultTier,
        background: true,
        backgroundOptions: BackgroundOptions(
          completionWindow: BackgroundCompletionWindow.twoHours,
          continuationId: 'release-notes',
        ),
        promptCacheOptions: ResponsePromptCacheOptionsParam(
          ttl: ResponsePromptCacheTtl.hours12,
        ),
      ),
    );
    // With a live service, poll with a delay until the status is terminal.
    final response = await client.responses.retrieve(queued.id);
    print('Status: ${response.status.name}');
    for (final item
        in response.inputTransformations ??
            const <ReasoningInputTransformation>[]) {
      print('Withheld reasoning: ${item.reason.value}');
    }
    final writes = response.usage?.inputTokensDetails?.cacheWriteTokensDetails;
    print('12-hour writes: ${writes?.ttl12hTokens}');
  } finally {
    client.close();
    transport.close();
  }
}
