import 'package:meta/meta.dart';

/// A ChromaDB tenant.
///
/// Tenants provide multi-tenancy isolation in ChromaDB. Each tenant
/// contains its own set of databases and collections.
@immutable
class Tenant {
  /// The tenant's name.
  final String name;

  /// Creates a tenant.
  const Tenant({required this.name});

  /// Creates a tenant from JSON.
  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(name: json['name'] as String);
  }

  /// Converts this tenant to JSON.
  Map<String, dynamic> toJson() => {'name': name};

  /// Creates a copy of this tenant with optional modifications.
  Tenant copyWith({String? name}) {
    return Tenant(name: name ?? this.name);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tenant && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Tenant(name: $name)';
}
