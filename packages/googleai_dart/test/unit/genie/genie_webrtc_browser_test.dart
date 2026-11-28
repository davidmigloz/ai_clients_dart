@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:googleai_dart/genie_web.dart';
import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  test('browser rejects a raw API key before signaling', () async {
    final transport = MockClient(
      (_) => throw StateError('Unexpected HTTP request'),
    );
    addTearDown(transport.close);
    final client = GoogleAIClient(
      config: const GoogleAIConfig(
        authProvider: ApiKeyProvider('raw-key-fixture'),
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
    await expectLater(
      client.interactions.genie.connectWebRtc('int_browser_raw'),
      throwsA(
        isA<GenieConnectionException>()
            .having(
              (error) => error.message,
              'message',
              contains('scoped token'),
            )
            .having(
              (error) => error.toString(),
              'diagnostics',
              isNot(contains('raw-key-fixture')),
            ),
      ),
    );
  });

  test(
    'native browser SDP offers receive-only media and attaches a remote track',
    () async {
      final server = web.RTCPeerConnection();
      // JS interop methods cannot be torn off.
      // ignore: unnecessary_lambdas
      addTearDown(() => server.close());
      final canvas = web.HTMLCanvasElement();
      final videoTrack = canvas.captureStream(1).getVideoTracks().toDart.single;
      // ignore: unnecessary_lambdas
      addTearDown(() => videoTrack.stop());
      final source = web.MediaStream()..addTrack(videoTrack);
      final video = web.HTMLVideoElement();
      final peer = BrowserGenieWebRtcPeer(mediaElement: video);
      addTearDown(peer.close);
      peer
        ..addReceiveOnlyTransceiver(GenieWebRtcMediaKind.audio)
        ..addReceiveOnlyTransceiver(GenieWebRtcMediaKind.video)
        ..createDataChannel('events');

      final offer = await peer.createOffer();
      expect(offer, contains('m=audio'));
      expect(offer, contains('m=video'));
      expect(offer, contains('m=application'));
      expect(offer, contains('a=recvonly'));
      await server
          .setRemoteDescription(
            web.RTCSessionDescriptionInit(type: 'offer', sdp: offer),
          )
          .toDart;
      server.addTrack(videoTrack, source);
      final answer = (await server.createAnswer().toDart)!;
      await peer.setAnswer(answer.sdp);

      expect(peer.remoteMediaStream.getVideoTracks().toDart, hasLength(1));
      expect(video.srcObject, isNotNull);
      await peer.close();
      expect(video.srcObject, isNull);
    },
  );
}
