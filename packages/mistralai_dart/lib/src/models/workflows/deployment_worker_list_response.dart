import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'deployment_worker_response.dart';

/// Cursor-paginated deployment workers.
@immutable
class DeploymentWorkerListResponse {
  /// Workers returned on this page.
  final List<DeploymentWorkerResponse> workers;

  /// Cursor for the next page. Null indicates the last page.
  final String? nextCursor;

  /// Creates a [DeploymentWorkerListResponse].
  const DeploymentWorkerListResponse({
    required this.workers,
    required this.nextCursor,
  });

  /// Creates a [DeploymentWorkerListResponse] from JSON.
  factory DeploymentWorkerListResponse.fromJson(Map<String, dynamic> json) {
    final workers = (json['workers'] as List<dynamic>?)
        ?.map(
          (value) =>
              DeploymentWorkerResponse.fromJson(value as Map<String, dynamic>),
        )
        .toList();
    final nextCursor = json['next_cursor'] as String?;
    if (workers == null) {
      throw const FormatException(
        'DeploymentWorkerListResponse: missing required "workers"',
      );
    }
    if (!json.containsKey('next_cursor')) {
      throw const FormatException(
        'DeploymentWorkerListResponse: missing required "next_cursor"',
      );
    }
    return DeploymentWorkerListResponse(
      workers: workers,
      nextCursor: nextCursor,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'workers': workers.map((value) => value.toJson()).toList(),
    'next_cursor': nextCursor,
  };

  /// Creates a copy with the given fields replaced.
  DeploymentWorkerListResponse copyWith({
    List<DeploymentWorkerResponse>? workers,
    Object? nextCursor = unsetCopyWithValue,
  }) => DeploymentWorkerListResponse(
    workers: workers ?? this.workers,
    nextCursor: nextCursor == unsetCopyWithValue
        ? this.nextCursor
        : nextCursor as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentWorkerListResponse &&
          listsEqual(workers, other.workers) &&
          nextCursor == other.nextCursor;

  @override
  int get hashCode => Object.hash(listHash(workers), nextCursor);

  @override
  String toString() =>
      'DeploymentWorkerListResponse(workers: ${workers.length} items, nextCursor: $nextCursor)';
}
