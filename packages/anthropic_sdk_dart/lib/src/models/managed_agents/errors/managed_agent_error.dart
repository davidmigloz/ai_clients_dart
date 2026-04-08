import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

// ============================================================================
// RetryStatus — sealed
// ============================================================================

/// What the client should do next in response to an error.
///
/// Variants:
/// - [RetryStatusRetrying] — Server is retrying automatically (type: "retrying")
/// - [RetryStatusExhausted] — Turn is dead, client may send new prompt (type: "exhausted")
/// - [RetryStatusTerminal] — Session encountered a terminal error (type: "terminal")
/// - [UnknownRetryStatus] — Unrecognized type (preserves raw JSON)
sealed class RetryStatus {
  const RetryStatus();

  /// Creates a [RetryStatus] from JSON.
  factory RetryStatus.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'retrying' => RetryStatusRetrying.fromJson(json),
      'exhausted' => RetryStatusExhausted.fromJson(json),
      'terminal' => RetryStatusTerminal.fromJson(json),
      _ => UnknownRetryStatus.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// The server is retrying automatically.
@immutable
class RetryStatusRetrying extends RetryStatus {
  /// The type discriminator. Always `retrying`.
  final String type;

  /// Creates a [RetryStatusRetrying].
  const RetryStatusRetrying({this.type = 'retrying'});

  /// Creates a [RetryStatusRetrying] from JSON.
  factory RetryStatusRetrying.fromJson(Map<String, dynamic> json) {
    return RetryStatusRetrying(type: json['type'] as String? ?? 'retrying');
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates a copy with replaced values.
  RetryStatusRetrying copyWith({String? type}) {
    return RetryStatusRetrying(type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetryStatusRetrying &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'RetryStatusRetrying(type: $type)';
}

/// This turn is dead; queued inputs are flushed and the session returns to
/// idle. Client may send a new prompt.
@immutable
class RetryStatusExhausted extends RetryStatus {
  /// The type discriminator. Always `exhausted`.
  final String type;

  /// Creates a [RetryStatusExhausted].
  const RetryStatusExhausted({this.type = 'exhausted'});

  /// Creates a [RetryStatusExhausted] from JSON.
  factory RetryStatusExhausted.fromJson(Map<String, dynamic> json) {
    return RetryStatusExhausted(type: json['type'] as String? ?? 'exhausted');
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates a copy with replaced values.
  RetryStatusExhausted copyWith({String? type}) {
    return RetryStatusExhausted(type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetryStatusExhausted &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'RetryStatusExhausted(type: $type)';
}

/// The session encountered a terminal error and will transition to
/// `terminated` state.
@immutable
class RetryStatusTerminal extends RetryStatus {
  /// The type discriminator. Always `terminal`.
  final String type;

  /// Creates a [RetryStatusTerminal].
  const RetryStatusTerminal({this.type = 'terminal'});

  /// Creates a [RetryStatusTerminal] from JSON.
  factory RetryStatusTerminal.fromJson(Map<String, dynamic> json) {
    return RetryStatusTerminal(type: json['type'] as String? ?? 'terminal');
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates a copy with replaced values.
  RetryStatusTerminal copyWith({String? type}) {
    return RetryStatusTerminal(type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetryStatusTerminal &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'RetryStatusTerminal(type: $type)';
}

/// Unrecognized retry status type (preserves raw JSON).
@immutable
class UnknownRetryStatus extends RetryStatus {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownRetryStatus].
  const UnknownRetryStatus({required this.rawJson});

  /// Creates an [UnknownRetryStatus] from JSON.
  factory UnknownRetryStatus.fromJson(Map<String, dynamic> json) {
    return UnknownRetryStatus(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownRetryStatus &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownRetryStatus(rawJson: $rawJson)';
}

// ============================================================================
// Error types
// ============================================================================

/// Billing error — out of credits or spend limit reached.
@immutable
class BillingError {
  /// The type discriminator. Always `billing_error`.
  final String type;

  /// Human-readable error description.
  final String message;

  /// What the client should do next.
  final RetryStatus retryStatus;

  /// Creates a [BillingError].
  const BillingError({
    this.type = 'billing_error',
    required this.message,
    required this.retryStatus,
  });

  /// Creates a [BillingError] from JSON.
  factory BillingError.fromJson(Map<String, dynamic> json) {
    return BillingError(
      type: json['type'] as String? ?? 'billing_error',
      message: json['message'] as String,
      retryStatus: RetryStatus.fromJson(
        json['retry_status'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'message': message,
    'retry_status': retryStatus.toJson(),
  };

  /// Creates a copy with replaced values.
  BillingError copyWith({
    String? type,
    String? message,
    RetryStatus? retryStatus,
  }) {
    return BillingError(
      type: type ?? this.type,
      message: message ?? this.message,
      retryStatus: retryStatus ?? this.retryStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message &&
          retryStatus == other.retryStatus;

  @override
  int get hashCode => Object.hash(type, message, retryStatus);

  @override
  String toString() =>
      'BillingError(type: $type, message: $message, retryStatus: $retryStatus)';
}

/// Failed to connect to an MCP server.
@immutable
class McpConnectionFailedError {
  /// The type discriminator. Always `mcp_connection_failed`.
  final String type;

  /// Human-readable error description.
  final String message;

  /// Name of the MCP server that failed to connect.
  final String mcpServerName;

  /// What the client should do next.
  final RetryStatus retryStatus;

  /// Creates a [McpConnectionFailedError].
  const McpConnectionFailedError({
    this.type = 'mcp_connection_failed',
    required this.message,
    required this.mcpServerName,
    required this.retryStatus,
  });

  /// Creates a [McpConnectionFailedError] from JSON.
  factory McpConnectionFailedError.fromJson(Map<String, dynamic> json) {
    return McpConnectionFailedError(
      type: json['type'] as String? ?? 'mcp_connection_failed',
      message: json['message'] as String,
      mcpServerName: json['mcp_server_name'] as String,
      retryStatus: RetryStatus.fromJson(
        json['retry_status'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'message': message,
    'mcp_server_name': mcpServerName,
    'retry_status': retryStatus.toJson(),
  };

  /// Creates a copy with replaced values.
  McpConnectionFailedError copyWith({
    String? type,
    String? message,
    String? mcpServerName,
    RetryStatus? retryStatus,
  }) {
    return McpConnectionFailedError(
      type: type ?? this.type,
      message: message ?? this.message,
      mcpServerName: mcpServerName ?? this.mcpServerName,
      retryStatus: retryStatus ?? this.retryStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpConnectionFailedError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message &&
          mcpServerName == other.mcpServerName &&
          retryStatus == other.retryStatus;

  @override
  int get hashCode => Object.hash(type, message, mcpServerName, retryStatus);

  @override
  String toString() =>
      'McpConnectionFailedError('
      'type: $type, '
      'message: $message, '
      'mcpServerName: $mcpServerName, '
      'retryStatus: $retryStatus)';
}

/// Authentication to an MCP server failed.
@immutable
class McpAuthenticationFailedError {
  /// The type discriminator. Always `mcp_authentication_failed`.
  final String type;

  /// Human-readable error description.
  final String message;

  /// Name of the MCP server that failed authentication.
  final String mcpServerName;

  /// What the client should do next.
  final RetryStatus retryStatus;

  /// Creates a [McpAuthenticationFailedError].
  const McpAuthenticationFailedError({
    this.type = 'mcp_authentication_failed',
    required this.message,
    required this.mcpServerName,
    required this.retryStatus,
  });

  /// Creates a [McpAuthenticationFailedError] from JSON.
  factory McpAuthenticationFailedError.fromJson(Map<String, dynamic> json) {
    return McpAuthenticationFailedError(
      type: json['type'] as String? ?? 'mcp_authentication_failed',
      message: json['message'] as String,
      mcpServerName: json['mcp_server_name'] as String,
      retryStatus: RetryStatus.fromJson(
        json['retry_status'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'message': message,
    'mcp_server_name': mcpServerName,
    'retry_status': retryStatus.toJson(),
  };

  /// Creates a copy with replaced values.
  McpAuthenticationFailedError copyWith({
    String? type,
    String? message,
    String? mcpServerName,
    RetryStatus? retryStatus,
  }) {
    return McpAuthenticationFailedError(
      type: type ?? this.type,
      message: message ?? this.message,
      mcpServerName: mcpServerName ?? this.mcpServerName,
      retryStatus: retryStatus ?? this.retryStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpAuthenticationFailedError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message &&
          mcpServerName == other.mcpServerName &&
          retryStatus == other.retryStatus;

  @override
  int get hashCode => Object.hash(type, message, mcpServerName, retryStatus);

  @override
  String toString() =>
      'McpAuthenticationFailedError('
      'type: $type, '
      'message: $message, '
      'mcpServerName: $mcpServerName, '
      'retryStatus: $retryStatus)';
}

/// The model request was rate-limited.
@immutable
class ModelRateLimitedError {
  /// The type discriminator. Always `model_rate_limited`.
  final String type;

  /// Human-readable error description.
  final String message;

  /// What the client should do next.
  final RetryStatus retryStatus;

  /// Creates a [ModelRateLimitedError].
  const ModelRateLimitedError({
    this.type = 'model_rate_limited',
    required this.message,
    required this.retryStatus,
  });

  /// Creates a [ModelRateLimitedError] from JSON.
  factory ModelRateLimitedError.fromJson(Map<String, dynamic> json) {
    return ModelRateLimitedError(
      type: json['type'] as String? ?? 'model_rate_limited',
      message: json['message'] as String,
      retryStatus: RetryStatus.fromJson(
        json['retry_status'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'message': message,
    'retry_status': retryStatus.toJson(),
  };

  /// Creates a copy with replaced values.
  ModelRateLimitedError copyWith({
    String? type,
    String? message,
    RetryStatus? retryStatus,
  }) {
    return ModelRateLimitedError(
      type: type ?? this.type,
      message: message ?? this.message,
      retryStatus: retryStatus ?? this.retryStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelRateLimitedError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message &&
          retryStatus == other.retryStatus;

  @override
  int get hashCode => Object.hash(type, message, retryStatus);

  @override
  String toString() =>
      'ModelRateLimitedError('
      'type: $type, '
      'message: $message, '
      'retryStatus: $retryStatus)';
}

/// The model is currently overloaded.
@immutable
class ModelOverloadedError {
  /// The type discriminator. Always `model_overloaded`.
  final String type;

  /// Human-readable error description.
  final String message;

  /// What the client should do next.
  final RetryStatus retryStatus;

  /// Creates a [ModelOverloadedError].
  const ModelOverloadedError({
    this.type = 'model_overloaded',
    required this.message,
    required this.retryStatus,
  });

  /// Creates a [ModelOverloadedError] from JSON.
  factory ModelOverloadedError.fromJson(Map<String, dynamic> json) {
    return ModelOverloadedError(
      type: json['type'] as String? ?? 'model_overloaded',
      message: json['message'] as String,
      retryStatus: RetryStatus.fromJson(
        json['retry_status'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'message': message,
    'retry_status': retryStatus.toJson(),
  };

  /// Creates a copy with replaced values.
  ModelOverloadedError copyWith({
    String? type,
    String? message,
    RetryStatus? retryStatus,
  }) {
    return ModelOverloadedError(
      type: type ?? this.type,
      message: message ?? this.message,
      retryStatus: retryStatus ?? this.retryStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelOverloadedError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message &&
          retryStatus == other.retryStatus;

  @override
  int get hashCode => Object.hash(type, message, retryStatus);

  @override
  String toString() =>
      'ModelOverloadedError('
      'type: $type, '
      'message: $message, '
      'retryStatus: $retryStatus)';
}

/// A model request failed for a reason other than overload or rate-limiting.
@immutable
class ModelRequestFailedError {
  /// The type discriminator. Always `model_request_failed`.
  final String type;

  /// Human-readable error description.
  final String message;

  /// What the client should do next.
  final RetryStatus retryStatus;

  /// Creates a [ModelRequestFailedError].
  const ModelRequestFailedError({
    this.type = 'model_request_failed',
    required this.message,
    required this.retryStatus,
  });

  /// Creates a [ModelRequestFailedError] from JSON.
  factory ModelRequestFailedError.fromJson(Map<String, dynamic> json) {
    return ModelRequestFailedError(
      type: json['type'] as String? ?? 'model_request_failed',
      message: json['message'] as String,
      retryStatus: RetryStatus.fromJson(
        json['retry_status'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'message': message,
    'retry_status': retryStatus.toJson(),
  };

  /// Creates a copy with replaced values.
  ModelRequestFailedError copyWith({
    String? type,
    String? message,
    RetryStatus? retryStatus,
  }) {
    return ModelRequestFailedError(
      type: type ?? this.type,
      message: message ?? this.message,
      retryStatus: retryStatus ?? this.retryStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelRequestFailedError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message &&
          retryStatus == other.retryStatus;

  @override
  int get hashCode => Object.hash(type, message, retryStatus);

  @override
  String toString() =>
      'ModelRequestFailedError('
      'type: $type, '
      'message: $message, '
      'retryStatus: $retryStatus)';
}

/// An unknown managed agent error (preserves raw JSON).
@immutable
class UnknownManagedAgentError {
  /// Human-readable error description.
  final String message;

  /// The raw JSON data.
  final Map<String, dynamic>? rawJson;

  /// Creates an [UnknownManagedAgentError].
  const UnknownManagedAgentError({required this.message, this.rawJson});

  /// Creates an [UnknownManagedAgentError] from JSON.
  factory UnknownManagedAgentError.fromJson(Map<String, dynamic> json) {
    return UnknownManagedAgentError(
      message: json['message'] as String,
      rawJson: json,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => rawJson ?? {'message': message};

  /// Creates a copy with replaced values.
  UnknownManagedAgentError copyWith({
    String? message,
    Object? rawJson = unsetCopyWithValue,
  }) {
    return UnknownManagedAgentError(
      message: message ?? this.message,
      rawJson: rawJson == unsetCopyWithValue
          ? this.rawJson
          : rawJson as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownManagedAgentError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(message, mapDeepHashCode(rawJson));

  @override
  String toString() =>
      'UnknownManagedAgentError(message: $message, rawJson: $rawJson)';
}
