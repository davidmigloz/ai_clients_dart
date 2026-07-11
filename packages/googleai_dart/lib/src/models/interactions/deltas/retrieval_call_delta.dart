part of 'deltas.dart';

/// The type of retrieval tools used by a [RetrievalCallDelta].
enum RetrievalType {
  /// Vertex AI Search.
  vertexAiSearch,

  /// RAG store.
  ragStore,

  /// Exa AI Search.
  exaAiSearch,

  /// Parallel AI Search.
  parallelAiSearch,
}

/// Converts a JSON string to a [RetrievalType], or `null` if unrecognized
/// (forward-compatible).
RetrievalType? retrievalTypeFromString(String? value) {
  return switch (value) {
    'vertex_ai_search' => RetrievalType.vertexAiSearch,
    'rag_store' => RetrievalType.ragStore,
    'exa_ai_search' => RetrievalType.exaAiSearch,
    'parallel_ai_search' => RetrievalType.parallelAiSearch,
    _ => null,
  };
}

/// Converts a [RetrievalType] to its JSON string.
String retrievalTypeToString(RetrievalType value) {
  return switch (value) {
    RetrievalType.vertexAiSearch => 'vertex_ai_search',
    RetrievalType.ragStore => 'rag_store',
    RetrievalType.exaAiSearch => 'exa_ai_search',
    RetrievalType.parallelAiSearch => 'parallel_ai_search',
  };
}

/// The arguments to pass to a Retrieval tool.
class RetrievalCallArguments {
  /// Queries for Retrieval information.
  final List<String>? queries;

  /// Creates a [RetrievalCallArguments] instance.
  const RetrievalCallArguments({this.queries});

  /// Creates a [RetrievalCallArguments] from JSON.
  factory RetrievalCallArguments.fromJson(Map<String, dynamic> json) =>
      RetrievalCallArguments(
        queries: (json['queries'] as List<dynamic>?)?.cast<String>(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (queries != null) 'queries': queries};

  /// Creates a copy with replaced values.
  RetrievalCallArguments copyWith({Object? queries = unsetCopyWithValue}) {
    return RetrievalCallArguments(
      queries: queries == unsetCopyWithValue
          ? this.queries
          : queries as List<String>?,
    );
  }
}

/// A streamed delta for a Retrieval tool call.
///
/// Used by Vertex Retrieval tools such as Parallel AI, Exa AI, Vertex AI
/// Search, etc. [retrievalType] decides which tool is used.
class RetrievalCallDelta extends StepDeltaData {
  @override
  String get type => 'retrieval_call';

  /// Required. The arguments to pass to the Retrieval tool.
  final RetrievalCallArguments arguments;

  /// The type of retrieval tools.
  final RetrievalType? retrievalType;

  /// A signature hash for backend validation.
  final String? signature;

  /// Creates a [RetrievalCallDelta] instance.
  const RetrievalCallDelta({
    required this.arguments,
    this.retrievalType,
    this.signature,
  });

  /// Creates a [RetrievalCallDelta] from JSON.
  factory RetrievalCallDelta.fromJson(Map<String, dynamic> json) =>
      RetrievalCallDelta(
        arguments: RetrievalCallArguments.fromJson(
          json['arguments'] as Map<String, dynamic>,
        ),
        retrievalType: retrievalTypeFromString(
          json['retrieval_type'] as String?,
        ),
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'arguments': arguments.toJson(),
    if (retrievalType != null)
      'retrieval_type': retrievalTypeToString(retrievalType!),
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  RetrievalCallDelta copyWith({
    Object? arguments = unsetCopyWithValue,
    Object? retrievalType = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return RetrievalCallDelta(
      arguments: arguments == unsetCopyWithValue
          ? this.arguments
          : arguments! as RetrievalCallArguments,
      retrievalType: retrievalType == unsetCopyWithValue
          ? this.retrievalType
          : retrievalType as RetrievalType?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
