// ignore_for_file: avoid_print

import 'dart:js_interop';

import 'package:googleai_dart/genie_web.dart';
import 'package:googleai_dart/googleai_dart.dart';
import 'package:web/web.dart' as web;

/// Requires an interaction ID and scoped token from your trusted backend.
/// Start opens a billed Genie 4 session.
void main() {
  final id = web.HTMLInputElement()..placeholder = 'Interaction ID';
  final token = web.HTMLInputElement()
    ..placeholder = 'Scoped session token'
    ..type = 'password';
  final start = web.HTMLButtonElement()..textContent = 'Start Genie';
  final stop = web.HTMLButtonElement()
    ..textContent = 'Complete'
    ..disabled = true;
  final status = web.HTMLParagraphElement();
  final video = web.HTMLVideoElement()
    ..autoplay = true
    ..controls = true
    ..playsInline = true;
  web.document.body!
    ..appendChild(id)
    ..appendChild(token)
    ..appendChild(start)
    ..appendChild(stop)
    ..appendChild(status)
    ..appendChild(video);

  final client = GoogleAIClient();
  GenieSession? session;
  start.onclick = ((web.MouseEvent _) {
    Future<void>(() async {
      start.disabled = true;
      try {
        final current = session = await client.interactions.genie.connectWebRtc(
          id.value,
          authToken: token.value,
          peer: BrowserGenieWebRtcPeer(mediaElement: video),
        );
        token.value = '';
        current.send(const GenieWorldSetup(prompt: 'A plaza at sunrise.'));
        stop.disabled = false;
        await for (final event in current.receive()) {
          status.textContent = event.eventType;
        }
      } on GenieConnectionException catch (error) {
        status.textContent = error.message;
      } finally {
        stop.disabled = true;
        await session?.detach();
        session = null;
        start.disabled = false;
      }
    }).ignore();
  }).toJS;

  stop.onclick = ((web.MouseEvent _) {
    Future<void>(() async {
      stop.disabled = true;
      try {
        await session?.complete();
      } on GenieConnectionException catch (error) {
        status.textContent = error.message;
        stop.disabled = false;
      }
    }).ignore();
  }).toJS;
}
