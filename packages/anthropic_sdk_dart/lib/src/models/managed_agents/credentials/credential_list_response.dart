import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'credential.dart';

/// Response containing a paginated list of credentials.
@immutable
class ListCredentialsResponse {
  /// List of credentials.
  final List<Credential> data;

  /// Pagination token for the next page, or null if no more results.
  final String? nextPage;

  /// Creates a [ListCredentialsResponse].
  const ListCredentialsResponse({required this.data, this.nextPage});

  /// Creates a [ListCredentialsResponse] from JSON.
  factory ListCredentialsResponse.fromJson(Map<String, dynamic> json) {
    return ListCredentialsResponse(
      data:
          (json['data'] as List?)
              ?.map((e) => Credential.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nextPage: json['next_page'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    if (nextPage != null) 'next_page': nextPage,
  };

  /// Creates a copy with replaced values.
  ListCredentialsResponse copyWith({
    List<Credential>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return ListCredentialsResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListCredentialsResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'ListCredentialsResponse(data: $data, nextPage: $nextPage)';
}
