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

  /// Creates an [EnvironmentConfig].
  const EnvironmentConfig({this.network, this.sources});

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
    return EnvironmentConfig(
      network: json['network'] != null
          ? EnvironmentNetworkEgressAllowlist.fromJson(
              json['network'] as Object,
            )
          : null,
      sources: (json['sources'] as List<dynamic>?)
          ?.map((e) => Source.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (network != null) 'network': network!.toJson(),
    if (sources != null) 'sources': sources!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  EnvironmentConfig copyWith({
    Object? network = unsetCopyWithValue,
    Object? sources = unsetCopyWithValue,
  }) {
    return EnvironmentConfig(
      network: network == unsetCopyWithValue
          ? this.network
          : network as EnvironmentNetworkEgressAllowlist?,
      sources: sources == unsetCopyWithValue
          ? this.sources
          : sources as List<Source>?,
    );
  }
}
