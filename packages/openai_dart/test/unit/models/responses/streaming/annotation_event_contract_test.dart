import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _annotation = FileCitation(
  index: 0,
  fileId: 'private file',
  filename: 'private filename',
);

Map<String, dynamic> _fixture({
  bool nullAnnotation = false,
  bool beta = false,
}) => {
  'type': 'response.output_text.annotation.added',
  'sequence_number': 3,
  'item_id': 'private item',
  'output_index': 0,
  'content_index': 1,
  'annotation_index': 2,
  'annotation': nullAnnotation ? null : _annotation.toJson(),
  if (beta) 'agent': {'agent_name': 'private agent'},
};

void main() {
  group('required nullable annotation-added contract', () {
    for (final beta in [false, true]) {
      for (final isNull in [false, true]) {
        test('SSE and WS shared roundtrip beta=$beta null=$isNull', () {
          final json = _fixture(nullAnnotation: isNull, beta: beta);
          final parsed =
              ResponseStreamEvent.fromJson(json)
                  as OutputTextAnnotationAddedEvent;
          expect(parsed.annotation, isNull ? null : _annotation);
          expect(parsed.toJson(), json);
          expect(OutputTextAnnotationAddedEvent.fromJson(json), parsed);
          expect(
            OutputTextAnnotationAddedEvent.fromJson(json).hashCode,
            parsed.hashCode,
          );
          final ws =
              ResponsesServerEvent.fromJson({...json, 'stream_id': 'lane'})
                  as ResponsesStreamEvent;
          expect(
            (ws.event as OutputTextAnnotationAddedEvent).annotation,
            parsed.annotation,
          );
          expect(ws.toJson(), {...json, 'stream_id': 'lane'});
        });
      }
    }

    test('constructor nullable roundtrip and copy clearing', () {
      const original = OutputTextAnnotationAddedEvent(
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

    test('known nullable key must be present', () {
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
      expect(() => ResponseStreamEvent.fromJson(json), throwsFormatException);
      expect(() => ResponsesServerEvent.fromJson(json), throwsFormatException);
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
      test('malformed supplied annotation ${bad.runtimeType} $bad', () {
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

    for (final field in ['output_index', 'content_index', 'annotation_index']) {
      for (final bad in <Object?>[
        null,
        1.5,
        true,
        'private number',
        <dynamic>[],
      ]) {
        test('malformed required $field ${bad.runtimeType}', () {
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
      test('missing required $field', () {
        expect(
          () => OutputTextAnnotationAddedEvent.fromJson(
            _fixture()..remove(field),
          ),
          throwsFormatException,
        );
      });
    }

    for (final field in ['item_id', 'sequence_number']) {
      test('existing optionalnullable $field omission/null compatibility', () {
        final absent = OutputTextAnnotationAddedEvent.fromJson(
          _fixture()..remove(field),
        );
        final nullable = OutputTextAnnotationAddedEvent.fromJson(
          _fixture()..[field] = null,
        );
        expect(absent, nullable);
        expect(absent.toJson().containsKey(field), isFalse);
      });
      for (final bad in <Object?>[true, <dynamic>[], <String, dynamic>{}]) {
        test('malformed supplied optional $field ${bad.runtimeType}', () {
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

    for (final bad in <Object?>[
      true,
      'private agent',
      <dynamic>[],
      <String, dynamic>{},
      {'agent_name': null},
      {'agent_name': 1},
    ]) {
      test('malformed supplied beta agent ${bad.runtimeType} $bad', () {
        expect(
          () => OutputTextAnnotationAddedEvent.fromJson(
            _fixture()..['agent'] = bad,
          ),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'safe context',
              allOf(contains('agent'), isNot(contains('private'))),
            ),
          ),
        );
      });
    }
    test('nullable beta agent retains established omission normalization', () {
      final parsed = OutputTextAnnotationAddedEvent.fromJson(
        _fixture()..['agent'] = null,
      );
      expect(parsed.agent, isNull);
      expect(parsed.toJson().containsKey('agent'), isFalse);
    });

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

    test('complete value/copy/hash contract across all fields', () {
      final original = OutputTextAnnotationAddedEvent.fromJson(
        _fixture(beta: true),
      );
      final equal = OutputTextAnnotationAddedEvent.fromJson(
        _fixture(beta: true),
      );
      expect(equal, original);
      expect(equal.hashCode, original.hashCode);
      expect(original.copyWith(), original);
      for (final changed in [
        original.copyWith(itemId: 'different'),
        original.copyWith(outputIndex: 1),
        original.copyWith(contentIndex: 2),
        original.copyWith(annotationIndex: 3),
        original.copyWith(annotation: null),
        original.copyWith(sequenceNumber: 4),
        original.copyWith(agent: const AgentTag(agentName: 'different')),
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
      final cleared = original.copyWith(
        itemId: null,
        sequenceNumber: null,
        agent: null,
        annotation: null,
      );
      expect(cleared.toJson(), {
        'type': original.type,
        'output_index': 0,
        'content_index': 1,
        'annotation_index': 2,
        'annotation': null,
      });
    });

    test(
      'diagnostics summarize every field without annotation/agent payloads',
      () {
        final parsed = OutputTextAnnotationAddedEvent.fromJson(
          _fixture(beta: true),
        );
        expect(parsed.toString(), isNot(contains('private')));
        for (final field in [
          'sequenceNumber',
          'itemId',
          'outputIndex',
          'contentIndex',
          'annotationIndex',
          'annotation',
          'agent',
        ]) {
          expect(parsed.toString(), contains('$field:'));
        }
        expect(
          parsed
              .copyWith(annotation: null, itemId: null, agent: null)
              .toString(),
          allOf(
            contains('annotation: null'),
            contains('itemId: null'),
            contains('agent: null'),
          ),
        );
      },
    );
  });
}
