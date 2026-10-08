import 'package:meta/meta.dart';
import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';
import 'websocket_json_helpers.dart';

/// Identifies a saved tool result or approval required for a pending steer.
///
/// Known variants are [ResponsesSteerFunctionCallOutput],
/// [ResponsesSteerCustomCallOutput], [ResponsesSteerComputerCallOutput],
/// [ResponsesSteerShellCallOutput], [ResponsesSteerApplyPatchCallOutput],
/// [ResponsesSteerToolSearchOutput], and [ResponsesSteerMcpApprovalResponse].
/// [UnknownResponsesSteerRequiredInput] retains future kinds. These stubs contain
/// no results, approval decision or safety acknowledgement: supply
/// saved results through the ordinary response-create input models.
@immutable
sealed class ResponsesSteerRequiredInput {
  /// Creates a required-input stub.
  const ResponsesSteerRequiredInput();

  /// The fixed kind for a known stub, or the provider's future discriminator.
  String get type;

  /// Parses identifying fields, failing on malformed known closed shapes.
  factory ResponsesSteerRequiredInput.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotResponsesJson(json, 'ResponsesSteerRequiredInput');
    final type = requireJsonString(
      snapshot['type'],
      'ResponsesSteerRequiredInput.type',
    );
    return switch (type) {
      'function_call_output' => ResponsesSteerFunctionCallOutput.fromJson(
        snapshot,
      ),
      'custom_tool_call_output' => ResponsesSteerCustomCallOutput.fromJson(
        snapshot,
      ),
      'computer_call_output' => ResponsesSteerComputerCallOutput.fromJson(
        snapshot,
      ),
      'shell_call_output' => ResponsesSteerShellCallOutput.fromJson(snapshot),
      'apply_patch_call_output' => ResponsesSteerApplyPatchCallOutput.fromJson(
        snapshot,
      ),
      'tool_search_output' => ResponsesSteerToolSearchOutput.fromJson(snapshot),
      'mcp_approval_response' => ResponsesSteerMcpApprovalResponse.fromJson(
        snapshot,
      ),
      _ => UnknownResponsesSteerRequiredInput(type: type, rawJson: snapshot),
    };
  }

  /// Serializes identifying fields only; this is not a completed tool result.
  Map<String, dynamic> toJson();
}

/// Identifies a saved `function_call_output` continuation input.
@immutable
class ResponsesSteerFunctionCallOutput extends ResponsesSteerRequiredInput {
  /// Required `call_id` identity.
  final String callId;

  /// Required `name` identity.
  final String name;

  /// Creates identifying metadata only.
  const ResponsesSteerFunctionCallOutput({
    required this.callId,
    required this.name,
  });
  @override
  String get type => 'function_call_output';

  /// Validates the fixed kind and its complete closed identifying shape.
  factory ResponsesSteerFunctionCallOutput.fromJson(Map<String, dynamic> json) {
    const context = 'ResponsesSteerFunctionCallOutput';
    requireJsonType(json, 'function_call_output', context);
    _requireInputKeys(json, const {'type', 'call_id', 'name'}, context);
    return ResponsesSteerFunctionCallOutput(
      callId: requireJsonString(json['call_id'], '$context.call_id'),
      name: requireJsonString(json['name'], '$context.name'),
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'name': name,
  };

  /// Copies every required identity.
  ResponsesSteerFunctionCallOutput copyWith({String? callId, String? name}) =>
      ResponsesSteerFunctionCallOutput(
        callId: callId ?? this.callId,
        name: name ?? this.name,
      );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerFunctionCallOutput &&
          runtimeType == other.runtimeType &&
          callId == other.callId &&
          name == other.name;
  @override
  int get hashCode => Object.hash(callId, name);
  @override
  String toString() =>
      'ResponsesSteerFunctionCallOutput(callId: [REDACTED], name: [REDACTED])';
}

/// Identifies a saved `custom_tool_call_output` continuation input.
@immutable
class ResponsesSteerCustomCallOutput extends ResponsesSteerRequiredInput {
  /// Required `call_id` identity.
  final String callId;

  /// Creates identifying metadata only.
  const ResponsesSteerCustomCallOutput({required this.callId});
  @override
  String get type => 'custom_tool_call_output';

  /// Validates the fixed kind and its complete closed identifying shape.
  factory ResponsesSteerCustomCallOutput.fromJson(Map<String, dynamic> json) {
    const context = 'ResponsesSteerCustomCallOutput';
    requireJsonType(json, 'custom_tool_call_output', context);
    _requireInputKeys(json, const {'type', 'call_id'}, context);
    return ResponsesSteerCustomCallOutput(
      callId: requireJsonString(json['call_id'], '$context.call_id'),
    );
  }
  @override
  Map<String, dynamic> toJson() => {'type': type, 'call_id': callId};

  /// Copies every required identity.
  ResponsesSteerCustomCallOutput copyWith({String? callId}) =>
      ResponsesSteerCustomCallOutput(callId: callId ?? this.callId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerCustomCallOutput &&
          runtimeType == other.runtimeType &&
          callId == other.callId;
  @override
  int get hashCode => callId.hashCode;
  @override
  String toString() => 'ResponsesSteerCustomCallOutput(callId: [REDACTED])';
}

/// Identifies a saved `computer_call_output` continuation input.
@immutable
class ResponsesSteerComputerCallOutput extends ResponsesSteerRequiredInput {
  /// Required `call_id` identity.
  final String callId;

  /// Creates identifying metadata only.
  const ResponsesSteerComputerCallOutput({required this.callId});
  @override
  String get type => 'computer_call_output';

  /// Validates the fixed kind and its complete closed identifying shape.
  factory ResponsesSteerComputerCallOutput.fromJson(Map<String, dynamic> json) {
    const context = 'ResponsesSteerComputerCallOutput';
    requireJsonType(json, 'computer_call_output', context);
    _requireInputKeys(json, const {'type', 'call_id'}, context);
    return ResponsesSteerComputerCallOutput(
      callId: requireJsonString(json['call_id'], '$context.call_id'),
    );
  }
  @override
  Map<String, dynamic> toJson() => {'type': type, 'call_id': callId};

  /// Copies every required identity.
  ResponsesSteerComputerCallOutput copyWith({String? callId}) =>
      ResponsesSteerComputerCallOutput(callId: callId ?? this.callId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerComputerCallOutput &&
          runtimeType == other.runtimeType &&
          callId == other.callId;
  @override
  int get hashCode => callId.hashCode;
  @override
  String toString() => 'ResponsesSteerComputerCallOutput(callId: [REDACTED])';
}

/// Identifies a saved `shell_call_output` continuation input.
@immutable
class ResponsesSteerShellCallOutput extends ResponsesSteerRequiredInput {
  /// Required `call_id` identity.
  final String callId;

  /// Creates identifying metadata only.
  const ResponsesSteerShellCallOutput({required this.callId});
  @override
  String get type => 'shell_call_output';

  /// Validates the fixed kind and its complete closed identifying shape.
  factory ResponsesSteerShellCallOutput.fromJson(Map<String, dynamic> json) {
    const context = 'ResponsesSteerShellCallOutput';
    requireJsonType(json, 'shell_call_output', context);
    _requireInputKeys(json, const {'type', 'call_id'}, context);
    return ResponsesSteerShellCallOutput(
      callId: requireJsonString(json['call_id'], '$context.call_id'),
    );
  }
  @override
  Map<String, dynamic> toJson() => {'type': type, 'call_id': callId};

  /// Copies every required identity.
  ResponsesSteerShellCallOutput copyWith({String? callId}) =>
      ResponsesSteerShellCallOutput(callId: callId ?? this.callId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerShellCallOutput &&
          runtimeType == other.runtimeType &&
          callId == other.callId;
  @override
  int get hashCode => callId.hashCode;
  @override
  String toString() => 'ResponsesSteerShellCallOutput(callId: [REDACTED])';
}

/// Identifies a saved `apply_patch_call_output` continuation input.
@immutable
class ResponsesSteerApplyPatchCallOutput extends ResponsesSteerRequiredInput {
  /// Required `call_id` identity.
  final String callId;

  /// Creates identifying metadata only.
  const ResponsesSteerApplyPatchCallOutput({required this.callId});
  @override
  String get type => 'apply_patch_call_output';

  /// Validates the fixed kind and its complete closed identifying shape.
  factory ResponsesSteerApplyPatchCallOutput.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'ResponsesSteerApplyPatchCallOutput';
    requireJsonType(json, 'apply_patch_call_output', context);
    _requireInputKeys(json, const {'type', 'call_id'}, context);
    return ResponsesSteerApplyPatchCallOutput(
      callId: requireJsonString(json['call_id'], '$context.call_id'),
    );
  }
  @override
  Map<String, dynamic> toJson() => {'type': type, 'call_id': callId};

  /// Copies every required identity.
  ResponsesSteerApplyPatchCallOutput copyWith({String? callId}) =>
      ResponsesSteerApplyPatchCallOutput(callId: callId ?? this.callId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerApplyPatchCallOutput &&
          runtimeType == other.runtimeType &&
          callId == other.callId;
  @override
  int get hashCode => callId.hashCode;
  @override
  String toString() => 'ResponsesSteerApplyPatchCallOutput(callId: [REDACTED])';
}

/// Identifies a saved `tool_search_output` continuation input.
@immutable
class ResponsesSteerToolSearchOutput extends ResponsesSteerRequiredInput {
  /// Required `call_id` identity.
  final String callId;

  /// Creates identifying metadata only.
  const ResponsesSteerToolSearchOutput({required this.callId});
  @override
  String get type => 'tool_search_output';

  /// Tool-search continuation always supplies client execution.
  String get execution => 'client';

  /// Validates the fixed kind and its complete closed identifying shape.
  factory ResponsesSteerToolSearchOutput.fromJson(Map<String, dynamic> json) {
    const context = 'ResponsesSteerToolSearchOutput';
    requireJsonType(json, 'tool_search_output', context);
    _requireInputKeys(json, const {'type', 'call_id', 'execution'}, context);
    if (json['execution'] != 'client') {
      throw const FormatException('$context.execution: expected client');
    }
    return ResponsesSteerToolSearchOutput(
      callId: requireJsonString(json['call_id'], '$context.call_id'),
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'execution': execution,
  };

  /// Copies every required identity.
  ResponsesSteerToolSearchOutput copyWith({String? callId}) =>
      ResponsesSteerToolSearchOutput(callId: callId ?? this.callId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerToolSearchOutput &&
          runtimeType == other.runtimeType &&
          callId == other.callId;
  @override
  int get hashCode => callId.hashCode;
  @override
  String toString() =>
      'ResponsesSteerToolSearchOutput(callId: [REDACTED], execution: client)';
}

/// Identifies a saved `mcp_approval_response` continuation input.
@immutable
class ResponsesSteerMcpApprovalResponse extends ResponsesSteerRequiredInput {
  /// Required `approval_request_id` identity.
  final String approvalRequestId;

  /// Creates identifying metadata only.
  const ResponsesSteerMcpApprovalResponse({required this.approvalRequestId});
  @override
  String get type => 'mcp_approval_response';

  /// Validates the fixed kind and its complete closed identifying shape.
  factory ResponsesSteerMcpApprovalResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'ResponsesSteerMcpApprovalResponse';
    requireJsonType(json, 'mcp_approval_response', context);
    _requireInputKeys(json, const {'type', 'approval_request_id'}, context);
    return ResponsesSteerMcpApprovalResponse(
      approvalRequestId: requireJsonString(
        json['approval_request_id'],
        '$context.approval_request_id',
      ),
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'approval_request_id': approvalRequestId,
  };

  /// Copies every required identity.
  ResponsesSteerMcpApprovalResponse copyWith({String? approvalRequestId}) =>
      ResponsesSteerMcpApprovalResponse(
        approvalRequestId: approvalRequestId ?? this.approvalRequestId,
      );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerMcpApprovalResponse &&
          runtimeType == other.runtimeType &&
          approvalRequestId == other.approvalRequestId;
  @override
  int get hashCode => approvalRequestId.hashCode;
  @override
  String toString() =>
      'ResponsesSteerMcpApprovalResponse(approvalRequestId: [REDACTED])';
}

/// A future identifying stub with deeply immutable parsed raw JSON.
@immutable
class UnknownResponsesSteerRequiredInput extends ResponsesSteerRequiredInput {
  @override
  final String type;

  /// Original future identifying metadata.
  final Map<String, dynamic> rawJson;

  /// Creates a future stub, retaining const caller-owned JSON semantics.
  const UnknownResponsesSteerRequiredInput({
    required this.type,
    required this.rawJson,
  });

  /// Parses a future kind without accepting malformed known kinds.
  factory UnknownResponsesSteerRequiredInput.fromJson(
    Map<String, dynamic> json,
  ) {
    final parsed = ResponsesSteerRequiredInput.fromJson(json);
    if (parsed is UnknownResponsesSteerRequiredInput) return parsed;
    throw const FormatException(
      'UnknownResponsesSteerRequiredInput.type: expected a future kind',
    );
  }
  @override
  Map<String, dynamic> toJson() {
    if (_knownSteerInputTypes.contains(type)) {
      throw const FormatException(
        'UnknownResponsesSteerRequiredInput.type: expected a future kind',
      );
    }
    snapshotResponsesJson(rawJson, 'UnknownResponsesSteerRequiredInput');
    return _valueJson();
  }

  Map<String, dynamic> _valueJson() => {...rawJson, 'type': type};

  /// Copies the discriminator and raw metadata; typed type wins on collision.
  UnknownResponsesSteerRequiredInput copyWith({
    String? type,
    Map<String, dynamic>? rawJson,
  }) => UnknownResponsesSteerRequiredInput(
    type: type ?? this.type,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownResponsesSteerRequiredInput &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_valueJson(), other._valueJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_valueJson()));
  @override
  String toString() =>
      'UnknownResponsesSteerRequiredInput(type: [REDACTED], rawJson: ${rawJson.length} entries)';
}

void _requireInputKeys(
  Map<String, dynamic> json,
  Set<String> keys,
  String context,
) {
  if (json.keys.any((key) => !keys.contains(key))) {
    throw FormatException('$context: unsupported identifying member');
  }
}

const _knownSteerInputTypes = {
  'function_call_output',
  'custom_tool_call_output',
  'computer_call_output',
  'shell_call_output',
  'apply_patch_call_output',
  'tool_search_output',
  'mcp_approval_response',
};
