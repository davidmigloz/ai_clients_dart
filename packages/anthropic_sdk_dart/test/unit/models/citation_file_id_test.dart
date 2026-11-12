import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  final fixtures = <Map<String, dynamic>>[
    {
      'type': 'char_location',
      'cited_text': 'text',
      'document_index': 0,
      'document_title': 'Doc',
      'start_char_index': 0,
      'end_char_index': 4,
    },
    {
      'type': 'page_location',
      'cited_text': 'text',
      'document_index': 0,
      'document_title': 'Doc',
      'start_page_number': 1,
      'end_page_number': 2,
    },
    {
      'type': 'content_block_location',
      'cited_text': 'text',
      'document_index': 0,
      'document_title': 'Doc',
      'start_block_index': 0,
      'end_block_index': 1,
    },
  ];
  for (final fixture in fixtures) {
    test('${fixture['type']} retains response file identifier', () {
      final json = {...fixture, 'file_id': 'file-sensitive'};
      final value = Citation.fromJson(json);
      expect(value.toJson(), json);
      final duplicate = Citation.fromJson(json);
      expect(value, duplicate);
      expect(value.hashCode, duplicate.hashCode);
      expect(value.toString(), isNot(contains('file-sensitive')));
      final preserved = switch (value) {
        final CharLocationCitation c => c.copyWith(),
        final PageLocationCitation c => c.copyWith(),
        final ContentBlockLocationCitation c => c.copyWith(),
        _ => fail('Unexpected citation'),
      };
      final cleared = switch (value) {
        final CharLocationCitation c => c.copyWith(fileId: null),
        final PageLocationCitation c => c.copyWith(fileId: null),
        final ContentBlockLocationCitation c => c.copyWith(fileId: null),
        _ => fail('Unexpected citation'),
      };
      expect(preserved, value);
      expect(cleared, isNot(value));
      expect(cleared.toJson(), {...fixture, 'file_id': null});
      final legacy = Citation.fromJson(fixture);
      expect(legacy.toJson(), fixture);
      expect(legacy, cleared);
      expect(Citation.fromJson({...fixture, 'file_id': null}), cleared);
      expect(
        InputCitation.fromJson(json).toJson().containsKey('file_id'),
        isFalse,
      );
    });
    test('${fixture['type']} survives streaming accumulation', () {
      final event = MessageStreamEvent.fromJson({
        'type': 'content_block_delta',
        'index': 0,
        'delta': {
          'type': 'citations_delta',
          'citation': {...fixture, 'file_id': 'file-id'},
        },
      });
      expect(
        ((event.toJson()['delta'] as Map)['citation'] as Map)['file_id'],
        'file-id',
      );
      final accumulator = MessageStreamAccumulator()
        ..add(
          MessageStreamEvent.fromJson({
            'type': 'content_block_start',
            'index': 0,
            'content_block': {'type': 'text', 'text': ''},
          }),
        )
        ..add(event)
        ..add(
          MessageStreamEvent.fromJson({
            'type': 'content_block_stop',
            'index': 0,
          }),
        );
      expect(
        accumulator.textBlocks.single.citations!.single.toJson()['file_id'],
        'file-id',
      );
    });
  }
  test('response citation can be converted to a request without file_id', () {
    final response = TextBlock.fromJson({
      'type': 'text',
      'text': 'answer',
      'citations': [
        {...fixtures.first, 'file_id': 'file-123'},
      ],
    });
    final responseCitations = response.toJson()['citations'] as List<dynamic>;
    expect(
      (responseCitations.single as Map<String, dynamic>)['file_id'],
      'file-123',
    );
    final request = MessageCreateRequest.fromJson({
      'model': 'example',
      'max_tokens': 10,
      'messages': [
        {
          'role': 'assistant',
          'content': [response.toJson()],
        },
      ],
    });
    final messages = request.toJson()['messages'] as List<dynamic>;
    final blocks =
        (messages.single as Map<String, dynamic>)['content'] as List<dynamic>;
    final citations =
        (blocks.single as Map<String, dynamic>)['citations'] as List<dynamic>;
    expect(
      (citations.single as Map<String, dynamic>).containsKey('file_id'),
      isFalse,
    );
  });
}
