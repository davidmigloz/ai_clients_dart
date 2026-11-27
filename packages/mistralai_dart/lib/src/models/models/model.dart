import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'model_audio_capabilities.dart';

/// Information about a model.
@immutable
class Model {
  /// The model identifier.
  final String id;

  /// The object type (always "model").
  final String object;

  /// Unix timestamp of when the model was created.
  final int? created;

  /// The owner of the model.
  final String? ownedBy;

  /// Human-readable name of the model.
  final String? name;

  /// Description of the model.
  final String? description;

  /// Maximum context length the model supports.
  final int? maxContextLength;

  /// Model aliases.
  final List<String>? aliases;

  /// Default temperature for this model.
  final double? defaultModelTemperature;

  /// The type of model (e.g., "base", "fine-tuned").
  final String? type;

  /// The capabilities of this model.
  final ModelCapabilities capabilities;

  /// Whether this model is internal-only.
  final bool internal;

  /// Model name used for billing.
  final String? billingModelName;

  /// Deprecation timestamp when the model has one.
  final String? deprecation;

  /// Model to use in place of this deprecated model.
  final String? deprecationReplacementModel;

  /// Job identifier for a fine-tuned model.
  final String? job;

  /// Root model identifier for a fine-tuned model.
  final String? root;

  /// Whether the fine-tuned model is archived.
  final bool? archived;

  /// Speech generation capabilities, when reported.
  final AudioSpeechCapabilities? audioSpeechCapabilities;

  /// Speech recognition capabilities, when reported.
  final AudioTranscriptionCapabilities? audioTranscriptionCapabilities;

  /// Creates a [Model].
  const Model({
    required this.id,
    required this.object,
    this.created,
    this.ownedBy,
    this.name,
    this.description,
    this.maxContextLength,
    this.aliases,
    this.defaultModelTemperature,
    this.type,
    this.capabilities = const ModelCapabilities(),
    this.internal = false,
    this.billingModelName,
    this.deprecation,
    this.deprecationReplacementModel,
    this.job,
    this.root,
    this.archived,
    this.audioSpeechCapabilities,
    this.audioTranscriptionCapabilities,
  });

  /// Creates a [Model] from JSON.
  factory Model.fromJson(Map<String, dynamic> json) => Model(
    id: json['id'] as String? ?? '',
    object: json['object'] as String? ?? 'model',
    created: json['created'] as int?,
    ownedBy: json['owned_by'] as String?,
    name: json['name'] as String?,
    description: json['description'] as String?,
    maxContextLength: json['max_context_length'] as int?,
    aliases: (json['aliases'] as List?)?.cast<String>(),
    defaultModelTemperature: (json['default_model_temperature'] as num?)
        ?.toDouble(),
    type: json['type'] as String?,
    capabilities: json['capabilities'] != null
        ? ModelCapabilities.fromJson(
            json['capabilities'] as Map<String, dynamic>,
          )
        : const ModelCapabilities(),
    internal: json['internal'] as bool? ?? false,
    billingModelName: json['billing_model_name'] as String?,
    deprecation: json['deprecation'] as String?,
    deprecationReplacementModel:
        json['deprecation_replacement_model'] as String?,
    job: json['job'] as String?,
    root: json['root'] as String?,
    archived: json['archived'] as bool?,
    audioSpeechCapabilities: json['audio_speech_capabilities'] == null
        ? null
        : AudioSpeechCapabilities.fromJson(
            json['audio_speech_capabilities'] as Map<String, dynamic>,
          ),
    audioTranscriptionCapabilities:
        json['audio_transcription_capabilities'] == null
        ? null
        : AudioTranscriptionCapabilities.fromJson(
            json['audio_transcription_capabilities'] as Map<String, dynamic>,
          ),
  );

  /// Creates a copy with the given fields replaced.
  Model copyWith({
    String? id,
    String? object,
    Object? created = unsetCopyWithValue,
    Object? ownedBy = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? maxContextLength = unsetCopyWithValue,
    Object? aliases = unsetCopyWithValue,
    Object? defaultModelTemperature = unsetCopyWithValue,
    Object? type = unsetCopyWithValue,
    ModelCapabilities? capabilities,
    bool? internal,
    Object? billingModelName = unsetCopyWithValue,
    Object? deprecation = unsetCopyWithValue,
    Object? deprecationReplacementModel = unsetCopyWithValue,
    Object? job = unsetCopyWithValue,
    Object? root = unsetCopyWithValue,
    Object? archived = unsetCopyWithValue,
    Object? audioSpeechCapabilities = unsetCopyWithValue,
    Object? audioTranscriptionCapabilities = unsetCopyWithValue,
  }) => Model(
    id: id ?? this.id,
    object: object ?? this.object,
    created: created == unsetCopyWithValue ? this.created : created as int?,
    ownedBy: ownedBy == unsetCopyWithValue ? this.ownedBy : ownedBy as String?,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    maxContextLength: maxContextLength == unsetCopyWithValue
        ? this.maxContextLength
        : maxContextLength as int?,
    aliases: aliases == unsetCopyWithValue
        ? this.aliases
        : aliases as List<String>?,
    defaultModelTemperature: defaultModelTemperature == unsetCopyWithValue
        ? this.defaultModelTemperature
        : defaultModelTemperature as double?,
    type: type == unsetCopyWithValue ? this.type : type as String?,
    capabilities: capabilities ?? this.capabilities,
    internal: internal ?? this.internal,
    billingModelName: billingModelName == unsetCopyWithValue
        ? this.billingModelName
        : billingModelName as String?,
    deprecation: deprecation == unsetCopyWithValue
        ? this.deprecation
        : deprecation as String?,
    deprecationReplacementModel:
        deprecationReplacementModel == unsetCopyWithValue
        ? this.deprecationReplacementModel
        : deprecationReplacementModel as String?,
    job: job == unsetCopyWithValue ? this.job : job as String?,
    root: root == unsetCopyWithValue ? this.root : root as String?,
    archived: archived == unsetCopyWithValue
        ? this.archived
        : archived as bool?,
    audioSpeechCapabilities: audioSpeechCapabilities == unsetCopyWithValue
        ? this.audioSpeechCapabilities
        : audioSpeechCapabilities as AudioSpeechCapabilities?,
    audioTranscriptionCapabilities:
        audioTranscriptionCapabilities == unsetCopyWithValue
        ? this.audioTranscriptionCapabilities
        : audioTranscriptionCapabilities as AudioTranscriptionCapabilities?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    if (created != null) 'created': created,
    if (ownedBy != null) 'owned_by': ownedBy,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (maxContextLength != null) 'max_context_length': maxContextLength,
    if (aliases != null) 'aliases': aliases,
    if (defaultModelTemperature != null)
      'default_model_temperature': defaultModelTemperature,
    if (type != null) 'type': type,
    'capabilities': capabilities.toJson(),
    'internal': internal,
    if (billingModelName != null) 'billing_model_name': billingModelName,
    if (deprecation != null) 'deprecation': deprecation,
    if (deprecationReplacementModel != null)
      'deprecation_replacement_model': deprecationReplacementModel,
    if (job != null) 'job': job,
    if (root != null) 'root': root,
    if (archived != null) 'archived': archived,
    if (audioSpeechCapabilities != null)
      'audio_speech_capabilities': audioSpeechCapabilities!.toJson(),
    if (audioTranscriptionCapabilities != null)
      'audio_transcription_capabilities': audioTranscriptionCapabilities!
          .toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Model &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          created == other.created &&
          ownedBy == other.ownedBy &&
          name == other.name &&
          description == other.description &&
          maxContextLength == other.maxContextLength &&
          listsEqual(aliases, other.aliases) &&
          defaultModelTemperature == other.defaultModelTemperature &&
          type == other.type &&
          capabilities == other.capabilities &&
          internal == other.internal &&
          billingModelName == other.billingModelName &&
          deprecation == other.deprecation &&
          deprecationReplacementModel == other.deprecationReplacementModel &&
          job == other.job &&
          root == other.root &&
          archived == other.archived &&
          audioSpeechCapabilities == other.audioSpeechCapabilities &&
          audioTranscriptionCapabilities ==
              other.audioTranscriptionCapabilities;

  @override
  int get hashCode => Object.hashAll([
    id,
    object,
    created,
    ownedBy,
    name,
    description,
    maxContextLength,
    Object.hashAll(aliases ?? []),
    defaultModelTemperature,
    type,
    capabilities,
    internal,
    billingModelName,
    deprecation,
    deprecationReplacementModel,
    job,
    root,
    archived,
    audioSpeechCapabilities,
    audioTranscriptionCapabilities,
  ]);

  @override
  String toString() =>
      'Model(id: $id, object: $object, created: $created, '
      'ownedBy: $ownedBy, name: $name, description: $description, '
      'maxContextLength: $maxContextLength, aliases: $aliases, '
      'defaultModelTemperature: $defaultModelTemperature, '
      'type: $type, capabilities: $capabilities, internal: $internal, '
      'billingModelName: $billingModelName, '
      'deprecation: $deprecation, '
      'deprecationReplacementModel: $deprecationReplacementModel, '
      'job: $job, '
      'root: $root, '
      'archived: $archived, '
      'audioSpeechCapabilities: $audioSpeechCapabilities, '
      'audioTranscriptionCapabilities: $audioTranscriptionCapabilities)';
}

/// Capabilities of a model.
@immutable
class ModelCapabilities {
  /// Whether the model supports chat completion.
  final bool? completionChat;

  /// Whether the model supports fill-in-the-middle completion.
  final bool? completionFim;

  /// Whether the model supports function/tool calling.
  final bool? functionCalling;

  /// Whether the model can be fine-tuned.
  final bool? fineTuning;

  /// Whether the model supports vision (image inputs).
  final bool? vision;

  /// Whether the model supports classification tasks.
  final bool? classification;

  /// Whether the model supports audio transcription.
  final bool? audioTranscription;

  /// Whether the model supports speech generation.
  final bool? audioSpeech;

  /// Whether the model supports realtime audio transcription.
  final bool? audioTranscriptionRealtime;

  /// Whether the model supports reasoning.
  final bool? reasoning;

  /// Whether the model supports audio inputs.
  final bool? audio;

  /// Whether the model supports moderation.
  final bool? moderation;

  /// Whether the model supports OCR.
  final bool? ocr;

  /// Whether the model supports unified resources.
  final bool? unifiedResources;

  /// Creates [ModelCapabilities].
  const ModelCapabilities({
    this.completionChat,
    this.completionFim,
    this.functionCalling,
    this.fineTuning,
    this.vision,
    this.classification,
    this.audioTranscription,
    this.audioSpeech,
    this.audioTranscriptionRealtime,
    this.reasoning,
    this.audio,
    this.moderation,
    this.ocr,
    this.unifiedResources,
  });

  /// Creates [ModelCapabilities] from JSON.
  factory ModelCapabilities.fromJson(Map<String, dynamic> json) =>
      ModelCapabilities(
        completionChat: json['completion_chat'] as bool?,
        completionFim: json['completion_fim'] as bool?,
        functionCalling: json['function_calling'] as bool?,
        fineTuning: json['fine_tuning'] as bool?,
        vision: json['vision'] as bool?,
        classification: json['classification'] as bool?,
        audioTranscription: json['audio_transcription'] as bool?,
        audioSpeech: json['audio_speech'] as bool?,
        audioTranscriptionRealtime:
            json['audio_transcription_realtime'] as bool?,
        reasoning: json['reasoning'] as bool?,
        audio: json['audio'] as bool?,
        moderation: json['moderation'] as bool?,
        ocr: json['ocr'] as bool?,
        unifiedResources: json['unified_resources'] as bool?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (completionChat != null) 'completion_chat': completionChat,
    if (completionFim != null) 'completion_fim': completionFim,
    if (functionCalling != null) 'function_calling': functionCalling,
    if (fineTuning != null) 'fine_tuning': fineTuning,
    if (vision != null) 'vision': vision,
    if (classification != null) 'classification': classification,
    if (audioTranscription != null) 'audio_transcription': audioTranscription,
    if (audioSpeech != null) 'audio_speech': audioSpeech,
    if (audioTranscriptionRealtime != null)
      'audio_transcription_realtime': audioTranscriptionRealtime,
    if (reasoning != null) 'reasoning': reasoning,
    if (audio != null) 'audio': audio,
    if (moderation != null) 'moderation': moderation,
    if (ocr != null) 'ocr': ocr,
    if (unifiedResources != null) 'unified_resources': unifiedResources,
  };

  /// Creates a copy with replaced values.
  ModelCapabilities copyWith({
    Object? completionChat = unsetCopyWithValue,
    Object? completionFim = unsetCopyWithValue,
    Object? functionCalling = unsetCopyWithValue,
    Object? fineTuning = unsetCopyWithValue,
    Object? vision = unsetCopyWithValue,
    Object? classification = unsetCopyWithValue,
    Object? audioTranscription = unsetCopyWithValue,
    Object? audioSpeech = unsetCopyWithValue,
    Object? audioTranscriptionRealtime = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? audio = unsetCopyWithValue,
    Object? moderation = unsetCopyWithValue,
    Object? ocr = unsetCopyWithValue,
    Object? unifiedResources = unsetCopyWithValue,
  }) => ModelCapabilities(
    completionChat: completionChat == unsetCopyWithValue
        ? this.completionChat
        : completionChat as bool?,
    completionFim: completionFim == unsetCopyWithValue
        ? this.completionFim
        : completionFim as bool?,
    functionCalling: functionCalling == unsetCopyWithValue
        ? this.functionCalling
        : functionCalling as bool?,
    fineTuning: fineTuning == unsetCopyWithValue
        ? this.fineTuning
        : fineTuning as bool?,
    vision: vision == unsetCopyWithValue ? this.vision : vision as bool?,
    classification: classification == unsetCopyWithValue
        ? this.classification
        : classification as bool?,
    audioTranscription: audioTranscription == unsetCopyWithValue
        ? this.audioTranscription
        : audioTranscription as bool?,
    audioSpeech: audioSpeech == unsetCopyWithValue
        ? this.audioSpeech
        : audioSpeech as bool?,
    audioTranscriptionRealtime: audioTranscriptionRealtime == unsetCopyWithValue
        ? this.audioTranscriptionRealtime
        : audioTranscriptionRealtime as bool?,
    reasoning: reasoning == unsetCopyWithValue
        ? this.reasoning
        : reasoning as bool?,
    audio: audio == unsetCopyWithValue ? this.audio : audio as bool?,
    moderation: moderation == unsetCopyWithValue
        ? this.moderation
        : moderation as bool?,
    ocr: ocr == unsetCopyWithValue ? this.ocr : ocr as bool?,
    unifiedResources: unifiedResources == unsetCopyWithValue
        ? this.unifiedResources
        : unifiedResources as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelCapabilities &&
          runtimeType == other.runtimeType &&
          completionChat == other.completionChat &&
          completionFim == other.completionFim &&
          functionCalling == other.functionCalling &&
          fineTuning == other.fineTuning &&
          vision == other.vision &&
          classification == other.classification &&
          audioTranscription == other.audioTranscription &&
          audioSpeech == other.audioSpeech &&
          audioTranscriptionRealtime == other.audioTranscriptionRealtime &&
          reasoning == other.reasoning &&
          audio == other.audio &&
          moderation == other.moderation &&
          ocr == other.ocr &&
          unifiedResources == other.unifiedResources;

  @override
  int get hashCode => Object.hash(
    completionChat,
    completionFim,
    functionCalling,
    fineTuning,
    vision,
    classification,
    audioTranscription,
    audioSpeech,
    audioTranscriptionRealtime,
    reasoning,
    audio,
    moderation,
    ocr,
    unifiedResources,
  );

  @override
  String toString() =>
      'ModelCapabilities('
      'completionChat: $completionChat, '
      'completionFim: $completionFim, '
      'functionCalling: $functionCalling, '
      'fineTuning: $fineTuning, '
      'vision: $vision, '
      'classification: $classification, '
      'audioTranscription: $audioTranscription, '
      'audioSpeech: $audioSpeech, '
      'audioTranscriptionRealtime: $audioTranscriptionRealtime, '
      'reasoning: $reasoning, '
      'audio: $audio, '
      'moderation: $moderation, '
      'ocr: $ocr, '
      'unifiedResources: $unifiedResources)';
}
