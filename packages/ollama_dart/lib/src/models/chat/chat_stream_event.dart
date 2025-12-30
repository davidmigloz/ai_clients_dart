import 'package:meta/meta.dart';

import 'chat_response.dart';

/// A streaming event from chat completion.
@immutable
class ChatStreamEvent {
  /// Model name used for this stream event.
  final String? model;

  /// When this chunk was created (ISO 8601).
  final String? createdAt;

  /// The message chunk.
  final ChatResponseMessage? message;

  /// True for the final event in the stream.
  final bool? done;

  /// Creates a [ChatStreamEvent].
  const ChatStreamEvent({this.model, this.createdAt, this.message, this.done});

  /// Creates a [ChatStreamEvent] from JSON.
  factory ChatStreamEvent.fromJson(Map<String, dynamic> json) =>
      ChatStreamEvent(
        model: json['model'] as String?,
        createdAt: json['created_at'] as String?,
        message: json['message'] != null
            ? ChatResponseMessage.fromJson(
                json['message'] as Map<String, dynamic>,
              )
            : null,
        done: json['done'] as bool?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (model != null) 'model': model,
    if (createdAt != null) 'created_at': createdAt,
    if (message != null) 'message': message!.toJson(),
    if (done != null) 'done': done,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatStreamEvent &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          createdAt == other.createdAt &&
          done == other.done;

  @override
  int get hashCode => Object.hash(model, createdAt, done);

  @override
  String toString() =>
      'ChatStreamEvent('
      'model: $model, '
      'message: $message, '
      'done: $done)';
}
