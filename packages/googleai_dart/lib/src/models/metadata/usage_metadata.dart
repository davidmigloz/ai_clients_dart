import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../common/service_tier.dart';
import '../copy_with_sentinel.dart';
import 'modality_token_count.dart';

/// Token usage metadata for the request/response.
@immutable
class UsageMetadata {
  /// Number of tokens in the prompt.
  ///
  /// When `cachedContent` is set, this is still the total effective prompt
  /// size meaning it includes the number of tokens in the cached content.
  final int? promptTokenCount;

  /// Total number of tokens across all generated response candidates.
  final int? candidatesTokenCount;

  /// Total token count for the generation request
  /// (prompt + thoughts + response candidates).
  final int? totalTokenCount;

  /// Number of tokens in the cached part of the prompt (the cached content).
  final int? cachedContentTokenCount;

  /// Output only. Number of tokens of thoughts for thinking models.
  ///
  /// May be `null` for models that do not produce thoughts.
  final int? thoughtsTokenCount;

  /// Output only. Number of tokens present in tool-use prompt(s).
  ///
  /// May be `null` when no tool-use prompt was processed.
  final int? toolUsePromptTokenCount;

  /// Output only. List of modalities of the cached content in the request
  /// input.
  ///
  /// May be `null` when no cached content was supplied.
  final List<ModalityTokenCount>? cacheTokensDetails;

  /// Output only. List of modalities that were returned in the response.
  ///
  /// May be `null` when no candidates were returned.
  final List<ModalityTokenCount>? candidatesTokensDetails;

  /// Output only. List of modalities that were processed in the request input.
  ///
  /// May be `null` when no prompt modality breakdown is available.
  final List<ModalityTokenCount>? promptTokensDetails;

  /// Output only. List of modalities that were processed for tool-use request
  /// inputs.
  ///
  /// May be `null` when no tool-use breakdown is available.
  final List<ModalityTokenCount>? toolUsePromptTokensDetails;

  /// Output only. Service tier of the request.
  ///
  /// May be `null` when the API did not report a service tier.
  final ServiceTier? serviceTier;

  /// Creates a [UsageMetadata].
  const UsageMetadata({
    this.promptTokenCount,
    this.candidatesTokenCount,
    this.totalTokenCount,
    this.cachedContentTokenCount,
    this.thoughtsTokenCount,
    this.toolUsePromptTokenCount,
    this.cacheTokensDetails,
    this.candidatesTokensDetails,
    this.promptTokensDetails,
    this.toolUsePromptTokensDetails,
    this.serviceTier,
  });

  /// Creates a [UsageMetadata] from JSON.
  factory UsageMetadata.fromJson(Map<String, dynamic> json) => UsageMetadata(
    promptTokenCount: json['promptTokenCount'] as int?,
    candidatesTokenCount: json['candidatesTokenCount'] as int?,
    totalTokenCount: json['totalTokenCount'] as int?,
    cachedContentTokenCount: json['cachedContentTokenCount'] as int?,
    thoughtsTokenCount: json['thoughtsTokenCount'] as int?,
    toolUsePromptTokenCount: json['toolUsePromptTokenCount'] as int?,
    cacheTokensDetails: (json['cacheTokensDetails'] as List?)
        ?.map((e) => ModalityTokenCount.fromJson(e as Map<String, dynamic>))
        .toList(),
    candidatesTokensDetails: (json['candidatesTokensDetails'] as List?)
        ?.map((e) => ModalityTokenCount.fromJson(e as Map<String, dynamic>))
        .toList(),
    promptTokensDetails: (json['promptTokensDetails'] as List?)
        ?.map((e) => ModalityTokenCount.fromJson(e as Map<String, dynamic>))
        .toList(),
    toolUsePromptTokensDetails: (json['toolUsePromptTokensDetails'] as List?)
        ?.map((e) => ModalityTokenCount.fromJson(e as Map<String, dynamic>))
        .toList(),
    serviceTier: json['serviceTier'] != null
        ? serviceTierFromString(json['serviceTier'] as String?)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (promptTokenCount != null) 'promptTokenCount': promptTokenCount,
    if (candidatesTokenCount != null)
      'candidatesTokenCount': candidatesTokenCount,
    if (totalTokenCount != null) 'totalTokenCount': totalTokenCount,
    if (cachedContentTokenCount != null)
      'cachedContentTokenCount': cachedContentTokenCount,
    if (thoughtsTokenCount != null) 'thoughtsTokenCount': thoughtsTokenCount,
    if (toolUsePromptTokenCount != null)
      'toolUsePromptTokenCount': toolUsePromptTokenCount,
    if (cacheTokensDetails != null)
      'cacheTokensDetails': cacheTokensDetails!.map((e) => e.toJson()).toList(),
    if (candidatesTokensDetails != null)
      'candidatesTokensDetails': candidatesTokensDetails!
          .map((e) => e.toJson())
          .toList(),
    if (promptTokensDetails != null)
      'promptTokensDetails': promptTokensDetails!
          .map((e) => e.toJson())
          .toList(),
    if (toolUsePromptTokensDetails != null)
      'toolUsePromptTokensDetails': toolUsePromptTokensDetails!
          .map((e) => e.toJson())
          .toList(),
    if (serviceTier != null && serviceTier != ServiceTier.unspecified)
      'serviceTier': serviceTierToString(serviceTier!),
  };

  /// Creates a copy with replaced values.
  UsageMetadata copyWith({
    Object? promptTokenCount = unsetCopyWithValue,
    Object? candidatesTokenCount = unsetCopyWithValue,
    Object? totalTokenCount = unsetCopyWithValue,
    Object? cachedContentTokenCount = unsetCopyWithValue,
    Object? thoughtsTokenCount = unsetCopyWithValue,
    Object? toolUsePromptTokenCount = unsetCopyWithValue,
    Object? cacheTokensDetails = unsetCopyWithValue,
    Object? candidatesTokensDetails = unsetCopyWithValue,
    Object? promptTokensDetails = unsetCopyWithValue,
    Object? toolUsePromptTokensDetails = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
  }) {
    return UsageMetadata(
      promptTokenCount: promptTokenCount == unsetCopyWithValue
          ? this.promptTokenCount
          : promptTokenCount as int?,
      candidatesTokenCount: candidatesTokenCount == unsetCopyWithValue
          ? this.candidatesTokenCount
          : candidatesTokenCount as int?,
      totalTokenCount: totalTokenCount == unsetCopyWithValue
          ? this.totalTokenCount
          : totalTokenCount as int?,
      cachedContentTokenCount: cachedContentTokenCount == unsetCopyWithValue
          ? this.cachedContentTokenCount
          : cachedContentTokenCount as int?,
      thoughtsTokenCount: thoughtsTokenCount == unsetCopyWithValue
          ? this.thoughtsTokenCount
          : thoughtsTokenCount as int?,
      toolUsePromptTokenCount: toolUsePromptTokenCount == unsetCopyWithValue
          ? this.toolUsePromptTokenCount
          : toolUsePromptTokenCount as int?,
      cacheTokensDetails: cacheTokensDetails == unsetCopyWithValue
          ? this.cacheTokensDetails
          : cacheTokensDetails as List<ModalityTokenCount>?,
      candidatesTokensDetails: candidatesTokensDetails == unsetCopyWithValue
          ? this.candidatesTokensDetails
          : candidatesTokensDetails as List<ModalityTokenCount>?,
      promptTokensDetails: promptTokensDetails == unsetCopyWithValue
          ? this.promptTokensDetails
          : promptTokensDetails as List<ModalityTokenCount>?,
      toolUsePromptTokensDetails:
          toolUsePromptTokensDetails == unsetCopyWithValue
          ? this.toolUsePromptTokensDetails
          : toolUsePromptTokensDetails as List<ModalityTokenCount>?,
      serviceTier: serviceTier == unsetCopyWithValue
          ? this.serviceTier
          : serviceTier as ServiceTier?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    const listEq = ListEquality<ModalityTokenCount>();
    return other is UsageMetadata &&
        other.promptTokenCount == promptTokenCount &&
        other.candidatesTokenCount == candidatesTokenCount &&
        other.totalTokenCount == totalTokenCount &&
        other.cachedContentTokenCount == cachedContentTokenCount &&
        other.thoughtsTokenCount == thoughtsTokenCount &&
        other.toolUsePromptTokenCount == toolUsePromptTokenCount &&
        listEq.equals(other.cacheTokensDetails, cacheTokensDetails) &&
        listEq.equals(other.candidatesTokensDetails, candidatesTokensDetails) &&
        listEq.equals(other.promptTokensDetails, promptTokensDetails) &&
        listEq.equals(
          other.toolUsePromptTokensDetails,
          toolUsePromptTokensDetails,
        ) &&
        other.serviceTier == serviceTier;
  }

  @override
  int get hashCode {
    const listEq = ListEquality<ModalityTokenCount>();
    return Object.hash(
      promptTokenCount,
      candidatesTokenCount,
      totalTokenCount,
      cachedContentTokenCount,
      thoughtsTokenCount,
      toolUsePromptTokenCount,
      listEq.hash(cacheTokensDetails),
      listEq.hash(candidatesTokensDetails),
      listEq.hash(promptTokensDetails),
      listEq.hash(toolUsePromptTokensDetails),
      serviceTier,
    );
  }

  @override
  String toString() =>
      'UsageMetadata('
      'promptTokenCount: $promptTokenCount, '
      'candidatesTokenCount: $candidatesTokenCount, '
      'totalTokenCount: $totalTokenCount, '
      'cachedContentTokenCount: $cachedContentTokenCount, '
      'thoughtsTokenCount: $thoughtsTokenCount, '
      'toolUsePromptTokenCount: $toolUsePromptTokenCount, '
      'cacheTokensDetails: ${_summarize(cacheTokensDetails)}, '
      'candidatesTokensDetails: ${_summarize(candidatesTokensDetails)}, '
      'promptTokensDetails: ${_summarize(promptTokensDetails)}, '
      'toolUsePromptTokensDetails: ${_summarize(toolUsePromptTokensDetails)}, '
      'serviceTier: $serviceTier)';
}

String _summarize(List<Object?>? list) =>
    list == null ? 'null' : '${list.length} items';
