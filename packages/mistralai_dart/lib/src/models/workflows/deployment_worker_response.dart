import 'package:meta/meta.dart';

/// Response for a deployment worker.
@immutable
class DeploymentWorkerResponse {
  /// The worker name.
  final String name;

  /// Creation timestamp.
  final String createdAt;

  /// Last update timestamp.
  final String updatedAt;

  /// Creates a [DeploymentWorkerResponse].
  const DeploymentWorkerResponse({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [DeploymentWorkerResponse] from JSON.
  factory DeploymentWorkerResponse.fromJson(Map<String, dynamic> json) =>
      DeploymentWorkerResponse(
        name: json['name'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  /// Creates a copy with replaced values.
  DeploymentWorkerResponse copyWith({
    String? name,
    String? createdAt,
    String? updatedAt,
  }) {
    return DeploymentWorkerResponse(
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentWorkerResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hash(name, createdAt, updatedAt);

  @override
  String toString() =>
      'DeploymentWorkerResponse(name: $name, createdAt: $createdAt, updatedAt: $updatedAt)';
}
