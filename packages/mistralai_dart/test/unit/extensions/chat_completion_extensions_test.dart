import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ChatCompletionResponseExtensions', () {
    test('text returns content from first assistant message', () {
      const response = ChatCompletionResponse(
        id: 'chat-1',
        object: 'chat.completion',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(content: 'Hello!'),
            finishReason: FinishReason.stop,
          ),
        ],
      );
      expect(response.text, 'Hello!');
    });

    test('text returns null when no content', () {
      const response = ChatCompletionResponse(
        id: 'chat-1',
        object: 'chat.completion',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(content: null),
            finishReason: FinishReason.stop,
          ),
        ],
      );
      expect(response.text, isNull);
    });

    test('text returns null when no choices', () {
      const response = ChatCompletionResponse(
        id: 'chat-1',
        object: 'chat.completion',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [],
      );
      expect(response.text, isNull);
    });

    test('allText concatenates text from all choices', () {
      const response = ChatCompletionResponse(
        id: 'chat-1',
        object: 'chat.completion',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(content: 'Hello '),
            finishReason: FinishReason.stop,
          ),
          ChatChoice(
            index: 1,
            message: AssistantMessage(content: 'World!'),
            finishReason: FinishReason.stop,
          ),
        ],
      );
      expect(response.allText, 'Hello World!');
    });

    test('firstChoice and lastChoice return correct choices', () {
      const response = ChatCompletionResponse(
        id: 'chat-1',
        object: 'chat.completion',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(content: 'First'),
            finishReason: FinishReason.stop,
          ),
          ChatChoice(
            index: 1,
            message: AssistantMessage(content: 'Last'),
            finishReason: FinishReason.stop,
          ),
        ],
      );
      expect(response.firstChoice?.index, 0);
      expect(response.lastChoice?.index, 1);
    });

    test('toolCalls returns tool calls from first message', () {
      const response = ChatCompletionResponse(
        id: 'chat-1',
        object: 'chat.completion',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(
              content: null,
              toolCalls: [
                ToolCall(
                  id: 'call-1',
                  type: 'function',
                  function: FunctionCall(
                    name: 'get_weather',
                    arguments: '{"location": "Paris"}',
                  ),
                ),
              ],
            ),
            finishReason: FinishReason.toolCalls,
          ),
        ],
      );
      expect(response.toolCalls, hasLength(1));
      expect(response.toolCalls.first.function.name, 'get_weather');
      expect(response.hasToolCalls, isTrue);
    });

    test('functionCalls extracts function calls from tool calls', () {
      const response = ChatCompletionResponse(
        id: 'chat-1',
        object: 'chat.completion',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(
              content: null,
              toolCalls: [
                ToolCall(
                  id: 'call-1',
                  type: 'function',
                  function: FunctionCall(name: 'fn1', arguments: '{}'),
                ),
                ToolCall(
                  id: 'call-2',
                  type: 'function',
                  function: FunctionCall(name: 'fn2', arguments: '{}'),
                ),
              ],
            ),
            finishReason: FinishReason.toolCalls,
          ),
        ],
      );
      final functionCalls = response.functionCalls;
      expect(functionCalls, hasLength(2));
      expect(functionCalls[0].name, 'fn1');
      expect(functionCalls[1].name, 'fn2');
    });

    test('hasContent returns true when text or tool calls exist', () {
      const withText = ChatCompletionResponse(
        id: 'chat-1',
        object: 'chat.completion',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(content: 'Hello'),
            finishReason: FinishReason.stop,
          ),
        ],
      );
      expect(withText.hasContent, isTrue);

      const withToolCalls = ChatCompletionResponse(
        id: 'chat-2',
        object: 'chat.completion',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(
              content: null,
              toolCalls: [
                ToolCall(
                  id: 'call-1',
                  type: 'function',
                  function: FunctionCall(name: 'fn', arguments: '{}'),
                ),
              ],
            ),
            finishReason: FinishReason.toolCalls,
          ),
        ],
      );
      expect(withToolCalls.hasContent, isTrue);
    });

    test('finish reason helpers work correctly', () {
      const stoppedNaturally = ChatCompletionResponse(
        id: 'chat-1',
        object: 'chat.completion',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(content: 'Done'),
            finishReason: FinishReason.stop,
          ),
        ],
      );
      expect(stoppedNaturally.stoppedNaturally, isTrue);
      expect(stoppedNaturally.stoppedForToolCalls, isFalse);
      expect(stoppedNaturally.stoppedDueToLength, isFalse);

      const stoppedForTools = ChatCompletionResponse(
        id: 'chat-2',
        object: 'chat.completion',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(content: null),
            finishReason: FinishReason.toolCalls,
          ),
        ],
      );
      expect(stoppedForTools.stoppedForToolCalls, isTrue);

      const stoppedForLength = ChatCompletionResponse(
        id: 'chat-3',
        object: 'chat.completion',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(content: 'Truncated...'),
            finishReason: FinishReason.length,
          ),
        ],
      );
      expect(stoppedForLength.stoppedDueToLength, isTrue);
    });
  });

  group('ChatChoiceExtensions', () {
    test('text returns message content', () {
      const choice = ChatChoice(
        index: 0,
        message: AssistantMessage(content: 'Test'),
        finishReason: FinishReason.stop,
      );
      expect(choice.text, 'Test');
    });

    test('toolCalls returns message tool calls', () {
      const choice = ChatChoice(
        index: 0,
        message: AssistantMessage(
          content: null,
          toolCalls: [
            ToolCall(
              id: 'call-1',
              type: 'function',
              function: FunctionCall(name: 'fn', arguments: '{}'),
            ),
          ],
        ),
        finishReason: FinishReason.toolCalls,
      );
      expect(choice.toolCalls, hasLength(1));
      expect(choice.hasToolCalls, isTrue);
    });

    test('stoppedForToolCalls and stoppedNaturally work correctly', () {
      const toolChoice = ChatChoice(
        index: 0,
        message: AssistantMessage(content: null),
        finishReason: FinishReason.toolCalls,
      );
      expect(toolChoice.stoppedForToolCalls, isTrue);
      expect(toolChoice.stoppedNaturally, isFalse);

      const stopChoice = ChatChoice(
        index: 0,
        message: AssistantMessage(content: 'Done'),
        finishReason: FinishReason.stop,
      );
      expect(stopChoice.stoppedNaturally, isTrue);
      expect(stopChoice.stoppedForToolCalls, isFalse);
    });
  });

  group('AssistantMessageExtensions', () {
    test('hasToolCalls returns correct value', () {
      const withCalls = AssistantMessage(
        content: null,
        toolCalls: [
          ToolCall(
            id: 'call-1',
            type: 'function',
            function: FunctionCall(name: 'fn', arguments: '{}'),
          ),
        ],
      );
      expect(withCalls.hasToolCalls, isTrue);
      expect(withCalls.toolCallCount, 1);

      const noCalls = AssistantMessage(content: 'Hello');
      expect(noCalls.hasToolCalls, isFalse);
      expect(noCalls.toolCallCount, 0);
    });

    test('hasContent returns correct value', () {
      const withContent = AssistantMessage(content: 'Hello');
      expect(withContent.hasContent, isTrue);

      const emptyContent = AssistantMessage(content: '');
      expect(emptyContent.hasContent, isFalse);

      const nullContent = AssistantMessage(content: null);
      expect(nullContent.hasContent, isFalse);
    });

    test('functionCalls extracts function information', () {
      const msg = AssistantMessage(
        content: null,
        toolCalls: [
          ToolCall(
            id: 'call-1',
            type: 'function',
            function: FunctionCall(name: 'get_time', arguments: '{}'),
          ),
        ],
      );
      expect(msg.functionCalls, hasLength(1));
      expect(msg.functionCalls.first.name, 'get_time');
    });
  });

  group('UserMessageExtensions', () {
    test('isTextOnly returns true for string content', () {
      final textMsg = UserMessage.text('Hello');
      expect(textMsg.isTextOnly, isTrue);
      expect(textMsg.isMultimodal, isFalse);
      expect(textMsg.textContent, 'Hello');
    });

    test('isMultimodal returns true for list content', () {
      final multiMsg = UserMessage.multimodal(const [
        TextContentPart(text: 'What is this?'),
        ImageUrlContentPart(url: 'https://example.com/image.jpg'),
      ]);
      expect(multiMsg.isMultimodal, isTrue);
      expect(multiMsg.isTextOnly, isFalse);
      expect(multiMsg.textContent, isNull);
    });
  });

  group('SystemMessageExtensions', () {
    test('hasContent returns correct value', () {
      const withContent = SystemMessage(content: 'You are helpful.');
      expect(withContent.hasContent, isTrue);

      const empty = SystemMessage(content: '');
      expect(empty.hasContent, isFalse);
    });
  });

  group('ToolMessageExtensions', () {
    test('hasContent returns correct value', () {
      const withContent = ToolMessage(
        toolCallId: 'call-1',
        content: '{"result": 42}',
      );
      expect(withContent.hasContent, isTrue);

      const empty = ToolMessage(toolCallId: 'call-2', content: '');
      expect(empty.hasContent, isFalse);
    });
  });
}
