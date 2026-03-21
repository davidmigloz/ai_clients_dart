import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

/// Tests that our [CreateResponseRequest.toJson] produces JSON structures
/// compatible with the official OpenResponses CLI compliance test runner.
///
/// Each test constructs the Dart equivalent of a CLI test template's
/// `getRequest()` output and validates the serialized JSON is spec-compliant.
///
/// Note: The CLI sends `content` as a plain string for text-only messages,
/// while our library always uses the typed array format
/// (`[{"type": "input_text", "text": "..."}]`). Both are valid per the
/// OpenAPI spec. The typed array format is more explicit and required for
/// multi-part content (e.g., images).
///
/// Reference: https://github.com/openresponses/openresponses/blob/main/src/lib/compliance-tests.ts
void main() {
  group('Request shape compatibility with CLI compliance tests', () {
    // CLI test: basic-response
    test('basic-response: simple user message', () {
      final request = CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseItemsInput([
          MessageItem.userText('Say hello in exactly 3 words.'),
        ]),
      );

      final json = request.toJson();

      expect(json['model'], 'gpt-4o-mini');
      expect(json['input'], isList);
      final input = json['input'] as List;
      expect(input, hasLength(1));

      final message = input[0] as Map<String, dynamic>;
      expect(message['type'], 'message');
      expect(message['role'], 'user');

      // Our library serializes text content as typed array format
      final content = message['content'] as List;
      expect(content, hasLength(1));
      expect(content[0], {
        'type': 'input_text',
        'text': 'Say hello in exactly 3 words.',
      });
    });

    // CLI test: streaming-response
    test('streaming-response: user message for streaming', () {
      final request = CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseItemsInput([MessageItem.userText('Count from 1 to 5.')]),
      );

      final json = request.toJson();

      expect(json['model'], 'gpt-4o-mini');
      final input = json['input'] as List;
      expect(input, hasLength(1));

      final message = input[0] as Map<String, dynamic>;
      expect(message['type'], 'message');
      expect(message['role'], 'user');

      final content = message['content'] as List;
      expect(content, hasLength(1));
      expect(content[0], {'type': 'input_text', 'text': 'Count from 1 to 5.'});

      // Note: the CLI adds `stream: true` at the HTTP level,
      // not in the request body. Our client handles this similarly
      // via createStream() vs create().
    });

    // CLI test: system-prompt
    test('system-prompt: system role message in input', () {
      final request = CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseItemsInput([
          MessageItem.systemText(
            'You are a pirate. Always respond in pirate speak.',
          ),
          MessageItem.userText('Say hello.'),
        ]),
      );

      final json = request.toJson();

      expect(json['model'], 'gpt-4o-mini');
      final input = json['input'] as List;
      expect(input, hasLength(2));

      final systemMsg = input[0] as Map<String, dynamic>;
      expect(systemMsg['type'], 'message');
      expect(systemMsg['role'], 'system');
      final systemContent = systemMsg['content'] as List;
      expect(systemContent, hasLength(1));
      expect(systemContent[0], {
        'type': 'input_text',
        'text': 'You are a pirate. Always respond in pirate speak.',
      });

      final userMsg = input[1] as Map<String, dynamic>;
      expect(userMsg['type'], 'message');
      expect(userMsg['role'], 'user');
      final userContent = userMsg['content'] as List;
      expect(userContent, hasLength(1));
      expect(userContent[0], {'type': 'input_text', 'text': 'Say hello.'});
    });

    // CLI test: tool-calling
    test('tool-calling: function tool definition', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseItemsInput([
          UserMessageItem(
            content: UserMessageTextContent(
              "What's the weather like in San Francisco?",
            ),
          ),
        ]),
        tools: [
          FunctionTool(
            name: 'get_weather',
            description: 'Get the current weather for a location',
            parameters: {
              'type': 'object',
              'properties': {
                'location': {
                  'type': 'string',
                  'description': 'The city and state, e.g. San Francisco, CA',
                },
              },
              'required': <String>['location'],
            },
          ),
        ],
      );

      final json = request.toJson();

      expect(json['model'], 'gpt-4o-mini');

      // Validate input
      final input = json['input'] as List;
      expect(input, hasLength(1));
      final message = input[0] as Map<String, dynamic>;
      expect(message['type'], 'message');
      expect(message['role'], 'user');

      // Validate tools
      final tools = json['tools'] as List;
      expect(tools, hasLength(1));
      final tool = tools[0] as Map<String, dynamic>;
      expect(tool['type'], 'function');
      expect(tool['name'], 'get_weather');
      expect(tool['description'], 'Get the current weather for a location');

      final params = tool['parameters'] as Map<String, dynamic>;
      expect(params['type'], 'object');
      expect(
        params['properties'],
        containsPair('location', isA<Map<String, dynamic>>()),
      );
      expect(params['required'], contains('location'));
    });

    // CLI test: image-input
    test('image-input: image URL in user content', () {
      final request = CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseItemsInput([
          MessageItem.user([
            InputContent.text(
              'What do you see in this image? Answer in one sentence.',
            ),
            InputContent.imageUrl(
              'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2j',
            ),
          ]),
        ]),
      );

      final json = request.toJson();

      expect(json['model'], 'gpt-4o-mini');
      final input = json['input'] as List;
      expect(input, hasLength(1));

      final message = input[0] as Map<String, dynamic>;
      expect(message['type'], 'message');
      expect(message['role'], 'user');

      // Image content always uses array format (both CLI and our library)
      final content = message['content'] as List;
      expect(content, hasLength(2));

      final textPart = content[0] as Map<String, dynamic>;
      expect(textPart['type'], 'input_text');
      expect(
        textPart['text'],
        'What do you see in this image? Answer in one sentence.',
      );

      final imagePart = content[1] as Map<String, dynamic>;
      expect(imagePart['type'], 'input_image');
      expect(
        imagePart['image_url'],
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2j',
      );
    });

    // CLI test: multi-turn
    test('multi-turn: conversation history with user and assistant', () {
      final request = CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseItemsInput([
          MessageItem.userText('My name is Alice.'),
          MessageItem.assistantText(
            'Hello Alice! Nice to meet you. How can I help you today?',
          ),
          MessageItem.userText('What is my name?'),
        ]),
      );

      final json = request.toJson();

      expect(json['model'], 'gpt-4o-mini');
      final input = json['input'] as List;
      expect(input, hasLength(3));

      final msg1 = input[0] as Map<String, dynamic>;
      expect(msg1['type'], 'message');
      expect(msg1['role'], 'user');
      final content1 = msg1['content'] as List;
      expect(content1[0], {'type': 'input_text', 'text': 'My name is Alice.'});

      final msg2 = input[1] as Map<String, dynamic>;
      expect(msg2['type'], 'message');
      expect(msg2['role'], 'assistant');
      final content2 = msg2['content'] as List;
      expect(content2[0], {
        'type': 'output_text',
        'text': 'Hello Alice! Nice to meet you. How can I help you today?',
      });

      final msg3 = input[2] as Map<String, dynamic>;
      expect(msg3['type'], 'message');
      expect(msg3['role'], 'user');
      final content3 = msg3['content'] as List;
      expect(content3[0], {'type': 'input_text', 'text': 'What is my name?'});
    });
  });
}
