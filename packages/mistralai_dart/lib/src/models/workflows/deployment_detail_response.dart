import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'deployment_location.dart';
import 'deployment_worker_response.dart';
import 'location_type.dart';
import 'managed_deployment_response.dart';

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

  /// Whether the deployment is hardened.
  final bool isHardened;

  /// The deployment location.
  final DeploymentLocation? location;

  /// Number of workers currently live within the liveness cutoff.
  final int activeWorkerCount;

  /// Number of workers registered to the deployment.
  final int workerCount;

  /// Distinct location types reported by the deployment's workers.
  final List<LocationType> locations;

  /// Live managed service state for managed deployments; `null` for
  /// self-hosted deployments or when managed services are unavailable.
  final ManagedDeploymentResponse? managed;

  /// Creates a [DeploymentDetailResponse].
  DeploymentDetailResponse({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required List<DeploymentWorkerResponse> workers,
    this.isHardened = false,
    this.location,
    this.activeWorkerCount = 0,
    this.workerCount = 0,
    List<LocationType> locations = const [],
    this.managed,
  }) : workers = List.unmodifiable(workers),
       locations = List.unmodifiable(locations);

  /// Creates a [DeploymentDetailResponse] from JSON.
  factory DeploymentDetailResponse.fromJson(
    Map<String, dynamic> json,
  ) => DeploymentDetailResponse(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    isActive: json['is_active'] as bool? ?? false,
    createdAt: json['created_at'] as String? ?? '',
    updatedAt: json['updated_at'] as String? ?? '',
    workers:
        (json['workers'] as List?)
            ?.map(
              (e) =>
                  DeploymentWorkerResponse.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [],
    isHardened: json['is_hardened'] as bool? ?? false,
    location: json['location'] == null
        ? null
        : DeploymentLocation.fromJson(json['location'] as Map<String, dynamic>),
    activeWorkerCount: json['active_worker_count'] as int? ?? 0,
    workerCount: json['worker_count'] as int? ?? 0,
    locations:
        (json['locations'] as List?)
            ?.map((e) => LocationType.fromJson(e as String?))
            .toList() ??
        const [],
    managed: json['managed'] == null
        ? null
        : ManagedDeploymentResponse.fromJson(
            json['managed'] as Map<String, dynamic>,
          ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'is_active': isActive,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'workers': workers.map((e) => e.toJson()).toList(),
    'is_hardened': isHardened,
    if (location != null) 'location': location!.toJson(),
    'active_worker_count': activeWorkerCount,
    'worker_count': workerCount,
    'locations': locations.map((e) => e.toJson()).toList(),
    if (managed != null) 'managed': managed!.toJson(),
  };

  /// Creates a copy with replaced values.
  DeploymentDetailResponse copyWith({
    String? id,
    String? name,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    List<DeploymentWorkerResponse>? workers,
    bool? isHardened,
    Object? location = unsetCopyWithValue,
    int? activeWorkerCount,
    int? workerCount,
    List<LocationType>? locations,
    Object? managed = unsetCopyWithValue,
  }) {
    return DeploymentDetailResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workers: workers ?? this.workers,
      isHardened: isHardened ?? this.isHardened,
      location: location == unsetCopyWithValue
          ? this.location
          : location as DeploymentLocation?,
      activeWorkerCount: activeWorkerCount ?? this.activeWorkerCount,
      workerCount: workerCount ?? this.workerCount,
      locations: locations ?? this.locations,
      managed: managed == unsetCopyWithValue
          ? this.managed
          : managed as ManagedDeploymentResponse?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentDetailResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(workers, other.workers)) return false;
    if (!listsEqual(locations, other.locations)) return false;
    return id == other.id &&
        name == other.name &&
        isActive == other.isActive &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        isHardened == other.isHardened &&
        location == other.location &&
        activeWorkerCount == other.activeWorkerCount &&
        workerCount == other.workerCount &&
        managed == other.managed;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    isActive,
    createdAt,
    updatedAt,
    listHash(workers),
    isHardened,
    location,
    activeWorkerCount,
    workerCount,
    Object.hash(listHash(locations), managed),
  );

  @override
  String toString() =>
      'DeploymentDetailResponse('
      'id: $id, '
      'name: $name, '
      'isActive: $isActive, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'workers: ${workers.length}, '
      'isHardened: $isHardened, '
      'location: $location, '
      'activeWorkerCount: $activeWorkerCount, '
      'workerCount: $workerCount, '
      'locations: $locations, '
      'managed: $managed'
      ')';
}
