part of 'response_formats.dart';

/// MIME type of the audio output.
enum AudioResponseFormatMimeType {
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

/// Converts a JSON string to an [AudioResponseFormatMimeType], or `null` if
/// unrecognized (forward-compatible).
AudioResponseFormatMimeType? audioResponseFormatMimeTypeFromString(
  String? value,
) {
  return switch (value) {
    'audio/mp3' => AudioResponseFormatMimeType.audioMp3,
    'audio/ogg_opus' => AudioResponseFormatMimeType.audioOggOpus,
    'audio/l16' => AudioResponseFormatMimeType.audioL16,
    'audio/wav' => AudioResponseFormatMimeType.audioWav,
    'audio/alaw' => AudioResponseFormatMimeType.audioAlaw,
    'audio/mulaw' => AudioResponseFormatMimeType.audioMulaw,
    _ => null,
  };
}

/// Converts an [AudioResponseFormatMimeType] to its JSON string.
String audioResponseFormatMimeTypeToString(AudioResponseFormatMimeType value) {
  return switch (value) {
    AudioResponseFormatMimeType.audioMp3 => 'audio/mp3',
    AudioResponseFormatMimeType.audioOggOpus => 'audio/ogg_opus',
    AudioResponseFormatMimeType.audioL16 => 'audio/l16',
    AudioResponseFormatMimeType.audioWav => 'audio/wav',
    AudioResponseFormatMimeType.audioAlaw => 'audio/alaw',
    AudioResponseFormatMimeType.audioMulaw => 'audio/mulaw',
  };
}

/// Delivery mode for an audio response.
enum AudioResponseFormatDelivery {
  /// Audio data is returned inline in the response.
  inline,

  /// Audio data is returned as a URL.
  url,
}

/// Converts a JSON string to an [AudioResponseFormatDelivery], or `null` if
/// unrecognized (forward-compatible).
AudioResponseFormatDelivery? audioResponseFormatDeliveryFromString(
  String? value,
) {
  return switch (value) {
    'inline' => AudioResponseFormatDelivery.inline,
    'url' => AudioResponseFormatDelivery.url,
    _ => null,
  };
}

/// Converts an [AudioResponseFormatDelivery] to its JSON string.
String audioResponseFormatDeliveryToString(AudioResponseFormatDelivery value) {
  return switch (value) {
    AudioResponseFormatDelivery.inline => 'inline',
    AudioResponseFormatDelivery.url => 'url',
  };
}

/// Configuration for audio output format.
class AudioResponseFormat extends ResponseFormat {
  @override
  String get type => 'audio';

  /// The MIME type of the audio output.
  final AudioResponseFormatMimeType? mimeType;

  /// Bit rate in bits per second (bps). Only applicable for compressed
  /// formats (MP3, Opus).
  final int? bitRate;

  /// Sample rate in Hz.
  final int? sampleRate;

  /// The delivery mode for the audio output.
  final AudioResponseFormatDelivery? delivery;

  /// Creates an [AudioResponseFormat] instance.
  const AudioResponseFormat({
    this.mimeType,
    this.bitRate,
    this.sampleRate,
    this.delivery,
  });

  /// Creates an [AudioResponseFormat] from JSON.
  factory AudioResponseFormat.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'audio') {
      throw FormatException('Expected type "audio" but got "${json['type']}"');
    }
    return AudioResponseFormat(
      mimeType: audioResponseFormatMimeTypeFromString(
        json['mime_type'] as String?,
      ),
      bitRate: json['bit_rate'] as int?,
      sampleRate: json['sample_rate'] as int?,
      delivery: audioResponseFormatDeliveryFromString(
        json['delivery'] as String?,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (mimeType != null)
      'mime_type': audioResponseFormatMimeTypeToString(mimeType!),
    if (bitRate != null) 'bit_rate': bitRate,
    if (sampleRate != null) 'sample_rate': sampleRate,
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
