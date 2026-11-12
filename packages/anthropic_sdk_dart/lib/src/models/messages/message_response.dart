import 'package:meta/meta.dart';

import 'message.dart';

/// A created [Message] and metadata from its HTTP response.
@immutable
final class MessageResponse {
  /// Creates a message response.
  const MessageResponse({
    required this.message,
    required this.statusCode,
    this.requestId,
    this.workspaceId,
    this.awsRequestId,
    this.azureRequestId,
  });

  /// The decoded message.
  final Message message;

  /// The HTTP status code of the response.
  final int statusCode;

  /// The Claude request ID, or a safe AWS or Azure ID if it is unavailable.
  final String? requestId;

  /// The provider's workspace ID, when present and safe to expose.
  final String? workspaceId;

  /// The AWS request ID from `x-amzn-requestid` or an AWS header alias.
  final String? awsRequestId;

  /// The `apim-request-id` value for Azure API Management tracing, when available.
  final String? azureRequestId;
}
