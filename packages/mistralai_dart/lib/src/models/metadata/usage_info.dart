import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'completion_tokens_details.dart';
import 'prompt_tokens_details.dart';

/// Token usage information for a completion.
@immutable
class UsageInfo {
  /// Number of tokens in the prompt.
  final int promptTokens;

  /// Number of tokens in the completion.
  final int completionTokens;

  /// Total number of tokens (prompt + completion).
  final int totalTokens;

  /// Number of audio seconds in the prompt.
  final int? promptAudioSeconds;

  /// Number of prompt tokens served from the prompt cache.
  final int? numCachedTokens;

  /// Prompt token details (`prompt_tokens_details`), such as cached tokens.
  final PromptTokensDetails? promptTokensDetails;

  /// Prompt token details sent under the legacy singular
  /// `prompt_token_details` key.
  final PromptTokensDetails? promptTokenDetails;

  /// Completion token details (`completion_tokens_details`), such as
  /// reasoning tokens.
  final CompletionTokensDetails? completionTokensDetails;

  /// Capacity tier that served the request, such as `standard` or `priority`.
  final String? serviceTier;

  /// The number of requests accounted for by the response, when reported.
  final int? requestCount;

  /// Total tokens used by connectors, when reported for a conversation.
  final int? connectorTokens;

  /// Usage by connector, when reported for a conversation.
  final Map<String, int>? connectors;

  /// Creates a [UsageInfo].
  const UsageInfo({
    this.requestCount,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    this.promptAudioSeconds,
    this.numCachedTokens,
    this.promptTokensDetails,
    this.promptTokenDetails,
    this.completionTokensDetails,
    this.serviceTier,
    this.connectorTokens,
    this.connectors,
  });

  /// Creates a [UsageInfo] from JSON.
  factory UsageInfo.fromJson(Map<String, dynamic> json) => UsageInfo(
    requestCount: json['request_count'] as int?,
    promptTokens: json['prompt_tokens'] as int? ?? 0,
    completionTokens: json['completion_tokens'] as int? ?? 0,
    totalTokens: json['total_tokens'] as int? ?? 0,
    promptAudioSeconds: json['prompt_audio_seconds'] as int?,
    numCachedTokens: json['num_cached_tokens'] as int?,
    serviceTier: json['service_tier'] as String?,
    connectorTokens: json['connector_tokens'] as int?,
    connectors: (json['connectors'] as Map<String, dynamic>?)
        ?.cast<String, int>(),
    promptTokensDetails: json['prompt_tokens_details'] != null
        ? PromptTokensDetails.fromJson(
            json['prompt_tokens_details'] as Map<String, dynamic>,
          )
        : null,
    promptTokenDetails: json['prompt_token_details'] != null
        ? PromptTokensDetails.fromJson(
            json['prompt_token_details'] as Map<String, dynamic>,
          )
        : null,
    completionTokensDetails: json['completion_tokens_details'] != null
        ? CompletionTokensDetails.fromJson(
            json['completion_tokens_details'] as Map<String, dynamic>,
          )
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (requestCount != null) 'request_count': requestCount,
    'prompt_tokens': promptTokens,
    'completion_tokens': completionTokens,
    'total_tokens': totalTokens,
    if (promptAudioSeconds != null) 'prompt_audio_seconds': promptAudioSeconds,
    if (numCachedTokens != null) 'num_cached_tokens': numCachedTokens,
    if (promptTokensDetails != null)
      'prompt_tokens_details': promptTokensDetails!.toJson(),
    if (promptTokenDetails != null)
      'prompt_token_details': promptTokenDetails!.toJson(),
    if (serviceTier != null) 'service_tier': serviceTier,
    'connector_tokens': ?connectorTokens,
    'connectors': ?connectors,
    if (completionTokensDetails != null)
      'completion_tokens_details': completionTokensDetails!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  UsageInfo copyWith({
    Object? requestCount = unsetCopyWithValue,
    int? promptTokens,
    int? completionTokens,
    int? totalTokens,
    Object? promptAudioSeconds = unsetCopyWithValue,
    Object? numCachedTokens = unsetCopyWithValue,
    Object? promptTokensDetails = unsetCopyWithValue,
    Object? promptTokenDetails = unsetCopyWithValue,
    Object? completionTokensDetails = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    Object? connectorTokens = unsetCopyWithValue,
    Object? connectors = unsetCopyWithValue,
  }) => UsageInfo(
    requestCount: requestCount == unsetCopyWithValue
        ? this.requestCount
        : requestCount as int?,
    promptTokens: promptTokens ?? this.promptTokens,
    completionTokens: completionTokens ?? this.completionTokens,
    totalTokens: totalTokens ?? this.totalTokens,
    promptAudioSeconds: promptAudioSeconds == unsetCopyWithValue
        ? this.promptAudioSeconds
        : promptAudioSeconds as int?,
    numCachedTokens: numCachedTokens == unsetCopyWithValue
        ? this.numCachedTokens
        : numCachedTokens as int?,
    promptTokensDetails: promptTokensDetails == unsetCopyWithValue
        ? this.promptTokensDetails
        : promptTokensDetails as PromptTokensDetails?,
    promptTokenDetails: promptTokenDetails == unsetCopyWithValue
        ? this.promptTokenDetails
        : promptTokenDetails as PromptTokensDetails?,
    connectorTokens: connectorTokens == unsetCopyWithValue
        ? this.connectorTokens
        : connectorTokens as int?,
    connectors: connectors == unsetCopyWithValue
        ? this.connectors
        : connectors as Map<String, int>?,
    serviceTier: serviceTier == unsetCopyWithValue
        ? this.serviceTier
        : serviceTier as String?,
    completionTokensDetails: completionTokensDetails == unsetCopyWithValue
        ? this.completionTokensDetails
        : completionTokensDetails as CompletionTokensDetails?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsageInfo &&
          requestCount == other.requestCount &&
          runtimeType == other.runtimeType &&
          promptTokens == other.promptTokens &&
          completionTokens == other.completionTokens &&
          totalTokens == other.totalTokens &&
          promptAudioSeconds == other.promptAudioSeconds &&
          numCachedTokens == other.numCachedTokens &&
          promptTokensDetails == other.promptTokensDetails &&
          promptTokenDetails == other.promptTokenDetails &&
          completionTokensDetails == other.completionTokensDetails &&
          serviceTier == other.serviceTier &&
          connectorTokens == other.connectorTokens &&
          mapsEqual(connectors, other.connectors);

  @override
  int get hashCode => Object.hashAll([
    promptTokens,
    completionTokens,
    totalTokens,
    promptAudioSeconds,
    numCachedTokens,
    promptTokensDetails,
    promptTokenDetails,
    completionTokensDetails,
    serviceTier,
    requestCount,
    connectorTokens,
    mapHash(connectors),
  ]);

  @override
  String toString() =>
      'UsageInfo(requestCount: $requestCount, promptTokens: $promptTokens, '
      'completionTokens: $completionTokens, '
      'totalTokens: $totalTokens, '
      'promptAudioSeconds: $promptAudioSeconds, '
      'numCachedTokens: $numCachedTokens, '
      'promptTokensDetails: $promptTokensDetails, '
      'promptTokenDetails: $promptTokenDetails, '
      'completionTokensDetails: $completionTokensDetails, '
      'serviceTier: $serviceTier, connectorTokens: $connectorTokens, '
      'connectors: $connectors)';
}
