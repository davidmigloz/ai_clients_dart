import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'deployment_run.dart';

/// Paginated list of deployment runs.
///
/// Sorted by created_at descending (most recent first).
@immutable
class DeploymentRunListResponse {
  /// List of deployment runs.
  final List<DeploymentRun> data;

  /// Opaque cursor for the next page, or null when no more results.
  final String? nextPage;

  /// Creates a [DeploymentRunListResponse].
  const DeploymentRunListResponse({required this.data, this.nextPage});

  /// Creates a [DeploymentRunListResponse] from JSON.
  factory DeploymentRunListResponse.fromJson(Map<String, dynamic> json) {
    return DeploymentRunListResponse(
      data:
          (json['data'] as List?)
              ?.map((e) => DeploymentRun.fromJson(e as Map<String, dynamic>))
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
  DeploymentRunListResponse copyWith({
    List<DeploymentRun>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return DeploymentRunListResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentRunListResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'DeploymentRunListResponse(data: ${data.length} items, '
      'nextPage: $nextPage)';
}
