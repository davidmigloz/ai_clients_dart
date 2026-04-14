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
        expect(error.errorCode, 'max_results_reached');
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
        expect(
          (block2.content as WebSearchResultError).errorCode,
          'search_unavailable',
        );
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
    });

    group('CompactionInputBlock', () {
      test('round-trips compaction content', () {
        const block = CompactionInputBlock(content: 'Compacted summary');
        final json = block.toJson();

        expect(json['type'], 'compaction');
        expect(json['content'], 'Compacted summary');

        final parsed = InputContentBlock.fromJson(json);
        expect(parsed, isA<CompactionInputBlock>());
        expect((parsed as CompactionInputBlock).content, 'Compacted summary');
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
  });
}
