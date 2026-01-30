import 'dart:math' as math;

import 'package:meta/meta.dart';

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Logprobs &&
          runtimeType == other.runtimeType &&
          _listEquals(content, other.content) &&
          _listEquals(refusal, other.refusal);

  @override
  int get hashCode => Object.hash(
    content != null ? Object.hashAll(content!) : null,
    refusal != null ? Object.hashAll(refusal!) : null,
  );

  @override
  String toString() => 'Logprobs(content: $content, refusal: $refusal)';

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
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
  String toString() => 'TokenLogprob(token: $token, logprob: $logprob)';
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopLogprob &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          logprob == other.logprob;

  @override
  int get hashCode => Object.hash(token, logprob);

  @override
  String toString() => 'TopLogprob(token: $token, logprob: $logprob)';
}

/// Converts a log probability to a regular probability.
double _logprobToProbability(double logprob) {
  // e^logprob = probability
  // Handle special case for very low log probabilities
  if (logprob <= -9998) return 0.0;
  return math.exp(logprob);
}
