import 'package:meta/meta.dart';

/// Request to create a new ChatKit session.
///
/// ## Example
///
/// ```dart
/// final session = await client.chatkit.sessions.create(
///   CreateChatSessionRequest(
///     workflow: WorkflowParam(id: 'workflow-abc'),
///     user: 'user-123',
///     expiresAfter: 600, // 10 minutes
///   ),
/// );
/// ```
@immutable
class CreateChatSessionRequest {
  /// Creates a [CreateChatSessionRequest].
  const CreateChatSessionRequest({
    required this.workflow,
    required this.user,
    this.expiresAfter,
    this.rateLimits,
    this.chatkitConfiguration,
  });

  /// Workflow that powers the session.
  final WorkflowParam workflow;

  /// A free-form string that identifies your end user.
  final String user;

  /// Optional override for session expiration timing in seconds from creation.
  ///
  /// Defaults to 10 minutes.
  final int? expiresAfter;

  /// Optional override for per-minute request limits.
  ///
  /// When omitted, defaults to 10.
  final RateLimitsParam? rateLimits;

  /// Optional overrides for ChatKit runtime configuration features.
  final ChatkitConfigurationParam? chatkitConfiguration;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'workflow': workflow.toJson(),
    'user': user,
    if (expiresAfter != null) 'expires_after': expiresAfter,
    if (rateLimits != null) 'rate_limits': rateLimits!.toJson(),
    if (chatkitConfiguration != null)
      'chatkit_configuration': chatkitConfiguration!.toJson(),
  };

  @override
  String toString() => 'CreateChatSessionRequest(user: $user)';
}

/// Workflow parameter for creating a session.
@immutable
class WorkflowParam {
  /// Creates a [WorkflowParam].
  const WorkflowParam({
    required this.id,
    this.version,
    this.stateVariables,
    this.tracing,
  });

  /// Identifier of the workflow.
  final String id;

  /// Specific workflow version to use.
  final String? version;

  /// State variable key-value pairs to apply when invoking the workflow.
  final Map<String, dynamic>? stateVariables;

  /// Tracing configuration.
  final TracingParam? tracing;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    if (version != null) 'version': version,
    if (stateVariables != null) 'state_variables': stateVariables,
    if (tracing != null) 'tracing': tracing!.toJson(),
  };

  @override
  String toString() => 'WorkflowParam(id: $id)';
}

/// Tracing parameter.
@immutable
class TracingParam {
  /// Creates a [TracingParam].
  const TracingParam({required this.enabled});

  /// Whether tracing is enabled.
  final bool enabled;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'enabled': enabled};

  @override
  String toString() => 'TracingParam(enabled: $enabled)';
}

/// Rate limits parameter.
@immutable
class RateLimitsParam {
  /// Creates a [RateLimitsParam].
  const RateLimitsParam({required this.maxRequestsPer1Minute});

  /// Maximum allowed requests per one-minute window.
  final int maxRequestsPer1Minute;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'max_requests_per_1_minute': maxRequestsPer1Minute,
  };

  @override
  String toString() =>
      'RateLimitsParam(maxRequestsPer1Minute: $maxRequestsPer1Minute)';
}

/// ChatKit configuration parameter.
@immutable
class ChatkitConfigurationParam {
  /// Creates a [ChatkitConfigurationParam].
  const ChatkitConfigurationParam({
    this.automaticThreadTitling,
    this.fileUpload,
    this.history,
  });

  /// Configuration for automatic thread titling.
  final AutomaticThreadTitlingParam? automaticThreadTitling;

  /// Configuration for file upload.
  final FileUploadParam? fileUpload;

  /// Configuration for chat history retention.
  final HistoryParam? history;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (automaticThreadTitling != null)
      'automatic_thread_titling': automaticThreadTitling!.toJson(),
    if (fileUpload != null) 'file_upload': fileUpload!.toJson(),
    if (history != null) 'history': history!.toJson(),
  };

  @override
  String toString() => 'ChatkitConfigurationParam(...)';
}

/// Automatic thread titling parameter.
@immutable
class AutomaticThreadTitlingParam {
  /// Creates an [AutomaticThreadTitlingParam].
  const AutomaticThreadTitlingParam({required this.enabled});

  /// Whether automatic thread titling is enabled.
  final bool enabled;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'enabled': enabled};

  @override
  String toString() => 'AutomaticThreadTitlingParam(enabled: $enabled)';
}

/// File upload parameter.
@immutable
class FileUploadParam {
  /// Creates a [FileUploadParam].
  const FileUploadParam({
    required this.enabled,
    this.maxFileSize,
    this.maxFiles,
  });

  /// Whether file uploads are enabled.
  final bool enabled;

  /// Maximum file size in megabytes.
  final int? maxFileSize;

  /// Maximum number of files allowed.
  final int? maxFiles;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    if (maxFileSize != null) 'max_file_size': maxFileSize,
    if (maxFiles != null) 'max_files': maxFiles,
  };

  @override
  String toString() => 'FileUploadParam(enabled: $enabled)';
}

/// History parameter.
@immutable
class HistoryParam {
  /// Creates a [HistoryParam].
  const HistoryParam({required this.enabled, this.recentThreads});

  /// Whether chat history is persisted.
  final bool enabled;

  /// Number of prior threads to surface in history views.
  final int? recentThreads;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    if (recentThreads != null) 'recent_threads': recentThreads,
  };

  @override
  String toString() => 'HistoryParam(enabled: $enabled)';
}
