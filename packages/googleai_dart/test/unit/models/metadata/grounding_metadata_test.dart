import 'package:googleai_dart/src/models/common/image.dart';
import 'package:googleai_dart/src/models/metadata/grounding_chunk.dart';
import 'package:googleai_dart/src/models/metadata/grounding_metadata.dart';
import 'package:googleai_dart/src/models/metadata/grounding_support.dart';
import 'package:googleai_dart/src/models/metadata/retrieval_metadata.dart';
import 'package:googleai_dart/src/models/metadata/search_entry_point.dart';
import 'package:googleai_dart/src/models/metadata/segment.dart';
import 'package:googleai_dart/src/models/metadata/web.dart';
import 'package:test/test.dart';

void main() {
  group('GroundingMetadata', () {
    group('fromJson', () {
      test('creates GroundingMetadata with all fields', () {
        final json = {
          'searchEntryPoint': {
            'renderedContent': '<div>Search content</div>',
            'sdkBlob': 'base64blob',
          },
          'groundingChunks': [
            {
              'web': {'uri': 'https://example.com', 'title': 'Example'},
            },
          ],
          'groundingSupports': [
            {
              'segment': {
                'startIndex': 0,
                'endIndex': 10,
                'text': 'Sample text',
              },
              'groundingChunkIndices': [0],
              'confidenceScores': [0.95],
            },
          ],
          'retrievalMetadata': {'googleSearchDynamicRetrievalScore': 0.85},
          'webSearchQueries': ['query1', 'query2'],
          'googleMapsWidgetContextToken': 'maps-token-123',
        };

        final metadata = GroundingMetadata.fromJson(json);

        expect(metadata.searchEntryPoint, isNotNull);
        expect(
          metadata.searchEntryPoint!.renderedContent,
          '<div>Search content</div>',
        );
        expect(metadata.groundingChunks, hasLength(1));
        expect(metadata.groundingChunks![0].web!.uri, 'https://example.com');
        expect(metadata.groundingSupports, hasLength(1));
        expect(metadata.retrievalMetadata, isNotNull);
        expect(metadata.webSearchQueries, ['query1', 'query2']);
        expect(metadata.googleMapsWidgetContextToken, 'maps-token-123');
      });

      test('creates GroundingMetadata with minimal fields', () {
        final json = <String, dynamic>{};

        final metadata = GroundingMetadata.fromJson(json);

        expect(metadata.searchEntryPoint, isNull);
        expect(metadata.groundingChunks, isNull);
        expect(metadata.groundingSupports, isNull);
        expect(metadata.retrievalMetadata, isNull);
        expect(metadata.webSearchQueries, isNull);
        expect(metadata.googleMapsWidgetContextToken, isNull);
      });
    });

    group('toJson', () {
      test('converts GroundingMetadata with all fields to JSON', () {
        const metadata = GroundingMetadata(
          searchEntryPoint: SearchEntryPoint(
            renderedContent: '<div>Content</div>',
          ),
          groundingChunks: [
            GroundingChunk(
              web: Web(uri: 'https://test.com', title: 'Test'),
            ),
          ],
          groundingSupports: [
            GroundingSupport(
              segment: Segment(startIndex: 0, endIndex: 5, text: 'Hello'),
              groundingChunkIndices: [0],
              confidenceScores: [0.9],
            ),
          ],
          retrievalMetadata: RetrievalMetadata(
            googleSearchDynamicRetrievalScore: 0.8,
          ),
          webSearchQueries: ['test query'],
          googleMapsWidgetContextToken: 'token-456',
        );

        final json = metadata.toJson();

        expect(json['searchEntryPoint'], isNotNull);
        expect(json['groundingChunks'], isNotNull);
        expect(json['groundingSupports'], isNotNull);
        expect(json['retrievalMetadata'], isNotNull);
        expect(json['webSearchQueries'], ['test query']);
        expect(json['googleMapsWidgetContextToken'], 'token-456');
      });

      test('omits null fields from JSON', () {
        const metadata = GroundingMetadata(webSearchQueries: ['query']);

        final json = metadata.toJson();

        expect(json.containsKey('searchEntryPoint'), false);
        expect(json.containsKey('groundingChunks'), false);
        expect(json['webSearchQueries'], ['query']);
      });
    });

    test('round-trip conversion preserves data', () {
      const original = GroundingMetadata(
        webSearchQueries: ['test', 'query'],
        googleMapsWidgetContextToken: 'token-roundtrip',
        retrievalMetadata: RetrievalMetadata(
          googleSearchDynamicRetrievalScore: 0.75,
        ),
      );

      final json = original.toJson();
      final restored = GroundingMetadata.fromJson(json);

      expect(restored.webSearchQueries, original.webSearchQueries);
      expect(
        restored.googleMapsWidgetContextToken,
        original.googleMapsWidgetContextToken,
      );
      expect(
        restored.retrievalMetadata!.googleSearchDynamicRetrievalScore,
        original.retrievalMetadata!.googleSearchDynamicRetrievalScore,
      );
    });
  });

  group('GroundingChunk', () {
    test('fromJson with web chunk', () {
      final json = {
        'web': {'uri': 'https://example.com', 'title': 'Example Title'},
      };

      final chunk = GroundingChunk.fromJson(json);

      expect(chunk.web, isNotNull);
      expect(chunk.web!.uri, 'https://example.com');
      expect(chunk.web!.title, 'Example Title');
      expect(chunk.retrievedContext, isNull);
      expect(chunk.image, isNull);
    });

    test('fromJson with image chunk', () {
      final json = {
        'image': {
          'domain': 'example.com',
          'imageUri': 'https://img.example.com/photo.jpg',
          'sourceUri': 'https://example.com/page',
          'title': 'Example Image',
        },
      };

      final chunk = GroundingChunk.fromJson(json);

      expect(chunk.image, isNotNull);
      expect(chunk.image!.domain, 'example.com');
      expect(chunk.image!.imageUri, 'https://img.example.com/photo.jpg');
      expect(chunk.image!.sourceUri, 'https://example.com/page');
      expect(chunk.image!.title, 'Example Image');
      expect(chunk.web, isNull);
    });

    test('toJson serializes web chunk correctly', () {
      const chunk = GroundingChunk(
        web: Web(uri: 'https://test.com', title: 'Test'),
      );

      final json = chunk.toJson();
      final webJson = json['web'] as Map<String, dynamic>?;

      expect(webJson!['uri'], 'https://test.com');
      expect(webJson['title'], 'Test');
      expect(json.containsKey('image'), isFalse);
    });

    test('toJson serializes image chunk correctly', () {
      const chunk = GroundingChunk(
        image: Image(
          domain: 'example.com',
          imageUri: 'https://img.example.com/photo.jpg',
        ),
      );

      final json = chunk.toJson();
      final imageJson = json['image'] as Map<String, dynamic>?;

      expect(imageJson!['domain'], 'example.com');
      expect(imageJson['imageUri'], 'https://img.example.com/photo.jpg');
      expect(json.containsKey('web'), isFalse);
    });

    test('round-trip preserves image chunk', () {
      final json = {
        'image': {
          'domain': 'test.com',
          'imageUri': 'https://img.test.com/img.png',
          'title': 'Test Image',
        },
      };

      final chunk = GroundingChunk.fromJson(json);
      final serialized = chunk.toJson();
      final imageJson = serialized['image'] as Map<String, dynamic>;

      expect(imageJson['domain'], 'test.com');
      expect(imageJson['imageUri'], 'https://img.test.com/img.png');
      expect(imageJson['title'], 'Test Image');
    });
  });

  group('GroundingSupport', () {
    test('fromJson parses all fields', () {
      final json = {
        'segment': {'startIndex': 10, 'endIndex': 25, 'text': 'supported text'},
        'groundingChunkIndices': [0, 1],
        'confidenceScores': [0.9, 0.8],
      };

      final support = GroundingSupport.fromJson(json);

      expect(support.segment!.startIndex, 10);
      expect(support.segment!.endIndex, 25);
      expect(support.segment!.text, 'supported text');
      expect(support.groundingChunkIndices, [0, 1]);
      expect(support.confidenceScores, [0.9, 0.8]);
    });

    test('fromJson parses renderedParts', () {
      final json = {
        'groundingChunkIndices': [0],
        'confidenceScores': [0.95],
        'renderedParts': [0, 2],
      };

      final support = GroundingSupport.fromJson(json);

      expect(support.renderedParts, [0, 2]);
    });

    test('toJson serializes renderedParts', () {
      const support = GroundingSupport(
        groundingChunkIndices: [0],
        renderedParts: [1, 3],
      );

      final json = support.toJson();

      expect(json['renderedParts'], [1, 3]);
    });

    test('toJson omits null renderedParts', () {
      const support = GroundingSupport(groundingChunkIndices: [0]);

      final json = support.toJson();

      expect(json.containsKey('renderedParts'), isFalse);
    });

    test('round-trip preserves renderedParts', () {
      final json = {
        'groundingChunkIndices': [0, 1],
        'confidenceScores': [0.9, 0.8],
        'renderedParts': [0, 1, 2],
      };

      final support = GroundingSupport.fromJson(json);
      final serialized = support.toJson();

      expect(serialized['renderedParts'], json['renderedParts']);
    });
  });

  group('Segment', () {
    test('fromJson and toJson work correctly', () {
      final json = {'startIndex': 5, 'endIndex': 15, 'text': 'test segment'};

      final segment = Segment.fromJson(json);
      expect(segment.startIndex, 5);
      expect(segment.endIndex, 15);
      expect(segment.text, 'test segment');

      final output = segment.toJson();
      expect(output['startIndex'], 5);
      expect(output['endIndex'], 15);
      expect(output['text'], 'test segment');
    });
  });

  group('RetrievalMetadata', () {
    test('fromJson parses score correctly', () {
      final json = {'googleSearchDynamicRetrievalScore': 0.85};

      final metadata = RetrievalMetadata.fromJson(json);

      expect(metadata.googleSearchDynamicRetrievalScore, 0.85);
    });

    test('toJson serializes correctly', () {
      const metadata = RetrievalMetadata(
        googleSearchDynamicRetrievalScore: 0.9,
      );

      final json = metadata.toJson();

      expect(json['googleSearchDynamicRetrievalScore'], 0.9);
    });
  });
}
