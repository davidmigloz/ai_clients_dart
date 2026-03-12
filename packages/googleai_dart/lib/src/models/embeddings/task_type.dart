/// Type of task for which the embedding will be used.
enum TaskType {
  /// Unspecified task type.
  unspecified,

  /// Retrieval query.
  retrievalQuery,

  /// Retrieval document.
  retrievalDocument,

  /// Semantic similarity.
  semanticSimilarity,

  /// Classification.
  classification,

  /// Clustering.
  clustering,

  /// Question answering.
  questionAnswering,

  /// Fact verification.
  factVerification,

  /// Code retrieval query.
  codeRetrievalQuery,
}

/// Converts string to TaskType enum.
TaskType taskTypeFromString(String? value) {
  return switch (value?.toUpperCase()) {
    'RETRIEVAL_QUERY' => TaskType.retrievalQuery,
    'RETRIEVAL_DOCUMENT' => TaskType.retrievalDocument,
    'SEMANTIC_SIMILARITY' => TaskType.semanticSimilarity,
    'CLASSIFICATION' => TaskType.classification,
    'CLUSTERING' => TaskType.clustering,
    'QUESTION_ANSWERING' => TaskType.questionAnswering,
    'FACT_VERIFICATION' => TaskType.factVerification,
    'CODE_RETRIEVAL_QUERY' => TaskType.codeRetrievalQuery,
    _ => TaskType.unspecified,
  };
}

/// Converts TaskType enum to string.
String taskTypeToString(TaskType type) {
  return switch (type) {
    TaskType.retrievalQuery => 'RETRIEVAL_QUERY',
    TaskType.retrievalDocument => 'RETRIEVAL_DOCUMENT',
    TaskType.semanticSimilarity => 'SEMANTIC_SIMILARITY',
    TaskType.classification => 'CLASSIFICATION',
    TaskType.clustering => 'CLUSTERING',
    TaskType.questionAnswering => 'QUESTION_ANSWERING',
    TaskType.factVerification => 'FACT_VERIFICATION',
    TaskType.codeRetrievalQuery => 'CODE_RETRIEVAL_QUERY',
    TaskType.unspecified => 'TASK_TYPE_UNSPECIFIED',
  };
}
