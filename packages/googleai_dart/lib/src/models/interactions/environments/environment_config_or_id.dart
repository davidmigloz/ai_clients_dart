part of 'environments.dart';

/// The `environment` value for an interaction or agent.
///
/// Either an inline [EnvironmentConfig] ([InlineEnvironmentConfig]) describing a
/// remote sandbox, or a string referencing an existing environment by id
/// ([EnvironmentIdRef]).
sealed class EnvironmentConfigOrId {
  const EnvironmentConfigOrId();

  /// Wraps an inline [EnvironmentConfig].
  const factory EnvironmentConfigOrId.config(EnvironmentConfig config) =
      InlineEnvironmentConfig;

  /// References an existing environment by [id].
  const factory EnvironmentConfigOrId.id(String id) = EnvironmentIdRef;

  /// Creates an [EnvironmentConfigOrId] from a JSON value.
  ///
  /// A [Map] is parsed as an inline [EnvironmentConfig]
  /// ([InlineEnvironmentConfig]); a [String] is parsed as an environment id
  /// reference ([EnvironmentIdRef]).
  factory EnvironmentConfigOrId.fromJson(Object json) {
    if (json is Map<String, dynamic>) {
      return InlineEnvironmentConfig(EnvironmentConfig.fromJson(json));
    }
    if (json is String) {
      return EnvironmentIdRef(json);
    }
    throw ArgumentError(
      'Unknown environment value: expected an object or a string id, got '
      '${json.runtimeType}',
    );
  }

  /// Converts to its JSON representation (an object or a string id).
  Object toJson();
}

/// An inline [EnvironmentConfig] environment value.
class InlineEnvironmentConfig extends EnvironmentConfigOrId {
  /// The environment configuration.
  final EnvironmentConfig config;

  /// Creates an [InlineEnvironmentConfig].
  const InlineEnvironmentConfig(this.config);

  @override
  Object toJson() => config.toJson();
}

/// A reference to an existing environment by id.
class EnvironmentIdRef extends EnvironmentConfigOrId {
  /// The environment id.
  final String id;

  /// Creates an [EnvironmentIdRef].
  const EnvironmentIdRef(this.id);

  @override
  Object toJson() => id;
}
