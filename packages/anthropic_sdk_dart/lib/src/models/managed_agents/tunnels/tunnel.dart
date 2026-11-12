import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// A Claude MCP tunnel.
@immutable
final class Tunnel {
  /// The wire discriminator.
  String get type => 'tunnel';

  /// Tunnel identifier.
  final String id;

  /// When archived, or null while active.
  final DateTime? archivedAt;

  /// When the resource was created.
  final DateTime createdAt;

  /// Optional tunnel display name.
  final String? displayName;

  /// Provider-assigned tunnel domain.
  final String domain;

  /// Creates a [Tunnel].
  const Tunnel({
    required this.id,
    required this.archivedAt,
    required this.createdAt,
    required this.displayName,
    required this.domain,
  });

  /// Reads a [Tunnel] from JSON.
  factory Tunnel.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'tunnel');
    return Tunnel(
      id: json['id'] as String,
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      displayName: json['display_name'] as String?,
      domain: json['domain'] as String,
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'archived_at': archivedAt?.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'display_name': displayName,
    'domain': domain,
  };

  /// Copies this object with the selected values replaced.
  Tunnel copyWith({
    String? id,
    Object? archivedAt = unsetCopyWithValue,
    DateTime? createdAt,
    Object? displayName = unsetCopyWithValue,
    String? domain,
  }) => Tunnel(
    id: id ?? this.id,
    archivedAt: archivedAt == unsetCopyWithValue
        ? this.archivedAt
        : archivedAt as DateTime?,
    createdAt: createdAt ?? this.createdAt,
    displayName: displayName == unsetCopyWithValue
        ? this.displayName
        : displayName as String?,
    domain: domain ?? this.domain,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tunnel &&
          id == other.id &&
          archivedAt == other.archivedAt &&
          createdAt == other.createdAt &&
          displayName == other.displayName &&
          domain == other.domain;

  @override
  int get hashCode =>
      Object.hash(id, archivedAt, createdAt, displayName, domain);

  @override
  String toString() =>
      'Tunnel(id: $id, archivedAt: $archivedAt, createdAt: $createdAt, displayName: $displayName, domain: $domain)';
}

/// Sensitive credential used by a tunnel proxy.
@immutable
final class TunnelToken {
  /// The wire discriminator.
  String get type => 'tunnel_token';

  /// Identifier of the current token. Changes when rotated.
  final String id;

  /// The sensitive token. Store it securely.
  final String tunnelToken;

  /// Creates a [TunnelToken].
  const TunnelToken({required this.id, required this.tunnelToken});

  /// Reads a [TunnelToken] from JSON.
  factory TunnelToken.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'tunnel_token');
    return TunnelToken(
      id: json['id'] as String,
      tunnelToken: json['tunnel_token'] as String,
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'tunnel_token': tunnelToken,
  };

  /// Copies this object with the selected values replaced.
  TunnelToken copyWith({String? id, String? tunnelToken}) => TunnelToken(
    id: id ?? this.id,
    tunnelToken: tunnelToken ?? this.tunnelToken,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TunnelToken &&
          id == other.id &&
          tunnelToken == other.tunnelToken;

  @override
  int get hashCode => Object.hash(id, tunnelToken);

  @override
  String toString() =>
      'TunnelToken(id: $id, tunnelToken: ${tunnelToken.isEmpty ? 'empty' : '[REDACTED]'})';
}

/// Metadata for the certificate authority associated with a tunnel.
@immutable
final class TunnelCertificate {
  /// The wire discriminator.
  String get type => 'tunnel_certificate';

  /// Certificate identifier.
  final String id;

  /// When archived, or null while active.
  final DateTime? archivedAt;

  /// When the resource was created.
  final DateTime createdAt;

  /// Certificate expiration when known.
  final DateTime? expiresAt;

  /// Certificate fingerprint.
  final String fingerprint;

  /// Tunnel that owns the certificate.
  final String tunnelId;

  /// Creates a [TunnelCertificate].
  const TunnelCertificate({
    required this.id,
    required this.archivedAt,
    required this.createdAt,
    required this.expiresAt,
    required this.fingerprint,
    required this.tunnelId,
  });

  /// Reads a [TunnelCertificate] from JSON.
  factory TunnelCertificate.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'tunnel_certificate');
    return TunnelCertificate(
      id: json['id'] as String,
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      fingerprint: json['fingerprint'] as String,
      tunnelId: json['tunnel_id'] as String,
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'archived_at': archivedAt?.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'expires_at': expiresAt?.toUtc().toIso8601String(),
    'fingerprint': fingerprint,
    'tunnel_id': tunnelId,
  };

  /// Copies this object with the selected values replaced.
  TunnelCertificate copyWith({
    String? id,
    Object? archivedAt = unsetCopyWithValue,
    DateTime? createdAt,
    Object? expiresAt = unsetCopyWithValue,
    String? fingerprint,
    String? tunnelId,
  }) => TunnelCertificate(
    id: id ?? this.id,
    archivedAt: archivedAt == unsetCopyWithValue
        ? this.archivedAt
        : archivedAt as DateTime?,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt == unsetCopyWithValue
        ? this.expiresAt
        : expiresAt as DateTime?,
    fingerprint: fingerprint ?? this.fingerprint,
    tunnelId: tunnelId ?? this.tunnelId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TunnelCertificate &&
          id == other.id &&
          archivedAt == other.archivedAt &&
          createdAt == other.createdAt &&
          expiresAt == other.expiresAt &&
          fingerprint == other.fingerprint &&
          tunnelId == other.tunnelId;

  @override
  int get hashCode =>
      Object.hash(id, archivedAt, createdAt, expiresAt, fingerprint, tunnelId);

  @override
  String toString() =>
      'TunnelCertificate(id: $id, archivedAt: $archivedAt, createdAt: $createdAt, expiresAt: $expiresAt, fingerprint: $fingerprint, tunnelId: $tunnelId)';
}

/// One page of MCP tunnels.
@immutable
final class TunnelListResponse {
  /// Tunnels in this page.
  final List<Tunnel> data;

  /// Opaque cursor, or null when there are no more results.
  final String? nextPage;

  /// Creates a [TunnelListResponse].
  const TunnelListResponse({required this.data, required this.nextPage});

  /// Reads a [TunnelListResponse] from JSON.
  factory TunnelListResponse.fromJson(Map<String, dynamic> json) {
    return TunnelListResponse(
      data: (json['data'] as List)
          .map((item) => Tunnel.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextPage: json['next_page'] as String?,
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    'next_page': nextPage,
  };

  /// Copies this object with the selected values replaced.
  TunnelListResponse copyWith({
    List<Tunnel>? data,
    Object? nextPage = unsetCopyWithValue,
  }) => TunnelListResponse(
    data: data ?? this.data,
    nextPage: nextPage == unsetCopyWithValue
        ? this.nextPage
        : nextPage as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TunnelListResponse &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() => 'TunnelListResponse(data: $data, nextPage: $nextPage)';
}

/// One page of tunnel certificates.
@immutable
final class TunnelCertificateListResponse {
  /// Certificates in this page.
  final List<TunnelCertificate> data;

  /// Opaque cursor, or null when there are no more results.
  final String? nextPage;

  /// Creates a [TunnelCertificateListResponse].
  const TunnelCertificateListResponse({
    required this.data,
    required this.nextPage,
  });

  /// Reads a [TunnelCertificateListResponse] from JSON.
  factory TunnelCertificateListResponse.fromJson(Map<String, dynamic> json) {
    return TunnelCertificateListResponse(
      data: (json['data'] as List)
          .map(
            (item) => TunnelCertificate.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      nextPage: json['next_page'] as String?,
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    'next_page': nextPage,
  };

  /// Copies this object with the selected values replaced.
  TunnelCertificateListResponse copyWith({
    List<TunnelCertificate>? data,
    Object? nextPage = unsetCopyWithValue,
  }) => TunnelCertificateListResponse(
    data: data ?? this.data,
    nextPage: nextPage == unsetCopyWithValue
        ? this.nextPage
        : nextPage as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TunnelCertificateListResponse &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'TunnelCertificateListResponse(data: $data, nextPage: $nextPage)';
}

void _validateType(Map<String, dynamic> json, String type) {
  if (json.containsKey('type') && json['type'] != type) {
    throw FormatException('Expected tunnel response type $type');
  }
}
