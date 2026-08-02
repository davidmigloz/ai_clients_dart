import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'prompt.dart';

/// Response returned by listing prompts.
@immutable
class ListPromptsResponse {
  /// The prompts on this page.
  final List<Prompt>? data;

  /// Token to fetch the next page, if any.
  final String? nextPageToken;

  /// Creates a [ListPromptsResponse].
  const ListPromptsResponse({this.data, this.nextPageToken});

  /// Creates a [ListPromptsResponse] from JSON.
  factory ListPromptsResponse.fromJson(Map<String, dynamic> json) =>
      ListPromptsResponse(
        data: (json['data'] as List?)
            ?.map((e) => Prompt.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextPageToken: json['nextPageToken'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (data != null) 'data': data!.map((e) => e.toJson()).toList(),
    if (nextPageToken != null) 'nextPageToken': nextPageToken,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  ListPromptsResponse copyWith({
    Object? data = unsetCopyWithValue,
    Object? nextPageToken = unsetCopyWithValue,
  }) => ListPromptsResponse(
    data: data == unsetCopyWithValue ? this.data : data as List<Prompt>?,
    nextPageToken: nextPageToken == unsetCopyWithValue
        ? this.nextPageToken
        : nextPageToken as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListPromptsResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPageToken == other.nextPageToken;

  @override
  int get hashCode => Object.hash(listHash(data), nextPageToken);

  @override
  String toString() =>
      'ListPromptsResponse(data: ${data?.length} items, '
      'nextPageToken: $nextPageToken)';
}
