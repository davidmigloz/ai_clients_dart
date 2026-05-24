import '../../copy_with_sentinel.dart';

/// MIME type of the audio output.
enum AudioResponseFormatMimeType {
  /// Default value. This value is unused.
  unspecified,

  /// MP3 audio format.
  audioMp3,

  /// OGG Opus audio format.
  audioOggOpus,

  /// Raw PCM (L16) audio format.
  audioL16,

  /// WAV audio format.
  audioWav,

  /// A-law audio format.
  audioAlaw,

  /// Mu-law audio format.
  audioMulaw,
}

/// Converts a string to an [AudioResponseFormatMimeType] enum value.
AudioResponseFormatMimeType audioResponseFormatMimeTypeFromString(
  String? value,
) {
  return switch (value) {
    'AUDIO_MP3' => AudioResponseFormatMimeType.audioMp3,
    'AUDIO_OGG_OPUS' => AudioResponseFormatMimeType.audioOggOpus,
    'AUDIO_L16' => AudioResponseFormatMimeType.audioL16,
    'AUDIO_WAV' => AudioResponseFormatMimeType.audioWav,
    'AUDIO_ALAW' => AudioResponseFormatMimeType.audioAlaw,
    'AUDIO_MULAW' => AudioResponseFormatMimeType.audioMulaw,
    _ => AudioResponseFormatMimeType.unspecified,
  };
}

/// Converts an [AudioResponseFormatMimeType] enum value to a string.
String audioResponseFormatMimeTypeToString(AudioResponseFormatMimeType value) {
  return switch (value) {
    AudioResponseFormatMimeType.audioMp3 => 'AUDIO_MP3',
    AudioResponseFormatMimeType.audioOggOpus => 'AUDIO_OGG_OPUS',
    AudioResponseFormatMimeType.audioL16 => 'AUDIO_L16',
    AudioResponseFormatMimeType.audioWav => 'AUDIO_WAV',
    AudioResponseFormatMimeType.audioAlaw => 'AUDIO_ALAW',
    AudioResponseFormatMimeType.audioMulaw => 'AUDIO_MULAW',
    AudioResponseFormatMimeType.unspecified => 'MIME_TYPE_UNSPECIFIED',
  };
}

/// Delivery mode for an audio response.
enum AudioResponseFormatDelivery {
  /// Default value. This value is unused.
  unspecified,

  /// Audio data is returned inline in the response.
  inline,

  /// Audio data is returned as a URI.
  uri,
}

/// Converts a string to an [AudioResponseFormatDelivery] enum value.
AudioResponseFormatDelivery audioResponseFormatDeliveryFromString(
  String? value,
) {
  return switch (value) {
    'INLINE' => AudioResponseFormatDelivery.inline,
    'URI' => AudioResponseFormatDelivery.uri,
    _ => AudioResponseFormatDelivery.unspecified,
  };
}

/// Converts an [AudioResponseFormatDelivery] enum value to a string.
String audioResponseFormatDeliveryToString(AudioResponseFormatDelivery value) {
  return switch (value) {
    AudioResponseFormatDelivery.inline => 'INLINE',
    AudioResponseFormatDelivery.uri => 'URI',
    AudioResponseFormatDelivery.unspecified => 'DELIVERY_UNSPECIFIED',
  };
}

/// Configuration for audio output format.
class AudioResponseFormat {
  /// The MIME type of the audio output.
  final AudioResponseFormatMimeType? mimeType;

  /// Bit rate in bits per second (bps).
  ///
  /// Only applicable for compressed formats (MP3, Opus).
  final int? bitRate;

  /// Sample rate in Hz.
  final int? sampleRate;

  /// The delivery mode for the audio output.
  final AudioResponseFormatDelivery? delivery;

  /// Creates an [AudioResponseFormat].
  const AudioResponseFormat({
    this.mimeType,
    this.bitRate,
    this.sampleRate,
    this.delivery,
  });

  /// Creates an [AudioResponseFormat] from JSON.
  factory AudioResponseFormat.fromJson(Map<String, dynamic> json) =>
      AudioResponseFormat(
        mimeType: json['mimeType'] != null
            ? audioResponseFormatMimeTypeFromString(json['mimeType'] as String)
            : null,
        bitRate: json['bitRate'] as int?,
        sampleRate: json['sampleRate'] as int?,
        delivery: json['delivery'] != null
            ? audioResponseFormatDeliveryFromString(json['delivery'] as String)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (mimeType != null)
      'mimeType': audioResponseFormatMimeTypeToString(mimeType!),
    if (bitRate != null) 'bitRate': bitRate,
    if (sampleRate != null) 'sampleRate': sampleRate,
    if (delivery != null)
      'delivery': audioResponseFormatDeliveryToString(delivery!),
  };

  /// Creates a copy with replaced values.
  AudioResponseFormat copyWith({
    Object? mimeType = unsetCopyWithValue,
    Object? bitRate = unsetCopyWithValue,
    Object? sampleRate = unsetCopyWithValue,
    Object? delivery = unsetCopyWithValue,
  }) {
    return AudioResponseFormat(
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as AudioResponseFormatMimeType?,
      bitRate: bitRate == unsetCopyWithValue ? this.bitRate : bitRate as int?,
      sampleRate: sampleRate == unsetCopyWithValue
          ? this.sampleRate
          : sampleRate as int?,
      delivery: delivery == unsetCopyWithValue
          ? this.delivery
          : delivery as AudioResponseFormatDelivery?,
    );
  }
}
