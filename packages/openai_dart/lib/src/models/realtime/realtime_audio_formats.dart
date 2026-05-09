import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

// =============================================================================
// RealtimeAudioFormats
// =============================================================================

/// Audio format for Realtime sessions.
///
/// A discriminated union (`type`) of three concrete formats:
///
/// - [AudioPcm] — `audio/pcm`, 24 kHz signed 16-bit PCM (`rate: 24000`).
/// - [AudioPcmu] — `audio/pcmu`, G.711 μ-law.
/// - [AudioPcma] — `audio/pcma`, G.711 A-law.
///
/// An [UnknownRealtimeAudioFormats] fallback preserves the original payload
/// for any unrecognised discriminator so that future server additions do not
/// break existing clients.
///
/// ## Example
///
/// ```dart
/// const format = RealtimeAudioFormats.pcm(rate: 24000);
/// const ulaw = RealtimeAudioFormats.pcmu();
/// ```
sealed class RealtimeAudioFormats {
  const RealtimeAudioFormats();

  /// Creates a 24 kHz PCM audio format.
  const factory RealtimeAudioFormats.pcm({int? rate}) = AudioPcm;

  /// Creates a G.711 μ-law audio format.
  const factory RealtimeAudioFormats.pcmu() = AudioPcmu;

  /// Creates a G.711 A-law audio format.
  const factory RealtimeAudioFormats.pcma() = AudioPcma;

  /// Creates from JSON.
  ///
  /// Returns an [UnknownRealtimeAudioFormats] for unrecognised `type` values
  /// rather than throwing — the raw payload is preserved on round-trip.
  factory RealtimeAudioFormats.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    return switch (type) {
      'audio/pcm' => AudioPcm.fromJson(json),
      'audio/pcmu' => AudioPcmu.fromJson(json),
      'audio/pcma' => AudioPcma.fromJson(json),
      _ => UnknownRealtimeAudioFormats(Map<String, dynamic>.from(json)),
    };
  }

  /// The audio format discriminator.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// 24 kHz signed 16-bit PCM audio format.
///
/// `type == "audio/pcm"`. Only `rate: 24000` is currently supported by the API.
@immutable
class AudioPcm extends RealtimeAudioFormats {
  /// Creates an [AudioPcm].
  const AudioPcm({this.rate});

  /// Creates from JSON.
  factory AudioPcm.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'audio/pcm') {
      throw FormatException(
        'AudioPcm.fromJson expected type "audio/pcm", got ${json['type']}',
      );
    }
    return AudioPcm(rate: json['rate'] as int?);
  }

  /// Sample rate. Always `24000` when present.
  final int? rate;

  @override
  String get type => 'audio/pcm';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (rate != null) 'rate': rate,
  };

  /// Returns a copy of this [AudioPcm] with the given fields replaced.
  ///
  /// Pass `null` for [rate] to clear the existing value.
  AudioPcm copyWith({Object? rate = unsetCopyWithValue}) => AudioPcm(
    rate: identical(rate, unsetCopyWithValue) ? this.rate : rate as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPcm &&
          runtimeType == other.runtimeType &&
          rate == other.rate;

  @override
  int get hashCode => rate.hashCode;

  @override
  String toString() => 'AudioPcm(rate: $rate)';
}

/// G.711 μ-law audio format.
///
/// `type == "audio/pcmu"`.
@immutable
class AudioPcmu extends RealtimeAudioFormats {
  /// Creates an [AudioPcmu].
  const AudioPcmu();

  /// Creates from JSON.
  factory AudioPcmu.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'audio/pcmu') {
      throw FormatException(
        'AudioPcmu.fromJson expected type "audio/pcmu", got ${json['type']}',
      );
    }
    return const AudioPcmu();
  }

  @override
  String get type => 'audio/pcmu';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Returns a copy of this [AudioPcmu]. No fields to replace.
  AudioPcmu copyWith() => const AudioPcmu();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPcmu && runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'AudioPcmu()';
}

/// G.711 A-law audio format.
///
/// `type == "audio/pcma"`.
@immutable
class AudioPcma extends RealtimeAudioFormats {
  /// Creates an [AudioPcma].
  const AudioPcma();

  /// Creates from JSON.
  factory AudioPcma.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'audio/pcma') {
      throw FormatException(
        'AudioPcma.fromJson expected type "audio/pcma", got ${json['type']}',
      );
    }
    return const AudioPcma();
  }

  @override
  String get type => 'audio/pcma';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Returns a copy of this [AudioPcma]. No fields to replace.
  AudioPcma copyWith() => const AudioPcma();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPcma && runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'AudioPcma()';
}

/// Forward-compatible fallback for unknown [RealtimeAudioFormats] discriminators.
///
/// Preserves the raw JSON payload so the value can round-trip without loss.
@immutable
class UnknownRealtimeAudioFormats extends RealtimeAudioFormats {
  /// Creates an [UnknownRealtimeAudioFormats] from the raw JSON payload.
  const UnknownRealtimeAudioFormats(this.json);

  /// The raw JSON map preserved verbatim.
  final Map<String, dynamic> json;

  @override
  String get type => json['type'] as String? ?? '';

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownRealtimeAudioFormats &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(json, other.json);

  @override
  int get hashCode => mapDeepHashCode(json);

  @override
  String toString() => 'UnknownRealtimeAudioFormats(type: $type)';
}
