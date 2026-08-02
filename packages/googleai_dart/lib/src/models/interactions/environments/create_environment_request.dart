part of 'environments.dart';

/// Request for `CreateEnvironment`.
class CreateEnvironmentRequest {
  /// Network configuration for the environment.
  final EnvironmentNetworkEgressAllowlist? network;

  /// Sources to be mounted into the environment.
  final List<Source>? sources;

  /// Creates a [CreateEnvironmentRequest].
  const CreateEnvironmentRequest({this.network, this.sources});

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
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (network != null) 'network': network!.toJson(),
    if (sources != null) 'sources': sources!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  CreateEnvironmentRequest copyWith({
    Object? network = unsetCopyWithValue,
    Object? sources = unsetCopyWithValue,
  }) {
    return CreateEnvironmentRequest(
      network: network == unsetCopyWithValue
          ? this.network
          : network as EnvironmentNetworkEgressAllowlist?,
      sources: sources == unsetCopyWithValue
          ? this.sources
          : sources as List<Source>?,
    );
  }
}
