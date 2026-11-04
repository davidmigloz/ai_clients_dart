import '../../client/admin_http.dart';
import '../../models/admin/admin.dart';

/// Bounded organization operations, authenticated only by OpenAIAdminClient.
final class AdminOrganizationResource {
  /// Creates a namespace sharing an isolated Admin HTTP policy.
  AdminOrganizationResource(this._http);
  final AdminHttp _http;
  AdminExternalKeysResource? _externalKeys;
  AdminExternalStorageResource? _externalStorage;
  AdminProjectsResource? _projects;
  AdminUsageResource? _usage;

  /// External key registration, inspection, validation and removal.
  AdminExternalKeysResource get externalKeys {
    _http.ensureOpen();
    return _externalKeys ??= AdminExternalKeysResource(_http);
  }

  /// Project external storage, including OCI provider configuration.
  AdminExternalStorageResource get externalStorage {
    _http.ensureOpen();
    return _externalStorage ??= AdminExternalStorageResource(_http);
  }

  /// Project administration limited to API-key updates.
  AdminProjectsResource get projects {
    _http.ensureOpen();
    return _projects ??= AdminProjectsResource(_http);
  }

  /// Organization usage limited to Decisions aggregation.
  AdminUsageResource get usage {
    _http.ensureOpen();
    return _usage ??= AdminUsageResource(_http);
  }
}

/// The five external-key operations; creation registers caller-owned key metadata.
final class AdminExternalKeysResource {
  /// Creates a resource sharing an isolated Admin HTTP policy.
  AdminExternalKeysResource(this._http);
  final AdminHttp _http;

  /// Registers AWS, Azure or GCP key metadata. Provider validation is explicit.
  Future<ExternalKey> create(
    ExternalKeyParams request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    _http.ensureOpen();
    request.validate();
    return _http.json(
      'POST',
      '/organization/external_keys',
      ExternalKey.fromJson,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Returns one cursor page. Zero is an accepted limit for this collection.
  Future<ExternalKeyList> list({
    int? limit,
    AdminListOrder? order,
    String? after,
    ExternalKeyPurpose? purpose,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    _http.ensureOpen();
    _limit(limit, 0, 100);
    _knownOrder(order);
    if (purpose != null && !purpose.isKnown) {
      throw const FormatException('Unsupported external-key purpose.');
    }
    return _http.json(
      'GET',
      '/organization/external_keys',
      ExternalKeyList.fromJson,
      query: {
        if (limit != null) 'limit': '$limit',
        if (order != null) 'order': order.value,
        if (after != null) 'after': adminQueryString(after, 'after'),
        if (purpose != null) 'purpose': purpose.value,
      },
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Retrieves one registered key without validating it implicitly.
  Future<ExternalKey> retrieve(
    String externalKeyId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) => _http.json(
    'GET',
    _path(externalKeyId),
    ExternalKey.fromJson,
    additionalHeaders: additionalHeaders,
    abortTrigger: abortTrigger,
  );

  /// Removes a registration and returns the external-key resource, not a deleted marker.
  Future<ExternalKey> delete(
    String externalKeyId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) => _http.json(
    'DELETE',
    _path(externalKeyId),
    ExternalKey.fromJson,
    additionalHeaders: additionalHeaders,
    abortTrigger: abortTrigger,
  );

  /// Requests provider validation. This POST deliberately has no body.
  Future<ExternalKeyValidation> validate(
    String externalKeyId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) => _http.json(
    'POST',
    '${_path(externalKeyId)}/validate',
    ExternalKeyValidation.fromJson,
    additionalHeaders: additionalHeaders,
    abortTrigger: abortTrigger,
  );

  String _path(String id) {
    _http.ensureOpen();
    return '/organization/external_keys/${adminPathId(id, 'externalKeyId')}';
  }
}

/// The five external-storage operations, including AWS, Azure, GCP and OCI.
final class AdminExternalStorageResource {
  /// Creates a resource sharing an isolated Admin HTTP policy.
  AdminExternalStorageResource(this._http);
  final AdminHttp _http;

  /// Saves a project's storage configuration; inspect/validate status explicitly.
  Future<ExternalStorage> create(
    CreateExternalStorageRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    _http.ensureOpen();
    request.validate();
    return _http.json(
      'POST',
      '/organization/external_storage',
      ExternalStorage.fromJson,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Returns one cursor page; no hidden pagination or project lookup occurs.
  Future<ExternalStorageList> list({
    int? limit,
    AdminListOrder? order,
    String? after,
    String? projectId,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    _http.ensureOpen();
    _limit(limit, 1, 100);
    _knownOrder(order);
    return _http.json(
      'GET',
      '/organization/external_storage',
      ExternalStorageList.fromJson,
      query: {
        if (limit != null) 'limit': '$limit',
        if (order != null) 'order': order.value,
        if (after != null) 'after': adminQueryString(after, 'after'),
        if (projectId != null)
          'project_id': adminQueryString(projectId, 'projectId'),
      },
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Retrieves a configuration with its provider/status unchanged.
  Future<ExternalStorage> retrieve(
    String externalStorageId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) => _http.json(
    'GET',
    _path(externalStorageId),
    ExternalStorage.fromJson,
    additionalHeaders: additionalHeaders,
    abortTrigger: abortTrigger,
  );

  /// Removes configuration, not cloud data. Removing the last active config
  /// restores organization-default retention. Repeating deletion can finish an
  /// interrupted retention update; the service owns that transition.
  Future<DeletedExternalStorage> delete(
    String externalStorageId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) => _http.json(
    'DELETE',
    _path(externalStorageId),
    DeletedExternalStorage.fromJson,
    additionalHeaders: additionalHeaders,
    abortTrigger: abortTrigger,
  );

  /// Requests validation without synthesizing a pending/validated transition.
  /// This POST has no body and returns the storage resource.
  Future<ExternalStorage> validate(
    String externalStorageId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) => _http.json(
    'POST',
    '${_path(externalStorageId)}/validate',
    ExternalStorage.fromJson,
    additionalHeaders: additionalHeaders,
    abortTrigger: abortTrigger,
  );

  String _path(String id) {
    _http.ensureOpen();
    return '/organization/external_storage/${adminPathId(id, 'externalStorageId')}';
  }
}

/// Bounded project administration; historical project CRUD is outside this API.
final class AdminProjectsResource {
  /// Creates a namespace sharing an isolated Admin HTTP policy.
  AdminProjectsResource(this._http);
  final AdminHttp _http;
  AdminProjectApiKeysResource? _apiKeys;

  /// API-key permission/expiry updates, including service-account-owned keys.
  AdminProjectApiKeysResource get apiKeys {
    _http.ensureOpen();
    return _apiKeys ??= AdminProjectApiKeysResource(_http);
  }
}

/// Updates project API keys without creating, retrieving or deleting credentials.
final class AdminProjectApiKeysResource {
  /// Creates a resource sharing an isolated Admin HTTP policy.
  AdminProjectApiKeysResource(this._http);
  final AdminHttp _http;

  /// Updates scopes and/or relative expiry. Empty scopes grants All permissions
  /// within the owner's effective access. Scope strings remain open-ended.
  ///
  /// Expiry is relative to each request; an ordinary HTTP retry reapplies that
  /// horizon. The service enforces expired-key and owner/project restrictions.
  Future<ProjectApiKey> update(
    String projectId,
    String apiKeyId,
    UpdateProjectApiKeyRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    _http.ensureOpen();
    request.validate();
    final project = adminPathId(projectId, 'projectId');
    final key = adminPathId(apiKeyId, 'apiKeyId');
    return _http.json(
      'POST',
      '/organization/projects/$project/api_keys/$key',
      ProjectApiKey.fromJson,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

/// Organization Decisions usage. Results are aggregates, not per-request costs.
final class AdminUsageResource {
  /// Creates a resource sharing an isolated Admin HTTP policy.
  AdminUsageResource(this._http);
  final AdminHttp _http;

  /// Returns one bucket page with an inclusive [startTime] and exclusive [endTime].
  ///
  /// Array filters use repeated bare keys, matching OpenAPI form/explode and
  /// Python; Node's bracket-key query dialect is not emitted. Null/empty arrays
  /// are omitted. Pass nextPage as page explicitly; no hidden requests occur.
  /// Default/max bucket counts are 7/31 (day), 24/168 (hour), 60/1440 (minute).
  Future<DecisionsUsagePage> decisions({
    required int startTime,
    int? endTime,
    DecisionsUsageBucketWidth? bucketWidth,
    int? limit,
    String? page,
    List<String>? projectIds,
    List<String>? userIds,
    List<String>? apiKeyIds,
    List<String>? models,
    List<DecisionsUsageGroupBy>? groupBy,
    bool? batch,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    _http.ensureOpen();
    if (!startTime.isFinite || (endTime != null && !endTime.isFinite)) {
      throw const FormatException('Invalid usage timestamp.');
    }
    if (bucketWidth != null && !bucketWidth.isKnown) {
      throw const FormatException('Unsupported bucket width.');
    }
    final max = switch (bucketWidth?.value ?? '1d') {
      '1m' => 1440,
      '1h' => 168,
      _ => 31,
    };
    _limit(limit, 1, max);
    final groups = groupBy == null
        ? null
        : List<DecisionsUsageGroupBy>.of(groupBy);
    if (groups != null && groups.any((g) => !g.isKnown)) {
      throw const FormatException('Unsupported usage group.');
    }
    List<String>? strings(List<String>? values) =>
        values == null || values.isEmpty
        ? null
        : [for (final value in values) adminQueryString(value, 'usage filter')];
    final repeated = <String, List<String>>{};
    void add(String key, List<String>? values) {
      if (values != null) repeated[key] = values;
    }

    add('project_ids', strings(projectIds));
    add('user_ids', strings(userIds));
    add('api_key_ids', strings(apiKeyIds));
    add('models', strings(models));
    if (groups != null && groups.isNotEmpty) {
      repeated['group_by'] = [for (final g in groups) g.value];
    }
    return _http.json(
      'GET',
      '/organization/usage/decisions',
      DecisionsUsagePage.fromJson,
      query: {
        'start_time': '$startTime',
        if (endTime != null) 'end_time': '$endTime',
        if (bucketWidth != null) 'bucket_width': bucketWidth.value,
        if (limit != null) 'limit': '$limit',
        if (page != null) 'page': adminQueryString(page, 'page'),
        if (batch != null) 'batch': '$batch',
      },
      repeated: repeated,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }
}

void _limit(int? value, int min, int max) {
  if (value != null && (!value.isFinite || value < min || value > max)) {
    throw const FormatException('Admin limit out of range.');
  }
}

void _knownOrder(AdminListOrder? order) {
  if (order != null && !order.isKnown) {
    throw const FormatException('Unsupported Admin list order.');
  }
}
