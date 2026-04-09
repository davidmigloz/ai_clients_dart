import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

/// Permission policy for tool execution.
///
/// Variants:
/// - [AlwaysAllowPolicy] — tool calls are automatically approved.
/// - [AlwaysAskPolicy] — tool calls require user confirmation.
/// - [UnknownPermissionPolicy] — unrecognised policy (preserves raw JSON).
sealed class PermissionPolicy {
  const PermissionPolicy();

  /// Creates a [PermissionPolicy] from JSON.
  factory PermissionPolicy.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'always_allow' => AlwaysAllowPolicy.fromJson(json),
      'always_ask' => AlwaysAskPolicy.fromJson(json),
      _ => UnknownPermissionPolicy._(type: type, raw: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Tool calls are automatically approved without user confirmation.
@immutable
class AlwaysAllowPolicy extends PermissionPolicy {
  /// The type discriminator. Always `always_allow`.
  final String type;

  /// Creates an [AlwaysAllowPolicy].
  const AlwaysAllowPolicy({this.type = 'always_allow'});

  /// Creates an [AlwaysAllowPolicy] from JSON.
  factory AlwaysAllowPolicy.fromJson(Map<String, dynamic> json) {
    return AlwaysAllowPolicy(type: json['type'] as String? ?? 'always_allow');
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates a copy with replaced values.
  AlwaysAllowPolicy copyWith({String? type}) {
    return AlwaysAllowPolicy(type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlwaysAllowPolicy &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'AlwaysAllowPolicy(type: $type)';
}

/// Tool calls require user confirmation before execution.
@immutable
class AlwaysAskPolicy extends PermissionPolicy {
  /// The type discriminator. Always `always_ask`.
  final String type;

  /// Creates an [AlwaysAskPolicy].
  const AlwaysAskPolicy({this.type = 'always_ask'});

  /// Creates an [AlwaysAskPolicy] from JSON.
  factory AlwaysAskPolicy.fromJson(Map<String, dynamic> json) {
    return AlwaysAskPolicy(type: json['type'] as String? ?? 'always_ask');
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates a copy with replaced values.
  AlwaysAskPolicy copyWith({String? type}) {
    return AlwaysAskPolicy(type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlwaysAskPolicy &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'AlwaysAskPolicy(type: $type)';
}

/// Unrecognised permission policy — preserves the raw JSON.
@immutable
class UnknownPermissionPolicy extends PermissionPolicy {
  /// The unrecognised type discriminator.
  final String type;

  /// The raw JSON map.
  final Map<String, dynamic> raw;

  const UnknownPermissionPolicy._({required this.type, required this.raw});

  @override
  Map<String, dynamic> toJson() => raw;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownPermissionPolicy &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(raw));

  @override
  String toString() => 'UnknownPermissionPolicy(type: $type, raw: $raw)';
}
