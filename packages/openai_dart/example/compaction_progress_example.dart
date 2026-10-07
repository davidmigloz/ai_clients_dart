// ignore_for_file: avoid_print

/// Observe synthetic compaction progress with a local transport.
///
/// This example needs no API key, makes no live API calls and creates no large
/// context. The encrypted output is a fixture and is never printed.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  const request = CreateResponseRequest(
    model: 'gpt-6-astra',
    input: ResponseInput.text('Continue the demonstration conversation.'),
    contextManagement: [ContextManagement.compaction(compactThreshold: 200000)],
  );
  const item = CompactionOutputItem(
    id: 'cmp_local',
    encryptedContent: 'synthetic_encrypted_fixture',
  );
  final finalResponse = <String, dynamic>{
    'id': 'resp_local',
    'object': 'response',
    'created_at': 1,
    'status': 'completed',
    'model': 'gpt-6-astra',
    'output': [item.toJson()],
    'access_programs': null,
    'error': null,
    'incomplete_details': null,
    'instructions': null,
    'tools': <dynamic>[],
    'parallel_tool_calls': false,
    'metadata': <String, dynamic>{},
    'tool_choice': 'auto',
    'temperature': 1.0,
    'top_p': 1.0,
  };
  final events = <Map<String, dynamic>>[
    {
      'type': 'response.created',
      'sequence_number': 0,
      'response': {
        ...finalResponse,
        'status': 'in_progress',
        'output': <dynamic>[],
      },
    },
    {
      'type': 'response.output_item.added',
      'sequence_number': 1,
      'output_index': 0,
      'item': item.toJson(),
    },
    const ResponseCompactionCompactingEvent(
      sequenceNumber: 2,
      outputIndex: 0,
      itemId: 'cmp_local',
    ).toJson(),
    {
      'type': 'response.output_item.done',
      'sequence_number': 3,
      'output_index': 0,
      'item': item.toJson(),
    },
    {
      'type': 'response.completed',
      'sequence_number': 4,
      'response': finalResponse,
    },
  ];
  var sends = 0;
  final transport = MockClient((sent) async {
    sends++;
    if (sent.method != 'POST' ||
        sent.url.path != '/v1/responses' ||
        jsonEncode(jsonDecode(sent.body)) !=
            jsonEncode({...request.toJson(), 'stream': true})) {
      throw StateError('Unexpected local demonstration request.');
    }
    return http.Response(
      '${events.map((event) => 'data: ${jsonEncode(event)}\n\n').join()}'
      'data: [DONE]\n\n',
      200,
      headers: {'content-type': 'text/event-stream'},
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/v1',
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  final accumulator = ResponseStreamAccumulator();
  var progressCount = 0;
  try {
    await for (final event in client.responses.createStream(request)) {
      accumulator.add(event);
      switch (event) {
        case ResponseCompactionCompactingEvent(
          :final itemId,
          :final outputIndex,
        ):
          progressCount++;
          if (event.isFinal ||
              accumulator.isComplete ||
              accumulator.text.isNotEmpty) {
            throw StateError('Progress must remain nonterminal.');
          }
          print('Compacting $itemId at output index $outputIndex.');
        case ResponseCompletedEvent(:final response):
          if (response.output.whereType<CompactionOutputItem>().single !=
              item) {
            throw StateError('Opaque compaction output was not preserved.');
          }
          print('Response completed with its opaque compaction item intact.');
        default:
          break;
      }
    }
    if (progressCount != 1 || !accumulator.isSuccessful || sends != 1) {
      throw StateError('Incomplete local demonstration.');
    }
    print('One local request; no API charges or encrypted payload logs.');
  } finally {
    client.close();
    transport.close();
  }
}
