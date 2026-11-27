import 'dart:convert';

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _secret = 'fixture-voice-webhook-café';
// Recorded fixture values with HMAC-SHA256 computed independently.
const _rawEndedBody = '''
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
const _validSignature =
    'hmac-sha256=74b9b4e0de3db34e7284b28896804119b2707e955e65295ba6bd746df36c404f';
const _invalidUtf8Signature =
    'hmac-sha256=ccece79c5d578a2dc9010c06737f018f88fcd43448719411fc7a40e0dbef20d6';
const _invalidJsonSignature =
    'hmac-sha256=ba5576947599e13004b600a1ac77d1b33b43968e0d5179771a02915a0f7b835b';

void main() {
  final verifier = VoiceAgentWebhookVerifier(signingSecret: _secret);
  final body = utf8.encode(_rawEndedBody);

  test('verifies exact UTF-8 bytes and decodes the completed call', () {
    final event =
        verifier.verifyAndParse(rawBody: body, signature: _validSignature)
            as VoiceAgentCallEndedEvent;
    expect(event.createdAt, DateTime.utc(2026, 11, 27, 17, 35, 42));
    expect(event.sessionId, 'RM_fixture42');
    expect(event.agentId, 'ag_fixture88');
    expect(event.model, 'mistral-small-latest');
    expect(event.startedAtUnixSeconds, 1795795720);
    expect(event.endedAtUnixSeconds, 1795795932);
    expect(event.durationSeconds, 212);
    expect(event.transcript, [
      const VoiceAgentWebhookTranscriptTurn(
        role: 'assistant',
        content: 'Bonjour ☎',
      ),
      const VoiceAgentWebhookTranscriptTurn(role: 'user'),
    ]);
    expect(event.toString(), isNot(contains('Bonjour')));
    final blank = event.copyWith(transcript: null);
    expect(blank.transcript, isNull);
    expect((blank.toJson()['data'] as Map)['transcript'], isNull);
    expect(VoiceAgentWebhookEvent.fromJson(blank.toJson()), blank);
    final restored = VoiceAgentWebhookEvent.fromJson(event.toJson());
    expect(restored, event);
    expect(restored.hashCode, event.hashCode);
    expect(event.copyWith(transcript: const []).transcript, isEmpty);
  });

  test(
    'deserializes recorded start and failure events with distinct fields',
    () {
      final start =
          VoiceAgentWebhookEvent.fromJson(const {
                'event': 'call_started',
                'created_at': '2026-11-27T18:32:00+01:00',
                'data': {
                  'session_id': 'RM_fixture42',
                  'agent_id': 'ag_fixture88',
                  'model': 'mistral-small-latest',
                  'started_at': 1795795720,
                },
              })
              as VoiceAgentCallStartedEvent;
      expect(start.createdAt, DateTime.utc(2026, 11, 27, 17, 32));
      expect(start.startedAtUnixSeconds, 1795795720);
      expect(start.copyWith(startedAtUnixSeconds: 0).startedAtUnixSeconds, 0);
      expect(VoiceAgentWebhookEvent.fromJson(start.toJson()), start);

      final failure =
          VoiceAgentWebhookEvent.fromJson(const {
                'event': 'call_failed',
                'created_at': '2026-11-27T17:32:01Z',
                'data': {
                  'session_id': 'RM_fixture42',
                  'agent_id': 'ag_fixture88',
                  'model': 'mistral-small-latest',
                  'error': 'future_transport_error',
                },
              })
              as VoiceAgentCallFailedEvent;
      expect(failure.error, 'future_transport_error');
      expect(failure.copyWith(error: 'livekit_error').error, 'livekit_error');
      expect(VoiceAgentWebhookEvent.fromJson(failure.toJson()), failure);
    },
  );

  test('unknown lifecycle deliveries retain original envelope and data', () {
    final raw = <String, dynamic>{
      'event': 'call_paused',
      'created_at': '2026-11-27T17:33:00Z',
      'data': {
        'detail': <Object>[1, 2],
      },
      'extra': {'version': 2},
    };
    final event =
        VoiceAgentWebhookEvent.fromJson(raw) as UnknownVoiceAgentWebhookEvent;
    final same = VoiceAgentWebhookEvent.fromJson(raw);
    expect(event, same);
    expect(event.hashCode, same.hashCode);
    expect(event.event, 'call_paused');
    expect(event.toJson(), raw);
    (raw['data'] as Map)['detail'] = <Object>[3];
    expect((event.rawJson['data'] as Map)['detail'], [1, 2]);
  });

  test('rejects missing, malformed, and mismatched signatures', () {
    for (final value in [
      null,
      '',
      _validSignature.substring(0, _validSignature.length - 1),
      '${_validSignature}0',
      _validSignature.replaceFirst('hmac-sha256=', 'hmac-sha512='),
      _validSignature.replaceFirst('74', 'zz'),
      _validSignature.replaceFirst('74', '04'),
      _validSignature.replaceFirst('04f', '04e'),
    ]) {
      expect(verifier.verify(rawBody: body, signature: value), isFalse);
      expect(
        () => verifier.verifyAndParse(rawBody: body, signature: value),
        throwsA(isA<VoiceAgentWebhookSignatureException>()),
      );
    }
    expect(
      VoiceAgentWebhookVerifier(
        signingSecret: 'different-fixture',
      ).verify(rawBody: body, signature: _validSignature),
      isFalse,
    );
    expect(
      () => VoiceAgentWebhookVerifier(signingSecret: ''),
      throwsArgumentError,
    );
  });

  test('detects body tampering even when the parsed JSON is unchanged', () {
    final withExtraSpace = [...body, 0x20];
    expect(
      verifier.verify(rawBody: withExtraSpace, signature: _validSignature),
      isFalse,
    );
    final modified = utf8.encode(_rawEndedBody.replaceFirst('212', '222'));
    expect(
      verifier.verify(rawBody: modified, signature: _validSignature),
      isFalse,
    );
    expect(
      () => verifier.verifyAndParse(rawBody: [255], signature: _validSignature),
      throwsA(isA<VoiceAgentWebhookSignatureException>()),
    );
  });

  test('reports JSON or UTF-8 errors only after successful verification', () {
    expect(
      verifier.verify(rawBody: [255], signature: _invalidUtf8Signature),
      isTrue,
    );
    expect(
      () => verifier.verifyAndParse(
        rawBody: [255],
        signature: _invalidUtf8Signature,
      ),
      throwsFormatException,
    );
    expect(
      () => verifier.verifyAndParse(
        rawBody: utf8.encode('not JSON'),
        signature: _invalidJsonSignature,
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.toString(),
          'diagnostic',
          isNot(contains('not JSON')),
        ),
      ),
    );
  });
}
