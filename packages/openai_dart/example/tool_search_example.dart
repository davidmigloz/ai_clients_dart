// ignore_for_file: avoid_print

/// Return complete client-discovered tools using the original search call ID.
///
/// Both responses are local fixtures. No API key, live search, or tool execution
/// is required, and no arguments or tool schemas are printed.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  const request = CreateResponseRequest(
    model: 'gpt-6-sol',
    input: ResponseInput.text('Find the inventory tools.'),
    tools: [
      ToolSearchTool(
        execution: ToolSearchExecutionType.client,
        description: 'Search a local tool catalog.',
        parameters: {
          'type': 'object',
          'properties': {
            'goal': {'type': 'string'},
          },
          'required': ['goal'],
          'additionalProperties': false,
        },
      ),
    ],
    parallelToolCalls: false,
  );
  const discovered = NamespaceTool(
    name: 'inventory',
    description: 'Inventory tools from a local catalog.',
    tools: [
      FunctionTool(
        name: 'get.status',
        description: 'Read inventory status.',
        parameters: {
          'type': 'object',
          'properties': {
            'item': {'type': 'string'},
          },
          'required': ['item'],
          'additionalProperties': false,
        },
        strict: true,
        outputSchema: {'type': 'object'},
        deferLoading: false,
        allowedCallers: [CallableToolAllowedCaller.direct],
        async: false,
      ),
      // Nested discovered functions may contain only their name and type.
      FunctionTool(name: 'lookup.item'),
      CustomTool(
        name: 'describe',
        description: 'Describe an inventory item.',
        format: {'type': 'text'},
        deferLoading: false,
        allowedCallers: [CallableToolAllowedCaller.direct],
        async: true,
      ),
    ],
  );
  const originalCallId = 'search_local_1';
  var sends = 0;
  final transport = MockClient((sent) async {
    sends++;
    if (sent.method != 'POST' || sent.url.path != '/v1/responses') {
      throw StateError('Unexpected local request destination.');
    }
    final body = jsonDecode(sent.body) as Map<String, dynamic>;
    final List<Map<String, dynamic>> output;
    if (sends == 1) {
      if (jsonEncode(body) != jsonEncode(request.toJson())) {
        throw StateError('Unexpected initial search request.');
      }
      output = [
        {
          'type': 'tool_search_call',
          'id': 'tsc_local_1',
          'call_id': originalCallId,
          'execution': 'client',
          'arguments': {'goal': 'inventory'},
          'status': 'completed',
          'created_by': 'local_fixture',
        },
      ];
    } else if (sends == 2) {
      const expectedResult = ToolSearchOutputItemParam(
        callId: originalCallId,
        execution: ToolSearchExecutionType.client,
        tools: [discovered],
        status: ItemStatus.completed,
      );
      final expected = CreateResponseRequest(
        model: request.model,
        previousResponseId: 'resp_local_1',
        input: const ResponseInput.items([expectedResult]),
      );
      if (jsonEncode(body) != jsonEncode(expected.toJson())) {
        throw StateError('Search continuation lost its ID or definitions.');
      }
      output = [
        {
          ...expectedResult.toJson(),
          'id': 'tso_local_1',
          'created_by': 'local_fixture',
        },
      ];
    } else {
      throw StateError('Unexpected extra local request.');
    }
    return http.Response(
      jsonEncode({
        'id': 'resp_local_$sends',
        'object': 'response',
        'created_at': 1,
        'status': 'completed',
        'model': request.model,
        'output': output,
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
    final first = await client.responses.create(request);
    final call = first.output.whereType<ToolSearchCallOutputItem>().single;
    final callId = call.callId;
    if (call.execution != ToolSearchExecutionType.client || callId == null) {
      throw StateError('Expected a client search call with an ID.');
    }
    // Returned arguments may be any JSON value: check before indexing them.
    final arguments = call.arguments;
    if (arguments is! Map<String, dynamic> ||
        arguments['goal'] != 'inventory') {
      throw StateError('Unexpected local catalog query.');
    }
    final second = await client.responses.create(
      CreateResponseRequest(
        model: request.model,
        previousResponseId: first.id,
        input: ResponseInput.items([
          ToolSearchOutputItemParam(
            callId: callId,
            execution: ToolSearchExecutionType.client,
            tools: const [discovered],
            status: ItemStatus.completed,
          ),
        ]),
      ),
    );
    final loaded = second.output.whereType<ToolSearchOutputItem>().single;
    if (sends != 2 ||
        loaded.callId != originalCallId ||
        loaded.execution != ToolSearchExecutionType.client ||
        loaded.tools.single != discovered ||
        loaded.createdBy == null) {
      throw StateError('Returned search metadata or tools were not preserved.');
    }
    print('Returned ${discovered.tools.length} tools for $originalCallId.');
    print('Two local requests; no API charges or tool execution.');
  } finally {
    client.close();
    transport.close();
  }
}
