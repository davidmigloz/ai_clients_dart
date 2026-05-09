import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

// =============================================================================
// SemanticVadEagerness
// =============================================================================

/// Eagerness levels for `semantic_vad` turn detection.
///
/// Determines how aggressively the model decides the user has finished
/// speaking. `low`/`medium`/`high` cap the detection timeout at 8s/4s/2s
/// respectively; `auto` is the default and behaves like `medium`.
///
/// Unknown values from `fromJson` throw `FormatException`, matching the
/// existing convention.
enum SemanticVadEagerness {
  /// Wait longer (up to 8s) before deciding the user has finished speaking.
  low._('low'),

  /// Default cadence (~4s timeout). Equivalent to `auto`.
  medium._('medium'),

  /// Respond more eagerly (up to 2s timeout).
  high._('high'),

  /// Auto (server default; equivalent to medium).
  auto._('auto');

  const SemanticVadEagerness._(this._value);

  /// Creates from JSON string. Throws `FormatException` for unknown values.
  factory SemanticVadEagerness.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () =>
          throw FormatException('Unknown SemanticVadEagerness: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

// =============================================================================
// RealtimeAudioInputTurnDetection
// =============================================================================

/// Turn detection configuration for Realtime sessions.
///
/// A discriminated union covering the two supported strategies:
///
/// - [ServerVad] — server-side voice activity detection that flips on/off
///   based on audio volume.
/// - [SemanticVad] — turn detection that uses a model to predict when the
///   speaker has finished.
///
/// An [UnknownRealtimeAudioInputTurnDetection] fallback preserves any
/// unrecognised payload so future server additions do not break existing
/// clients.
sealed class RealtimeAudioInputTurnDetection {
  const RealtimeAudioInputTurnDetection();

  /// Server VAD turn detection.
  const factory RealtimeAudioInputTurnDetection.serverVad({
    bool? createResponse,
    int? idleTimeoutMs,
    bool? interruptResponse,
    int? prefixPaddingMs,
    int? silenceDurationMs,
    double? threshold,
  }) = ServerVad;

  /// Semantic VAD turn detection.
  const factory RealtimeAudioInputTurnDetection.semanticVad({
    bool? createResponse,
    SemanticVadEagerness? eagerness,
    bool? interruptResponse,
  }) = SemanticVad;

  /// Creates from JSON.
  factory RealtimeAudioInputTurnDetection.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    return switch (type) {
      'server_vad' => ServerVad.fromJson(json),
      'semantic_vad' => SemanticVad.fromJson(json),
      _ => UnknownRealtimeAudioInputTurnDetection(
        Map<String, dynamic>.from(json),
      ),
    };
  }

  /// The discriminator value.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Server-side voice activity detection.
@immutable
class ServerVad extends RealtimeAudioInputTurnDetection {
  /// Creates a [ServerVad].
  const ServerVad({
    this.createResponse,
    this.idleTimeoutMs,
    this.interruptResponse,
    this.prefixPaddingMs,
    this.silenceDurationMs,
    this.threshold,
  });

  /// Creates from JSON.
  factory ServerVad.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'server_vad') {
      throw FormatException(
        'ServerVad.fromJson expected type "server_vad", got ${json['type']}',
      );
    }
    return ServerVad(
      createResponse: json['create_response'] as bool?,
      idleTimeoutMs: json['idle_timeout_ms'] as int?,
      interruptResponse: json['interrupt_response'] as bool?,
      prefixPaddingMs: json['prefix_padding_ms'] as int?,
      silenceDurationMs: json['silence_duration_ms'] as int?,
      threshold: (json['threshold'] as num?)?.toDouble(),
    );
  }

  /// Whether to automatically generate a response on VAD stop.
  final bool? createResponse;

  /// Idle timeout in milliseconds (5000–30000) that triggers a model response.
  final int? idleTimeoutMs;

  /// Whether to interrupt an in-progress response on VAD start.
  final bool? interruptResponse;

  /// Audio padding before detected speech (ms). Default 300.
  final int? prefixPaddingMs;

  /// Silence duration to detect speech end (ms). Default 500.
  final int? silenceDurationMs;

  /// Activation threshold (0.0–1.0). Default 0.5.
  final double? threshold;

  @override
  String get type => 'server_vad';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (createResponse != null) 'create_response': createResponse,
    if (idleTimeoutMs != null) 'idle_timeout_ms': idleTimeoutMs,
    if (interruptResponse != null) 'interrupt_response': interruptResponse,
    if (prefixPaddingMs != null) 'prefix_padding_ms': prefixPaddingMs,
    if (silenceDurationMs != null) 'silence_duration_ms': silenceDurationMs,
    if (threshold != null) 'threshold': threshold,
  };

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass `null` for any field to clear the existing value.
  ServerVad copyWith({
    Object? createResponse = unsetCopyWithValue,
    Object? idleTimeoutMs = unsetCopyWithValue,
    Object? interruptResponse = unsetCopyWithValue,
    Object? prefixPaddingMs = unsetCopyWithValue,
    Object? silenceDurationMs = unsetCopyWithValue,
    Object? threshold = unsetCopyWithValue,
  }) => ServerVad(
    createResponse: identical(createResponse, unsetCopyWithValue)
        ? this.createResponse
        : createResponse as bool?,
    idleTimeoutMs: identical(idleTimeoutMs, unsetCopyWithValue)
        ? this.idleTimeoutMs
        : idleTimeoutMs as int?,
    interruptResponse: identical(interruptResponse, unsetCopyWithValue)
        ? this.interruptResponse
        : interruptResponse as bool?,
    prefixPaddingMs: identical(prefixPaddingMs, unsetCopyWithValue)
        ? this.prefixPaddingMs
        : prefixPaddingMs as int?,
    silenceDurationMs: identical(silenceDurationMs, unsetCopyWithValue)
        ? this.silenceDurationMs
        : silenceDurationMs as int?,
    threshold: identical(threshold, unsetCopyWithValue)
        ? this.threshold
        : threshold as double?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerVad &&
          runtimeType == other.runtimeType &&
          createResponse == other.createResponse &&
          idleTimeoutMs == other.idleTimeoutMs &&
          interruptResponse == other.interruptResponse &&
          prefixPaddingMs == other.prefixPaddingMs &&
          silenceDurationMs == other.silenceDurationMs &&
          threshold == other.threshold;

  @override
  int get hashCode => Object.hash(
    createResponse,
    idleTimeoutMs,
    interruptResponse,
    prefixPaddingMs,
    silenceDurationMs,
    threshold,
  );

  @override
  String toString() =>
      'ServerVad(createResponse: $createResponse, idleTimeoutMs: $idleTimeoutMs, '
      'interruptResponse: $interruptResponse, prefixPaddingMs: $prefixPaddingMs, '
      'silenceDurationMs: $silenceDurationMs, threshold: $threshold)';
}

/// Semantic VAD turn detection.
@immutable
class SemanticVad extends RealtimeAudioInputTurnDetection {
  /// Creates a [SemanticVad].
  const SemanticVad({
    this.createResponse,
    this.eagerness,
    this.interruptResponse,
  });

  /// Creates from JSON.
  factory SemanticVad.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'semantic_vad') {
      throw FormatException(
        'SemanticVad.fromJson expected type "semantic_vad", got ${json['type']}',
      );
    }
    return SemanticVad(
      createResponse: json['create_response'] as bool?,
      eagerness: json['eagerness'] != null
          ? SemanticVadEagerness.fromJson(json['eagerness'] as String)
          : null,
      interruptResponse: json['interrupt_response'] as bool?,
    );
  }

  /// Whether to automatically generate a response on VAD stop.
  final bool? createResponse;

  /// Eagerness controlling the timeout used to decide the speaker is done.
  final SemanticVadEagerness? eagerness;

  /// Whether to interrupt an in-progress response on VAD start.
  final bool? interruptResponse;

  @override
  String get type => 'semantic_vad';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (createResponse != null) 'create_response': createResponse,
    if (eagerness != null) 'eagerness': eagerness!.toJson(),
    if (interruptResponse != null) 'interrupt_response': interruptResponse,
  };

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass `null` for any field to clear the existing value.
  SemanticVad copyWith({
    Object? createResponse = unsetCopyWithValue,
    Object? eagerness = unsetCopyWithValue,
    Object? interruptResponse = unsetCopyWithValue,
  }) => SemanticVad(
    createResponse: identical(createResponse, unsetCopyWithValue)
        ? this.createResponse
        : createResponse as bool?,
    eagerness: identical(eagerness, unsetCopyWithValue)
        ? this.eagerness
        : eagerness as SemanticVadEagerness?,
    interruptResponse: identical(interruptResponse, unsetCopyWithValue)
        ? this.interruptResponse
        : interruptResponse as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemanticVad &&
          runtimeType == other.runtimeType &&
          createResponse == other.createResponse &&
          eagerness == other.eagerness &&
          interruptResponse == other.interruptResponse;

  @override
  int get hashCode => Object.hash(createResponse, eagerness, interruptResponse);

  @override
  String toString() =>
      'SemanticVad(createResponse: $createResponse, eagerness: $eagerness, '
      'interruptResponse: $interruptResponse)';
}

/// Forward-compatible fallback for unknown turn-detection variants.
@immutable
class UnknownRealtimeAudioInputTurnDetection
    extends RealtimeAudioInputTurnDetection {
  /// Creates from the raw payload.
  const UnknownRealtimeAudioInputTurnDetection(this.json);

  /// The raw JSON map preserved verbatim.
  final Map<String, dynamic> json;

  @override
  String get type => json['type'] as String? ?? '';

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownRealtimeAudioInputTurnDetection &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(json, other.json);

  @override
  int get hashCode => mapDeepHashCode(json);

  @override
  String toString() => 'UnknownRealtimeAudioInputTurnDetection(type: $type)';
}
