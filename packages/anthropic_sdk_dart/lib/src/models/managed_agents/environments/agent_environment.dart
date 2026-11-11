import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'environment_config.dart';

/// A Claude Managed Agents environment.
@immutable
final class AgentEnvironment {
  /// The wire discriminator.
  String get type => 'environment';

  /// Environment identifier.
  final String id;

  /// When archived, or null when active.
  final DateTime? archivedAt;

  /// The cloud or self-hosted configuration.
  final EnvironmentConfig config;

  /// When created.
  final DateTime createdAt;

  /// The description, if set.
  final String? description;

  /// User-provided metadata.
  final Map<String, String> metadata;

  /// Display name.
  final String name;

  /// When last updated.
  final DateTime updatedAt;

  /// Visibility scope as supplied by the server.
  final String? scope;

  /// Creates a [AgentEnvironment].
  const AgentEnvironment({
    required this.id,
    required this.archivedAt,
    required this.config,
    required this.createdAt,
    required this.description,
    required this.metadata,
    required this.name,
    required this.updatedAt,
    this.scope,
  });

  /// Reads a [AgentEnvironment] from JSON.
  factory AgentEnvironment.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'environment');
    return AgentEnvironment(
      id: json['id'] as String,
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      config: EnvironmentConfig.fromJson(
        json['config'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      description: json['description'] as String?,
      metadata: (json['metadata'] as Map).cast<String, String>(),
      name: json['name'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      scope: json['scope'] as String?,
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'archived_at': archivedAt?.toUtc().toIso8601String(),
    'config': config.toJson(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'description': description,
    'metadata': metadata,
    'name': name,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    if (scope != null) 'scope': scope,
  };

  /// Copies this object with the selected values replaced.
  AgentEnvironment copyWith({
    String? id,
    Object? archivedAt = unsetCopyWithValue,
    EnvironmentConfig? config,
    DateTime? createdAt,
    Object? description = unsetCopyWithValue,
    Map<String, String>? metadata,
    String? name,
    DateTime? updatedAt,
    Object? scope = unsetCopyWithValue,
  }) => AgentEnvironment(
    id: id ?? this.id,
    archivedAt: archivedAt == unsetCopyWithValue
        ? this.archivedAt
        : archivedAt as DateTime?,
    config: config ?? this.config,
    createdAt: createdAt ?? this.createdAt,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    metadata: metadata ?? this.metadata,
    name: name ?? this.name,
    updatedAt: updatedAt ?? this.updatedAt,
    scope: scope == unsetCopyWithValue ? this.scope : scope as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentEnvironment &&
          id == other.id &&
          archivedAt == other.archivedAt &&
          config == other.config &&
          createdAt == other.createdAt &&
          description == other.description &&
          mapsEqual(metadata, other.metadata) &&
          name == other.name &&
          updatedAt == other.updatedAt &&
          scope == other.scope;

  @override
  int get hashCode => Object.hash(
    id,
    archivedAt,
    config,
    createdAt,
    description,
    mapHash(metadata),
    name,
    updatedAt,
    scope,
  );

  @override
  String toString() =>
      'AgentEnvironment(id: $id, archivedAt: $archivedAt, config: $config, createdAt: $createdAt, description: $description, metadata: $metadata, name: $name, updatedAt: $updatedAt, scope: $scope)';
}

/// One page of environments.
@immutable
final class EnvironmentListResponse {
  /// Environments in this page.
  final List<AgentEnvironment> data;

  /// Opaque cursor, or null when there are no more pages.
  final String? nextPage;

  /// Creates a [EnvironmentListResponse].
  const EnvironmentListResponse({required this.data, required this.nextPage});

  /// Reads a [EnvironmentListResponse] from JSON.
  factory EnvironmentListResponse.fromJson(Map<String, dynamic> json) {
    return EnvironmentListResponse(
      data: (json['data'] as List)
          .map(
            (item) => AgentEnvironment.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      nextPage: json['next_page'] as String?,
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    'next_page': nextPage,
  };

  /// Copies this object with the selected values replaced.
  EnvironmentListResponse copyWith({
    List<AgentEnvironment>? data,
    Object? nextPage = unsetCopyWithValue,
  }) => EnvironmentListResponse(
    data: data ?? this.data,
    nextPage: nextPage == unsetCopyWithValue
        ? this.nextPage
        : nextPage as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentListResponse &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'EnvironmentListResponse(data: $data, nextPage: $nextPage)';
}

/// Confirmation that an environment was deleted.
@immutable
final class EnvironmentDeleteResponse {
  /// The wire discriminator.
  String get type => 'environment_deleted';

  /// Identifier of the deleted environment.
  final String id;

  /// Creates a [EnvironmentDeleteResponse].
  const EnvironmentDeleteResponse({required this.id});

  /// Reads a [EnvironmentDeleteResponse] from JSON.
  factory EnvironmentDeleteResponse.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'environment_deleted');
    return EnvironmentDeleteResponse(id: json['id'] as String);
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {'type': type, 'id': id};

  /// Copies this object with the selected values replaced.
  EnvironmentDeleteResponse copyWith({String? id}) =>
      EnvironmentDeleteResponse(id: id ?? this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentDeleteResponse && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'EnvironmentDeleteResponse(id: $id)';
}

void _validateType(Map<String, dynamic> json, String type) {
  if (json.containsKey('type') && json['type'] != type) {
    throw FormatException('Expected $type, got ${json['type']}');
  }
}
