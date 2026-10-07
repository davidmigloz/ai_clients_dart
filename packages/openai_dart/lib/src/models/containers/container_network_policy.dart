import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'container_json_helpers.dart';

/// Requested outbound network access for a container.
///
/// Use [disabled] to disable access or [allowlist] to specify allowed domains.
sealed class ContainerNetworkPolicy {
  /// Creates a [ContainerNetworkPolicy].
  const ContainerNetworkPolicy();

  /// Creates a policy from JSON, preserving future object variants.
  factory ContainerNetworkPolicy.fromJson(Object? json) {
    final map = requireContainerMap(json, 'ContainerNetworkPolicy');
    final type = requireContainerString(
      map['type'],
      'ContainerNetworkPolicy.type',
    );
    return switch (type) {
      'disabled' => ContainerNetworkPolicyDisabled.fromJson(map),
      'allowlist' => ContainerNetworkPolicyAllowlist.fromJson(map),
      _ => UnknownContainerNetworkPolicy(map),
    };
  }

  /// Disables outbound network access.
  static const disabled = ContainerNetworkPolicyDisabled();

  /// Allows access to [allowedDomains] with optional domain-scoped secrets.
  static ContainerNetworkPolicyAllowlist allowlist(
    List<String> allowedDomains, {
    List<ContainerNetworkPolicyDomainSecret>? domainSecrets,
  }) => ContainerNetworkPolicyAllowlist(
    allowedDomains: allowedDomains,
    domainSecrets: domainSecrets,
  );

  /// The policy's API discriminator.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Disables outbound network access for a container.
@immutable
class ContainerNetworkPolicyDisabled extends ContainerNetworkPolicy {
  /// Creates a [ContainerNetworkPolicyDisabled].
  const ContainerNetworkPolicyDisabled();

  /// Creates a disabled policy from JSON.
  factory ContainerNetworkPolicyDisabled.fromJson(Map<String, dynamic> json) {
    requireContainerType(json, 'disabled', 'ContainerNetworkPolicyDisabled');
    return const ContainerNetworkPolicyDisabled();
  }

  @override
  String get type => 'disabled';

  @override
  Map<String, dynamic> toJson() => const {'type': 'disabled'};

  /// Creates a copy of this policy.
  ContainerNetworkPolicyDisabled copyWith() =>
      const ContainerNetworkPolicyDisabled();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerNetworkPolicyDisabled &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ContainerNetworkPolicyDisabled()';
}

/// Allows outbound access only to specified domains.
@immutable
class ContainerNetworkPolicyAllowlist extends ContainerNetworkPolicy {
  /// Creates an allowlist, snapshotting its ordered domains and secrets.
  ContainerNetworkPolicyAllowlist({
    required List<String> allowedDomains,
    List<ContainerNetworkPolicyDomainSecret>? domainSecrets,
  }) : allowedDomains = List.unmodifiable(allowedDomains),
       domainSecrets = domainSecrets == null
           ? null
           : List.unmodifiable(domainSecrets);

  /// Creates an allowlist from JSON.
  factory ContainerNetworkPolicyAllowlist.fromJson(Map<String, dynamic> json) {
    requireContainerType(json, 'allowlist', 'ContainerNetworkPolicyAllowlist');
    return ContainerNetworkPolicyAllowlist(
      allowedDomains: requireContainerStrings(
        json['allowed_domains'],
        'ContainerNetworkPolicyAllowlist.allowed_domains',
      ),
      domainSecrets: json.containsKey('domain_secrets')
          ? parseContainerObjects(
              json['domain_secrets'],
              ContainerNetworkPolicyDomainSecret.fromJson,
              'ContainerNetworkPolicyAllowlist.domain_secrets',
            )
          : null,
    );
  }

  /// The ordered allowed domains. The server requires at least one domain.
  final List<String> allowedDomains;

  /// Optional domain-scoped secrets. The server requires a nonempty list.
  final List<ContainerNetworkPolicyDomainSecret>? domainSecrets;

  @override
  String get type => 'allowlist';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'allowed_domains': allowedDomains,
    if (domainSecrets != null)
      'domain_secrets': domainSecrets!
          .map((secret) => secret.toJson())
          .toList(),
  };

  /// Creates a copy; pass `domainSecrets: null` to clear secrets.
  ContainerNetworkPolicyAllowlist copyWith({
    List<String>? allowedDomains,
    Object? domainSecrets = unsetCopyWithValue,
  }) => ContainerNetworkPolicyAllowlist(
    allowedDomains: allowedDomains ?? this.allowedDomains,
    domainSecrets: domainSecrets == unsetCopyWithValue
        ? this.domainSecrets
        : domainSecrets == null
        ? null
        : List<ContainerNetworkPolicyDomainSecret>.from(domainSecrets as List),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerNetworkPolicyAllowlist &&
          runtimeType == other.runtimeType &&
          listsEqual(allowedDomains, other.allowedDomains) &&
          listsEqual(domainSecrets, other.domainSecrets);

  @override
  int get hashCode => Object.hash(
    runtimeType,
    listHash(allowedDomains),
    listHash(domainSecrets),
  );

  @override
  String toString() =>
      'ContainerNetworkPolicyAllowlist(allowedDomains: $allowedDomains, '
      'domainSecrets: ${domainSecrets == null ? null : '${domainSecrets!.length} items'})';
}

/// A secret injected for an allowlisted domain.
@immutable
class ContainerNetworkPolicyDomainSecret {
  /// Creates a domain-scoped secret.
  const ContainerNetworkPolicyDomainSecret({
    required this.domain,
    required this.name,
    required this.value,
  });

  /// Creates a domain-scoped secret from JSON.
  factory ContainerNetworkPolicyDomainSecret.fromJson(
    Map<String, dynamic> json,
  ) => ContainerNetworkPolicyDomainSecret(
    domain: requireContainerString(
      json['domain'],
      'ContainerNetworkPolicyDomainSecret.domain',
    ),
    name: requireContainerString(
      json['name'],
      'ContainerNetworkPolicyDomainSecret.name',
    ),
    value: requireContainerString(
      json['value'],
      'ContainerNetworkPolicyDomainSecret.value',
    ),
  );

  /// The associated domain. The server requires a nonempty string.
  final String domain;

  /// The secret name. The server requires a nonempty string.
  final String name;

  /// The secret value, excluded from string diagnostics.
  ///
  /// The server requires 1–10,485,760 characters.
  final String value;

  /// Converts to JSON, including the value required by the API.
  Map<String, dynamic> toJson() => {
    'domain': domain,
    'name': name,
    'value': value,
  };

  /// Creates a copy with replaced values.
  ContainerNetworkPolicyDomainSecret copyWith({
    String? domain,
    String? name,
    String? value,
  }) => ContainerNetworkPolicyDomainSecret(
    domain: domain ?? this.domain,
    name: name ?? this.name,
    value: value ?? this.value,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerNetworkPolicyDomainSecret &&
          runtimeType == other.runtimeType &&
          domain == other.domain &&
          name == other.name &&
          value == other.value;

  @override
  int get hashCode => Object.hash(domain, name, value);

  @override
  String toString() =>
      'ContainerNetworkPolicyDomainSecret(domain: $domain, name: $name, '
      'value: [REDACTED])';
}

/// A future request policy retaining its complete immutable JSON payload.
@immutable
class UnknownContainerNetworkPolicy extends ContainerNetworkPolicy {
  /// Creates an unknown policy with a defensive JSON snapshot.
  UnknownContainerNetworkPolicy(Map<String, dynamic> rawJson)
    : type = requireContainerString(
        rawJson['type'],
        'UnknownContainerNetworkPolicy.type',
      ),
      rawJson = freezeContainerJsonMap(rawJson);

  /// Creates an unknown policy from JSON.
  factory UnknownContainerNetworkPolicy.fromJson(Map<String, dynamic> json) =>
      UnknownContainerNetworkPolicy(json);

  @override
  final String type;

  /// The recursively unmodifiable original JSON.
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(rawJson);

  /// Creates a copy with a replaced raw payload.
  UnknownContainerNetworkPolicy copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownContainerNetworkPolicy(rawJson ?? this.rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownContainerNetworkPolicy &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(rawJson));

  @override
  String toString() => 'UnknownContainerNetworkPolicy(type: $type)';
}

/// Network settings returned by the API, without domain-scoped secrets.
///
/// Unlike a requested allowlist, returned [allowedDomains] may be omitted.
@immutable
class ContainerNetworkPolicyInfo {
  /// Creates returned network settings, snapshotting optional domains.
  ContainerNetworkPolicyInfo({required this.type, List<String>? allowedDomains})
    : allowedDomains = allowedDomains == null
          ? null
          : List.unmodifiable(allowedDomains);

  /// Creates returned network settings from JSON.
  factory ContainerNetworkPolicyInfo.fromJson(Map<String, dynamic> json) =>
      ContainerNetworkPolicyInfo(
        type: requireContainerString(
          json['type'],
          'ContainerNetworkPolicyInfo.type',
        ),
        allowedDomains: optionalContainerStrings(
          json,
          'allowed_domains',
          'ContainerNetworkPolicyInfo',
        ),
      );

  /// The exact returned mode, currently `allowlist` or `disabled`.
  final String type;

  /// Optional ordered domains allowed by an allowlist policy.
  final List<String>? allowedDomains;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (allowedDomains != null) 'allowed_domains': allowedDomains,
  };

  /// Creates a copy; pass `allowedDomains: null` to clear domains.
  ContainerNetworkPolicyInfo copyWith({
    String? type,
    Object? allowedDomains = unsetCopyWithValue,
  }) => ContainerNetworkPolicyInfo(
    type: type ?? this.type,
    allowedDomains: allowedDomains == unsetCopyWithValue
        ? this.allowedDomains
        : allowedDomains == null
        ? null
        : List<String>.from(allowedDomains as List),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerNetworkPolicyInfo &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          listsEqual(allowedDomains, other.allowedDomains);

  @override
  int get hashCode => Object.hash(type, listHash(allowedDomains));

  @override
  String toString() =>
      'ContainerNetworkPolicyInfo(type: $type, allowedDomains: $allowedDomains)';
}
