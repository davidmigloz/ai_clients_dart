import 'dart:convert';

import '../../errors/exceptions.dart';
import '../../models/admin/admin_scim.dart';
import 'admin_transport.dart';

/// A SCIM sync was already running when a new run was requested.
final class AdminScimSyncConflictException extends ApiException {
  AdminScimSyncConflictException._(this.activeRun, ApiException error)
    : super(
        statusCode: error.statusCode,
        message: 'A SCIM synchronization run is already active.',
        requestMetadata: error.requestMetadata,
        responseMetadata: error.responseMetadata,
      );

  /// The existing run. Use its ID with [AdminScimResource.getRun].
  final AdminScimSyncActiveRun activeRun;
}

/// Administrative scim operations.
class AdminScimResource {
  /// Creates the scim resource.
  const AdminScimResource(this._transport);

  final AdminTransport _transport;

  /// Starts synchronization.
  ///
  /// Throws [AdminScimSyncConflictException] if a run is already active.
  Future<AdminScimSyncStarted> startSync({
    required StartAdminScimSyncRequest request,
  }) async {
    try {
      return await _transport.json(
        'POST',
        '/v1/admin/scim/sync',
        AdminScimSyncStarted.fromJson,
        body: request.toJson(),
      );
    } on ApiException catch (error) {
      if (error.statusCode == 409) {
        if (_activeRun(error) case final active?) {
          throw AdminScimSyncConflictException._(active, error);
        }
      }
      rethrow;
    }
  }

  /// Get Scim Sync Run.
  Future<AdminScimSyncRun> getRun({required String runId}) => _transport.json(
    'GET',
    '/v1/admin/scim/sync/${Uri.encodeComponent(runId)}',
    AdminScimSyncRun.fromJson,
  );

  AdminScimSyncActiveRun? _activeRun(ApiException error) {
    try {
      // The generic error parser uses the full body as the message for
      // objects without its usual message or detail field.
      final body = error.details.firstOrNull ?? jsonDecode(error.message);
      if (body case {'run_id': final String _, 'status': final String _}) {
        return AdminScimSyncActiveRun.fromJson(body as Map<String, dynamic>);
      }
      return null;
    } on FormatException {
      return null;
    }
  }
}
