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
      test('fromJson parses web search result block', () {
        final json = {
          'type': 'web_search_tool_result',
          'tool_use_id': 'tu_ws_123',
          'content': {
            'type': 'web_search_result',
            'results': [
              {
                'url': 'https://example.com',
                'title': 'Example',
                'encrypted_content_index': 'encrypted...',
                'page_age': '1 day ago',
              },
            ],
          },
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

    test('UrlImageSource roundtrips through JSON', () {
      const source = UrlImageSource('https://example.com/img.png');

      final json = source.toJson();
      final restored = ImageSource.fromJson(json);

      expect(restored, isA<UrlImageSource>());
      expect((restored as UrlImageSource).url, 'https://example.com/img.png');
    });
  });
}
