import 'package:meta/meta.dart';

/// The workspace the current user belongs to.
@immutable
class UserIdentityWorkspace {
  /// Unique identifier of the workspace.
  final String id;

  /// Display name of the workspace.
  final String name;

  /// Creates a [UserIdentityWorkspace].
  const UserIdentityWorkspace({required this.id, required this.name});

  /// Creates a [UserIdentityWorkspace] from JSON.
  ///
  /// Throws a [FormatException] if a required field is missing or null.
  factory UserIdentityWorkspace.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! String || name is! String) {
      throw FormatException('Missing or invalid "id"/"name" field: $json');
    }
    return UserIdentityWorkspace(id: id, name: name);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  /// Creates a copy with the specified fields replaced.
  UserIdentityWorkspace copyWith({String? id, String? name}) =>
      UserIdentityWorkspace(id: id ?? this.id, name: name ?? this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserIdentityWorkspace &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'UserIdentityWorkspace(id: $id, name: $name)';
}
