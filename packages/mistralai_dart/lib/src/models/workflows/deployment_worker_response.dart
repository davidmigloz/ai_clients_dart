import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'deployment_location.dart';

/// Response for a deployment worker.
@immutable
class DeploymentWorkerResponse {
  /// The worker name.
  final String name;

  /// Whether the worker is active.
  final bool isActive;

  /// Creation timestamp.
  final String createdAt;

  /// Last update timestamp.
  final String updatedAt;

  /// Where the worker is running; `null` if the worker did not report a
  /// location.
  final DeploymentLocation? location;

  /// Creates a [DeploymentWorkerResponse].
  const DeploymentWorkerResponse({
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.location,
  });

  /// Creates a [DeploymentWorkerResponse] from JSON.
  factory DeploymentWorkerResponse.fromJson(Map<String, dynamic> json) =>
      DeploymentWorkerResponse(
        name: json['name'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? false,
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
        location: json['location'] == null
            ? null
            : DeploymentLocation.fromJson(
                json['location'] as Map<String, dynamic>,
              ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'is_active': isActive,
    'created_at': createdAt,
    'updated_at': updatedAt,
    if (location != null) 'location': location!.toJson(),
  };

  /// Creates a copy with replaced values.
  DeploymentWorkerResponse copyWith({
    String? name,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    Object? location = unsetCopyWithValue,
  }) {
    return DeploymentWorkerResponse(
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location == unsetCopyWithValue
          ? this.location
          : location as DeploymentLocation?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentWorkerResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name &&
        isActive == other.isActive &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        location == other.location;
  }

  @override
  int get hashCode =>
      Object.hash(name, isActive, createdAt, updatedAt, location);

  @override
  String toString() =>
      'DeploymentWorkerResponse(name: $name, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, location: $location)';
}
