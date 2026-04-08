import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'chat_transcription_event.dart';

/// A full chat completion event with all details.
@immutable
class ChatCompletionEvent {
  /// Unique event identifier.
  final String eventId;

  /// Correlation identifier.
  final String correlationId;

  /// When the event was created.
  final DateTime createdAt;

  /// Extra fields (free-form key-value pairs).
  final Map<String, dynamic> extraFields;

  /// Number of input tokens.
  final int nbInputTokens;

  /// Number of output tokens.
  final int nbOutputTokens;

  /// Tools that were enabled for this completion.
  final List<Map<String, dynamic>> enabledTools;

  /// Request messages sent to the model.
  final List<Map<String, dynamic>> requestMessages;

  /// Response messages from the model.
  final List<Map<String, dynamic>> responseMessages;

  /// Number of messages in the conversation.
  final int nbMessages;

  /// Associated chat transcription events.
  final List<ChatTranscriptionEvent> chatTranscriptionEvents;

  /// Creates a [ChatCompletionEvent].
  ChatCompletionEvent({
    required this.eventId,
    required this.correlationId,
    required this.createdAt,
    required Map<String, dynamic> extraFields,
    required this.nbInputTokens,
    required this.nbOutputTokens,
    required List<Map<String, dynamic>> enabledTools,
    required List<Map<String, dynamic>> requestMessages,
    required List<Map<String, dynamic>> responseMessages,
    required this.nbMessages,
    required List<ChatTranscriptionEvent> chatTranscriptionEvents,
  }) : extraFields = Map.unmodifiable(extraFields),
       enabledTools = List.unmodifiable(
         enabledTools.map(Map<String, dynamic>.unmodifiable),
       ),
       requestMessages = List.unmodifiable(
         requestMessages.map(Map<String, dynamic>.unmodifiable),
       ),
       responseMessages = List.unmodifiable(
         responseMessages.map(Map<String, dynamic>.unmodifiable),
       ),
       chatTranscriptionEvents = List.unmodifiable(chatTranscriptionEvents);

  /// Creates a [ChatCompletionEvent] from JSON.
  factory ChatCompletionEvent.fromJson(
    Map<String, dynamic> json,
  ) => ChatCompletionEvent(
    eventId: json['event_id'] as String? ?? '',
    correlationId: json['correlation_id'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    extraFields: Map<String, dynamic>.from(json['extra_fields'] as Map? ?? {}),
    nbInputTokens: json['nb_input_tokens'] as int? ?? 0,
    nbOutputTokens: json['nb_output_tokens'] as int? ?? 0,
    enabledTools:
        (json['enabled_tools'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [],
    requestMessages:
        (json['request_messages'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [],
    responseMessages:
        (json['response_messages'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [],
    nbMessages: json['nb_messages'] as int? ?? 0,
    chatTranscriptionEvents:
        (json['chat_transcription_events'] as List?)
            ?.map(
              (e) => ChatTranscriptionEvent.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [],
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'event_id': eventId,
    'correlation_id': correlationId,
    'created_at': createdAt.toIso8601String(),
    'extra_fields': Map<String, dynamic>.from(extraFields),
    'nb_input_tokens': nbInputTokens,
    'nb_output_tokens': nbOutputTokens,
    'enabled_tools': enabledTools.map(Map<String, dynamic>.from).toList(),
    'request_messages': requestMessages.map(Map<String, dynamic>.from).toList(),
    'response_messages': responseMessages
        .map(Map<String, dynamic>.from)
        .toList(),
    'nb_messages': nbMessages,
    'chat_transcription_events': chatTranscriptionEvents
        .map((e) => e.toJson())
        .toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatCompletionEvent) return false;
    if (runtimeType != other.runtimeType) return false;
    return eventId == other.eventId &&
        correlationId == other.correlationId &&
        createdAt == other.createdAt &&
        mapsDeepEqual(extraFields, other.extraFields) &&
        nbInputTokens == other.nbInputTokens &&
        nbOutputTokens == other.nbOutputTokens &&
        listOfMapsDeepEqual(enabledTools, other.enabledTools) &&
        listOfMapsDeepEqual(requestMessages, other.requestMessages) &&
        listOfMapsDeepEqual(responseMessages, other.responseMessages) &&
        nbMessages == other.nbMessages &&
        listsEqual(chatTranscriptionEvents, other.chatTranscriptionEvents);
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    correlationId,
    createdAt,
    mapDeepHashCode(extraFields),
    nbInputTokens,
    nbOutputTokens,
    listOfMapsHashCode(enabledTools),
    listOfMapsHashCode(requestMessages),
    listOfMapsHashCode(responseMessages),
    nbMessages,
    listHash(chatTranscriptionEvents),
  );

  @override
  String toString() =>
      'ChatCompletionEvent(eventId: $eventId, '
      'nbInputTokens: $nbInputTokens, nbOutputTokens: $nbOutputTokens, '
      'nbMessages: $nbMessages)';
}
