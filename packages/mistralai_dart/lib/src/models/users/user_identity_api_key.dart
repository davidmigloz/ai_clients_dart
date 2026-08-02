import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// The API key used to authenticate the current request, if any.
@immutable
class UserIdentityApiKey {
  /// Unique identifier of the API key.
  final String id;

  /// Display name of the API key.
  final String? name;

  /// Creates a [UserIdentityApiKey].
  const UserIdentityApiKey({required this.id, required this.name});

  /// Creates a [UserIdentityApiKey] from JSON.
  ///
  /// Throws a [FormatException] if [id] is missing or null.
  factory UserIdentityApiKey.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) {
      throw FormatException('Missing or invalid "id" field: $json');
    }
    return UserIdentityApiKey(id: id, name: json['name'] as String?);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear [name].
  UserIdentityApiKey copyWith({
    String? id,
    Object? name = unsetCopyWithValue,
  }) => UserIdentityApiKey(
    id: id ?? this.id,
    name: name == unsetCopyWithValue ? this.name : name as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserIdentityApiKey &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'UserIdentityApiKey(id: $id, name: $name)';
}
