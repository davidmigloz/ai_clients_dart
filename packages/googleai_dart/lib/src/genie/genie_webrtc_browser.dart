import 'dart:async';
import 'dart:js_interop';

import 'package:meta/meta.dart';
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

/// Creates a browser adapter for a caller-owned test peer.
@visibleForTesting
BrowserGenieWebRtcPeer browserPeerForTesting(
  web.RTCPeerConnection connection,
) => BrowserGenieWebRtcPeer._(connection, null);

/// A Genie peer backed by the browser's native WebRTC and media APIs.
///
/// The optional [mediaElement] receives the combined remote audio/video
/// stream. The page controls playback, including browser autoplay permission.
class BrowserGenieWebRtcPeer implements GenieWebRtcPeer {
  final web.RTCPeerConnection _peer;
  final web.HTMLMediaElement? _mediaElement;
  _BrowserDataChannels? _channel;
  bool _closed = false;

  /// Remote audio and video delivered by WebRTC.
  final web.MediaStream remoteMediaStream = web.MediaStream();

  /// Creates a browser peer. Supply a video element to display the world.
  BrowserGenieWebRtcPeer({
    web.HTMLMediaElement? mediaElement,
    web.RTCConfiguration? configuration,
  }) : this._(
         web.RTCPeerConnection(configuration ?? web.RTCConfiguration()),
         mediaElement,
       );

  BrowserGenieWebRtcPeer._(this._peer, this._mediaElement) {
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
      }).toJS
      ..ondatachannel = ((web.RTCDataChannelEvent event) {
        _channel?.attachIncoming(event.channel);
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
    return _channel = _BrowserDataChannels(_peer, label)
      ..attach(_peer.createDataChannel(label));
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
      ..oniceconnectionstatechange = null
      ..ondatachannel = null;
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

class _BrowserDataChannels implements GenieWebRtcDataChannel {
  final web.RTCPeerConnection _peer;
  final String _label;
  final _opened = Completer<void>();
  final _messages = StreamController<Object>();
  final _channels = <web.RTCDataChannel>{};
  web.RTCDataChannel? _active;

  _BrowserDataChannels(this._peer, this._label) {
    _opened.future.ignore();
  }

  void attachIncoming(web.RTCDataChannel channel) {
    if (channel.label.isEmpty || channel.label == _label) attach(channel);
  }

  void attach(web.RTCDataChannel channel) {
    if (_messages.isClosed || !_channels.add(channel)) return;
    channel
      ..binaryType = 'arraybuffer'
      ..onopen = ((web.Event _) => _markOpen(channel)).toJS
      ..onmessage = ((web.MessageEvent event) {
        if (_messages.isClosed) return;
        final data = event.data;
        if (data.typeofEquals('string')) {
          _messages.add((data! as JSString).toDart);
        } else if (data.isA<JSArrayBuffer>()) {
          _messages.add((data! as JSArrayBuffer).toDart.asUint8List());
        }
      }).toJS
      ..onerror = ((web.Event _) => _remove(channel, failed: true)).toJS
      ..onclose = ((web.Event _) => _remove(channel, failed: false)).toJS;
    if (_isOpen(channel)) _markOpen(channel);
  }

  void _markOpen(web.RTCDataChannel channel) {
    if (_messages.isClosed) return;
    _active = channel;
    if (!_opened.isCompleted) _opened.complete();
  }

  static bool _isOpen(web.RTCDataChannel channel) =>
      channel.readyState == 'open';

  web.RTCDataChannel? get _openChannel {
    final current = _active;
    if (current != null && _isOpen(current)) return current;
    return _channels.where(_isOpen).firstOrNull;
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
  void sendText(String message) {
    final channel = _openChannel;
    if (channel == null) {
      throw StateError('The Genie WebRTC data channel is closed.');
    }
    channel.send(message.toJS);
  }

  @override
  Future<void> flush() async {
    final elapsed = Stopwatch()..start();
    while (_channels.any(
          (channel) => _isOpen(channel) && channel.bufferedAmount > 0,
        ) &&
        elapsed.elapsed < const Duration(milliseconds: 500)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    if (_openChannel != null) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  void fail() => _finish(StateError('The browser WebRTC data channel failed.'));

  void _remove(web.RTCDataChannel channel, {required bool failed}) {
    _channels.remove(channel);
    if (channel == _active) _active = null;
    _closeChannel(channel);
    _active = _openChannel;
    // During setup, an incoming channel may still arrive after the offered
    // channel closes. Let the peer fault or handshake timeout end that wait.
    if (_active == null && _opened.isCompleted && !_messages.isClosed) {
      _finish(
        failed ? StateError('The browser WebRTC data channel failed.') : null,
      );
    }
  }

  void _finish([Object? error]) {
    if (!_opened.isCompleted) {
      _opened.completeError(
        error ?? StateError('The WebRTC data channel closed before opening.'),
      );
    }
    if (_messages.isClosed) return;
    if (error != null) _messages.addError(error);
    unawaited(_messages.close());
  }

  static void _closeChannel(web.RTCDataChannel channel) {
    channel
      ..onopen = null
      ..onmessage = null
      ..onerror = null
      ..onclose = null;
    try {
      channel.close();
    } catch (_) {
      // A closed channel no longer has any active callbacks.
    }
  }

  void close() {
    _channels
      ..forEach(_closeChannel)
      ..clear();
    _active = null;
    _finish();
  }
}
