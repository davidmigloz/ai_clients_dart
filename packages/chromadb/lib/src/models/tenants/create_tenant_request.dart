import 'package:meta/meta.dart' show immutable;

/// Request to create a new tenant.
@immutable
class CreateTenantRequest {
  /// The name for the new tenant.
  final String name;

  /// Creates a create tenant request.
  const CreateTenantRequest({required this.name});

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() => {'name': name};
}
