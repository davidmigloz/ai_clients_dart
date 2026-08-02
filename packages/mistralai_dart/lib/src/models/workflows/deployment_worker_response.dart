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
  ///
  /// Throws a [FormatException] if a required field is missing.
  factory DeploymentWorkerResponse.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    if (name == null) {
      throw const FormatException(
        'DeploymentWorkerResponse: missing required field "name"',
      );
    }
    final isActive = json['is_active'] as bool?;
    if (isActive == null) {
      throw const FormatException(
        'DeploymentWorkerResponse: missing required field "is_active"',
      );
    }
    final createdAt = json['created_at'] as String?;
    if (createdAt == null) {
      throw const FormatException(
        'DeploymentWorkerResponse: missing required field "created_at"',
      );
    }
    final updatedAt = json['updated_at'] as String?;
    if (updatedAt == null) {
      throw const FormatException(
        'DeploymentWorkerResponse: missing required field "updated_at"',
      );
    }
    return DeploymentWorkerResponse(
      name: name,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      location: json['location'] == null
          ? null
          : DeploymentLocation.fromJson(
              json['location'] as Map<String, dynamic>,
            ),
    );
  }

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
