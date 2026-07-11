import '../copy_with_sentinel.dart';

/// Harm categories that can be blocked by an [InteractionSafetySetting].
enum InteractionHarmCategory {
  /// Content that promotes violence or incites hatred against individuals or
  /// groups based on certain attributes.
  hateSpeech,

  /// Content that promotes, facilitates, or enables dangerous activities.
  dangerousContent,

  /// Abusive, threatening, or content intended to bully, torment, or ridicule.
  harassment,

  /// Content that contains sexually explicit material.
  sexuallyExplicit,

  /// Deprecated: Election filter is not longer supported. The harm category
  /// is civic integrity.
  civicIntegrity,

  /// Images that contain hate speech.
  imageHate,

  /// Images that contain dangerous content.
  imageDangerousContent,

  /// Images that contain harassment.
  imageHarassment,

  /// Images that contain sexually explicit content.
  imageSexuallyExplicit,

  /// Prompts designed to bypass safety filters.
  jailbreak,

  /// Unknown harm category (for forward compatibility).
  unknown,
}

/// Converts a string to [InteractionHarmCategory].
///
/// Returns [InteractionHarmCategory.unknown] for unrecognized values.
InteractionHarmCategory interactionHarmCategoryFromString(String? value) {
  return switch (value) {
    'hate_speech' => InteractionHarmCategory.hateSpeech,
    'dangerous_content' => InteractionHarmCategory.dangerousContent,
    'harassment' => InteractionHarmCategory.harassment,
    'sexually_explicit' => InteractionHarmCategory.sexuallyExplicit,
    'civic_integrity' => InteractionHarmCategory.civicIntegrity,
    'image_hate' => InteractionHarmCategory.imageHate,
    'image_dangerous_content' => InteractionHarmCategory.imageDangerousContent,
    'image_harassment' => InteractionHarmCategory.imageHarassment,
    'image_sexually_explicit' => InteractionHarmCategory.imageSexuallyExplicit,
    'jailbreak' => InteractionHarmCategory.jailbreak,
    _ => InteractionHarmCategory.unknown,
  };
}

/// Converts [InteractionHarmCategory] to a string.
String interactionHarmCategoryToString(InteractionHarmCategory category) {
  return switch (category) {
    InteractionHarmCategory.hateSpeech => 'hate_speech',
    InteractionHarmCategory.dangerousContent => 'dangerous_content',
    InteractionHarmCategory.harassment => 'harassment',
    InteractionHarmCategory.sexuallyExplicit => 'sexually_explicit',
    InteractionHarmCategory.civicIntegrity => 'civic_integrity',
    InteractionHarmCategory.imageHate => 'image_hate',
    InteractionHarmCategory.imageDangerousContent => 'image_dangerous_content',
    InteractionHarmCategory.imageHarassment => 'image_harassment',
    InteractionHarmCategory.imageSexuallyExplicit => 'image_sexually_explicit',
    InteractionHarmCategory.jailbreak => 'jailbreak',
    InteractionHarmCategory.unknown => 'unknown',
  };
}

/// The threshold for blocking content in an [InteractionSafetySetting].
enum InteractionHarmBlockThreshold {
  /// Block content with a low harm probability or higher.
  blockLowAndAbove,

  /// Block content with a medium harm probability or higher.
  blockMediumAndAbove,

  /// Block content with a high harm probability.
  blockOnlyHigh,

  /// Do not block any content, regardless of its harm probability.
  blockNone,

  /// Turn off the safety filter entirely.
  off,

  /// Unknown threshold (for forward compatibility).
  unknown,
}

/// Converts a string to [InteractionHarmBlockThreshold].
///
/// Returns [InteractionHarmBlockThreshold.unknown] for unrecognized values.
InteractionHarmBlockThreshold interactionHarmBlockThresholdFromString(
  String? value,
) {
  return switch (value) {
    'block_low_and_above' => InteractionHarmBlockThreshold.blockLowAndAbove,
    'block_medium_and_above' =>
      InteractionHarmBlockThreshold.blockMediumAndAbove,
    'block_only_high' => InteractionHarmBlockThreshold.blockOnlyHigh,
    'block_none' => InteractionHarmBlockThreshold.blockNone,
    'off' => InteractionHarmBlockThreshold.off,
    _ => InteractionHarmBlockThreshold.unknown,
  };
}

/// Converts [InteractionHarmBlockThreshold] to a string.
String interactionHarmBlockThresholdToString(
  InteractionHarmBlockThreshold threshold,
) {
  return switch (threshold) {
    InteractionHarmBlockThreshold.blockLowAndAbove => 'block_low_and_above',
    InteractionHarmBlockThreshold.blockMediumAndAbove =>
      'block_medium_and_above',
    InteractionHarmBlockThreshold.blockOnlyHigh => 'block_only_high',
    InteractionHarmBlockThreshold.blockNone => 'block_none',
    InteractionHarmBlockThreshold.off => 'off',
    InteractionHarmBlockThreshold.unknown => 'unknown',
  };
}

/// The method for blocking content in an [InteractionSafetySetting].
enum InteractionSafetyMethod {
  /// The harm block method uses both probability and severity scores.
  severity,

  /// The harm block method uses the probability score.
  probability,
}

/// Converts a string to an [InteractionSafetyMethod], or `null` if
/// unrecognized (forward-compatible).
InteractionSafetyMethod? interactionSafetyMethodFromString(String? value) {
  return switch (value) {
    'severity' => InteractionSafetyMethod.severity,
    'probability' => InteractionSafetyMethod.probability,
    _ => null,
  };
}

/// Converts an [InteractionSafetyMethod] to its JSON string.
String interactionSafetyMethodToString(InteractionSafetyMethod method) {
  return switch (method) {
    InteractionSafetyMethod.severity => 'severity',
    InteractionSafetyMethod.probability => 'probability',
  };
}

/// A safety setting that affects the safety-blocking behavior of an
/// interaction.
///
/// A [InteractionSafetySetting] consists of a harm category and a threshold
/// for that category.
class InteractionSafetySetting {
  /// Required. The type of harm category to be blocked.
  final InteractionHarmCategory type;

  /// Required. The threshold for blocking content. If the harm probability
  /// exceeds this threshold, the content will be blocked.
  final InteractionHarmBlockThreshold threshold;

  /// Optional. The method for blocking content. If not specified, the
  /// default behavior is to use the probability score.
  final InteractionSafetyMethod? method;

  /// Creates an [InteractionSafetySetting].
  const InteractionSafetySetting({
    required this.type,
    required this.threshold,
    this.method,
  });

  /// Creates an [InteractionSafetySetting] from JSON.
  factory InteractionSafetySetting.fromJson(Map<String, dynamic> json) =>
      InteractionSafetySetting(
        type: interactionHarmCategoryFromString(json['type'] as String?),
        threshold: interactionHarmBlockThresholdFromString(
          json['threshold'] as String?,
        ),
        method: interactionSafetyMethodFromString(json['method'] as String?),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': interactionHarmCategoryToString(type),
    'threshold': interactionHarmBlockThresholdToString(threshold),
    if (method != null) 'method': interactionSafetyMethodToString(method!),
  };

  /// Creates a copy with replaced values.
  InteractionSafetySetting copyWith({
    Object? type = unsetCopyWithValue,
    Object? threshold = unsetCopyWithValue,
    Object? method = unsetCopyWithValue,
  }) {
    return InteractionSafetySetting(
      type: type == unsetCopyWithValue
          ? this.type
          : type! as InteractionHarmCategory,
      threshold: threshold == unsetCopyWithValue
          ? this.threshold
          : threshold! as InteractionHarmBlockThreshold,
      method: method == unsetCopyWithValue
          ? this.method
          : method as InteractionSafetyMethod?,
    );
  }
}
