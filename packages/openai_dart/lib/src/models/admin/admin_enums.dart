import 'admin_json.dart';

/// Frozen `ExternalKeyPurpose` values; unknown received strings retain their exact value.
final class ExternalKeyPurpose extends AdminJsonValue {
  const ExternalKeyPurpose._(this.value);

  /// The `ekm` wire value.
  static const ExternalKeyPurpose ekm = ExternalKeyPurpose._('ekm');

  /// The `psp_decryption` wire value.
  static const ExternalKeyPurpose pspDecryption = ExternalKeyPurpose._(
    'psp_decryption',
  );

  /// Exact wire string.
  final String value;

  /// Reads a known or future string without normalizing it.
  factory ExternalKeyPurpose.fromJson(Object? json) {
    final value = adminString(json, 'ExternalKeyPurpose');
    return switch (value) {
      'ekm' => ekm,
      'psp_decryption' => pspDecryption,
      _ => ExternalKeyPurpose._(value),
    };
  }

  /// Whether this is in the frozen source set.
  bool get isKnown => ['ekm', 'psp_decryption'].contains(value);
  @override
  String toJson() => value;

  /// Copies the exact wire string.
  ExternalKeyPurpose copyWith({String? value}) =>
      ExternalKeyPurpose.fromJson(value ?? this.value);
}

/// Frozen `ExternalStorageStatus` values; unknown received strings retain their exact value.
final class ExternalStorageStatus extends AdminJsonValue {
  const ExternalStorageStatus._(this.value);

  /// The `pending` wire value.
  static const ExternalStorageStatus pending = ExternalStorageStatus._(
    'pending',
  );

  /// The `validated` wire value.
  static const ExternalStorageStatus validated = ExternalStorageStatus._(
    'validated',
  );

  /// The `degraded` wire value.
  static const ExternalStorageStatus degraded = ExternalStorageStatus._(
    'degraded',
  );

  /// The `unhealthy` wire value.
  static const ExternalStorageStatus unhealthy = ExternalStorageStatus._(
    'unhealthy',
  );

  /// Exact wire string.
  final String value;

  /// Reads a known or future string without normalizing it.
  factory ExternalStorageStatus.fromJson(Object? json) {
    final value = adminString(json, 'ExternalStorageStatus');
    return switch (value) {
      'pending' => pending,
      'validated' => validated,
      'degraded' => degraded,
      'unhealthy' => unhealthy,
      _ => ExternalStorageStatus._(value),
    };
  }

  /// Whether this is in the frozen source set.
  bool get isKnown =>
      ['pending', 'validated', 'degraded', 'unhealthy'].contains(value);
  @override
  String toJson() => value;

  /// Copies the exact wire string.
  ExternalStorageStatus copyWith({String? value}) =>
      ExternalStorageStatus.fromJson(value ?? this.value);
}

/// Frozen `DecisionsUsageBucketWidth` values; unknown received strings retain their exact value.
final class DecisionsUsageBucketWidth extends AdminJsonValue {
  const DecisionsUsageBucketWidth._(this.value);

  /// The `1m` wire value.
  static const DecisionsUsageBucketWidth minute = DecisionsUsageBucketWidth._(
    '1m',
  );

  /// The `1h` wire value.
  static const DecisionsUsageBucketWidth hour = DecisionsUsageBucketWidth._(
    '1h',
  );

  /// The `1d` wire value.
  static const DecisionsUsageBucketWidth day = DecisionsUsageBucketWidth._(
    '1d',
  );

  /// Exact wire string.
  final String value;

  /// Reads a known or future string without normalizing it.
  factory DecisionsUsageBucketWidth.fromJson(Object? json) {
    final value = adminString(json, 'DecisionsUsageBucketWidth');
    return switch (value) {
      '1m' => minute,
      '1h' => hour,
      '1d' => day,
      _ => DecisionsUsageBucketWidth._(value),
    };
  }

  /// Whether this is in the frozen source set.
  bool get isKnown => ['1m', '1h', '1d'].contains(value);
  @override
  String toJson() => value;

  /// Copies the exact wire string.
  DecisionsUsageBucketWidth copyWith({String? value}) =>
      DecisionsUsageBucketWidth.fromJson(value ?? this.value);
}

/// Frozen `DecisionsUsageGroupBy` values; unknown received strings retain their exact value.
final class DecisionsUsageGroupBy extends AdminJsonValue {
  const DecisionsUsageGroupBy._(this.value);

  /// The `project_id` wire value.
  static const DecisionsUsageGroupBy projectId = DecisionsUsageGroupBy._(
    'project_id',
  );

  /// The `user_id` wire value.
  static const DecisionsUsageGroupBy userId = DecisionsUsageGroupBy._(
    'user_id',
  );

  /// The `api_key_id` wire value.
  static const DecisionsUsageGroupBy apiKeyId = DecisionsUsageGroupBy._(
    'api_key_id',
  );

  /// The `model` wire value.
  static const DecisionsUsageGroupBy model = DecisionsUsageGroupBy._('model');

  /// The `batch` wire value.
  static const DecisionsUsageGroupBy batch = DecisionsUsageGroupBy._('batch');

  /// The `service_tier` wire value.
  static const DecisionsUsageGroupBy serviceTier = DecisionsUsageGroupBy._(
    'service_tier',
  );

  /// The `api_source` wire value.
  static const DecisionsUsageGroupBy apiSource = DecisionsUsageGroupBy._(
    'api_source',
  );

  /// Exact wire string.
  final String value;

  /// Reads a known or future string without normalizing it.
  factory DecisionsUsageGroupBy.fromJson(Object? json) {
    final value = adminString(json, 'DecisionsUsageGroupBy');
    return switch (value) {
      'project_id' => projectId,
      'user_id' => userId,
      'api_key_id' => apiKeyId,
      'model' => model,
      'batch' => batch,
      'service_tier' => serviceTier,
      'api_source' => apiSource,
      _ => DecisionsUsageGroupBy._(value),
    };
  }

  /// Whether this is in the frozen source set.
  bool get isKnown => [
    'project_id',
    'user_id',
    'api_key_id',
    'model',
    'batch',
    'service_tier',
    'api_source',
  ].contains(value);
  @override
  String toJson() => value;

  /// Copies the exact wire string.
  DecisionsUsageGroupBy copyWith({String? value}) =>
      DecisionsUsageGroupBy.fromJson(value ?? this.value);
}

/// Frozen `DecisionsUsageApiSource` values; unknown received strings retain their exact value.
final class DecisionsUsageApiSource extends AdminJsonValue {
  const DecisionsUsageApiSource._(this.value);

  /// The `agents_api` wire value.
  static const DecisionsUsageApiSource agentsApi = DecisionsUsageApiSource._(
    'agents_api',
  );

  /// The `unlabeled` wire value.
  static const DecisionsUsageApiSource unlabeled = DecisionsUsageApiSource._(
    'unlabeled',
  );

  /// Exact wire string.
  final String value;

  /// Reads a known or future string without normalizing it.
  factory DecisionsUsageApiSource.fromJson(Object? json) {
    final value = adminString(json, 'DecisionsUsageApiSource');
    return switch (value) {
      'agents_api' => agentsApi,
      'unlabeled' => unlabeled,
      _ => DecisionsUsageApiSource._(value),
    };
  }

  /// Whether this is in the frozen source set.
  bool get isKnown => ['agents_api', 'unlabeled'].contains(value);
  @override
  String toJson() => value;

  /// Copies the exact wire string.
  DecisionsUsageApiSource copyWith({String? value}) =>
      DecisionsUsageApiSource.fromJson(value ?? this.value);
}

/// Frozen `OrderEnum` values; unknown received strings retain their exact value.
final class AdminListOrder extends AdminJsonValue {
  const AdminListOrder._(this.value);

  /// The `asc` wire value.
  static const AdminListOrder asc = AdminListOrder._('asc');

  /// The `desc` wire value.
  static const AdminListOrder desc = AdminListOrder._('desc');

  /// Exact wire string.
  final String value;

  /// Reads a known or future string without normalizing it.
  factory AdminListOrder.fromJson(Object? json) {
    final value = adminString(json, 'AdminListOrder');
    return switch (value) {
      'asc' => asc,
      'desc' => desc,
      _ => AdminListOrder._(value),
    };
  }

  /// Whether this is in the frozen source set.
  bool get isKnown => ['asc', 'desc'].contains(value);
  @override
  String toJson() => value;

  /// Copies the exact wire string.
  AdminListOrder copyWith({String? value}) =>
      AdminListOrder.fromJson(value ?? this.value);
}
