import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';

/// Why a prompt cache prefix could not be reused.
///
/// Future reason strings are preserved in [value].
@immutable
class CacheMissReason {
  /// The response model changed.
  static const modelChanged = CacheMissReason('model_changed');

  /// The prompt-cache key changed.
  static const promptCacheKeyChanged = CacheMissReason(
    'prompt_cache_key_changed',
  );

  /// The available tools changed.
  static const toolsChanged = CacheMissReason('tools_changed');

  /// The requested output format changed.
  static const textFormatChanged = CacheMissReason('text_format_changed');

  /// The reasoning effort changed.
  static const reasoningEffortChanged = CacheMissReason(
    'reasoning_effort_changed',
  );

  /// The verbosity changed.
  static const verbosityChanged = CacheMissReason('verbosity_changed');

  /// The conversation context was compacted.
  static const contextCompacted = CacheMissReason('context_compacted');

  /// The input changed.
  static const inputChanged = CacheMissReason('input_changed');

  /// The service tier changed.
  static const serviceTierChanged = CacheMissReason('service_tier_changed');

  /// The exact wire value, including unrecognized future reasons.
  final String value;

  /// Creates a cache miss reason.
  const CacheMissReason(this.value);

  /// Creates a reason from its JSON string.
  factory CacheMissReason.fromJson(Object? json) =>
      CacheMissReason(requireJsonString(json, 'CacheMissReason'));

  /// Converts to the wire string.
  String toJson() => value;

  /// Creates a copy with a different wire string.
  CacheMissReason copyWith({String? value}) =>
      CacheMissReason(value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheMissReason &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'CacheMissReason($value)';
}

/// Prompt-cache diagnostics for a Responses API result.
///
/// A result can be a cache hit, a miss with a reason and token counts, a missing
/// comparison response, or unavailable diagnostics. Future variants retain an
/// immutable raw payload through [UnknownPromptCacheDiagnostics]. Diagnostics
/// can be absent and do not guarantee reuse of every input token.
///
/// Variants: [PromptCacheMissDiagnostics], [PromptCacheHitDiagnostics],
/// [PromptCacheComparisonResponseNotFoundDiagnostics],
/// [PromptCacheUnavailableDiagnostics], and [UnknownPromptCacheDiagnostics].
@immutable
sealed class PromptCacheDiagnostics {
  const PromptCacheDiagnostics();

  /// A cache miss with its reason and token counts.
  const factory PromptCacheDiagnostics.cacheMiss({
    required CacheMissReason reason,
    required int cacheMissedTokens,
    int? comparisonReusableTokens,
  }) = PromptCacheMissDiagnostics;

  /// A cache hit.
  const factory PromptCacheDiagnostics.cacheHit() = PromptCacheHitDiagnostics;

  /// The requested comparison response could not be found.
  const factory PromptCacheDiagnostics.comparisonResponseNotFound() =
      PromptCacheComparisonResponseNotFoundDiagnostics;

  /// Cache diagnostics were unavailable.
  const factory PromptCacheDiagnostics.unavailable() =
      PromptCacheUnavailableDiagnostics;

  /// Parses a diagnostic, validating known variants and preserving future ones.
  factory PromptCacheDiagnostics.fromJson(Map<String, dynamic> json) {
    final type = requireJsonString(json['type'], 'PromptCacheDiagnostics.type');
    return switch (type) {
      'cache_miss' => PromptCacheMissDiagnostics.fromJson(json),
      'cache_hit' => PromptCacheHitDiagnostics.fromJson(json),
      'comparison_response_not_found' =>
        PromptCacheComparisonResponseNotFoundDiagnostics.fromJson(json),
      'unavailable' => PromptCacheUnavailableDiagnostics.fromJson(json),
      _ => UnknownPromptCacheDiagnostics(json),
    };
  }

  /// The diagnostic discriminator.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A cache miss with a reason and token counts.
@immutable
class PromptCacheMissDiagnostics extends PromptCacheDiagnostics {
  /// The reason a prefix was not reused.
  final CacheMissReason reason;

  /// Estimated input tokens affected after the first detected cache divergence.
  ///
  /// This diagnostic estimate can differ from usage counters. Use the response's
  /// usage fields to measure actual cache reuse and billing.
  final int cacheMissedTokens;

  /// Raw token count of the comparison response's reusable prefix.
  final int? comparisonReusableTokens;

  /// Creates cache-miss diagnostics.
  const PromptCacheMissDiagnostics({
    required this.reason,
    required this.cacheMissedTokens,
    this.comparisonReusableTokens,
  });

  /// Creates cache-miss diagnostics from JSON.
  factory PromptCacheMissDiagnostics.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'cache_miss', 'PromptCacheMissDiagnostics');
    return PromptCacheMissDiagnostics(
      reason: CacheMissReason.fromJson(
        requireJsonString(json['reason'], 'PromptCacheMissDiagnostics.reason'),
      ),
      cacheMissedTokens: requireJsonInt(
        json['cache_missed_tokens'],
        'PromptCacheMissDiagnostics.cache_missed_tokens',
      ),
      comparisonReusableTokens: optionalJsonInt(
        json,
        'comparison_reusable_tokens',
        'PromptCacheMissDiagnostics',
      ),
    );
  }

  @override
  String get type => 'cache_miss';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'reason': reason.toJson(),
    'cache_missed_tokens': cacheMissedTokens,
    if (comparisonReusableTokens != null)
      'comparison_reusable_tokens': comparisonReusableTokens,
  };

  /// Creates a copy; the optional comparison count can be explicitly cleared.
  PromptCacheMissDiagnostics copyWith({
    CacheMissReason? reason,
    int? cacheMissedTokens,
    Object? comparisonReusableTokens = unsetCopyWithValue,
  }) => PromptCacheMissDiagnostics(
    reason: reason ?? this.reason,
    cacheMissedTokens: cacheMissedTokens ?? this.cacheMissedTokens,
    comparisonReusableTokens: comparisonReusableTokens == unsetCopyWithValue
        ? this.comparisonReusableTokens
        : comparisonReusableTokens as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptCacheMissDiagnostics &&
          runtimeType == other.runtimeType &&
          reason == other.reason &&
          cacheMissedTokens == other.cacheMissedTokens &&
          comparisonReusableTokens == other.comparisonReusableTokens;

  @override
  int get hashCode =>
      Object.hash(reason, cacheMissedTokens, comparisonReusableTokens);

  @override
  String toString() =>
      'PromptCacheMissDiagnostics(reason: $reason, '
      'cacheMissedTokens: $cacheMissedTokens, '
      'comparisonReusableTokens: $comparisonReusableTokens)';
}

/// The prompt cache was hit.
@immutable
class PromptCacheHitDiagnostics extends PromptCacheDiagnostics {
  /// Creates cache-hit diagnostics.
  const PromptCacheHitDiagnostics();

  /// Creates cache-hit diagnostics from JSON.
  factory PromptCacheHitDiagnostics.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'cache_hit', 'PromptCacheHitDiagnostics');
    return const PromptCacheHitDiagnostics();
  }

  @override
  String get type => 'cache_hit';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates an equivalent copy.
  PromptCacheHitDiagnostics copyWith() => const PromptCacheHitDiagnostics();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptCacheHitDiagnostics && runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'PromptCacheHitDiagnostics()';
}

/// The requested comparison response was not found.
@immutable
class PromptCacheComparisonResponseNotFoundDiagnostics
    extends PromptCacheDiagnostics {
  /// Creates comparison-not-found diagnostics.
  const PromptCacheComparisonResponseNotFoundDiagnostics();

  /// Creates comparison-not-found diagnostics from JSON.
  factory PromptCacheComparisonResponseNotFoundDiagnostics.fromJson(
    Map<String, dynamic> json,
  ) {
    requireJsonType(
      json,
      'comparison_response_not_found',
      'PromptCacheComparisonResponseNotFoundDiagnostics',
    );
    return const PromptCacheComparisonResponseNotFoundDiagnostics();
  }

  @override
  String get type => 'comparison_response_not_found';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates an equivalent copy.
  PromptCacheComparisonResponseNotFoundDiagnostics copyWith() =>
      const PromptCacheComparisonResponseNotFoundDiagnostics();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptCacheComparisonResponseNotFoundDiagnostics &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'PromptCacheComparisonResponseNotFoundDiagnostics()';
}

/// Prompt-cache diagnostics were unavailable.
@immutable
class PromptCacheUnavailableDiagnostics extends PromptCacheDiagnostics {
  /// Creates unavailable diagnostics.
  const PromptCacheUnavailableDiagnostics();

  /// Creates unavailable diagnostics from JSON.
  factory PromptCacheUnavailableDiagnostics.fromJson(
    Map<String, dynamic> json,
  ) {
    requireJsonType(json, 'unavailable', 'PromptCacheUnavailableDiagnostics');
    return const PromptCacheUnavailableDiagnostics();
  }

  @override
  String get type => 'unavailable';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates an equivalent copy.
  PromptCacheUnavailableDiagnostics copyWith() =>
      const PromptCacheUnavailableDiagnostics();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptCacheUnavailableDiagnostics &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'PromptCacheUnavailableDiagnostics()';
}

/// An unrecognized diagnostic with a recursively immutable JSON snapshot.
@immutable
class UnknownPromptCacheDiagnostics extends PromptCacheDiagnostics {
  /// The complete future diagnostic object.
  final Map<String, dynamic> rawJson;

  /// Creates an unknown diagnostic, validating its string discriminator.
  UnknownPromptCacheDiagnostics(Map<String, dynamic> json)
    : rawJson = freezeJsonObject(json) {
    requireJsonString(rawJson['type'], 'UnknownPromptCacheDiagnostics.type');
  }

  /// Creates an unknown diagnostic from JSON.
  factory UnknownPromptCacheDiagnostics.fromJson(Map<String, dynamic> json) =>
      UnknownPromptCacheDiagnostics(json);

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => rawJson;

  /// Creates a fresh immutable snapshot, replacing the complete payload if given.
  UnknownPromptCacheDiagnostics copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownPromptCacheDiagnostics(rawJson ?? this.rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownPromptCacheDiagnostics &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() =>
      'UnknownPromptCacheDiagnostics(type: $type, '
      'fields: ${rawJson.length})';
}
