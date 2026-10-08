import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'audio_json_helpers.dart';

/// Token counts from the inline usage object of `speech.audio.done`.
///
/// This has no usage discriminator and is distinct from transcription usage.
@immutable
final class SpeechUsage {
  /// Creates counts and snapshots any caller-supplied future metadata.
  SpeechUsage({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(rawJson, 'SpeechUsage.rawJson') {
    _validate();
  }

  /// Requires all three canonical integer counts and preserves future metadata.
  factory SpeechUsage.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotAudioJson(
      json,
      'SpeechUsage',
      knownKeys: const {'input_tokens', 'output_tokens', 'total_tokens'},
    );
    return SpeechUsage(
      inputTokens: requireAudioInt(
        snapshot['input_tokens'],
        'SpeechUsage.input_tokens',
      ),
      outputTokens: requireAudioInt(
        snapshot['output_tokens'],
        'SpeechUsage.output_tokens',
      ),
      totalTokens: requireAudioInt(
        snapshot['total_tokens'],
        'SpeechUsage.total_tokens',
      ),
      rawJson: snapshot,
    );
  }

  /// Input tokens used for the request.
  final int inputTokens;

  /// Output tokens generated.
  final int outputTokens;

  /// Total tokens reported by the service.
  final int totalTokens;

  /// Deeply immutable original JSON, including future usage members.
  final Map<String, dynamic> rawJson;

  void _validate() {
    requireAudioInt(inputTokens, 'SpeechUsage.input_tokens');
    requireAudioInt(outputTokens, 'SpeechUsage.output_tokens');
    requireAudioInt(totalTokens, 'SpeechUsage.total_tokens');
  }

  /// Serializes every count, letting typed values override original JSON.
  Map<String, dynamic> toJson() => mergeAudioJson(
    rawJson,
    const {'input_tokens', 'output_tokens', 'total_tokens'},
    {
      'input_tokens': inputTokens,
      'output_tokens': outputTokens,
      'total_tokens': totalTokens,
    },
  );

  /// Copies all counts and future metadata; an empty raw map clears its extras.
  SpeechUsage copyWith({
    int? inputTokens,
    int? outputTokens,
    int? totalTokens,
    Map<String, dynamic>? rawJson,
  }) => SpeechUsage(
    inputTokens: inputTokens ?? this.inputTokens,
    outputTokens: outputTokens ?? this.outputTokens,
    totalTokens: totalTokens ?? this.totalTokens,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechUsage &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      'SpeechUsage(inputTokens: $inputTokens, outputTokens: $outputTokens, '
      'totalTokens: $totalTokens, rawJson: ${rawJson.length} entries)';
}
