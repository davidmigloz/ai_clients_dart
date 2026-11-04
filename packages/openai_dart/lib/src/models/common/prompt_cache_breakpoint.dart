import 'package:meta/meta.dart';

import 'copy_with_sentinel.dart';
import 'json_helpers.dart';

/// A Responses breakpoint lifetime, distinct from top-level cache TTL options.
enum PromptCacheBreakpointTtl {
  /// Fallback for a future lifetime in received content.
  unknown('unknown'),

  /// A minimum lifetime of 30 minutes.
  minutes30('30m'),

  /// A minimum lifetime of 12 hours.
  hours12('12h');

  const PromptCacheBreakpointTtl(this.value);

  /// The wire value.
  final String value;

  /// Reads a known value or the forward-compatible fallback.
  factory PromptCacheBreakpointTtl.fromJson(String value) =>
      PromptCacheBreakpointTtl.values.firstWhere(
        (ttl) => ttl.value == value,
        orElse: () => PromptCacheBreakpointTtl.unknown,
      );

  /// Converts to JSON.
  String toJson() => value;
}

/// Marks the exact end of a reusable prompt prefix.
///
/// An omitted [ttl] inherits `prompt_cache_options.ttl`. Responses breakpoints
/// support `30m` and `12h`; the pinned top-level options still admit only `30m`.
/// This shared content model is also used by Chat; model/API support is validated
/// by the server. Decisions has a separate marker without a TTL override.
/// Boundaries are exact, rather than rounded to token blocks. The marker can be
/// requested on input content and echoed back on response content.
@immutable
class PromptCacheBreakpointConfig {
  /// The breakpoint mode. Always `explicit`.
  String get mode => 'explicit';

  /// The minimum lifetime of this breakpoint, or null to inherit the request.
  final PromptCacheBreakpointTtl? ttl;

  /// Creates a [PromptCacheBreakpointConfig].
  const PromptCacheBreakpointConfig({this.ttl});

  /// Reads the fixed mode and optional nonnullable lifetime.
  factory PromptCacheBreakpointConfig.fromJson(Map<String, dynamic> json) {
    if (json['mode'] != 'explicit') {
      throw const FormatException(
        'PromptCacheBreakpointConfig.mode: expected explicit',
      );
    }
    return PromptCacheBreakpointConfig(
      ttl: json.containsKey('ttl')
          ? PromptCacheBreakpointTtl.fromJson(
              requireJsonString(json['ttl'], 'PromptCacheBreakpointConfig.ttl'),
            )
          : null,
    );
  }

  /// Converts to JSON, omitting an inherited TTL.
  Map<String, dynamic> toJson() => {
    'mode': mode,
    if (ttl != null) 'ttl': ttl!.toJson(),
  };

  /// Copies the lifetime; explicit null restores inheritance.
  PromptCacheBreakpointConfig copyWith({Object? ttl = unsetCopyWithValue}) =>
      PromptCacheBreakpointConfig(
        ttl: identical(ttl, unsetCopyWithValue)
            ? this.ttl
            : ttl as PromptCacheBreakpointTtl?,
      );

  @override
  bool operator ==(Object other) =>
      other is PromptCacheBreakpointConfig &&
      runtimeType == other.runtimeType &&
      ttl == other.ttl;

  @override
  int get hashCode => Object.hash(runtimeType, ttl);

  @override
  String toString() => 'PromptCacheBreakpointConfig(mode: $mode, ttl: $ttl)';
}
