part of 'vault_models.dart';

/// Variants: [VaultLimitedNetworking], [VaultUnrestrictedNetworking].
/// Destination permissions for an environment-variable credential. These do not grant network access to the environment.
///
/// Variants: [VaultLimitedNetworking], [VaultUnrestrictedNetworking] and [UnknownVaultCredentialNetworking].
sealed class VaultCredentialNetworking extends AgentJsonModel {
  const VaultCredentialNetworking();

  /// Parses known variants strictly and retains future received variants.
  factory VaultCredentialNetworking.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(
        json['type'],
        'VaultCredentialNetworking.type',
      )) {
        'limited' => VaultLimitedNetworking.fromJson(json),
        'unrestricted' => VaultUnrestrictedNetworking.fromJson(json),
        _ => UnknownVaultCredentialNetworking.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `limited` variant.
  factory VaultCredentialNetworking.limited({
    required List<String> allowedHosts,
  }) = VaultLimitedNetworking;

  /// Creates the `unrestricted` variant.
  factory VaultCredentialNetworking.unrestricted() =
      VaultUnrestrictedNetworking;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownVaultCredentialNetworking extends VaultCredentialNetworking {
  const UnknownVaultCredentialNetworking._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownVaultCredentialNetworking.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownVaultCredentialNetworking.type',
    );
    if (const ['limited', 'unrestricted'].contains(type)) {
      throw const FormatException(
        'UnknownVaultCredentialNetworking: expected a future type',
      );
    }
    return UnknownVaultCredentialNetworking._(
      snapshotAgentJson(json, 'UnknownVaultCredentialNetworking'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownVaultCredentialNetworking copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownVaultCredentialNetworking.fromJson(rawJson ?? this.rawJson);

  @override
  void validate() => throw const FormatException(
    'UnknownVaultCredentialNetworking: future credential configuration is not writable',
  );
}

/// Allows substitution only for the listed hosts. The environment network policy must also allow these hosts.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class VaultLimitedNetworking extends VaultCredentialNetworking {
  /// Creates a validated [VaultLimitedNetworking].
  VaultLimitedNetworking({required List<String> allowedHosts})
    : allowedHosts = List.unmodifiable(allowedHosts) {
    validate();
  }

  /// The 1 to 16 distinct allowed hostnames or IPv4 addresses, normalized to lowercase. Entries contain no scheme, path, port, or wildcard. IPv6 addresses are not supported.
  final List<String> allowedHosts;

  /// The type of the object. Always `limited`.
  @override
  String get type => 'limited';

  /// Parses [VaultLimitedNetworking] with contextual, payload-free errors.
  factory VaultLimitedNetworking.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'allowed_hosts',
      'type',
    ], 'VaultLimitedNetworking');
    requireAgentTag(json, 'type', 'limited', 'VaultLimitedNetworking');
    return VaultLimitedNetworking(
      allowedHosts: requiredAgentValue(
        json,
        'allowed_hosts',
        'VaultLimitedNetworking.allowedHosts',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    _validateVaultHosts(allowedHosts, 'VaultLimitedNetworking.allowedHosts');
    validateAgentCount(
      allowedHosts.length,
      'VaultLimitedNetworking.allowedHosts',
      min: 1,
      max: 16,
    );
    for (final item in allowedHosts) {
      validateAgentLength(
        item,
        'VaultLimitedNetworking.allowedHosts',
        min: 0,
        max: 1048576,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'allowed_hosts': allowedHosts.map((value) => value).toList(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  VaultLimitedNetworking copyWith({List<String>? allowedHosts}) =>
      VaultLimitedNetworking(allowedHosts: allowedHosts ?? this.allowedHosts);
}

/// Allows substitution for destinations permitted by the environment network policy. Requires `environment.network.access` to be `restricted`, with explicit `allowed_domains`.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class VaultUnrestrictedNetworking extends VaultCredentialNetworking {
  /// Creates a validated [VaultUnrestrictedNetworking].
  VaultUnrestrictedNetworking() {
    validate();
  }

  /// The type of the object. Always `unrestricted`.
  @override
  String get type => 'unrestricted';

  /// Parses [VaultUnrestrictedNetworking] with contextual, payload-free errors.
  factory VaultUnrestrictedNetworking.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const ['type'], 'VaultUnrestrictedNetworking');
    requireAgentTag(
      json,
      'type',
      'unrestricted',
      'VaultUnrestrictedNetworking',
    );
    return VaultUnrestrictedNetworking();
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  VaultUnrestrictedNetworking copyWith() => VaultUnrestrictedNetworking();
}

/// Variants: [VaultLimitedNetworkingResource], [VaultUnrestrictedNetworkingResource].
/// Destination permissions for an environment-variable credential. These do not grant network access to the environment.
///
/// Variants: [VaultLimitedNetworkingResource], [VaultUnrestrictedNetworkingResource] and [UnknownVaultCredentialNetworkingResource].
sealed class VaultCredentialNetworkingResource extends AgentJsonModel {
  const VaultCredentialNetworkingResource();

  /// Parses known variants strictly and retains future received variants.
  factory VaultCredentialNetworkingResource.fromJson(
    Map<String, dynamic> json,
  ) => switch (requireAgentString(
    json['type'],
    'VaultCredentialNetworkingResource.type',
  )) {
    'limited' => VaultLimitedNetworkingResource.fromJson(json),
    'unrestricted' => VaultUnrestrictedNetworkingResource.fromJson(json),
    _ => UnknownVaultCredentialNetworkingResource.fromJson(json),
  };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `limited` variant.
  factory VaultCredentialNetworkingResource.limited({
    required List<String> allowedHosts,
    Map<String, dynamic> rawJson,
  }) = VaultLimitedNetworkingResource;

  /// Creates the `unrestricted` variant.
  factory VaultCredentialNetworkingResource.unrestricted({
    Map<String, dynamic> rawJson,
  }) = VaultUnrestrictedNetworkingResource;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownVaultCredentialNetworkingResource
    extends VaultCredentialNetworkingResource {
  const UnknownVaultCredentialNetworkingResource._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownVaultCredentialNetworkingResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = requireAgentString(
      json['type'],
      'UnknownVaultCredentialNetworkingResource.type',
    );
    if (const ['limited', 'unrestricted'].contains(type)) {
      throw const FormatException(
        'UnknownVaultCredentialNetworkingResource: expected a future type',
      );
    }
    return UnknownVaultCredentialNetworkingResource._(
      snapshotAgentJson(json, 'UnknownVaultCredentialNetworkingResource'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownVaultCredentialNetworkingResource copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownVaultCredentialNetworkingResource.fromJson(
    rawJson ?? this.rawJson,
  );
}

/// Allows substitution only for the listed hosts. The environment network policy must also allow these hosts.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class VaultLimitedNetworkingResource
    extends VaultCredentialNetworkingResource {
  /// Creates a validated [VaultLimitedNetworkingResource].
  VaultLimitedNetworkingResource({
    required List<String> allowedHosts,
    Map<String, dynamic> rawJson = const {},
  }) : allowedHosts = List.unmodifiable(allowedHosts),
       rawJson = agentExtras(rawJson, const [
         'allowed_hosts',
         'type',
       ], 'VaultLimitedNetworkingResource') {
    validate();
  }

  /// The 1 to 16 distinct allowed hostnames or IPv4 addresses, normalized to lowercase. Entries contain no scheme, path, port, or wildcard. IPv6 addresses are not supported.
  final List<String> allowedHosts;

  /// The type of the object. Always `limited`.
  @override
  String get type => 'limited';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [VaultLimitedNetworkingResource] with contextual, payload-free errors.
  factory VaultLimitedNetworkingResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'limited', 'VaultLimitedNetworkingResource');
    return VaultLimitedNetworkingResource(
      allowedHosts: requiredAgentValue(
        json,
        'allowed_hosts',
        'VaultLimitedNetworkingResource.allowedHosts',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['allowed_hosts', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    _validateVaultHosts(
      allowedHosts,
      'VaultLimitedNetworkingResource.allowedHosts',
    );
    validateAgentCount(
      allowedHosts.length,
      'VaultLimitedNetworkingResource.allowedHosts',
      min: 1,
      max: 16,
    );
    for (final item in allowedHosts) {
      validateAgentLength(
        item,
        'VaultLimitedNetworkingResource.allowedHosts',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'allowed_hosts': allowedHosts.map((value) => value).toList(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  VaultLimitedNetworkingResource copyWith({
    List<String>? allowedHosts,
    Map<String, dynamic>? rawJson,
  }) => VaultLimitedNetworkingResource(
    allowedHosts: allowedHosts ?? this.allowedHosts,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Allows substitution for destinations permitted by the environment network policy. Requires `environment.network.access` to be `restricted`, with explicit `allowed_domains`.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class VaultUnrestrictedNetworkingResource
    extends VaultCredentialNetworkingResource {
  /// Creates a validated [VaultUnrestrictedNetworkingResource].
  VaultUnrestrictedNetworkingResource({Map<String, dynamic> rawJson = const {}})
    : rawJson = agentExtras(rawJson, const [
        'type',
      ], 'VaultUnrestrictedNetworkingResource') {
    validate();
  }

  /// The type of the object. Always `unrestricted`.
  @override
  String get type => 'unrestricted';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [VaultUnrestrictedNetworkingResource] with contextual, payload-free errors.
  factory VaultUnrestrictedNetworkingResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'unrestricted',
      'VaultUnrestrictedNetworkingResource',
    );
    return VaultUnrestrictedNetworkingResource(
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type'].contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  VaultUnrestrictedNetworkingResource copyWith({
    Map<String, dynamic>? rawJson,
  }) => VaultUnrestrictedNetworkingResource(rawJson: rawJson ?? this.rawJson);
}
