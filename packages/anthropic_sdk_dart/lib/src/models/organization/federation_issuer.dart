import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// How Anthropic obtains public signing keys for a federation issuer.
///
/// Supports [FederationJwksDiscovery], [FederationJwksExplicitUrl],
/// [FederationJwksInline], and [UnknownFederationJwksSource].
@immutable
sealed class FederationJwksSource {
  const FederationJwksSource._();

  /// Discovers the key endpoint through the issuer's OIDC configuration.
  const factory FederationJwksSource.discovery({
    String? caCertPem,
    String? discoveryBase,
  }) = FederationJwksDiscovery;

  /// Fetches signing keys from a specified endpoint.
  const factory FederationJwksSource.explicitUrl({
    required String url,
    String? caCertPem,
  }) = FederationJwksExplicitUrl;

  /// Uses a fixed set of public JSON Web Keys.
  factory FederationJwksSource.inline({
    required List<Map<String, dynamic>> keys,
  }) = FederationJwksInline;

  /// Reads a signing-key source, preserving an unknown variant.
  factory FederationJwksSource.fromJson(Map<String, dynamic> json) =>
      switch (_required<String>(json, 'type')) {
        'discovery' => FederationJwksDiscovery.fromJson(json),
        'explicit_url' => FederationJwksExplicitUrl.fromJson(json),
        'inline' => FederationJwksInline.fromJson(json),
        _ => UnknownFederationJwksSource(json),
      };

  /// The wire discriminator.
  String get type;

  /// Encodes this signing-key source for the Admin API.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) =>
      other is FederationJwksSource &&
      other.runtimeType == runtimeType &&
      mapsDeepEqual(other.toJson(), toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() => 'FederationJwksSource(type: $type)';
}

/// Uses the issuer's OIDC discovery document.
final class FederationJwksDiscovery extends FederationJwksSource {
  /// Configures OIDC discovery.
  const FederationJwksDiscovery({this.caCertPem, this.discoveryBase})
    : super._();

  /// Custom CA certificate used to verify the discovery endpoint's TLS.
  final String? caCertPem;

  /// Alternate base URL for the discovery document, if used.
  final String? discoveryBase;

  /// Decodes this signing-key source.
  factory FederationJwksDiscovery.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'discovery');
    return FederationJwksDiscovery(
      caCertPem: _optional<String>(json, 'ca_cert_pem'),
      discoveryBase: _optional<String>(json, 'discovery_base'),
    );
  }

  /// Copies this value with the supplied fields replaced.
  FederationJwksDiscovery copyWith({
    Object? caCertPem = unsetCopyWithValue,
    Object? discoveryBase = unsetCopyWithValue,
  }) => FederationJwksDiscovery(
    caCertPem: identical(caCertPem, unsetCopyWithValue)
        ? this.caCertPem
        : caCertPem as String?,
    discoveryBase: identical(discoveryBase, unsetCopyWithValue)
        ? this.discoveryBase
        : discoveryBase as String?,
  );

  @override
  String get type => 'discovery';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'ca_cert_pem': ?caCertPem,
    'discovery_base': ?discoveryBase,
  };
}

/// Reads JWKS from a fixed endpoint.
final class FederationJwksExplicitUrl extends FederationJwksSource {
  /// Configures an explicit JWKS endpoint.
  const FederationJwksExplicitUrl({required this.url, this.caCertPem})
    : super._();

  /// URL of the public key set.
  final String url;

  /// Custom CA certificate used to verify the endpoint's TLS.
  final String? caCertPem;

  /// Decodes this signing-key source.
  factory FederationJwksExplicitUrl.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'explicit_url');
    return FederationJwksExplicitUrl(
      url: _required<String>(json, 'url'),
      caCertPem: _optional<String>(json, 'ca_cert_pem'),
    );
  }

  /// Copies this value with the supplied fields replaced.
  FederationJwksExplicitUrl copyWith({
    String? url,
    Object? caCertPem = unsetCopyWithValue,
  }) => FederationJwksExplicitUrl(
    url: url ?? this.url,
    caCertPem: identical(caCertPem, unsetCopyWithValue)
        ? this.caCertPem
        : caCertPem as String?,
  );

  @override
  String get type => 'explicit_url';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'url': url,
    'ca_cert_pem': ?caCertPem,
  };
}

/// Uses inline public JSON Web Keys without an upstream fetch.
final class FederationJwksInline extends FederationJwksSource {
  /// Configures a nonempty collection of public JWK objects.
  FederationJwksInline({required List<Map<String, dynamic>> keys})
    : keys = List.unmodifiable(keys.map(deepUnmodifiableMap)),
      super._() {
    if (keys.isEmpty) throw ArgumentError('At least one public JWK is needed.');
  }

  /// Inline public keys, including algorithm-specific fields.
  final List<Map<String, dynamic>> keys;

  /// Decodes this signing-key source.
  factory FederationJwksInline.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'inline');
    return FederationJwksInline(keys: _inlineKeys(json));
  }

  /// Copies this value with the supplied fields replaced.
  FederationJwksInline copyWith({List<Map<String, dynamic>>? keys}) =>
      FederationJwksInline(keys: keys ?? this.keys);

  @override
  String get type => 'inline';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'keys': keys};
}

/// Preserves an unrecognized source returned by the API.
final class UnknownFederationJwksSource extends FederationJwksSource {
  /// Creates an unknown source from its raw object.
  UnknownFederationJwksSource(Map<String, dynamic> raw)
    : raw = deepUnmodifiableMap(raw),
      super._();

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  String get type => _required<String>(raw, 'type');

  @override
  Map<String, dynamic> toJson() => raw;
}

/// Automatic signing-key polling state for a federation issuer.
@immutable
final class FederationIssuerPollStatus {
  /// Creates a polling state.
  const FederationIssuerPollStatus({
    required this.consecutiveFailures,
    required this.lastFetchedAt,
    required this.nextPollAt,
  });

  /// Number of failed fetches since the last success.
  final int consecutiveFailures;

  /// Time of the last successful fetch.
  final DateTime? lastFetchedAt;

  /// Scheduled fetch time, or null when paused.
  final DateTime? nextPollAt;

  /// Reads the polling state from an Admin API response.
  factory FederationIssuerPollStatus.fromJson(Map<String, dynamic> json) =>
      FederationIssuerPollStatus(
        consecutiveFailures: _required<int>(json, 'consecutive_failures'),
        lastFetchedAt: _nullableTime(json, 'last_fetched_at'),
        nextPollAt: _nullableTime(json, 'next_poll_at'),
      );

  /// Encodes the polling state with explicit nullable timestamps.
  Map<String, dynamic> toJson() => {
    'consecutive_failures': consecutiveFailures,
    'last_fetched_at': _wireTime(lastFetchedAt),
    'next_poll_at': _wireTime(nextPollAt),
  };

  /// Copies this value with the supplied fields replaced.
  FederationIssuerPollStatus copyWith({
    int? consecutiveFailures,
    Object? lastFetchedAt = unsetCopyWithValue,
    Object? nextPollAt = unsetCopyWithValue,
  }) => FederationIssuerPollStatus(
    consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
    lastFetchedAt: identical(lastFetchedAt, unsetCopyWithValue)
        ? this.lastFetchedAt
        : lastFetchedAt as DateTime?,
    nextPollAt: identical(nextPollAt, unsetCopyWithValue)
        ? this.nextPollAt
        : nextPollAt as DateTime?,
  );

  @override
  bool operator ==(Object other) =>
      other is FederationIssuerPollStatus &&
      other.consecutiveFailures == consecutiveFailures &&
      other.lastFetchedAt == lastFetchedAt &&
      other.nextPollAt == nextPollAt;

  @override
  int get hashCode =>
      Object.hash(consecutiveFailures, lastFetchedAt, nextPollAt);

  @override
  String toString() =>
      'FederationIssuerPollStatus(consecutiveFailures: $consecutiveFailures, '
      'lastFetchedAt: $lastFetchedAt, nextPollAt: $nextPollAt)';
}

/// A registered OIDC identity provider.
@immutable
final class FederationIssuer {
  /// Creates a federation issuer response.
  const FederationIssuer({
    required this.id,
    required this.name,
    required this.issuerUrl,
    required this.jwks,
    required this.checkJti,
    required this.maxJwtLifetimeSeconds,
    required this.createdAt,
    required this.createdByActorId,
    required this.updatedAt,
    required this.updatedByActorId,
    required this.archivedAt,
    required this.archivedByActorId,
    required this.jwksPollingDisabledAt,
    required this.pollStatus,
  });

  /// Tagged issuer ID.
  final String id;

  /// Organization-unique issuer slug.
  final String name;

  /// Exact JWT issuer claim the service matches.
  final String issuerUrl;

  /// How the provider's signing keys are read.
  final FederationJwksSource jwks;

  /// Whether JWTs that carry a JTI claim are single-use.
  final bool checkJti;

  /// Maximum accepted JWT lifetime, in seconds.
  final int maxJwtLifetimeSeconds;

  /// When the issuer was created.
  final DateTime createdAt;

  /// Actor who created the issuer, when known.
  final String? createdByActorId;

  /// When the issuer was last updated.
  final DateTime updatedAt;

  /// Actor who last updated the issuer, when known.
  final String? updatedByActorId;

  /// When the issuer was archived, when applicable.
  final DateTime? archivedAt;

  /// Actor who archived the issuer, when known.
  final String? archivedByActorId;

  /// Time at which Anthropic paused automatic JWKS polling.
  final DateTime? jwksPollingDisabledAt;

  /// Current polling status, if available.
  final FederationIssuerPollStatus? pollStatus;

  /// The wire discriminator.
  String get type => 'federation_issuer';

  /// Reads issuer metadata from an Admin API response.
  factory FederationIssuer.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'federation_issuer');
    final pollStatus = _required<Map<String, dynamic>?>(json, 'poll_status');
    return FederationIssuer(
      id: _required<String>(json, 'id'),
      name: _required<String>(json, 'name'),
      issuerUrl: _required<String>(json, 'issuer_url'),
      jwks: FederationJwksSource.fromJson(
        _required<Map<String, dynamic>>(json, 'jwks'),
      ),
      checkJti: _required<bool>(json, 'check_jti'),
      maxJwtLifetimeSeconds: _required<int>(json, 'max_jwt_lifetime_seconds'),
      createdAt: DateTime.parse(_required<String>(json, 'created_at')),
      createdByActorId: _required<String?>(json, 'created_by_actor_id'),
      updatedAt: DateTime.parse(_required<String>(json, 'updated_at')),
      updatedByActorId: _required<String?>(json, 'updated_by_actor_id'),
      archivedAt: _nullableTime(json, 'archived_at'),
      archivedByActorId: _required<String?>(json, 'archived_by_actor_id'),
      jwksPollingDisabledAt: _nullableTime(json, 'jwks_polling_disabled_at'),
      pollStatus: pollStatus == null
          ? null
          : FederationIssuerPollStatus.fromJson(pollStatus),
    );
  }

  /// Converts this issuer to its wire representation.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'issuer_url': issuerUrl,
    'jwks': jwks.toJson(),
    'check_jti': checkJti,
    'max_jwt_lifetime_seconds': maxJwtLifetimeSeconds,
    'created_at': _wireTime(createdAt),
    'created_by_actor_id': createdByActorId,
    'updated_at': _wireTime(updatedAt),
    'updated_by_actor_id': updatedByActorId,
    'archived_at': _wireTime(archivedAt),
    'archived_by_actor_id': archivedByActorId,
    'jwks_polling_disabled_at': _wireTime(jwksPollingDisabledAt),
    'poll_status': pollStatus?.toJson(),
  };

  /// Copies this value with the supplied fields replaced.
  FederationIssuer copyWith({
    String? id,
    String? name,
    String? issuerUrl,
    FederationJwksSource? jwks,
    bool? checkJti,
    int? maxJwtLifetimeSeconds,
    DateTime? createdAt,
    Object? createdByActorId = unsetCopyWithValue,
    DateTime? updatedAt,
    Object? updatedByActorId = unsetCopyWithValue,
    Object? archivedAt = unsetCopyWithValue,
    Object? archivedByActorId = unsetCopyWithValue,
    Object? jwksPollingDisabledAt = unsetCopyWithValue,
    Object? pollStatus = unsetCopyWithValue,
  }) => FederationIssuer(
    id: id ?? this.id,
    name: name ?? this.name,
    issuerUrl: issuerUrl ?? this.issuerUrl,
    jwks: jwks ?? this.jwks,
    checkJti: checkJti ?? this.checkJti,
    maxJwtLifetimeSeconds: maxJwtLifetimeSeconds ?? this.maxJwtLifetimeSeconds,
    createdAt: createdAt ?? this.createdAt,
    createdByActorId: identical(createdByActorId, unsetCopyWithValue)
        ? this.createdByActorId
        : createdByActorId as String?,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedByActorId: identical(updatedByActorId, unsetCopyWithValue)
        ? this.updatedByActorId
        : updatedByActorId as String?,
    archivedAt: identical(archivedAt, unsetCopyWithValue)
        ? this.archivedAt
        : archivedAt as DateTime?,
    archivedByActorId: identical(archivedByActorId, unsetCopyWithValue)
        ? this.archivedByActorId
        : archivedByActorId as String?,
    jwksPollingDisabledAt: identical(jwksPollingDisabledAt, unsetCopyWithValue)
        ? this.jwksPollingDisabledAt
        : jwksPollingDisabledAt as DateTime?,
    pollStatus: identical(pollStatus, unsetCopyWithValue)
        ? this.pollStatus
        : pollStatus as FederationIssuerPollStatus?,
  );

  @override
  bool operator ==(Object other) =>
      other is FederationIssuer &&
      id == other.id &&
      name == other.name &&
      issuerUrl == other.issuerUrl &&
      jwks == other.jwks &&
      checkJti == other.checkJti &&
      maxJwtLifetimeSeconds == other.maxJwtLifetimeSeconds &&
      createdAt == other.createdAt &&
      createdByActorId == other.createdByActorId &&
      updatedAt == other.updatedAt &&
      updatedByActorId == other.updatedByActorId &&
      archivedAt == other.archivedAt &&
      archivedByActorId == other.archivedByActorId &&
      jwksPollingDisabledAt == other.jwksPollingDisabledAt &&
      pollStatus == other.pollStatus;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    issuerUrl,
    jwks,
    checkJti,
    maxJwtLifetimeSeconds,
    createdAt,
    createdByActorId,
    updatedAt,
    updatedByActorId,
    archivedAt,
    archivedByActorId,
    jwksPollingDisabledAt,
    pollStatus,
  );

  @override
  String toString() =>
      'FederationIssuer(id: $id, name: $name, issuerUrl: [${issuerUrl.length} chars], '
      'jwks: $jwks, checkJti: $checkJti, maxJwtLifetimeSeconds: $maxJwtLifetimeSeconds, '
      'createdAt: $createdAt, createdByActorId: $createdByActorId, updatedAt: $updatedAt, '
      'updatedByActorId: $updatedByActorId, archivedAt: $archivedAt, '
      'archivedByActorId: $archivedByActorId, '
      'jwksPollingDisabledAt: $jwksPollingDisabledAt, pollStatus: $pollStatus)';
}

/// Creates an OIDC federation issuer.
@immutable
final class FederationIssuerCreateParams {
  /// Creates issuer parameters. If omitted, [jwks] defaults to discovery.
  const FederationIssuerCreateParams({
    required this.issuerUrl,
    required this.name,
    this.jwks,
    this.checkJti,
    this.maxJwtLifetimeSeconds,
  });

  /// Exact JWT issuer claim to match.
  final String issuerUrl;

  /// Organization-unique issuer slug.
  final String name;

  /// How the provider's signing keys are read.
  final FederationJwksSource? jwks;

  /// Whether JWTs that carry a JTI claim are single-use.
  final bool? checkJti;

  /// Maximum accepted JWT lifetime, in seconds.
  final int? maxJwtLifetimeSeconds;

  /// Reads the issuer creation request.
  factory FederationIssuerCreateParams.fromJson(Map<String, dynamic> json) =>
      FederationIssuerCreateParams(
        issuerUrl: _required<String>(json, 'issuer_url'),
        name: _required<String>(json, 'name'),
        jwks: _optionalJwks(json),
        checkJti: _optional<bool>(json, 'check_jti'),
        maxJwtLifetimeSeconds: _optional<int>(json, 'max_jwt_lifetime_seconds'),
      );

  /// Encodes the issuer creation request.
  Map<String, dynamic> toJson() => {
    'issuer_url': issuerUrl,
    'name': name,
    'jwks': ?jwks?.toJson(),
    'check_jti': ?checkJti,
    'max_jwt_lifetime_seconds': ?maxJwtLifetimeSeconds,
  };

  /// Copies this value with the supplied fields replaced.
  FederationIssuerCreateParams copyWith({
    String? issuerUrl,
    String? name,
    Object? jwks = unsetCopyWithValue,
    Object? checkJti = unsetCopyWithValue,
    Object? maxJwtLifetimeSeconds = unsetCopyWithValue,
  }) => FederationIssuerCreateParams(
    issuerUrl: issuerUrl ?? this.issuerUrl,
    name: name ?? this.name,
    jwks: identical(jwks, unsetCopyWithValue)
        ? this.jwks
        : jwks as FederationJwksSource?,
    checkJti: identical(checkJti, unsetCopyWithValue)
        ? this.checkJti
        : checkJti as bool?,
    maxJwtLifetimeSeconds: identical(maxJwtLifetimeSeconds, unsetCopyWithValue)
        ? this.maxJwtLifetimeSeconds
        : maxJwtLifetimeSeconds as int?,
  );

  @override
  bool operator ==(Object other) =>
      other is FederationIssuerCreateParams &&
      issuerUrl == other.issuerUrl &&
      name == other.name &&
      jwks == other.jwks &&
      checkJti == other.checkJti &&
      maxJwtLifetimeSeconds == other.maxJwtLifetimeSeconds;

  @override
  int get hashCode =>
      Object.hash(issuerUrl, name, jwks, checkJti, maxJwtLifetimeSeconds);

  @override
  String toString() =>
      'FederationIssuerCreateParams(name: $name, issuerUrl: [${issuerUrl.length} chars], '
      'jwks: $jwks, checkJti: $checkJti, maxJwtLifetimeSeconds: $maxJwtLifetimeSeconds)';
}

/// Updates an issuer while preserving omitted and explicit-null fields.
@immutable
final class FederationIssuerUpdateParams {
  /// Creates an issuer patch.
  ///
  /// Pass a [String] for [issuerUrl] or [name], a [FederationJwksSource]
  /// for [jwks], a [bool] for [checkJti], and an [int] for
  /// [maxJwtLifetimeSeconds]. Only `false` re-enables JWKS polling through
  /// [jwksPollingDisabled]. Every parameter also accepts explicit null.
  FederationIssuerUpdateParams({
    Object? issuerUrl = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? jwks = unsetCopyWithValue,
    Object? checkJti = unsetCopyWithValue,
    Object? maxJwtLifetimeSeconds = unsetCopyWithValue,
    Object? jwksPollingDisabled = unsetCopyWithValue,
  }) : _json = deepUnmodifiableMap({
         if (!identical(issuerUrl, unsetCopyWithValue))
           'issuer_url': issuerUrl as String?,
         if (!identical(name, unsetCopyWithValue)) 'name': name as String?,
         if (!identical(jwks, unsetCopyWithValue))
           'jwks': (jwks as FederationJwksSource?)?.toJson(),
         if (!identical(checkJti, unsetCopyWithValue))
           'check_jti': checkJti as bool?,
         if (!identical(maxJwtLifetimeSeconds, unsetCopyWithValue))
           'max_jwt_lifetime_seconds': maxJwtLifetimeSeconds as int?,
         if (!identical(jwksPollingDisabled, unsetCopyWithValue))
           'jwks_polling_disabled': jwksPollingDisabled as bool?,
       }) {
    if (jwksPollingDisabled == true) {
      throw ArgumentError('JWKS polling can only be re-enabled by this API.');
    }
  }

  /// Decodes a patch without treating an omitted value as null.
  factory FederationIssuerUpdateParams.fromJson(
    Map<String, dynamic> json,
  ) => FederationIssuerUpdateParams(
    issuerUrl: _patchValue<String>(json, 'issuer_url'),
    name: _patchValue<String>(json, 'name'),
    jwks: json.containsKey('jwks') ? _optionalJwks(json) : unsetCopyWithValue,
    checkJti: _patchValue<bool>(json, 'check_jti'),
    maxJwtLifetimeSeconds: _patchValue<int>(json, 'max_jwt_lifetime_seconds'),
    jwksPollingDisabled: _patchValue<bool>(json, 'jwks_polling_disabled'),
  );

  final Map<String, dynamic> _json;

  /// Replacement issuer URL, when present and non-null.
  String? get issuerUrl => _json['issuer_url'] as String?;

  /// Replacement slug, when present and non-null.
  String? get name => _json['name'] as String?;

  /// Replacement signing-key source, when present and non-null.
  FederationJwksSource? get jwks => _optionalJwks(_json);

  /// Replacement JTI check, when present and non-null.
  bool? get checkJti => _json['check_jti'] as bool?;

  /// Replacement lifetime, when present and non-null.
  int? get maxJwtLifetimeSeconds => _json['max_jwt_lifetime_seconds'] as int?;

  /// Whether a JWKS polling request is included.
  bool? get jwksPollingDisabled => _json['jwks_polling_disabled'] as bool?;

  /// Encodes the issuer update request.
  Map<String, dynamic> toJson() => Map.of(_json);

  @override
  bool operator ==(Object other) =>
      other is FederationIssuerUpdateParams &&
      mapsDeepEqual(_json, other._json);

  @override
  int get hashCode => mapDeepHashCode(_json);

  @override
  String toString() => 'FederationIssuerUpdateParams(${_json.length} fields)';
}

T _required<T>(Map<String, dynamic> json, String name) =>
    requiredOrganizationField<T>(json, name, 'Federation issuer');

DateTime? _nullableTime(Map<String, dynamic> json, String name) {
  final value = _required<String?>(json, name);
  return value == null ? null : DateTime.parse(value);
}

String? _wireTime(DateTime? value) => value?.toUtc().toIso8601String();

T? _optional<T>(Map<String, dynamic> json, String name) =>
    json.containsKey(name) ? _required<T?>(json, name) : null;

Object? _patchValue<T>(Map<String, dynamic> json, String name) =>
    json.containsKey(name) ? _required<T?>(json, name) : unsetCopyWithValue;

FederationJwksSource? _optionalJwks(Map<String, dynamic> json) {
  final jwks = _optional<Map<String, dynamic>>(json, 'jwks');
  return jwks == null ? null : FederationJwksSource.fromJson(jwks);
}

List<Map<String, dynamic>> _inlineKeys(Map<String, dynamic> json) {
  final keys = _required<List<dynamic>>(json, 'keys');
  if (keys.isEmpty) throw const FormatException('Expected public JWKs');
  return keys.map((key) {
    if (key is Map<String, dynamic>) return key;
    throw const FormatException('Expected a public JWK object');
  }).toList();
}
