import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Filters for listing connectors.
@immutable
class ConnectorsQueryFilters {
  /// Historical filter for active connectors.
  final bool? active;

  /// Filters by MCP-compatible tool support.
  final bool? supportsMcp;

  /// Creates a [ConnectorsQueryFilters].
  const ConnectorsQueryFilters({this.supportsMcp, this.active});

  /// Creates a [ConnectorsQueryFilters] from JSON.
  factory ConnectorsQueryFilters.fromJson(Map<String, dynamic> json) =>
      ConnectorsQueryFilters(
        supportsMcp: json['supports_mcp'] as bool?,
        active: json['active'] as bool?,
      );

  /// Converts these filters to JSON.
  Map<String, dynamic> toJson() => {
    if (supportsMcp != null) 'supports_mcp': supportsMcp,
    if (active != null) 'active': active,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for [active] to clear it explicitly; omit to keep.
  ConnectorsQueryFilters copyWith({
    Object? supportsMcp = unsetCopyWithValue,
    Object? active = unsetCopyWithValue,
  }) => ConnectorsQueryFilters(
    supportsMcp: supportsMcp == unsetCopyWithValue
        ? this.supportsMcp
        : supportsMcp as bool?,
    active: active == unsetCopyWithValue ? this.active : active as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorsQueryFilters &&
          supportsMcp == other.supportsMcp &&
          runtimeType == other.runtimeType &&
          active == other.active;

  @override
  int get hashCode => Object.hashAll([active.hashCode, supportsMcp]);

  @override
  String toString() =>
      'ConnectorsQueryFilters(supportsMcp: $supportsMcp, active: $active)';
}
