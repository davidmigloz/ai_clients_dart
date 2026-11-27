import 'package:meta/meta.dart';

import '../common/deep_unmodifiable_json.dart';
import '../common/equality_helpers.dart';

/// A validation issue reported by a Managed Search query.
@immutable
sealed class ManagedSearchQueryError {
  const ManagedSearchQueryError();

  /// Decodes an issue, preserving unrecognized discriminators.
  factory ManagedSearchQueryError.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'embedding_mismatch' => SearchEmbeddingMismatch.fromJson(json),
        'incorrect_field_type' => SearchIncorrectFieldType.fromJson(json),
        'max_candidates_too_small' => SearchMaxCandidatesTooSmall.fromJson(
          json,
        ),
        'missing_embedding' => SearchMissingEmbedding.fromJson(json),
        'missing_field' => SearchMissingField.fromJson(json),
        'top_k_too_large' => SearchTopKTooLarge.fromJson(json),
        final String type when type.isNotEmpty =>
          UnknownManagedSearchQueryError._(type, json),
        _ => throw const FormatException('Missing Managed Search error type.'),
      };

  /// The error discriminator on the wire.
  String get type;

  /// Serializes an issue.
  Map<String, dynamic> toJson();
}

/// The supplied embedding dimensions differ from the index dimensions.
final class SearchEmbeddingMismatch extends ManagedSearchQueryError {
  /// Creates an issue with its reported fields.
  const SearchEmbeddingMismatch({
    required this.expected,
    required this.received,
  });

  /// Decodes the issued error payload.
  factory SearchEmbeddingMismatch.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'embedding_mismatch');
    return SearchEmbeddingMismatch(
      expected: _required<int>(json, 'expected'),
      received: _required<int>(json, 'received'),
    );
  }

  @override
  String get type => 'embedding_mismatch';

  /// The number of dimensions the index expects.
  final int expected;

  /// The number of dimensions in the supplied embedding.
  final int received;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'expected': expected,
    'received': received,
  };

  /// Copies the issue with selected fields replaced.
  SearchEmbeddingMismatch copyWith({int? expected, int? received}) =>
      SearchEmbeddingMismatch(
        expected: expected ?? this.expected,
        received: received ?? this.received,
      );

  @override
  bool operator ==(Object other) =>
      other is SearchEmbeddingMismatch &&
      expected == other.expected &&
      received == other.received;

  @override
  int get hashCode => Object.hash(type, expected, received);

  @override
  String toString() =>
      'SearchEmbeddingMismatch(expected: $expected, received: $received)';
}

/// A selected index field has an incompatible type.
final class SearchIncorrectFieldType extends ManagedSearchQueryError {
  /// Creates an issue with its reported fields.
  const SearchIncorrectFieldType({
    required this.expectedType,
    required this.name,
    required this.receivedType,
  });

  /// Decodes the issued error payload.
  factory SearchIncorrectFieldType.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'incorrect_field_type');
    return SearchIncorrectFieldType(
      expectedType: _required<String>(json, 'expected_type'),
      name: _required<String>(json, 'name'),
      receivedType: _required<String>(json, 'received_type'),
    );
  }

  @override
  String get type => 'incorrect_field_type';

  /// The type required by the query.
  final String expectedType;

  /// The index field name.
  final String name;

  /// The type of the selected field.
  final String receivedType;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'expected_type': expectedType,
    'name': name,
    'received_type': receivedType,
  };

  /// Copies the issue with selected fields replaced.
  SearchIncorrectFieldType copyWith({
    String? expectedType,
    String? name,
    String? receivedType,
  }) => SearchIncorrectFieldType(
    expectedType: expectedType ?? this.expectedType,
    name: name ?? this.name,
    receivedType: receivedType ?? this.receivedType,
  );

  @override
  bool operator ==(Object other) =>
      other is SearchIncorrectFieldType &&
      expectedType == other.expectedType &&
      name == other.name &&
      receivedType == other.receivedType;

  @override
  int get hashCode => Object.hash(type, expectedType, name, receivedType);

  @override
  String toString() =>
      'SearchIncorrectFieldType(expectedType: $expectedType, name: $name, receivedType: $receivedType)';
}

/// The candidate pool is smaller than the number of requested hits.
final class SearchMaxCandidatesTooSmall extends ManagedSearchQueryError {
  /// Creates an issue with its reported fields.
  const SearchMaxCandidatesTooSmall({
    required this.maxCandidates,
    required this.topK,
  });

  /// Decodes the issued error payload.
  factory SearchMaxCandidatesTooSmall.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'max_candidates_too_small');
    return SearchMaxCandidatesTooSmall(
      maxCandidates: _required<int>(json, 'max_candidates'),
      topK: _required<int>(json, 'top_k'),
    );
  }

  @override
  String get type => 'max_candidates_too_small';

  /// The configured candidate pool size.
  final int maxCandidates;

  /// The number of requested hits.
  final int topK;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'max_candidates': maxCandidates,
    'top_k': topK,
  };

  /// Copies the issue with selected fields replaced.
  SearchMaxCandidatesTooSmall copyWith({int? maxCandidates, int? topK}) =>
      SearchMaxCandidatesTooSmall(
        maxCandidates: maxCandidates ?? this.maxCandidates,
        topK: topK ?? this.topK,
      );

  @override
  bool operator ==(Object other) =>
      other is SearchMaxCandidatesTooSmall &&
      maxCandidates == other.maxCandidates &&
      topK == other.topK;

  @override
  int get hashCode => Object.hash(type, maxCandidates, topK);

  @override
  String toString() =>
      'SearchMaxCandidatesTooSmall(maxCandidates: $maxCandidates, topK: $topK)';
}

/// The search query needs an embedding.
final class SearchMissingEmbedding extends ManagedSearchQueryError {
  /// Creates the issue.
  const SearchMissingEmbedding();

  /// Decodes the issued error payload.
  factory SearchMissingEmbedding.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'missing_embedding');
    return const SearchMissingEmbedding();
  }

  @override
  String get type => 'missing_embedding';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) => other is SearchMissingEmbedding;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'SearchMissingEmbedding()';
}

/// A selected index field is missing.
final class SearchMissingField extends ManagedSearchQueryError {
  /// Creates an issue with its reported fields.
  const SearchMissingField({required this.name});

  /// Decodes the issued error payload.
  factory SearchMissingField.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'missing_field');
    return SearchMissingField(name: _required<String>(json, 'name'));
  }

  @override
  String get type => 'missing_field';

  /// The missing index field name.
  final String name;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'name': name};

  /// Copies the issue with selected fields replaced.
  SearchMissingField copyWith({String? name}) =>
      SearchMissingField(name: name ?? this.name);

  @override
  bool operator ==(Object other) =>
      other is SearchMissingField && name == other.name;

  @override
  int get hashCode => Object.hash(type, name);

  @override
  String toString() => 'SearchMissingField(name: $name)';
}

/// The request exceeds the result limit.
final class SearchTopKTooLarge extends ManagedSearchQueryError {
  /// Creates an issue with its reported fields.
  const SearchTopKTooLarge({required this.limit, required this.topK});

  /// Decodes the issued error payload.
  factory SearchTopKTooLarge.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'top_k_too_large');
    return SearchTopKTooLarge(
      limit: _required<int>(json, 'limit'),
      topK: _required<int>(json, 'top_k'),
    );
  }

  @override
  String get type => 'top_k_too_large';

  /// The maximum number of supported hits.
  final int limit;

  /// The number of requested hits.
  final int topK;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'limit': limit,
    'top_k': topK,
  };

  /// Copies the issue with selected fields replaced.
  SearchTopKTooLarge copyWith({int? limit, int? topK}) =>
      SearchTopKTooLarge(limit: limit ?? this.limit, topK: topK ?? this.topK);

  @override
  bool operator ==(Object other) =>
      other is SearchTopKTooLarge && limit == other.limit && topK == other.topK;

  @override
  int get hashCode => Object.hash(type, limit, topK);

  @override
  String toString() => 'SearchTopKTooLarge(limit: $limit, topK: $topK)';
}

/// An issue with a newer discriminator.
final class UnknownManagedSearchQueryError extends ManagedSearchQueryError {
  UnknownManagedSearchQueryError._(this.type, Map<String, dynamic> json)
    : rawJson = deepUnmodifiableJson(json)! as Map<String, dynamic>;

  @override
  final String type;

  /// The issue payload supplied by the server.
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  @override
  bool operator ==(Object other) =>
      other is UnknownManagedSearchQueryError &&
      mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownManagedSearchQueryError(type: $type)';
}

void _checkType(Map<String, dynamic> json, String expected) {
  if (json.containsKey('type') && json['type'] != expected) {
    throw const FormatException('Unexpected Managed Search error type.');
  }
}

T _required<T extends Object>(Map<String, dynamic> json, String key) {
  if (json[key] case final T value) return value;
  throw FormatException('Invalid Managed Search error field "$key".');
}
