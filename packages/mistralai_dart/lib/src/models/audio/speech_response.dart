import 'package:meta/meta.dart';

/// Response from speech synthesis containing audio data.
@immutable
class SpeechResponse {
  /// Base64-encoded audio data.
  final String audioData;

  /// Creates a [SpeechResponse].
  const SpeechResponse({required this.audioData});

  /// Creates a [SpeechResponse] from JSON.
  factory SpeechResponse.fromJson(Map<String, dynamic> json) =>
      SpeechResponse(audioData: json['audio_data'] as String? ?? '');

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'audio_data': audioData};

  /// Creates a copy with the given fields replaced.
  SpeechResponse copyWith({String? audioData}) =>
      SpeechResponse(audioData: audioData ?? this.audioData);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechResponse &&
          runtimeType == other.runtimeType &&
          audioData == other.audioData;

  @override
  int get hashCode => audioData.hashCode;

  @override
  String toString() => 'SpeechResponse(audioData: ${audioData.length} chars)';
}
