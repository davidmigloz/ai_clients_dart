import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'connection_config_type.dart';

/// Public view of a connector's connection configuration.
@immutable
class PublicConnectionConfig {
  /// The connection config type.
  final ConnectionConfigType? type;

  /// The base URL of the connection.
  final String? baseUrl;

  /// Static headers used for the connection.
  final Map<String, String>? headers;

  /// Whether the connection is signed.
  final bool? signed;

  /// Creates a [PublicConnectionConfig].
  const PublicConnectionConfig({
    this.type,
    this.baseUrl,
    this.headers,
    this.signed,
  });

  /// Creates a [PublicConnectionConfig] from JSON.
  factory PublicConnectionConfig.fromJson(Map<String, dynamic> json) =>
      PublicConnectionConfig(
        type: json['type'] != null
            ? ConnectionConfigType.fromJson(json['type'] as String?)
            : null,
        baseUrl: json['base_url'] as String?,
        headers: (json['headers'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as String),
        ),
        signed: json['signed'] as bool?,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    if (type != null) 'type': type!.toJson(),
    if (baseUrl != null) 'base_url': baseUrl,
    if (headers != null) 'headers': headers,
    if (signed != null) 'signed': signed,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  PublicConnectionConfig copyWith({
    Object? type = unsetCopyWithValue,
    Object? baseUrl = unsetCopyWithValue,
    Object? headers = unsetCopyWithValue,
    Object? signed = unsetCopyWithValue,
  }) => PublicConnectionConfig(
    type: type == unsetCopyWithValue
        ? this.type
        : type as ConnectionConfigType?,
    baseUrl: baseUrl == unsetCopyWithValue ? this.baseUrl : baseUrl as String?,
    headers: headers == unsetCopyWithValue
        ? this.headers
        : headers as Map<String, String>?,
    signed: signed == unsetCopyWithValue ? this.signed : signed as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicConnectionConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          baseUrl == other.baseUrl &&
          mapsEqual(headers, other.headers) &&
          signed == other.signed;

  @override
  int get hashCode => Object.hash(type, baseUrl, mapHash(headers), signed);

  @override
  String toString() =>
      'PublicConnectionConfig('
      'type: $type, '
      'baseUrl: $baseUrl, '
      'headers: ${headers?.length ?? 'null'} entries, '
      'signed: $signed)';
}
