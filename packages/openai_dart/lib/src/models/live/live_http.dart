import 'dart:convert';

import 'live_config.dart';
import 'live_json_helpers.dart';

/// Writable transport for HTTP Live creation.
///
/// Offers and per-call SIP credentials are separate from received transports.
sealed class LiveTransport extends LiveJsonModel {
  /// Creates a writable transport.
  const LiveTransport();

  /// Parses a closed WebRTC or SIP request transport.
  factory LiveTransport.fromJson(Map<String, dynamic> json) =>
      switch (requireLiveString(json['type'], 'LiveTransport.type')) {
        'webrtc' => LiveWebRTCTransport.fromJson(json),
        'sip' => LiveSIPTransport.fromJson(json),
        _ => throw const FormatException(
          'LiveTransport.type: unsupported value',
        ),
      };

  /// Transport discriminator.
  String get type;

  /// Validates the writable transport before authentication.
  @override
  void validate();

  @override
  Map<String, dynamic> toJson();
}

/// A WebRTC offer supplied by the caller; this client does not create media.
final class LiveWebRTCTransport extends LiveTransport {
  /// Creates a transport containing a nonempty offer [sdp].
  LiveWebRTCTransport({required this.sdp}) {
    validate();
  }

  /// Parses a closed WebRTC offer.
  factory LiveWebRTCTransport.fromJson(Map<String, dynamic> json) {
    _closed(json, const {'type', 'sdp'}, 'LiveWebRTCTransport');
    _tag(json, 'webrtc', 'LiveWebRTCTransport');
    return LiveWebRTCTransport(
      sdp: requireLiveString(json['sdp'], 'LiveWebRTCTransport.sdp'),
    );
  }

  /// Original nonempty offer SDP, retained without normalization.
  final String sdp;

  @override
  String get type => 'webrtc';

  @override
  void validate() => validateLiveLength(sdp, 'LiveWebRTCTransport.sdp', min: 1);

  @override
  Map<String, dynamic> toJson() => {'type': type, 'sdp': sdp};

  /// Copies the original offer or replaces it explicitly.
  LiveWebRTCTransport copyWith({String? sdp}) =>
      LiveWebRTCTransport(sdp: sdp ?? this.sdp);
}

/// SIP Digest credentials supplied for one outbound call.
///
/// Credentials remain explicitly readable and are omitted from diagnostics.
final class LiveSIPTrunkAuth extends LiveJsonModel {
  /// Creates Digest authentication with the documented UTF-8 byte limits.
  LiveSIPTrunkAuth({required this.username, required this.password}) {
    validate();
  }

  /// Parses a closed Digest authentication object.
  factory LiveSIPTrunkAuth.fromJson(Map<String, dynamic> json) {
    _closed(json, const {'type', 'username', 'password'}, 'LiveSIPTrunkAuth');
    _tag(json, 'digest', 'LiveSIPTrunkAuth');
    return LiveSIPTrunkAuth(
      username: requireLiveString(
        json['username'],
        'LiveSIPTrunkAuth.username',
      ),
      password: requireLiveString(
        json['password'],
        'LiveSIPTrunkAuth.password',
      ),
    );
  }

  /// Provider username; nonblank, at most 256 UTF-8 bytes, without CR/LF/NUL.
  final String username;

  /// Provider password; nonempty, at most 4096 UTF-8 bytes, without CR/LF/NUL.
  final String password;

  /// Fixed Digest authentication discriminator.
  String get type => 'digest';

  /// Validates credentials without echoing their contents.
  @override
  void validate() {
    _credential(username, 'LiveSIPTrunkAuth.username', 256, nonblank: true);
    _credential(password, 'LiveSIPTrunkAuth.password', 4096);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'username': username,
    'password': password,
  };

  /// Copies all credential fields.
  LiveSIPTrunkAuth copyWith({String? username, String? password}) =>
      LiveSIPTrunkAuth(
        username: username ?? this.username,
        password: password ?? this.password,
      );
}

/// TLS SIP provider configuration for one outbound call.
final class LiveSIPTrunk extends LiveJsonModel {
  /// Creates a trunk without resolving or contacting [providerUrl].
  LiveSIPTrunk({
    required this.providerUrl,
    required this.auth,
    required this.callerNumber,
  }) {
    validate();
  }

  /// Parses a closed per-call trunk configuration.
  factory LiveSIPTrunk.fromJson(Map<String, dynamic> json) {
    _closed(json, const {
      'provider_url',
      'auth',
      'caller_number',
    }, 'LiveSIPTrunk');
    return LiveSIPTrunk(
      providerUrl: requireLiveString(
        json['provider_url'],
        'LiveSIPTrunk.providerUrl',
      ),
      auth: LiveSIPTrunkAuth.fromJson(
        requireLiveObject(json['auth'], 'LiveSIPTrunk.auth'),
      ),
      callerNumber: requireLiveString(
        json['caller_number'],
        'LiveSIPTrunk.callerNumber',
      ),
    );
  }

  /// `sips:host[:port][;transport=tcp]`, preserving caller spelling.
  ///
  /// Local hostnames and literal private/local addresses are rejected. This
  /// validation performs no DNS lookup; the service enforces provider policy.
  final String providerUrl;

  /// Explicit caller-owned Digest credentials.
  final LiveSIPTrunkAuth auth;

  /// E.164 caller phone number placed in the SIP From header.
  final String callerNumber;

  /// Validates the documented URI, credential and phone-number constraints.
  @override
  void validate() {
    _provider(providerUrl);
    auth.validate();
    _e164(callerNumber, 'LiveSIPTrunk.callerNumber');
  }

  @override
  Map<String, dynamic> toJson() => {
    'provider_url': providerUrl,
    'auth': auth.toJson(),
    'caller_number': callerNumber,
  };

  /// Copies all per-call trunk fields.
  LiveSIPTrunk copyWith({
    String? providerUrl,
    LiveSIPTrunkAuth? auth,
    String? callerNumber,
  }) => LiveSIPTrunk(
    providerUrl: providerUrl ?? this.providerUrl,
    auth: auth ?? this.auth,
    callerNumber: callerNumber ?? this.callerNumber,
  );
}

/// An outbound SIP call request, using an E.164 destination and a TLS trunk.
final class LiveSIPTransport extends LiveTransport {
  /// Creates one new outbound call; caller owns service/provider eligibility.
  LiveSIPTransport({required this.destination, required this.trunk}) {
    validate();
  }

  /// Parses a closed outbound SIP request transport.
  factory LiveSIPTransport.fromJson(Map<String, dynamic> json) {
    _closed(json, const {'type', 'destination', 'trunk'}, 'LiveSIPTransport');
    _tag(json, 'sip', 'LiveSIPTransport');
    return LiveSIPTransport(
      destination: requireLiveString(
        json['destination'],
        'LiveSIPTransport.destination',
      ),
      trunk: LiveSIPTrunk.fromJson(
        requireLiveObject(json['trunk'], 'LiveSIPTransport.trunk'),
      ),
    );
  }

  /// E.164 number to call; SIP URI destinations are unsupported.
  final String destination;

  /// TLS signaling, Digest credentials and caller number for this call.
  final LiveSIPTrunk trunk;

  @override
  String get type => 'sip';

  @override
  void validate() {
    _e164(destination, 'LiveSIPTransport.destination');
    trunk.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'destination': destination,
    'trunk': trunk.toJson(),
  };

  /// Copies all outbound-call transport fields.
  LiveSIPTransport copyWith({String? destination, LiveSIPTrunk? trunk}) =>
      LiveSIPTransport(
        destination: destination ?? this.destination,
        trunk: trunk ?? this.trunk,
      );
}

/// A closed HTTP request that initializes WebRTC or places an outbound SIP call.
final class LiveSessionCreateRequest extends LiveJsonModel {
  /// Creates startup configuration and a writable media transport.
  LiveSessionCreateRequest({required this.session, required this.transport}) {
    validate();
  }

  /// Maximum outbound SIP JSON body size: 1 MiB of encoded UTF-8.
  ///
  /// This guide limit does not constrain WebRTC creation or replace individual
  /// tool/configuration limits and service-enforced token limits.
  static const int maxSipRequestBytes = 1024 * 1024;

  /// Parses a closed canonical HTTP creation request.
  factory LiveSessionCreateRequest.fromJson(Map<String, dynamic> json) {
    _closed(json, const {'session', 'transport'}, 'LiveSessionCreateRequest');
    return LiveSessionCreateRequest(
      session: LiveMediaSessionCreateParams.fromJson(
        requireLiveObject(json['session'], 'LiveSessionCreateRequest.session'),
      ),
      transport: LiveTransport.fromJson(
        requireLiveObject(
          json['transport'],
          'LiveSessionCreateRequest.transport',
        ),
      ),
    );
  }

  /// Complete immutable startup configuration for the chosen media transport.
  final LiveMediaSessionCreateParams session;

  /// WebRTC offer or per-call outbound SIP configuration.
  final LiveTransport transport;

  /// Validates writable admission before authentication or dispatch.
  @override
  void validate() {
    transport.validate();
    session.validateForTransport(transport.type);
    if (transport is LiveSIPTransport &&
        utf8.encode(jsonEncode(toJson())).length > maxSipRequestBytes) {
      throw const FormatException(
        'LiveSessionCreateRequest: outbound SIP JSON body exceeds 1 MiB of UTF-8',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'session': session.toJson(),
    'transport': transport.toJson(),
  };

  /// Copies startup configuration and transport.
  LiveSessionCreateRequest copyWith({
    LiveMediaSessionCreateParams? session,
    LiveTransport? transport,
  }) => LiveSessionCreateRequest(
    session: session ?? this.session,
    transport: transport ?? this.transport,
  );
}

/// Accepts an incoming SIP call with fixed Live startup configuration.
final class LiveCallAcceptRequest extends LiveJsonModel {
  /// Creates an explicit incoming-call acceptance request.
  LiveCallAcceptRequest({required this.session}) {
    validate();
  }

  /// Parses the closed acceptance wrapper.
  factory LiveCallAcceptRequest.fromJson(Map<String, dynamic> json) {
    _closed(json, const {'session'}, 'LiveCallAcceptRequest');
    return LiveCallAcceptRequest(
      session: LiveCallAcceptSession.fromJson(
        requireLiveObject(json['session'], 'LiveCallAcceptRequest.session'),
      ),
    );
  }

  /// Startup model/configuration for the accepted SIP call.
  final LiveCallAcceptSession session;

  /// Validates the startup session before authentication.
  @override
  void validate() => session.validate();

  @override
  Map<String, dynamic> toJson() => {'session': session.toJson()};

  /// Copies the startup session.
  LiveCallAcceptRequest copyWith({LiveCallAcceptSession? session}) =>
      LiveCallAcceptRequest(session: session ?? this.session);
}

/// Rejects an incoming SIP call with an explicit SIP status.
final class LiveCallRejectRequest extends LiveJsonModel {
  /// Creates a request with a status from 300 through 699.
  LiveCallRejectRequest({required this.statusCode}) {
    validate();
  }

  /// Parses the closed rejection request without rounding numeric values.
  factory LiveCallRejectRequest.fromJson(Map<String, dynamic> json) {
    _closed(json, const {'status_code'}, 'LiveCallRejectRequest');
    return LiveCallRejectRequest(
      statusCode: requireLiveInt(
        json['status_code'],
        'LiveCallRejectRequest.statusCode',
      ),
    );
  }

  /// Required SIP rejection status, inclusive range 300–699.
  final int statusCode;

  /// Validates the documented SIP status range.
  @override
  void validate() {
    if (!statusCode.isFinite || statusCode < 300 || statusCode > 699) {
      throw const FormatException(
        'LiveCallRejectRequest.statusCode: expected an integer from 300 through 699',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {'status_code': statusCode};

  /// Copies the rejection status.
  LiveCallRejectRequest copyWith({int? statusCode}) =>
      LiveCallRejectRequest(statusCode: statusCode ?? this.statusCode);
}

/// Transfers a SIP call to an explicitly selected destination URI.
final class LiveCallReferRequest extends LiveJsonModel {
  /// Creates a request containing a nonblank URI such as `tel:` or `sip:`.
  LiveCallReferRequest({required this.targetUri}) {
    validate();
  }

  /// Parses the closed call-transfer request.
  factory LiveCallReferRequest.fromJson(Map<String, dynamic> json) {
    _closed(json, const {'target_uri'}, 'LiveCallReferRequest');
    return LiveCallReferRequest(
      targetUri: requireLiveString(
        json['target_uri'],
        'LiveCallReferRequest.targetUri',
      ),
    );
  }

  /// Original nonblank SIP Refer-To URI, without inferred scheme restrictions.
  final String targetUri;

  /// Validates nonblank admission without modifying the caller's URI.
  @override
  void validate() {
    if (targetUri.trim().isEmpty) {
      throw const FormatException(
        'LiveCallReferRequest.targetUri: expected a nonblank URI',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {'target_uri': targetUri};

  /// Copies the selected destination URI.
  LiveCallReferRequest copyWith({String? targetUri}) =>
      LiveCallReferRequest(targetUri: targetUri ?? this.targetUri);
}

/// Forks a stored session onto a new caller-owned WebRTC connection.
final class LiveForkRequest extends LiveJsonModel {
  /// Creates a fork; omitted or empty [session] inherits stored configuration.
  LiveForkRequest({required this.transport, this.session}) {
    validate();
  }

  /// Parses a closed REST fork request.
  factory LiveForkRequest.fromJson(Map<String, dynamic> json) {
    _closed(json, const {'session', 'transport'}, 'LiveForkRequest');
    return LiveForkRequest(
      transport: LiveWebRTCTransport.fromJson(
        requireLiveObject(json['transport'], 'LiveForkRequest.transport'),
      ),
      session: optionalLiveValue(
        json,
        'session',
        'LiveForkRequest',
        (value, context) => LiveMediaSessionForkParams.fromJson(
          requireLiveObject(value, context),
        ),
      ),
    );
  }

  /// Original WebRTC offer for the new connection.
  final LiveWebRTCTransport transport;

  /// Optional overrides; absence and an empty object both inherit settings.
  final LiveMediaSessionForkParams? session;

  /// Validates writable fork admission.
  @override
  void validate() {
    transport.validate();
    session?.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    'transport': transport.toJson(),
    if (session != null) 'session': session!.toJson(),
  };

  /// Copies all fields; `session: null` clears the optional wrapper.
  LiveForkRequest copyWith({
    LiveWebRTCTransport? transport,
    Object? session = liveUnset,
  }) => LiveForkRequest(
    transport: transport ?? this.transport,
    session: copyLiveValue<LiveMediaSessionForkParams>(
      session,
      this.session,
      'LiveForkRequest.session',
    ),
  );
}

/// Received transport; future variants/metadata are retained without becoming writable.
sealed class LiveResponseTransport extends LiveJsonModel {
  /// Creates a receive-only transport.
  const LiveResponseTransport();

  /// Parses known WebRTC/SIP responses or a future receive-only variant.
  factory LiveResponseTransport.fromJson(Map<String, dynamic> json) =>
      switch (requireLiveString(json['type'], 'LiveResponseTransport.type')) {
        'webrtc' => LiveWebRTCResponseTransport.fromJson(json),
        'sip' => LiveSIPResponseTransport.fromJson(json),
        _ => UnknownLiveResponseTransport(rawJson: json),
      };

  /// Received discriminator, never inferred from a request.
  String get type;

  /// Immutable original received JSON, including private future metadata.
  Map<String, dynamic> get rawJson;

  @override
  Map<String, dynamic> toJson();
}

/// A received WebRTC answer, distinct from a writable SDP offer.
final class LiveWebRTCResponseTransport extends LiveResponseTransport {
  /// Creates an answer while retaining immutable future received metadata.
  LiveWebRTCResponseTransport({
    required this.sdp,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveWebRTCResponseTransport',
         knownKeys: _fields,
       ) {
    validateLiveLength(sdp, 'LiveWebRTCResponseTransport.sdp', min: 1);
  }

  /// Parses a strict known discriminator/nonempty answer with open metadata.
  factory LiveWebRTCResponseTransport.fromJson(Map<String, dynamic> json) {
    _tag(json, 'webrtc', 'LiveWebRTCResponseTransport');
    return LiveWebRTCResponseTransport(
      sdp: requireLiveString(json['sdp'], 'LiveWebRTCResponseTransport.sdp'),
      rawJson: json,
    );
  }

  static const _fields = {'type', 'sdp'};

  /// Original answer SDP for the caller's peer connection.
  final String sdp;

  @override
  String get type => 'webrtc';

  @override
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _fields, {'type': type, 'sdp': sdp});

  /// Copies the typed answer and preserves/replaces immutable future metadata.
  LiveWebRTCResponseTransport copyWith({
    String? sdp,
    Map<String, dynamic>? rawJson,
  }) => LiveWebRTCResponseTransport(
    sdp: sdp ?? this.sdp,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Minimal SIP initialization result; it has no writable credentials or SDP.
///
/// A 201 does not mean the callee answered. Future received members remain
/// explicitly accessible in [rawJson] and are redacted from diagnostics.
final class LiveSIPResponseTransport extends LiveResponseTransport {
  /// Creates the receive-only SIP marker.
  LiveSIPResponseTransport({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveSIPResponseTransport',
        knownKeys: _fields,
      );

  /// Parses the SIP marker without requiring request credentials or SDP.
  factory LiveSIPResponseTransport.fromJson(Map<String, dynamic> json) {
    _tag(json, 'sip', 'LiveSIPResponseTransport');
    return LiveSIPResponseTransport(rawJson: json);
  }

  static const _fields = {'type'};

  @override
  String get type => 'sip';

  @override
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _fields, {'type': type});

  /// Copies immutable future received metadata.
  LiveSIPResponseTransport copyWith({Map<String, dynamic>? rawJson}) =>
      LiveSIPResponseTransport(rawJson: rawJson ?? this.rawJson);
}

/// A future receive-only transport; it cannot be supplied as [LiveTransport].
final class UnknownLiveResponseTransport extends LiveResponseTransport {
  /// Snapshots all finite future transport data.
  UnknownLiveResponseTransport({required Map<String, dynamic> rawJson})
    : rawJson = snapshotLiveJson(
        rawJson,
        'UnknownLiveResponseTransport',
        knownKeys: const {'type'},
      ) {
    final type = requireLiveString(
      this.rawJson['type'],
      'UnknownLiveResponseTransport.type',
    );
    if (type == 'webrtc' || type == 'sip') {
      throw const FormatException(
        'UnknownLiveResponseTransport.type: expected a future transport variant',
      );
    }
  }

  /// Parses a future received transport.
  factory UnknownLiveResponseTransport.fromJson(Map<String, dynamic> json) =>
      UnknownLiveResponseTransport(rawJson: json);

  @override
  String get type => rawJson['type'] as String;

  @override
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => rawJson;

  /// Copies or replaces the complete immutable future transport.
  UnknownLiveResponseTransport copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownLiveResponseTransport(rawJson: rawJson ?? this.rawJson);
}

/// The opaque identifier returned for a newly initialized session.
final class LiveCreatedSession extends LiveJsonModel {
  /// Creates an identifier without inventing a prefix or ID grammar.
  LiveCreatedSession({
    required this.id,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveCreatedSession',
         knownKeys: _fields,
       );

  /// Parses the required identifier and retains immutable received metadata.
  factory LiveCreatedSession.fromJson(Map<String, dynamic> json) =>
      LiveCreatedSession(
        id: requireLiveString(json['id'], 'LiveCreatedSession.id'),
        rawJson: json,
      );

  static const _fields = {'id'};

  /// Opaque original session ID, including its returned prefix.
  final String id;

  /// Complete immutable original JSON for explicit caller inspection.
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _fields, {'id': id});

  /// Copies the identifier and preserves/replaces future metadata.
  LiveCreatedSession copyWith({String? id, Map<String, dynamic>? rawJson}) =>
      LiveCreatedSession(id: id ?? this.id, rawJson: rawJson ?? this.rawJson);
}

/// HTTP creation result for WebRTC or outbound SIP initialization.
final class LiveSessionCreateResponse extends LiveJsonModel {
  /// Creates a received result with independent request/response transports.
  LiveSessionCreateResponse({
    required this.session,
    required this.transport,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionCreateResponse',
         knownKeys: _fields,
       );

  /// Parses both canonical result branches and immutable future metadata.
  factory LiveSessionCreateResponse.fromJson(Map<String, dynamic> json) =>
      LiveSessionCreateResponse(
        session: LiveCreatedSession.fromJson(
          requireLiveObject(
            json['session'],
            'LiveSessionCreateResponse.session',
          ),
        ),
        transport: LiveResponseTransport.fromJson(
          requireLiveObject(
            json['transport'],
            'LiveSessionCreateResponse.transport',
          ),
        ),
        rawJson: json,
      );

  static const _fields = {'session', 'transport'};

  /// Initialized session identifier.
  final LiveCreatedSession session;

  /// WebRTC answer or minimal SIP marker, including received future variants.
  final LiveResponseTransport transport;

  /// Complete immutable received JSON; automatic diagnostics redact it.
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _fields, {
    'session': session.toJson(),
    'transport': transport.toJson(),
  });

  /// Copies all typed fields; fresh child replacements replace old child extras.
  LiveSessionCreateResponse copyWith({
    LiveCreatedSession? session,
    LiveResponseTransport? transport,
    Map<String, dynamic>? rawJson,
  }) => LiveSessionCreateResponse(
    session: session ?? this.session,
    transport: transport ?? this.transport,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// REST fork result with a new session identifier and WebRTC answer.
final class LiveCreateResponse extends LiveJsonModel {
  /// Creates the WebRTC-only received fork result.
  LiveCreateResponse({
    required this.session,
    required this.transport,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveCreateResponse',
         knownKeys: _fields,
       );

  /// Parses the required WebRTC answer; a SIP fork result is malformed.
  factory LiveCreateResponse.fromJson(Map<String, dynamic> json) =>
      LiveCreateResponse(
        session: LiveCreatedSession.fromJson(
          requireLiveObject(json['session'], 'LiveCreateResponse.session'),
        ),
        transport: LiveWebRTCResponseTransport.fromJson(
          requireLiveObject(json['transport'], 'LiveCreateResponse.transport'),
        ),
        rawJson: json,
      );

  static const _fields = {'session', 'transport'};

  /// New session ID; never inferred from or replaced by the original ID.
  final LiveCreatedSession session;

  /// WebRTC answer for the new peer connection.
  final LiveWebRTCResponseTransport transport;

  /// Complete immutable received JSON.
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _fields, {
    'session': session.toJson(),
    'transport': transport.toJson(),
  });

  /// Copies all typed fields and immutable future metadata.
  LiveCreateResponse copyWith({
    LiveCreatedSession? session,
    LiveWebRTCResponseTransport? transport,
    Map<String, dynamic>? rawJson,
  }) => LiveCreateResponse(
    session: session ?? this.session,
    transport: transport ?? this.transport,
    rawJson: rawJson ?? this.rawJson,
  );
}

void _closed(Map<String, dynamic> json, Set<String> fields, String context) {
  requireClosedLiveJson(json, fields, context);
  snapshotLiveJson(json, context, knownKeys: fields);
}

void _tag(Map<String, dynamic> json, String expected, String context) {
  if (requireLiveString(json['type'], '$context.type') != expected) {
    throw FormatException('$context.type: unexpected discriminator');
  }
}

void _credential(
  String value,
  String context,
  int maxBytes, {
  bool nonblank = false,
}) {
  if (value.isEmpty ||
      (nonblank && value.trim().isEmpty) ||
      utf8.encode(value).length > maxBytes ||
      value.contains(RegExp(r'[\r\n\x00]'))) {
    throw FormatException('$context: invalid credential length or characters');
  }
}

void _e164(String value, String context) {
  final match = RegExp(r'^\+[1-9][0-9]{1,14}$').firstMatch(value);
  if (match == null || match.end != value.length) {
    throw FormatException('$context: expected an E.164 phone number');
  }
}

void _provider(String value) {
  const message =
      'LiveSIPTrunk.providerUrl: expected a public TLS SIP provider endpoint';
  final match = RegExp(
    r'^sips:(\[[0-9a-f:.]+\]|[a-z0-9.-]+)(?::([0-9]{1,5}))?(?:;transport=tcp)?$',
    caseSensitive: false,
  ).firstMatch(value);
  if (match == null || match.end != value.length) {
    throw const FormatException(message);
  }
  final port = match.group(2);
  if (port != null && (int.parse(port) < 1 || int.parse(port) > 65535)) {
    throw const FormatException(message);
  }
  var host = match.group(1)!.toLowerCase();
  if (host.startsWith('[')) {
    if (!_publicIPv6(host.substring(1, host.length - 1))) {
      throw const FormatException(message);
    }
    return;
  }
  if (RegExp(r'^[0-9.]+$').hasMatch(host)) {
    if (!_publicIPv4(host)) throw const FormatException(message);
    return;
  }
  if (host.endsWith('.')) host = host.substring(0, host.length - 1);
  final labels = host.split('.');
  if (labels.length < 2 ||
      labels.any(
        (label) =>
            !RegExp(r'^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$').hasMatch(label),
      ) ||
      host == 'localhost.localdomain' ||
      host == 'home.arpa' ||
      const [
        'localhost',
        'local',
        'localdomain',
        'internal',
        'lan',
      ].contains(labels.last) ||
      host.endsWith('.home.arpa')) {
    throw const FormatException(message);
  }
}

bool _publicIPv4(String host) {
  final parts = host.split('.');
  if (parts.length != 4 ||
      parts.any(
        (part) =>
            part.isEmpty ||
            (part.length > 1 && part.startsWith('0')) ||
            int.tryParse(part) == null ||
            int.parse(part) > 255,
      )) {
    return false;
  }
  final bytes = parts.map(int.parse).toList();
  return bytes[0] != 0 &&
      bytes[0] != 10 &&
      bytes[0] != 127 &&
      bytes[0] < 224 &&
      !(bytes[0] == 100 && bytes[1] >= 64 && bytes[1] <= 127) &&
      !(bytes[0] == 169 && bytes[1] == 254) &&
      !(bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) &&
      !(bytes[0] == 192 && bytes[1] == 168);
}

bool _publicIPv6(String host) {
  final compression = host.split('::');
  if (compression.length > 2) return false;
  if (compression.length == 2 && compression[0].contains('.')) return false;
  List<int>? parseParts(String part) {
    if (part.isEmpty) return <int>[];
    final tokens = part.split(':');
    final result = <int>[];
    for (var index = 0; index < tokens.length; index++) {
      final token = tokens[index];
      if (token.contains('.')) {
        if (index != tokens.length - 1) return null;
        final bytes = token.split('.');
        if (bytes.length != 4 ||
            bytes.any(
              (byte) =>
                  int.tryParse(byte) == null ||
                  int.parse(byte) > 255 ||
                  (byte.length > 1 && byte.startsWith('0')),
            )) {
          return null;
        }
        result
          ..add((int.parse(bytes[0]) << 8) | int.parse(bytes[1]))
          ..add((int.parse(bytes[2]) << 8) | int.parse(bytes[3]));
      } else {
        if (!RegExp(r'^[0-9a-f]{1,4}$').hasMatch(token)) return null;
        result.add(int.parse(token, radix: 16));
      }
    }
    return result;
  }

  final left = parseParts(compression[0]);
  final right = compression.length == 2 ? parseParts(compression[1]) : <int>[];
  if (left == null || right == null) return false;
  final count = left.length + right.length;
  if ((compression.length == 1 && count != 8) ||
      (compression.length == 2 && count >= 8)) {
    return false;
  }
  final words = <int>[
    ...left,
    if (compression.length == 2) ...List<int>.filled(8 - count, 0),
    ...right,
  ];
  if (words.every((word) => word == 0) ||
      (words.take(7).every((word) => word == 0) && words[7] == 1) ||
      (words[0] & 0xfe00) == 0xfc00 ||
      (words[0] & 0xffc0) == 0xfe80 ||
      (words[0] & 0xffc0) == 0xfec0 ||
      (words[0] & 0xff00) == 0xff00) {
    return false;
  }
  if (words.take(5).every((word) => word == 0) &&
      (words[5] == 0 || words[5] == 0xffff)) {
    return _publicIPv4(
      '${words[6] >> 8}.${words[6] & 255}.${words[7] >> 8}.${words[7] & 255}',
    );
  }
  return true;
}
