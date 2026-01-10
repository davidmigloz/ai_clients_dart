import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

void main() {
  group('Embeddable', () {
    group('factories', () {
      test('document factory creates EmbeddableDocument', () {
        final embeddable = Embeddable.document('Hello world');

        expect(embeddable, isA<EmbeddableDocument>());
        expect((embeddable as EmbeddableDocument).document, 'Hello world');
      });

      test('image factory creates EmbeddableImage', () {
        const base64Data = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAA';
        final embeddable = Embeddable.image(base64Data);

        expect(embeddable, isA<EmbeddableImage>());
        expect((embeddable as EmbeddableImage).image, base64Data);
      });
    });

    group('EmbeddableDocument', () {
      test('equality works correctly', () {
        const doc1 = EmbeddableDocument('Hello');
        const doc2 = EmbeddableDocument('Hello');
        const doc3 = EmbeddableDocument('World');

        expect(doc1, equals(doc2));
        expect(doc1, isNot(equals(doc3)));
      });

      test('hashCode is consistent', () {
        const doc1 = EmbeddableDocument('Hello');
        const doc2 = EmbeddableDocument('Hello');

        expect(doc1.hashCode, equals(doc2.hashCode));
      });

      test('toString returns readable representation', () {
        const doc = EmbeddableDocument('Hello world');

        expect(doc.toString(), 'EmbeddableDocument(Hello world)');
      });
    });

    group('EmbeddableImage', () {
      test('equality works correctly', () {
        const img1 = EmbeddableImage('abc123');
        const img2 = EmbeddableImage('abc123');
        const img3 = EmbeddableImage('xyz789');

        expect(img1, equals(img2));
        expect(img1, isNot(equals(img3)));
      });

      test('hashCode is consistent', () {
        const img1 = EmbeddableImage('abc123');
        const img2 = EmbeddableImage('abc123');

        expect(img1.hashCode, equals(img2.hashCode));
      });

      test('toString returns character count', () {
        const img = EmbeddableImage('abc123');

        expect(img.toString(), 'EmbeddableImage(6 chars)');
      });
    });

    group('pattern matching', () {
      test('switch expression works for EmbeddableDocument', () {
        final embeddable = Embeddable.document('test doc');

        final result = switch (embeddable) {
          EmbeddableDocument(:final document) => 'Document: $document',
          EmbeddableImage(:final image) => 'Image: ${image.length} chars',
        };

        expect(result, 'Document: test doc');
      });

      test('switch expression works for EmbeddableImage', () {
        final embeddable = Embeddable.image('base64data');

        final result = switch (embeddable) {
          EmbeddableDocument(:final document) => 'Document: $document',
          EmbeddableImage(:final image) => 'Image: ${image.length} chars',
        };

        expect(result, 'Image: 10 chars');
      });

      test('exhaustive matching covers all cases', () {
        final inputs = [Embeddable.document('doc'), Embeddable.image('img')];

        final results = inputs
            .map(
              (e) => switch (e) {
                EmbeddableDocument() => 'doc',
                EmbeddableImage() => 'img',
              },
            )
            .toList();

        expect(results, ['doc', 'img']);
      });
    });
  });
}
