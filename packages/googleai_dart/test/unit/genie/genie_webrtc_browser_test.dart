@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:googleai_dart/genie_web.dart';
import 'package:googleai_dart/googleai_dart.dart';
import 'package:googleai_dart/src/genie/genie_webrtc_browser.dart'
    show browserPeerForTesting;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

@JS('Object.defineProperty')
external void _defineProperty(
  JSObject object,
  JSString name,
  _PropertyValue descriptor,
);

extension type _PropertyValue._(JSObject _) implements JSObject {
  external factory _PropertyValue({required JSAny value, bool configurable});
}

void _overrideProperty(JSObject object, String name, JSAny value) {
  _defineProperty(
    object,
    name.toJS,
    _PropertyValue(value: value, configurable: true),
  );
}

void _incoming(web.RTCPeerConnection peer, web.RTCDataChannel channel) {
  peer.dispatchEvent(
    web.RTCDataChannelEvent(
      'datachannel',
      web.RTCDataChannelEventInit(channel: channel),
    ),
  );
}

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
    'uses peer-created control channels and falls back after a close',
    () async {
      final connection = web.RTCPeerConnection();
      final remote = web.RTCPeerConnection();
      // JS interop methods cannot be torn off.
      // ignore: unnecessary_lambdas
      addTearDown(() => remote.close());
      final peer = browserPeerForTesting(connection);
      addTearDown(peer.close);
      final outgoing = connection.createDataChannel('events');
      _overrideProperty(
        connection,
        'createDataChannel',
        ((JSString _) => outgoing).toJS,
      );
      final offeredFrames = <String>[];
      _overrideProperty(
        outgoing,
        'send',
        ((JSString frame) => offeredFrames.add(frame.toDart)).toJS,
      );

      final control = peer.createDataChannel('events');
      final ready = Completer<void>();
      unawaited(control.opened.then((_) => ready.complete()));
      final unrelated = remote.createDataChannel('telemetry');
      _overrideProperty(unrelated, 'readyState', 'open'.toJS);
      _incoming(connection, unrelated);
      await Future<void>.value();
      expect(ready.isCompleted, isFalse);
      expect(unrelated.onmessage, isNull);

      final fallback = remote.createDataChannel('');
      final incomingFrames = <String>[];
      _overrideProperty(fallback, 'readyState', 'open'.toJS);
      _overrideProperty(
        fallback,
        'send',
        ((JSString frame) => incomingFrames.add(frame.toDart)).toJS,
      );
      _incoming(connection, fallback);
      await ready.future.timeout(const Duration(seconds: 3));
      expect(fallback.binaryType, 'arraybuffer');
      control.sendText('peer-opened');
      expect(incomingFrames, ['peer-opened']);

      _overrideProperty(outgoing, 'readyState', 'open'.toJS);
      outgoing.dispatchEvent(web.Event('open'));
      control.sendText('offer-opened');
      expect(offeredFrames, ['offer-opened']);

      _overrideProperty(outgoing, 'readyState', 'closed'.toJS);
      outgoing.dispatchEvent(web.Event('close'));
      control.sendText('peer-fallback');
      expect(incomingFrames, ['peer-opened', 'peer-fallback']);
      expect(outgoing.onmessage, isNull);
      final inbound = control.messages.first.timeout(
        const Duration(seconds: 3),
      );
      fallback.dispatchEvent(
        web.MessageEvent('message', web.MessageEventInit(data: 'inbound'.toJS)),
      );
      expect(await inbound, 'inbound');

      await peer.close();
      expect(connection.ondatachannel, isNull);
      expect(fallback.onmessage, isNull);
    },
  );

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
