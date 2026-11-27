import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Log probabilities for the tokens of a completion choice.
@immutable
class ChatChoiceLogprobs {
  /// Log probabilities in token order.
  final List<ChatTokenLogprobTopK> content;

  /// Creates the log probabilities for a choice.
  const ChatChoiceLogprobs({required this.content});

  /// Creates a [ChatChoiceLogprobs] from JSON.
  factory ChatChoiceLogprobs.fromJson(Map<String, dynamic> json) {
    final content = _required<List<Object?>>(json, 'content');
    return ChatChoiceLogprobs(
      content: content.map(ChatTokenLogprobTopK._parse).toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'content': content.map((token) => token.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ChatChoiceLogprobs copyWith({List<ChatTokenLogprobTopK>? content}) =>
      ChatChoiceLogprobs(content: content ?? this.content);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatChoiceLogprobs &&
          runtimeType == other.runtimeType &&
          listsEqual(content, other.content);

  @override
  int get hashCode => listHash(content);

  @override
  String toString() => 'ChatChoiceLogprobs(content: $content)';
}

/// The log probability of a single token.
@immutable
class ChatTokenLogprob {
  /// The text representation of the token.
  final String token;

  /// The token's log probability.
  final double logprob;

  /// The bytes of the token as returned by the API.
  final List<int> bytes;

  /// The token's ID in the model vocabulary.
  final int tokenId;

  /// Creates a token log probability.
  const ChatTokenLogprob({
    required this.token,
    required this.logprob,
    required this.bytes,
    required this.tokenId,
  });

  /// Creates a [ChatTokenLogprob] from JSON.
  factory ChatTokenLogprob.fromJson(Map<String, dynamic> json) =>
      ChatTokenLogprob(
        token: _required<String>(json, 'token'),
        logprob: _required<num>(json, 'logprob').toDouble(),
        bytes: _parseBytes(json),
        tokenId: _required<int>(json, 'token_id'),
      );

  factory ChatTokenLogprob._parse(Object? value) =>
      ChatTokenLogprob.fromJson(_asObject(value));

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'token': token,
    'logprob': logprob,
    'bytes': bytes,
    'token_id': tokenId,
  };

  /// Creates a copy with the given fields replaced.
  ChatTokenLogprob copyWith({
    String? token,
    double? logprob,
    List<int>? bytes,
    int? tokenId,
  }) => ChatTokenLogprob(
    token: token ?? this.token,
    logprob: logprob ?? this.logprob,
    bytes: bytes ?? this.bytes,
    tokenId: tokenId ?? this.tokenId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatTokenLogprob &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          logprob == other.logprob &&
          listsEqual(bytes, other.bytes) &&
          tokenId == other.tokenId;

  @override
  int get hashCode => Object.hash(token, logprob, listHash(bytes), tokenId);

  @override
  String toString() =>
      'ChatTokenLogprob(token: $token, logprob: $logprob, '
      'bytes: $bytes, tokenId: $tokenId)';
}

/// A token's log probability with optional candidates for its position.
@immutable
class ChatTokenLogprobTopK {
  /// The text representation of the token.
  final String token;

  /// The token's log probability.
  final double logprob;

  /// The bytes of the token as returned by the API.
  final List<int> bytes;

  /// The token's ID in the model vocabulary.
  final int tokenId;

  /// Log probabilities of the highest-ranked alternative tokens, when requested.
  final List<ChatTokenLogprob>? topLogprobs;

  /// Creates a token log probability with optional alternatives.
  const ChatTokenLogprobTopK({
    required this.token,
    required this.logprob,
    required this.bytes,
    required this.tokenId,
    this.topLogprobs,
  });

  /// Creates a [ChatTokenLogprobTopK] from JSON.
  factory ChatTokenLogprobTopK.fromJson(Map<String, dynamic> json) =>
      ChatTokenLogprobTopK(
        token: _required<String>(json, 'token'),
        logprob: _required<num>(json, 'logprob').toDouble(),
        bytes: _parseBytes(json),
        tokenId: _required<int>(json, 'token_id'),
        topLogprobs: json['top_logprobs'] == null
            ? null
            : _required<List<Object?>>(
                json,
                'top_logprobs',
              ).map(ChatTokenLogprob._parse).toList(),
      );

  factory ChatTokenLogprobTopK._parse(Object? value) =>
      ChatTokenLogprobTopK.fromJson(_asObject(value));

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'token': token,
    'logprob': logprob,
    'bytes': bytes,
    'token_id': tokenId,
    if (topLogprobs != null)
      'top_logprobs': topLogprobs!.map((token) => token.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ChatTokenLogprobTopK copyWith({
    String? token,
    double? logprob,
    List<int>? bytes,
    int? tokenId,
    Object? topLogprobs = unsetCopyWithValue,
  }) => ChatTokenLogprobTopK(
    token: token ?? this.token,
    logprob: logprob ?? this.logprob,
    bytes: bytes ?? this.bytes,
    tokenId: tokenId ?? this.tokenId,
    topLogprobs: topLogprobs == unsetCopyWithValue
        ? this.topLogprobs
        : topLogprobs as List<ChatTokenLogprob>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatTokenLogprobTopK &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          logprob == other.logprob &&
          listsEqual(bytes, other.bytes) &&
          tokenId == other.tokenId &&
          listsEqual(topLogprobs, other.topLogprobs);

  @override
  int get hashCode => Object.hash(
    token,
    logprob,
    listHash(bytes),
    tokenId,
    listHash(topLogprobs),
  );

  @override
  String toString() =>
      'ChatTokenLogprobTopK(token: $token, logprob: $logprob, '
      'bytes: $bytes, tokenId: $tokenId, topLogprobs: $topLogprobs)';
}

T _required<T>(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! T) {
    throw FormatException('Expected $T for log probability field "$key"');
  }
  return value;
}

Map<String, dynamic> _asObject(Object? value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Expected a token log probability object');
  }
  return value;
}

List<int> _parseBytes(Map<String, dynamic> json) =>
    _required<List<Object?>>(json, 'bytes').map((value) {
      if (value is! int) {
        throw const FormatException('Expected integer entries in "bytes"');
      }
      return value;
    }).toList();
