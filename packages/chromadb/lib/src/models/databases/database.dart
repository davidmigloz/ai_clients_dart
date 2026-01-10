import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';

/// A ChromaDB database.
///
/// Databases provide a logical grouping of collections within a tenant.
/// Each database belongs to exactly one tenant.
@immutable
class Database {
  /// The database's unique identifier.
  ///
  /// May be the same as [name] if the server doesn't return a separate ID.
  final String id;

  /// The database's name.
  final String name;

  /// The tenant this database belongs to.
  final String? tenant;

  /// Creates a database.
  const Database({required this.id, required this.name, this.tenant});

  /// Creates a database from JSON.
  ///
  /// Some server responses may omit fields. If [id] is missing, [name] is used.
  /// If [name] is missing, [id] is used.
  factory Database.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    final id = json['id'] as String?;

    if (name == null && id == null) {
      throw FormatException(
        'Database JSON must contain at least "id" or "name"',
        json,
      );
    }

    return Database(
      id: id ?? name!,
      name: name ?? id!,
      tenant: json['tenant'] as String?,
    );
  }

  /// Converts this database to JSON.
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, if (tenant != null) 'tenant': tenant};
  }

  /// Creates a copy of this database with optional modifications.
  Database copyWith({
    String? id,
    String? name,
    Object? tenant = unsetCopyWithValue,
  }) {
    return Database(
      id: id ?? this.id,
      name: name ?? this.name,
      tenant: tenant == unsetCopyWithValue ? this.tenant : tenant as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Database &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          tenant == other.tenant;

  @override
  int get hashCode => Object.hash(id, name, tenant);

  @override
  String toString() => 'Database(id: $id, name: $name, tenant: $tenant)';
}
