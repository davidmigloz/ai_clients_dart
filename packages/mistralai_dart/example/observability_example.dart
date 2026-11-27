// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Queries an Enterprise workspace with Observability enabled.
Future<void> main() async {
  final env = Platform.environment;
  final apiKey = env['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Set MISTRAL_API_KEY for a workspace with Observability access.');
    return;
  }

  final client = MistralClient.withApiKey(apiKey);
  try {
    final observability = client.observability;
    final datasets = await observability.datasets.list(pageSize: 10);
    for (final dataset in datasets.datasets.results) {
      print('${dataset.slug}: ${dataset.name}');
    }

    final projects = await observability.projects.list(pageSize: 10);
    for (final project in projects.projects.results) {
      print('${project.slug}: ${project.name}');
    }

    final runs = await observability.evaluations.searchAllRuns(pageSize: 10);
    print('Offline evaluation runs: ${runs.runs.count}');

    final scorers = await observability.scorers.list(pageSize: 10);
    print('Scorers: ${scorers.scorers.count}');
    final pipelines = await observability.pipelines.list(enabled: true);
    print('Live evaluations: ${pipelines.pipelines.count}');

    final optimizations = await observability.optimizations.list(pageSize: 10);
    print('Optimizations: ${optimizations.optimizations.count}');

    final from = DateTime.now().toUtc().subtract(const Duration(hours: 1));
    final traces = await observability.traces.search(
      from: from.toIso8601String(),
      pageSize: 5,
    );
    print('Returned traces: ${traces.traces.results.length}');

    final spanFields = await observability.spans.getFields();
    print('Span filter fields: ${spanFields.fieldDefinitions.length}');
    final logs = await observability.logs.search(
      from: from.toIso8601String(),
      pageSize: 5,
    );
    print('Returned logs: ${logs.logs.results.length}');

    final configSlug = env['MISTRAL_PIPELINE_CONFIG_SLUG'];
    if (configSlug != null) {
      final results = await observability.pipelines.searchResults(
        from: from,
        request: PipelineResultsRequest(pipelineConfigSlugs: [configSlug]),
      );
      for (final item in results.pipelineResults.results) {
        print('Trace ${item.traceId}, span ${item.spanId}');
      }
    }
  } finally {
    client.close();
  }
}
