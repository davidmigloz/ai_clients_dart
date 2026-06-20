import 'package:meta/meta.dart';

import '../beta/config/output_config.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../metadata/speed.dart';
import '../metadata/stop_reason.dart';
import 'thinking_config.dart';

/// One entry in the `fallbacks` chain on a message create request.
///
/// [model] is required. The four override fields ([maxTokens], [thinking],
/// [outputConfig], and [speed]) replace the corresponding top-level field for
/// this attempt only and are validated as if the request were made to [model].
///
/// The schema is open (`additionalProperties: true`): any unknown keys are
/// preserved in [extra] for forward compatibility.
@immutable
class FallbackConfigV2 {
  /// The fallback model to attempt.
  final String model;

  /// Overrides the top-level `max_tokens` for this fallback attempt only.
  final int? maxTokens;

  /// Overrides the top-level extended thinking configuration for this
  /// fallback attempt only.
  final ThinkingConfig? thinking;

  /// Overrides the top-level output behavior configuration for this fallback
  /// attempt only.
  final OutputConfig? outputConfig;

  /// Overrides the top-level inference speed mode for this fallback attempt
  /// only.
  final Speed? speed;

  /// Undeclared keys preserved for forward compatibility.
  final Map<String, dynamic>? extra;

  /// Creates a [FallbackConfigV2].
  const FallbackConfigV2({
    required this.model,
    this.maxTokens,
    this.thinking,
    this.outputConfig,
    this.speed,
    this.extra,
  });

  /// JSON keys backed by a declared, typed field on this class.
  static const _knownKeys = {
    'model',
    'max_tokens',
    'thinking',
    'output_config',
    'speed',
  };

  /// Creates a [FallbackConfigV2] from JSON.
  factory FallbackConfigV2.fromJson(Map<String, dynamic> json) {
    final extraEntries = {
      for (final entry in json.entries)
        if (!_knownKeys.contains(entry.key)) entry.key: entry.value,
    };
    return FallbackConfigV2(
      model: json['model'] as String,
      maxTokens: json['max_tokens'] as int?,
      thinking: json['thinking'] != null
          ? ThinkingConfig.fromJson(json['thinking'] as Map<String, dynamic>)
          : null,
      outputConfig: json['output_config'] != null
          ? OutputConfig.fromJson(json['output_config'] as Map<String, dynamic>)
          : null,
      speed: json['speed'] != null
          ? Speed.fromJson(json['speed'] as String)
          : null,
      extra: extraEntries.isEmpty ? null : extraEntries,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    // Spread only undeclared keys so `extra` can never emit or override a
    // declared field (e.g. a stray `max_tokens` in `extra` when the typed
    // `maxTokens` is null).
    if (extra != null)
      for (final entry in extra!.entries)
        if (!_knownKeys.contains(entry.key)) entry.key: entry.value,
    'model': model,
    if (maxTokens != null) 'max_tokens': maxTokens,
    if (thinking != null) 'thinking': thinking!.toJson(),
    if (outputConfig != null) 'output_config': outputConfig!.toJson(),
    if (speed != null) 'speed': speed!.toJson(),
  };

  /// Creates a copy with replaced values.
  FallbackConfigV2 copyWith({
    String? model,
    Object? maxTokens = unsetCopyWithValue,
    Object? thinking = unsetCopyWithValue,
    Object? outputConfig = unsetCopyWithValue,
    Object? speed = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) {
    return FallbackConfigV2(
      model: model ?? this.model,
      maxTokens: maxTokens == unsetCopyWithValue
          ? this.maxTokens
          : maxTokens as int?,
      thinking: thinking == unsetCopyWithValue
          ? this.thinking
          : thinking as ThinkingConfig?,
      outputConfig: outputConfig == unsetCopyWithValue
          ? this.outputConfig
          : outputConfig as OutputConfig?,
      speed: speed == unsetCopyWithValue ? this.speed : speed as Speed?,
      extra: extra == unsetCopyWithValue
          ? this.extra
          : extra as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FallbackConfigV2 &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          maxTokens == other.maxTokens &&
          thinking == other.thinking &&
          outputConfig == other.outputConfig &&
          speed == other.speed &&
          mapsDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hash(
    model,
    maxTokens,
    thinking,
    outputConfig,
    speed,
    mapDeepHashCode(extra),
  );

  @override
  String toString() =>
      'FallbackConfigV2(model: $model, maxTokens: $maxTokens, '
      'thinking: $thinking, outputConfig: $outputConfig, speed: $speed, '
      'extra: $extra)';
}

/// Identifies one hop of a fallback transition.
///
/// Used by both request and response fallback blocks.
@immutable
class FallbackHopInfo {
  /// The model for this hop.
  final String model;

  /// Creates a [FallbackHopInfo].
  const FallbackHopInfo({required this.model});

  /// Creates a [FallbackHopInfo] from JSON.
  factory FallbackHopInfo.fromJson(Map<String, dynamic> json) {
    return FallbackHopInfo(model: json['model'] as String);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'model': model};

  /// Creates a copy with replaced values.
  FallbackHopInfo copyWith({String? model}) {
    return FallbackHopInfo(model: model ?? this.model);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FallbackHopInfo &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;

  @override
  String toString() => 'FallbackHopInfo(model: $model)';
}

/// What caused the `from` model to hand over at a fallback hop.
///
/// Currently the only trigger is a policy refusal by the `from` model.
@immutable
class FallbackRefusalTrigger {
  /// The raw policy-category string from the API.
  ///
  /// Preserved for round-trip fidelity — unrecognized categories are stored
  /// verbatim and serialized back unchanged. `null` when the refusal doesn't
  /// map to a named category.
  final String? rawCategory;

  /// The parsed policy category that triggered the `from` model's refusal at
  /// this hop, derived from [rawCategory].
  ///
  /// `null` when [rawCategory] is `null`. Same vocabulary as
  /// `stop_details.category`.
  RefusalCategory? get category =>
      rawCategory == null ? null : RefusalCategory.fromJson(rawCategory!);

  /// Object type. Always "refusal".
  String get type => 'refusal';

  /// Creates a [FallbackRefusalTrigger].
  const FallbackRefusalTrigger({this.rawCategory});

  /// Creates a [FallbackRefusalTrigger] from JSON.
  factory FallbackRefusalTrigger.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'refusal') {
      throw FormatException(
        'FallbackRefusalTrigger: expected type "refusal", got "$type"',
      );
    }
    if (!json.containsKey('category')) {
      throw const FormatException(
        'FallbackRefusalTrigger: missing required field "category"',
      );
    }
    return FallbackRefusalTrigger(rawCategory: json['category'] as String?);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'category': rawCategory};

  /// Creates a copy with replaced values.
  FallbackRefusalTrigger copyWith({Object? rawCategory = unsetCopyWithValue}) {
    return FallbackRefusalTrigger(
      rawCategory: rawCategory == unsetCopyWithValue
          ? this.rawCategory
          : rawCategory as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FallbackRefusalTrigger &&
          runtimeType == other.runtimeType &&
          rawCategory == other.rawCategory;

  @override
  int get hashCode => rawCategory.hashCode;

  @override
  String toString() =>
      'FallbackRefusalTrigger(category: $category, rawCategory: $rawCategory)';
}
