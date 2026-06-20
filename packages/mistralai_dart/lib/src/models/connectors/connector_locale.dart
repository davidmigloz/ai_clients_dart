import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Localized strings for a connector or connector tool.
@immutable
class ConnectorLocale {
  /// Localized names, keyed by locale code.
  final Map<String, String> name;

  /// Localized descriptions, keyed by locale code.
  final Map<String, String> description;

  /// Localized usage sentences, keyed by locale code.
  final Map<String, String> usageSentence;

  /// Creates a [ConnectorLocale].
  const ConnectorLocale({
    required this.name,
    required this.description,
    required this.usageSentence,
  });

  /// Creates a [ConnectorLocale] from JSON.
  factory ConnectorLocale.fromJson(Map<String, dynamic> json) =>
      ConnectorLocale(
        name: (json['name'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, v as String),
        ),
        description: (json['description'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, v as String),
        ),
        usageSentence: (json['usage_sentence'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, v as String)),
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'usage_sentence': usageSentence,
  };

  /// Creates a copy with the given fields replaced.
  ConnectorLocale copyWith({
    Map<String, String>? name,
    Map<String, String>? description,
    Map<String, String>? usageSentence,
  }) => ConnectorLocale(
    name: name ?? this.name,
    description: description ?? this.description,
    usageSentence: usageSentence ?? this.usageSentence,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorLocale &&
          runtimeType == other.runtimeType &&
          mapsEqual(name, other.name) &&
          mapsEqual(description, other.description) &&
          mapsEqual(usageSentence, other.usageSentence);

  @override
  int get hashCode =>
      Object.hash(mapHash(name), mapHash(description), mapHash(usageSentence));

  @override
  String toString() =>
      'ConnectorLocale('
      'name: ${name.length} entries, '
      'description: ${description.length} entries, '
      'usageSentence: ${usageSentence.length} entries)';
}
