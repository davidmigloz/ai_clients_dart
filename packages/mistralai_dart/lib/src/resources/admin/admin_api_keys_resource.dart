import '../../models/admin/admin_api_keys.dart';
import 'admin_transport.dart';

/// Administrative api_keys operations.
class AdminApiKeysResource {
  /// Creates the api_keys resource.
  const AdminApiKeysResource(this._transport);

  final AdminTransport _transport;

  /// Get Api Keys.
  Future<AdminApiKeyList> list({int? limit, int? offset, String? name}) =>
      _transport.json(
        'GET',
        '/v1/admin/api-keys',
        AdminApiKeyList.fromJson,
        secretResponse: true,
        query: {
          'limit': ?limit?.toString(),
          'offset': ?offset?.toString(),
          'name': ?name,
        },
      );

  /// Create Api Key.
  Future<AdminCreatedApiKey> create({
    required CreateAdminApiKeyRequest request,
  }) => _transport.json(
    'POST',
    '/v1/admin/api-keys',
    AdminCreatedApiKey.fromJson,
    secretResponse: true,
    body: request.toJson(),
  );

  /// Delete Api Key.
  Future<AdminDeletedApiKey> delete({required String keyId}) => _transport.json(
    'DELETE',
    '/v1/admin/api-keys/${Uri.encodeComponent(keyId)}',
    AdminDeletedApiKey.fromJson,
    secretResponse: true,
  );
}
