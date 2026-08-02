import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'prompt_version.dart';

/// Response returned by listing the versions of a prompt.
@immutable
class ListPromptVersionsResponse {
  /// The versions of the prompt.
  final List<PromptVersion>? data;

  /// Creates a [ListPromptVersionsResponse].
  const ListPromptVersionsResponse({this.data});

  /// Creates a [ListPromptVersionsResponse] from JSON.
  factory ListPromptVersionsResponse.fromJson(Map<String, dynamic> json) =>
      ListPromptVersionsResponse(
        data: (json['data'] as List?)
            ?.map((e) => PromptVersion.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (data != null) 'data': data!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  ListPromptVersionsResponse copyWith({Object? data = unsetCopyWithValue}) =>
      ListPromptVersionsResponse(
        data: data == unsetCopyWithValue
            ? this.data
            : data as List<PromptVersion>?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListPromptVersionsResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data);

  @override
  int get hashCode => listHash(data);

  @override
  String toString() =>
      'ListPromptVersionsResponse(data: ${data?.length} items)';
}
