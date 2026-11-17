part of 'agent_session_models.dart';

/// Controls obfuscation of events on a streamed session creation.
final class AgentSessionStreamOptions extends AgentJsonModel {
  /// Omit [includeObfuscation] to use the server's default.
  const AgentSessionStreamOptions({this.includeObfuscation});

  /// Whether to include random padding in events. The service defaults to true.
  final bool? includeObfuscation;

  /// Parses stream options.
  factory AgentSessionStreamOptions.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'include_obfuscation',
    ], 'AgentSessionStreamOptions');
    return AgentSessionStreamOptions(
      includeObfuscation: optionalAgentValue(
        json,
        'include_obfuscation',
        'AgentSessionStreamOptions.includeObfuscation',
        requireAgentBool,
        nullable: false,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'include_obfuscation': ?includeObfuscation};

  /// Copies the options. Explicit null clears the override.
  AgentSessionStreamOptions copyWith({
    Object? includeObfuscation = unsetCopyWithValue,
  }) => AgentSessionStreamOptions(
    includeObfuscation: copyAgentValue<bool>(
      includeObfuscation,
      this.includeObfuscation,
      'AgentSessionStreamOptions.includeObfuscation',
    ),
  );
}

/// Prompt cache lifetime for an Agent session or turn.
final class AgentSessionPromptCacheTtl extends AgentJsonModel {
  const AgentSessionPromptCacheTtl._(this.value);

  /// A minimum lifetime of 30 minutes.
  static const minutes30 = AgentSessionPromptCacheTtl._('30m');

  /// A minimum lifetime of 12 hours.
  static const hours12 = AgentSessionPromptCacheTtl._('12h');

  /// Parses and preserves known or future TTL values.
  factory AgentSessionPromptCacheTtl.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentSessionPromptCacheTtl');
    return switch (value) {
      '30m' => minutes30,
      '12h' => hours12,
      _ => AgentSessionPromptCacheTtl._(value),
    };
  }

  /// The exact wire value.
  final String value;

  @override
  String toJson() => value;
}

/// Configures the default prompt cache lifetime for Managed Agents turns.
final class AgentSessionPromptCacheConfig extends AgentJsonModel {
  /// Creates options. The service defaults an omitted TTL to 30 minutes.
  const AgentSessionPromptCacheConfig({this.ttl});

  /// The configured prompt cache lifetime, if provided.
  final AgentSessionPromptCacheTtl? ttl;

  /// Parses a closed writable cache object.
  factory AgentSessionPromptCacheConfig.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'ttl',
    ], 'AgentSessionPromptCacheConfig');
    return AgentSessionPromptCacheConfig(
      ttl: optionalAgentValue(
        json,
        'ttl',
        'AgentSessionPromptCacheConfig.ttl',
        (value, _) => AgentSessionPromptCacheTtl.fromJson(value),
        nullable: false,
      ),
    )..validate();
  }

  @override
  void validate() {
    if (ttl case final configured?) {
      validateAgentEnum(configured.value, const [
        '30m',
        '12h',
      ], 'AgentSessionPromptCacheConfig.ttl');
    }
  }

  @override
  Map<String, dynamic> toJson() => {'ttl': ?ttl?.toJson()};

  /// Copies the options. Explicit null clears the TTL.
  AgentSessionPromptCacheConfig copyWith({Object? ttl = unsetCopyWithValue}) =>
      AgentSessionPromptCacheConfig(
        ttl: copyAgentValue<AgentSessionPromptCacheTtl>(
          ttl,
          this.ttl,
          'AgentSessionPromptCacheConfig.ttl',
        ),
      )..validate();
}

/// The recorded prompt cache options for a session or turn.
final class AgentSessionPromptCacheOptions extends AgentJsonModel {
  /// Creates received options with their effective lifetime.
  AgentSessionPromptCacheOptions({
    required this.ttl,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'ttl',
       ], 'AgentSessionPromptCacheOptions');

  /// The applied cache lifetime.
  final AgentSessionPromptCacheTtl ttl;

  /// Additional data returned by a newer server.
  final Map<String, dynamic> rawJson;

  /// Parses the server's cache options.
  factory AgentSessionPromptCacheOptions.fromJson(Map<String, dynamic> json) =>
      AgentSessionPromptCacheOptions(
        ttl: AgentSessionPromptCacheTtl.fromJson(json['ttl']),
        rawJson: Map.of(json)..remove('ttl'),
      );

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'ttl': ttl.toJson()};

  /// Copies the received options.
  AgentSessionPromptCacheOptions copyWith({
    AgentSessionPromptCacheTtl? ttl,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionPromptCacheOptions(
    ttl: ttl ?? this.ttl,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Sets the session-wide limit without changing recorded spend.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionSpendControlConfig extends AgentJsonModel {
  /// Creates a validated [AgentSessionSpendControlConfig].
  AgentSessionSpendControlConfig({required this.limit}) {
    validate();
  }

  /// Positive USD cents, or null to remove the limit.
  final int? limit;

  /// Parses [AgentSessionSpendControlConfig] with contextual, payload-free errors.
  factory AgentSessionSpendControlConfig.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'limit',
    ], 'AgentSessionSpendControlConfig');
    return AgentSessionSpendControlConfig(
      limit: requiredAgentValue(
        json,
        'limit',
        'AgentSessionSpendControlConfig.limit',
        requireAgentInt,
        nullable: true,
      ),
    );
  }
  @override
  void validate() {
    if (limit != null) {
      validateAgentInt(
        limit!,
        'AgentSessionSpendControlConfig.limit',
        min: 1,
        max: 4503599627370495,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {'limit': limit};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSpendControlConfig copyWith({
    Object? limit = unsetCopyWithValue,
  }) => AgentSessionSpendControlConfig(
    limit: copyAgentValue<int>(
      limit,
      this.limit,
      'AgentSessionSpendControlConfig.limit',
    ),
  );
}

/// Session-wide spending control, including unlimited sessions.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionSpendControl extends AgentJsonModel {
  /// Creates a validated [AgentSessionSpendControl].
  AgentSessionSpendControl({
    required this.consumed,
    required this.limit,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'consumed',
         'limit',
       ], 'AgentSessionSpendControl') {
    validate();
  }

  /// Best-effort recorded spend floored to whole USD cents, or null when unavailable.
  final int? consumed;

  /// The configured positive limit in USD cents, or null when unlimited.
  final int? limit;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionSpendControl] with contextual, payload-free errors.
  factory AgentSessionSpendControl.fromJson(Map<String, dynamic> json) {
    return AgentSessionSpendControl(
      consumed: requiredAgentValue(
        json,
        'consumed',
        'AgentSessionSpendControl.consumed',
        requireAgentInt,
        nullable: true,
      ),
      limit: requiredAgentValue(
        json,
        'limit',
        'AgentSessionSpendControl.limit',
        requireAgentInt,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const ['consumed', 'limit'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (consumed != null) {
      validateAgentInt(consumed!, 'AgentSessionSpendControl.consumed', min: 0);
    }
    if (limit case final configured?) {
      validateAgentInt(
        configured,
        'AgentSessionSpendControl.limit',
        min: 1,
        max: 4503599627370495,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'consumed': consumed,
    'limit': limit,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSpendControl copyWith({
    Object? consumed = unsetCopyWithValue,
    Object? limit = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionSpendControl(
    consumed: copyAgentValue<int>(
      consumed,
      this.consumed,
      'AgentSessionSpendControl.consumed',
    ),
    limit: copyAgentValue<int>(
      limit,
      this.limit,
      'AgentSessionSpendControl.limit',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}
