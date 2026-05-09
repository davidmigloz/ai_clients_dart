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
      model: 'gpt-realtime-2',
      config: const realtime.RealtimeSessionCreateRequest(
        model: 'gpt-realtime-2',
        audio: realtime.RealtimeAudioConfig(
          output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
        ),
        instructions: 'You are a helpful assistant.',
      ),
    );

    // Send a user text message and process events until the response is
    // complete. Use `ws.appendAudioBytes(rawPcmBytes)` to stream audio.
    ws.sendUserMessage('Say hello and nothing else.');

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

    // --- Ephemeral client secret (for WebRTC / signed URLs) ---
    print('\n=== Ephemeral Client Secret ===\n');

    // Generates a short-lived (`ek_…`) credential for use with the
    // Realtime API. Use cases:
    //   • WebRTC SDP exchange (`realtimeSessions.calls.create(...)`) —
    //     the SDK uses the secret server-side; the browser only sees
    //     the SDP answer.
    //   • Server-side WebSocket sessions where you'd rather not pass
    //     the main API key around (the secret has narrower scope and a
    //     ~10-minute lifetime).
    //
    // Note: browser WebSocket connections cannot use this secret as a
    // bearer token because the WebSocket API doesn't allow custom
    // Authorization headers. For browser realtime, prefer WebRTC (see
    // the WebRTC section below) or proxy the WebSocket through a
    // server.
    final secretResponse = await client.realtimeSessions.createClientSecret(
      const realtime.RealtimeClientSecretCreateRequest(
        session: realtime.RealtimeSessionCreateRequest(
          model: 'gpt-realtime-2',
          audio: realtime.RealtimeAudioConfig(
            input: realtime.RealtimeAudioConfigInput(
              turnDetection:
                  realtime.RealtimeAudioInputTurnDetection.serverVad(),
            ),
            output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
          ),
          instructions: 'You are a helpful assistant.',
        ),
      ),
    );

    print('Session ID: ${secretResponse.session.id}');
    print('Client secret: ${secretResponse.value}');
    print('Expires at: ${secretResponse.expiresAt}');

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
    //       model: 'gpt-realtime-2',
    //       audio: realtime.RealtimeAudioConfig(
    //         output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
    //       ),
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

    // Accept an incoming SIP call (optionally override the session
    // configuration on accept).
    // await client.realtimeSessions.calls.accept(callId);
    // await client.realtimeSessions.calls.accept(
    //   callId,
    //   request: const realtime.RealtimeSessionCreateRequest(
    //     model: 'gpt-realtime-2',
    //     audio: realtime.RealtimeAudioConfig(
    //       output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
    //     ),
    //     instructions: 'Greet the caller in English.',
    //   ),
    // );
    print('accept(callId, {request}) - Accept an incoming call');

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

    // Transcription sessions use the dedicated
    // `createTranscriptionClientSecret(...)` helper, which posts to the
    // shared `/realtime/client_secrets` endpoint with the transcription
    // session shape (no top-level `model`).
    final transcriptionSecret = await client.realtimeSessions
        .createTranscriptionClientSecret(
          const realtime.RealtimeTranscriptionClientSecretCreateRequest(
            session: realtime.RealtimeTranscriptionSessionCreateRequest(
              audio: realtime.RealtimeTranscriptionSessionAudio(
                input: realtime.RealtimeAudioConfigInput(
                  format: realtime.AudioPcm(rate: 24000),
                  transcription: realtime.InputAudioTranscription(
                    model: 'gpt-realtime-whisper',
                    delay: realtime.AudioTranscriptionDelay.high,
                  ),
                ),
              ),
            ),
          ),
        );

    print('Transcription session ID: ${transcriptionSecret.session.id}');

    // --- Translation session (new in v6) ---
    print('\n=== Translation Session ===\n');

    final translationSecret = await client.realtimeSessions.translations
        .createClientSecret(
          const realtime.RealtimeTranslationClientSecretCreateRequest(
            session: realtime.RealtimeTranslationSessionCreateRequest(
              model: 'gpt-realtime-translate',
              audio: realtime.RealtimeTranslationSessionAudio(
                input: realtime.RealtimeTranslationSessionAudioInput(
                  transcription: realtime.RealtimeTranslationInputTranscription(
                    model: 'gpt-realtime-whisper',
                  ),
                ),
                output: realtime.RealtimeTranslationSessionAudioOutput(
                  language: 'es',
                ),
              ),
            ),
          ),
        );

    print('Translation secret: ${translationSecret.value}');
    print('Translation session: ${translationSecret.session.id}');

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
