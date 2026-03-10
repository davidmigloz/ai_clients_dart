// ignore_for_file: avoid_print, unused_local_variable
/// Example demonstrating the Realtime API with OpenAI.
///
/// This example shows both WebSocket and WebRTC usage for real-time
/// conversations. Run with: dart run example/realtime_example.dart
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;

Future<void> main() async {
  // Create client from environment variable
  final client = OpenAIClient.fromEnvironment();

  try {
    // --- WebSocket: Connect directly (server-side) ---
    print('=== WebSocket: Direct Connection ===\n');

    // Connect to a realtime session via WebSocket using the main API key.
    // This is suitable for server-side (Dart VM) usage.
    final ws = await client.realtime.connect(
      model: 'gpt-realtime-1.5',
      config: const realtime.SessionUpdateConfig(
        voice: realtime.RealtimeVoice.alloy,
        instructions: 'You are a helpful assistant.',
      ),
    );

    // Listen for events
    ws.events.listen((event) {
      switch (event) {
        case realtime.SessionCreatedEvent(:final session):
          print('Session created: ${session.id}');
        case realtime.ResponseTextDeltaEvent(:final delta):
          stdout.write(delta);
        case realtime.ResponseTextDoneEvent():
          print(''); // newline after text
        case realtime.ErrorEvent(:final error):
          print('Error: ${error.message}');
        default:
          break;
      }
    });

    // Create a text response
    ws.createResponse();

    // Close WebSocket when done
    await ws.close();

    // --- Ephemeral client secret (for web/frontend clients) ---
    print('\n=== Ephemeral Client Secret ===\n');

    // On web platforms, browsers cannot set custom headers on WebSocket
    // connections. Use realtimeSessions.create() to obtain an ephemeral
    // client secret, then pass it to your frontend to connect directly.
    final session = await client.realtimeSessions.create(
      const realtime.RealtimeSessionCreateRequest(
        model: 'gpt-realtime-1.5',
        voice: realtime.RealtimeVoice.alloy,
        instructions: 'You are a helpful assistant.',
        turnDetection: realtime.TurnDetection(
          type: realtime.TurnDetectionType.serverVad,
        ),
      ),
    );

    print('Session ID: ${session.id}');
    print('Client secret: ${session.clientSecret?.value}');
    print('Expires at: ${session.clientSecret?.expiresAt}');
    // Use session.clientSecret.value as the Bearer token when connecting
    // from a browser WebSocket client.

    // --- WebRTC: Create call with SDP exchange ---
    print('\n=== WebRTC: SDP Exchange ===\n');

    // For WebRTC peer connections in Flutter, use the flutter_webrtc package:
    // https://pub.dev/packages/flutter_webrtc
    //
    // final pc = await createPeerConnection({'iceServers': []});
    // final offer = await pc.createOffer();
    // await pc.setLocalDescription(offer);

    // In a real application, you would get the SDP offer from your
    // RTCPeerConnection. Here we show the API call pattern.
    const sdpOffer =
        'v=0\r\n'
        'o=- 0 0 IN IP4 127.0.0.1\r\n'
        's=-\r\n'
        't=0 0\r\n';

    // Create a WebRTC call with an SDP offer
    // Returns the SDP answer string
    final sdpAnswer = await client.realtimeSessions.calls.create(
      const realtime.RealtimeCallCreateRequest(
        sdp: sdpOffer,
        session: realtime.RealtimeSessionCreateRequest(
          model: 'gpt-realtime-1.5',
          voice: realtime.RealtimeVoice.alloy,
        ),
      ),
    );

    print('Received SDP answer (${sdpAnswer.length} chars)');

    // In a real application, set the SDP answer to complete the handshake:
    // await pc.setRemoteDescription(RTCSessionDescription(sdpAnswer, 'answer'));

    // --- WebRTC: Call management ---
    print('\n=== WebRTC: Call Management ===\n');

    // These operations require a valid call ID from a previous call
    const callId = 'call_example_id';

    // Accept an incoming SIP call
    // await client.realtimeSessions.calls.accept(callId);
    print('accept(callId) - Accept an incoming call');

    // Hang up an active call
    // await client.realtimeSessions.calls.hangup(callId);
    print('hangup(callId) - Hang up an active call');

    // Transfer a call to another destination
    // await client.realtimeSessions.calls.refer(
    //   callId,
    //   realtime.RealtimeCallReferRequest(targetUri: 'tel:+14155550123'),
    // );
    print('refer(callId, request) - Transfer a call');

    // Reject an incoming call with a SIP status code
    // await client.realtimeSessions.calls.reject(
    //   callId,
    //   request: realtime.RealtimeCallRejectRequest(statusCode: 486),
    // );
    print('reject(callId, request) - Reject an incoming call');

    // --- Transcription session ---
    print('\n=== Transcription Session ===\n');

    final transcriptionSession = await client.realtimeSessions
        .createTranscription(
          const realtime.RealtimeTranscriptionSessionCreateRequest(
            inputAudioFormat: realtime.RealtimeAudioFormat.pcm16,
            inputAudioTranscription: realtime.InputAudioTranscription(
              model: 'whisper-1',
            ),
            turnDetection: realtime.TurnDetection(
              type: realtime.TurnDetectionType.serverVad,
            ),
          ),
        );

    print('Client secret: ${transcriptionSession.clientSecret.value}');

    print('\nDone!');
  } on OpenAIException catch (e) {
    print('OpenAI error: ${e.message}');
    if (e is ApiException) {
      print('Status: ${e.statusCode}');
    }
    exit(1);
  } finally {
    client.close();
  }
}
