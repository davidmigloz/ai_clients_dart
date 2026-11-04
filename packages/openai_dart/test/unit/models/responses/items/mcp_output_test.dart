import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

class DerivedMcpError extends McpProtocolError {
  const DerivedMcpError({required super.code, required super.message});
}

void main() {
  final items = <Map<String, dynamic>>[
    {
      'type': 'mcp_call',
      'id': 'call',
      'arguments': '{}',
      'name': 'search',
      'server_label': 'docs',
      'approval_request_id': 'approval',
      'status': 'calling',
      'output': 'found',
    },
    {
      'type': 'mcp_list_tools',
      'id': 'list',
      'server_label': 'docs',
      'tools': [
        {
          'name': 'search',
          'input_schema': {
            'type': 'object',
            'properties': {
              'x': {'type': 'string'},
            },
          },
          'annotations': {'readOnlyHint': true},
          'description': 'Search',
        },
      ],
    },
    {
      'type': 'mcp_approval_request',
      'id': 'approval',
      'arguments': '{}',
      'name': 'search',
      'server_label': 'docs',
    },
    {
      'type': 'mcp_approval_response',
      'id': 'decision',
      'approval_request_id': 'approval',
      'approve': true,
      'reason': 'allowed',
    },
  ];
  test('native output items round trip through both public entry points', () {
    for (final json in items) {
      final item = OutputItem.fromJson(json);
      expect(item.toJson(), json);
      expect(item, OutputItem.fromJson(json));
      expect(item.hashCode, OutputItem.fromJson(json).hashCode);
      final response = Response.fromJson({
        'id': 'r',
        'object': 'response',
        'created_at': 1,
        'status': 'completed',
        'output': [json],
      });
      expect(response.output.single, item);
      expect(response.output.single.toJson(), json);
      expect(item.toString(), isNot(contains('approval')));
    }
  });
  test('preserves producing agent and supports clearing it', () {
    for (final json in items) {
      final item = OutputItem.fromJson({
        ...json,
        'agent': {'agent_name': 'worker'},
      });
      expect(item.toJson()['agent'], {'agent_name': 'worker'});
    }
    final call =
        OutputItem.fromJson({
              ...items.first,
              'agent': {'agent_name': 'worker'},
            })
            as McpCallOutputItem;
    expect(call.copyWith(agent: null).agent, isNull);
    expect(call, isNot(call.copyWith(name: 'other')));
  });
  test('all native statuses and structured errors round trip', () {
    for (final status in [
      'in_progress',
      'calling',
      'completed',
      'incomplete',
      'failed',
    ]) {
      final item = OutputItem.fromJson({...items.first, 'status': status});
      expect(item.toJson()['status'], status);
    }
    for (final error in [
      {'type': 'mcp_protocol_error', 'code': -1, 'message': 'private'},
      {'type': 'http_error', 'code': 403, 'message': 'private'},
      {
        'type': 'mcp_tool_execution_error',
        'content': [
          {'text': 'private'},
        ],
      },
    ]) {
      final item = OutputItem.fromJson({...items.first, 'error': error});
      expect(item.toJson()['error'], error);
      expect(item, OutputItem.fromJson(item.toJson()));
      expect(item.hashCode, OutputItem.fromJson(item.toJson()).hashCode);
      expect(
        (item as McpCallOutputItem).error.toString(),
        isNot(contains('private')),
      );
      expect(item.copyWith(error: null).error, isNull);
    }
  });
  test(
    'copyWith clears optional fields and rejects malformed required data',
    () {
      final call = OutputItem.fromJson(items.first) as McpCallOutputItem;
      expect(
        call
            .copyWith(approvalRequestId: null, status: null, output: null)
            .toJson(),
        {
          'type': 'mcp_call',
          'id': 'call',
          'arguments': '{}',
          'name': 'search',
          'server_label': 'docs',
        },
      );
      final list = OutputItem.fromJson(items[1]) as McpListToolsOutputItem;
      expect(
        list.tools.single
            .copyWith(description: null, annotations: null)
            .description,
        isNull,
      );
      final response =
          OutputItem.fromJson(items.last) as McpApprovalResponseOutputItem;
      expect(response.copyWith(reason: null).reason, isNull);
      expect(
        () => OutputItem.fromJson({'type': 'mcp_call', 'id': 'x'}),
        throwsFormatException,
      );
      expect(
        () => McpToolDescriptor.fromJson(const {'name': 'x'}),
        throwsFormatException,
      );
      expect(
        McpCallError.fromJson({'type': 'other'}),
        isA<UnknownMcpCallError>(),
      );
    },
  );
  test('parsed nested JSON and tool lists are immutable snapshots', () {
    final schema = <String, dynamic>{
      'nested': <dynamic>[
        {'x': 1},
      ],
    };
    final annotations = <String, dynamic>{
      'tags': <dynamic>['a'],
    };
    final tools = <dynamic>[
      {'name': 'x', 'input_schema': schema, 'annotations': annotations},
    ];
    final item =
        OutputItem.fromJson({
              'type': 'mcp_list_tools',
              'id': 'l',
              'server_label': 's',
              'tools': tools,
            })
            as McpListToolsOutputItem;
    final hash = item.hashCode;
    (schema['nested'] as List).add(2);
    (annotations['tags'] as List).add('b');
    tools.clear();
    expect(item.hashCode, hash);
    expect((item.tools.single.inputSchema! as Map)['nested'], [
      {'x': 1},
    ]);
    expect(item.tools.clear, throwsUnsupportedError);
    expect(
      () => ((item.tools.single.annotations! as Map)['tags'] as List).add('c'),
      throwsUnsupportedError,
    );
    expect(item.copyWith().hashCode, hash);
    final content = <Map<String, dynamic>>[
      {
        'a': <dynamic>[1],
      },
    ];
    final error =
        McpCallError.fromJson({
              'type': 'mcp_tool_execution_error',
              'content': content,
            })
            as McpToolExecutionError;
    final errorHash = error.hashCode;
    (content.first['a'] as List).add(2);
    expect(error.hashCode, errorHash);
    expect(() => (error.content! as List).clear(), throwsUnsupportedError);
    expect(error.copyWith().hashCode, errorHash);
  });
  test('leaf decoders reject wrong discriminator and malformed fields', () {
    expect(
      () => McpCallOutputItem.fromJson({...items.first, 'type': 'other'}),
      throwsFormatException,
    );
    expect(
      () => McpProtocolError.fromJson(const {
        'type': 'http_error',
        'code': 1,
        'message': 'x',
      }),
      throwsFormatException,
    );
    expect(
      () => McpApprovalResponseOutputItem.fromJson({
        ...items.last,
        'approve': 'yes',
      }),
      throwsFormatException,
    );
    expect(
      () => McpListToolsOutputItem.fromJson({...items[1], 'tools': 'bad'}),
      throwsFormatException,
    );
  });
  test(
    'raw output replay is valid ResponseInput without typed input models',
    () {
      final json = items.map((e) => OutputItem.fromJson(e).toJson()).toList();
      expect(ResponseInput.fromOutputItems(json).toJson(), json);
    },
  );
  test('base values are not equal to subclass instances', () {
    const base = McpProtocolError(code: 1, message: 'error');
    const derived = DerivedMcpError(code: 1, message: 'error');
    expect(base == derived, isFalse);
    expect(derived == base, isFalse);
  });
  test('responses.create continues a native MCP approval over HTTP', () async {
    final requests = <Map<String, dynamic>>[];
    final mock = MockClient((request) async {
      requests.add(jsonDecode(request.body) as Map<String, dynamic>);
      return http.Response(
        jsonEncode({
          'id': requests.length == 1 ? 'first-response' : 'second-response',
          'object': 'response',
          'created_at': 1,
          'status': 'completed',
          'output': requests.length == 1 ? items : [items.first],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final client = OpenAIClient(
      config: const OpenAIConfig(
        authProvider: ApiKeyProvider('fixture-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: mock,
    );
    addTearDown(client.close);
    final first = await client.responses.create(
      const CreateResponseRequest(
        model: 'fixture',
        input: ResponseInput.text('Search'),
      ),
    );
    expect(first.output.map((item) => item.runtimeType), [
      McpCallOutputItem,
      McpListToolsOutputItem,
      McpApprovalRequestOutputItem,
      McpApprovalResponseOutputItem,
    ]);
    final approval = first.output
        .whereType<McpApprovalRequestOutputItem>()
        .single;
    final second = await client.responses.create(
      CreateResponseRequest(
        model: 'fixture',
        previousResponseId: first.id,
        input: ResponseInput.fromOutputItems([
          {
            'type': 'mcp_approval_response',
            'approval_request_id': approval.id,
            'approve': true,
            'reason': 'allowed',
          },
        ]),
      ),
    );
    expect(requests, hasLength(2));
    expect(requests.last['previous_response_id'], first.id);
    expect(requests.last['input'], [
      {
        'type': 'mcp_approval_response',
        'approval_request_id': approval.id,
        'approve': true,
        'reason': 'allowed',
      },
    ]);
    expect(jsonEncode(requests), isNot(contains('call_id')));
    expect(second.output.single, isA<McpCallOutputItem>());
    expect(second.output.single.toJson(), items.first);
  });
}
