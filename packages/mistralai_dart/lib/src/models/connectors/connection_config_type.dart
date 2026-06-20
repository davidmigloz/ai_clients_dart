/// The type of a connector connection config.
enum ConnectionConfigType {
  /// Model Context Protocol.
  mcp('mcp'),

  /// Turbine connection.
  turbine('turbine'),

  /// Eolienne connection.
  eolienne('eolienne'),

  /// Unknown connection config type (forward-compatibility fallback).
  unknown('unknown');

  const ConnectionConfigType(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [ConnectionConfigType] from a JSON string value.
  static ConnectionConfigType fromJson(String? value) {
    if (value == null) return ConnectionConfigType.unknown;
    return ConnectionConfigType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ConnectionConfigType.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
