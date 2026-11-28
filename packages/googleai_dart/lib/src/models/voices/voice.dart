import 'dart:convert';

import '../interactions/usage.dart';

/// The creation method or catalog source for a Gemini voice.
extension type const VoiceType(String value) {
  /// A voice designed from a written prompt.
  static const prompted = VoiceType('prompted');

  /// A voice made from a speaker's sample and consent recordings.
  static const replicated = VoiceType('replicated');

  /// A built-in voice from Google's catalog.
  static const prebuilt = VoiceType('prebuilt');
}

/// Vocal pitch for voice creation and filtering.
extension type const VoicePitch(String value) {
  /// A lower pitch voice.
  static const low = VoicePitch('low');

  /// A medium pitch voice.
  static const medium = VoicePitch('medium');

  /// A higher pitch voice.
  static const high = VoicePitch('high');
}

/// Audio used for voice creation or returned as a synthesized preview.
class VoiceAudioData {
  /// Base64-encoded audio.
  final String data;

  /// The IANA MIME type of the audio.
  final String mimeType;

  /// Creates an audio payload from base64 data.
  const VoiceAudioData({required this.data, required this.mimeType});

  /// Creates an audio payload from raw bytes.
  factory VoiceAudioData.fromBytes(
    List<int> bytes, {
    required String mimeType,
  }) => VoiceAudioData(data: base64Encode(bytes), mimeType: mimeType);

  /// Creates an audio payload from JSON.
  factory VoiceAudioData.fromJson(Map<String, dynamic> json) => VoiceAudioData(
    data: json['data'] as String,
    mimeType: json['mime_type'] as String,
  );

  /// Decodes the audio bytes.
  List<int> toBytes() => base64Decode(data);

  /// Converts the audio payload to JSON.
  Map<String, dynamic> toJson() => {'data': data, 'mime_type': mimeType};
}

/// A prompt for designing or remixing a voice.
class PromptedVoice {
  /// The description of the desired voice or changes to [baseVoice].
  final String input;

  /// Optional prebuilt voice name or custom voice ID to remix.
  final String? baseVoice;

  /// Creates a voice prompt.
  const PromptedVoice({required this.input, this.baseVoice});

  /// Creates a voice prompt from JSON.
  factory PromptedVoice.fromJson(Map<String, dynamic> json) => PromptedVoice(
    input: json['input'] as String,
    baseVoice: json['base_voice'] as String?,
  );

  /// Converts the voice prompt to JSON.
  Map<String, dynamic> toJson() => {'input': input, 'base_voice': ?baseVoice};
}

/// Audio supplied when replicating a voice with the speaker's consent.
class ReplicatedVoice {
  /// An unmodified source recording of the speaker.
  final VoiceAudioData sourceAudio;

  /// The same speaker's recording of Google's required consent phrase.
  final VoiceAudioData consentAudio;

  /// Creates a voice replication request with both required recordings.
  const ReplicatedVoice({
    required this.sourceAudio,
    required this.consentAudio,
  });

  /// Creates a voice replication request from JSON.
  factory ReplicatedVoice.fromJson(Map<String, dynamic> json) =>
      ReplicatedVoice(
        sourceAudio: VoiceAudioData.fromJson(
          json['source_audio'] as Map<String, dynamic>,
        ),
        consentAudio: VoiceAudioData.fromJson(
          json['consent_audio'] as Map<String, dynamic>,
        ),
      );

  /// Converts the voice replication request to JSON.
  Map<String, dynamic> toJson() => {
    'source_audio': sourceAudio.toJson(),
    'consent_audio': consentAudio.toJson(),
  };
}

/// A custom Gemini voice or a prebuilt voice catalog entry.
class Voice {
  /// The type of voice.
  final VoiceType type;

  /// Model used to create the voice.
  final String? model;

  /// Name for a stored or prebuilt voice.
  final String? displayName;

  /// The BCP-47 language tag.
  final String? languageCode;

  /// The ISO 3166-1 alpha-2 or UN M.49 region.
  final String? regionCode;

  /// A description of the voice.
  final String? description;

  /// A descriptor of the regional accent.
  final String? accent;

  /// The intended context or domain for this voice.
  final String? context;

  /// The perceived gender of the voice.
  final String? gender;

  /// A descriptor of the vocal persona.
  final String? persona;

  /// The vocal pitch.
  final VoicePitch? pitch;

  /// The prompt used to create or edit a voice.
  final PromptedVoice? prompted;

  /// Input-only audio for a replication request.
  final ReplicatedVoice? replicated;

  /// The stored voice ID or prebuilt catalog name.
  final String? id;

  /// The client-managed replication key returned for an unstored voice. Treat it as sensitive.
  final String? key;

  /// The expiration time of a stored voice or client-managed key.
  final DateTime? expireTime;

  /// Preview audio returned by voice design.
  final VoiceAudioData? sampleAudio;

  /// Usage for creating the voice, when returned.
  final InteractionUsage? usage;

  /// Creates a voice resource.
  const Voice({
    required this.type,
    this.model,
    this.displayName,
    this.languageCode,
    this.regionCode,
    this.description,
    this.accent,
    this.context,
    this.gender,
    this.persona,
    this.pitch,
    this.prompted,
    this.replicated,
    this.id,
    this.key,
    this.expireTime,
    this.sampleAudio,
    this.usage,
  });

  /// Creates a voice resource from JSON.
  factory Voice.fromJson(Map<String, dynamic> json) => Voice(
    type: VoiceType(json['type'] as String),
    model: json['model'] as String?,
    displayName: json['display_name'] as String?,
    languageCode: json['language_code'] as String?,
    regionCode: json['region_code'] as String?,
    description: json['description'] as String?,
    accent: json['accent'] as String?,
    context: json['context'] as String?,
    gender: json['gender'] as String?,
    persona: json['persona'] as String?,
    pitch: json['pitch'] == null ? null : VoicePitch(json['pitch'] as String),
    prompted: json['prompted'] == null
        ? null
        : PromptedVoice.fromJson(json['prompted'] as Map<String, dynamic>),
    replicated: json['replicated'] == null
        ? null
        : ReplicatedVoice.fromJson(json['replicated'] as Map<String, dynamic>),
    id: json['id'] as String?,
    key: json['key'] as String?,
    expireTime: json['expire_time'] == null
        ? null
        : DateTime.parse(json['expire_time'] as String),
    sampleAudio: json['sample_audio'] == null
        ? null
        : VoiceAudioData.fromJson(json['sample_audio'] as Map<String, dynamic>),
    usage: json['usage'] == null
        ? null
        : InteractionUsage.fromJson(json['usage'] as Map<String, dynamic>),
  );

  /// Converts the voice resource to JSON.
  Map<String, dynamic> toJson() => {
    ...toCreateJson(),
    'id': ?id,
    'key': ?key,
    'expire_time': ?expireTime?.toIso8601String(),
    'sample_audio': ?sampleAudio?.toJson(),
    'usage': ?usage?.toJson(),
  };

  /// Encodes writable fields for a create request.
  Map<String, dynamic> toCreateJson() => {
    'type': type.value,
    'model': ?model,
    'display_name': ?displayName,
    'language_code': ?languageCode,
    'region_code': ?regionCode,
    'description': ?description,
    'accent': ?accent,
    'context': ?context,
    'gender': ?gender,
    'persona': ?persona,
    'pitch': ?pitch?.value,
    'prompted': ?prompted?.toJson(),
    'replicated': ?replicated?.toJson(),
  };
}

/// A page of custom and prebuilt Gemini voices.
class ListVoicesResponse {
  /// Voices on this page.
  final List<Voice>? voices;

  /// Token for the next page, when available.
  final String? nextPageToken;

  /// Creates a page of voices.
  const ListVoicesResponse({this.voices, this.nextPageToken});

  /// Creates a page of voices from JSON.
  factory ListVoicesResponse.fromJson(Map<String, dynamic> json) =>
      ListVoicesResponse(
        voices: (json['voices'] as List<dynamic>?)
            ?.map((item) => Voice.fromJson(item as Map<String, dynamic>))
            .toList(),
        nextPageToken: json['next_page_token'] as String?,
      );

  /// Converts the response to JSON.
  Map<String, dynamic> toJson() => {
    if (voices != null) 'voices': [for (final voice in voices!) voice.toJson()],
    'next_page_token': ?nextPageToken,
  };
}
