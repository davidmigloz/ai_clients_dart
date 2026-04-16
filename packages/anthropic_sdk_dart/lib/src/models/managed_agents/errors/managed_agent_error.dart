import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../events/telemetry.dart';

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

/// An unknown managed agent error (preserves raw JSON for forward compatibility).
@immutable
class UnknownManagedAgentError {
  /// The type discriminator. Always `unknown_error`.
  final String type;

  /// Human-readable error description.
  final String message;

  /// What the client should do next.
  final RetryStatus retryStatus;

  /// The raw JSON data (preserves unknown future fields).
  final Map<String, dynamic>? rawJson;

  /// Creates an [UnknownManagedAgentError].
  UnknownManagedAgentError({
    this.type = 'unknown_error',
    required this.message,
    required this.retryStatus,
    Map<String, dynamic>? rawJson,
  }) : rawJson = rawJson != null ? Map.unmodifiable(rawJson) : null;

  /// Creates an [UnknownManagedAgentError] from JSON.
  factory UnknownManagedAgentError.fromJson(Map<String, dynamic> json) {
    return UnknownManagedAgentError(
      type: json['type'] as String? ?? 'unknown_error',
      message: json['message'] as String,
      retryStatus: RetryStatus.fromJson(
        json['retry_status'] as Map<String, dynamic>,
      ),
      rawJson: json,
    );
  }

  /// Converts to JSON.
  ///
  /// When [rawJson] is present, it is used as the base to preserve unknown
  /// fields. Lossless scalar fields (`type`, `message`) are overwritten, and
  /// `retry_status` is merged so the current [retryStatus] state is reflected
  /// while preserving any extra unknown fields from the original payload
  /// (e.g. `retry_at`).
  Map<String, dynamic> toJson() {
    final retryStatusJson = retryStatus.toJson();
    if (rawJson != null) {
      final rawRetryStatus = rawJson!['retry_status'];
      final mergedRetryStatus = rawRetryStatus is Map<String, dynamic>
          ? {...rawRetryStatus, ...retryStatusJson}
          : retryStatusJson;
      return {
        ...rawJson!,
        'type': type,
        'message': message,
        'retry_status': mergedRetryStatus,
      };
    }
    return {'type': type, 'message': message, 'retry_status': retryStatusJson};
  }

  /// Creates a copy with replaced values.
  UnknownManagedAgentError copyWith({
    String? type,
    String? message,
    RetryStatus? retryStatus,
    Object? rawJson = unsetCopyWithValue,
  }) {
    return UnknownManagedAgentError(
      type: type ?? this.type,
      message: message ?? this.message,
      retryStatus: retryStatus ?? this.retryStatus,
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
          type == other.type &&
          message == other.message &&
          retryStatus == other.retryStatus &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode =>
      Object.hash(type, message, retryStatus, mapDeepHashCode(rawJson));

  @override
  String toString() =>
      'UnknownManagedAgentError('
      'type: $type, '
      'message: $message, '
      'retryStatus: $retryStatus, '
      'rawJson: $rawJson)';
}
