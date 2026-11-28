import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'genie_webrtc_peer.dart';

/// Creates the default browser peer without a bound media element.
GenieWebRtcPeer createWebRtcPeer() {
  try {
    return BrowserGenieWebRtcPeer();
  } catch (_) {
    throw UnsupportedError('This browser does not provide native WebRTC.');
  }
}

/// A Genie peer backed by the browser's native WebRTC and media APIs.
///
/// The optional [mediaElement] receives the combined remote audio/video
/// stream. The page controls playback, including browser autoplay permission.
class BrowserGenieWebRtcPeer implements GenieWebRtcPeer {
  final web.RTCPeerConnection _peer;
  final web.HTMLMediaElement? _mediaElement;
  _BrowserDataChannel? _channel;
  bool _closed = false;

  /// Remote audio and video delivered by WebRTC.
  final web.MediaStream remoteMediaStream = web.MediaStream();

  /// Creates a browser peer. Supply a video element to display the world.
  BrowserGenieWebRtcPeer({
    this._mediaElement,
    web.RTCConfiguration? configuration,
  }) : _peer = web.RTCPeerConnection(configuration ?? web.RTCConfiguration()) {
    _peer
      ..ontrack = ((web.RTCTrackEvent event) {
        remoteMediaStream.addTrack(event.track);
        _mediaElement?.srcObject = remoteMediaStream;
      }).toJS
      ..onconnectionstatechange = ((web.Event _) {
        _onPeerState(_peer.connectionState);
      }).toJS
      ..oniceconnectionstatechange = ((web.Event _) {
        _onPeerState(_peer.iceConnectionState);
      }).toJS;
  }

  void _onPeerState(String state) {
    if (state == 'failed' || state == 'closed') _channel?.fail();
  }

  @override
  void addReceiveOnlyTransceiver(GenieWebRtcMediaKind kind) {
    _peer.addTransceiver(
      kind.name.toJS,
      web.RTCRtpTransceiverInit(direction: 'recvonly'),
    );
  }

  @override
  GenieWebRtcDataChannel createDataChannel(String label) {
    if (_channel != null) {
      throw StateError('The Genie peer already has a channel.');
    }
    return _channel = _BrowserDataChannel(
      _peer.createDataChannel(label),
      _peer,
    );
  }

  @override
  Future<String> createOffer() async {
    final offer = await _peer.createOffer().toDart;
    if (offer == null) return '';
    await _peer
        .setLocalDescription(
          web.RTCLocalSessionDescriptionInit(type: offer.type, sdp: offer.sdp),
        )
        .toDart;
    // The signaling endpoint exchanges SDP once and has no trickle ICE route.
    await _gatherLocalCandidates();
    return _peer.localDescription?.sdp ?? offer.sdp;
  }

  Future<void> _gatherLocalCandidates() async {
    if (_peer.iceGatheringState == 'complete') return;
    final complete = Completer<void>();
    final listener = ((web.Event _) {
      if (_peer.iceGatheringState == 'complete' && !complete.isCompleted) {
        complete.complete();
      }
    }).toJS;
    _peer.addEventListener('icegatheringstatechange', listener);
    try {
      // Slow or inaccessible ICE servers should not consume the entire
      // negotiation budget. The peer can still receive remote candidates.
      await complete.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );
    } finally {
      _peer.removeEventListener('icegatheringstatechange', listener);
    }
  }

  @override
  Future<void> setAnswer(String sdp) async {
    await _peer
        .setRemoteDescription(
          web.RTCSessionDescriptionInit(type: 'answer', sdp: sdp),
        )
        .toDart;
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _peer
      ..ontrack = null
      ..onconnectionstatechange = null
      ..oniceconnectionstatechange = null;
    try {
      _channel?.close();
    } finally {
      _peer.close();
      for (final track in remoteMediaStream.getTracks().toDart) {
        track.stop();
      }
      _mediaElement?.srcObject = null;
    }
  }
}

class _BrowserDataChannel implements GenieWebRtcDataChannel {
  final web.RTCDataChannel _channel;
  final web.RTCPeerConnection _peer;
  final _opened = Completer<void>();
  final _messages = StreamController<Object>();

  _BrowserDataChannel(this._channel, this._peer) {
    _opened.future.ignore();
    _channel
      ..binaryType = 'arraybuffer'
      ..onopen = ((web.Event _) => _markOpen()).toJS
      ..onmessage = ((web.MessageEvent event) {
        final data = event.data;
        if (data.typeofEquals('string')) {
          _messages.add((data! as JSString).toDart);
        } else if (data.isA<JSArrayBuffer>()) {
          _messages.add((data! as JSArrayBuffer).toDart.asUint8List());
        }
      }).toJS
      ..onerror = ((web.Event _) => fail()).toJS
      ..onclose = ((web.Event _) => _finish()).toJS;
    if (_channel.readyState == 'open') _markOpen();
  }

  void _markOpen() {
    if (!_opened.isCompleted) _opened.complete();
  }

  @override
  Future<void> get opened => _opened.future;

  @override
  Stream<Object> get messages => _messages.stream;

  @override
  int? get maxMessageSize {
    final maximum = _peer.sctp?.maxMessageSize;
    return maximum != null && maximum.isFinite ? maximum.toInt() : null;
  }

  @override
  void sendText(String message) => _channel.send(message.toJS);

  @override
  Future<void> flush() async {
    final elapsed = Stopwatch()..start();
    while (_channel.readyState == 'open' &&
        _channel.bufferedAmount > 0 &&
        elapsed.elapsed < const Duration(milliseconds: 500)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    if (_channel.readyState == 'open') {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  void fail() => _finish(StateError('The browser WebRTC data channel failed.'));

  void _finish([Object? error]) {
    if (!_opened.isCompleted) {
      _opened.completeError(
        error ?? StateError('The WebRTC data channel closed before opening.'),
      );
    }
    if (!_messages.isClosed) {
      _channel.onmessage = null;
      if (error != null) _messages.addError(error);
      unawaited(_messages.close());
    }
  }

  void close() {
    _channel
      ..onopen = null
      ..onmessage = null
      ..onerror = null
      ..onclose = null
      ..close();
    _finish();
  }
}
