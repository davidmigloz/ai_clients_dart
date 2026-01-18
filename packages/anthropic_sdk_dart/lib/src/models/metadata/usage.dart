import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Token usage breakdown for cache creation.
@immutable
class CacheCreation {
  /// The number of input tokens used to create the 1 hour cache entry.
  final int ephemeral1hInputTokens;

  /// The number of input tokens used to create the 5 minute cache entry.
  final int ephemeral5mInputTokens;

  /// Creates a [CacheCreation].
  const CacheCreation({
    this.ephemeral1hInputTokens = 0,
    this.ephemeral5mInputTokens = 0,
  });

  /// Creates a [CacheCreation] from JSON.
  factory CacheCreation.fromJson(Map<String, dynamic> json) {
    return CacheCreation(
      ephemeral1hInputTokens: json['ephemeral_1h_input_tokens'] as int? ?? 0,
      ephemeral5mInputTokens: json['ephemeral_5m_input_tokens'] as int? ?? 0,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'ephemeral_1h_input_tokens': ephemeral1hInputTokens,
    'ephemeral_5m_input_tokens': ephemeral5mInputTokens,
  };

  /// Creates a copy with replaced values.
  CacheCreation copyWith({
    int? ephemeral1hInputTokens,
    int? ephemeral5mInputTokens,
  }) {
    return CacheCreation(
      ephemeral1hInputTokens:
          ephemeral1hInputTokens ?? this.ephemeral1hInputTokens,
      ephemeral5mInputTokens:
          ephemeral5mInputTokens ?? this.ephemeral5mInputTokens,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheCreation &&
          runtimeType == other.runtimeType &&
          ephemeral1hInputTokens == other.ephemeral1hInputTokens &&
          ephemeral5mInputTokens == other.ephemeral5mInputTokens;

  @override
  int get hashCode =>
      Object.hash(ephemeral1hInputTokens, ephemeral5mInputTokens);

  @override
  String toString() =>
      'CacheCreation(ephemeral1hInputTokens: $ephemeral1hInputTokens, '
      'ephemeral5mInputTokens: $ephemeral5mInputTokens)';
}

/// Token usage breakdown for cache reads.
@immutable
class CacheRead {
  /// The number of input tokens read from the 1 hour cache.
  final int ephemeral1hInputTokens;

  /// The number of input tokens read from the 5 minute cache.
  final int ephemeral5mInputTokens;

  /// Creates a [CacheRead].
  const CacheRead({
    this.ephemeral1hInputTokens = 0,
    this.ephemeral5mInputTokens = 0,
  });

  /// Creates a [CacheRead] from JSON.
  factory CacheRead.fromJson(Map<String, dynamic> json) {
    return CacheRead(
      ephemeral1hInputTokens: json['ephemeral_1h_input_tokens'] as int? ?? 0,
      ephemeral5mInputTokens: json['ephemeral_5m_input_tokens'] as int? ?? 0,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'ephemeral_1h_input_tokens': ephemeral1hInputTokens,
    'ephemeral_5m_input_tokens': ephemeral5mInputTokens,
  };

  /// Creates a copy with replaced values.
  CacheRead copyWith({
    int? ephemeral1hInputTokens,
    int? ephemeral5mInputTokens,
  }) {
    return CacheRead(
      ephemeral1hInputTokens:
          ephemeral1hInputTokens ?? this.ephemeral1hInputTokens,
      ephemeral5mInputTokens:
          ephemeral5mInputTokens ?? this.ephemeral5mInputTokens,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheRead &&
          runtimeType == other.runtimeType &&
          ephemeral1hInputTokens == other.ephemeral1hInputTokens &&
          ephemeral5mInputTokens == other.ephemeral5mInputTokens;

  @override
  int get hashCode =>
      Object.hash(ephemeral1hInputTokens, ephemeral5mInputTokens);

  @override
  String toString() =>
      'CacheRead(ephemeral1hInputTokens: $ephemeral1hInputTokens, '
      'ephemeral5mInputTokens: $ephemeral5mInputTokens)';
}

/// Server tool usage statistics.
@immutable
class ServerToolUsage {
  /// The number of web search tool requests.
  final int webSearchRequests;

  /// Creates a [ServerToolUsage].
  const ServerToolUsage({this.webSearchRequests = 0});

  /// Creates a [ServerToolUsage] from JSON.
  factory ServerToolUsage.fromJson(Map<String, dynamic> json) {
    return ServerToolUsage(
      webSearchRequests: json['web_search_requests'] as int? ?? 0,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'web_search_requests': webSearchRequests};

  /// Creates a copy with replaced values.
  ServerToolUsage copyWith({int? webSearchRequests}) {
    return ServerToolUsage(
      webSearchRequests: webSearchRequests ?? this.webSearchRequests,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerToolUsage &&
          runtimeType == other.runtimeType &&
          webSearchRequests == other.webSearchRequests;

  @override
  int get hashCode => webSearchRequests.hashCode;

  @override
  String toString() => 'ServerToolUsage(webSearchRequests: $webSearchRequests)';
}

/// Service tier used for the request.
enum ServiceTier {
  /// Standard tier.
  standard,

  /// Priority tier.
  priority,

  /// Batch tier.
  batch;

  /// Creates a [ServiceTier] from JSON.
  factory ServiceTier.fromJson(String value) => switch (value) {
    'standard' => standard,
    'priority' => priority,
    'batch' => batch,
    _ => throw FormatException('Unknown ServiceTier: $value'),
  };

  /// Converts to JSON.
  String toJson() => name;
}

/// Token usage statistics for a request.
@immutable
class Usage {
  /// The number of input tokens used.
  final int inputTokens;

  /// The number of output tokens generated.
  final int outputTokens;

  /// Breakdown of cached tokens by TTL for creation.
  final CacheCreation? cacheCreation;

  /// The number of input tokens used to create the cache entry.
  final int? cacheCreationInputTokens;

  /// Breakdown of cached tokens by TTL for reads.
  final CacheRead? cacheRead;

  /// The number of input tokens read from the cache.
  final int? cacheReadInputTokens;

  /// Server tool usage statistics, if any.
  final ServerToolUsage? serverToolUse;

  /// The service tier used (standard, priority, batch).
  final ServiceTier? serviceTier;

  /// Creates a [Usage].
  const Usage({
    required this.inputTokens,
    required this.outputTokens,
    this.cacheCreation,
    this.cacheCreationInputTokens,
    this.cacheRead,
    this.cacheReadInputTokens,
    this.serverToolUse,
    this.serviceTier,
  });

  /// Creates a [Usage] from JSON.
  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      inputTokens: json['input_tokens'] as int,
      outputTokens: json['output_tokens'] as int,
      cacheCreation: json['cache_creation'] != null
          ? CacheCreation.fromJson(
              json['cache_creation'] as Map<String, dynamic>,
            )
          : null,
      cacheCreationInputTokens: json['cache_creation_input_tokens'] as int?,
      cacheRead: json['cache_read'] != null
          ? CacheRead.fromJson(json['cache_read'] as Map<String, dynamic>)
          : null,
      cacheReadInputTokens: json['cache_read_input_tokens'] as int?,
      serverToolUse: json['server_tool_use'] != null
          ? ServerToolUsage.fromJson(
              json['server_tool_use'] as Map<String, dynamic>,
            )
          : null,
      serviceTier: json['service_tier'] != null
          ? ServiceTier.fromJson(json['service_tier'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input_tokens': inputTokens,
    'output_tokens': outputTokens,
    if (cacheCreation != null) 'cache_creation': cacheCreation!.toJson(),
    if (cacheCreationInputTokens != null)
      'cache_creation_input_tokens': cacheCreationInputTokens,
    if (cacheRead != null) 'cache_read': cacheRead!.toJson(),
    if (cacheReadInputTokens != null)
      'cache_read_input_tokens': cacheReadInputTokens,
    if (serverToolUse != null) 'server_tool_use': serverToolUse!.toJson(),
    if (serviceTier != null) 'service_tier': serviceTier!.toJson(),
  };

  /// Creates a copy with replaced values.
  Usage copyWith({
    int? inputTokens,
    int? outputTokens,
    Object? cacheCreation = unsetCopyWithValue,
    Object? cacheCreationInputTokens = unsetCopyWithValue,
    Object? cacheRead = unsetCopyWithValue,
    Object? cacheReadInputTokens = unsetCopyWithValue,
    Object? serverToolUse = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
  }) {
    return Usage(
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      cacheCreation: cacheCreation == unsetCopyWithValue
          ? this.cacheCreation
          : cacheCreation as CacheCreation?,
      cacheCreationInputTokens: cacheCreationInputTokens == unsetCopyWithValue
          ? this.cacheCreationInputTokens
          : cacheCreationInputTokens as int?,
      cacheRead: cacheRead == unsetCopyWithValue
          ? this.cacheRead
          : cacheRead as CacheRead?,
      cacheReadInputTokens: cacheReadInputTokens == unsetCopyWithValue
          ? this.cacheReadInputTokens
          : cacheReadInputTokens as int?,
      serverToolUse: serverToolUse == unsetCopyWithValue
          ? this.serverToolUse
          : serverToolUse as ServerToolUsage?,
      serviceTier: serviceTier == unsetCopyWithValue
          ? this.serviceTier
          : serviceTier as ServiceTier?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Usage &&
          runtimeType == other.runtimeType &&
          inputTokens == other.inputTokens &&
          outputTokens == other.outputTokens &&
          cacheCreation == other.cacheCreation &&
          cacheCreationInputTokens == other.cacheCreationInputTokens &&
          cacheRead == other.cacheRead &&
          cacheReadInputTokens == other.cacheReadInputTokens &&
          serverToolUse == other.serverToolUse &&
          serviceTier == other.serviceTier;

  @override
  int get hashCode => Object.hash(
    inputTokens,
    outputTokens,
    cacheCreation,
    cacheCreationInputTokens,
    cacheRead,
    cacheReadInputTokens,
    serverToolUse,
    serviceTier,
  );

  @override
  String toString() =>
      'Usage(inputTokens: $inputTokens, outputTokens: $outputTokens, '
      'cacheCreation: $cacheCreation, '
      'cacheCreationInputTokens: $cacheCreationInputTokens, '
      'cacheRead: $cacheRead, cacheReadInputTokens: $cacheReadInputTokens, '
      'serverToolUse: $serverToolUse, serviceTier: $serviceTier)';
}
