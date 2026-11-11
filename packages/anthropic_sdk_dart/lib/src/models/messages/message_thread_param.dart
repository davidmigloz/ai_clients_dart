import 'package:meta/meta.dart';

/// Selects server-held conversation state for a Messages request.
///
/// Include `message-threads-2026-08-12` in the request's beta headers. A
/// continuation sends only new messages. Omit system and tools on that turn.
@immutable
final class MessageThreadParam {
  /// The response ID to continue. Null for a create request.
  final String? previousMessageId;

  /// Starts a thread using the full conversation on this request.
  const MessageThreadParam.create() : previousMessageId = null;

  /// Continues from a completed response.
  const MessageThreadParam.continueFrom(String this.previousMessageId);

  /// Creates a [MessageThreadParam] from its wire representation.
  factory MessageThreadParam.fromJson(Map<String, dynamic> json) =>
      switch (json) {
        {'type': 'create'} => const MessageThreadParam.create(),
        {
          'type': 'continue',
          'previous_message_id': final String previousMessageId,
        } =>
          MessageThreadParam.continueFrom(previousMessageId),
        _ => throw const FormatException('Invalid Messages thread parameter'),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': previousMessageId == null ? 'create' : 'continue',
    'previous_message_id': ?previousMessageId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageThreadParam &&
          previousMessageId == other.previousMessageId;

  @override
  int get hashCode => previousMessageId.hashCode;

  @override
  String toString() =>
      'MessageThreadParam(previousMessageId: $previousMessageId)';
}
