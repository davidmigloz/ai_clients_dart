import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// How a failing fallback-credit token affects a retry.
enum FallbackCreditMode {
  /// The default, and the bare-string behavior: a failing redemption is a 400
  /// and the retry is not served.
  strict('strict'),

  /// The retry is served either way — a token-layer failure no longer
  /// rejects the request; the retry proceeds at normal price and the outcome
  /// is reported on the response's `usage.fallback_credit`.
  ///
  /// Two failures stay hard in both modes: a malformed token, and combining
  /// `fallback_credit_token` with `fallbacks`.
  bestEffort('best_effort');

  const FallbackCreditMode(this.value);

  /// JSON value for this mode.
  final String value;

  /// Parses a [FallbackCreditMode] from JSON.
  static FallbackCreditMode fromJson(String value) => switch (value) {
    'strict' => strict,
    'best_effort' => bestEffort,
    _ => throw FormatException('Unknown FallbackCreditMode: $value'),
  };

  /// Converts this mode to JSON.
  String toJson() => value;
}

/// `fallback_credit_token` request parameter — either a bare opaque token
/// string, or a [FallbackCreditTokenParamConfig] object pairing the token
/// with a redemption [FallbackCreditMode].
///
/// The bare string and the mode-less object are equivalent (both select
/// [FallbackCreditMode.strict]), so wrapping an existing token changes
/// nothing by itself. The object form requires the
/// `anthropic-beta: fallback-credit-2026-07-01` header; without that header
/// the field accepts the bare string only.
///
/// Variants:
/// - [FallbackCreditTokenParamToken] — a plain opaque token string.
/// - [FallbackCreditTokenParamConfig] — a token plus an optional
///   [FallbackCreditMode].
sealed class FallbackCreditTokenParam {
  const FallbackCreditTokenParam();

  /// Creates a [FallbackCreditTokenParamToken] from a bare token string.
  const factory FallbackCreditTokenParam.token(String token) =
      FallbackCreditTokenParamToken;

  /// Creates a [FallbackCreditTokenParamConfig] with an optional redemption
  /// [mode].
  const factory FallbackCreditTokenParam.config({
    required String token,
    FallbackCreditMode? mode,
  }) = FallbackCreditTokenParamConfig;

  /// Creates a [FallbackCreditTokenParam] from JSON.
  ///
  /// If [json] is a [String], returns [FallbackCreditTokenParamToken].
  /// Otherwise expects a [Map] and returns [FallbackCreditTokenParamConfig].
  static FallbackCreditTokenParam fromJson(Object json) {
    if (json is String) {
      return FallbackCreditTokenParamToken(json);
    }
    return FallbackCreditTokenParamConfig.fromJson(
      json as Map<String, dynamic>,
    );
  }

  /// Converts to JSON.
  Object toJson();
}

/// A plain opaque fallback-credit token string.
@immutable
class FallbackCreditTokenParamToken extends FallbackCreditTokenParam {
  /// The opaque `fallback_credit_token` from a prior refusal's
  /// `stop_details`.
  final String token;

  /// Creates a [FallbackCreditTokenParamToken].
  const FallbackCreditTokenParamToken(this.token);

  @override
  Object toJson() => token;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FallbackCreditTokenParamToken &&
          runtimeType == other.runtimeType &&
          token == other.token;

  @override
  int get hashCode => token.hashCode;

  @override
  String toString() => 'FallbackCreditTokenParamToken(token: [redacted])';
}

/// A fallback-credit token paired with a redemption mode.
@immutable
class FallbackCreditTokenParamConfig extends FallbackCreditTokenParam {
  /// The opaque `fallback_credit_token` from a prior refusal's
  /// `stop_details` — the same string the bare-string form carries.
  final String token;

  /// How a failing token affects the retry.
  final FallbackCreditMode? mode;

  /// Creates a [FallbackCreditTokenParamConfig].
  const FallbackCreditTokenParamConfig({required this.token, this.mode});

  /// Creates a [FallbackCreditTokenParamConfig] from JSON.
  factory FallbackCreditTokenParamConfig.fromJson(Map<String, dynamic> json) {
    return FallbackCreditTokenParamConfig(
      token: json['token'] as String,
      mode: json['mode'] != null
          ? FallbackCreditMode.fromJson(json['mode'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'token': token,
    if (mode != null) 'mode': mode!.toJson(),
  };

  /// Creates a copy with replaced values.
  FallbackCreditTokenParamConfig copyWith({
    String? token,
    Object? mode = unsetCopyWithValue,
  }) => FallbackCreditTokenParamConfig(
    token: token ?? this.token,
    mode: mode == unsetCopyWithValue ? this.mode : mode as FallbackCreditMode?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FallbackCreditTokenParamConfig &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          mode == other.mode;

  @override
  int get hashCode => Object.hash(token, mode);

  @override
  String toString() =>
      'FallbackCreditTokenParamConfig(token: [redacted], mode: $mode)';
}
