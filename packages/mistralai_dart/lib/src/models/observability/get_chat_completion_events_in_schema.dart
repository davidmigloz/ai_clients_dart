import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'filter_payload.dart';

/// Request to search for chat completion events.
@immutable
class GetChatCompletionEventsInSchema {
  /// Search filter parameters.
  final FilterPayload searchParams;

  /// Extra fields to include in the response.
  final List<String>? extraFields;

  /// Creates a [GetChatCompletionEventsInSchema].
  GetChatCompletionEventsInSchema({
    required this.searchParams,
    List<String>? extraFields,
  }) : extraFields = extraFields != null
           ? List.unmodifiable(extraFields)
           : null;

  /// Creates a [GetChatCompletionEventsInSchema] from JSON.
  factory GetChatCompletionEventsInSchema.fromJson(Map<String, dynamic> json) =>
      GetChatCompletionEventsInSchema(
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
  GetChatCompletionEventsInSchema copyWith({
    FilterPayload? searchParams,
    Object? extraFields = unsetCopyWithValue,
  }) {
    return GetChatCompletionEventsInSchema(
      searchParams: searchParams ?? this.searchParams,
      extraFields: extraFields == unsetCopyWithValue
          ? this.extraFields
          : extraFields as List<String>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetChatCompletionEventsInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return searchParams == other.searchParams &&
        listsEqual(extraFields, other.extraFields);
  }

  @override
  int get hashCode => Object.hash(searchParams, listHash(extraFields));

  @override
  String toString() =>
      'GetChatCompletionEventsInSchema(searchParams: $searchParams)';
}
