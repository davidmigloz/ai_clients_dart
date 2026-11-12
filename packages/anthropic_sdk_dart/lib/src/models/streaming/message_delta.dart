import 'package:meta/meta.dart';

import '../beta/config/container.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../metadata/fallback_credit_usage.dart';
import '../metadata/speed.dart';
import '../metadata/stop_reason.dart';
import '../metadata/usage.dart';

/// Delta update for message properties during streaming.
@immutable
class MessageDelta {
  /// Container metadata when server-side code execution was used.
  final Container? container;

  /// The stop reason if the message has finished.
  final StopReason? stopReason;

  /// Whether the delta specifies a stop reason, including an explicit null.
  final bool hasStopReason;

  final String? _rawStopReason;

  /// The original provider stop reason, including an unfamiliar value.
  String? get stopReasonValue => _rawStopReason ?? stopReason?.value;

  /// Structured information about why model output stopped.
  ///
  /// This is non-null when [stopReason] is [StopReason.refusal].
  final RefusalStopDetails? stopDetails;

  /// Whether the delta specifies stop details, including an explicit null.
  final bool hasStopDetails;

  /// The stop sequence that caused the stop, if applicable.
  final String? stopSequence;

  /// Whether the delta specifies a stop sequence, including an explicit null.
  final bool hasStopSequence;

  /// Creates a [MessageDelta].
  ///
  /// Pass a stop field to set it. Pass its presence flag with a null value to
  /// clear it.
  const MessageDelta({
    this.container,
    this.stopReason,
    bool hasStopReason = false,
    this.stopDetails,
    bool hasStopDetails = false,
    this.stopSequence,
    bool hasStopSequence = false,
  }) : hasStopReason = hasStopReason || stopReason != null,
       hasStopDetails = hasStopDetails || stopDetails != null,
       hasStopSequence = hasStopSequence || stopSequence != null,
       _rawStopReason = null;

  const MessageDelta._({
    this.container,
    this.stopReason,
    required this.hasStopReason,
    String? stopReasonValue,
    this.stopDetails,
    required this.hasStopDetails,
    this.stopSequence,
    required this.hasStopSequence,
  }) : _rawStopReason = stopReason == StopReason.unknown
           ? stopReasonValue
           : null;

  /// Creates a [MessageDelta] from JSON.
  factory MessageDelta.fromJson(Map<String, dynamic> json) {
    final stopReasonValue = json['stop_reason'] as String?;
    return MessageDelta._(
      container: json['container'] != null
          ? Container.fromJson(json['container'] as Map<String, dynamic>)
          : null,
      stopReason: stopReasonValue == null
          ? null
          : StopReason.fromJson(stopReasonValue),
      hasStopReason: json.containsKey('stop_reason'),
      stopReasonValue: stopReasonValue,
      stopDetails: json['stop_details'] != null
          ? RefusalStopDetails.fromJson(
              json['stop_details'] as Map<String, dynamic>,
            )
          : null,
      hasStopDetails: json.containsKey('stop_details'),
      stopSequence: json['stop_sequence'] as String?,
      hasStopSequence: json.containsKey('stop_sequence'),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (container != null) 'container': container!.toJson(),
    if (hasStopReason) 'stop_reason': stopReasonValue,
    if (hasStopDetails) 'stop_details': stopDetails?.toJson(),
    if (hasStopSequence) 'stop_sequence': stopSequence,
  };

  /// Creates a copy with replaced values.
  MessageDelta copyWith({
    Object? container = unsetCopyWithValue,
    Object? stopReason = unsetCopyWithValue,
    Object? stopDetails = unsetCopyWithValue,
    Object? stopSequence = unsetCopyWithValue,
  }) {
    final replaceStopReason = !identical(stopReason, unsetCopyWithValue);
    final replaceStopDetails = !identical(stopDetails, unsetCopyWithValue);
    final replaceStopSequence = !identical(stopSequence, unsetCopyWithValue);
    return MessageDelta._(
      container: container == unsetCopyWithValue
          ? this.container
          : container as Container?,
      stopReason: replaceStopReason
          ? stopReason as StopReason?
          : this.stopReason,
      hasStopReason: replaceStopReason || hasStopReason,
      stopReasonValue: replaceStopReason ? null : _rawStopReason,
      stopDetails: replaceStopDetails
          ? stopDetails as RefusalStopDetails?
          : this.stopDetails,
      hasStopDetails: replaceStopDetails || hasStopDetails,
      stopSequence: replaceStopSequence
          ? stopSequence as String?
          : this.stopSequence,
      hasStopSequence: replaceStopSequence || hasStopSequence,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageDelta &&
          runtimeType == other.runtimeType &&
          container == other.container &&
          hasStopReason == other.hasStopReason &&
          stopReason == other.stopReason &&
          stopReasonValue == other.stopReasonValue &&
          hasStopDetails == other.hasStopDetails &&
          stopDetails == other.stopDetails &&
          hasStopSequence == other.hasStopSequence &&
          stopSequence == other.stopSequence;

  @override
  int get hashCode => Object.hash(
    container,
    stopReason,
    hasStopReason,
    stopReasonValue,
    stopDetails,
    hasStopDetails,
    stopSequence,
    hasStopSequence,
  );

  @override
  String toString() =>
      'MessageDelta(container: $container, stopReason: $stopReasonValue, '
      'stopDetails: $stopDetails, stopSequence: $stopSequence)';
}

/// Usage information in delta events.
@immutable
class MessageDeltaUsage {
  /// The cumulative number of output tokens generated so far.
  final int outputTokens;

  /// Breakdown of output tokens by category (e.g., reasoning tokens).
  final OutputTokensDetails? outputTokensDetails;

  /// The cumulative number of input tokens used.
  final int? inputTokens;

  /// Cumulative cache creation input token count.
  final int? cacheCreationInputTokens;

  /// Cumulative cache read input token count.
  final int? cacheReadInputTokens;

  /// Server tool usage metrics.
  final ServerToolUsage? serverToolUse;

  /// Iteration usage metrics (beta / compaction-related).
  final List<IterationUsage>? iterations;

  /// Speed mode used for this response (beta).
  final Speed? speed;

  /// Outcome of the `fallback_credit_token` presented on this request.
  ///
  /// Present on every response to a non-batch request that carried a
  /// `fallback_credit_token`, in either redemption mode; absent otherwise
  /// (batch items accept and ignore the token and carry no outcome object).
  final FallbackCreditUsage? fallbackCredit;

  /// Creates a [MessageDeltaUsage].
  const MessageDeltaUsage({
    required this.outputTokens,
    this.outputTokensDetails,
    this.inputTokens,
    this.cacheCreationInputTokens,
    this.cacheReadInputTokens,
    this.serverToolUse,
    this.iterations,
    this.speed,
    this.fallbackCredit,
  });

  /// Creates a [MessageDeltaUsage] from JSON.
  factory MessageDeltaUsage.fromJson(Map<String, dynamic> json) {
    return MessageDeltaUsage(
      outputTokens: json['output_tokens'] as int,
      outputTokensDetails: json['output_tokens_details'] != null
          ? OutputTokensDetails.fromJson(
              json['output_tokens_details'] as Map<String, dynamic>,
            )
          : null,
      inputTokens: json['input_tokens'] as int?,
      cacheCreationInputTokens: json['cache_creation_input_tokens'] as int?,
      cacheReadInputTokens: json['cache_read_input_tokens'] as int?,
      serverToolUse: json['server_tool_use'] != null
          ? ServerToolUsage.fromJson(
              json['server_tool_use'] as Map<String, dynamic>,
            )
          : null,
      iterations: json['iterations'] != null
          ? (json['iterations'] as List)
                .map((e) => IterationUsage.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
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
    'output_tokens': outputTokens,
    if (outputTokensDetails != null)
      'output_tokens_details': outputTokensDetails!.toJson(),
    if (inputTokens != null) 'input_tokens': inputTokens,
    if (cacheCreationInputTokens != null)
      'cache_creation_input_tokens': cacheCreationInputTokens,
    if (cacheReadInputTokens != null)
      'cache_read_input_tokens': cacheReadInputTokens,
    if (serverToolUse != null) 'server_tool_use': serverToolUse!.toJson(),
    if (iterations != null)
      'iterations': iterations!.map((e) => e.toJson()).toList(),
    if (speed != null) 'speed': speed!.toJson(),
    if (fallbackCredit != null) 'fallback_credit': fallbackCredit!.toJson(),
  };

  /// Creates a copy with replaced values.
  MessageDeltaUsage copyWith({
    int? outputTokens,
    Object? outputTokensDetails = unsetCopyWithValue,
    Object? inputTokens = unsetCopyWithValue,
    Object? cacheCreationInputTokens = unsetCopyWithValue,
    Object? cacheReadInputTokens = unsetCopyWithValue,
    Object? serverToolUse = unsetCopyWithValue,
    Object? iterations = unsetCopyWithValue,
    Object? speed = unsetCopyWithValue,
    Object? fallbackCredit = unsetCopyWithValue,
  }) {
    return MessageDeltaUsage(
      outputTokens: outputTokens ?? this.outputTokens,
      outputTokensDetails: outputTokensDetails == unsetCopyWithValue
          ? this.outputTokensDetails
          : outputTokensDetails as OutputTokensDetails?,
      inputTokens: inputTokens == unsetCopyWithValue
          ? this.inputTokens
          : inputTokens as int?,
      cacheCreationInputTokens: cacheCreationInputTokens == unsetCopyWithValue
          ? this.cacheCreationInputTokens
          : cacheCreationInputTokens as int?,
      cacheReadInputTokens: cacheReadInputTokens == unsetCopyWithValue
          ? this.cacheReadInputTokens
          : cacheReadInputTokens as int?,
      serverToolUse: serverToolUse == unsetCopyWithValue
          ? this.serverToolUse
          : serverToolUse as ServerToolUsage?,
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
      other is MessageDeltaUsage &&
          runtimeType == other.runtimeType &&
          outputTokens == other.outputTokens &&
          outputTokensDetails == other.outputTokensDetails &&
          inputTokens == other.inputTokens &&
          cacheCreationInputTokens == other.cacheCreationInputTokens &&
          cacheReadInputTokens == other.cacheReadInputTokens &&
          serverToolUse == other.serverToolUse &&
          listsEqual(iterations, other.iterations) &&
          speed == other.speed &&
          fallbackCredit == other.fallbackCredit;

  @override
  int get hashCode => Object.hash(
    outputTokens,
    outputTokensDetails,
    inputTokens,
    cacheCreationInputTokens,
    cacheReadInputTokens,
    serverToolUse,
    listHash(iterations),
    speed,
    fallbackCredit,
  );

  @override
  String toString() =>
      'MessageDeltaUsage(outputTokens: $outputTokens, '
      'outputTokensDetails: $outputTokensDetails, inputTokens: $inputTokens, '
      'cacheCreationInputTokens: $cacheCreationInputTokens, '
      'cacheReadInputTokens: $cacheReadInputTokens, '
      'serverToolUse: $serverToolUse, iterations: $iterations, speed: $speed, '
      'fallbackCredit: $fallbackCredit)';
}
