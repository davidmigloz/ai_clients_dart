import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Filters for listing connectors.
@immutable
class ConnectorsQueryFilters {
  /// Filter for active connectors for a given user, workspace and
  /// organization.
  final bool? active;

  /// Creates a [ConnectorsQueryFilters].
  const ConnectorsQueryFilters({this.active});

  /// Creates a [ConnectorsQueryFilters] from JSON.
  factory ConnectorsQueryFilters.fromJson(Map<String, dynamic> json) =>
      ConnectorsQueryFilters(active: json['active'] as bool?);

  /// Converts these filters to JSON.
  Map<String, dynamic> toJson() => {if (active != null) 'active': active};

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for [active] to clear it explicitly; omit to keep.
  ConnectorsQueryFilters copyWith({Object? active = unsetCopyWithValue}) =>
      ConnectorsQueryFilters(
        active: active == unsetCopyWithValue ? this.active : active as bool?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorsQueryFilters &&
          runtimeType == other.runtimeType &&
          active == other.active;

  @override
  int get hashCode => active.hashCode;

  @override
  String toString() => 'ConnectorsQueryFilters(active: $active)';
}
