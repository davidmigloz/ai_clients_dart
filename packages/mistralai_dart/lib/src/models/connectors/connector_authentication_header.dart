import 'package:meta/meta.dart';

/// A header required by a connector authentication method.
@immutable
class ConnectorAuthenticationHeader {
  /// The header name.
  final String name;

  /// Whether the header is required.
  final bool isRequired;

  /// Whether the header value is secret.
  final bool isSecret;

  /// Creates a [ConnectorAuthenticationHeader].
  const ConnectorAuthenticationHeader({
    required this.name,
    this.isRequired = true,
    this.isSecret = true,
  });

  /// Creates a [ConnectorAuthenticationHeader] from JSON.
  factory ConnectorAuthenticationHeader.fromJson(Map<String, dynamic> json) =>
      ConnectorAuthenticationHeader(
        name: json['name'] as String? ?? '',
        isRequired: json['is_required'] as bool? ?? true,
        isSecret: json['is_secret'] as bool? ?? true,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'is_required': isRequired,
    'is_secret': isSecret,
  };

  /// Creates a copy with the given fields replaced.
  ConnectorAuthenticationHeader copyWith({
    String? name,
    bool? isRequired,
    bool? isSecret,
  }) => ConnectorAuthenticationHeader(
    name: name ?? this.name,
    isRequired: isRequired ?? this.isRequired,
    isSecret: isSecret ?? this.isSecret,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorAuthenticationHeader &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          isRequired == other.isRequired &&
          isSecret == other.isSecret;

  @override
  int get hashCode => Object.hash(name, isRequired, isSecret);

  @override
  String toString() =>
      'ConnectorAuthenticationHeader(name: $name, isRequired: $isRequired, '
      'isSecret: $isSecret)';
}
