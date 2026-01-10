import 'package:meta/meta.dart';

/// Interface for custom embedding generation.
///
/// Implement this interface to provide your own embedding generation logic,
/// for example using OpenAI, Cohere, or local models.
///
/// Example:
/// ```dart
/// class OpenAIEmbeddingFunction implements EmbeddingFunction {
///   final OpenAIClient client;
///   final String model;
///
///   OpenAIEmbeddingFunction(this.client, {this.model = 'text-embedding-3-small'});
///
///   @override
///   Future<List<List<double>>> generate(List<Embeddable> inputs) async {
///     final texts = inputs.map((e) => switch (e) {
///       EmbeddableDocument(:final document) => document,
///       EmbeddableImage(:final image) => image,
///     }).toList();
///
///     final response = await client.embeddings.create(
///       model: model,
///       input: texts,
///     );
///     return response.data.map((e) => e.embedding).toList();
///   }
/// }
/// ```
abstract interface class EmbeddingFunction {
  /// Generates embeddings for the given inputs.
  ///
  /// [inputs] - List of embeddable items (documents or images).
  ///
  /// Returns a list of embedding vectors, one for each input.
  Future<List<List<double>>> generate(List<Embeddable> inputs);
}

/// Input for embedding generation.
///
/// This is a sealed class with two variants:
/// - [EmbeddableDocument] for text documents
/// - [EmbeddableImage] for base64-encoded images
sealed class Embeddable {
  const Embeddable();

  /// Creates an embeddable from a text document.
  factory Embeddable.document(String text) = EmbeddableDocument;

  /// Creates an embeddable from a base64-encoded image.
  factory Embeddable.image(String base64) = EmbeddableImage;
}

/// An embeddable text document.
@immutable
class EmbeddableDocument extends Embeddable {
  /// The document text.
  final String document;

  /// Creates an embeddable document.
  const EmbeddableDocument(this.document);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddableDocument &&
          runtimeType == other.runtimeType &&
          document == other.document;

  @override
  int get hashCode => document.hashCode;

  @override
  String toString() => 'EmbeddableDocument($document)';
}

/// An embeddable base64-encoded image.
@immutable
class EmbeddableImage extends Embeddable {
  /// The base64-encoded image data.
  final String image;

  /// Creates an embeddable image.
  const EmbeddableImage(this.image);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddableImage &&
          runtimeType == other.runtimeType &&
          image == other.image;

  @override
  int get hashCode => image.hashCode;

  @override
  String toString() => 'EmbeddableImage(${image.length} chars)';
}
