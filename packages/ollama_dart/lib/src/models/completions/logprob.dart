import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Log probability information for a single token alternative.
@immutable
class TokenLogprob {
  /// The text representation of the token.
  final String? token;

  /// The log probability of this token.
  final double? logprob;

  /// The raw byte representation of the token.
  final List<int>? bytes;

  /// Creates a [TokenLogprob].
  const TokenLogprob({this.token, this.logprob, this.bytes});

  /// Creates a [TokenLogprob] from JSON.
  factory TokenLogprob.fromJson(Map<String, dynamic> json) => TokenLogprob(
    token: json['token'] as String?,
    logprob: (json['logprob'] as num?)?.toDouble(),
    bytes: (json['bytes'] as List?)?.cast<int>(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (token != null) 'token': token,
    if (logprob != null) 'logprob': logprob,
    if (bytes != null) 'bytes': bytes,
  };

  /// Creates a copy with replaced values.
  TokenLogprob copyWith({
    Object? token = unsetCopyWithValue,
    Object? logprob = unsetCopyWithValue,
    Object? bytes = unsetCopyWithValue,
  }) {
    return TokenLogprob(
      token: token == unsetCopyWithValue ? this.token : token as String?,
      logprob: logprob == unsetCopyWithValue
          ? this.logprob
          : logprob as double?,
      bytes: bytes == unsetCopyWithValue ? this.bytes : bytes as List<int>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenLogprob &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          logprob == other.logprob;

  @override
  int get hashCode => Object.hash(token, logprob);

  @override
  String toString() =>
      'TokenLogprob('
      'token: $token, '
      'logprob: $logprob, '
      'bytes: $bytes)';
}

/// Log probability information for a generated token.
@immutable
class Logprob {
  /// The text representation of the token.
  final String? token;

  /// The log probability of this token.
  final double? logprob;

  /// The raw byte representation of the token.
  final List<int>? bytes;

  /// Most likely tokens and their log probabilities at this position.
  final List<TokenLogprob>? topLogprobs;

  /// Creates a [Logprob].
  const Logprob({this.token, this.logprob, this.bytes, this.topLogprobs});

  /// Creates a [Logprob] from JSON.
  factory Logprob.fromJson(Map<String, dynamic> json) => Logprob(
    token: json['token'] as String?,
    logprob: (json['logprob'] as num?)?.toDouble(),
    bytes: (json['bytes'] as List?)?.cast<int>(),
    topLogprobs: (json['top_logprobs'] as List?)
        ?.map((e) => TokenLogprob.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (token != null) 'token': token,
    if (logprob != null) 'logprob': logprob,
    if (bytes != null) 'bytes': bytes,
    if (topLogprobs != null)
      'top_logprobs': topLogprobs!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  Logprob copyWith({
    Object? token = unsetCopyWithValue,
    Object? logprob = unsetCopyWithValue,
    Object? bytes = unsetCopyWithValue,
    Object? topLogprobs = unsetCopyWithValue,
  }) {
    return Logprob(
      token: token == unsetCopyWithValue ? this.token : token as String?,
      logprob: logprob == unsetCopyWithValue
          ? this.logprob
          : logprob as double?,
      bytes: bytes == unsetCopyWithValue ? this.bytes : bytes as List<int>?,
      topLogprobs: topLogprobs == unsetCopyWithValue
          ? this.topLogprobs
          : topLogprobs as List<TokenLogprob>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Logprob &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          logprob == other.logprob;

  @override
  int get hashCode => Object.hash(token, logprob);

  @override
  String toString() =>
      'Logprob('
      'token: $token, '
      'logprob: $logprob, '
      'bytes: $bytes, '
      'topLogprobs: $topLogprobs)';
}
