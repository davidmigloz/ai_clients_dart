import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('StepDeltaData', () {
    test('the 9 documented step-delta variants dispatch to typed classes', () {
      const types = [
        'text',
        'image',
        'audio',
        'document',
        'video',
        'thought_summary',
        'thought_signature',
        'text_annotation_delta',
        'arguments_delta',
      ];
      for (final type in types) {
        final json = <String, dynamic>{'type': type};
        if (type == 'text') json['text'] = '';
        final delta = StepDeltaData.fromJson(json);
        expect(delta.type, type);
        expect(delta, isNot(isA<UnknownStepDelta>()), reason: type);
      }
    });

    test('undocumented tool-delta types parse as UnknownStepDelta', () {
      // The API also streams tool-call/result payloads as `step.delta` events
      // whose `type` mirrors the step; these are not in the published schema.
      for (final type in [
        'function_result',
        'code_execution_call',
        'mcp_server_tool_call',
        'google_search_call',
        'url_context_result',
      ]) {
        final delta = StepDeltaData.fromJson({'type': type, 'foo': 'bar'});
        expect(delta, isA<UnknownStepDelta>(), reason: type);
        expect(delta.type, type);
        expect((delta as UnknownStepDelta).json['foo'], 'bar');
      }
    });

    group('TextAnnotationDelta', () {
      test('roundtrip serialization', () {
        const original = TextAnnotationDelta(
          annotations: [
            UrlCitation(
              url: 'https://example.com',
              title: 'Test',
              startIndex: 0,
              endIndex: 5,
            ),
          ],
        );
        final restored =
            StepDeltaData.fromJson(original.toJson()) as TextAnnotationDelta;
        expect(restored.annotations, hasLength(1));
        expect(
          (restored.annotations![0] as UrlCitation).url,
          'https://example.com',
        );
      });
    });

    group('AudioDelta', () {
      test('uses sample_rate (renamed from rate)', () {
        final json = {
          'type': 'audio',
          'data': 'audiodata',
          'channels': 2,
          'sample_rate': 24000,
        };
        final delta = StepDeltaData.fromJson(json) as AudioDelta;
        expect(delta.channels, 2);
        expect(delta.sampleRate, 24000);
        final out = delta.toJson();
        expect(out['sample_rate'], 24000);
        expect(out.containsKey('rate'), isFalse);
      });
    });

    group('ArgumentsDelta', () {
      test('roundtrip', () {
        const delta = ArgumentsDelta(partialArguments: '{"a":');
        final restored =
            StepDeltaData.fromJson(delta.toJson()) as ArgumentsDelta;
        expect(restored.partialArguments, '{"a":');
      });

      test('handles empty partial', () {
        final delta = StepDeltaData.fromJson({'type': 'arguments_delta'});
        expect(delta, isA<ArgumentsDelta>());
        expect((delta as ArgumentsDelta).partialArguments, isNull);
      });

      test('rejects mismatched type', () {
        expect(
          () => ArgumentsDelta.fromJson({'type': 'text'}),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('ThoughtSummaryDelta', () {
      test(
        'parses content as ThoughtSummaryContent (not InteractionContent)',
        () {
          final json = {
            'type': 'thought_summary',
            'content': {'type': 'text', 'text': 'reasoning'},
          };
          final delta = StepDeltaData.fromJson(json) as ThoughtSummaryDelta;
          expect(delta.content, isA<ThoughtSummaryContentText>());
          final wrapper = delta.content! as ThoughtSummaryContentText;
          expect(wrapper.content.text, 'reasoning');
        },
      );
    });
  });

  group('InteractionResponseModality', () {
    test('roundtrip all values', () {
      for (final value in InteractionResponseModality.values) {
        final str = interactionResponseModalityToString(value);
        final parsed = interactionResponseModalityFromString(str);
        expect(parsed, value);
      }
    });
  });
}
