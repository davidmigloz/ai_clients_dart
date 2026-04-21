import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ChatCompletion', () {
    test('fromJson parses response correctly', () {
      final json = {
        'id': 'chatcmpl-123',
        'object': 'chat.completion',
        'created': 1677652288,
        'model': 'gpt-4o',
        'choices': [
          {
            'index': 0,
            'message': {
              'role': 'assistant',
              'content': 'Hello! How can I help you today?',
            },
            'finish_reason': 'stop',
          },
        ],
        'usage': {
          'prompt_tokens': 9,
          'completion_tokens': 12,
          'total_tokens': 21,
        },
        'system_fingerprint': 'fp_123',
      };

      final completion = ChatCompletion.fromJson(json);

      expect(completion.id, 'chatcmpl-123');
      expect(completion.object, 'chat.completion');
      expect(completion.created, 1677652288);
      expect(completion.model, 'gpt-4o');
      expect(completion.choices.length, 1);
      expect(
        completion.choices.first.message.content,
        'Hello! How can I help you today?',
      );
      expect(completion.choices.first.finishReason, FinishReason.stop);
      expect(completion.usage?.promptTokens, 9);
      expect(completion.usage?.completionTokens, 12);
      expect(completion.usage?.totalTokens, 21);
      expect(completion.systemFingerprint, 'fp_123');
    });

    test('text getter returns first choice content', () {
      final json = {
        'id': 'chatcmpl-123',
        'object': 'chat.completion',
        'created': 1677652288,
        'model': 'gpt-4o',
        'choices': [
          {
            'index': 0,
            'message': {'role': 'assistant', 'content': 'The answer is 42.'},
            'finish_reason': 'stop',
          },
        ],
        'usage': {
          'prompt_tokens': 9,
          'completion_tokens': 5,
          'total_tokens': 14,
        },
      };

      final completion = ChatCompletion.fromJson(json);
      expect(completion.text, 'The answer is 42.');
    });

    test('handles tool calls correctly', () {
      final json = {
        'id': 'chatcmpl-123',
        'object': 'chat.completion',
        'created': 1677652288,
        'model': 'gpt-4o',
        'choices': [
          {
            'index': 0,
            'message': {
              'role': 'assistant',
              'content': null,
              'tool_calls': [
                {
                  'id': 'call_abc123',
                  'type': 'function',
                  'function': {
                    'name': 'get_weather',
                    'arguments': '{"location":"Boston","unit":"celsius"}',
                  },
                },
              ],
            },
            'finish_reason': 'tool_calls',
          },
        ],
        'usage': {
          'prompt_tokens': 20,
          'completion_tokens': 15,
          'total_tokens': 35,
        },
      };

      final completion = ChatCompletion.fromJson(json);

      expect(completion.choices.first.finishReason, FinishReason.toolCalls);
      expect(completion.choices.first.message.toolCalls, isNotNull);
      expect(completion.choices.first.message.toolCalls!.length, 1);

      final toolCall = completion.choices.first.message.toolCalls!.first;
      expect(toolCall.id, 'call_abc123');
      expect(toolCall.type, 'function');
      expect(toolCall.function.name, 'get_weather');
      expect(
        toolCall.function.arguments,
        '{"location":"Boston","unit":"celsius"}',
      );
    });

    test('toJson produces valid output', () {
      const completion = ChatCompletion(
        id: 'chatcmpl-123',
        object: 'chat.completion',
        created: 1677652288,
        model: 'gpt-4o',
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(content: 'Hello!'),
            finishReason: FinishReason.stop,
          ),
        ],
        usage: Usage(promptTokens: 5, completionTokens: 3, totalTokens: 8),
      );

      final json = completion.toJson();

      expect(json['id'], 'chatcmpl-123');
      expect(json['model'], 'gpt-4o');
      expect(json['choices'], isA<List<dynamic>>());
      expect(json['usage'], isA<Map<String, dynamic>>());
    });
  });

  group('ToolCall', () {
    test('functionCall() factory sets type to function', () {
      const call = FunctionCall(
        name: 'get_weather',
        arguments: '{"location":"Boston"}',
      );
      final toolCall = ToolCall.functionCall(id: 'call_123', call: call);

      expect(toolCall.id, equals('call_123'));
      expect(toolCall.type, equals('function'));
      expect(toolCall.function.name, equals('get_weather'));

      final json = toolCall.toJson();
      expect(json['type'], equals('function'));
    });

    test('functionCall() factory with FunctionCall.fromMap', () {
      final call = FunctionCall.fromMap(
        name: 'get_weather',
        arguments: const {'location': 'Boston', 'unit': 'celsius'},
      );
      final toolCall = ToolCall.functionCall(id: 'call_123', call: call);

      expect(toolCall.function.argumentsMap['location'], equals('Boston'));
      expect(toolCall.function.argumentsMap['unit'], equals('celsius'));
    });
  });

  group('FunctionCall', () {
    test('argumentsMap parses JSON arguments', () {
      const call = FunctionCall(
        name: 'get_weather',
        arguments: '{"location":"Boston","unit":"celsius"}',
      );

      final argsMap = call.argumentsMap;

      expect(argsMap['location'], equals('Boston'));
      expect(argsMap['unit'], equals('celsius'));
    });

    test('argumentsMap throws on invalid JSON', () {
      const call = FunctionCall(name: 'test', arguments: 'not valid json');

      expect(() => call.argumentsMap, throwsFormatException);
    });

    test('argumentsMap throws on non-object JSON', () {
      const call = FunctionCall(name: 'test', arguments: '[]');

      expect(() => call.argumentsMap, throwsFormatException);
    });

    test('fromMap encodes arguments as JSON', () {
      final call = FunctionCall.fromMap(
        name: 'get_weather',
        arguments: const {'location': 'Boston', 'unit': 'celsius'},
      );

      expect(call.name, equals('get_weather'));
      expect(call.arguments, equals('{"location":"Boston","unit":"celsius"}'));
    });

    test('fromMap round-trip with argumentsMap', () {
      final original = {'location': 'Boston', 'count': 5};
      final call = FunctionCall.fromMap(name: 'test', arguments: original);

      expect(call.argumentsMap, equals(original));
    });
  });

  group('ChatMessage', () {
    test('system message creates correctly', () {
      final message = ChatMessage.system('You are a helpful assistant.');

      expect(message, isA<SystemMessage>());
      expect(message.role, 'system');
      expect(
        (message as SystemMessage).content,
        'You are a helpful assistant.',
      );
    });

    test('user message creates correctly', () {
      final message = ChatMessage.user('Hello!');

      expect(message, isA<UserMessage>());
      expect(message.role, 'user');
    });

    test('assistant message creates correctly', () {
      final message = ChatMessage.assistant(content: 'Hi there!');

      expect(message, isA<AssistantMessage>());
      expect(message.role, 'assistant');
      expect((message as AssistantMessage).content, 'Hi there!');
    });

    test('tool message creates correctly', () {
      final message = ChatMessage.tool(
        toolCallId: 'call_123',
        content: '{"result": 42}',
      );

      expect(message, isA<ToolMessage>());
      expect(message.role, 'tool');
      expect((message as ToolMessage).toolCallId, 'call_123');
      expect(message.content, '{"result": 42}');
    });

    test('fromJson parses different message types', () {
      final systemJson = {'role': 'system', 'content': 'Be helpful'};
      final userJson = {'role': 'user', 'content': 'Hello'};
      final assistantJson = {'role': 'assistant', 'content': 'Hi'};
      final toolJson = {
        'role': 'tool',
        'tool_call_id': 'call_123',
        'content': 'result',
      };

      expect(ChatMessage.fromJson(systemJson), isA<SystemMessage>());
      expect(ChatMessage.fromJson(userJson), isA<UserMessage>());
      expect(ChatMessage.fromJson(assistantJson), isA<AssistantMessage>());
      expect(ChatMessage.fromJson(toolJson), isA<ToolMessage>());
    });
  });

  group('ChatCompletionCreateRequest', () {
    test('creates minimal request', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
      );

      expect(request.model, 'gpt-4o');
      expect(request.messages.length, 1);
    });

    test('toJson excludes null values', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
      );

      final json = request.toJson();

      expect(json['model'], 'gpt-4o');
      expect(json['messages'], isA<List<dynamic>>());
      expect(json.containsKey('temperature'), false);
      expect(json.containsKey('max_tokens'), false);
    });

    test('toJson includes all specified parameters', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
        temperature: 0.7,
        maxTokens: 100,
        topP: 0.9,
        n: 2,
        stop: const ['END'],
        presencePenalty: 0.5,
        frequencyPenalty: 0.5,
        user: 'user-123',
      );

      final json = request.toJson();

      expect(json['temperature'], 0.7);
      expect(json['max_tokens'], 100);
      expect(json['top_p'], 0.9);
      expect(json['n'], 2);
      expect(json['stop'], ['END']);
      expect(json['presence_penalty'], 0.5);
      expect(json['frequency_penalty'], 0.5);
      expect(json['user'], 'user-123');
    });

    test('supports reasoning_effort for reasoning models', () {
      final request = ChatCompletionCreateRequest(
        model: 'o3',
        messages: [ChatMessage.user('Solve this problem...')],
        reasoningEffort: ReasoningEffort.high,
      );

      final json = request.toJson();

      expect(json['reasoning_effort'], 'high');
      expect(request.reasoningEffort, ReasoningEffort.high);
    });

    test('supports prediction for faster responses', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Update this code...')],
        prediction: const Prediction.content('predicted output here'),
      );

      final json = request.toJson();

      expect(json['prediction'], {
        'type': 'content',
        'content': 'predicted output here',
      });
    });

    test('supports modalities for audio output', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-audio-1.5',
        messages: [ChatMessage.user('Tell me a story.')],
        modalities: const [ChatModality.text, ChatModality.audio],
        audio: const ChatAudioConfig(
          voice: ChatAudioVoice.alloy,
          format: ChatAudioFormat.mp3,
        ),
      );

      final json = request.toJson();

      expect(json['modalities'], ['text', 'audio']);
      expect(json['audio'], {'voice': 'alloy', 'format': 'mp3'});
    });

    test('fromJson parses new parameters correctly', () {
      final json = {
        'model': 'o3',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'reasoning_effort': 'medium',
        'prediction': {'type': 'content', 'content': 'predicted text'},
        'modalities': ['text', 'audio'],
        'audio': {'voice': 'shimmer', 'format': 'wav'},
      };

      final request = ChatCompletionCreateRequest.fromJson(json);

      expect(request.reasoningEffort, ReasoningEffort.medium);
      expect(request.prediction, isA<Prediction>());
      expect(request.modalities, [ChatModality.text, ChatModality.audio]);
      expect(request.audio?.voice, ChatAudioVoice.shimmer);
      expect(request.audio?.format, ChatAudioFormat.wav);
    });

    test('copyWith works with new parameters', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
      );

      final updated = request.copyWith(
        reasoningEffort: ReasoningEffort.low,
        modalities: const [ChatModality.text],
      );

      expect(updated.reasoningEffort, ReasoningEffort.low);
      expect(updated.modalities, [ChatModality.text]);
      expect(updated.model, 'gpt-4o'); // unchanged
    });

    test('supports verbosity parameter', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Explain quantum physics.')],
        verbosity: Verbosity.low,
      );

      final json = request.toJson();
      expect(json['verbosity'], 'low');
      expect(request.verbosity, Verbosity.low);
    });

    test('fromJson parses verbosity', () {
      final json = {
        'model': 'gpt-4o',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'verbosity': 'high',
      };

      final request = ChatCompletionCreateRequest.fromJson(json);
      expect(request.verbosity, Verbosity.high);
    });

    test('copyWith works with verbosity', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
      );

      final updated = request.copyWith(verbosity: Verbosity.medium);
      expect(updated.verbosity, Verbosity.medium);
      expect(updated.model, 'gpt-4o'); // unchanged
    });

    test('verbosity omitted from JSON when null', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
      );

      final json = request.toJson();
      expect(json.containsKey('verbosity'), isFalse);
    });

    test('metadata omitted when all values are null', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
        metadata: const {'key1': null, 'key2': null},
      );
      final json = request.toJson();
      expect(json.containsKey('metadata'), isFalse);
    });

    test('metadata accepts Map<String, dynamic>', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
        metadata: const {'key': 'value', 'count': 42, 'flag': true},
      );

      final json = request.toJson();
      final metadata = json['metadata'] as Map<String, dynamic>;

      // All values are stringified in JSON output
      expect(metadata['key'], equals('value'));
      expect(metadata['count'], equals('42'));
      expect(metadata['flag'], equals('true'));
    });

    test('metadata round-trip preserves string values', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
        metadata: const {'key': 'value'},
      );

      final json = request.toJson();
      final restored = ChatCompletionCreateRequest.fromJson(json);

      expect(restored.metadata, equals({'key': 'value'}));
    });

    test('supports web_search_options parameter', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Search the web for latest news.')],
        webSearchOptions: const WebSearchOptions(
          searchContextSize: 'medium',
          userLocation: WebSearchUserLocation(
            approximate: WebSearchLocation(
              country: 'US',
              region: 'California',
              city: 'San Francisco',
              timezone: 'America/Los_Angeles',
            ),
          ),
        ),
      );

      final json = request.toJson();
      expect(json['web_search_options'], {
        'search_context_size': 'medium',
        'user_location': {
          'type': 'approximate',
          'approximate': {
            'country': 'US',
            'region': 'California',
            'city': 'San Francisco',
            'timezone': 'America/Los_Angeles',
          },
        },
      });
    });

    test('fromJson parses web_search_options', () {
      final json = {
        'model': 'gpt-4o',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'web_search_options': {
          'search_context_size': 'high',
          'user_location': {
            'type': 'approximate',
            'approximate': {'country': 'GB', 'city': 'London'},
          },
        },
      };

      final request = ChatCompletionCreateRequest.fromJson(json);
      expect(request.webSearchOptions, isNotNull);
      expect(request.webSearchOptions!.searchContextSize, 'high');
      expect(request.webSearchOptions!.userLocation!.approximate.country, 'GB');
      expect(
        request.webSearchOptions!.userLocation!.approximate.city,
        'London',
      );
    });

    test('supports prompt_cache_key parameter', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
        promptCacheKey: 'cache-key-123',
      );

      final json = request.toJson();
      expect(json['prompt_cache_key'], 'cache-key-123');
    });

    test('fromJson parses prompt_cache_key', () {
      final json = {
        'model': 'gpt-4o',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'prompt_cache_key': 'my-key',
      };

      final request = ChatCompletionCreateRequest.fromJson(json);
      expect(request.promptCacheKey, 'my-key');
    });

    test('supports prompt_cache_retention parameter', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
        promptCacheRetention: PromptCacheRetention.h24,
      );

      final json = request.toJson();
      expect(json['prompt_cache_retention'], '24h');
    });

    test('fromJson parses prompt_cache_retention', () {
      final json = {
        'model': 'gpt-4o',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'prompt_cache_retention': 'in-memory',
      };

      final request = ChatCompletionCreateRequest.fromJson(json);
      expect(request.promptCacheRetention, PromptCacheRetention.inMemory);
    });

    test('supports safety_identifier parameter', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
        safetyIdentifier: 'user-hash-abc123',
      );

      final json = request.toJson();
      expect(json['safety_identifier'], 'user-hash-abc123');
    });

    test('fromJson parses safety_identifier', () {
      final json = {
        'model': 'gpt-4o',
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'safety_identifier': 'user-hash-xyz',
      };

      final request = ChatCompletionCreateRequest.fromJson(json);
      expect(request.safetyIdentifier, 'user-hash-xyz');
    });

    test('copyWith works with new fields', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
      );

      final updated = request.copyWith(
        webSearchOptions: const WebSearchOptions(searchContextSize: 'low'),
        promptCacheKey: 'key-1',
        promptCacheRetention: PromptCacheRetention.h24,
        safetyIdentifier: 'safety-1',
      );

      expect(updated.webSearchOptions!.searchContextSize, 'low');
      expect(updated.promptCacheKey, 'key-1');
      expect(updated.promptCacheRetention, PromptCacheRetention.h24);
      expect(updated.safetyIdentifier, 'safety-1');
      expect(updated.model, 'gpt-4o'); // unchanged
    });

    test('new fields omitted from JSON when null', () {
      final request = ChatCompletionCreateRequest(
        model: 'gpt-4o',
        messages: [ChatMessage.user('Hello!')],
      );

      final json = request.toJson();
      expect(json.containsKey('web_search_options'), isFalse);
      expect(json.containsKey('prompt_cache_key'), isFalse);
      expect(json.containsKey('prompt_cache_retention'), isFalse);
      expect(json.containsKey('safety_identifier'), isFalse);
    });
  });

  group('WebSearchOptions', () {
    test('toJson produces correct nested structure', () {
      const options = WebSearchOptions(
        searchContextSize: 'medium',
        userLocation: WebSearchUserLocation(
          approximate: WebSearchLocation(country: 'US', region: 'California'),
        ),
      );

      final json = options.toJson();
      expect(json, {
        'search_context_size': 'medium',
        'user_location': {
          'type': 'approximate',
          'approximate': {'country': 'US', 'region': 'California'},
        },
      });
    });

    test('fromJson parses correctly', () {
      final json = {
        'search_context_size': 'high',
        'user_location': {
          'type': 'approximate',
          'approximate': {
            'country': 'GB',
            'city': 'London',
            'timezone': 'Europe/London',
          },
        },
      };

      final options = WebSearchOptions.fromJson(json);
      expect(options.searchContextSize, 'high');
      expect(options.userLocation, isNotNull);
      expect(options.userLocation!.approximate.country, 'GB');
      expect(options.userLocation!.approximate.city, 'London');
      expect(options.userLocation!.approximate.timezone, 'Europe/London');
    });

    test('toJson omits null fields', () {
      const options = WebSearchOptions();
      final json = options.toJson();
      expect(json, isEmpty);
    });

    test('round-trip preserves data', () {
      const original = WebSearchOptions(
        searchContextSize: 'low',
        userLocation: WebSearchUserLocation(
          approximate: WebSearchLocation(country: 'DE'),
        ),
      );

      final restored = WebSearchOptions.fromJson(original.toJson());
      expect(restored, original);
    });
  });

  group('FinishReason', () {
    test('parses all valid values', () {
      expect(FinishReason.fromJson('stop'), FinishReason.stop);
      expect(FinishReason.fromJson('length'), FinishReason.length);
      expect(FinishReason.fromJson('tool_calls'), FinishReason.toolCalls);
      expect(
        FinishReason.fromJson('content_filter'),
        FinishReason.contentFilter,
      );
      expect(FinishReason.fromJson('function_call'), FinishReason.functionCall);
    });

    test('toJson returns correct values', () {
      expect(FinishReason.stop.toJson(), 'stop');
      expect(FinishReason.length.toJson(), 'length');
      expect(FinishReason.toolCalls.toJson(), 'tool_calls');
      expect(FinishReason.contentFilter.toJson(), 'content_filter');
    });
  });

  group('Verbosity', () {
    test('has correct values matching spec', () {
      expect(Verbosity.low.toJson(), 'low');
      expect(Verbosity.medium.toJson(), 'medium');
      expect(Verbosity.high.toJson(), 'high');
    });

    test('fromJson parses all valid values', () {
      expect(Verbosity.fromJson('low'), Verbosity.low);
      expect(Verbosity.fromJson('medium'), Verbosity.medium);
      expect(Verbosity.fromJson('high'), Verbosity.high);
    });

    test('fromJson returns unknown for unrecognized values', () {
      expect(Verbosity.fromJson('something_else'), Verbosity.unknown);
    });
  });

  group('ReasoningEffort', () {
    test('has correct values matching spec', () {
      expect(ReasoningEffort.none.toJson(), 'none');
      expect(ReasoningEffort.minimal.toJson(), 'minimal');
      expect(ReasoningEffort.low.toJson(), 'low');
      expect(ReasoningEffort.medium.toJson(), 'medium');
      expect(ReasoningEffort.high.toJson(), 'high');
      expect(ReasoningEffort.xhigh.toJson(), 'xhigh');
    });

    test('fromJson parses all valid values', () {
      expect(ReasoningEffort.fromJson('none'), ReasoningEffort.none);
      expect(ReasoningEffort.fromJson('minimal'), ReasoningEffort.minimal);
      expect(ReasoningEffort.fromJson('low'), ReasoningEffort.low);
      expect(ReasoningEffort.fromJson('medium'), ReasoningEffort.medium);
      expect(ReasoningEffort.fromJson('high'), ReasoningEffort.high);
      expect(ReasoningEffort.fromJson('xhigh'), ReasoningEffort.xhigh);
    });

    test('fromJson returns unknown for unrecognized values', () {
      expect(
        ReasoningEffort.fromJson('something_else'),
        ReasoningEffort.unknown,
      );
    });
  });

  // OpenAI-Compatible APIs Tests
  group('OpenAI-Compatible APIs', () {
    group('ChatCompletion nullable fields', () {
      test('handles missing id (OpenRouter compatibility)', () {
        final json = {
          // No 'id' field
          'object': 'chat.completion',
          'created': 1677652288,
          'model': 'openai/gpt-4o',
          'choices': [
            {
              'index': 0,
              'message': {'role': 'assistant', 'content': 'Hello!'},
              'finish_reason': 'stop',
            },
          ],
        };

        final completion = ChatCompletion.fromJson(json);

        expect(completion.id, isNull);
        expect(completion.model, 'openai/gpt-4o');
        expect(completion.text, 'Hello!');
      });

      test('handles provider field (OpenRouter)', () {
        final json = {
          'id': 'chatcmpl-123',
          'object': 'chat.completion',
          'created': 1677652288,
          'model': 'openai/gpt-4o',
          'provider': 'OpenAI',
          'choices': [
            {
              'message': {'role': 'assistant', 'content': 'Hello!'},
              'finish_reason': 'stop',
            },
          ],
        };

        final completion = ChatCompletion.fromJson(json);

        expect(completion.provider, 'OpenAI');
      });

      test(
        'handles different object values (Anyscale sends text_completion)',
        () {
          final json = {
            'id': 'chatcmpl-123',
            'object': 'text_completion', // Different from 'chat.completion'
            'created': 1677652288,
            'model': 'meta-llama/Llama-2-70b',
            'choices': [
              {
                'index': 0,
                'message': {'role': 'assistant', 'content': 'Hello!'},
                'finish_reason': 'stop',
              },
            ],
          };

          final completion = ChatCompletion.fromJson(json);

          expect(completion.object, 'text_completion');
        },
      );
    });

    group('ChatCompletion nullable created', () {
      test('handles missing created (provider compatibility)', () {
        final json = {
          'id': 'chatcmpl-123',
          'object': 'chat.completion',
          // No 'created' field
          'model': 'command-r-plus',
          'choices': [
            {
              'index': 0,
              'message': {'role': 'assistant', 'content': 'Hello!'},
              'finish_reason': 'stop',
            },
          ],
        };

        final completion = ChatCompletion.fromJson(json);

        expect(completion.created, isNull);
        expect(completion.createdAt, isNull);
        expect(completion.model, 'command-r-plus');
        expect(completion.text, 'Hello!');
      });

      test('toJson omits created when null', () {
        const completion = ChatCompletion(
          id: 'chatcmpl-123',
          object: 'chat.completion',
          model: 'gpt-4o',
          choices: [
            ChatChoice(
              index: 0,
              message: AssistantMessage(content: 'Hello!'),
              finishReason: FinishReason.stop,
            ),
          ],
        );

        final json = completion.toJson();

        expect(json.containsKey('created'), isFalse);
      });

      test('createdAt returns DateTime when created is present', () {
        const completion = ChatCompletion(
          object: 'chat.completion',
          created: 1677652288,
          model: 'gpt-4o',
          choices: [],
        );

        expect(completion.createdAt, isA<DateTime>());
      });
    });

    group('ChatChoice nullable index', () {
      test('handles missing index (OpenRouter compatibility)', () {
        final json = {
          'id': 'chatcmpl-123',
          'object': 'chat.completion',
          'created': 1677652288,
          'model': 'gpt-4o',
          'choices': [
            {
              // No 'index' field
              'message': {'role': 'assistant', 'content': 'Hello!'},
              'finish_reason': 'stop',
            },
          ],
        };

        final completion = ChatCompletion.fromJson(json);

        expect(completion.choices.first.index, isNull);
        expect(completion.choices.first.message.content, 'Hello!');
      });
    });

    group('AssistantMessage reasoning fields', () {
      test('parses reasoning_content (DeepSeek R1)', () {
        final json = {
          'role': 'assistant',
          'content': 'The answer is 42.',
          'reasoning_content': 'Let me think about this...',
        };

        final message = AssistantMessage.fromJson(json);

        expect(message.content, 'The answer is 42.');
        expect(message.reasoningContent, 'Let me think about this...');
        expect(message.hasReasoningContent, true);
      });

      test('parses reasoning (OpenRouter)', () {
        final json = {
          'role': 'assistant',
          'content': 'The answer is 42.',
          'reasoning': 'Quick summary of reasoning...',
        };

        final message = AssistantMessage.fromJson(json);

        expect(message.reasoning, 'Quick summary of reasoning...');
        expect(message.hasReasoningContent, true);
      });

      test('parses reasoning_details (OpenRouter)', () {
        final json = {
          'role': 'assistant',
          'content': 'The answer is 42.',
          'reasoning_details': [
            {'type': 'reasoning.summary', 'text': 'I analyzed the question.'},
            {'type': 'reasoning.encrypted', 'data': 'YmFzZTY0ZGF0YQ=='},
          ],
        };

        final message = AssistantMessage.fromJson(json);

        expect(message.reasoningDetails, isNotNull);
        expect(message.reasoningDetails!.length, 2);
        expect(message.reasoningDetails!.first.type, 'reasoning.summary');
        expect(
          message.reasoningDetails!.first.text,
          'I analyzed the question.',
        );
        expect(message.reasoningDetails!.last.type, 'reasoning.encrypted');
        expect(message.hasReasoningContent, true);
      });

      test('toApiJson excludes reasoning fields', () {
        const message = AssistantMessage(
          content: 'The answer is 42.',
          reasoningContent: 'Let me think...',
          reasoning: 'Summary...',
        );

        final apiJson = message.toApiJson();

        expect(apiJson['content'], 'The answer is 42.');
        expect(apiJson.containsKey('reasoning_content'), false);
        expect(apiJson.containsKey('reasoning'), false);
        expect(apiJson.containsKey('reasoning_details'), false);
      });

      test('toJson includes reasoning fields', () {
        const message = AssistantMessage(
          content: 'The answer is 42.',
          reasoningContent: 'Let me think...',
        );

        final json = message.toJson();

        expect(json['content'], 'The answer is 42.');
        expect(json['reasoning_content'], 'Let me think...');
      });
    });

    group('OpenRouter request parameters', () {
      test('serializes sampling parameters', () {
        final request = ChatCompletionCreateRequest(
          model: 'openai/gpt-4o',
          messages: [ChatMessage.user('Hello!')],
          topK: 40,
          minP: 0.1,
          topA: 0.5,
          repetitionPenalty: 1.2,
        );

        final json = request.toJson();

        expect(json['top_k'], 40);
        expect(json['min_p'], 0.1);
        expect(json['top_a'], 0.5);
        expect(json['repetition_penalty'], 1.2);
      });

      test('serializes routing parameters', () {
        final request = ChatCompletionCreateRequest(
          model: 'openai/gpt-4o',
          messages: [ChatMessage.user('Hello!')],
          openRouterProvider: const OpenRouterProviderPreferences(
            order: ['OpenAI', 'Azure'],
            allowFallbacks: true,
          ),
          models: const ['openai/gpt-4o', 'anthropic/claude-3'],
          route: 'fallback',
          transforms: const ['middle-out'],
        );

        final json = request.toJson();

        expect(json['provider'], isA<Map<String, dynamic>>());
        expect((json['provider'] as Map)['order'], ['OpenAI', 'Azure']);
        expect(json['models'], ['openai/gpt-4o', 'anthropic/claude-3']);
        expect(json['route'], 'fallback');
        expect(json['transforms'], ['middle-out']);
      });

      test('serializes config parameters', () {
        final request = ChatCompletionCreateRequest(
          model: 'deepseek/deepseek-r1',
          messages: [ChatMessage.user('Hello!')],
          openRouterUsage: const OpenRouterUsageConfig(include: true),
          openRouterReasoning: const OpenRouterReasoning(
            effort: 'high',
            maxTokens: 8000,
          ),
        );

        final json = request.toJson();

        expect(json['usage'], {'include': true});
        expect(json['reasoning'], {'effort': 'high', 'max_tokens': 8000});
      });

      test('fromJson parses OpenRouter parameters', () {
        final json = {
          'model': 'openai/gpt-4o',
          'messages': [
            {'role': 'user', 'content': 'Hello'},
          ],
          'top_k': 40,
          'min_p': 0.1,
          'provider': {
            'order': ['OpenAI'],
          },
          'models': ['openai/gpt-4o'],
          'reasoning': {'effort': 'medium'},
        };

        final request = ChatCompletionCreateRequest.fromJson(json);

        expect(request.topK, 40);
        expect(request.minP, 0.1);
        expect(request.openRouterProvider?.order, ['OpenAI']);
        expect(request.models, ['openai/gpt-4o']);
        expect(request.openRouterReasoning?.effort, 'medium');
      });

      test('copyWith works with OpenRouter parameters', () {
        final request = ChatCompletionCreateRequest(
          model: 'gpt-4o',
          messages: [ChatMessage.user('Hello!')],
        );

        final updated = request.copyWith(
          topK: 50,
          openRouterProvider: const OpenRouterProviderPreferences(
            order: ['Azure'],
          ),
        );

        expect(updated.topK, 50);
        expect(updated.openRouterProvider?.order, ['Azure']);
        expect(updated.model, 'gpt-4o'); // unchanged
      });
    });

    group('Usage nullable completionTokens', () {
      test('handles missing completion_tokens', () {
        final json = {
          'prompt_tokens': 10,
          'total_tokens': 10,
          // No 'completion_tokens'
        };

        final usage = Usage.fromJson(json);

        expect(usage.promptTokens, 10);
        expect(usage.completionTokens, isNull);
        expect(usage.totalTokens, 10);
      });
    });

    group('ChatCompletion missing fields (third-party proxies)', () {
      test('handles missing object field — defaults to chat.completion', () {
        final json = {
          'id': 'chatcmpl-123',
          'created': 1677652288,
          'model': 'gpt-4o',
          'choices': <dynamic>[
            {
              'index': 0,
              'message': {'role': 'assistant', 'content': 'Hello!'},
              'finish_reason': 'stop',
            },
          ],
        };

        final completion = ChatCompletion.fromJson(json);
        expect(completion.object, 'chat.completion');
      });

      test('handles missing model field — defaults to empty string', () {
        final json = {
          'id': 'chatcmpl-123',
          'object': 'chat.completion',
          'created': 1677652288,
          'choices': <dynamic>[
            {
              'index': 0,
              'message': {'role': 'assistant', 'content': 'Hello!'},
              'finish_reason': 'stop',
            },
          ],
        };

        final completion = ChatCompletion.fromJson(json);
        expect(completion.model, '');
      });

      test('handles missing choices field — defaults to empty list', () {
        final json = {
          'id': 'chatcmpl-123',
          'object': 'chat.completion',
          'created': 1677652288,
          'model': 'gpt-4o',
        };

        final completion = ChatCompletion.fromJson(json);
        expect(completion.choices, isEmpty);
        expect(completion.text, isNull);
      });
    });

    group('FunctionCall.arguments formats (third-party providers)', () {
      test('handles arguments as Map — jsonEncodes it', () {
        final json = {
          'name': 'get_weather',
          'arguments': {'location': 'Boston', 'unit': 'celsius'},
        };

        final call = FunctionCall.fromJson(json);
        expect(call.arguments, '{"location":"Boston","unit":"celsius"}');
        expect(call.argumentsMap['location'], 'Boston');
      });

      test('handles arguments as null — defaults to empty JSON object', () {
        final json = {'name': 'do_something', 'arguments': null};

        final call = FunctionCall.fromJson(json);
        expect(call.arguments, '{}');
      });

      test('handles arguments as String — passes through', () {
        final json = {
          'name': 'get_weather',
          'arguments': '{"location":"Boston"}',
        };

        final call = FunctionCall.fromJson(json);
        expect(call.arguments, '{"location":"Boston"}');
      });
    });

    group('ToolCall missing type (third-party providers)', () {
      test('defaults type to function when omitted', () {
        final json = {
          'id': 'call_abc123',
          'function': {
            'name': 'get_weather',
            'arguments': '{"location":"Boston"}',
          },
        };

        final toolCall = ToolCall.fromJson(json);
        expect(toolCall.type, 'function');
      });
    });

    group('FinishReason non-standard values', () {
      test('unknown finish_reason returns FinishReason.unknown', () {
        expect(FinishReason.fromJson('error'), FinishReason.unknown);
        expect(
          FinishReason.fromJson('some_custom_value'),
          FinishReason.unknown,
        );
      });

      test('Bedrock end_turn maps to stop', () {
        expect(FinishReason.fromJson('end_turn'), FinishReason.stop);
      });

      test('Bedrock tool_use maps to toolCalls', () {
        expect(FinishReason.fromJson('tool_use'), FinishReason.toolCalls);
      });

      test('Bedrock max_tokens maps to length', () {
        expect(FinishReason.fromJson('max_tokens'), FinishReason.length);
      });

      test('Bedrock stop_sequence maps to stop', () {
        expect(FinishReason.fromJson('stop_sequence'), FinishReason.stop);
      });

      test('TogetherAI eos maps to stop', () {
        expect(FinishReason.fromJson('eos'), FinishReason.stop);
      });
    });
  });

  group('ContentPart', () {
    group('TextContentPart', () {
      test('text() factory creates TextContentPart', () {
        final part = ContentPart.text('Hello');
        expect(part, isA<TextContentPart>());
        expect((part as TextContentPart).text, 'Hello');
        expect(part.type, 'text');
      });

      test('fromJson/toJson round-trip', () {
        final json = {'type': 'text', 'text': 'Hello'};
        final part = ContentPart.fromJson(json);
        expect(part, isA<TextContentPart>());
        expect(part.toJson(), json);
      });

      test('equality', () {
        expect(
          const TextContentPart(text: 'a'),
          equals(const TextContentPart(text: 'a')),
        );
        expect(
          const TextContentPart(text: 'a'),
          isNot(equals(const TextContentPart(text: 'b'))),
        );
      });
    });

    group('ImageContentPart', () {
      test('imageUrl() factory creates ImageContentPart', () {
        final part = ContentPart.imageUrl('https://example.com/img.jpg');
        expect(part, isA<ImageContentPart>());
        expect((part as ImageContentPart).url, 'https://example.com/img.jpg');
        expect(part.detail, isNull);
        expect(part.type, 'image_url');
      });

      test('imageBase64() factory creates data URL', () {
        final part = ContentPart.imageBase64(
          data: 'abc123',
          mediaType: 'image/png',
        );
        expect(part, isA<ImageContentPart>());
        expect((part as ImageContentPart).url, 'data:image/png;base64,abc123');
      });

      test('fromJson/toJson round-trip with detail', () {
        final json = {
          'type': 'image_url',
          'image_url': {'url': 'https://example.com/img.jpg', 'detail': 'high'},
        };
        final part = ContentPart.fromJson(json);
        expect(part, isA<ImageContentPart>());
        expect((part as ImageContentPart).detail, ImageDetail.high);
        expect(part.toJson(), json);
      });

      test('toJson omits null detail', () {
        final part = ContentPart.imageUrl('https://example.com/img.jpg');
        final json = part.toJson();
        expect(
          (json['image_url'] as Map<String, dynamic>).containsKey('detail'),
          isFalse,
        );
      });
    });

    group('AudioContentPart', () {
      test('inputAudio() factory creates AudioContentPart', () {
        final part = ContentPart.inputAudio(
          data: 'base64data',
          format: AudioFormat.wav,
        );
        expect(part, isA<AudioContentPart>());
        expect((part as AudioContentPart).data, 'base64data');
        expect(part.format, AudioFormat.wav);
        expect(part.type, 'input_audio');
      });

      test('fromJson/toJson round-trip', () {
        final json = {
          'type': 'input_audio',
          'input_audio': {'data': 'base64data', 'format': 'mp3'},
        };
        final part = ContentPart.fromJson(json);
        expect(part, isA<AudioContentPart>());
        expect(part.toJson(), json);
      });
    });

    group('FileContentPart', () {
      test('file() factory creates FileContentPart with fileId', () {
        final part = ContentPart.file(fileId: 'file-123');
        expect(part, isA<FileContentPart>());
        expect((part as FileContentPart).fileId, 'file-123');
        expect(part.fileData, isNull);
        expect(part.filename, isNull);
        expect(part.type, 'file');
      });

      test('file() factory accepts optional filename', () {
        final part = ContentPart.file(fileId: 'file-123', filename: 'doc.pdf');
        expect(part, isA<FileContentPart>());
        expect((part as FileContentPart).fileId, 'file-123');
        expect(part.filename, 'doc.pdf');
      });

      test('fileData() factory creates FileContentPart with data URL', () {
        final part = ContentPart.fileData(
          data: 'base64pdf',
          mediaType: 'application/pdf',
          filename: 'test.pdf',
        );
        expect(part, isA<FileContentPart>());
        expect(
          (part as FileContentPart).fileData,
          'data:application/pdf;base64,base64pdf',
        );
        expect(part.filename, 'test.pdf');
        expect(part.fileId, isNull);
      });

      test('fromJson with all fields', () {
        final json = {
          'type': 'file',
          'file': {
            'file_id': 'file-123',
            'file_data': 'base64data',
            'filename': 'test.pdf',
          },
        };
        final part = ContentPart.fromJson(json);
        expect(part, isA<FileContentPart>());
        final file = part as FileContentPart;
        expect(file.fileId, 'file-123');
        expect(file.fileData, 'base64data');
        expect(file.filename, 'test.pdf');
      });

      test('fromJson with only file_id', () {
        final json = {
          'type': 'file',
          'file': {'file_id': 'file-456'},
        };
        final part = ContentPart.fromJson(json) as FileContentPart;
        expect(part.fileId, 'file-456');
        expect(part.fileData, isNull);
        expect(part.filename, isNull);
      });

      test('fromJson with file_data and filename', () {
        final json = {
          'type': 'file',
          'file': {'file_data': 'base64data', 'filename': 'doc.pdf'},
        };
        final part = ContentPart.fromJson(json) as FileContentPart;
        expect(part.fileId, isNull);
        expect(part.fileData, 'base64data');
        expect(part.filename, 'doc.pdf');
      });

      test('toJson round-trip with all fields', () {
        final json = {
          'type': 'file',
          'file': {
            'file_id': 'file-123',
            'file_data': 'base64data',
            'filename': 'test.pdf',
          },
        };
        final part = ContentPart.fromJson(json);
        expect(part.toJson(), json);
      });

      test('toJson omits null fields', () {
        const part = FileContentPart(fileId: 'file-123');
        final json = part.toJson();
        final file = json['file'] as Map<String, dynamic>;
        expect(file.containsKey('file_id'), isTrue);
        expect(file.containsKey('file_data'), isFalse);
        expect(file.containsKey('filename'), isFalse);
      });

      test('copyWith replaces fields', () {
        const original = FileContentPart(fileId: 'file-1', filename: 'a.pdf');
        final copy = original.copyWith(fileId: 'file-2');
        expect(copy.fileId, 'file-2');
        expect(copy.filename, 'a.pdf'); // unchanged
      });

      test('copyWith sets field to null', () {
        const original = FileContentPart(fileId: 'file-1', filename: 'a.pdf');
        final copy = original.copyWith(filename: null);
        expect(copy.fileId, 'file-1');
        expect(copy.filename, isNull);
      });

      test('equality', () {
        expect(
          const FileContentPart(fileId: 'f1', filename: 'a.pdf'),
          equals(const FileContentPart(fileId: 'f1', filename: 'a.pdf')),
        );
        expect(
          const FileContentPart(fileId: 'f1'),
          isNot(equals(const FileContentPart(fileId: 'f2'))),
        );
      });

      test('hashCode is consistent with equality', () {
        const a = FileContentPart(fileId: 'f1', filename: 'a.pdf');
        const b = FileContentPart(fileId: 'f1', filename: 'a.pdf');
        expect(a.hashCode, b.hashCode);
      });

      test('toString shows hasFileData indicator', () {
        const part = FileContentPart(
          fileId: 'file-1',
          fileData: 'long-base64',
          filename: 'doc.pdf',
        );
        final str = part.toString();
        expect(str, contains('file-1'));
        expect(str, contains('doc.pdf'));
        expect(str, contains('hasFileData: true'));
        expect(str, isNot(contains('long-base64')));
      });

      test('toString shows hasFileData false when null', () {
        const part = FileContentPart(fileId: 'file-1');
        expect(part.toString(), contains('hasFileData: false'));
      });
    });

    group('RefusalContentPart', () {
      test('refusal() factory creates RefusalContentPart', () {
        final part = ContentPart.refusal('I cannot help with that');
        expect(part, isA<RefusalContentPart>());
        expect((part as RefusalContentPart).refusal, 'I cannot help with that');
        expect(part.type, 'refusal');
      });

      test('fromJson/toJson round-trip', () {
        final json = {'type': 'refusal', 'refusal': 'Declined'};
        final part = ContentPart.fromJson(json);
        expect(part, isA<RefusalContentPart>());
        expect(part.toJson(), json);
      });

      test('copyWith', () {
        const original = RefusalContentPart(refusal: 'a');
        final copy = original.copyWith(refusal: 'b');
        expect(copy.refusal, 'b');
      });

      test('equality', () {
        expect(
          const RefusalContentPart(refusal: 'a'),
          equals(const RefusalContentPart(refusal: 'a')),
        );
        expect(
          const RefusalContentPart(refusal: 'a'),
          isNot(equals(const RefusalContentPart(refusal: 'b'))),
        );
      });
    });

    group('fromJson dispatch', () {
      test('routes text', () {
        expect(
          ContentPart.fromJson(const {'type': 'text', 'text': 'hi'}),
          isA<TextContentPart>(),
        );
      });

      test('routes image_url', () {
        expect(
          ContentPart.fromJson(const {
            'type': 'image_url',
            'image_url': {'url': 'https://x.com/img.jpg'},
          }),
          isA<ImageContentPart>(),
        );
      });

      test('routes input_audio', () {
        expect(
          ContentPart.fromJson(const {
            'type': 'input_audio',
            'input_audio': {'data': 'd', 'format': 'wav'},
          }),
          isA<AudioContentPart>(),
        );
      });

      test('routes file', () {
        expect(
          ContentPart.fromJson(const {
            'type': 'file',
            'file': {'file_id': 'f1'},
          }),
          isA<FileContentPart>(),
        );
      });

      test('routes refusal', () {
        expect(
          ContentPart.fromJson(const {'type': 'refusal', 'refusal': 'no'}),
          isA<RefusalContentPart>(),
        );
      });

      test('throws on unknown type', () {
        expect(
          () => ContentPart.fromJson(const {'type': 'unknown'}),
          throwsFormatException,
        );
      });
    });

    group('ImageDetail', () {
      test('fromJson/toJson round-trip', () {
        for (final detail in ImageDetail.values) {
          expect(ImageDetail.fromJson(detail.toJson()), detail);
        }
      });

      test('throws on unknown value', () {
        expect(() => ImageDetail.fromJson('unknown'), throwsFormatException);
      });
    });

    group('AudioFormat', () {
      test('fromJson/toJson round-trip', () {
        for (final format in AudioFormat.values) {
          expect(AudioFormat.fromJson(format.toJson()), format);
        }
      });

      test('throws on unknown value', () {
        expect(() => AudioFormat.fromJson('unknown'), throwsFormatException);
      });
    });
  });
}
