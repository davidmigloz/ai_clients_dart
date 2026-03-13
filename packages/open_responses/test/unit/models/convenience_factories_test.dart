import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

void main() {
  group('ToolChoice static factories', () {
    test('auto returns ToolChoiceAuto', () {
      expect(ToolChoice.auto, isA<ToolChoiceAuto>());
      expect(ToolChoice.auto.toJson(), 'auto');
    });

    test('none returns ToolChoiceNone', () {
      expect(ToolChoice.none, isA<ToolChoiceNone>());
      expect(ToolChoice.none.toJson(), 'none');
    });

    test('required returns ToolChoiceRequired', () {
      expect(ToolChoice.required, isA<ToolChoiceRequired>());
      expect(ToolChoice.required.toJson(), 'required');
    });

    test('function_ returns ToolChoiceFunction', () {
      final choice = ToolChoice.function_(name: 'get_weather');
      expect(choice, isA<ToolChoiceFunction>());
      expect((choice as ToolChoiceFunction).name, 'get_weather');
      expect(choice.toJson(), {'type': 'function', 'name': 'get_weather'});
    });

    test('allowedTools returns ToolChoiceAllowedTools', () {
      final choice = ToolChoice.allowedTools(
        tools: const [SpecificFunctionChoice(name: 'search')],
        mode: ToolChoiceMode.required,
      );
      expect(choice, isA<ToolChoiceAllowedTools>());
      final allowed = choice as ToolChoiceAllowedTools;
      expect(allowed.tools, hasLength(1));
      expect(allowed.mode, ToolChoiceMode.required);
    });

    test('allowedTools round-trip', () {
      final original = ToolChoice.allowedTools(
        tools: const [
          SpecificFunctionChoice(name: 'fn1'),
          SpecificFunctionChoice(name: 'fn2'),
        ],
        mode: ToolChoiceMode.auto,
      );
      final json = original.toJson();
      final restored = ToolChoice.fromJson(json);
      expect(restored, equals(original));
    });
  });

  group('InputContent static factories', () {
    test('text() creates InputTextContent', () {
      final content = InputContent.text('Hello');
      expect(content, isA<InputTextContent>());
      expect((content as InputTextContent).text, 'Hello');
    });

    test('text() round-trip', () {
      final original = InputContent.text('Hello');
      final json = original.toJson();
      final restored = InputContent.fromJson(json);
      expect(restored, equals(original));
    });

    test('imageUrl() creates InputImageContent with URL', () {
      final content = InputContent.imageUrl('https://example.com/img.png');
      expect(content, isA<InputImageContent>());
      final img = content as InputImageContent;
      expect(img.imageUrl, 'https://example.com/img.png');
      expect(img.fileId, isNull);
    });

    test('imageUrl() round-trip', () {
      final original = InputContent.imageUrl('https://example.com/img.png');
      final json = original.toJson();
      final restored = InputContent.fromJson(json);
      expect(restored, equals(original));
    });

    test('imageFile() creates InputImageContent with file ID', () {
      final content = InputContent.imageFile('file_abc');
      expect(content, isA<InputImageContent>());
      final img = content as InputImageContent;
      expect(img.fileId, 'file_abc');
      expect(img.imageUrl, isNull);
    });

    test('imageFile() round-trip', () {
      final original = InputContent.imageFile('file_abc');
      final json = original.toJson();
      final restored = InputContent.fromJson(json);
      expect(restored, equals(original));
    });

    test('fileUrl() creates InputFileContent with URL', () {
      final content = InputContent.fileUrl(
        'https://example.com/doc.pdf',
        filename: 'doc.pdf',
      );
      expect(content, isA<InputFileContent>());
      final file = content as InputFileContent;
      expect(file.fileUrl, 'https://example.com/doc.pdf');
      expect(file.filename, 'doc.pdf');
    });

    test('fileUrl() round-trip', () {
      final original = InputContent.fileUrl(
        'https://example.com/doc.pdf',
        filename: 'doc.pdf',
      );
      final json = original.toJson();
      final restored = InputContent.fromJson(json);
      expect(restored, equals(original));
    });

    test('videoUrl() creates InputVideoContent', () {
      final content = InputContent.videoUrl('https://example.com/vid.mp4');
      expect(content, isA<InputVideoContent>());
      expect(
        (content as InputVideoContent).videoUrl,
        'https://example.com/vid.mp4',
      );
    });

    test('videoUrl() round-trip', () {
      final original = InputContent.videoUrl('https://example.com/vid.mp4');
      final json = original.toJson();
      final restored = InputContent.fromJson(json);
      expect(restored, equals(original));
    });

    test('fromJson throws on unknown type', () {
      expect(
        () => InputContent.fromJson({'type': 'unknown'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('OutputContent static factories', () {
    test('text() creates OutputTextContent', () {
      final content = OutputContent.text('Hello');
      expect(content, isA<OutputTextContent>());
      expect((content as OutputTextContent).text, 'Hello');
    });

    test('text() with annotations', () {
      final content = OutputContent.text('Hello', annotations: []);
      expect(content, isA<OutputTextContent>());
      expect((content as OutputTextContent).annotations, isEmpty);
    });

    test('text() round-trip', () {
      final original = OutputContent.text('Hello');
      final json = original.toJson();
      final restored = OutputContent.fromJson(json);
      expect(restored, equals(original));
    });

    test('refusal() creates RefusalContent', () {
      final content = OutputContent.refusal('I cannot help with that');
      expect(content, isA<RefusalContent>());
      expect((content as RefusalContent).refusal, 'I cannot help with that');
    });

    test('refusal() round-trip', () {
      final original = OutputContent.refusal('No');
      final json = original.toJson();
      final restored = OutputContent.fromJson(json);
      expect(restored, equals(original));
    });

    test('reasoning() creates ReasoningTextContent', () {
      final content = OutputContent.reasoning('Step 1: ...');
      expect(content, isA<ReasoningTextContent>());
      expect((content as ReasoningTextContent).text, 'Step 1: ...');
    });

    test('reasoning() round-trip', () {
      final original = OutputContent.reasoning('Think...');
      final json = original.toJson();
      final restored = OutputContent.fromJson(json);
      expect(restored, equals(original));
    });

    test('summary() creates SummaryTextContent', () {
      final content = OutputContent.summary('Summary of reasoning');
      expect(content, isA<SummaryTextContent>());
      expect((content as SummaryTextContent).text, 'Summary of reasoning');
    });

    test('summary() round-trip', () {
      final original = OutputContent.summary('Summary');
      final json = original.toJson();
      final restored = OutputContent.fromJson(json);
      expect(restored, equals(original));
    });

    test('fromJson throws on unknown type', () {
      expect(
        () => OutputContent.fromJson({'type': 'unknown'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Tool static factories', () {
    test('function_() creates FunctionTool', () {
      final tool = Tool.function_(
        name: 'get_weather',
        description: 'Get the weather',
        parameters: {
          'type': 'object',
          'properties': {
            'location': {'type': 'string'},
          },
        },
        strict: true,
      );
      expect(tool, isA<FunctionTool>());
      final fn = tool as FunctionTool;
      expect(fn.name, 'get_weather');
      expect(fn.description, 'Get the weather');
      expect(fn.parameters, isNotNull);
      expect(fn.strict, true);
    });

    test('function_() round-trip', () {
      final original = Tool.function_(
        name: 'calc',
        description: 'Calculate',
        parameters: {'type': 'object'},
      );
      final json = original.toJson();
      final restored = Tool.fromJson(json);
      expect(restored, equals(original));
    });

    test('function_() minimal', () {
      final tool = Tool.function_(name: 'simple');
      expect(tool, isA<FunctionTool>());
      final fn = tool as FunctionTool;
      expect(fn.name, 'simple');
      expect(fn.description, isNull);
      expect(fn.parameters, isNull);
      expect(fn.strict, isNull);
    });

    test('mcp() creates McpTool', () {
      final tool = Tool.mcp(
        serverLabel: 'my-server',
        serverUrl: 'https://mcp.example.com',
        allowedTools: ['tool_a', 'tool_b'],
        requireApproval: 'always',
      );
      expect(tool, isA<McpTool>());
      final mcp = tool as McpTool;
      expect(mcp.serverLabel, 'my-server');
      expect(mcp.serverUrl, 'https://mcp.example.com');
      expect(mcp.allowedTools, ['tool_a', 'tool_b']);
      expect(mcp.requireApproval, 'always');
    });

    test('mcp() round-trip', () {
      final original = Tool.mcp(
        serverLabel: 'srv',
        serverUrl: 'https://example.com',
        allowedTools: ['tool1'],
      );
      final json = original.toJson();
      final restored = Tool.fromJson(json);
      expect(restored, equals(original));
    });

    test('fromJson throws on unknown type', () {
      expect(
        () => Tool.fromJson({'type': 'unknown'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('MessageOutputItem convenience getters', () {
    test('text returns combined text', () {
      const item = MessageOutputItem(
        id: 'msg_1',
        role: MessageRole.assistant,
        content: [
          OutputTextContent(text: 'Hello '),
          OutputTextContent(text: 'World'),
        ],
      );
      expect(item.text, 'Hello World');
    });

    test('text returns null when no text content', () {
      const item = MessageOutputItem(
        id: 'msg_1',
        role: MessageRole.assistant,
        content: [RefusalContent(refusal: 'Refused')],
      );
      expect(item.text, isNull);
    });

    test('hasRefusal is true when refusal content exists', () {
      const item = MessageOutputItem(
        id: 'msg_1',
        role: MessageRole.assistant,
        content: [
          OutputTextContent(text: 'Partial'),
          RefusalContent(refusal: 'Cannot help'),
        ],
      );
      expect(item.hasRefusal, isTrue);
    });

    test('hasRefusal is false when no refusal content', () {
      const item = MessageOutputItem(
        id: 'msg_1',
        role: MessageRole.assistant,
        content: [OutputTextContent(text: 'All good')],
      );
      expect(item.hasRefusal, isFalse);
    });
  });

  group('FunctionCallOutputItemResponse convenience getters', () {
    test('isCompleted returns true when status is completed', () {
      const item = FunctionCallOutputItemResponse(
        id: 'call_1',
        callId: 'c1',
        name: 'fn',
        arguments: '{}',
        status: ItemStatus.completed,
      );
      expect(item.isCompleted, isTrue);
    });

    test('isCompleted returns false when status is in_progress', () {
      const item = FunctionCallOutputItemResponse(
        id: 'call_1',
        callId: 'c1',
        name: 'fn',
        arguments: '{}',
        status: ItemStatus.inProgress,
      );
      expect(item.isCompleted, isFalse);
    });

    test('isCompleted returns false when status is null', () {
      const item = FunctionCallOutputItemResponse(
        id: 'call_1',
        callId: 'c1',
        name: 'fn',
        arguments: '{}',
      );
      expect(item.isCompleted, isFalse);
    });

    test('toFunctionCallItem converts correctly', () {
      const item = FunctionCallOutputItemResponse(
        id: 'call_1',
        callId: 'c1',
        name: 'get_weather',
        arguments: '{"location":"NYC"}',
        status: ItemStatus.completed,
      );
      final input = item.toFunctionCallItem();
      expect(input.id, 'call_1');
      expect(input.callId, 'c1');
      expect(input.name, 'get_weather');
      expect(input.arguments, '{"location":"NYC"}');
      expect(input.status, ItemStatus.completed);
    });
  });
}
