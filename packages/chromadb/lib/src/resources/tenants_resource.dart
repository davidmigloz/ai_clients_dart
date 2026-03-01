import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/tenants/tenant.dart';
import 'base_resource.dart';

/// Resource for tenant management endpoints.
///
/// This resource provides methods for managing tenants in ChromaDB.
/// Tenants provide multi-tenancy isolation, where each tenant has
/// its own set of databases and collections.
///
/// Example:
/// ```dart
/// final client = ChromaClient();
///
/// // Create a new tenant
/// final tenant = await client.tenants.create(name: 'my-tenant');
/// print('Created tenant: ${tenant.name}');
///
/// // Get an existing tenant
/// final retrieved = await client.tenants.get(name: 'my-tenant');
/// ```
class TenantsResource extends ResourceBase {
  /// Creates a tenants resource.
  TenantsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a new tenant.
  ///
  /// [name] - The name for the new tenant.
  ///
  /// Returns the created [Tenant].
  ///
  /// Endpoint: `POST /api/v2/tenants`
  Future<Tenant> create({required String name}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/api/v2/tenants');
    final headers = requestBuilder.buildHeaders(null);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode({'name': name});
    final response = await interceptorChain.execute(httpRequest);
    return Tenant.fromJson(parseJson(response));
  }

  /// Gets a tenant by name.
  ///
  /// [name] - The name of the tenant to retrieve.
  ///
  /// Returns the [Tenant] if found.
  ///
  /// Throws [ChromaNotFoundException] if the tenant does not exist.
  ///
  /// Endpoint: `GET /api/v2/tenants/{tenant_name}`
  Future<Tenant> getByName({required String name}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/api/v2/tenants/${Uri.encodeComponent(name)}',
    );
    final headers = requestBuilder.buildHeaders(null);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return Tenant.fromJson(parseJson(response));
  }

  /// Updates an existing tenant.
  ///
  /// [name] - The current name of the tenant.
  /// [newName] - The new name for the tenant (optional).
  ///
  /// Returns the updated [Tenant].
  ///
  /// Endpoint: `PATCH /api/v2/tenants/{tenant_name}`
  Future<Tenant> update({required String name, String? newName}) async {
    ensureNotClosed?.call();
    final body = <String, dynamic>{};
    if (newName != null) {
      body['new_name'] = newName;
    }

    final url = requestBuilder.buildUrl(
      '/api/v2/tenants/${Uri.encodeComponent(name)}',
    );
    final headers = requestBuilder.buildHeaders(null);
    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);
    final response = await interceptorChain.execute(httpRequest);
    return Tenant.fromJson(parseJson(response));
  }
}
