import 'package:meta/meta.dart';

/// A response from the embeddings API.
///
/// Contains the generated embeddings along with token usage information.
///
/// ## Example
///
/// ```dart
/// final response = await client.embeddings.create(request);
///
/// for (final embedding in response.data) {
///   print('Embedding ${embedding.index}: ${embedding.embedding.length} dims');
/// }
///
/// if (response.usage != null) {
///   print('Used ${response.usage!.totalTokens} tokens');
/// }
/// ```
@immutable
class EmbeddingResponse {
  /// Creates an [EmbeddingResponse].
  const EmbeddingResponse({
    required this.object,
    required this.data,
    required this.model,
    this.usage,
  });

  /// Creates an [EmbeddingResponse] from JSON.
  factory EmbeddingResponse.fromJson(Map<String, dynamic> json) {
    return EmbeddingResponse(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Embedding.fromJson(e as Map<String, dynamic>))
          .toList(),
      model: json['model'] as String,
      usage: json['usage'] != null
          ? EmbeddingUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of embeddings generated.
  final List<Embedding> data;

  /// The model used for generating embeddings.
  final String model;

  /// Token usage statistics.
  ///
  /// May be null with some OpenAI-compatible providers (e.g., Together AI
  /// doesn't return `usage` with some models).
  final EmbeddingUsage? usage;

  /// Gets the first embedding vector.
  ///
  /// Convenient when embedding a single input.
  List<double> get firstEmbedding => data.first.embedding;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((e) => e.toJson()).toList(),
    'model': model,
    if (usage != null) 'usage': usage!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddingResponse &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          model == other.model;

  @override
  int get hashCode => Object.hash(object, model);

  @override
  String toString() =>
      'EmbeddingResponse(model: $model, embeddings: ${data.length})';
}

/// A single embedding object.
///
/// Contains the embedding vector and its index in the input list.
@immutable
class Embedding {
  /// Creates an [Embedding].
  const Embedding({
    required this.object,
    required this.embedding,
    required this.index,
  });

  /// Creates an [Embedding] from JSON.
  factory Embedding.fromJson(Map<String, dynamic> json) {
    return Embedding(
      object: json['object'] as String,
      embedding: (json['embedding'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      index: json['index'] as int,
    );
  }

  /// The object type (always "embedding").
  final String object;

  /// The embedding vector.
  ///
  /// A list of floats representing the semantic meaning of the input.
  /// The length depends on the model and any dimensions parameter.
  final List<double> embedding;

  /// The index of this embedding in the input list.
  final int index;

  /// The number of dimensions in this embedding.
  int get dimensions => embedding.length;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'embedding': embedding,
    'index': index,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Embedding &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          index == other.index;

  @override
  int get hashCode => Object.hash(object, index);

  @override
  String toString() => 'Embedding(index: $index, dimensions: $dimensions)';
}

/// Token usage statistics for an embedding request.
@immutable
class EmbeddingUsage {
  /// Creates an [EmbeddingUsage].
  const EmbeddingUsage({required this.promptTokens, required this.totalTokens});

  /// Creates an [EmbeddingUsage] from JSON.
  factory EmbeddingUsage.fromJson(Map<String, dynamic> json) {
    return EmbeddingUsage(
      promptTokens: json['prompt_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
    );
  }

  /// The number of tokens in the input.
  final int promptTokens;

  /// The total number of tokens used.
  final int totalTokens;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'prompt_tokens': promptTokens,
    'total_tokens': totalTokens,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddingUsage &&
          runtimeType == other.runtimeType &&
          promptTokens == other.promptTokens &&
          totalTokens == other.totalTokens;

  @override
  int get hashCode => Object.hash(promptTokens, totalTokens);

  @override
  String toString() =>
      'EmbeddingUsage(promptTokens: $promptTokens, totalTokens: $totalTokens)';
}
