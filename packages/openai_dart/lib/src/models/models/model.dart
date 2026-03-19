import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Information about an OpenAI model.
///
/// Models represent the available language models and their capabilities.
///
/// ## Example
///
/// ```dart
/// final models = await client.models.list();
///
/// for (final model in models.data) {
///   print('${model.id}: owned by ${model.ownedBy}');
/// }
/// ```
@immutable
class Model {
  /// Creates a [Model].
  const Model({
    required this.id,
    required this.object,
    this.created,
    this.ownedBy,
  });

  /// Creates a [Model] from JSON.
  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'] as String,
      object: json['object'] as String,
      created: json['created'] as int?,
      ownedBy: json['owned_by'] as String?,
    );
  }

  /// The model identifier.
  ///
  /// This is the value used when specifying a model in API requests.
  /// Examples: `gpt-4o`, `gpt-4-turbo`, `text-embedding-3-small`.
  final String id;

  /// The object type (always "model").
  final String object;

  /// The Unix timestamp when the model was created.
  ///
  /// May be null with some OpenAI-compatible providers (e.g., Cohere
  /// doesn't return `created`).
  final int? created;

  /// The organization that owns the model.
  ///
  /// For OpenAI models, this is typically "openai" or "system".
  /// For fine-tuned models, this is the organization ID.
  ///
  /// May be null with some OpenAI-compatible providers.
  final String? ownedBy;

  /// The creation time as a [DateTime], or null if [created] is null.
  DateTime? get createdAt => created != null
      ? DateTime.fromMillisecondsSinceEpoch(created! * 1000)
      : null;

  /// Whether this is a GPT-4 model.
  bool get isGpt4 => id.startsWith('gpt-4');

  /// Whether this is a GPT-3.5 model.
  bool get isGpt35 => id.startsWith('gpt-3.5');

  /// Whether this is an embedding model.
  bool get isEmbedding => id.contains('embedding');

  /// Whether this is a DALL-E model.
  bool get isDallE => id.startsWith('dall-e');

  /// Whether this is a Whisper model.
  bool get isWhisper => id.startsWith('whisper');

  /// Whether this is a TTS model.
  bool get isTts => id.startsWith('tts');

  /// Whether this is a fine-tuned model.
  bool get isFineTuned => id.startsWith('ft:');

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    if (created != null) 'created': created,
    if (ownedBy != null) 'owned_by': ownedBy,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Model && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Model(id: $id, ownedBy: $ownedBy)';
}

/// A list of models.
@immutable
class ModelList {
  /// Creates a [ModelList].
  const ModelList({required this.object, required this.data});

  /// Creates a [ModelList] from JSON.
  factory ModelList.fromJson(Map<String, dynamic> json) {
    return ModelList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Model.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of models.
  final List<Model> data;

  /// Whether the list is empty.
  bool get isEmpty => data.isEmpty;

  /// Whether the list is not empty.
  bool get isNotEmpty => data.isNotEmpty;

  /// The number of models.
  int get length => data.length;

  /// Gets models owned by a specific organization.
  List<Model> ownedBy(String owner) =>
      data.where((m) => m.ownedBy == owner).toList();

  /// Gets all GPT-4 models.
  List<Model> get gpt4Models => data.where((m) => m.isGpt4).toList();

  /// Gets all embedding models.
  List<Model> get embeddingModels => data.where((m) => m.isEmbedding).toList();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((m) => m.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          listsEqual(data, other.data);

  @override
  int get hashCode => Object.hash(object, Object.hashAll(data));

  @override
  String toString() => 'ModelList(${data.length} models)';
}

/// The response from deleting a model.
@immutable
class DeleteModelResponse {
  /// Creates a [DeleteModelResponse].
  const DeleteModelResponse({
    required this.id,
    required this.object,
    required this.deleted,
  });

  /// Creates a [DeleteModelResponse] from JSON.
  factory DeleteModelResponse.fromJson(Map<String, dynamic> json) {
    return DeleteModelResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      deleted: json['deleted'] as bool,
    );
  }

  /// The ID of the deleted model.
  final String id;

  /// The object type (always "model").
  final String object;

  /// Whether the model was successfully deleted.
  final bool deleted;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'deleted': deleted,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteModelResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deleted == other.deleted;

  @override
  int get hashCode => Object.hash(id, deleted);

  @override
  String toString() => 'DeleteModelResponse(id: $id, deleted: $deleted)';
}
