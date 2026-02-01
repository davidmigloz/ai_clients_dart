// ignore_for_file: avoid_print, unused_local_variable
import 'dart:async';

import 'package:openai_dart/openai_dart.dart';

/// Example demonstrating the Evals API for model evaluation.
///
/// The Evals API allows you to:
/// - Create evaluations with various grading criteria
/// - Run evaluations against data sources
/// - Analyze results to understand model performance
///
/// Before running this example, set the `OPENAI_API_KEY` environment variable.
Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    // Example 1: Create an evaluation with a string check grader
    await createBasicEvaluation(client);

    // Example 2: Create an evaluation with multiple graders
    await createMultiGraderEvaluation(client);

    // Example 3: Run an evaluation and poll for results
    await runEvaluationWithPolling(client);

    // Example 4: List and analyze output items
    await analyzeOutputItems(client);
  } finally {
    client.close();
  }
}

/// Creates a basic evaluation with a string check grader.
Future<void> createBasicEvaluation(OpenAIClient client) async {
  print('--- Creating Basic Evaluation ---');

  // Create an evaluation that checks if model output contains expected text
  final eval = await client.evals.create(
    CreateEvalRequest(
      name: 'Greeting Check',
      dataSourceConfig: EvalDataSourceConfig.custom(
        itemSchema: {
          'type': 'object',
          'properties': {
            'prompt': {'type': 'string'},
            'expected_word': {'type': 'string'},
          },
          'required': ['prompt', 'expected_word'],
        },
        includeSampleSchema: true,
      ),
      testingCriteria: [
        EvalGrader.stringCheck(
          name: 'contains_expected',
          input: '{{sample.output_text}}',
          operation: StringCheckOperation.ilike,
          reference: '%{{item.expected_word}}%',
        ),
      ],
      metadata: const {'environment': 'example'},
    ),
  );

  print('Created evaluation: ${eval.id}');
  print('Name: ${eval.name}');
  print('Graders: ${eval.testingCriteria.length}');

  // Clean up
  await client.evals.delete(eval.id);
  print('Deleted evaluation');
}

/// Creates an evaluation with multiple types of graders.
Future<void> createMultiGraderEvaluation(OpenAIClient client) async {
  print('\n--- Creating Multi-Grader Evaluation ---');

  final eval = await client.evals.create(
    CreateEvalRequest(
      name: 'Comprehensive Quality Check',
      dataSourceConfig: EvalDataSourceConfig.custom(
        itemSchema: {
          'type': 'object',
          'properties': {
            'prompt': {'type': 'string'},
            'expected_answer': {'type': 'string'},
          },
        },
        includeSampleSchema: true,
      ),
      testingCriteria: [
        // 1. String check with pattern matching
        EvalGrader.stringCheck(
          name: 'starts_with_greeting',
          input: '{{sample.output_text}}',
          operation: StringCheckOperation.ilike,
          reference: 'Hello%',
        ),

        // 2. Text similarity for semantic matching
        EvalGrader.textSimilarity(
          name: 'answer_similarity',
          input: '{{sample.output_text}}',
          reference: '{{item.expected_answer}}',
          evaluationMetric: TextSimilarityMetric.fuzzyMatch,
          passThreshold: 0.7,
        ),

        // 3. Label model for sentiment classification
        EvalGrader.labelModel(
          name: 'positive_tone',
          model: 'gpt-4o-mini',
          labels: ['positive', 'negative', 'neutral'],
          passingLabels: ['positive', 'neutral'],
          input: [
            const LabelModelInput.system(
              'Classify the tone of the following response.',
            ),
            const LabelModelInput.user('Response: {{sample.output_text}}'),
          ],
        ),
      ],
    ),
  );

  print('Created evaluation with ${eval.testingCriteria.length} graders:');
  for (final grader in eval.testingCriteria) {
    print('  - ${grader.name} (${grader.type})');
  }

  // Clean up
  await client.evals.delete(eval.id);
}

/// Runs an evaluation and polls for completion.
Future<void> runEvaluationWithPolling(OpenAIClient client) async {
  print('\n--- Running Evaluation with Polling ---');

  // Create a simple evaluation
  final eval = await client.evals.create(
    CreateEvalRequest(
      name: 'Quick Test',
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

  print('Created evaluation: ${eval.id}');

  // Create a run with inline JSONL data using the responses data source
  final run = await client.evals.runs.create(
    eval.id,
    CreateEvalRunRequest(
      name: 'Example Run',
      dataSource: EvalRunDataSource.responses(
        source: const ResponsesContentSource(
          content: [
            {
              'item': {'input': 'Say hello'},
            },
            {
              'item': {'input': 'What is 2+2?'},
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
          temperature: 0.7,
        ),
      ),
    ),
  );

  print('Started run: ${run.id}');
  print('Initial status: ${run.status}');

  // Poll for completion
  var currentRun = run;
  while (currentRun.isRunning) {
    await Future<void>.delayed(const Duration(seconds: 2));
    currentRun = await client.evals.runs.retrieve(eval.id, run.id);
    print('Status: ${currentRun.status}');
  }

  // Check results
  if (currentRun.isCompleted) {
    print('\nRun completed!');
    print('Results: ${currentRun.resultCounts}');
    print('Pass rate: ${(currentRun.passRate! * 100).toStringAsFixed(1)}%');
    print('Report URL: ${currentRun.reportUrl}');
  } else if (currentRun.isFailed) {
    print('Run failed: ${currentRun.error?.message}');
  }

  // Clean up
  await client.evals.delete(eval.id);
}

/// Analyzes output items from an evaluation run.
Future<void> analyzeOutputItems(OpenAIClient client) async {
  print('\n--- Analyzing Output Items ---');

  // This example shows how to iterate through output items
  // In a real scenario, you would use an existing eval and run ID

  print('To analyze output items after a run completes:');
  print(r'''
  // List all output items
  final items = await client.evals.runs.outputItems.list(
    evalId,
    runId,
    limit: 10,
  );

  for (final item in items.data) {
    print('Item ${item.id}:');
    print('  Status: ${item.status}');
    print('  Output: ${item.sample.outputText}');

    for (final result in item.results) {
      print('  Grader "${result.name}": passed=${result.passed}');
      if (result.score != null) {
        print('    Score: ${result.score}');
      }
    }
  }

  // Filter by status to see only failures
  final failures = await client.evals.runs.outputItems.list(
    evalId,
    runId,
    status: EvalOutputItemStatus.fail,
  );

  print('Failed items: ${failures.data.length}');
  ''');
}
