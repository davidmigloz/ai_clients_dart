import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'connector_authentication_header.dart';
import 'outbound_authentication_type.dart';

/// Public view of an authentication method, without secrets.
@immutable
class PublicAuthenticationMethod {
  /// The authentication mechanism.
  final OutboundAuthenticationType methodType;

  /// Whether the connector has default credentials for this method.
  final bool hasDefaultCredentials;

  /// The headers required by this authentication method.
  final List<ConnectorAuthenticationHeader>? headers;

  /// Creates a [PublicAuthenticationMethod].
  const PublicAuthenticationMethod({
    required this.methodType,
    required this.hasDefaultCredentials,
    this.headers,
  });

  /// Creates a [PublicAuthenticationMethod] from JSON.
  factory PublicAuthenticationMethod.fromJson(
    Map<String, dynamic> json,
  ) => PublicAuthenticationMethod(
    methodType: OutboundAuthenticationType.fromJson(
      json['method_type'] as String?,
    ),
    hasDefaultCredentials: json['has_default_credentials'] as bool? ?? false,
    headers: (json['headers'] as List<dynamic>?)
        ?.map(
          (e) =>
              ConnectorAuthenticationHeader.fromJson(e as Map<String, dynamic>),
        )
        .toList(),
  );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'method_type': methodType.toJson(),
    'has_default_credentials': hasDefaultCredentials,
    if (headers != null) 'headers': headers!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for [headers] to clear it explicitly; omit to keep.
  PublicAuthenticationMethod copyWith({
    OutboundAuthenticationType? methodType,
    bool? hasDefaultCredentials,
    Object? headers = unsetCopyWithValue,
  }) => PublicAuthenticationMethod(
    methodType: methodType ?? this.methodType,
    hasDefaultCredentials: hasDefaultCredentials ?? this.hasDefaultCredentials,
    headers: headers == unsetCopyWithValue
        ? this.headers
        : headers as List<ConnectorAuthenticationHeader>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicAuthenticationMethod &&
          runtimeType == other.runtimeType &&
          methodType == other.methodType &&
          hasDefaultCredentials == other.hasDefaultCredentials &&
          listsEqual(headers, other.headers);

  @override
  int get hashCode =>
      Object.hash(methodType, hasDefaultCredentials, listHash(headers));

  @override
  String toString() =>
      'PublicAuthenticationMethod('
      'methodType: $methodType, '
      'hasDefaultCredentials: $hasDefaultCredentials, '
      'headers: ${headers == null ? 'null' : '${headers!.length} items'})';
}
