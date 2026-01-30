// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  OpenAIClient? client;

  setUpAll(() {
    apiKey = Platform.environment['OPENAI_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('OPENAI_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = OpenAIClient(
        config: OpenAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Evals - Integration', () {
    test(
      'creates, retrieves, updates, and deletes an evaluation',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create evaluation with string check grader
        final eval = await client!.evals.create(
          CreateEvalRequest(
            name: 'Integration Test Eval',
            dataSourceConfig: EvalDataSourceConfig.custom(
              itemSchema: {
                'type': 'object',
                'properties': {
                  'prompt': {'type': 'string'},
                  'expected': {'type': 'string'},
                },
                'required': ['prompt', 'expected'],
              },
              includeSampleSchema: true,
            ),
            testingCriteria: [
              EvalGrader.stringCheck(
                name: 'matches_expected',
                input: '{{sample.output_text}}',
                operation: StringCheckOperation.ilike,
                reference: '%{{item.expected}}%',
              ),
            ],
            metadata: const {'test': 'integration'},
          ),
        );

        expect(eval.id, startsWith('eval'));
        expect(eval.name, 'Integration Test Eval');
        expect(eval.testingCriteria, hasLength(1));
        expect(eval.metadata?['test'], 'integration');

        final evalId = eval.id;

        try {
          // Retrieve
          final retrieved = await client!.evals.retrieve(evalId);

          expect(retrieved.id, evalId);
          expect(retrieved.name, 'Integration Test Eval');
          expect(retrieved.object, 'eval');

          // Update metadata
          final updated = await client!.evals.update(
            evalId,
            const UpdateEvalRequest(
              name: 'Updated Integration Test Eval',
              metadata: {'test': 'updated'},
            ),
          );

          expect(updated.id, evalId);
          expect(updated.name, 'Updated Integration Test Eval');
          expect(updated.metadata?['test'], 'updated');
        } finally {
          // Clean up
          final deleted = await client!.evals.delete(evalId);

          expect(deleted.evalId, evalId);
          expect(deleted.deleted, isTrue);
        }
      },
    );

    test(
      'lists evaluations',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final evals = await client!.evals.list(limit: 5);

        expect(evals.object, 'list');
        expect(evals.data, isA<List<Eval>>());
        expect(evals.data.length, lessThanOrEqualTo(5));
      },
    );

    test(
      'creates evaluation with text similarity grader',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final eval = await client!.evals.create(
          CreateEvalRequest(
            name: 'Text Similarity Test',
            dataSourceConfig: EvalDataSourceConfig.custom(
              itemSchema: {
                'type': 'object',
                'properties': {
                  'input': {'type': 'string'},
                  'expected': {'type': 'string'},
                },
              },
              includeSampleSchema: true,
            ),
            testingCriteria: [
              EvalGrader.textSimilarity(
                name: 'fuzzy_match',
                input: '{{sample.output_text}}',
                reference: '{{item.expected}}',
                evaluationMetric: TextSimilarityMetric.fuzzyMatch,
                passThreshold: 0.7,
              ),
            ],
          ),
        );

        expect(eval.id, startsWith('eval'));
        expect(eval.testingCriteria.first.name, 'fuzzy_match');

        // Clean up
        await client!.evals.delete(eval.id);
      },
    );

    test(
      'creates evaluation with label model grader',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final eval = await client!.evals.create(
          CreateEvalRequest(
            name: 'Label Model Test',
            dataSourceConfig: EvalDataSourceConfig.custom(
              itemSchema: {
                'type': 'object',
                'properties': {
                  'text': {'type': 'string'},
                },
              },
              includeSampleSchema: true,
            ),
            testingCriteria: [
              EvalGrader.labelModel(
                name: 'sentiment',
                model: 'gpt-4o-mini',
                labels: ['positive', 'negative', 'neutral'],
                passingLabels: ['positive', 'neutral'],
                input: [
                  const LabelModelInput.system('Classify the sentiment.'),
                  const LabelModelInput.user('Text: {{sample.output_text}}'),
                ],
              ),
            ],
          ),
        );

        expect(eval.id, startsWith('eval'));
        expect(eval.testingCriteria.first.name, 'sentiment');
        expect(eval.testingCriteria.first.type, 'label_model');

        // Clean up
        await client!.evals.delete(eval.id);
      },
    );

    test(
      'creates evaluation with multiple graders',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final eval = await client!.evals.create(
          CreateEvalRequest(
            name: 'Multi-Grader Test',
            dataSourceConfig: EvalDataSourceConfig.custom(
              itemSchema: {
                'type': 'object',
                'properties': {
                  'prompt': {'type': 'string'},
                  'expected': {'type': 'string'},
                },
              },
              includeSampleSchema: true,
            ),
            testingCriteria: [
              EvalGrader.stringCheck(
                name: 'not_empty',
                input: '{{sample.output_text}}',
                operation: StringCheckOperation.notEquals,
                reference: '',
              ),
              EvalGrader.stringCheck(
                name: 'no_error',
                input: '{{sample.output_text}}',
                operation: StringCheckOperation.notEquals,
                reference: 'error',
              ),
            ],
          ),
        );

        expect(eval.id, startsWith('eval'));
        expect(eval.testingCriteria, hasLength(2));

        // Clean up
        await client!.evals.delete(eval.id);
      },
    );
  });

  group('Eval Runs - Integration', () {
    test(
      'creates and lists runs',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // First create an evaluation
        final eval = await client!.evals.create(
          CreateEvalRequest(
            name: 'Run Test Eval',
            dataSourceConfig: EvalDataSourceConfig.custom(
              itemSchema: {
                'type': 'object',
                'properties': {
                  'input': {'type': 'string'},
                },
              },
              includeSampleSchema: true,
            ),
            testingCriteria: [
              EvalGrader.stringCheck(
                name: 'not_empty',
                input: '{{sample.output_text}}',
                operation: StringCheckOperation.notEquals,
                reference: '',
              ),
            ],
          ),
        );

        final evalId = eval.id;

        try {
          // Create a run with inline data
          final run = await client!.evals.runs.create(
            evalId,
            CreateEvalRunRequest(
              name: 'Integration Test Run',
              dataSource: EvalRunDataSource.responses(
                source: const ResponsesContentSource(
                  content: [
                    {
                      'item': {'input': 'Say hello'},
                    },
                    {
                      'item': {'input': 'Say goodbye'},
                    },
                  ],
                ),
                model: 'gpt-4o-mini',
                inputMessages: InputMessages.template([
                  const InputMessage.system('You are a helpful assistant.'),
                  const InputMessage.user('{{item.input}}'),
                ]),
                samplingParams: const EvalSamplingParams(
                  maxCompletionsTokens: 50,
                  temperature: 0.5,
                ),
              ),
              metadata: const {'test': 'run'},
            ),
          );

          expect(run.id, anyOf(startsWith('run-'), startsWith('evalrun_')));
          expect(run.evalId, evalId);
          expect(run.name, 'Integration Test Run');
          expect(run.status.name, isIn(['queued', 'in_progress', 'completed']));

          final runId = run.id;

          // List runs
          final runs = await client!.evals.runs.list(evalId, limit: 5);

          expect(runs.data, isA<List<EvalRun>>());
          expect(runs.data.any((r) => r.id == runId), isTrue);

          // Retrieve run
          final retrieved = await client!.evals.runs.retrieve(evalId, runId);

          expect(retrieved.id, runId);
          expect(retrieved.evalId, evalId);

          // Delete run (may fail if still running)
          try {
            final deleted = await client!.evals.runs.delete(evalId, runId);
            expect(deleted.runId, runId);
          } on OpenAIException catch (e) {
            // Run might be in progress and cannot be deleted
            print('Run deletion note: ${e.message}');
          }
        } finally {
          // Clean up eval (may fail if runs are still in progress)
          try {
            await client!.evals.delete(evalId);
          } on OpenAIException catch (e) {
            print('Eval cleanup note: ${e.message}');
          }
        }
      },
    );

    test(
      'creates run with JSONL file source',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // This test requires an existing JSONL file
        // Skip if no files available
        final files = await client!.files.list(purpose: FilePurpose.evals);
        if (files.data.isEmpty) {
          print('No evals files available - skipping file source test');
          return;
        }

        final fileId = files.data.first.id;

        // Create evaluation
        final eval = await client!.evals.create(
          CreateEvalRequest(
            name: 'File Source Test',
            dataSourceConfig: EvalDataSourceConfig.custom(
              itemSchema: {
                'type': 'object',
                'properties': {
                  'prompt': {'type': 'string'},
                },
              },
              includeSampleSchema: true,
            ),
            testingCriteria: [
              EvalGrader.stringCheck(
                name: 'check',
                input: '{{sample.output_text}}',
                operation: StringCheckOperation.notEquals,
                reference: '',
              ),
            ],
          ),
        );

        try {
          // Create run with file source
          final run = await client!.evals.runs.create(
            eval.id,
            CreateEvalRunRequest(
              name: 'File Source Run',
              dataSource: EvalRunDataSource.responses(
                source: ResponsesFileSource(fileId: fileId),
                model: 'gpt-4o-mini',
                inputMessages: InputMessages.template([
                  const InputMessage.user('{{item.prompt}}'),
                ]),
              ),
            ),
          );

          expect(run.id, anyOf(startsWith('run-'), startsWith('evalrun_')));

          // Clean up run if possible
          try {
            await client!.evals.runs.delete(eval.id, run.id);
          } catch (_) {
            // Ignore errors during cleanup
          }
        } finally {
          await client!.evals.delete(eval.id);
        }
      },
    );

    test(
      'cancels a running evaluation',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create evaluation
        final eval = await client!.evals.create(
          CreateEvalRequest(
            name: 'Cancel Test Eval',
            dataSourceConfig: EvalDataSourceConfig.custom(
              itemSchema: {
                'type': 'object',
                'properties': {
                  'input': {'type': 'string'},
                },
              },
              includeSampleSchema: true,
            ),
            testingCriteria: [
              EvalGrader.stringCheck(
                name: 'check',
                input: '{{sample.output_text}}',
                operation: StringCheckOperation.notEquals,
                reference: '',
              ),
            ],
          ),
        );

        try {
          // Create a run with multiple items to ensure it runs long enough
          final run = await client!.evals.runs.create(
            eval.id,
            CreateEvalRunRequest(
              name: 'Cancel Test Run',
              dataSource: EvalRunDataSource.responses(
                source: ResponsesContentSource(
                  content: List.generate(
                    10,
                    (i) => {
                      'item': {'input': 'Tell me about topic $i in detail'},
                    },
                  ),
                ),
                model: 'gpt-4o-mini',
                inputMessages: InputMessages.template([
                  const InputMessage.user('{{item.input}}'),
                ]),
                samplingParams: const EvalSamplingParams(
                  maxCompletionsTokens: 200,
                ),
              ),
            ),
          );

          // Try to cancel if still running
          if (run.isRunning) {
            final canceled = await client!.evals.runs.cancel(eval.id, run.id);
            expect(
              canceled.status,
              anyOf(EvalRunStatus.canceled, EvalRunStatus.completed),
            );
          }
        } finally {
          // Clean up eval (may fail if runs are still in progress)
          try {
            await client!.evals.delete(eval.id);
          } on OpenAIException catch (e) {
            print('Eval cleanup note: ${e.message}');
          }
        }
      },
    );
  });

  group('Eval Output Items - Integration', () {
    test(
      'lists output items from completed run',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create evaluation
        final eval = await client!.evals.create(
          CreateEvalRequest(
            name: 'Output Items Test',
            dataSourceConfig: EvalDataSourceConfig.custom(
              itemSchema: {
                'type': 'object',
                'properties': {
                  'input': {'type': 'string'},
                },
              },
              includeSampleSchema: true,
            ),
            testingCriteria: [
              EvalGrader.stringCheck(
                name: 'not_empty',
                input: '{{sample.output_text}}',
                operation: StringCheckOperation.notEquals,
                reference: '',
              ),
            ],
          ),
        );

        try {
          // Create a small run
          final run = await client!.evals.runs.create(
            eval.id,
            CreateEvalRunRequest(
              name: 'Output Items Run',
              dataSource: EvalRunDataSource.responses(
                source: const ResponsesContentSource(
                  content: [
                    {
                      'item': {'input': 'Hello'},
                    },
                    {
                      'item': {'input': 'World'},
                    },
                  ],
                ),
                model: 'gpt-4o-mini',
                inputMessages: InputMessages.template([
                  const InputMessage.user('Respond to: {{item.input}}'),
                ]),
                samplingParams: const EvalSamplingParams(
                  maxCompletionsTokens: 20,
                ),
              ),
            ),
          );

          // Poll for completion
          var currentRun = run;
          var attempts = 0;
          while (currentRun.isRunning && attempts < 30) {
            await Future<void>.delayed(const Duration(seconds: 5));
            currentRun = await client!.evals.runs.retrieve(eval.id, run.id);
            attempts++;
          }

          if (currentRun.isCompleted) {
            // List output items
            final items = await client!.evals.runs.outputItems.list(
              eval.id,
              run.id,
              limit: 10,
            );

            expect(items.data, isA<List<EvalOutputItem>>());

            if (items.data.isNotEmpty) {
              // Retrieve a specific item
              final item = await client!.evals.runs.outputItems.retrieve(
                eval.id,
                run.id,
                items.data.first.id,
              );

              expect(item.id, items.data.first.id);
              expect(item.evalId, eval.id);
              expect(item.runId, run.id);
              expect(item.sample, isNotNull);
              expect(item.results, isA<List<EvalOutputItemResult>>());
            }

            // Test filtering by status
            if (items.data.any((item) => item.passed)) {
              final passedItems = await client!.evals.runs.outputItems.list(
                eval.id,
                run.id,
                status: EvalOutputItemStatus.pass,
              );

              expect(passedItems.data.every((item) => item.passed), isTrue);
            }

            // Check result counts match
            if (currentRun.resultCounts != null) {
              print('Total: ${currentRun.resultCounts!.total}');
              print('Passed: ${currentRun.resultCounts!.passed}');
              print('Failed: ${currentRun.resultCounts!.failed}');
              print('Pass rate: ${currentRun.passRate}');
            }
          } else {
            print(
              'Run did not complete in time - status: ${currentRun.status}',
            );
          }
        } finally {
          await client!.evals.delete(eval.id);
        }
      },
    );
  });

  group('Evals Error Handling - Integration', () {
    test(
      'handles non-existent evaluation',
      timeout: const Timeout(Duration(minutes: 1)),
      () {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        expect(
          () => client!.evals.retrieve('eval-nonexistent123'),
          throwsA(isA<OpenAIException>()),
        );
      },
    );

    test(
      'handles non-existent run',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a real eval first
        final eval = await client!.evals.create(
          CreateEvalRequest(
            name: 'Error Test Eval',
            dataSourceConfig: EvalDataSourceConfig.custom(
              itemSchema: {
                'type': 'object',
                'properties': {
                  'input': {'type': 'string'},
                },
              },
              includeSampleSchema: true,
            ),
            testingCriteria: [
              EvalGrader.stringCheck(
                name: 'check',
                input: '{{sample.output_text}}',
                operation: StringCheckOperation.notEquals,
                reference: '',
              ),
            ],
          ),
        );

        try {
          expect(
            () => client!.evals.runs.retrieve(eval.id, 'run-nonexistent123'),
            throwsA(isA<OpenAIException>()),
          );
        } finally {
          await client!.evals.delete(eval.id);
        }
      },
    );

    test(
      'handles invalid grader configuration',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Attempt to create eval with empty labels
        // Note: API behavior may vary - it might accept or reject this
        Eval? createdEval;
        try {
          createdEval = await client!.evals.create(
            CreateEvalRequest(
              name: 'Invalid Grader Test',
              dataSourceConfig: EvalDataSourceConfig.custom(
                itemSchema: {
                  'type': 'object',
                  'properties': {
                    'input': {'type': 'string'},
                  },
                },
                includeSampleSchema: true,
              ),
              testingCriteria: [
                EvalGrader.labelModel(
                  name: 'empty_labels',
                  model: 'gpt-4o-mini',
                  labels: <String>[], // May or may not be rejected
                  passingLabels: <String>[],
                  input: [const LabelModelInput.user('{{sample.output_text}}')],
                ),
              ],
            ),
          );
          // If we get here, API accepted it - clean up
          print('API accepted empty labels configuration');
        } on OpenAIException catch (e) {
          // Expected error for invalid configuration
          print('API rejected empty labels: ${e.message}');
        } finally {
          // Clean up if eval was created
          if (createdEval != null) {
            await client!.evals.delete(createdEval.id);
          }
        }
      },
    );
  });
}
