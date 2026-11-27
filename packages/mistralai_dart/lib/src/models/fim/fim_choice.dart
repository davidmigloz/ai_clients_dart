import 'package:meta/meta.dart';

import '../chat/chat_choice_delta.dart';
import '../chat/chat_message.dart';
import '../chat/message_content.dart';
import '../common/equality_helpers.dart';
import '../metadata/finish_reason.dart';

/// A choice in a FIM completion response.
@immutable
class FimChoice {
  /// The index of this choice in the list of choices.
  final int index;

  final String? _legacyMessage;

  /// The generated text, including text from structured message content.
  String get message =>
      _legacyMessage ??
      assistantMessage?.content?.text ??
      messages?.map((message) => message.content?.text ?? '').join() ??
      '';

  /// The assistant message when the server returns an object.
  final AssistantMessage? assistantMessage;

  /// Deltas returned in place of a single assistant message.
  final List<DeltaContent>? messages;

  /// The reason the model stopped generating.
  final FinishReason? finishReason;

  /// Creates a [FimChoice] with a legacy plain-text message.
  const FimChoice({
    required this.index,
    required String message,
    this.finishReason,
  }) : _legacyMessage = message,
       assistantMessage = null,
       messages = null;

  /// Creates a [FimChoice] with structured message data.
  const FimChoice.structured({
    required this.index,
    this.assistantMessage,
    this.messages,
    this.finishReason,
  }) : _legacyMessage = null;

  /// Creates a [FimChoice] from JSON.
  factory FimChoice.fromJson(Map<String, dynamic> json) {
    final index = json['index'] as int? ?? 0;
    final finishReason = finishReasonFromString(
      json['finish_reason'] as String?,
    );
    final message = json['message'];
    if (message is String) {
      return FimChoice(
        index: index,
        message: message,
        finishReason: finishReason,
      );
    }
    return FimChoice.structured(
      index: index,
      assistantMessage: message == null
          ? null
          : AssistantMessage.fromJson(message as Map<String, dynamic>),
      messages: (json['messages'] as List?)
          ?.map(
            (message) => DeltaContent.fromJson(message as Map<String, dynamic>),
          )
          .toList(),
      finishReason: finishReason,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'index': index,
    if (_legacyMessage != null || assistantMessage != null)
      'message': _legacyMessage ?? assistantMessage!.toJson(),
    if (messages != null) 'messages': messages!.map((e) => e.toJson()).toList(),
    if (finishReason != null)
      'finish_reason': finishReasonToString(finishReason!),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FimChoice &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          _legacyMessage == other._legacyMessage &&
          assistantMessage == other.assistantMessage &&
          listsEqual(messages, other.messages) &&
          finishReason == other.finishReason;

  @override
  int get hashCode => Object.hash(
    index,
    _legacyMessage,
    assistantMessage,
    listHash(messages),
    finishReason,
  );

  @override
  String toString() =>
      'FimChoice(index: $index, message: ${message.length} chars, '
      'assistantMessage: ${assistantMessage != null}, '
      'messages: ${messages?.length}, finishReason: $finishReason)';
}
