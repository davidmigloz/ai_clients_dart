import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'vault.dart';

/// Response containing a paginated list of vaults.
@immutable
class ListVaultsResponse {
  /// List of vaults.
  final List<Vault> data;

  /// Pagination token for the next page, or null if no more results.
  final String? nextPage;

  /// Creates a [ListVaultsResponse].
  const ListVaultsResponse({required this.data, this.nextPage});

  /// Creates a [ListVaultsResponse] from JSON.
  factory ListVaultsResponse.fromJson(Map<String, dynamic> json) {
    return ListVaultsResponse(
      data:
          (json['data'] as List?)
              ?.map((e) => Vault.fromJson(e as Map<String, dynamic>))
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
  ListVaultsResponse copyWith({
    List<Vault>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return ListVaultsResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListVaultsResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() => 'ListVaultsResponse(data: $data, nextPage: $nextPage)';
}
