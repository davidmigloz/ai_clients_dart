/// Demonstrates asynchronous function declarations and explicit MCP approvals.
/// Run with `dart run example/agent_mcp_approvals_example.dart`.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final function = AgentTool.function(
    name: 'fixture_lookup',
    description: 'A local example function.',
    parameters: const {'type': 'object'},
    async: true,
  );
  stdout.writeln(
    'Function can continue before a result: ${function.toJson()['async']}.',
  );

  final action =
      AgentSessionRequiredAction.fromJson(const {
            'type': 'mcp_approval_request',
            'request_id': 'approval_fixture',
            'turn_id': 'turn_fixture',
            'request': {
              'type': 'mcp_tool_call',
              'server_label': 'fixture',
              'name': null,
              'arguments': null,
              'message': 'A synthetic request for the reviewer.',
            },
          })
          as AgentSessionMcpApprovalRequiredAction;

  // This fixture represents a decision already made by the reviewer.
  const reviewedDecision = AgentSessionMcpApprovalDecision.deny;
  final transport = MockClient((request) async {
    if (request.method != 'POST' ||
        request.url.path != '/v1/agents/sessions/session_fixture/events') {
      throw StateError('Unexpected synthetic request.');
    }
    final payload = jsonDecode(request.body) as Map<String, dynamic>;
    final events = CreateAgentSessionEventsRequest.fromJson(payload).events;
    final input = events.single as AgentSessionMcpApprovalResultInput;
    stdout.writeln(
      'Reviewer decision submitted: ${input.response.decision.toJson()}.',
    );
    return http.Response('', 202);
  });
  final client = OpenAIClient(httpClient: transport);
  try {
    await client.agents.sessions.events.create(
      'session_fixture',
      CreateAgentSessionEventsRequest(
        events: [
          AgentSessionInput.mcpApprovalRequestResult(
            requestId: action.requestId,
            response: const AgentSessionMcpApprovalResponse(
              decision: reviewedDecision,
            ),
          ),
        ],
      ),
    );
  } finally {
    client.close();
    transport.close();
  }
}
