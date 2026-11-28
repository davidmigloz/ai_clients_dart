import 'dart:typed_data';

/// The media kinds the Genie 4 WebRTC peer receives.
enum GenieWebRtcMediaKind {
  /// The remote audio track.
  audio,

  /// The remote video track.
  video,
}

/// A one-session adapter around a host WebRTC peer connection.
///
/// The browser adapter is available through `package:googleai_dart/genie_web.dart`.
/// Other runtimes can supply an implementation backed by their RTC binding.
/// The adapter owns track handling and rendering. The resource closes the peer
/// on failure and the session closes it on completion, cancellation, or detach.
abstract interface class GenieWebRtcPeer {
  /// Adds a receive-only transceiver of [kind] before creating the offer.
  void addReceiveOnlyTransceiver(GenieWebRtcMediaKind kind);

  /// Creates the ordered control channel before the offer.
  GenieWebRtcDataChannel createDataChannel(String label);

  /// Creates and sets the local offer, then returns its SDP.
  Future<String> createOffer();

  /// Applies the remote answer SDP.
  Future<void> setAnswer(String sdp);

  /// Releases the peer connection and its remote media resources.
  Future<void> close();
}

/// The ordered data channel used for Genie WebRTC controls and lifecycle events.
abstract interface class GenieWebRtcDataChannel {
  /// Completes when the channel opens, or fails if it cannot open.
  Future<void> get opened;

  /// Incoming complete channel messages as UTF-8 [String] or [Uint8List].
  ///
  /// The stream must buffer messages received before its first subscriber.
  /// Report a channel or peer failure through this stream, and close the stream
  /// when the underlying data channel closes.
  Stream<Object> get messages;

  /// The negotiated SCTP message limit in bytes, if known.
  int? get maxMessageSize;

  /// Sends one complete UTF-8 control message on the open channel.
  void sendText(String message);

  /// Gives already queued messages a chance to be sent before peer closure.
  Future<void> flush();
}
