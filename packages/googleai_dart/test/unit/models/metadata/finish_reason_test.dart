import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FinishReason', () {
    group('finishReasonFromString', () {
      test('parses all known values', () {
        expect(finishReasonFromString('STOP'), FinishReason.stop);
        expect(finishReasonFromString('MAX_TOKENS'), FinishReason.maxTokens);
        expect(finishReasonFromString('SAFETY'), FinishReason.safety);
        expect(finishReasonFromString('RECITATION'), FinishReason.recitation);
        expect(finishReasonFromString('OTHER'), FinishReason.other);
        expect(finishReasonFromString('BLOCKLIST'), FinishReason.blocklist);
        expect(
          finishReasonFromString('PROHIBITED_CONTENT'),
          FinishReason.prohibitedContent,
        );
        expect(finishReasonFromString('SPII'), FinishReason.spii);
        expect(
          finishReasonFromString('MALFORMED_FUNCTION_CALL'),
          FinishReason.malformedFunctionCall,
        );
        expect(finishReasonFromString('LANGUAGE'), FinishReason.language);
        expect(
          finishReasonFromString('IMAGE_SAFETY'),
          FinishReason.imageSafety,
        );
        expect(
          finishReasonFromString('IMAGE_PROHIBITED_CONTENT'),
          FinishReason.imageProhibitedContent,
        );
        expect(finishReasonFromString('IMAGE_OTHER'), FinishReason.imageOther);
        expect(finishReasonFromString('NO_IMAGE'), FinishReason.noImage);
        expect(
          finishReasonFromString('IMAGE_RECITATION'),
          FinishReason.imageRecitation,
        );
        expect(
          finishReasonFromString('UNEXPECTED_TOOL_CALL'),
          FinishReason.unexpectedToolCall,
        );
        expect(
          finishReasonFromString('TOO_MANY_TOOL_CALLS'),
          FinishReason.tooManyToolCalls,
        );
        expect(
          finishReasonFromString('MISSING_THOUGHT_SIGNATURE'),
          FinishReason.missingThoughtSignature,
        );
        expect(
          finishReasonFromString('MALFORMED_RESPONSE'),
          FinishReason.malformedResponse,
        );
      });

      test('returns unspecified for unknown value', () {
        expect(finishReasonFromString('UNKNOWN'), FinishReason.unspecified);
      });

      test('returns unspecified for null', () {
        expect(finishReasonFromString(null), FinishReason.unspecified);
      });

      test('is case-insensitive', () {
        expect(finishReasonFromString('stop'), FinishReason.stop);
        expect(finishReasonFromString('Safety'), FinishReason.safety);
      });
    });

    group('finishReasonToString', () {
      test('converts all enum values', () {
        expect(finishReasonToString(FinishReason.stop), 'STOP');
        expect(finishReasonToString(FinishReason.maxTokens), 'MAX_TOKENS');
        expect(finishReasonToString(FinishReason.language), 'LANGUAGE');
        expect(finishReasonToString(FinishReason.imageSafety), 'IMAGE_SAFETY');
        expect(
          finishReasonToString(FinishReason.imageProhibitedContent),
          'IMAGE_PROHIBITED_CONTENT',
        );
        expect(finishReasonToString(FinishReason.imageOther), 'IMAGE_OTHER');
        expect(finishReasonToString(FinishReason.noImage), 'NO_IMAGE');
        expect(
          finishReasonToString(FinishReason.imageRecitation),
          'IMAGE_RECITATION',
        );
        expect(
          finishReasonToString(FinishReason.unexpectedToolCall),
          'UNEXPECTED_TOOL_CALL',
        );
        expect(
          finishReasonToString(FinishReason.tooManyToolCalls),
          'TOO_MANY_TOOL_CALLS',
        );
        expect(
          finishReasonToString(FinishReason.missingThoughtSignature),
          'MISSING_THOUGHT_SIGNATURE',
        );
        expect(
          finishReasonToString(FinishReason.malformedResponse),
          'MALFORMED_RESPONSE',
        );
        expect(
          finishReasonToString(FinishReason.unspecified),
          'FINISH_REASON_UNSPECIFIED',
        );
      });
    });

    test('round-trip conversion preserves all values', () {
      for (final reason in FinishReason.values) {
        final str = finishReasonToString(reason);
        final restored = finishReasonFromString(str);
        expect(restored, reason, reason: 'Failed for $reason');
      }
    });
  });
}
