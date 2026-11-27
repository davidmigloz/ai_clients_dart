import '../../models/admin/admin_roles.dart';
import 'admin_transport.dart';

/// Administrative roles operations.
class AdminRolesResource {
  /// Creates the roles resource.
  const AdminRolesResource(this._transport);

  final AdminTransport _transport;

  /// Get Roles.
  Future<AdminRoles> list() =>
      _transport.json('GET', '/v1/admin/roles', AdminRoles.fromJson);
}
