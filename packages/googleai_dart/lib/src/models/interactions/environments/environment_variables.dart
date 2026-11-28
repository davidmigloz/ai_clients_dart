part of 'environments.dart';

/// The string or map accepted by the sandbox's `env` field.
sealed class EnvironmentVariables {
  const EnvironmentVariables();

  /// Supplies the complete `env` value as a string.
  const factory EnvironmentVariables.text(String value) =
      EnvironmentVariablesText;

  /// Supplies a map of variable names to literal values or credentials.
  const factory EnvironmentVariables.map(Map<String, EnvVar> variables) =
      EnvironmentVariablesMap;

  /// Parses either wire representation.
  factory EnvironmentVariables.fromJson(Object json) => switch (json) {
    String() => EnvironmentVariablesText(json),
    Map<String, dynamic>() => EnvironmentVariablesMap({
      for (final entry in json.entries) entry.key: EnvVar.fromJson(entry.value),
    }),
    _ => throw const FormatException('Expected an environment string or map'),
  };

  /// Encodes the `env` value.
  Object toJson();
}

/// A string supplied as the complete `env` value.
final class EnvironmentVariablesText extends EnvironmentVariables {
  /// The wire value.
  final String value;

  /// Creates a string environment value.
  const EnvironmentVariablesText(this.value);

  @override
  String toJson() => value;
}

/// A map of variables to configure in the sandbox.
final class EnvironmentVariablesMap extends EnvironmentVariables {
  /// Variable names and their values.
  final Map<String, EnvVar> variables;

  /// Creates a map of environment variables.
  const EnvironmentVariablesMap(this.variables);

  @override
  Map<String, Object> toJson() => {
    for (final entry in variables.entries) entry.key: entry.value.toJson(),
  };
}

/// One sandbox variable, encoded as a literal string or a structured value.
final class EnvVar {
  final bool _literal;

  /// Plain text to set in the sandbox.
  ///
  /// Use a [credential] reference for secrets.
  final String? value;

  /// The ID of a stored server-managed credential.
  final String? credential;

  /// Creates a structured variable with a value or credential reference.
  const EnvVar({this.value, this.credential}) : _literal = false;

  /// Encodes [value] directly as a string.
  const EnvVar.literal(String this.value) : credential = null, _literal = true;

  /// Parses a literal string or an object containing variable fields.
  factory EnvVar.fromJson(Object? json) => switch (json) {
    String() => EnvVar.literal(json),
    Map<String, dynamic>() => EnvVar(
      value: json['value'] as String?,
      credential: json['credential'] as String?,
    ),
    _ => throw const FormatException('Expected a variable string or object'),
  };

  /// Encodes the variable in the original wire form.
  Object toJson() => _literal
      ? value!
      : <String, String>{'value': ?value, 'credential': ?credential};
}
