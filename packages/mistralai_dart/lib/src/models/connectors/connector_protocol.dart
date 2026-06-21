/// The protocol a connector speaks.
enum ConnectorProtocol {
  /// Model Context Protocol.
  mcp('mcp'),

  /// Plain HTTP.
  http('http'),

  /// Turbine protocol.
  turbine('turbine'),

  /// Unknown protocol (forward-compatibility fallback).
  unknown('unknown');

  const ConnectorProtocol(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [ConnectorProtocol] from a JSON string value.
  static ConnectorProtocol fromJson(String? value) {
    if (value == null) return ConnectorProtocol.unknown;
    return ConnectorProtocol.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ConnectorProtocol.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
