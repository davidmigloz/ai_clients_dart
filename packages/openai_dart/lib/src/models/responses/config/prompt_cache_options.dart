import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';

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

  /// Creates a [PromptCacheOptions].
  const PromptCacheOptions({required this.mode, required this.ttl});

  /// Creates a [PromptCacheOptions] from JSON.
  factory PromptCacheOptions.fromJson(Map<String, dynamic> json) {
    return PromptCacheOptions(
      mode: PromptCacheMode.fromJson(json['mode'] as String),
      ttl: PromptCacheTtl.fromJson(json['ttl'] as String),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'mode': mode.toJson(), 'ttl': ttl.toJson()};

  /// Creates a copy with the given fields replaced.
  PromptCacheOptions copyWith({PromptCacheMode? mode, PromptCacheTtl? ttl}) =>
      PromptCacheOptions(mode: mode ?? this.mode, ttl: ttl ?? this.ttl);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptCacheOptions &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          ttl == other.ttl;

  @override
  int get hashCode => Object.hash(mode, ttl);

  @override
  String toString() => 'PromptCacheOptions(mode: $mode, ttl: $ttl)';
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
      mode: json['mode'] != null
          ? PromptCacheMode.fromJson(json['mode'] as String)
          : null,
      ttl: json['ttl'] != null
          ? PromptCacheTtl.fromJson(json['ttl'] as String)
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
