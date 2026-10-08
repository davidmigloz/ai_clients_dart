import 'package:meta/meta.dart';

import 'live_json_helpers.dart';

/// Raw, mono 16-bit little-endian PCM audio for a Live WebSocket connection.
@immutable
class LiveSessionAudioFormatPCMParam extends LiveAudioFormat {
  /// Creates LiveSessionAudioFormatPCMParam.
  LiveSessionAudioFormatPCMParam({
    required this.rate,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionAudioFormatPCMParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'rate', 'type'};

  /// Audio sample rate in hertz. Live WebSocket PCM audio supports 16000 or 24000 Hz.
  @override
  final int rate;

  /// The audio encoding. Always `audio/pcm`.
  @override
  String get type => 'audio/pcm';

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveSessionAudioFormatPCMParam with contextual validation.
  factory LiveSessionAudioFormatPCMParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'audio/pcm',
      'LiveSessionAudioFormatPCMParam',
      key: 'type',
      required: true,
    );
    return LiveSessionAudioFormatPCMParam(
      rate: requireLiveInt(json['rate'], 'LiveSessionAudioFormatPCMParam.rate'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    {
      if (rate < 16000 || rate > 24000 || ![16000, 24000].contains(rate)) {
        throw const FormatException(
          'LiveSessionAudioFormatPCMParam.rate: unsupported integer value',
        );
      }
    }
  }

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'rate': rate, 'type': type});

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveSessionAudioFormatPCMParam copyWith({
    int? rate,
    Map<String, dynamic>? rawJson,
  }) => LiveSessionAudioFormatPCMParam(
    rate: rate ?? this.rate,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveSessionAudioFormatPCMParam('
      'rate: ${livePresence(rate)}, '
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// Raw, mono G.711 A-law audio for a Live WebSocket connection.
@immutable
class LiveSessionAudioFormatPCMAParam extends LiveAudioFormat {
  /// Creates LiveSessionAudioFormatPCMAParam.
  LiveSessionAudioFormatPCMAParam({
    required this.rate,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionAudioFormatPCMAParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'rate', 'type'};

  /// Audio sample rate in hertz. G.711 audio uses 8000 Hz.
  @override
  final int rate;

  /// The audio encoding. Always `audio/pcma`.
  @override
  String get type => 'audio/pcma';

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveSessionAudioFormatPCMAParam with contextual validation.
  factory LiveSessionAudioFormatPCMAParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'audio/pcma',
      'LiveSessionAudioFormatPCMAParam',
      key: 'type',
      required: true,
    );
    return LiveSessionAudioFormatPCMAParam(
      rate: requireLiveInt(
        json['rate'],
        'LiveSessionAudioFormatPCMAParam.rate',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    {
      if (rate < 8000 || rate > 8000) {
        throw const FormatException(
          'LiveSessionAudioFormatPCMAParam.rate: unsupported integer value',
        );
      }
    }
  }

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'rate': rate, 'type': type});

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveSessionAudioFormatPCMAParam copyWith({
    int? rate,
    Map<String, dynamic>? rawJson,
  }) => LiveSessionAudioFormatPCMAParam(
    rate: rate ?? this.rate,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveSessionAudioFormatPCMAParam('
      'rate: ${livePresence(rate)}, '
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// Raw, mono G.711 μ-law audio for a Live WebSocket connection.
@immutable
class LiveSessionAudioFormatPCMUParam extends LiveAudioFormat {
  /// Creates LiveSessionAudioFormatPCMUParam.
  LiveSessionAudioFormatPCMUParam({
    required this.rate,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveSessionAudioFormatPCMUParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'rate', 'type'};

  /// Audio sample rate in hertz. G.711 audio uses 8000 Hz.
  @override
  final int rate;

  /// The audio encoding. Always `audio/pcmu`.
  @override
  String get type => 'audio/pcmu';

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveSessionAudioFormatPCMUParam with contextual validation.
  factory LiveSessionAudioFormatPCMUParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'audio/pcmu',
      'LiveSessionAudioFormatPCMUParam',
      key: 'type',
      required: true,
    );
    return LiveSessionAudioFormatPCMUParam(
      rate: requireLiveInt(
        json['rate'],
        'LiveSessionAudioFormatPCMUParam.rate',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    {
      if (rate < 8000 || rate > 8000) {
        throw const FormatException(
          'LiveSessionAudioFormatPCMUParam.rate: unsupported integer value',
        );
      }
    }
  }

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'rate': rate, 'type': type});

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveSessionAudioFormatPCMUParam copyWith({
    int? rate,
    Map<String, dynamic>? rawJson,
  }) => LiveSessionAudioFormatPCMUParam(
    rate: rate ?? this.rate,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveSessionAudioFormatPCMUParam('
      'rate: ${livePresence(rate)}, '
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// LiveCustomVoiceParam
@immutable
class LiveCustomVoiceParam extends LiveVoice {
  /// Creates LiveCustomVoiceParam.
  LiveCustomVoiceParam({
    required this.id,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveCustomVoiceParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'id'};

  /// The canonical id field.
  final String id;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveCustomVoiceParam with contextual validation.
  factory LiveCustomVoiceParam.fromJson(Map<String, dynamic> json) {
    return LiveCustomVoiceParam(
      id: requireLiveString(json['id'], 'LiveCustomVoiceParam.id'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    validateLiveLength(id, 'LiveCustomVoiceParam.id', min: 1, max: 128);
  }

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'id': id});

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveCustomVoiceParam copyWith({String? id, Map<String, dynamic>? rawJson}) =>
      LiveCustomVoiceParam(id: id ?? this.id, rawJson: rawJson ?? this.rawJson);

  @override
  String toString() =>
      'LiveCustomVoiceParam('
      'id: ${livePresence(id)}, '
      'rawJson: [REDACTED])';
}

/// Settings for speech generated by the Live model. Choose the voice before starting the session.
@immutable
class LiveInitialSessionAudioOutputParam extends LiveJsonModel {
  /// Creates LiveInitialSessionAudioOutputParam.
  LiveInitialSessionAudioOutputParam({
    this.voice,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveInitialSessionAudioOutputParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'voice'};

  /// The voice used for Live speech, as a built-in voice name or a custom voice object containing its ID. Defaults to `marin` and cannot change after startup.
  final LiveVoice? voice;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveInitialSessionAudioOutputParam with contextual validation.
  factory LiveInitialSessionAudioOutputParam.fromJson(
    Map<String, dynamic> json,
  ) {
    return LiveInitialSessionAudioOutputParam(
      voice: optionalLiveValue(
        json,
        'voice',
        'LiveInitialSessionAudioOutputParam',
        (value, context) => LiveVoice.fromJson(value),
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    voice?.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (voice != null) 'voice': voice!.toJson(),
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveInitialSessionAudioOutputParam copyWith({
    Object? voice = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveInitialSessionAudioOutputParam(
    voice: copyLiveValue<LiveVoice>(
      voice,
      this.voice,
      'LiveInitialSessionAudioOutputParam.voice',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveInitialSessionAudioOutputParam('
      'voice: ${livePresence(voice)}, '
      'rawJson: [REDACTED])';
}

/// Startup audio configuration. Only primary WebSockets accept audio.format; WebRTC and SIP negotiate their media format. Voice and format are immutable after startup.
@immutable
class LiveInitialSessionAudioParam extends LiveJsonModel {
  /// Creates LiveInitialSessionAudioParam.
  LiveInitialSessionAudioParam({
    this.format,
    this.output,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveInitialSessionAudioParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'format', 'output'};

  /// Audio encoding and sample rate for audio sent and received over a Live WebSocket connection. WebRTC and SIP negotiate their media format separately.
  final LiveAudioFormat? format;

  /// The voice used for speech generated by the Live model.
  final LiveInitialSessionAudioOutputParam? output;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveInitialSessionAudioParam with contextual validation.
  factory LiveInitialSessionAudioParam.fromJson(Map<String, dynamic> json) {
    return LiveInitialSessionAudioParam(
      format: optionalLiveValue(
        json,
        'format',
        'LiveInitialSessionAudioParam',
        (value, context) =>
            LiveAudioFormat.fromJson(requireLiveObject(value, context)),
        nullable: false,
      ),
      output: optionalLiveValue(
        json,
        'output',
        'LiveInitialSessionAudioParam',
        (value, context) => LiveInitialSessionAudioOutputParam.fromJson(
          requireLiveObject(value, context),
        ),
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    format?.validate();
    output?.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (format != null) 'format': format!.toJson(),
    if (output != null) 'output': output!.toJson(),
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveInitialSessionAudioParam copyWith({
    Object? format = liveUnset,
    Object? output = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveInitialSessionAudioParam(
    format: copyLiveValue<LiveAudioFormat>(
      format,
      this.format,
      'LiveInitialSessionAudioParam.format',
    ),
    output: copyLiveValue<LiveInitialSessionAudioOutputParam>(
      output,
      this.output,
      'LiveInitialSessionAudioParam.output',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveInitialSessionAudioParam('
      'format: ${livePresence(format)}, '
      'output: ${livePresence(output)}, '
      'rawJson: [REDACTED])';
}

/// Startup audio output configuration. WebRTC and SIP negotiate the media format; audio.format is only accepted for primary WebSockets. Voice cannot change after startup.
@immutable
class LiveMediaSessionAudioParam extends LiveJsonModel {
  /// Creates LiveMediaSessionAudioParam.
  LiveMediaSessionAudioParam({
    this.output,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveMediaSessionAudioParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'output'};

  /// The canonical output field.
  final LiveInitialSessionAudioOutputParam? output;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveMediaSessionAudioParam with contextual validation.
  factory LiveMediaSessionAudioParam.fromJson(Map<String, dynamic> json) {
    requireClosedLiveJson(json, _knownKeys, 'LiveMediaSessionAudioParam');
    return LiveMediaSessionAudioParam(
      output: optionalLiveValue(
        json,
        'output',
        'LiveMediaSessionAudioParam',
        (value, context) => LiveInitialSessionAudioOutputParam.fromJson(
          requireLiveObject(value, context),
        ),
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    requireClosedLiveJson(rawJson, _knownKeys, 'LiveMediaSessionAudioParam');
    output?.validate();
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (output != null) 'output': output!.toJson(),
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveMediaSessionAudioParam copyWith({
    Object? output = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveMediaSessionAudioParam(
    output: copyLiveValue<LiveInitialSessionAudioOutputParam>(
      output,
      this.output,
      'LiveMediaSessionAudioParam.output',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveMediaSessionAudioParam('
      'output: ${livePresence(output)}, '
      'rawJson: [REDACTED])';
}

/// Audio format for the new WebSocket connection to a forked Live session. The stored voice is preserved.
@immutable
class LiveForkAudioParam extends LiveJsonModel {
  /// Creates LiveForkAudioParam.
  LiveForkAudioParam({this.format, Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveForkAudioParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  static const _knownKeys = {'format'};

  /// Audio encoding and sample rate for audio sent and received over a Live WebSocket connection. WebRTC and SIP negotiate their media format separately.
  final LiveAudioFormat? format;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveForkAudioParam with contextual validation.
  factory LiveForkAudioParam.fromJson(Map<String, dynamic> json) {
    return LiveForkAudioParam(
      format: optionalLiveValue(
        json,
        'format',
        'LiveForkAudioParam',
        (value, context) =>
            LiveAudioFormat.fromJson(requireLiveObject(value, context)),
        nullable: false,
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {
    format?.validate();
    if (rawJson.containsKey('output') || rawJson.containsKey('voice')) {
      throw const FormatException(
        'LiveForkAudioParam: inherited voice cannot be overridden',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (format != null) 'format': format!.toJson(),
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveForkAudioParam copyWith({
    Object? format = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveForkAudioParam(
    format: copyLiveValue<LiveAudioFormat>(
      format,
      this.format,
      'LiveForkAudioParam.format',
    ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveForkAudioParam('
      'format: ${livePresence(format)}, '
      'rawJson: [REDACTED])';
}

/// Audio encoding negotiated explicitly for a primary Live WebSocket.
sealed class LiveAudioFormat extends LiveJsonModel {
  /// Creates an audio encoding value.
  const LiveAudioFormat();

  /// The fixed wire encoding discriminator.
  String get type;

  /// The sample rate in hertz.
  int get rate;

  /// PCM16LE mono audio at 16000 or 24000 Hz.
  factory LiveAudioFormat.pcm({required int rate}) =
      LiveSessionAudioFormatPCMParam;

  /// G.711 A-law mono audio at 8000 Hz.
  static LiveAudioFormat pcma() => LiveSessionAudioFormatPCMAParam(rate: 8000);

  /// G.711 mu-law mono audio at 8000 Hz.
  static LiveAudioFormat pcmu() => LiveSessionAudioFormatPCMUParam(rate: 8000);

  /// Parses only the three canonical WebSocket encodings.
  static LiveAudioFormat fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'audio/pcm' => LiveSessionAudioFormatPCMParam.fromJson(json),
        'audio/pcma' => LiveSessionAudioFormatPCMAParam.fromJson(json),
        'audio/pcmu' => LiveSessionAudioFormatPCMUParam.fromJson(json),
        _ => throw const FormatException(
          'LiveAudioFormat.type: unsupported encoding',
        ),
      };
}

/// A Live voice name or an open custom voice reference.
sealed class LiveVoice extends LiveJsonModel {
  /// Creates a voice value.
  const LiveVoice();

  /// Preserves any named Live voice, including future names.
  const factory LiveVoice.named(String name) = LiveNamedVoice;

  /// References a custom Live voice with its own 1–128 character ID limit.
  factory LiveVoice.custom({required String id, Map<String, dynamic> rawJson}) =
      LiveCustomVoiceParam;

  /// Parses a name or custom object without borrowing Speech constraints.
  static LiveVoice fromJson(Object? json) {
    if (json is String) return LiveNamedVoice(json);
    return LiveCustomVoiceParam.fromJson(requireLiveObject(json, 'LiveVoice'));
  }

  /// The named Live voice `alloy`.
  static const alloy = LiveNamedVoice('alloy');

  /// The named Live voice `ash`.
  static const ash = LiveNamedVoice('ash');

  /// The named Live voice `ballad`.
  static const ballad = LiveNamedVoice('ballad');

  /// The named Live voice `beacon`.
  static const beacon = LiveNamedVoice('beacon');

  /// The named Live voice `bossa`.
  static const bossa = LiveNamedVoice('bossa');

  /// The named Live voice `brise`.
  static const brise = LiveNamedVoice('brise');

  /// The named Live voice `cedar`.
  static const cedar = LiveNamedVoice('cedar');

  /// The named Live voice `cinder`.
  static const cinder = LiveNamedVoice('cinder');

  /// The named Live voice `coral`.
  static const coral = LiveNamedVoice('coral');

  /// The named Live voice `delta`.
  static const delta = LiveNamedVoice('delta');

  /// The named Live voice `echo`.
  static const echo = LiveNamedVoice('echo');

  /// The named Live voice `flitz`.
  static const flitz = LiveNamedVoice('flitz');

  /// The named Live voice `gleam`.
  static const gleam = LiveNamedVoice('gleam');

  /// The named Live voice `harema`.
  static const harema = LiveNamedVoice('harema');

  /// The named Live voice `juni`.
  static const juni = LiveNamedVoice('juni');

  /// The named Live voice `marin`.
  static const marin = LiveNamedVoice('marin');

  /// The named Live voice `meridian`.
  static const meridian = LiveNamedVoice('meridian');

  /// The named Live voice `nira`.
  static const nira = LiveNamedVoice('nira');

  /// The named Live voice `noeul`.
  static const noeul = LiveNamedVoice('noeul');

  /// The named Live voice `nuri`.
  static const nuri = LiveNamedVoice('nuri');

  /// The named Live voice `quartz`.
  static const quartz = LiveNamedVoice('quartz');

  /// The named Live voice `ripple`.
  static const ripple = LiveNamedVoice('ripple');

  /// The named Live voice `sage`.
  static const sage = LiveNamedVoice('sage');

  /// The named Live voice `shida`.
  static const shida = LiveNamedVoice('shida');

  /// The named Live voice `shimmer`.
  static const shimmer = LiveNamedVoice('shimmer');

  /// The named Live voice `sillage`.
  static const sillage = LiveNamedVoice('sillage');

  /// The named Live voice `stone`.
  static const stone = LiveNamedVoice('stone');

  /// The named Live voice `tempo`.
  static const tempo = LiveNamedVoice('tempo');

  /// The named Live voice `verse`.
  static const verse = LiveNamedVoice('verse');

  /// The named Live voice `vesper`.
  static const vesper = LiveNamedVoice('vesper');

  /// The named Live voice `willow`.
  static const willow = LiveNamedVoice('willow');
}

/// An open Live voice name; no closed named-voice enum is imposed.
@immutable
class LiveNamedVoice extends LiveVoice {
  /// Creates an open voice name.
  const LiveNamedVoice(this.name);

  /// The exact caller-supplied or received name.
  final String name;

  /// Copies the open name.
  LiveNamedVoice copyWith({String? name}) => LiveNamedVoice(name ?? this.name);

  @override
  String toJson() => name;

  @override
  String toString() => 'LiveNamedVoice(name: [REDACTED])';
}
