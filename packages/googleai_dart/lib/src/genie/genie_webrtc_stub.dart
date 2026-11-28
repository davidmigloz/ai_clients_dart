import 'genie_webrtc_peer.dart';

/// Explains how native callers can supply their own RTC implementation.
GenieWebRtcPeer createWebRtcPeer() => throw UnsupportedError(
  'Supply a GenieWebRtcPeer backed by your runtime on native Dart, '
  'or use the Genie WebSocket transport.',
);
