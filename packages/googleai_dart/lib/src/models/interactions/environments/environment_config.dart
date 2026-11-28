part of 'environments.dart';

/// Configuration for a remote environment (sandbox) for an interaction or agent.
class EnvironmentConfig {
  /// The environment type.
  ///
  /// Per the spec this is the constant `"remote"`; it is not configurable.
  String get type => 'remote';

  /// Network configuration for the environment.
  ///
  /// An [EnvironmentNetworkAllowlist] to restrict egress, or
  /// [EnvironmentNetworkDisabled] to block all network access. Omit to allow
  /// all outbound traffic.
  final EnvironmentNetworkEgressAllowlist? network;

  /// Sources mounted into the environment's sandbox.
  final List<Source>? sources;

  /// Optional. The environment ID for the interaction. If specified, the
  /// request will update the existing environment instead of creating a new
  /// one. Leave [sources] and [env] unset when updating an existing environment.
  final String? environmentId;

  /// Variables to configure in a new Google-hosted sandbox.
  final EnvironmentVariables? env;

  /// The compute lifecycle mode, when specified.
  final EnvironmentMode? mode;

  /// The original wire string when [mode] is unrecognized.
  final String? unrecognizedMode;

  /// JSON configuration for a self-hosted environment.
  final Map<String, dynamic>? customConfig;

  /// Creates an [EnvironmentConfig].
  const EnvironmentConfig({
    this.network,
    this.sources,
    this.environmentId,
    this.env,
    this.mode,
    this.unrecognizedMode,
    this.customConfig,
  });

  /// Creates an [EnvironmentConfig] from JSON.
  ///
  /// Throws a [FormatException] if a `type` other than the constant `"remote"`
  /// is present.
  factory EnvironmentConfig.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != null && type != 'remote') {
      throw FormatException(
        'Expected EnvironmentConfig type "remote" but got "$type"',
      );
    }
    final wireMode = json['mode'] as String?;
    final mode = EnvironmentMode.fromString(wireMode);
    return EnvironmentConfig(
      network: json['network'] != null
          ? EnvironmentNetworkEgressAllowlist.fromJson(
              json['network'] as Object,
            )
          : null,
      sources: (json['sources'] as List<dynamic>?)
          ?.map((e) => Source.fromJson(e as Map<String, dynamic>))
          .toList(),
      environmentId: json['environment_id'] as String?,
      env: json['env'] == null
          ? null
          : EnvironmentVariables.fromJson(json['env'] as Object),
      mode: mode,
      unrecognizedMode: mode == null ? wireMode : null,
      customConfig: json['custom_config'] as Map<String, dynamic>?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (network != null) 'network': network!.toJson(),
    if (sources != null) 'sources': sources!.map((e) => e.toJson()).toList(),
    if (environmentId != null) 'environment_id': environmentId,
    'env': ?env?.toJson(),
    'mode': ?(mode?.value ?? unrecognizedMode),
    'custom_config': ?customConfig,
  };

  /// Creates a copy with replaced values.
  EnvironmentConfig copyWith({
    Object? network = unsetCopyWithValue,
    Object? sources = unsetCopyWithValue,
    Object? environmentId = unsetCopyWithValue,
    Object? env = unsetCopyWithValue,
    Object? mode = unsetCopyWithValue,
    Object? customConfig = unsetCopyWithValue,
  }) {
    return EnvironmentConfig(
      network: network == unsetCopyWithValue
          ? this.network
          : network as EnvironmentNetworkEgressAllowlist?,
      sources: sources == unsetCopyWithValue
          ? this.sources
          : sources as List<Source>?,
      environmentId: environmentId == unsetCopyWithValue
          ? this.environmentId
          : environmentId as String?,
      env: env == unsetCopyWithValue ? this.env : env as EnvironmentVariables?,
      mode: mode == unsetCopyWithValue ? this.mode : mode as EnvironmentMode?,
      unrecognizedMode: mode == unsetCopyWithValue ? unrecognizedMode : null,
      customConfig: customConfig == unsetCopyWithValue
          ? this.customConfig
          : customConfig as Map<String, dynamic>?,
    );
  }
}
