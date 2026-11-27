import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'audio_agent_config.dart';
import 'audio_session.dart';

/// The AudioAgentCreateRequest wire payload.
@immutable
class CreateAudioAgentRequest {
  /// Creates a [CreateAudioAgentRequest].
  const CreateAudioAgentRequest({
    required this.configuration,
    this.description,
    required this.name,
  });

  /// The configuration field.
  final AudioAgentConfiguration configuration;

  /// The description field.
  final String? description;

  /// The name field.
  final String name;

  /// Parses a [CreateAudioAgentRequest] from JSON.
  factory CreateAudioAgentRequest.fromJson(Map<String, dynamic> json) {
    if (json['configuration'] == null) {
      throw const FormatException(
        'CreateAudioAgentRequest: missing configuration',
      );
    }
    if (json['name'] == null) {
      throw const FormatException('CreateAudioAgentRequest: missing name');
    }
    return CreateAudioAgentRequest(
      configuration: AudioAgentConfiguration.fromJson(
        json['configuration'] as Map<String, dynamic>,
      ),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      name: json['name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'configuration': configuration.toJson(),
    'description': ?description,
    'name': name,
  };

  /// Creates a copy with the given fields replaced.
  CreateAudioAgentRequest copyWith({
    AudioAgentConfiguration? configuration,
    Object? description = unsetCopyWithValue,
    String? name,
  }) => CreateAudioAgentRequest(
    configuration: configuration ?? this.configuration,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    name: name ?? this.name,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateAudioAgentRequest &&
          runtimeType == other.runtimeType &&
          configuration == other.configuration &&
          description == other.description &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([configuration, description, name]);

  @override
  String toString() =>
      'CreateAudioAgentRequest('
      'configuration: $configuration, '
      'description: $description, '
      'name: $name)';
}

/// The AudioAgentUpdateRequest wire payload.
@immutable
class UpdateAudioAgentRequest {
  /// Creates a [UpdateAudioAgentRequest].
  const UpdateAudioAgentRequest({
    required this.configuration,
    this.description,
    required this.name,
  });

  /// The configuration field.
  final AudioAgentConfiguration configuration;

  /// The description field.
  final String? description;

  /// The name field.
  final String name;

  /// Parses a [UpdateAudioAgentRequest] from JSON.
  factory UpdateAudioAgentRequest.fromJson(Map<String, dynamic> json) {
    if (json['configuration'] == null) {
      throw const FormatException(
        'UpdateAudioAgentRequest: missing configuration',
      );
    }
    if (json['name'] == null) {
      throw const FormatException('UpdateAudioAgentRequest: missing name');
    }
    return UpdateAudioAgentRequest(
      configuration: AudioAgentConfiguration.fromJson(
        json['configuration'] as Map<String, dynamic>,
      ),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      name: json['name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'configuration': configuration.toJson(),
    'description': ?description,
    'name': name,
  };

  /// Creates a copy with the given fields replaced.
  UpdateAudioAgentRequest copyWith({
    AudioAgentConfiguration? configuration,
    Object? description = unsetCopyWithValue,
    String? name,
  }) => UpdateAudioAgentRequest(
    configuration: configuration ?? this.configuration,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    name: name ?? this.name,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAudioAgentRequest &&
          runtimeType == other.runtimeType &&
          configuration == other.configuration &&
          description == other.description &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([configuration, description, name]);

  @override
  String toString() =>
      'UpdateAudioAgentRequest('
      'configuration: $configuration, '
      'description: $description, '
      'name: $name)';
}

/// The AudioAgentResponse wire payload.
@immutable
class AudioAgent {
  /// Creates a [AudioAgent].
  const AudioAgent({
    this.configuration,
    required this.createdAt,
    this.description,
    required this.id,
    this.name,
    required this.ownerId,
    required this.updatedAt,
    this.version,
  });

  /// The configuration field.
  final AudioAgentConfigurationSnapshot? configuration;

  /// The created_at field.
  final DateTime createdAt;

  /// The description field.
  final String? description;

  /// The id field.
  final String id;

  /// The name field.
  final String? name;

  /// The owner_id field.
  final String ownerId;

  /// The updated_at field.
  final DateTime updatedAt;

  /// The version field.
  final int? version;

  /// Parses a [AudioAgent] from JSON.
  factory AudioAgent.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('AudioAgent: missing created_at');
    }
    if (json['id'] == null) {
      throw const FormatException('AudioAgent: missing id');
    }
    if (json['owner_id'] == null) {
      throw const FormatException('AudioAgent: missing owner_id');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('AudioAgent: missing updated_at');
    }
    return AudioAgent(
      configuration: json['configuration'] == null
          ? null
          : AudioAgentConfigurationSnapshot.fromJson(
              json['configuration'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      id: json['id'] as String,
      name: json['name'] == null ? null : json['name'] as String,
      ownerId: json['owner_id'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
      version: json['version'] == null ? null : json['version'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (configuration != null) 'configuration': configuration!.toJson(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'description': ?description,
    'id': id,
    'name': ?name,
    'owner_id': ownerId,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'version': ?version,
  };

  /// Creates a copy with the given fields replaced.
  AudioAgent copyWith({
    Object? configuration = unsetCopyWithValue,
    DateTime? createdAt,
    Object? description = unsetCopyWithValue,
    String? id,
    Object? name = unsetCopyWithValue,
    String? ownerId,
    DateTime? updatedAt,
    Object? version = unsetCopyWithValue,
  }) => AudioAgent(
    configuration: configuration == unsetCopyWithValue
        ? this.configuration
        : configuration as AudioAgentConfigurationSnapshot?,
    createdAt: createdAt ?? this.createdAt,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    id: id ?? this.id,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    ownerId: ownerId ?? this.ownerId,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version == unsetCopyWithValue ? this.version : version as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioAgent &&
          runtimeType == other.runtimeType &&
          configuration == other.configuration &&
          createdAt == other.createdAt &&
          description == other.description &&
          id == other.id &&
          name == other.name &&
          ownerId == other.ownerId &&
          updatedAt == other.updatedAt &&
          version == other.version;

  @override
  int get hashCode => Object.hashAll([
    configuration,
    createdAt,
    description,
    id,
    name,
    ownerId,
    updatedAt,
    version,
  ]);

  @override
  String toString() =>
      'AudioAgent('
      'configuration: $configuration, '
      'createdAt: $createdAt, '
      'description: $description, '
      'id: $id, '
      'name: $name, '
      'ownerId: $ownerId, '
      'updatedAt: $updatedAt, '
      'version: $version)';
}

/// The AudioAgentListPage wire payload.
@immutable
class AudioAgentListPage {
  /// Creates a [AudioAgentListPage].
  const AudioAgentListPage({required this.data, this.nextPageToken});

  /// The data field.
  final List<AudioAgent> data;

  /// Cursor for the next page, null on the last page
  final String? nextPageToken;

  /// Parses a [AudioAgentListPage] from JSON.
  factory AudioAgentListPage.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      throw const FormatException('AudioAgentListPage: missing data');
    }
    return AudioAgentListPage(
      data: (json['data'] as List)
          .map((item) => AudioAgent.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextPageToken: json['next_page_token'] == null
          ? null
          : json['next_page_token'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    'next_page_token': ?nextPageToken,
  };

  /// Creates a copy with the given fields replaced.
  AudioAgentListPage copyWith({
    List<AudioAgent>? data,
    Object? nextPageToken = unsetCopyWithValue,
  }) => AudioAgentListPage(
    data: data ?? this.data,
    nextPageToken: nextPageToken == unsetCopyWithValue
        ? this.nextPageToken
        : nextPageToken as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioAgentListPage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(data, other.data) &&
          nextPageToken == other.nextPageToken;

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(data), nextPageToken]);

  @override
  String toString() =>
      'AudioAgentListPage('
      'data: ${data.length}, '
      'nextPageToken: $nextPageToken)';
}

/// The AudioAgentSessionListPage wire payload.
@immutable
class AudioAgentSessionListPage {
  /// Creates a [AudioAgentSessionListPage].
  const AudioAgentSessionListPage({required this.data, this.nextPageToken});

  /// The data field.
  final List<AudioAgentSessionSummary> data;

  /// Cursor for the next page, null on the last page
  final String? nextPageToken;

  /// Parses a [AudioAgentSessionListPage] from JSON.
  factory AudioAgentSessionListPage.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      throw const FormatException('AudioAgentSessionListPage: missing data');
    }
    return AudioAgentSessionListPage(
      data: (json['data'] as List)
          .map(
            (item) =>
                AudioAgentSessionSummary.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      nextPageToken: json['next_page_token'] == null
          ? null
          : json['next_page_token'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    'next_page_token': ?nextPageToken,
  };

  /// Creates a copy with the given fields replaced.
  AudioAgentSessionListPage copyWith({
    List<AudioAgentSessionSummary>? data,
    Object? nextPageToken = unsetCopyWithValue,
  }) => AudioAgentSessionListPage(
    data: data ?? this.data,
    nextPageToken: nextPageToken == unsetCopyWithValue
        ? this.nextPageToken
        : nextPageToken as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioAgentSessionListPage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(data, other.data) &&
          nextPageToken == other.nextPageToken;

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(data), nextPageToken]);

  @override
  String toString() =>
      'AudioAgentSessionListPage('
      'data: ${data.length}, '
      'nextPageToken: $nextPageToken)';
}

/// A session of a saved agent, without its transcript.
@immutable
class AudioAgentSessionSummary {
  /// Creates a [AudioAgentSessionSummary].
  const AudioAgentSessionSummary({
    required this.agentId,
    this.bridgeMetadata,
    this.duration,
    required this.id,
    this.phoneNumberId,
    this.startedAt,
  });

  /// The agent_id field.
  final String agentId;

  /// The bridge_metadata field.
  final AmazonConnectContact? bridgeMetadata;

  /// Seconds from the first participant joining to the session ending, null if nobody joined or it is still running.
  final int? duration;

  /// The id field.
  final String id;

  /// Set when the session came in over telephony.
  final String? phoneNumberId;

  /// When the first participant joined, null if nobody ever did.
  final DateTime? startedAt;

  /// Parses a [AudioAgentSessionSummary] from JSON.
  factory AudioAgentSessionSummary.fromJson(Map<String, dynamic> json) {
    if (json['agent_id'] == null) {
      throw const FormatException('AudioAgentSessionSummary: missing agent_id');
    }
    if (json['id'] == null) {
      throw const FormatException('AudioAgentSessionSummary: missing id');
    }
    return AudioAgentSessionSummary(
      agentId: json['agent_id'] as String,
      bridgeMetadata: json['bridge_metadata'] == null
          ? null
          : AmazonConnectContact.fromJson(
              json['bridge_metadata'] as Map<String, dynamic>,
            ),
      duration: json['duration'] == null ? null : json['duration'] as int,
      id: json['id'] as String,
      phoneNumberId: json['phone_number_id'] == null
          ? null
          : json['phone_number_id'] as String,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String).toUtc(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'agent_id': agentId,
    if (bridgeMetadata != null) 'bridge_metadata': bridgeMetadata!.toJson(),
    'duration': ?duration,
    'id': id,
    'phone_number_id': ?phoneNumberId,
    'started_at': ?startedAt?.toUtc().toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  AudioAgentSessionSummary copyWith({
    String? agentId,
    Object? bridgeMetadata = unsetCopyWithValue,
    Object? duration = unsetCopyWithValue,
    String? id,
    Object? phoneNumberId = unsetCopyWithValue,
    Object? startedAt = unsetCopyWithValue,
  }) => AudioAgentSessionSummary(
    agentId: agentId ?? this.agentId,
    bridgeMetadata: bridgeMetadata == unsetCopyWithValue
        ? this.bridgeMetadata
        : bridgeMetadata as AmazonConnectContact?,
    duration: duration == unsetCopyWithValue ? this.duration : duration as int?,
    id: id ?? this.id,
    phoneNumberId: phoneNumberId == unsetCopyWithValue
        ? this.phoneNumberId
        : phoneNumberId as String?,
    startedAt: startedAt == unsetCopyWithValue
        ? this.startedAt
        : startedAt as DateTime?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioAgentSessionSummary &&
          runtimeType == other.runtimeType &&
          agentId == other.agentId &&
          bridgeMetadata == other.bridgeMetadata &&
          duration == other.duration &&
          id == other.id &&
          phoneNumberId == other.phoneNumberId &&
          startedAt == other.startedAt;

  @override
  int get hashCode => Object.hashAll([
    agentId,
    bridgeMetadata,
    duration,
    id,
    phoneNumberId,
    startedAt,
  ]);

  @override
  String toString() =>
      'AudioAgentSessionSummary('
      'agentId: $agentId, '
      'bridgeMetadata: $bridgeMetadata, '
      'duration: $duration, '
      'id: $id, '
      'phoneNumberId: $phoneNumberId, '
      'startedAt: $startedAt)';
}
