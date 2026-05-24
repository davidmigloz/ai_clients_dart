part of 'environments.dart';

/// The `environment` value for an interaction or agent.
///
/// Either an inline [EnvironmentConfig] ([InlineEnvironmentConfig]) describing a
/// remote sandbox, or a string reference ([EnvironmentIdRef]) — typically an
/// existing environment id, but the API also accepts literals such as
/// `"remote"`.
sealed class EnvironmentConfigOrId {
  const EnvironmentConfigOrId();

  /// Wraps an inline [EnvironmentConfig].
  const factory EnvironmentConfigOrId.config(EnvironmentConfig config) =
      InlineEnvironmentConfig;

  /// References an environment by the string [id].
  ///
  /// Typically an existing environment id, but the API also accepts literals
  /// such as `"remote"`.
  const factory EnvironmentConfigOrId.id(String id) = EnvironmentIdRef;

  /// Creates an [EnvironmentConfigOrId] from a JSON value.
  ///
  /// A [Map] is parsed as an inline [EnvironmentConfig]
  /// ([InlineEnvironmentConfig]); a [String] is parsed as an environment
  /// reference ([EnvironmentIdRef]).
  factory EnvironmentConfigOrId.fromJson(Object json) {
    if (json is Map<String, dynamic>) {
      return InlineEnvironmentConfig(EnvironmentConfig.fromJson(json));
    }
    if (json is String) {
      return EnvironmentIdRef(json);
    }
    throw ArgumentError(
      'Unknown environment value: expected an object or a string reference, '
      'got ${json.runtimeType}',
    );
  }

  /// Converts to its JSON representation (an object or a string reference).
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

/// A string reference to an environment — an existing environment id, or a
/// literal such as `"remote"`.
class EnvironmentIdRef extends EnvironmentConfigOrId {
  /// The environment reference string (an existing environment id, or a literal
  /// such as `"remote"`).
  final String id;

  /// Creates an [EnvironmentIdRef].
  const EnvironmentIdRef(this.id);

  @override
  Object toJson() => id;
}
