import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'feed_result.dart';
import 'online_scorers.dart';
import 'paginated_result.dart';
import 'telemetry_aggregation.dart';

/// The AttributeHashSampling wire payload.
@immutable
final class AttributeHashSampling extends PipelineConfigSampling {
  /// Creates a [AttributeHashSampling].
  const AttributeHashSampling({
    required this.attribute,
    required this.percentage,
  });

  /// The fixed type discriminator.
  String get type => 'attribute_hash';

  /// The attribute field.
  final String attribute;

  /// The percentage field.
  final double percentage;

  /// Parses a [AttributeHashSampling] from JSON.
  factory AttributeHashSampling.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'attribute_hash') {
      throw FormatException('AttributeHashSampling: unexpected type $value');
    }
    if (json['attribute'] == null) {
      throw const FormatException('AttributeHashSampling: missing attribute');
    }
    if (json['percentage'] == null) {
      throw const FormatException('AttributeHashSampling: missing percentage');
    }
    return AttributeHashSampling(
      attribute: json['attribute'] as String,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'attribute': attribute,
    'percentage': percentage,
  };

  /// Creates a copy with the given fields replaced.
  AttributeHashSampling copyWith({String? attribute, double? percentage}) =>
      AttributeHashSampling(
        attribute: attribute ?? this.attribute,
        percentage: percentage ?? this.percentage,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttributeHashSampling &&
          runtimeType == other.runtimeType &&
          attribute == other.attribute &&
          percentage == other.percentage;

  @override
  int get hashCode => Object.hashAll([attribute, percentage]);

  @override
  String toString() =>
      'AttributeHashSampling('
      'attribute: $attribute, '
      'percentage: $percentage)';
}

/// The CreatePipelineRequest wire payload.
@immutable
class CreatePipelineRequest {
  /// Creates a [CreatePipelineRequest].
  const CreatePipelineRequest({
    required this.definitions,
    this.description,
    this.enabled,
    required this.name,
    required this.selectors,
  });

  /// The definitions field.
  final List<LlmJudgeReference> definitions;

  /// The description field.
  final String? description;

  /// The enabled field.
  final bool? enabled;

  /// The name field.
  final String name;

  /// The selectors field.
  final List<PipelineConfigSelector> selectors;

  /// Parses a [CreatePipelineRequest] from JSON.
  factory CreatePipelineRequest.fromJson(Map<String, dynamic> json) {
    if (json['definitions'] == null) {
      throw const FormatException('CreatePipelineRequest: missing definitions');
    }
    if (json['name'] == null) {
      throw const FormatException('CreatePipelineRequest: missing name');
    }
    if (json['selectors'] == null) {
      throw const FormatException('CreatePipelineRequest: missing selectors');
    }
    return CreatePipelineRequest(
      definitions: (json['definitions'] as List<Object?>)
          .map(
            (item) => LlmJudgeReference.fromJson(item! as Map<String, dynamic>),
          )
          .toList(),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      enabled: json['enabled'] == null ? null : json['enabled'] as bool,
      name: json['name'] as String,
      selectors: (json['selectors'] as List<Object?>)
          .map(
            (item) =>
                PipelineConfigSelector.fromJson(item! as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'definitions': definitions.map((item) => item.toJson()).toList(),
    'description': ?description,
    'enabled': ?enabled,
    'name': name,
    'selectors': selectors.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  CreatePipelineRequest copyWith({
    List<LlmJudgeReference>? definitions,
    Object? description = unsetCopyWithValue,
    Object? enabled = unsetCopyWithValue,
    String? name,
    List<PipelineConfigSelector>? selectors,
  }) => CreatePipelineRequest(
    definitions: definitions ?? this.definitions,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
    name: name ?? this.name,
    selectors: selectors ?? this.selectors,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatePipelineRequest &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(definitions, other.definitions) &&
          description == other.description &&
          enabled == other.enabled &&
          name == other.name &&
          valuesDeepEqual(selectors, other.selectors);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(definitions),
    description,
    enabled,
    name,
    valueDeepHashCode(selectors),
  ]);

  @override
  String toString() =>
      'CreatePipelineRequest('
      'definitions: ${definitions.length}, '
      'description: $description, '
      'enabled: $enabled, '
      'name: $name, '
      'selectors: ${selectors.length})';
}

/// The DetectionDefinitionV1 wire payload.
@immutable
final class DetectionDefinitionV1 extends PipelineConfigDefinition {
  /// Creates a [DetectionDefinitionV1].
  const DetectionDefinitionV1({
    required this.patterns,
    required this.targetAttributes,
  });

  /// The patterns field.
  final List<DetectionPattern> patterns;

  /// The target_attributes field.
  final List<String> targetAttributes;

  /// Parses a [DetectionDefinitionV1] from JSON.
  factory DetectionDefinitionV1.fromJson(Map<String, dynamic> json) {
    if (json['patterns'] == null) {
      throw const FormatException('DetectionDefinitionV1: missing patterns');
    }
    if (json['target_attributes'] == null) {
      throw const FormatException(
        'DetectionDefinitionV1: missing target_attributes',
      );
    }
    return DetectionDefinitionV1(
      patterns: (json['patterns'] as List<Object?>)
          .map(
            (item) => DetectionPattern.fromJson(item! as Map<String, dynamic>),
          )
          .toList(),
      targetAttributes: (json['target_attributes'] as List<Object?>)
          .map((item) => item! as String)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'patterns': patterns.map((item) => item.toJson()).toList(),
    'target_attributes': targetAttributes,
  };

  /// Creates a copy with the given fields replaced.
  DetectionDefinitionV1 copyWith({
    List<DetectionPattern>? patterns,
    List<String>? targetAttributes,
  }) => DetectionDefinitionV1(
    patterns: patterns ?? this.patterns,
    targetAttributes: targetAttributes ?? this.targetAttributes,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionDefinitionV1 &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(patterns, other.patterns) &&
          valuesDeepEqual(targetAttributes, other.targetAttributes);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(patterns),
    valueDeepHashCode(targetAttributes),
  ]);

  @override
  String toString() =>
      'DetectionDefinitionV1('
      'patterns: ${patterns.length}, '
      'targetAttributes: ${targetAttributes.length})';
}

/// The DetectionPattern wire payload.
@immutable
class DetectionPattern {
  /// Creates a [DetectionPattern].
  const DetectionPattern({
    required this.category,
    required this.confidence,
    required this.name,
    required this.regex,
  });

  /// The category field.
  final String category;

  /// The confidence field.
  final String confidence;

  /// The name field.
  final String name;

  /// The regex field.
  final String regex;

  /// Parses a [DetectionPattern] from JSON.
  factory DetectionPattern.fromJson(Map<String, dynamic> json) {
    if (json['category'] == null) {
      throw const FormatException('DetectionPattern: missing category');
    }
    if (json['confidence'] == null) {
      throw const FormatException('DetectionPattern: missing confidence');
    }
    if (json['name'] == null) {
      throw const FormatException('DetectionPattern: missing name');
    }
    if (json['regex'] == null) {
      throw const FormatException('DetectionPattern: missing regex');
    }
    return DetectionPattern(
      category: json['category'] as String,
      confidence: json['confidence'] as String,
      name: json['name'] as String,
      regex: json['regex'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'category': category,
    'confidence': confidence,
    'name': name,
    'regex': regex,
  };

  /// Creates a copy with the given fields replaced.
  DetectionPattern copyWith({
    String? category,
    String? confidence,
    String? name,
    String? regex,
  }) => DetectionPattern(
    category: category ?? this.category,
    confidence: confidence ?? this.confidence,
    name: name ?? this.name,
    regex: regex ?? this.regex,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionPattern &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          confidence == other.confidence &&
          name == other.name &&
          regex == other.regex;

  @override
  int get hashCode => Object.hashAll([category, confidence, name, regex]);

  @override
  String toString() =>
      'DetectionPattern('
      'category: $category, '
      'confidence: $confidence, '
      'name: $name, '
      'regex: $regex)';
}

/// The EnumConstraints wire payload.
@immutable
class EnumConstraints {
  /// Creates a [EnumConstraints].
  const EnumConstraints({this.options});

  /// The options field.
  final List<String>? options;

  /// Parses a [EnumConstraints] from JSON.
  factory EnumConstraints.fromJson(Map<String, dynamic> json) {
    return EnumConstraints(
      options: json['options'] == null
          ? null
          : (json['options'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'options': ?options};

  /// Creates a copy with the given fields replaced.
  EnumConstraints copyWith({Object? options = unsetCopyWithValue}) =>
      EnumConstraints(
        options: options == unsetCopyWithValue
            ? this.options
            : (options as List<Object?>?)?.cast<String>(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnumConstraints &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(options, other.options);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(options)]);

  @override
  String toString() =>
      'EnumConstraints('
      'options: ${options?.length})';
}

/// The ExportDefinitionV1 wire payload.
@immutable
final class ExportDefinitionV1 extends PipelineConfigDefinition {
  /// Creates a [ExportDefinitionV1].
  const ExportDefinitionV1({required this.destination});

  /// The destination field.
  final OtlpDestination destination;

  /// Parses a [ExportDefinitionV1] from JSON.
  factory ExportDefinitionV1.fromJson(Map<String, dynamic> json) {
    if (json['destination'] == null) {
      throw const FormatException('ExportDefinitionV1: missing destination');
    }
    return ExportDefinitionV1(
      destination: OtlpDestination.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'destination': destination.toJson()};

  /// Creates a copy with the given fields replaced.
  ExportDefinitionV1 copyWith({OtlpDestination? destination}) =>
      ExportDefinitionV1(destination: destination ?? this.destination);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportDefinitionV1 &&
          runtimeType == other.runtimeType &&
          destination == other.destination;

  @override
  int get hashCode => Object.hashAll([destination]);

  @override
  String toString() =>
      'ExportDefinitionV1('
      'destination: $destination)';
}

/// The FloatConstraints wire payload.
@immutable
class FloatConstraints {
  /// Creates a [FloatConstraints].
  const FloatConstraints({this.max, this.min});

  /// The max field.
  final double? max;

  /// The min field.
  final double? min;

  /// Parses a [FloatConstraints] from JSON.
  factory FloatConstraints.fromJson(Map<String, dynamic> json) {
    return FloatConstraints(
      max: json['max'] == null ? null : (json['max'] as num).toDouble(),
      min: json['min'] == null ? null : (json['min'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'max': ?max, 'min': ?min};

  /// Creates a copy with the given fields replaced.
  FloatConstraints copyWith({
    Object? max = unsetCopyWithValue,
    Object? min = unsetCopyWithValue,
  }) => FloatConstraints(
    max: max == unsetCopyWithValue ? this.max : (max as num?)?.toDouble(),
    min: min == unsetCopyWithValue ? this.min : (min as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FloatConstraints &&
          runtimeType == other.runtimeType &&
          max == other.max &&
          min == other.min;

  @override
  int get hashCode => Object.hashAll([max, min]);

  @override
  String toString() =>
      'FloatConstraints('
      'max: $max, '
      'min: $min)';
}

/// The GetPipelineResultFields wire payload.
@immutable
class GetPipelineResultFields {
  /// Creates a [GetPipelineResultFields].
  const GetPipelineResultFields({required this.fieldDefinitions});

  /// The field_definitions field.
  final List<PipelineResultField> fieldDefinitions;

  /// Parses a [GetPipelineResultFields] from JSON.
  factory GetPipelineResultFields.fromJson(Map<String, dynamic> json) {
    if (json['field_definitions'] == null) {
      throw const FormatException(
        'GetPipelineResultFields: missing field_definitions',
      );
    }
    return GetPipelineResultFields(
      fieldDefinitions: (json['field_definitions'] as List<Object?>)
          .map(
            (item) =>
                PipelineResultField.fromJson(item! as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'field_definitions': fieldDefinitions.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  GetPipelineResultFields copyWith({
    List<PipelineResultField>? fieldDefinitions,
  }) => GetPipelineResultFields(
    fieldDefinitions: fieldDefinitions ?? this.fieldDefinitions,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetPipelineResultFields &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(fieldDefinitions, other.fieldDefinitions);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(fieldDefinitions)]);

  @override
  String toString() =>
      'GetPipelineResultFields('
      'fieldDefinitions: ${fieldDefinitions.length})';
}

/// The GetPipelineResults wire payload.
@immutable
class GetPipelineResults {
  /// Creates a [GetPipelineResults].
  const GetPipelineResults({required this.pipelineResults});

  /// The pipeline_results field.
  final FeedResult<PipelineResult> pipelineResults;

  /// Parses a [GetPipelineResults] from JSON.
  factory GetPipelineResults.fromJson(Map<String, dynamic> json) {
    if (json['pipeline_results'] == null) {
      throw const FormatException(
        'GetPipelineResults: missing pipeline_results',
      );
    }
    return GetPipelineResults(
      pipelineResults: FeedResult<PipelineResult>.fromJson(
        json['pipeline_results'] as Map<String, dynamic>,
        PipelineResult.fromJson,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'pipeline_results': pipelineResults.toJson((item) => item.toJson()),
  };

  /// Creates a copy with the given fields replaced.
  GetPipelineResults copyWith({FeedResult<PipelineResult>? pipelineResults}) =>
      GetPipelineResults(
        pipelineResults: pipelineResults ?? this.pipelineResults,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetPipelineResults &&
          runtimeType == other.runtimeType &&
          pipelineResults == other.pipelineResults;

  @override
  int get hashCode => Object.hashAll([pipelineResults]);

  @override
  String toString() =>
      'GetPipelineResults('
      'pipelineResults: $pipelineResults)';
}

/// The fully materialized LLM judge behavior stored in a pipeline config.
@immutable
final class JudgeDefinitionV1 extends PipelineConfigDefinition {
  /// Creates a [JudgeDefinitionV1].
  const JudgeDefinitionV1({
    this.mapping,
    this.maxTokens,
    required this.model,
    required this.prompt,
    this.randomSeed,
    required this.resultSpec,
    this.temperature,
    this.topP,
    this.useCache,
  });

  /// The mapping field.
  final Map<String, String>? mapping;

  /// The max_tokens field.
  final int? maxTokens;

  /// The model field.
  final String model;

  /// The prompt field.
  final String prompt;

  /// The random_seed field.
  final int? randomSeed;

  /// The result_spec field.
  final EvaluationResultSpec resultSpec;

  /// The temperature field.
  final double? temperature;

  /// The top_p field.
  final double? topP;

  /// The use_cache field.
  final bool? useCache;

  /// Parses a [JudgeDefinitionV1] from JSON.
  factory JudgeDefinitionV1.fromJson(Map<String, dynamic> json) {
    if (json['model'] == null) {
      throw const FormatException('JudgeDefinitionV1: missing model');
    }
    if (json['prompt'] == null) {
      throw const FormatException('JudgeDefinitionV1: missing prompt');
    }
    if (json['result_spec'] == null) {
      throw const FormatException('JudgeDefinitionV1: missing result_spec');
    }
    return JudgeDefinitionV1(
      mapping: json['mapping'] == null
          ? null
          : (json['mapping'] as Map<String, Object?>).map(
              (key, item) => MapEntry(key, item! as String),
            ),
      maxTokens: json['max_tokens'] == null ? null : json['max_tokens'] as int,
      model: json['model'] as String,
      prompt: json['prompt'] as String,
      randomSeed: json['random_seed'] == null
          ? null
          : json['random_seed'] as int,
      resultSpec: EvaluationResultSpec.fromJson(
        json['result_spec'] as Map<String, dynamic>,
      ),
      temperature: json['temperature'] == null
          ? null
          : (json['temperature'] as num).toDouble(),
      topP: json['top_p'] == null ? null : (json['top_p'] as num).toDouble(),
      useCache: json['use_cache'] == null ? null : json['use_cache'] as bool,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'mapping': ?mapping,
    'max_tokens': ?maxTokens,
    'model': model,
    'prompt': prompt,
    'random_seed': ?randomSeed,
    'result_spec': resultSpec.toJson(),
    'temperature': ?temperature,
    'top_p': ?topP,
    'use_cache': ?useCache,
  };

  /// Creates a copy with the given fields replaced.
  JudgeDefinitionV1 copyWith({
    Object? mapping = unsetCopyWithValue,
    Object? maxTokens = unsetCopyWithValue,
    String? model,
    String? prompt,
    Object? randomSeed = unsetCopyWithValue,
    EvaluationResultSpec? resultSpec,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? useCache = unsetCopyWithValue,
  }) => JudgeDefinitionV1(
    mapping: mapping == unsetCopyWithValue
        ? this.mapping
        : (mapping as Map?)?.cast<String, String>(),
    maxTokens: maxTokens == unsetCopyWithValue
        ? this.maxTokens
        : maxTokens as int?,
    model: model ?? this.model,
    prompt: prompt ?? this.prompt,
    randomSeed: randomSeed == unsetCopyWithValue
        ? this.randomSeed
        : randomSeed as int?,
    resultSpec: resultSpec ?? this.resultSpec,
    temperature: temperature == unsetCopyWithValue
        ? this.temperature
        : (temperature as num?)?.toDouble(),
    topP: topP == unsetCopyWithValue ? this.topP : (topP as num?)?.toDouble(),
    useCache: useCache == unsetCopyWithValue
        ? this.useCache
        : useCache as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JudgeDefinitionV1 &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(mapping, other.mapping) &&
          maxTokens == other.maxTokens &&
          model == other.model &&
          prompt == other.prompt &&
          randomSeed == other.randomSeed &&
          resultSpec == other.resultSpec &&
          temperature == other.temperature &&
          topP == other.topP &&
          useCache == other.useCache;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(mapping),
    maxTokens,
    model,
    prompt,
    randomSeed,
    resultSpec,
    temperature,
    topP,
    useCache,
  ]);

  @override
  String toString() =>
      'JudgeDefinitionV1('
      'mapping: ${mapping?.length}, '
      'maxTokens: $maxTokens, '
      'model: $model, '
      'prompt: $prompt, '
      'randomSeed: $randomSeed, '
      'resultSpec: $resultSpec, '
      'temperature: $temperature, '
      'topP: $topP, '
      'useCache: $useCache)';
}

/// The scorer selected to build a judge pipeline configuration.
@immutable
class LlmJudgeReference {
  /// Creates a [LlmJudgeReference].
  const LlmJudgeReference({this.mapping, this.sampling, required this.slug});

  /// The mapping field.
  final Map<String, String>? mapping;

  /// The sampling field.
  final PipelineConfigSampling? sampling;

  /// The slug field.
  final String slug;

  /// Parses a [LlmJudgeReference] from JSON.
  factory LlmJudgeReference.fromJson(Map<String, dynamic> json) {
    if (json['slug'] == null) {
      throw const FormatException('LlmJudgeReference: missing slug');
    }
    return LlmJudgeReference(
      mapping: json['mapping'] == null
          ? null
          : (json['mapping'] as Map<String, Object?>).map(
              (key, item) => MapEntry(key, item! as String),
            ),
      sampling: json['sampling'] == null
          ? null
          : PipelineConfigSampling.fromJson(
              json['sampling'] as Map<String, dynamic>,
            ),
      slug: json['slug'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'mapping': ?mapping,
    if (sampling != null) 'sampling': sampling!.toJson(),
    'slug': slug,
  };

  /// Creates a copy with the given fields replaced.
  LlmJudgeReference copyWith({
    Object? mapping = unsetCopyWithValue,
    Object? sampling = unsetCopyWithValue,
    String? slug,
  }) => LlmJudgeReference(
    mapping: mapping == unsetCopyWithValue
        ? this.mapping
        : (mapping as Map?)?.cast<String, String>(),
    sampling: sampling == unsetCopyWithValue
        ? this.sampling
        : sampling as PipelineConfigSampling?,
    slug: slug ?? this.slug,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LlmJudgeReference &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(mapping, other.mapping) &&
          sampling == other.sampling &&
          slug == other.slug;

  @override
  int get hashCode =>
      Object.hashAll([valueDeepHashCode(mapping), sampling, slug]);

  @override
  String toString() =>
      'LlmJudgeReference('
      'mapping: ${mapping?.length}, '
      'sampling: $sampling, '
      'slug: $slug)';
}

/// The ModerationDefinitionV1 wire payload.
@immutable
final class ModerationDefinitionV1 extends PipelineConfigDefinition {
  /// Creates a [ModerationDefinitionV1].
  const ModerationDefinitionV1({this.model, this.targetAttributes});

  /// The model field.
  final String? model;

  /// The target_attributes field.
  final List<String>? targetAttributes;

  /// Parses a [ModerationDefinitionV1] from JSON.
  factory ModerationDefinitionV1.fromJson(Map<String, dynamic> json) {
    return ModerationDefinitionV1(
      model: json['model'] == null ? null : json['model'] as String,
      targetAttributes: json['target_attributes'] == null
          ? null
          : (json['target_attributes'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'model': ?model,
    'target_attributes': ?targetAttributes,
  };

  /// Creates a copy with the given fields replaced.
  ModerationDefinitionV1 copyWith({
    Object? model = unsetCopyWithValue,
    Object? targetAttributes = unsetCopyWithValue,
  }) => ModerationDefinitionV1(
    model: model == unsetCopyWithValue ? this.model : model as String?,
    targetAttributes: targetAttributes == unsetCopyWithValue
        ? this.targetAttributes
        : (targetAttributes as List<Object?>?)?.cast<String>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationDefinitionV1 &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          valuesDeepEqual(targetAttributes, other.targetAttributes);

  @override
  int get hashCode =>
      Object.hashAll([model, valueDeepHashCode(targetAttributes)]);

  @override
  String toString() =>
      'ModerationDefinitionV1('
      'model: $model, '
      'targetAttributes: ${targetAttributes?.length})';
}

/// The OTLPDestination wire payload.
@immutable
class OtlpDestination {
  /// Creates a [OtlpDestination].
  const OtlpDestination({
    required this.endpoint,
    this.headers,
    this.insecure,
    required this.protocol,
  });

  /// The endpoint field.
  final String endpoint;

  /// The headers field.
  final Map<String, PipelineConfigHeader>? headers;

  /// The insecure field.
  final bool? insecure;

  /// The protocol field.
  final String protocol;

  /// Parses a [OtlpDestination] from JSON.
  factory OtlpDestination.fromJson(Map<String, dynamic> json) {
    if (json['endpoint'] == null) {
      throw const FormatException('OtlpDestination: missing endpoint');
    }
    if (json['protocol'] == null) {
      throw const FormatException('OtlpDestination: missing protocol');
    }
    return OtlpDestination(
      endpoint: json['endpoint'] as String,
      headers: json['headers'] == null
          ? null
          : (json['headers'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                PipelineConfigHeader.fromJson(item! as Map<String, dynamic>),
              ),
            ),
      insecure: json['insecure'] == null ? null : json['insecure'] as bool,
      protocol: json['protocol'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'endpoint': endpoint,
    if (headers != null)
      'headers': headers!.map((key, item) => MapEntry(key, item.toJson())),
    'insecure': ?insecure,
    'protocol': protocol,
  };

  /// Creates a copy with the given fields replaced.
  OtlpDestination copyWith({
    String? endpoint,
    Object? headers = unsetCopyWithValue,
    Object? insecure = unsetCopyWithValue,
    String? protocol,
  }) => OtlpDestination(
    endpoint: endpoint ?? this.endpoint,
    headers: headers == unsetCopyWithValue
        ? this.headers
        : (headers as Map?)?.cast<String, PipelineConfigHeader>(),
    insecure: insecure == unsetCopyWithValue
        ? this.insecure
        : insecure as bool?,
    protocol: protocol ?? this.protocol,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtlpDestination &&
          runtimeType == other.runtimeType &&
          endpoint == other.endpoint &&
          valuesDeepEqual(headers, other.headers) &&
          insecure == other.insecure &&
          protocol == other.protocol;

  @override
  int get hashCode => Object.hashAll([
    endpoint,
    valueDeepHashCode(headers),
    insecure,
    protocol,
  ]);

  @override
  String toString() =>
      'OtlpDestination('
      'endpoint: $endpoint, '
      'headers: ${headers?.length}, '
      'insecure: $insecure, '
      'protocol: $protocol)';
}

/// The OtelEnumFieldDefinition wire payload.
@immutable
final class OtelEnumFieldDefinition extends PipelineResultField {
  /// Creates a [OtelEnumFieldDefinition].
  const OtelEnumFieldDefinition({
    this.constraints,
    this.group,
    required this.label,
    required this.name,
    this.sourceAttributeKey,
    required this.supportedAggregations,
    required this.supportedOperators,
  });

  /// The fixed type discriminator.
  String get type => 'ENUM';

  /// The constraints field.
  final EnumConstraints? constraints;

  /// The group field.
  final String? group;

  /// The label field.
  final String label;

  /// The name field.
  final String name;

  /// Raw OpenTelemetry attribute key this field is projected from, whether a span attribute (e.g. `gen_ai.request.model` for `request_model`) or a resource attribute (e.g. `service.name` for `service_name`). None when the field is a native OTLP field (like `span_name` or `trace_id`) or a nested attribute map (like `span_attributes`).
  final String? sourceAttributeKey;

  /// The supported_aggregations field.
  final List<MetricAggregation> supportedAggregations;

  /// The supported_operators field.
  final List<String> supportedOperators;

  /// Parses a [OtelEnumFieldDefinition] from JSON.
  factory OtelEnumFieldDefinition.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'ENUM') {
      throw FormatException('OtelEnumFieldDefinition: unexpected type $value');
    }
    if (json['label'] == null) {
      throw const FormatException('OtelEnumFieldDefinition: missing label');
    }
    if (json['name'] == null) {
      throw const FormatException('OtelEnumFieldDefinition: missing name');
    }
    if (json['supported_aggregations'] == null) {
      throw const FormatException(
        'OtelEnumFieldDefinition: missing supported_aggregations',
      );
    }
    if (json['supported_operators'] == null) {
      throw const FormatException(
        'OtelEnumFieldDefinition: missing supported_operators',
      );
    }
    return OtelEnumFieldDefinition(
      constraints: json['constraints'] == null
          ? null
          : EnumConstraints.fromJson(
              json['constraints'] as Map<String, dynamic>,
            ),
      group: json['group'] == null ? null : json['group'] as String,
      label: json['label'] as String,
      name: json['name'] as String,
      sourceAttributeKey: json['source_attribute_key'] == null
          ? null
          : json['source_attribute_key'] as String,
      supportedAggregations: (json['supported_aggregations'] as List<Object?>)
          .map((item) => MetricAggregation.fromJson(item! as String))
          .toList(),
      supportedOperators: (json['supported_operators'] as List<Object?>)
          .map((item) => item! as String)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (constraints != null) 'constraints': constraints!.toJson(),
    'group': ?group,
    'label': label,
    'name': name,
    'source_attribute_key': ?sourceAttributeKey,
    'supported_aggregations': supportedAggregations
        .map((item) => item.toJson())
        .toList(),
    'supported_operators': supportedOperators,
  };

  /// Creates a copy with the given fields replaced.
  OtelEnumFieldDefinition copyWith({
    Object? constraints = unsetCopyWithValue,
    Object? group = unsetCopyWithValue,
    String? label,
    String? name,
    Object? sourceAttributeKey = unsetCopyWithValue,
    List<MetricAggregation>? supportedAggregations,
    List<String>? supportedOperators,
  }) => OtelEnumFieldDefinition(
    constraints: constraints == unsetCopyWithValue
        ? this.constraints
        : constraints as EnumConstraints?,
    group: group == unsetCopyWithValue ? this.group : group as String?,
    label: label ?? this.label,
    name: name ?? this.name,
    sourceAttributeKey: sourceAttributeKey == unsetCopyWithValue
        ? this.sourceAttributeKey
        : sourceAttributeKey as String?,
    supportedAggregations: supportedAggregations ?? this.supportedAggregations,
    supportedOperators: supportedOperators ?? this.supportedOperators,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtelEnumFieldDefinition &&
          runtimeType == other.runtimeType &&
          constraints == other.constraints &&
          group == other.group &&
          label == other.label &&
          name == other.name &&
          sourceAttributeKey == other.sourceAttributeKey &&
          valuesDeepEqual(supportedAggregations, other.supportedAggregations) &&
          valuesDeepEqual(supportedOperators, other.supportedOperators);

  @override
  int get hashCode => Object.hashAll([
    constraints,
    group,
    label,
    name,
    sourceAttributeKey,
    valueDeepHashCode(supportedAggregations),
    valueDeepHashCode(supportedOperators),
  ]);

  @override
  String toString() =>
      'OtelEnumFieldDefinition('
      'constraints: $constraints, '
      'group: $group, '
      'label: $label, '
      'name: $name, '
      'sourceAttributeKey: $sourceAttributeKey, '
      'supportedAggregations: ${supportedAggregations.length}, '
      'supportedOperators: ${supportedOperators.length})';
}

/// The OtelFloatFieldDefinition wire payload.
@immutable
final class OtelFloatFieldDefinition extends PipelineResultField {
  /// Creates a [OtelFloatFieldDefinition].
  const OtelFloatFieldDefinition({
    this.constraints,
    this.group,
    required this.label,
    required this.name,
    this.sourceAttributeKey,
    required this.supportedAggregations,
    required this.supportedOperators,
  });

  /// The fixed type discriminator.
  String get type => 'FLOAT';

  /// The constraints field.
  final FloatConstraints? constraints;

  /// The group field.
  final String? group;

  /// The label field.
  final String label;

  /// The name field.
  final String name;

  /// Raw OpenTelemetry attribute key this field is projected from, whether a span attribute (e.g. `gen_ai.request.model` for `request_model`) or a resource attribute (e.g. `service.name` for `service_name`). None when the field is a native OTLP field (like `span_name` or `trace_id`) or a nested attribute map (like `span_attributes`).
  final String? sourceAttributeKey;

  /// The supported_aggregations field.
  final List<MetricAggregation> supportedAggregations;

  /// The supported_operators field.
  final List<String> supportedOperators;

  /// Parses a [OtelFloatFieldDefinition] from JSON.
  factory OtelFloatFieldDefinition.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'FLOAT') {
      throw FormatException('OtelFloatFieldDefinition: unexpected type $value');
    }
    if (json['label'] == null) {
      throw const FormatException('OtelFloatFieldDefinition: missing label');
    }
    if (json['name'] == null) {
      throw const FormatException('OtelFloatFieldDefinition: missing name');
    }
    if (json['supported_aggregations'] == null) {
      throw const FormatException(
        'OtelFloatFieldDefinition: missing supported_aggregations',
      );
    }
    if (json['supported_operators'] == null) {
      throw const FormatException(
        'OtelFloatFieldDefinition: missing supported_operators',
      );
    }
    return OtelFloatFieldDefinition(
      constraints: json['constraints'] == null
          ? null
          : FloatConstraints.fromJson(
              json['constraints'] as Map<String, dynamic>,
            ),
      group: json['group'] == null ? null : json['group'] as String,
      label: json['label'] as String,
      name: json['name'] as String,
      sourceAttributeKey: json['source_attribute_key'] == null
          ? null
          : json['source_attribute_key'] as String,
      supportedAggregations: (json['supported_aggregations'] as List<Object?>)
          .map((item) => MetricAggregation.fromJson(item! as String))
          .toList(),
      supportedOperators: (json['supported_operators'] as List<Object?>)
          .map((item) => item! as String)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (constraints != null) 'constraints': constraints!.toJson(),
    'group': ?group,
    'label': label,
    'name': name,
    'source_attribute_key': ?sourceAttributeKey,
    'supported_aggregations': supportedAggregations
        .map((item) => item.toJson())
        .toList(),
    'supported_operators': supportedOperators,
  };

  /// Creates a copy with the given fields replaced.
  OtelFloatFieldDefinition copyWith({
    Object? constraints = unsetCopyWithValue,
    Object? group = unsetCopyWithValue,
    String? label,
    String? name,
    Object? sourceAttributeKey = unsetCopyWithValue,
    List<MetricAggregation>? supportedAggregations,
    List<String>? supportedOperators,
  }) => OtelFloatFieldDefinition(
    constraints: constraints == unsetCopyWithValue
        ? this.constraints
        : constraints as FloatConstraints?,
    group: group == unsetCopyWithValue ? this.group : group as String?,
    label: label ?? this.label,
    name: name ?? this.name,
    sourceAttributeKey: sourceAttributeKey == unsetCopyWithValue
        ? this.sourceAttributeKey
        : sourceAttributeKey as String?,
    supportedAggregations: supportedAggregations ?? this.supportedAggregations,
    supportedOperators: supportedOperators ?? this.supportedOperators,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtelFloatFieldDefinition &&
          runtimeType == other.runtimeType &&
          constraints == other.constraints &&
          group == other.group &&
          label == other.label &&
          name == other.name &&
          sourceAttributeKey == other.sourceAttributeKey &&
          valuesDeepEqual(supportedAggregations, other.supportedAggregations) &&
          valuesDeepEqual(supportedOperators, other.supportedOperators);

  @override
  int get hashCode => Object.hashAll([
    constraints,
    group,
    label,
    name,
    sourceAttributeKey,
    valueDeepHashCode(supportedAggregations),
    valueDeepHashCode(supportedOperators),
  ]);

  @override
  String toString() =>
      'OtelFloatFieldDefinition('
      'constraints: $constraints, '
      'group: $group, '
      'label: $label, '
      'name: $name, '
      'sourceAttributeKey: $sourceAttributeKey, '
      'supportedAggregations: ${supportedAggregations.length}, '
      'supportedOperators: ${supportedOperators.length})';
}

/// Pipeline response schema. Pipelines are hard-deleted — no deleted_at field.
@immutable
class Pipeline {
  /// Creates a [Pipeline].
  const Pipeline({
    required this.createdAt,
    required this.creatorId,
    required this.description,
    required this.enabled,
    required this.id,
    required this.name,
    required this.pipelineConfigs,
    required this.selectors,
    required this.slug,
    required this.updatedAt,
    required this.workspaceId,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The creator_id field.
  final String? creatorId;

  /// The description field.
  final String? description;

  /// The enabled field.
  final bool enabled;

  /// The id field.
  final String id;

  /// The name field.
  final String name;

  /// The pipeline_configs field.
  final List<PipelineConfig> pipelineConfigs;

  /// The selectors field.
  final List<PipelineConfigSelector> selectors;

  /// The slug field.
  final String slug;

  /// The updated_at field.
  final DateTime updatedAt;

  /// The workspace_id field.
  final String workspaceId;

  /// Parses a [Pipeline] from JSON.
  factory Pipeline.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('Pipeline: missing created_at');
    }
    if (!json.containsKey('creator_id')) {
      throw const FormatException('Pipeline: missing creator_id');
    }
    if (!json.containsKey('description')) {
      throw const FormatException('Pipeline: missing description');
    }
    if (json['enabled'] == null) {
      throw const FormatException('Pipeline: missing enabled');
    }
    if (json['id'] == null) {
      throw const FormatException('Pipeline: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('Pipeline: missing name');
    }
    if (json['pipeline_configs'] == null) {
      throw const FormatException('Pipeline: missing pipeline_configs');
    }
    if (json['selectors'] == null) {
      throw const FormatException('Pipeline: missing selectors');
    }
    if (json['slug'] == null) {
      throw const FormatException('Pipeline: missing slug');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('Pipeline: missing updated_at');
    }
    if (json['workspace_id'] == null) {
      throw const FormatException('Pipeline: missing workspace_id');
    }
    return Pipeline(
      createdAt: DateTime.parse(json['created_at'] as String),
      creatorId: json['creator_id'] == null
          ? null
          : json['creator_id'] as String,
      description: json['description'] == null
          ? null
          : json['description'] as String,
      enabled: json['enabled'] as bool,
      id: json['id'] as String,
      name: json['name'] as String,
      pipelineConfigs: (json['pipeline_configs'] as List<Object?>)
          .map((item) => PipelineConfig.fromJson(item! as Map<String, dynamic>))
          .toList(),
      selectors: (json['selectors'] as List<Object?>)
          .map(
            (item) =>
                PipelineConfigSelector.fromJson(item! as Map<String, dynamic>),
          )
          .toList(),
      slug: json['slug'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      workspaceId: json['workspace_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'creator_id': creatorId,
    'description': description,
    'enabled': enabled,
    'id': id,
    'name': name,
    'pipeline_configs': pipelineConfigs.map((item) => item.toJson()).toList(),
    'selectors': selectors.map((item) => item.toJson()).toList(),
    'slug': slug,
    'updated_at': updatedAt.toIso8601String(),
    'workspace_id': workspaceId,
  };

  /// Creates a copy with the given fields replaced.
  Pipeline copyWith({
    DateTime? createdAt,
    Object? creatorId = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    bool? enabled,
    String? id,
    String? name,
    List<PipelineConfig>? pipelineConfigs,
    List<PipelineConfigSelector>? selectors,
    String? slug,
    DateTime? updatedAt,
    String? workspaceId,
  }) => Pipeline(
    createdAt: createdAt ?? this.createdAt,
    creatorId: creatorId == unsetCopyWithValue
        ? this.creatorId
        : creatorId as String?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    enabled: enabled ?? this.enabled,
    id: id ?? this.id,
    name: name ?? this.name,
    pipelineConfigs: pipelineConfigs ?? this.pipelineConfigs,
    selectors: selectors ?? this.selectors,
    slug: slug ?? this.slug,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pipeline &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          creatorId == other.creatorId &&
          description == other.description &&
          enabled == other.enabled &&
          id == other.id &&
          name == other.name &&
          valuesDeepEqual(pipelineConfigs, other.pipelineConfigs) &&
          valuesDeepEqual(selectors, other.selectors) &&
          slug == other.slug &&
          updatedAt == other.updatedAt &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    creatorId,
    description,
    enabled,
    id,
    name,
    valueDeepHashCode(pipelineConfigs),
    valueDeepHashCode(selectors),
    slug,
    updatedAt,
    workspaceId,
  ]);

  @override
  String toString() =>
      'Pipeline('
      'createdAt: $createdAt, '
      'creatorId: $creatorId, '
      'description: $description, '
      'enabled: $enabled, '
      'id: $id, '
      'name: $name, '
      'pipelineConfigs: ${pipelineConfigs.length}, '
      'selectors: ${selectors.length}, '
      'slug: $slug, '
      'updatedAt: $updatedAt, '
      'workspaceId: $workspaceId)';
}

/// The PipelineConfig wire payload.
@immutable
class PipelineConfig {
  /// Creates a [PipelineConfig].
  const PipelineConfig({
    required this.createdAt,
    required this.definition,
    required this.deletedAt,
    required this.enabled,
    required this.id,
    required this.name,
    required this.pipelineKind,
    this.sampling,
    required this.scope,
    this.scorerSlug,
    this.scorerVersion,
    required this.selectors,
    required this.slug,
    required this.updatedAt,
    required this.workspaceId,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The definition field.
  final PipelineConfigDefinition definition;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The enabled field.
  final bool enabled;

  /// The id field.
  final String id;

  /// The name field.
  final String name;

  /// The pipeline_kind field.
  final PipelineKind pipelineKind;

  /// The sampling field.
  final PipelineConfigSampling? sampling;

  /// The scope field.
  final PipelineConfigScope scope;

  /// The scorer_slug field.
  final String? scorerSlug;

  /// The scorer_version field.
  final int? scorerVersion;

  /// The selectors field.
  final List<PipelineConfigSelector> selectors;

  /// The slug field.
  final String slug;

  /// The updated_at field.
  final DateTime updatedAt;

  /// The workspace_id field.
  final String workspaceId;

  /// Parses a [PipelineConfig] from JSON.
  factory PipelineConfig.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('PipelineConfig: missing created_at');
    }
    if (json['definition'] == null) {
      throw const FormatException('PipelineConfig: missing definition');
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException('PipelineConfig: missing deleted_at');
    }
    if (json['enabled'] == null) {
      throw const FormatException('PipelineConfig: missing enabled');
    }
    if (json['id'] == null) {
      throw const FormatException('PipelineConfig: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('PipelineConfig: missing name');
    }
    if (json['pipeline_kind'] == null) {
      throw const FormatException('PipelineConfig: missing pipeline_kind');
    }
    if (json['scope'] == null) {
      throw const FormatException('PipelineConfig: missing scope');
    }
    if (json['selectors'] == null) {
      throw const FormatException('PipelineConfig: missing selectors');
    }
    if (json['slug'] == null) {
      throw const FormatException('PipelineConfig: missing slug');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('PipelineConfig: missing updated_at');
    }
    if (json['workspace_id'] == null) {
      throw const FormatException('PipelineConfig: missing workspace_id');
    }
    return PipelineConfig(
      createdAt: DateTime.parse(json['created_at'] as String),
      definition: PipelineConfigDefinition.fromJson(
        json['definition'] as Map<String, dynamic>,
        kind: json['pipeline_kind'] as String?,
      ),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      enabled: json['enabled'] as bool,
      id: json['id'] as String,
      name: json['name'] as String,
      pipelineKind: PipelineKind.fromJson(json['pipeline_kind'] as String),
      sampling: json['sampling'] == null
          ? null
          : PipelineConfigSampling.fromJson(
              json['sampling'] as Map<String, dynamic>,
            ),
      scope: PipelineConfigScope.fromJson(json['scope'] as String),
      scorerSlug: json['scorer_slug'] == null
          ? null
          : json['scorer_slug'] as String,
      scorerVersion: json['scorer_version'] == null
          ? null
          : json['scorer_version'] as int,
      selectors: (json['selectors'] as List<Object?>)
          .map(
            (item) =>
                PipelineConfigSelector.fromJson(item! as Map<String, dynamic>),
          )
          .toList(),
      slug: json['slug'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      workspaceId: json['workspace_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'definition': definition.toJson(),
    'deleted_at': deletedAt?.toIso8601String(),
    'enabled': enabled,
    'id': id,
    'name': name,
    'pipeline_kind': pipelineKind.toJson(),
    if (sampling != null) 'sampling': sampling!.toJson(),
    'scope': scope.toJson(),
    'scorer_slug': ?scorerSlug,
    'scorer_version': ?scorerVersion,
    'selectors': selectors.map((item) => item.toJson()).toList(),
    'slug': slug,
    'updated_at': updatedAt.toIso8601String(),
    'workspace_id': workspaceId,
  };

  /// Creates a copy with the given fields replaced.
  PipelineConfig copyWith({
    DateTime? createdAt,
    PipelineConfigDefinition? definition,
    Object? deletedAt = unsetCopyWithValue,
    bool? enabled,
    String? id,
    String? name,
    PipelineKind? pipelineKind,
    Object? sampling = unsetCopyWithValue,
    PipelineConfigScope? scope,
    Object? scorerSlug = unsetCopyWithValue,
    Object? scorerVersion = unsetCopyWithValue,
    List<PipelineConfigSelector>? selectors,
    String? slug,
    DateTime? updatedAt,
    String? workspaceId,
  }) => PipelineConfig(
    createdAt: createdAt ?? this.createdAt,
    definition: definition ?? this.definition,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    enabled: enabled ?? this.enabled,
    id: id ?? this.id,
    name: name ?? this.name,
    pipelineKind: pipelineKind ?? this.pipelineKind,
    sampling: sampling == unsetCopyWithValue
        ? this.sampling
        : sampling as PipelineConfigSampling?,
    scope: scope ?? this.scope,
    scorerSlug: scorerSlug == unsetCopyWithValue
        ? this.scorerSlug
        : scorerSlug as String?,
    scorerVersion: scorerVersion == unsetCopyWithValue
        ? this.scorerVersion
        : scorerVersion as int?,
    selectors: selectors ?? this.selectors,
    slug: slug ?? this.slug,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelineConfig &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          definition == other.definition &&
          deletedAt == other.deletedAt &&
          enabled == other.enabled &&
          id == other.id &&
          name == other.name &&
          pipelineKind == other.pipelineKind &&
          sampling == other.sampling &&
          scope == other.scope &&
          scorerSlug == other.scorerSlug &&
          scorerVersion == other.scorerVersion &&
          valuesDeepEqual(selectors, other.selectors) &&
          slug == other.slug &&
          updatedAt == other.updatedAt &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    definition,
    deletedAt,
    enabled,
    id,
    name,
    pipelineKind,
    sampling,
    scope,
    scorerSlug,
    scorerVersion,
    valueDeepHashCode(selectors),
    slug,
    updatedAt,
    workspaceId,
  ]);

  @override
  String toString() =>
      'PipelineConfig('
      'createdAt: $createdAt, '
      'definition: $definition, '
      'deletedAt: $deletedAt, '
      'enabled: $enabled, '
      'id: $id, '
      'name: $name, '
      'pipelineKind: $pipelineKind, '
      'sampling: $sampling, '
      'scope: $scope, '
      'scorerSlug: $scorerSlug, '
      'scorerVersion: $scorerVersion, '
      'selectors: ${selectors.length}, '
      'slug: $slug, '
      'updatedAt: $updatedAt, '
      'workspaceId: $workspaceId)';
}

/// A variant of [PipelineConfigDefinition] returned or accepted by Observability.
sealed class PipelineConfigDefinition {
  const PipelineConfigDefinition();

  /// Decodes a variant from its API representation.
  factory PipelineConfigDefinition.fromJson(
    Map<String, dynamic> json, {
    String? kind,
  }) => switch (kind) {
    'detection-v1' => DetectionDefinitionV1.fromJson(json),
    'moderation-v1' => ModerationDefinitionV1.fromJson(json),
    'judge-v1' => JudgeDefinitionV1.fromJson(json),
    'export-v1' => ExportDefinitionV1.fromJson(json),
    _ => UnknownPipelineConfigDefinition(json),
  };

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A server variant of [PipelineConfigDefinition] unknown to this client.
@immutable
final class UnknownPipelineConfigDefinition extends PipelineConfigDefinition {
  /// Retains the original payload.
  UnknownPipelineConfigDefinition(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The unrecognized payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownPipelineConfigDefinition && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// The PipelineConfigHeader wire payload.
@immutable
class PipelineConfigHeader {
  /// Creates a [PipelineConfigHeader].
  const PipelineConfigHeader({this.value});

  /// The value field.
  final String? value;

  /// Parses a [PipelineConfigHeader] from JSON.
  factory PipelineConfigHeader.fromJson(Map<String, dynamic> json) {
    return PipelineConfigHeader(
      value: json['value'] == null ? null : json['value'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'value': ?value};

  /// Creates a copy with the given fields replaced.
  PipelineConfigHeader copyWith({Object? value = unsetCopyWithValue}) =>
      PipelineConfigHeader(
        value: value == unsetCopyWithValue ? this.value : value as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelineConfigHeader &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => Object.hashAll([value]);

  @override
  String toString() =>
      'PipelineConfigHeader('
      'valuePresent: ${value != null})';
}

/// A variant of [PipelineConfigSampling] returned or accepted by Observability.
sealed class PipelineConfigSampling {
  const PipelineConfigSampling();

  /// Decodes a variant from its API representation.
  factory PipelineConfigSampling.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'probabilistic' => ProbabilisticSampling.fromJson(json),
        'attribute_hash' => AttributeHashSampling.fromJson(json),
        _ => UnknownPipelineConfigSampling(json),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A server variant of [PipelineConfigSampling] unknown to this client.
@immutable
final class UnknownPipelineConfigSampling extends PipelineConfigSampling {
  /// Retains the original payload.
  UnknownPipelineConfigSampling(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The unrecognized payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownPipelineConfigSampling && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// Values for PipelineConfigScope.
enum PipelineConfigScope {
  /// Represents workspace.
  workspace('workspace'),

  /// Represents shared.
  shared('shared'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const PipelineConfigScope(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static PipelineConfigScope fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The PipelineConfigSelector wire payload.
@immutable
class PipelineConfigSelector {
  /// Creates a [PipelineConfigSelector].
  const PipelineConfigSelector({this.filter, required this.sourceKind});

  /// The filter field.
  final String? filter;

  /// The telemetry source. Select [PipelineSourceKind.span] for live evaluations.
  final PipelineSourceKind sourceKind;

  /// Parses a [PipelineConfigSelector] from JSON.
  factory PipelineConfigSelector.fromJson(Map<String, dynamic> json) {
    if (json['source_kind'] == null) {
      throw const FormatException(
        'PipelineConfigSelector: missing source_kind',
      );
    }
    return PipelineConfigSelector(
      filter: json['filter'] == null ? null : json['filter'] as String,
      sourceKind: PipelineSourceKind.fromJson(json['source_kind'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'filter': ?filter,
    'source_kind': sourceKind.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  PipelineConfigSelector copyWith({
    Object? filter = unsetCopyWithValue,
    PipelineSourceKind? sourceKind,
  }) => PipelineConfigSelector(
    filter: filter == unsetCopyWithValue ? this.filter : filter as String?,
    sourceKind: sourceKind ?? this.sourceKind,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelineConfigSelector &&
          runtimeType == other.runtimeType &&
          filter == other.filter &&
          sourceKind == other.sourceKind;

  @override
  int get hashCode => Object.hashAll([filter, sourceKind]);

  @override
  String toString() =>
      'PipelineConfigSelector('
      'filter: $filter, '
      'sourceKind: $sourceKind)';
}

/// Values for PipelineKind.
enum PipelineKind {
  /// Represents detection-v1.
  detectionV1('detection-v1'),

  /// Represents moderation-v1.
  moderationV1('moderation-v1'),

  /// Represents judge-v1.
  judgeV1('judge-v1'),

  /// Represents export-v1.
  exportV1('export-v1'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const PipelineKind(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static PipelineKind fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The PipelineResult wire payload.
@immutable
class PipelineResult {
  /// Creates a [PipelineResult].
  const PipelineResult({
    required this.durationNs,
    required this.evaluatedAt,
    required this.judgeExplanations,
    required this.judgeLabels,
    required this.judgeScores,
    required this.operationName,
    required this.spanId,
    required this.spanName,
    required this.toolName,
    required this.traceId,
  });

  /// The duration_ns field.
  final int durationNs;

  /// The evaluated_at field.
  final DateTime evaluatedAt;

  /// The judge_explanations field.
  final Map<String, String> judgeExplanations;

  /// The judge_labels field.
  final Map<String, String> judgeLabels;

  /// The judge_scores field.
  final Map<String, double> judgeScores;

  /// The operation_name field.
  final String operationName;

  /// The span_id field.
  final String spanId;

  /// The span_name field.
  final String spanName;

  /// The tool_name field.
  final String toolName;

  /// The trace_id field.
  final String traceId;

  /// Parses a [PipelineResult] from JSON.
  factory PipelineResult.fromJson(Map<String, dynamic> json) {
    if (json['duration_ns'] == null) {
      throw const FormatException('PipelineResult: missing duration_ns');
    }
    if (json['evaluated_at'] == null) {
      throw const FormatException('PipelineResult: missing evaluated_at');
    }
    if (json['judge_explanations'] == null) {
      throw const FormatException('PipelineResult: missing judge_explanations');
    }
    if (json['judge_labels'] == null) {
      throw const FormatException('PipelineResult: missing judge_labels');
    }
    if (json['judge_scores'] == null) {
      throw const FormatException('PipelineResult: missing judge_scores');
    }
    if (json['operation_name'] == null) {
      throw const FormatException('PipelineResult: missing operation_name');
    }
    if (json['span_id'] == null) {
      throw const FormatException('PipelineResult: missing span_id');
    }
    if (json['span_name'] == null) {
      throw const FormatException('PipelineResult: missing span_name');
    }
    if (json['tool_name'] == null) {
      throw const FormatException('PipelineResult: missing tool_name');
    }
    if (json['trace_id'] == null) {
      throw const FormatException('PipelineResult: missing trace_id');
    }
    return PipelineResult(
      durationNs: json['duration_ns'] as int,
      evaluatedAt: DateTime.parse(json['evaluated_at'] as String),
      judgeExplanations: (json['judge_explanations'] as Map<String, Object?>)
          .map((key, item) => MapEntry(key, item! as String)),
      judgeLabels: (json['judge_labels'] as Map<String, Object?>).map(
        (key, item) => MapEntry(key, item! as String),
      ),
      judgeScores: (json['judge_scores'] as Map<String, Object?>).map(
        (key, item) => MapEntry(key, (item! as num).toDouble()),
      ),
      operationName: json['operation_name'] as String,
      spanId: json['span_id'] as String,
      spanName: json['span_name'] as String,
      toolName: json['tool_name'] as String,
      traceId: json['trace_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'duration_ns': durationNs,
    'evaluated_at': evaluatedAt.toIso8601String(),
    'judge_explanations': judgeExplanations,
    'judge_labels': judgeLabels,
    'judge_scores': judgeScores,
    'operation_name': operationName,
    'span_id': spanId,
    'span_name': spanName,
    'tool_name': toolName,
    'trace_id': traceId,
  };

  /// Creates a copy with the given fields replaced.
  PipelineResult copyWith({
    int? durationNs,
    DateTime? evaluatedAt,
    Map<String, String>? judgeExplanations,
    Map<String, String>? judgeLabels,
    Map<String, double>? judgeScores,
    String? operationName,
    String? spanId,
    String? spanName,
    String? toolName,
    String? traceId,
  }) => PipelineResult(
    durationNs: durationNs ?? this.durationNs,
    evaluatedAt: evaluatedAt ?? this.evaluatedAt,
    judgeExplanations: judgeExplanations ?? this.judgeExplanations,
    judgeLabels: judgeLabels ?? this.judgeLabels,
    judgeScores: judgeScores ?? this.judgeScores,
    operationName: operationName ?? this.operationName,
    spanId: spanId ?? this.spanId,
    spanName: spanName ?? this.spanName,
    toolName: toolName ?? this.toolName,
    traceId: traceId ?? this.traceId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelineResult &&
          runtimeType == other.runtimeType &&
          durationNs == other.durationNs &&
          evaluatedAt == other.evaluatedAt &&
          valuesDeepEqual(judgeExplanations, other.judgeExplanations) &&
          valuesDeepEqual(judgeLabels, other.judgeLabels) &&
          valuesDeepEqual(judgeScores, other.judgeScores) &&
          operationName == other.operationName &&
          spanId == other.spanId &&
          spanName == other.spanName &&
          toolName == other.toolName &&
          traceId == other.traceId;

  @override
  int get hashCode => Object.hashAll([
    durationNs,
    evaluatedAt,
    valueDeepHashCode(judgeExplanations),
    valueDeepHashCode(judgeLabels),
    valueDeepHashCode(judgeScores),
    operationName,
    spanId,
    spanName,
    toolName,
    traceId,
  ]);

  @override
  String toString() =>
      'PipelineResult('
      'durationNs: $durationNs, '
      'evaluatedAt: $evaluatedAt, '
      'judgeExplanations: ${judgeExplanations.length}, '
      'judgeLabels: ${judgeLabels.length}, '
      'judgeScores: ${judgeScores.length}, '
      'operationName: $operationName, '
      'spanId: $spanId, '
      'spanName: $spanName, '
      'toolName: $toolName, '
      'traceId: $traceId)';
}

/// The PipelineResultsRequest wire payload.
@immutable
class PipelineResultsRequest {
  /// Creates a [PipelineResultsRequest].
  const PipelineResultsRequest({
    required this.pipelineConfigSlugs,
    this.searchExpression,
  });

  /// The pipeline_config_slugs field.
  final List<String> pipelineConfigSlugs;

  /// The search_expression field.
  final String? searchExpression;

  /// Parses a [PipelineResultsRequest] from JSON.
  factory PipelineResultsRequest.fromJson(Map<String, dynamic> json) {
    if (json['pipeline_config_slugs'] == null) {
      throw const FormatException(
        'PipelineResultsRequest: missing pipeline_config_slugs',
      );
    }
    return PipelineResultsRequest(
      pipelineConfigSlugs: (json['pipeline_config_slugs'] as List<Object?>)
          .map((item) => item! as String)
          .toList(),
      searchExpression: json['search_expression'] == null
          ? null
          : json['search_expression'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'pipeline_config_slugs': pipelineConfigSlugs,
    'search_expression': ?searchExpression,
  };

  /// Creates a copy with the given fields replaced.
  PipelineResultsRequest copyWith({
    List<String>? pipelineConfigSlugs,
    Object? searchExpression = unsetCopyWithValue,
  }) => PipelineResultsRequest(
    pipelineConfigSlugs: pipelineConfigSlugs ?? this.pipelineConfigSlugs,
    searchExpression: searchExpression == unsetCopyWithValue
        ? this.searchExpression
        : searchExpression as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelineResultsRequest &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(pipelineConfigSlugs, other.pipelineConfigSlugs) &&
          searchExpression == other.searchExpression;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(pipelineConfigSlugs),
    searchExpression,
  ]);

  @override
  String toString() =>
      'PipelineResultsRequest('
      'pipelineConfigSlugs: ${pipelineConfigSlugs.length}, '
      'searchExpression: $searchExpression)';
}

/// The PipelinesResponse wire payload.
@immutable
class PipelinesResponse {
  /// Creates a [PipelinesResponse].
  const PipelinesResponse({required this.pipelines});

  /// The pipelines field.
  final PaginatedResult<Pipeline> pipelines;

  /// Parses a [PipelinesResponse] from JSON.
  factory PipelinesResponse.fromJson(Map<String, dynamic> json) {
    if (json['pipelines'] == null) {
      throw const FormatException('PipelinesResponse: missing pipelines');
    }
    return PipelinesResponse(
      pipelines: PaginatedResult<Pipeline>.fromJson(
        json['pipelines'] as Map<String, dynamic>,
        Pipeline.fromJson,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'pipelines': pipelines.toJson((item) => item.toJson()),
  };

  /// Creates a copy with the given fields replaced.
  PipelinesResponse copyWith({PaginatedResult<Pipeline>? pipelines}) =>
      PipelinesResponse(pipelines: pipelines ?? this.pipelines);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelinesResponse &&
          runtimeType == other.runtimeType &&
          pipelines == other.pipelines;

  @override
  int get hashCode => Object.hashAll([pipelines]);

  @override
  String toString() =>
      'PipelinesResponse('
      'pipelines: $pipelines)';
}

/// The ProbabilisticSampling wire payload.
@immutable
final class ProbabilisticSampling extends PipelineConfigSampling {
  /// Creates a [ProbabilisticSampling].
  const ProbabilisticSampling({required this.percentage});

  /// The fixed type discriminator.
  String get type => 'probabilistic';

  /// The percentage field.
  final double percentage;

  /// Parses a [ProbabilisticSampling] from JSON.
  factory ProbabilisticSampling.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'probabilistic') {
      throw FormatException('ProbabilisticSampling: unexpected type $value');
    }
    if (json['percentage'] == null) {
      throw const FormatException('ProbabilisticSampling: missing percentage');
    }
    return ProbabilisticSampling(
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'percentage': percentage};

  /// Creates a copy with the given fields replaced.
  ProbabilisticSampling copyWith({double? percentage}) =>
      ProbabilisticSampling(percentage: percentage ?? this.percentage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProbabilisticSampling &&
          runtimeType == other.runtimeType &&
          percentage == other.percentage;

  @override
  int get hashCode => Object.hashAll([percentage]);

  @override
  String toString() =>
      'ProbabilisticSampling('
      'percentage: $percentage)';
}

/// Values for PipelineSourceKind.
enum PipelineSourceKind {
  /// Represents span.
  span('span'),

  /// Represents log.
  log('log'),

  /// Represents metric.
  metric('metric'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const PipelineSourceKind(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static PipelineSourceKind fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The UpdatePipelineRequest wire payload.
@immutable
class UpdatePipelineRequest {
  /// Creates a [UpdatePipelineRequest].
  const UpdatePipelineRequest({
    this.definitions,
    this._description = unsetCopyWithValue,
    this.enabled,
    this.name,
    this.selectors,
  });

  /// The definitions field.
  final List<LlmJudgeReference>? definitions;

  /// The description field.
  final Object? _description;

  /// The optional description. Passing null replaces an existing value.
  String? get description =>
      _description == unsetCopyWithValue ? null : _description as String?;

  /// The enabled field.
  final bool? enabled;

  /// The name field.
  final String? name;

  /// The selectors field.
  final List<PipelineConfigSelector>? selectors;

  /// Parses a [UpdatePipelineRequest] from JSON.
  factory UpdatePipelineRequest.fromJson(Map<String, dynamic> json) {
    return UpdatePipelineRequest(
      definitions: json['definitions'] == null
          ? null
          : (json['definitions'] as List<Object?>)
                .map(
                  (item) =>
                      LlmJudgeReference.fromJson(item! as Map<String, dynamic>),
                )
                .toList(),
      description: json.containsKey('description')
          ? json['description']
          : unsetCopyWithValue,
      enabled: json['enabled'] == null ? null : json['enabled'] as bool,
      name: json['name'] == null ? null : json['name'] as String,
      selectors: json['selectors'] == null
          ? null
          : (json['selectors'] as List<Object?>)
                .map(
                  (item) => PipelineConfigSelector.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (definitions != null)
      'definitions': definitions!.map((item) => item.toJson()).toList(),
    if (_description != unsetCopyWithValue) 'description': description,
    'enabled': ?enabled,
    'name': ?name,
    if (selectors != null)
      'selectors': selectors!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  UpdatePipelineRequest copyWith({
    Object? definitions = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? enabled = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? selectors = unsetCopyWithValue,
  }) => UpdatePipelineRequest(
    definitions: definitions == unsetCopyWithValue
        ? this.definitions
        : (definitions as List<Object?>?)?.cast<LlmJudgeReference>(),
    description: description == unsetCopyWithValue ? _description : description,
    enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    selectors: selectors == unsetCopyWithValue
        ? this.selectors
        : (selectors as List<Object?>?)?.cast<PipelineConfigSelector>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatePipelineRequest &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(definitions, other.definitions) &&
          _description == other._description &&
          enabled == other.enabled &&
          name == other.name &&
          valuesDeepEqual(selectors, other.selectors);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(definitions),
    _description,
    enabled,
    name,
    valueDeepHashCode(selectors),
  ]);

  @override
  String toString() =>
      'UpdatePipelineRequest('
      'definitions: ${definitions?.length}, '
      'description: $description, '
      'enabled: $enabled, '
      'name: $name, '
      'selectors: ${selectors?.length})';
}

/// A variant of [PipelineResultField] returned or accepted by Observability.
sealed class PipelineResultField {
  const PipelineResultField();

  /// Decodes a variant from its API representation.
  factory PipelineResultField.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'ENUM' => OtelEnumFieldDefinition.fromJson(json),
        'FLOAT' => OtelFloatFieldDefinition.fromJson(json),
        _ => UnknownPipelineResultField(json),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A server variant of [PipelineResultField] unknown to this client.
@immutable
final class UnknownPipelineResultField extends PipelineResultField {
  /// Retains the original payload.
  UnknownPipelineResultField(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The unrecognized payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownPipelineResultField && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}
