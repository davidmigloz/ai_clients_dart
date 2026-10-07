import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

typedef _ChangeRequest =
    ChatCompletionCreateRequest Function(ChatCompletionCreateRequest);

void main() {
  group('ChatCompletionCreateRequest value equality', () {
    final changes = <String, _ChangeRequest>{
      'model': (r) => r.copyWith(model: 'other-model'),
      'messages': (r) =>
          r.copyWith(messages: [ChatMessage.user('Other input')]),
      'frequencyPenalty': (r) => r.copyWith(frequencyPenalty: 0.8),
      'logitBias': (r) => r.copyWith(logitBias: <String, int>{'1': 99}),
      'logprobs': (r) => r.copyWith(logprobs: false),
      'topLogprobs': (r) => r.copyWith(topLogprobs: 5),
      'maxTokens': (r) => r.copyWith(maxTokens: 300),
      'maxCompletionTokens': (r) => r.copyWith(maxCompletionTokens: 400),
      'n': (r) => r.copyWith(n: 3),
      'presencePenalty': (r) => r.copyWith(presencePenalty: 0.9),
      'responseFormat': (r) =>
          r.copyWith(responseFormat: ResponseFormat.text()),
      'seed': (r) => r.copyWith(seed: 12),
      'serviceTier': (r) => r.copyWith(serviceTier: 'flex'),
      'stop': (r) => r.copyWith(stop: <String>['OTHER']),
      'temperature': (r) => r.copyWith(temperature: 0.9),
      'topP': (r) => r.copyWith(topP: 0.4),
      'tools': (r) => r.copyWith(tools: [Tool.function(name: 'other_tool')]),
      'toolChoice': (r) => r.copyWith(toolChoice: ToolChoice.none()),
      'parallelToolCalls': (r) => r.copyWith(parallelToolCalls: false),
      'user': (r) => r.copyWith(user: 'other-user'),
      'metadata': (r) =>
          r.copyWith(metadata: <String, dynamic>{'key': 'other'}),
      'store': (r) => r.copyWith(store: false),
      'streamOptions': (r) =>
          r.copyWith(streamOptions: const StreamOptions(includeUsage: false)),
      'reasoningEffort': (r) =>
          r.copyWith(reasoningEffort: ReasoningEffort.low),
      'verbosity': (r) => r.copyWith(verbosity: Verbosity.low),
      'prediction': (r) =>
          r.copyWith(prediction: const Prediction.content('Other prediction')),
      'modalities': (r) =>
          r.copyWith(modalities: <ChatModality>[ChatModality.text]),
      'audio': (r) => r.copyWith(
        audio: const ChatAudioConfig(
          voice: ChatAudioVoice.echo,
          format: ChatAudioFormat.wav,
        ),
      ),
      'webSearchOptions': (r) => r.copyWith(
        webSearchOptions: const WebSearchOptions(searchContextSize: 'low'),
      ),
      'moderation': (r) => r.copyWith(
        moderation: const ModerationConfig(model: 'other-moderation'),
      ),
      'promptCacheKey': (r) => r.copyWith(promptCacheKey: 'other-cache-key'),
      'promptCacheRetention': (r) =>
          r.copyWith(promptCacheRetention: PromptCacheRetention.inMemory),
      'promptCacheOptions': (r) => r.copyWith(
        promptCacheOptions: const PromptCacheOptionsParam(
          mode: PromptCacheMode.implicit,
          ttl: PromptCacheTtl.minutes30,
        ),
      ),
      'safetyIdentifier': (r) =>
          r.copyWith(safetyIdentifier: 'other-safety-id'),
      'topK': (r) => r.copyWith(topK: 20),
      'minP': (r) => r.copyWith(minP: 0.3),
      'topA': (r) => r.copyWith(topA: 0.2),
      'repetitionPenalty': (r) => r.copyWith(repetitionPenalty: 1.4),
      'openRouterProvider': (r) => r.copyWith(
        openRouterProvider: const OpenRouterProviderPreferences(
          order: ['Other provider'],
          allowFallbacks: false,
        ),
      ),
      'models': (r) => r.copyWith(models: <String>['other-fallback']),
      'route': (r) => r.copyWith(route: 'other-route'),
      'transforms': (r) => r.copyWith(transforms: <String>['other-transform']),
      'openRouterUsage': (r) => r.copyWith(
        openRouterUsage: const OpenRouterUsageConfig(include: false),
      ),
      'openRouterReasoning': (r) => r.copyWith(
        openRouterReasoning: const OpenRouterReasoning(effort: 'low'),
      ),
    };

    for (final entry in changes.entries) {
      test('${entry.key} participates in equality and hashed collections', () {
        final original = _fullyConfiguredRequest();
        final changed = entry.value(original);
        final independentlyChanged = entry.value(_fullyConfiguredRequest());

        expect(original, isNot(changed));
        expect(changed, isNot(original));
        expect(changed, independentlyChanged);
        expect(changed.hashCode, independentlyChanged.hashCode);
        expect({original, changed, independentlyChanged}, hasLength(2));
      });
    }

    final clears = <String, _ChangeRequest>{
      'frequencyPenalty': (r) => r.copyWith(frequencyPenalty: null),
      'logitBias': (r) => r.copyWith(logitBias: null),
      'logprobs': (r) => r.copyWith(logprobs: null),
      'topLogprobs': (r) => r.copyWith(topLogprobs: null),
      'maxTokens': (r) => r.copyWith(maxTokens: null),
      'maxCompletionTokens': (r) => r.copyWith(maxCompletionTokens: null),
      'n': (r) => r.copyWith(n: null),
      'presencePenalty': (r) => r.copyWith(presencePenalty: null),
      'responseFormat': (r) => r.copyWith(responseFormat: null),
      'seed': (r) => r.copyWith(seed: null),
      'serviceTier': (r) => r.copyWith(serviceTier: null),
      'stop': (r) => r.copyWith(stop: null),
      'temperature': (r) => r.copyWith(temperature: null),
      'topP': (r) => r.copyWith(topP: null),
      'tools': (r) => r.copyWith(tools: null),
      'toolChoice': (r) => r.copyWith(toolChoice: null),
      'parallelToolCalls': (r) => r.copyWith(parallelToolCalls: null),
      'user': (r) => r.copyWith(user: null),
      'metadata': (r) => r.copyWith(metadata: null),
      'store': (r) => r.copyWith(store: null),
      'streamOptions': (r) => r.copyWith(streamOptions: null),
      'reasoningEffort': (r) => r.copyWith(reasoningEffort: null),
      'verbosity': (r) => r.copyWith(verbosity: null),
      'prediction': (r) => r.copyWith(prediction: null),
      'modalities': (r) => r.copyWith(modalities: null),
      'audio': (r) => r.copyWith(audio: null),
      'webSearchOptions': (r) => r.copyWith(webSearchOptions: null),
      'moderation': (r) => r.copyWith(moderation: null),
      'promptCacheKey': (r) => r.copyWith(promptCacheKey: null),
      'promptCacheRetention': (r) => r.copyWith(promptCacheRetention: null),
      'promptCacheOptions': (r) => r.copyWith(promptCacheOptions: null),
      'safetyIdentifier': (r) => r.copyWith(safetyIdentifier: null),
      'topK': (r) => r.copyWith(topK: null),
      'minP': (r) => r.copyWith(minP: null),
      'topA': (r) => r.copyWith(topA: null),
      'repetitionPenalty': (r) => r.copyWith(repetitionPenalty: null),
      'openRouterProvider': (r) => r.copyWith(openRouterProvider: null),
      'models': (r) => r.copyWith(models: null),
      'route': (r) => r.copyWith(route: null),
      'transforms': (r) => r.copyWith(transforms: null),
      'openRouterUsage': (r) => r.copyWith(openRouterUsage: null),
      'openRouterReasoning': (r) => r.copyWith(openRouterReasoning: null),
    };

    for (final entry in clears.entries) {
      test('${entry.key} distinguishes a present value from null', () {
        final original = _fullyConfiguredRequest();
        final cleared = entry.value(original);
        final independentlyCleared = entry.value(_fullyConfiguredRequest());

        expect(cleared, isNot(original));
        expect(original, isNot(cleared));
        expect(cleared.copyWith(), cleared);
        expect(cleared, independentlyCleared);
        expect(cleared.hashCode, independentlyCleared.hashCode);
      });
    }

    test('independent complete requests and JSON round-trip are equal', () {
      final first = _fullyConfiguredRequest();
      final second = _fullyConfiguredRequest();
      final restored = ChatCompletionCreateRequest.fromJson(first.toJson());

      expect(identical(first.messages, second.messages), isFalse);
      expect(identical(first.tools, second.tools), isFalse);
      expect(identical(first.logitBias, second.logitBias), isFalse);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(restored, first);
      expect(restored.hashCode, first.hashCode);
      expect(first.copyWith(), first);
      expect({first, second, restored}, hasLength(1));
    });

    test('logit bias and metadata equality ignore map insertion order', () {
      final original = _fullyConfiguredRequest().copyWith(
        metadata: <String, dynamic>{'a': 'first', 'b': 'second'},
      );
      final reordered = _fullyConfiguredRequest().copyWith(
        logitBias: <String, int>{'2': 3, '1': 2},
        metadata: <String, dynamic>{'b': 'second', 'a': 'first'},
      );

      expect(original, reordered);
      expect(original.hashCode, reordered.hashCode);
    });

    test('metadata compares nested maps and lists by value', () {
      final first = _fullyConfiguredRequest().copyWith(
        metadata: <String, dynamic>{
          'nested': <dynamic, dynamic>{
            'items': [
              <dynamic, dynamic>{
                'count': 1,
                'flags': [true, null],
              },
            ],
            2: 'non-string nested key',
          },
        },
      );
      final second = _fullyConfiguredRequest().copyWith(
        metadata: <String, dynamic>{
          'nested': <dynamic, dynamic>{
            2: 'non-string nested key',
            'items': [
              <dynamic, dynamic>{
                'flags': [true, null],
                'count': 1,
              },
            ],
          },
        },
      );
      final changed = _fullyConfiguredRequest().copyWith(
        metadata: <String, dynamic>{
          'nested': <dynamic, dynamic>{
            'items': [
              <dynamic, dynamic>{
                'count': 2,
                'flags': [true, null],
              },
            ],
            2: 'non-string nested key',
          },
        },
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(changed));
      expect({first, second, changed}, hasLength(2));
    });

    test(
      'metadata retains its raw model values despite JSON stringification',
      () {
        final numeric = _fullyConfiguredRequest().copyWith(
          metadata: <String, dynamic>{'count': 1, 'omitted': null},
        );
        final text = _fullyConfiguredRequest().copyWith(
          metadata: <String, dynamic>{'count': '1'},
        );
        final missingNull = _fullyConfiguredRequest().copyWith(
          metadata: <String, dynamic>{'count': 1},
        );

        expect(numeric.toJson()['metadata'], {'count': '1'});
        expect(numeric.toJson()['metadata'], text.toJson()['metadata']);
        expect(numeric, isNot(text));
        expect(numeric, isNot(missingNull));
      },
    );

    test('list ordering matters and null differs from an empty collection', () {
      final request = _fullyConfiguredRequest();
      final ordered = request.copyWith(stop: <String>['FIRST', 'SECOND']);
      final reversed = request.copyWith(stop: <String>['SECOND', 'FIRST']);
      expect(ordered, isNot(reversed));

      final emptyCollections = <String, _ChangeRequest>{
        'stop': (r) => r.copyWith(stop: <String>[]),
        'tools': (r) => r.copyWith(tools: <Tool>[]),
        'modalities': (r) => r.copyWith(modalities: <ChatModality>[]),
        'models': (r) => r.copyWith(models: <String>[]),
        'transforms': (r) => r.copyWith(transforms: <String>[]),
        'logitBias': (r) => r.copyWith(logitBias: <String, int>{}),
        'metadata': (r) => r.copyWith(metadata: <String, dynamic>{}),
      };
      for (final entry in emptyCollections.entries) {
        final empty = entry.value(request);
        final cleared = clears[entry.key]!(request);
        expect(empty, isNot(cleared), reason: entry.key);
        expect(
          empty,
          entry.value(_fullyConfiguredRequest()),
          reason: entry.key,
        );
        expect(
          empty.hashCode,
          entry.value(_fullyConfiguredRequest()).hashCode,
          reason: entry.key,
        );
      }
    });

    test('toString summarizes payloads and displays cache options', () {
      final request = _fullyConfiguredRequest().copyWith(
        messages: [ChatMessage.user('private-message-payload')],
        tools: [
          Tool.function(
            name: 'private-tool-name',
            parameters: const {'private-schema': 'private-schema-payload'},
          ),
        ],
        stop: <String>['private-stop-payload'],
        metadata: <String, dynamic>{'secret': 'private-metadata-payload'},
        user: 'private-user-id',
        promptCacheKey: 'private-cache-key',
        safetyIdentifier: 'private-safety-id',
        models: <String>['private-fallback-model'],
        transforms: <String>['private-transform'],
        openRouterProvider: const OpenRouterProviderPreferences(
          order: ['private-provider-name'],
          ignore: ['private-excluded-provider'],
          quantizations: ['private-quantization'],
        ),
        webSearchOptions: const WebSearchOptions(
          searchContextSize: 'medium',
          userLocation: WebSearchUserLocation(
            approximate: WebSearchLocation(
              country: 'private-country',
              region: 'private-region',
              city: 'private-city',
              timezone: 'private-timezone',
            ),
          ),
        ),
      );
      final diagnostic = request.toString();

      expect(diagnostic, contains('messages: 1 items'));
      expect(diagnostic, contains('tools: 1 items'));
      expect(diagnostic, contains('stop: 1 items'));
      expect(diagnostic, contains('metadata: 1 items'));
      expect(diagnostic, contains('models: 1 items'));
      expect(diagnostic, contains('transforms: 1 items'));
      expect(diagnostic, contains('order: 1 items'));
      expect(diagnostic, contains('ignore: 1 items'));
      expect(diagnostic, contains('quantizations: 1 items'));
      expect(diagnostic, contains('webSearchOptions: present'));
      expect(
        diagnostic,
        contains('promptCacheOptions: PromptCacheOptionsParam('),
      );
      expect(diagnostic, contains('mode: PromptCacheMode.explicit'));
      expect(diagnostic, contains('ttl: PromptCacheTtl.minutes30'));
      expect(diagnostic, isNot(contains('private-')));
      final minimalDiagnostic = const ChatCompletionCreateRequest(
        model: 'gpt-5.6',
        messages: [],
      ).toString();
      expect(minimalDiagnostic, contains('promptCacheOptions: null'));
      expect(minimalDiagnostic, contains('webSearchOptions: null'));
    });
  });
}

ChatCompletionCreateRequest _fullyConfiguredRequest() {
  // Every call builds fresh collections to exercise content-based equality.
  final json = <String, dynamic>{
    'model': 'gpt-5.6',
    'messages': [
      {'role': 'user', 'content': 'Hello'},
    ],
    'frequency_penalty': 0.2,
    'logit_bias': {'1': 2, '2': 3},
    'logprobs': true,
    'top_logprobs': 3,
    'max_tokens': 100,
    'max_completion_tokens': 200,
    'n': 2,
    'presence_penalty': 0.3,
    'response_format': {
      'type': 'json_schema',
      'json_schema': {
        'name': 'result',
        'description': 'A result object',
        'strict': true,
        'schema': {
          'type': 'object',
          'properties': {
            'value': {'type': 'string'},
          },
          'required': ['value'],
          'additionalProperties': false,
        },
      },
    },
    'seed': 11,
    'service_tier': 'default',
    'stop': ['END'],
    'temperature': 0.7,
    'top_p': 0.8,
    'tools': [
      {
        'type': 'function',
        'function': {
          'name': 'get_result',
          'description': 'Read a result',
          'parameters': {
            'type': 'object',
            'properties': {
              'id': {'type': 'string'},
            },
            'required': ['id'],
          },
          'strict': true,
        },
      },
    ],
    'tool_choice': {
      'type': 'function',
      'function': {'name': 'get_result'},
    },
    'parallel_tool_calls': true,
    'user': 'user-id',
    'metadata': {'key': 'value'},
    'store': true,
    'stream_options': {'include_usage': true},
    'reasoning_effort': 'high',
    'verbosity': 'high',
    'prediction': {'type': 'content', 'content': 'Predicted result'},
    'modalities': ['text', 'audio'],
    'audio': {'voice': 'alloy', 'format': 'mp3'},
    'web_search_options': {
      'search_context_size': 'medium',
      'user_location': {
        'type': 'approximate',
        'approximate': {'country': 'US', 'city': 'New York'},
      },
    },
    'moderation': {'model': 'omni-moderation-latest'},
    'prompt_cache_key': 'cache-key',
    'prompt_cache_retention': '24h',
    'prompt_cache_options': {'mode': 'explicit', 'ttl': '30m'},
    'safety_identifier': 'safety-id',
    'top_k': 10,
    'min_p': 0.1,
    'top_a': 0.1,
    'repetition_penalty': 1.1,
    'provider': {
      'order': ['OpenAI', 'Azure'],
      'allow_fallbacks': true,
      'require_parameters': true,
      'data_collection': 'deny',
      'zdr': true,
      'ignore': ['Other provider'],
      'quantizations': ['fp16'],
      'sort': 'price',
    },
    'models': ['gpt-5.5'],
    'route': 'fallback',
    'transforms': ['middle-out'],
    'usage': {'include': true},
    'reasoning': {
      'effort': 'high',
      'max_tokens': 100,
      'exclude': false,
      'enabled': true,
    },
  };
  return ChatCompletionCreateRequest.fromJson(json);
}
