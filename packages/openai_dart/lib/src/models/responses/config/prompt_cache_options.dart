import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/json_helpers.dart';

/// Whether implicit prompt-cache breakpoints are enabled.
enum PromptCacheMode {
  /// Unknown mode (fallback for unrecognized values).
  unknown('unknown'),

  /// OpenAI creates one implicit breakpoint and writes up to the latest
  /// three explicit breakpoints in the request.
  implicit('implicit'),

  /// OpenAI does not create an implicit breakpoint and writes up to the
  /// latest four explicit breakpoints. If there are no explicit
  /// breakpoints, the request does not use prompt caching.
  explicit('explicit');

  /// The JSON value for this mode.
  final String value;

  const PromptCacheMode(this.value);

  /// Creates a [PromptCacheMode] from a JSON value.
  factory PromptCacheMode.fromJson(String json) {
    return PromptCacheMode.values.firstWhere(
      (e) => e.value == json,
      orElse: () => PromptCacheMode.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}

/// The minimum lifetime applied to a prompt cache breakpoint.
enum PromptCacheTtl {
  /// Unknown TTL (fallback for unrecognized values).
  unknown('unknown'),

  /// 30-minute cache lifetime.
  ///
  /// Currently the only supported value.
  minutes30('30m');

  /// The JSON value for this TTL.
  final String value;

  const PromptCacheTtl(this.value);

  /// Creates a [PromptCacheTtl] from a JSON value.
  factory PromptCacheTtl.fromJson(String json) {
    return PromptCacheTtl.values.firstWhere(
      (e) => e.value == json,
      orElse: () => PromptCacheTtl.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}

/// The prompt-caching options that were applied to the response.
///
/// Supported for `gpt-5.6` and later models.
@immutable
class PromptCacheOptions {
  /// Whether implicit prompt-cache breakpoints were enabled.
  final PromptCacheMode mode;

  /// The minimum lifetime applied to each cache breakpoint.
  final PromptCacheTtl ttl;

  /// The requested baseline response ID, when supplied for diagnostics.
  final String? comparisonResponseId;

  /// Creates a [PromptCacheOptions].
  const PromptCacheOptions({
    required this.mode,
    required this.ttl,
    this.comparisonResponseId,
  });

  /// Creates a [PromptCacheOptions] from JSON.
  factory PromptCacheOptions.fromJson(Map<String, dynamic> json) {
    return PromptCacheOptions(
      mode: PromptCacheMode.fromJson(
        requireJsonString(json['mode'], 'PromptCacheOptions.mode'),
      ),
      ttl: PromptCacheTtl.fromJson(
        requireJsonString(json['ttl'], 'PromptCacheOptions.ttl'),
      ),
      comparisonResponseId: optionalJsonString(
        json,
        'comparison_response_id',
        'PromptCacheOptions',
        nullable: true,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'mode': mode.toJson(),
    'ttl': ttl.toJson(),
    if (comparisonResponseId != null)
      'comparison_response_id': comparisonResponseId,
  };

  /// Creates a copy with the given fields replaced.
  PromptCacheOptions copyWith({
    PromptCacheMode? mode,
    PromptCacheTtl? ttl,
    Object? comparisonResponseId = unsetCopyWithValue,
  }) => PromptCacheOptions(
    mode: mode ?? this.mode,
    ttl: ttl ?? this.ttl,
    comparisonResponseId: comparisonResponseId == unsetCopyWithValue
        ? this.comparisonResponseId
        : comparisonResponseId as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptCacheOptions &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          ttl == other.ttl &&
          comparisonResponseId == other.comparisonResponseId;

  @override
  int get hashCode => Object.hash(mode, ttl, comparisonResponseId);

  @override
  String toString() =>
      'PromptCacheOptions(mode: $mode, ttl: $ttl, '
      'comparisonResponseId: $comparisonResponseId)';
}

/// Options for prompt caching.
///
/// Supported for `gpt-5.6` and later models. By default, OpenAI automatically
/// chooses one implicit cache breakpoint. You can add explicit breakpoints to
/// content blocks with `prompt_cache_breakpoint`. Each request can write up to
/// four breakpoints. For cache matching, OpenAI considers up to the latest 80
/// breakpoints in the conversation, without a content-block lookback limit.
/// Set [mode] to [PromptCacheMode.explicit] to disable the implicit
/// breakpoint. The [ttl] defaults to [PromptCacheTtl.minutes30], which is
/// currently the only supported value. See the
/// [prompt caching guide](https://platform.openai.com/docs/guides/prompt-caching)
/// for current details.
@immutable
class PromptCacheOptionsParam {
  /// Controls whether OpenAI automatically creates an implicit cache
  /// breakpoint.
  ///
  /// Defaults to [PromptCacheMode.implicit]. With [PromptCacheMode.implicit],
  /// OpenAI creates one implicit breakpoint and writes up to the latest three
  /// explicit breakpoints in the request. With [PromptCacheMode.explicit],
  /// OpenAI does not create an implicit breakpoint and writes up to the
  /// latest four explicit breakpoints. If there are no explicit breakpoints,
  /// the request does not use prompt caching.
  final PromptCacheMode? mode;

  /// The minimum lifetime applied to every implicit and explicit cache
  /// breakpoint written by the request.
  ///
  /// Defaults to [PromptCacheTtl.minutes30], which is currently the only
  /// supported value. The backend may retain cache entries for longer.
  final PromptCacheTtl? ttl;

  /// Creates a [PromptCacheOptionsParam].
  const PromptCacheOptionsParam({this.mode, this.ttl});

  /// Creates a [PromptCacheOptionsParam] from JSON.
  factory PromptCacheOptionsParam.fromJson(Map<String, dynamic> json) {
    return PromptCacheOptionsParam(
      mode: json.containsKey('mode')
          ? PromptCacheMode.fromJson(
              requireJsonString(json['mode'], 'PromptCacheOptionsParam.mode'),
            )
          : null,
      ttl: json.containsKey('ttl')
          ? PromptCacheTtl.fromJson(
              requireJsonString(json['ttl'], 'PromptCacheOptionsParam.ttl'),
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (mode != null) 'mode': mode!.toJson(),
    if (ttl != null) 'ttl': ttl!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  PromptCacheOptionsParam copyWith({
    Object? mode = unsetCopyWithValue,
    Object? ttl = unsetCopyWithValue,
  }) {
    return PromptCacheOptionsParam(
      mode: mode == unsetCopyWithValue ? this.mode : mode as PromptCacheMode?,
      ttl: ttl == unsetCopyWithValue ? this.ttl : ttl as PromptCacheTtl?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptCacheOptionsParam &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          ttl == other.ttl;

  @override
  int get hashCode => Object.hash(mode, ttl);

  @override
  String toString() => 'PromptCacheOptionsParam(mode: $mode, ttl: $ttl)';
}

/// Responses-specific prompt-cache controls.
///
/// Supported for `gpt-5.6` and later models. [mode] and [ttl] have the same
/// semantics as [PromptCacheOptionsParam]. [prewarm] prepares the cache without
/// generating output, and [comparisonResponseId] requests diagnostics against
/// a completed response in the same organization. It does not load conversation
/// history or change cache matching.
@immutable
class ResponsePromptCacheOptionsParam {
  /// Controls automatic implicit breakpoints. Defaults to implicit.
  final PromptCacheMode? mode;

  /// Minimum lifetime of each written breakpoint. Defaults to 30 minutes.
  final PromptCacheTtl? ttl;

  /// A completed response ID to compare for cache diagnostics.
  final String? comparisonResponseId;

  /// Whether to prepare the prompt cache without generating output.
  final bool? prewarm;

  /// Creates Responses prompt-cache controls.
  const ResponsePromptCacheOptionsParam({
    this.mode,
    this.ttl,
    this.comparisonResponseId,
    this.prewarm,
  });

  /// Creates Responses prompt-cache controls from JSON.
  factory ResponsePromptCacheOptionsParam.fromJson(Map<String, dynamic> json) =>
      ResponsePromptCacheOptionsParam(
        mode: json.containsKey('mode')
            ? PromptCacheMode.fromJson(
                requireJsonString(
                  json['mode'],
                  'ResponsePromptCacheOptionsParam.mode',
                ),
              )
            : null,
        ttl: json.containsKey('ttl')
            ? PromptCacheTtl.fromJson(
                requireJsonString(
                  json['ttl'],
                  'ResponsePromptCacheOptionsParam.ttl',
                ),
              )
            : null,
        comparisonResponseId: optionalJsonString(
          json,
          'comparison_response_id',
          'ResponsePromptCacheOptionsParam',
          nullable: true,
        ),
        prewarm: optionalJsonBool(
          json,
          'prewarm',
          'ResponsePromptCacheOptionsParam',
        ),
      );

  /// Converts to JSON, preserving an empty object and explicit false.
  Map<String, dynamic> toJson() => {
    if (mode != null) 'mode': mode!.toJson(),
    if (ttl != null) 'ttl': ttl!.toJson(),
    if (comparisonResponseId != null)
      'comparison_response_id': comparisonResponseId,
    if (prewarm != null) 'prewarm': prewarm,
  };

  /// Creates a copy; nullable controls can be explicitly cleared.
  ResponsePromptCacheOptionsParam copyWith({
    Object? mode = unsetCopyWithValue,
    Object? ttl = unsetCopyWithValue,
    Object? comparisonResponseId = unsetCopyWithValue,
    Object? prewarm = unsetCopyWithValue,
  }) => ResponsePromptCacheOptionsParam(
    mode: mode == unsetCopyWithValue ? this.mode : mode as PromptCacheMode?,
    ttl: ttl == unsetCopyWithValue ? this.ttl : ttl as PromptCacheTtl?,
    comparisonResponseId: comparisonResponseId == unsetCopyWithValue
        ? this.comparisonResponseId
        : comparisonResponseId as String?,
    prewarm: prewarm == unsetCopyWithValue ? this.prewarm : prewarm as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsePromptCacheOptionsParam &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          ttl == other.ttl &&
          comparisonResponseId == other.comparisonResponseId &&
          prewarm == other.prewarm;

  @override
  int get hashCode => Object.hash(mode, ttl, comparisonResponseId, prewarm);

  @override
  String toString() =>
      'ResponsePromptCacheOptionsParam(mode: $mode, ttl: $ttl, '
      'comparisonResponseId: $comparisonResponseId, prewarm: $prewarm)';
}
