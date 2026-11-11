import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  test('thread shapes round-trip and require the continuation ID', () {
    const create = MessageThreadParam.create();
    const next = MessageThreadParam.continueFrom('msg_previous');
    expect(create.toJson(), {'type': 'create'});
    expect(next.toJson(), {
      'type': 'continue',
      'previous_message_id': 'msg_previous',
    });
    expect(MessageThreadParam.fromJson(create.toJson()), create);
    expect(MessageThreadParam.fromJson(next.toJson()).hashCode, next.hashCode);
    expect(next, isNot(create));
    expect(
      () => MessageThreadParam.fromJson(const {'type': 'continue'}),
      throwsFormatException,
    );
  });

  test('request state round-trips and can be cleared', () {
    final request = MessageCreateRequest(
      model: 'claude-sonnet-5-5',
      maxTokens: 128,
      messages: [InputMessage.user('Summarize')],
      compaction: const CompactionConfig.summarize(instructions: 'Keep dates.'),
    );
    final restored = MessageCreateRequest.fromJson(request.toJson());
    expect(restored, request);
    expect(restored.hashCode, request.hashCode);
    expect(request.toString(), contains('compaction: CompactionConfig'));
    expect(restored.compaction!.copyWith(instructions: null).toJson(), {
      'type': 'summarize',
    });
    final threaded = request.copyWith(
      compaction: null,
      thread: const MessageThreadParam.create(),
    );
    expect(threaded.toJson()['thread'], {'type': 'create'});
    expect(threaded.toJson(), isNot(contains('compaction')));
    expect(threaded.toString(), contains('thread: MessageThreadParam'));
    expect(threaded.copyWith(thread: null).toJson(), isNot(contains('thread')));
    expect(threaded, isNot(request));

    final count = TokenCountRequest.fromMessageCreateRequest(request);
    final countRestored = TokenCountRequest.fromJson(count.toJson());
    expect(countRestored, count);
    expect(countRestored.hashCode, count.hashCode);
    expect(count.toString(), contains('compaction: CompactionConfig'));
    expect(
      count.copyWith(compaction: null).toJson(),
      isNot(contains('compaction')),
    );
  });

  test(
    'signed compaction fields use deep equality and preserve an empty list',
    () {
      final summary = CompactionBlock.fromJson(const {
        'type': 'compaction',
        'content': 'Summary',
        'signature': 'opaque',
        'tool_changes': [
          {
            'type': 'future_change',
            'tool': {
              'metadata': ['future'],
            },
          },
        ],
      });
      final restored = CompactionBlock.fromJson(summary.toJson());
      expect(restored, summary);
      expect(restored.hashCode, summary.hashCode);
      expect(summary.toString(), contains('signature: [6 chars]'));
      expect(summary.toString(), contains('toolChanges: 1'));
      final input = summary.toInputBlock() as CompactionInputBlock;
      final inputAgain = CompactionInputBlock.fromJson(input.toJson());
      expect(inputAgain, input);
      expect(inputAgain.hashCode, input.hashCode);
      expect(input.toString(), contains('signature: [6 chars]'));
      expect(input.toString(), contains('toolChanges: 1'));
      final cleared = input.copyWith(signature: null, toolChanges: null);
      expect(cleared.toJson(), isNot(contains('signature')));
      expect(cleared.toJson(), isNot(contains('tool_changes')));
      final empty = summary.copyWith(
        toolChanges: const <Map<String, dynamic>>[],
      );
      expect(empty.toInputBlock().toJson()['tool_changes'], isEmpty);
    },
  );

  for (final type in ['thinking_dropped', 'thinking_mismatch_allowed']) {
    test('$type preserves future wire reasons', () {
      final json = {
        'type': type,
        'path': 'messages.0.content.1',
        'reason': 'future_binding_check',
      };
      final transformation = InputTransformation.fromJson(json);
      final restored = InputTransformation.fromJson(transformation.toJson());
      final (reason, moved) = switch (transformation) {
        ThinkingDroppedInputTransformation t => (
          t.reason,
          t.copyWith(path: 'messages.1.content.1'),
        ),
        ThinkingMismatchAllowedInputTransformation t => (
          t.reason,
          t.copyWith(path: 'messages.1.content.1'),
        ),
        _ => throw StateError('Unexpected transformation type'),
      };
      expect(reason, InputTransformationReason.unknown);
      expect(transformation.toJson(), json);
      expect(transformation.toString(), contains('future_binding_check'));
      expect(moved.toJson(), {...json, 'path': 'messages.1.content.1'});
      expect(restored, transformation);
      expect(restored.hashCode, transformation.hashCode);
    });
  }
}
