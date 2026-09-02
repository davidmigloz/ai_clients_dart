import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ContentBlock', () {
    group('TextBlock', () {
      test('fromJson parses text block', () {
        final json = {'type': 'text', 'text': 'Hello, world!'};
        final block = ContentBlock.fromJson(json);

        expect(block, isA<TextBlock>());
        final textBlock = block as TextBlock;
        expect(textBlock.text, 'Hello, world!');
      });

      test('toJson produces valid JSON', () {
        const block = TextBlock(text: 'Test message');
        final json = block.toJson();

        expect(json['type'], 'text');
        expect(json['text'], 'Test message');
      });

      test('copyWith creates modified copy', () {
        const original = TextBlock(text: 'Original');
        final modified = original.copyWith(text: 'Modified');

        expect(modified.text, 'Modified');
      });
    });

    group('ThinkingBlock', () {
      test('fromJson parses thinking block', () {
        final json = {
          'type': 'thinking',
          'thinking': 'Let me think...',
          'signature': 'sig123',
        };
        final block = ContentBlock.fromJson(json);

        expect(block, isA<ThinkingBlock>());
        final thinkingBlock = block as ThinkingBlock;
        expect(thinkingBlock.thinking, 'Let me think...');
        expect(thinkingBlock.signature, 'sig123');
      });

      test('toJson produces valid JSON', () {
        const block = ThinkingBlock(
          thinking: 'Deep thought',
          signature: 'abc123',
        );
        final json = block.toJson();

        expect(json['type'], 'thinking');
        expect(json['thinking'], 'Deep thought');
        expect(json['signature'], 'abc123');
      });

      test('fromJson tolerates missing signature (streaming '
          'content_block_start before signature_delta)', () {
        // MiniMax-Anthropic and other Anthropic-compatible servers emit
        // content_block_start without `signature`; the real signature
        // arrives later as a signature_delta the accumulator merges on.
        // `signature` is required only on the final response block, so
        // defaulting to empty keeps parsing robust for the partial
        // streaming shape too.
        final json = <String, dynamic>{'type': 'thinking', 'thinking': ''};
        final block = ContentBlock.fromJson(json);

        expect(block, isA<ThinkingBlock>());
        final thinking = block as ThinkingBlock;
        expect(thinking.thinking, '');
        expect(thinking.signature, '');
      });

      test('fromJson tolerates explicit null signature', () {
        final json = <String, dynamic>{
          'type': 'thinking',
          'thinking': 'hmm',
          'signature': null,
        };
        final block = ContentBlock.fromJson(json) as ThinkingBlock;
        expect(block.thinking, 'hmm');
        expect(block.signature, '');
      });

      test('fromJson tolerates missing thinking field', () {
        final json = <String, dynamic>{'type': 'thinking', 'signature': 'sig'};
        final block = ContentBlock.fromJson(json) as ThinkingBlock;
        expect(block.thinking, '');
        expect(block.signature, 'sig');
      });

      test(
        'toJson re-emits defaulted fields after parsing a partial block',
        () {
          // Parsing a partial streaming block defaults the fields; toJson must
          // still emit them (the always-emit contract round-trips rely on).
          final block =
              ContentBlock.fromJson({'type': 'thinking'}) as ThinkingBlock;
          expect(block.toJson(), {
            'type': 'thinking',
            'thinking': '',
            'signature': '',
          });
        },
      );
    });

    group('RedactedThinkingBlock', () {
      test('fromJson parses redacted thinking block with data', () {
        final json = {'type': 'redacted_thinking', 'data': 'opaque-blob'};
        final block = ContentBlock.fromJson(json);
        expect(block, isA<RedactedThinkingBlock>());
        expect((block as RedactedThinkingBlock).data, 'opaque-blob');
      });

      test('fromJson tolerates missing/null data (mirrors '
          'ThinkingBlock for non-canonical servers)', () {
        final missing =
            ContentBlock.fromJson({'type': 'redacted_thinking'})
                as RedactedThinkingBlock;
        expect(missing.data, '');

        final nullData =
            ContentBlock.fromJson({'type': 'redacted_thinking', 'data': null})
                as RedactedThinkingBlock;
        expect(nullData.data, '');
      });
    });

    group('ToolUseBlock', () {
      test('fromJson parses tool use block', () {
        final json = {
          'type': 'tool_use',
          'id': 'tu_123',
          'name': 'get_weather',
          'input': {'city': 'London', 'unit': 'celsius'},
        };
        final block = ContentBlock.fromJson(json);

        expect(block, isA<ToolUseBlock>());
        final toolUse = block as ToolUseBlock;
        expect(toolUse.id, 'tu_123');
        expect(toolUse.name, 'get_weather');
        expect(toolUse.input, {'city': 'London', 'unit': 'celsius'});
      });

      test('toJson produces valid JSON', () {
        const block = ToolUseBlock(
          id: 'tu_456',
          name: 'search',
          input: {'query': 'Dart programming'},
        );
        final json = block.toJson();

        expect(json['type'], 'tool_use');
        expect(json['id'], 'tu_456');
        expect(json['name'], 'search');
        expect(json['input'], {'query': 'Dart programming'});
      });

      test('copyWith creates modified copy', () {
        const original = ToolUseBlock(
          id: 'tu_1',
          name: 'original',
          input: {'key': 'value'},
        );
        final modified = original.copyWith(name: 'modified');

        expect(modified.name, 'modified');
        expect(modified.id, 'tu_1'); // Unchanged
        expect(modified.input, {'key': 'value'}); // Unchanged
      });

      test('parses caller metadata when present', () {
        final json = {
          'type': 'tool_use',
          'id': 'tu_1',
          'name': 'search',
          'input': {'q': 'hello'},
          'caller': {
            'type': 'code_execution_20260120',
            'tool_id': 'srvtoolu_1',
          },
        };

        final block = ContentBlock.fromJson(json) as ToolUseBlock;
        expect(block.caller, isA<ServerToolCaller>());
      });

      test('parses and round-trips toolsetName when present', () {
        final json = {
          'type': 'tool_use',
          'id': 'tu_1',
          'name': 'left_click',
          'input': {'x': 1, 'y': 2},
          'toolset_name': 'computer_toolset_20260801',
        };

        final block = ContentBlock.fromJson(json) as ToolUseBlock;
        expect(block.toolsetName, 'computer_toolset_20260801');
        expect(block.toJson(), json);
      });

      test('omits toolset_name when absent', () {
        const block = ToolUseBlock(id: 'tu_1', name: 'search', input: {});
        expect(block.toJson().containsKey('toolset_name'), isFalse);
      });

      test('copyWith updates toolsetName', () {
        const block = ToolUseBlock(id: 'tu_1', name: 'search', input: {});
        final updated = block.copyWith(toolsetName: 'browser_toolset_20260801');
        expect(updated.toolsetName, 'browser_toolset_20260801');
        expect(updated.copyWith(toolsetName: null).toolsetName, isNull);
      });
    });

    group('ServerToolUseBlock', () {
      test('fromJson parses web search tool use block', () {
        final json = {
          'type': 'server_tool_use',
          'id': 'stu_123',
          'name': 'web_search',
          'input': {'query': 'latest news'},
        };
        final block = ContentBlock.fromJson(json);

        expect(block, isA<ServerToolUseBlock>());
        final serverTool = block as ServerToolUseBlock;
        expect(serverTool.id, 'stu_123');
        expect(serverTool.name, 'web_search');
        expect(serverTool.input, {'query': 'latest news'});
      });
    });

    group('WebSearchToolResultBlock', () {
      test('fromJson parses web search result block (success)', () {
        final json = {
          'type': 'web_search_tool_result',
          'tool_use_id': 'tu_ws_123',
          'content': <dynamic>[
            {
              'type': 'web_search_result',
              'url': 'https://example.com',
              'title': 'Example',
              'encrypted_content': 'encrypted...',
              'page_age': '1 day ago',
            },
          ],
        };
        final block = ContentBlock.fromJson(json);

        expect(block, isA<WebSearchToolResultBlock>());
        final result = block as WebSearchToolResultBlock;
        expect(result.toolUseId, 'tu_ws_123');
        expect(result.content, isA<WebSearchResultSuccess>());
        final content = result.content as WebSearchResultSuccess;
        expect(content.results, hasLength(1));
        expect(content.results.first.url, 'https://example.com');
        expect(content.results.first.title, 'Example');
        expect(content.results.first.encryptedContent, 'encrypted...');
        expect(content.results.first.pageAge, '1 day ago');
      });

      test('fromJson parses web search result block (error)', () {
        final json = {
          'type': 'web_search_tool_result',
          'tool_use_id': 'tu_ws_err',
          'content': {
            'type': 'web_search_tool_result_error',
            'error_code': 'max_results_reached',
          },
        };
        final block = ContentBlock.fromJson(json);

        expect(block, isA<WebSearchToolResultBlock>());
        final result = block as WebSearchToolResultBlock;
        expect(result.toolUseId, 'tu_ws_err');
        expect(result.content, isA<WebSearchResultError>());
        final error = result.content as WebSearchResultError;
        // Unrecognized code: raw preserved, typed getter falls back to unknown.
        expect(error.rawErrorCode, 'max_results_reached');
        expect(error.errorCode, WebSearchToolResultErrorCode.unknown);
      });

      test('parses a known web search error code as a typed enum', () {
        final json = {
          'type': 'web_search_tool_result',
          'tool_use_id': 'tu_ws_err2',
          'content': {
            'type': 'web_search_tool_result_error',
            'error_code': 'max_uses_exceeded',
          },
        };
        final block = ContentBlock.fromJson(json) as WebSearchToolResultBlock;
        final error = block.content as WebSearchResultError;
        expect(error.rawErrorCode, 'max_uses_exceeded');
        expect(error.errorCode, WebSearchToolResultErrorCode.maxUsesExceeded);
        expect(block.toJson(), json);
      });

      test('roundtrip fromJson → toJson → fromJson (success)', () {
        final json = {
          'type': 'web_search_tool_result',
          'tool_use_id': 'tu_ws_rt',
          'content': <dynamic>[
            {
              'type': 'web_search_result',
              'url': 'https://example.com',
              'title': 'Example',
              'encrypted_content': 'enc_data',
            },
            {
              'type': 'web_search_result',
              'url': 'https://other.com',
              'title': 'Other',
            },
          ],
        };

        final block = ContentBlock.fromJson(json) as WebSearchToolResultBlock;
        final reJson = block.toJson();
        final block2 =
            ContentBlock.fromJson(reJson) as WebSearchToolResultBlock;

        expect(block2.toolUseId, block.toolUseId);
        expect(block2.content, isA<WebSearchResultSuccess>());
        final results = (block2.content as WebSearchResultSuccess).results;
        expect(results, hasLength(2));
        expect(results[0].url, 'https://example.com');
        expect(results[1].url, 'https://other.com');
      });

      test('roundtrip fromJson → toJson → fromJson (error)', () {
        final json = {
          'type': 'web_search_tool_result',
          'tool_use_id': 'tu_ws_rt_err',
          'content': {
            'type': 'web_search_tool_result_error',
            'error_code': 'search_unavailable',
          },
        };

        final block = ContentBlock.fromJson(json) as WebSearchToolResultBlock;
        final reJson = block.toJson();
        final block2 =
            ContentBlock.fromJson(reJson) as WebSearchToolResultBlock;

        expect(block2.toolUseId, block.toolUseId);
        expect(block2.content, isA<WebSearchResultError>());
        // Raw value round-trips verbatim even for unrecognized codes.
        expect(
          (block2.content as WebSearchResultError).rawErrorCode,
          'search_unavailable',
        );
      });
    });

    group('MCPToolUseBlock', () {
      test('fromJson parses all fields', () {
        final json = {
          'type': 'mcp_tool_use',
          'id': 'tu_mcp_1',
          'name': 'read_file',
          'server_name': 'filesystem',
          'input': {'path': '/tmp/test.txt'},
        };

        final block = ContentBlock.fromJson(json);
        expect(block, isA<MCPToolUseBlock>());
        final mcp = block as MCPToolUseBlock;
        expect(mcp.id, 'tu_mcp_1');
        expect(mcp.name, 'read_file');
        expect(mcp.serverName, 'filesystem');
        expect(mcp.input, {'path': '/tmp/test.txt'});
      });

      test('toJson round-trips correctly', () {
        const block = MCPToolUseBlock(
          id: 'tu_1',
          name: 'query',
          serverName: 'db-server',
          input: {'sql': 'SELECT 1'},
        );

        final json = block.toJson();
        expect(json['type'], 'mcp_tool_use');
        expect(json['server_name'], 'db-server');

        final restored = MCPToolUseBlock.fromJson(json);
        expect(restored, equals(block));
      });

      test('copyWith creates modified copy', () {
        const block = MCPToolUseBlock(
          id: 'tu_1',
          name: 'tool_a',
          serverName: 'server_a',
          input: {'key': 'value'},
        );

        final modified = block.copyWith(name: 'tool_b');
        expect(modified.name, 'tool_b');
        expect(modified.id, 'tu_1');
      });

      test('equality uses content-based map comparison', () {
        const a = MCPToolUseBlock(
          id: 'tu_1',
          name: 'tool',
          serverName: 'srv',
          input: {'k': 'v'},
        );
        const b = MCPToolUseBlock(
          id: 'tu_1',
          name: 'tool',
          serverName: 'srv',
          input: {'k': 'v'},
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('MCPToolResultBlock', () {
      test('fromJson with string content', () {
        final json = {
          'type': 'mcp_tool_result',
          'content': 'file contents here',
          'is_error': false,
          'tool_use_id': 'tu_mcp_1',
        };

        final block = ContentBlock.fromJson(json);
        expect(block, isA<MCPToolResultBlock>());
        final result = block as MCPToolResultBlock;
        expect(result.content, isA<MCPToolResultStringContent>());
        expect(
          (result.content as MCPToolResultStringContent).text,
          'file contents here',
        );
        expect(result.isError, false);
        expect(result.toolUseId, 'tu_mcp_1');
      });

      test('fromJson with list content', () {
        final json = {
          'type': 'mcp_tool_result',
          'content': [
            {'type': 'text', 'text': 'block one'},
            {'type': 'text', 'text': 'block two'},
          ],
          'is_error': false,
          'tool_use_id': 'tu_mcp_2',
        };

        final block = MCPToolResultBlock.fromJson(json);
        expect(block.content, isA<MCPToolResultBlocksContent>());
        final blocks = (block.content as MCPToolResultBlocksContent).blocks;
        expect(blocks, hasLength(2));
        expect(blocks[0].text, 'block one');
        expect(blocks[1].text, 'block two');
      });

      test('isError defaults to false', () {
        final json = {
          'type': 'mcp_tool_result',
          'content': 'ok',
          'tool_use_id': 'tu_1',
        };

        final block = MCPToolResultBlock.fromJson(json);
        expect(block.isError, false);
      });

      test('toJson round-trips string content', () {
        final block = MCPToolResultBlock(
          content: MCPToolResultContent.text('result'),
          toolUseId: 'tu_1',
        );

        final json = block.toJson();
        expect(json['type'], 'mcp_tool_result');
        expect(json['content'], 'result');
        expect(json['is_error'], false);

        final restored = MCPToolResultBlock.fromJson(json);
        expect(restored, equals(block));
      });

      test('toJson round-trips list content', () {
        final block = MCPToolResultBlock(
          content: MCPToolResultContent.blocks([
            const TextBlock(text: 'hello'),
          ]),
          isError: true,
          toolUseId: 'tu_1',
        );

        final json = block.toJson();
        expect(json['is_error'], true);
        expect(json['content'], isList);

        final restored = MCPToolResultBlock.fromJson(json);
        expect(restored, equals(block));
      });
    });

    group('Additional tool result blocks', () {
      test('parses web fetch tool result block', () {
        final json = {
          'type': 'web_fetch_tool_result',
          'tool_use_id': 'tu_wf_1',
          'caller': {'type': 'direct'},
          'content': {
            'type': 'web_fetch_result',
            'url': 'https://example.com',
            'content': 'Example text',
          },
        };

        final block = ContentBlock.fromJson(json);
        expect(block, isA<WebFetchToolResultBlock>());
        final result = block as WebFetchToolResultBlock;
        expect(result.toolUseId, 'tu_wf_1');
        expect(result.caller, isA<DirectToolCaller>());
      });

      test('parses compaction block', () {
        final json = {'type': 'compaction', 'content': 'Conversation summary'};

        final block = ContentBlock.fromJson(json);
        expect(block, isA<CompactionBlock>());
        final compaction = block as CompactionBlock;
        expect(compaction.content, 'Conversation summary');
        expect(compaction.encryptedContent, isNull);
      });

      test('round-trips compaction block with encrypted_content', () {
        final json = {
          'type': 'compaction',
          'content': 'Conversation summary',
          'encrypted_content': 'enc_payload_xyz',
        };

        final block = ContentBlock.fromJson(json) as CompactionBlock;
        expect(block.encryptedContent, 'enc_payload_xyz');
        expect(block.toJson(), json);
      });

      test('compaction block always serializes encrypted_content key', () {
        const block = CompactionBlock(content: 'Summary');
        final json = block.toJson();

        expect(json.containsKey('encrypted_content'), isTrue);
        expect(json['encrypted_content'], isNull);
      });
    });
  });

  group('InputContentBlock', () {
    group('TextInputBlock', () {
      test('factory text creates text block', () {
        final block = InputContentBlock.text('Hello, Claude!');

        expect(block, isA<TextInputBlock>());
        expect((block as TextInputBlock).text, 'Hello, Claude!');
      });

      test('toJson produces valid JSON', () {
        const block = TextInputBlock('Test input');
        final json = block.toJson();

        expect(json['type'], 'text');
        expect(json['text'], 'Test input');
      });

      test('supports cache control', () {
        const block = TextInputBlock(
          'Cached content',
          cacheControl: CacheControlEphemeral(),
        );
        final json = block.toJson();

        expect(json['cache_control'], {'type': 'ephemeral'});
      });

      test('round-trips citations', () {
        const block = TextInputBlock(
          'cited text',
          citations: [
            SearchResultLocationInputCitation(
              citedText: 'cited text',
              searchResultIndex: 0,
              source: 'kb://doc-1',
              title: 'Doc 1',
              startBlockIndex: 0,
              endBlockIndex: 1,
            ),
          ],
        );
        final json = block.toJson();
        expect(json['citations'], hasLength(1));
        expect(TextInputBlock.fromJson(json), equals(block));
      });

      test('omits citations when absent; copyWith sets and clears them', () {
        const block = TextInputBlock('no citations');
        expect(block.toJson().containsKey('citations'), isFalse);

        final withCitations = block.copyWith(
          citations: const [
            CharLocationInputCitation(
              citedText: 'a',
              documentIndex: 0,
              documentTitle: null,
              startCharIndex: 0,
              endCharIndex: 1,
            ),
          ],
        );
        expect(withCitations.citations, hasLength(1));
        expect(withCitations.copyWith(citations: null).citations, isNull);
      });

      test('toString includes citations', () {
        const block = TextInputBlock('hi', citations: []);
        expect(block.toString(), contains('citations: []'));
      });
    });

    group('ThinkingInputBlock', () {
      test('round-trips thinking block', () {
        const block = ThinkingInputBlock(
          thinking: 'Let me think about this...',
          signature: 'sig123',
        );
        final json = block.toJson();

        expect(json['type'], 'thinking');
        expect(json['thinking'], 'Let me think about this...');
        expect(json['signature'], 'sig123');
        expect(json.containsKey('cache_control'), isFalse);
        expect(json, hasLength(3));

        final parsed = InputContentBlock.fromJson(json);
        expect(parsed, isA<ThinkingInputBlock>());
        expect(parsed, equals(block));
      });

      test('fromJson parses thinking block as typed variant '
          '(not UnknownInputContentBlock)', () {
        final block = InputContentBlock.fromJson({
          'type': 'thinking',
          'thinking': 'Reasoning...',
          'signature': 'sig456',
        });

        expect(block, isA<ThinkingInputBlock>());
        expect(block, isNot(isA<UnknownInputContentBlock>()));
      });

      test('fromJson throws on missing required fields', () {
        expect(
          () => InputContentBlock.fromJson({'type': 'thinking'}),
          throwsFormatException,
        );
        expect(
          () => InputContentBlock.fromJson({
            'type': 'thinking',
            'thinking': 'Reasoning...',
          }),
          throwsFormatException,
        );
      });

      test('fromJson accepts empty-but-present fields', () {
        final block =
            InputContentBlock.fromJson({
                  'type': 'thinking',
                  'thinking': '',
                  'signature': '',
                })
                as ThinkingInputBlock;

        expect(block.thinking, '');
        expect(block.signature, '');
      });

      test('factory creates ThinkingInputBlock', () {
        final block = InputContentBlock.thinking(
          thinking: 'Some reasoning',
          signature: 'sig789',
        );

        expect(block, isA<ThinkingInputBlock>());
        final thinkingBlock = block as ThinkingInputBlock;
        expect(thinkingBlock.thinking, 'Some reasoning');
        expect(thinkingBlock.signature, 'sig789');
      });

      test('copyWith replaces fields independently', () {
        const block = ThinkingInputBlock(
          thinking: 'Original thinking',
          signature: 'original_sig',
        );

        final withNewThinking = block.copyWith(thinking: 'New thinking');
        expect(withNewThinking.thinking, 'New thinking');
        expect(withNewThinking.signature, 'original_sig');

        final withNewSignature = block.copyWith(signature: 'new_sig');
        expect(withNewSignature.thinking, 'Original thinking');
        expect(withNewSignature.signature, 'new_sig');
      });

      test('equality and hashCode', () {
        const a = ThinkingInputBlock(thinking: 'Same', signature: 'sig');
        const b = ThinkingInputBlock(thinking: 'Same', signature: 'sig');
        const differentThinking = ThinkingInputBlock(
          thinking: 'Different',
          signature: 'sig',
        );
        const differentSignature = ThinkingInputBlock(
          thinking: 'Same',
          signature: 'other',
        );

        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
        expect(a, isNot(equals(differentThinking)));
        expect(a, isNot(equals(differentSignature)));
      });

      test('toString does not leak content', () {
        const block = ThinkingInputBlock(thinking: 'abcde', signature: 'sig');
        expect(block.toString(), contains('[5 chars]'));
        expect(block.toString(), isNot(contains('abcde')));
      });
    });

    group('RedactedThinkingInputBlock', () {
      test('round-trips redacted thinking block', () {
        const block = RedactedThinkingInputBlock(data: 'opaque_payload');
        final json = block.toJson();

        expect(json['type'], 'redacted_thinking');
        expect(json['data'], 'opaque_payload');
        expect(json.containsKey('cache_control'), isFalse);
        expect(json, hasLength(2));

        final parsed = InputContentBlock.fromJson(json);
        expect(parsed, isA<RedactedThinkingInputBlock>());
        expect(parsed, equals(block));
      });

      test('fromJson parses redacted thinking block as typed variant '
          '(not UnknownInputContentBlock)', () {
        final block = InputContentBlock.fromJson({
          'type': 'redacted_thinking',
          'data': 'encrypted_data',
        });

        expect(block, isA<RedactedThinkingInputBlock>());
        expect(block, isNot(isA<UnknownInputContentBlock>()));
      });

      test('fromJson throws on missing required data', () {
        expect(
          () => InputContentBlock.fromJson({'type': 'redacted_thinking'}),
          throwsFormatException,
        );
      });

      test('fromJson accepts an empty-but-present data', () {
        final block =
            InputContentBlock.fromJson({
                  'type': 'redacted_thinking',
                  'data': '',
                })
                as RedactedThinkingInputBlock;

        expect(block.data, '');
      });

      test('factory creates RedactedThinkingInputBlock', () {
        final block = InputContentBlock.redactedThinking(data: 'opaque');

        expect(block, isA<RedactedThinkingInputBlock>());
        expect((block as RedactedThinkingInputBlock).data, 'opaque');
      });

      test('copyWith replaces data', () {
        const block = RedactedThinkingInputBlock(data: 'original');
        final copy = block.copyWith(data: 'updated');

        expect(copy.data, 'updated');
      });

      test('equality and hashCode', () {
        const a = RedactedThinkingInputBlock(data: 'same');
        const b = RedactedThinkingInputBlock(data: 'same');
        const c = RedactedThinkingInputBlock(data: 'different');

        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
        expect(a, isNot(equals(c)));
      });

      test('toString does not leak content', () {
        const block = RedactedThinkingInputBlock(data: 'abcde');
        expect(block.toString(), contains('[5 chars]'));
        expect(block.toString(), isNot(contains('abcde')));
      });
    });

    group('SearchResultInputBlock', () {
      Map<String, dynamic> sampleJson() => {
        'type': 'search_result',
        'content': [
          {
            'type': 'text',
            'text': 'Earth orbits the Sun.',
            'citations': [
              {
                'type': 'search_result_location',
                'cited_text': 'Earth orbits the Sun.',
                'search_result_index': 0,
                'source': 'kb://astro',
                'title': 'Astronomy',
                'start_block_index': 0,
                'end_block_index': 1,
              },
            ],
          },
          {'type': 'text', 'text': 'It takes 365 days.'},
        ],
        'source': 'kb://astro',
        'title': 'Astronomy',
        'citations': {'enabled': true},
      };

      test('factory creates a search result block', () {
        final block = InputContentBlock.searchResult(
          content: const [TextInputBlock('Earth orbits the Sun.')],
          source: 'kb://astro',
          title: 'Astronomy',
          citations: const RequestCitationsConfig(enabled: true),
        );
        expect(block, isA<SearchResultInputBlock>());
        final b = block as SearchResultInputBlock;
        expect(b.content, hasLength(1));
        expect(b.source, 'kb://astro');
        expect(b.title, 'Astronomy');
        expect(b.citations, const RequestCitationsConfig(enabled: true));
      });

      test('dispatches via InputContentBlock.fromJson and round-trips', () {
        final json = sampleJson();
        final block = InputContentBlock.fromJson(json);
        expect(block, isA<SearchResultInputBlock>());
        expect(block.toJson(), json);
      });

      test('omits citations/cacheControl when absent', () {
        const block = SearchResultInputBlock(
          content: [TextInputBlock('x')],
          source: 's',
          title: 't',
        );
        final json = block.toJson();
        expect(json.containsKey('citations'), isFalse);
        expect(json.containsKey('cache_control'), isFalse);
      });

      test('copyWith updates fields and clears nullables', () {
        const block = SearchResultInputBlock(
          content: [TextInputBlock('x')],
          source: 's',
          title: 't',
          citations: RequestCitationsConfig(enabled: true),
        );
        expect(block.copyWith(title: 'new').title, 'new');
        expect(block.copyWith(source: 'z').citations, isNotNull);
        expect(block.copyWith(citations: null).citations, isNull);
      });

      test('toString includes fields', () {
        const block = SearchResultInputBlock(
          content: [TextInputBlock('x')],
          source: 'kb://astro',
          title: 'Astronomy',
        );
        final s = block.toString();
        expect(s, contains('SearchResultInputBlock'));
        expect(s, contains('source: kb://astro'));
        expect(s, contains('title: Astronomy'));
      });
    });

    group('mid_conv_system removal', () {
      test('fromJson falls back to UnknownInputContentBlock '
          '(type removed from the spec)', () {
        final json = {
          'type': 'mid_conv_system',
          'content': [
            {'type': 'text', 'text': 'From now on, answer in French.'},
          ],
          'cache_control': {'type': 'ephemeral'},
        };
        final block = InputContentBlock.fromJson(json);
        expect(block, isA<UnknownInputContentBlock>());
        expect(block.toJson(), json);
      });
    });

    group('DocumentInputBlock citations/context', () {
      test('round-trips citations and context', () {
        final block = DocumentInputBlock(
          DocumentSource.url('https://example.com/doc.pdf'),
          title: 'Doc',
          context: 'Quarterly report',
          citations: const RequestCitationsConfig(enabled: true),
        );
        final json = block.toJson();
        expect(json['context'], 'Quarterly report');
        expect(json['citations'], {'enabled': true});
        expect(DocumentInputBlock.fromJson(json), equals(block));
      });

      test('omits citations/context when absent; copyWith clears them', () {
        final block = DocumentInputBlock(
          DocumentSource.url('https://example.com/doc.pdf'),
        );
        final json = block.toJson();
        expect(json.containsKey('context'), isFalse);
        expect(json.containsKey('citations'), isFalse);

        final withBoth = block.copyWith(
          context: 'ctx',
          citations: const RequestCitationsConfig(),
        );
        expect(withBoth.copyWith(context: null).context, isNull);
        expect(withBoth.copyWith(citations: null).citations, isNull);
      });

      test('toString includes context and citations', () {
        final block = DocumentInputBlock(
          DocumentSource.url('https://example.com/doc.pdf'),
          context: 'ctx',
          citations: const RequestCitationsConfig(),
        );
        final s = block.toString();
        expect(s, contains('context: ctx'));
        expect(s, contains('citations:'));
      });
    });

    group('ImageInputBlock', () {
      test('creates base64 image input', () {
        const block = ImageInputBlock(
          Base64ImageSource(
            mediaType: ImageMediaType.png,
            data: 'base64data...',
          ),
        );
        final json = block.toJson();

        expect(json['type'], 'image');
        final source = json['source'] as Map<String, dynamic>;
        expect(source['type'], 'base64');
        expect(source['media_type'], 'image/png');
        expect(source['data'], 'base64data...');
      });

      test('creates URL image input', () {
        const block = ImageInputBlock(
          UrlImageSource('https://example.com/image.png'),
        );
        final json = block.toJson();

        expect(json['type'], 'image');
        final source = json['source'] as Map<String, dynamic>;
        expect(source['type'], 'url');
        expect(source['url'], 'https://example.com/image.png');
      });
    });

    group('ToolUseInputBlock', () {
      test('round-trips toolsetName', () {
        final json = {
          'type': 'tool_use',
          'id': 'tu_1',
          'name': 'left_click',
          'input': {'x': 1, 'y': 2},
          'toolset_name': 'computer_toolset_20260801',
        };

        final block = InputContentBlock.fromJson(json) as ToolUseInputBlock;
        expect(block.toolsetName, 'computer_toolset_20260801');
        expect(block.toJson(), json);
      });

      test('omits toolset_name when absent', () {
        const block = ToolUseInputBlock(id: 'tu_1', name: 'search', input: {});
        expect(block.toJson().containsKey('toolset_name'), isFalse);
      });
    });

    group('ToolResultInputBlock', () {
      test('creates tool result with text content', () {
        const block = ToolResultInputBlock(
          toolUseId: 'tu_123',
          content: [ToolResultTextContent('Tool result')],
        );
        final json = block.toJson();

        expect(json['type'], 'tool_result');
        expect(json['tool_use_id'], 'tu_123');
        expect(json['content'], hasLength(1));
        expect(
          ((json['content'] as List)[0] as Map<String, dynamic>)['type'],
          'text',
        );
      });

      test('text factory creates single text result', () {
        final block = ToolResultInputBlock.text(
          toolUseId: 'tu_789',
          text: 'Sunny, 22°C',
        );

        expect(block.toolUseId, 'tu_789');
        expect(block.content, hasLength(1));
        expect(block.content!.first, isA<ToolResultTextContent>());
        expect(
          (block.content!.first as ToolResultTextContent).text,
          'Sunny, 22°C',
        );
        expect(block.isError, isNull);
        expect(block.cacheControl, isNull);
      });

      test('text factory supports isError and cacheControl', () {
        final block = ToolResultInputBlock.text(
          toolUseId: 'tu_err',
          text: 'Error: not found',
          isError: true,
          cacheControl: const CacheControlEphemeral(),
        );

        expect(block.isError, isTrue);
        expect(block.cacheControl, isNotNull);
      });

      test('InputContentBlock.toolResultText factory works', () {
        final block = InputContentBlock.toolResultText(
          toolUseId: 'tu_abc',
          text: 'Result text',
        );

        expect(block, isA<ToolResultInputBlock>());
        final toolResult = block as ToolResultInputBlock;
        expect(toolResult.toolUseId, 'tu_abc');
        expect(toolResult.content, hasLength(1));
        expect(
          (toolResult.content!.first as ToolResultTextContent).text,
          'Result text',
        );
      });

      test('text factory toJson produces valid JSON', () {
        final block = ToolResultInputBlock.text(
          toolUseId: 'tu_json',
          text: 'Some result',
        );
        final json = block.toJson();

        expect(json['type'], 'tool_result');
        expect(json['tool_use_id'], 'tu_json');
        expect(json['content'], hasLength(1));
        final content = (json['content'] as List)[0] as Map<String, dynamic>;
        expect(content['type'], 'text');
        expect(content['text'], 'Some result');
      });

      test('creates error tool result', () {
        const block = ToolResultInputBlock(
          toolUseId: 'tu_456',
          content: [ToolResultTextContent('Error: Not found')],
          isError: true,
        );
        final json = block.toJson();

        expect(json['is_error'], isTrue);
      });

      test('fromJson normalizes a plain string content to a single text '
          'block', () {
        final json = {
          'type': 'tool_result',
          'tool_use_id': 'tu_str',
          'content': 'Sunny, 22°C',
        };

        final block = ToolResultInputBlock.fromJson(json);

        expect(block.content, hasLength(1));
        expect(
          (block.content!.single as ToolResultTextContent).text,
          'Sunny, 22°C',
        );
      });

      test('fromJson still accepts list content', () {
        final json = {
          'type': 'tool_result',
          'tool_use_id': 'tu_list',
          'content': [
            {'type': 'text', 'text': 'hi'},
          ],
        };

        final block = ToolResultInputBlock.fromJson(json);

        expect(block.content, hasLength(1));
        expect((block.content!.single as ToolResultTextContent).text, 'hi');
      });

      test('fromJson throws FormatException for non-string/list content', () {
        final json = {
          'type': 'tool_result',
          'tool_use_id': 'tu_bad',
          'content': 42,
        };

        expect(
          () => ToolResultInputBlock.fromJson(json),
          throwsFormatException,
        );
      });

      test('toolsetName round-trips through fromJson/toJson', () {
        final json = {
          'type': 'tool_result',
          'tool_use_id': 'tu_toolset',
          'toolset_name': 'computer_toolset_20260801',
        };

        final block = ToolResultInputBlock.fromJson(json);

        expect(block.toolsetName, 'computer_toolset_20260801');
        expect(block.toJson(), json);
      });

      test('omits toolset_name when absent', () {
        const block = ToolResultInputBlock(toolUseId: 'tu_no_toolset');
        expect(block.toJson().containsKey('toolset_name'), isFalse);
      });
    });

    group('ToolResultContent variants', () {
      test('image content round-trips transformations', () {
        final json = {
          'type': 'image',
          'source': {'type': 'url', 'url': 'https://example.com/image.png'},
          'transformations': {'oversized_image': 'error'},
        };
        final content =
            ToolResultContent.fromJson(json) as ToolResultImageContent;
        expect(
          content.transformations,
          const ImageTransformations(
            oversizedImage: OversizedImageBehavior.error,
          ),
        );
        expect(content.toJson(), json);
      });

      test('document content wraps DocumentInputBlock', () {
        final json = {
          'type': 'document',
          'source': {
            'type': 'text',
            'media_type': 'text/plain',
            'data': 'hello',
          },
        };
        final content =
            ToolResultContent.fromJson(json) as ToolResultDocumentContent;
        expect(content.document, isA<DocumentInputBlock>());
        expect(content.toJson(), json);

        final built = ToolResultContent.document(content.document);
        expect(built, equals(content));
      });

      test('search_result content wraps SearchResultInputBlock', () {
        final json = {
          'type': 'search_result',
          'content': [
            {'type': 'text', 'text': 'Some fact'},
          ],
          'source': 'kb://astro',
          'title': 'Astronomy',
        };
        final content =
            ToolResultContent.fromJson(json) as ToolResultSearchResultContent;
        expect(content.searchResult, isA<SearchResultInputBlock>());
        expect(content.toJson(), json);
      });

      test('tool_reference content wraps ToolReferenceInputBlock', () {
        final json = {'type': 'tool_reference', 'tool_name': 'get_weather'};
        final content =
            ToolResultContent.fromJson(json) as ToolResultToolReferenceContent;
        expect(content.toolReference.toolName, 'get_weather');
        expect(content.toJson(), json);
      });

      test('browser_state content round-trips tabs and state changes', () {
        final json = {
          'type': 'browser_state',
          'tabs': [
            {
              'tab_id': 'tab_1',
              'title': 'Example',
              'url': 'https://example.com',
              'active': true,
            },
          ],
          'state_changes': [
            {'type': 'tab_opened', 'tab_id': 'tab_2'},
            {
              'type': 'download_started',
              'download_id': 'dl_1',
              'url': 'https://example.com/f.pdf',
            },
            {
              'type': 'download_completed',
              'download_id': 'dl_1',
              'url': 'https://example.com/f.pdf',
              'path': '/tmp/f.pdf',
              'size_bytes': 1024,
            },
            {
              'type': 'download_failed',
              'download_id': 'dl_2',
              'url': 'https://example.com/g.pdf',
              'error': 'network error',
            },
          ],
        };
        final content =
            ToolResultContent.fromJson(json) as ToolResultBrowserStateContent;
        expect(content.tabs, hasLength(1));
        expect(content.tabs.first.active, isTrue);
        expect(content.stateChanges, hasLength(4));
        expect(content.stateChanges![0], isA<BrowserStateChangeTabOpened>());
        expect(
          content.stateChanges![1],
          isA<BrowserStateChangeDownloadStarted>(),
        );
        expect(
          content.stateChanges![2],
          isA<BrowserStateChangeDownloadCompleted>(),
        );
        expect(
          content.stateChanges![3],
          isA<BrowserStateChangeDownloadFailed>(),
        );
        expect(content.toJson(), json);
      });

      test('browser_state active defaults to false when absent', () {
        final entry = BrowserStateTabEntry.fromJson(const {
          'tab_id': 'tab_1',
          'title': '',
          'url': '',
        });
        expect(entry.active, isFalse);
      });

      test(
        'unrecognized state change falls back to UnknownBrowserStateChange',
        () {
          final change = BrowserStateChange.fromJson({'type': 'something_new'});
          expect(change, isA<UnknownBrowserStateChange>());
          expect(change.toJson(), {'type': 'something_new'});
        },
      );

      test(
        'unrecognized content type falls back to UnknownToolResultContent',
        () {
          final json = {'type': 'something_new', 'foo': 'bar'};
          final content = ToolResultContent.fromJson(json);
          expect(content, isA<UnknownToolResultContent>());
          expect((content as UnknownToolResultContent).type, 'something_new');
          expect(content.toJson(), json);
        },
      );
    });

    group('ImageTransformations', () {
      test('copyWith(oversizedImage: null) clears the field', () {
        const original = ImageTransformations(
          oversizedImage: OversizedImageBehavior.error,
        );

        final cleared = original.copyWith(oversizedImage: null);

        expect(cleared.oversizedImage, isNull);
        expect(cleared, const ImageTransformations());
      });

      test('copyWith with no arguments keeps the original value', () {
        const original = ImageTransformations(
          oversizedImage: OversizedImageBehavior.error,
        );

        expect(original.copyWith(), equals(original));
      });

      test('copyWith replaces the value when given', () {
        const original = ImageTransformations(
          oversizedImage: OversizedImageBehavior.downsize,
        );

        final updated = original.copyWith(
          oversizedImage: OversizedImageBehavior.error,
        );

        expect(updated.oversizedImage, OversizedImageBehavior.error);
      });
    });

    group('CompactionInputBlock', () {
      test('round-trips compaction content', () {
        const block = CompactionInputBlock(content: 'Compacted summary');
        final json = block.toJson();

        expect(json['type'], 'compaction');
        expect(json['content'], 'Compacted summary');
        expect(json.containsKey('encrypted_content'), isFalse);

        final parsed = InputContentBlock.fromJson(json);
        expect(parsed, isA<CompactionInputBlock>());
        expect((parsed as CompactionInputBlock).content, 'Compacted summary');
        expect(parsed.encryptedContent, isNull);
      });

      test('round-trips compaction content with encrypted_content', () {
        const block = CompactionInputBlock(
          content: 'Compacted summary',
          encryptedContent: 'enc_payload_abc',
        );
        final json = block.toJson();

        expect(json['encrypted_content'], 'enc_payload_abc');

        final parsed = InputContentBlock.fromJson(json) as CompactionInputBlock;
        expect(parsed.encryptedContent, 'enc_payload_abc');
      });
    });

    group('ToolAdditionInputBlock', () {
      test('round-trips without cacheControl', () {
        const block = ToolAdditionInputBlock(
          tool: ToolChangeToolReference('calculator'),
        );
        final json = block.toJson();

        expect(json['type'], 'tool_addition');
        expect(json['tool'], {'type': 'tool_reference', 'name': 'calculator'});
        expect(json.containsKey('cache_control'), isFalse);

        final parsed = InputContentBlock.fromJson(json);
        expect(parsed, isA<ToolAdditionInputBlock>());
        final addition = parsed as ToolAdditionInputBlock;
        expect(addition.tool, const ToolChangeToolReference('calculator'));
        expect(addition.cacheControl, isNull);
      });

      test('round-trips with cacheControl', () {
        const block = ToolAdditionInputBlock(
          tool: ToolChangeMCPToolsetReference('my-server'),
          cacheControl: CacheControlEphemeral(),
        );
        final json = block.toJson();

        expect(json['cache_control'], {'type': 'ephemeral'});

        final parsed =
            InputContentBlock.fromJson(json) as ToolAdditionInputBlock;
        expect(parsed.tool, const ToolChangeMCPToolsetReference('my-server'));
        expect(parsed.cacheControl, const CacheControlEphemeral());
      });

      test('copyWith replaces fields', () {
        const block = ToolAdditionInputBlock(
          tool: ToolChangeToolReference('calculator'),
        );
        final modified = block.copyWith(
          tool: const ToolChangeToolReference('other'),
          cacheControl: const CacheControlEphemeral(),
        );

        expect(modified.tool, const ToolChangeToolReference('other'));
        expect(modified.cacheControl, const CacheControlEphemeral());
      });

      test('toString includes all fields', () {
        const block = ToolAdditionInputBlock(
          tool: ToolChangeToolReference('calculator'),
        );

        expect(block.toString(), contains('tool:'));
        expect(block.toString(), contains('cacheControl:'));
      });

      test('supports the InputContentBlock.toolAddition factory', () {
        final block = InputContentBlock.toolAddition(
          tool: const ToolChangeToolReference('calculator'),
        );

        expect(block, isA<ToolAdditionInputBlock>());
        expect(block.toJson()['type'], 'tool_addition');
      });
    });

    group('ToolRemovalInputBlock', () {
      test('round-trips without cacheControl', () {
        const block = ToolRemovalInputBlock(
          tool: ToolChangeMCPToolReference(
            serverName: 'my-server',
            name: 'search',
          ),
        );
        final json = block.toJson();

        expect(json['type'], 'tool_removal');
        expect(json['tool'], {
          'type': 'mcp_tool_reference',
          'server_name': 'my-server',
          'name': 'search',
        });
        expect(json.containsKey('cache_control'), isFalse);

        final parsed = InputContentBlock.fromJson(json);
        expect(parsed, isA<ToolRemovalInputBlock>());
        final removal = parsed as ToolRemovalInputBlock;
        expect(
          removal.tool,
          const ToolChangeMCPToolReference(
            serverName: 'my-server',
            name: 'search',
          ),
        );
        expect(removal.cacheControl, isNull);
      });

      test('round-trips with cacheControl', () {
        const block = ToolRemovalInputBlock(
          tool: ToolChangeToolReference('calculator'),
          cacheControl: CacheControlEphemeral(),
        );
        final json = block.toJson();

        expect(json['cache_control'], {'type': 'ephemeral'});

        final parsed =
            InputContentBlock.fromJson(json) as ToolRemovalInputBlock;
        expect(parsed.tool, const ToolChangeToolReference('calculator'));
        expect(parsed.cacheControl, const CacheControlEphemeral());
      });

      test('copyWith replaces fields', () {
        const block = ToolRemovalInputBlock(
          tool: ToolChangeToolReference('calculator'),
        );
        final modified = block.copyWith(
          tool: const ToolChangeMCPToolsetReference('my-server'),
        );

        expect(modified.tool, const ToolChangeMCPToolsetReference('my-server'));
      });

      test('toString includes all fields', () {
        const block = ToolRemovalInputBlock(
          tool: ToolChangeToolReference('calculator'),
        );

        expect(block.toString(), contains('tool:'));
        expect(block.toString(), contains('cacheControl:'));
      });

      test('supports the InputContentBlock.toolRemoval factory', () {
        final block = InputContentBlock.toolRemoval(
          tool: const ToolChangeToolReference('calculator'),
        );

        expect(block, isA<ToolRemovalInputBlock>());
        expect(block.toJson()['type'], 'tool_removal');
      });
    });

    group('ToolChangeReference', () {
      test('round-trips ToolChangeToolReference', () {
        const ref = ToolChangeToolReference('calculator');
        final json = ref.toJson();

        expect(json, {'type': 'tool_reference', 'name': 'calculator'});
        expect(ToolChangeReference.fromJson(json), ref);
      });

      test('round-trips ToolChangeMCPToolReference', () {
        const ref = ToolChangeMCPToolReference(
          serverName: 'my-server',
          name: 'search',
        );
        final json = ref.toJson();

        expect(json, {
          'type': 'mcp_tool_reference',
          'server_name': 'my-server',
          'name': 'search',
        });
        expect(ToolChangeReference.fromJson(json), ref);
      });

      test('round-trips ToolChangeMCPToolsetReference', () {
        const ref = ToolChangeMCPToolsetReference('my-server');
        final json = ref.toJson();

        expect(json, {
          'type': 'mcp_toolset_reference',
          'server_name': 'my-server',
        });
        expect(ToolChangeReference.fromJson(json), ref);
      });

      test('factory constructors build expected variants', () {
        expect(
          ToolChangeReference.tool('calculator'),
          const ToolChangeToolReference('calculator'),
        );
        expect(
          ToolChangeReference.mcpTool(serverName: 'my-server', name: 'search'),
          const ToolChangeMCPToolReference(
            serverName: 'my-server',
            name: 'search',
          ),
        );
        expect(
          ToolChangeReference.mcpToolset('my-server'),
          const ToolChangeMCPToolsetReference('my-server'),
        );
      });

      test('copyWith replaces fields on each variant', () {
        expect(
          const ToolChangeToolReference('calculator').copyWith(name: 'other'),
          const ToolChangeToolReference('other'),
        );
        expect(
          const ToolChangeMCPToolReference(
            serverName: 'my-server',
            name: 'search',
          ).copyWith(name: 'other'),
          const ToolChangeMCPToolReference(
            serverName: 'my-server',
            name: 'other',
          ),
        );
        expect(
          const ToolChangeMCPToolsetReference(
            'my-server',
          ).copyWith(serverName: 'other-server'),
          const ToolChangeMCPToolsetReference('other-server'),
        );
      });

      test('toString includes all fields per variant', () {
        expect(
          const ToolChangeToolReference('calculator').toString(),
          contains('name:'),
        );
        expect(
          const ToolChangeMCPToolReference(
            serverName: 'my-server',
            name: 'search',
          ).toString(),
          allOf(contains('serverName:'), contains('name:')),
        );
        expect(
          const ToolChangeMCPToolsetReference('my-server').toString(),
          contains('serverName:'),
        );
      });

      test('fromJson preserves an unrecognized type verbatim', () {
        final json = {'type': 'bogus', 'name': 'calculator'};
        final ref = ToolChangeReference.fromJson(json);

        expect(ref, isA<UnknownToolChangeReference>());
        expect((ref as UnknownToolChangeReference).rawJson, json);
        expect(ref.toJson(), json);
      });
    });

    group('MCPToolUseInputBlock', () {
      test('fromJson parses all fields', () {
        final json = {
          'type': 'mcp_tool_use',
          'id': 'tu_mcp_1',
          'name': 'read_file',
          'server_name': 'filesystem',
          'input': {'path': '/tmp/test.txt'},
          'cache_control': {'type': 'ephemeral'},
        };

        final block = InputContentBlock.fromJson(json);
        expect(block, isA<MCPToolUseInputBlock>());
        final mcp = block as MCPToolUseInputBlock;
        expect(mcp.id, 'tu_mcp_1');
        expect(mcp.serverName, 'filesystem');
        expect(mcp.cacheControl, isNotNull);
      });

      test('toJson round-trips correctly', () {
        const block = MCPToolUseInputBlock(
          id: 'tu_1',
          name: 'tool',
          serverName: 'server',
          input: {'k': 'v'},
        );

        final json = block.toJson();
        expect(json['type'], 'mcp_tool_use');
        expect(json['server_name'], 'server');
        expect(json.containsKey('cache_control'), false);

        final restored = MCPToolUseInputBlock.fromJson(json);
        expect(restored, equals(block));
      });

      test('factory constructor works', () {
        final block = InputContentBlock.mcpToolUse(
          id: 'tu_1',
          name: 'query',
          serverName: 'db',
          input: const {'sql': 'SELECT 1'},
        );
        expect(block, isA<MCPToolUseInputBlock>());
      });
    });

    group('MCPToolResultInputBlock', () {
      test('fromJson with all optional fields', () {
        final json = {
          'type': 'mcp_tool_result',
          'tool_use_id': 'tu_mcp_1',
          'content': 'result text',
          'is_error': true,
          'cache_control': {'type': 'ephemeral'},
        };

        final block = InputContentBlock.fromJson(json);
        expect(block, isA<MCPToolResultInputBlock>());
        final mcp = block as MCPToolResultInputBlock;
        expect(mcp.toolUseId, 'tu_mcp_1');
        expect(mcp.content, isA<MCPToolResultStringContent>());
        expect(mcp.isError, true);
        expect(mcp.cacheControl, isNotNull);
      });

      test('fromJson with minimal fields', () {
        final json = {'type': 'mcp_tool_result', 'tool_use_id': 'tu_mcp_1'};

        final block = MCPToolResultInputBlock.fromJson(json);
        expect(block.toolUseId, 'tu_mcp_1');
        expect(block.content, isNull);
        expect(block.isError, isNull);
      });

      test('toJson omits null fields', () {
        const block = MCPToolResultInputBlock(toolUseId: 'tu_1');
        final json = block.toJson();

        expect(json['type'], 'mcp_tool_result');
        expect(json['tool_use_id'], 'tu_1');
        expect(json.containsKey('content'), false);
        expect(json.containsKey('is_error'), false);
        expect(json.containsKey('cache_control'), false);
      });

      test('factory constructor works', () {
        final block = InputContentBlock.mcpToolResult(
          toolUseId: 'tu_1',
          content: MCPToolResultContent.text('ok'),
        );
        expect(block, isA<MCPToolResultInputBlock>());
      });
    });

    group('AdvisorToolResultInputBlock', () {
      test('InputContentBlock.fromJson dispatches advisor_tool_result', () {
        final json = {
          'type': 'advisor_tool_result',
          'tool_use_id': 'srvtoolu_abc123',
          'content': {
            'type': 'advisor_result',
            'text': 'Use channels for coordination.',
          },
        };
        final block = InputContentBlock.fromJson(json);

        expect(block, isA<AdvisorToolResultInputBlock>());
        final advisor = block as AdvisorToolResultInputBlock;
        expect(advisor.toolUseId, 'srvtoolu_abc123');
        expect(advisor.content, isA<AdvisorResult>());
      });

      test('toJson/fromJson round-trip with advisor_result', () {
        final original = {
          'type': 'advisor_tool_result',
          'tool_use_id': 'srvtoolu_abc',
          'content': {'type': 'advisor_result', 'text': 'Advice text.'},
        };
        final block =
            InputContentBlock.fromJson(original) as AdvisorToolResultInputBlock;
        expect(block.toJson(), original);
      });

      test('toJson/fromJson round-trip with advisor_redacted_result', () {
        final original = {
          'type': 'advisor_tool_result',
          'tool_use_id': 'srvtoolu_red',
          'content': {
            'type': 'advisor_redacted_result',
            'encrypted_content': 'opaque-blob',
          },
        };
        final block =
            InputContentBlock.fromJson(original) as AdvisorToolResultInputBlock;
        expect(block.toJson(), original);
      });

      test('round-trips unknown advisor content verbatim', () {
        final original = {
          'type': 'advisor_tool_result',
          'tool_use_id': 'srvtoolu_unk',
          'content': {
            'type': 'advisor_future_variant',
            'data': {'nested': true},
          },
        };
        final block =
            InputContentBlock.fromJson(original) as AdvisorToolResultInputBlock;
        expect(block.content, isA<AdvisorToolResultUnknown>());
        expect(block.toJson(), original);
      });

      test('factory constructor', () {
        final block = InputContentBlock.advisorToolResult(
          toolUseId: 'srvtoolu_test',
          content: const AdvisorResult(text: 'advice'),
        );

        expect(block, isA<AdvisorToolResultInputBlock>());
        expect(block.toJson()['type'], 'advisor_tool_result');
        expect(block.toJson()['tool_use_id'], 'srvtoolu_test');
      });

      test('equality', () {
        const a = AdvisorToolResultInputBlock(
          toolUseId: 'id1',
          content: AdvisorResult(text: 'advice'),
        );
        const b = AdvisorToolResultInputBlock(
          toolUseId: 'id1',
          content: AdvisorResult(text: 'advice'),
        );
        const c = AdvisorToolResultInputBlock(
          toolUseId: 'id2',
          content: AdvisorResult(text: 'advice'),
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
        expect(a, isNot(equals(c)));
      });
    });
  });

  group('ImageSource', () {
    test('Base64ImageSource roundtrips through JSON', () {
      const source = Base64ImageSource(
        data: 'abc123',
        mediaType: ImageMediaType.jpeg,
      );

      final json = source.toJson();
      final restored = ImageSource.fromJson(json);

      expect(restored, isA<Base64ImageSource>());
      final b64 = restored as Base64ImageSource;
      expect(b64.data, 'abc123');
      expect(b64.mediaType, ImageMediaType.jpeg);
    });

    test('ImageMediaType.fromMimeType returns correct type', () {
      expect(ImageMediaType.fromMimeType('image/jpeg'), ImageMediaType.jpeg);
      expect(ImageMediaType.fromMimeType('image/png'), ImageMediaType.png);
      expect(ImageMediaType.fromMimeType('image/gif'), ImageMediaType.gif);
      expect(ImageMediaType.fromMimeType('image/webp'), ImageMediaType.webp);
    });

    test('ImageMediaType.fromMimeType throws on unknown type', () {
      expect(
        () => ImageMediaType.fromMimeType('image/bmp'),
        throwsFormatException,
      );
    });

    test('UrlImageSource roundtrips through JSON', () {
      const source = UrlImageSource('https://example.com/img.png');

      final json = source.toJson();
      final restored = ImageSource.fromJson(json);

      expect(restored, isA<UrlImageSource>());
      expect((restored as UrlImageSource).url, 'https://example.com/img.png');
    });
  });

  group('UnknownContentBlock', () {
    test('unknown type parses to UnknownContentBlock', () {
      final json = {
        'type': 'some_future_block',
        'data': 'hello',
        'nested': {'key': 'value'},
      };
      final block = ContentBlock.fromJson(json);

      expect(block, isA<UnknownContentBlock>());
      final unknown = block as UnknownContentBlock;
      expect(unknown.raw['type'], 'some_future_block');
      expect(unknown.raw['data'], 'hello');
    });

    test('round-trips raw JSON', () {
      final json = {
        'type': 'future_tool_result',
        'tool_use_id': 'tu_123',
        'payload': [1, 2, 3],
      };
      final block = ContentBlock.fromJson(json);
      expect(block.toJson(), json);
    });

    test('equality', () {
      final a = UnknownContentBlock(raw: const {'type': 'x', 'v': 1});
      final b = UnknownContentBlock(raw: const {'type': 'x', 'v': 1});
      final c = UnknownContentBlock(raw: const {'type': 'y'});

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('AdvisorToolResultBlock', () {
    test('fromJson parses advisor_result content', () {
      final json = {
        'type': 'advisor_tool_result',
        'tool_use_id': 'srvtoolu_abc123',
        'content': {
          'type': 'advisor_result',
          'text': 'Use a channel-based coordination pattern.',
        },
      };
      final block = ContentBlock.fromJson(json);

      expect(block, isA<AdvisorToolResultBlock>());
      final advisor = block as AdvisorToolResultBlock;
      expect(advisor.toolUseId, 'srvtoolu_abc123');
      expect(advisor.content, isA<AdvisorResult>());
      expect(
        (advisor.content as AdvisorResult).text,
        'Use a channel-based coordination pattern.',
      );
    });

    test('fromJson parses advisor_redacted_result content', () {
      final json = {
        'type': 'advisor_tool_result',
        'tool_use_id': 'srvtoolu_xyz',
        'content': {
          'type': 'advisor_redacted_result',
          'encrypted_content': 'opaque-blob-data',
        },
      };
      final block = ContentBlock.fromJson(json) as AdvisorToolResultBlock;

      expect(block.content, isA<AdvisorRedactedResult>());
      expect(
        (block.content as AdvisorRedactedResult).encryptedContent,
        'opaque-blob-data',
      );
    });

    test('fromJson parses advisor_tool_result_error content', () {
      final json = {
        'type': 'advisor_tool_result',
        'tool_use_id': 'srvtoolu_err',
        'content': {
          'type': 'advisor_tool_result_error',
          'error_code': 'overloaded',
        },
      };
      final block = ContentBlock.fromJson(json) as AdvisorToolResultBlock;

      expect(block.content, isA<AdvisorToolResultError>());
      expect(
        (block.content as AdvisorToolResultError).errorCode,
        AdvisorToolResultErrorCode.overloaded,
      );
    });

    test('fromJson handles unknown content type as fallback', () {
      final json = {
        'type': 'advisor_tool_result',
        'tool_use_id': 'srvtoolu_unknown',
        'content': {'type': 'advisor_future_type', 'data': 'something new'},
      };
      final block = ContentBlock.fromJson(json) as AdvisorToolResultBlock;

      expect(block.content, isA<AdvisorToolResultUnknown>());
      final unknown = block.content as AdvisorToolResultUnknown;
      expect(unknown.raw['type'], 'advisor_future_type');
      expect(unknown.raw['data'], 'something new');
    });

    test('toJson round-trip for advisor_result', () {
      final original = {
        'type': 'advisor_tool_result',
        'tool_use_id': 'srvtoolu_abc123',
        'content': {'type': 'advisor_result', 'text': 'Use channels.'},
      };
      final block = ContentBlock.fromJson(original) as AdvisorToolResultBlock;
      expect(block.toJson(), original);
    });

    test('toJson round-trip for advisor_redacted_result', () {
      final original = {
        'type': 'advisor_tool_result',
        'tool_use_id': 'srvtoolu_red',
        'content': {
          'type': 'advisor_redacted_result',
          'encrypted_content': 'encrypted-blob',
        },
      };
      final block = ContentBlock.fromJson(original) as AdvisorToolResultBlock;
      expect(block.toJson(), original);
    });

    test('toJson round-trip for advisor_tool_result_error', () {
      final original = {
        'type': 'advisor_tool_result',
        'tool_use_id': 'srvtoolu_err',
        'content': {
          'type': 'advisor_tool_result_error',
          'error_code': 'max_uses_exceeded',
        },
      };
      final block = ContentBlock.fromJson(original) as AdvisorToolResultBlock;
      expect(block.toJson(), original);
    });

    test('toJson round-trip for unknown content type', () {
      final original = {
        'type': 'advisor_tool_result',
        'tool_use_id': 'srvtoolu_unk',
        'content': {
          'type': 'advisor_new_variant',
          'payload': [1, 2, 3],
        },
      };
      final block = ContentBlock.fromJson(original) as AdvisorToolResultBlock;
      expect(block.toJson(), original);
    });

    test('equality', () {
      const a = AdvisorToolResultBlock(
        toolUseId: 'id1',
        content: AdvisorResult(text: 'advice'),
      );
      const b = AdvisorToolResultBlock(
        toolUseId: 'id1',
        content: AdvisorResult(text: 'advice'),
      );
      const c = AdvisorToolResultBlock(
        toolUseId: 'id1',
        content: AdvisorResult(text: 'different'),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('copyWith', () {
      const original = AdvisorToolResultBlock(
        toolUseId: 'id1',
        content: AdvisorResult(text: 'advice'),
      );
      final modified = original.copyWith(toolUseId: 'id2');
      expect(modified.toolUseId, 'id2');
      expect(modified.content, isA<AdvisorResult>());
    });
  });

  group('AdvisorResult.stopReason', () {
    test('round-trips when present', () {
      final json = {
        'type': 'advisor_result',
        'text': 'advice',
        'stop_reason': 'max_tokens',
      };
      final result = AdvisorResult.fromJson(json);
      expect(result.stopReason, 'max_tokens');
      expect(result.toJson(), json);
    });

    test('omits stop_reason when absent', () {
      const result = AdvisorResult(text: 'advice');
      expect(result.toJson().containsKey('stop_reason'), isFalse);
    });

    test('copyWith updates and clears stopReason', () {
      const result = AdvisorResult(text: 'advice', stopReason: 'end_turn');
      expect(
        result.copyWith(stopReason: 'max_tokens').stopReason,
        'max_tokens',
      );
      expect(result.copyWith(stopReason: null).stopReason, isNull);
    });

    test('equality and toString include stopReason', () {
      const a = AdvisorResult(text: 'advice', stopReason: 'end_turn');
      const b = AdvisorResult(text: 'advice');
      expect(a, isNot(equals(b)));
      expect(a.toString(), contains('stopReason: end_turn'));
    });
  });

  group('AdvisorRedactedResult.stopReason', () {
    test('round-trips when present', () {
      final json = {
        'type': 'advisor_redacted_result',
        'encrypted_content': 'opaque-blob',
        'stop_reason': 'max_tokens',
      };
      final result = AdvisorRedactedResult.fromJson(json);
      expect(result.stopReason, 'max_tokens');
      expect(result.toJson(), json);
    });

    test('toString redacts encryptedContent and shows stopReason', () {
      const result = AdvisorRedactedResult(
        encryptedContent: 'opaque-blob',
        stopReason: 'end_turn',
      );
      final s = result.toString();
      expect(s, isNot(contains('opaque-blob')));
      expect(s, contains('chars]'));
      expect(s, contains('stopReason: end_turn'));
    });

    test('copyWith clears stopReason', () {
      const result = AdvisorRedactedResult(
        encryptedContent: 'blob',
        stopReason: 'end_turn',
      );
      expect(result.copyWith(stopReason: null).stopReason, isNull);
    });
  });

  group('AdvisorToolResultErrorCode', () {
    test('all known error codes round-trip', () {
      const codes = {
        'execution_time_exceeded':
            AdvisorToolResultErrorCode.executionTimeExceeded,
        'max_uses_exceeded': AdvisorToolResultErrorCode.maxUsesExceeded,
        'overloaded': AdvisorToolResultErrorCode.overloaded,
        'prompt_too_long': AdvisorToolResultErrorCode.promptTooLong,
        'too_many_requests': AdvisorToolResultErrorCode.tooManyRequests,
        'unavailable': AdvisorToolResultErrorCode.unavailable,
      };

      for (final entry in codes.entries) {
        final parsed = AdvisorToolResultErrorCode.fromJson(entry.key);
        expect(parsed, entry.value, reason: 'Parsing ${entry.key}');
        expect(parsed.toJson(), entry.key, reason: 'Serializing ${entry.key}');
      }
    });

    test('unrecognized error code returns unknown fallback', () {
      final code = AdvisorToolResultErrorCode.fromJson(
        'some_future_error_code',
      );
      expect(code, AdvisorToolResultErrorCode.unknown);
    });
  });

  group('AdvisorToolResultContent variants', () {
    test('AdvisorResult validates type discriminator', () {
      expect(
        () => AdvisorResult.fromJson(const {
          'type': 'wrong_type',
          'text': 'hello',
        }),
        throwsFormatException,
      );
    });

    test('AdvisorRedactedResult validates type discriminator', () {
      expect(
        () => AdvisorRedactedResult.fromJson(const {
          'type': 'wrong_type',
          'encrypted_content': 'data',
        }),
        throwsFormatException,
      );
    });

    test('AdvisorToolResultError validates type discriminator', () {
      expect(
        () => AdvisorToolResultError.fromJson(const {
          'type': 'wrong_type',
          'error_code': 'overloaded',
        }),
        throwsFormatException,
      );
    });

    test('AdvisorRedactedResult equality', () {
      const a = AdvisorRedactedResult(encryptedContent: 'data');
      const b = AdvisorRedactedResult(encryptedContent: 'data');
      const c = AdvisorRedactedResult(encryptedContent: 'other');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('AdvisorToolResultError equality', () {
      const a = AdvisorToolResultError(rawErrorCode: 'overloaded');
      const b = AdvisorToolResultError(rawErrorCode: 'overloaded');
      const c = AdvisorToolResultError(rawErrorCode: 'unavailable');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('AdvisorToolResultError.errorCode derived from rawErrorCode', () {
      const known = AdvisorToolResultError(rawErrorCode: 'overloaded');
      expect(known.errorCode, AdvisorToolResultErrorCode.overloaded);

      const unknown = AdvisorToolResultError(rawErrorCode: 'some_future_code');
      expect(unknown.errorCode, AdvisorToolResultErrorCode.unknown);
    });

    test('AdvisorToolResultError round-trips unknown error code', () {
      final json = {
        'type': 'advisor_tool_result',
        'tool_use_id': 'srvtoolu_future',
        'content': {
          'type': 'advisor_tool_result_error',
          'error_code': 'some_future_error_code',
        },
      };
      final block = ContentBlock.fromJson(json) as AdvisorToolResultBlock;
      final error = block.content as AdvisorToolResultError;

      expect(error.errorCode, AdvisorToolResultErrorCode.unknown);
      expect(error.rawErrorCode, 'some_future_error_code');

      // Round-trip must preserve the original error code string
      expect(block.toJson(), json);
    });

    test('AdvisorToolResultUnknown equality', () {
      final a = AdvisorToolResultUnknown(raw: const {'type': 'x', 'data': 1});
      final b = AdvisorToolResultUnknown(raw: const {'type': 'x', 'data': 1});
      final c = AdvisorToolResultUnknown(raw: const {'type': 'y'});

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    group('AdvisorResult copyWith', () {
      test('creates modified copy', () {
        const original = AdvisorResult(text: 'original advice');
        final modified = original.copyWith(text: 'new advice');

        expect(modified.text, 'new advice');
        expect(original.text, 'original advice');
      });

      test('returns equal copy when no args', () {
        const original = AdvisorResult(text: 'advice');
        final copy = original.copyWith();

        expect(copy, equals(original));
        expect(copy.hashCode, equals(original.hashCode));
      });
    });

    group('AdvisorRedactedResult copyWith', () {
      test('creates modified copy', () {
        const original = AdvisorRedactedResult(encryptedContent: 'enc1');
        final modified = original.copyWith(encryptedContent: 'enc2');

        expect(modified.encryptedContent, 'enc2');
        expect(original.encryptedContent, 'enc1');
      });

      test('returns equal copy when no args', () {
        const original = AdvisorRedactedResult(encryptedContent: 'enc');
        final copy = original.copyWith();

        expect(copy, equals(original));
        expect(copy.hashCode, equals(original.hashCode));
      });
    });
  });

  group('Citation', () {
    final byType = <String, Map<String, dynamic>>{
      'char_location': {
        'type': 'char_location',
        'cited_text': 'a',
        'document_index': 0,
        'start_char_index': 0,
        'end_char_index': 1,
      },
      'page_location': {
        'type': 'page_location',
        'cited_text': 'a',
        'document_index': 0,
        'start_page_number': 1,
        'end_page_number': 2,
      },
      'content_block_location': {
        'type': 'content_block_location',
        'cited_text': 'a',
        'document_index': 0,
        'start_block_index': 0,
        'end_block_index': 1,
      },
      'web_search_result_location': {
        'type': 'web_search_result_location',
        'cited_text': 'a',
        'encrypted_index': 'enc',
      },
      'search_result_location': {
        'type': 'search_result_location',
        'cited_text': 'a',
        'search_result_index': 0,
        'source': 'src',
        'start_block_index': 0,
        'end_block_index': 1,
      },
    };

    final expectedType = <String, Matcher>{
      'char_location': isA<CharLocationCitation>(),
      'page_location': isA<PageLocationCitation>(),
      'content_block_location': isA<ContentBlockLocationCitation>(),
      'web_search_result_location': isA<WebSearchResultLocationCitation>(),
      'search_result_location': isA<SearchResultLocationCitation>(),
    };

    byType.forEach((type, json) {
      test('$type dispatches and round-trips', () {
        final c = Citation.fromJson(json);
        expect(c, expectedType[type]);
        expect(c.toJson(), json);
      });
    });

    test('search_result_location parses all fields incl. title', () {
      final json = {
        'type': 'search_result_location',
        'cited_text': 'the cited span',
        'search_result_index': 2,
        'source': 'kb://doc-42',
        'title': 'Result title',
        'start_block_index': 1,
        'end_block_index': 3,
      };
      final c = Citation.fromJson(json) as SearchResultLocationCitation;
      expect(c.citedText, 'the cited span');
      expect(c.searchResultIndex, 2);
      expect(c.source, 'kb://doc-42');
      expect(c.title, 'Result title');
      expect(c.startBlockIndex, 1);
      expect(c.endBlockIndex, 3);
      expect(c.toJson(), json);
    });

    test('search_result_location omits title when null', () {
      const c = SearchResultLocationCitation(
        citedText: 'x',
        searchResultIndex: 0,
        source: 's',
        startBlockIndex: 0,
        endBlockIndex: 1,
      );
      expect(c.toJson().containsKey('title'), isFalse);
    });

    test('copyWith clears title with explicit null and preserves on omit', () {
      const c = SearchResultLocationCitation(
        citedText: 'x',
        searchResultIndex: 0,
        source: 's',
        title: 'T',
        startBlockIndex: 0,
        endBlockIndex: 1,
      );
      expect(c.copyWith(title: null).title, isNull);
      expect(c.copyWith(source: 'y').title, 'T');
    });

    test('search_result_location toString includes fields (cited text '
        'redacted)', () {
      const c = SearchResultLocationCitation(
        citedText: 'hello world',
        searchResultIndex: 2,
        source: 'kb://doc-42',
        title: 'T',
        startBlockIndex: 1,
        endBlockIndex: 3,
      );
      final s = c.toString();
      expect(s, contains('SearchResultLocationCitation'));
      expect(s, contains('citedText: [11 chars]'));
      expect(s, contains('searchResultIndex: 2'));
      expect(s, contains('source: kb://doc-42'));
      expect(s, contains('title: T'));
      expect(s, contains('startBlockIndex: 1'));
      expect(s, contains('endBlockIndex: 3'));
    });

    test('unknown type falls back to UnknownCitation (never throws)', () {
      final json = {'type': 'future_location', 'foo': 'bar'};
      final c = Citation.fromJson(json);
      expect(c, isA<UnknownCitation>());
      expect(c.toJson(), json);
    });

    test('missing type falls back to UnknownCitation', () {
      final json = {'foo': 'bar'};
      final c = Citation.fromJson(json);
      expect(c, isA<UnknownCitation>());
      expect(c.toJson(), json);
    });

    test('UnknownCitation uses deep equality', () {
      final a = Citation.fromJson({
        'type': 'x',
        'n': {'k': 1},
      });
      final b = Citation.fromJson({
        'type': 'x',
        'n': {'k': 1},
      });
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('InputCitation', () {
    // Request citations always emit the required-but-nullable title /
    // document_title keys, so the sample JSON includes them (as null).
    final byType = <String, Map<String, dynamic>>{
      'char_location': {
        'type': 'char_location',
        'cited_text': 'a',
        'document_index': 0,
        'document_title': null,
        'start_char_index': 0,
        'end_char_index': 1,
      },
      'page_location': {
        'type': 'page_location',
        'cited_text': 'a',
        'document_index': 0,
        'document_title': null,
        'start_page_number': 1,
        'end_page_number': 2,
      },
      'content_block_location': {
        'type': 'content_block_location',
        'cited_text': 'a',
        'document_index': 0,
        'document_title': null,
        'start_block_index': 0,
        'end_block_index': 1,
      },
      'web_search_result_location': {
        'type': 'web_search_result_location',
        'cited_text': 'a',
        'encrypted_index': 'enc',
        'title': null,
        'url': 'https://example.com',
      },
      'search_result_location': {
        'type': 'search_result_location',
        'cited_text': 'a',
        'search_result_index': 0,
        'source': 'src',
        'title': null,
        'start_block_index': 0,
        'end_block_index': 1,
      },
    };

    final expectedType = <String, Matcher>{
      'char_location': isA<CharLocationInputCitation>(),
      'page_location': isA<PageLocationInputCitation>(),
      'content_block_location': isA<ContentBlockLocationInputCitation>(),
      'web_search_result_location': isA<WebSearchResultLocationInputCitation>(),
      'search_result_location': isA<SearchResultLocationInputCitation>(),
    };

    byType.forEach((type, json) {
      test('$type dispatches and round-trips', () {
        final c = InputCitation.fromJson(json);
        expect(c, expectedType[type]);
        expect(c.toJson(), json);
      });
    });

    test('search_result_location parses all fields incl. title', () {
      final json = {
        'type': 'search_result_location',
        'cited_text': 'the cited span',
        'search_result_index': 2,
        'source': 'kb://doc-42',
        'title': 'Result title',
        'start_block_index': 1,
        'end_block_index': 3,
      };
      final c =
          InputCitation.fromJson(json) as SearchResultLocationInputCitation;
      expect(c.citedText, 'the cited span');
      expect(c.searchResultIndex, 2);
      expect(c.source, 'kb://doc-42');
      expect(c.title, 'Result title');
      expect(c.startBlockIndex, 1);
      expect(c.endBlockIndex, 3);
      expect(c.toJson(), json);
    });

    test('always emits required-nullable title key (even when null)', () {
      const c = SearchResultLocationInputCitation(
        citedText: 'x',
        searchResultIndex: 0,
        source: 's',
        title: null,
        startBlockIndex: 0,
        endBlockIndex: 1,
      );
      final json = c.toJson();
      expect(json.containsKey('title'), isTrue);
      expect(json['title'], isNull);
    });

    test('always emits required-nullable document_title key (even when '
        'null)', () {
      const c = CharLocationInputCitation(
        citedText: 'a',
        documentIndex: 0,
        documentTitle: null,
        startCharIndex: 0,
        endCharIndex: 1,
      );
      final json = c.toJson();
      expect(json.containsKey('document_title'), isTrue);
      expect(json['document_title'], isNull);
    });

    test('copyWith clears title with explicit null and preserves on omit', () {
      const c = SearchResultLocationInputCitation(
        citedText: 'x',
        searchResultIndex: 0,
        source: 's',
        title: 'T',
        startBlockIndex: 0,
        endBlockIndex: 1,
      );
      expect(c.copyWith(title: null).title, isNull);
      expect(c.copyWith(source: 'y').title, 'T');
    });

    test('web_search_result_location round-trips and redacts in toString', () {
      const c = WebSearchResultLocationInputCitation(
        citedText: 'hello world',
        encryptedIndex: 'secret-index',
        title: 'T',
        url: 'https://example.com',
      );
      final s = c.toString();
      expect(s, contains('WebSearchResultLocationInputCitation'));
      expect(s, contains('citedText: [11 chars]'));
      expect(s, contains('encryptedIndex: [12 chars]'));
      expect(s, contains('url: https://example.com'));
    });

    test('search_result_location toString includes fields (cited text '
        'redacted)', () {
      const c = SearchResultLocationInputCitation(
        citedText: 'hello world',
        searchResultIndex: 2,
        source: 'kb://doc-42',
        title: 'T',
        startBlockIndex: 1,
        endBlockIndex: 3,
      );
      final s = c.toString();
      expect(s, contains('SearchResultLocationInputCitation'));
      expect(s, contains('citedText: [11 chars]'));
      expect(s, contains('searchResultIndex: 2'));
      expect(s, contains('source: kb://doc-42'));
      expect(s, contains('title: T'));
    });

    test('unknown type falls back to UnknownInputCitation (never throws)', () {
      final json = {'type': 'future_location', 'foo': 'bar'};
      final c = InputCitation.fromJson(json);
      expect(c, isA<UnknownInputCitation>());
      expect(c.toJson(), json);
    });

    test('missing type falls back to UnknownInputCitation', () {
      final json = {'foo': 'bar'};
      final c = InputCitation.fromJson(json);
      expect(c, isA<UnknownInputCitation>());
      expect(c.toJson(), json);
    });

    test('UnknownInputCitation uses deep equality', () {
      final a = InputCitation.fromJson({
        'type': 'x',
        'n': {'k': 1},
      });
      final b = InputCitation.fromJson({
        'type': 'x',
        'n': {'k': 1},
      });
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
