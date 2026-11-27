import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'audio_agent_config.dart';
import 'audio_agent_tools.dart';
import 'audio_session_transcript.dart';

/// Values for AudioSessionStatus.
enum AudioSessionStatus {
  /// Represents active.
  active('active'),

  /// Represents ended.
  ended('ended'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AudioSessionStatus(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AudioSessionStatus fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The AudioSessionCreateRequest wire payload.
@immutable
class CreateAudioSessionRequest {
  /// Creates a [CreateAudioSessionRequest].
  const CreateAudioSessionRequest({
    this.agentId,
    this.agentVersion,
    this.instructions,
    this.llm,
    this.stt,
    this.tools,
    this.tts,
    this.turn,
    this.welcomeMessage,
  });

  /// The agent_id field.
  final String? agentId;

  /// The agent_version field.
  final int? agentVersion;

  /// The instructions field.
  final String? instructions;

  /// The llm field.
  final AudioLlmConfig? llm;

  /// The stt field.
  final AudioSttConfig? stt;

  /// The tools field.
  final List<VoiceAgentTool>? tools;

  /// The tts field.
  final AudioTtsConfig? tts;

  /// The turn field.
  final AudioTurnConfig? turn;

  /// The welcome_message field.
  final String? welcomeMessage;

  /// Parses a [CreateAudioSessionRequest] from JSON.
  factory CreateAudioSessionRequest.fromJson(Map<String, dynamic> json) {
    return CreateAudioSessionRequest(
      agentId: json['agent_id'] == null ? null : json['agent_id'] as String,
      agentVersion: json['agent_version'] == null
          ? null
          : json['agent_version'] as int,
      instructions: json['instructions'] == null
          ? null
          : json['instructions'] as String,
      llm: json['llm'] == null
          ? null
          : AudioLlmConfig.fromJson(json['llm'] as Map<String, dynamic>),
      stt: json['stt'] == null
          ? null
          : AudioSttConfig.fromJson(json['stt'] as Map<String, dynamic>),
      tools: json['tools'] == null
          ? null
          : (json['tools'] as List)
                .map(
                  (item) =>
                      VoiceAgentTool.fromJson(item as Map<String, dynamic>),
                )
                .toList(),
      tts: json['tts'] == null
          ? null
          : AudioTtsConfig.fromJson(json['tts'] as Map<String, dynamic>),
      turn: json['turn'] == null
          ? null
          : AudioTurnConfig.fromJson(json['turn'] as Map<String, dynamic>),
      welcomeMessage: json['welcome_message'] == null
          ? null
          : json['welcome_message'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'agent_id': ?agentId,
    'agent_version': ?agentVersion,
    'instructions': ?instructions,
    if (llm != null) 'llm': llm!.toJson(),
    if (stt != null) 'stt': stt!.toJson(),
    if (tools != null) 'tools': tools!.map((item) => item.toJson()).toList(),
    if (tts != null) 'tts': tts!.toJson(),
    if (turn != null) 'turn': turn!.toJson(),
    'welcome_message': ?welcomeMessage,
  };

  /// Creates a copy with the given fields replaced.
  CreateAudioSessionRequest copyWith({
    Object? agentId = unsetCopyWithValue,
    Object? agentVersion = unsetCopyWithValue,
    Object? instructions = unsetCopyWithValue,
    Object? llm = unsetCopyWithValue,
    Object? stt = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? tts = unsetCopyWithValue,
    Object? turn = unsetCopyWithValue,
    Object? welcomeMessage = unsetCopyWithValue,
  }) => CreateAudioSessionRequest(
    agentId: agentId == unsetCopyWithValue ? this.agentId : agentId as String?,
    agentVersion: agentVersion == unsetCopyWithValue
        ? this.agentVersion
        : agentVersion as int?,
    instructions: instructions == unsetCopyWithValue
        ? this.instructions
        : instructions as String?,
    llm: llm == unsetCopyWithValue ? this.llm : llm as AudioLlmConfig?,
    stt: stt == unsetCopyWithValue ? this.stt : stt as AudioSttConfig?,
    tools: tools == unsetCopyWithValue
        ? this.tools
        : (tools as List?)?.cast<VoiceAgentTool>(),
    tts: tts == unsetCopyWithValue ? this.tts : tts as AudioTtsConfig?,
    turn: turn == unsetCopyWithValue ? this.turn : turn as AudioTurnConfig?,
    welcomeMessage: welcomeMessage == unsetCopyWithValue
        ? this.welcomeMessage
        : welcomeMessage as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateAudioSessionRequest &&
          runtimeType == other.runtimeType &&
          agentId == other.agentId &&
          agentVersion == other.agentVersion &&
          instructions == other.instructions &&
          llm == other.llm &&
          stt == other.stt &&
          valuesDeepEqual(tools, other.tools) &&
          tts == other.tts &&
          turn == other.turn &&
          welcomeMessage == other.welcomeMessage;

  @override
  int get hashCode => Object.hashAll([
    agentId,
    agentVersion,
    instructions,
    llm,
    stt,
    valueDeepHashCode(tools),
    tts,
    turn,
    welcomeMessage,
  ]);

  @override
  String toString() =>
      'CreateAudioSessionRequest('
      'agentId: $agentId, '
      'agentVersion: $agentVersion, '
      'instructions: $instructions, '
      'llm: $llm, '
      'stt: $stt, '
      'tools: ${tools?.length}, '
      'tts: $tts, '
      'turn: $turn, '
      'welcomeMessage: $welcomeMessage)';
}

/// The AudioSessionCreateResponse wire payload.
@immutable
class AudioSessionCredentials {
  /// Creates a [AudioSessionCredentials].
  const AudioSessionCredentials({
    required this.createdAt,
    required this.expiresAt,
    this.functionTools,
    required this.id,
    required this.participantToken,
    required this.serverUrl,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The expires_at field.
  final DateTime expiresAt;

  /// Effective function declarations after saved-agent and session overrides are merged. Connected SDKs can compare them with their local handlers.
  final List<VoiceAgentFunctionTool>? functionTools;

  /// The id field.
  final String id;

  /// The participant_token field.
  final String participantToken;

  /// The server_url field.
  final String serverUrl;

  /// Parses a [AudioSessionCredentials] from JSON.
  factory AudioSessionCredentials.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException(
        'AudioSessionCredentials: missing created_at',
      );
    }
    if (json['expires_at'] == null) {
      throw const FormatException(
        'AudioSessionCredentials: missing expires_at',
      );
    }
    if (json['id'] == null) {
      throw const FormatException('AudioSessionCredentials: missing id');
    }
    if (json['participant_token'] == null) {
      throw const FormatException(
        'AudioSessionCredentials: missing participant_token',
      );
    }
    if (json['server_url'] == null) {
      throw const FormatException(
        'AudioSessionCredentials: missing server_url',
      );
    }
    return AudioSessionCredentials(
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      expiresAt: DateTime.parse(json['expires_at'] as String).toUtc(),
      functionTools: json['function_tools'] == null
          ? null
          : (json['function_tools'] as List)
                .map(
                  (item) => VoiceAgentFunctionTool.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList(),
      id: json['id'] as String,
      participantToken: json['participant_token'] as String,
      serverUrl: json['server_url'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toUtc().toIso8601String(),
    'expires_at': expiresAt.toUtc().toIso8601String(),
    if (functionTools != null)
      'function_tools': functionTools!.map((item) => item.toJson()).toList(),
    'id': id,
    'participant_token': participantToken,
    'server_url': serverUrl,
  };

  /// Creates a copy with the given fields replaced.
  AudioSessionCredentials copyWith({
    DateTime? createdAt,
    DateTime? expiresAt,
    Object? functionTools = unsetCopyWithValue,
    String? id,
    String? participantToken,
    String? serverUrl,
  }) => AudioSessionCredentials(
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
    functionTools: functionTools == unsetCopyWithValue
        ? this.functionTools
        : (functionTools as List?)?.cast<VoiceAgentFunctionTool>(),
    id: id ?? this.id,
    participantToken: participantToken ?? this.participantToken,
    serverUrl: serverUrl ?? this.serverUrl,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioSessionCredentials &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          expiresAt == other.expiresAt &&
          valuesDeepEqual(functionTools, other.functionTools) &&
          id == other.id &&
          participantToken == other.participantToken &&
          serverUrl == other.serverUrl;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    expiresAt,
    valueDeepHashCode(functionTools),
    id,
    participantToken,
    serverUrl,
  ]);

  @override
  String toString() =>
      'AudioSessionCredentials('
      'createdAt: $createdAt, '
      'expiresAt: $expiresAt, '
      'functionTools: ${functionTools?.length}, '
      'id: $id, '
      'participantToken: [REDACTED], '
      'serverUrl: $serverUrl)';
}

/// The AudioSessionUpdateRequest wire payload.
@immutable
class UpdateAudioSessionRequest {
  /// Creates a [UpdateAudioSessionRequest].
  const UpdateAudioSessionRequest({
    this.instructions,
    this.tools,
    this.turn,
    this.sendNullInstructions = false,
    this.sendNullTools = false,
    this.sendNullTurn = false,
  });

  /// Whether to send an explicit null when [instructions] is absent.
  final bool sendNullInstructions;

  /// Whether to send an explicit null when [tools] is absent.
  final bool sendNullTools;

  /// Whether to send an explicit null when [turn] is absent.
  final bool sendNullTurn;

  /// The instructions field.
  final String? instructions;

  /// The tools field.
  final List<VoiceAgentTool>? tools;

  /// The turn field.
  final AudioSessionTurnUpdate? turn;

  /// Parses a [UpdateAudioSessionRequest] from JSON.
  factory UpdateAudioSessionRequest.fromJson(Map<String, dynamic> json) {
    return UpdateAudioSessionRequest(
      sendNullInstructions:
          json.containsKey('instructions') && json['instructions'] == null,
      sendNullTools: json.containsKey('tools') && json['tools'] == null,
      sendNullTurn: json.containsKey('turn') && json['turn'] == null,
      instructions: json['instructions'] == null
          ? null
          : json['instructions'] as String,
      tools: json['tools'] == null
          ? null
          : (json['tools'] as List)
                .map(
                  (item) =>
                      VoiceAgentTool.fromJson(item as Map<String, dynamic>),
                )
                .toList(),
      turn: json['turn'] == null
          ? null
          : AudioSessionTurnUpdate.fromJson(
              json['turn'] as Map<String, dynamic>,
            ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (instructions != null || sendNullInstructions)
      'instructions': instructions,
    if (tools != null || sendNullTools)
      'tools': tools?.map((item) => item.toJson()).toList(),
    if (turn != null || sendNullTurn) 'turn': turn?.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  UpdateAudioSessionRequest copyWith({
    Object? instructions = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? turn = unsetCopyWithValue,
    bool? sendNullInstructions,
    bool? sendNullTools,
    bool? sendNullTurn,
  }) => UpdateAudioSessionRequest(
    sendNullInstructions: sendNullInstructions ?? this.sendNullInstructions,
    sendNullTools: sendNullTools ?? this.sendNullTools,
    sendNullTurn: sendNullTurn ?? this.sendNullTurn,
    instructions: instructions == unsetCopyWithValue
        ? this.instructions
        : instructions as String?,
    tools: tools == unsetCopyWithValue
        ? this.tools
        : (tools as List?)?.cast<VoiceAgentTool>(),
    turn: turn == unsetCopyWithValue
        ? this.turn
        : turn as AudioSessionTurnUpdate?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAudioSessionRequest &&
          runtimeType == other.runtimeType &&
          instructions == other.instructions &&
          valuesDeepEqual(tools, other.tools) &&
          turn == other.turn &&
          sendNullInstructions == other.sendNullInstructions &&
          sendNullTools == other.sendNullTools &&
          sendNullTurn == other.sendNullTurn;

  @override
  int get hashCode => Object.hash(
    instructions,
    valueDeepHashCode(tools),
    turn,
    sendNullInstructions,
    sendNullTools,
    sendNullTurn,
  );

  @override
  String toString() =>
      'UpdateAudioSessionRequest('
      'instructions: $instructions, '
      'tools: ${tools?.length}, '
      'turn: $turn, sendNullInstructions: $sendNullInstructions, '
      'sendNullTools: $sendNullTools, sendNullTurn: $sendNullTurn)';
}

/// The AudioSessionResponse wire payload.
@immutable
class AudioSession {
  /// Creates a [AudioSession].
  const AudioSession({
    this.bridgeMetadata,
    required this.createdAt,
    required this.id,
    required this.numParticipants,
    this.phoneCall,
    required this.status,
    this.transcripts,
  });

  /// The bridge_metadata field.
  final AmazonConnectContact? bridgeMetadata;

  /// The created_at field.
  final DateTime createdAt;

  /// The id field.
  final String id;

  /// The num_participants field.
  final int numParticipants;

  /// The phone_call field.
  final AudioSessionPhoneCall? phoneCall;

  /// The status field.
  final AudioSessionStatus status;

  /// The turns of the conversation, or null while no transcript has been recorded for this session yet.
  final List<AudioTranscriptTurn>? transcripts;

  /// Parses a [AudioSession] from JSON.
  factory AudioSession.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('AudioSession: missing created_at');
    }
    if (json['id'] == null) {
      throw const FormatException('AudioSession: missing id');
    }
    if (json['num_participants'] == null) {
      throw const FormatException('AudioSession: missing num_participants');
    }
    if (json['status'] == null) {
      throw const FormatException('AudioSession: missing status');
    }
    return AudioSession(
      bridgeMetadata: json['bridge_metadata'] == null
          ? null
          : AmazonConnectContact.fromJson(
              json['bridge_metadata'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      id: json['id'] as String,
      numParticipants: json['num_participants'] as int,
      phoneCall: json['phone_call'] == null
          ? null
          : AudioSessionPhoneCall.fromJson(
              json['phone_call'] as Map<String, dynamic>,
            ),
      status: AudioSessionStatus.fromJson(json['status'] as String),
      transcripts: json['transcripts'] == null
          ? null
          : (json['transcripts'] as List)
                .map(
                  (item) => AudioTranscriptTurn.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (bridgeMetadata != null) 'bridge_metadata': bridgeMetadata!.toJson(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'id': id,
    'num_participants': numParticipants,
    if (phoneCall != null) 'phone_call': phoneCall!.toJson(),
    'status': status.toJson(),
    if (transcripts != null)
      'transcripts': transcripts!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  AudioSession copyWith({
    Object? bridgeMetadata = unsetCopyWithValue,
    DateTime? createdAt,
    String? id,
    int? numParticipants,
    Object? phoneCall = unsetCopyWithValue,
    AudioSessionStatus? status,
    Object? transcripts = unsetCopyWithValue,
  }) => AudioSession(
    bridgeMetadata: bridgeMetadata == unsetCopyWithValue
        ? this.bridgeMetadata
        : bridgeMetadata as AmazonConnectContact?,
    createdAt: createdAt ?? this.createdAt,
    id: id ?? this.id,
    numParticipants: numParticipants ?? this.numParticipants,
    phoneCall: phoneCall == unsetCopyWithValue
        ? this.phoneCall
        : phoneCall as AudioSessionPhoneCall?,
    status: status ?? this.status,
    transcripts: transcripts == unsetCopyWithValue
        ? this.transcripts
        : (transcripts as List?)?.cast<AudioTranscriptTurn>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioSession &&
          runtimeType == other.runtimeType &&
          bridgeMetadata == other.bridgeMetadata &&
          createdAt == other.createdAt &&
          id == other.id &&
          numParticipants == other.numParticipants &&
          phoneCall == other.phoneCall &&
          status == other.status &&
          valuesDeepEqual(transcripts, other.transcripts);

  @override
  int get hashCode => Object.hashAll([
    bridgeMetadata,
    createdAt,
    id,
    numParticipants,
    phoneCall,
    status,
    valueDeepHashCode(transcripts),
  ]);

  @override
  String toString() =>
      'AudioSession('
      'bridgeMetadata: $bridgeMetadata, '
      'createdAt: $createdAt, '
      'id: $id, '
      'numParticipants: $numParticipants, '
      'phoneCall: $phoneCall, '
      'status: $status, '
      'transcripts: ${transcripts?.length})';
}

/// The session the update was sent to. The agent applies the update at its next turn boundary and reports the outcome through the `session_updated` and `session_update_failed` webhooks.
@immutable
class AudioSessionUpdate {
  /// Creates a [AudioSessionUpdate].
  const AudioSessionUpdate({
    this.bridgeMetadata,
    required this.createdAt,
    required this.id,
    required this.numParticipants,
    this.phoneCall,
    required this.status,
  });

  /// The bridge_metadata field.
  final AmazonConnectContact? bridgeMetadata;

  /// The created_at field.
  final DateTime createdAt;

  /// The id field.
  final String id;

  /// The num_participants field.
  final int numParticipants;

  /// The phone_call field.
  final AudioSessionPhoneCall? phoneCall;

  /// The status field.
  final AudioSessionStatus status;

  /// Parses a [AudioSessionUpdate] from JSON.
  factory AudioSessionUpdate.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('AudioSessionUpdate: missing created_at');
    }
    if (json['id'] == null) {
      throw const FormatException('AudioSessionUpdate: missing id');
    }
    if (json['num_participants'] == null) {
      throw const FormatException(
        'AudioSessionUpdate: missing num_participants',
      );
    }
    if (json['status'] == null) {
      throw const FormatException('AudioSessionUpdate: missing status');
    }
    return AudioSessionUpdate(
      bridgeMetadata: json['bridge_metadata'] == null
          ? null
          : AmazonConnectContact.fromJson(
              json['bridge_metadata'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      id: json['id'] as String,
      numParticipants: json['num_participants'] as int,
      phoneCall: json['phone_call'] == null
          ? null
          : AudioSessionPhoneCall.fromJson(
              json['phone_call'] as Map<String, dynamic>,
            ),
      status: AudioSessionStatus.fromJson(json['status'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (bridgeMetadata != null) 'bridge_metadata': bridgeMetadata!.toJson(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'id': id,
    'num_participants': numParticipants,
    if (phoneCall != null) 'phone_call': phoneCall!.toJson(),
    'status': status.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  AudioSessionUpdate copyWith({
    Object? bridgeMetadata = unsetCopyWithValue,
    DateTime? createdAt,
    String? id,
    int? numParticipants,
    Object? phoneCall = unsetCopyWithValue,
    AudioSessionStatus? status,
  }) => AudioSessionUpdate(
    bridgeMetadata: bridgeMetadata == unsetCopyWithValue
        ? this.bridgeMetadata
        : bridgeMetadata as AmazonConnectContact?,
    createdAt: createdAt ?? this.createdAt,
    id: id ?? this.id,
    numParticipants: numParticipants ?? this.numParticipants,
    phoneCall: phoneCall == unsetCopyWithValue
        ? this.phoneCall
        : phoneCall as AudioSessionPhoneCall?,
    status: status ?? this.status,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioSessionUpdate &&
          runtimeType == other.runtimeType &&
          bridgeMetadata == other.bridgeMetadata &&
          createdAt == other.createdAt &&
          id == other.id &&
          numParticipants == other.numParticipants &&
          phoneCall == other.phoneCall &&
          status == other.status;

  @override
  int get hashCode => Object.hashAll([
    bridgeMetadata,
    createdAt,
    id,
    numParticipants,
    phoneCall,
    status,
  ]);

  @override
  String toString() =>
      'AudioSessionUpdate('
      'bridgeMetadata: $bridgeMetadata, '
      'createdAt: $createdAt, '
      'id: $id, '
      'numParticipants: $numParticipants, '
      'phoneCall: $phoneCall, '
      'status: $status)';
}

/// Contact metadata recorded when Amazon Connect starts a session.
@immutable
class AmazonConnectContact {
  /// Creates a [AmazonConnectContact].
  const AmazonConnectContact({
    this.calledNumber,
    this.callerNumber,
    this.channel,
    this.contactArn,
    this.contactId,
    required this.contextId,
    this.instanceArn,
    this.instanceId,
  });

  /// The fixed type discriminator.
  String get type => 'amazon_connect';

  /// The called_number field.
  final String? calledNumber;

  /// The caller_number field.
  final String? callerNumber;

  /// The channel field.
  final String? channel;

  /// The contact_arn field.
  final String? contactArn;

  /// The contact_id field.
  final String? contactId;

  /// Amazon Connect session context ID.
  final String contextId;

  /// The instance_arn field.
  final String? instanceArn;

  /// The instance_id field.
  final String? instanceId;

  /// Parses a [AmazonConnectContact] from JSON.
  factory AmazonConnectContact.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'amazon_connect') {
      throw FormatException('AmazonConnectContact: unexpected type $value');
    }
    if (json['context_id'] == null) {
      throw const FormatException('AmazonConnectContact: missing context_id');
    }
    return AmazonConnectContact(
      calledNumber: json['called_number'] == null
          ? null
          : json['called_number'] as String,
      callerNumber: json['caller_number'] == null
          ? null
          : json['caller_number'] as String,
      channel: json['channel'] == null ? null : json['channel'] as String,
      contactArn: json['contact_arn'] == null
          ? null
          : json['contact_arn'] as String,
      contactId: json['contact_id'] == null
          ? null
          : json['contact_id'] as String,
      contextId: json['context_id'] as String,
      instanceArn: json['instance_arn'] == null
          ? null
          : json['instance_arn'] as String,
      instanceId: json['instance_id'] == null
          ? null
          : json['instance_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'type': type,
    'called_number': ?calledNumber,
    'caller_number': ?callerNumber,
    'channel': ?channel,
    'contact_arn': ?contactArn,
    'contact_id': ?contactId,
    'context_id': contextId,
    'instance_arn': ?instanceArn,
    'instance_id': ?instanceId,
  };

  /// Creates a copy with the given fields replaced.
  AmazonConnectContact copyWith({
    Object? calledNumber = unsetCopyWithValue,
    Object? callerNumber = unsetCopyWithValue,
    Object? channel = unsetCopyWithValue,
    Object? contactArn = unsetCopyWithValue,
    Object? contactId = unsetCopyWithValue,
    String? contextId,
    Object? instanceArn = unsetCopyWithValue,
    Object? instanceId = unsetCopyWithValue,
  }) => AmazonConnectContact(
    calledNumber: calledNumber == unsetCopyWithValue
        ? this.calledNumber
        : calledNumber as String?,
    callerNumber: callerNumber == unsetCopyWithValue
        ? this.callerNumber
        : callerNumber as String?,
    channel: channel == unsetCopyWithValue ? this.channel : channel as String?,
    contactArn: contactArn == unsetCopyWithValue
        ? this.contactArn
        : contactArn as String?,
    contactId: contactId == unsetCopyWithValue
        ? this.contactId
        : contactId as String?,
    contextId: contextId ?? this.contextId,
    instanceArn: instanceArn == unsetCopyWithValue
        ? this.instanceArn
        : instanceArn as String?,
    instanceId: instanceId == unsetCopyWithValue
        ? this.instanceId
        : instanceId as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmazonConnectContact &&
          runtimeType == other.runtimeType &&
          calledNumber == other.calledNumber &&
          callerNumber == other.callerNumber &&
          channel == other.channel &&
          contactArn == other.contactArn &&
          contactId == other.contactId &&
          contextId == other.contextId &&
          instanceArn == other.instanceArn &&
          instanceId == other.instanceId;

  @override
  int get hashCode => Object.hashAll([
    calledNumber,
    callerNumber,
    channel,
    contactArn,
    contactId,
    contextId,
    instanceArn,
    instanceId,
  ]);

  @override
  String toString() =>
      'AmazonConnectContact('
      'calledNumber: $calledNumber, '
      'callerNumber: $callerNumber, '
      'channel: $channel, '
      'contactArn: $contactArn, '
      'contactId: $contactId, '
      'contextId: $contextId, '
      'instanceArn: $instanceArn, '
      'instanceId: $instanceId)';
}

/// The phone line a session is attached to. Present only when the caller reached the agent over telephony, `null` for a session started from a browser or the API.
@immutable
class AudioSessionPhoneCall {
  /// Creates a [AudioSessionPhoneCall].
  const AudioSessionPhoneCall({this.phoneNumber, required this.phoneNumberId});

  /// The number as it stands now, or null once it has been released or when you cannot read it.
  final AudioSessionPhoneNumber? phoneNumber;

  /// The phone_number_id field.
  final String phoneNumberId;

  /// Parses a [AudioSessionPhoneCall] from JSON.
  factory AudioSessionPhoneCall.fromJson(Map<String, dynamic> json) {
    if (json['phone_number_id'] == null) {
      throw const FormatException(
        'AudioSessionPhoneCall: missing phone_number_id',
      );
    }
    return AudioSessionPhoneCall(
      phoneNumber: json['phone_number'] == null
          ? null
          : AudioSessionPhoneNumber.fromJson(
              json['phone_number'] as Map<String, dynamic>,
            ),
      phoneNumberId: json['phone_number_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (phoneNumber != null) 'phone_number': phoneNumber!.toJson(),
    'phone_number_id': phoneNumberId,
  };

  /// Creates a copy with the given fields replaced.
  AudioSessionPhoneCall copyWith({
    Object? phoneNumber = unsetCopyWithValue,
    String? phoneNumberId,
  }) => AudioSessionPhoneCall(
    phoneNumber: phoneNumber == unsetCopyWithValue
        ? this.phoneNumber
        : phoneNumber as AudioSessionPhoneNumber?,
    phoneNumberId: phoneNumberId ?? this.phoneNumberId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioSessionPhoneCall &&
          runtimeType == other.runtimeType &&
          phoneNumber == other.phoneNumber &&
          phoneNumberId == other.phoneNumberId;

  @override
  int get hashCode => Object.hashAll([phoneNumber, phoneNumberId]);

  @override
  String toString() =>
      'AudioSessionPhoneCall('
      'phoneNumber: $phoneNumber, '
      'phoneNumberId: $phoneNumberId)';
}

/// The line the call came in on, as it stands now.
@immutable
class AudioSessionPhoneNumber {
  /// Creates a [AudioSessionPhoneNumber].
  const AudioSessionPhoneNumber({
    required this.id,
    required this.identifier,
    this.name,
  });

  /// The id field.
  final String id;

  /// What the caller dialed to reach this number.
  final String identifier;

  /// The name field.
  final String? name;

  /// Parses a [AudioSessionPhoneNumber] from JSON.
  factory AudioSessionPhoneNumber.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw const FormatException('AudioSessionPhoneNumber: missing id');
    }
    if (json['identifier'] == null) {
      throw const FormatException(
        'AudioSessionPhoneNumber: missing identifier',
      );
    }
    return AudioSessionPhoneNumber(
      id: json['id'] as String,
      identifier: json['identifier'] as String,
      name: json['name'] == null ? null : json['name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'id': id,
    'identifier': identifier,
    'name': ?name,
  };

  /// Creates a copy with the given fields replaced.
  AudioSessionPhoneNumber copyWith({
    String? id,
    String? identifier,
    Object? name = unsetCopyWithValue,
  }) => AudioSessionPhoneNumber(
    id: id ?? this.id,
    identifier: identifier ?? this.identifier,
    name: name == unsetCopyWithValue ? this.name : name as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioSessionPhoneNumber &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          identifier == other.identifier &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([id, identifier, name]);

  @override
  String toString() =>
      'AudioSessionPhoneNumber('
      'id: $id, '
      'identifier: $identifier, '
      'name: $name)';
}

/// The AudioSessionTurnUpdate wire payload.
@immutable
class AudioSessionTurnUpdate {
  /// Creates a [AudioSessionTurnUpdate].
  const AudioSessionTurnUpdate({this.allowInterruptions});

  /// The allow_interruptions field.
  final bool? allowInterruptions;

  /// Parses a [AudioSessionTurnUpdate] from JSON.
  factory AudioSessionTurnUpdate.fromJson(Map<String, dynamic> json) {
    return AudioSessionTurnUpdate(
      allowInterruptions: json['allow_interruptions'] == null
          ? null
          : json['allow_interruptions'] as bool,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'allow_interruptions': ?allowInterruptions};

  /// Creates a copy with the given fields replaced.
  AudioSessionTurnUpdate copyWith({
    Object? allowInterruptions = unsetCopyWithValue,
  }) => AudioSessionTurnUpdate(
    allowInterruptions: allowInterruptions == unsetCopyWithValue
        ? this.allowInterruptions
        : allowInterruptions as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioSessionTurnUpdate &&
          runtimeType == other.runtimeType &&
          allowInterruptions == other.allowInterruptions;

  @override
  int get hashCode => Object.hashAll([allowInterruptions]);

  @override
  String toString() =>
      'AudioSessionTurnUpdate('
      'allowInterruptions: $allowInterruptions)';
}
