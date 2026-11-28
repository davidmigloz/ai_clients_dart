import '../../../content/content.dart';
import '../../../metadata/grounding_metadata.dart';
import '../../../metadata/usage_metadata.dart';
import '../../../tools/function_call.dart';
import '../../config/transcription.dart';
import 'live_usage_metadata.dart';
import 'live_voice_activity.dart';

/// Base class for server-to-client WebSocket messages.
///
/// Each message type has a specific wrapper key in the JSON:
/// - `setupComplete` for [BidiGenerateContentSetupComplete]
/// - `serverContent` for [BidiGenerateContentServerContent]
/// - `toolCall` for [BidiGenerateContentToolCall]
/// - `toolCallCancellation` for [BidiGenerateContentToolCallCancellation]
/// - `goAway` for [GoAway]
/// - `sessionResumptionUpdate` for [SessionResumptionUpdate]
///
/// Frames without a recognized wrapper use [UnknownServerMessage]. This
/// includes frames that carry only [responseUsageMetadata] or [voiceActivity].
sealed class BidiGenerateContentServerMessage {
  /// Usage reported alongside the message payload at the top level.
  ///
  /// The server can send this by itself or together with a typed message.
  final LiveUsageMetadata? responseUsageMetadata;

  /// Voice activity reported at the top level of this frame.
  final LiveVoiceActivity? voiceActivity;

  /// Creates a message.
  const BidiGenerateContentServerMessage({
    this.responseUsageMetadata,
    this.voiceActivity,
  });

  /// Creates a message from JSON.
  ///
  /// Dispatches to the appropriate subclass based on the JSON key.
  factory BidiGenerateContentServerMessage.fromJson(Map<String, dynamic> json) {
    final responseUsageMetadata = switch (json['usageMetadata']) {
      final Map<String, dynamic> usage => LiveUsageMetadata.fromJson(usage),
      _ => null,
    };
    final voiceActivity = switch (json['voiceActivity']) {
      final Map<String, dynamic> activity => LiveVoiceActivity.fromJson(
        activity,
      ),
      _ => null,
    };
    if (json.containsKey('setupComplete')) {
      return BidiGenerateContentSetupComplete.fromJson(
        json['setupComplete'] as Map<String, dynamic>,
        responseUsageMetadata: responseUsageMetadata,
        voiceActivity: voiceActivity,
      );
    }
    if (json.containsKey('serverContent')) {
      return BidiGenerateContentServerContent.fromJson(
        json['serverContent'] as Map<String, dynamic>,
        responseUsageMetadata: responseUsageMetadata,
        voiceActivity: voiceActivity,
      );
    }
    if (json.containsKey('toolCall')) {
      return BidiGenerateContentToolCall.fromJson(
        json['toolCall'] as Map<String, dynamic>,
        responseUsageMetadata: responseUsageMetadata,
        voiceActivity: voiceActivity,
      );
    }
    if (json.containsKey('toolCallCancellation')) {
      return BidiGenerateContentToolCallCancellation.fromJson(
        json['toolCallCancellation'] as Map<String, dynamic>,
        responseUsageMetadata: responseUsageMetadata,
        voiceActivity: voiceActivity,
      );
    }
    if (json.containsKey('goAway')) {
      return GoAway.fromJson(
        json['goAway'] as Map<String, dynamic>,
        responseUsageMetadata: responseUsageMetadata,
        voiceActivity: voiceActivity,
      );
    }
    if (json.containsKey('sessionResumptionUpdate')) {
      return SessionResumptionUpdate.fromJson(
        json['sessionResumptionUpdate'] as Map<String, dynamic>,
        responseUsageMetadata: responseUsageMetadata,
        voiceActivity: voiceActivity,
      );
    }
    // Return unknown message type instead of throwing to handle
    // future API additions gracefully
    return UnknownServerMessage(
      json,
      responseUsageMetadata: responseUsageMetadata,
      voiceActivity: voiceActivity,
    );
  }

  Map<String, dynamic> get _ancillaryJson => {
    if (responseUsageMetadata != null)
      'usageMetadata': responseUsageMetadata!.toJson(),
    if (voiceActivity != null) 'voiceActivity': voiceActivity!.toJson(),
  };

  /// Converts to JSON with the message type wrapper key.
  Map<String, dynamic> toJson();
}

/// Session setup complete message.
///
/// Sent by the server after receiving [BidiGenerateContentSetup] and
/// successfully initializing the session.
class BidiGenerateContentSetupComplete
    extends BidiGenerateContentServerMessage {
  /// The session ID.
  final String? sessionId;

  /// Creates a [BidiGenerateContentSetupComplete].
  const BidiGenerateContentSetupComplete({
    this.sessionId,
    super.responseUsageMetadata,
    super.voiceActivity,
  });

  /// Creates from JSON.
  factory BidiGenerateContentSetupComplete.fromJson(
    Map<String, dynamic> json, {
    LiveUsageMetadata? responseUsageMetadata,
    LiveVoiceActivity? voiceActivity,
  }) {
    return BidiGenerateContentSetupComplete(
      sessionId: json['sessionId'] as String?,
      responseUsageMetadata: responseUsageMetadata,
      voiceActivity: voiceActivity,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'setupComplete': {if (sessionId != null) 'sessionId': sessionId},
    ..._ancillaryJson,
  };

  @override
  String toString() =>
      'BidiGenerateContentSetupComplete(sessionId: $sessionId)';
}

/// Server content message containing model output.
///
/// This is the main response message containing the model's generated content.
class BidiGenerateContentServerContent
    extends BidiGenerateContentServerMessage {
  /// The model's generated content for this turn.
  final Content? modelTurn;

  /// Whether the model's turn is complete.
  ///
  /// When `true`, the model has finished generating for this turn.
  final bool? turnComplete;

  /// Whether generation is fully complete.
  ///
  /// When `true`, no more content will be generated for this request.
  final bool? generationComplete;

  /// Whether the model was interrupted.
  ///
  /// `true` if user activity interrupted the model's output.
  final bool? interrupted;

  /// Transcription of the user's input audio.
  ///
  /// Only present if `inputAudioTranscription` was enabled in setup.
  final Transcription? inputTranscription;

  /// A provisional input transcript while the user is speaking.
  ///
  /// It can change as more audio arrives. Read [inputTranscription] for
  /// the authoritative result.
  final Transcription? interimInputTranscription;

  /// Transcription of the model's output audio.
  ///
  /// Only present if `outputAudioTranscription` was enabled in setup.
  final Transcription? outputTranscription;

  /// Grounding metadata for the response.
  final GroundingMetadata? groundingMetadata;

  /// Token usage nested inside the content in earlier API responses.
  ///
  /// For usage accompanying a current Live message, see [responseUsageMetadata].
  final UsageMetadata? usageMetadata;

  /// The model expects additional input before generating more content.
  final bool? waitingForInput;

  /// The server-reported reason the turn ended, when supplied.
  ///
  /// This is the raw wire string, such as `NEED_MORE_INPUT`.
  final String? turnCompleteReason;

  /// The server's activity status accompanying a completed turn.
  ///
  /// This is the raw wire string, such as `IN_PROGRESS` or `IDLE`.
  final String? interactionStatus;

  /// A change in server-side speech detection reported by Vertex AI.
  ///
  /// Examples include `SPEECH` and `NON_SPEECH`.
  final String? speechState;

  /// URL retrieval metadata, when the model reports it.
  final Map<String, dynamic>? urlContextMetadata;

  /// Creates a [BidiGenerateContentServerContent].
  const BidiGenerateContentServerContent({
    this.modelTurn,
    this.turnComplete,
    this.generationComplete,
    this.interrupted,
    this.inputTranscription,
    this.interimInputTranscription,
    this.outputTranscription,
    this.groundingMetadata,
    this.usageMetadata,
    this.waitingForInput,
    this.turnCompleteReason,
    this.interactionStatus,
    this.speechState,
    this.urlContextMetadata,
    super.responseUsageMetadata,
    super.voiceActivity,
  });

  /// Creates from JSON.
  factory BidiGenerateContentServerContent.fromJson(
    Map<String, dynamic> json, {
    LiveUsageMetadata? responseUsageMetadata,
    LiveVoiceActivity? voiceActivity,
  }) {
    return BidiGenerateContentServerContent(
      modelTurn: json['modelTurn'] != null
          ? Content.fromJson(json['modelTurn'] as Map<String, dynamic>)
          : null,
      turnComplete: json['turnComplete'] as bool?,
      generationComplete: json['generationComplete'] as bool?,
      interrupted: json['interrupted'] as bool?,
      inputTranscription: json['inputTranscription'] != null
          ? Transcription.fromJson(
              json['inputTranscription'] as Map<String, dynamic>,
            )
          : null,
      interimInputTranscription: json['interimInputTranscription'] != null
          ? Transcription.fromJson(
              json['interimInputTranscription'] as Map<String, dynamic>,
            )
          : null,
      outputTranscription: json['outputTranscription'] != null
          ? Transcription.fromJson(
              json['outputTranscription'] as Map<String, dynamic>,
            )
          : null,
      groundingMetadata: json['groundingMetadata'] != null
          ? GroundingMetadata.fromJson(
              json['groundingMetadata'] as Map<String, dynamic>,
            )
          : null,
      usageMetadata: json['usageMetadata'] != null
          ? UsageMetadata.fromJson(
              json['usageMetadata'] as Map<String, dynamic>,
            )
          : null,
      waitingForInput: json['waitingForInput'] as bool?,
      turnCompleteReason: json['turnCompleteReason'] as String?,
      interactionStatus: json['interactionStatus'] as String?,
      speechState: json['speechState'] as String?,
      urlContextMetadata: json['urlContextMetadata'] as Map<String, dynamic>?,
      responseUsageMetadata: responseUsageMetadata,
      voiceActivity: voiceActivity,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'serverContent': {
      if (modelTurn != null) 'modelTurn': modelTurn!.toJson(),
      if (turnComplete != null) 'turnComplete': turnComplete,
      if (generationComplete != null) 'generationComplete': generationComplete,
      if (interrupted != null) 'interrupted': interrupted,
      if (inputTranscription != null)
        'inputTranscription': inputTranscription!.toJson(),
      if (interimInputTranscription != null)
        'interimInputTranscription': interimInputTranscription!.toJson(),
      if (outputTranscription != null)
        'outputTranscription': outputTranscription!.toJson(),
      if (groundingMetadata != null)
        'groundingMetadata': groundingMetadata!.toJson(),
      if (usageMetadata != null) 'usageMetadata': usageMetadata!.toJson(),
      if (waitingForInput != null) 'waitingForInput': waitingForInput,
      if (turnCompleteReason != null) 'turnCompleteReason': turnCompleteReason,
      if (interactionStatus != null) 'interactionStatus': interactionStatus,
      if (speechState != null) 'speechState': speechState,
      if (urlContextMetadata != null) 'urlContextMetadata': urlContextMetadata,
    },
    ..._ancillaryJson,
  };

  @override
  String toString() =>
      'BidiGenerateContentServerContent(turnComplete: $turnComplete, '
      'generationComplete: $generationComplete, interrupted: $interrupted, '
      'hasInterimInputTranscription: ${interimInputTranscription != null}, '
      'waitingForInput: $waitingForInput, turnCompleteReason: $turnCompleteReason, '
      'interactionStatus: $interactionStatus, speechState: $speechState, '
      'hasUrlContextMetadata: ${urlContextMetadata != null})';
}

/// Tool call request message.
///
/// Sent when the model wants to execute one or more tools.
/// Respond with [BidiGenerateContentToolResponse].
class BidiGenerateContentToolCall extends BidiGenerateContentServerMessage {
  /// The function calls to execute.
  final List<FunctionCall> functionCalls;

  /// Creates a [BidiGenerateContentToolCall].
  const BidiGenerateContentToolCall({
    required this.functionCalls,
    super.responseUsageMetadata,
    super.voiceActivity,
  });

  /// Creates from JSON.
  factory BidiGenerateContentToolCall.fromJson(
    Map<String, dynamic> json, {
    LiveUsageMetadata? responseUsageMetadata,
    LiveVoiceActivity? voiceActivity,
  }) {
    return BidiGenerateContentToolCall(
      functionCalls: (json['functionCalls'] as List<dynamic>)
          .map((e) => FunctionCall.fromJson(e as Map<String, dynamic>))
          .toList(),
      responseUsageMetadata: responseUsageMetadata,
      voiceActivity: voiceActivity,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'toolCall': {
      'functionCalls': functionCalls.map((e) => e.toJson()).toList(),
    },
    ..._ancillaryJson,
  };

  @override
  String toString() =>
      'BidiGenerateContentToolCall(functionCalls: ${functionCalls.length})';
}

/// Tool call cancellation message.
///
/// Sent when the model no longer needs the results of pending tool calls,
/// typically due to user interruption.
class BidiGenerateContentToolCallCancellation
    extends BidiGenerateContentServerMessage {
  /// The IDs of tool calls to cancel.
  final List<String> ids;

  /// Creates a [BidiGenerateContentToolCallCancellation].
  const BidiGenerateContentToolCallCancellation({
    required this.ids,
    super.responseUsageMetadata,
    super.voiceActivity,
  });

  /// Creates from JSON.
  factory BidiGenerateContentToolCallCancellation.fromJson(
    Map<String, dynamic> json, {
    LiveUsageMetadata? responseUsageMetadata,
    LiveVoiceActivity? voiceActivity,
  }) {
    return BidiGenerateContentToolCallCancellation(
      ids: (json['ids'] as List<dynamic>).cast<String>(),
      responseUsageMetadata: responseUsageMetadata,
      voiceActivity: voiceActivity,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'toolCallCancellation': {'ids': ids},
    ..._ancillaryJson,
  };

  @override
  String toString() => 'BidiGenerateContentToolCallCancellation(ids: $ids)';
}

/// Go away message indicating session is ending.
///
/// Sent by the server before the session ends, giving the client
/// time to save state or reconnect with a resumption token.
class GoAway extends BidiGenerateContentServerMessage {
  /// Time remaining before the session ends.
  ///
  /// Format: ISO 8601 duration (e.g., "PT30S" for 30 seconds).
  final String? timeLeft;

  /// Creates a [GoAway].
  const GoAway({
    this.timeLeft,
    super.responseUsageMetadata,
    super.voiceActivity,
  });

  /// Creates from JSON.
  factory GoAway.fromJson(
    Map<String, dynamic> json, {
    LiveUsageMetadata? responseUsageMetadata,
    LiveVoiceActivity? voiceActivity,
  }) {
    return GoAway(
      timeLeft: json['timeLeft'] as String?,
      responseUsageMetadata: responseUsageMetadata,
      voiceActivity: voiceActivity,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'goAway': {if (timeLeft != null) 'timeLeft': timeLeft},
    ..._ancillaryJson,
  };

  @override
  String toString() => 'GoAway(timeLeft: $timeLeft)';
}

/// Session resumption update message.
///
/// Contains a token that can be used to resume the session later.
class SessionResumptionUpdate extends BidiGenerateContentServerMessage {
  /// The new resumption handle/token.
  ///
  /// Store this and include it in [SessionResumptionConfig.handle] when
  /// reconnecting to resume the session.
  final String? newHandle;

  /// Whether the session can be resumed.
  final bool? resumable;

  /// Last client message included in the resumable state, when supplied.
  ///
  /// Vertex AI transparent resumption reports this as a protobuf int64
  /// string. Keep it as a string or parse it with [BigInt.parse].
  final String? lastConsumedClientMessageIndex;

  /// Creates a [SessionResumptionUpdate].
  const SessionResumptionUpdate({
    this.newHandle,
    this.resumable,
    this.lastConsumedClientMessageIndex,
    super.responseUsageMetadata,
    super.voiceActivity,
  });

  /// Creates from JSON.
  factory SessionResumptionUpdate.fromJson(
    Map<String, dynamic> json, {
    LiveUsageMetadata? responseUsageMetadata,
    LiveVoiceActivity? voiceActivity,
  }) {
    return SessionResumptionUpdate(
      newHandle: json['newHandle'] as String?,
      resumable: json['resumable'] as bool?,
      lastConsumedClientMessageIndex:
          switch (json['lastConsumedClientMessageIndex']) {
            final String index => index,
            final int index => index.toString(),
            null => null,
            _ => throw const FormatException(
              'Invalid Live resumption message index.',
            ),
          },
      responseUsageMetadata: responseUsageMetadata,
      voiceActivity: voiceActivity,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'sessionResumptionUpdate': {
      if (newHandle != null) 'newHandle': newHandle,
      if (resumable != null) 'resumable': resumable,
      if (lastConsumedClientMessageIndex != null)
        'lastConsumedClientMessageIndex': lastConsumedClientMessageIndex,
    },
    ..._ancillaryJson,
  };

  @override
  String toString() =>
      'SessionResumptionUpdate(newHandle: ${newHandle != null ? "..." : null}, '
      'resumable: $resumable, '
      'lastConsumedClientMessageIndex: $lastConsumedClientMessageIndex)';
}

/// Unknown server message type.
///
/// This is returned when the server sends a message type that this client
/// version doesn't recognize. This allows graceful handling of future API
/// additions without crashing.
///
/// Applications can check for this type and handle it appropriately:
/// ```dart
/// final message = BidiGenerateContentServerMessage.fromJson(json);
/// if (message is UnknownServerMessage) {
///   // Log or ignore unrecognized message type
///   print('Unknown message: ${message.rawJson.keys}');
/// }
/// ```
class UnknownServerMessage extends BidiGenerateContentServerMessage {
  /// The raw JSON of the unrecognized message.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownServerMessage].
  const UnknownServerMessage(
    this.rawJson, {
    super.responseUsageMetadata,
    super.voiceActivity,
  });

  @override
  Map<String, dynamic> toJson() =>
      responseUsageMetadata == null && voiceActivity == null
      ? rawJson
      : {..._ancillaryJson, ...rawJson};

  @override
  String toString() => 'UnknownServerMessage(keys: ${rawJson.keys})';
}
