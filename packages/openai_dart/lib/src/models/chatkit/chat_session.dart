import 'package:meta/meta.dart';

/// A ChatKit session.
///
/// Represents a ChatKit session and its resolved configuration.
///
/// ## Example
///
/// ```dart
/// final session = await client.chatkit.sessions.create(
///   CreateChatSessionRequest(
///     workflow: WorkflowParam(id: 'workflow-abc'),
///     user: 'user-123',
///   ),
/// );
///
/// print('Session: ${session.id}');
/// print('Client secret: ${session.clientSecret}');
/// ```
@immutable
class ChatSession {
  /// Creates a [ChatSession].
  const ChatSession({
    required this.id,
    required this.object,
    required this.expiresAt,
    required this.clientSecret,
    required this.workflow,
    required this.user,
    required this.rateLimits,
    required this.maxRequestsPer1Minute,
    required this.status,
    required this.chatkitConfiguration,
  });

  /// Creates a [ChatSession] from JSON.
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      object: json['object'] as String? ?? 'chatkit.session',
      expiresAt: json['expires_at'] as int,
      clientSecret: json['client_secret'] as String,
      workflow: ChatkitWorkflow.fromJson(
        json['workflow'] as Map<String, dynamic>,
      ),
      user: json['user'] as String,
      rateLimits: ChatSessionRateLimits.fromJson(
        json['rate_limits'] as Map<String, dynamic>,
      ),
      maxRequestsPer1Minute: json['max_requests_per_1_minute'] as int,
      status: ChatSessionStatus.fromJson(json['status'] as String),
      chatkitConfiguration: ChatSessionChatkitConfiguration.fromJson(
        json['chatkit_configuration'] as Map<String, dynamic>,
      ),
    );
  }

  /// Identifier for the ChatKit session.
  final String id;

  /// Type discriminator that is always `chatkit.session`.
  final String object;

  /// Unix timestamp (in seconds) for when the session expires.
  final int expiresAt;

  /// Ephemeral client secret that authenticates session requests.
  final String clientSecret;

  /// Workflow metadata for the session.
  final ChatkitWorkflow workflow;

  /// User identifier associated with the session.
  final String user;

  /// Resolved rate limit values.
  final ChatSessionRateLimits rateLimits;

  /// Convenience copy of the per-minute request limit.
  final int maxRequestsPer1Minute;

  /// Current lifecycle state of the session.
  final ChatSessionStatus status;

  /// Resolved ChatKit feature configuration for the session.
  final ChatSessionChatkitConfiguration chatkitConfiguration;

  /// The expiration time as a DateTime.
  DateTime get expiresAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);

  /// Whether the session is active.
  bool get isActive => status == ChatSessionStatus.active;

  /// Whether the session is expired.
  bool get isExpired => status == ChatSessionStatus.expired;

  /// Whether the session is cancelled.
  bool get isCancelled => status == ChatSessionStatus.cancelled;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'expires_at': expiresAt,
    'client_secret': clientSecret,
    'workflow': workflow.toJson(),
    'user': user,
    'rate_limits': rateLimits.toJson(),
    'max_requests_per_1_minute': maxRequestsPer1Minute,
    'status': status.toJson(),
    'chatkit_configuration': chatkitConfiguration.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatSession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ChatSession(id: $id, status: $status)';
}

/// Workflow metadata for a ChatKit session.
@immutable
class ChatkitWorkflow {
  /// Creates a [ChatkitWorkflow].
  const ChatkitWorkflow({
    required this.id,
    this.version,
    this.stateVariables,
    this.tracing,
  });

  /// Creates a [ChatkitWorkflow] from JSON.
  factory ChatkitWorkflow.fromJson(Map<String, dynamic> json) {
    return ChatkitWorkflow(
      id: json['id'] as String,
      version: json['version'] as String?,
      stateVariables: json['state_variables'] as Map<String, dynamic>?,
      tracing: json['tracing'] != null
          ? ChatkitWorkflowTracing.fromJson(
              json['tracing'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Identifier of the workflow backing the session.
  final String id;

  /// Specific workflow version used for the session.
  final String? version;

  /// State variable key-value pairs applied when invoking the workflow.
  final Map<String, dynamic>? stateVariables;

  /// Tracing settings applied to the workflow.
  final ChatkitWorkflowTracing? tracing;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'version': version,
    'state_variables': stateVariables,
    if (tracing != null) 'tracing': tracing!.toJson(),
  };

  @override
  String toString() => 'ChatkitWorkflow(id: $id)';
}

/// Tracing configuration for a ChatKit workflow.
@immutable
class ChatkitWorkflowTracing {
  /// Creates a [ChatkitWorkflowTracing].
  const ChatkitWorkflowTracing({required this.enabled});

  /// Creates a [ChatkitWorkflowTracing] from JSON.
  factory ChatkitWorkflowTracing.fromJson(Map<String, dynamic> json) {
    return ChatkitWorkflowTracing(enabled: json['enabled'] as bool);
  }

  /// Indicates whether tracing is enabled.
  final bool enabled;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'enabled': enabled};

  @override
  String toString() => 'ChatkitWorkflowTracing(enabled: $enabled)';
}

/// Rate limits for a ChatKit session.
@immutable
class ChatSessionRateLimits {
  /// Creates a [ChatSessionRateLimits].
  const ChatSessionRateLimits({required this.maxRequestsPer1Minute});

  /// Creates a [ChatSessionRateLimits] from JSON.
  factory ChatSessionRateLimits.fromJson(Map<String, dynamic> json) {
    return ChatSessionRateLimits(
      maxRequestsPer1Minute: json['max_requests_per_1_minute'] as int,
    );
  }

  /// Maximum allowed requests per one-minute window.
  final int maxRequestsPer1Minute;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'max_requests_per_1_minute': maxRequestsPer1Minute,
  };

  @override
  String toString() =>
      'ChatSessionRateLimits(maxRequestsPer1Minute: $maxRequestsPer1Minute)';
}

/// ChatKit feature configuration for a session.
@immutable
class ChatSessionChatkitConfiguration {
  /// Creates a [ChatSessionChatkitConfiguration].
  const ChatSessionChatkitConfiguration({
    required this.automaticThreadTitling,
    required this.fileUpload,
    required this.history,
  });

  /// Creates a [ChatSessionChatkitConfiguration] from JSON.
  factory ChatSessionChatkitConfiguration.fromJson(Map<String, dynamic> json) {
    return ChatSessionChatkitConfiguration(
      automaticThreadTitling: ChatSessionAutomaticThreadTitling.fromJson(
        json['automatic_thread_titling'] as Map<String, dynamic>,
      ),
      fileUpload: ChatSessionFileUpload.fromJson(
        json['file_upload'] as Map<String, dynamic>,
      ),
      history: ChatSessionHistory.fromJson(
        json['history'] as Map<String, dynamic>,
      ),
    );
  }

  /// Automatic thread titling preferences.
  final ChatSessionAutomaticThreadTitling automaticThreadTitling;

  /// Upload settings for the session.
  final ChatSessionFileUpload fileUpload;

  /// History retention configuration.
  final ChatSessionHistory history;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'automatic_thread_titling': automaticThreadTitling.toJson(),
    'file_upload': fileUpload.toJson(),
    'history': history.toJson(),
  };

  @override
  String toString() => 'ChatSessionChatkitConfiguration(...)';
}

/// Automatic thread titling configuration.
@immutable
class ChatSessionAutomaticThreadTitling {
  /// Creates a [ChatSessionAutomaticThreadTitling].
  const ChatSessionAutomaticThreadTitling({required this.enabled});

  /// Creates a [ChatSessionAutomaticThreadTitling] from JSON.
  factory ChatSessionAutomaticThreadTitling.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChatSessionAutomaticThreadTitling(enabled: json['enabled'] as bool);
  }

  /// Whether automatic thread titling is enabled.
  final bool enabled;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'enabled': enabled};

  @override
  String toString() => 'ChatSessionAutomaticThreadTitling(enabled: $enabled)';
}

/// File upload settings for a session.
@immutable
class ChatSessionFileUpload {
  /// Creates a [ChatSessionFileUpload].
  const ChatSessionFileUpload({
    required this.enabled,
    this.maxFileSize,
    this.maxFiles,
  });

  /// Creates a [ChatSessionFileUpload] from JSON.
  factory ChatSessionFileUpload.fromJson(Map<String, dynamic> json) {
    return ChatSessionFileUpload(
      enabled: json['enabled'] as bool,
      maxFileSize: json['max_file_size'] as int?,
      maxFiles: json['max_files'] as int?,
    );
  }

  /// Indicates if uploads are enabled for the session.
  final bool enabled;

  /// Maximum upload size in megabytes.
  final int? maxFileSize;

  /// Maximum number of uploads allowed during the session.
  final int? maxFiles;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'max_file_size': maxFileSize,
    'max_files': maxFiles,
  };

  @override
  String toString() => 'ChatSessionFileUpload(enabled: $enabled)';
}

/// History retention settings for a session.
@immutable
class ChatSessionHistory {
  /// Creates a [ChatSessionHistory].
  const ChatSessionHistory({required this.enabled, this.recentThreads});

  /// Creates a [ChatSessionHistory] from JSON.
  factory ChatSessionHistory.fromJson(Map<String, dynamic> json) {
    return ChatSessionHistory(
      enabled: json['enabled'] as bool,
      recentThreads: json['recent_threads'] as int?,
    );
  }

  /// Indicates if chat history is persisted for the session.
  final bool enabled;

  /// Number of prior threads surfaced in history views.
  final int? recentThreads;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'recent_threads': recentThreads,
  };

  @override
  String toString() => 'ChatSessionHistory(enabled: $enabled)';
}

/// Session lifecycle status.
enum ChatSessionStatus {
  /// Session is active.
  active._('active'),

  /// Session has expired.
  expired._('expired'),

  /// Session was cancelled.
  cancelled._('cancelled');

  const ChatSessionStatus._(this._value);

  /// Creates from JSON string.
  factory ChatSessionStatus.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown session status: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}
