import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TaskType', () {
    test('taskTypeFromString converts all known values', () {
      expect(taskTypeFromString('TASK_TYPE_UNSPECIFIED'), TaskType.unspecified);
      expect(taskTypeFromString('RETRIEVAL_QUERY'), TaskType.retrievalQuery);
      expect(
        taskTypeFromString('RETRIEVAL_DOCUMENT'),
        TaskType.retrievalDocument,
      );
      expect(
        taskTypeFromString('SEMANTIC_SIMILARITY'),
        TaskType.semanticSimilarity,
      );
      expect(taskTypeFromString('CLASSIFICATION'), TaskType.classification);
      expect(taskTypeFromString('CLUSTERING'), TaskType.clustering);
      expect(
        taskTypeFromString('QUESTION_ANSWERING'),
        TaskType.questionAnswering,
      );
      expect(
        taskTypeFromString('FACT_VERIFICATION'),
        TaskType.factVerification,
      );
      expect(
        taskTypeFromString('CODE_RETRIEVAL_QUERY'),
        TaskType.codeRetrievalQuery,
      );
    });

    test('taskTypeFromString handles unknown values', () {
      expect(taskTypeFromString(null), TaskType.unspecified);
      expect(taskTypeFromString('UNKNOWN'), TaskType.unspecified);
    });

    test('taskTypeFromString is case-insensitive', () {
      expect(taskTypeFromString('retrieval_query'), TaskType.retrievalQuery);
      expect(
        taskTypeFromString('question_answering'),
        TaskType.questionAnswering,
      );
    });

    test('taskTypeToString converts all enum values', () {
      expect(taskTypeToString(TaskType.unspecified), 'TASK_TYPE_UNSPECIFIED');
      expect(taskTypeToString(TaskType.retrievalQuery), 'RETRIEVAL_QUERY');
      expect(
        taskTypeToString(TaskType.retrievalDocument),
        'RETRIEVAL_DOCUMENT',
      );
      expect(
        taskTypeToString(TaskType.semanticSimilarity),
        'SEMANTIC_SIMILARITY',
      );
      expect(taskTypeToString(TaskType.classification), 'CLASSIFICATION');
      expect(taskTypeToString(TaskType.clustering), 'CLUSTERING');
      expect(
        taskTypeToString(TaskType.questionAnswering),
        'QUESTION_ANSWERING',
      );
      expect(taskTypeToString(TaskType.factVerification), 'FACT_VERIFICATION');
      expect(
        taskTypeToString(TaskType.codeRetrievalQuery),
        'CODE_RETRIEVAL_QUERY',
      );
    });

    test('round-trip conversion for all values', () {
      for (final type in TaskType.values) {
        expect(taskTypeFromString(taskTypeToString(type)), type);
      }
    });
  });
}
