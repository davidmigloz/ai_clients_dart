import 'package:meta/meta.dart';

/// Authentication configuration for custom connectors.
///
/// Variants:
/// - [ApiKeyAuth] — API key authentication.
/// - [OAuth2TokenAuth] — OAuth2 token authentication.
@immutable
sealed class ConnectorAuth {
  const ConnectorAuth();

  /// The authentication type.
  String get type;

  /// Creates a [ConnectorAuth] from JSON.
  factory ConnectorAuth.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'api-key' => ApiKeyAuth.fromJson(json),
      'oauth2-token' => OAuth2TokenAuth.fromJson(json),
      _ => throw FormatException(
        'Unknown connector auth type: ${json['type']}',
      ),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// API key authentication for custom connectors.
@immutable
class ApiKeyAuth extends ConnectorAuth {
  @override
  String get type => 'api-key';

  /// The API key value.
  final String value;

  /// Creates an [ApiKeyAuth].
  const ApiKeyAuth({required this.value});

  /// Creates an [ApiKeyAuth] from JSON.
  factory ApiKeyAuth.fromJson(Map<String, dynamic> json) =>
      ApiKeyAuth(value: json['value'] as String? ?? '');

  @override
  Map<String, dynamic> toJson() => {'type': type, 'value': value};

  /// Creates a copy with the given fields replaced.
  ApiKeyAuth copyWith({String? value}) =>
      ApiKeyAuth(value: value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiKeyAuth &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => Object.hash(type, value);

  @override
  String toString() => 'ApiKeyAuth(value: ***)';
}

/// OAuth2 token authentication for custom connectors.
@immutable
class OAuth2TokenAuth extends ConnectorAuth {
  @override
  String get type => 'oauth2-token';

  /// The OAuth2 token value.
  final String value;

  /// Creates an [OAuth2TokenAuth].
  const OAuth2TokenAuth({required this.value});

  /// Creates an [OAuth2TokenAuth] from JSON.
  factory OAuth2TokenAuth.fromJson(Map<String, dynamic> json) =>
      OAuth2TokenAuth(value: json['value'] as String? ?? '');

  @override
  Map<String, dynamic> toJson() => {'type': type, 'value': value};

  /// Creates a copy with the given fields replaced.
  OAuth2TokenAuth copyWith({String? value}) =>
      OAuth2TokenAuth(value: value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuth2TokenAuth &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => Object.hash(type, value);

  @override
  String toString() => 'OAuth2TokenAuth(value: ***)';
}
