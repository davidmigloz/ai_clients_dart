part of 'environments.dart';

/// Request for `CreateEnvironment`.
class CreateEnvironmentRequest {
  /// Network configuration for the environment.
  final EnvironmentNetworkEgressAllowlist? network;

  /// Sources to be mounted into the environment.
  final List<Source>? sources;

  /// Variables to configure in a Google-hosted sandbox.
  final EnvironmentVariables? env;

  /// The compute lifecycle mode. The service chooses its default when omitted.
  final EnvironmentMode? mode;

  /// JSON configuration passed to the self-hosted environment poller.
  final Map<String, dynamic>? customConfig;

  /// The source environment to fork, either an ID or `environments/{id}`.
  ///
  /// Leave [sources] and [env] empty when copying an environment.
  final String? fromEnvironment;

  /// Instructions for interactions running in this self-hosted environment.
  final String? systemInstruction;

  /// Creates a [CreateEnvironmentRequest].
  const CreateEnvironmentRequest({
    this.network,
    this.sources,
    this.env,
    this.mode,
    this.customConfig,
    this.fromEnvironment,
    this.systemInstruction,
  });

  /// Creates a [CreateEnvironmentRequest] from JSON.
  factory CreateEnvironmentRequest.fromJson(Map<String, dynamic> json) =>
      CreateEnvironmentRequest(
        network: json['network'] != null
            ? EnvironmentNetworkEgressAllowlist.fromJson(
                json['network'] as Object,
              )
            : null,
        sources: (json['sources'] as List<dynamic>?)
            ?.map((e) => Source.fromJson(e as Map<String, dynamic>))
            .toList(),
        env: json['env'] == null
            ? null
            : EnvironmentVariables.fromJson(json['env'] as Object),
        mode: EnvironmentMode.fromString(json['mode'] as String?),
        customConfig: json['custom_config'] as Map<String, dynamic>?,
        fromEnvironment: json['from_environment'] as String?,
        systemInstruction: json['system_instruction'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (network != null) 'network': network!.toJson(),
    if (sources != null) 'sources': sources!.map((e) => e.toJson()).toList(),
    'env': ?env?.toJson(),
    'mode': ?mode?.value,
    'custom_config': ?customConfig,
    'from_environment': ?fromEnvironment,
    'system_instruction': ?systemInstruction,
  };

  /// Creates a copy with replaced values.
  CreateEnvironmentRequest copyWith({
    Object? network = unsetCopyWithValue,
    Object? sources = unsetCopyWithValue,
    Object? env = unsetCopyWithValue,
    Object? mode = unsetCopyWithValue,
    Object? customConfig = unsetCopyWithValue,
    Object? fromEnvironment = unsetCopyWithValue,
    Object? systemInstruction = unsetCopyWithValue,
  }) {
    return CreateEnvironmentRequest(
      network: network == unsetCopyWithValue
          ? this.network
          : network as EnvironmentNetworkEgressAllowlist?,
      sources: sources == unsetCopyWithValue
          ? this.sources
          : sources as List<Source>?,
      env: env == unsetCopyWithValue ? this.env : env as EnvironmentVariables?,
      mode: mode == unsetCopyWithValue ? this.mode : mode as EnvironmentMode?,
      customConfig: customConfig == unsetCopyWithValue
          ? this.customConfig
          : customConfig as Map<String, dynamic>?,
      fromEnvironment: fromEnvironment == unsetCopyWithValue
          ? this.fromEnvironment
          : fromEnvironment as String?,
      systemInstruction: systemInstruction == unsetCopyWithValue
          ? this.systemInstruction
          : systemInstruction as String?,
    );
  }
}
