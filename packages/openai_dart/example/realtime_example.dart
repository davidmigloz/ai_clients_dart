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

    // Listen for events using await for to process them until done
    ws.createResponse();

    await for (final event in ws.events) {
      switch (event) {
        case realtime.SessionCreatedEvent(:final session):
          print('Session created: ${session.id}');
        case realtime.ResponseTextDeltaEvent(:final delta):
          stdout.write(delta);
        case realtime.ResponseDoneEvent():
          print(''); // newline after response completes
          await ws.close();
        case realtime.ErrorEvent(:final error):
          print('Error: ${error.message}');
          await ws.close();
        default:
          break;
      }
    }

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

    // Create a WebRTC call by sending an SDP offer and receiving an SDP answer.
    // In a real application, use the SDP offer from your RTCPeerConnection:
    //
    // final sdpAnswer = await client.realtimeSessions.calls.create(
    //   realtime.RealtimeCallCreateRequest(
    //     sdp: offer.sdp!,
    //     session: realtime.RealtimeSessionCreateRequest(
    //       model: 'gpt-realtime-1.5',
    //       voice: realtime.RealtimeVoice.alloy,
    //     ),
    //   ),
    // );
    //
    // // Set the SDP answer to complete the WebRTC handshake
    // await pc.setRemoteDescription(
    //   RTCSessionDescription(sdpAnswer, 'answer'),
    // );
    print('calls.create(request) - Create a WebRTC call with SDP exchange');

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
