import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import '../common/copy_with_sentinel.dart';

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
          capabilities == other.capabilities;

  @override
  int get hashCode => Object.hash(
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
  );

  @override
  String toString() =>
      'Model(id: $id, object: $object, created: $created, '
      'ownedBy: $ownedBy, name: $name, description: $description, '
      'maxContextLength: $maxContextLength, aliases: $aliases, '
      'defaultModelTemperature: $defaultModelTemperature, '
      'type: $type, capabilities: $capabilities)';
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

  /// Creates [ModelCapabilities].
  const ModelCapabilities({
    this.completionChat,
    this.completionFim,
    this.functionCalling,
    this.fineTuning,
    this.vision,
    this.classification,
    this.audioTranscription,
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
  };

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
          audioTranscription == other.audioTranscription;

  @override
  int get hashCode => Object.hash(
    completionChat,
    completionFim,
    functionCalling,
    fineTuning,
    vision,
    classification,
    audioTranscription,
  );

  @override
  String toString() =>
      'ModelCapabilities('
      'chat: $completionChat, '
      'fim: $completionFim, '
      'functions: $functionCalling, '
      'vision: $vision)';
}
