// ignore_for_file: avoid_print
/// Offline Decisions GA: JSON, captured tool history, multimodal criteria, cache.
///
/// Run: dart run example/decisions_ga_example.dart
/// One MockClient POST, no API key, image download, tool execution or API cost.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  var sends = 0;
  final transport = MockClient((request) async {
    sends++;
    if (request.method != 'POST' || request.url.path != '/v1/decisions') {
      throw StateError('Expected a mock Decisions POST.');
    }
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    final input = body['input'] as List<dynamic>;
    final questions = body['questions'] as List<dynamic>;
    if (input.length != 4 ||
        (questions.single as Map<String, dynamic>)['instructions'] is! List ||
        (body['prompt_cache_options'] as Map<String, dynamic>)['ttl'] !=
            '30m') {
      throw StateError('GA history, multimodal instructions or cache lost.');
    }
    return http.Response(
      jsonEncode({
        'model': 'gpt-6-luna',
        'answers': [
          {'type': 'predicate', 'name': 'replace', 'probability': 0.92},
        ],
        'usage': {
          'input_tokens': 120,
          'output_tokens': 2,
          'total_tokens': 122,
          'input_tokens_details': {'cached_tokens': 0, 'cache_write_tokens': 0},
          'output_tokens_details': {'reasoning_tokens': 0},
        },
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/v1',
      authProvider: ApiKeyProvider('synthetic-decisions-key'),
    ),
    httpClient: transport,
  );
  try {
    final response = await client.decisions.create(
      DecisionRequest(
        model: 'gpt-6-luna',
        input: DecisionInput.items([
          DeveloperDecisionInputMessage(
            content: DecisionDeveloperContent.parts(const [
              TextDecisionInputPart(
                'Replace damaged orders delivered within 30 days.',
                promptCacheBreakpoint: DecisionPromptCacheBreakpoint(),
              ),
            ]),
          ),
          DecisionInputMessage(
            content: DecisionContent.parts([
              DecisionInputPart.json(const {
                'order': 'example-order',
                'age_days': 3,
              }),
              const DecisionInputPart.text('The screen arrived broken.'),
            ]),
          ),
          // Captured evidence only: Decisions never invokes this function.
          DecisionFunctionCall(
            callId: 'lookup_1',
            name: 'orders.lookup',
            arguments: '{"order":"example-order"}',
            status: DecisionToolStatus.completed,
          ),
          DecisionFunctionCallOutput(
            callId: 'lookup_1',
            output: const DecisionToolOutput.text('Delivered three days ago.'),
            status: DecisionToolStatus.completed,
          ),
        ]),
        questions: [
          DecisionQuestion.predicateWithInstructions(
            name: 'replace',
            instructions: DecisionInstructions.parts([
              const DecisionQuestionPart.text('Is replacement allowed?'),
              DecisionQuestionPart.json(const {'maximum_age_days': 30}),
              // A reference image belongs to this question, outside the cache.
              DecisionQuestionPart.image(
                imageUrl: 'https://example.invalid/reference.png',
                detail: ImageDetail.low,
              ),
            ]),
          ),
        ],
        promptCacheKey: 'example-tenant',
        promptCacheOptions: const DecisionPromptCacheOptions(
          ttl: DecisionCacheTtl.thirtyMinutes,
          mode: DecisionCacheMode.explicit,
        ),
      ),
    );
    if (sends != 1) throw StateError('Expected exactly one mock POST.');
    switch (response.answers.single) {
      case PredicateDecisionAnswer(:final probability):
        print('Replacement probability (synthetic): $probability');
      case RefusalDecisionAnswer():
        print('The question was refused.');
      default:
        throw StateError('Unexpected answer variant.');
    }
    print('GA request completed offline; no charges or tool execution.');
  } finally {
    client.close();
    transport.close();
  }
}
