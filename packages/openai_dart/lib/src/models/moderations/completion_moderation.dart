import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// The input modality a moderation category score applies to.
///
/// Returned within [ModerationResultBody.categoryAppliedInputTypes].
enum ModerationInputType {
  /// Unknown modality (fallback for unrecognized values).
  unknown('unknown'),

  /// Text input.
  text('text'),

  /// Image input.
  image('image');

  const ModerationInputType(this.value);

  /// The JSON value for this modality.
  final String value;

  /// Creates a [ModerationInputType] from a JSON value.
  factory ModerationInputType.fromJson(String json) {
    return ModerationInputType.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ModerationInputType.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}

/// Configuration for running moderation on the input and generated output of a
/// generation request.
///
/// Pass this as the `moderation` field of a Chat Completions or Responses
/// request to receive [ChatCompletionModeration]/[Moderation] results for both
/// the request input and the generated output in the same response.
///
/// ## Example
///
/// ```dart
/// final request = ChatCompletionCreateRequest(
///   model: 'gpt-5.5',
///   messages: [...],
///   moderation: const ModerationConfig(model: 'omni-moderation-latest'),
/// );
/// ```
@immutable
class ModerationConfig {
  /// Creates a [ModerationConfig].
  const ModerationConfig({required this.model});

  /// Creates a [ModerationConfig] from JSON.
  factory ModerationConfig.fromJson(Map<String, dynamic> json) {
    return ModerationConfig(model: json['model'] as String);
  }

  /// The moderation model to use, e.g. `omni-moderation-latest`.
  final String model;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'model': model};

  /// Creates a copy with the given fields replaced.
  ModerationConfig copyWith({String? model}) =>
      ModerationConfig(model: model ?? this.model);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationConfig &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;

  @override
  String toString() => 'ModerationConfig(model: $model)';
}

/// Moderation results or errors for the input and output of a Responses API
/// response.
///
/// Present on `Response.moderation` when moderated completions were requested
/// via [ModerationConfig].
@immutable
class Moderation {
  /// Creates a [Moderation].
  const Moderation({required this.input, required this.output});

  /// Creates a [Moderation] from JSON.
  factory Moderation.fromJson(Map<String, dynamic> json) {
    return Moderation(
      input: ModerationOutcome.fromJson(json['input'] as Map<String, dynamic>),
      output: ModerationOutcome.fromJson(
        json['output'] as Map<String, dynamic>,
      ),
    );
  }

  /// Moderation for the response input.
  final ModerationOutcome input;

  /// Moderation for the response output.
  final ModerationOutcome output;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input': input.toJson(),
    'output': output.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  Moderation copyWith({ModerationOutcome? input, ModerationOutcome? output}) =>
      Moderation(input: input ?? this.input, output: output ?? this.output);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Moderation &&
          runtimeType == other.runtimeType &&
          input == other.input &&
          output == other.output;

  @override
  int get hashCode => Object.hash(input, output);

  @override
  String toString() => 'Moderation(input: $input, output: $output)';
}

/// A moderation outcome for a single input or output.
///
/// Either a successful [ModerationResultBody] or a [ModerationErrorBody],
/// discriminated by the `type` field.
@immutable
sealed class ModerationOutcome {
  /// Creates a [ModerationOutcome].
  const ModerationOutcome();

  /// Creates a [ModerationOutcome] from JSON, dispatching on `type`.
  factory ModerationOutcome.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'moderation_result' => ModerationResultBody.fromJson(json),
      'error' => ModerationErrorBody.fromJson(json),
      _ => throw FormatException('Unknown moderation outcome type: $type'),
    };
  }

  /// The discriminator type for this outcome.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A successful moderation result produced for a request input or output.
@immutable
class ModerationResultBody extends ModerationOutcome {
  /// Creates a [ModerationResultBody].
  const ModerationResultBody({
    required this.model,
    required this.flagged,
    required this.categories,
    required this.categoryScores,
    required this.categoryAppliedInputTypes,
  });

  /// Creates a [ModerationResultBody] from JSON.
  factory ModerationResultBody.fromJson(Map<String, dynamic> json) {
    return ModerationResultBody(
      model: json['model'] as String,
      flagged: json['flagged'] as bool,
      categories: (json['categories'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as bool),
      ),
      categoryScores: (json['category_scores'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      categoryAppliedInputTypes:
          (json['category_applied_input_types'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
              key,
              (value as List)
                  .map((e) => ModerationInputType.fromJson(e as String))
                  .toList(),
            ),
          ),
    );
  }

  @override
  String get type => 'moderation_result';

  /// The moderation model that produced this result.
  final String model;

  /// Whether the content was flagged by any category.
  final bool flagged;

  /// Moderation categories mapped to whether the content is flagged.
  final Map<String, bool> categories;

  /// Moderation categories mapped to confidence scores.
  final Map<String, double> categoryScores;

  /// Which input modalities each category score applies to.
  final Map<String, List<ModerationInputType>> categoryAppliedInputTypes;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'model': model,
    'flagged': flagged,
    'categories': categories,
    'category_scores': categoryScores,
    'category_applied_input_types': categoryAppliedInputTypes.map(
      (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
    ),
  };

  /// Creates a copy with the given fields replaced.
  ModerationResultBody copyWith({
    String? model,
    bool? flagged,
    Map<String, bool>? categories,
    Map<String, double>? categoryScores,
    Map<String, List<ModerationInputType>>? categoryAppliedInputTypes,
  }) => ModerationResultBody(
    model: model ?? this.model,
    flagged: flagged ?? this.flagged,
    categories: categories ?? this.categories,
    categoryScores: categoryScores ?? this.categoryScores,
    categoryAppliedInputTypes:
        categoryAppliedInputTypes ?? this.categoryAppliedInputTypes,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationResultBody &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          flagged == other.flagged &&
          mapsEqual(categories, other.categories) &&
          mapsEqual(categoryScores, other.categoryScores) &&
          _appliedInputTypesEqual(
            categoryAppliedInputTypes,
            other.categoryAppliedInputTypes,
          );

  @override
  int get hashCode => Object.hash(
    model,
    flagged,
    mapHash(categories),
    mapHash(categoryScores),
    _appliedInputTypesHash(categoryAppliedInputTypes),
  );

  @override
  String toString() =>
      'ModerationResultBody(model: $model, flagged: $flagged, '
      'categories: $categories, categoryScores: $categoryScores, '
      'categoryAppliedInputTypes: $categoryAppliedInputTypes)';
}

/// An error produced while attempting moderation for a request input or output.
@immutable
class ModerationErrorBody extends ModerationOutcome {
  /// Creates a [ModerationErrorBody].
  const ModerationErrorBody({required this.code, required this.message});

  /// Creates a [ModerationErrorBody] from JSON.
  factory ModerationErrorBody.fromJson(Map<String, dynamic> json) {
    return ModerationErrorBody(
      code: json['code'] as String,
      message: json['message'] as String,
    );
  }

  @override
  String get type => 'error';

  /// The error code.
  final String code;

  /// The error message.
  final String message;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'code': code,
    'message': message,
  };

  /// Creates a copy with the given fields replaced.
  ModerationErrorBody copyWith({String? code, String? message}) =>
      ModerationErrorBody(
        code: code ?? this.code,
        message: message ?? this.message,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationErrorBody &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message;

  @override
  int get hashCode => Object.hash(code, message);

  @override
  String toString() => 'ModerationErrorBody(code: $code, message: $message)';
}

bool _appliedInputTypesEqual(
  Map<String, List<ModerationInputType>> a,
  Map<String, List<ModerationInputType>> b,
) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key)) return false;
    if (!listsEqual(entry.value, b[entry.key])) return false;
  }
  return true;
}

int _appliedInputTypesHash(Map<String, List<ModerationInputType>> map) {
  return Object.hashAllUnordered(
    map.entries.map((e) => Object.hash(e.key, Object.hashAll(e.value))),
  );
}
