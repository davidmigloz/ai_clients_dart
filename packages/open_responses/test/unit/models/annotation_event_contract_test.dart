import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

const _annotation = FileCitation(
  startIndex: 0,
  endIndex: 1,
  fileId: 'private file',
  filename: 'private filename',
);

Map<String, dynamic> _fixture({bool nullAnnotation = false}) => {
  'type': 'response.output_text.annotation.added',
  'sequence_number': 3,
  'item_id': 'private item',
  'output_index': 0,
  'content_index': 1,
  'annotation_index': 2,
  'annotation': nullAnnotation ? null : _annotation.toJson(),
};

void main() {
  group('required nullable annotation-added contract', () {
    for (final isNull in [false, true]) {
      test('shared SSE roundtrip null=$isNull', () {
        final json = _fixture(nullAnnotation: isNull);
        final parsed =
            StreamingEvent.fromJson(json) as OutputTextAnnotationAddedEvent;
        expect(parsed.annotation, isNull ? null : _annotation);
        expect(parsed.toJson(), json);
        expect(OutputTextAnnotationAddedEvent.fromJson(json), parsed);
        expect(
          OutputTextAnnotationAddedEvent.fromJson(json).hashCode,
          parsed.hashCode,
        );
      });
    }
    test('constructor nullable roundtrip and copy clearing', () {
      const original = OutputTextAnnotationAddedEvent(
        sequenceNumber: 3,
        itemId: 'item',
        outputIndex: 0,
        contentIndex: 1,
        annotationIndex: 2,
        annotation: _annotation,
      );
      expect(original.copyWith(), original);
      final cleared = original.copyWith(annotation: null);
      expect(cleared.annotation, isNull);
      expect(cleared.toJson().containsKey('annotation'), isTrue);
      expect(cleared.toJson()['annotation'], isNull);
      expect(
        OutputTextAnnotationAddedEvent.fromJson(cleared.toJson()),
        cleared,
      );
      expect(
        OutputTextAnnotationAddedEvent.fromJson(cleared.toJson()).hashCode,
        cleared.hashCode,
      );
      expect(cleared.copyWith(annotation: _annotation), original);
    });
    test('required nullable key cannot be missing', () {
      final json = _fixture()..remove('annotation');
      expect(
        () => OutputTextAnnotationAddedEvent.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('annotation'),
          ),
        ),
      );
      expect(() => StreamingEvent.fromJson(json), throwsFormatException);
    });
    for (final bad in <Object?>[
      true,
      1,
      'private text',
      <dynamic>[],
      <String, dynamic>{},
      {'type': 1},
      {'type': 'private future type'},
      {'type': 'file_citation', 'index': 0},
      {'type': 'url_citation', 'start_index': 0, 'end_index': null},
    ]) {
      test('malformed annotation ${bad.runtimeType} $bad', () {
        expect(
          () => OutputTextAnnotationAddedEvent.fromJson(
            _fixture()..['annotation'] = bad,
          ),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'safe context',
              allOf(contains('annotation'), isNot(contains('private'))),
            ),
          ),
        );
      });
    }
    for (final field in [
      'sequence_number',
      'output_index',
      'content_index',
      'annotation_index',
    ]) {
      test('existing provider omitted/null $field fallback remains zero', () {
        final absent = OutputTextAnnotationAddedEvent.fromJson(
          _fixture()..remove(field),
        );
        final nullable = OutputTextAnnotationAddedEvent.fromJson(
          _fixture()..[field] = null,
        );
        expect(absent.toJson()[field], 0);
        expect(nullable, absent);
      });
      for (final bad in <Object?>[
        1.5,
        true,
        'private number',
        <dynamic>[],
        <String, dynamic>{},
      ]) {
        test('malformed supplied $field ${bad.runtimeType}', () {
          expect(
            () => OutputTextAnnotationAddedEvent.fromJson(
              _fixture()..[field] = bad,
            ),
            throwsA(
              isA<FormatException>().having(
                (error) => error.message,
                'context',
                contains(field),
              ),
            ),
          );
        });
      }
    }
    test('required item_id rejects omission', () {
      expect(
        () => OutputTextAnnotationAddedEvent.fromJson(
          _fixture()..remove('item_id'),
        ),
        throwsFormatException,
      );
    });
    for (final bad in <Object?>[
      null,
      1,
      true,
      <dynamic>[],
      <String, dynamic>{},
    ]) {
      test('malformed item_id ${bad.runtimeType}', () {
        expect(
          () => OutputTextAnnotationAddedEvent.fromJson(
            _fixture()..['item_id'] = bad,
          ),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'context',
              contains('item_id'),
            ),
          ),
        );
      });
    }
    for (final type in <Object?>[null, false, 'other', 'private type']) {
      test('direct discriminator rejects $type', () {
        expect(
          () => OutputTextAnnotationAddedEvent.fromJson(
            _fixture()..['type'] = type,
          ),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'context',
              contains('.type'),
            ),
          ),
        );
      });
    }
    test('complete copy/value/hash contract across all fields', () {
      final original = OutputTextAnnotationAddedEvent.fromJson(_fixture());
      final equal = OutputTextAnnotationAddedEvent.fromJson(_fixture());
      expect(equal, original);
      expect(equal.hashCode, original.hashCode);
      for (final changed in [
        original.copyWith(sequenceNumber: 4),
        original.copyWith(itemId: 'different'),
        original.copyWith(outputIndex: 1),
        original.copyWith(contentIndex: 2),
        original.copyWith(annotationIndex: 3),
        original.copyWith(annotation: null),
      ]) {
        expect(changed, isNot(original));
        expect(
          OutputTextAnnotationAddedEvent.fromJson(changed.toJson()),
          changed,
        );
        expect(
          OutputTextAnnotationAddedEvent.fromJson(changed.toJson()).hashCode,
          changed.hashCode,
        );
      }
    });
    test('diagnostics include every field without payloads', () {
      final parsed = OutputTextAnnotationAddedEvent.fromJson(_fixture());
      expect(parsed.toString(), isNot(contains('private')));
      for (final field in [
        'sequenceNumber',
        'itemId',
        'outputIndex',
        'contentIndex',
        'annotationIndex',
        'annotation',
      ]) {
        expect(parsed.toString(), contains('$field:'));
      }
      expect(
        parsed.copyWith(annotation: null).toString(),
        contains('annotation: null'),
      );
    });
  });
}
