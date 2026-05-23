// ignore_for_file: avoid_dynamic_calls

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InteractionContent (media-only)', () {
    test('only the 5 media variants dispatch through fromJson', () {
      const types = ['text', 'image', 'audio', 'document', 'video'];
      for (final type in types) {
        final json = <String, dynamic>{'type': type};
        if (type == 'text') json['text'] = '';
        final content = InteractionContent.fromJson(json);
        expect(content.type, type);
      }
    });

    test('rejects removed tool-content discriminator values', () {
      for (final type in [
        'function_call',
        'function_result',
        'code_execution_call',
        'thought',
        'google_maps_call',
        'mcp_server_tool_call',
      ]) {
        expect(
          () => InteractionContent.fromJson({'type': type}),
          throwsA(isA<ArgumentError>()),
          reason: '$type should no longer be a Content variant',
        );
      }
    });

    group('TextContent', () {
      test('roundtrip serialization', () {
        const original = TextContent(text: 'Test message');
        final restored = InteractionContent.fromJson(original.toJson());
        expect(restored, isA<TextContent>());
        expect((restored as TextContent).text, original.text);
      });

      test('with url_citation annotation', () {
        final json = {
          'type': 'text',
          'text': 'Check this link',
          'annotations': [
            {
              'type': 'url_citation',
              'url': 'https://example.com',
              'title': 'Example',
              'start_index': 0,
              'end_index': 15,
            },
          ],
        };
        final textContent = InteractionContent.fromJson(json) as TextContent;
        expect(textContent.annotations, hasLength(1));
        final citation = textContent.annotations![0] as UrlCitation;
        expect(citation.url, 'https://example.com');
      });

      test('FileCitation parses new fields', () {
        final json = {
          'type': 'text',
          'text': '',
          'annotations': [
            {
              'type': 'file_citation',
              'file_name': 'doc.pdf',
              'document_uri': 'gs://bucket/doc.pdf',
              'source': 'file-123',
              'page_number': 5,
              'media_id': 'img-7',
              'custom_metadata': {'k': 'v'},
            },
          ],
        };
        final tc = InteractionContent.fromJson(json) as TextContent;
        final fc = tc.annotations![0] as FileCitation;
        expect(fc.fileName, 'doc.pdf');
        expect(fc.pageNumber, 5);
        expect(fc.mediaId, 'img-7');
        expect(fc.customMetadata, {'k': 'v'});
      });

      test('FileCitation roundtrip preserves new fields', () {
        const fc = FileCitation(
          fileName: 'doc.pdf',
          pageNumber: 12,
          mediaId: 'img-1',
          customMetadata: {'priority': 'high'},
        );
        final restored = Annotation.fromJson(fc.toJson()) as FileCitation;
        expect(restored.pageNumber, 12);
        expect(restored.mediaId, 'img-1');
        expect(restored.customMetadata, {'priority': 'high'});
      });
    });

    group('ImageContent', () {
      test('roundtrip with media resolution', () {
        const content = ImageContent(
          data: 'img',
          resolution: InteractionMediaResolution.ultraHigh,
        );
        final restored =
            InteractionContent.fromJson(content.toJson()) as ImageContent;
        expect(restored.resolution, InteractionMediaResolution.ultraHigh);
      });
    });

    group('AudioContent', () {
      test('uses sample_rate (renamed from rate)', () {
        final json = {
          'type': 'audio',
          'data': 'base64audio',
          'mime_type': 'audio/l16',
          'channels': 2,
          'sample_rate': 24000,
        };
        final content = InteractionContent.fromJson(json) as AudioContent;
        expect(content.channels, 2);
        expect(content.sampleRate, 24000);

        final out = content.toJson();
        expect(out['sample_rate'], 24000);
        expect(out.containsKey('rate'), isFalse);
      });

      test('copyWith preserves sampleRate', () {
        const content = AudioContent(
          data: 'data',
          channels: 1,
          sampleRate: 16000,
        );
        final copy = content.copyWith(sampleRate: 24000);
        expect(copy.channels, 1);
        expect(copy.sampleRate, 24000);
      });
    });

    group('DocumentContent', () {
      test('deserializes from JSON', () {
        final content = InteractionContent.fromJson({'type': 'document'});
        expect(content, isA<DocumentContent>());
      });
    });

    group('VideoContent', () {
      test('roundtrip with media resolution', () {
        const content = VideoContent(
          data: 'vid',
          resolution: InteractionMediaResolution.high,
        );
        final restored =
            InteractionContent.fromJson(content.toJson()) as VideoContent;
        expect(restored.resolution, InteractionMediaResolution.high);
      });
    });
  });
}
