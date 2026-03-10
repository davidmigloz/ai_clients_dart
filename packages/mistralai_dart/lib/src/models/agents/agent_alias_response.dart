import 'package:meta/meta.dart';

/// Response for an agent version alias.
@immutable
class AgentAliasResponse {
  /// The alias name.
  final String alias;

  /// The version number the alias points to.
  final int version;

  /// When the alias was created.
  final DateTime createdAt;

  /// When the alias was last updated.
  final DateTime updatedAt;

  /// Creates an [AgentAliasResponse].
  const AgentAliasResponse({
    required this.alias,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an [AgentAliasResponse] from JSON.
  factory AgentAliasResponse.fromJson(Map<String, dynamic> json) =>
      AgentAliasResponse(
        alias: json['alias'] as String? ?? '',
        version: json['version'] as int? ?? 0,
        createdAt: _parseDateTime(json['created_at']) ?? DateTime.utc(1970),
        updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.utc(1970),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'alias': alias,
    'version': version,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentAliasResponse &&
          runtimeType == other.runtimeType &&
          alias == other.alias &&
          version == other.version;

  @override
  int get hashCode => Object.hash(alias, version);

  @override
  String toString() => 'AgentAliasResponse(alias: $alias, version: $version)';
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
