import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CyberAccessProgram', () {
    const wireValues = {
      CyberAccessProgram.standard: 'standard',
      CyberAccessProgram.daybreakBlue: 'daybreak_blue',
      CyberAccessProgram.daybreakRed: 'daybreak_red',
    };
    for (final entry in wireValues.entries) {
      test('${entry.value} has exact wire fidelity', () {
        expect(entry.key.value, entry.value);
        expect(entry.key.toJson(), entry.value);
        expect(CyberAccessProgram.fromJson(entry.value), entry.key);
        final param = AccessProgramsParam(cyber: entry.key);
        final body = AccessProgramsBody(cyber: entry.key);
        final expected = {'cyber': entry.value};
        expect(param.toJson(), expected);
        expect(body.toJson(), expected);
        final parsedParam = AccessProgramsParam.fromJson(expected);
        final parsedBody = AccessProgramsBody.fromJson(expected);
        expect(parsedParam, param);
        expect(parsedParam.hashCode, param.hashCode);
        expect(parsedBody, body);
        expect(parsedBody.hashCode, body.hashCode);
      });
    }
    for (final unknown in ['', 'future-program', 'Standard', 'daybreakBlue']) {
      test('unknown "$unknown" has no meaningful enum fallback', () {
        expect(CyberAccessProgram.fromJson(unknown), isNull);
        expect(
          () => AccessProgramsParam.fromJson({'cyber': unknown}),
          _formatError('AccessProgramsParam.cyber'),
        );
        expect(
          () => AccessProgramsBody.fromJson({'cyber': unknown}),
          _formatError('AccessProgramsBody.cyber'),
        );
      });
    }
  });

  group('AccessProgramsParam and AccessProgramsBody', () {
    test('request omission is an empty object, not explicit Standard', () {
      const empty = AccessProgramsParam();
      const explicit = AccessProgramsParam(cyber: CyberAccessProgram.standard);
      expect(empty.toJson(), <String, dynamic>{});
      expect(AccessProgramsParam.fromJson(const {}), empty);
      expect(empty, isNot(explicit));
      expect(explicit.toJson(), {'cyber': 'standard'});
      expect(empty.toString(), 'AccessProgramsParam(cyber: null)');
    });

    test('returned body requires cyber instead of inventing a selection', () {
      expect(
        () => AccessProgramsBody.fromJson(const {}),
        _formatError('AccessProgramsBody.cyber'),
      );
    });

    for (final invalid in <Object?>[null, 0, false, [], {}]) {
      test('nonnull string validation rejects ${invalid.runtimeType}', () {
        expect(
          () => AccessProgramsParam.fromJson({'cyber': invalid}),
          _formatError('AccessProgramsParam.cyber'),
        );
        expect(
          () => AccessProgramsBody.fromJson({'cyber': invalid}),
          _formatError('AccessProgramsBody.cyber'),
        );
      });
    }

    test('closed request rejects unknown fields without printing contents', () {
      for (final json in [
        {'future-field': 'opaque-private'},
        {'cyber': 'standard', 'future-field': 'opaque-private'},
      ]) {
        expect(
          () => AccessProgramsParam.fromJson(json),
          throwsA(
            isA<FormatException>()
                .having(
                  (e) => e.message,
                  'context',
                  contains('AccessProgramsParam'),
                )
                .having(
                  (e) => e.message,
                  'safe diagnostic',
                  isNot(contains('opaque-private')),
                ),
          ),
        );
      }
    });

    test('returned body tolerates unrelated extra provider fields', () {
      expect(
        AccessProgramsBody.fromJson(const {
          'cyber': 'standard',
          'future-field': 'opaque-private',
        }),
        const AccessProgramsBody(cyber: CyberAccessProgram.standard),
      );
    });

    test('const leaves retain, replace, clear and compare every field', () {
      const param = AccessProgramsParam(cyber: CyberAccessProgram.daybreakBlue);
      const body = AccessProgramsBody(cyber: CyberAccessProgram.daybreakBlue);
      expect(param.copyWith(), param);
      expect(param.copyWith().hashCode, param.hashCode);
      expect(body.copyWith(), body);
      expect(body.copyWith().hashCode, body.hashCode);
      expect(param.copyWith(cyber: null), const AccessProgramsParam());
      expect(param.copyWith(cyber: null).toJson(), <String, dynamic>{});
      expect(
        param.copyWith(cyber: CyberAccessProgram.daybreakRed),
        const AccessProgramsParam(cyber: CyberAccessProgram.daybreakRed),
      );
      expect(
        body.copyWith(cyber: CyberAccessProgram.daybreakRed),
        const AccessProgramsBody(cyber: CyberAccessProgram.daybreakRed),
      );
      expect(body.copyWith(cyber: null), body);
      expect(param.copyWith(cyber: CyberAccessProgram.standard), isNot(param));
      expect(body.copyWith(cyber: CyberAccessProgram.standard), isNot(body));
      expect({param, param.copyWith()}, hasLength(1));
      expect({body, body.copyWith()}, hasLength(1));
      expect(
        param.toString(),
        'AccessProgramsParam(cyber: CyberAccessProgram.daybreakBlue)',
      );
      expect(
        body.toString(),
        'AccessProgramsBody(cyber: CyberAccessProgram.daybreakBlue)',
      );
      expect(param == (body as Object), isFalse);
      expect(body == (param as Object), isFalse);
    });

    test('runtime type guards preserve symmetric subclass inequality', () {
      const param = AccessProgramsParam(cyber: CyberAccessProgram.standard);
      const childParam = _ParamSubclass(cyber: CyberAccessProgram.standard);
      const body = AccessProgramsBody(cyber: CyberAccessProgram.standard);
      const childBody = _BodySubclass(cyber: CyberAccessProgram.standard);
      expect(param == childParam, isFalse);
      expect(childParam == param, isFalse);
      expect(body == childBody, isFalse);
      expect(childBody == body, isFalse);
      expect(childParam, childParam);
      expect(childBody, childBody);
    });
  });

  group('Request access-program holder', () {
    const minimal = CreateResponseRequest(
      model: 'fixture-model',
      input: ResponseInput.text('fixture input'),
    );
    test(
      'const omission, empty object and explicit selection stay distinct',
      () {
        expect(minimal.toJson(), {
          'model': 'fixture-model',
          'input': 'fixture input',
        });
        const empty = CreateResponseRequest(
          model: 'fixture-model',
          input: ResponseInput.text('fixture input'),
          accessPrograms: AccessProgramsParam(),
        );
        expect(empty.toJson()['access_programs'], <String, dynamic>{});
        expect(empty, isNot(minimal));
        expect(CreateResponseRequest.fromJson(empty.toJson()), empty);
        expect(empty.copyWith(accessPrograms: null), minimal);
        for (final program in CyberAccessProgram.values) {
          final request = minimal.copyWith(
            accessPrograms: AccessProgramsParam(cyber: program),
          );
          expect(request.toJson()['access_programs'], {
            'cyber': program.toJson(),
          });
          expect(request.copyWith(), request);
          expect(request.copyWith().hashCode, request.hashCode);
          final parsed = CreateResponseRequest.fromJson(request.toJson());
          expect(parsed, request);
          expect(parsed.hashCode, request.hashCode);
          expect(request.copyWith(accessPrograms: null), minimal);
        }
      },
    );

    final invalids = <Object?>[
      null,
      0,
      false,
      'standard',
      [],
      {'cyber': null},
      {'cyber': false},
      {'cyber': 0},
      {'cyber': <Object>[]},
      {'cyber': <String, Object>{}},
      {'cyber': 'future-program'},
      {'future-field': 'opaque-private'},
      <dynamic, dynamic>{0: 'opaque-private'},
    ];
    for (var index = 0; index < invalids.length; index++) {
      test('malformed supplied request selection $index is contextual', () {
        expect(
          () => CreateResponseRequest.fromJson({
            ...minimal.toJson(),
            'access_programs': invalids[index],
          }),
          _formatError('CreateResponseRequest.access_programs'),
        );
      });
    }

    test(
      'string-keyed dynamic map normalization preserves exact selection',
      () {
        final request = CreateResponseRequest.fromJson({
          ...minimal.toJson(),
          'access_programs': const <dynamic, dynamic>{'cyber': 'daybreak_blue'},
        });
        expect(
          request.accessPrograms,
          const AccessProgramsParam(cyber: CyberAccessProgram.daybreakBlue),
        );
      },
    );

    test('existing parent unknown-key tolerance is unchanged', () {
      expect(
        CreateResponseRequest.fromJson({
          ...minimal.toJson(),
          'future-parent-field': 'opaque-private',
        }),
        minimal,
      );
    });
  });

  group('Response access-program holder', () {
    const minimal = Response(
      id: 'resp_fixture',
      object: 'response',
      createdAt: 0,
      status: ResponseStatus.completed,
      output: [],
    );
    test(
      'omitted and explicit null remain compatible and normalize omission',
      () {
        final omitted = Response.fromJson(minimal.toJson());
        final nullable = Response.fromJson({
          ...minimal.toJson(),
          'access_programs': null,
        });
        expect(omitted, minimal);
        expect(nullable, minimal);
        expect(nullable.hashCode, omitted.hashCode);
        expect(nullable.toJson(), minimal.toJson());
        expect(nullable.toJson().containsKey('access_programs'), isFalse);
      },
    );

    for (final program in CyberAccessProgram.values) {
      test('${program.value} result participates in the complete contract', () {
        final response = minimal.copyWith(
          accessPrograms: AccessProgramsBody(cyber: program),
        );
        expect(response, isNot(minimal));
        expect(response.toJson()['access_programs'], {
          'cyber': program.toJson(),
        });
        final parsed = Response.fromJson(response.toJson());
        expect(parsed, response);
        expect(parsed.hashCode, response.hashCode);
        expect(response.copyWith(), response);
        expect(response.copyWith().hashCode, response.hashCode);
        expect(response.copyWith(accessPrograms: null), minimal);
        expect(response.toString(), contains('accessPrograms:'));
      });
    }

    final invalids = <Object?>[
      0,
      false,
      'standard',
      [],
      {},
      {'cyber': null},
      {'cyber': false},
      {'cyber': 0},
      {'cyber': <Object>[]},
      {'cyber': <String, Object>{}},
      {'cyber': 'future-program'},
      <dynamic, dynamic>{0: 'opaque-private'},
    ];
    for (var index = 0; index < invalids.length; index++) {
      test('malformed supplied response selection $index is contextual', () {
        expect(
          () => Response.fromJson({
            ...minimal.toJson(),
            'access_programs': invalids[index],
          }),
          _formatError('Response.access_programs'),
        );
      });
    }

    test('const result and dynamic-map provider parsing are supported', () {
      const response = Response(
        id: 'resp_fixture',
        object: 'response',
        createdAt: 0,
        status: ResponseStatus.completed,
        output: [],
        accessPrograms: AccessProgramsBody(cyber: CyberAccessProgram.standard),
      );
      final parsed = Response.fromJson({
        ...minimal.toJson(),
        'access_programs': const <dynamic, dynamic>{'cyber': 'standard'},
      });
      expect(parsed, response);
      expect(parsed.hashCode, response.hashCode);
    });

    test('ResponseList centrally retains each effective program', () {
      final json = {
        'object': 'list',
        'has_more': false,
        'data': [
          for (final program in CyberAccessProgram.values)
            {
              ...minimal.toJson(),
              'id': 'resp_${program.value}',
              'access_programs': {'cyber': program.value},
            },
        ],
      };
      final list = ResponseList.fromJson(json);
      expect(
        list.data.map((response) => response.accessPrograms!.cyber),
        CyberAccessProgram.values,
      );
      expect(list.toJson(), json);
      expect(ResponseList.fromJson(list.toJson()), list);
      expect(ResponseList.fromJson(list.toJson()).hashCode, list.hashCode);
    });
  });

  _parentContractTests();
}

Matcher _formatError(String context) => throwsA(
  isA<FormatException>().having(
    (error) => error.message,
    'context',
    contains(context),
  ),
);

class _ParamSubclass extends AccessProgramsParam {
  const _ParamSubclass({super.cyber});
}

class _BodySubclass extends AccessProgramsBody {
  const _BodySubclass({required super.cyber});
}

class _RequestSubclass extends CreateResponseRequest {
  const _RequestSubclass()
    : super(
        model: 'fixture-model',
        input: const ResponseInput.text('fixture input'),
        accessPrograms: const AccessProgramsParam(
          cyber: CyberAccessProgram.daybreakBlue,
        ),
      );
}

class _ResponseSubclass extends Response {
  const _ResponseSubclass()
    : super(
        id: 'resp_fixture',
        object: 'response',
        createdAt: 0,
        status: ResponseStatus.completed,
        output: const [],
        accessPrograms: const AccessProgramsBody(
          cyber: CyberAccessProgram.daybreakBlue,
        ),
      );
}

const _fullRequest = CreateResponseRequest(
  model: 'fixture-model',
  input: ResponseInput.text('input-private'),
  instructions: 'instructions-private',
  tools: [
    FunctionTool(
      name: 'function-private',
      description: 'description-private',
      parameters: {'type': 'object'},
      strict: true,
    ),
  ],
  toolChoice: ResponseToolChoice.auto,
  previousResponseId: 'previous-private',
  maxOutputTokens: 16,
  temperature: 0.5,
  topP: 0.7,
  presencePenalty: 0.1,
  frequencyPenalty: 0.2,
  stream: false,
  streamOptions: StreamOptions(includeUsage: false),
  reasoning: ReasoningConfig(
    effort: ReasoningEffort.low,
    context: ReasoningContext.allTurns,
    mode: ReasoningMode.custom('reasoning-private'),
  ),
  text: TextConfig(format: JsonObjectFormat(), verbosity: Verbosity.low),
  truncation: Truncation.auto,
  contextManagement: [ContextManagement.compaction(compactThreshold: 200000)],
  parallelToolCalls: false,
  serviceTier: ServiceTier.priority,
  metadata: {'metadata-private': 'value-private'},
  include: [Include.reasoningEncryptedContent],
  store: false,
  background: false,
  maxToolCalls: 3,
  safetyIdentifier: 'safety-private',
  moderation: ModerationConfig(model: 'moderation-private'),
  promptCacheKey: 'cache-private',
  promptCacheOptions: ResponsePromptCacheOptionsParam(
    mode: PromptCacheMode.explicit,
    ttl: PromptCacheTtl.minutes30,
    comparisonResponseId: 'comparison-private',
    prewarm: false,
  ),
  promptCacheRetention: PromptCacheRetention.h24,
  topLogprobs: 2,
  multiAgent: MultiAgentConfig(enabled: true, maxConcurrentSubagents: 3),
  accessPrograms: AccessProgramsParam(cyber: CyberAccessProgram.daybreakBlue),
);

const _fullResponse = Response(
  id: 'resp_fixture',
  object: 'response',
  createdAt: 0,
  status: ResponseStatus.completed,
  output: [
    CompactionOutputItem(id: 'cmp_fixture', encryptedContent: 'output-private'),
  ],
  usage: ResponseUsage(inputTokens: 1, outputTokens: 2, totalTokens: 3),
  error: ResponseError(
    type: 'error',
    code: 'server_error',
    message: 'error-private',
  ),
  incompleteDetails: IncompleteDetails(reason: 'max_output_tokens'),
  model: 'fixture-model',
  instructions: 'instructions-private',
  previousResponseId: 'previous-private',
  serviceTier: ServiceTier.priority,
  metadata: {'metadata-private': 'value-private'},
  maxOutputTokens: 16,
  temperature: 0.5,
  topP: 0.7,
  background: false,
  parallelToolCalls: false,
  promptCacheKey: 'cache-private',
  promptCacheRetention: PromptCacheRetention.h24,
  promptCacheOptions: PromptCacheOptions(
    mode: PromptCacheMode.explicit,
    ttl: PromptCacheTtl.minutes30,
    comparisonResponseId: 'comparison-private',
  ),
  promptCacheDiagnostics: PromptCacheDiagnostics.cacheHit(),
  moderation: Moderation(
    input: ModerationErrorBody(code: 'fixture', message: 'moderation-private'),
    output: ModerationErrorBody(code: 'fixture', message: 'moderation-private'),
  ),
  reasoning: ReasoningConfig(
    effort: ReasoningEffort.low,
    context: ReasoningContext.allTurns,
    mode: ReasoningMode.custom('reasoning-private'),
  ),
  truncation: Truncation.auto,
  accessPrograms: AccessProgramsBody(cyber: CyberAccessProgram.daybreakBlue),
);

void _parentContractTests() {
  group('CreateResponseRequest complete field contracts', () {
    final cases =
        <
          ({
            String name,
            String key,
            Object? value,
            CreateResponseRequest Function(CreateResponseRequest) replace,
            CreateResponseRequest Function(CreateResponseRequest)? clear,
          })
        >[
          (
            name: 'model',
            key: 'model',
            value: 'different-model',
            replace: (r) => r.copyWith(model: 'different-model'),
            clear: null,
          ),
          (
            name: 'input',
            key: 'input',
            value: 'different input',
            replace: (r) =>
                r.copyWith(input: const ResponseInput.text('different input')),
            clear: null,
          ),
          (
            name: 'instructions',
            key: 'instructions',
            value: 'different instructions',
            replace: (r) => r.copyWith(instructions: 'different instructions'),
            clear: (r) => r.copyWith(instructions: null),
          ),
          (
            name: 'tools',
            key: 'tools',
            value: const <Object>[],
            replace: (r) => r.copyWith(tools: const <ResponseTool>[]),
            clear: (r) => r.copyWith(tools: null),
          ),
          (
            name: 'toolChoice',
            key: 'tool_choice',
            value: 'none',
            replace: (r) => r.copyWith(toolChoice: ResponseToolChoice.none),
            clear: (r) => r.copyWith(toolChoice: null),
          ),
          (
            name: 'previousResponseId',
            key: 'previous_response_id',
            value: 'different-id',
            replace: (r) => r.copyWith(previousResponseId: 'different-id'),
            clear: (r) => r.copyWith(previousResponseId: null),
          ),
          (
            name: 'maxOutputTokens',
            key: 'max_output_tokens',
            value: 32,
            replace: (r) => r.copyWith(maxOutputTokens: 32),
            clear: (r) => r.copyWith(maxOutputTokens: null),
          ),
          (
            name: 'temperature',
            key: 'temperature',
            value: 1.0,
            replace: (r) => r.copyWith(temperature: 1.0),
            clear: (r) => r.copyWith(temperature: null),
          ),
          (
            name: 'topP',
            key: 'top_p',
            value: 0.9,
            replace: (r) => r.copyWith(topP: 0.9),
            clear: (r) => r.copyWith(topP: null),
          ),
          (
            name: 'presencePenalty',
            key: 'presence_penalty',
            value: 0.3,
            replace: (r) => r.copyWith(presencePenalty: 0.3),
            clear: (r) => r.copyWith(presencePenalty: null),
          ),
          (
            name: 'frequencyPenalty',
            key: 'frequency_penalty',
            value: 0.4,
            replace: (r) => r.copyWith(frequencyPenalty: 0.4),
            clear: (r) => r.copyWith(frequencyPenalty: null),
          ),
          (
            name: 'stream',
            key: 'stream',
            value: true,
            replace: (r) => r.copyWith(stream: true),
            clear: (r) => r.copyWith(stream: null),
          ),
          (
            name: 'streamOptions',
            key: 'stream_options',
            value: const {'include_usage': true},
            replace: (r) => r.copyWith(
              streamOptions: const StreamOptions(includeUsage: true),
            ),
            clear: (r) => r.copyWith(streamOptions: null),
          ),
          (
            name: 'reasoning',
            key: 'reasoning',
            value: const {'effort': 'high'},
            replace: (r) => r.copyWith(
              reasoning: const ReasoningConfig(effort: ReasoningEffort.high),
            ),
            clear: (r) => r.copyWith(reasoning: null),
          ),
          (
            name: 'text',
            key: 'text',
            value: const {
              'format': {'type': 'text'},
            },
            replace: (r) =>
                r.copyWith(text: const TextConfig(format: PlainTextFormat())),
            clear: (r) => r.copyWith(text: null),
          ),
          (
            name: 'truncation',
            key: 'truncation',
            value: 'disabled',
            replace: (r) => r.copyWith(truncation: Truncation.disabled),
            clear: (r) => r.copyWith(truncation: null),
          ),
          (
            name: 'contextManagement',
            key: 'context_management',
            value: const <Object>[],
            replace: (r) =>
                r.copyWith(contextManagement: const <ContextManagement>[]),
            clear: (r) => r.copyWith(contextManagement: null),
          ),
          (
            name: 'parallelToolCalls',
            key: 'parallel_tool_calls',
            value: true,
            replace: (r) => r.copyWith(parallelToolCalls: true),
            clear: (r) => r.copyWith(parallelToolCalls: null),
          ),
          (
            name: 'serviceTier',
            key: 'service_tier',
            value: 'flex',
            replace: (r) => r.copyWith(serviceTier: ServiceTier.flex),
            clear: (r) => r.copyWith(serviceTier: null),
          ),
          (
            name: 'metadata',
            key: 'metadata',
            value: const {'different': 'value'},
            replace: (r) => r.copyWith(metadata: const {'different': 'value'}),
            clear: (r) => r.copyWith(metadata: null),
          ),
          (
            name: 'include',
            key: 'include',
            value: const <Object>[],
            replace: (r) => r.copyWith(include: const <Include>[]),
            clear: (r) => r.copyWith(include: null),
          ),
          (
            name: 'store',
            key: 'store',
            value: true,
            replace: (r) => r.copyWith(store: true),
            clear: (r) => r.copyWith(store: null),
          ),
          (
            name: 'background',
            key: 'background',
            value: true,
            replace: (r) => r.copyWith(background: true),
            clear: (r) => r.copyWith(background: null),
          ),
          (
            name: 'maxToolCalls',
            key: 'max_tool_calls',
            value: 4,
            replace: (r) => r.copyWith(maxToolCalls: 4),
            clear: (r) => r.copyWith(maxToolCalls: null),
          ),
          (
            name: 'safetyIdentifier',
            key: 'safety_identifier',
            value: 'different-safety',
            replace: (r) => r.copyWith(safetyIdentifier: 'different-safety'),
            clear: (r) => r.copyWith(safetyIdentifier: null),
          ),
          (
            name: 'moderation',
            key: 'moderation',
            value: const {'model': 'different-model'},
            replace: (r) => r.copyWith(
              moderation: const ModerationConfig(model: 'different-model'),
            ),
            clear: (r) => r.copyWith(moderation: null),
          ),
          (
            name: 'promptCacheKey',
            key: 'prompt_cache_key',
            value: 'different-cache',
            replace: (r) => r.copyWith(promptCacheKey: 'different-cache'),
            clear: (r) => r.copyWith(promptCacheKey: null),
          ),
          (
            name: 'promptCacheOptions',
            key: 'prompt_cache_options',
            value: const {'prewarm': true},
            replace: (r) => r.copyWith(
              promptCacheOptions: const ResponsePromptCacheOptionsParam(
                prewarm: true,
              ),
            ),
            clear: (r) => r.copyWith(promptCacheOptions: null),
          ),
          (
            name: 'promptCacheRetention',
            key: 'prompt_cache_retention',
            value: 'in_memory',
            replace: (r) =>
                r.copyWith(promptCacheRetention: PromptCacheRetention.inMemory),
            clear: (r) => r.copyWith(promptCacheRetention: null),
          ),
          (
            name: 'topLogprobs',
            key: 'top_logprobs',
            value: 3,
            replace: (r) => r.copyWith(topLogprobs: 3),
            clear: (r) => r.copyWith(topLogprobs: null),
          ),
          (
            name: 'multiAgent',
            key: 'multi_agent',
            value: const {'enabled': false},
            replace: (r) =>
                r.copyWith(multiAgent: const MultiAgentConfig(enabled: false)),
            clear: (r) => r.copyWith(multiAgent: null),
          ),
          (
            name: 'accessPrograms',
            key: 'access_programs',
            value: const {'cyber': 'daybreak_red'},
            replace: (r) => r.copyWith(
              accessPrograms: const AccessProgramsParam(
                cyber: CyberAccessProgram.daybreakRed,
              ),
            ),
            clear: (r) => r.copyWith(accessPrograms: null),
          ),
        ];
    test(
      'const full fixture preserves all serialization, value and diagnostics',
      () {
        expect(_fullRequest.toJson(), _fullRequestJson);
        final parsed = CreateResponseRequest.fromJson(_fullRequestJson);
        expect(parsed, _fullRequest);
        expect(parsed.hashCode, _fullRequest.hashCode);
        expect(_fullRequest.copyWith(), _fullRequest);
        expect(_fullRequest.copyWith().hashCode, _fullRequest.hashCode);
        expect(_fullRequest.toString(), isNot(contains('-private')));
        for (final entry in cases) {
          expect(_fullRequest.toString(), contains('${entry.name}:'));
        }
      },
    );
    for (final entry in cases) {
      test(
        '${entry.name} copy replaces only this field, parses and compares',
        () {
          final changed = entry.replace(_fullRequest);
          final expected = {..._fullRequestJson, entry.key: entry.value};
          expect(changed.toJson(), expected);
          expect(changed, isNot(_fullRequest));
          final parsed = CreateResponseRequest.fromJson(expected);
          expect(parsed, changed);
          expect(parsed.hashCode, changed.hashCode);
          expect(changed.copyWith(), changed);
          expect(changed.copyWith().hashCode, changed.hashCode);
          expect({changed, parsed, changed.copyWith()}, hasLength(1));
        },
      );
      if (entry.clear case final clear?) {
        test(
          '${entry.name} clears explicitly while retaining other fields',
          () {
            final cleared = clear(_fullRequest);
            final expected = Map<String, dynamic>.of(_fullRequestJson)
              ..remove(entry.key);
            expect(cleared.toJson(), expected);
            expect(cleared, isNot(_fullRequest));
            final parsed = CreateResponseRequest.fromJson(expected);
            expect(cleared, parsed);
            expect(cleared.hashCode, parsed.hashCode);
            expect(cleared.copyWith(), cleared);
          },
        );
      }
    }
  });
  group('Response complete field contracts', () {
    final cases =
        <
          ({
            String name,
            String key,
            Object? value,
            Response Function(Response) replace,
            Response Function(Response)? clear,
          })
        >[
          (
            name: 'id',
            key: 'id',
            value: 'resp_other',
            replace: (r) => r.copyWith(id: 'resp_other'),
            clear: null,
          ),
          (
            name: 'object',
            key: 'object',
            value: 'different',
            replace: (r) => r.copyWith(object: 'different'),
            clear: null,
          ),
          (
            name: 'createdAt',
            key: 'created_at',
            value: 1,
            replace: (r) => r.copyWith(createdAt: 1),
            clear: null,
          ),
          (
            name: 'status',
            key: 'status',
            value: 'failed',
            replace: (r) => r.copyWith(status: ResponseStatus.failed),
            clear: null,
          ),
          (
            name: 'output',
            key: 'output',
            value: const <Object>[],
            replace: (r) => r.copyWith(output: const <OutputItem>[]),
            clear: null,
          ),
          (
            name: 'usage',
            key: 'usage',
            value: const {
              'input_tokens': 2,
              'output_tokens': 2,
              'total_tokens': 4,
            },
            replace: (r) => r.copyWith(
              usage: const ResponseUsage(
                inputTokens: 2,
                outputTokens: 2,
                totalTokens: 4,
              ),
            ),
            clear: (r) => r.copyWith(usage: null),
          ),
          (
            name: 'error',
            key: 'error',
            value: const {
              'type': 'error',
              'code': 'server_error',
              'message': 'different',
            },
            replace: (r) => r.copyWith(
              error: const ResponseError(
                type: 'error',
                code: 'server_error',
                message: 'different',
              ),
            ),
            clear: (r) => r.copyWith(error: null),
          ),
          (
            name: 'incompleteDetails',
            key: 'incomplete_details',
            value: const {'reason': 'content_filter'},
            replace: (r) => r.copyWith(
              incompleteDetails: const IncompleteDetails(
                reason: 'content_filter',
              ),
            ),
            clear: (r) => r.copyWith(incompleteDetails: null),
          ),
          (
            name: 'model',
            key: 'model',
            value: 'different-model',
            replace: (r) => r.copyWith(model: 'different-model'),
            clear: (r) => r.copyWith(model: null),
          ),
          (
            name: 'instructions',
            key: 'instructions',
            value: 'different instructions',
            replace: (r) => r.copyWith(instructions: 'different instructions'),
            clear: (r) => r.copyWith(instructions: null),
          ),
          (
            name: 'previousResponseId',
            key: 'previous_response_id',
            value: 'different-id',
            replace: (r) => r.copyWith(previousResponseId: 'different-id'),
            clear: (r) => r.copyWith(previousResponseId: null),
          ),
          (
            name: 'serviceTier',
            key: 'service_tier',
            value: 'flex',
            replace: (r) => r.copyWith(serviceTier: ServiceTier.flex),
            clear: (r) => r.copyWith(serviceTier: null),
          ),
          (
            name: 'metadata',
            key: 'metadata',
            value: const {'different': 'value'},
            replace: (r) => r.copyWith(metadata: const {'different': 'value'}),
            clear: (r) => r.copyWith(metadata: null),
          ),
          (
            name: 'maxOutputTokens',
            key: 'max_output_tokens',
            value: 32,
            replace: (r) => r.copyWith(maxOutputTokens: 32),
            clear: (r) => r.copyWith(maxOutputTokens: null),
          ),
          (
            name: 'temperature',
            key: 'temperature',
            value: 1.0,
            replace: (r) => r.copyWith(temperature: 1.0),
            clear: (r) => r.copyWith(temperature: null),
          ),
          (
            name: 'topP',
            key: 'top_p',
            value: 0.9,
            replace: (r) => r.copyWith(topP: 0.9),
            clear: (r) => r.copyWith(topP: null),
          ),
          (
            name: 'background',
            key: 'background',
            value: true,
            replace: (r) => r.copyWith(background: true),
            clear: (r) => r.copyWith(background: null),
          ),
          (
            name: 'parallelToolCalls',
            key: 'parallel_tool_calls',
            value: true,
            replace: (r) => r.copyWith(parallelToolCalls: true),
            clear: (r) => r.copyWith(parallelToolCalls: null),
          ),
          (
            name: 'promptCacheKey',
            key: 'prompt_cache_key',
            value: 'different-cache',
            replace: (r) => r.copyWith(promptCacheKey: 'different-cache'),
            clear: (r) => r.copyWith(promptCacheKey: null),
          ),
          (
            name: 'promptCacheRetention',
            key: 'prompt_cache_retention',
            value: 'in_memory',
            replace: (r) =>
                r.copyWith(promptCacheRetention: PromptCacheRetention.inMemory),
            clear: (r) => r.copyWith(promptCacheRetention: null),
          ),
          (
            name: 'promptCacheOptions',
            key: 'prompt_cache_options',
            value: const {'mode': 'implicit', 'ttl': '30m'},
            replace: (r) => r.copyWith(
              promptCacheOptions: const PromptCacheOptions(
                mode: PromptCacheMode.implicit,
                ttl: PromptCacheTtl.minutes30,
              ),
            ),
            clear: (r) => r.copyWith(promptCacheOptions: null),
          ),
          (
            name: 'promptCacheDiagnostics',
            key: 'prompt_cache_diagnostics',
            value: const {'type': 'unavailable'},
            replace: (r) => r.copyWith(
              promptCacheDiagnostics:
                  const PromptCacheDiagnostics.unavailable(),
            ),
            clear: (r) => r.copyWith(promptCacheDiagnostics: null),
          ),
          (
            name: 'moderation',
            key: 'moderation',
            value: const {
              'input': {
                'type': 'error',
                'code': 'different',
                'message': 'different',
              },
              'output': {
                'type': 'error',
                'code': 'different',
                'message': 'different',
              },
            },
            replace: (r) => r.copyWith(
              moderation: const Moderation(
                input: ModerationErrorBody(
                  code: 'different',
                  message: 'different',
                ),
                output: ModerationErrorBody(
                  code: 'different',
                  message: 'different',
                ),
              ),
            ),
            clear: (r) => r.copyWith(moderation: null),
          ),
          (
            name: 'reasoning',
            key: 'reasoning',
            value: const {'effort': 'high'},
            replace: (r) => r.copyWith(
              reasoning: const ReasoningConfig(effort: ReasoningEffort.high),
            ),
            clear: (r) => r.copyWith(reasoning: null),
          ),
          (
            name: 'truncation',
            key: 'truncation',
            value: 'disabled',
            replace: (r) => r.copyWith(truncation: Truncation.disabled),
            clear: (r) => r.copyWith(truncation: null),
          ),
          (
            name: 'accessPrograms',
            key: 'access_programs',
            value: const {'cyber': 'daybreak_red'},
            replace: (r) => r.copyWith(
              accessPrograms: const AccessProgramsBody(
                cyber: CyberAccessProgram.daybreakRed,
              ),
            ),
            clear: (r) => r.copyWith(accessPrograms: null),
          ),
        ];
    test(
      'const full fixture preserves all serialization, value and diagnostics',
      () {
        expect(_fullResponse.toJson(), _fullResponseJson);
        final parsed = Response.fromJson(_fullResponseJson);
        expect(parsed, _fullResponse);
        expect(parsed.hashCode, _fullResponse.hashCode);
        expect(_fullResponse.copyWith(), _fullResponse);
        expect(_fullResponse.copyWith().hashCode, _fullResponse.hashCode);
        expect(_fullResponse.toString(), isNot(contains('-private')));
        for (final entry in cases) {
          expect(_fullResponse.toString(), contains('${entry.name}:'));
        }
      },
    );
    for (final entry in cases) {
      test(
        '${entry.name} copy replaces only this field, parses and compares',
        () {
          final changed = entry.replace(_fullResponse);
          final expected = {..._fullResponseJson, entry.key: entry.value};
          expect(changed.toJson(), expected);
          expect(changed, isNot(_fullResponse));
          final parsed = Response.fromJson(expected);
          expect(parsed, changed);
          expect(parsed.hashCode, changed.hashCode);
          expect(changed.copyWith(), changed);
          expect(changed.copyWith().hashCode, changed.hashCode);
          expect({changed, parsed, changed.copyWith()}, hasLength(1));
        },
      );
      if (entry.clear case final clear?) {
        test(
          '${entry.name} clears explicitly while retaining other fields',
          () {
            final cleared = clear(_fullResponse);
            final expected = Map<String, dynamic>.of(_fullResponseJson)
              ..remove(entry.key);
            expect(cleared.toJson(), expected);
            expect(cleared, isNot(_fullResponse));
            final parsed = Response.fromJson(expected);
            expect(cleared, parsed);
            expect(cleared.hashCode, parsed.hashCode);
            expect(cleared.copyWith(), cleared);
          },
        );
      }
    }
  });

  test('parent runtime type guards remain symmetric with the new field', () {
    const request = CreateResponseRequest(
      model: 'fixture-model',
      input: ResponseInput.text('fixture input'),
      accessPrograms: AccessProgramsParam(
        cyber: CyberAccessProgram.daybreakBlue,
      ),
    );
    const response = Response(
      id: 'resp_fixture',
      object: 'response',
      createdAt: 0,
      status: ResponseStatus.completed,
      output: [],
      accessPrograms: AccessProgramsBody(
        cyber: CyberAccessProgram.daybreakBlue,
      ),
    );
    const childRequest = _RequestSubclass();
    const childResponse = _ResponseSubclass();
    expect(request == childRequest, isFalse);
    expect(childRequest == request, isFalse);
    expect(response == childResponse, isFalse);
    expect(childResponse == response, isFalse);
  });

  test('nested request metadata remains deep and independent of map order', () {
    final first = _fullRequest.copyWith(
      metadata: {
        'nested': {
          'a': 1,
          'b': [
            true,
            {'c': 2},
          ],
        },
        'other': 'value',
      },
    );
    final second = _fullRequest.copyWith(
      metadata: {
        'other': 'value',
        'nested': {
          'b': [
            true,
            {'c': 2},
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
            'a': 2,
            'b': [
              true,
              {'c': 2},
            ],
          },
          'other': 'value',
        },
      ),
      isNot(first),
    );
    final normalized = CreateResponseRequest.fromJson(first.toJson());
    expect(normalized.accessPrograms, first.accessPrograms);
    expect(normalized.metadata!.values, everyElement(isA<String>()));
    expect(
      first.copyWith(metadata: {'null': null}).toJson().containsKey('metadata'),
      isFalse,
    );
    expect(
      first
          .copyWith(metadata: <String, dynamic>{})
          .toJson()
          .containsKey('metadata'),
      isFalse,
    );
    expect(
      first
          .copyWith(metadata: {'zero': 0, 'false': false, 'null': null})
          .toJson()['metadata'],
      {'zero': '0', 'false': 'false'},
    );
  });

  test('response metadata hash remains independent of map insertion order', () {
    final first = _fullResponse.copyWith(metadata: {'a': '1', 'b': '2'});
    final second = _fullResponse.copyWith(metadata: {'b': '2', 'a': '1'});
    expect(second, first);
    expect(second.hashCode, first.hashCode);
    expect(second.copyWith(metadata: {'a': '1', 'b': '3'}), isNot(first));
  });

  test(
    'existing caller-owned collections survive request selection copies',
    () {
      final tools = <ResponseTool>[];
      final context = <ContextManagement>[];
      final include = <Include>[];
      final metadata = <String, dynamic>{'a': 1};
      final request = CreateResponseRequest(
        model: 'fixture-model',
        input: const ResponseInput.text('fixture input'),
        tools: tools,
        contextManagement: context,
        include: include,
        metadata: metadata,
        accessPrograms: const AccessProgramsParam(
          cyber: CyberAccessProgram.daybreakBlue,
        ),
      );
      final copied = request.copyWith(accessPrograms: null);
      expect(identical(request.tools, tools), isTrue);
      expect(identical(copied.tools, tools), isTrue);
      expect(identical(copied.contextManagement, context), isTrue);
      expect(identical(copied.include, include), isTrue);
      expect(identical(copied.metadata, metadata), isTrue);
      tools.add(
        const FunctionTool(name: 'fixture', parameters: {'type': 'object'}),
      );
      context.add(const ContextManagement.compaction());
      include.add(Include.reasoningEncryptedContent);
      metadata['a'] = 2;
      expect(copied.toJson()['tools'], hasLength(1));
      expect(copied.toJson()['context_management'], [
        {'type': 'compaction'},
      ]);
      expect(copied.toJson()['include'], ['reasoning.encrypted_content']);
      expect(copied.toJson()['metadata'], {'a': '2'});
      expect(request.accessPrograms, isNotNull);
      expect(copied.accessPrograms, isNull);
    },
  );

  test(
    'existing response collection ownership and metadata copy remain intact',
    () {
      final output = <OutputItem>[];
      final metadata = <String, String>{'a': '1'};
      final response = Response(
        id: 'resp_fixture',
        object: 'response',
        createdAt: 0,
        status: ResponseStatus.completed,
        output: output,
        metadata: metadata,
        accessPrograms: const AccessProgramsBody(
          cyber: CyberAccessProgram.daybreakBlue,
        ),
      );
      final copied = response.copyWith(accessPrograms: null);
      expect(identical(response.output, output), isTrue);
      expect(identical(copied.output, output), isTrue);
      expect(identical(response.metadata, metadata), isTrue);
      expect(identical(copied.metadata, metadata), isTrue);
      final replacement = <String, String>{'new': 'value'};
      final metadataCopy = response.copyWith(metadata: replacement);
      replacement['new'] = 'changed';
      expect(metadataCopy.metadata, {'new': 'value'});
      output.add(
        const CompactionOutputItem(
          id: 'cmp_fixture',
          encryptedContent: 'opaque',
        ),
      );
      metadata['a'] = '2';
      expect(copied.output, hasLength(1));
      expect(copied.toJson()['metadata'], {'a': '2'});
      expect(response.accessPrograms, isNotNull);
      expect(copied.accessPrograms, isNull);
    },
  );
}

const _fullRequestJson = <String, dynamic>{
  'model': 'fixture-model',
  'input': 'input-private',
  'instructions': 'instructions-private',
  'tools': [
    {
      'type': 'function',
      'name': 'function-private',
      'description': 'description-private',
      'parameters': {'type': 'object'},
      'strict': true,
    },
  ],
  'tool_choice': 'auto',
  'previous_response_id': 'previous-private',
  'max_output_tokens': 16,
  'temperature': 0.5,
  'top_p': 0.7,
  'presence_penalty': 0.1,
  'frequency_penalty': 0.2,
  'stream': false,
  'stream_options': {'include_usage': false},
  'reasoning': {
    'effort': 'low',
    'context': 'all_turns',
    'mode': 'reasoning-private',
  },
  'text': {
    'format': {'type': 'json_object'},
    'verbosity': 'low',
  },
  'truncation': 'auto',
  'context_management': [
    {'type': 'compaction', 'compact_threshold': 200000},
  ],
  'parallel_tool_calls': false,
  'service_tier': 'priority',
  'metadata': {'metadata-private': 'value-private'},
  'include': ['reasoning.encrypted_content'],
  'store': false,
  'background': false,
  'max_tool_calls': 3,
  'safety_identifier': 'safety-private',
  'moderation': {'model': 'moderation-private'},
  'prompt_cache_key': 'cache-private',
  'prompt_cache_options': {
    'mode': 'explicit',
    'ttl': '30m',
    'comparison_response_id': 'comparison-private',
    'prewarm': false,
  },
  'prompt_cache_retention': '24h',
  'top_logprobs': 2,
  'multi_agent': {'enabled': true, 'max_concurrent_subagents': 3},
  'access_programs': {'cyber': 'daybreak_blue'},
};

const _fullResponseJson = <String, dynamic>{
  'id': 'resp_fixture',
  'object': 'response',
  'created_at': 0,
  'status': 'completed',
  'output': [
    {
      'type': 'compaction',
      'id': 'cmp_fixture',
      'encrypted_content': 'output-private',
    },
  ],
  'usage': {'input_tokens': 1, 'output_tokens': 2, 'total_tokens': 3},
  'error': {
    'type': 'error',
    'code': 'server_error',
    'message': 'error-private',
  },
  'incomplete_details': {'reason': 'max_output_tokens'},
  'model': 'fixture-model',
  'instructions': 'instructions-private',
  'previous_response_id': 'previous-private',
  'service_tier': 'priority',
  'metadata': {'metadata-private': 'value-private'},
  'max_output_tokens': 16,
  'temperature': 0.5,
  'top_p': 0.7,
  'background': false,
  'parallel_tool_calls': false,
  'prompt_cache_key': 'cache-private',
  'prompt_cache_retention': '24h',
  'prompt_cache_options': {
    'mode': 'explicit',
    'ttl': '30m',
    'comparison_response_id': 'comparison-private',
  },
  'prompt_cache_diagnostics': {'type': 'cache_hit'},
  'moderation': {
    'input': {
      'type': 'error',
      'code': 'fixture',
      'message': 'moderation-private',
    },
    'output': {
      'type': 'error',
      'code': 'fixture',
      'message': 'moderation-private',
    },
  },
  'reasoning': {
    'effort': 'low',
    'context': 'all_turns',
    'mode': 'reasoning-private',
  },
  'truncation': 'auto',
  'access_programs': {'cyber': 'daybreak_blue'},
};
