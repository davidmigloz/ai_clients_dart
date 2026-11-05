/// Reported time range, including the current partial period.
enum UsageRange {
  /// The previous 24 complete UTC hours and the current hour.
  hours24('24h'),

  /// The previous seven complete UTC days and today.
  days7('7d'),

  /// The previous 30 complete UTC days and today.
  days30('30d'),

  /// An unrecognized response value; the original string is not retained.
  unknown('unknown');

  /// The API wire value.
  final String value;

  const UsageRange(this.value);

  /// Parses a value, falling back for future server values.
  static UsageRange fromJson(String value) => switch (value) {
    '24h' => hours24,
    '7d' => days7,
    '30d' => days30,
    _ => unknown,
  };

  /// Converts to the API wire value.
  String toJson() => value;
}

/// Whose usage to report.
enum UsageScope {
  /// Usage for the authenticated user.
  self('self'),

  /// Usage for the whole team; requires a team administrator.
  team('team'),

  /// An unrecognized response value; the original string is not retained.
  unknown('unknown');

  /// The API wire value.
  final String value;

  const UsageScope(this.value);

  /// Parses a value, falling back for future server values.
  static UsageScope fromJson(String value) => switch (value) {
    'self' => self,
    'team' => team,
    _ => unknown,
  };

  /// Converts to the API wire value.
  String toJson() => value;
}

/// How usage is grouped within totals and buckets.
enum UsageGroupBy {
  /// Group usage by model.
  model('model'),

  /// An unrecognized response value; the original string is not retained.
  unknown('unknown');

  /// The API wire value.
  final String value;

  const UsageGroupBy(this.value);

  /// Parses a value, falling back for future server values.
  static UsageGroupBy fromJson(String value) => switch (value) {
    'model' => model,
    _ => unknown,
  };

  /// Converts to the API wire value.
  String toJson() => value;
}

/// Bucket size selected automatically by the service.
enum UsageGranularity {
  /// Hourly buckets for the 24h range.
  hour('hour'),

  /// Daily buckets for the 7d and 30d ranges.
  day('day'),

  /// An unrecognized response value; the original string is not retained.
  unknown('unknown');

  /// The API wire value.
  final String value;

  const UsageGranularity(this.value);

  /// Parses a value, falling back for future server values.
  static UsageGranularity fromJson(String value) => switch (value) {
    'hour' => hour,
    'day' => day,
    _ => unknown,
  };

  /// Converts to the API wire value.
  String toJson() => value;
}
