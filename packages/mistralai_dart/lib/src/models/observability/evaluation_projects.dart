import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../workflows/principal_type.dart';
import 'paginated_result.dart';

/// The EvaluationV2 wire payload.
@immutable
class ObservabilityEvaluation {
  /// Creates a [ObservabilityEvaluation].
  const ObservabilityEvaluation({
    required this.createdAt,
    required this.creatorId,
    this.creatorType,
    required this.deletedAt,
    required this.description,
    required this.id,
    this.isFavorite,
    required this.metadata,
    required this.name,
    required this.projectId,
    required this.slug,
    required this.tags,
    required this.updatedAt,
    required this.workspaceId,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The creator_id field.
  final String creatorId;

  /// The creator_type field.
  final PrincipalType? creatorType;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The description field.
  final String? description;

  /// The id field.
  final String id;

  /// The is_favorite field.
  final bool? isFavorite;

  /// The metadata_ field.
  final Map<String, Object?> metadata;

  /// The name field.
  final String name;

  /// The project_id field.
  final String projectId;

  /// The slug field.
  final String slug;

  /// The tags field.
  final List<String> tags;

  /// The updated_at field.
  final DateTime updatedAt;

  /// The workspace_id field.
  final String workspaceId;

  /// Parses a [ObservabilityEvaluation] from JSON.
  factory ObservabilityEvaluation.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException(
        'ObservabilityEvaluation: missing created_at',
      );
    }
    if (json['creator_id'] == null) {
      throw const FormatException(
        'ObservabilityEvaluation: missing creator_id',
      );
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException(
        'ObservabilityEvaluation: missing deleted_at',
      );
    }
    if (!json.containsKey('description')) {
      throw const FormatException(
        'ObservabilityEvaluation: missing description',
      );
    }
    if (json['id'] == null) {
      throw const FormatException('ObservabilityEvaluation: missing id');
    }
    if (json['metadata_'] == null) {
      throw const FormatException('ObservabilityEvaluation: missing metadata_');
    }
    if (json['name'] == null) {
      throw const FormatException('ObservabilityEvaluation: missing name');
    }
    if (json['project_id'] == null) {
      throw const FormatException(
        'ObservabilityEvaluation: missing project_id',
      );
    }
    if (json['slug'] == null) {
      throw const FormatException('ObservabilityEvaluation: missing slug');
    }
    if (json['tags'] == null) {
      throw const FormatException('ObservabilityEvaluation: missing tags');
    }
    if (json['updated_at'] == null) {
      throw const FormatException(
        'ObservabilityEvaluation: missing updated_at',
      );
    }
    if (json['workspace_id'] == null) {
      throw const FormatException(
        'ObservabilityEvaluation: missing workspace_id',
      );
    }
    return ObservabilityEvaluation(
      createdAt: DateTime.parse(json['created_at'] as String),
      creatorId: json['creator_id'] as String,
      creatorType: json['creator_type'] == null
          ? null
          : PrincipalType.fromJson(json['creator_type'] as String?),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      id: json['id'] as String,
      isFavorite: json['is_favorite'] == null
          ? null
          : json['is_favorite'] as bool,
      metadata: json['metadata_'] as Map<String, Object?>,
      name: json['name'] as String,
      projectId: json['project_id'] as String,
      slug: json['slug'] as String,
      tags: (json['tags'] as List<Object?>)
          .map((item) => item! as String)
          .toList(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      workspaceId: json['workspace_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'creator_id': creatorId,
    if (creatorType != null) 'creator_type': creatorType!.value,
    'deleted_at': deletedAt?.toIso8601String(),
    'description': description,
    'id': id,
    'is_favorite': ?isFavorite,
    'metadata_': metadata,
    'name': name,
    'project_id': projectId,
    'slug': slug,
    'tags': tags,
    'updated_at': updatedAt.toIso8601String(),
    'workspace_id': workspaceId,
  };

  /// Creates a copy with the given fields replaced.
  ObservabilityEvaluation copyWith({
    DateTime? createdAt,
    String? creatorId,
    Object? creatorType = unsetCopyWithValue,
    Object? deletedAt = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    String? id,
    Object? isFavorite = unsetCopyWithValue,
    Map<String, Object?>? metadata,
    String? name,
    String? projectId,
    String? slug,
    List<String>? tags,
    DateTime? updatedAt,
    String? workspaceId,
  }) => ObservabilityEvaluation(
    createdAt: createdAt ?? this.createdAt,
    creatorId: creatorId ?? this.creatorId,
    creatorType: creatorType == unsetCopyWithValue
        ? this.creatorType
        : creatorType as PrincipalType?,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    id: id ?? this.id,
    isFavorite: isFavorite == unsetCopyWithValue
        ? this.isFavorite
        : isFavorite as bool?,
    metadata: metadata ?? this.metadata,
    name: name ?? this.name,
    projectId: projectId ?? this.projectId,
    slug: slug ?? this.slug,
    tags: tags ?? this.tags,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservabilityEvaluation &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          creatorId == other.creatorId &&
          creatorType == other.creatorType &&
          deletedAt == other.deletedAt &&
          description == other.description &&
          id == other.id &&
          isFavorite == other.isFavorite &&
          valuesDeepEqual(metadata, other.metadata) &&
          name == other.name &&
          projectId == other.projectId &&
          slug == other.slug &&
          valuesDeepEqual(tags, other.tags) &&
          updatedAt == other.updatedAt &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    creatorId,
    creatorType,
    deletedAt,
    description,
    id,
    isFavorite,
    valueDeepHashCode(metadata),
    name,
    projectId,
    slug,
    valueDeepHashCode(tags),
    updatedAt,
    workspaceId,
  ]);

  @override
  String toString() =>
      'ObservabilityEvaluation('
      'createdAt: $createdAt, '
      'creatorId: $creatorId, '
      'creatorType: $creatorType, '
      'deletedAt: $deletedAt, '
      'description: $description, '
      'id: $id, '
      'isFavorite: $isFavorite, '
      'metadata: ${metadata.length}, '
      'name: $name, '
      'projectId: $projectId, '
      'slug: $slug, '
      'tags: ${tags.length}, '
      'updatedAt: $updatedAt, '
      'workspaceId: $workspaceId)';
}

/// The EvaluationsV2 wire payload.
@immutable
class ObservabilityEvaluations {
  /// Creates a [ObservabilityEvaluations].
  const ObservabilityEvaluations({required this.evaluations});

  /// The evaluations field.
  final PaginatedResult<ObservabilityEvaluation> evaluations;

  /// Parses a [ObservabilityEvaluations] from JSON.
  factory ObservabilityEvaluations.fromJson(Map<String, dynamic> json) {
    if (json['evaluations'] == null) {
      throw const FormatException(
        'ObservabilityEvaluations: missing evaluations',
      );
    }
    return ObservabilityEvaluations(
      evaluations: PaginatedResult<ObservabilityEvaluation>.fromJson(
        json['evaluations'] as Map<String, dynamic>,
        ObservabilityEvaluation.fromJson,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'evaluations': evaluations.toJson((item) => item.toJson()),
  };

  /// Creates a copy with the given fields replaced.
  ObservabilityEvaluations copyWith({
    PaginatedResult<ObservabilityEvaluation>? evaluations,
  }) => ObservabilityEvaluations(evaluations: evaluations ?? this.evaluations);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservabilityEvaluations &&
          runtimeType == other.runtimeType &&
          evaluations == other.evaluations;

  @override
  int get hashCode => Object.hashAll([evaluations]);

  @override
  String toString() =>
      'ObservabilityEvaluations('
      'evaluations: $evaluations)';
}

/// The Project wire payload.
@immutable
class EvaluationProject {
  /// Creates a [EvaluationProject].
  const EvaluationProject({
    required this.createdAt,
    required this.creatorId,
    this.creatorType,
    required this.deletedAt,
    required this.description,
    this.evaluations,
    required this.id,
    this.isFavorite,
    required this.name,
    required this.slug,
    required this.updatedAt,
    required this.workspaceId,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The creator_id field.
  final String creatorId;

  /// The creator_type field.
  final PrincipalType? creatorType;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The description field.
  final String? description;

  /// The evaluations field.
  final List<ProjectEvaluationSummary>? evaluations;

  /// The id field.
  final String id;

  /// The is_favorite field.
  final bool? isFavorite;

  /// The name field.
  final String name;

  /// The slug field.
  final String slug;

  /// The updated_at field.
  final DateTime updatedAt;

  /// The workspace_id field.
  final String workspaceId;

  /// Parses a [EvaluationProject] from JSON.
  factory EvaluationProject.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('EvaluationProject: missing created_at');
    }
    if (json['creator_id'] == null) {
      throw const FormatException('EvaluationProject: missing creator_id');
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException('EvaluationProject: missing deleted_at');
    }
    if (!json.containsKey('description')) {
      throw const FormatException('EvaluationProject: missing description');
    }
    if (json['id'] == null) {
      throw const FormatException('EvaluationProject: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('EvaluationProject: missing name');
    }
    if (json['slug'] == null) {
      throw const FormatException('EvaluationProject: missing slug');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('EvaluationProject: missing updated_at');
    }
    if (json['workspace_id'] == null) {
      throw const FormatException('EvaluationProject: missing workspace_id');
    }
    return EvaluationProject(
      createdAt: DateTime.parse(json['created_at'] as String),
      creatorId: json['creator_id'] as String,
      creatorType: json['creator_type'] == null
          ? null
          : PrincipalType.fromJson(json['creator_type'] as String?),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      evaluations: json['evaluations'] == null
          ? null
          : (json['evaluations'] as List<Object?>)
                .map(
                  (item) => ProjectEvaluationSummary.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
      id: json['id'] as String,
      isFavorite: json['is_favorite'] == null
          ? null
          : json['is_favorite'] as bool,
      name: json['name'] as String,
      slug: json['slug'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      workspaceId: json['workspace_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'creator_id': creatorId,
    if (creatorType != null) 'creator_type': creatorType!.value,
    'deleted_at': deletedAt?.toIso8601String(),
    'description': description,
    if (evaluations != null)
      'evaluations': evaluations!.map((item) => item.toJson()).toList(),
    'id': id,
    'is_favorite': ?isFavorite,
    'name': name,
    'slug': slug,
    'updated_at': updatedAt.toIso8601String(),
    'workspace_id': workspaceId,
  };

  /// Creates a copy with the given fields replaced.
  EvaluationProject copyWith({
    DateTime? createdAt,
    String? creatorId,
    Object? creatorType = unsetCopyWithValue,
    Object? deletedAt = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? evaluations = unsetCopyWithValue,
    String? id,
    Object? isFavorite = unsetCopyWithValue,
    String? name,
    String? slug,
    DateTime? updatedAt,
    String? workspaceId,
  }) => EvaluationProject(
    createdAt: createdAt ?? this.createdAt,
    creatorId: creatorId ?? this.creatorId,
    creatorType: creatorType == unsetCopyWithValue
        ? this.creatorType
        : creatorType as PrincipalType?,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    evaluations: evaluations == unsetCopyWithValue
        ? this.evaluations
        : (evaluations as List<Object?>?)?.cast<ProjectEvaluationSummary>(),
    id: id ?? this.id,
    isFavorite: isFavorite == unsetCopyWithValue
        ? this.isFavorite
        : isFavorite as bool?,
    name: name ?? this.name,
    slug: slug ?? this.slug,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationProject &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          creatorId == other.creatorId &&
          creatorType == other.creatorType &&
          deletedAt == other.deletedAt &&
          description == other.description &&
          valuesDeepEqual(evaluations, other.evaluations) &&
          id == other.id &&
          isFavorite == other.isFavorite &&
          name == other.name &&
          slug == other.slug &&
          updatedAt == other.updatedAt &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    creatorId,
    creatorType,
    deletedAt,
    description,
    valueDeepHashCode(evaluations),
    id,
    isFavorite,
    name,
    slug,
    updatedAt,
    workspaceId,
  ]);

  @override
  String toString() =>
      'EvaluationProject('
      'createdAt: $createdAt, '
      'creatorId: $creatorId, '
      'creatorType: $creatorType, '
      'deletedAt: $deletedAt, '
      'description: $description, '
      'evaluations: ${evaluations?.length}, '
      'id: $id, '
      'isFavorite: $isFavorite, '
      'name: $name, '
      'slug: $slug, '
      'updatedAt: $updatedAt, '
      'workspaceId: $workspaceId)';
}

/// A lightweight evaluation reference embedded in the projects listing, so the client can render a project's evaluations without firing one request per project.
@immutable
class ProjectEvaluationSummary {
  /// Creates a [ProjectEvaluationSummary].
  const ProjectEvaluationSummary({
    required this.id,
    required this.name,
    required this.slug,
  });

  /// The id field.
  final String id;

  /// The name field.
  final String name;

  /// The slug field.
  final String slug;

  /// Parses a [ProjectEvaluationSummary] from JSON.
  factory ProjectEvaluationSummary.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw const FormatException('ProjectEvaluationSummary: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('ProjectEvaluationSummary: missing name');
    }
    if (json['slug'] == null) {
      throw const FormatException('ProjectEvaluationSummary: missing slug');
    }
    return ProjectEvaluationSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};

  /// Creates a copy with the given fields replaced.
  ProjectEvaluationSummary copyWith({String? id, String? name, String? slug}) =>
      ProjectEvaluationSummary(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectEvaluationSummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          slug == other.slug;

  @override
  int get hashCode => Object.hashAll([id, name, slug]);

  @override
  String toString() =>
      'ProjectEvaluationSummary('
      'id: $id, '
      'name: $name, '
      'slug: $slug)';
}

/// The Projects wire payload.
@immutable
class EvaluationProjects {
  /// Creates a [EvaluationProjects].
  const EvaluationProjects({required this.projects});

  /// The projects field.
  final PaginatedResult<EvaluationProject> projects;

  /// Parses a [EvaluationProjects] from JSON.
  factory EvaluationProjects.fromJson(Map<String, dynamic> json) {
    if (json['projects'] == null) {
      throw const FormatException('EvaluationProjects: missing projects');
    }
    return EvaluationProjects(
      projects: PaginatedResult<EvaluationProject>.fromJson(
        json['projects'] as Map<String, dynamic>,
        EvaluationProject.fromJson,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'projects': projects.toJson((item) => item.toJson()),
  };

  /// Creates a copy with the given fields replaced.
  EvaluationProjects copyWith({PaginatedResult<EvaluationProject>? projects}) =>
      EvaluationProjects(projects: projects ?? this.projects);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationProjects &&
          runtimeType == other.runtimeType &&
          projects == other.projects;

  @override
  int get hashCode => Object.hashAll([projects]);

  @override
  String toString() =>
      'EvaluationProjects('
      'projects: $projects)';
}
