import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request-level cache diagnostics parameters (Beta).
///
/// Opts a request into prompt-cache diagnostics, optionally anchoring the
/// diagnosis to the immediately preceding turn so the API can report which
/// portion of the cached prefix missed.
///
/// Requires the `cache-diagnosis-2026-04-07` beta header. Pass
/// `betas: ['cache-diagnosis-2026-04-07']` to `messages.create`.
///
/// ```dart
/// final response = await client.messages.create(
///   MessageCreateRequest(
///     model: 'claude-sonnet-4-6',
///     maxTokens: 1024,
///     diagnostics: DiagnosticsParam(previousMessageId: 'msg_123'),
///     messages: [InputMessage.user('Continue the conversation.')],
///   ),
///   betas: ['cache-diagnosis-2026-04-07'],
/// );
/// ```
@immutable
class DiagnosticsParam {
  /// Identifier of the previous message in the conversation.
  ///
  /// When set, the API anchors cache diagnostics to this prior turn. Maximum
  /// length 256 characters.
  final String? previousMessageId;

  /// Creates a [DiagnosticsParam].
  const DiagnosticsParam({this.previousMessageId});

  /// Creates a [DiagnosticsParam] from JSON.
  factory DiagnosticsParam.fromJson(Map<String, dynamic> json) {
    return DiagnosticsParam(
      previousMessageId: json['previous_message_id'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (previousMessageId != null) 'previous_message_id': previousMessageId,
  };

  /// Creates a copy with replaced values.
  DiagnosticsParam copyWith({Object? previousMessageId = unsetCopyWithValue}) {
    return DiagnosticsParam(
      previousMessageId: previousMessageId == unsetCopyWithValue
          ? this.previousMessageId
          : previousMessageId as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosticsParam &&
          runtimeType == other.runtimeType &&
          previousMessageId == other.previousMessageId;

  @override
  int get hashCode => previousMessageId.hashCode;

  @override
  String toString() =>
      'DiagnosticsParam(previousMessageId: $previousMessageId)';
}
