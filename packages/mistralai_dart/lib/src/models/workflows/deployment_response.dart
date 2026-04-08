import 'package:meta/meta.dart';

/// Response for a deployment.
@immutable
class DeploymentResponse {
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

  /// Creates a [DeploymentResponse].
  const DeploymentResponse({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [DeploymentResponse] from JSON.
  factory DeploymentResponse.fromJson(Map<String, dynamic> json) =>
      DeploymentResponse(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? false,
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'is_active': isActive,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  /// Creates a copy with replaced values.
  DeploymentResponse copyWith({
    String? id,
    String? name,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return DeploymentResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return id == other.id &&
        name == other.name &&
        isActive == other.isActive &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, name, isActive, createdAt, updatedAt);

  @override
  String toString() =>
      'DeploymentResponse('
      'id: $id, '
      'name: $name, '
      'isActive: $isActive, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt'
      ')';
}
