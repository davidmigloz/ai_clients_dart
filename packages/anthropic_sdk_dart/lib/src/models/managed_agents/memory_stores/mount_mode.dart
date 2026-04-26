/// Access mode for a memory store mounted into a session.
enum MountMode {
  /// Read-write mount — the agent can both read and modify memories.
  readWrite('read_write'),

  /// Read-only mount — the agent can read but not modify memories.
  readOnly('read_only'),

  /// Unknown mount mode — fallback for unrecognized values.
  unknown('unknown');

  const MountMode(this.value);

  /// JSON value for this mount mode.
  final String value;

  /// Parses a [MountMode] from JSON.
  static MountMode fromJson(String value) => switch (value) {
    'read_write' => MountMode.readWrite,
    'read_only' => MountMode.readOnly,
    _ => MountMode.unknown,
  };

  /// Converts this mount mode to JSON.
  String toJson() => value;
}
