import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

// ============================================================================
// Params types — sent to API
// ============================================================================

/// Networking scope for an environment variable credential (create/update
/// params): the outbound hosts on which the secret value is substituted.
///
/// Variants:
/// - [UnrestrictedCredentialNetworkingParams] — any host the session's
///   Environment network policy permits (type: "unrestricted")
/// - [LimitedCredentialNetworkingParams] — only the listed hosts
///   (type: "limited")
/// - [UnknownCredentialNetworkingParams] — Unrecognized type (preserves raw
///   JSON)
sealed class CredentialNetworkingParams {
  const CredentialNetworkingParams();

  /// Creates a [CredentialNetworkingParams] from JSON.
  factory CredentialNetworkingParams.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'unrestricted' => UnrestrictedCredentialNetworkingParams.fromJson(json),
      'limited' => LimitedCredentialNetworkingParams.fromJson(json),
      _ => UnknownCredentialNetworkingParams.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Substitute the secret on any host the session's Environment network policy
/// permits egress to.
@immutable
class UnrestrictedCredentialNetworkingParams
    extends CredentialNetworkingParams {
  /// Creates an [UnrestrictedCredentialNetworkingParams].
  const UnrestrictedCredentialNetworkingParams();

  /// The type discriminator. Always `unrestricted`.
  String get type => 'unrestricted';

  /// Creates an [UnrestrictedCredentialNetworkingParams] from JSON.
  factory UnrestrictedCredentialNetworkingParams.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'unrestricted') {
      throw FormatException(
        'UnrestrictedCredentialNetworkingParams: '
        'expected type "unrestricted", got "$type"',
      );
    }
    return const UnrestrictedCredentialNetworkingParams();
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnrestrictedCredentialNetworkingParams &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'UnrestrictedCredentialNetworkingParams(type: $type)';
}

/// Substitute the secret only on requests to the listed hosts.
@immutable
class LimitedCredentialNetworkingParams extends CredentialNetworkingParams {
  /// Hostnames on which the secret will be substituted.
  ///
  /// Each entry is a bare hostname (`api.example.com`), an IPv4 address
  /// (`192.0.2.1`), or a `*.`-prefixed wildcard (`*.example.com`). URLs,
  /// ports, paths, and IPv6 addresses are not accepted. At most 16 entries.
  final List<String> allowedHosts;

  /// Creates a [LimitedCredentialNetworkingParams].
  LimitedCredentialNetworkingParams({required List<String> allowedHosts})
    : allowedHosts = List.unmodifiable(allowedHosts);

  /// The type discriminator. Always `limited`.
  String get type => 'limited';

  /// Creates a [LimitedCredentialNetworkingParams] from JSON.
  factory LimitedCredentialNetworkingParams.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'limited') {
      throw FormatException(
        'LimitedCredentialNetworkingParams: '
        'expected type "limited", got "$type"',
      );
    }
    return LimitedCredentialNetworkingParams(
      allowedHosts: (json['allowed_hosts'] as List).cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'allowed_hosts': allowedHosts,
  };

  /// Creates a copy with replaced values.
  LimitedCredentialNetworkingParams copyWith({List<String>? allowedHosts}) {
    return LimitedCredentialNetworkingParams(
      allowedHosts: allowedHosts ?? this.allowedHosts,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LimitedCredentialNetworkingParams &&
          runtimeType == other.runtimeType &&
          listsEqual(allowedHosts, other.allowedHosts);

  @override
  int get hashCode => listHash(allowedHosts);

  @override
  String toString() =>
      'LimitedCredentialNetworkingParams('
      'type: $type, '
      'allowedHosts: ${allowedHosts.length} items)';
}

/// Unrecognized credential networking type (preserves raw JSON).
@immutable
class UnknownCredentialNetworkingParams extends CredentialNetworkingParams {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownCredentialNetworkingParams].
  const UnknownCredentialNetworkingParams({required this.rawJson});

  /// Creates an [UnknownCredentialNetworkingParams] from JSON.
  factory UnknownCredentialNetworkingParams.fromJson(
    Map<String, dynamic> json,
  ) {
    return UnknownCredentialNetworkingParams(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownCredentialNetworkingParams &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownCredentialNetworkingParams(rawJson: $rawJson)';
}

// ============================================================================
// Response types — returned from the API
// ============================================================================

/// Networking scope for an environment variable credential (response): the
/// outbound hosts on which the secret value is substituted.
///
/// Variants:
/// - [UnrestrictedCredentialNetworkingResponse] — any host the session's
///   Environment network policy permits (type: "unrestricted")
/// - [LimitedCredentialNetworkingResponse] — only the listed hosts
///   (type: "limited")
/// - [UnknownCredentialNetworkingResponse] — Unrecognized type (preserves raw
///   JSON)
sealed class CredentialNetworkingResponse {
  const CredentialNetworkingResponse();

  /// Creates a [CredentialNetworkingResponse] from JSON.
  factory CredentialNetworkingResponse.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'unrestricted' => UnrestrictedCredentialNetworkingResponse.fromJson(json),
      'limited' => LimitedCredentialNetworkingResponse.fromJson(json),
      _ => UnknownCredentialNetworkingResponse.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// The secret is substituted on any host the session's Environment network
/// policy permits egress to.
@immutable
class UnrestrictedCredentialNetworkingResponse
    extends CredentialNetworkingResponse {
  /// Creates an [UnrestrictedCredentialNetworkingResponse].
  const UnrestrictedCredentialNetworkingResponse();

  /// The type discriminator. Always `unrestricted`.
  String get type => 'unrestricted';

  /// Creates an [UnrestrictedCredentialNetworkingResponse] from JSON.
  factory UnrestrictedCredentialNetworkingResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'unrestricted') {
      throw FormatException(
        'UnrestrictedCredentialNetworkingResponse: '
        'expected type "unrestricted", got "$type"',
      );
    }
    return const UnrestrictedCredentialNetworkingResponse();
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnrestrictedCredentialNetworkingResponse &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'UnrestrictedCredentialNetworkingResponse(type: $type)';
}

/// The secret is substituted only on requests to the listed hosts.
@immutable
class LimitedCredentialNetworkingResponse extends CredentialNetworkingResponse {
  /// Hostnames on which the secret will be substituted.
  ///
  /// An entry matches the request host exactly; a `*.`-prefixed entry matches
  /// any subdomain of the named domain but not the domain itself.
  final List<String> allowedHosts;

  /// Creates a [LimitedCredentialNetworkingResponse].
  LimitedCredentialNetworkingResponse({required List<String> allowedHosts})
    : allowedHosts = List.unmodifiable(allowedHosts);

  /// The type discriminator. Always `limited`.
  String get type => 'limited';

  /// Creates a [LimitedCredentialNetworkingResponse] from JSON.
  factory LimitedCredentialNetworkingResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'limited') {
      throw FormatException(
        'LimitedCredentialNetworkingResponse: '
        'expected type "limited", got "$type"',
      );
    }
    return LimitedCredentialNetworkingResponse(
      allowedHosts: (json['allowed_hosts'] as List).cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'allowed_hosts': allowedHosts,
  };

  /// Creates a copy with replaced values.
  LimitedCredentialNetworkingResponse copyWith({List<String>? allowedHosts}) {
    return LimitedCredentialNetworkingResponse(
      allowedHosts: allowedHosts ?? this.allowedHosts,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LimitedCredentialNetworkingResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(allowedHosts, other.allowedHosts);

  @override
  int get hashCode => listHash(allowedHosts);

  @override
  String toString() =>
      'LimitedCredentialNetworkingResponse('
      'type: $type, '
      'allowedHosts: ${allowedHosts.length} items)';
}

/// Unrecognized credential networking type (preserves raw JSON).
@immutable
class UnknownCredentialNetworkingResponse extends CredentialNetworkingResponse {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownCredentialNetworkingResponse].
  const UnknownCredentialNetworkingResponse({required this.rawJson});

  /// Creates an [UnknownCredentialNetworkingResponse] from JSON.
  factory UnknownCredentialNetworkingResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return UnknownCredentialNetworkingResponse(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownCredentialNetworkingResponse &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownCredentialNetworkingResponse(rawJson: $rawJson)';
}
