// ignore_for_file: avoid_print
/// Configures a Responses backend for Live and reads a synthetic webhook.
/// Run with dart run example/live_responses_delegation_example.dart.
/// This example sends no requests and requires no API key.
library;

import 'package:openai_dart/openai_dart.dart';

void main() {
  final lookup = LiveMCPTool(
    serverLabel: 'ProductManual',
    serverUrl: 'https://mcp.example.com/manual',
    allowedCallers: const [LiveCallableToolAllowedCaller.direct],
    allowedTools: LiveMCPAllowedTools.names(const ['lookup']),
    requireApproval: LiveMCPApproval.always,
  );
  final startup = LiveSessionCreateParams(
    model: 'gpt-live-1',
    safetyIdentifier: 'customer-pseudonym',
    delegation: LiveResponsesDelegationParam(
      responses: LiveResponsesDelegationSettingsInputParam(
        model: 'gpt-6.2-sol',
        tools: [lookup],
        toolChoice: LiveMCPToolChoice(
          serverLabel: 'ProductManual',
          name: 'lookup',
        ),
      ),
    ),
  );

  // Use LiveSessionStartEvent(session: startup) with the primary connection.
  print('Startup event: ${LiveSessionStartEvent(session: startup).type}');

  // In production, authenticate the original webhook bytes with
  // client.webhooks.unwrapBytes before processing the decoded event.
  final event = WebhookEvent.fromJson(const {
    'id': 'event_example',
    'object': 'event',
    'type': 'live.transport.connected',
    'created_at': 1,
    'data': {'type': 'webrtc', 'session_id': 'live_example'},
  });
  if (event is LiveTransportConnectedWebhookEvent) {
    // Use client.live.attach(event.data.sessionId) to observe the session.
    print('Received ${event.type} for ${event.data.sessionId}');
  }
}
