import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'decision_helpers.dart';

/// The minimum cache lifetime supported by Decisions.
enum DecisionCacheTtl {
  /// Cache shared input for at least 30 minutes.
  thirtyMinutes('30m');

  const DecisionCacheTtl(this.value);

  /// The API value.
  final String value;

  /// Reads a supported Decisions lifetime.
  factory DecisionCacheTtl.fromJson(String value) => switch (value) {
    '30m' => thirtyMinutes,
    _ => throw const FormatException('DecisionCacheTtl: expected "30m"'),
  };

  /// Converts to the API value.
  String toJson() => value;
}

/// Whether shared-input cache boundaries are implicit or explicitly marked.
enum DecisionCacheMode {
  /// Also use the server's implicit boundary at the end of shared input.
  implicit('implicit'),

  /// Only use boundaries explicitly marked in shared input parts.
  explicit('explicit');

  const DecisionCacheMode(this.value);

  /// The API value.
  final String value;

  /// Reads a supported cache mode.
  factory DecisionCacheMode.fromJson(String value) => switch (value) {
    'implicit' => implicit,
    'explicit' => explicit,
    _ => throw const FormatException('DecisionCacheMode: invalid mode'),
  };

  /// Converts to the API value.
  String toJson() => value;
}

/// Cache options for shared Decisions input; question content is not cached.
@immutable
class DecisionPromptCacheOptions {
  /// Creates options. Omission uses the server defaults, 30m and implicit.
  const DecisionPromptCacheOptions({this.ttl, this.mode});

  /// Minimum lifetime. Decisions does not support Responses' 12h lifetime.
  final DecisionCacheTtl? ttl;

  /// Optional cache-boundary policy.
  final DecisionCacheMode? mode;

  /// Reads options without admitting unsupported fields or lifetimes.
  factory DecisionPromptCacheOptions.fromJson(Map<String, dynamic> json) {
    requireDecisionKeys(json, {'ttl', 'mode'}, 'DecisionPromptCacheOptions');
    return DecisionPromptCacheOptions(
      ttl: json.containsKey('ttl')
          ? DecisionCacheTtl.fromJson(
              requireDecisionString(
                json['ttl'],
                'DecisionPromptCacheOptions.ttl',
              ),
            )
          : null,
      mode: json['mode'] == null
          ? null
          : DecisionCacheMode.fromJson(
              requireDecisionString(
                json['mode'],
                'DecisionPromptCacheOptions.mode',
              ),
            ),
    );
  }

  /// Converts options to JSON, omitting absent defaults.
  Map<String, dynamic> toJson() => {
    if (ttl != null) 'ttl': ttl!.toJson(),
    if (mode != null) 'mode': mode!.toJson(),
  };

  /// Copies options; explicit null clears either optional value.
  DecisionPromptCacheOptions copyWith({
    Object? ttl = unsetCopyWithValue,
    Object? mode = unsetCopyWithValue,
  }) => DecisionPromptCacheOptions(
    ttl: identical(ttl, unsetCopyWithValue)
        ? this.ttl
        : ttl as DecisionCacheTtl?,
    mode: identical(mode, unsetCopyWithValue)
        ? this.mode
        : mode as DecisionCacheMode?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionPromptCacheOptions &&
          ttl == other.ttl &&
          mode == other.mode;

  @override
  int get hashCode => Object.hash(ttl, mode);

  @override
  String toString() => 'DecisionPromptCacheOptions(ttl: $ttl, mode: $mode)';
}

/// An explicit boundary on shared input text or images.
///
/// This marker has no TTL override and cannot appear in question instructions.
@immutable
class DecisionPromptCacheBreakpoint {
  /// Creates an explicit shared-input boundary.
  const DecisionPromptCacheBreakpoint();

  /// Always explicit.
  String get mode => 'explicit';

  /// Reads the exact Decisions breakpoint shape.
  factory DecisionPromptCacheBreakpoint.fromJson(Map<String, dynamic> json) {
    requireDecisionKeys(json, {'mode'}, 'DecisionPromptCacheBreakpoint');
    if (json['mode'] != 'explicit') {
      throw const FormatException(
        'DecisionPromptCacheBreakpoint.mode: expected explicit',
      );
    }
    return const DecisionPromptCacheBreakpoint();
  }

  /// Converts the marker to JSON.
  Map<String, dynamic> toJson() => {'mode': mode};

  @override
  bool operator ==(Object other) => other is DecisionPromptCacheBreakpoint;

  @override
  int get hashCode => mode.hashCode;

  @override
  String toString() => 'DecisionPromptCacheBreakpoint(mode: explicit)';
}
