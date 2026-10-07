import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Responses request cache fields (CACHE-001/006)', () {
    test('const request preserves all controls independently', () {
      const request = CreateResponseRequest(
        model: 'fixture-model',
        input: ResponseInput.text('Hello'),
        promptCacheKey: 'fixture-key',
        promptCacheRetention: PromptCacheRetention.h24,
        promptCacheOptions: ResponsePromptCacheOptionsParam(
          mode: PromptCacheMode.explicit,
          ttl: PromptCacheTtl.minutes30,
          comparisonResponseId: 'resp_previous',
          prewarm: false,
        ),
      );
      final json = {
        'model': 'fixture-model',
        'input': 'Hello',
        'prompt_cache_key': 'fixture-key',
        'prompt_cache_retention': '24h',
        'prompt_cache_options': {
          'mode': 'explicit',
          'ttl': '30m',
          'comparison_response_id': 'resp_previous',
          'prewarm': false,
        },
      };
      expect(request.toJson(), json);
      final restored = CreateResponseRequest.fromJson(json);
      expect(restored, request);
      expect(restored.hashCode, request.hashCode);
      expect(request.copyWith(), request);
      expect(request.toJson(), isNot(contains('generate')));
      expect(request.promptCacheOptions!.toJson(), isNot(contains('generate')));
      expect(request.toString(), contains('promptCacheOptions:'));
      expect(request.toString(), contains('promptCacheRetention:'));
      expect(request.toString(), contains('comparisonResponseId: [REDACTED]'));
      expect(request.toString(), isNot(contains('resp_previous')));
      expect(
        request.copyWith(promptCacheRetention: PromptCacheRetention.inMemory),
        isNot(request),
      );
      expect(
        request.copyWith(
          promptCacheOptions: const ResponsePromptCacheOptionsParam(
            prewarm: true,
          ),
        ),
        isNot(request),
      );
    });

    test(
      'empty options, false, parsed comparison null, and clearing stay distinct',
      () {
        const minimal = CreateResponseRequest(
          model: 'fixture-model',
          input: ResponseInput.text('Hello'),
        );
        expect(minimal.toJson(), {'model': 'fixture-model', 'input': 'Hello'});
        final empty = minimal.copyWith(
          promptCacheOptions: const ResponsePromptCacheOptionsParam(),
        );
        expect(empty.toJson()['prompt_cache_options'], <String, dynamic>{});
        final parsed = CreateResponseRequest.fromJson(const {
          'model': 'fixture-model',
          'input': 'Hello',
          'prompt_cache_options': {
            'comparison_response_id': null,
            'prewarm': false,
          },
          'prompt_cache_retention': null,
        });
        expect(parsed.promptCacheOptions!.comparisonResponseId, isNull);
        expect(parsed.promptCacheOptions!.prewarm, isFalse);
        expect(parsed.promptCacheRetention, isNull);
        expect(parsed.toJson()['prompt_cache_options'], {'prewarm': false});
        expect(parsed.toJson().containsKey('prompt_cache_retention'), isFalse);
        expect(
          parsed.copyWith(promptCacheOptions: null, promptCacheRetention: null),
          minimal,
        );
        expect(
          parsed.promptCacheOptions!.copyWith(prewarm: null).toJson(),
          <String, dynamic>{},
        );
      },
    );

    test('both legacy retention spellings parse to canonical output', () {
      for (final wire in [
        'in_memory',
        'in-memory',
        '24h',
        'future-retention',
      ]) {
        final request = CreateResponseRequest.fromJson({
          'model': 'fixture-model',
          'input': 'Hello',
          'prompt_cache_retention': wire,
        });
        final expected = switch (wire) {
          'in_memory' || 'in-memory' => 'in_memory',
          '24h' => '24h',
          _ => 'unknown',
        };
        expect(request.toJson()['prompt_cache_retention'], expected);
        expect(
          request
              .copyWith(promptCacheRetention: null)
              .toJson()
              .containsKey('prompt_cache_retention'),
          isFalse,
        );
      }
    });

    test('string-keyed dynamic option maps are accepted', () {
      final request = CreateResponseRequest.fromJson(const {
        'model': 'fixture-model',
        'input': 'Hello',
        'prompt_cache_options': <dynamic, dynamic>{
          'mode': 'explicit',
          'ttl': '30m',
          'prewarm': false,
          'comparison_response_id': 'resp_previous',
        },
      });
      expect(request.promptCacheOptions!.toJson(), {
        'mode': 'explicit',
        'ttl': '30m',
        'prewarm': false,
        'comparison_response_id': 'resp_previous',
      });
    });

    test(
      'nested metadata equality is independent of identity and key order',
      () {
        const first = CreateResponseRequest(
          model: 'fixture-model',
          input: ResponseInput.text('Hello'),
          metadata: {
            'nested': {
              'a': 1,
              'b': [
                {'c': true},
              ],
            },
          },
        );
        final second = first.copyWith(
          metadata: {
            'nested': {
              'b': [
                {'c': true},
              ],
              'a': 1,
            },
          },
        );
        expect(second, first);
        expect(second.hashCode, first.hashCode);
        expect(
          second.copyWith(
            metadata: {
              'nested': {
                'a': 1,
                'b': [
                  {'c': false},
                ],
              },
            },
          ),
          isNot(first),
        );
      },
    );

    test('request diagnostics summarize opaque fields and preserve labels', () {
      final request = CreateResponseRequest(
        model: 'fixture-model',
        input: const ResponseInput.text('input-private'),
        instructions: 'instructions-private',
        previousResponseId: 'previous-private',
        tools: [
          ResponseTool.fromJson(const {
            'type': 'function',
            'name': 'function-private',
            'description': 'description-private',
            'parameters': {
              'type': 'object',
              'properties': {
                'schema-private': {'type': 'string'},
              },
            },
          }),
        ],
        text: const TextConfig(
          format: JsonSchemaFormat(
            name: 'schema-name-private',
            description: 'schema-description-private',
            schema: {'schema-private': true},
          ),
        ),
        contextManagement: const [ContextManagement(type: 'context-private')],
        reasoning: const ReasoningConfig(
          context: ReasoningContext.allTurns,
          mode: ReasoningMode.custom('reasoning-private'),
        ),
        metadata: const {
          'metadata-private': ['value-private'],
        },
        safetyIdentifier: 'safety-private',
        promptCacheKey: 'key-private',
        promptCacheOptions: const ResponsePromptCacheOptionsParam(
          comparisonResponseId: 'comparison-private',
          prewarm: false,
        ),
      );
      final summary = request.toString();
      expect(summary, isNot(contains('-private')));
      expect(summary, contains('tools: 1 items'));
      expect(summary, contains('contextManagement: 1 items'));
      expect(summary, contains('metadata: 1 entries'));
      expect(summary, contains('prewarm: false'));
      expect(summary, contains('context: ReasoningContext.allTurns'));
      expect(summary, contains('mode: [custom]'));
      expect(summary, isNot(contains('null items')));
      for (final field in [
        'model',
        'input',
        'instructions',
        'tools',
        'toolChoice',
        'previousResponseId',
        'maxOutputTokens',
        'temperature',
        'topP',
        'presencePenalty',
        'frequencyPenalty',
        'stream',
        'streamOptions',
        'reasoning',
        'text',
        'truncation',
        'contextManagement',
        'parallelToolCalls',
        'serviceTier',
        'metadata',
        'include',
        'store',
        'background',
        'maxToolCalls',
        'safetyIdentifier',
        'moderation',
        'promptCacheKey',
        'promptCacheOptions',
        'promptCacheRetention',
        'topLogprobs',
        'multiAgent',
      ]) {
        expect(summary, contains('$field:'));
      }
    });

    test('new request option failures identify the holder field', () {
      for (final raw in <Object?>[
        null,
        7,
        [],
        'options',
        {'mode': null},
        {'ttl': null},
        {'prewarm': null},
        {'prewarm': 'false'},
        {'comparison_response_id': false},
        <dynamic, dynamic>{7: 'bad key'},
      ]) {
        expect(
          () => CreateResponseRequest.fromJson({
            'model': 'fixture-model',
            'input': 'Hello',
            'prompt_cache_options': raw,
          }),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'context',
              contains('CreateResponseRequest.prompt_cache_options'),
            ),
          ),
        );
      }
      expect(
        () => CreateResponseRequest.fromJson(const {
          'model': 'fixture-model',
          'input': 'Hello',
          'prompt_cache_retention': 7,
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'context',
            contains('prompt_cache_retention'),
          ),
        ),
      );
    });
  });

  group('Response echo and diagnostics (CACHE-002/003)', () {
    test(
      'comparison echo preserves empty ID and supports explicit clearing',
      () {
        for (final comparison in ['resp_previous', '', null]) {
          final response = Response.fromJson({
            ..._responseJson(),
            'prompt_cache_options': {
              'mode': 'implicit',
              'ttl': '30m',
              'comparison_response_id': comparison,
            },
          });
          expect(response.promptCacheOptions!.comparisonResponseId, comparison);
          expect(response.toJson()['prompt_cache_options'], {
            'mode': 'implicit',
            'ttl': '30m',
            'comparison_response_id': ?comparison,
          });
          expect(
            response.promptCacheOptions!
                .copyWith(comparisonResponseId: null)
                .toJson(),
            {'mode': 'implicit', 'ttl': '30m'},
          );
          expect(
            response
                .copyWith(promptCacheOptions: null)
                .toJson()
                .containsKey('prompt_cache_options'),
            isFalse,
          );
        }
        // Existing response-holder null compatibility is retained.
        final nullableEcho = Response.fromJson({
          ..._responseJson(),
          'prompt_cache_options': null,
        });
        expect(nullableEcho.promptCacheOptions, isNull);
      },
    );

    const reasons = [
      'model_changed',
      'prompt_cache_key_changed',
      'tools_changed',
      'text_format_changed',
      'reasoning_effort_changed',
      'verbosity_changed',
      'context_compacted',
      'input_changed',
      'service_tier_changed',
      'future_reason',
    ];
    for (final reason in reasons) {
      test('cache miss retains reason $reason and zero counters', () {
        final diagnostics = {
          'type': 'cache_miss',
          'reason': reason,
          'cache_missed_tokens': 0,
          'comparison_reusable_tokens': 0,
        };
        final response = Response.fromJson({
          ..._responseJson(),
          'prompt_cache_diagnostics': diagnostics,
        });
        final miss =
            response.promptCacheDiagnostics! as PromptCacheMissDiagnostics;
        expect(miss.reason.toJson(), reason);
        expect(miss.cacheMissedTokens, 0);
        expect(miss.comparisonReusableTokens, 0);
        expect(response.toJson()['prompt_cache_diagnostics'], diagnostics);
        final restored = Response.fromJson(response.toJson());
        expect(restored, response);
        expect(restored.hashCode, response.hashCode);
        expect(miss.copyWith(comparisonReusableTokens: null).toJson(), {
          'type': 'cache_miss',
          'reason': reason,
          'cache_missed_tokens': 0,
        });
        expect(
          response
              .copyWith(promptCacheDiagnostics: null)
              .toJson()
              .containsKey('prompt_cache_diagnostics'),
          isFalse,
        );
        expect(response.toString(), contains('promptCacheDiagnostics:'));
      });
    }

    for (final type in [
      'cache_hit',
      'comparison_response_not_found',
      'unavailable',
    ]) {
      test('$type has no fabricated miss counters', () {
        final json = <String, dynamic>{'type': type};
        final response = Response.fromJson({
          ..._responseJson(),
          'prompt_cache_diagnostics': json,
        });
        expect(response.promptCacheDiagnostics!.type, type);
        expect(response.toJson()['prompt_cache_diagnostics'], json);
      });
    }

    test('dynamic diagnostic maps preserve known and nested future data', () {
      final known = Response.fromJson({
        ..._responseJson(),
        'prompt_cache_diagnostics': const <dynamic, dynamic>{
          'type': 'cache_miss',
          'reason': 'input_changed',
          'cache_missed_tokens': 0,
        },
      });
      expect(known.toJson()['prompt_cache_diagnostics'], {
        'type': 'cache_miss',
        'reason': 'input_changed',
        'cache_missed_tokens': 0,
      });
      final future = Response.fromJson({
        ..._responseJson(),
        'prompt_cache_diagnostics': const <dynamic, dynamic>{
          'type': 'future_diagnostic',
          'nested': <dynamic, dynamic>{
            'items': [
              <dynamic, dynamic>{'value': 0},
            ],
          },
        },
      });
      expect(future.toJson()['prompt_cache_diagnostics'], {
        'type': 'future_diagnostic',
        'nested': {
          'items': [
            {'value': 0},
          ],
        },
      });
    });

    test('response diagnostics summarize opaque fields', () {
      final response = Response.fromJson({
        ..._responseJson(),
        'instructions': 'instructions-private',
        'previous_response_id': 'previous-private',
        'metadata': const {'metadata-private': 'value-private'},
        'prompt_cache_key': 'key-private',
        'reasoning': const {
          'context': 'all_turns',
          'mode': 'reasoning-private',
        },
        'prompt_cache_options': const {
          'mode': 'explicit',
          'ttl': '30m',
          'comparison_response_id': 'comparison-private',
        },
        'error': const {'code': 'server_error', 'message': 'error-private'},
        'output': const [
          {
            'type': 'message',
            'id': 'msg_fixture',
            'status': 'completed',
            'role': 'assistant',
            'content': [
              {
                'type': 'output_text',
                'text': 'output-private',
                'annotations': <Object>[],
              },
            ],
          },
        ],
      });
      final summary = response.toString();
      expect(summary, isNot(contains('-private')));
      expect(summary, contains('output: 1 items'));
      expect(summary, contains('metadata: 1 entries'));
      expect(summary, contains('error: present'));
      expect(summary, contains('mode: PromptCacheMode.explicit'));
      expect(summary, contains('context: ReasoningContext.allTurns'));
      expect(summary, contains('mode: [custom]'));
      expect(summary, isNot(contains('null items')));
    });

    test(
      'absent diagnostics omit cleanly and malformed present data fails contextually',
      () {
        expect(
          Response.fromJson(_responseJson()).promptCacheDiagnostics,
          isNull,
        );
        expect(
          Response.fromJson(
            _responseJson(),
          ).toJson().containsKey('prompt_cache_diagnostics'),
          isFalse,
        );
        for (final raw in <Object?>[
          null,
          7,
          [],
          '',
          {},
          {'type': null},
          {'type': 'cache_miss'},
          {
            'type': 'cache_miss',
            'reason': 'input_changed',
            'cache_missed_tokens': null,
          },
          {
            'type': 'cache_miss',
            'reason': 'input_changed',
            'cache_missed_tokens': 1.5,
          },
          {'type': 'cache_miss', 'reason': false, 'cache_missed_tokens': 0},
          <dynamic, dynamic>{7: 'bad key'},
          {
            'type': 'future_diagnostic',
            'nested': <dynamic, dynamic>{7: 'bad nested key'},
          },
          {
            'type': 'cache_miss',
            'reason': 'input_changed',
            'cache_missed_tokens': 0,
            'comparison_reusable_tokens': null,
          },
        ]) {
          expect(
            () => Response.fromJson({
              ..._responseJson(),
              'prompt_cache_diagnostics': raw,
            }),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'context',
                contains('Response.prompt_cache_diagnostics'),
              ),
            ),
          );
        }
      },
    );

    test(
      'unknown diagnostics preserve deep immutable data and safe diagnostics',
      () {
        final nested = <String, dynamic>{
          'opaque': 'fixture-opaque-secret',
          'values': [
            0,
            {'key': 'value'},
          ],
        };
        final json = <String, dynamic>{
          'type': 'future_diagnostic',
          'nested': nested,
        };
        final response = Response.fromJson({
          ..._responseJson(),
          'prompt_cache_diagnostics': json,
        });
        final unknown =
            response.promptCacheDiagnostics! as UnknownPromptCacheDiagnostics;
        final equal = Response.fromJson({
          ..._responseJson(),
          'prompt_cache_diagnostics': const {
            'nested': {
              'values': [
                0,
                {'key': 'value'},
              ],
              'opaque': 'fixture-opaque-secret',
            },
            'type': 'future_diagnostic',
          },
        });
        expect(equal, response);
        expect(equal.hashCode, response.hashCode);
        final hash = response.hashCode;
        nested['opaque'] = 'mutated';
        (nested['values'] as List<Object?>).clear();
        json['type'] = 'mutated';
        final expected = {
          'type': 'future_diagnostic',
          'nested': {
            'opaque': 'fixture-opaque-secret',
            'values': [
              0,
              {'key': 'value'},
            ],
          },
        };
        expect(unknown.toJson(), expected);
        expect(response.hashCode, hash);
        expect(() => unknown.rawJson['type'] = 'other', throwsUnsupportedError);
        expect(
          () => (unknown.rawJson['nested'] as Map<String, dynamic>)['opaque'] =
              'other',
          throwsUnsupportedError,
        );
        expect(
          () =>
              ((unknown.rawJson['nested'] as Map<String, dynamic>)['values']
                      as List<Object?>)
                  .clear(),
          throwsUnsupportedError,
        );
        expect(response.toString(), isNot(contains('fixture-opaque-secret')));
        final different = response.copyWith(
          promptCacheDiagnostics: PromptCacheDiagnostics.fromJson(const {
            'type': 'future_diagnostic',
            'nested': {'opaque': 'different'},
          }),
        );
        expect(different, isNot(response));
      },
    );
  });

  group('Response complete copy contract', () {
    test('const construction and every visible field participate', () {
      const base = Response(
        id: 'resp_fixture',
        object: 'response',
        createdAt: 0,
        status: ResponseStatus.completed,
        output: [],
      );
      final variants = <Response>[
        base.copyWith(id: 'other'),
        base.copyWith(object: 'other'),
        base.copyWith(createdAt: 1),
        base.copyWith(status: ResponseStatus.failed),
        base.copyWith(
          output: [
            OutputItem.fromJson(const {
              'type': 'message',
              'id': 'msg_fixture',
              'status': 'completed',
              'role': 'assistant',
              'content': [
                {
                  'type': 'output_text',
                  'text': 'ok',
                  'annotations': <Object>[],
                },
              ],
            }),
          ],
        ),
        base.copyWith(
          usage: const ResponseUsage(
            inputTokens: 0,
            outputTokens: 0,
            totalTokens: 0,
          ),
        ),
        base.copyWith(
          error: ResponseError.fromJson(const {
            'code': 'server_error',
            'message': 'fixture error',
          }),
        ),
        base.copyWith(
          incompleteDetails: IncompleteDetails.fromJson(const {
            'reason': 'max_output_tokens',
          }),
        ),
        base.copyWith(model: 'fixture-model'),
        base.copyWith(instructions: 'fixture instructions'),
        base.copyWith(previousResponseId: 'resp_previous'),
        base.copyWith(serviceTier: const ServiceTier('future-tier')),
        base.copyWith(metadata: {'fixture': 'value'}),
        base.copyWith(maxOutputTokens: 16),
        base.copyWith(temperature: 0.0),
        base.copyWith(topP: 0.0),
        base.copyWith(background: false),
        base.copyWith(parallelToolCalls: false),
        base.copyWith(promptCacheKey: ''),
        base.copyWith(promptCacheRetention: PromptCacheRetention.h24),
        base.copyWith(
          promptCacheOptions: const PromptCacheOptions(
            mode: PromptCacheMode.implicit,
            ttl: PromptCacheTtl.minutes30,
          ),
        ),
        base.copyWith(
          promptCacheDiagnostics: const PromptCacheDiagnostics.cacheHit(),
        ),
        base.copyWith(
          moderation: const Moderation(
            input: ModerationErrorBody(
              code: 'fixture',
              message: 'fixture error',
            ),
            output: ModerationErrorBody(
              code: 'fixture',
              message: 'fixture error',
            ),
          ),
        ),
        base.copyWith(
          reasoning: const ReasoningConfig(effort: ReasoningEffort.low),
        ),
        base.copyWith(truncation: Truncation.auto),
      ];
      for (final variant in variants) {
        expect(variant, isNot(base));
        expect(variant.copyWith(), variant);
        expect(variant.copyWith().hashCode, variant.hashCode);
      }
      final metadata = base.copyWith(metadata: {});
      expect(metadata.metadata, isEmpty);
      final output = base.copyWith(output: []);
      expect(output, base);
      for (final field in [
        'id',
        'object',
        'createdAt',
        'status',
        'output',
        'usage',
        'error',
        'incompleteDetails',
        'model',
        'instructions',
        'previousResponseId',
        'serviceTier',
        'metadata',
        'maxOutputTokens',
        'temperature',
        'topP',
        'background',
        'parallelToolCalls',
        'promptCacheKey',
        'promptCacheRetention',
        'promptCacheOptions',
        'promptCacheDiagnostics',
        'moderation',
        'reasoning',
        'truncation',
      ]) {
        expect(base.toString(), contains('$field:'));
      }
    });

    test('every populated nullable response field can be cleared', () {
      final response = Response.fromJson({
        ..._responseJson(),
        'usage': const {
          'input_tokens': 0,
          'output_tokens': 0,
          'total_tokens': 0,
        },
        'error': const {'code': 'server_error', 'message': 'fixture error'},
        'incomplete_details': const {'reason': 'max_output_tokens'},
        'model': 'fixture-model',
        'instructions': 'fixture instructions',
        'previous_response_id': 'resp_previous',
        'service_tier': 'future-tier',
        'metadata': const {'fixture': 'value'},
        'max_output_tokens': 16,
        'temperature': 0.0,
        'top_p': 0.0,
        'background': false,
        'parallel_tool_calls': false,
        'prompt_cache_key': '',
        'prompt_cache_retention': '24h',
        'prompt_cache_options': const {'mode': 'implicit', 'ttl': '30m'},
        'prompt_cache_diagnostics': const {'type': 'cache_hit'},
        'moderation': const {
          'input': {
            'type': 'error',
            'code': 'fixture',
            'message': 'fixture error',
          },
          'output': {
            'type': 'error',
            'code': 'fixture',
            'message': 'fixture error',
          },
        },
        'reasoning': const {'effort': 'low'},
        'truncation': 'auto',
      });
      final cleared = response.copyWith(
        usage: null,
        error: null,
        incompleteDetails: null,
        model: null,
        instructions: null,
        previousResponseId: null,
        serviceTier: null,
        metadata: null,
        maxOutputTokens: null,
        temperature: null,
        topP: null,
        background: null,
        parallelToolCalls: null,
        promptCacheKey: null,
        promptCacheRetention: null,
        promptCacheOptions: null,
        promptCacheDiagnostics: null,
        moderation: null,
        reasoning: null,
        truncation: null,
      );
      expect(cleared.toJson(), _responseJson());
    });
  });
}

Map<String, dynamic> _responseJson() => {
  'id': 'resp_fixture',
  'object': 'response',
  'created_at': 0,
  'status': 'completed',
  'output': <Object>[],
};
