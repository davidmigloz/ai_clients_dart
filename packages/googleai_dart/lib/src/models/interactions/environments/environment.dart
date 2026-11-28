part of 'environments.dart';

/// Compute lifecycle mode for a managed-agent environment.
enum EnvironmentMode {
  /// Google provisions the environment on demand.
  onDemand('on_demand'),

  /// Your infrastructure hosts the environment.
  selfHosted('self_hosted');

  const EnvironmentMode(this.value);

  /// The API wire value.
  final String value;

  /// Parses a known lifecycle mode, returning null for other values.
  static EnvironmentMode? fromString(String? value) => switch (value) {
    'on_demand' => EnvironmentMode.onDemand,
    'self_hosted' => EnvironmentMode.selfHosted,
    _ => null,
  };
}

/// The status of an [Environment]'s container.
enum EnvironmentStatus {
  /// The environment is active.
  active,

  /// The environment has expired.
  expired,
}

/// Converts a JSON string to an [EnvironmentStatus], or `null` if unrecognized
/// (forward-compatible).
EnvironmentStatus? environmentStatusFromString(String? value) {
  return switch (value) {
    'active' => EnvironmentStatus.active,
    'expired' => EnvironmentStatus.expired,
    _ => null,
  };
}

/// Converts an [EnvironmentStatus] to its JSON string.
String environmentStatusToString(EnvironmentStatus value) {
  return switch (value) {
    EnvironmentStatus.active => 'active',
    EnvironmentStatus.expired => 'expired',
  };
}

/// An execution environment for an agent.
class Environment {
  /// Output only. The ID of the environment.
  final String id;

  /// Output only. The time at which the environment was created.
  final DateTime? created;

  /// Output only. The time at which the environment was last updated.
  final DateTime? updated;

  /// Output only. The time at which the environment was last accessed.
  final DateTime? lastAccessed;

  /// Output only. The number of files in the environment.
  final String? fileCount;

  /// Output only. The total size of the environment files in bytes.
  final String? sizeBytes;

  /// Network configuration for the environment.
  ///
  /// An [EnvironmentNetworkAllowlist] to restrict egress, or
  /// [EnvironmentNetworkDisabled] to block all network access. Omit to allow
  /// all outbound traffic.
  final EnvironmentNetworkEgressAllowlist? network;

  /// Sources mounted into the environment's sandbox.
  final List<Source>? sources;

  /// Output only. The status of the environment container.
  final EnvironmentStatus? status;

  /// Output only. The compute lifecycle mode, when the service returns it.
  final EnvironmentMode? mode;

  /// The original wire string when [mode] is unrecognized.
  final String? unrecognizedMode;

  /// Output only. Customer configuration for a self-hosted environment.
  final Map<String, dynamic>? customConfig;

  /// Output only. The secret returned when a self-hosted environment is created.
  ///
  /// Store it securely for the sandbox daemon. Get and list responses omit it.
  final String? environmentKey;

  /// Creates an [Environment].
  const Environment({
    required this.id,
    this.created,
    this.updated,
    this.lastAccessed,
    this.fileCount,
    this.sizeBytes,
    this.network,
    this.sources,
    this.status,
    this.mode,
    this.unrecognizedMode,
    this.customConfig,
    this.environmentKey,
  });

  /// Creates an [Environment] from JSON.
  factory Environment.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) {
      throw const FormatException('Environment: expected an ID');
    }
    final wireMode = json['mode'] as String?;
    final mode = EnvironmentMode.fromString(wireMode);
    return Environment(
      id: id,
      created: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : null,
      updated: json['updated'] != null
          ? DateTime.parse(json['updated'] as String)
          : null,
      lastAccessed: json['last_accessed'] != null
          ? DateTime.parse(json['last_accessed'] as String)
          : null,
      fileCount: json['file_count'] as String?,
      sizeBytes: json['size_bytes'] as String?,
      network: json['network'] != null
          ? EnvironmentNetworkEgressAllowlist.fromJson(
              json['network'] as Object,
            )
          : null,
      sources: (json['sources'] as List<dynamic>?)
          ?.map((e) => Source.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: environmentStatusFromString(json['status'] as String?),
      mode: mode,
      unrecognizedMode: mode == null ? wireMode : null,
      customConfig: json['custom_config'] as Map<String, dynamic>?,
      environmentKey: json['environment_key'] as String?,
    );
  }

  /// Creates environment metadata without reading the one-time secret.
  factory Environment.fromMetadataJson(Map<String, dynamic> json) =>
      Environment.fromJson({...json}..remove('environment_key'));

  /// Converts metadata to JSON.
  ///
  /// Read [environmentKey] directly to store a newly issued key securely.
  Map<String, dynamic> toJson() => {
    'id': id,
    if (created != null) 'created': created!.toIso8601String(),
    if (updated != null) 'updated': updated!.toIso8601String(),
    if (lastAccessed != null) 'last_accessed': lastAccessed!.toIso8601String(),
    if (fileCount != null) 'file_count': fileCount,
    if (sizeBytes != null) 'size_bytes': sizeBytes,
    if (network != null) 'network': network!.toJson(),
    if (sources != null) 'sources': sources!.map((e) => e.toJson()).toList(),
    if (status != null) 'status': environmentStatusToString(status!),
    'mode': ?(mode?.value ?? unrecognizedMode),
    'custom_config': ?customConfig,
  };

  /// Creates a copy with replaced values.
  Environment copyWith({
    Object? id = unsetCopyWithValue,
    Object? created = unsetCopyWithValue,
    Object? updated = unsetCopyWithValue,
    Object? lastAccessed = unsetCopyWithValue,
    Object? fileCount = unsetCopyWithValue,
    Object? sizeBytes = unsetCopyWithValue,
    Object? network = unsetCopyWithValue,
    Object? sources = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? mode = unsetCopyWithValue,
    Object? customConfig = unsetCopyWithValue,
    Object? environmentKey = unsetCopyWithValue,
  }) {
    return Environment(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      created: created == unsetCopyWithValue
          ? this.created
          : created as DateTime?,
      updated: updated == unsetCopyWithValue
          ? this.updated
          : updated as DateTime?,
      lastAccessed: lastAccessed == unsetCopyWithValue
          ? this.lastAccessed
          : lastAccessed as DateTime?,
      fileCount: fileCount == unsetCopyWithValue
          ? this.fileCount
          : fileCount as String?,
      sizeBytes: sizeBytes == unsetCopyWithValue
          ? this.sizeBytes
          : sizeBytes as String?,
      network: network == unsetCopyWithValue
          ? this.network
          : network as EnvironmentNetworkEgressAllowlist?,
      sources: sources == unsetCopyWithValue
          ? this.sources
          : sources as List<Source>?,
      status: status == unsetCopyWithValue
          ? this.status
          : status as EnvironmentStatus?,
      mode: mode == unsetCopyWithValue ? this.mode : mode as EnvironmentMode?,
      unrecognizedMode: mode == unsetCopyWithValue ? unrecognizedMode : null,
      customConfig: customConfig == unsetCopyWithValue
          ? this.customConfig
          : customConfig as Map<String, dynamic>?,
      environmentKey: environmentKey == unsetCopyWithValue
          ? this.environmentKey
          : environmentKey as String?,
    );
  }
}
