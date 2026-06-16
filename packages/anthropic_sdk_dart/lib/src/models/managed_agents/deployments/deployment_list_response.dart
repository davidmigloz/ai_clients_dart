import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'deployment.dart';

/// Paginated list of deployments.
@immutable
class DeploymentListResponse {
  /// List of deployments.
  final List<Deployment> data;

  /// Opaque cursor for the next page, or null when no more results.
  final String? nextPage;

  /// Creates a [DeploymentListResponse].
  const DeploymentListResponse({required this.data, this.nextPage});

  /// Creates a [DeploymentListResponse] from JSON.
  factory DeploymentListResponse.fromJson(Map<String, dynamic> json) {
    return DeploymentListResponse(
      data:
          (json['data'] as List?)
              ?.map((e) => Deployment.fromJson(e as Map<String, dynamic>))
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
  DeploymentListResponse copyWith({
    List<Deployment>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return DeploymentListResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentListResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'DeploymentListResponse(data: ${data.length} items, '
      'nextPage: $nextPage)';
}
