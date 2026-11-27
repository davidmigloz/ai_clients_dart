import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../workflows/principal_type.dart';
import 'paginated_result.dart';

/// The CreateScorerRequest wire payload.
@immutable
class CreateScorerRequest {
  /// Creates a [CreateScorerRequest].
  const CreateScorerRequest({
    required this.config,
    this.description,
    required this.kind,
    required this.name,
  });

  /// The config field.
  final LlmJudgeConfig config;

  /// The description field.
  final String? description;

  /// The kind field.
  final ScorerKind kind;

  /// The name field.
  final String name;

  /// Parses a [CreateScorerRequest] from JSON.
  factory CreateScorerRequest.fromJson(Map<String, dynamic> json) {
    if (json['config'] == null) {
      throw const FormatException('CreateScorerRequest: missing config');
    }
    if (json['kind'] == null) {
      throw const FormatException('CreateScorerRequest: missing kind');
    }
    if (json['name'] == null) {
      throw const FormatException('CreateScorerRequest: missing name');
    }
    return CreateScorerRequest(
      config: LlmJudgeConfig.fromJson(json['config'] as Map<String, dynamic>),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      kind: ScorerKind.fromJson(json['kind'] as String),
      name: json['name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'config': config.toJson(),
    'description': ?description,
    'kind': kind.toJson(),
    'name': name,
  };

  /// Creates a copy with the given fields replaced.
  CreateScorerRequest copyWith({
    LlmJudgeConfig? config,
    Object? description = unsetCopyWithValue,
    ScorerKind? kind,
    String? name,
  }) => CreateScorerRequest(
    config: config ?? this.config,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    kind: kind ?? this.kind,
    name: name ?? this.name,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateScorerRequest &&
          runtimeType == other.runtimeType &&
          config == other.config &&
          description == other.description &&
          kind == other.kind &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([config, description, kind, name]);

  @override
  String toString() =>
      'CreateScorerRequest('
      'config: $config, '
      'description: $description, '
      'kind: $kind, '
      'name: $name)';
}

/// The EditScorerRequest wire payload.
@immutable
class EditScorerRequest {
  /// Creates a [EditScorerRequest].
  const EditScorerRequest({
    this.config,
    this._description = unsetCopyWithValue,
    this.name,
  });

  /// The config field.
  final LlmJudgeConfig? config;

  /// The description field.
  final Object? _description;

  /// The optional description. Passing null replaces an existing value.
  String? get description =>
      _description == unsetCopyWithValue ? null : _description as String?;

  /// The name field.
  final String? name;

  /// Parses a [EditScorerRequest] from JSON.
  factory EditScorerRequest.fromJson(Map<String, dynamic> json) {
    return EditScorerRequest(
      config: json['config'] == null
          ? null
          : LlmJudgeConfig.fromJson(json['config'] as Map<String, dynamic>),
      description: json.containsKey('description')
          ? json['description']
          : unsetCopyWithValue,
      name: json['name'] == null ? null : json['name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (config != null) 'config': config!.toJson(),
    if (_description != unsetCopyWithValue) 'description': description,
    'name': ?name,
  };

  /// Creates a copy with the given fields replaced.
  EditScorerRequest copyWith({
    Object? config = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
  }) => EditScorerRequest(
    config: config == unsetCopyWithValue
        ? this.config
        : config as LlmJudgeConfig?,
    description: description == unsetCopyWithValue ? _description : description,
    name: name == unsetCopyWithValue ? this.name : name as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditScorerRequest &&
          runtimeType == other.runtimeType &&
          config == other.config &&
          _description == other._description &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([config, _description, name]);

  @override
  String toString() =>
      'EditScorerRequest('
      'config: $config, '
      'description: $description, '
      'name: $name)';
}

/// A scorer result with two possible values.
@immutable
final class EvaluationBooleanResultSpec extends EvaluationResultSpec {
  /// Creates a boolean result specification.
  const EvaluationBooleanResultSpec();

  /// The wire discriminator.
  String get type => 'boolean';

  /// Creates a boolean scorer result specification.
  factory EvaluationBooleanResultSpec.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'boolean') {
      throw FormatException(
        'Expected boolean result specification, got $value',
      );
    }
    return const EvaluationBooleanResultSpec();
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) => other is EvaluationBooleanResultSpec;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'EvaluationBooleanResultSpec()';
}

/// The EvaluationCategoricalResultSpec wire payload.
@immutable
final class EvaluationCategoricalResultSpec extends EvaluationResultSpec {
  /// Creates a [EvaluationCategoricalResultSpec].
  const EvaluationCategoricalResultSpec({required this.labels});

  /// The fixed type discriminator.
  String get type => 'categorical';

  /// The labels field.
  final List<String> labels;

  /// Parses a [EvaluationCategoricalResultSpec] from JSON.
  factory EvaluationCategoricalResultSpec.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'categorical') {
      throw FormatException(
        'EvaluationCategoricalResultSpec: unexpected type $value',
      );
    }
    if (json['labels'] == null) {
      throw const FormatException(
        'EvaluationCategoricalResultSpec: missing labels',
      );
    }
    return EvaluationCategoricalResultSpec(
      labels: (json['labels'] as List<Object?>)
          .map((item) => item! as String)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'labels': labels};

  /// Creates a copy with the given fields replaced.
  EvaluationCategoricalResultSpec copyWith({List<String>? labels}) =>
      EvaluationCategoricalResultSpec(labels: labels ?? this.labels);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationCategoricalResultSpec &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(labels, other.labels);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(labels)]);

  @override
  String toString() =>
      'EvaluationCategoricalResultSpec('
      'labels: ${labels.length})';
}

/// The EvaluationNumericResultSpec wire payload.
@immutable
final class EvaluationNumericResultSpec extends EvaluationResultSpec {
  /// Creates a [EvaluationNumericResultSpec].
  const EvaluationNumericResultSpec({required this.max, required this.min});

  /// The fixed type discriminator.
  String get type => 'numeric';

  /// The max field.
  final double max;

  /// The min field.
  final double min;

  /// Parses a [EvaluationNumericResultSpec] from JSON.
  factory EvaluationNumericResultSpec.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'numeric') {
      throw FormatException(
        'EvaluationNumericResultSpec: unexpected type $value',
      );
    }
    if (json['max'] == null) {
      throw const FormatException('EvaluationNumericResultSpec: missing max');
    }
    if (json['min'] == null) {
      throw const FormatException('EvaluationNumericResultSpec: missing min');
    }
    return EvaluationNumericResultSpec(
      max: (json['max'] as num).toDouble(),
      min: (json['min'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'max': max, 'min': min};

  /// Creates a copy with the given fields replaced.
  EvaluationNumericResultSpec copyWith({double? max, double? min}) =>
      EvaluationNumericResultSpec(max: max ?? this.max, min: min ?? this.min);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationNumericResultSpec &&
          runtimeType == other.runtimeType &&
          max == other.max &&
          min == other.min;

  @override
  int get hashCode => Object.hashAll([max, min]);

  @override
  String toString() =>
      'EvaluationNumericResultSpec('
      'max: $max, '
      'min: $min)';
}

/// A variant of [EvaluationResultSpec] returned or accepted by Observability.
sealed class EvaluationResultSpec {
  const EvaluationResultSpec();

  /// Decodes a variant from its API representation.
  factory EvaluationResultSpec.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'boolean' => EvaluationBooleanResultSpec.fromJson(json),
        'categorical' => EvaluationCategoricalResultSpec.fromJson(json),
        'numeric' => EvaluationNumericResultSpec.fromJson(json),
        _ => UnknownEvaluationResultSpec(json),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A server variant of [EvaluationResultSpec] unknown to this client.
@immutable
final class UnknownEvaluationResultSpec extends EvaluationResultSpec {
  /// Retains the original payload.
  UnknownEvaluationResultSpec(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The unrecognized payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownEvaluationResultSpec && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// The ListScorersResponse wire payload.
@immutable
class ListScorersResponse {
  /// Creates a [ListScorersResponse].
  const ListScorersResponse({required this.scorers});

  /// The scorers field.
  final PaginatedResult<ScorerSummary> scorers;

  /// Parses a [ListScorersResponse] from JSON.
  factory ListScorersResponse.fromJson(Map<String, dynamic> json) {
    if (json['scorers'] == null) {
      throw const FormatException('ListScorersResponse: missing scorers');
    }
    return ListScorersResponse(
      scorers: PaginatedResult<ScorerSummary>.fromJson(
        json['scorers'] as Map<String, dynamic>,
        ScorerSummary.fromJson,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'scorers': scorers.toJson((item) => item.toJson()),
  };

  /// Creates a copy with the given fields replaced.
  ListScorersResponse copyWith({PaginatedResult<ScorerSummary>? scorers}) =>
      ListScorersResponse(scorers: scorers ?? this.scorers);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListScorersResponse &&
          runtimeType == other.runtimeType &&
          scorers == other.scorers;

  @override
  int get hashCode => Object.hashAll([scorers]);

  @override
  String toString() =>
      'ListScorersResponse('
      'scorers: $scorers)';
}

/// The LlmJudgeConfig wire payload.
@immutable
class LlmJudgeConfig {
  /// Creates a [LlmJudgeConfig].
  const LlmJudgeConfig({
    required this.model,
    required this.outputSpec,
    this.params,
    required this.promptTemplate,
  });

  /// The model field.
  final String model;

  /// The output_spec field.
  final EvaluationResultSpec outputSpec;

  /// The params field.
  final LlmJudgeParams? params;

  /// The prompt_template field.
  final String promptTemplate;

  /// Parses a [LlmJudgeConfig] from JSON.
  factory LlmJudgeConfig.fromJson(Map<String, dynamic> json) {
    if (json['model'] == null) {
      throw const FormatException('LlmJudgeConfig: missing model');
    }
    if (json['output_spec'] == null) {
      throw const FormatException('LlmJudgeConfig: missing output_spec');
    }
    if (json['prompt_template'] == null) {
      throw const FormatException('LlmJudgeConfig: missing prompt_template');
    }
    return LlmJudgeConfig(
      model: json['model'] as String,
      outputSpec: EvaluationResultSpec.fromJson(
        json['output_spec'] as Map<String, dynamic>,
      ),
      params: json['params'] == null
          ? null
          : LlmJudgeParams.fromJson(json['params'] as Map<String, dynamic>),
      promptTemplate: json['prompt_template'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'model': model,
    'output_spec': outputSpec.toJson(),
    if (params != null) 'params': params!.toJson(),
    'prompt_template': promptTemplate,
  };

  /// Creates a copy with the given fields replaced.
  LlmJudgeConfig copyWith({
    String? model,
    EvaluationResultSpec? outputSpec,
    Object? params = unsetCopyWithValue,
    String? promptTemplate,
  }) => LlmJudgeConfig(
    model: model ?? this.model,
    outputSpec: outputSpec ?? this.outputSpec,
    params: params == unsetCopyWithValue
        ? this.params
        : params as LlmJudgeParams?,
    promptTemplate: promptTemplate ?? this.promptTemplate,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LlmJudgeConfig &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          outputSpec == other.outputSpec &&
          params == other.params &&
          promptTemplate == other.promptTemplate;

  @override
  int get hashCode =>
      Object.hashAll([model, outputSpec, params, promptTemplate]);

  @override
  String toString() =>
      'LlmJudgeConfig('
      'model: $model, '
      'outputSpec: $outputSpec, '
      'params: $params, '
      'promptTemplate: $promptTemplate)';
}

/// The LlmJudgeParams wire payload.
@immutable
class LlmJudgeParams {
  /// Creates a [LlmJudgeParams].
  const LlmJudgeParams({
    this.maxTokens,
    this.randomSeed,
    this.temperature,
    this.topP,
  });

  /// The max_tokens field.
  final int? maxTokens;

  /// The random_seed field.
  final int? randomSeed;

  /// The temperature field.
  final double? temperature;

  /// The top_p field.
  final double? topP;

  /// Parses a [LlmJudgeParams] from JSON.
  factory LlmJudgeParams.fromJson(Map<String, dynamic> json) {
    return LlmJudgeParams(
      maxTokens: json['max_tokens'] == null ? null : json['max_tokens'] as int,
      randomSeed: json['random_seed'] == null
          ? null
          : json['random_seed'] as int,
      temperature: json['temperature'] == null
          ? null
          : (json['temperature'] as num).toDouble(),
      topP: json['top_p'] == null ? null : (json['top_p'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'max_tokens': ?maxTokens,
    'random_seed': ?randomSeed,
    'temperature': ?temperature,
    'top_p': ?topP,
  };

  /// Creates a copy with the given fields replaced.
  LlmJudgeParams copyWith({
    Object? maxTokens = unsetCopyWithValue,
    Object? randomSeed = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
  }) => LlmJudgeParams(
    maxTokens: maxTokens == unsetCopyWithValue
        ? this.maxTokens
        : maxTokens as int?,
    randomSeed: randomSeed == unsetCopyWithValue
        ? this.randomSeed
        : randomSeed as int?,
    temperature: temperature == unsetCopyWithValue
        ? this.temperature
        : (temperature as num?)?.toDouble(),
    topP: topP == unsetCopyWithValue ? this.topP : (topP as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LlmJudgeParams &&
          runtimeType == other.runtimeType &&
          maxTokens == other.maxTokens &&
          randomSeed == other.randomSeed &&
          temperature == other.temperature &&
          topP == other.topP;

  @override
  int get hashCode =>
      Object.hashAll([maxTokens, randomSeed, temperature, topP]);

  @override
  String toString() =>
      'LlmJudgeParams('
      'maxTokens: $maxTokens, '
      'randomSeed: $randomSeed, '
      'temperature: $temperature, '
      'topP: $topP)';
}

/// The Scorer wire payload.
@immutable
class Scorer {
  /// Creates a [Scorer].
  const Scorer({
    required this.createdAt,
    required this.description,
    required this.kind,
    required this.latestVersion,
    required this.name,
    required this.slug,
    required this.updatedAt,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The description field.
  final String? description;

  /// The kind field.
  final ScorerKind kind;

  /// The latest_version field.
  final ScorerVersion latestVersion;

  /// The name field.
  final String name;

  /// The slug field.
  final String slug;

  /// The updated_at field.
  final DateTime updatedAt;

  /// Parses a [Scorer] from JSON.
  factory Scorer.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('Scorer: missing created_at');
    }
    if (!json.containsKey('description')) {
      throw const FormatException('Scorer: missing description');
    }
    if (json['kind'] == null) {
      throw const FormatException('Scorer: missing kind');
    }
    if (json['latest_version'] == null) {
      throw const FormatException('Scorer: missing latest_version');
    }
    if (json['name'] == null) {
      throw const FormatException('Scorer: missing name');
    }
    if (json['slug'] == null) {
      throw const FormatException('Scorer: missing slug');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('Scorer: missing updated_at');
    }
    return Scorer(
      createdAt: DateTime.parse(json['created_at'] as String),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      kind: ScorerKind.fromJson(json['kind'] as String),
      latestVersion: ScorerVersion.fromJson(
        json['latest_version'] as Map<String, dynamic>,
      ),
      name: json['name'] as String,
      slug: json['slug'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'description': description,
    'kind': kind.toJson(),
    'latest_version': latestVersion.toJson(),
    'name': name,
    'slug': slug,
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  Scorer copyWith({
    DateTime? createdAt,
    Object? description = unsetCopyWithValue,
    ScorerKind? kind,
    ScorerVersion? latestVersion,
    String? name,
    String? slug,
    DateTime? updatedAt,
  }) => Scorer(
    createdAt: createdAt ?? this.createdAt,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    kind: kind ?? this.kind,
    latestVersion: latestVersion ?? this.latestVersion,
    name: name ?? this.name,
    slug: slug ?? this.slug,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Scorer &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          description == other.description &&
          kind == other.kind &&
          latestVersion == other.latestVersion &&
          name == other.name &&
          slug == other.slug &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    description,
    kind,
    latestVersion,
    name,
    slug,
    updatedAt,
  ]);

  @override
  String toString() =>
      'Scorer('
      'createdAt: $createdAt, '
      'description: $description, '
      'kind: $kind, '
      'latestVersion: $latestVersion, '
      'name: $name, '
      'slug: $slug, '
      'updatedAt: $updatedAt)';
}

/// Values for ScorerKind.
enum ScorerKind {
  /// Represents llm_judge.
  llmJudge('llm_judge'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const ScorerKind(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static ScorerKind fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The ScorerSummary wire payload.
@immutable
class ScorerSummary {
  /// Creates a [ScorerSummary].
  const ScorerSummary({
    required this.createdAt,
    required this.creatorId,
    this.creatorType,
    required this.description,
    required this.isOotb,
    required this.kind,
    required this.name,
    required this.slug,
    required this.updatedAt,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The creator_id field.
  final String creatorId;

  /// The creator_type field.
  final PrincipalType? creatorType;

  /// The description field.
  final String? description;

  /// The is_ootb field.
  final bool isOotb;

  /// The kind field.
  final ScorerKind kind;

  /// The name field.
  final String name;

  /// The slug field.
  final String slug;

  /// The updated_at field.
  final DateTime updatedAt;

  /// Parses a [ScorerSummary] from JSON.
  factory ScorerSummary.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('ScorerSummary: missing created_at');
    }
    if (json['creator_id'] == null) {
      throw const FormatException('ScorerSummary: missing creator_id');
    }
    if (!json.containsKey('description')) {
      throw const FormatException('ScorerSummary: missing description');
    }
    if (json['is_ootb'] == null) {
      throw const FormatException('ScorerSummary: missing is_ootb');
    }
    if (json['kind'] == null) {
      throw const FormatException('ScorerSummary: missing kind');
    }
    if (json['name'] == null) {
      throw const FormatException('ScorerSummary: missing name');
    }
    if (json['slug'] == null) {
      throw const FormatException('ScorerSummary: missing slug');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('ScorerSummary: missing updated_at');
    }
    return ScorerSummary(
      createdAt: DateTime.parse(json['created_at'] as String),
      creatorId: json['creator_id'] as String,
      creatorType: json['creator_type'] == null
          ? null
          : PrincipalType.fromJson(json['creator_type'] as String?),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      isOotb: json['is_ootb'] as bool,
      kind: ScorerKind.fromJson(json['kind'] as String),
      name: json['name'] as String,
      slug: json['slug'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'creator_id': creatorId,
    if (creatorType != null) 'creator_type': creatorType!.value,
    'description': description,
    'is_ootb': isOotb,
    'kind': kind.toJson(),
    'name': name,
    'slug': slug,
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  ScorerSummary copyWith({
    DateTime? createdAt,
    String? creatorId,
    Object? creatorType = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    bool? isOotb,
    ScorerKind? kind,
    String? name,
    String? slug,
    DateTime? updatedAt,
  }) => ScorerSummary(
    createdAt: createdAt ?? this.createdAt,
    creatorId: creatorId ?? this.creatorId,
    creatorType: creatorType == unsetCopyWithValue
        ? this.creatorType
        : creatorType as PrincipalType?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    isOotb: isOotb ?? this.isOotb,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    slug: slug ?? this.slug,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScorerSummary &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          creatorId == other.creatorId &&
          creatorType == other.creatorType &&
          description == other.description &&
          isOotb == other.isOotb &&
          kind == other.kind &&
          name == other.name &&
          slug == other.slug &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    creatorId,
    creatorType,
    description,
    isOotb,
    kind,
    name,
    slug,
    updatedAt,
  ]);

  @override
  String toString() =>
      'ScorerSummary('
      'createdAt: $createdAt, '
      'creatorId: $creatorId, '
      'creatorType: $creatorType, '
      'description: $description, '
      'isOotb: $isOotb, '
      'kind: $kind, '
      'name: $name, '
      'slug: $slug, '
      'updatedAt: $updatedAt)';
}

/// The ScorerVersion wire payload.
@immutable
class ScorerVersion {
  /// Creates a [ScorerVersion].
  const ScorerVersion({
    required this.config,
    required this.createdAt,
    required this.creatorId,
    this.creatorType,
    required this.variables,
    required this.version,
  });

  /// The config field.
  final LlmJudgeConfig config;

  /// The created_at field.
  final DateTime createdAt;

  /// The creator_id field.
  final String creatorId;

  /// The creator_type field.
  final PrincipalType? creatorType;

  /// The variables field.
  final List<String> variables;

  /// The version field.
  final int version;

  /// Parses a [ScorerVersion] from JSON.
  factory ScorerVersion.fromJson(Map<String, dynamic> json) {
    if (json['config'] == null) {
      throw const FormatException('ScorerVersion: missing config');
    }
    if (json['created_at'] == null) {
      throw const FormatException('ScorerVersion: missing created_at');
    }
    if (json['creator_id'] == null) {
      throw const FormatException('ScorerVersion: missing creator_id');
    }
    if (json['variables'] == null) {
      throw const FormatException('ScorerVersion: missing variables');
    }
    if (json['version'] == null) {
      throw const FormatException('ScorerVersion: missing version');
    }
    return ScorerVersion(
      config: LlmJudgeConfig.fromJson(json['config'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      creatorId: json['creator_id'] as String,
      creatorType: json['creator_type'] == null
          ? null
          : PrincipalType.fromJson(json['creator_type'] as String?),
      variables: (json['variables'] as List<Object?>)
          .map((item) => item! as String)
          .toList(),
      version: json['version'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'config': config.toJson(),
    'created_at': createdAt.toIso8601String(),
    'creator_id': creatorId,
    if (creatorType != null) 'creator_type': creatorType!.value,
    'variables': variables,
    'version': version,
  };

  /// Creates a copy with the given fields replaced.
  ScorerVersion copyWith({
    LlmJudgeConfig? config,
    DateTime? createdAt,
    String? creatorId,
    Object? creatorType = unsetCopyWithValue,
    List<String>? variables,
    int? version,
  }) => ScorerVersion(
    config: config ?? this.config,
    createdAt: createdAt ?? this.createdAt,
    creatorId: creatorId ?? this.creatorId,
    creatorType: creatorType == unsetCopyWithValue
        ? this.creatorType
        : creatorType as PrincipalType?,
    variables: variables ?? this.variables,
    version: version ?? this.version,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScorerVersion &&
          runtimeType == other.runtimeType &&
          config == other.config &&
          createdAt == other.createdAt &&
          creatorId == other.creatorId &&
          creatorType == other.creatorType &&
          valuesDeepEqual(variables, other.variables) &&
          version == other.version;

  @override
  int get hashCode => Object.hashAll([
    config,
    createdAt,
    creatorId,
    creatorType,
    valueDeepHashCode(variables),
    version,
  ]);

  @override
  String toString() =>
      'ScorerVersion('
      'config: $config, '
      'createdAt: $createdAt, '
      'creatorId: $creatorId, '
      'creatorType: $creatorType, '
      'variables: ${variables.length}, '
      'version: $version)';
}
