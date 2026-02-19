import 'dart:convert';

import 'package:openai_dart/src/models/responses/responses.dart';
import 'package:test/test.dart';

void main() {
  group('ResponseInput', () {
    test('creates text input', () {
      const input = ResponseInput.text('Hello!');

      expect(input, isA<ResponseInputText>());
      expect((input as ResponseInputText).text, equals('Hello!'));
      expect(input.toJson(), equals('Hello!'));
    });

    test('creates items input', () {
      final input = ResponseInput.items([MessageItem.userText('What is 2+2?')]);

      expect(input, isA<ResponseInputItems>());
      expect((input as ResponseInputItems).items.length, equals(1));
      expect(input.toJson(), isList);
    });

    test('const text input works', () {
      const input = ResponseInputText('hello');

      expect(input.text, equals('hello'));
    });

    test('fromJson parses string', () {
      final input = ResponseInput.fromJson('Hello!');

      expect(input, isA<ResponseInputText>());
      expect((input as ResponseInputText).text, equals('Hello!'));
    });

    test('fromJson parses list', () {
      final input = ResponseInput.fromJson(const [
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': 'Hello!'},
          ],
        },
      ]);

      expect(input, isA<ResponseInputItems>());
      expect((input as ResponseInputItems).items.length, equals(1));
    });

    test('fromJson throws on invalid input', () {
      expect(() => ResponseInput.fromJson(42), throwsFormatException);
    });

    test('fromJson throws on invalid list element', () {
      expect(
        () => ResponseInput.fromJson(const ['not a map']),
        throwsFormatException,
      );
    });

    test('equality for text input', () {
      const a = ResponseInputText('hello');
      const b = ResponseInputText('hello');
      const c = ResponseInputText('world');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('equality for items input', () {
      final a = ResponseInputItems([MessageItem.userText('Hello!')]);
      final b = ResponseInputItems([MessageItem.userText('Hello!')]);
      final c = ResponseInputItems([MessageItem.userText('Bye!')]);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('switch exhaustiveness works', () {
      const ResponseInput input = ResponseInputText('hello');

      final result = switch (input) {
        ResponseInputText(:final text) => 'text: $text',
        ResponseInputItems(:final items) => 'items: ${items.length}',
      };

      expect(result, equals('text: hello'));
    });
  });

  group('CreateResponseRequest', () {
    test('creates with text input', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseInput.text('Hello, world!'),
      );

      expect(request.model, equals('gpt-4o'));
      final json = request.toJson();
      expect(json['input'], equals('Hello, world!'));
    });

    test('creates with item input', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseInput.items([
          MessageItem(
            role: MessageRole.user,
            content: [InputContent.text('Hello!')],
          ),
        ]),
      );

      expect(request.model, equals('gpt-4o'));
      final json = request.toJson();
      expect(json['input'], isList);
    });

    test('serializes to JSON', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseInput.text('Hello!'),
        temperature: 0.7,
        maxOutputTokens: 100,
      );

      final json = request.toJson();

      expect(json['model'], equals('gpt-4o'));
      expect(json['input'], equals('Hello!'));
      expect(json['temperature'], equals(0.7));
      expect(json['max_output_tokens'], equals(100));
    });

    test('deserializes from JSON', () {
      final json = {
        'model': 'gpt-4o',
        'input': 'Hello!',
        'temperature': 0.5,
        'top_p': 0.9,
      };

      final request = CreateResponseRequest.fromJson(json);

      expect(request.model, equals('gpt-4o'));
      expect(request.input, isA<ResponseInputText>());
      expect(request.temperature, equals(0.5));
      expect(request.topP, equals(0.9));
    });

    test('text factory creates ResponseInputText', () {
      final request = CreateResponseRequest.text(
        model: 'gpt-4o',
        text: 'Hello!',
      );

      expect(request.input, isA<ResponseInputText>());
      expect((request.input as ResponseInputText).text, equals('Hello!'));
    });

    test('JSON round-trip with text input produces identical JSON', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseInput.text('Hello!'),
      );

      final json = request.toJson();
      final restored = CreateResponseRequest.fromJson(json);
      final json2 = restored.toJson();

      expect(json2, equals(json));
    });

    test('JSON round-trip with items input produces identical JSON', () {
      final request = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseInput.items([
          MessageItem.userText('Question?'),
          MessageItem.assistantText('Answer.'),
        ]),
      );

      final json = request.toJson();
      final restored = CreateResponseRequest.fromJson(json);
      final json2 = restored.toJson();

      // Compare JSON strings to ensure exact match
      expect(jsonEncode(json2), equals(jsonEncode(json)));
    });

    test('metadata accepts Map<String, dynamic>', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseInput.text('Hello!'),
        metadata: {'key': 'value', 'count': 42, 'flag': true},
      );

      final json = request.toJson();
      final metadata = json['metadata'] as Map<String, dynamic>;

      // All values are stringified in JSON output
      expect(metadata['key'], equals('value'));
      expect(metadata['count'], equals('42'));
      expect(metadata['flag'], equals('true'));
    });

    test('metadata omitted when all values are null', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseInput.text('Hello!'),
        metadata: {'key1': null, 'key2': null},
      );
      final json = request.toJson();
      expect(json.containsKey('metadata'), isFalse);
    });

    test('metadata omits null values', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseInput.text('Hello!'),
        metadata: {'key': 'value', 'empty': null},
      );
      final json = request.toJson();
      final metadata = json['metadata'] as Map<String, dynamic>;
      expect(metadata, equals({'key': 'value'}));
      expect(metadata.containsKey('empty'), isFalse);
    });

    test('metadata round-trip preserves string values', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseInput.text('Hello!'),
        metadata: {'key': 'value'},
      );

      final json = request.toJson();
      final restored = CreateResponseRequest.fromJson(json);

      expect(restored.metadata, equals({'key': 'value'}));
    });

    test('copyWith can reset nullable fields to null', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseInput.text('Hello!'),
        instructions: 'Be helpful',
        temperature: 0.7,
        metadata: {'key': 'value'},
      );

      final cleared = request.copyWith(
        instructions: null,
        temperature: null,
        metadata: null,
      );

      expect(cleared.model, equals('gpt-4o'));
      expect(cleared.instructions, isNull);
      expect(cleared.temperature, isNull);
      expect(cleared.metadata, isNull);
    });
  });

  group('Response', () {
    test('deserializes from JSON', () {
      final json = {
        'id': 'resp_123',
        'object': 'response',
        'created_at': 1234567890,
        'model': 'gpt-4o',
        'status': 'completed',
        'output': [
          {
            'type': 'message',
            'id': 'msg_123',
            'role': 'assistant',
            'status': 'completed',
            'content': [
              {'type': 'output_text', 'text': 'Hello!'},
            ],
          },
        ],
        'usage': {'input_tokens': 10, 'output_tokens': 5, 'total_tokens': 15},
      };

      final response = Response.fromJson(json);

      expect(response.id, equals('resp_123'));
      expect(response.object, equals('response'));
      expect(response.createdAt, equals(1234567890));
      expect(response.model, equals('gpt-4o'));
      expect(response.status, equals(ResponseStatus.completed));
      expect(response.output.length, equals(1));
      expect(response.outputText, equals('Hello!'));
    });

    test('serializes to JSON', () {
      const response = Response(
        id: 'resp_123',
        object: 'response',
        createdAt: 1234567890,
        model: 'gpt-4o',
        status: ResponseStatus.completed,
        output: [
          MessageOutputItem(
            id: 'msg_123',
            role: MessageRole.assistant,
            status: ItemStatus.completed,
            content: [OutputContent.text(text: 'Hello!')],
          ),
        ],
        usage: ResponseUsage(inputTokens: 10, outputTokens: 5, totalTokens: 15),
      );

      final json = response.toJson();

      expect(json['id'], equals('resp_123'));
      expect(json['model'], equals('gpt-4o'));
      expect(json['status'], equals('completed'));
    });
  });

  group('ResponseTool', () {
    test('creates function tool', () {
      final tool = ResponseTool.function(
        name: 'get_weather',
        description: 'Get weather',
        parameters: {'type': 'object'},
      );

      expect(tool, isA<FunctionTool>());
      expect(tool.name, equals('get_weather'));
    });

    test('creates web search tool', () {
      final tool = ResponseTool.webSearch();

      expect(tool, isA<WebSearchTool>());
    });

    test('creates file search tool', () {
      final tool = ResponseTool.fileSearch(vectorStoreIds: ['vs_123']);

      expect(tool, isA<FileSearchTool>());
      expect(tool.vectorStoreIds, contains('vs_123'));
    });

    test('creates code interpreter tool', () {
      final tool = ResponseTool.codeInterpreter();

      expect(tool, isA<CodeInterpreterTool>());
    });

    test('creates computer use tool', () {
      final tool = ResponseTool.computerUse(
        displayWidth: 1920,
        displayHeight: 1080,
        environment: 'browser',
      );

      expect(tool, isA<ComputerUseTool>());
      expect(tool.displayWidth, equals(1920));
    });

    test('creates image generation tool', () {
      final tool = ResponseTool.imageGeneration();

      expect(tool, isA<ImageGenerationTool>());
    });

    test('deserializes function tool from JSON', () {
      final json = {
        'type': 'function',
        'name': 'calculate',
        'description': 'Calculate something',
        'parameters': {'type': 'object'},
      };

      final tool = ResponseTool.fromJson(json);

      expect(tool, isA<FunctionTool>());
      expect((tool as FunctionTool).name, equals('calculate'));
    });

    test('deserializes web search tool from JSON', () {
      final json = {
        'type': 'web_search_preview',
        'search_context_size': 'high',
      };

      final tool = ResponseTool.fromJson(json);

      expect(tool, isA<WebSearchTool>());
    });
  });

  group('ResponseToolChoice', () {
    test('creates none choice', () {
      const choice = ResponseToolChoice.none;

      expect(choice, isA<ResponseToolChoiceNone>());
    });

    test('creates auto choice', () {
      const choice = ResponseToolChoice.auto;

      expect(choice, isA<ResponseToolChoiceAuto>());
    });

    test('creates required choice', () {
      const choice = ResponseToolChoice.required;

      expect(choice, isA<ResponseToolChoiceRequired>());
    });

    test('creates function choice', () {
      final choice = ResponseToolChoice.function(name: 'get_weather');

      expect(choice, isA<ResponseToolChoiceFunction>());
      expect(choice.name, equals('get_weather'));
    });
  });

  group('Item', () {
    test('creates message item', () {
      const item = MessageItem(
        role: MessageRole.user,
        content: [InputContent.text('Hello!')],
      );

      expect(item.role, equals(MessageRole.user));
    });

    test('creates user message with text', () {
      final item = MessageItem.userText('Hello!');

      expect(item.role, equals(MessageRole.user));
      expect(item.content.length, equals(1));
    });

    test('creates function call output item', () {
      final item = FunctionCallOutputItem.string(
        callId: 'call_123',
        output: '{"result": 42}',
      );

      expect(item.callId, equals('call_123'));
    });

    test('creates item reference', () {
      const item = ItemReference(id: 'item_123');

      expect(item.id, equals('item_123'));
    });

    test('FunctionCallItem.argumentsMap parses JSON arguments', () {
      const item = FunctionCallItem(
        callId: 'call_123',
        name: 'get_weather',
        arguments: '{"location":"Boston","unit":"celsius"}',
      );

      final argsMap = item.argumentsMap;

      expect(argsMap['location'], equals('Boston'));
      expect(argsMap['unit'], equals('celsius'));
    });

    test('FunctionCallItem.argumentsMap throws on non-object JSON', () {
      const item = FunctionCallItem(
        callId: 'call_123',
        name: 'test',
        arguments: '[]',
      );

      expect(() => item.argumentsMap, throwsFormatException);
    });

    test(
      'FunctionCallOutputItemResponse.argumentsMap parses JSON arguments',
      () {
        const item = FunctionCallOutputItemResponse(
          id: 'fc_123',
          callId: 'call_123',
          name: 'get_weather',
          arguments: '{"location":"Paris"}',
        );

        final argsMap = item.argumentsMap;

        expect(argsMap['location'], equals('Paris'));
      },
    );

    test(
      'FunctionCallOutputItemResponse.argumentsMap throws on non-object JSON',
      () {
        const item = FunctionCallOutputItemResponse(
          id: 'fc_123',
          callId: 'call_123',
          name: 'test',
          arguments: '"string"',
        );

        expect(() => item.argumentsMap, throwsFormatException);
      },
    );
  });

  group('InputContent', () {
    test('creates text content', () {
      const content = InputContent.text('Hello!');

      expect(content, isA<InputTextContent>());
      expect((content as InputTextContent).text, equals('Hello!'));
      expect(content.toJson()['type'], equals('input_text'));
    });

    test('creates text content with direct constructor', () {
      const content = InputTextContent('Hello!');

      expect(content.text, equals('Hello!'));
      expect(content.toJson()['type'], equals('input_text'));
    });

    test('creates image content from URL', () {
      const content = InputContent.imageUrl('https://example.com/img.png');

      expect(content, isA<InputImageContent>());
      expect(
        (content as InputImageContent).imageUrl,
        equals('https://example.com/img.png'),
      );
    });

    test('creates image content from file ID', () {
      const content = InputContent.imageFile('file_123');

      expect(content, isA<InputImageContent>());
      expect((content as InputImageContent).fileId, equals('file_123'));
    });

    test('creates video content', () {
      const content = InputContent.video('https://example.com/video.mp4');

      expect(content, isA<InputVideoContent>());
      expect(
        (content as InputVideoContent).videoUrl,
        equals('https://example.com/video.mp4'),
      );
    });

    test('creates file content from URL', () {
      const content = InputContent.fileUrl('https://example.com/file.pdf');

      expect(content, isA<InputFileContent>());
      expect(
        (content as InputFileContent).fileUrl,
        equals('https://example.com/file.pdf'),
      );
    });

    test('creates file content from file ID', () {
      const content = InputContent.fileId('file_456');

      expect(content, isA<InputFileContent>());
      expect((content as InputFileContent).fileId, equals('file_456'));
    });

    test('creates file content from base64 data', () {
      const content = InputContent.fileData('base64data==');

      expect(content, isA<InputFileContent>());
      expect((content as InputFileContent).fileData, equals('base64data=='));
    });
  });

  group('AssistantTextContent', () {
    test('serializes as output_text', () {
      const content = InputContent.assistantText('Hello!');

      expect(content, isA<AssistantTextContent>());
      final json = content.toJson();

      expect(json['type'], equals('output_text'));
      expect(json['text'], equals('Hello!'));
    });

    test('creates with direct constructor', () {
      const content = AssistantTextContent('Hello!');

      expect(content.text, equals('Hello!'));
      expect(content.toJson()['type'], equals('output_text'));
    });

    test('deserializes from JSON', () {
      final json = {'type': 'output_text', 'text': 'Hello!'};

      final content = InputContent.fromJson(json);

      expect(content, isA<AssistantTextContent>());
      expect((content as AssistantTextContent).text, equals('Hello!'));
    });

    test('MessageItem.assistantText uses AssistantTextContent', () {
      final item = MessageItem.assistantText('Hello!');

      expect(item.role, equals(MessageRole.assistant));
      expect(item.content.first, isA<AssistantTextContent>());

      final json = item.toJson();
      final contentJson =
          (json['content'] as List).first as Map<String, dynamic>;
      expect(contentJson['type'], equals('output_text'));
    });

    test('equality', () {
      const content1 = AssistantTextContent('Hello!');
      const content2 = AssistantTextContent('Hello!');
      const content3 = AssistantTextContent('Hi!');

      expect(content1, equals(content2));
      expect(content1, isNot(equals(content3)));
    });
  });

  group('OutputContent', () {
    test('creates text content via factory', () {
      const content = OutputContent.text(text: 'Response text');

      expect(content, isA<OutputTextContent>());
      expect((content as OutputTextContent).text, equals('Response text'));
    });

    test('creates reasoning content via factory', () {
      const content = OutputContent.reasoning('Thinking...');

      expect(content, isA<ReasoningTextContent>());
      expect((content as ReasoningTextContent).text, equals('Thinking...'));
    });

    test('creates summary content via factory', () {
      const content = OutputContent.summary('Summary here');

      expect(content, isA<SummaryTextContent>());
      expect((content as SummaryTextContent).text, equals('Summary here'));
    });

    test('creates refusal content via factory', () {
      const content = OutputContent.refusal('Cannot comply');

      expect(content, isA<RefusalContent>());
      expect((content as RefusalContent).refusal, equals('Cannot comply'));
    });

    test('creates refusal content with direct constructor', () {
      const content = RefusalContent('Cannot comply');

      expect(content.refusal, equals('Cannot comply'));
    });

    test('deserializes from JSON', () {
      final json = {'type': 'output_text', 'text': 'Hello!'};

      final content = OutputContent.fromJson(json);

      expect(content, isA<OutputTextContent>());
      expect((content as OutputTextContent).text, equals('Hello!'));
    });
  });

  group('OutputItem built-in tool types', () {
    test('deserializes WebSearchCallOutputItem', () {
      final json = {
        'type': 'web_search_call',
        'id': 'ws_123',
        'status': 'completed',
      };

      final item = OutputItem.fromJson(json);

      expect(item, isA<WebSearchCallOutputItem>());
      expect((item as WebSearchCallOutputItem).id, equals('ws_123'));
      expect(item.status, equals(ItemStatus.completed));
    });

    test('WebSearchCallOutputItem serializes correctly', () {
      const item = WebSearchCallOutputItem(
        id: 'ws_123',
        status: ItemStatus.completed,
      );

      final json = item.toJson();

      expect(json['type'], equals('web_search_call'));
      expect(json['id'], equals('ws_123'));
      expect(json['status'], equals('completed'));
    });

    test('deserializes FileSearchCallOutputItem', () {
      final json = {
        'type': 'file_search_call',
        'id': 'fs_123',
        'queries': ['search query'],
        'results': [
          {'file_id': 'file_1', 'text': 'result'},
        ],
        'status': 'completed',
      };

      final item = OutputItem.fromJson(json);

      expect(item, isA<FileSearchCallOutputItem>());
      final fsItem = item as FileSearchCallOutputItem;
      expect(fsItem.id, equals('fs_123'));
      expect(fsItem.queries, equals(['search query']));
      expect(fsItem.results, isNotNull);
      expect(fsItem.status, equals(ItemStatus.completed));
    });

    test('FileSearchCallOutputItem serializes correctly', () {
      const item = FileSearchCallOutputItem(
        id: 'fs_123',
        queries: ['test query'],
        status: ItemStatus.inProgress,
      );

      final json = item.toJson();

      expect(json['type'], equals('file_search_call'));
      expect(json['id'], equals('fs_123'));
      expect(json['queries'], equals(['test query']));
    });

    test('deserializes CodeInterpreterCallOutputItem', () {
      final json = {
        'type': 'code_interpreter_call',
        'id': 'ci_123',
        'code': 'print("hello")',
        'language': 'python',
        'outputs': [
          {'type': 'text', 'text': 'hello'},
        ],
        'status': 'completed',
      };

      final item = OutputItem.fromJson(json);

      expect(item, isA<CodeInterpreterCallOutputItem>());
      final ciItem = item as CodeInterpreterCallOutputItem;
      expect(ciItem.id, equals('ci_123'));
      expect(ciItem.code, equals('print("hello")'));
      expect(ciItem.language, equals('python'));
      expect(ciItem.outputs, isNotNull);
      expect(ciItem.status, equals(ItemStatus.completed));
    });

    test('CodeInterpreterCallOutputItem serializes correctly', () {
      const item = CodeInterpreterCallOutputItem(
        id: 'ci_123',
        code: 'x = 1 + 1',
        language: 'python',
        status: ItemStatus.completed,
      );

      final json = item.toJson();

      expect(json['type'], equals('code_interpreter_call'));
      expect(json['code'], equals('x = 1 + 1'));
      expect(json['language'], equals('python'));
    });

    test('deserializes ImageGenerationCallOutputItem', () {
      final json = {
        'type': 'image_generation_call',
        'id': 'img_123',
        'prompt': 'A cat',
        'revised_prompt': 'A cute cat sitting',
        'result': 'base64data==',
        'status': 'completed',
      };

      final item = OutputItem.fromJson(json);

      expect(item, isA<ImageGenerationCallOutputItem>());
      final imgItem = item as ImageGenerationCallOutputItem;
      expect(imgItem.id, equals('img_123'));
      expect(imgItem.prompt, equals('A cat'));
      expect(imgItem.revisedPrompt, equals('A cute cat sitting'));
      expect(imgItem.result, equals('base64data=='));
      expect(imgItem.status, equals(ItemStatus.completed));
    });

    test('ImageGenerationCallOutputItem serializes correctly', () {
      const item = ImageGenerationCallOutputItem(
        id: 'img_123',
        prompt: 'A dog',
        status: ItemStatus.inProgress,
      );

      final json = item.toJson();

      expect(json['type'], equals('image_generation_call'));
      expect(json['id'], equals('img_123'));
      expect(json['prompt'], equals('A dog'));
    });

    test('deserializes McpCallOutputItem', () {
      final json = {
        'type': 'mcp_call',
        'id': 'mcp_123',
        'call_id': 'call_456',
        'server_label': 'my_server',
        'name': 'read_file',
        'arguments': '{"path": "/tmp/file.txt"}',
        'output': 'file contents',
        'status': 'completed',
      };

      final item = OutputItem.fromJson(json);

      expect(item, isA<McpCallOutputItem>());
      final mcpItem = item as McpCallOutputItem;
      expect(mcpItem.id, equals('mcp_123'));
      expect(mcpItem.callId, equals('call_456'));
      expect(mcpItem.serverLabel, equals('my_server'));
      expect(mcpItem.name, equals('read_file'));
      expect(mcpItem.arguments, equals('{"path": "/tmp/file.txt"}'));
      expect(mcpItem.output, equals('file contents'));
      expect(mcpItem.status, equals(ItemStatus.completed));
    });

    test('McpCallOutputItem serializes correctly', () {
      const item = McpCallOutputItem(
        id: 'mcp_123',
        callId: 'call_456',
        serverLabel: 'test_server',
        name: 'test_tool',
        status: ItemStatus.inProgress,
      );

      final json = item.toJson();

      expect(json['type'], equals('mcp_call'));
      expect(json['id'], equals('mcp_123'));
      expect(json['call_id'], equals('call_456'));
      expect(json['server_label'], equals('test_server'));
      expect(json['name'], equals('test_tool'));
    });

    test('McpCallOutputItem with error', () {
      final json = {
        'type': 'mcp_call',
        'id': 'mcp_123',
        'call_id': 'call_456',
        'error': 'Connection refused',
        'status': 'incomplete',
      };

      final item = OutputItem.fromJson(json);

      expect(item, isA<McpCallOutputItem>());
      final mcpItem = item as McpCallOutputItem;
      expect(mcpItem.error, equals('Connection refused'));
      expect(mcpItem.status, equals(ItemStatus.incomplete));
    });
  });

  group('Response convenience getters for built-in tools', () {
    test('webSearchCalls returns web search items', () {
      const response = Response(
        id: 'resp_123',
        object: 'response',
        createdAt: 1234567890,
        status: ResponseStatus.completed,
        output: [
          MessageOutputItem(
            id: 'msg_123',
            role: MessageRole.assistant,
            content: [OutputContent.text(text: 'Found it!')],
          ),
          WebSearchCallOutputItem(id: 'ws_1', status: ItemStatus.completed),
          WebSearchCallOutputItem(id: 'ws_2', status: ItemStatus.completed),
        ],
      );

      expect(response.webSearchCalls.length, equals(2));
      expect(response.webSearchCalls.first.id, equals('ws_1'));
    });

    test('codeInterpreterCalls returns code interpreter items', () {
      const response = Response(
        id: 'resp_123',
        object: 'response',
        createdAt: 1234567890,
        status: ResponseStatus.completed,
        output: [
          CodeInterpreterCallOutputItem(
            id: 'ci_1',
            code: 'print(42)',
            language: 'python',
          ),
        ],
      );

      expect(response.codeInterpreterCalls.length, equals(1));
      expect(response.codeInterpreterCalls.first.code, equals('print(42)'));
    });
  });

  group('FunctionCallOutputItem copyWith', () {
    test('creates copy with updated fields', () {
      final original = FunctionCallOutputItem.string(
        callId: 'call_123',
        output: '{"result": 42}',
      );

      final copied = original.copyWith(callId: 'call_456');

      expect(copied.callId, equals('call_456'));
      expect(copied.output, equals(original.output));
    });

    test('creates copy preserving original fields', () {
      final original = FunctionCallOutputItem.string(
        id: 'id_123',
        callId: 'call_123',
        output: '{"result": 42}',
        status: FunctionCallStatus.completed,
      );

      final copied = original.copyWith();

      expect(copied.id, equals(original.id));
      expect(copied.callId, equals(original.callId));
      expect(copied.output, equals(original.output));
      expect(copied.status, equals(original.status));
    });
  });

  group('ResponseStreamEvent', () {
    test('deserializes response.created event', () {
      final json = {
        'type': 'response.created',
        'sequence_number': 1,
        'response': {
          'id': 'resp_123',
          'object': 'response',
          'created_at': 1234567890,
          'model': 'gpt-4o',
          'status': 'in_progress',
          'output': <dynamic>[],
        },
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<ResponseCreatedEvent>());
      expect((event as ResponseCreatedEvent).response.id, equals('resp_123'));
    });

    test('deserializes text delta event', () {
      final json = {
        'type': 'response.output_text.delta',
        'output_index': 0,
        'content_index': 0,
        'delta': 'Hello',
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<OutputTextDeltaEvent>());
      expect((event as OutputTextDeltaEvent).delta, equals('Hello'));
      expect(event.textDelta, equals('Hello'));
    });

    test('deserializes function call arguments delta', () {
      final json = {
        'type': 'response.function_call_arguments.delta',
        'output_index': 0,
        'item_id': 'item_123',
        'delta': '{"loc',
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<FunctionCallArgumentsDeltaEvent>());
      expect(
        (event as FunctionCallArgumentsDeltaEvent).itemId,
        equals('item_123'),
      );
    });

    test('deserializes reasoning text delta event (renamed)', () {
      final json = {
        'type': 'response.reasoning_text.delta',
        'item_id': 'item_123',
        'output_index': 0,
        'content_index': 0,
        'delta': 'thinking...',
        'sequence_number': 1,
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<ReasoningTextDeltaEvent>());
      final reasoningEvent = event as ReasoningTextDeltaEvent;
      expect(reasoningEvent.itemId, equals('item_123'));
      expect(reasoningEvent.contentIndex, equals(0));
      expect(reasoningEvent.delta, equals('thinking...'));
    });

    test('deserializes response.queued event', () {
      final json = {
        'type': 'response.queued',
        'sequence_number': 1,
        'response': {
          'id': 'resp_123',
          'object': 'response',
          'created_at': 1234567890,
          'model': 'gpt-4o',
          'status': 'queued',
          'output': <dynamic>[],
        },
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<ResponseQueuedEvent>());
      expect((event as ResponseQueuedEvent).response.id, equals('resp_123'));
    });

    test('deserializes audio delta event', () {
      final json = {
        'type': 'response.audio.delta',
        'delta': 'base64audiodata==',
        'sequence_number': 1,
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<ResponseAudioDeltaEvent>());
      expect(
        (event as ResponseAudioDeltaEvent).delta,
        equals('base64audiodata=='),
      );
    });

    test('deserializes web search call completed event', () {
      final json = {
        'type': 'response.web_search_call.completed',
        'item_id': 'ws_123',
        'output_index': 0,
        'sequence_number': 1,
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<ResponseWebSearchCallCompletedEvent>());
      final wsEvent = event as ResponseWebSearchCallCompletedEvent;
      expect(wsEvent.itemId, equals('ws_123'));
      expect(wsEvent.outputIndex, equals(0));
    });

    test('deserializes file search call in progress event', () {
      final json = {
        'type': 'response.file_search_call.in_progress',
        'item_id': 'fs_123',
        'output_index': 0,
        'sequence_number': 1,
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<ResponseFileSearchCallInProgressEvent>());
      expect(
        (event as ResponseFileSearchCallInProgressEvent).itemId,
        equals('fs_123'),
      );
    });

    test('deserializes code interpreter call code delta event', () {
      final json = {
        'type': 'response.code_interpreter_call_code.delta',
        'item_id': 'ci_123',
        'output_index': 0,
        'delta': 'print("hello")',
        'sequence_number': 1,
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<ResponseCodeInterpreterCallCodeDeltaEvent>());
      final ciEvent = event as ResponseCodeInterpreterCallCodeDeltaEvent;
      expect(ciEvent.itemId, equals('ci_123'));
      expect(ciEvent.delta, equals('print("hello")'));
    });

    test('deserializes image generation partial image event', () {
      final json = {
        'type': 'response.image_generation_call.partial_image',
        'item_id': 'img_123',
        'output_index': 0,
        'partial_image_b64': 'base64imagedata==',
        'partial_image_index': 0,
        'sequence_number': 1,
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<ResponseImageGenerationCallPartialImageEvent>());
      final imgEvent = event as ResponseImageGenerationCallPartialImageEvent;
      expect(imgEvent.itemId, equals('img_123'));
      expect(imgEvent.partialImageB64, equals('base64imagedata=='));
      expect(imgEvent.partialImageIndex, equals(0));
    });

    test('deserializes MCP call arguments delta event', () {
      final json = {
        'type': 'response.mcp_call_arguments.delta',
        'item_id': 'mcp_123',
        'output_index': 0,
        'delta': '{"arg": "value"}',
        'sequence_number': 1,
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<ResponseMcpCallArgumentsDeltaEvent>());
      final mcpEvent = event as ResponseMcpCallArgumentsDeltaEvent;
      expect(mcpEvent.itemId, equals('mcp_123'));
      expect(mcpEvent.delta, equals('{"arg": "value"}'));
    });

    test('deserializes custom tool call input done event', () {
      final json = {
        'type': 'response.custom_tool_call_input.done',
        'item_id': 'tool_123',
        'output_index': 0,
        'input': '{"complete": "input"}',
        'sequence_number': 1,
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<ResponseCustomToolCallInputDoneEvent>());
      final toolEvent = event as ResponseCustomToolCallInputDoneEvent;
      expect(toolEvent.itemId, equals('tool_123'));
      expect(toolEvent.input, equals('{"complete": "input"}'));
    });

    test('text delta event includes itemId and logprobs', () {
      final json = {
        'type': 'response.output_text.delta',
        'item_id': 'item_123',
        'output_index': 0,
        'content_index': 0,
        'delta': 'Hello',
        'logprobs': [
          {'token': 'Hello', 'logprob': -0.5, 'bytes': null},
        ],
        'sequence_number': 1,
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<OutputTextDeltaEvent>());
      final textEvent = event as OutputTextDeltaEvent;
      expect(textEvent.itemId, equals('item_123'));
      expect(textEvent.logprobs, isNotNull);
      expect(textEvent.logprobs!.first.token, equals('Hello'));
    });

    test('function call arguments done event includes name', () {
      final json = {
        'type': 'response.function_call_arguments.done',
        'item_id': 'item_123',
        'output_index': 0,
        'name': 'get_weather',
        'arguments': '{"location": "Paris"}',
        'sequence_number': 1,
      };

      final event = ResponseStreamEvent.fromJson(json);

      expect(event, isA<FunctionCallArgumentsDoneEvent>());
      final funcEvent = event as FunctionCallArgumentsDoneEvent;
      expect(funcEvent.itemId, equals('item_123'));
      expect(funcEvent.name, equals('get_weather'));
      expect(funcEvent.arguments, equals('{"location": "Paris"}'));
    });

    test('isFinal returns true for completed events', () {
      const completedEvent = ResponseCompletedEvent(
        response: Response(
          id: 'resp_123',
          object: 'response',
          createdAt: 1234567890,
          model: 'gpt-4o',
          status: ResponseStatus.completed,
          output: [],
        ),
      );

      expect(completedEvent.isFinal, isTrue);
    });
  });

  group('ResponseUsage', () {
    test('deserializes from JSON', () {
      final json = {
        'input_tokens': 100,
        'output_tokens': 50,
        'total_tokens': 150,
        'input_tokens_details': {'cached_tokens': 20},
        'output_tokens_details': {'reasoning_tokens': 10},
      };

      final usage = ResponseUsage.fromJson(json);

      expect(usage.inputTokens, equals(100));
      expect(usage.outputTokens, equals(50));
      expect(usage.totalTokens, equals(150));
      expect(usage.inputTokensDetails?.cachedTokens, equals(20));
      expect(usage.outputTokensDetails?.reasoningTokens, equals(10));
    });

    test('serializes to JSON', () {
      const usage = ResponseUsage(
        inputTokens: 100,
        outputTokens: 50,
        totalTokens: 150,
      );

      final json = usage.toJson();

      expect(json['input_tokens'], equals(100));
      expect(json['output_tokens'], equals(50));
      expect(json['total_tokens'], equals(150));
    });
  });

  group('TextFormat', () {
    test('creates plain text format', () {
      const format = PlainTextFormat();

      expect(format.toJson()['type'], equals('text'));
    });

    test('creates json object format', () {
      const format = JsonObjectFormat();

      expect(format.toJson()['type'], equals('json_object'));
    });

    test('creates json schema format', () {
      const format = JsonSchemaFormat(
        name: 'person',
        schema: {'type': 'object'},
        strict: true,
      );

      final json = format.toJson();

      expect(json['type'], equals('json_schema'));
      expect(json['name'], equals('person'));
      expect(json['strict'], isTrue);
    });

    test('deserializes from JSON', () {
      final json = {
        'type': 'json_schema',
        'name': 'output',
        'schema': {'type': 'object'},
      };

      final format = TextFormat.fromJson(json);

      expect(format, isA<JsonSchemaFormat>());
      expect((format as JsonSchemaFormat).name, equals('output'));
    });
  });

  group('InputTokenCountResponse', () {
    test('deserializes from JSON', () {
      final json = {'input_tokens': 100, 'object': 'response.input_tokens'};

      final response = InputTokenCountResponse.fromJson(json);

      expect(response.inputTokens, equals(100));
      expect(response.object, equals('response.input_tokens'));
    });

    test('serializes to JSON', () {
      const response = InputTokenCountResponse(inputTokens: 50);

      final json = response.toJson();

      expect(json['input_tokens'], equals(50));
      expect(json['object'], equals('response.input_tokens'));
    });

    test('uses default object value', () {
      final json = {'input_tokens': 25};

      final response = InputTokenCountResponse.fromJson(json);

      expect(response.inputTokens, equals(25));
      expect(response.object, equals('response.input_tokens'));
    });

    test('equality', () {
      const response1 = InputTokenCountResponse(inputTokens: 100);
      const response2 = InputTokenCountResponse(inputTokens: 100);
      const response3 = InputTokenCountResponse(inputTokens: 200);

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });
  });
}
