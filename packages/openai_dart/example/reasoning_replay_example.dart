// ignore_for_file: avoid_print

/// Replay returned reasoning alongside function history with typed input.
/// All responses are synthetic; no API key or external service is used.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  var requests = 0;
  final mock = MockClient((request) async {
    if (request.method != 'POST' || request.url.path != '/v1/responses') {
      throw StateError('Unexpected local request');
    }
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    requests++;
    if (requests == 2) {
      final input = body['input'] as List;
      final reasoning = input[1] as Map;
      if (input.length != 4 ||
          reasoning['type'] != 'reasoning' ||
          reasoning['id'] != 'rs_fixture' ||
          reasoning['encrypted_content'] != 'opaque-fixture' ||
          reasoning['status'] != 'completed' ||
          (input[2] as Map)['type'] != 'function_call' ||
          (input[3] as Map)['call_id'] != 'call_fixture') {
        throw StateError('Typed replay lost reasoning or tool ordering');
      }
    } else if (requests != 1) {
      throw StateError('Unexpected extra request');
    }
    return http.Response(
      jsonEncode({
        'id': 'response_$requests',
        'object': 'response',
        'created_at': 1,
        'status': 'completed',
        'output': requests == 1
            ? [
                {
                  'type': 'reasoning',
                  'id': 'rs_fixture',
                  'summary': <dynamic>[],
                  'content': [
                    {
                      'type': 'reasoning_text',
                      'text': 'Synthetic provider context.',
                    },
                  ],
                  'encrypted_content': 'opaque-fixture',
                  'status': 'completed',
                },
                {
                  'type': 'function_call',
                  'id': 'fc_fixture',
                  'call_id': 'call_fixture',
                  'name': 'status',
                  'arguments': '{}',
                  'status': 'completed',
                },
              ]
            : [
                {
                  'type': 'message',
                  'id': 'msg_fixture',
                  'role': 'assistant',
                  'status': 'completed',
                  'content': [
                    {
                      'type': 'output_text',
                      'text': 'Ready.',
                      'annotations': <dynamic>[],
                    },
                  ],
                },
              ],
      }),
      200,
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(baseUrl: 'https://example.invalid/v1'),
    httpClient: mock,
  );
  try {
    final history = <Item>[MessageItem.userText('Check synthetic status.')];
    final first = await client.responses.create(
      CreateResponseRequest(
        model: 'fixture',
        store: false,
        input: ResponseInput.items(history),
      ),
    );
    // Preserve returned item order. Convert only the known types in this example;
    // this is an explicit tool turn, not an automatic output/tool dispatcher.
    for (final item in first.output) {
      history.add(switch (item) {
        final ReasoningItem reasoning => reasoning.toInput(),
        final FunctionCallOutputItemResponse call => call.toFunctionCallItem(),
        _ => throw StateError('Unexpected synthetic output'),
      });
    }
    final call = first.functionCalls.single;
    if (call.name != 'status' || call.argumentsMap.isNotEmpty) {
      throw StateError('Unexpected synthetic tool call');
    }
    // A real application validates and executes its own allowed tool here.
    history.add(
      FunctionCallOutputItem.string(callId: call.callId, output: 'healthy'),
    );
    final second = await client.responses.create(
      CreateResponseRequest(
        model: 'fixture',
        store: false,
        input: ResponseInput.items(history),
      ),
    );
    if (requests != 2 || second.outputText != 'Ready.') {
      throw StateError('Unexpected synthetic continuation');
    }
    print(
      'Typed reasoning and tool history replayed in order: ${second.outputText}',
    );
    print('Two mocked requests; API cost: 0.');
  } finally {
    client.close();
    mock.close();
  }
}
