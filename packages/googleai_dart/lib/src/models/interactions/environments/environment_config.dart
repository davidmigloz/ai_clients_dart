part of 'environments.dart';

/// Configuration for a remote environment (sandbox) for an interaction or agent.
class EnvironmentConfig {
  /// The environment type. Currently always `"remote"`.
  final String type;

  /// Network configuration for the environment.
  ///
  /// An [EnvironmentNetworkAllowlist] to restrict egress, or
  /// [EnvironmentNetworkDisabled] to block all network access. Omit to allow
  /// all outbound traffic.
  final EnvironmentNetworkEgressAllowlist? network;

  /// Sources mounted into the environment's sandbox.
  final List<Source>? sources;

  /// Creates an [EnvironmentConfig].
  const EnvironmentConfig({this.type = 'remote', this.network, this.sources});

  /// Creates an [EnvironmentConfig] from JSON.
  factory EnvironmentConfig.fromJson(Map<String, dynamic> json) =>
      EnvironmentConfig(
        type: json['type'] as String? ?? 'remote',
        network: json['network'] != null
            ? EnvironmentNetworkEgressAllowlist.fromJson(
                json['network'] as Object,
              )
            : null,
        sources: (json['sources'] as List<dynamic>?)
            ?.map((e) => Source.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (network != null) 'network': network!.toJson(),
    if (sources != null) 'sources': sources!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  EnvironmentConfig copyWith({
    Object? type = unsetCopyWithValue,
    Object? network = unsetCopyWithValue,
    Object? sources = unsetCopyWithValue,
  }) {
    return EnvironmentConfig(
      type: type == unsetCopyWithValue ? this.type : type! as String,
      network: network == unsetCopyWithValue
          ? this.network
          : network as EnvironmentNetworkEgressAllowlist?,
      sources: sources == unsetCopyWithValue
          ? this.sources
          : sources as List<Source>?,
    );
  }
}
