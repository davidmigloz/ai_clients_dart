import '../../models/admin/admin_audit_logs.dart';
import 'admin_transport.dart';

/// Admin audit log retrieval.
class AdminAuditLogsResource {
  /// Creates the audit log resource.
  const AdminAuditLogsResource(this._transport);

  final AdminTransport _transport;

  /// Get Audit Logs.
  Future<List<AdminAuditLog>> list({
    List<AdminAuditActorType>? actorType,
    List<AdminAuditEventType>? eventType,
    List<AdminAuditTargetType>? targetType,
    String? actorUserUuid,
    AdminAuditLogSort? sort,
    String? after,
    String? before,
    int? limit,
  }) => _transport.list(
    'GET',
    '/v1/admin/audit-logs',
    AdminAuditLog.fromJson,
    query: {
      'actor_type': ?actorType?.map((value) => value.toJson()).toList(),
      'event_type': ?eventType?.map((value) => value.toJson()).toList(),
      'target_type': ?targetType?.map((value) => value.toJson()).toList(),
      'actor_user_uuid': ?actorUserUuid,
      'sort': ?sort?.value,
      'after': ?after,
      'before': ?before,
      'limit': ?limit?.toString(),
    },
  );
}
