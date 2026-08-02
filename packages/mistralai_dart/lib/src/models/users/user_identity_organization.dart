import 'package:meta/meta.dart';

/// The organization the current user belongs to.
@immutable
class UserIdentityOrganization {
  /// Unique identifier of the organization.
  final String id;

  /// Display name of the organization.
  final String name;

  /// Creates a [UserIdentityOrganization].
  const UserIdentityOrganization({required this.id, required this.name});

  /// Creates a [UserIdentityOrganization] from JSON.
  ///
  /// Throws a [FormatException] if a required field is missing or null.
  factory UserIdentityOrganization.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! String || name is! String) {
      throw FormatException('Missing or invalid "id"/"name" field: $json');
    }
    return UserIdentityOrganization(id: id, name: name);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  /// Creates a copy with the specified fields replaced.
  UserIdentityOrganization copyWith({String? id, String? name}) =>
      UserIdentityOrganization(id: id ?? this.id, name: name ?? this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserIdentityOrganization &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'UserIdentityOrganization(id: $id, name: $name)';
}
