import 'package:meta/meta.dart' show immutable;

/// Request to create a new database.
@immutable
class CreateDatabaseRequest {
  /// The name for the new database.
  final String name;

  /// Creates a create database request.
  const CreateDatabaseRequest({required this.name});

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() => {'name': name};
}
