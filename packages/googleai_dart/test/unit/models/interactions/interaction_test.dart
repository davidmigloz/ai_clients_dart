import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Interaction', () {
    group('fromJson', () {
      test('creates Interaction with all fields', () {
        final json = {
          'id': 'abc-123',
          'model': 'gemini-3.5-flash',
          'status': 'completed',
          'created': '2024-01-15T10:30:00Z',
          'updated': '2024-01-15T10:31:00Z',
          'service_tier': 'standard',
          'usage': {
            'total_input_tokens': 100,
            'total_output_tokens': 50,
            'total_tokens': 150,
          },
          'steps': [
            {
              'type': 'model_output',
              'content': [
                {'type': 'text', 'text': 'Hello!'},
              ],
            },
          ],
        };

        final interaction = Interaction.fromJson(json);

        expect(interaction.id, 'abc-123');
        expect(interaction.model, 'gemini-3.5-flash');
        expect(interaction.status, InteractionStatus.completed);
        expect(interaction.created, DateTime.parse('2024-01-15T10:30:00Z'));
        expect(interaction.updated, DateTime.parse('2024-01-15T10:31:00Z'));
        expect(interaction.serviceTier, ServiceTier.standard);
        expect(interaction.usage, isNotNull);
        expect(interaction.usage!.totalInputTokens, 100);
        expect(interaction.steps, isNotNull);
        expect(interaction.steps!.length, 1);
        expect(interaction.steps!.first, isA<ModelOutputStep>());
        final modelOutput = interaction.steps!.first as ModelOutputStep;
        expect(modelOutput.content, hasLength(1));
        expect((modelOutput.content!.first as TextContent).text, 'Hello!');
      });

      test('creates Interaction with minimal required fields', () {
        final json = {'id': 'minimal-123', 'status': 'in_progress'};

        final interaction = Interaction.fromJson(json);

        expect(interaction.id, 'minimal-123');
        expect(interaction.status, InteractionStatus.inProgress);
        expect(interaction.model, isNull);
        expect(interaction.usage, isNull);
        expect(interaction.steps, isNull);
      });

      test('parses all status values', () {
        final statuses = {
          'in_progress': InteractionStatus.inProgress,
          'requires_action': InteractionStatus.requiresAction,
          'completed': InteractionStatus.completed,
          'failed': InteractionStatus.failed,
          'cancelled': InteractionStatus.cancelled,
          'incomplete': InteractionStatus.incomplete,
        };

        for (final entry in statuses.entries) {
          final json = {'id': 'test-123', 'status': entry.key};
          final interaction = Interaction.fromJson(json);
          expect(interaction.status, entry.value);
        }
      });
    });

    group('toJson', () {
      test('converts Interaction with all fields to JSON', () {
        final interaction = Interaction(
          id: 'test-456',
          status: InteractionStatus.completed,
          model: 'gemini-3.5-flash',
          created: DateTime.parse('2024-02-20T08:15:00Z'),
          updated: DateTime.parse('2024-02-20T08:16:00Z'),
          usage: const InteractionUsage(
            totalInputTokens: 200,
            totalOutputTokens: 100,
          ),
        );

        final json = interaction.toJson();

        expect(json['id'], 'test-456');
        expect(json['model'], 'gemini-3.5-flash');
        expect(json['status'], 'completed');
        expect(json['created'], contains('2024-02-20'));
        expect(json['updated'], contains('2024-02-20'));
        expect(json['usage'], isNotNull);
      });

      test('omits null fields from JSON', () {
        const interaction = Interaction(
          id: 'minimal-456',
          status: InteractionStatus.inProgress,
        );

        final json = interaction.toJson();

        expect(json['id'], 'minimal-456');
        expect(json['status'], 'in_progress');
        expect(json.containsKey('model'), false);
        expect(json.containsKey('usage'), false);
        expect(json.containsKey('steps'), false);
      });
    });

    test('round-trip conversion preserves data', () {
      final original = Interaction(
        id: 'roundtrip-789',
        status: InteractionStatus.inProgress,
        model: 'gemini-3.5-flash',
        created: DateTime.parse('2024-03-10T12:00:00Z'),
        usage: const InteractionUsage(
          totalInputTokens: 50,
          totalOutputTokens: 25,
          totalTokens: 75,
        ),
      );

      final json = original.toJson();
      final restored = Interaction.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.model, original.model);
      expect(restored.status, original.status);
      expect(restored.created, original.created);
      expect(
        restored.usage!.totalInputTokens,
        original.usage!.totalInputTokens,
      );
    });

    group('steps type safety', () {
      test('parses ModelOutputStep with TextContent', () {
        final json = {
          'id': 'test-id',
          'status': 'completed',
          'steps': [
            {
              'type': 'model_output',
              'content': [
                {'type': 'text', 'text': 'Hello world'},
              ],
            },
          ],
        };
        final interaction = Interaction.fromJson(json);

        expect(interaction.steps, hasLength(1));
        final step = interaction.steps!.first as ModelOutputStep;
        expect(step.content!.first, isA<TextContent>());
        expect((step.content!.first as TextContent).text, 'Hello world');
      });

      test('parses FunctionCallStep correctly', () {
        final json = {
          'id': 'test-id',
          'status': 'completed',
          'steps': [
            {
              'type': 'function_call',
              'id': 'call-1',
              'name': 'get_weather',
              'arguments': {'city': 'Tokyo'},
            },
          ],
        };
        final interaction = Interaction.fromJson(json);

        expect(interaction.steps!.first, isA<FunctionCallStep>());
        final call = interaction.steps!.first as FunctionCallStep;
        expect(call.id, 'call-1');
        expect(call.name, 'get_weather');
        expect(call.arguments, {'city': 'Tokyo'});
      });

      test('parses ThoughtStep correctly', () {
        final json = {
          'id': 'test-id',
          'status': 'completed',
          'steps': [
            {'type': 'thought', 'signature': 'sig-123'},
          ],
        };
        final interaction = Interaction.fromJson(json);

        expect(interaction.steps!.first, isA<ThoughtStep>());
        final thought = interaction.steps!.first as ThoughtStep;
        expect(thought.signature, 'sig-123');
      });

      test('parses mixed step types', () {
        final json = {
          'id': 'test-id',
          'status': 'completed',
          'steps': [
            {'type': 'thought', 'signature': 'sig-1'},
            {
              'type': 'model_output',
              'content': [
                {'type': 'text', 'text': 'Response'},
              ],
            },
            {
              'type': 'function_call',
              'id': 'call-1',
              'name': 'search',
              'arguments': <String, dynamic>{},
            },
          ],
        };
        final interaction = Interaction.fromJson(json);

        expect(interaction.steps, hasLength(3));
        expect(interaction.steps![0], isA<ThoughtStep>());
        expect(interaction.steps![1], isA<ModelOutputStep>());
        expect(interaction.steps![2], isA<FunctionCallStep>());
      });

      test('handles null steps', () {
        final json = {'id': 'test-id', 'status': 'in_progress'};
        final interaction = Interaction.fromJson(json);
        expect(interaction.steps, isNull);
      });

      test('round-trip serialization preserves typed steps', () {
        const original = Interaction(
          id: 'roundtrip-steps',
          status: InteractionStatus.completed,
          steps: [
            ModelOutputStep(content: [TextContent(text: 'Hello')]),
            FunctionCallStep(
              id: 'call-1',
              name: 'test_fn',
              arguments: {'key': 'value'},
            ),
          ],
        );

        final json = original.toJson();
        final restored = Interaction.fromJson(json);

        expect(restored.steps, hasLength(2));
        expect(restored.steps![0], isA<ModelOutputStep>());
        expect(
          ((restored.steps![0] as ModelOutputStep).content!.first
                  as TextContent)
              .text,
          'Hello',
        );
        expect(restored.steps![1], isA<FunctionCallStep>());
        expect((restored.steps![1] as FunctionCallStep).name, 'test_fn');
      });

      test('webhookConfig roundtrip', () {
        const interaction = Interaction(
          id: 'wh-test',
          status: InteractionStatus.inProgress,
          webhookConfig: WebhookConfig(
            uris: ['https://example.com/hook'],
            userMetadata: {'env': 'test'},
          ),
        );
        final restored = Interaction.fromJson(interaction.toJson());
        expect(restored.webhookConfig, isNotNull);
        expect(restored.webhookConfig!.uris, ['https://example.com/hook']);
        expect(restored.webhookConfig!.userMetadata, {'env': 'test'});
      });
    });
  });

  group('InteractionStatus', () {
    test('fromString parses all values', () {
      expect(
        InteractionStatus.fromString('in_progress'),
        InteractionStatus.inProgress,
      );
      expect(
        InteractionStatus.fromString('requires_action'),
        InteractionStatus.requiresAction,
      );
      expect(
        InteractionStatus.fromString('completed'),
        InteractionStatus.completed,
      );
      expect(InteractionStatus.fromString('failed'), InteractionStatus.failed);
      expect(
        InteractionStatus.fromString('cancelled'),
        InteractionStatus.cancelled,
      );
      expect(
        InteractionStatus.fromString('incomplete'),
        InteractionStatus.incomplete,
      );
    });

    test('fromString returns default for unknown value', () {
      expect(
        InteractionStatus.fromString('unknown'),
        InteractionStatus.inProgress,
      );
      expect(InteractionStatus.fromString(null), InteractionStatus.inProgress);
    });

    test('toJson returns correct string', () {
      expect(InteractionStatus.inProgress.toJson(), 'in_progress');
      expect(InteractionStatus.requiresAction.toJson(), 'requires_action');
      expect(InteractionStatus.completed.toJson(), 'completed');
      expect(InteractionStatus.failed.toJson(), 'failed');
      expect(InteractionStatus.cancelled.toJson(), 'cancelled');
      expect(InteractionStatus.incomplete.toJson(), 'incomplete');
    });
  });

  group('InteractionUsage', () {
    test('fromJson with all fields', () {
      final json = {
        'total_input_tokens': 100,
        'total_output_tokens': 50,
        'total_tokens': 150,
        'total_thought_tokens': 20,
        'total_tool_use_tokens': 10,
        'total_cached_tokens': 5,
        'input_tokens_by_modality': [
          {'modality': 'TEXT', 'tokens': 80},
          {'modality': 'IMAGE', 'tokens': 20},
        ],
      };

      final usage = InteractionUsage.fromJson(json);

      expect(usage.totalInputTokens, 100);
      expect(usage.totalOutputTokens, 50);
      expect(usage.totalTokens, 150);
      expect(usage.totalThoughtTokens, 20);
      expect(usage.totalToolUseTokens, 10);
      expect(usage.totalCachedTokens, 5);
      expect(usage.inputTokensByModality, isNotNull);
      expect(usage.inputTokensByModality!.length, 2);
    });

    test('toJson omits null fields', () {
      const usage = InteractionUsage(totalInputTokens: 100);

      final json = usage.toJson();

      expect(json['total_input_tokens'], 100);
      expect(json.containsKey('total_output_tokens'), false);
      expect(json.containsKey('total_tokens'), false);
    });
  });

  group('CreateModelInteractionParams tools type safety', () {
    test('parses serviceTier correctly', () {
      final json = {'model': 'gemini-3.5-flash', 'service_tier': 'priority'};
      final params = CreateModelInteractionParams.fromJson(json);

      expect(params.serviceTier, ServiceTier.priority);

      final toJson = params.toJson();
      expect(toJson['service_tier'], 'priority');
    });

    test('parses GoogleSearchTool correctly', () {
      final json = {
        'model': 'gemini-3.5-flash',
        'tools': [
          {'type': 'google_search'},
        ],
      };
      final params = CreateModelInteractionParams.fromJson(json);

      expect(params.tools, hasLength(1));
      expect(params.tools!.first, isA<GoogleSearchTool>());
    });

    test('parses FunctionTool correctly', () {
      final json = {
        'model': 'gemini-3.5-flash',
        'tools': [
          {
            'type': 'function',
            'name': 'get_weather',
            'description': 'Gets weather for a city',
            'parameters': {
              'type': 'object',
              'properties': {
                'city': {'type': 'string'},
              },
            },
          },
        ],
      };
      final params = CreateModelInteractionParams.fromJson(json);

      expect(params.tools!.first, isA<FunctionTool>());
      final tool = params.tools!.first as FunctionTool;
      expect(tool.name, 'get_weather');
      expect(tool.description, 'Gets weather for a city');
    });

    test('parses CodeExecutionTool correctly', () {
      final json = {
        'model': 'gemini-3.5-flash',
        'tools': [
          {'type': 'code_execution'},
        ],
      };
      final params = CreateModelInteractionParams.fromJson(json);

      expect(params.tools!.first, isA<CodeExecutionTool>());
    });

    test('parses UrlContextTool correctly', () {
      final json = {
        'model': 'gemini-3.5-flash',
        'tools': [
          {'type': 'url_context'},
        ],
      };
      final params = CreateModelInteractionParams.fromJson(json);

      expect(params.tools!.first, isA<UrlContextTool>());
    });

    test('parses multiple tools', () {
      final json = {
        'model': 'gemini-3.5-flash',
        'tools': [
          {'type': 'google_search'},
          {'type': 'code_execution'},
          {'type': 'function', 'name': 'test', 'description': 'Test function'},
        ],
      };
      final params = CreateModelInteractionParams.fromJson(json);

      expect(params.tools, hasLength(3));
      expect(params.tools![0], isA<GoogleSearchTool>());
      expect(params.tools![1], isA<CodeExecutionTool>());
      expect(params.tools![2], isA<FunctionTool>());
    });

    test('parses RetrievalTool correctly', () {
      final json = {
        'model': 'gemini-3.5-flash',
        'tools': [
          {
            'type': 'retrieval',
            'retrieval_types': ['vertex_ai_search'],
            'vertex_ai_search_config': {
              'datastores': ['ds-1', 'ds-2'],
              'engine': 'engine-1',
            },
          },
        ],
      };
      final params = CreateModelInteractionParams.fromJson(json);

      expect(params.tools, hasLength(1));
      expect(params.tools!.first, isA<RetrievalTool>());
      final tool = params.tools!.first as RetrievalTool;
      expect(tool.retrievalTypes, ['vertex_ai_search']);
      expect(tool.vertexAiSearchConfig, isNotNull);
      expect(tool.vertexAiSearchConfig!.datastores, ['ds-1', 'ds-2']);
      expect(tool.vertexAiSearchConfig!.engine, 'engine-1');

      // Round-trip
      final toolJson = tool.toJson();
      expect(toolJson['type'], 'retrieval');
      expect(toolJson['retrieval_types'], ['vertex_ai_search']);
      final restored = RetrievalTool.fromJson(toolJson);
      expect(restored.retrievalTypes, tool.retrievalTypes);
      expect(restored.vertexAiSearchConfig!.engine, 'engine-1');
    });

    test('handles null tools', () {
      final json = {'model': 'gemini-3.5-flash'};
      final params = CreateModelInteractionParams.fromJson(json);
      expect(params.tools, isNull);
    });

    test('round-trip serialization preserves typed tools', () {
      const original = CreateModelInteractionParams(
        model: 'gemini-3.5-flash',
        tools: [
          GoogleSearchTool(),
          FunctionTool(name: 'get_weather', description: 'Gets weather'),
        ],
      );

      final json = original.toJson();
      final restored = CreateModelInteractionParams.fromJson(json);

      expect(restored.tools, hasLength(2));
      expect(restored.tools![0], isA<GoogleSearchTool>());
      expect(restored.tools![1], isA<FunctionTool>());
      expect((restored.tools![1] as FunctionTool).name, 'get_weather');
    });
  });

  group('Interaction labels and safetySettings', () {
    test('round-trip conversion preserves labels and safetySettings', () {
      const original = Interaction(
        id: 'labels-test',
        status: InteractionStatus.completed,
        labels: {'env': 'test', 'team': 'growth'},
        safetySettings: [
          InteractionSafetySetting(
            type: InteractionHarmCategory.jailbreak,
            threshold: InteractionHarmBlockThreshold.blockOnlyHigh,
            method: InteractionSafetyMethod.probability,
          ),
        ],
      );

      final json = original.toJson();
      final restored = Interaction.fromJson(json);

      expect(restored.labels, {'env': 'test', 'team': 'growth'});
      expect(restored.safetySettings, hasLength(1));
      expect(
        restored.safetySettings!.first.type,
        InteractionHarmCategory.jailbreak,
      );
      expect(
        restored.safetySettings!.first.threshold,
        InteractionHarmBlockThreshold.blockOnlyHigh,
      );
      expect(
        restored.safetySettings!.first.method,
        InteractionSafetyMethod.probability,
      );
    });

    test('CreateModelInteractionParams round-trip preserves labels and '
        'safetySettings', () {
      const original = CreateModelInteractionParams(
        model: 'gemini-3.5-flash',
        labels: {'env': 'test'},
        safetySettings: [
          InteractionSafetySetting(
            type: InteractionHarmCategory.harassment,
            threshold: InteractionHarmBlockThreshold.blockNone,
          ),
        ],
      );

      final json = original.toJson();
      final restored = CreateModelInteractionParams.fromJson(json);

      expect(restored.labels, {'env': 'test'});
      expect(restored.safetySettings, hasLength(1));
      expect(
        restored.safetySettings!.first.type,
        InteractionHarmCategory.harassment,
      );
    });

    test('CreateAgentInteractionParams round-trip preserves labels and '
        'safetySettings', () {
      const original = CreateAgentInteractionParams(
        agent: 'my-agent',
        labels: {'env': 'test'},
        safetySettings: [
          InteractionSafetySetting(
            type: InteractionHarmCategory.civicIntegrity,
            threshold: InteractionHarmBlockThreshold.off,
          ),
        ],
      );

      final json = original.toJson();
      final restored = CreateAgentInteractionParams.fromJson(json);

      expect(restored.labels, {'env': 'test'});
      expect(restored.safetySettings, hasLength(1));
      expect(
        restored.safetySettings!.first.type,
        InteractionHarmCategory.civicIntegrity,
      );
    });
  });

  group('InteractionHarmCategory', () {
    test('fromString parses all values', () {
      final cases = {
        'hate_speech': InteractionHarmCategory.hateSpeech,
        'dangerous_content': InteractionHarmCategory.dangerousContent,
        'harassment': InteractionHarmCategory.harassment,
        'sexually_explicit': InteractionHarmCategory.sexuallyExplicit,
        'civic_integrity': InteractionHarmCategory.civicIntegrity,
        'image_hate': InteractionHarmCategory.imageHate,
        'image_dangerous_content':
            InteractionHarmCategory.imageDangerousContent,
        'image_harassment': InteractionHarmCategory.imageHarassment,
        'image_sexually_explicit':
            InteractionHarmCategory.imageSexuallyExplicit,
        'jailbreak': InteractionHarmCategory.jailbreak,
      };

      for (final entry in cases.entries) {
        expect(interactionHarmCategoryFromString(entry.key), entry.value);
        expect(interactionHarmCategoryToString(entry.value), entry.key);
      }
    });

    test('fromString falls back to unknown for unrecognized value', () {
      expect(
        interactionHarmCategoryFromString('unknown_category'),
        InteractionHarmCategory.unknown,
      );
      expect(
        interactionHarmCategoryFromString(null),
        InteractionHarmCategory.unknown,
      );
    });

    test('toString serializes unknown', () {
      expect(
        interactionHarmCategoryToString(InteractionHarmCategory.unknown),
        'unknown',
      );
    });
  });

  group('InteractionHarmBlockThreshold', () {
    test('fromString parses all values', () {
      final cases = {
        'block_low_and_above': InteractionHarmBlockThreshold.blockLowAndAbove,
        'block_medium_and_above':
            InteractionHarmBlockThreshold.blockMediumAndAbove,
        'block_only_high': InteractionHarmBlockThreshold.blockOnlyHigh,
        'block_none': InteractionHarmBlockThreshold.blockNone,
        'off': InteractionHarmBlockThreshold.off,
      };

      for (final entry in cases.entries) {
        expect(interactionHarmBlockThresholdFromString(entry.key), entry.value);
        expect(interactionHarmBlockThresholdToString(entry.value), entry.key);
      }
    });

    test('fromString falls back to unknown for unrecognized value', () {
      expect(
        interactionHarmBlockThresholdFromString('some_future_threshold'),
        InteractionHarmBlockThreshold.unknown,
      );
      expect(
        interactionHarmBlockThresholdFromString(null),
        InteractionHarmBlockThreshold.unknown,
      );
    });

    test('toString serializes unknown', () {
      expect(
        interactionHarmBlockThresholdToString(
          InteractionHarmBlockThreshold.unknown,
        ),
        'unknown',
      );
    });

    test('InteractionSafetySetting round-trips an unrecognized threshold as '
        'unknown', () {
      final setting = InteractionSafetySetting.fromJson({
        'type': 'jailbreak',
        'threshold': 'some_future_threshold',
      });

      expect(setting.threshold, InteractionHarmBlockThreshold.unknown);

      final json = setting.toJson();
      expect(json['threshold'], 'unknown');
    });
  });

  group('InteractionGenerationConfig', () {
    test('fromJson and toJson round-trip videoConfig', () {
      const original = InteractionGenerationConfig(
        videoConfig: InteractionVideoConfig(
          task: InteractionVideoConfigTask.imageToVideo,
        ),
      );

      final json = original.toJson();
      final restored = InteractionGenerationConfig.fromJson(json);

      expect(json.containsKey('frequency_penalty'), false);
      expect(json.containsKey('presence_penalty'), false);
      expect(restored.videoConfig, isNotNull);
      expect(
        restored.videoConfig!.task,
        InteractionVideoConfigTask.imageToVideo,
      );
    });
  });
}
