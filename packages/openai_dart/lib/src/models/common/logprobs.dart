import 'dart:math' as math;

import 'package:meta/meta.dart';

import 'copy_with_sentinel.dart';
import 'equality_helpers.dart';

/// Log probability information for a token.
///
/// Provides detailed probability information for each token in the response,
/// useful for understanding model confidence and debugging.
@immutable
class Logprobs {
  /// Creates a [Logprobs].
  const Logprobs({this.content, this.refusal});

  /// Creates a [Logprobs] from JSON.
  factory Logprobs.fromJson(Map<String, dynamic> json) {
    return Logprobs(
      content: (json['content'] as List<dynamic>?)
          ?.map((e) => TokenLogprob.fromJson(e as Map<String, dynamic>))
          .toList(),
      refusal: (json['refusal'] as List<dynamic>?)
          ?.map((e) => TokenLogprob.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// A list of message content tokens with log probability information.
  final List<TokenLogprob>? content;

  /// A list of message refusal tokens with log probability information.
  final List<TokenLogprob>? refusal;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (content != null) 'content': content!.map((e) => e.toJson()).toList(),
    if (refusal != null) 'refusal': refusal!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy; nullable token lists can be explicitly cleared.
  Logprobs copyWith({
    Object? content = unsetCopyWithValue,
    Object? refusal = unsetCopyWithValue,
  }) => Logprobs(
    content: content == unsetCopyWithValue
        ? this.content
        : content == null
        ? null
        : List<TokenLogprob>.from(content as List<dynamic>),
    refusal: refusal == unsetCopyWithValue
        ? this.refusal
        : refusal == null
        ? null
        : List<TokenLogprob>.from(refusal as List<dynamic>),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Logprobs &&
          runtimeType == other.runtimeType &&
          listsEqual(content, other.content) &&
          listsEqual(refusal, other.refusal);

  @override
  int get hashCode => Object.hash(listHash(content), listHash(refusal));

  @override
  String toString() =>
      'Logprobs(content: ${_listSummary(content)}, refusal: ${_listSummary(refusal)})';
}

/// Log probability information for a single token.
@immutable
class TokenLogprob {
  /// Creates a [TokenLogprob].
  const TokenLogprob({
    required this.token,
    required this.logprob,
    this.bytes,
    this.topLogprobs,
  });

  /// Creates a [TokenLogprob] from JSON.
  factory TokenLogprob.fromJson(Map<String, dynamic> json) {
    return TokenLogprob(
      token: json['token'] as String,
      logprob: (json['logprob'] as num).toDouble(),
      bytes: (json['bytes'] as List<dynamic>?)?.cast<int>(),
      topLogprobs: (json['top_logprobs'] as List<dynamic>?)
          ?.map((e) => TopLogprob.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The token string.
  final String token;

  /// The log probability of this token.
  ///
  /// -9999.0 indicates the token was sampled from a partial output
  /// for continued generation.
  final double logprob;

  /// A list of integers representing the UTF-8 bytes representation of
  /// the token.
  ///
  /// Can be null if there is no bytes representation for the token.
  final List<int>? bytes;

  /// List of the most likely tokens and their log probability.
  final List<TopLogprob>? topLogprobs;

  /// The probability of this token (converted from log probability).
  double get probability => _logprobToProbability(logprob);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'token': token,
    'logprob': logprob,
    if (bytes != null) 'bytes': bytes,
    if (topLogprobs != null)
      'top_logprobs': topLogprobs!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy; nullable bytes and alternatives can be explicitly cleared.
  TokenLogprob copyWith({
    String? token,
    double? logprob,
    Object? bytes = unsetCopyWithValue,
    Object? topLogprobs = unsetCopyWithValue,
  }) => TokenLogprob(
    token: token ?? this.token,
    logprob: logprob ?? this.logprob,
    bytes: bytes == unsetCopyWithValue
        ? this.bytes
        : bytes == null
        ? null
        : List<int>.from(bytes as List<dynamic>),
    topLogprobs: topLogprobs == unsetCopyWithValue
        ? this.topLogprobs
        : topLogprobs == null
        ? null
        : List<TopLogprob>.from(topLogprobs as List<dynamic>),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenLogprob &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          logprob == other.logprob &&
          listsEqual(bytes, other.bytes) &&
          listsEqual(topLogprobs, other.topLogprobs);

  @override
  int get hashCode =>
      Object.hash(token, logprob, listHash(bytes), listHash(topLogprobs));

  @override
  String toString() =>
      'TokenLogprob(token: $token, logprob: $logprob, '
      'bytes: ${_listSummary(bytes)}, topLogprobs: ${_listSummary(topLogprobs)})';
}

/// Information about a top log probability token alternative.
@immutable
class TopLogprob {
  /// Creates a [TopLogprob].
  const TopLogprob({required this.token, required this.logprob, this.bytes});

  /// Creates a [TopLogprob] from JSON.
  factory TopLogprob.fromJson(Map<String, dynamic> json) {
    return TopLogprob(
      token: json['token'] as String,
      logprob: (json['logprob'] as num).toDouble(),
      bytes: (json['bytes'] as List<dynamic>?)?.cast<int>(),
    );
  }

  /// The token string.
  final String token;

  /// The log probability of this token.
  final double logprob;

  /// The UTF-8 bytes representation of the token.
  final List<int>? bytes;

  /// The probability of this token (converted from log probability).
  double get probability => _logprobToProbability(logprob);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'token': token,
    'logprob': logprob,
    if (bytes != null) 'bytes': bytes,
  };

  /// Creates a copy; nullable bytes can be explicitly cleared.
  TopLogprob copyWith({
    String? token,
    double? logprob,
    Object? bytes = unsetCopyWithValue,
  }) => TopLogprob(
    token: token ?? this.token,
    logprob: logprob ?? this.logprob,
    bytes: bytes == unsetCopyWithValue
        ? this.bytes
        : bytes == null
        ? null
        : List<int>.from(bytes as List<dynamic>),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopLogprob &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          logprob == other.logprob &&
          listsEqual(bytes, other.bytes);

  @override
  int get hashCode => Object.hash(token, logprob, listHash(bytes));

  @override
  String toString() =>
      'TopLogprob(token: $token, logprob: $logprob, '
      'bytes: ${_listSummary(bytes)})';
}

/// Converts a log probability to a regular probability.
double _logprobToProbability(double logprob) {
  // e^logprob = probability
  // Handle special case for very low log probabilities
  if (logprob <= -9998) return 0.0;
  return math.exp(logprob);
}

String _listSummary(List<dynamic>? list) =>
    list == null ? 'null' : '${list.length} items';
