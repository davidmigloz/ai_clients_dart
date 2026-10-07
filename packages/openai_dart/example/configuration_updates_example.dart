/// Persistent reasoning updates with a local transport; no API key or charges.
// ignore_for_file: avoid_print

library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  const baseline = ReasoningConfig(effort: ReasoningEffort.low);
  const instructions = 'Help plan a safe database migration.';
  var requests = 0;
  var effectiveEffort = 'low';
  final appliedEfforts = <String>[];
  final transport = MockClient((request) async {
    if (request.method != 'POST' || request.url.path != '/v1/responses') {
      throw StateError('Unexpected local example request');
    }
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    if (body['reasoning'] is! Map ||
        (body['reasoning'] as Map)['effort'] != 'low' ||
        body['instructions'] != instructions) {
      throw StateError('Keep request-level effort and instructions stable');
    }
    requests++;
    if (requests > 1 &&
        body['previous_response_id'] != 'resp_${requests - 1}') {
      throw StateError('Continue from the latest response');
    }
    final input = body['input'] as List<dynamic>;
    final updates = input.where(
      (dynamic item) => (item as Map)['type'] == 'configuration_update',
    );
    if (updates.isNotEmpty) {
      final update = updates.single as Map;
      if ((input.last as Map)['type'] != 'message') {
        throw StateError('Place the update before the next user message');
      }
      effectiveEffort = (update['reasoning'] as Map)['effort'] as String;
    }
    appliedEfforts.add(effectiveEffort);
    // This transport simulates persistence. A real API applies the update.
    // Response.reasoning still reports the unchanged request-level setting.
    return http.Response(
      jsonEncode({
        'object': 'response',
        'id': 'resp_$requests',
        'model': body['model'],
        'created_at': 1,
        'status': 'completed',
        'error': null,
        'incomplete_details': null,
        'instructions': instructions,
        'reasoning': body['reasoning'],
        'tools': <Object?>[],
        'output': <Object?>[],
        'parallel_tool_calls': true,
        'metadata': <String, dynamic>{},
        'tool_choice': 'auto',
        'temperature': 1.0,
        'top_p': 1.0,
        'access_programs': null,
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/v1',
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  try {
    var response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-6-astra',
        reasoning: baseline,
        instructions: instructions,
        input: ResponseInput.items([
          MessageItem.userText('Draft a migration plan.'),
        ]),
      ),
    );
    response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-6-astra',
        reasoning: baseline,
        instructions: instructions,
        previousResponseId: response.id,
        input: ResponseInput.items([
          const ConfigurationUpdateItem(
            reasoning: ConfigurationUpdateReasoning(
              effort: ReasoningEffort.high,
            ),
          ),
          MessageItem.userText('Analyze failure modes and rollback steps.'),
        ]),
      ),
    );
    response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-6-astra',
        reasoning: baseline,
        instructions: instructions,
        previousResponseId: response.id,
        input: ResponseInput.items([
          MessageItem.userText(
            'Check whether the rollback plan covers outages.',
          ),
        ]),
      ),
    );
    response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-6-astra',
        reasoning: baseline,
        instructions: instructions,
        previousResponseId: response.id,
        input: ResponseInput.items([
          const ConfigurationUpdateItem(
            reasoning: ConfigurationUpdateReasoning(
              effort: ReasoningEffort.low,
            ),
          ),
          MessageItem.userText('Summarize the approved checklist.'),
        ]),
      ),
    );
    if (appliedEfforts.join(',') != 'low,high,high,low' ||
        response.reasoning?.effort != baseline.effort ||
        requests != 4) {
      throw StateError('Unexpected local reasoning continuation');
    }
    print('Simulated effort per turn: ${appliedEfforts.join(', ')}.');
    print('Reported request-level effort remains ${baseline.effort?.value}.');
    print('Completed ${response.id}; $requests local requests, no API cost.');
  } finally {
    client.close();
    transport.close();
  }
}
