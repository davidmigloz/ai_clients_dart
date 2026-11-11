import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'environment_config.dart';

/// Visibility for an environment.
enum EnvironmentScope {
  /// Visible to eligible accounts in the organization.
  organization,

  /// Restricted to the owning account. API organizations do not support it.
  account,
}

/// Request to create a Managed Agents environment.
@immutable
final class CreateEnvironmentParams {
  /// Display name.
  final String name;

  /// The cloud or self-hosted configuration.
  EnvironmentConfigParams? get config => _config == unsetCopyWithValue
      ? null
      : _config as EnvironmentConfigParams?;
  final Object? _config;

  /// The description.
  String? get description =>
      _description == unsetCopyWithValue ? null : _description as String?;
  final Object? _description;

  /// The visibility scope.
  EnvironmentScope? get scope =>
      _scope == unsetCopyWithValue ? null : _scope as EnvironmentScope?;
  final Object? _scope;

  /// User-provided metadata.
  final Map<String, String>? metadata;

  /// Creates a [CreateEnvironmentParams].
  ///
  /// Omit an optional field to omit its wire key. Pass null to send JSON null.
  const CreateEnvironmentParams({
    required this.name,
    this._config = unsetCopyWithValue,
    this._description = unsetCopyWithValue,
    this._scope = unsetCopyWithValue,
    this.metadata,
  });

  /// Reads a [CreateEnvironmentParams] from JSON.
  factory CreateEnvironmentParams.fromJson(Map<String, dynamic> json) {
    return CreateEnvironmentParams(
      name: json['name'] as String,
      config: json.containsKey('config')
          ? (json['config'] == null
                ? null
                : EnvironmentConfigParams.fromJson(
                    json['config'] as Map<String, dynamic>,
                  ))
          : unsetCopyWithValue,
      description: json.containsKey('description')
          ? (json['description'] as String?)
          : unsetCopyWithValue,
      scope: json.containsKey('scope')
          ? (json['scope'] == null
                ? null
                : EnvironmentScope.values.byName(json['scope'] as String))
          : unsetCopyWithValue,
      metadata: (json['metadata'] as Map?)?.cast<String, String>(),
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (_config != unsetCopyWithValue) 'config': config?.toJson(),
    if (_description != unsetCopyWithValue) 'description': description,
    if (_scope != unsetCopyWithValue) 'scope': scope?.name,
    if (metadata != null) 'metadata': metadata,
  };

  /// Copies this object with the selected values replaced.
  CreateEnvironmentParams copyWith({
    String? name,
    Object? config = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? scope = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) => CreateEnvironmentParams(
    name: name ?? this.name,
    config: config == unsetCopyWithValue ? _config : config,
    description: description == unsetCopyWithValue ? _description : description,
    scope: scope == unsetCopyWithValue ? _scope : scope,
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : (metadata as Map?)?.cast<String, String>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateEnvironmentParams &&
          name == other.name &&
          mapsEqual(metadata, other.metadata) &&
          (_config == unsetCopyWithValue) ==
              (other._config == unsetCopyWithValue) &&
          config == other.config &&
          (_description == unsetCopyWithValue) ==
              (other._description == unsetCopyWithValue) &&
          description == other.description &&
          (_scope == unsetCopyWithValue) ==
              (other._scope == unsetCopyWithValue) &&
          scope == other.scope;

  @override
  int get hashCode => Object.hash(
    name,
    mapHash(metadata),
    _config == unsetCopyWithValue ? unsetCopyWithValue : config,
    _description == unsetCopyWithValue ? unsetCopyWithValue : description,
    _scope == unsetCopyWithValue ? unsetCopyWithValue : scope,
  );

  @override
  String toString() =>
      'CreateEnvironmentParams(name: $name, metadata: $metadata, config: $config, description: $description, scope: $scope)';
}

/// Partial update to a Managed Agents environment.
@immutable
final class UpdateEnvironmentParams {
  /// Updated display name.
  String? get name => _name == unsetCopyWithValue ? null : _name as String?;
  final Object? _name;

  /// The cloud or self-hosted configuration.
  EnvironmentConfigParams? get config => _config == unsetCopyWithValue
      ? null
      : _config as EnvironmentConfigParams?;
  final Object? _config;

  /// The description.
  String? get description =>
      _description == unsetCopyWithValue ? null : _description as String?;
  final Object? _description;

  /// The visibility scope.
  EnvironmentScope? get scope =>
      _scope == unsetCopyWithValue ? null : _scope as EnvironmentScope?;
  final Object? _scope;

  /// Metadata patch. Null or an empty string deletes an individual key.
  final Map<String, String?>? metadata;

  /// Creates a [UpdateEnvironmentParams].
  ///
  /// Omit an optional field to omit its wire key. Pass null to send JSON null.
  const UpdateEnvironmentParams({
    this._name = unsetCopyWithValue,
    this._config = unsetCopyWithValue,
    this._description = unsetCopyWithValue,
    this._scope = unsetCopyWithValue,
    this.metadata,
  });

  /// Reads a [UpdateEnvironmentParams] from JSON.
  factory UpdateEnvironmentParams.fromJson(Map<String, dynamic> json) {
    return UpdateEnvironmentParams(
      name: json.containsKey('name')
          ? (json['name'] as String?)
          : unsetCopyWithValue,
      config: json.containsKey('config')
          ? (json['config'] == null
                ? null
                : EnvironmentConfigParams.fromJson(
                    json['config'] as Map<String, dynamic>,
                  ))
          : unsetCopyWithValue,
      description: json.containsKey('description')
          ? (json['description'] as String?)
          : unsetCopyWithValue,
      scope: json.containsKey('scope')
          ? (json['scope'] == null
                ? null
                : EnvironmentScope.values.byName(json['scope'] as String))
          : unsetCopyWithValue,
      metadata: (json['metadata'] as Map?)?.cast<String, String?>(),
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    if (_name != unsetCopyWithValue) 'name': name,
    if (_config != unsetCopyWithValue) 'config': config?.toJson(),
    if (_description != unsetCopyWithValue) 'description': description,
    if (_scope != unsetCopyWithValue) 'scope': scope?.name,
    if (metadata != null) 'metadata': metadata,
  };

  /// Copies this object with the selected values replaced.
  UpdateEnvironmentParams copyWith({
    Object? name = unsetCopyWithValue,
    Object? config = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? scope = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) => UpdateEnvironmentParams(
    name: name == unsetCopyWithValue ? _name : name,
    config: config == unsetCopyWithValue ? _config : config,
    description: description == unsetCopyWithValue ? _description : description,
    scope: scope == unsetCopyWithValue ? _scope : scope,
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : (metadata as Map?)?.cast<String, String?>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateEnvironmentParams &&
          mapsEqual(metadata, other.metadata) &&
          (_name == unsetCopyWithValue) ==
              (other._name == unsetCopyWithValue) &&
          name == other.name &&
          (_config == unsetCopyWithValue) ==
              (other._config == unsetCopyWithValue) &&
          config == other.config &&
          (_description == unsetCopyWithValue) ==
              (other._description == unsetCopyWithValue) &&
          description == other.description &&
          (_scope == unsetCopyWithValue) ==
              (other._scope == unsetCopyWithValue) &&
          scope == other.scope;

  @override
  int get hashCode => Object.hash(
    mapHash(metadata),
    _name == unsetCopyWithValue ? unsetCopyWithValue : name,
    _config == unsetCopyWithValue ? unsetCopyWithValue : config,
    _description == unsetCopyWithValue ? unsetCopyWithValue : description,
    _scope == unsetCopyWithValue ? unsetCopyWithValue : scope,
  );

  @override
  String toString() =>
      'UpdateEnvironmentParams(metadata: $metadata, name: $name, config: $config, description: $description, scope: $scope)';
}
