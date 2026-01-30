import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Log probability information for a token.
@immutable
class LogProb {
  /// The token string.
  final String token;

  /// The log probability of the token.
  final double logprob;

  /// Optional byte offsets for the token.
  final List<int>? bytes;

  /// Alternative tokens with their log probabilities.
  final List<TopLogProb>? topLogprobs;

  /// Creates a [LogProb].
  const LogProb({
    required this.token,
    required this.logprob,
    this.bytes,
    this.topLogprobs,
  });

  /// Creates a [LogProb] from JSON.
  factory LogProb.fromJson(Map<String, dynamic> json) {
    return LogProb(
      token: json['token'] as String,
      logprob: (json['logprob'] as num).toDouble(),
      bytes: (json['bytes'] as List?)?.cast<int>(),
      topLogprobs: (json['top_logprobs'] as List?)
          ?.map((e) => TopLogProb.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

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
      other is LogProb &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          logprob == other.logprob &&
          listsEqual(bytes, other.bytes) &&
          listsEqual(topLogprobs, other.topLogprobs);

  @override
  int get hashCode => Object.hash(token, logprob, bytes, topLogprobs);

  @override
  String toString() =>
      'LogProb(token: $token, logprob: $logprob, bytes: $bytes, topLogprobs: $topLogprobs)';
}

/// Alternative token with its log probability.
@immutable
class TopLogProb {
  /// The token string.
  final String token;

  /// The log probability of the token.
  final double logprob;

  /// Optional byte offsets for the token.
  final List<int>? bytes;

  /// Creates a [TopLogProb].
  const TopLogProb({required this.token, required this.logprob, this.bytes});

  /// Creates a [TopLogProb] from JSON.
  factory TopLogProb.fromJson(Map<String, dynamic> json) {
    return TopLogProb(
      token: json['token'] as String,
      logprob: (json['logprob'] as num).toDouble(),
      bytes: (json['bytes'] as List?)?.cast<int>(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'token': token,
    'logprob': logprob,
    if (bytes != null) 'bytes': bytes,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopLogProb &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          logprob == other.logprob &&
          listsEqual(bytes, other.bytes);

  @override
  int get hashCode => Object.hash(token, logprob, bytes);

  @override
  String toString() =>
      'TopLogProb(token: $token, logprob: $logprob, bytes: $bytes)';
}
