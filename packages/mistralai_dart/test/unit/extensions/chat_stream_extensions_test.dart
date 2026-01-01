import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ChatCompletionStreamResponseExtensions', () {
    test('text returns content from first delta', () {
      const chunk = ChatCompletionStreamResponse(
        id: 'chat-1',
        object: 'chat.completion.chunk',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoiceDelta(
            index: 0,
            delta: DeltaContent(role: 'assistant', content: 'Hello'),
          ),
        ],
      );
      expect(chunk.text, 'Hello');
    });

    test('text returns null when no content', () {
      const chunk = ChatCompletionStreamResponse(
        id: 'chat-1',
        object: 'chat.completion.chunk',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoiceDelta(index: 0, delta: DeltaContent(role: 'assistant')),
        ],
      );
      expect(chunk.text, isNull);
    });

    test('firstChoice returns first choice delta', () {
      const chunk = ChatCompletionStreamResponse(
        id: 'chat-1',
        object: 'chat.completion.chunk',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoiceDelta(
            index: 0,
            delta: DeltaContent(role: 'assistant', content: 'First'),
          ),
          ChatChoiceDelta(
            index: 1,
            delta: DeltaContent(role: 'assistant', content: 'Second'),
          ),
        ],
      );
      expect(chunk.firstChoice?.index, 0);
    });

    test('toolCalls returns tool calls from delta', () {
      const chunk = ChatCompletionStreamResponse(
        id: 'chat-1',
        object: 'chat.completion.chunk',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoiceDelta(
            index: 0,
            delta: DeltaContent(
              role: 'assistant',
              toolCalls: [
                ToolCall(
                  id: 'call-1',
                  type: 'function',
                  function: FunctionCall(
                    name: 'get_weather',
                    arguments: '{"location":',
                  ),
                ),
              ],
            ),
          ),
        ],
      );
      expect(chunk.toolCalls, hasLength(1));
      expect(chunk.hasToolCalls, isTrue);
    });

    test('isFinal returns true when finishReason exists', () {
      const notFinal = ChatCompletionStreamResponse(
        id: 'chat-1',
        object: 'chat.completion.chunk',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoiceDelta(
            index: 0,
            delta: DeltaContent(role: 'assistant', content: 'partial'),
          ),
        ],
      );
      expect(notFinal.isFinal, isFalse);

      const isFinal = ChatCompletionStreamResponse(
        id: 'chat-2',
        object: 'chat.completion.chunk',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoiceDelta(
            index: 0,
            delta: DeltaContent(role: 'assistant'),
            finishReason: FinishReason.stop,
          ),
        ],
      );
      expect(isFinal.isFinal, isTrue);
    });

    test(
      'stoppedForToolCalls returns true when finish reason is tool_calls',
      () {
        const chunk = ChatCompletionStreamResponse(
          id: 'chat-1',
          object: 'chat.completion.chunk',
          model: 'mistral-small-latest',
          created: 1703980800,
          choices: [
            ChatChoiceDelta(
              index: 0,
              delta: DeltaContent(role: 'assistant'),
              finishReason: FinishReason.toolCalls,
            ),
          ],
        );
        expect(chunk.stoppedForToolCalls, isTrue);
        expect(chunk.stoppedNaturally, isFalse);
      },
    );

    test('stoppedNaturally returns true when finish reason is stop', () {
      const chunk = ChatCompletionStreamResponse(
        id: 'chat-1',
        object: 'chat.completion.chunk',
        model: 'mistral-small-latest',
        created: 1703980800,
        choices: [
          ChatChoiceDelta(
            index: 0,
            delta: DeltaContent(role: 'assistant'),
            finishReason: FinishReason.stop,
          ),
        ],
      );
      expect(chunk.stoppedNaturally, isTrue);
      expect(chunk.stoppedForToolCalls, isFalse);
    });
  });

  group('ChatChoiceDeltaExtensions', () {
    test('text returns delta content', () {
      const delta = ChatChoiceDelta(
        index: 0,
        delta: DeltaContent(role: 'assistant', content: 'Test content'),
      );
      expect(delta.text, 'Test content');
    });

    test('toolCalls returns delta tool calls', () {
      const delta = ChatChoiceDelta(
        index: 0,
        delta: DeltaContent(
          role: 'assistant',
          toolCalls: [
            ToolCall(
              id: 'call-1',
              type: 'function',
              function: FunctionCall(name: 'fn', arguments: '{}'),
            ),
          ],
        ),
      );
      expect(delta.toolCalls, hasLength(1));
      expect(delta.hasToolCalls, isTrue);
    });

    test('isFinal returns true when finishReason exists', () {
      const notFinal = ChatChoiceDelta(
        index: 0,
        delta: DeltaContent(role: 'assistant', content: 'x'),
      );
      expect(notFinal.isFinal, isFalse);

      const isFinal = ChatChoiceDelta(
        index: 0,
        delta: DeltaContent(role: 'assistant'),
        finishReason: FinishReason.stop,
      );
      expect(isFinal.isFinal, isTrue);
    });
  });

  group('ChatStreamExtensions', () {
    test('text collects all text from stream', () async {
      final stream = Stream.fromIterable([
        const ChatCompletionStreamResponse(
          id: 'chat-1',
          object: 'chat.completion.chunk',
          model: 'mistral-small-latest',
          created: 1703980800,
          choices: [
            ChatChoiceDelta(
              index: 0,
              delta: DeltaContent(role: 'assistant', content: 'Hello'),
            ),
          ],
        ),
        const ChatCompletionStreamResponse(
          id: 'chat-1',
          object: 'chat.completion.chunk',
          model: 'mistral-small-latest',
          created: 1703980800,
          choices: [
            ChatChoiceDelta(
              index: 0,
              delta: DeltaContent(role: 'assistant', content: ' '),
            ),
          ],
        ),
        const ChatCompletionStreamResponse(
          id: 'chat-1',
          object: 'chat.completion.chunk',
          model: 'mistral-small-latest',
          created: 1703980800,
          choices: [
            ChatChoiceDelta(
              index: 0,
              delta: DeltaContent(role: 'assistant', content: 'World!'),
            ),
          ],
        ),
      ]);

      final text = await stream.text;
      expect(text, 'Hello World!');
    });

    test('allToolCalls collects tool calls from stream', () async {
      final stream = Stream.fromIterable([
        const ChatCompletionStreamResponse(
          id: 'chat-1',
          object: 'chat.completion.chunk',
          model: 'mistral-small-latest',
          created: 1703980800,
          choices: [
            ChatChoiceDelta(
              index: 0,
              delta: DeltaContent(
                role: 'assistant',
                toolCalls: [
                  ToolCall(
                    id: 'call-1',
                    type: 'function',
                    function: FunctionCall(name: 'fn1', arguments: '{}'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const ChatCompletionStreamResponse(
          id: 'chat-1',
          object: 'chat.completion.chunk',
          model: 'mistral-small-latest',
          created: 1703980800,
          choices: [
            ChatChoiceDelta(
              index: 0,
              delta: DeltaContent(
                role: 'assistant',
                toolCalls: [
                  ToolCall(
                    id: 'call-2',
                    type: 'function',
                    function: FunctionCall(name: 'fn2', arguments: '{}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ]);

      final toolCalls = await stream.allToolCalls;
      expect(toolCalls, hasLength(2));
      expect(toolCalls[0].function.name, 'fn1');
      expect(toolCalls[1].function.name, 'fn2');
    });
  });
}
