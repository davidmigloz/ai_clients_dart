import '../copy_with_sentinel.dart';
import 'harm_category.dart';

/// Threshold for blocking harmful content.
enum HarmBlockThreshold {
  /// Unspecified threshold.
  unspecified,

  /// Block low and above.
  blockLowAndAbove,

  /// Block medium and above.
  blockMediumAndAbove,

  /// Block only high.
  blockOnlyHigh,

  /// Block none.
  blockNone,

  /// Off (no blocking).
  off,
}

/// Converts string to HarmBlockThreshold enum.
HarmBlockThreshold harmBlockThresholdFromString(String? value) {
  return switch (value?.toUpperCase()) {
    'BLOCK_LOW_AND_ABOVE' => HarmBlockThreshold.blockLowAndAbove,
    'BLOCK_MEDIUM_AND_ABOVE' => HarmBlockThreshold.blockMediumAndAbove,
    'BLOCK_ONLY_HIGH' => HarmBlockThreshold.blockOnlyHigh,
    'BLOCK_NONE' => HarmBlockThreshold.blockNone,
    'OFF' => HarmBlockThreshold.off,
    _ => HarmBlockThreshold.unspecified,
  };
}

/// Converts HarmBlockThreshold enum to string.
String harmBlockThresholdToString(HarmBlockThreshold threshold) {
  return switch (threshold) {
    HarmBlockThreshold.blockLowAndAbove => 'BLOCK_LOW_AND_ABOVE',
    HarmBlockThreshold.blockMediumAndAbove => 'BLOCK_MEDIUM_AND_ABOVE',
    HarmBlockThreshold.blockOnlyHigh => 'BLOCK_ONLY_HIGH',
    HarmBlockThreshold.blockNone => 'BLOCK_NONE',
    HarmBlockThreshold.off => 'OFF',
    HarmBlockThreshold.unspecified => 'HARM_BLOCK_THRESHOLD_UNSPECIFIED',
  };
}

/// Selects the score used for safety blocking on Vertex AI.
enum HarmBlockMethod {
  /// Uses the Vertex AI default blocking method.
  unspecified('HARM_BLOCK_METHOD_UNSPECIFIED'),

  /// Uses both severity and probability scores.
  severity('SEVERITY'),

  /// Uses the probability score.
  probability('PROBABILITY');

  const HarmBlockMethod(this.value);

  /// The wire value for this method.
  final String value;

  /// Parses a wire value.
  static HarmBlockMethod fromJson(String value) =>
      switch (value.toUpperCase()) {
        'SEVERITY' => severity,
        'PROBABILITY' => probability,
        _ => unspecified,
      };

  /// Returns the wire value for this method.
  String toJson() => value;
}

/// Safety setting to block content at different thresholds.
class SafetySetting {
  /// The category for this setting.
  final HarmCategory category;

  /// The threshold for blocking.
  final HarmBlockThreshold threshold;

  /// The blocking method for Vertex AI. Omit on the Gemini Developer API.
  final HarmBlockMethod? method;

  /// Creates a [SafetySetting].
  const SafetySetting({
    required this.category,
    required this.threshold,
    this.method,
  });

  /// Creates a [SafetySetting] from JSON.
  factory SafetySetting.fromJson(Map<String, dynamic> json) => SafetySetting(
    category: harmCategoryFromString(json['category'] as String?),
    threshold: harmBlockThresholdFromString(json['threshold'] as String?),
    method: json['method'] == null
        ? null
        : HarmBlockMethod.fromJson(json['method'] as String),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'category': harmCategoryToString(category),
    'threshold': harmBlockThresholdToString(threshold),
    'method': ?method?.toJson(),
  };

  /// Creates a copy with replaced values.
  SafetySetting copyWith({
    Object? category = unsetCopyWithValue,
    Object? threshold = unsetCopyWithValue,
    Object? method = unsetCopyWithValue,
  }) {
    return SafetySetting(
      category: category == unsetCopyWithValue
          ? this.category
          : category! as HarmCategory,
      threshold: threshold == unsetCopyWithValue
          ? this.threshold
          : threshold! as HarmBlockThreshold,
      method: method == unsetCopyWithValue
          ? this.method
          : method as HarmBlockMethod?,
    );
  }
}
