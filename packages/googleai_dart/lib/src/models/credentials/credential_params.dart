import 'credential.dart';

/// Where an environment variable credential can be injected.
enum InjectionLocation {
  /// An outgoing HTTP header.
  header,

  /// An outgoing URL query parameter.
  query,

  /// An outgoing HTTP request body.
  body;

  /// Parses an injection location.
  static InjectionLocation fromString(String value) => switch (value) {
    'header' => header,
    'query' => query,
    'body' => body,
    _ => throw const FormatException(
      'Unrecognized credential injection location',
    ),
  };
}

/// One or more locations for injecting an environment variable credential.
///
/// [SingleInjectionLocation] encodes a string.
/// [MultipleInjectionLocations] encodes a list of strings.
sealed class CredentialInjectionLocations {
  const CredentialInjectionLocations();

  /// Injects the credential into one location.
  const factory CredentialInjectionLocations.single(
    InjectionLocation location,
  ) = SingleInjectionLocation;

  /// Injects the credential into a list of locations.
  const factory CredentialInjectionLocations.multiple(
    List<InjectionLocation> locations,
  ) = MultipleInjectionLocations;

  /// Parses a location or a nonempty list of locations.
  factory CredentialInjectionLocations.fromJson(Object? json) => switch (json) {
    final String location => SingleInjectionLocation(
      InjectionLocation.fromString(location),
    ),
    final List<dynamic> locations when locations.isNotEmpty =>
      MultipleInjectionLocations([
        for (final location in locations)
          if (location is String)
            InjectionLocation.fromString(location)
          else
            throw const FormatException(
              'Invalid credential injection location',
            ),
      ]),
    _ => throw const FormatException(
      'Expected at least one credential injection location',
    ),
  };

  /// Converts the value to its wire representation.
  Object toJson();
}

/// One injection location.
final class SingleInjectionLocation extends CredentialInjectionLocations {
  /// Where to inject the credential.
  final InjectionLocation location;

  /// Creates one injection location.
  const SingleInjectionLocation(this.location);

  @override
  String toJson() => location.name;
}

/// A list of injection locations.
final class MultipleInjectionLocations extends CredentialInjectionLocations {
  /// Where to inject the credential.
  final List<InjectionLocation> locations;

  /// Creates a list of locations.
  const MultipleInjectionLocations(this.locations);

  @override
  List<String> toJson() {
    if (locations.isEmpty) {
      throw ArgumentError(
        'At least one credential injection location is required',
      );
    }
    return [for (final location in locations) location.name];
  }
}

/// Request parameters for creating a server-managed credential.
///
/// Supports [EnvironmentVariableConfig], [HttpBearerConfig], and [OAuth2Config].
/// The JSON representation includes the secrets needed for the request.
sealed class CredentialCreateParams {
  const CredentialCreateParams();

  /// The identifier to assign to the credential.
  String get id;

  /// The kind of credential to create.
  CredentialType get type;

  /// Parses parameters for one of the supported credential types.
  factory CredentialCreateParams.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'environment_variable' => EnvironmentVariableConfig.fromJson(json),
        'bearer_token' => HttpBearerConfig.fromJson(json),
        'oauth2' => OAuth2Config.fromJson(json),
        _ => throw const FormatException('Unknown credential create type'),
      };

  /// Encodes the request, including its secret values.
  Map<String, dynamic> toJson();
}

/// Parameters for storing an environment variable credential.
final class EnvironmentVariableConfig extends CredentialCreateParams {
  @override
  final String id;

  @override
  CredentialType get type => CredentialType.environmentVariable;

  /// The secret environment variable value to store.
  final String value;

  /// Locations where this value may be injected into requests.
  final CredentialInjectionLocations injectionLocation;

  /// Domains that may receive this value in outbound requests.
  final List<String>? trustedDomains;

  /// Creates environment variable credential parameters.
  const EnvironmentVariableConfig({
    required this.id,
    required this.value,
    required this.injectionLocation,
    this.trustedDomains,
  });

  /// Parses environment variable credential parameters.
  factory EnvironmentVariableConfig.fromJson(Map<String, dynamic> json) {
    _expectType(json, CredentialType.environmentVariable);
    return EnvironmentVariableConfig(
      id: _requiredString(json, 'id'),
      value: _requiredString(json, 'value'),
      injectionLocation: CredentialInjectionLocations.fromJson(
        json['injection_location'],
      ),
      trustedDomains: _readStrings(json['trusted_domains']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type.value,
    'id': id,
    'value': value,
    'injection_location': injectionLocation.toJson(),
    'trusted_domains': ?trustedDomains,
  };
}

/// Parameters for storing an HTTP bearer token credential.
final class HttpBearerConfig extends CredentialCreateParams {
  @override
  final String id;

  @override
  CredentialType get type => CredentialType.bearerToken;

  /// The secret token to store.
  final String token;

  /// The target header. The server defaults to `Authorization`.
  final String? headerName;

  /// The token prefix. An empty string requests no prefix.
  final String? prefix;

  /// Creates HTTP bearer credential parameters.
  const HttpBearerConfig({
    required this.id,
    required this.token,
    this.headerName,
    this.prefix,
  });

  /// Parses HTTP bearer credential parameters.
  factory HttpBearerConfig.fromJson(Map<String, dynamic> json) {
    _expectType(json, CredentialType.bearerToken);
    return HttpBearerConfig(
      id: _requiredString(json, 'id'),
      token: _requiredString(json, 'token'),
      headerName: json['header_name'] as String?,
      prefix: json['prefix'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type.value,
    'id': id,
    'token': token,
    'header_name': ?headerName,
    'prefix': ?prefix,
  };
}

/// Parameters for storing an OAuth2 credential.
final class OAuth2Config extends CredentialCreateParams {
  @override
  final String id;

  @override
  CredentialType get type => CredentialType.oauth2;

  /// The OAuth2 client identifier.
  final String clientId;

  /// The OAuth2 client secret to store.
  final String clientSecret;

  /// The secret refresh token to store.
  final String refreshToken;

  /// The token endpoint for refreshing access tokens.
  final String tokenUrl;

  /// The requested OAuth2 scopes.
  final List<String>? scopes;

  /// Creates OAuth2 credential parameters.
  const OAuth2Config({
    required this.id,
    required this.clientId,
    required this.clientSecret,
    required this.refreshToken,
    required this.tokenUrl,
    this.scopes,
  });

  /// Parses OAuth2 credential parameters.
  factory OAuth2Config.fromJson(Map<String, dynamic> json) {
    _expectType(json, CredentialType.oauth2);
    return OAuth2Config(
      id: _requiredString(json, 'id'),
      clientId: _requiredString(json, 'client_id'),
      clientSecret: _requiredString(json, 'client_secret'),
      refreshToken: _requiredString(json, 'refresh_token'),
      tokenUrl: _requiredString(json, 'token_url'),
      scopes: _readStrings(json['scopes']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type.value,
    'id': id,
    'client_id': clientId,
    'client_secret': clientSecret,
    'refresh_token': refreshToken,
    'token_url': tokenUrl,
    'scopes': ?scopes,
  };
}

/// Request parameters for modifying a server-managed credential.
///
/// Supports [EnvironmentVariableUpdateConfig], [HttpBearerUpdateConfig], and
/// [OAuth2UpdateConfig]. Null fields are omitted from the request.
sealed class CredentialUpdateParams {
  const CredentialUpdateParams();

  /// The type of the credential being modified.
  CredentialType get type;

  /// Parses update parameters for a supported credential type.
  factory CredentialUpdateParams.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'environment_variable' => EnvironmentVariableUpdateConfig.fromJson(
          json,
        ),
        'bearer_token' => HttpBearerUpdateConfig.fromJson(json),
        'oauth2' => OAuth2UpdateConfig.fromJson(json),
        _ => throw const FormatException('Unknown credential update type'),
      };

  /// Encodes the request, including supplied secret values.
  Map<String, dynamic> toJson();
}

/// Updates an environment variable credential.
final class EnvironmentVariableUpdateConfig extends CredentialUpdateParams {
  @override
  CredentialType get type => CredentialType.environmentVariable;

  /// A replacement secret value.
  final String? value;

  /// Replacement injection locations.
  final CredentialInjectionLocations? injectionLocation;

  /// Replacement trusted domains.
  final List<String>? trustedDomains;

  /// Creates environment variable update parameters.
  const EnvironmentVariableUpdateConfig({
    this.value,
    this.injectionLocation,
    this.trustedDomains,
  });

  /// Parses environment variable update parameters.
  factory EnvironmentVariableUpdateConfig.fromJson(Map<String, dynamic> json) {
    _expectType(json, CredentialType.environmentVariable);
    final injection = json['injection_location'];
    return EnvironmentVariableUpdateConfig(
      value: json['value'] as String?,
      injectionLocation: injection == null
          ? null
          : CredentialInjectionLocations.fromJson(injection),
      trustedDomains: _readStrings(json['trusted_domains']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type.value,
    'value': ?value,
    if (injectionLocation != null)
      'injection_location': injectionLocation!.toJson(),
    'trusted_domains': ?trustedDomains,
  };
}

/// Updates an HTTP bearer token credential.
final class HttpBearerUpdateConfig extends CredentialUpdateParams {
  @override
  CredentialType get type => CredentialType.bearerToken;

  /// A replacement secret token.
  final String? token;

  /// A replacement header name.
  final String? headerName;

  /// A replacement prefix. An empty string requests no prefix.
  final String? prefix;

  /// Creates HTTP bearer update parameters.
  const HttpBearerUpdateConfig({this.token, this.headerName, this.prefix});

  /// Parses HTTP bearer update parameters.
  factory HttpBearerUpdateConfig.fromJson(Map<String, dynamic> json) {
    _expectType(json, CredentialType.bearerToken);
    return HttpBearerUpdateConfig(
      token: json['token'] as String?,
      headerName: json['header_name'] as String?,
      prefix: json['prefix'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type.value,
    'token': ?token,
    'header_name': ?headerName,
    'prefix': ?prefix,
  };
}

/// Updates an OAuth2 credential.
final class OAuth2UpdateConfig extends CredentialUpdateParams {
  @override
  CredentialType get type => CredentialType.oauth2;

  /// A replacement OAuth2 client identifier.
  final String? clientId;

  /// A replacement OAuth2 client secret.
  final String? clientSecret;

  /// A replacement secret refresh token.
  final String? refreshToken;

  /// A replacement token endpoint.
  final String? tokenUrl;

  /// Replacement OAuth2 scopes.
  final List<String>? scopes;

  /// Creates OAuth2 update parameters.
  const OAuth2UpdateConfig({
    this.clientId,
    this.clientSecret,
    this.refreshToken,
    this.tokenUrl,
    this.scopes,
  });

  /// Parses OAuth2 update parameters.
  factory OAuth2UpdateConfig.fromJson(Map<String, dynamic> json) {
    _expectType(json, CredentialType.oauth2);
    return OAuth2UpdateConfig(
      clientId: json['client_id'] as String?,
      clientSecret: json['client_secret'] as String?,
      refreshToken: json['refresh_token'] as String?,
      tokenUrl: json['token_url'] as String?,
      scopes: _readStrings(json['scopes']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type.value,
    'client_id': ?clientId,
    'client_secret': ?clientSecret,
    'refresh_token': ?refreshToken,
    'token_url': ?tokenUrl,
    'scopes': ?scopes,
  };
}

String _requiredString(Map<String, dynamic> json, String name) {
  final value = json[name];
  if (value is! String) {
    throw FormatException('Credential parameters: expected "$name"');
  }
  return value;
}

void _expectType(Map<String, dynamic> json, CredentialType type) {
  if (json['type'] != type.value) {
    throw FormatException(
      'Credential parameters: expected type "${type.value}"',
    );
  }
}

List<String>? _readStrings(Object? json) =>
    json == null ? null : List<String>.from(json as List<dynamic>);
