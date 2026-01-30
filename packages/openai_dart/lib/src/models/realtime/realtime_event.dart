import 'package:meta/meta.dart';

import 'realtime_session.dart';

/// Base class for all realtime events.
///
/// Events are sent and received over the WebSocket connection.
sealed class RealtimeEvent {
  /// Creates a [RealtimeEvent] from JSON.
  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    // Session events
    if (type == 'session.created') {
      return SessionCreatedEvent.fromJson(json);
    }
    if (type == 'session.updated') {
      return SessionUpdatedEvent.fromJson(json);
    }

    // Conversation events
    if (type == 'conversation.created') {
      return ConversationCreatedEvent.fromJson(json);
    }
    if (type == 'conversation.item.created') {
      return ConversationItemCreatedEvent.fromJson(json);
    }
    if (type == 'conversation.item.deleted') {
      return ConversationItemDeletedEvent.fromJson(json);
    }
    if (type == 'conversation.item.truncated') {
      return ConversationItemTruncatedEvent.fromJson(json);
    }

    // Input audio transcription events
    if (type == 'conversation.item.input_audio_transcription.delta') {
      return InputAudioTranscriptionDeltaEvent.fromJson(json);
    }
    if (type == 'conversation.item.input_audio_transcription.completed') {
      return InputAudioTranscriptionCompletedEvent.fromJson(json);
    }
    if (type == 'conversation.item.input_audio_transcription.failed') {
      return InputAudioTranscriptionFailedEvent.fromJson(json);
    }
    if (type == 'conversation.item.input_audio_transcription.segment') {
      return InputAudioTranscriptionSegmentEvent.fromJson(json);
    }

    // Input audio events
    if (type == 'input_audio_buffer.committed') {
      return InputAudioBufferCommittedEvent.fromJson(json);
    }
    if (type == 'input_audio_buffer.cleared') {
      return InputAudioBufferClearedEvent.fromJson(json);
    }
    if (type == 'input_audio_buffer.speech_started') {
      return InputAudioBufferSpeechStartedEvent.fromJson(json);
    }
    if (type == 'input_audio_buffer.speech_stopped') {
      return InputAudioBufferSpeechStoppedEvent.fromJson(json);
    }

    // Response events
    if (type == 'response.created') {
      return ResponseCreatedEvent.fromJson(json);
    }
    if (type == 'response.done') {
      return ResponseDoneEvent.fromJson(json);
    }
    if (type == 'response.output_item.added') {
      return ResponseOutputItemAddedEvent.fromJson(json);
    }
    if (type == 'response.output_item.done') {
      return ResponseOutputItemDoneEvent.fromJson(json);
    }
    if (type == 'response.content_part.added') {
      return ResponseContentPartAddedEvent.fromJson(json);
    }
    if (type == 'response.content_part.done') {
      return ResponseContentPartDoneEvent.fromJson(json);
    }
    if (type == 'response.text.delta') {
      return ResponseTextDeltaEvent.fromJson(json);
    }
    if (type == 'response.text.done') {
      return ResponseTextDoneEvent.fromJson(json);
    }
    if (type == 'response.audio_transcript.delta') {
      return ResponseAudioTranscriptDeltaEvent.fromJson(json);
    }
    if (type == 'response.audio_transcript.done') {
      return ResponseAudioTranscriptDoneEvent.fromJson(json);
    }
    if (type == 'response.audio.delta') {
      return ResponseAudioDeltaEvent.fromJson(json);
    }
    if (type == 'response.audio.done') {
      return ResponseAudioDoneEvent.fromJson(json);
    }
    if (type == 'response.function_call_arguments.delta') {
      return ResponseFunctionCallArgumentsDeltaEvent.fromJson(json);
    }
    if (type == 'response.function_call_arguments.done') {
      return ResponseFunctionCallArgumentsDoneEvent.fromJson(json);
    }

    // Rate limit event
    if (type == 'rate_limits.updated') {
      return RateLimitsUpdatedEvent.fromJson(json);
    }

    // Error event
    if (type == 'error') {
      return ErrorEvent.fromJson(json);
    }

    throw FormatException('Unknown realtime event type: $type');
  }

  /// The event type.
  String get type;

  /// The event ID.
  String? get eventId;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Session created event.
@immutable
class SessionCreatedEvent implements RealtimeEvent {
  /// Creates a [SessionCreatedEvent].
  const SessionCreatedEvent({required this.eventId, required this.session});

  /// Creates a [SessionCreatedEvent] from JSON.
  factory SessionCreatedEvent.fromJson(Map<String, dynamic> json) {
    return SessionCreatedEvent(
      eventId: json['event_id'] as String,
      session: RealtimeSession.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  String get type => 'session.created';

  @override
  final String eventId;

  /// The session that was created.
  final RealtimeSession session;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'session': session.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionCreatedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'SessionCreatedEvent(eventId: $eventId)';
}

/// Session updated event.
@immutable
class SessionUpdatedEvent implements RealtimeEvent {
  /// Creates a [SessionUpdatedEvent].
  const SessionUpdatedEvent({required this.eventId, required this.session});

  /// Creates a [SessionUpdatedEvent] from JSON.
  factory SessionUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return SessionUpdatedEvent(
      eventId: json['event_id'] as String,
      session: RealtimeSession.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  String get type => 'session.updated';

  @override
  final String eventId;

  /// The updated session.
  final RealtimeSession session;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'session': session.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionUpdatedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'SessionUpdatedEvent(eventId: $eventId)';
}

/// Conversation created event.
@immutable
class ConversationCreatedEvent implements RealtimeEvent {
  /// Creates a [ConversationCreatedEvent].
  const ConversationCreatedEvent({
    required this.eventId,
    required this.conversation,
  });

  /// Creates a [ConversationCreatedEvent] from JSON.
  factory ConversationCreatedEvent.fromJson(Map<String, dynamic> json) {
    return ConversationCreatedEvent(
      eventId: json['event_id'] as String,
      conversation: json['conversation'] as Map<String, dynamic>,
    );
  }

  @override
  String get type => 'conversation.created';

  @override
  final String eventId;

  /// The conversation data.
  final Map<String, dynamic> conversation;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'conversation': conversation,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationCreatedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ConversationCreatedEvent(eventId: $eventId)';
}

/// Conversation item created event.
@immutable
class ConversationItemCreatedEvent implements RealtimeEvent {
  /// Creates a [ConversationItemCreatedEvent].
  const ConversationItemCreatedEvent({
    required this.eventId,
    required this.previousItemId,
    required this.item,
  });

  /// Creates a [ConversationItemCreatedEvent] from JSON.
  factory ConversationItemCreatedEvent.fromJson(Map<String, dynamic> json) {
    return ConversationItemCreatedEvent(
      eventId: json['event_id'] as String,
      previousItemId: json['previous_item_id'] as String?,
      item: json['item'] as Map<String, dynamic>,
    );
  }

  @override
  String get type => 'conversation.item.created';

  @override
  final String eventId;

  /// The ID of the previous item.
  final String? previousItemId;

  /// The created item.
  final Map<String, dynamic> item;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    if (previousItemId != null) 'previous_item_id': previousItemId,
    'item': item,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationItemCreatedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ConversationItemCreatedEvent(eventId: $eventId)';
}

/// Conversation item deleted event.
@immutable
class ConversationItemDeletedEvent implements RealtimeEvent {
  /// Creates a [ConversationItemDeletedEvent].
  const ConversationItemDeletedEvent({
    required this.eventId,
    required this.itemId,
  });

  /// Creates a [ConversationItemDeletedEvent] from JSON.
  factory ConversationItemDeletedEvent.fromJson(Map<String, dynamic> json) {
    return ConversationItemDeletedEvent(
      eventId: json['event_id'] as String,
      itemId: json['item_id'] as String,
    );
  }

  @override
  String get type => 'conversation.item.deleted';

  @override
  final String eventId;

  /// The deleted item ID.
  final String itemId;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'item_id': itemId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationItemDeletedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ConversationItemDeletedEvent(itemId: $itemId)';
}

/// Conversation item truncated event.
@immutable
class ConversationItemTruncatedEvent implements RealtimeEvent {
  /// Creates a [ConversationItemTruncatedEvent].
  const ConversationItemTruncatedEvent({
    required this.eventId,
    required this.itemId,
    required this.contentIndex,
    required this.audioEndMs,
  });

  /// Creates a [ConversationItemTruncatedEvent] from JSON.
  factory ConversationItemTruncatedEvent.fromJson(Map<String, dynamic> json) {
    return ConversationItemTruncatedEvent(
      eventId: json['event_id'] as String,
      itemId: json['item_id'] as String,
      contentIndex: json['content_index'] as int,
      audioEndMs: json['audio_end_ms'] as int,
    );
  }

  @override
  String get type => 'conversation.item.truncated';

  @override
  final String eventId;

  /// The truncated item ID.
  final String itemId;

  /// The content index.
  final int contentIndex;

  /// The audio end time in milliseconds.
  final int audioEndMs;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'item_id': itemId,
    'content_index': contentIndex,
    'audio_end_ms': audioEndMs,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationItemTruncatedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ConversationItemTruncatedEvent(itemId: $itemId)';
}

/// Input audio transcription delta event.
///
/// Sent when a transcription delta is available for input audio.
@immutable
class InputAudioTranscriptionDeltaEvent implements RealtimeEvent {
  /// Creates an [InputAudioTranscriptionDeltaEvent].
  const InputAudioTranscriptionDeltaEvent({
    required this.eventId,
    required this.itemId,
    required this.contentIndex,
    required this.delta,
    this.obfuscation,
  });

  /// Creates an [InputAudioTranscriptionDeltaEvent] from JSON.
  factory InputAudioTranscriptionDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return InputAudioTranscriptionDeltaEvent(
      eventId: json['event_id'] as String,
      itemId: json['item_id'] as String,
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
      obfuscation: json['obfuscation'] as String?,
    );
  }

  @override
  String get type => 'conversation.item.input_audio_transcription.delta';

  @override
  final String eventId;

  /// The item ID.
  final String itemId;

  /// The content index.
  final int contentIndex;

  /// The transcription delta.
  final String delta;

  /// The obfuscation string (if present).
  final String? obfuscation;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'item_id': itemId,
    'content_index': contentIndex,
    'delta': delta,
    if (obfuscation != null) 'obfuscation': obfuscation,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputAudioTranscriptionDeltaEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'InputAudioTranscriptionDeltaEvent(delta: $delta)';
}

/// Input audio transcription completed event.
///
/// Sent when input audio transcription is completed.
@immutable
class InputAudioTranscriptionCompletedEvent implements RealtimeEvent {
  /// Creates an [InputAudioTranscriptionCompletedEvent].
  const InputAudioTranscriptionCompletedEvent({
    required this.eventId,
    required this.itemId,
    required this.contentIndex,
    required this.transcript,
    this.usage,
  });

  /// Creates an [InputAudioTranscriptionCompletedEvent] from JSON.
  factory InputAudioTranscriptionCompletedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return InputAudioTranscriptionCompletedEvent(
      eventId: json['event_id'] as String,
      itemId: json['item_id'] as String,
      contentIndex: json['content_index'] as int,
      transcript: json['transcript'] as String,
      usage: json['usage'] as Map<String, dynamic>?,
    );
  }

  @override
  String get type => 'conversation.item.input_audio_transcription.completed';

  @override
  final String eventId;

  /// The item ID.
  final String itemId;

  /// The content index.
  final int contentIndex;

  /// The complete transcript.
  final String transcript;

  /// Token usage information.
  final Map<String, dynamic>? usage;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'item_id': itemId,
    'content_index': contentIndex,
    'transcript': transcript,
    if (usage != null) 'usage': usage,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputAudioTranscriptionCompletedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() =>
      'InputAudioTranscriptionCompletedEvent(${transcript.length} chars)';
}

/// Input audio transcription failed event.
///
/// Sent when input audio transcription fails.
@immutable
class InputAudioTranscriptionFailedEvent implements RealtimeEvent {
  /// Creates an [InputAudioTranscriptionFailedEvent].
  const InputAudioTranscriptionFailedEvent({
    required this.eventId,
    required this.itemId,
    required this.contentIndex,
    required this.error,
  });

  /// Creates an [InputAudioTranscriptionFailedEvent] from JSON.
  factory InputAudioTranscriptionFailedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return InputAudioTranscriptionFailedEvent(
      eventId: json['event_id'] as String,
      itemId: json['item_id'] as String,
      contentIndex: json['content_index'] as int,
      error: RealtimeError.fromJson(json['error'] as Map<String, dynamic>),
    );
  }

  @override
  String get type => 'conversation.item.input_audio_transcription.failed';

  @override
  final String eventId;

  /// The item ID.
  final String itemId;

  /// The content index.
  final int contentIndex;

  /// The error details.
  final RealtimeError error;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'item_id': itemId,
    'content_index': contentIndex,
    'error': error.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputAudioTranscriptionFailedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() =>
      'InputAudioTranscriptionFailedEvent(error: ${error.code})';
}

/// Input audio transcription segment event.
///
/// Sent when a transcription segment is available.
@immutable
class InputAudioTranscriptionSegmentEvent implements RealtimeEvent {
  /// Creates an [InputAudioTranscriptionSegmentEvent].
  const InputAudioTranscriptionSegmentEvent({
    required this.eventId,
    required this.itemId,
    required this.contentIndex,
    required this.text,
    required this.id,
    this.speaker,
    required this.start,
    required this.end,
  });

  /// Creates an [InputAudioTranscriptionSegmentEvent] from JSON.
  factory InputAudioTranscriptionSegmentEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return InputAudioTranscriptionSegmentEvent(
      eventId: json['event_id'] as String,
      itemId: json['item_id'] as String,
      contentIndex: json['content_index'] as int,
      text: json['text'] as String,
      id: json['id'] as String,
      speaker: json['speaker'] as String?,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
    );
  }

  @override
  String get type => 'conversation.item.input_audio_transcription.segment';

  @override
  final String eventId;

  /// The item ID.
  final String itemId;

  /// The content index.
  final int contentIndex;

  /// The transcription text for this segment.
  final String text;

  /// The segment ID.
  final String id;

  /// The speaker identifier.
  final String? speaker;

  /// Start time in seconds.
  final double start;

  /// End time in seconds.
  final double end;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'item_id': itemId,
    'content_index': contentIndex,
    'text': text,
    'id': id,
    if (speaker != null) 'speaker': speaker,
    'start': start,
    'end': end,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputAudioTranscriptionSegmentEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'InputAudioTranscriptionSegmentEvent(text: $text)';
}

/// Input audio buffer committed event.
@immutable
class InputAudioBufferCommittedEvent implements RealtimeEvent {
  /// Creates an [InputAudioBufferCommittedEvent].
  const InputAudioBufferCommittedEvent({
    required this.eventId,
    required this.previousItemId,
    required this.itemId,
  });

  /// Creates an [InputAudioBufferCommittedEvent] from JSON.
  factory InputAudioBufferCommittedEvent.fromJson(Map<String, dynamic> json) {
    return InputAudioBufferCommittedEvent(
      eventId: json['event_id'] as String,
      previousItemId: json['previous_item_id'] as String?,
      itemId: json['item_id'] as String,
    );
  }

  @override
  String get type => 'input_audio_buffer.committed';

  @override
  final String eventId;

  /// The previous item ID.
  final String? previousItemId;

  /// The new item ID.
  final String itemId;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    if (previousItemId != null) 'previous_item_id': previousItemId,
    'item_id': itemId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputAudioBufferCommittedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'InputAudioBufferCommittedEvent(itemId: $itemId)';
}

/// Input audio buffer cleared event.
@immutable
class InputAudioBufferClearedEvent implements RealtimeEvent {
  /// Creates an [InputAudioBufferClearedEvent].
  const InputAudioBufferClearedEvent({required this.eventId});

  /// Creates an [InputAudioBufferClearedEvent] from JSON.
  factory InputAudioBufferClearedEvent.fromJson(Map<String, dynamic> json) {
    return InputAudioBufferClearedEvent(eventId: json['event_id'] as String);
  }

  @override
  String get type => 'input_audio_buffer.cleared';

  @override
  final String eventId;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'event_id': eventId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputAudioBufferClearedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'InputAudioBufferClearedEvent(eventId: $eventId)';
}

/// Input audio buffer speech started event.
@immutable
class InputAudioBufferSpeechStartedEvent implements RealtimeEvent {
  /// Creates an [InputAudioBufferSpeechStartedEvent].
  const InputAudioBufferSpeechStartedEvent({
    required this.eventId,
    required this.audioStartMs,
    required this.itemId,
  });

  /// Creates an [InputAudioBufferSpeechStartedEvent] from JSON.
  factory InputAudioBufferSpeechStartedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return InputAudioBufferSpeechStartedEvent(
      eventId: json['event_id'] as String,
      audioStartMs: json['audio_start_ms'] as int,
      itemId: json['item_id'] as String,
    );
  }

  @override
  String get type => 'input_audio_buffer.speech_started';

  @override
  final String eventId;

  /// When speech started in the audio buffer.
  final int audioStartMs;

  /// The item ID.
  final String itemId;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'audio_start_ms': audioStartMs,
    'item_id': itemId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputAudioBufferSpeechStartedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() =>
      'InputAudioBufferSpeechStartedEvent(audioStartMs: $audioStartMs)';
}

/// Input audio buffer speech stopped event.
@immutable
class InputAudioBufferSpeechStoppedEvent implements RealtimeEvent {
  /// Creates an [InputAudioBufferSpeechStoppedEvent].
  const InputAudioBufferSpeechStoppedEvent({
    required this.eventId,
    required this.audioEndMs,
    required this.itemId,
  });

  /// Creates an [InputAudioBufferSpeechStoppedEvent] from JSON.
  factory InputAudioBufferSpeechStoppedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return InputAudioBufferSpeechStoppedEvent(
      eventId: json['event_id'] as String,
      audioEndMs: json['audio_end_ms'] as int,
      itemId: json['item_id'] as String,
    );
  }

  @override
  String get type => 'input_audio_buffer.speech_stopped';

  @override
  final String eventId;

  /// When speech stopped.
  final int audioEndMs;

  /// The item ID.
  final String itemId;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'audio_end_ms': audioEndMs,
    'item_id': itemId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputAudioBufferSpeechStoppedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() =>
      'InputAudioBufferSpeechStoppedEvent(audioEndMs: $audioEndMs)';
}

/// Response created event.
@immutable
class ResponseCreatedEvent implements RealtimeEvent {
  /// Creates a [ResponseCreatedEvent].
  const ResponseCreatedEvent({required this.eventId, required this.response});

  /// Creates a [ResponseCreatedEvent] from JSON.
  factory ResponseCreatedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseCreatedEvent(
      eventId: json['event_id'] as String,
      response: json['response'] as Map<String, dynamic>,
    );
  }

  @override
  String get type => 'response.created';

  @override
  final String eventId;

  /// The response data.
  final Map<String, dynamic> response;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response': response,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCreatedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ResponseCreatedEvent(eventId: $eventId)';
}

/// Response done event.
@immutable
class ResponseDoneEvent implements RealtimeEvent {
  /// Creates a [ResponseDoneEvent].
  const ResponseDoneEvent({required this.eventId, required this.response});

  /// Creates a [ResponseDoneEvent] from JSON.
  factory ResponseDoneEvent.fromJson(Map<String, dynamic> json) {
    return ResponseDoneEvent(
      eventId: json['event_id'] as String,
      response: json['response'] as Map<String, dynamic>,
    );
  }

  @override
  String get type => 'response.done';

  @override
  final String eventId;

  /// The completed response.
  final Map<String, dynamic> response;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response': response,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseDoneEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ResponseDoneEvent(eventId: $eventId)';
}

/// Response output item added event.
@immutable
class ResponseOutputItemAddedEvent implements RealtimeEvent {
  /// Creates a [ResponseOutputItemAddedEvent].
  const ResponseOutputItemAddedEvent({
    required this.eventId,
    required this.responseId,
    required this.outputIndex,
    required this.item,
  });

  /// Creates a [ResponseOutputItemAddedEvent] from JSON.
  factory ResponseOutputItemAddedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseOutputItemAddedEvent(
      eventId: json['event_id'] as String,
      responseId: json['response_id'] as String,
      outputIndex: json['output_index'] as int,
      item: json['item'] as Map<String, dynamic>,
    );
  }

  @override
  String get type => 'response.output_item.added';

  @override
  final String eventId;

  /// The response ID.
  final String responseId;

  /// The output index.
  final int outputIndex;

  /// The added item.
  final Map<String, dynamic> item;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response_id': responseId,
    'output_index': outputIndex,
    'item': item,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseOutputItemAddedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() =>
      'ResponseOutputItemAddedEvent(outputIndex: $outputIndex)';
}

/// Response output item done event.
@immutable
class ResponseOutputItemDoneEvent implements RealtimeEvent {
  /// Creates a [ResponseOutputItemDoneEvent].
  const ResponseOutputItemDoneEvent({
    required this.eventId,
    required this.responseId,
    required this.outputIndex,
    required this.item,
  });

  /// Creates a [ResponseOutputItemDoneEvent] from JSON.
  factory ResponseOutputItemDoneEvent.fromJson(Map<String, dynamic> json) {
    return ResponseOutputItemDoneEvent(
      eventId: json['event_id'] as String,
      responseId: json['response_id'] as String,
      outputIndex: json['output_index'] as int,
      item: json['item'] as Map<String, dynamic>,
    );
  }

  @override
  String get type => 'response.output_item.done';

  @override
  final String eventId;

  /// The response ID.
  final String responseId;

  /// The output index.
  final int outputIndex;

  /// The completed item.
  final Map<String, dynamic> item;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response_id': responseId,
    'output_index': outputIndex,
    'item': item,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseOutputItemDoneEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ResponseOutputItemDoneEvent(outputIndex: $outputIndex)';
}

/// Response content part added event.
@immutable
class ResponseContentPartAddedEvent implements RealtimeEvent {
  /// Creates a [ResponseContentPartAddedEvent].
  const ResponseContentPartAddedEvent({
    required this.eventId,
    required this.responseId,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.part,
  });

  /// Creates a [ResponseContentPartAddedEvent] from JSON.
  factory ResponseContentPartAddedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseContentPartAddedEvent(
      eventId: json['event_id'] as String,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      part: json['part'] as Map<String, dynamic>,
    );
  }

  @override
  String get type => 'response.content_part.added';

  @override
  final String eventId;

  /// The response ID.
  final String responseId;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The added content part.
  final Map<String, dynamic> part;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response_id': responseId,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'part': part,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseContentPartAddedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() =>
      'ResponseContentPartAddedEvent(contentIndex: $contentIndex)';
}

/// Response content part done event.
@immutable
class ResponseContentPartDoneEvent implements RealtimeEvent {
  /// Creates a [ResponseContentPartDoneEvent].
  const ResponseContentPartDoneEvent({
    required this.eventId,
    required this.responseId,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.part,
  });

  /// Creates a [ResponseContentPartDoneEvent] from JSON.
  factory ResponseContentPartDoneEvent.fromJson(Map<String, dynamic> json) {
    return ResponseContentPartDoneEvent(
      eventId: json['event_id'] as String,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      part: json['part'] as Map<String, dynamic>,
    );
  }

  @override
  String get type => 'response.content_part.done';

  @override
  final String eventId;

  /// The response ID.
  final String responseId;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The completed content part.
  final Map<String, dynamic> part;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response_id': responseId,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'part': part,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseContentPartDoneEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() =>
      'ResponseContentPartDoneEvent(contentIndex: $contentIndex)';
}

/// Response text delta event.
@immutable
class ResponseTextDeltaEvent implements RealtimeEvent {
  /// Creates a [ResponseTextDeltaEvent].
  const ResponseTextDeltaEvent({
    required this.eventId,
    required this.responseId,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.delta,
  });

  /// Creates a [ResponseTextDeltaEvent] from JSON.
  factory ResponseTextDeltaEvent.fromJson(Map<String, dynamic> json) {
    return ResponseTextDeltaEvent(
      eventId: json['event_id'] as String,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
    );
  }

  @override
  String get type => 'response.text.delta';

  @override
  final String eventId;

  /// The response ID.
  final String responseId;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The text delta.
  final String delta;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response_id': responseId,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'delta': delta,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseTextDeltaEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ResponseTextDeltaEvent(delta: $delta)';
}

/// Response text done event.
@immutable
class ResponseTextDoneEvent implements RealtimeEvent {
  /// Creates a [ResponseTextDoneEvent].
  const ResponseTextDoneEvent({
    required this.eventId,
    required this.responseId,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.text,
  });

  /// Creates a [ResponseTextDoneEvent] from JSON.
  factory ResponseTextDoneEvent.fromJson(Map<String, dynamic> json) {
    return ResponseTextDoneEvent(
      eventId: json['event_id'] as String,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      text: json['text'] as String,
    );
  }

  @override
  String get type => 'response.text.done';

  @override
  final String eventId;

  /// The response ID.
  final String responseId;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The complete text.
  final String text;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response_id': responseId,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'text': text,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseTextDoneEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ResponseTextDoneEvent(${text.length} chars)';
}

/// Response audio transcript delta event.
@immutable
class ResponseAudioTranscriptDeltaEvent implements RealtimeEvent {
  /// Creates a [ResponseAudioTranscriptDeltaEvent].
  const ResponseAudioTranscriptDeltaEvent({
    required this.eventId,
    required this.responseId,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.delta,
  });

  /// Creates a [ResponseAudioTranscriptDeltaEvent] from JSON.
  factory ResponseAudioTranscriptDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseAudioTranscriptDeltaEvent(
      eventId: json['event_id'] as String,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
    );
  }

  @override
  String get type => 'response.audio_transcript.delta';

  @override
  final String eventId;

  /// The response ID.
  final String responseId;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The transcript delta.
  final String delta;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response_id': responseId,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'delta': delta,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAudioTranscriptDeltaEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ResponseAudioTranscriptDeltaEvent(delta: $delta)';
}

/// Response audio transcript done event.
@immutable
class ResponseAudioTranscriptDoneEvent implements RealtimeEvent {
  /// Creates a [ResponseAudioTranscriptDoneEvent].
  const ResponseAudioTranscriptDoneEvent({
    required this.eventId,
    required this.responseId,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.transcript,
  });

  /// Creates a [ResponseAudioTranscriptDoneEvent] from JSON.
  factory ResponseAudioTranscriptDoneEvent.fromJson(Map<String, dynamic> json) {
    return ResponseAudioTranscriptDoneEvent(
      eventId: json['event_id'] as String,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      transcript: json['transcript'] as String,
    );
  }

  @override
  String get type => 'response.audio_transcript.done';

  @override
  final String eventId;

  /// The response ID.
  final String responseId;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The complete transcript.
  final String transcript;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response_id': responseId,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'transcript': transcript,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAudioTranscriptDoneEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() =>
      'ResponseAudioTranscriptDoneEvent(${transcript.length} chars)';
}

/// Response audio delta event.
@immutable
class ResponseAudioDeltaEvent implements RealtimeEvent {
  /// Creates a [ResponseAudioDeltaEvent].
  const ResponseAudioDeltaEvent({
    required this.eventId,
    required this.responseId,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.delta,
  });

  /// Creates a [ResponseAudioDeltaEvent] from JSON.
  factory ResponseAudioDeltaEvent.fromJson(Map<String, dynamic> json) {
    return ResponseAudioDeltaEvent(
      eventId: json['event_id'] as String,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
    );
  }

  @override
  String get type => 'response.audio.delta';

  @override
  final String eventId;

  /// The response ID.
  final String responseId;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The base64-encoded audio delta.
  final String delta;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response_id': responseId,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'delta': delta,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAudioDeltaEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ResponseAudioDeltaEvent(${delta.length} chars)';
}

/// Response audio done event.
@immutable
class ResponseAudioDoneEvent implements RealtimeEvent {
  /// Creates a [ResponseAudioDoneEvent].
  const ResponseAudioDoneEvent({
    required this.eventId,
    required this.responseId,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
  });

  /// Creates a [ResponseAudioDoneEvent] from JSON.
  factory ResponseAudioDoneEvent.fromJson(Map<String, dynamic> json) {
    return ResponseAudioDoneEvent(
      eventId: json['event_id'] as String,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
    );
  }

  @override
  String get type => 'response.audio.done';

  @override
  final String eventId;

  /// The response ID.
  final String responseId;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response_id': responseId,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAudioDoneEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ResponseAudioDoneEvent(eventId: $eventId)';
}

/// Response function call arguments delta event.
@immutable
class ResponseFunctionCallArgumentsDeltaEvent implements RealtimeEvent {
  /// Creates a [ResponseFunctionCallArgumentsDeltaEvent].
  const ResponseFunctionCallArgumentsDeltaEvent({
    required this.eventId,
    required this.responseId,
    required this.itemId,
    required this.outputIndex,
    required this.callId,
    required this.delta,
  });

  /// Creates a [ResponseFunctionCallArgumentsDeltaEvent] from JSON.
  factory ResponseFunctionCallArgumentsDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseFunctionCallArgumentsDeltaEvent(
      eventId: json['event_id'] as String,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      callId: json['call_id'] as String,
      delta: json['delta'] as String,
    );
  }

  @override
  String get type => 'response.function_call_arguments.delta';

  @override
  final String eventId;

  /// The response ID.
  final String responseId;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The function call ID.
  final String callId;

  /// The arguments delta.
  final String delta;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response_id': responseId,
    'item_id': itemId,
    'output_index': outputIndex,
    'call_id': callId,
    'delta': delta,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFunctionCallArgumentsDeltaEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ResponseFunctionCallArgumentsDeltaEvent(delta: $delta)';
}

/// Response function call arguments done event.
@immutable
class ResponseFunctionCallArgumentsDoneEvent implements RealtimeEvent {
  /// Creates a [ResponseFunctionCallArgumentsDoneEvent].
  const ResponseFunctionCallArgumentsDoneEvent({
    required this.eventId,
    required this.responseId,
    required this.itemId,
    required this.outputIndex,
    required this.callId,
    required this.arguments,
  });

  /// Creates a [ResponseFunctionCallArgumentsDoneEvent] from JSON.
  factory ResponseFunctionCallArgumentsDoneEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseFunctionCallArgumentsDoneEvent(
      eventId: json['event_id'] as String,
      responseId: json['response_id'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      callId: json['call_id'] as String,
      arguments: json['arguments'] as String,
    );
  }

  @override
  String get type => 'response.function_call_arguments.done';

  @override
  final String eventId;

  /// The response ID.
  final String responseId;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The function call ID.
  final String callId;

  /// The complete arguments.
  final String arguments;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'response_id': responseId,
    'item_id': itemId,
    'output_index': outputIndex,
    'call_id': callId,
    'arguments': arguments,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFunctionCallArgumentsDoneEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() =>
      'ResponseFunctionCallArgumentsDoneEvent(callId: $callId)';
}

/// Rate limits updated event.
@immutable
class RateLimitsUpdatedEvent implements RealtimeEvent {
  /// Creates a [RateLimitsUpdatedEvent].
  const RateLimitsUpdatedEvent({
    required this.eventId,
    required this.rateLimits,
  });

  /// Creates a [RateLimitsUpdatedEvent] from JSON.
  factory RateLimitsUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return RateLimitsUpdatedEvent(
      eventId: json['event_id'] as String,
      rateLimits: (json['rate_limits'] as List<dynamic>)
          .map((e) => RateLimit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String get type => 'rate_limits.updated';

  @override
  final String eventId;

  /// The current rate limits.
  final List<RateLimit> rateLimits;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'rate_limits': rateLimits.map((r) => r.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RateLimitsUpdatedEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'RateLimitsUpdatedEvent(${rateLimits.length} limits)';
}

/// A rate limit.
@immutable
class RateLimit {
  /// Creates a [RateLimit].
  const RateLimit({
    required this.name,
    required this.limit,
    required this.remaining,
    required this.resetSeconds,
  });

  /// Creates a [RateLimit] from JSON.
  factory RateLimit.fromJson(Map<String, dynamic> json) {
    return RateLimit(
      name: json['name'] as String,
      limit: json['limit'] as int,
      remaining: json['remaining'] as int,
      resetSeconds: (json['reset_seconds'] as num).toDouble(),
    );
  }

  /// The rate limit name.
  final String name;

  /// The limit.
  final int limit;

  /// The remaining quota.
  final int remaining;

  /// Seconds until reset.
  final double resetSeconds;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'limit': limit,
    'remaining': remaining,
    'reset_seconds': resetSeconds,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RateLimit &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'RateLimit(name: $name, remaining: $remaining)';
}

/// An error event.
@immutable
class ErrorEvent implements RealtimeEvent {
  /// Creates an [ErrorEvent].
  const ErrorEvent({required this.eventId, required this.error});

  /// Creates an [ErrorEvent] from JSON.
  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    return ErrorEvent(
      eventId: json['event_id'] as String,
      error: RealtimeError.fromJson(json['error'] as Map<String, dynamic>),
    );
  }

  @override
  String get type => 'error';

  @override
  final String eventId;

  /// The error details.
  final RealtimeError error;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'error': error.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ErrorEvent(error: ${error.code})';
}

/// A realtime error.
@immutable
class RealtimeError {
  /// Creates a [RealtimeError].
  const RealtimeError({
    required this.type,
    this.code,
    required this.message,
    this.param,
    this.eventId,
  });

  /// Creates a [RealtimeError] from JSON.
  factory RealtimeError.fromJson(Map<String, dynamic> json) {
    return RealtimeError(
      type: json['type'] as String,
      code: json['code'] as String?,
      message: json['message'] as String,
      param: json['param'] as String?,
      eventId: json['event_id'] as String?,
    );
  }

  /// The error type.
  final String type;

  /// The error code.
  final String? code;

  /// The error message.
  final String message;

  /// The parameter that caused the error.
  final String? param;

  /// The event ID that caused the error.
  final String? eventId;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (code != null) 'code': code,
    'message': message,
    if (param != null) 'param': param,
    if (eventId != null) 'event_id': eventId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeError &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'RealtimeError(code: $code, message: $message)';
}
