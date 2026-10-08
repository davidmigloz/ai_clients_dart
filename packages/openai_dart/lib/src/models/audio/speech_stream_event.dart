import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';
import 'audio_json_helpers.dart';
import 'speech_usage.dart';

/// A typed speech SSE event, with lossless future-event fallback.
@immutable
sealed class SpeechStreamEvent {
  const SpeechStreamEvent();

  /// Dispatches on a required string discriminator without masking malformed events.
  factory SpeechStreamEvent.fromJson(Map<String, dynamic> json) {
    final type = requireJsonString(json['type'], 'SpeechStreamEvent.type');
    return switch (type) {
      'speech.audio.delta' => SpeechAudioDeltaEvent.fromJson(json),
      'speech.audio.done' => SpeechAudioDoneEvent.fromJson(json),
      _ => SpeechUnknownEvent.fromJson(json),
    };
  }

  /// The event discriminator.
  String get type;

  /// Serializes the event with typed fields authoritative over original JSON.
  Map<String, dynamic> toJson();
}

/// A speech audio chunk containing its original raw Base64 string.
@immutable
final class SpeechAudioDeltaEvent extends SpeechStreamEvent {
  /// Creates a chunk and deeply snapshots caller-supplied metadata.
  SpeechAudioDeltaEvent({
    required this.audio,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(rawJson, 'SpeechAudioDeltaEvent.rawJson');

  /// Requires its fixed discriminator and a nonnull audio string.
  factory SpeechAudioDeltaEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotAudioJson(
      json,
      'SpeechAudioDeltaEvent',
      knownKeys: const {'type', 'audio'},
    );
    requireJsonType(snapshot, 'speech.audio.delta', 'SpeechAudioDeltaEvent');
    return SpeechAudioDeltaEvent(
      audio: requireJsonString(
        snapshot['audio'],
        'SpeechAudioDeltaEvent.audio',
      ),
      rawJson: snapshot,
    );
  }

  /// The original Base64 chunk; this is not a data URL.
  final String audio;

  /// Deeply immutable original JSON, including future event members.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'speech.audio.delta';

  /// Decodes raw Base64 into fresh bytes, without exposing invalid payloads.
  ///
  /// Parsing preserves any audio string; decoding is an explicit opt-in operation.
  Uint8List decodeAudio() {
    try {
      return base64Decode(audio);
    } on FormatException {
      throw const FormatException(
        'SpeechAudioDeltaEvent.audio: invalid Base64 audio',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeAudioJson(
    rawJson,
    const {'type', 'audio'},
    {'type': type, 'audio': audio},
  );

  /// Copies the chunk and metadata; an empty raw map clears future members.
  SpeechAudioDeltaEvent copyWith({
    String? audio,
    Map<String, dynamic>? rawJson,
  }) => SpeechAudioDeltaEvent(
    audio: audio ?? this.audio,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechAudioDeltaEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      'SpeechAudioDeltaEvent(type: $type, audio: ${audio.length} chars, '
      'rawJson: ${rawJson.length} entries)';
}

/// The terminal speech event containing all reported token counts.
@immutable
final class SpeechAudioDoneEvent extends SpeechStreamEvent {
  /// Creates a terminal event and snapshots caller-supplied future metadata.
  SpeechAudioDoneEvent({
    required this.usage,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(rawJson, 'SpeechAudioDoneEvent.rawJson');

  /// Requires the fixed type and complete inline usage object.
  factory SpeechAudioDoneEvent.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'speech.audio.done', 'SpeechAudioDoneEvent');
    final usage = SpeechUsage.fromJson(
      requireJsonObject(json['usage'], 'SpeechAudioDoneEvent.usage'),
    );
    final snapshot = snapshotAudioJson(
      json,
      'SpeechAudioDoneEvent',
      knownKeys: const {'type', 'usage'},
    );
    return SpeechAudioDoneEvent(usage: usage, rawJson: snapshot);
  }

  /// Complete usage reported by the service.
  final SpeechUsage usage;

  /// Deeply immutable original JSON, including future event members.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'speech.audio.done';

  @override
  Map<String, dynamic> toJson() => mergeAudioJson(
    rawJson,
    const {'type', 'usage'},
    {
      'type': type,
      'usage': mergeAudioModelJson(rawJson['usage'], const {
        'input_tokens',
        'output_tokens',
        'total_tokens',
      }, usage.toJson()),
    },
  );

  /// Copies usage and event metadata.
  ///
  /// Explicit usage replacement drops old child metadata. An explicit parent
  /// [rawJson] instead supplies its own future child members; typed counts win.
  SpeechAudioDoneEvent copyWith({
    SpeechUsage? usage,
    Map<String, dynamic>? rawJson,
  }) => SpeechAudioDoneEvent(
    usage: usage ?? this.usage,
    rawJson:
        rawJson ??
        (usage == null
            ? this.rawJson
            : mergeAudioJson(this.rawJson, const {'usage'}, const {})),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechAudioDoneEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      'SpeechAudioDoneEvent(type: $type, usage: $usage, '
      'rawJson: ${rawJson.length} entries)';
}

/// A future speech event whose complete JSON is preserved without interpretation.
@immutable
final class SpeechUnknownEvent extends SpeechStreamEvent {
  /// Creates a future event and snapshots all caller metadata.
  SpeechUnknownEvent({
    required this.rawType,
    required Map<String, dynamic> rawJson,
  }) : rawJson = snapshotAudioJson(rawJson, 'SpeechUnknownEvent.rawJson') {
    _validateUnknownType(rawType);
  }

  /// Requires an unknown string type, retaining deeply immutable finite JSON.
  factory SpeechUnknownEvent.fromJson(Map<String, dynamic> json) =>
      SpeechUnknownEvent(
        rawType: requireJsonString(json['type'], 'SpeechUnknownEvent.type'),
        rawJson: json,
      );

  /// The provider's future event discriminator.
  final String rawType;

  /// Deeply immutable original event JSON.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawType;

  @override
  Map<String, dynamic> toJson() =>
      mergeAudioJson(rawJson, const {'type'}, {'type': type});

  /// Copies the future discriminator and metadata, with typed type authoritative.
  SpeechUnknownEvent copyWith({
    String? rawType,
    Map<String, dynamic>? rawJson,
  }) => SpeechUnknownEvent(
    rawType: rawType ?? this.rawType,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechUnknownEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      'SpeechUnknownEvent(rawType: [REDACTED], rawJson: ${rawJson.length} entries)';
}

void _validateUnknownType(String type) {
  if (type == 'speech.audio.delta' || type == 'speech.audio.done') {
    throw const FormatException(
      'SpeechUnknownEvent.type: expected a future discriminator',
    );
  }
}
