import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A conversation payload containing messages.
///
/// This schema has `additionalProperties: true`, so extra fields
/// beyond [messages] are captured in [extra].
@immutable
class ConversationPayload {
  /// The messages in the conversation.
  final List<Map<String, dynamic>> messages;

  /// Additional properties not captured by defined fields.
  final Map<String, dynamic>? extra;

  /// Creates a [ConversationPayload].
  ConversationPayload({
    required List<Map<String, dynamic>> messages,
    Map<String, dynamic>? extra,
  }) : messages = List.unmodifiable(
         messages.map(Map<String, dynamic>.unmodifiable),
       ),
       extra = extra != null ? Map.unmodifiable(extra) : null;

  /// Creates a [ConversationPayload] from JSON.
  factory ConversationPayload.fromJson(Map<String, dynamic> json) {
    final messages =
        (json['messages'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
    final extra = Map<String, dynamic>.from(json)..remove('messages');
    return ConversationPayload(
      messages: messages,
      extra: extra.isNotEmpty ? extra : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'messages': messages.map(Map<String, dynamic>.from).toList(),
    if (extra != null) ...extra!,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ConversationPayload) return false;
    if (runtimeType != other.runtimeType) return false;
    return listOfMapsDeepEqual(messages, other.messages) &&
        mapsDeepEqual(extra, other.extra);
  }

  @override
  int get hashCode =>
      Object.hash(listOfMapsHashCode(messages), mapDeepHashCode(extra));

  @override
  String toString() =>
      'ConversationPayload(messages: ${messages.length} messages)';
}
