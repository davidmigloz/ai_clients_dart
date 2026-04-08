import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A chat transcription event within a chat completion event.
@immutable
class ChatTranscriptionEvent {
  /// URL to the audio file.
  final String audioUrl;

  /// The model used for transcription.
  final String model;

  /// The response message (free-form object).
  final Map<String, dynamic> responseMessage;

  /// Creates a [ChatTranscriptionEvent].
  ChatTranscriptionEvent({
    required this.audioUrl,
    required this.model,
    required Map<String, dynamic> responseMessage,
  }) : responseMessage = Map.unmodifiable(responseMessage);

  /// Creates a [ChatTranscriptionEvent] from JSON.
  factory ChatTranscriptionEvent.fromJson(Map<String, dynamic> json) =>
      ChatTranscriptionEvent(
        audioUrl: json['audio_url'] as String? ?? '',
        model: json['model'] as String? ?? '',
        responseMessage: Map<String, dynamic>.from(
          json['response_message'] as Map? ?? {},
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'audio_url': audioUrl,
    'model': model,
    'response_message': Map<String, dynamic>.from(responseMessage),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatTranscriptionEvent) return false;
    if (runtimeType != other.runtimeType) return false;
    return audioUrl == other.audioUrl &&
        model == other.model &&
        mapsDeepEqual(responseMessage, other.responseMessage);
  }

  @override
  int get hashCode =>
      Object.hash(audioUrl, model, mapDeepHashCode(responseMessage));

  @override
  String toString() =>
      'ChatTranscriptionEvent(audioUrl: $audioUrl, model: $model)';
}
