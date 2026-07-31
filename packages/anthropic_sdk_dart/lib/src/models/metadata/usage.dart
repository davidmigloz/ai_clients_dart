import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'fallback_credit_usage.dart';
import 'speed.dart';

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

  /// The number of web fetch tool requests.
  final int webFetchRequests;

  /// Creates a [ServerToolUsage].
  const ServerToolUsage({
    this.webSearchRequests = 0,
    this.webFetchRequests = 0,
  });

  /// Creates a [ServerToolUsage] from JSON.
  factory ServerToolUsage.fromJson(Map<String, dynamic> json) {
    return ServerToolUsage(
      webSearchRequests: json['web_search_requests'] as int? ?? 0,
      webFetchRequests: json['web_fetch_requests'] as int? ?? 0,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'web_search_requests': webSearchRequests,
    'web_fetch_requests': webFetchRequests,
  };

  /// Creates a copy with replaced values.
  ServerToolUsage copyWith({int? webSearchRequests, int? webFetchRequests}) {
    return ServerToolUsage(
      webSearchRequests: webSearchRequests ?? this.webSearchRequests,
      webFetchRequests: webFetchRequests ?? this.webFetchRequests,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerToolUsage &&
          runtimeType == other.runtimeType &&
          webSearchRequests == other.webSearchRequests &&
          webFetchRequests == other.webFetchRequests;

  @override
  int get hashCode => Object.hash(webSearchRequests, webFetchRequests);

  @override
  String toString() =>
      'ServerToolUsage(webSearchRequests: $webSearchRequests, '
      'webFetchRequests: $webFetchRequests)';
}

/// Token usage for a single iteration.
///
/// The [type] field indicates the iteration kind:
/// - `"message"` — executor model inference.
/// - `"compaction"` — context compaction.
/// - `"advisor_message"` — advisor sub-inference; [model] contains the
///   advisor model ID and usage is billed at the advisor model's rates.
@immutable
class IterationUsage {
  /// Iteration type (e.g., "message", "compaction", or "advisor_message").
  final String type;

  /// Input tokens for this iteration.
  final int inputTokens;

  /// Output tokens for this iteration.
  final int outputTokens;

  /// Cache creation token count for this iteration.
  final int cacheCreationInputTokens;

  /// Cache read token count for this iteration.
  final int cacheReadInputTokens;

  /// Cache creation details by TTL.
  final CacheCreation? cacheCreation;

  /// The model used for this iteration (present for `advisor_message`).
  final String? model;

  /// Creates an [IterationUsage].
  const IterationUsage({
    required this.type,
    required this.inputTokens,
    required this.outputTokens,
    this.cacheCreationInputTokens = 0,
    this.cacheReadInputTokens = 0,
    this.cacheCreation,
    this.model,
  });

  /// Creates an [IterationUsage] from JSON.
  factory IterationUsage.fromJson(Map<String, dynamic> json) {
    return IterationUsage(
      type: json['type'] as String? ?? 'message',
      inputTokens: json['input_tokens'] as int? ?? 0,
      outputTokens: json['output_tokens'] as int? ?? 0,
      cacheCreationInputTokens:
          json['cache_creation_input_tokens'] as int? ?? 0,
      cacheReadInputTokens: json['cache_read_input_tokens'] as int? ?? 0,
      cacheCreation: json['cache_creation'] != null
          ? CacheCreation.fromJson(
              json['cache_creation'] as Map<String, dynamic>,
            )
          : null,
      model: json['model'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'input_tokens': inputTokens,
    'output_tokens': outputTokens,
    'cache_creation_input_tokens': cacheCreationInputTokens,
    'cache_read_input_tokens': cacheReadInputTokens,
    if (cacheCreation != null) 'cache_creation': cacheCreation!.toJson(),
    if (model != null) 'model': model,
  };

  /// Creates a copy with replaced values.
  IterationUsage copyWith({
    String? type,
    int? inputTokens,
    int? outputTokens,
    int? cacheCreationInputTokens,
    int? cacheReadInputTokens,
    Object? cacheCreation = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
  }) {
    return IterationUsage(
      type: type ?? this.type,
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      cacheCreationInputTokens:
          cacheCreationInputTokens ?? this.cacheCreationInputTokens,
      cacheReadInputTokens: cacheReadInputTokens ?? this.cacheReadInputTokens,
      cacheCreation: cacheCreation == unsetCopyWithValue
          ? this.cacheCreation
          : cacheCreation as CacheCreation?,
      model: model == unsetCopyWithValue ? this.model : model as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IterationUsage &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          inputTokens == other.inputTokens &&
          outputTokens == other.outputTokens &&
          cacheCreationInputTokens == other.cacheCreationInputTokens &&
          cacheReadInputTokens == other.cacheReadInputTokens &&
          cacheCreation == other.cacheCreation &&
          model == other.model;

  @override
  int get hashCode => Object.hash(
    type,
    inputTokens,
    outputTokens,
    cacheCreationInputTokens,
    cacheReadInputTokens,
    cacheCreation,
    model,
  );

  @override
  String toString() =>
      'IterationUsage(type: $type, inputTokens: $inputTokens, '
      'outputTokens: $outputTokens, '
      'cacheCreationInputTokens: $cacheCreationInputTokens, '
      'cacheReadInputTokens: $cacheReadInputTokens, '
      'cacheCreation: $cacheCreation, model: $model)';
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

/// Breakdown of output tokens by category.
///
/// `outputTokens` remains the inclusive, authoritative total used for billing;
/// this object is a read-only decomposition for observability.
@immutable
class OutputTokensDetails {
  /// Number of output tokens the model generated as internal reasoning,
  /// including the thinking-block delimiter tokens.
  ///
  /// Always ≤ `outputTokens`; `outputTokens - thinkingTokens` approximates the
  /// non-reasoning output. Computed by re-tokenizing the raw reasoning text, so
  /// it may differ from the model's exact generation count by a few tokens.
  final int thinkingTokens;

  /// Creates an [OutputTokensDetails].
  const OutputTokensDetails({this.thinkingTokens = 0});

  /// Creates an [OutputTokensDetails] from JSON.
  factory OutputTokensDetails.fromJson(Map<String, dynamic> json) {
    return OutputTokensDetails(
      thinkingTokens: json['thinking_tokens'] as int? ?? 0,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'thinking_tokens': thinkingTokens};

  /// Creates a copy with replaced values.
  OutputTokensDetails copyWith({int? thinkingTokens}) {
    return OutputTokensDetails(
      thinkingTokens: thinkingTokens ?? this.thinkingTokens,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputTokensDetails &&
          runtimeType == other.runtimeType &&
          thinkingTokens == other.thinkingTokens;

  @override
  int get hashCode => thinkingTokens.hashCode;

  @override
  String toString() => 'OutputTokensDetails(thinkingTokens: $thinkingTokens)';
}

/// Token usage statistics for a request.
@immutable
class Usage {
  /// The number of input tokens used.
  final int inputTokens;

  /// The number of output tokens generated.
  final int outputTokens;

  /// Breakdown of output tokens by category (e.g., reasoning tokens).
  final OutputTokensDetails? outputTokensDetails;

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

  /// Geographic region where inference was performed.
  final String? inferenceGeo;

  /// Per-iteration token usage breakdown.
  final List<IterationUsage>? iterations;

  /// Speed mode used for this request.
  final Speed? speed;

  /// Outcome of the `fallback_credit_token` presented on this request.
  ///
  /// Present on every response to a non-batch request that carried a
  /// `fallback_credit_token`, in either redemption mode; absent otherwise
  /// (batch items accept and ignore the token and carry no outcome object).
  final FallbackCreditUsage? fallbackCredit;

  /// Creates a [Usage].
  const Usage({
    required this.inputTokens,
    required this.outputTokens,
    this.outputTokensDetails,
    this.cacheCreation,
    this.cacheCreationInputTokens,
    this.cacheRead,
    this.cacheReadInputTokens,
    this.serverToolUse,
    this.serviceTier,
    this.inferenceGeo,
    this.iterations,
    this.speed,
    this.fallbackCredit,
  });

  /// Creates a [Usage] from JSON.
  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      inputTokens: json['input_tokens'] as int,
      outputTokens: json['output_tokens'] as int,
      outputTokensDetails: json['output_tokens_details'] != null
          ? OutputTokensDetails.fromJson(
              json['output_tokens_details'] as Map<String, dynamic>,
            )
          : null,
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
      inferenceGeo: json['inference_geo'] as String?,
      iterations: (json['iterations'] as List?)
          ?.map((e) => IterationUsage.fromJson(e as Map<String, dynamic>))
          .toList(),
      speed: json['speed'] != null
          ? Speed.fromJson(json['speed'] as String)
          : null,
      fallbackCredit: json['fallback_credit'] != null
          ? FallbackCreditUsage.fromJson(
              json['fallback_credit'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input_tokens': inputTokens,
    'output_tokens': outputTokens,
    if (outputTokensDetails != null)
      'output_tokens_details': outputTokensDetails!.toJson(),
    if (cacheCreation != null) 'cache_creation': cacheCreation!.toJson(),
    if (cacheCreationInputTokens != null)
      'cache_creation_input_tokens': cacheCreationInputTokens,
    if (cacheRead != null) 'cache_read': cacheRead!.toJson(),
    if (cacheReadInputTokens != null)
      'cache_read_input_tokens': cacheReadInputTokens,
    if (serverToolUse != null) 'server_tool_use': serverToolUse!.toJson(),
    if (serviceTier != null) 'service_tier': serviceTier!.toJson(),
    if (inferenceGeo != null) 'inference_geo': inferenceGeo,
    if (iterations != null)
      'iterations': iterations!.map((e) => e.toJson()).toList(),
    if (speed != null) 'speed': speed!.toJson(),
    if (fallbackCredit != null) 'fallback_credit': fallbackCredit!.toJson(),
  };

  /// Creates a copy with replaced values.
  Usage copyWith({
    int? inputTokens,
    int? outputTokens,
    Object? outputTokensDetails = unsetCopyWithValue,
    Object? cacheCreation = unsetCopyWithValue,
    Object? cacheCreationInputTokens = unsetCopyWithValue,
    Object? cacheRead = unsetCopyWithValue,
    Object? cacheReadInputTokens = unsetCopyWithValue,
    Object? serverToolUse = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    Object? inferenceGeo = unsetCopyWithValue,
    Object? iterations = unsetCopyWithValue,
    Object? speed = unsetCopyWithValue,
    Object? fallbackCredit = unsetCopyWithValue,
  }) {
    return Usage(
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      outputTokensDetails: outputTokensDetails == unsetCopyWithValue
          ? this.outputTokensDetails
          : outputTokensDetails as OutputTokensDetails?,
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
      inferenceGeo: inferenceGeo == unsetCopyWithValue
          ? this.inferenceGeo
          : inferenceGeo as String?,
      iterations: iterations == unsetCopyWithValue
          ? this.iterations
          : iterations as List<IterationUsage>?,
      speed: speed == unsetCopyWithValue ? this.speed : speed as Speed?,
      fallbackCredit: fallbackCredit == unsetCopyWithValue
          ? this.fallbackCredit
          : fallbackCredit as FallbackCreditUsage?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Usage &&
          runtimeType == other.runtimeType &&
          inputTokens == other.inputTokens &&
          outputTokens == other.outputTokens &&
          outputTokensDetails == other.outputTokensDetails &&
          cacheCreation == other.cacheCreation &&
          cacheCreationInputTokens == other.cacheCreationInputTokens &&
          cacheRead == other.cacheRead &&
          cacheReadInputTokens == other.cacheReadInputTokens &&
          serverToolUse == other.serverToolUse &&
          serviceTier == other.serviceTier &&
          inferenceGeo == other.inferenceGeo &&
          listsEqual(iterations, other.iterations) &&
          speed == other.speed &&
          fallbackCredit == other.fallbackCredit;

  @override
  int get hashCode => Object.hash(
    inputTokens,
    outputTokens,
    outputTokensDetails,
    cacheCreation,
    cacheCreationInputTokens,
    cacheRead,
    cacheReadInputTokens,
    serverToolUse,
    serviceTier,
    inferenceGeo,
    listHash(iterations),
    speed,
    fallbackCredit,
  );

  @override
  String toString() =>
      'Usage(inputTokens: $inputTokens, outputTokens: $outputTokens, '
      'outputTokensDetails: $outputTokensDetails, '
      'cacheCreation: $cacheCreation, '
      'cacheCreationInputTokens: $cacheCreationInputTokens, '
      'cacheRead: $cacheRead, cacheReadInputTokens: $cacheReadInputTokens, '
      'serverToolUse: $serverToolUse, serviceTier: $serviceTier, '
      'inferenceGeo: $inferenceGeo, iterations: $iterations, speed: $speed, '
      'fallbackCredit: $fallbackCredit)';
}
