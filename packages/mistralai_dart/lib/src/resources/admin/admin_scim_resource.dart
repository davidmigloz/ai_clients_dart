import '../../models/admin/admin_scim.dart';
import 'admin_transport.dart';

/// Administrative scim operations.
class AdminScimResource {
  /// Creates the scim resource.
  const AdminScimResource(this._transport);

  final AdminTransport _transport;

  /// Trigger Scim Sync.
  Future<AdminScimSyncStarted> startSync({
    required StartAdminScimSyncRequest request,
  }) => _transport.json(
    'POST',
    '/v1/admin/scim/sync',
    AdminScimSyncStarted.fromJson,
    body: request.toJson(),
  );

  /// Get Scim Sync Run.
  Future<AdminScimSyncRun> getRun({required String runId}) => _transport.json(
    'GET',
    '/v1/admin/scim/sync/${Uri.encodeComponent(runId)}',
    AdminScimSyncRun.fromJson,
  );
}
