// Compile-level smoke test: importers of `openai_dart_realtime.dart` alone
// (without also importing `openai_dart.dart`) must be able to name the
// audio-transcription types used by
// `InputAudioTranscriptionCompletedEvent.usage`/`languages`, so they can
// exhaustively switch over `TranscriptUsage`.
import 'package:openai_dart/openai_dart_realtime.dart';
import 'package:test/test.dart';

void main() {
  test('re-exports TranscriptUsage variants and TranscriptionLanguage', () {
    const TranscriptUsage tokensUsage = TranscriptTextUsageTokens(
      inputTokens: 1,
      outputTokens: 2,
      totalTokens: 3,
      inputTokenDetails: TranscriptUsageInputTokenDetails(
        audioTokens: 1,
        textTokens: 0,
      ),
    );
    const TranscriptUsage durationUsage = TranscriptTextUsageDuration(
      seconds: 1.5,
    );
    const TranscriptUsage unknownUsage = TranscriptUsageUnknown(
      rawType: 'future_usage_type',
      rawJson: {'type': 'future_usage_type'},
    );

    for (final usage in [tokensUsage, durationUsage, unknownUsage]) {
      final description = switch (usage) {
        TranscriptTextUsageTokens() => 'tokens',
        TranscriptTextUsageDuration() => 'duration',
        TranscriptUsageUnknown() => 'unknown',
      };
      expect(description, isNotEmpty);
    }

    const language = TranscriptionLanguage(code: 'en');

    const event = InputAudioTranscriptionCompletedEvent(
      eventId: 'event_1',
      itemId: 'item_1',
      contentIndex: 0,
      transcript: 'hello world',
      usage: tokensUsage,
      languages: [language],
    );

    expect(event.usage, tokensUsage);
    expect(event.languages, [language]);
  });
}
