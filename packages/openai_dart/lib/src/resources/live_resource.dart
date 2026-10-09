import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../models/live/live_http.dart';
import '../utils/http_error_response.dart';
import '../utils/private_audio_http.dart';
import 'base_resource.dart';
import 'live/live_connect.dart';
import 'live/live_connection.dart';
import 'speech_stream_transport.dart';

export 'live/live_connection.dart';

/// Live HTTP signaling, media controls and primary/sideband WebSocket connections.
class LiveResource extends ResourceBase {
  /// Creates the cached Live resource.
  LiveResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

  /// Opens a primary socket without starting a session. Call `start` explicitly
  /// and await its acknowledgment before submitting application work.
  ///
  /// The browser default rejects configured handshake headers before asking
  /// for credentials. Use trusted backend signaling/caller media, or supply
  /// an explicitly authenticated proxy connector. Connections are caller-owned
  /// after opening; client closure does not close them.
  Future<LivePrimaryConnection> connect({
    LiveWebSocketConnector? connector,
    Map<String, String>? additionalHeaders,
    Duration? connectionTimeout,
    int maxBufferedEvents = 1024,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return openLiveConnection(
      config: config,
      requestBuilder: requestBuilder,
      sideband: false,
      endpoint: '/live/sessions',
      connector: connector,
      additionalHeaders: additionalHeaders,
      connectionTimeout: connectionTimeout,
      maxBufferedEvents: maxBufferedEvents,
      abortTrigger: abortTrigger,
      ensureNotClosed: ensureNotClosed,
    ).then((connection) => connection as LivePrimaryConnection);
  }

  /// Attaches a trusted sideband to an already-running session without startup
  /// or audio submission. Optional graceful_close is sent exactly as supplied.
  ///
  /// SIP progress from the preceding three seconds may be replayed with its
  /// original IDs. Application deduplication is explicit; audio and actions
  /// are never replayed by this client.
  Future<LiveSidebandConnection> attach(
    String sessionId, {
    bool? gracefulClose,
    LiveWebSocketConnector? connector,
    Map<String, String>? additionalHeaders,
    Duration? connectionTimeout,
    int maxBufferedEvents = 1024,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    if (sessionId.isEmpty || sessionId == '.' || sessionId == '..') {
      throw const FormatException(
        'Live sessionId: expected an opaque path identifier',
      );
    }
    final String encoded;
    try {
      encoded = Uri.encodeComponent(sessionId);
    } on ArgumentError {
      throw const FormatException(
        'Live sessionId: expected an encodable opaque path identifier',
      );
    }
    return openLiveConnection(
      config: config,
      requestBuilder: requestBuilder,
      sideband: true,
      endpoint: '/live/sessions/$encoded/attach',
      gracefulClose: gracefulClose,
      connector: connector,
      additionalHeaders: additionalHeaders,
      connectionTimeout: connectionTimeout,
      maxBufferedEvents: maxBufferedEvents,
      abortTrigger: abortTrigger,
      ensureNotClosed: ensureNotClosed,
    ).then((connection) => connection as LiveSidebandConnection);
  }

  /// Opens a new fork of a finalized stored session without startup or replay.
  ///
  /// Explicitly call `start(LiveForkSessionStartEvent(session: ...))` and await
  /// the new session acknowledgment. An empty overrides object inherits the
  /// stored configuration; the model, voice and conversation cannot be changed.
  /// Storage availability and outstanding application state remain caller-owned.
  Future<LiveForkConnection> forkConnection(
    String sessionId, {
    LiveWebSocketConnector? connector,
    Map<String, String>? additionalHeaders,
    Duration? connectionTimeout,
    int maxBufferedEvents = 1024,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    if (sessionId.isEmpty || sessionId == '.' || sessionId == '..') {
      throw const FormatException(
        'Live sessionId: expected an opaque path identifier',
      );
    }
    final String encoded;
    try {
      encoded = Uri.encodeComponent(sessionId);
      if (Uri.decodeComponent(encoded) != sessionId) {
        throw const FormatException();
      }
    } on ArgumentError {
      throw const FormatException(
        'Live sessionId: expected an encodable opaque path identifier',
      );
    } on FormatException {
      throw const FormatException(
        'Live sessionId: expected an encodable opaque path identifier',
      );
    }
    return openLiveConnection(
      config: config,
      requestBuilder: requestBuilder,
      sideband: false,
      fork: true,
      endpoint: '/live/sessions/$encoded/fork',
      connector: connector,
      additionalHeaders: additionalHeaders,
      connectionTimeout: connectionTimeout,
      maxBufferedEvents: maxBufferedEvents,
      abortTrigger: abortTrigger,
      ensureNotClosed: ensureNotClosed,
    ).then((connection) => connection as LiveForkConnection);
  }

  LiveSessionsResource? _sessions;

  /// Cached HTTP sessions resource.
  LiveSessionsResource get sessions => _sessions ??= LiveSessionsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
    streamClientFactory: streamClientFactory,
  );
}

/// The seven Live HTTP operations and two recording-download modes.
///
/// Applications supply SDP, media, SIP providers, storage policy and explicit
/// control decisions. Creating SIP returns initialization, before an answer.
class LiveSessionsResource extends ResourceBase {
  /// Creates the HTTP sessions resource.
  LiveSessionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

  static const _endpoint = '/live/sessions';

  /// Initializes WebRTC with the caller's offer or places one outbound SIP call.
  ///
  /// A SIP 201 means initialized, not answered. Every creation is a new call;
  /// tracing IDs do not deduplicate calls. Shared POST policy retries only
  /// eligible rejected requests, never ambiguous timeout/connection/5xx results.
  Future<LiveSessionCreateResponse> create(
    LiveSessionCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    request.validate();
    final response = await _send(
      'POST',
      _endpoint,
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );
    _status(response, 201, 'Live session create');
    return parsePrivateAudioResponse(
      response,
      LiveSessionCreateResponse.fromJson,
      'Live session create',
    );
  }

  /// Accepts the caller-selected incoming SIP session with startup configuration.
  Future<void> accept(
    String sessionId,
    LiveCallAcceptRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final endpoint = _item(sessionId, 'accept');
    request.validate();
    _empty(
      await _send(
        'POST',
        endpoint,
        body: request.toJson(),
        abortTrigger: abortTrigger,
      ),
      'Live call accept',
    );
  }

  /// Rejects an incoming SIP session with an explicit status from 300 to 699.
  Future<void> reject(
    String sessionId,
    LiveCallRejectRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final endpoint = _item(sessionId, 'reject');
    request.validate();
    _empty(
      await _send(
        'POST',
        endpoint,
        body: request.toJson(),
        abortTrigger: abortTrigger,
      ),
      'Live call reject',
    );
  }

  /// Transfers a SIP session to the caller-selected nonblank Refer-To URI.
  Future<void> refer(
    String sessionId,
    LiveCallReferRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final endpoint = _item(sessionId, 'refer');
    request.validate();
    _empty(
      await _send(
        'POST',
        endpoint,
        body: request.toJson(),
        abortTrigger: abortTrigger,
      ),
      'Live call refer',
    );
  }

  /// Ends the caller-selected SIP session with an empty request body.
  Future<void> hangup(String sessionId, {Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    _empty(
      await _send(
        'POST',
        _item(sessionId, 'hangup'),
        abortTrigger: abortTrigger,
      ),
      'Live call hangup',
    );
  }

  /// Downloads untouched stereo WAV bytes from a stored finalized recording.
  ///
  /// Input is the left channel and output the right. Storage defaults false,
  /// requires project policy and is unavailable with ZDR. Finalized recordings
  /// are available for 30 days. This method does not poll or enable storage.
  Future<Uint8List> downloadRecording(
    String sessionId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final response = await _send(
      'GET',
      _recording(sessionId),
      accept: 'audio/wav',
      abortTrigger: abortTrigger,
    );
    _recordingResponse(response);
    return response.bodyBytes;
  }

  /// Downloads original stereo WAV chunks through an owned stream client.
  ///
  /// A supplied factory owns its client unless it returns the borrowed shared
  /// client. Completion, errors and cancellation release this request. No audio
  /// is parsed as JSON, transcoded, replayed or implicitly concatenated.
  Stream<Uint8List> downloadRecordingStream(
    String sessionId, {
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final endpoint = _recording(sessionId);
    final fallbackRequest = http.Request(
      'GET',
      requestBuilder.buildUrl(endpoint),
    );
    return openPrivateByteStream(
      httpClient: httpClient,
      streamClientFactory: streamClientFactory,
      requestBuilder: requestBuilder,
      method: 'GET',
      endpoint: endpoint,
      accept: 'audio/wav',
      timeout: config.timeout,
      context: 'Live recording',
      parseError: (response) => parseHttpErrorResponse(
        response,
        request: response.request ?? fallbackRequest,
      ),
      validateResponse: _recordingResponse,
      ensureNotClosed: ensureNotClosed,
      abortTrigger: abortTrigger,
    );
  }

  /// Forks a completed stored session onto a new caller-owned WebRTC connection.
  ///
  /// Omitted or empty overrides inherit configuration. The result contains a
  /// new session ID and answer SDP; this method does not connect the peer.
  Future<LiveCreateResponse> fork(
    String sessionId,
    LiveForkRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final endpoint = _item(sessionId, 'fork');
    request.validate();
    final response = await _send(
      'POST',
      endpoint,
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );
    _status(response, 201, 'Live session fork');
    return parsePrivateAudioResponse(
      response,
      LiveCreateResponse.fromJson,
      'Live session fork',
    );
  }

  Future<http.Response> _send(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    String? accept,
    Future<void>? abortTrigger,
  }) async {
    await checkPrivateAudioAbort(abortTrigger, 'Live');
    ensureNotClosed?.call();
    final request = http.Request(method, requestBuilder.buildUrl(endpoint))
      ..headers.addAll(
        requestBuilder.buildHeaders(
          additionalHeaders: {
            'Accept': accept ?? (body == null ? '*/*' : 'application/json'),
            if (body != null) 'Content-Type': 'application/json',
          },
        ),
      )
      ..headers['accept'] =
          accept ?? (body == null ? '*/*' : 'application/json');
    if (body == null) {
      request.headers.remove('content-type');
    } else {
      request.headers['content-type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    return sendPrivateAudioRequest(
      request,
      interceptorChain: interceptorChain,
      context: 'Live',
      abortTrigger: abortTrigger,
    );
  }

  String _item(String sessionId, String action) {
    if (sessionId.isEmpty || sessionId == '.' || sessionId == '..') {
      throw const FormatException(
        'Live sessionId: expected a nonempty opaque path identifier',
      );
    }
    try {
      return '$_endpoint/${Uri.encodeComponent(sessionId)}/$action';
    } on ArgumentError {
      throw const FormatException(
        'Live sessionId: expected an encodable opaque path identifier',
      );
    }
  }

  String _recording(String sessionId) {
    final match = RegExp(r'^live_[A-Za-z0-9_-]{1,128}$').firstMatch(sessionId);
    if (match == null || match.end != sessionId.length) {
      throw const FormatException(
        'Live recording sessionId: expected the declared stored-session identifier',
      );
    }
    return _item(sessionId, 'content');
  }
}

void _status(http.BaseResponse response, int expected, String context) {
  if (response.statusCode != expected) {
    throw ParseException(
      message: '$context response: expected HTTP $expected.',
      cause: response,
    );
  }
}

void _empty(http.Response response, String context) {
  _status(response, 200, context);
  if (response.bodyBytes.isNotEmpty) {
    throw ParseException(
      message: '$context response: expected an empty body.',
      responseBody: utf8.decode(response.bodyBytes, allowMalformed: true),
      cause: response,
    );
  }
}

void _recordingResponse(http.BaseResponse response) {
  _status(response, 200, 'Live recording');
  final mediaType = response.headers['content-type']
      ?.split(';')
      .first
      .trim()
      .toLowerCase();
  if (mediaType != 'audio/wav') {
    throw ParseException(
      message: 'Live recording response: expected audio/wav.',
      cause: response,
    );
  }
}
