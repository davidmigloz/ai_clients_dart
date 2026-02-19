import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// A request to generate embeddings for input text.
///
/// Embeddings are numerical representations of text that capture semantic
/// meaning, useful for search, clustering, recommendations, and more.
///
/// ## Example
///
/// ```dart
/// final request = EmbeddingRequest(
///   model: 'text-embedding-3-small',
///   input: EmbeddingInput.text('Hello, world!'),
/// );
/// ```
@immutable
class EmbeddingRequest {
  /// Creates an [EmbeddingRequest].
  const EmbeddingRequest({
    required this.model,
    required this.input,
    this.encodingFormat,
    this.dimensions,
    this.user,
  });

  /// Creates an [EmbeddingRequest] from JSON.
  factory EmbeddingRequest.fromJson(Map<String, dynamic> json) {
    return EmbeddingRequest(
      model: json['model'] as String,
      input: EmbeddingInput.fromJson(json['input']),
      encodingFormat: json['encoding_format'] != null
          ? EmbeddingEncodingFormat.fromJson(json['encoding_format'] as String)
          : null,
      dimensions: json['dimensions'] as int?,
      user: json['user'] as String?,
    );
  }

  /// The model to use for generating embeddings.
  ///
  /// Recommended models:
  /// - `text-embedding-3-small` - Best balance of performance and cost
  /// - `text-embedding-3-large` - Higher quality for complex tasks
  /// - `text-embedding-ada-002` - Legacy model
  final String model;

  /// The input text to generate embeddings for.
  ///
  /// Can be a single string, a list of strings, a list of integers
  /// (token IDs), or a list of integer arrays.
  final EmbeddingInput input;

  /// The format to return embeddings in.
  ///
  /// Defaults to `float`. Use `base64` for more efficient transfer.
  final EmbeddingEncodingFormat? encodingFormat;

  /// The number of dimensions for the output embeddings.
  ///
  /// Only supported in `text-embedding-3` and later models.
  /// Lower dimensions reduce storage costs while maintaining quality.
  final int? dimensions;

  /// A unique identifier representing your end-user.
  ///
  /// Helps OpenAI monitor and detect abuse.
  final String? user;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'input': input.toJson(),
    if (encodingFormat != null) 'encoding_format': encodingFormat!.toJson(),
    if (dimensions != null) 'dimensions': dimensions,
    if (user != null) 'user': user,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  EmbeddingRequest copyWith({
    String? model,
    EmbeddingInput? input,
    Object? encodingFormat = unsetCopyWithValue,
    Object? dimensions = unsetCopyWithValue,
    Object? user = unsetCopyWithValue,
  }) {
    return EmbeddingRequest(
      model: model ?? this.model,
      input: input ?? this.input,
      encodingFormat: encodingFormat == unsetCopyWithValue
          ? this.encodingFormat
          : encodingFormat as EmbeddingEncodingFormat?,
      dimensions: dimensions == unsetCopyWithValue
          ? this.dimensions
          : dimensions as int?,
      user: user == unsetCopyWithValue ? this.user : user as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddingRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          input == other.input &&
          encodingFormat == other.encodingFormat &&
          dimensions == other.dimensions &&
          user == other.user;

  @override
  int get hashCode =>
      Object.hash(model, input, encodingFormat, dimensions, user);

  @override
  String toString() => 'EmbeddingRequest(model: $model, input: $input)';
}

/// The input for embedding generation.
///
/// Can be a single string, a list of strings, a list of integers
/// (token IDs), or a list of integer arrays.
sealed class EmbeddingInput {
  /// Creates an [EmbeddingInput] from JSON.
  factory EmbeddingInput.fromJson(Object json) {
    if (json is String) {
      return EmbeddingInputText(json);
    } else if (json is List) {
      if (json.isEmpty) {
        return const EmbeddingInputTextList([]);
      }
      if (json.first is String) {
        return EmbeddingInputTextList(json.cast<String>());
      }
      if (json.first is int) {
        return EmbeddingInputTokens(json.cast<int>());
      }
      if (json.first is List) {
        return EmbeddingInputTokensList(
          json.map((e) => (e as List).cast<int>()).toList(),
        );
      }
    }
    throw FormatException('Unknown embedding input format: $json');
  }

  /// Creates input from a single text string.
  static EmbeddingInput text(String text) => EmbeddingInputText(text);

  /// Creates input from multiple text strings.
  static EmbeddingInput textList(List<String> texts) =>
      EmbeddingInputTextList(texts);

  /// Creates input from token IDs.
  static EmbeddingInput tokens(List<int> tokens) =>
      EmbeddingInputTokens(tokens);

  /// Creates input from multiple token ID arrays.
  static EmbeddingInput tokensList(List<List<int>> tokensList) =>
      EmbeddingInputTokensList(tokensList);

  /// Converts to JSON.
  Object toJson();
}

/// A single text string input.
@immutable
class EmbeddingInputText implements EmbeddingInput {
  /// Creates an [EmbeddingInputText].
  const EmbeddingInputText(this.text);

  /// The text to embed.
  final String text;

  @override
  Object toJson() => text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddingInputText &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'EmbeddingInputText(${text.length} chars)';
}

/// Multiple text strings input.
@immutable
class EmbeddingInputTextList implements EmbeddingInput {
  /// Creates an [EmbeddingInputTextList].
  const EmbeddingInputTextList(this.texts);

  /// The texts to embed.
  final List<String> texts;

  @override
  Object toJson() => texts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddingInputTextList &&
          runtimeType == other.runtimeType &&
          _listEquals(texts, other.texts);

  @override
  int get hashCode => Object.hashAll(texts);

  @override
  String toString() => 'EmbeddingInputTextList(${texts.length} texts)';
}

/// Token IDs input.
@immutable
class EmbeddingInputTokens implements EmbeddingInput {
  /// Creates an [EmbeddingInputTokens].
  const EmbeddingInputTokens(this.tokens);

  /// The token IDs to embed.
  final List<int> tokens;

  @override
  Object toJson() => tokens;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddingInputTokens &&
          runtimeType == other.runtimeType &&
          _listEquals(tokens, other.tokens);

  @override
  int get hashCode => Object.hashAll(tokens);

  @override
  String toString() => 'EmbeddingInputTokens(${tokens.length} tokens)';
}

/// Multiple token ID arrays input.
@immutable
class EmbeddingInputTokensList implements EmbeddingInput {
  /// Creates an [EmbeddingInputTokensList].
  const EmbeddingInputTokensList(this.tokensList);

  /// The token ID arrays to embed.
  final List<List<int>> tokensList;

  @override
  Object toJson() => tokensList;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddingInputTokensList &&
          runtimeType == other.runtimeType &&
          _nestedListEquals(tokensList, other.tokensList);

  @override
  int get hashCode => Object.hashAll(tokensList.map(Object.hashAll));

  @override
  String toString() =>
      'EmbeddingInputTokensList(${tokensList.length} token arrays)';
}

/// The encoding format for embeddings.
enum EmbeddingEncodingFormat {
  /// Float array format (default).
  float._('float'),

  /// Base64-encoded binary format.
  base64._('base64');

  const EmbeddingEncodingFormat._(this._value);

  /// Creates from JSON string.
  factory EmbeddingEncodingFormat.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown encoding format: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

// Helper for list equality
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// Helper for nested list equality
bool _nestedListEquals<T>(List<List<T>> a, List<List<T>> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!_listEquals(a[i], b[i])) return false;
  }
  return true;
}
