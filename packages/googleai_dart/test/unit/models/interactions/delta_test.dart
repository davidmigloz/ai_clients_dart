import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InteractionDelta', () {
    group('TextAnnotationDelta', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'text_annotation',
          'annotations': [
            {
              'type': 'url_citation',
              'url': 'https://example.com',
              'title': 'Example',
              'start_index': 0,
              'end_index': 10,
            },
          ],
        };
        final delta = InteractionDelta.fromJson(json);
        expect(delta, isA<TextAnnotationDelta>());
        final tad = delta as TextAnnotationDelta;
        expect(tad.type, 'text_annotation');
        expect(tad.annotations, hasLength(1));
        expect(tad.annotations![0], isA<UrlCitation>());
      });

      test('handles partial JSON (delta start)', () {
        final json = {'type': 'text_annotation'};
        final delta = InteractionDelta.fromJson(json);
        expect(delta, isA<TextAnnotationDelta>());
        expect((delta as TextAnnotationDelta).annotations, isNull);
      });

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
        final json = original.toJson();
        expect(json['type'], 'text_annotation');
        final restored = InteractionDelta.fromJson(json) as TextAnnotationDelta;
        expect(restored.annotations, hasLength(1));
        expect(
          (restored.annotations![0] as UrlCitation).url,
          'https://example.com',
        );
      });
    });

    group('AudioDelta', () {
      test('deserializes channels and rate', () {
        final json = {
          'type': 'audio',
          'data': 'audiodata',
          'channels': 2,
          'rate': 24000,
        };
        final delta = InteractionDelta.fromJson(json) as AudioDelta;
        expect(delta.channels, 2);
        expect(delta.rate, 24000);

        final toJson = delta.toJson();
        expect(toJson['channels'], 2);
        expect(toJson['rate'], 24000);
      });
    });

    group('TextDelta', () {
      test('does not have annotations field', () {
        final json = {'type': 'text', 'text': 'hello'};
        final delta = InteractionDelta.fromJson(json) as TextDelta;
        expect(delta.text, 'hello');

        final toJson = delta.toJson();
        expect(toJson.containsKey('annotations'), false);
      });
    });
  });

  group('InteractionResponseModality', () {
    test('parses document value', () {
      expect(
        interactionResponseModalityFromString('document'),
        InteractionResponseModality.document,
      );
    });

    test('parses video value', () {
      expect(
        interactionResponseModalityFromString('video'),
        InteractionResponseModality.video,
      );
    });

    test('roundtrip all values', () {
      for (final value in InteractionResponseModality.values) {
        final str = interactionResponseModalityToString(value);
        final parsed = interactionResponseModalityFromString(str);
        expect(parsed, value);
      }
    });
  });
}
