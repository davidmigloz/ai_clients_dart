// ignore_for_file: avoid_print
/// Offline Live HTTP signaling, recordings and explicitly selected controls.
///
/// Run: dart run example/live_http_example.dart
/// Optional: --accept-incoming or --reject-incoming, and --recording-not-ready.
/// Every request uses MockClient. No API key, media connection or paid call.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

const _signingKey = 'synthetic-live-example-signing-key';
const _offer = 'synthetic caller-owned offer SDP';
const _answer = 'synthetic service answer SDP';

Future<void> main(List<String> args) async {
  const options = {
    '--accept-incoming',
    '--reject-incoming',
    '--recording-not-ready',
  };
  if (args.any((arg) => !options.contains(arg)) ||
      (args.contains('--accept-incoming') &&
          args.contains('--reject-incoming'))) {
    throw ArgumentError('Select at most one incoming-call action.');
  }
  var requests = 0;
  final wav = _stereoWav();
  final transport = MockClient.streaming((request, body) async {
    requests++;
    if (request.url.host != 'example.invalid' ||
        request.headers['authorization'] != 'Bearer synthetic-live-key') {
      throw StateError('Unexpected offline request scope.');
    }
    final bytes = await body.toBytes();
    final path = request.url.path;
    Object? response;
    var status = 200;
    if (request.method == 'POST' && path == '/v1/live/sessions') {
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final media = json['transport'] as Map<String, dynamic>;
      final sip = media['type'] == 'sip';
      response = {
        'session': {'id': sip ? 'live_synthetic_sip' : 'live_synthetic_webrtc'},
        'transport': {'type': sip ? 'sip' : 'webrtc', if (!sip) 'sdp': _answer},
      };
      status = 201;
    } else if (request.method == 'GET' && path.endsWith('/content')) {
      if (args.contains('--recording-not-ready')) {
        return http.StreamedResponse(
          Stream.value(utf8.encode('Synthetic recording is not finalized.')),
          503,
          request: request,
          headers: const {'content-type': 'text/plain', 'retry-after': '2'},
        );
      }
      return http.StreamedResponse(
        Stream.fromIterable([wav.sublist(0, 25), wav.sublist(25)]),
        200,
        request: request,
        headers: const {'content-type': 'audio/wav'},
      );
    } else if (request.method == 'POST' && path.endsWith('/fork')) {
      response = {
        'session': {'id': 'live_synthetic_fork'},
        'transport': {'type': 'webrtc', 'sdp': _answer},
      };
      status = 201;
    } else if (request.method != 'POST' ||
        ![
          'accept',
          'reject',
          'refer',
          'hangup',
        ].contains(path.split('/').last)) {
      throw StateError('Unexpected offline operation.');
    }
    return http.StreamedResponse(
      Stream.value(
        response == null ? <int>[] : utf8.encode(jsonEncode(response)),
      ),
      status,
      request: request,
      headers: const {'content-type': 'application/json'},
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/v1',
      authProvider: ApiKeyProvider('synthetic-live-key'),
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  try {
    // Production SDP comes from the application's WebRTC peer. Apply the
    // returned answer there; this package does not capture or play media.
    final webrtc = await client.live.sessions.create(
      LiveSessionCreateRequest(
        session: LiveMediaSessionCreateParams(
          model: 'gpt-live-1',
          instructions: 'Help the caller find an appointment.',
          store: true,
        ),
        transport: LiveWebRTCTransport(sdp: _offer),
      ),
    );
    if (webrtc.transport is! LiveWebRTCResponseTransport ||
        (webrtc.transport as LiveWebRTCResponseTransport).sdp != _answer) {
      throw StateError('Expected the original WebRTC answer.');
    }

    // The mock places no call. Production requires outbound SIP eligibility,
    // a TLS/Opus/SDES-SRTP trunk and real per-call credentials kept on a server.
    final sip = await client.live.sessions.create(
      LiveSessionCreateRequest(
        session: LiveMediaSessionCreateParams(model: 'gpt-live-1'),
        transport: LiveSIPTransport(
          destination: '+14155550123',
          trunk: LiveSIPTrunk(
            providerUrl: 'sips:sip.example.com:5061',
            callerNumber: '+14155550100',
            auth: LiveSIPTrunkAuth(
              username: 'synthetic-user',
              password: 'synthetic-password',
            ),
          ),
        ),
      ),
    );
    // A 201 initializes SIP; it does not mean answered. Each create is a new
    // call. A trace ID does not deduplicate an ambiguous failed create.
    await client.live.sessions.refer(
      sip.session.id,
      LiveCallReferRequest(targetUri: 'sip:reception@example.com'),
    );
    await client.live.sessions.hangup(sip.session.id);

    // Verify original notice bytes. The call ID is data.session_id, distinct
    // from the delivery ID and event ID. Verification performs no call action.
    final notice = _verifiedIncoming();
    final incomingId = notice.data.sessionId;
    if (args.contains('--accept-incoming')) {
      await client.live.sessions.accept(
        incomingId,
        LiveCallAcceptRequest(
          session: LiveCallAcceptSession(model: 'gpt-live-1'),
        ),
      );
    } else if (args.contains('--reject-incoming')) {
      await client.live.sessions.reject(
        incomingId,
        LiveCallRejectRequest(statusCode: 486),
      );
    }
    print('Verified incoming notice; action requires an explicit option.');

    // Production downloads require storage policy, no ZDR and a finalized
    // recording; stereo input-left/output-right audio remains available 30 days.
    try {
      final buffered = await client.live.sessions.downloadRecording(
        webrtc.session.id,
      );
      final streamed = BytesBuilder();
      await client.live.sessions
          .downloadRecordingStream(webrtc.session.id)
          .forEach(streamed.add);
      if (base64.encode(buffered) != base64.encode(wav) ||
          base64.encode(streamed.takeBytes()) != base64.encode(wav)) {
        throw StateError('Original recording bytes changed.');
      }
      print('Preserved ${wav.length} stereo WAV bytes in both download modes.');
    } on ApiException catch (error) {
      if (error.statusCode != 503 || error.cause is! http.Response) rethrow;
      final response = error.cause! as http.Response;
      print(
        'Recording not finalized; Retry-After: ${response.headers['retry-after']} seconds.',
      );
    }
    // Empty overrides inherit stored configuration. Fork has a new session ID;
    // application state and external tool effects are not implicitly replayed.
    final fork = await client.live.sessions.fork(
      webrtc.session.id,
      LiveForkRequest(
        transport: LiveWebRTCTransport(sdp: _offer),
        session: LiveMediaSessionForkParams(),
      ),
    );
    if (fork.session.id == webrtc.session.id) {
      throw StateError('Fork must return a new session ID.');
    }
    print('$requests mock requests; API cost \$0.');
  } finally {
    client.close();
    transport.close();
  }
}

LiveTransportIncomingWebhookEvent _verifiedIncoming() {
  final bytes = utf8.encode(
    jsonEncode({
      'type': 'live.transport.incoming',
      'id': 'evt_synthetic_live',
      'created_at': 1,
      'data': {
        'type': 'sip',
        'session_id': 'live_synthetic_incoming',
        'sip_headers': <Object>[],
      },
    }),
  );
  const deliveryId = 'delivery_synthetic_live';
  final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
  final signature = Hmac(
    sha256,
    utf8.encode(_signingKey),
  ).convert([...utf8.encode('$deliveryId.$timestamp.'), ...bytes]);
  final notice = const WebhookVerifier(secret: _signingKey).unwrapBytes(bytes, {
    'webhook-id': deliveryId,
    'webhook-timestamp': timestamp,
    'webhook-signature': 'v1,${base64.encode(signature.bytes)}',
  });
  if (notice is! LiveTransportIncomingWebhookEvent) {
    throw StateError('Expected a verified incoming Live transport notice.');
  }
  return notice;
}

Uint8List _stereoWav() {
  final bytes = Uint8List(48);
  final header = ByteData.sublistView(bytes);
  for (final (offset, text) in [
    (0, 'RIFF'),
    (8, 'WAVE'),
    (12, 'fmt '),
    (36, 'data'),
  ]) {
    bytes.setRange(offset, offset + text.length, ascii.encode(text));
  }
  header
    ..setUint32(4, 40, Endian.little)
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little)
    ..setUint16(22, 2, Endian.little)
    ..setUint32(24, 24000, Endian.little)
    ..setUint32(28, 96000, Endian.little)
    ..setUint16(32, 4, Endian.little)
    ..setUint16(34, 16, Endian.little)
    ..setUint32(40, 4, Endian.little);
  return bytes;
}
