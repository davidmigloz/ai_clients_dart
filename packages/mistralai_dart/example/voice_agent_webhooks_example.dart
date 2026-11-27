// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:mistralai_dart/mistralai_dart.dart';

// These are offline fixture values. In a server, use the original request
// bytes, its X-Mistral-Signature header, and the endpoint's signing secret.
const _fixtureBody = '''
{
  "event": "call_ended",
  "created_at": "2026-11-27T17:35:42Z",
  "data": {
    "session_id": "RM_fixture42", "agent_id": "ag_fixture88",
    "model": "mistral-small-latest", "duration_seconds": 212,
    "started_at": 1795795720, "ended_at": 1795795932,
    "transcript": [{"role": "assistant", "content": "Bonjour ☎"}, {"role": "user", "content": null}]
  }
}''';
const _fixtureSignature =
    'hmac-sha256=74b9b4e0de3db34e7284b28896804119b2707e955e65295ba6bd746df36c404f';

/// Verifies a signed Voice Agent webhook and handles its lifecycle event.
void main() {
  final verifier = VoiceAgentWebhookVerifier(
    signingSecret: 'fixture-voice-webhook-café',
  );
  final event = verifier.verifyAndParse(
    rawBody: utf8.encode(_fixtureBody),
    signature: _fixtureSignature,
  );
  switch (event) {
    case VoiceAgentCallStartedEvent(:final sessionId):
      print('Call $sessionId started.');
    case VoiceAgentCallEndedEvent(:final sessionId, :final durationSeconds):
      print('Call $sessionId ended after $durationSeconds seconds.');
    case VoiceAgentCallFailedEvent(:final sessionId, :final error):
      print('Call $sessionId failed with code $error.');
    case UnknownVoiceAgentWebhookEvent():
      print('Received a new Voice Agent event type.');
  }
}
