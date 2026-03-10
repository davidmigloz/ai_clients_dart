import 'package:meta/meta.dart';

/// Action to take when moderation detects a violation.
enum ModerationLLMV1Action {
  /// Block the request.
  block('block'),

  /// Take no action (log only).
  none('none');

  const ModerationLLMV1Action(this.value);

  /// The string value of this action.
  final String value;

  /// Creates from a string value.
  static ModerationLLMV1Action fromString(String? value) => switch (value) {
    'block' => block,
    'none' => none,
    _ => none,
  };
}

/// Custom thresholds for moderation categories.
///
/// Each threshold is a number between 0.0 and 1.0, where lower values
/// are more sensitive (more likely to flag content).
@immutable
class ModerationLLMV1CategoryThresholds {
  /// Threshold for dangerous and criminal content.
  final double? dangerousAndCriminalContent;

  /// Threshold for financial content.
  final double? financial;

  /// Threshold for hate and discrimination.
  final double? hateAndDiscrimination;

  /// Threshold for health-related content.
  final double? health;

  /// Threshold for legal content.
  final double? law;

  /// Threshold for personally identifiable information.
  final double? pii;

  /// Threshold for self-harm content.
  final double? selfharm;

  /// Threshold for sexual content.
  final double? sexual;

  /// Threshold for violence and threats.
  final double? violenceAndThreats;

  /// Creates [ModerationLLMV1CategoryThresholds].
  const ModerationLLMV1CategoryThresholds({
    this.dangerousAndCriminalContent,
    this.financial,
    this.hateAndDiscrimination,
    this.health,
    this.law,
    this.pii,
    this.selfharm,
    this.sexual,
    this.violenceAndThreats,
  });

  /// Creates from JSON.
  factory ModerationLLMV1CategoryThresholds.fromJson(
    Map<String, dynamic> json,
  ) => ModerationLLMV1CategoryThresholds(
    dangerousAndCriminalContent:
        (json['dangerous_and_criminal_content'] as num?)?.toDouble(),
    financial: (json['financial'] as num?)?.toDouble(),
    hateAndDiscrimination: (json['hate_and_discrimination'] as num?)
        ?.toDouble(),
    health: (json['health'] as num?)?.toDouble(),
    law: (json['law'] as num?)?.toDouble(),
    pii: (json['pii'] as num?)?.toDouble(),
    selfharm: (json['selfharm'] as num?)?.toDouble(),
    sexual: (json['sexual'] as num?)?.toDouble(),
    violenceAndThreats: (json['violence_and_threats'] as num?)?.toDouble(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (dangerousAndCriminalContent != null)
      'dangerous_and_criminal_content': dangerousAndCriminalContent,
    if (financial != null) 'financial': financial,
    if (hateAndDiscrimination != null)
      'hate_and_discrimination': hateAndDiscrimination,
    if (health != null) 'health': health,
    if (law != null) 'law': law,
    if (pii != null) 'pii': pii,
    if (selfharm != null) 'selfharm': selfharm,
    if (sexual != null) 'sexual': sexual,
    if (violenceAndThreats != null) 'violence_and_threats': violenceAndThreats,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationLLMV1CategoryThresholds &&
          runtimeType == other.runtimeType &&
          dangerousAndCriminalContent == other.dangerousAndCriminalContent &&
          financial == other.financial &&
          hateAndDiscrimination == other.hateAndDiscrimination &&
          health == other.health &&
          law == other.law &&
          pii == other.pii &&
          selfharm == other.selfharm &&
          sexual == other.sexual &&
          violenceAndThreats == other.violenceAndThreats;

  @override
  int get hashCode => Object.hash(
    dangerousAndCriminalContent,
    financial,
    hateAndDiscrimination,
    health,
    law,
    pii,
    selfharm,
    sexual,
    violenceAndThreats,
  );

  @override
  String toString() => 'ModerationLLMV1CategoryThresholds(...)';
}

/// Configuration for LLM-based moderation.
@immutable
class ModerationLLMV1Config {
  /// Action to take when moderation detects a violation.
  final ModerationLLMV1Action? action;

  /// Custom category thresholds.
  final ModerationLLMV1CategoryThresholds? customCategoryThresholds;

  /// Whether to ignore categories not in the custom thresholds.
  final bool? ignoreOtherCategories;

  /// The moderation model to use.
  final String? modelName;

  /// Creates a [ModerationLLMV1Config].
  const ModerationLLMV1Config({
    this.action,
    this.customCategoryThresholds,
    this.ignoreOtherCategories,
    this.modelName,
  });

  /// Creates from JSON.
  factory ModerationLLMV1Config.fromJson(Map<String, dynamic> json) =>
      ModerationLLMV1Config(
        action: json['action'] != null
            ? ModerationLLMV1Action.fromString(json['action'] as String?)
            : null,
        customCategoryThresholds: json['custom_category_thresholds'] != null
            ? ModerationLLMV1CategoryThresholds.fromJson(
                json['custom_category_thresholds'] as Map<String, dynamic>,
              )
            : null,
        ignoreOtherCategories: json['ignore_other_categories'] as bool?,
        modelName: json['model_name'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (action != null) 'action': action!.value,
    if (customCategoryThresholds != null)
      'custom_category_thresholds': customCategoryThresholds!.toJson(),
    if (ignoreOtherCategories != null)
      'ignore_other_categories': ignoreOtherCategories,
    if (modelName != null) 'model_name': modelName,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationLLMV1Config &&
          runtimeType == other.runtimeType &&
          action == other.action &&
          customCategoryThresholds == other.customCategoryThresholds &&
          ignoreOtherCategories == other.ignoreOtherCategories &&
          modelName == other.modelName;

  @override
  int get hashCode => Object.hash(
    action,
    customCategoryThresholds,
    ignoreOtherCategories,
    modelName,
  );

  @override
  String toString() =>
      'ModerationLLMV1Config(action: $action, '
      'modelName: $modelName)';
}

/// Guardrail configuration for content moderation.
@immutable
class GuardrailConfig {
  /// If true, return HTTP 403 and block request on server-side error.
  final bool blockOnError;

  /// LLM-based moderation configuration.
  final ModerationLLMV1Config? moderationLlmV1;

  /// Creates a [GuardrailConfig].
  const GuardrailConfig({this.blockOnError = false, this.moderationLlmV1});

  /// Creates from JSON.
  factory GuardrailConfig.fromJson(Map<String, dynamic> json) =>
      GuardrailConfig(
        blockOnError: json['block_on_error'] as bool? ?? false,
        moderationLlmV1: json['moderation_llm_v1'] != null
            ? ModerationLLMV1Config.fromJson(
                json['moderation_llm_v1'] as Map<String, dynamic>,
              )
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'block_on_error': blockOnError,
    if (moderationLlmV1 != null) 'moderation_llm_v1': moderationLlmV1!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuardrailConfig &&
          runtimeType == other.runtimeType &&
          blockOnError == other.blockOnError &&
          moderationLlmV1 == other.moderationLlmV1;

  @override
  int get hashCode => Object.hash(blockOnError, moderationLlmV1);

  @override
  String toString() =>
      'GuardrailConfig(blockOnError: $blockOnError, '
      'moderationLlmV1: $moderationLlmV1)';
}
