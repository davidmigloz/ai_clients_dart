import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to evaluate a conversation with a judge.
@immutable
class JudgeConversationRequest {
  /// The messages in the conversation.
  final List<Map<String, dynamic>> messages;

  /// Optional properties for context.
  final Map<String, dynamic>? properties;

  /// Creates a [JudgeConversationRequest].
  JudgeConversationRequest({
    required List<Map<String, dynamic>> messages,
    Map<String, dynamic>? properties,
  }) : messages = List.unmodifiable(
         messages.map(Map<String, dynamic>.unmodifiable),
       ),
       properties = properties != null ? Map.unmodifiable(properties) : null;

  /// Creates a [JudgeConversationRequest] from JSON.
  factory JudgeConversationRequest.fromJson(Map<String, dynamic> json) =>
      JudgeConversationRequest(
        messages:
            (json['messages'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [],
        properties: json['properties'] != null
            ? Map<String, dynamic>.from(json['properties'] as Map)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'messages': messages.map(Map<String, dynamic>.from).toList(),
    if (properties != null) 'properties': properties,
  };

  /// Creates a copy with replaced values.
  JudgeConversationRequest copyWith({
    List<Map<String, dynamic>>? messages,
    Object? properties = unsetCopyWithValue,
  }) {
    return JudgeConversationRequest(
      messages: messages ?? this.messages,
      properties: properties == unsetCopyWithValue
          ? this.properties
          : properties as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JudgeConversationRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return listOfMapsDeepEqual(messages, other.messages) &&
        mapsDeepEqual(properties, other.properties);
  }

  @override
  int get hashCode =>
      Object.hash(listOfMapsHashCode(messages), mapDeepHashCode(properties));

  @override
  String toString() =>
      'JudgeConversationRequest(messages: ${messages.length} messages)';
}
