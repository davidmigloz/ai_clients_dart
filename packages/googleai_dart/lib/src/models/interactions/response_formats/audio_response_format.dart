part of 'response_formats.dart';

/// MIME type of the audio output.
enum InteractionAudioResponseFormatMimeType {
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

/// Converts a JSON string to an [InteractionAudioResponseFormatMimeType], or
/// `null` if unrecognized (forward-compatible).
InteractionAudioResponseFormatMimeType?
interactionAudioResponseFormatMimeTypeFromString(String? value) {
  return switch (value) {
    'audio/mp3' => InteractionAudioResponseFormatMimeType.audioMp3,
    'audio/ogg_opus' => InteractionAudioResponseFormatMimeType.audioOggOpus,
    'audio/l16' => InteractionAudioResponseFormatMimeType.audioL16,
    'audio/wav' => InteractionAudioResponseFormatMimeType.audioWav,
    'audio/alaw' => InteractionAudioResponseFormatMimeType.audioAlaw,
    'audio/mulaw' => InteractionAudioResponseFormatMimeType.audioMulaw,
    _ => null,
  };
}

/// Converts an [InteractionAudioResponseFormatMimeType] to its JSON string.
String interactionAudioResponseFormatMimeTypeToString(
  InteractionAudioResponseFormatMimeType value,
) {
  return switch (value) {
    InteractionAudioResponseFormatMimeType.audioMp3 => 'audio/mp3',
    InteractionAudioResponseFormatMimeType.audioOggOpus => 'audio/ogg_opus',
    InteractionAudioResponseFormatMimeType.audioL16 => 'audio/l16',
    InteractionAudioResponseFormatMimeType.audioWav => 'audio/wav',
    InteractionAudioResponseFormatMimeType.audioAlaw => 'audio/alaw',
    InteractionAudioResponseFormatMimeType.audioMulaw => 'audio/mulaw',
  };
}

/// Delivery mode for an audio response.
enum InteractionAudioResponseFormatDelivery {
  /// Audio data is returned inline in the response.
  inline,

  /// Audio data is returned as a URL.
  url,
}

/// Converts a JSON string to an [InteractionAudioResponseFormatDelivery], or
/// `null` if unrecognized (forward-compatible).
InteractionAudioResponseFormatDelivery?
interactionAudioResponseFormatDeliveryFromString(String? value) {
  return switch (value) {
    'inline' => InteractionAudioResponseFormatDelivery.inline,
    'url' => InteractionAudioResponseFormatDelivery.url,
    _ => null,
  };
}

/// Converts an [InteractionAudioResponseFormatDelivery] to its JSON string.
String interactionAudioResponseFormatDeliveryToString(
  InteractionAudioResponseFormatDelivery value,
) {
  return switch (value) {
    InteractionAudioResponseFormatDelivery.inline => 'inline',
    InteractionAudioResponseFormatDelivery.url => 'url',
  };
}

/// Configuration for audio output format.
class InteractionAudioResponseFormat extends InteractionResponseFormat {
  @override
  String get type => 'audio';

  /// The MIME type of the audio output.
  final InteractionAudioResponseFormatMimeType? mimeType;

  /// Bit rate in bits per second (bps). Only applicable for compressed
  /// formats (MP3, Opus).
  final int? bitRate;

  /// Sample rate in Hz.
  final int? sampleRate;

  /// The delivery mode for the audio output.
  final InteractionAudioResponseFormatDelivery? delivery;

  /// Creates an [InteractionAudioResponseFormat] instance.
  const InteractionAudioResponseFormat({
    this.mimeType,
    this.bitRate,
    this.sampleRate,
    this.delivery,
  });

  /// Creates an [InteractionAudioResponseFormat] from JSON.
  factory InteractionAudioResponseFormat.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'audio') {
      throw FormatException('Expected type "audio" but got "${json['type']}"');
    }
    return InteractionAudioResponseFormat(
      mimeType: interactionAudioResponseFormatMimeTypeFromString(
        json['mime_type'] as String?,
      ),
      bitRate: json['bit_rate'] as int?,
      sampleRate: json['sample_rate'] as int?,
      delivery: interactionAudioResponseFormatDeliveryFromString(
        json['delivery'] as String?,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (mimeType != null)
      'mime_type': interactionAudioResponseFormatMimeTypeToString(mimeType!),
    if (bitRate != null) 'bit_rate': bitRate,
    if (sampleRate != null) 'sample_rate': sampleRate,
    if (delivery != null)
      'delivery': interactionAudioResponseFormatDeliveryToString(delivery!),
  };

  /// Creates a copy with replaced values.
  InteractionAudioResponseFormat copyWith({
    Object? mimeType = unsetCopyWithValue,
    Object? bitRate = unsetCopyWithValue,
    Object? sampleRate = unsetCopyWithValue,
    Object? delivery = unsetCopyWithValue,
  }) {
    return InteractionAudioResponseFormat(
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as InteractionAudioResponseFormatMimeType?,
      bitRate: bitRate == unsetCopyWithValue ? this.bitRate : bitRate as int?,
      sampleRate: sampleRate == unsetCopyWithValue
          ? this.sampleRate
          : sampleRate as int?,
      delivery: delivery == unsetCopyWithValue
          ? this.delivery
          : delivery as InteractionAudioResponseFormatDelivery?,
    );
  }
}
