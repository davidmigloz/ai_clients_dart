import 'package:meta/meta.dart';

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
  final ModelCapabilities? capabilities;

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
    this.capabilities,
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
        : null,
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
    if (capabilities != null) 'capabilities': capabilities!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Model && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Model(id: $id, name: $name)';
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

  /// Creates [ModelCapabilities].
  const ModelCapabilities({
    this.completionChat,
    this.completionFim,
    this.functionCalling,
    this.fineTuning,
    this.vision,
    this.classification,
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
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (completionChat != null) 'completion_chat': completionChat,
    if (completionFim != null) 'completion_fim': completionFim,
    if (functionCalling != null) 'function_calling': functionCalling,
    if (fineTuning != null) 'fine_tuning': fineTuning,
    if (vision != null) 'vision': vision,
    if (classification != null) 'classification': classification,
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
          classification == other.classification;

  @override
  int get hashCode => Object.hash(
    completionChat,
    completionFim,
    functionCalling,
    fineTuning,
    vision,
    classification,
  );

  @override
  String toString() =>
      'ModelCapabilities('
      'chat: $completionChat, '
      'fim: $completionFim, '
      'functions: $functionCalling, '
      'vision: $vision)';
}
