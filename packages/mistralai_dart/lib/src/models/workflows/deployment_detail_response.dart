import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'deployment_worker_response.dart';

/// Detailed response for a deployment.
@immutable
class DeploymentDetailResponse {
  /// The deployment identifier.
  final String id;

  /// The deployment name.
  final String name;

  /// Whether the deployment is active.
  final bool isActive;

  /// Creation timestamp.
  final String createdAt;

  /// Last update timestamp.
  final String updatedAt;

  /// Workers in this deployment.
  final List<DeploymentWorkerResponse> workers;

  /// Creates a [DeploymentDetailResponse].
  DeploymentDetailResponse({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required List<DeploymentWorkerResponse> workers,
  }) : workers = List.unmodifiable(workers);

  /// Creates a [DeploymentDetailResponse] from JSON.
  factory DeploymentDetailResponse.fromJson(Map<String, dynamic> json) =>
      DeploymentDetailResponse(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? false,
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
        workers:
            (json['workers'] as List?)
                ?.map(
                  (e) => DeploymentWorkerResponse.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'is_active': isActive,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'workers': workers.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  DeploymentDetailResponse copyWith({
    String? id,
    String? name,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    List<DeploymentWorkerResponse>? workers,
  }) {
    return DeploymentDetailResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workers: workers ?? this.workers,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentDetailResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(workers, other.workers)) return false;
    return id == other.id &&
        name == other.name &&
        isActive == other.isActive &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, isActive, createdAt, updatedAt, listHash(workers));

  @override
  String toString() =>
      'DeploymentDetailResponse('
      'id: $id, '
      'name: $name, '
      'isActive: $isActive, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'workers: ${workers.length}'
      ')';
}
