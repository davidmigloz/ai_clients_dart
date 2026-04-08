import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'filter_payload.dart';

/// Request to search for chat completion event IDs.
@immutable
class GetChatCompletionEventIdsInSchema {
  /// Search filter parameters.
  final FilterPayload searchParams;

  /// Extra fields to include in the response.
  final List<String>? extraFields;

  /// Creates a [GetChatCompletionEventIdsInSchema].
  GetChatCompletionEventIdsInSchema({
    required this.searchParams,
    List<String>? extraFields,
  }) : extraFields = extraFields != null
           ? List.unmodifiable(extraFields)
           : null;

  /// Creates a [GetChatCompletionEventIdsInSchema] from JSON.
  factory GetChatCompletionEventIdsInSchema.fromJson(
    Map<String, dynamic> json,
  ) => GetChatCompletionEventIdsInSchema(
    searchParams: FilterPayload.fromJson(
      json['search_params'] as Map<String, dynamic>? ?? {},
    ),
    extraFields: (json['extra_fields'] as List?)?.cast<String>(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'search_params': searchParams.toJson(),
    if (extraFields != null) 'extra_fields': extraFields,
  };

  /// Creates a copy with replaced values.
  GetChatCompletionEventIdsInSchema copyWith({
    FilterPayload? searchParams,
    Object? extraFields = unsetCopyWithValue,
  }) {
    return GetChatCompletionEventIdsInSchema(
      searchParams: searchParams ?? this.searchParams,
      extraFields: extraFields == unsetCopyWithValue
          ? this.extraFields
          : extraFields as List<String>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetChatCompletionEventIdsInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return searchParams == other.searchParams &&
        listsEqual(extraFields, other.extraFields);
  }

  @override
  int get hashCode => Object.hash(searchParams, listHash(extraFields));

  @override
  String toString() =>
      'GetChatCompletionEventIdsInSchema(searchParams: $searchParams)';
}
