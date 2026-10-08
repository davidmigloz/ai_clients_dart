import 'package:meta/meta.dart';

import 'live_audio.dart';
import 'live_delegation.dart';
import 'live_history.dart';
import 'live_json_helpers.dart';

/// A Live server event selector for the WebRTC frontend data channel.
@immutable
class LiveAllowedServerEventParam extends LiveJsonModel {
  /// Creates LiveAllowedServerEventParam.
  LiveAllowedServerEventParam({
    this.responseEvent,
    required this.type,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveAllowedServerEventParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'response_event', 'type'};

  /// The nested Responses event type. Required when type is 'response.event'; forbidden for other event types.
  final String? responseEvent;

  /// The outer Live server event type. Use 'response.event' for Responses events.
  final String type;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveAllowedServerEventParam with contextual validation.
  factory LiveAllowedServerEventParam.fromJson(Map<String, dynamic> json) {
    requireClosedLiveJson(json, _knownKeys, 'LiveAllowedServerEventParam');
    return LiveAllowedServerEventParam(
      responseEvent: optionalLiveValue(
        json,
        'response_event',
        'LiveAllowedServerEventParam',
        requireLiveString,
        nullable: false,
      ),
      type: requireLiveString(json['type'], 'LiveAllowedServerEventParam.type'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    requireClosedLiveJson(rawJson, _knownKeys, 'LiveAllowedServerEventParam');
    if (responseEvent != null) {
      validateLiveLength(
        responseEvent!,
        'LiveAllowedServerEventParam.response_event',
        min: 1,
        max: 256,
      );
    }
    validateLiveLength(
      type,
      'LiveAllowedServerEventParam.type',
      min: 1,
      max: 256,
    );
    if ((type == 'response.event') != (responseEvent != null)) {
      throw const FormatException(
        'LiveAllowedServerEventParam.response_event: required only for response.event',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (responseEvent != null) 'response_event': responseEvent,
    'type': type,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveAllowedServerEventParam copyWith({
    Object? responseEvent = liveUnset,
    String? type,
    Map<String, dynamic>? rawJson,
  }) => LiveAllowedServerEventParam(
    responseEvent: copyLiveValue<String>(
      responseEvent,
      this.responseEvent,
      'LiveAllowedServerEventParam.response_event',
    ),
    type: type ?? this.type,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveAllowedServerEventParam('
      'responseEvent: ${livePresence(responseEvent)}, '
      'type: ${livePresence(type)}, '
      'rawJson: [REDACTED])';
}

/// Control which Live events an untrusted WebRTC frontend can send and receive over its data channel. These restrictions do not apply to trusted sideband connections.
@immutable
class LiveDataChannelConfigParam extends LiveJsonModel {
  /// Creates LiveDataChannelConfigParam.
  LiveDataChannelConfigParam({
    this.allowedClientEvents,
    this.allowedServerEvents,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveDataChannelConfigParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'allowed_client_events', 'allowed_server_events'};

  /// Client event types that the frontend data channel may send. Use 'all' to allow every client event; an empty array allows none. Omission preserves the existing allow-all behavior.
  final LiveAllowedClientEvents? allowedClientEvents;

  /// Server events that may be sent to the frontend data channel. Use 'all' to allow every server event; an empty array allows none. Omission preserves the existing allow-all behavior. Responses events use an object with type 'response.event' and a response_event selector.
  final LiveAllowedServerEvents? allowedServerEvents;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveDataChannelConfigParam with contextual validation.
  factory LiveDataChannelConfigParam.fromJson(Map<String, dynamic> json) {
    return LiveDataChannelConfigParam(
      allowedClientEvents: optionalLiveValue(
        json,
        'allowed_client_events',
        'LiveDataChannelConfigParam',
        (value, context) => LiveAllowedClientEvents.fromJson(value),
        nullable: false,
      ),
      allowedServerEvents: optionalLiveValue(
        json,
        'allowed_server_events',
        'LiveDataChannelConfigParam',
        (value, context) => LiveAllowedServerEvents.fromJson(value),
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    allowedClientEvents?.validate();
    allowedServerEvents?.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (allowedClientEvents != null)
      'allowed_client_events': allowedClientEvents!.toJson(),
    if (allowedServerEvents != null)
      'allowed_server_events': allowedServerEvents!.toJson(),
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveDataChannelConfigParam copyWith({
    Object? allowedClientEvents = liveUnset,
    Object? allowedServerEvents = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveDataChannelConfigParam(
    allowedClientEvents: copyLiveValue<LiveAllowedClientEvents>(
      allowedClientEvents,
      this.allowedClientEvents,
      'LiveDataChannelConfigParam.allowed_client_events',
    ),
    allowedServerEvents: copyLiveValue<LiveAllowedServerEvents>(
      allowedServerEvents,
      this.allowedServerEvents,
      'LiveDataChannelConfigParam.allowed_server_events',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveDataChannelConfigParam('
      'allowedClientEvents: ${livePresence(allowedClientEvents)}, '
      'allowedServerEvents: ${livePresence(allowedServerEvents)}, '
      'rawJson: [REDACTED])';
}

/// Startup-only capabilities for an untrusted frontend attached to a unified WebRTC session. Trusted sideband connections are unaffected.
@immutable
class LiveClientConfigParam extends LiveJsonModel {
  /// Creates LiveClientConfigParam.
  LiveClientConfigParam({
    required this.dataChannel,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveClientConfigParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'data_channel'};

  /// Client and server event permissions for the WebRTC frontend data channel.
  final LiveDataChannelConfigParam dataChannel;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveClientConfigParam with contextual validation.
  factory LiveClientConfigParam.fromJson(Map<String, dynamic> json) {
    return LiveClientConfigParam(
      dataChannel: LiveDataChannelConfigParam.fromJson(
        requireLiveObject(
          json['data_channel'],
          'LiveClientConfigParam.data_channel',
        ),
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    dataChannel.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'data_channel': dataChannel.toJson(),
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveClientConfigParam copyWith({
    LiveDataChannelConfigParam? dataChannel,
    Map<String, dynamic>? rawJson,
  }) => LiveClientConfigParam(
    dataChannel: dataChannel ?? this.dataChannel,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveClientConfigParam('
      'dataChannel: ${livePresence(dataChannel)}, '
      'rawJson: [REDACTED])';
}

/// Initial configuration for a Live session, including its model, conversation instructions, audio, and delegated task handling.
@immutable
class LiveSessionCreateParams extends LiveJsonModel {
  /// Creates LiveSessionCreateParams.
  LiveSessionCreateParams({
    this.audio,
    this.client,
    this.delegation,
    bool hasDelegation = false,
    List<LiveInitialItem>? input,
    this.instructions,
    bool hasInstructions = false,
    required this.model,
    this.store,
    Map<String, dynamic> rawJson = const {},
  }) : hasDelegation = hasDelegation || delegation != null,
       input = input == null ? null : List.unmodifiable(input),
       hasInstructions = hasInstructions || instructions != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionCreateParams',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {
    'audio',
    'client',
    'delegation',
    'input',
    'instructions',
    'model',
    'store',
  };

  /// Startup audio configuration. Only primary WebSockets accept audio.format; WebRTC and SIP negotiate their media format. Voice and format are immutable after startup.
  final LiveInitialSessionAudioParam? audio;

  /// Startup-only capabilities for an untrusted frontend attached to a unified WebRTC session. Trusted sideband connections are unaffected.
  final LiveClientConfigParam? client;

  /// Who handles tasks delegated by the Live model. Omitted or null selects your application; use `responses` to let the API manage a Responses backend.
  final LiveDelegation? delegation;

  /// Distinguishes omission from explicit null for delegation.
  final bool hasDelegation;

  /// Ordered text-only history supplied before startup. Supports developer, user, and assistant messages with one text part each; at most 128 messages and 8,192 rendered tokens in total.
  final List<LiveInitialItem>? input;

  /// Frontend instructions for voice, conversation, interruptions, and when to delegate. Start with the [Live prompting guide](https://developers.openai.com/api/docs/guides/live-prompting); put business rules and tool workflows in a separate [backend prompt](https://developers.openai.com/api/docs/guides/live-delegation#start-with-your-existing-backend-prompt). Limited to 16,384 client-supplied tokens. Omitted or blank instructions use server defaults. Immutable after startup.
  final String? instructions;

  /// Distinguishes omission from explicit null for instructions.
  final bool hasInstructions;

  /// The Live model. Required in the session configuration for every transport; do not pass it as a URL query parameter.
  final String model;

  /// Whether to store the session for later forking and recording download. Defaults to false for new sessions.
  final bool? store;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveSessionCreateParams with contextual validation.
  factory LiveSessionCreateParams.fromJson(Map<String, dynamic> json) {
    return LiveSessionCreateParams(
      audio: optionalLiveValue(
        json,
        'audio',
        'LiveSessionCreateParams',
        (value, context) => LiveInitialSessionAudioParam.fromJson(
          requireLiveObject(value, context),
        ),
        nullable: false,
      ),
      client: optionalLiveValue(
        json,
        'client',
        'LiveSessionCreateParams',
        (value, context) =>
            LiveClientConfigParam.fromJson(requireLiveObject(value, context)),
        nullable: false,
      ),
      delegation: optionalLiveValue(
        json,
        'delegation',
        'LiveSessionCreateParams',
        (value, context) =>
            LiveDelegation.fromJson(requireLiveObject(value, context)),
        nullable: true,
      ),
      hasDelegation: json.containsKey('delegation'),
      input: optionalLiveValue(
        json,
        'input',
        'LiveSessionCreateParams',
        (value, context) => requireLiveList(value, context)
            .map(
              (item) =>
                  LiveInitialItem.fromJson(requireLiveObject(item, context)),
            )
            .toList(),
        nullable: false,
      ),
      instructions: optionalLiveValue(
        json,
        'instructions',
        'LiveSessionCreateParams',
        requireLiveString,
        nullable: true,
      ),
      hasInstructions: json.containsKey('instructions'),
      model: requireLiveString(json['model'], 'LiveSessionCreateParams.model'),
      store: optionalLiveValue(
        json,
        'store',
        'LiveSessionCreateParams',
        requireLiveBool,
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    validateLiveLength(model, 'LiveSessionCreateParams.model', min: 1);
    audio?.validate();
    client?.validate();
    delegation?.validate();
    if (input != null) {
      if (input!.length > 128) {
        throw const FormatException(
          'LiveSessionCreateParams.input: invalid item count',
        );
      }
    }
    for (final item in input ?? const <LiveInitialItem>[]) {
      item.validate();
    }
  }

  /// Checks startup audio and frontend capabilities for the selected transport.
  void validateForTransport(String transport) {
    validate();
    _requireLiveTransport(transport, 'LiveSessionCreateParams');
    if (transport != 'websocket' && audio?.format != null) {
      throw const FormatException(
        'LiveSessionCreateParams.audio.format: primary WebSocket only',
      );
    }
    if (transport != 'webrtc' && client != null) {
      throw const FormatException(
        'LiveSessionCreateParams.client: WebRTC frontend only',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (audio != null) 'audio': audio!.toJson(),
    if (client != null) 'client': client!.toJson(),
    if (hasDelegation) 'delegation': delegation?.toJson(),
    if (input != null) 'input': input!.map((item) => item.toJson()).toList(),
    if (hasInstructions) 'instructions': instructions,
    'model': model,
    if (store != null) 'store': store,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveSessionCreateParams copyWith({
    Object? audio = liveUnset,
    Object? client = liveUnset,
    Object? delegation = liveUnset,
    bool clearDelegation = false,
    Object? input = liveUnset,
    Object? instructions = liveUnset,
    bool clearInstructions = false,
    String? model,
    Object? store = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveSessionCreateParams(
    audio: copyLiveValue<LiveInitialSessionAudioParam>(
      audio,
      this.audio,
      'LiveSessionCreateParams.audio',
    ),
    client: copyLiveValue<LiveClientConfigParam>(
      client,
      this.client,
      'LiveSessionCreateParams.client',
    ),
    delegation: clearDelegation
        ? null
        : copyLiveValue<LiveDelegation>(
            delegation,
            this.delegation,
            'LiveSessionCreateParams.delegation',
          ),
    hasDelegation:
        !clearDelegation &&
        (!identical(delegation, liveUnset) || hasDelegation),
    input: copyLiveValue<List<LiveInitialItem>>(
      input,
      this.input,
      'LiveSessionCreateParams.input',
    ),
    instructions: clearInstructions
        ? null
        : copyLiveValue<String>(
            instructions,
            this.instructions,
            'LiveSessionCreateParams.instructions',
          ),
    hasInstructions:
        !clearInstructions &&
        (!identical(instructions, liveUnset) || hasInstructions),
    model: model ?? this.model,
    store: copyLiveValue<bool>(
      store,
      this.store,
      'LiveSessionCreateParams.store',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveSessionCreateParams('
      'audio: ${livePresence(audio)}, '
      'client: ${livePresence(client)}, '
      'delegation: ${livePresence(delegation)}, '
      'hasDelegation: $hasDelegation, '
      'input: ${livePresence(input)}, '
      'instructions: ${livePresence(instructions)}, '
      'hasInstructions: $hasInstructions, '
      'model: ${livePresence(model)}, '
      'store: ${livePresence(store)}, '
      'rawJson: [REDACTED])';
}

/// The resolved Live session configuration and server-assigned session metadata.
@immutable
class LiveSessionResourceParam extends LiveJsonModel {
  /// Creates LiveSessionResourceParam.
  LiveSessionResourceParam({
    this.audio,
    this.client,
    this.delegation,
    bool hasDelegation = false,
    required this.expiresAt,
    required this.id,
    List<LiveInitialItem>? input,
    this.instructions,
    bool hasInstructions = false,
    required this.model,
    this.store,
    Map<String, dynamic> rawJson = const {},
  }) : hasDelegation = hasDelegation || delegation != null,
       input = input == null ? null : List.unmodifiable(input),
       hasInstructions = hasInstructions || instructions != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionResourceParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {
    'audio',
    'client',
    'delegation',
    'expires_at',
    'id',
    'input',
    'instructions',
    'model',
    'status',
    'store',
  };

  /// Startup audio configuration. Only primary WebSockets accept audio.format; WebRTC and SIP negotiate their media format. Voice and format are immutable after startup.
  final LiveInitialSessionAudioParam? audio;

  /// Startup-only capabilities for an untrusted frontend attached to a unified WebRTC session. Trusted sideband connections are unaffected.
  final LiveClientConfigParam? client;

  /// Who handles tasks delegated by the Live model. Omitted or null selects your application; use `responses` to let the API manage a Responses backend.
  final LiveDelegation? delegation;

  /// Distinguishes omission from explicit null for delegation.
  final bool hasDelegation;

  /// The Unix timestamp, in seconds, at which the Live session expires.
  final int expiresAt;

  /// The unique ID of the Live session. Use this ID for sideband connections, forking, and recording download.
  final String id;

  /// Ordered text-only history supplied before startup. Supports developer, user, and assistant messages with one text part each; at most 128 messages and 8,192 rendered tokens in total.
  final List<LiveInitialItem>? input;

  /// Frontend instructions for voice, conversation, interruptions, and when to delegate. Start with the [Live prompting guide](https://developers.openai.com/api/docs/guides/live-prompting); put business rules and tool workflows in a separate [backend prompt](https://developers.openai.com/api/docs/guides/live-delegation#start-with-your-existing-backend-prompt). Limited to 16,384 client-supplied tokens. Omitted or blank instructions use server defaults. Immutable after startup.
  final String? instructions;

  /// Distinguishes omission from explicit null for instructions.
  final bool hasInstructions;

  /// The Live model. Required in the session configuration for every transport; do not pass it as a URL query parameter.
  final String model;

  /// The status of the session snapshot. Always `active`, including the final snapshot in session.closed; use the event type to determine that the session has closed.
  String get status => 'active';

  /// Whether to store the session for later forking and recording download. Defaults to false for new sessions.
  final bool? store;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveSessionResourceParam with contextual validation.
  factory LiveSessionResourceParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'active',
      'LiveSessionResourceParam',
      key: 'status',
      required: true,
    );
    return LiveSessionResourceParam(
      audio: optionalLiveValue(
        json,
        'audio',
        'LiveSessionResourceParam',
        (value, context) => LiveInitialSessionAudioParam.fromJson(
          requireLiveObject(value, context),
        ),
        nullable: false,
      ),
      client: optionalLiveValue(
        json,
        'client',
        'LiveSessionResourceParam',
        (value, context) =>
            LiveClientConfigParam.fromJson(requireLiveObject(value, context)),
        nullable: false,
      ),
      delegation: optionalLiveValue(
        json,
        'delegation',
        'LiveSessionResourceParam',
        (value, context) =>
            LiveDelegation.fromJson(requireLiveObject(value, context)),
        nullable: true,
      ),
      hasDelegation: json.containsKey('delegation'),
      expiresAt: requireLiveInt(
        json['expires_at'],
        'LiveSessionResourceParam.expires_at',
      ),
      id: requireLiveString(json['id'], 'LiveSessionResourceParam.id'),
      input: optionalLiveValue(
        json,
        'input',
        'LiveSessionResourceParam',
        (value, context) => requireLiveList(value, context)
            .map(
              (item) =>
                  LiveInitialItem.fromJson(requireLiveObject(item, context)),
            )
            .toList(),
        nullable: false,
      ),
      instructions: optionalLiveValue(
        json,
        'instructions',
        'LiveSessionResourceParam',
        requireLiveString,
        nullable: true,
      ),
      hasInstructions: json.containsKey('instructions'),
      model: requireLiveString(json['model'], 'LiveSessionResourceParam.model'),
      store: optionalLiveValue(
        json,
        'store',
        'LiveSessionResourceParam',
        requireLiveBool,
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    validateLiveLength(model, 'LiveSessionResourceParam.model', min: 1);
    audio?.validate();
    client?.validate();
    delegation?.validate();
    if (input != null) {
      if (input!.length > 128) {
        throw const FormatException(
          'LiveSessionResourceParam.input: invalid item count',
        );
      }
    }
    for (final item in input ?? const <LiveInitialItem>[]) {
      item.validate();
    }
  }

  /// Checks startup audio and frontend capabilities for the selected transport.
  void validateForTransport(String transport) {
    validate();
    _requireLiveTransport(transport, 'LiveSessionResourceParam');
    if (transport != 'websocket' && audio?.format != null) {
      throw const FormatException(
        'LiveSessionResourceParam.audio.format: primary WebSocket only',
      );
    }
    if (transport != 'webrtc' && client != null) {
      throw const FormatException(
        'LiveSessionResourceParam.client: WebRTC frontend only',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (audio != null) 'audio': audio!.toJson(),
    if (client != null) 'client': client!.toJson(),
    if (hasDelegation) 'delegation': delegation?.toJson(),
    'expires_at': expiresAt,
    'id': id,
    if (input != null) 'input': input!.map((item) => item.toJson()).toList(),
    if (hasInstructions) 'instructions': instructions,
    'model': model,
    'status': status,
    if (store != null) 'store': store,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveSessionResourceParam copyWith({
    Object? audio = liveUnset,
    Object? client = liveUnset,
    Object? delegation = liveUnset,
    bool clearDelegation = false,
    int? expiresAt,
    String? id,
    Object? input = liveUnset,
    Object? instructions = liveUnset,
    bool clearInstructions = false,
    String? model,
    Object? store = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveSessionResourceParam(
    audio: copyLiveValue<LiveInitialSessionAudioParam>(
      audio,
      this.audio,
      'LiveSessionResourceParam.audio',
    ),
    client: copyLiveValue<LiveClientConfigParam>(
      client,
      this.client,
      'LiveSessionResourceParam.client',
    ),
    delegation: clearDelegation
        ? null
        : copyLiveValue<LiveDelegation>(
            delegation,
            this.delegation,
            'LiveSessionResourceParam.delegation',
          ),
    hasDelegation:
        !clearDelegation &&
        (!identical(delegation, liveUnset) || hasDelegation),
    expiresAt: expiresAt ?? this.expiresAt,
    id: id ?? this.id,
    input: copyLiveValue<List<LiveInitialItem>>(
      input,
      this.input,
      'LiveSessionResourceParam.input',
    ),
    instructions: clearInstructions
        ? null
        : copyLiveValue<String>(
            instructions,
            this.instructions,
            'LiveSessionResourceParam.instructions',
          ),
    hasInstructions:
        !clearInstructions &&
        (!identical(instructions, liveUnset) || hasInstructions),
    model: model ?? this.model,
    store: copyLiveValue<bool>(
      store,
      this.store,
      'LiveSessionResourceParam.store',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveSessionResourceParam('
      'audio: ${livePresence(audio)}, '
      'client: ${livePresence(client)}, '
      'delegation: ${livePresence(delegation)}, '
      'hasDelegation: $hasDelegation, '
      'expiresAt: ${livePresence(expiresAt)}, '
      'id: ${livePresence(id)}, '
      'input: ${livePresence(input)}, '
      'instructions: ${livePresence(instructions)}, '
      'hasInstructions: $hasInstructions, '
      'model: ${livePresence(model)}, '
      'status: $status, '
      'store: ${livePresence(store)}, '
      'rawJson: [REDACTED])';
}

/// Changes to an active Live session. Only delegation backend settings can be updated after startup.
@immutable
class LiveSessionUpdateParams extends LiveJsonModel {
  /// Creates LiveSessionUpdateParams.
  LiveSessionUpdateParams({
    this.delegation,
    bool hasDelegation = false,
    Map<String, dynamic> rawJson = const {},
  }) : hasDelegation = hasDelegation || delegation != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionUpdateParams',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'delegation'};

  /// Delegation settings to update. The delegation type must match the current session; omitted settings retain their values.
  final LiveDelegationUpdate? delegation;

  /// Distinguishes omission from explicit null for delegation.
  final bool hasDelegation;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveSessionUpdateParams with contextual validation.
  factory LiveSessionUpdateParams.fromJson(Map<String, dynamic> json) {
    return LiveSessionUpdateParams(
      delegation: optionalLiveValue(
        json,
        'delegation',
        'LiveSessionUpdateParams',
        (value, context) =>
            LiveDelegationUpdate.fromJson(requireLiveObject(value, context)),
        nullable: true,
      ),
      hasDelegation: json.containsKey('delegation'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    delegation?.validate();
    if (rawJson.keys.any(_immutableStartupFields.contains)) {
      throw const FormatException(
        'LiveSessionUpdateParams: startup fields cannot be updated',
      );
    }
  }

  /// Rejects attempts to change the current session's delegation owner.
  void validateForSession(LiveSessionResourceParam session) {
    validate();
    if (!hasDelegation) return;
    final current = session.delegation?.type ?? 'client';
    final requested = delegation?.type ?? 'client';
    if (current != requested) {
      throw const FormatException(
        'LiveSessionUpdateParams.delegation: delegation owner is immutable',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (hasDelegation) 'delegation': delegation?.toJson(),
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveSessionUpdateParams copyWith({
    Object? delegation = liveUnset,
    bool clearDelegation = false,
    Map<String, dynamic>? rawJson,
  }) => LiveSessionUpdateParams(
    delegation: clearDelegation
        ? null
        : copyLiveValue<LiveDelegationUpdate>(
            delegation,
            this.delegation,
            'LiveSessionUpdateParams.delegation',
          ),
    hasDelegation:
        !clearDelegation &&
        (!identical(delegation, liveUnset) || hasDelegation),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveSessionUpdateParams('
      'delegation: ${livePresence(delegation)}, '
      'hasDelegation: $hasDelegation, '
      'rawJson: [REDACTED])';
}

/// Startup configuration for a Live media session. Follow the [Live prompting guide](https://developers.openai.com/api/docs/guides/live-prompting) when writing frontend instructions and the backend prompt under delegation.responses.instructions.
@immutable
class LiveMediaSessionCreateParams extends LiveJsonModel {
  /// Creates LiveMediaSessionCreateParams.
  LiveMediaSessionCreateParams({
    this.audio,
    this.client,
    this.delegation,
    bool hasDelegation = false,
    List<LiveInitialItem>? input,
    this.instructions,
    bool hasInstructions = false,
    required this.model,
    this.store,
    Map<String, dynamic> rawJson = const {},
  }) : hasDelegation = hasDelegation || delegation != null,
       input = input == null ? null : List.unmodifiable(input),
       hasInstructions = hasInstructions || instructions != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveMediaSessionCreateParams',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {
    'audio',
    'client',
    'delegation',
    'input',
    'instructions',
    'model',
    'store',
  };

  /// Startup audio configuration. WebRTC and SIP negotiate their audio format on the media transport.
  final LiveMediaSessionAudioParam? audio;

  /// The canonical client field.
  final LiveClientConfigParam? client;

  /// Who handles tasks delegated by the Live model. Omitted or null selects your application; use `responses` to let the API manage a Responses backend.
  final LiveDelegation? delegation;

  /// Distinguishes omission from explicit null for delegation.
  final bool hasDelegation;

  /// Ordered text-only history supplied before startup. Supports developer, user, and assistant messages with one text part each; at most 128 messages and 8,192 rendered tokens in total.
  final List<LiveInitialItem>? input;

  /// Frontend instructions for voice, conversation, interruptions, and when to delegate. Start with the [Live prompting guide](https://developers.openai.com/api/docs/guides/live-prompting); put business rules and tool workflows in a separate [backend prompt](https://developers.openai.com/api/docs/guides/live-delegation#start-with-your-existing-backend-prompt). Limited to 16,384 client-supplied tokens. Omitted or blank instructions use server defaults. Immutable after startup.
  final String? instructions;

  /// Distinguishes omission from explicit null for instructions.
  final bool hasInstructions;

  /// The Live model. Required in the session configuration for every transport; do not pass it as a URL query parameter.
  final String model;

  /// Whether to store the session for later forking and recording download. Defaults to false for new sessions.
  final bool? store;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveMediaSessionCreateParams with contextual validation.
  factory LiveMediaSessionCreateParams.fromJson(Map<String, dynamic> json) {
    requireClosedLiveJson(json, _knownKeys, 'LiveMediaSessionCreateParams');
    return LiveMediaSessionCreateParams(
      audio: optionalLiveValue(
        json,
        'audio',
        'LiveMediaSessionCreateParams',
        (value, context) => LiveMediaSessionAudioParam.fromJson(
          requireLiveObject(value, context),
        ),
        nullable: false,
      ),
      client: optionalLiveValue(
        json,
        'client',
        'LiveMediaSessionCreateParams',
        (value, context) =>
            LiveClientConfigParam.fromJson(requireLiveObject(value, context)),
        nullable: false,
      ),
      delegation: optionalLiveValue(
        json,
        'delegation',
        'LiveMediaSessionCreateParams',
        (value, context) =>
            LiveDelegation.fromJson(requireLiveObject(value, context)),
        nullable: true,
      ),
      hasDelegation: json.containsKey('delegation'),
      input: optionalLiveValue(
        json,
        'input',
        'LiveMediaSessionCreateParams',
        (value, context) => requireLiveList(value, context)
            .map(
              (item) =>
                  LiveInitialItem.fromJson(requireLiveObject(item, context)),
            )
            .toList(),
        nullable: false,
      ),
      instructions: optionalLiveValue(
        json,
        'instructions',
        'LiveMediaSessionCreateParams',
        requireLiveString,
        nullable: true,
      ),
      hasInstructions: json.containsKey('instructions'),
      model: requireLiveString(
        json['model'],
        'LiveMediaSessionCreateParams.model',
      ),
      store: optionalLiveValue(
        json,
        'store',
        'LiveMediaSessionCreateParams',
        requireLiveBool,
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    validateLiveLength(model, 'LiveMediaSessionCreateParams.model', min: 1);
    requireClosedLiveJson(rawJson, _knownKeys, 'LiveMediaSessionCreateParams');
    audio?.validate();
    client?.validate();
    delegation?.validate();
    if (input != null) {
      if (input!.length > 128) {
        throw const FormatException(
          'LiveMediaSessionCreateParams.input: invalid item count',
        );
      }
    }
    for (final item in input ?? const <LiveInitialItem>[]) {
      item.validate();
    }
  }

  /// Validates the separately negotiated WebRTC or SIP media transport.
  void validateForTransport(String transport) {
    validate();
    _requireLiveTransport(transport, 'LiveMediaSessionCreateParams');
    if (transport == 'websocket') {
      throw const FormatException(
        'LiveMediaSessionCreateParams: media transport required',
      );
    }
    if (transport == 'sip' && client != null) {
      throw const FormatException(
        'LiveMediaSessionCreateParams.client: WebRTC frontend only',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (audio != null) 'audio': audio!.toJson(),
    if (client != null) 'client': client!.toJson(),
    if (hasDelegation) 'delegation': delegation?.toJson(),
    if (input != null) 'input': input!.map((item) => item.toJson()).toList(),
    if (hasInstructions) 'instructions': instructions,
    'model': model,
    if (store != null) 'store': store,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveMediaSessionCreateParams copyWith({
    Object? audio = liveUnset,
    Object? client = liveUnset,
    Object? delegation = liveUnset,
    bool clearDelegation = false,
    Object? input = liveUnset,
    Object? instructions = liveUnset,
    bool clearInstructions = false,
    String? model,
    Object? store = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveMediaSessionCreateParams(
    audio: copyLiveValue<LiveMediaSessionAudioParam>(
      audio,
      this.audio,
      'LiveMediaSessionCreateParams.audio',
    ),
    client: copyLiveValue<LiveClientConfigParam>(
      client,
      this.client,
      'LiveMediaSessionCreateParams.client',
    ),
    delegation: clearDelegation
        ? null
        : copyLiveValue<LiveDelegation>(
            delegation,
            this.delegation,
            'LiveMediaSessionCreateParams.delegation',
          ),
    hasDelegation:
        !clearDelegation &&
        (!identical(delegation, liveUnset) || hasDelegation),
    input: copyLiveValue<List<LiveInitialItem>>(
      input,
      this.input,
      'LiveMediaSessionCreateParams.input',
    ),
    instructions: clearInstructions
        ? null
        : copyLiveValue<String>(
            instructions,
            this.instructions,
            'LiveMediaSessionCreateParams.instructions',
          ),
    hasInstructions:
        !clearInstructions &&
        (!identical(instructions, liveUnset) || hasInstructions),
    model: model ?? this.model,
    store: copyLiveValue<bool>(
      store,
      this.store,
      'LiveMediaSessionCreateParams.store',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveMediaSessionCreateParams('
      'audio: ${livePresence(audio)}, '
      'client: ${livePresence(client)}, '
      'delegation: ${livePresence(delegation)}, '
      'hasDelegation: $hasDelegation, '
      'input: ${livePresence(input)}, '
      'instructions: ${livePresence(instructions)}, '
      'hasInstructions: $hasInstructions, '
      'model: ${livePresence(model)}, '
      'store: ${livePresence(store)}, '
      'rawJson: [REDACTED])';
}

/// Optional overrides for a stored Live session. Omitted settings are inherited. The model, voice, frontend instructions, and prior conversation come from the stored session. WebRTC negotiates its audio format; audio.format is only supported on WebSocket forks.
@immutable
class LiveMediaSessionForkParams extends LiveJsonModel {
  /// Creates LiveMediaSessionForkParams.
  LiveMediaSessionForkParams({
    this.client,
    this.delegation,
    this.store,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveMediaSessionForkParams',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'client', 'delegation', 'store'};

  /// The canonical client field.
  final LiveClientConfigParam? client;

  /// The canonical delegation field.
  final LiveResponsesDelegationUpdateParam? delegation;

  /// Whether to store the forked session. Omission inherits the stored session's setting.
  final bool? store;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveMediaSessionForkParams with contextual validation.
  factory LiveMediaSessionForkParams.fromJson(Map<String, dynamic> json) {
    requireClosedLiveJson(json, _knownKeys, 'LiveMediaSessionForkParams');
    return LiveMediaSessionForkParams(
      client: optionalLiveValue(
        json,
        'client',
        'LiveMediaSessionForkParams',
        (value, context) =>
            LiveClientConfigParam.fromJson(requireLiveObject(value, context)),
        nullable: false,
      ),
      delegation: optionalLiveValue(
        json,
        'delegation',
        'LiveMediaSessionForkParams',
        (value, context) => LiveResponsesDelegationUpdateParam.fromJson(
          requireLiveObject(value, context),
        ),
        nullable: false,
      ),
      store: optionalLiveValue(
        json,
        'store',
        'LiveMediaSessionForkParams',
        requireLiveBool,
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    requireClosedLiveJson(rawJson, _knownKeys, 'LiveMediaSessionForkParams');
    client?.validate();
    delegation?.validate();
  }

  /// Backend overrides require a stored session already using Responses.
  void validateForSession(LiveSessionResourceParam session) {
    validate();
    if (delegation != null && session.delegation?.type != 'responses') {
      throw const FormatException(
        'LiveMediaSessionForkParams.delegation: stored Responses delegation required',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (client != null) 'client': client!.toJson(),
    if (delegation != null) 'delegation': delegation!.toJson(),
    if (store != null) 'store': store,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveMediaSessionForkParams copyWith({
    Object? client = liveUnset,
    Object? delegation = liveUnset,
    Object? store = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveMediaSessionForkParams(
    client: copyLiveValue<LiveClientConfigParam>(
      client,
      this.client,
      'LiveMediaSessionForkParams.client',
    ),
    delegation: copyLiveValue<LiveResponsesDelegationUpdateParam>(
      delegation,
      this.delegation,
      'LiveMediaSessionForkParams.delegation',
    ),
    store: copyLiveValue<bool>(
      store,
      this.store,
      'LiveMediaSessionForkParams.store',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveMediaSessionForkParams('
      'client: ${livePresence(client)}, '
      'delegation: ${livePresence(delegation)}, '
      'store: ${livePresence(store)}, '
      'rawJson: [REDACTED])';
}

/// Startup configuration for accepting an incoming Live SIP call. Follow the [Live prompting guide](https://developers.openai.com/api/docs/guides/live-prompting) when writing frontend and backend instructions.
@immutable
class LiveCallAcceptSession extends LiveJsonModel {
  /// Creates LiveCallAcceptSession.
  LiveCallAcceptSession({
    this.audio,
    this.delegation,
    bool hasDelegation = false,
    List<LiveInitialItem>? input,
    this.instructions,
    bool hasInstructions = false,
    required this.model,
    this.store,
    Map<String, dynamic> rawJson = const {},
  }) : hasDelegation = hasDelegation || delegation != null,
       input = input == null ? null : List.unmodifiable(input),
       hasInstructions = hasInstructions || instructions != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveCallAcceptSession',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {
    'audio',
    'delegation',
    'input',
    'instructions',
    'model',
    'store',
    'type',
  };

  /// Startup audio output configuration. SIP negotiates the media format; audio.format is only accepted for primary WebSockets. Voice cannot change after startup.
  final LiveMediaSessionAudioParam? audio;

  /// Who handles tasks delegated by the Live model. Omitted or null selects your application; use `responses` to let the API manage a Responses backend.
  final LiveDelegation? delegation;

  /// Distinguishes omission from explicit null for delegation.
  final bool hasDelegation;

  /// Ordered text-only history supplied before startup. Supports developer, user, and assistant messages with one text part each; at most 128 messages and 8,192 rendered tokens in total.
  final List<LiveInitialItem>? input;

  /// Frontend instructions for voice, conversation, interruptions, and when to delegate. Start with the [Live prompting guide](https://developers.openai.com/api/docs/guides/live-prompting); put business rules and tool workflows in a separate [backend prompt](https://developers.openai.com/api/docs/guides/live-delegation#start-with-your-existing-backend-prompt). Limited to 16,384 client-supplied tokens. Omitted or blank instructions use server defaults. Immutable after startup.
  final String? instructions;

  /// Distinguishes omission from explicit null for instructions.
  final bool hasInstructions;

  /// The Live model to use for the accepted call.
  final String model;

  /// Whether to store the session for later forking and recording download. Defaults to false for new sessions.
  final bool? store;

  /// The session type. Always `live`.
  String get type => 'live';

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveCallAcceptSession with contextual validation.
  factory LiveCallAcceptSession.fromJson(Map<String, dynamic> json) {
    requireClosedLiveJson(json, _knownKeys, 'LiveCallAcceptSession');
    requireLiveType(
      json,
      'live',
      'LiveCallAcceptSession',
      key: 'type',
      required: true,
    );
    return LiveCallAcceptSession(
      audio: optionalLiveValue(
        json,
        'audio',
        'LiveCallAcceptSession',
        (value, context) => LiveMediaSessionAudioParam.fromJson(
          requireLiveObject(value, context),
        ),
        nullable: false,
      ),
      delegation: optionalLiveValue(
        json,
        'delegation',
        'LiveCallAcceptSession',
        (value, context) =>
            LiveDelegation.fromJson(requireLiveObject(value, context)),
        nullable: true,
      ),
      hasDelegation: json.containsKey('delegation'),
      input: optionalLiveValue(
        json,
        'input',
        'LiveCallAcceptSession',
        (value, context) => requireLiveList(value, context)
            .map(
              (item) =>
                  LiveInitialItem.fromJson(requireLiveObject(item, context)),
            )
            .toList(),
        nullable: false,
      ),
      instructions: optionalLiveValue(
        json,
        'instructions',
        'LiveCallAcceptSession',
        requireLiveString,
        nullable: true,
      ),
      hasInstructions: json.containsKey('instructions'),
      model: requireLiveString(json['model'], 'LiveCallAcceptSession.model'),
      store: optionalLiveValue(
        json,
        'store',
        'LiveCallAcceptSession',
        requireLiveBool,
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    validateLiveLength(model, 'LiveCallAcceptSession.model', min: 1);
    requireClosedLiveJson(rawJson, _knownKeys, 'LiveCallAcceptSession');
    audio?.validate();
    delegation?.validate();
    if (input != null) {
      if (input!.length > 128) {
        throw const FormatException(
          'LiveCallAcceptSession.input: invalid item count',
        );
      }
    }
    for (final item in input ?? const <LiveInitialItem>[]) {
      item.validate();
    }
    validateLiveLength(model, 'LiveCallAcceptSession.model', min: 1, max: null);
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (audio != null) 'audio': audio!.toJson(),
    if (hasDelegation) 'delegation': delegation?.toJson(),
    if (input != null) 'input': input!.map((item) => item.toJson()).toList(),
    if (hasInstructions) 'instructions': instructions,
    'model': model,
    if (store != null) 'store': store,
    'type': type,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveCallAcceptSession copyWith({
    Object? audio = liveUnset,
    Object? delegation = liveUnset,
    bool clearDelegation = false,
    Object? input = liveUnset,
    Object? instructions = liveUnset,
    bool clearInstructions = false,
    String? model,
    Object? store = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveCallAcceptSession(
    audio: copyLiveValue<LiveMediaSessionAudioParam>(
      audio,
      this.audio,
      'LiveCallAcceptSession.audio',
    ),
    delegation: clearDelegation
        ? null
        : copyLiveValue<LiveDelegation>(
            delegation,
            this.delegation,
            'LiveCallAcceptSession.delegation',
          ),
    hasDelegation:
        !clearDelegation &&
        (!identical(delegation, liveUnset) || hasDelegation),
    input: copyLiveValue<List<LiveInitialItem>>(
      input,
      this.input,
      'LiveCallAcceptSession.input',
    ),
    instructions: clearInstructions
        ? null
        : copyLiveValue<String>(
            instructions,
            this.instructions,
            'LiveCallAcceptSession.instructions',
          ),
    hasInstructions:
        !clearInstructions &&
        (!identical(instructions, liveUnset) || hasInstructions),
    model: model ?? this.model,
    store: copyLiveValue<bool>(
      store,
      this.store,
      'LiveCallAcceptSession.store',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveCallAcceptSession('
      'audio: ${livePresence(audio)}, '
      'delegation: ${livePresence(delegation)}, '
      'hasDelegation: $hasDelegation, '
      'input: ${livePresence(input)}, '
      'instructions: ${livePresence(instructions)}, '
      'hasInstructions: $hasInstructions, '
      'model: ${livePresence(model)}, '
      'store: ${livePresence(store)}, '
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// Overrides for a stored session after connecting to the fork WebSocket. An empty object inherits the stored configuration; do not supply a new model. audio.format applies only to the new WebSocket connection. client overrides are only supported for WebRTC forks.
@immutable
class LiveForkSessionConfigParam extends LiveJsonModel {
  /// Creates LiveForkSessionConfigParam.
  LiveForkSessionConfigParam({
    this.audio,
    this.client,
    this.delegation,
    this.store,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveForkSessionConfigParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'audio', 'client', 'delegation', 'store'};

  /// Audio format for a WebSocket fork. WebRTC forks negotiate their audio format and must omit this field.
  final LiveForkAudioParam? audio;

  /// Frontend data-channel permissions for a WebRTC fork. Omitted permissions inherit the stored values. Not supported for WebSocket forks.
  final LiveClientConfigParam? client;

  /// Overrides for the stored session’s Responses backend. Only supported when the stored session already uses Responses delegation; the delegation type cannot change.
  final LiveResponsesDelegationUpdateParam? delegation;

  /// Whether to store the forked session. Omission inherits the stored session's setting.
  final bool? store;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveForkSessionConfigParam with contextual validation.
  factory LiveForkSessionConfigParam.fromJson(Map<String, dynamic> json) {
    return LiveForkSessionConfigParam(
      audio: optionalLiveValue(
        json,
        'audio',
        'LiveForkSessionConfigParam',
        (value, context) =>
            LiveForkAudioParam.fromJson(requireLiveObject(value, context)),
        nullable: false,
      ),
      client: optionalLiveValue(
        json,
        'client',
        'LiveForkSessionConfigParam',
        (value, context) =>
            LiveClientConfigParam.fromJson(requireLiveObject(value, context)),
        nullable: false,
      ),
      delegation: optionalLiveValue(
        json,
        'delegation',
        'LiveForkSessionConfigParam',
        (value, context) => LiveResponsesDelegationUpdateParam.fromJson(
          requireLiveObject(value, context),
        ),
        nullable: false,
      ),
      store: optionalLiveValue(
        json,
        'store',
        'LiveForkSessionConfigParam',
        requireLiveBool,
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    audio?.validate();
    client?.validate();
    delegation?.validate();
    if (rawJson.keys.any(_immutableForkStartupFields.contains)) {
      throw const FormatException(
        'LiveForkSessionConfigParam: inherited startup fields cannot be overridden',
      );
    }
  }

  /// Backend overrides require a stored session already using Responses.
  void validateForSession(LiveSessionResourceParam session) {
    validate();
    if (delegation != null && session.delegation?.type != 'responses') {
      throw const FormatException(
        'LiveForkSessionConfigParam.delegation: stored Responses delegation required',
      );
    }
  }

  /// Fork audio format is WebSocket-only and client capabilities WebRTC-only.
  void validateForTransport(String transport) {
    validate();
    _requireLiveTransport(transport, 'LiveForkSessionConfigParam');
    if (transport == 'sip') {
      throw const FormatException(
        'LiveForkSessionConfigParam: unsupported fork transport',
      );
    }
    if (transport != 'websocket' && audio != null) {
      throw const FormatException(
        'LiveForkSessionConfigParam.audio: primary WebSocket only',
      );
    }
    if (transport != 'webrtc' && client != null) {
      throw const FormatException(
        'LiveForkSessionConfigParam.client: WebRTC frontend only',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (audio != null) 'audio': audio!.toJson(),
    if (client != null) 'client': client!.toJson(),
    if (delegation != null) 'delegation': delegation!.toJson(),
    if (store != null) 'store': store,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveForkSessionConfigParam copyWith({
    Object? audio = liveUnset,
    Object? client = liveUnset,
    Object? delegation = liveUnset,
    Object? store = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveForkSessionConfigParam(
    audio: copyLiveValue<LiveForkAudioParam>(
      audio,
      this.audio,
      'LiveForkSessionConfigParam.audio',
    ),
    client: copyLiveValue<LiveClientConfigParam>(
      client,
      this.client,
      'LiveForkSessionConfigParam.client',
    ),
    delegation: copyLiveValue<LiveResponsesDelegationUpdateParam>(
      delegation,
      this.delegation,
      'LiveForkSessionConfigParam.delegation',
    ),
    store: copyLiveValue<bool>(
      store,
      this.store,
      'LiveForkSessionConfigParam.store',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveForkSessionConfigParam('
      'audio: ${livePresence(audio)}, '
      'client: ${livePresence(client)}, '
      'delegation: ${livePresence(delegation)}, '
      'store: ${livePresence(store)}, '
      'rawJson: [REDACTED])';
}

const _immutableStartupFields = {
  'audio',
  'client',
  'input',
  'instructions',
  'model',
  'store',
  'voice',
  'id',
  'expires_at',
  'status',
  'type',
};

const _immutableForkStartupFields = {
  'model',
  'voice',
  'input',
  'instructions',
  'id',
  'expires_at',
  'status',
  'type',
};

void _requireLiveTransport(String transport, String context) {
  if (!const {'websocket', 'webrtc', 'sip'}.contains(transport)) {
    throw FormatException('$context: unsupported transport');
  }
}

/// WebRTC frontend client-event permissions: all, or an explicit list.
sealed class LiveAllowedClientEvents extends LiveJsonModel {
  /// Creates a permission selector.
  const LiveAllowedClientEvents();

  /// Allows every client event.
  const factory LiveAllowedClientEvents.all() = LiveAllClientEvents;

  /// Allows exactly the supplied event names; an empty list allows none.
  factory LiveAllowedClientEvents.selected(List<String> events) =
      LiveSelectedClientEvents;

  /// Parses the canonical all/list union.
  static LiveAllowedClientEvents fromJson(Object? json) {
    if (json == 'all') return const LiveAllClientEvents();
    final events = requireLiveList(json, 'LiveAllowedClientEvents');
    return LiveSelectedClientEvents([
      for (var i = 0; i < events.length; i++)
        requireLiveString(events[i], 'LiveAllowedClientEvents[$i]'),
    ]);
  }
}

/// The literal allow-all client policy.
@immutable
class LiveAllClientEvents extends LiveAllowedClientEvents {
  /// Creates an allow-all policy.
  const LiveAllClientEvents();

  @override
  String toJson() => 'all';
}

/// An immutable selection of frontend client event names.
@immutable
class LiveSelectedClientEvents extends LiveAllowedClientEvents {
  /// Creates a selected policy.
  LiveSelectedClientEvents(List<String> events)
    : events = List.unmodifiable(events) {
    validate();
  }

  /// Exact frontend event names; empty means none.
  final List<String> events;

  static final _eventPattern = RegExp(
    r'^(?:error|info|[a-z][a-z0-9_-]*(?:\.[a-z0-9_-]+)+)$',
  );

  @override
  void validate() {
    if (events.length > 256) {
      throw const FormatException(
        'LiveSelectedClientEvents.events: too many events',
      );
    }
    for (final event in events) {
      validateLiveLength(
        event,
        'LiveSelectedClientEvents.events',
        min: 1,
        max: 256,
      );
      if (!_eventPattern.hasMatch(event)) {
        throw const FormatException(
          'LiveSelectedClientEvents.events: invalid event name',
        );
      }
    }
  }

  /// Copies the explicit selection.
  LiveSelectedClientEvents copyWith({List<String>? events}) =>
      LiveSelectedClientEvents(events ?? this.events);

  @override
  List<String> toJson() => events.toList();

  @override
  String toString() => 'LiveSelectedClientEvents(events: [REDACTED])';
}

/// WebRTC frontend server-event permissions: all, or exact selectors.
sealed class LiveAllowedServerEvents extends LiveJsonModel {
  /// Creates a permission selector.
  const LiveAllowedServerEvents();

  /// Allows every server event.
  const factory LiveAllowedServerEvents.all() = LiveAllServerEvents;

  /// Allows exactly the supplied selectors; an empty list allows none.
  factory LiveAllowedServerEvents.selected(
    List<LiveAllowedServerEventParam> events,
  ) = LiveSelectedServerEvents;

  /// Parses the canonical all/list union.
  static LiveAllowedServerEvents fromJson(Object? json) {
    if (json == 'all') return const LiveAllServerEvents();
    final events = requireLiveList(json, 'LiveAllowedServerEvents');
    return LiveSelectedServerEvents([
      for (var i = 0; i < events.length; i++)
        LiveAllowedServerEventParam.fromJson(
          requireLiveObject(events[i], 'LiveAllowedServerEvents[$i]'),
        ),
    ]);
  }
}

/// The literal allow-all server policy.
@immutable
class LiveAllServerEvents extends LiveAllowedServerEvents {
  /// Creates an allow-all policy.
  const LiveAllServerEvents();

  @override
  String toJson() => 'all';
}

/// Immutable frontend server selectors.
@immutable
class LiveSelectedServerEvents extends LiveAllowedServerEvents {
  /// Creates a selected policy.
  LiveSelectedServerEvents(List<LiveAllowedServerEventParam> events)
    : events = List.unmodifiable(events) {
    validate();
  }

  /// Exact event selectors; empty means none.
  final List<LiveAllowedServerEventParam> events;

  @override
  void validate() {
    if (events.length > 256) {
      throw const FormatException(
        'LiveSelectedServerEvents.events: too many events',
      );
    }
    for (final event in events) {
      event.validate();
    }
  }

  /// Copies the explicit selection.
  LiveSelectedServerEvents copyWith({
    List<LiveAllowedServerEventParam>? events,
  }) => LiveSelectedServerEvents(events ?? this.events);

  @override
  List<Map<String, dynamic>> toJson() =>
      events.map((event) => event.toJson()).toList();

  @override
  String toString() => 'LiveSelectedServerEvents(events: [REDACTED])';
}
