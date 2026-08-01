import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

void main() {
  group('FallbackBlock (response)', () {
    test('fromJson/toJson round-trip', () {
      final json = {
        'type': 'fallback',
        'from': {'model': 'claude-opus-4-8'},
        'to': {'model': 'claude-sonnet-4-6'},
        'trigger': {'type': 'refusal', 'category': 'frontier_llm'},
      };

      final block = FallbackBlock.fromJson(json);
      expect(block.from, const FallbackHopInfo(model: 'claude-opus-4-8'));
      expect(block.to, const FallbackHopInfo(model: 'claude-sonnet-4-6'));
      expect(block.type, 'fallback');
      expect(block.trigger.category, RefusalCategory.frontierLlm);
      expect(block.toJson(), json);
    });

    test('ContentBlock.fromJson dispatches type:fallback to FallbackBlock', () {
      final block = ContentBlock.fromJson({
        'type': 'fallback',
        'from': {'model': 'claude-opus-4-8'},
        'to': {'model': 'claude-sonnet-4-6'},
        'trigger': {'type': 'refusal', 'category': null},
      });

      expect(block, isA<FallbackBlock>());
      final fallback = block as FallbackBlock;
      expect(fallback.from.model, 'claude-opus-4-8');
      expect(fallback.to.model, 'claude-sonnet-4-6');
      expect(fallback.trigger.category, isNull);
    });

    test('fromJson rejects a mismatched discriminator', () {
      expect(
        () => FallbackBlock.fromJson(const {
          'type': 'text',
          'from': {'model': 'a'},
          'to': {'model': 'b'},
        }),
        throwsFormatException,
      );
    });

    test('copyWith replaces hop info and trigger', () {
      const original = FallbackBlock(
        from: FallbackHopInfo(model: 'a'),
        to: FallbackHopInfo(model: 'b'),
        trigger: FallbackRefusalTrigger(rawCategory: 'cyber'),
      );
      final modified = original.copyWith(
        to: const FallbackHopInfo(model: 'c'),
        trigger: const FallbackRefusalTrigger(rawCategory: 'bio'),
      );
      expect(modified.from.model, 'a');
      expect(modified.to.model, 'c');
      expect(modified.trigger.category, RefusalCategory.bio);
    });
  });

  group('FallbackRefusalTrigger', () {
    test('round-trips a known category', () {
      final json = {'type': 'refusal', 'category': 'cyber'};
      final trigger = FallbackRefusalTrigger.fromJson(json);
      expect(trigger.type, 'refusal');
      expect(trigger.category, RefusalCategory.cyber);
      expect(trigger.rawCategory, 'cyber');
      expect(trigger.toJson(), json);
    });

    test('round-trips a null category', () {
      final json = {'type': 'refusal', 'category': null};
      final trigger = FallbackRefusalTrigger.fromJson(json);
      expect(trigger.category, isNull);
      expect(trigger.rawCategory, isNull);
      expect(trigger.toJson(), json);
    });

    test('preserves an unrecognized category verbatim', () {
      final json = {'type': 'refusal', 'category': 'future_policy'};
      final trigger = FallbackRefusalTrigger.fromJson(json);
      // The typed getter degrades to unknown...
      expect(trigger.category, RefusalCategory.unknown);
      // ...but the raw wire value round-trips unchanged.
      expect(trigger.rawCategory, 'future_policy');
      expect(trigger.toJson()['category'], 'future_policy');
    });

    test('copyWith clears category to null vs preserves on omission', () {
      const trigger = FallbackRefusalTrigger(rawCategory: 'cyber');
      expect(trigger.copyWith(rawCategory: null).rawCategory, isNull);
      expect(trigger.copyWith().rawCategory, 'cyber');
    });

    test('fromJson throws on a wrong discriminator', () {
      expect(
        () => FallbackRefusalTrigger.fromJson(const {
          'type': 'other',
          'category': null,
        }),
        throwsFormatException,
      );
    });

    test('fromJson throws when the type is missing', () {
      expect(
        () => FallbackRefusalTrigger.fromJson(const {'category': null}),
        throwsFormatException,
      );
    });

    test('fromJson throws when the required category key is absent', () {
      expect(
        () => FallbackRefusalTrigger.fromJson(const {'type': 'refusal'}),
        throwsFormatException,
      );
    });
  });

  group('FallbackInputBlock (request)', () {
    test('fromJson/toJson round-trip (no trigger)', () {
      final json = {
        'type': 'fallback',
        'from': {'model': 'claude-opus-4-8'},
        'to': {'model': 'claude-sonnet-4-6'},
      };

      final block = FallbackInputBlock.fromJson(json);
      expect(block.from.model, 'claude-opus-4-8');
      expect(block.to.model, 'claude-sonnet-4-6');
      expect(block.type, 'fallback');
      expect(block.hasTrigger, isFalse);
      expect(block.toJson(), json);
    });

    test('InputContentBlock.fromJson dispatch', () {
      final block = InputContentBlock.fromJson({
        'type': 'fallback',
        'from': {'model': 'claude-opus-4-8'},
        'to': {'model': 'claude-sonnet-4-6'},
      });

      expect(block, isA<FallbackInputBlock>());
    });

    test('InputContentBlock.fallback factory', () {
      final block = InputContentBlock.fallback(
        from: const FallbackHopInfo(model: 'claude-opus-4-8'),
        to: const FallbackHopInfo(model: 'claude-sonnet-4-6'),
      );

      expect(block, isA<FallbackInputBlock>());
      expect(block.toJson(), {
        'type': 'fallback',
        'from': {'model': 'claude-opus-4-8'},
        'to': {'model': 'claude-sonnet-4-6'},
      });
    });

    test('echoes a free-form trigger map verbatim', () {
      final json = {
        'type': 'fallback',
        'from': {'model': 'a'},
        'to': {'model': 'b'},
        'trigger': {'type': 'refusal', 'category': 'frontier_llm'},
      };
      final block = FallbackInputBlock.fromJson(json);
      expect(block.hasTrigger, isTrue);
      expect(block.trigger, {'type': 'refusal', 'category': 'frontier_llm'});
      expect(block.toJson(), json);
    });

    test('preserves an explicit null trigger', () {
      final json = {
        'type': 'fallback',
        'from': {'model': 'a'},
        'to': {'model': 'b'},
        'trigger': null,
      };
      final block = FallbackInputBlock.fromJson(json);
      expect(block.hasTrigger, isTrue);
      expect(block.trigger, isNull);
      expect(block.toJson().containsKey('trigger'), isTrue);
      expect(block.toJson()['trigger'], isNull);
    });

    test('omits an absent trigger key', () {
      final json = {
        'type': 'fallback',
        'from': {'model': 'a'},
        'to': {'model': 'b'},
      };
      final block = FallbackInputBlock.fromJson(json);
      expect(block.hasTrigger, isFalse);
      expect(block.trigger, isNull);
      expect(block.toJson().containsKey('trigger'), isFalse);
    });

    test('stores the trigger map deeply unmodifiable', () {
      final block = FallbackInputBlock(
        from: const FallbackHopInfo(model: 'a'),
        to: const FallbackHopInfo(model: 'b'),
        trigger: const {
          'type': 'refusal',
          'meta': {'nested': 1},
          'list': [
            {'k': 'v'},
          ],
        },
      );
      // Outer map is frozen...
      expect(() => block.trigger!['x'] = 1, throwsUnsupportedError);
      // ...and so are nested maps and lists.
      expect(
        () => (block.trigger!['meta'] as Map)['nested'] = 2,
        throwsUnsupportedError,
      );
      expect(
        () => (block.trigger!['list'] as List).add('z'),
        throwsUnsupportedError,
      );
      expect(
        () => ((block.trigger!['list'] as List)[0] as Map)['k'] = 'w',
        throwsUnsupportedError,
      );
    });

    test('freezing a trigger does not alias the source nested maps', () {
      final source = {
        'meta': {'nested': 1},
      };
      final block = FallbackInputBlock(
        from: const FallbackHopInfo(model: 'a'),
        to: const FallbackHopInfo(model: 'b'),
        trigger: source,
      );
      // Mutating the original nested map must not change the frozen copy.
      (source['meta']! as Map)['nested'] = 99;
      expect((block.trigger!['meta'] as Map)['nested'], 1);
    });

    test('copyWith preserves trigger presence on omission', () {
      final block = FallbackInputBlock(
        from: const FallbackHopInfo(model: 'a'),
        to: const FallbackHopInfo(model: 'b'),
        trigger: const {'k': 'v'},
      );
      final copy = block.copyWith(to: const FallbackHopInfo(model: 'c'));
      expect(copy.hasTrigger, isTrue);
      expect(copy.trigger, {'k': 'v'});
      expect(copy.toString(), contains('hasTrigger: true'));
    });
  });

  group('FallbackConfigV2', () {
    test('round-trips required model only', () {
      final json = {'model': 'claude-sonnet-4-6'};
      final config = FallbackConfigV2.fromJson(json);

      expect(config.model, 'claude-sonnet-4-6');
      expect(config.maxTokens, isNull);
      expect(config.thinking, isNull);
      expect(config.outputConfig, isNull);
      expect(config.speed, isNull);
      expect(config.extra, isNull);
      expect(config.toJson(), json);
    });

    test('round-trips all override fields', () {
      final json = {
        'model': 'claude-sonnet-4-6',
        'max_tokens': 2048,
        'thinking': {'type': 'enabled', 'budget_tokens': 1024},
        'output_config': {'effort': 'high'},
        'speed': 'fast',
      };

      final config = FallbackConfigV2.fromJson(json);
      expect(config.model, 'claude-sonnet-4-6');
      expect(config.maxTokens, 2048);
      expect(config.thinking, isA<ThinkingEnabled>());
      expect((config.thinking! as ThinkingEnabled).budgetTokens, 1024);
      expect(config.outputConfig!.effort, EffortLevel.high);
      expect(config.speed, Speed.fast);
      expect(config.extra, isNull);
      expect(config.toJson(), json);
    });

    test('preserves unknown keys in extra (open object) and re-emits them', () {
      final json = {
        'model': 'claude-sonnet-4-6',
        'max_tokens': 512,
        'future_field': 'value',
        'nested': {'a': 1},
      };

      final config = FallbackConfigV2.fromJson(json);
      expect(config.extra, {
        'future_field': 'value',
        'nested': {'a': 1},
      });

      final out = config.toJson();
      expect(out['model'], 'claude-sonnet-4-6');
      expect(out['max_tokens'], 512);
      expect(out['future_field'], 'value');
      expect(out['nested'], {'a': 1});
      // Full round-trip fidelity.
      expect(out, json);
    });

    test('extra does not override declared keys on collision', () {
      // A stale `model` smuggled into extra must lose to the typed field.
      const config = FallbackConfigV2(
        model: 'declared-model',
        extra: {'model': 'stale-model'},
      );
      expect(config.toJson()['model'], 'declared-model');
    });

    test('extra never emits a declared key when its typed field is null', () {
      // A declared optional key smuggled into `extra` must NOT leak when the
      // typed field is absent — `extra` is for undeclared keys only.
      const config = FallbackConfigV2(
        model: 'm',
        extra: {'max_tokens': 99, 'custom': 'kept'},
      );
      final json = config.toJson();
      expect(json.containsKey('max_tokens'), isFalse);
      expect(json['custom'], 'kept'); // undeclared keys still pass through
    });

    test('equality is content-based for extra', () {
      const a = FallbackConfigV2(
        model: 'm',
        extra: {
          'nested': {'a': 1},
        },
      );
      const b = FallbackConfigV2(
        model: 'm',
        extra: {
          'nested': {'a': 1},
        },
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('MessageCreateRequest fallback fields', () {
    test('toJson includes fallbacks and fallback_credit_token', () {
      const request = MessageCreateRequest(
        model: 'claude-opus-4-8',
        maxTokens: 1024,
        messages: [],
        fallbacks: [
          FallbackConfigV2(model: 'claude-sonnet-4-6', maxTokens: 512),
          FallbackConfigV2(model: 'claude-haiku-4-5-20251001'),
        ],
        fallbackCreditToken: FallbackCreditTokenParam.token(
          'tok_secret_abc123',
        ),
      );

      final json = request.toJson();
      expect(json['fallback_credit_token'], 'tok_secret_abc123');
      expect(json['fallbacks'], [
        {'model': 'claude-sonnet-4-6', 'max_tokens': 512},
        {'model': 'claude-haiku-4-5-20251001'},
      ]);
    });

    test('fromJson parses fallbacks and fallback_credit_token', () {
      final request = MessageCreateRequest.fromJson(const {
        'model': 'claude-opus-4-8',
        'max_tokens': 1024,
        'messages': <Map<String, dynamic>>[],
        'fallbacks': [
          {'model': 'claude-sonnet-4-6', 'max_tokens': 512},
        ],
        'fallback_credit_token': 'tok_secret_abc123',
      });

      expect(request.fallbacks, hasLength(1));
      expect(request.fallbacks!.first.model, 'claude-sonnet-4-6');
      expect(request.fallbacks!.first.maxTokens, 512);
      expect(
        request.fallbackCreditToken,
        const FallbackCreditTokenParam.token('tok_secret_abc123'),
      );
    });

    test('omits fallback fields when null', () {
      const request = MessageCreateRequest(
        model: 'claude-opus-4-8',
        maxTokens: 1024,
        messages: [],
      );

      final json = request.toJson();
      expect(json.containsKey('fallbacks'), isFalse);
      expect(json.containsKey('fallback_credit_token'), isFalse);
    });
  });

  group('MessageCreateRequest with fallback betas (resource)', () {
    late MockHttpClient mockHttpClient;
    late AnthropicClient client;

    setUp(() {
      mockHttpClient = MockHttpClient();
      client = AnthropicClient(
        config: const AnthropicConfig(
          authProvider: ApiKeyProvider('test-api-key'),
          retryPolicy: RetryPolicy(maxRetries: 0),
        ),
        httpClient: mockHttpClient,
      );
    });

    tearDown(() {
      client.close();
    });

    test('sends fallback betas in anthropic-beta header (comma-joined) and '
        'fallbacks in the body', () async {
      mockHttpClient.queueJsonResponse(MockResponses.message());

      await client.messages.create(
        MessageCreateRequest(
          model: 'claude-opus-4-8',
          maxTokens: 1024,
          messages: [InputMessage.user('Hi')],
          fallbacks: const [FallbackConfigV2(model: 'claude-sonnet-4-6')],
          fallbackCreditToken: const FallbackCreditTokenParam.token(
            'tok_secret_abc123',
          ),
        ),
        betas: const [
          'server-side-fallback-2026-06-01',
          'fallback-credit-2026-06-01',
        ],
      );

      final request = mockHttpClient.lastRequest!;
      expect(
        request.headers['anthropic-beta'],
        'server-side-fallback-2026-06-01,fallback-credit-2026-06-01',
      );

      final body =
          jsonDecode((request as http.Request).body) as Map<String, dynamic>;
      expect(body['fallbacks'], [
        {'model': 'claude-sonnet-4-6'},
      ]);
      expect(body['fallback_credit_token'], 'tok_secret_abc123');
    });
  });

  group('Redaction', () {
    test('MessageCreateRequest.toString does not leak '
        'fallbackCreditToken', () {
      const request = MessageCreateRequest(
        model: 'claude-opus-4-8',
        maxTokens: 1024,
        messages: [],
        fallbackCreditToken: FallbackCreditTokenParam.token(
          'tok_super_secret_value',
        ),
      );

      final str = request.toString();
      expect(str, isNot(contains('tok_super_secret_value')));
      expect(str, contains('fallbackCreditToken: [redacted]'));
    });

    test('RefusalStopDetails.toString does not leak fallbackCreditToken', () {
      const details = RefusalStopDetails(
        fallbackCreditToken: 'tok_super_secret_value',
      );

      final str = details.toString();
      expect(str, isNot(contains('tok_super_secret_value')));
      expect(str, contains('fallbackCreditToken: [redacted]'));
    });

    test('toString shows null token when absent', () {
      const request = MessageCreateRequest(
        model: 'claude-opus-4-8',
        maxTokens: 1024,
        messages: [],
      );
      expect(request.toString(), contains('fallbackCreditToken: null'));
    });
  });

  group('RefusalCategory', () {
    test('fromJson maps the new categories', () {
      expect(
        RefusalCategory.fromJson('frontier_llm'),
        RefusalCategory.frontierLlm,
      );
      expect(
        RefusalCategory.fromJson('reasoning_extraction'),
        RefusalCategory.reasoningExtraction,
      );
    });

    test('fromJson keeps existing categories and falls back to unknown', () {
      expect(RefusalCategory.fromJson('cyber'), RefusalCategory.cyber);
      expect(RefusalCategory.fromJson('bio'), RefusalCategory.bio);
      expect(
        RefusalCategory.fromJson('not_a_category'),
        RefusalCategory.unknown,
      );
    });

    test('new categories round-trip through toJson', () {
      expect(RefusalCategory.frontierLlm.toJson(), 'frontier_llm');
      expect(
        RefusalCategory.reasoningExtraction.toJson(),
        'reasoning_extraction',
      );
    });

    test('general_harms round-trips', () {
      expect(
        RefusalCategory.fromJson('general_harms'),
        RefusalCategory.generalHarms,
      );
      expect(RefusalCategory.generalHarms.toJson(), 'general_harms');
    });
  });

  group('RefusalStopDetails', () {
    test('round-trips the three new fields', () {
      final json = {
        'type': 'refusal',
        'category': 'frontier_llm',
        'explanation': 'Not allowed.',
        'fallback_credit_token': 'tok_abc',
        'fallback_has_prefill_claim': true,
        'recommended_model': 'claude-sonnet-4-6',
      };

      final details = RefusalStopDetails.fromJson(json);
      expect(details.category, RefusalCategory.frontierLlm);
      expect(details.explanation, 'Not allowed.');
      expect(details.fallbackCreditToken, 'tok_abc');
      expect(details.fallbackHasPrefillClaim, isTrue);
      expect(details.recommendedModel, 'claude-sonnet-4-6');
      expect(details.toJson(), json);
    });

    test('omits the optional new fields when null', () {
      const details = RefusalStopDetails(category: RefusalCategory.cyber);
      final json = details.toJson();
      expect(json.containsKey('fallback_credit_token'), isFalse);
      expect(json.containsKey('fallback_has_prefill_claim'), isFalse);
      expect(json.containsKey('recommended_model'), isFalse);
    });
  });

  group('AdvisorTool maxTokens', () {
    test('round-trips max_tokens', () {
      const tool = AdvisorTool(model: 'claude-opus-4-8', maxTokens: 4096);
      final json = tool.toJson();
      expect(json['max_tokens'], 4096);

      final parsed = AdvisorTool.fromJson(json);
      expect(parsed.maxTokens, 4096);
    });

    test('omits max_tokens when null', () {
      const tool = AdvisorTool(model: 'claude-opus-4-8');
      expect(tool.toJson().containsKey('max_tokens'), isFalse);
    });

    test('copyWith updates max_tokens', () {
      const tool = AdvisorTool(model: 'claude-opus-4-8');
      expect(tool.copyWith(maxTokens: 1024).maxTokens, 1024);
    });
  });

  group('AdvisorToolResultErrorCode', () {
    test('fromJson maps model_not_found', () {
      expect(
        AdvisorToolResultErrorCode.fromJson('model_not_found'),
        AdvisorToolResultErrorCode.modelNotFound,
      );
    });

    test('toJson serializes model_not_found back', () {
      expect(
        AdvisorToolResultErrorCode.modelNotFound.toJson(),
        'model_not_found',
      );
    });
  });

  group('ModelInfo allowedFallbackModels', () {
    test('round-trips allowed_fallback_models', () {
      final json = {
        'id': 'claude-opus-4-8',
        'display_name': 'Claude Opus 4.8',
        'created_at': '2025-05-14T00:00:00.000Z',
        'type': 'model',
        'allowed_fallback_models': ['claude-sonnet-4-6', 'claude-haiku-4-5'],
      };

      final info = ModelInfo.fromJson(json);
      expect(info.allowedFallbackModels, [
        'claude-sonnet-4-6',
        'claude-haiku-4-5',
      ]);
      expect(info.toJson()['allowed_fallback_models'], [
        'claude-sonnet-4-6',
        'claude-haiku-4-5',
      ]);
    });

    test('omits allowed_fallback_models when null', () {
      final info = ModelInfo(
        id: 'claude-opus-4-8',
        displayName: 'Claude Opus 4.8',
        createdAt: DateTime.utc(2025, 5, 14),
      );
      expect(info.toJson().containsKey('allowed_fallback_models'), isFalse);
    });

    test('equality is content-based for allowedFallbackModels', () {
      final a = ModelInfo(
        id: 'm',
        displayName: 'M',
        createdAt: DateTime.utc(2025),
        allowedFallbackModels: const ['x', 'y'],
      );
      final b = ModelInfo(
        id: 'm',
        displayName: 'M',
        createdAt: DateTime.utc(2025),
        allowedFallbackModels: const ['x', 'y'],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
