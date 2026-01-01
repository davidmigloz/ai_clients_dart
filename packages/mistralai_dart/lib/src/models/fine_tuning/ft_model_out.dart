import 'package:meta/meta.dart';

import 'classifier_target_out.dart';
import 'ft_model_capabilities_out.dart';

/// Base class for fine-tuned model output.
///
/// This is a sealed class with two implementations:
/// - [CompletionFTModelOut] for completion models
/// - [ClassifierFTModelOut] for classifier models
sealed class FTModelOut {
  /// The model ID.
  String get id;

  /// The object type (always "model").
  String get object;

  /// The creation timestamp.
  int get created;

  /// The owner of the model.
  String get ownedBy;

  /// The workspace ID.
  String get workspaceId;

  /// The root model ID.
  String get root;

  /// The root model version.
  String get rootVersion;

  /// Whether the model is archived.
  bool get archived;

  /// The model name.
  String? get name;

  /// The model description.
  String? get description;

  /// The model capabilities.
  FTModelCapabilitiesOut get capabilities;

  /// The maximum context length.
  int get maxContextLength;

  /// Model aliases.
  List<String> get aliases;

  /// The fine-tuning job ID.
  String get job;

  /// The model type discriminator.
  String get modelType;

  /// Creates from JSON, dispatching to the correct subclass.
  factory FTModelOut.fromJson(Map<String, dynamic> json) {
    final modelType = json['model_type'] as String?;
    return switch (modelType) {
      'classifier' => ClassifierFTModelOut.fromJson(json),
      _ => CompletionFTModelOut.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A completion fine-tuned model.
@immutable
class CompletionFTModelOut implements FTModelOut {
  @override
  final String id;

  @override
  final String object;

  @override
  final int created;

  @override
  final String ownedBy;

  @override
  final String workspaceId;

  @override
  final String root;

  @override
  final String rootVersion;

  @override
  final bool archived;

  @override
  final String? name;

  @override
  final String? description;

  @override
  final FTModelCapabilitiesOut capabilities;

  @override
  final int maxContextLength;

  @override
  final List<String> aliases;

  @override
  final String job;

  @override
  String get modelType => 'completion';

  /// Creates [CompletionFTModelOut].
  const CompletionFTModelOut({
    required this.id,
    this.object = 'model',
    required this.created,
    required this.ownedBy,
    required this.workspaceId,
    required this.root,
    required this.rootVersion,
    required this.archived,
    this.name,
    this.description,
    required this.capabilities,
    this.maxContextLength = 32768,
    this.aliases = const [],
    required this.job,
  });

  /// Creates from JSON.
  factory CompletionFTModelOut.fromJson(Map<String, dynamic> json) =>
      CompletionFTModelOut(
        id: json['id'] as String,
        object: json['object'] as String? ?? 'model',
        created: json['created'] as int,
        ownedBy: json['owned_by'] as String,
        workspaceId: json['workspace_id'] as String,
        root: json['root'] as String,
        rootVersion: json['root_version'] as String,
        archived: json['archived'] as bool,
        name: json['name'] as String?,
        description: json['description'] as String?,
        capabilities: FTModelCapabilitiesOut.fromJson(
          json['capabilities'] as Map<String, dynamic>,
        ),
        maxContextLength: json['max_context_length'] as int? ?? 32768,
        aliases: (json['aliases'] as List?)?.cast<String>() ?? const [],
        job: json['job'] as String,
      );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created': created,
    'owned_by': ownedBy,
    'workspace_id': workspaceId,
    'root': root,
    'root_version': rootVersion,
    'archived': archived,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    'capabilities': capabilities.toJson(),
    'max_context_length': maxContextLength,
    'aliases': aliases,
    'job': job,
    'model_type': modelType,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionFTModelOut &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          created == other.created &&
          archived == other.archived;

  @override
  int get hashCode => Object.hash(id, created, archived);

  @override
  String toString() =>
      'CompletionFTModelOut(id: $id, name: $name, '
      'archived: $archived)';
}

/// A classifier fine-tuned model.
@immutable
class ClassifierFTModelOut implements FTModelOut {
  @override
  final String id;

  @override
  final String object;

  @override
  final int created;

  @override
  final String ownedBy;

  @override
  final String workspaceId;

  @override
  final String root;

  @override
  final String rootVersion;

  @override
  final bool archived;

  @override
  final String? name;

  @override
  final String? description;

  @override
  final FTModelCapabilitiesOut capabilities;

  @override
  final int maxContextLength;

  @override
  final List<String> aliases;

  @override
  final String job;

  /// The classifier targets for this model.
  final List<ClassifierTargetOut> classifierTargets;

  @override
  String get modelType => 'classifier';

  /// Creates [ClassifierFTModelOut].
  const ClassifierFTModelOut({
    required this.id,
    this.object = 'model',
    required this.created,
    required this.ownedBy,
    required this.workspaceId,
    required this.root,
    required this.rootVersion,
    required this.archived,
    this.name,
    this.description,
    required this.capabilities,
    this.maxContextLength = 32768,
    this.aliases = const [],
    required this.job,
    required this.classifierTargets,
  });

  /// Creates from JSON.
  factory ClassifierFTModelOut.fromJson(Map<String, dynamic> json) =>
      ClassifierFTModelOut(
        id: json['id'] as String,
        object: json['object'] as String? ?? 'model',
        created: json['created'] as int,
        ownedBy: json['owned_by'] as String,
        workspaceId: json['workspace_id'] as String,
        root: json['root'] as String,
        rootVersion: json['root_version'] as String,
        archived: json['archived'] as bool,
        name: json['name'] as String?,
        description: json['description'] as String?,
        capabilities: FTModelCapabilitiesOut.fromJson(
          json['capabilities'] as Map<String, dynamic>,
        ),
        maxContextLength: json['max_context_length'] as int? ?? 32768,
        aliases: (json['aliases'] as List?)?.cast<String>() ?? const [],
        job: json['job'] as String,
        classifierTargets: (json['classifier_targets'] as List)
            .map((e) => ClassifierTargetOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created': created,
    'owned_by': ownedBy,
    'workspace_id': workspaceId,
    'root': root,
    'root_version': rootVersion,
    'archived': archived,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    'capabilities': capabilities.toJson(),
    'max_context_length': maxContextLength,
    'aliases': aliases,
    'job': job,
    'classifier_targets': classifierTargets.map((e) => e.toJson()).toList(),
    'model_type': modelType,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassifierFTModelOut &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          created == other.created &&
          archived == other.archived;

  @override
  int get hashCode => Object.hash(id, created, archived);

  @override
  String toString() =>
      'ClassifierFTModelOut(id: $id, name: $name, '
      'archived: $archived, classifierTargets: ${classifierTargets.length})';
}
