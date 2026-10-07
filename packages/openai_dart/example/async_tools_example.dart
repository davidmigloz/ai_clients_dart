/// Async function/custom tools with a local transport; no API key or charges.
// ignore_for_file: avoid_print

library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final tools = <ResponseTool>[
    ResponseTool.function(
      name: 'get_weather',
      description: 'Look up the weather while independent work continues.',
      async: true,
      allowedCallers: const [CallableToolAllowedCaller.direct],
      strict: true,
      parameters: const {
        'type': 'object',
        'properties': {
          'city': {'type': 'string'},
        },
        'required': ['city'],
        'additionalProperties': false,
      },
    ),
    ResponseTool.custom(
      name: 'summarize_report',
      async: true,
      allowedCallers: const [CallableToolAllowedCaller.direct],
      format: const {'type': 'text'},
    ),
  ];
  const instructions = 'Use async direct calls for independent work.';
  var requests = 0;
  final transport = MockClient((request) async {
    if (request.method != 'POST' || request.url.path != '/v1/responses') {
      throw StateError('Unexpected local example request');
    }
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    final definitions = body['tools'] as List<dynamic>;
    if (definitions.any((dynamic tool) => (tool as Map)['async'] != true)) {
      throw StateError('Both tools must carry async: true');
    }
    requests++;
    final output = switch (requests) {
      1 => <OutputItem>[
        const FunctionCallOutputItemResponse(
          id: 'fc_weather',
          callId: 'call_weather',
          name: 'get_weather',
          arguments: '{"city":"Paris"}',
          status: ItemStatus.completed,
          async: true,
        ),
        const CustomToolCallItem(
          id: 'ct_summary',
          callId: 'call_summary',
          name: 'summarize_report',
          status: ItemStatus.completed,
          input: 'Summarize the example report.',
          async: true,
        ),
      ],
      2 => <OutputItem>[],
      3 => <OutputItem>[],
      _ => throw StateError('Unexpected additional request'),
    };
    if (requests == 2 && body['previous_response_id'] != 'resp_1') {
      throw StateError(
        'Intermediate work must continue from the first response',
      );
    }
    if (requests == 3) {
      final results = (body['input'] as List<dynamic>)
          .map((value) => value as Map<String, dynamic>)
          .toList();
      if (body['previous_response_id'] != 'resp_2' ||
          results[0]['call_id'] != 'call_weather' ||
          results[1]['call_id'] != 'call_summary') {
        throw StateError(
          'Results need original call IDs and latest response ID',
        );
      }
    }
    return http.Response(
      jsonEncode({
        'object': 'response',
        'id': 'resp_$requests',
        'model': body['model'],
        'created_at': 1,
        'status': 'completed',
        'error': null,
        'incomplete_details': null,
        'instructions': body['instructions'],
        'tools': definitions,
        'output': output.map((item) => item.toJson()).toList(),
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
        input: const ResponseInput.text('Start weather and report work.'),
        tools: tools,
        instructions: instructions,
      ),
    );
    final weatherCall = response.output
        .whereType<FunctionCallOutputItemResponse>()
        .single;
    final summaryCall = response.output.whereType<CustomToolCallItem>().single;
    print('Async flags: ${weatherCall.async}, ${summaryCall.async}');

    // Your application owns execution and keeps each job's original call ID.
    // Completers stand in for jobs that are still running in this local demo.
    final weatherJob = Completer<Map<String, dynamic>>();
    final summaryJob = Completer<String>();
    response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-6-astra',
        previousResponseId: response.id,
        input: const ResponseInput.text(
          'Do independent work while those jobs finish.',
        ),
        tools: tools,
        instructions: instructions,
      ),
    );
    final latestResponseId = response.id;
    weatherJob.complete({
      'city': weatherCall.argumentsMap['city'],
      'celsius': 24,
    });
    summaryJob.complete('The example report is ready.');

    final completed = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-6-astra',
        previousResponseId: latestResponseId,
        input: ResponseInput.items([
          FunctionCallOutputItem(
            callId: weatherCall.callId,
            output: FunctionCallOutputString(
              jsonEncode(await weatherJob.future),
            ),
          ),
          CustomToolCallOutputInputItem(
            callId: summaryCall.callId,
            output: FunctionCallOutputString(await summaryJob.future),
          ),
        ]),
        tools: tools,
        instructions: instructions,
      ),
    );
    print('Returned original call IDs against $latestResponseId.');
    print('Completed ${completed.id}; $requests local requests, no API cost.');
  } finally {
    client.close();
    transport.close();
  }
}
