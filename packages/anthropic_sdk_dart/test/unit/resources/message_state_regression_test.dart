import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

const _start = <String, dynamic>{
  'type': 'message_start',
  'message': {
    'id': 'msg_1',
    'model': 'claude-sonnet-5-5',
    'role': 'assistant',
    'type': 'message',
    'content': <Object>[],
    'usage': {'input_tokens': 1, 'output_tokens': 0},
  },
};

Stream<MessageStreamEvent> _events(
  Map<String, dynamic> block,
  Map<String, dynamic>? delta, {
  String stopReason = 'end_turn',
}) => Stream.fromIterable(
  [
    _start,
    {'type': 'content_block_start', 'index': 0, 'content_block': block},
    if (delta != null)
      {'type': 'content_block_delta', 'index': 0, 'delta': delta},
    {'type': 'content_block_stop', 'index': 0},
    {
      'type': 'message_delta',
      'delta': {'stop_reason': stopReason, 'stop_sequence': null},
      'usage': {'output_tokens': 1},
    },
    {'type': 'message_stop'},
  ].map(MessageStreamEvent.fromJson),
);

void main() {
  test('gated encrypted_content omission retains the previous value', () async {
    final message = await _events(
      {'type': 'compaction', 'content': null, 'encrypted_content': 'opaque'},
      {'type': 'compaction_delta', 'content': 'summary'},
    ).finalMessage();
    expect(
      (message.content.single as CompactionBlock).encryptedContent,
      'opaque',
    );
  });

  test(
    'explicit null clears encrypted content in a compaction delta',
    () async {
      final message = await _events(
        {
          'type': 'compaction',
          'content': 'initial',
          'encrypted_content': 'opaque',
        },
        {
          'type': 'compaction_delta',
          'content': 'final',
          'encrypted_content': null,
        },
      ).finalMessage();
      final block = message.content.single as CompactionBlock;
      expect(block.content, 'final');
      expect(block.encryptedContent, isNull);
    },
  );

  test('replay and copyWith keep explicit null signature and tool_changes', () {
    const json = {
      'type': 'compaction',
      'content': 'summary',
      'encrypted_content': null,
      'signature': null,
      'tool_changes': null,
    };
    final block = CompactionBlock.fromJson(json);
    expect(block.toJson(), json);
    final replay =
        block.copyWith(content: 'revised').toInputBlock()
            as CompactionInputBlock;
    expect(replay.copyWith().toJson(), {
      'type': 'compaction',
      'content': 'revised',
      'signature': null,
      'tool_changes': null,
    });
  });

  test('complete streamed content preserves data on block start', () async {
    for (final block in <Map<String, dynamic>>[
      {'type': 'text', 'text': 'Text on start'},
      {
        'type': 'thinking',
        'thinking': 'Thinking on start',
        'signature': 'fixture',
      },
      {
        'type': 'tool_use',
        'id': 'tool_fixture',
        'name': 'lookup',
        'input': {'value': 1},
      },
    ]) {
      final message = await _events(block, null).finalMessage();
      expect(message.content.single.toJson(), block);
    }
  });

  test('collects streamed arguments for server and MCP tools', () async {
    for (final block in <Map<String, dynamic>>[
      {
        'type': 'server_tool_use',
        'id': 'srvtool_fixture',
        'name': 'web_search',
        'input': <String, dynamic>{},
      },
      {
        'type': 'mcp_tool_use',
        'id': 'mcp_fixture',
        'name': 'lookup',
        'server_name': 'fixture',
        'input': <String, dynamic>{},
      },
    ]) {
      final message = await _events(block, {
        'type': 'input_json_delta',
        'partial_json': '{"value":1}',
      }).finalMessage();
      expect(message.content.single.toJson(), {
        ...block,
        'input': {'value': 1},
      });
    }
  });

  test('signed summary replay keeps explicit null tool_changes', () {
    const json = <String, dynamic>{
      'type': 'compaction',
      'content': 'summary',
      'signature': 'signed',
      'tool_changes': null,
    };
    final block = ContentBlock.fromJson(json).toInputBlock();
    expect(block.toJson(), json);
  });

  test(
    'final message cannot fabricate empty arguments for malformed JSON',
    () async {
      await expectLater(
        _events(
          {
            'type': 'tool_use',
            'id': 'tool_1',
            'name': 'dangerous_when_omitted',
            'input': <String, dynamic>{},
          },
          {'type': 'input_json_delta', 'partial_json': '{"name":'},
          stopReason: 'tool_use',
        ).finalMessage(),
        throwsA(anyOf(isA<FormatException>(), isA<StateError>())),
      );
    },
  );
}
