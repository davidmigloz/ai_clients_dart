import 'dart:collection';
import 'package:meta/meta.dart';
import '../common/equality_helpers.dart';
import '../responses/items/item.dart' show Item;
import '../responses/items/output_item.dart' show OutputItem;
import 'live_json_helpers.dart';

/// A finite, deeply immutable canonical Live backend payload value.
@immutable
sealed class LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputValue();

  /// Returns the exact canonical wire value.
  Object? toJson();

  /// Validates all declared fields and nested contracts.
  void validate();
  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is LiveInputValue &&
      mapsDeepEqual({'value': toJson()}, {'value': other.toJson()});
  @override
  int get hashCode =>
      Object.hash(runtimeType, mapDeepHashCode({'value': toJson()}));
  @override
  String toString() => 'LiveInputValue([REDACTED])';
}

/// Canonical writable InputItem, distinct from standalone Responses DTOs.
/// Concrete adapters: [LiveEasyInputMessage], [LiveInputMessage], [LiveInputOutputMessage], [LiveInputFileSearchToolCall], [LiveInputComputerToolCall], [LiveInputComputerCallOutputItemParam], [LiveInputWebSearchToolCall], [LiveInputFunctionToolCall], [LiveInputFunctionCallOutputItemParam], [LiveInputToolSearchCallItemParam], [LiveInputToolSearchOutputItemParam], [LiveInputAdditionalToolsItemParam], [LiveInputResponseConfigurationUpdateItemParam], [LiveInputReasoningItem], [LiveInputCompactionSummaryItemParam], [LiveInputImageGenToolCall], [LiveInputCodeInterpreterToolCall], [LiveInputLocalShellToolCall], [LiveInputLocalShellToolCallOutput], [LiveInputFunctionShellCallItemParam], [LiveInputFunctionShellCallOutputItemParam], [LiveInputApplyPatchToolCallItemParam], [LiveInputApplyPatchToolCallOutputItemParam], [LiveInputMCPListTools], [LiveInputMCPApprovalRequest], [LiveInputMCPApprovalResponse], [LiveInputMCPToolCall], [LiveInputCustomToolCallOutput], [LiveInputCustomToolCall], [LiveInputCompactionTriggerItemParam], [LiveInputItemReferenceParam], [LiveInputProgramItemParam], [LiveInputProgramOutputItemParam].
/// Includes all 33 reachable item branch contracts; an omitted message/reference
/// type and nullable caller/result IDs retain their original wire presence.
/// Existing Responses input/output objects can be detached with fromItem or
/// fromOutputItem where their serialized contracts match this canonical union.
@immutable
sealed class LiveInputItem extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputItem();

  /// Parses and validates the canonical value.
  factory LiveInputItem.fromItem(Item item) =>
      LiveInputItem.fromJson(item.toJson());

  /// Parses and validates the canonical value.
  factory LiveInputItem.fromOutputItem(OutputItem item) =>
      LiveInputItem.fromJson(item.toJson());

  /// Parses and validates the canonical value.
  factory LiveInputItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if ((type == null || type == 'message') && json.containsKey('role')) {
      // Message contracts overlap: future metadata cannot decide their branch.
      if (_matchesInputSchema(
        _inputSchemas['OutputMessage'] as Map<String, dynamic>,
        json,
      )) {
        return LiveInputOutputMessage.fromJson(json);
      }
      if (_matchesInputSchema(
        _inputSchemas['InputMessage'] as Map<String, dynamic>,
        json,
      )) {
        return LiveInputMessage.fromJson(json);
      }
      if (_matchesInputSchema(
        _inputSchemas['EasyInputMessage'] as Map<String, dynamic>,
        json,
      )) {
        return LiveEasyInputMessage.fromJson(json);
      }
      if (type == null &&
          _matchesInputSchema(
            _inputSchemas['ItemReferenceParam'] as Map<String, dynamic>,
            json,
          )) {
        return LiveInputItemReferenceParam.fromJson(json);
      }
      return LiveEasyInputMessage.fromJson(json);
    }
    if (type == null && json.containsKey('id')) {
      return LiveInputItemReferenceParam.fromJson(json);
    }
    return switch (type) {
      'file_search_call' => LiveInputFileSearchToolCall.fromJson(json),
      'computer_call' => LiveInputComputerToolCall.fromJson(json),
      'computer_call_output' => LiveInputComputerCallOutputItemParam.fromJson(
        json,
      ),
      'web_search_call' => LiveInputWebSearchToolCall.fromJson(json),
      'function_call' => LiveInputFunctionToolCall.fromJson(json),
      'function_call_output' => LiveInputFunctionCallOutputItemParam.fromJson(
        json,
      ),
      'tool_search_call' => LiveInputToolSearchCallItemParam.fromJson(json),
      'tool_search_output' => LiveInputToolSearchOutputItemParam.fromJson(json),
      'additional_tools' => LiveInputAdditionalToolsItemParam.fromJson(json),
      'configuration_update' =>
        LiveInputResponseConfigurationUpdateItemParam.fromJson(json),
      'reasoning' => LiveInputReasoningItem.fromJson(json),
      'compaction' => LiveInputCompactionSummaryItemParam.fromJson(json),
      'image_generation_call' => LiveInputImageGenToolCall.fromJson(json),
      'code_interpreter_call' => LiveInputCodeInterpreterToolCall.fromJson(
        json,
      ),
      'local_shell_call' => LiveInputLocalShellToolCall.fromJson(json),
      'local_shell_call_output' => LiveInputLocalShellToolCallOutput.fromJson(
        json,
      ),
      'shell_call' => LiveInputFunctionShellCallItemParam.fromJson(json),
      'shell_call_output' => LiveInputFunctionShellCallOutputItemParam.fromJson(
        json,
      ),
      'apply_patch_call' => LiveInputApplyPatchToolCallItemParam.fromJson(json),
      'apply_patch_call_output' =>
        LiveInputApplyPatchToolCallOutputItemParam.fromJson(json),
      'mcp_list_tools' => LiveInputMCPListTools.fromJson(json),
      'mcp_approval_request' => LiveInputMCPApprovalRequest.fromJson(json),
      'mcp_approval_response' => LiveInputMCPApprovalResponse.fromJson(json),
      'mcp_call' => LiveInputMCPToolCall.fromJson(json),
      'custom_tool_call_output' => LiveInputCustomToolCallOutput.fromJson(json),
      'custom_tool_call' => LiveInputCustomToolCall.fromJson(json),
      'compaction_trigger' => LiveInputCompactionTriggerItemParam.fromJson(
        json,
      ),
      'item_reference' => LiveInputItemReferenceParam.fromJson(json),
      'program' => LiveInputProgramItemParam.fromJson(json),
      'program_output' => LiveInputProgramOutputItemParam.fromJson(json),
      _ => throw const FormatException(
        'LiveInputItem.type: unsupported canonical input item',
      ),
    };
  }
  @override
  Map<String, dynamic> toJson();
}

/// Immutable typed adapter for EasyInputMessage.
@immutable
final class LiveEasyInputMessage extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveEasyInputMessage.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveEasyInputMessage'),
        'LiveEasyInputMessage',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'content', 'phase', 'role', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `content` value.
  LiveEasyInputMessageContentValue get content =>
      LiveEasyInputMessageContentValue.fromJson(rawJson['content']);

  /// Canonical `phase` value.
  LiveInputMessagePhase? get phase => rawJson['phase'] == null
      ? null
      : LiveInputMessagePhase.fromJson(rawJson['phase']);

  /// Distinguishes absent `phase` from an explicit null.
  bool get hasPhase => rawJson.containsKey('phase');

  /// Canonical `role` value.
  String get role => rawJson['role'] as String;

  /// Canonical `type` value.
  String? get type =>
      rawJson['type'] == null ? null : (rawJson['type'] as String);

  /// Distinguishes absent `type` from an explicit null.
  bool get hasType => rawJson.containsKey('type');
  @override
  void validate() => _validateInputComponent(
    'EasyInputMessage',
    rawJson,
    'LiveEasyInputMessage',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveEasyInputMessage copyWith({
    Object? content = liveUnset,
    Object? phase = liveUnset,
    bool clearPhase = false,
    Object? role = liveUnset,
    Object? type = liveUnset,
    bool clearType = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveEasyInputMessage.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'content': content, 'phase': phase, 'role': role, 'type': type},
      <String>{if (clearPhase) 'phase', if (clearType) 'type'},
      'LiveEasyInputMessage',
    ),
  );
  @override
  String toString() =>
      'LiveEasyInputMessage(content: [REDACTED], phase: [REDACTED], role: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for AdditionalToolsItemParam.
@immutable
final class LiveInputAdditionalToolsItemParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputAdditionalToolsItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputAdditionalToolsItemParam'),
        'LiveInputAdditionalToolsItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'id', 'role', 'tools', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `role` value.
  String get role => rawJson['role'] as String;

  /// Canonical `tools` value.
  List<LiveInputTool> get tools =>
      List.unmodifiable((rawJson['tools'] as List).map(LiveInputTool.fromJson));

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'AdditionalToolsItemParam',
    rawJson,
    'LiveInputAdditionalToolsItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputAdditionalToolsItemParam copyWith({
    Object? id = liveUnset,
    bool clearId = false,
    Object? tools = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputAdditionalToolsItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'id': id, 'tools': tools},
      <String>{if (clearId) 'id'},
      'LiveInputAdditionalToolsItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputAdditionalToolsItemParam(id: [REDACTED], role: [REDACTED], tools: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ApplyPatchCreateFileOperationParam.
@immutable
final class LiveInputApplyPatchCreateFileOperationParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputApplyPatchCreateFileOperationParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputApplyPatchCreateFileOperationParam'),
        'LiveInputApplyPatchCreateFileOperationParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'diff', 'path', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `diff` value.
  String get diff => rawJson['diff'] as String;

  /// Canonical `path` value.
  String get path => rawJson['path'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ApplyPatchCreateFileOperationParam',
    rawJson,
    'LiveInputApplyPatchCreateFileOperationParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputApplyPatchCreateFileOperationParam copyWith({
    Object? diff = liveUnset,
    Object? path = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputApplyPatchCreateFileOperationParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'diff': diff, 'path': path},
      <String>{},
      'LiveInputApplyPatchCreateFileOperationParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputApplyPatchCreateFileOperationParam(diff: [REDACTED], path: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ApplyPatchDeleteFileOperationParam.
@immutable
final class LiveInputApplyPatchDeleteFileOperationParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputApplyPatchDeleteFileOperationParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputApplyPatchDeleteFileOperationParam'),
        'LiveInputApplyPatchDeleteFileOperationParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'path', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `path` value.
  String get path => rawJson['path'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ApplyPatchDeleteFileOperationParam',
    rawJson,
    'LiveInputApplyPatchDeleteFileOperationParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputApplyPatchDeleteFileOperationParam copyWith({
    Object? path = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputApplyPatchDeleteFileOperationParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'path': path},
      <String>{},
      'LiveInputApplyPatchDeleteFileOperationParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputApplyPatchDeleteFileOperationParam(path: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ApplyPatchToolCallItemParam.
@immutable
final class LiveInputApplyPatchToolCallItemParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputApplyPatchToolCallItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputApplyPatchToolCallItemParam'),
        'LiveInputApplyPatchToolCallItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'call_id',
    'caller',
    'id',
    'operation',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `call_id` value.
  String get callId => rawJson['call_id'] as String;

  /// Canonical `caller` value.
  LiveInputToolCallCallerParam? get caller => rawJson['caller'] == null
      ? null
      : LiveInputToolCallCallerParam.fromJson(rawJson['caller']);

  /// Distinguishes absent `caller` from an explicit null.
  bool get hasCaller => rawJson.containsKey('caller');

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `operation` value.
  LiveInputApplyPatchOperationParam get operation =>
      LiveInputApplyPatchOperationParam.fromJson(rawJson['operation']);

  /// Canonical `status` value.
  LiveInputApplyPatchCallStatusParam get status =>
      LiveInputApplyPatchCallStatusParam.fromJson(rawJson['status']);

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ApplyPatchToolCallItemParam',
    rawJson,
    'LiveInputApplyPatchToolCallItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputApplyPatchToolCallItemParam copyWith({
    Object? callId = liveUnset,
    Object? caller = liveUnset,
    bool clearCaller = false,
    Object? id = liveUnset,
    bool clearId = false,
    Object? operation = liveUnset,
    Object? status = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputApplyPatchToolCallItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'call_id': callId,
        'caller': caller,
        'id': id,
        'operation': operation,
        'status': status,
      },
      <String>{if (clearCaller) 'caller', if (clearId) 'id'},
      'LiveInputApplyPatchToolCallItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputApplyPatchToolCallItemParam(call_id: [REDACTED], caller: [REDACTED], id: [REDACTED], operation: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ApplyPatchToolCallOutputItemParam.
@immutable
final class LiveInputApplyPatchToolCallOutputItemParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputApplyPatchToolCallOutputItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputApplyPatchToolCallOutputItemParam'),
        'LiveInputApplyPatchToolCallOutputItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'call_id',
    'caller',
    'id',
    'output',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `call_id` value.
  String get callId => rawJson['call_id'] as String;

  /// Canonical `caller` value.
  LiveInputToolCallCallerParam? get caller => rawJson['caller'] == null
      ? null
      : LiveInputToolCallCallerParam.fromJson(rawJson['caller']);

  /// Distinguishes absent `caller` from an explicit null.
  bool get hasCaller => rawJson.containsKey('caller');

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `output` value.
  String? get output =>
      rawJson['output'] == null ? null : (rawJson['output'] as String);

  /// Distinguishes absent `output` from an explicit null.
  bool get hasOutput => rawJson.containsKey('output');

  /// Canonical `status` value.
  LiveInputApplyPatchCallOutputStatusParam get status =>
      LiveInputApplyPatchCallOutputStatusParam.fromJson(rawJson['status']);

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ApplyPatchToolCallOutputItemParam',
    rawJson,
    'LiveInputApplyPatchToolCallOutputItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputApplyPatchToolCallOutputItemParam copyWith({
    Object? callId = liveUnset,
    Object? caller = liveUnset,
    bool clearCaller = false,
    Object? id = liveUnset,
    bool clearId = false,
    Object? output = liveUnset,
    bool clearOutput = false,
    Object? status = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputApplyPatchToolCallOutputItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'call_id': callId,
        'caller': caller,
        'id': id,
        'output': output,
        'status': status,
      },
      <String>{
        if (clearCaller) 'caller',
        if (clearId) 'id',
        if (clearOutput) 'output',
      },
      'LiveInputApplyPatchToolCallOutputItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputApplyPatchToolCallOutputItemParam(call_id: [REDACTED], caller: [REDACTED], id: [REDACTED], output: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ApplyPatchToolParam.
@immutable
final class LiveInputApplyPatchToolParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputApplyPatchToolParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputApplyPatchToolParam'),
        'LiveInputApplyPatchToolParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'allowed_callers', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `allowed_callers` value.
  List<LiveInputCallableToolAllowedCaller>? get allowedCallers =>
      rawJson['allowed_callers'] == null
      ? null
      : List.unmodifiable(
          (rawJson['allowed_callers'] as List).map(
            LiveInputCallableToolAllowedCaller.fromJson,
          ),
        );

  /// Distinguishes absent `allowed_callers` from an explicit null.
  bool get hasAllowedCallers => rawJson.containsKey('allowed_callers');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ApplyPatchToolParam',
    rawJson,
    'LiveInputApplyPatchToolParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputApplyPatchToolParam copyWith({
    Object? allowedCallers = liveUnset,
    bool clearAllowedCallers = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputApplyPatchToolParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'allowed_callers': allowedCallers},
      <String>{if (clearAllowedCallers) 'allowed_callers'},
      'LiveInputApplyPatchToolParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputApplyPatchToolParam(allowed_callers: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ApplyPatchUpdateFileOperationParam.
@immutable
final class LiveInputApplyPatchUpdateFileOperationParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputApplyPatchUpdateFileOperationParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputApplyPatchUpdateFileOperationParam'),
        'LiveInputApplyPatchUpdateFileOperationParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'diff', 'path', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `diff` value.
  String get diff => rawJson['diff'] as String;

  /// Canonical `path` value.
  String get path => rawJson['path'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ApplyPatchUpdateFileOperationParam',
    rawJson,
    'LiveInputApplyPatchUpdateFileOperationParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputApplyPatchUpdateFileOperationParam copyWith({
    Object? diff = liveUnset,
    Object? path = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputApplyPatchUpdateFileOperationParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'diff': diff, 'path': path},
      <String>{},
      'LiveInputApplyPatchUpdateFileOperationParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputApplyPatchUpdateFileOperationParam(diff: [REDACTED], path: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ApproximateLocation.
@immutable
final class LiveInputApproximateLocation extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputApproximateLocation.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputApproximateLocation'),
        'LiveInputApproximateLocation',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'city',
    'country',
    'region',
    'timezone',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `city` value.
  String? get city =>
      rawJson['city'] == null ? null : (rawJson['city'] as String);

  /// Distinguishes absent `city` from an explicit null.
  bool get hasCity => rawJson.containsKey('city');

  /// Canonical `country` value.
  String? get country =>
      rawJson['country'] == null ? null : (rawJson['country'] as String);

  /// Distinguishes absent `country` from an explicit null.
  bool get hasCountry => rawJson.containsKey('country');

  /// Canonical `region` value.
  String? get region =>
      rawJson['region'] == null ? null : (rawJson['region'] as String);

  /// Distinguishes absent `region` from an explicit null.
  bool get hasRegion => rawJson.containsKey('region');

  /// Canonical `timezone` value.
  String? get timezone =>
      rawJson['timezone'] == null ? null : (rawJson['timezone'] as String);

  /// Distinguishes absent `timezone` from an explicit null.
  bool get hasTimezone => rawJson.containsKey('timezone');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ApproximateLocation',
    rawJson,
    'LiveInputApproximateLocation',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputApproximateLocation copyWith({
    Object? city = liveUnset,
    bool clearCity = false,
    Object? country = liveUnset,
    bool clearCountry = false,
    Object? region = liveUnset,
    bool clearRegion = false,
    Object? timezone = liveUnset,
    bool clearTimezone = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputApproximateLocation.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'city': city,
        'country': country,
        'region': region,
        'timezone': timezone,
      },
      <String>{
        if (clearCity) 'city',
        if (clearCountry) 'country',
        if (clearRegion) 'region',
        if (clearTimezone) 'timezone',
      },
      'LiveInputApproximateLocation',
    ),
  );
  @override
  String toString() =>
      'LiveInputApproximateLocation(city: [REDACTED], country: [REDACTED], region: [REDACTED], timezone: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for AutoCodeInterpreterToolParam.
@immutable
final class LiveInputAutoCodeInterpreterToolParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputAutoCodeInterpreterToolParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputAutoCodeInterpreterToolParam'),
        'LiveInputAutoCodeInterpreterToolParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'file_ids',
    'memory_limit',
    'network_policy',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `file_ids` value.
  List<String>? get fileIds => rawJson['file_ids'] == null
      ? null
      : List.unmodifiable(
          (rawJson['file_ids'] as List).map((value) => value as String),
        );

  /// Distinguishes absent `file_ids` from an explicit null.
  bool get hasFileIds => rawJson.containsKey('file_ids');

  /// Canonical `memory_limit` value.
  LiveInputContainerMemoryLimit? get memoryLimit =>
      rawJson['memory_limit'] == null
      ? null
      : LiveInputContainerMemoryLimit.fromJson(rawJson['memory_limit']);

  /// Distinguishes absent `memory_limit` from an explicit null.
  bool get hasMemoryLimit => rawJson.containsKey('memory_limit');

  /// Canonical `network_policy` value.
  LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue? get networkPolicy =>
      rawJson['network_policy'] == null
      ? null
      : LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue.fromJson(
          rawJson['network_policy'],
        );

  /// Distinguishes absent `network_policy` from an explicit null.
  bool get hasNetworkPolicy => rawJson.containsKey('network_policy');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'AutoCodeInterpreterToolParam',
    rawJson,
    'LiveInputAutoCodeInterpreterToolParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputAutoCodeInterpreterToolParam copyWith({
    Object? fileIds = liveUnset,
    bool clearFileIds = false,
    Object? memoryLimit = liveUnset,
    bool clearMemoryLimit = false,
    Object? networkPolicy = liveUnset,
    bool clearNetworkPolicy = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputAutoCodeInterpreterToolParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'file_ids': fileIds,
        'memory_limit': memoryLimit,
        'network_policy': networkPolicy,
      },
      <String>{
        if (clearFileIds) 'file_ids',
        if (clearMemoryLimit) 'memory_limit',
        if (clearNetworkPolicy) 'network_policy',
      },
      'LiveInputAutoCodeInterpreterToolParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputAutoCodeInterpreterToolParam(file_ids: [REDACTED], memory_limit: [REDACTED], network_policy: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ClickParam.
@immutable
final class LiveInputClickParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputClickParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputClickParam'),
        'LiveInputClickParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'button', 'keys', 'type', 'x', 'y'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `button` value.
  LiveInputClickButtonType get button =>
      LiveInputClickButtonType.fromJson(rawJson['button']);

  /// Canonical `keys` value.
  List<String>? get keys => rawJson['keys'] == null
      ? null
      : List.unmodifiable(
          (rawJson['keys'] as List).map((value) => value as String),
        );

  /// Distinguishes absent `keys` from an explicit null.
  bool get hasKeys => rawJson.containsKey('keys');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `x` value.
  int get x => rawJson['x'] as int;

  /// Canonical `y` value.
  int get y => rawJson['y'] as int;
  @override
  void validate() =>
      _validateInputComponent('ClickParam', rawJson, 'LiveInputClickParam');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputClickParam copyWith({
    Object? button = liveUnset,
    Object? keys = liveUnset,
    bool clearKeys = false,
    Object? x = liveUnset,
    Object? y = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputClickParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'button': button, 'keys': keys, 'x': x, 'y': y},
      <String>{if (clearKeys) 'keys'},
      'LiveInputClickParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputClickParam(button: [REDACTED], keys: [REDACTED], type: [REDACTED], x: [REDACTED], y: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for CodeInterpreterOutputImage.
@immutable
final class LiveInputCodeInterpreterOutputImage extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputCodeInterpreterOutputImage.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputCodeInterpreterOutputImage'),
        'LiveInputCodeInterpreterOutputImage',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'type', 'url'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `url` value.
  String get url => rawJson['url'] as String;
  @override
  void validate() => _validateInputComponent(
    'CodeInterpreterOutputImage',
    rawJson,
    'LiveInputCodeInterpreterOutputImage',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputCodeInterpreterOutputImage copyWith({
    Object? url = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputCodeInterpreterOutputImage.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'url': url},
      <String>{},
      'LiveInputCodeInterpreterOutputImage',
    ),
  );
  @override
  String toString() =>
      'LiveInputCodeInterpreterOutputImage(type: [REDACTED], url: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for CodeInterpreterOutputLogs.
@immutable
final class LiveInputCodeInterpreterOutputLogs extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputCodeInterpreterOutputLogs.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputCodeInterpreterOutputLogs'),
        'LiveInputCodeInterpreterOutputLogs',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'logs', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `logs` value.
  String get logs => rawJson['logs'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'CodeInterpreterOutputLogs',
    rawJson,
    'LiveInputCodeInterpreterOutputLogs',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputCodeInterpreterOutputLogs copyWith({
    Object? logs = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputCodeInterpreterOutputLogs.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'logs': logs},
      <String>{},
      'LiveInputCodeInterpreterOutputLogs',
    ),
  );
  @override
  String toString() =>
      'LiveInputCodeInterpreterOutputLogs(logs: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for CodeInterpreterTool.
@immutable
final class LiveInputCodeInterpreterTool extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputCodeInterpreterTool.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputCodeInterpreterTool'),
        'LiveInputCodeInterpreterTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'allowed_callers',
    'container',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `allowed_callers` value.
  List<LiveInputCallableToolAllowedCaller>? get allowedCallers =>
      rawJson['allowed_callers'] == null
      ? null
      : List.unmodifiable(
          (rawJson['allowed_callers'] as List).map(
            LiveInputCallableToolAllowedCaller.fromJson,
          ),
        );

  /// Distinguishes absent `allowed_callers` from an explicit null.
  bool get hasAllowedCallers => rawJson.containsKey('allowed_callers');

  /// Canonical `container` value.
  LiveInputCodeInterpreterToolContainerValue get container =>
      LiveInputCodeInterpreterToolContainerValue.fromJson(rawJson['container']);

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'CodeInterpreterTool',
    rawJson,
    'LiveInputCodeInterpreterTool',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputCodeInterpreterTool copyWith({
    Object? allowedCallers = liveUnset,
    bool clearAllowedCallers = false,
    Object? container = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputCodeInterpreterTool.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'allowed_callers': allowedCallers, 'container': container},
      <String>{if (clearAllowedCallers) 'allowed_callers'},
      'LiveInputCodeInterpreterTool',
    ),
  );
  @override
  String toString() =>
      'LiveInputCodeInterpreterTool(allowed_callers: [REDACTED], container: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for CodeInterpreterToolCall.
@immutable
final class LiveInputCodeInterpreterToolCall extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputCodeInterpreterToolCall.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputCodeInterpreterToolCall'),
        'LiveInputCodeInterpreterToolCall',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'code',
    'container_id',
    'id',
    'outputs',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `code` value.
  String? get code =>
      rawJson['code'] == null ? null : (rawJson['code'] as String);

  /// Canonical `container_id` value.
  String get containerId => rawJson['container_id'] as String;

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `outputs` value.
  List<LiveInputCodeInterpreterToolCallOutputsItemValue>? get outputs =>
      rawJson['outputs'] == null
      ? null
      : List.unmodifiable(
          (rawJson['outputs'] as List).map(
            LiveInputCodeInterpreterToolCallOutputsItemValue.fromJson,
          ),
        );

  /// Canonical `status` value.
  String get status => rawJson['status'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'CodeInterpreterToolCall',
    rawJson,
    'LiveInputCodeInterpreterToolCall',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputCodeInterpreterToolCall copyWith({
    Object? code = liveUnset,
    Object? containerId = liveUnset,
    Object? id = liveUnset,
    Object? outputs = liveUnset,
    Object? status = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputCodeInterpreterToolCall.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'code': code,
        'container_id': containerId,
        'id': id,
        'outputs': outputs,
        'status': status,
      },
      <String>{},
      'LiveInputCodeInterpreterToolCall',
    ),
  );
  @override
  String toString() =>
      'LiveInputCodeInterpreterToolCall(code: [REDACTED], container_id: [REDACTED], id: [REDACTED], outputs: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for CompactionSummaryItemParam.
@immutable
final class LiveInputCompactionSummaryItemParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputCompactionSummaryItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputCompactionSummaryItemParam'),
        'LiveInputCompactionSummaryItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'encrypted_content', 'id', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `encrypted_content` value.
  String get encryptedContent => rawJson['encrypted_content'] as String;

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'CompactionSummaryItemParam',
    rawJson,
    'LiveInputCompactionSummaryItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputCompactionSummaryItemParam copyWith({
    Object? encryptedContent = liveUnset,
    Object? id = liveUnset,
    bool clearId = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputCompactionSummaryItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'encrypted_content': encryptedContent, 'id': id},
      <String>{if (clearId) 'id'},
      'LiveInputCompactionSummaryItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputCompactionSummaryItemParam(encrypted_content: [REDACTED], id: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for CompactionTriggerItemParam.
@immutable
final class LiveInputCompactionTriggerItemParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputCompactionTriggerItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputCompactionTriggerItemParam'),
        'LiveInputCompactionTriggerItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'id', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'CompactionTriggerItemParam',
    rawJson,
    'LiveInputCompactionTriggerItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputCompactionTriggerItemParam copyWith({
    Object? id = liveUnset,
    bool clearId = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputCompactionTriggerItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'id': id},
      <String>{if (clearId) 'id'},
      'LiveInputCompactionTriggerItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputCompactionTriggerItemParam(id: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ComparisonFilter.
@immutable
final class LiveInputComparisonFilter extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputComparisonFilter.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputComparisonFilter'),
        'LiveInputComparisonFilter',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'key', 'type', 'value'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `key` value.
  String get key => rawJson['key'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `value` value.
  LiveInputComparisonFilterValueValue get value =>
      LiveInputComparisonFilterValueValue.fromJson(rawJson['value']);
  @override
  void validate() => _validateInputComponent(
    'ComparisonFilter',
    rawJson,
    'LiveInputComparisonFilter',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputComparisonFilter copyWith({
    Object? key = liveUnset,
    Object? type = liveUnset,
    Object? value = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputComparisonFilter.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'key': key, 'type': type, 'value': value},
      <String>{},
      'LiveInputComparisonFilter',
    ),
  );
  @override
  String toString() =>
      'LiveInputComparisonFilter(key: [REDACTED], type: [REDACTED], value: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for CompoundFilter.
@immutable
final class LiveInputCompoundFilter extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputCompoundFilter.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputCompoundFilter'),
        'LiveInputCompoundFilter',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'filters', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `filters` value.
  List<LiveInputCompoundFilterFiltersItemValue> get filters =>
      List.unmodifiable(
        (rawJson['filters'] as List).map(
          LiveInputCompoundFilterFiltersItemValue.fromJson,
        ),
      );

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'CompoundFilter',
    rawJson,
    'LiveInputCompoundFilter',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputCompoundFilter copyWith({
    Object? filters = liveUnset,
    Object? type = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputCompoundFilter.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'filters': filters, 'type': type},
      <String>{},
      'LiveInputCompoundFilter',
    ),
  );
  @override
  String toString() =>
      'LiveInputCompoundFilter(filters: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ComputerCallOutputItemParam.
@immutable
final class LiveInputComputerCallOutputItemParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputComputerCallOutputItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputComputerCallOutputItemParam'),
        'LiveInputComputerCallOutputItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'acknowledged_safety_checks',
    'call_id',
    'id',
    'output',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `acknowledged_safety_checks` value.
  List<LiveInputComputerCallSafetyCheckParam>? get acknowledgedSafetyChecks =>
      rawJson['acknowledged_safety_checks'] == null
      ? null
      : List.unmodifiable(
          (rawJson['acknowledged_safety_checks'] as List).map(
            LiveInputComputerCallSafetyCheckParam.fromJson,
          ),
        );

  /// Distinguishes absent `acknowledged_safety_checks` from an explicit null.
  bool get hasAcknowledgedSafetyChecks =>
      rawJson.containsKey('acknowledged_safety_checks');

  /// Canonical `call_id` value.
  String get callId => rawJson['call_id'] as String;

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `output` value.
  LiveInputComputerScreenshotImage get output =>
      LiveInputComputerScreenshotImage.fromJson(rawJson['output']);

  /// Canonical `status` value.
  LiveInputFunctionCallItemStatus? get status => rawJson['status'] == null
      ? null
      : LiveInputFunctionCallItemStatus.fromJson(rawJson['status']);

  /// Distinguishes absent `status` from an explicit null.
  bool get hasStatus => rawJson.containsKey('status');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ComputerCallOutputItemParam',
    rawJson,
    'LiveInputComputerCallOutputItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputComputerCallOutputItemParam copyWith({
    Object? acknowledgedSafetyChecks = liveUnset,
    bool clearAcknowledgedSafetyChecks = false,
    Object? callId = liveUnset,
    Object? id = liveUnset,
    bool clearId = false,
    Object? output = liveUnset,
    Object? status = liveUnset,
    bool clearStatus = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputComputerCallOutputItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'acknowledged_safety_checks': acknowledgedSafetyChecks,
        'call_id': callId,
        'id': id,
        'output': output,
        'status': status,
      },
      <String>{
        if (clearAcknowledgedSafetyChecks) 'acknowledged_safety_checks',
        if (clearId) 'id',
        if (clearStatus) 'status',
      },
      'LiveInputComputerCallOutputItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputComputerCallOutputItemParam(acknowledged_safety_checks: [REDACTED], call_id: [REDACTED], id: [REDACTED], output: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ComputerCallSafetyCheckParam.
@immutable
final class LiveInputComputerCallSafetyCheckParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputComputerCallSafetyCheckParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputComputerCallSafetyCheckParam'),
        'LiveInputComputerCallSafetyCheckParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'code', 'id', 'message'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `code` value.
  String? get code =>
      rawJson['code'] == null ? null : (rawJson['code'] as String);

  /// Distinguishes absent `code` from an explicit null.
  bool get hasCode => rawJson.containsKey('code');

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `message` value.
  String? get message =>
      rawJson['message'] == null ? null : (rawJson['message'] as String);

  /// Distinguishes absent `message` from an explicit null.
  bool get hasMessage => rawJson.containsKey('message');
  @override
  void validate() => _validateInputComponent(
    'ComputerCallSafetyCheckParam',
    rawJson,
    'LiveInputComputerCallSafetyCheckParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputComputerCallSafetyCheckParam copyWith({
    Object? code = liveUnset,
    bool clearCode = false,
    Object? id = liveUnset,
    Object? message = liveUnset,
    bool clearMessage = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputComputerCallSafetyCheckParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'code': code, 'id': id, 'message': message},
      <String>{if (clearCode) 'code', if (clearMessage) 'message'},
      'LiveInputComputerCallSafetyCheckParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputComputerCallSafetyCheckParam(code: [REDACTED], id: [REDACTED], message: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ComputerScreenshotImage.
@immutable
final class LiveInputComputerScreenshotImage extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputComputerScreenshotImage.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputComputerScreenshotImage'),
        'LiveInputComputerScreenshotImage',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'file_id', 'image_url', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `file_id` value.
  String? get fileId =>
      rawJson['file_id'] == null ? null : (rawJson['file_id'] as String);

  /// Distinguishes absent `file_id` from an explicit null.
  bool get hasFileId => rawJson.containsKey('file_id');

  /// Canonical `image_url` value.
  String? get imageUrl =>
      rawJson['image_url'] == null ? null : (rawJson['image_url'] as String);

  /// Distinguishes absent `image_url` from an explicit null.
  bool get hasImageUrl => rawJson.containsKey('image_url');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ComputerScreenshotImage',
    rawJson,
    'LiveInputComputerScreenshotImage',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputComputerScreenshotImage copyWith({
    Object? fileId = liveUnset,
    bool clearFileId = false,
    Object? imageUrl = liveUnset,
    bool clearImageUrl = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputComputerScreenshotImage.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'file_id': fileId, 'image_url': imageUrl},
      <String>{if (clearFileId) 'file_id', if (clearImageUrl) 'image_url'},
      'LiveInputComputerScreenshotImage',
    ),
  );
  @override
  String toString() =>
      'LiveInputComputerScreenshotImage(file_id: [REDACTED], image_url: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ComputerTool.
@immutable
final class LiveInputComputerTool extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputComputerTool.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputComputerTool'),
        'LiveInputComputerTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() =>
      _validateInputComponent('ComputerTool', rawJson, 'LiveInputComputerTool');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputComputerTool copyWith({
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputComputerTool.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {},
      <String>{},
      'LiveInputComputerTool',
    ),
  );
  @override
  String toString() =>
      'LiveInputComputerTool(type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ComputerToolCall.
@immutable
final class LiveInputComputerToolCall extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputComputerToolCall.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputComputerToolCall'),
        'LiveInputComputerToolCall',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'action',
    'actions',
    'call_id',
    'id',
    'pending_safety_checks',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `action` value.
  LiveInputComputerAction? get action => rawJson['action'] == null
      ? null
      : LiveInputComputerAction.fromJson(rawJson['action']);

  /// Distinguishes absent `action` from an explicit null.
  bool get hasAction => rawJson.containsKey('action');

  /// Canonical `actions` value.
  LiveInputComputerActionList? get actions => rawJson['actions'] == null
      ? null
      : LiveInputComputerActionList.fromJson(rawJson['actions']);

  /// Distinguishes absent `actions` from an explicit null.
  bool get hasActions => rawJson.containsKey('actions');

  /// Canonical `call_id` value.
  String get callId => rawJson['call_id'] as String;

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `pending_safety_checks` value.
  List<LiveInputComputerCallSafetyCheckParam> get pendingSafetyChecks =>
      List.unmodifiable(
        (rawJson['pending_safety_checks'] as List).map(
          LiveInputComputerCallSafetyCheckParam.fromJson,
        ),
      );

  /// Canonical `status` value.
  String get status => rawJson['status'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ComputerToolCall',
    rawJson,
    'LiveInputComputerToolCall',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputComputerToolCall copyWith({
    Object? action = liveUnset,
    bool clearAction = false,
    Object? actions = liveUnset,
    bool clearActions = false,
    Object? callId = liveUnset,
    Object? id = liveUnset,
    Object? pendingSafetyChecks = liveUnset,
    Object? status = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputComputerToolCall.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'action': action,
        'actions': actions,
        'call_id': callId,
        'id': id,
        'pending_safety_checks': pendingSafetyChecks,
        'status': status,
      },
      <String>{if (clearAction) 'action', if (clearActions) 'actions'},
      'LiveInputComputerToolCall',
    ),
  );
  @override
  String toString() =>
      'LiveInputComputerToolCall(action: [REDACTED], actions: [REDACTED], call_id: [REDACTED], id: [REDACTED], pending_safety_checks: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ComputerUsePreviewTool.
@immutable
final class LiveInputComputerUsePreviewTool extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputComputerUsePreviewTool.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputComputerUsePreviewTool'),
        'LiveInputComputerUsePreviewTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'display_height',
    'display_width',
    'environment',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `display_height` value.
  int get displayHeight => rawJson['display_height'] as int;

  /// Canonical `display_width` value.
  int get displayWidth => rawJson['display_width'] as int;

  /// Canonical `environment` value.
  LiveInputComputerEnvironment get environment =>
      LiveInputComputerEnvironment.fromJson(rawJson['environment']);

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ComputerUsePreviewTool',
    rawJson,
    'LiveInputComputerUsePreviewTool',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputComputerUsePreviewTool copyWith({
    Object? displayHeight = liveUnset,
    Object? displayWidth = liveUnset,
    Object? environment = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputComputerUsePreviewTool.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'display_height': displayHeight,
        'display_width': displayWidth,
        'environment': environment,
      },
      <String>{},
      'LiveInputComputerUsePreviewTool',
    ),
  );
  @override
  String toString() =>
      'LiveInputComputerUsePreviewTool(display_height: [REDACTED], display_width: [REDACTED], environment: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ContainerAutoParam.
@immutable
final class LiveInputContainerAutoParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputContainerAutoParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputContainerAutoParam'),
        'LiveInputContainerAutoParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'file_ids',
    'memory_limit',
    'network_policy',
    'skills',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `file_ids` value.
  List<String>? get fileIds => rawJson['file_ids'] == null
      ? null
      : List.unmodifiable(
          (rawJson['file_ids'] as List).map((value) => value as String),
        );

  /// Distinguishes absent `file_ids` from an explicit null.
  bool get hasFileIds => rawJson.containsKey('file_ids');

  /// Canonical `memory_limit` value.
  LiveInputContainerMemoryLimit? get memoryLimit =>
      rawJson['memory_limit'] == null
      ? null
      : LiveInputContainerMemoryLimit.fromJson(rawJson['memory_limit']);

  /// Distinguishes absent `memory_limit` from an explicit null.
  bool get hasMemoryLimit => rawJson.containsKey('memory_limit');

  /// Canonical `network_policy` value.
  LiveInputContainerAutoParamNetworkPolicyValue? get networkPolicy =>
      rawJson['network_policy'] == null
      ? null
      : LiveInputContainerAutoParamNetworkPolicyValue.fromJson(
          rawJson['network_policy'],
        );

  /// Distinguishes absent `network_policy` from an explicit null.
  bool get hasNetworkPolicy => rawJson.containsKey('network_policy');

  /// Canonical `skills` value.
  List<LiveInputContainerAutoParamSkillsItemValue>? get skills =>
      rawJson['skills'] == null
      ? null
      : List.unmodifiable(
          (rawJson['skills'] as List).map(
            LiveInputContainerAutoParamSkillsItemValue.fromJson,
          ),
        );

  /// Distinguishes absent `skills` from an explicit null.
  bool get hasSkills => rawJson.containsKey('skills');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ContainerAutoParam',
    rawJson,
    'LiveInputContainerAutoParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputContainerAutoParam copyWith({
    Object? fileIds = liveUnset,
    bool clearFileIds = false,
    Object? memoryLimit = liveUnset,
    bool clearMemoryLimit = false,
    Object? networkPolicy = liveUnset,
    bool clearNetworkPolicy = false,
    Object? skills = liveUnset,
    bool clearSkills = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputContainerAutoParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'file_ids': fileIds,
        'memory_limit': memoryLimit,
        'network_policy': networkPolicy,
        'skills': skills,
      },
      <String>{
        if (clearFileIds) 'file_ids',
        if (clearMemoryLimit) 'memory_limit',
        if (clearNetworkPolicy) 'network_policy',
        if (clearSkills) 'skills',
      },
      'LiveInputContainerAutoParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputContainerAutoParam(file_ids: [REDACTED], memory_limit: [REDACTED], network_policy: [REDACTED], skills: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ContainerFileCitationBody.
@immutable
final class LiveInputContainerFileCitationBody extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputContainerFileCitationBody.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputContainerFileCitationBody'),
        'LiveInputContainerFileCitationBody',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'container_id',
    'end_index',
    'file_id',
    'filename',
    'start_index',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `container_id` value.
  String get containerId => rawJson['container_id'] as String;

  /// Canonical `end_index` value.
  int get endIndex => rawJson['end_index'] as int;

  /// Canonical `file_id` value.
  String get fileId => rawJson['file_id'] as String;

  /// Canonical `filename` value.
  String get filename => rawJson['filename'] as String;

  /// Canonical `start_index` value.
  int get startIndex => rawJson['start_index'] as int;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ContainerFileCitationBody',
    rawJson,
    'LiveInputContainerFileCitationBody',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputContainerFileCitationBody copyWith({
    Object? containerId = liveUnset,
    Object? endIndex = liveUnset,
    Object? fileId = liveUnset,
    Object? filename = liveUnset,
    Object? startIndex = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputContainerFileCitationBody.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'container_id': containerId,
        'end_index': endIndex,
        'file_id': fileId,
        'filename': filename,
        'start_index': startIndex,
      },
      <String>{},
      'LiveInputContainerFileCitationBody',
    ),
  );
  @override
  String toString() =>
      'LiveInputContainerFileCitationBody(container_id: [REDACTED], end_index: [REDACTED], file_id: [REDACTED], filename: [REDACTED], start_index: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ContainerNetworkPolicyAllowlistParam.
@immutable
final class LiveInputContainerNetworkPolicyAllowlistParam
    extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputContainerNetworkPolicyAllowlistParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(
          json,
          'LiveInputContainerNetworkPolicyAllowlistParam',
        ),
        'LiveInputContainerNetworkPolicyAllowlistParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'allowed_domains',
    'domain_secrets',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `allowed_domains` value.
  List<String> get allowedDomains => List.unmodifiable(
    (rawJson['allowed_domains'] as List).map((value) => value as String),
  );

  /// Canonical `domain_secrets` value.
  List<LiveInputContainerNetworkPolicyDomainSecretParam>? get domainSecrets =>
      rawJson['domain_secrets'] == null
      ? null
      : List.unmodifiable(
          (rawJson['domain_secrets'] as List).map(
            LiveInputContainerNetworkPolicyDomainSecretParam.fromJson,
          ),
        );

  /// Distinguishes absent `domain_secrets` from an explicit null.
  bool get hasDomainSecrets => rawJson.containsKey('domain_secrets');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ContainerNetworkPolicyAllowlistParam',
    rawJson,
    'LiveInputContainerNetworkPolicyAllowlistParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputContainerNetworkPolicyAllowlistParam copyWith({
    Object? allowedDomains = liveUnset,
    Object? domainSecrets = liveUnset,
    bool clearDomainSecrets = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputContainerNetworkPolicyAllowlistParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'allowed_domains': allowedDomains, 'domain_secrets': domainSecrets},
      <String>{if (clearDomainSecrets) 'domain_secrets'},
      'LiveInputContainerNetworkPolicyAllowlistParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputContainerNetworkPolicyAllowlistParam(allowed_domains: [REDACTED], domain_secrets: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ContainerNetworkPolicyDisabledParam.
@immutable
final class LiveInputContainerNetworkPolicyDisabledParam
    extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputContainerNetworkPolicyDisabledParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputContainerNetworkPolicyDisabledParam'),
        'LiveInputContainerNetworkPolicyDisabledParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ContainerNetworkPolicyDisabledParam',
    rawJson,
    'LiveInputContainerNetworkPolicyDisabledParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputContainerNetworkPolicyDisabledParam copyWith({
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputContainerNetworkPolicyDisabledParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {},
      <String>{},
      'LiveInputContainerNetworkPolicyDisabledParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputContainerNetworkPolicyDisabledParam(type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ContainerNetworkPolicyDomainSecretParam.
@immutable
final class LiveInputContainerNetworkPolicyDomainSecretParam
    extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(
          json,
          'LiveInputContainerNetworkPolicyDomainSecretParam',
        ),
        'LiveInputContainerNetworkPolicyDomainSecretParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'domain', 'name', 'value'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `domain` value.
  String get domain => rawJson['domain'] as String;

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;

  /// Canonical `value` value.
  String get value => rawJson['value'] as String;
  @override
  void validate() => _validateInputComponent(
    'ContainerNetworkPolicyDomainSecretParam',
    rawJson,
    'LiveInputContainerNetworkPolicyDomainSecretParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputContainerNetworkPolicyDomainSecretParam copyWith({
    Object? domain = liveUnset,
    Object? name = liveUnset,
    Object? value = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputContainerNetworkPolicyDomainSecretParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'domain': domain, 'name': name, 'value': value},
      <String>{},
      'LiveInputContainerNetworkPolicyDomainSecretParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputContainerNetworkPolicyDomainSecretParam(domain: [REDACTED], name: [REDACTED], value: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ContainerReferenceParam.
@immutable
final class LiveInputContainerReferenceParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputContainerReferenceParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputContainerReferenceParam'),
        'LiveInputContainerReferenceParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'container_id', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `container_id` value.
  String get containerId => rawJson['container_id'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ContainerReferenceParam',
    rawJson,
    'LiveInputContainerReferenceParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputContainerReferenceParam copyWith({
    Object? containerId = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputContainerReferenceParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'container_id': containerId},
      <String>{},
      'LiveInputContainerReferenceParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputContainerReferenceParam(container_id: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for CoordParam.
@immutable
final class LiveInputCoordParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputCoordParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputCoordParam'),
        'LiveInputCoordParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'x', 'y'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `x` value.
  int get x => rawJson['x'] as int;

  /// Canonical `y` value.
  int get y => rawJson['y'] as int;
  @override
  void validate() =>
      _validateInputComponent('CoordParam', rawJson, 'LiveInputCoordParam');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputCoordParam copyWith({
    Object? x = liveUnset,
    Object? y = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputCoordParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'x': x, 'y': y},
      <String>{},
      'LiveInputCoordParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputCoordParam(x: [REDACTED], y: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for CustomGrammarFormatParam.
@immutable
final class LiveInputCustomGrammarFormatParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputCustomGrammarFormatParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputCustomGrammarFormatParam'),
        'LiveInputCustomGrammarFormatParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'definition', 'syntax', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `definition` value.
  String get definition => rawJson['definition'] as String;

  /// Canonical `syntax` value.
  LiveInputGrammarSyntax1 get syntax =>
      LiveInputGrammarSyntax1.fromJson(rawJson['syntax']);

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'CustomGrammarFormatParam',
    rawJson,
    'LiveInputCustomGrammarFormatParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputCustomGrammarFormatParam copyWith({
    Object? definition = liveUnset,
    Object? syntax = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputCustomGrammarFormatParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'definition': definition, 'syntax': syntax},
      <String>{},
      'LiveInputCustomGrammarFormatParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputCustomGrammarFormatParam(definition: [REDACTED], syntax: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for CustomTextFormatParam.
@immutable
final class LiveInputCustomTextFormatParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputCustomTextFormatParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputCustomTextFormatParam'),
        'LiveInputCustomTextFormatParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'CustomTextFormatParam',
    rawJson,
    'LiveInputCustomTextFormatParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputCustomTextFormatParam copyWith({
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputCustomTextFormatParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {},
      <String>{},
      'LiveInputCustomTextFormatParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputCustomTextFormatParam(type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for CustomToolCall.
@immutable
final class LiveInputCustomToolCall extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputCustomToolCall.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputCustomToolCall'),
        'LiveInputCustomToolCall',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'async',
    'call_id',
    'caller',
    'id',
    'input',
    'name',
    'namespace',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `async` value.
  bool? get async =>
      rawJson['async'] == null ? null : (rawJson['async'] as bool);

  /// Distinguishes absent `async` from an explicit null.
  bool get hasAsync => rawJson.containsKey('async');

  /// Canonical `call_id` value.
  String get callId => rawJson['call_id'] as String;

  /// Canonical `caller` value.
  LiveInputToolCallCaller? get caller => rawJson['caller'] == null
      ? null
      : LiveInputToolCallCaller.fromJson(rawJson['caller']);

  /// Distinguishes absent `caller` from an explicit null.
  bool get hasCaller => rawJson.containsKey('caller');

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `input` value.
  String get input => rawJson['input'] as String;

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;

  /// Canonical `namespace` value.
  String? get namespace =>
      rawJson['namespace'] == null ? null : (rawJson['namespace'] as String);

  /// Distinguishes absent `namespace` from an explicit null.
  bool get hasNamespace => rawJson.containsKey('namespace');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'CustomToolCall',
    rawJson,
    'LiveInputCustomToolCall',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputCustomToolCall copyWith({
    Object? async = liveUnset,
    bool clearAsync = false,
    Object? callId = liveUnset,
    Object? caller = liveUnset,
    bool clearCaller = false,
    Object? id = liveUnset,
    bool clearId = false,
    Object? input = liveUnset,
    Object? name = liveUnset,
    Object? namespace = liveUnset,
    bool clearNamespace = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputCustomToolCall.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'async': async,
        'call_id': callId,
        'caller': caller,
        'id': id,
        'input': input,
        'name': name,
        'namespace': namespace,
      },
      <String>{
        if (clearAsync) 'async',
        if (clearCaller) 'caller',
        if (clearId) 'id',
        if (clearNamespace) 'namespace',
      },
      'LiveInputCustomToolCall',
    ),
  );
  @override
  String toString() =>
      'LiveInputCustomToolCall(async: [REDACTED], call_id: [REDACTED], caller: [REDACTED], id: [REDACTED], input: [REDACTED], name: [REDACTED], namespace: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for CustomToolCallOutput.
@immutable
final class LiveInputCustomToolCallOutput extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputCustomToolCallOutput.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputCustomToolCallOutput'),
        'LiveInputCustomToolCallOutput',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'call_id',
    'caller',
    'id',
    'output',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `call_id` value.
  String get callId => rawJson['call_id'] as String;

  /// Canonical `caller` value.
  LiveInputToolCallCallerParam? get caller => rawJson['caller'] == null
      ? null
      : LiveInputToolCallCallerParam.fromJson(rawJson['caller']);

  /// Distinguishes absent `caller` from an explicit null.
  bool get hasCaller => rawJson.containsKey('caller');

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `output` value.
  LiveInputCustomToolCallOutputOutputValue get output =>
      LiveInputCustomToolCallOutputOutputValue.fromJson(rawJson['output']);

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'CustomToolCallOutput',
    rawJson,
    'LiveInputCustomToolCallOutput',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputCustomToolCallOutput copyWith({
    Object? callId = liveUnset,
    Object? caller = liveUnset,
    bool clearCaller = false,
    Object? id = liveUnset,
    bool clearId = false,
    Object? output = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputCustomToolCallOutput.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'call_id': callId, 'caller': caller, 'id': id, 'output': output},
      <String>{if (clearCaller) 'caller', if (clearId) 'id'},
      'LiveInputCustomToolCallOutput',
    ),
  );
  @override
  String toString() =>
      'LiveInputCustomToolCallOutput(call_id: [REDACTED], caller: [REDACTED], id: [REDACTED], output: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for CustomToolParam.
@immutable
final class LiveInputCustomToolParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputCustomToolParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputCustomToolParam'),
        'LiveInputCustomToolParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'allowed_callers',
    'async',
    'defer_loading',
    'description',
    'format',
    'name',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `allowed_callers` value.
  List<LiveInputCallableToolAllowedCaller>? get allowedCallers =>
      rawJson['allowed_callers'] == null
      ? null
      : List.unmodifiable(
          (rawJson['allowed_callers'] as List).map(
            LiveInputCallableToolAllowedCaller.fromJson,
          ),
        );

  /// Distinguishes absent `allowed_callers` from an explicit null.
  bool get hasAllowedCallers => rawJson.containsKey('allowed_callers');

  /// Canonical `async` value.
  bool? get async =>
      rawJson['async'] == null ? null : (rawJson['async'] as bool);

  /// Distinguishes absent `async` from an explicit null.
  bool get hasAsync => rawJson.containsKey('async');

  /// Canonical `defer_loading` value.
  bool? get deferLoading => rawJson['defer_loading'] == null
      ? null
      : (rawJson['defer_loading'] as bool);

  /// Distinguishes absent `defer_loading` from an explicit null.
  bool get hasDeferLoading => rawJson.containsKey('defer_loading');

  /// Canonical `description` value.
  String? get description => rawJson['description'] == null
      ? null
      : (rawJson['description'] as String);

  /// Distinguishes absent `description` from an explicit null.
  bool get hasDescription => rawJson.containsKey('description');

  /// Canonical `format` value.
  LiveInputCustomToolParamFormatValue? get format => rawJson['format'] == null
      ? null
      : LiveInputCustomToolParamFormatValue.fromJson(rawJson['format']);

  /// Distinguishes absent `format` from an explicit null.
  bool get hasFormat => rawJson.containsKey('format');

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'CustomToolParam',
    rawJson,
    'LiveInputCustomToolParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputCustomToolParam copyWith({
    Object? allowedCallers = liveUnset,
    bool clearAllowedCallers = false,
    Object? async = liveUnset,
    bool clearAsync = false,
    Object? deferLoading = liveUnset,
    bool clearDeferLoading = false,
    Object? description = liveUnset,
    bool clearDescription = false,
    Object? format = liveUnset,
    bool clearFormat = false,
    Object? name = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputCustomToolParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'allowed_callers': allowedCallers,
        'async': async,
        'defer_loading': deferLoading,
        'description': description,
        'format': format,
        'name': name,
      },
      <String>{
        if (clearAllowedCallers) 'allowed_callers',
        if (clearAsync) 'async',
        if (clearDeferLoading) 'defer_loading',
        if (clearDescription) 'description',
        if (clearFormat) 'format',
      },
      'LiveInputCustomToolParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputCustomToolParam(allowed_callers: [REDACTED], async: [REDACTED], defer_loading: [REDACTED], description: [REDACTED], format: [REDACTED], name: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for DirectToolCallCaller.
@immutable
final class LiveInputDirectToolCallCaller extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputDirectToolCallCaller.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputDirectToolCallCaller'),
        'LiveInputDirectToolCallCaller',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'DirectToolCallCaller',
    rawJson,
    'LiveInputDirectToolCallCaller',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputDirectToolCallCaller copyWith({
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputDirectToolCallCaller.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {},
      <String>{},
      'LiveInputDirectToolCallCaller',
    ),
  );
  @override
  String toString() =>
      'LiveInputDirectToolCallCaller(type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for DirectToolCallCallerParam.
@immutable
final class LiveInputDirectToolCallCallerParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputDirectToolCallCallerParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputDirectToolCallCallerParam'),
        'LiveInputDirectToolCallCallerParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'DirectToolCallCallerParam',
    rawJson,
    'LiveInputDirectToolCallCallerParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputDirectToolCallCallerParam copyWith({
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputDirectToolCallCallerParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {},
      <String>{},
      'LiveInputDirectToolCallCallerParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputDirectToolCallCallerParam(type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for DoubleClickAction.
@immutable
final class LiveInputDoubleClickAction extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputDoubleClickAction.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputDoubleClickAction'),
        'LiveInputDoubleClickAction',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'keys', 'type', 'x', 'y'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `keys` value.
  List<String>? get keys => rawJson['keys'] == null
      ? null
      : List.unmodifiable(
          (rawJson['keys'] as List).map((value) => value as String),
        );

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `x` value.
  int get x => rawJson['x'] as int;

  /// Canonical `y` value.
  int get y => rawJson['y'] as int;
  @override
  void validate() => _validateInputComponent(
    'DoubleClickAction',
    rawJson,
    'LiveInputDoubleClickAction',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputDoubleClickAction copyWith({
    Object? keys = liveUnset,
    Object? x = liveUnset,
    Object? y = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputDoubleClickAction.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'keys': keys, 'x': x, 'y': y},
      <String>{},
      'LiveInputDoubleClickAction',
    ),
  );
  @override
  String toString() =>
      'LiveInputDoubleClickAction(keys: [REDACTED], type: [REDACTED], x: [REDACTED], y: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for DragParam.
@immutable
final class LiveInputDragParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputDragParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputDragParam'),
        'LiveInputDragParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'keys', 'path', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `keys` value.
  List<String>? get keys => rawJson['keys'] == null
      ? null
      : List.unmodifiable(
          (rawJson['keys'] as List).map((value) => value as String),
        );

  /// Distinguishes absent `keys` from an explicit null.
  bool get hasKeys => rawJson.containsKey('keys');

  /// Canonical `path` value.
  List<LiveInputCoordParam> get path => List.unmodifiable(
    (rawJson['path'] as List).map(LiveInputCoordParam.fromJson),
  );

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() =>
      _validateInputComponent('DragParam', rawJson, 'LiveInputDragParam');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputDragParam copyWith({
    Object? keys = liveUnset,
    bool clearKeys = false,
    Object? path = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputDragParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'keys': keys, 'path': path},
      <String>{if (clearKeys) 'keys'},
      'LiveInputDragParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputDragParam(keys: [REDACTED], path: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for EmptyModelParam.
@immutable
final class LiveInputEmptyModelParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputEmptyModelParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputEmptyModelParam'),
        'LiveInputEmptyModelParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;
  @override
  void validate() => _validateInputComponent(
    'EmptyModelParam',
    rawJson,
    'LiveInputEmptyModelParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputEmptyModelParam copyWith({
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputEmptyModelParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {},
      <String>{},
      'LiveInputEmptyModelParam',
    ),
  );
  @override
  String toString() => 'LiveInputEmptyModelParam(, rawJson: [REDACTED])';
}

/// Immutable typed adapter for FileCitationBody.
@immutable
final class LiveInputFileCitationBody extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputFileCitationBody.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFileCitationBody'),
        'LiveInputFileCitationBody',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'file_id',
    'filename',
    'index',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `file_id` value.
  String get fileId => rawJson['file_id'] as String;

  /// Canonical `filename` value.
  String get filename => rawJson['filename'] as String;

  /// Canonical `index` value.
  int get index => rawJson['index'] as int;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'FileCitationBody',
    rawJson,
    'LiveInputFileCitationBody',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFileCitationBody copyWith({
    Object? fileId = liveUnset,
    Object? filename = liveUnset,
    Object? index = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFileCitationBody.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'file_id': fileId, 'filename': filename, 'index': index},
      <String>{},
      'LiveInputFileCitationBody',
    ),
  );
  @override
  String toString() =>
      'LiveInputFileCitationBody(file_id: [REDACTED], filename: [REDACTED], index: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for InputFileContent.
@immutable
final class LiveInputFileContent extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputFileContent.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFileContent'),
        'LiveInputFileContent',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'detail',
    'file_data',
    'file_id',
    'file_url',
    'filename',
    'prompt_cache_breakpoint',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `detail` value.
  LiveInputFileInputDetail? get detail => rawJson['detail'] == null
      ? null
      : LiveInputFileInputDetail.fromJson(rawJson['detail']);

  /// Distinguishes absent `detail` from an explicit null.
  bool get hasDetail => rawJson.containsKey('detail');

  /// Canonical `file_data` value.
  String? get fileData =>
      rawJson['file_data'] == null ? null : (rawJson['file_data'] as String);

  /// Distinguishes absent `file_data` from an explicit null.
  bool get hasFileData => rawJson.containsKey('file_data');

  /// Canonical `file_id` value.
  String? get fileId =>
      rawJson['file_id'] == null ? null : (rawJson['file_id'] as String);

  /// Distinguishes absent `file_id` from an explicit null.
  bool get hasFileId => rawJson.containsKey('file_id');

  /// Canonical `file_url` value.
  String? get fileUrl =>
      rawJson['file_url'] == null ? null : (rawJson['file_url'] as String);

  /// Distinguishes absent `file_url` from an explicit null.
  bool get hasFileUrl => rawJson.containsKey('file_url');

  /// Canonical `filename` value.
  String? get filename =>
      rawJson['filename'] == null ? null : (rawJson['filename'] as String);

  /// Distinguishes absent `filename` from an explicit null.
  bool get hasFilename => rawJson.containsKey('filename');

  /// Canonical `prompt_cache_breakpoint` value.
  LiveInputPromptCacheBreakpointConfig? get promptCacheBreakpoint =>
      rawJson['prompt_cache_breakpoint'] == null
      ? null
      : LiveInputPromptCacheBreakpointConfig.fromJson(
          rawJson['prompt_cache_breakpoint'],
        );

  /// Distinguishes absent `prompt_cache_breakpoint` from an explicit null.
  bool get hasPromptCacheBreakpoint =>
      rawJson.containsKey('prompt_cache_breakpoint');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'InputFileContent',
    rawJson,
    'LiveInputFileContent',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFileContent copyWith({
    Object? detail = liveUnset,
    bool clearDetail = false,
    Object? fileData = liveUnset,
    bool clearFileData = false,
    Object? fileId = liveUnset,
    bool clearFileId = false,
    Object? fileUrl = liveUnset,
    bool clearFileUrl = false,
    Object? filename = liveUnset,
    bool clearFilename = false,
    Object? promptCacheBreakpoint = liveUnset,
    bool clearPromptCacheBreakpoint = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFileContent.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'detail': detail,
        'file_data': fileData,
        'file_id': fileId,
        'file_url': fileUrl,
        'filename': filename,
        'prompt_cache_breakpoint': promptCacheBreakpoint,
      },
      <String>{
        if (clearDetail) 'detail',
        if (clearFileData) 'file_data',
        if (clearFileId) 'file_id',
        if (clearFileUrl) 'file_url',
        if (clearFilename) 'filename',
        if (clearPromptCacheBreakpoint) 'prompt_cache_breakpoint',
      },
      'LiveInputFileContent',
    ),
  );
  @override
  String toString() =>
      'LiveInputFileContent(detail: [REDACTED], file_data: [REDACTED], file_id: [REDACTED], file_url: [REDACTED], filename: [REDACTED], prompt_cache_breakpoint: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for InputFileContentParam.
@immutable
final class LiveInputFileContentParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputFileContentParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFileContentParam'),
        'LiveInputFileContentParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'detail',
    'file_data',
    'file_id',
    'file_url',
    'filename',
    'prompt_cache_breakpoint',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `detail` value.
  LiveInputFileDetailEnum? get detail => rawJson['detail'] == null
      ? null
      : LiveInputFileDetailEnum.fromJson(rawJson['detail']);

  /// Distinguishes absent `detail` from an explicit null.
  bool get hasDetail => rawJson.containsKey('detail');

  /// Canonical `file_data` value.
  String? get fileData =>
      rawJson['file_data'] == null ? null : (rawJson['file_data'] as String);

  /// Distinguishes absent `file_data` from an explicit null.
  bool get hasFileData => rawJson.containsKey('file_data');

  /// Canonical `file_id` value.
  String? get fileId =>
      rawJson['file_id'] == null ? null : (rawJson['file_id'] as String);

  /// Distinguishes absent `file_id` from an explicit null.
  bool get hasFileId => rawJson.containsKey('file_id');

  /// Canonical `file_url` value.
  String? get fileUrl =>
      rawJson['file_url'] == null ? null : (rawJson['file_url'] as String);

  /// Distinguishes absent `file_url` from an explicit null.
  bool get hasFileUrl => rawJson.containsKey('file_url');

  /// Canonical `filename` value.
  String? get filename =>
      rawJson['filename'] == null ? null : (rawJson['filename'] as String);

  /// Distinguishes absent `filename` from an explicit null.
  bool get hasFilename => rawJson.containsKey('filename');

  /// Canonical `prompt_cache_breakpoint` value.
  LiveInputPromptCacheBreakpointParam? get promptCacheBreakpoint =>
      rawJson['prompt_cache_breakpoint'] == null
      ? null
      : LiveInputPromptCacheBreakpointParam.fromJson(
          rawJson['prompt_cache_breakpoint'],
        );

  /// Distinguishes absent `prompt_cache_breakpoint` from an explicit null.
  bool get hasPromptCacheBreakpoint =>
      rawJson.containsKey('prompt_cache_breakpoint');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'InputFileContentParam',
    rawJson,
    'LiveInputFileContentParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFileContentParam copyWith({
    Object? detail = liveUnset,
    bool clearDetail = false,
    Object? fileData = liveUnset,
    bool clearFileData = false,
    Object? fileId = liveUnset,
    bool clearFileId = false,
    Object? fileUrl = liveUnset,
    bool clearFileUrl = false,
    Object? filename = liveUnset,
    bool clearFilename = false,
    Object? promptCacheBreakpoint = liveUnset,
    bool clearPromptCacheBreakpoint = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFileContentParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'detail': detail,
        'file_data': fileData,
        'file_id': fileId,
        'file_url': fileUrl,
        'filename': filename,
        'prompt_cache_breakpoint': promptCacheBreakpoint,
      },
      <String>{
        if (clearDetail) 'detail',
        if (clearFileData) 'file_data',
        if (clearFileId) 'file_id',
        if (clearFileUrl) 'file_url',
        if (clearFilename) 'filename',
        if (clearPromptCacheBreakpoint) 'prompt_cache_breakpoint',
      },
      'LiveInputFileContentParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputFileContentParam(detail: [REDACTED], file_data: [REDACTED], file_id: [REDACTED], file_url: [REDACTED], filename: [REDACTED], prompt_cache_breakpoint: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FilePath.
@immutable
final class LiveInputFilePath extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputFilePath.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFilePath'),
        'LiveInputFilePath',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'file_id', 'index', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `file_id` value.
  String get fileId => rawJson['file_id'] as String;

  /// Canonical `index` value.
  int get index => rawJson['index'] as int;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() =>
      _validateInputComponent('FilePath', rawJson, 'LiveInputFilePath');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFilePath copyWith({
    Object? fileId = liveUnset,
    Object? index = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFilePath.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'file_id': fileId, 'index': index},
      <String>{},
      'LiveInputFilePath',
    ),
  );
  @override
  String toString() =>
      'LiveInputFilePath(file_id: [REDACTED], index: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FileSearchTool.
@immutable
final class LiveInputFileSearchTool extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputFileSearchTool.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFileSearchTool'),
        'LiveInputFileSearchTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'filters',
    'max_num_results',
    'ranking_options',
    'type',
    'vector_store_ids',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `filters` value.
  LiveInputFilters? get filters => rawJson['filters'] == null
      ? null
      : LiveInputFilters.fromJson(rawJson['filters']);

  /// Distinguishes absent `filters` from an explicit null.
  bool get hasFilters => rawJson.containsKey('filters');

  /// Canonical `max_num_results` value.
  int? get maxNumResults => rawJson['max_num_results'] == null
      ? null
      : (rawJson['max_num_results'] as int);

  /// Distinguishes absent `max_num_results` from an explicit null.
  bool get hasMaxNumResults => rawJson.containsKey('max_num_results');

  /// Canonical `ranking_options` value.
  LiveInputRankingOptions? get rankingOptions =>
      rawJson['ranking_options'] == null
      ? null
      : LiveInputRankingOptions.fromJson(rawJson['ranking_options']);

  /// Distinguishes absent `ranking_options` from an explicit null.
  bool get hasRankingOptions => rawJson.containsKey('ranking_options');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `vector_store_ids` value.
  List<String> get vectorStoreIds => List.unmodifiable(
    (rawJson['vector_store_ids'] as List).map((value) => value as String),
  );
  @override
  void validate() => _validateInputComponent(
    'FileSearchTool',
    rawJson,
    'LiveInputFileSearchTool',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFileSearchTool copyWith({
    Object? filters = liveUnset,
    bool clearFilters = false,
    Object? maxNumResults = liveUnset,
    bool clearMaxNumResults = false,
    Object? rankingOptions = liveUnset,
    bool clearRankingOptions = false,
    Object? vectorStoreIds = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFileSearchTool.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'filters': filters,
        'max_num_results': maxNumResults,
        'ranking_options': rankingOptions,
        'vector_store_ids': vectorStoreIds,
      },
      <String>{
        if (clearFilters) 'filters',
        if (clearMaxNumResults) 'max_num_results',
        if (clearRankingOptions) 'ranking_options',
      },
      'LiveInputFileSearchTool',
    ),
  );
  @override
  String toString() =>
      'LiveInputFileSearchTool(filters: [REDACTED], max_num_results: [REDACTED], ranking_options: [REDACTED], type: [REDACTED], vector_store_ids: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FileSearchToolCall.
@immutable
final class LiveInputFileSearchToolCall extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputFileSearchToolCall.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFileSearchToolCall'),
        'LiveInputFileSearchToolCall',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'id',
    'queries',
    'results',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `queries` value.
  List<String> get queries => List.unmodifiable(
    (rawJson['queries'] as List).map((value) => value as String),
  );

  /// Canonical `results` value.
  List<LiveInputFileSearchToolCallResultsItemValue>? get results =>
      rawJson['results'] == null
      ? null
      : List.unmodifiable(
          (rawJson['results'] as List).map(
            LiveInputFileSearchToolCallResultsItemValue.fromJson,
          ),
        );

  /// Distinguishes absent `results` from an explicit null.
  bool get hasResults => rawJson.containsKey('results');

  /// Canonical `status` value.
  String get status => rawJson['status'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'FileSearchToolCall',
    rawJson,
    'LiveInputFileSearchToolCall',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFileSearchToolCall copyWith({
    Object? id = liveUnset,
    Object? queries = liveUnset,
    Object? results = liveUnset,
    bool clearResults = false,
    Object? status = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFileSearchToolCall.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'id': id, 'queries': queries, 'results': results, 'status': status},
      <String>{if (clearResults) 'results'},
      'LiveInputFileSearchToolCall',
    ),
  );
  @override
  String toString() =>
      'LiveInputFileSearchToolCall(id: [REDACTED], queries: [REDACTED], results: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for the canonical inline payload.
@immutable
final class LiveInputFileSearchToolCallResultsItemValue extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputFileSearchToolCallResultsItemValue.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFileSearchToolCallResultsItemValue'),
        'LiveInputFileSearchToolCallResultsItemValue',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'attributes',
    'file_id',
    'filename',
    'score',
    'text',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `attributes` value.
  LiveInputVectorStoreFileAttributes? get attributes =>
      rawJson['attributes'] == null
      ? null
      : LiveInputVectorStoreFileAttributes.fromJson(rawJson['attributes']);

  /// Distinguishes absent `attributes` from an explicit null.
  bool get hasAttributes => rawJson.containsKey('attributes');

  /// Canonical `file_id` value.
  String? get fileId =>
      rawJson['file_id'] == null ? null : (rawJson['file_id'] as String);

  /// Distinguishes absent `file_id` from an explicit null.
  bool get hasFileId => rawJson.containsKey('file_id');

  /// Canonical `filename` value.
  String? get filename =>
      rawJson['filename'] == null ? null : (rawJson['filename'] as String);

  /// Distinguishes absent `filename` from an explicit null.
  bool get hasFilename => rawJson.containsKey('filename');

  /// Canonical `score` value.
  num? get score => rawJson['score'] == null ? null : (rawJson['score'] as num);

  /// Distinguishes absent `score` from an explicit null.
  bool get hasScore => rawJson.containsKey('score');

  /// Canonical `text` value.
  String? get text =>
      rawJson['text'] == null ? null : (rawJson['text'] as String);

  /// Distinguishes absent `text` from an explicit null.
  bool get hasText => rawJson.containsKey('text');
  @override
  void validate() => _validateInputSchema(
    {
      'properties': {
        'attributes': {
          r'$ref': '#/components/schemas/VectorStoreFileAttributes',
        },
        'file_id': {'type': 'string'},
        'filename': {'type': 'string'},
        'score': {'format': 'float', 'type': 'number'},
        'text': {'type': 'string'},
      },
      'type': 'object',
    },
    rawJson,
    'LiveInputFileSearchToolCallResultsItemValue',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFileSearchToolCallResultsItemValue copyWith({
    Object? attributes = liveUnset,
    bool clearAttributes = false,
    Object? fileId = liveUnset,
    bool clearFileId = false,
    Object? filename = liveUnset,
    bool clearFilename = false,
    Object? score = liveUnset,
    bool clearScore = false,
    Object? text = liveUnset,
    bool clearText = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFileSearchToolCallResultsItemValue.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'attributes': attributes,
        'file_id': fileId,
        'filename': filename,
        'score': score,
        'text': text,
      },
      <String>{
        if (clearAttributes) 'attributes',
        if (clearFileId) 'file_id',
        if (clearFilename) 'filename',
        if (clearScore) 'score',
        if (clearText) 'text',
      },
      'LiveInputFileSearchToolCallResultsItemValue',
    ),
  );
  @override
  String toString() =>
      'LiveInputFileSearchToolCallResultsItemValue(attributes: [REDACTED], file_id: [REDACTED], filename: [REDACTED], score: [REDACTED], text: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FunctionCallOutputItemParam.
@immutable
final class LiveInputFunctionCallOutputItemParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputFunctionCallOutputItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFunctionCallOutputItemParam'),
        'LiveInputFunctionCallOutputItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'call_id',
    'caller',
    'id',
    'name',
    'namespace',
    'output',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `call_id` value.
  String? get callId =>
      rawJson['call_id'] == null ? null : (rawJson['call_id'] as String);

  /// Distinguishes absent `call_id` from an explicit null.
  bool get hasCallId => rawJson.containsKey('call_id');

  /// Canonical `caller` value.
  LiveInputToolCallCallerParam? get caller => rawJson['caller'] == null
      ? null
      : LiveInputToolCallCallerParam.fromJson(rawJson['caller']);

  /// Distinguishes absent `caller` from an explicit null.
  bool get hasCaller => rawJson.containsKey('caller');

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `name` value.
  String? get name =>
      rawJson['name'] == null ? null : (rawJson['name'] as String);

  /// Distinguishes absent `name` from an explicit null.
  bool get hasName => rawJson.containsKey('name');

  /// Canonical `namespace` value.
  String? get namespace =>
      rawJson['namespace'] == null ? null : (rawJson['namespace'] as String);

  /// Distinguishes absent `namespace` from an explicit null.
  bool get hasNamespace => rawJson.containsKey('namespace');

  /// Canonical `output` value.
  LiveInputFunctionCallOutputItemParamOutputValue get output =>
      LiveInputFunctionCallOutputItemParamOutputValue.fromJson(
        rawJson['output'],
      );

  /// Canonical `status` value.
  LiveInputFunctionCallItemStatus? get status => rawJson['status'] == null
      ? null
      : LiveInputFunctionCallItemStatus.fromJson(rawJson['status']);

  /// Distinguishes absent `status` from an explicit null.
  bool get hasStatus => rawJson.containsKey('status');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'FunctionCallOutputItemParam',
    rawJson,
    'LiveInputFunctionCallOutputItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFunctionCallOutputItemParam copyWith({
    Object? callId = liveUnset,
    bool clearCallId = false,
    Object? caller = liveUnset,
    bool clearCaller = false,
    Object? id = liveUnset,
    bool clearId = false,
    Object? name = liveUnset,
    bool clearName = false,
    Object? namespace = liveUnset,
    bool clearNamespace = false,
    Object? output = liveUnset,
    Object? status = liveUnset,
    bool clearStatus = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFunctionCallOutputItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'call_id': callId,
        'caller': caller,
        'id': id,
        'name': name,
        'namespace': namespace,
        'output': output,
        'status': status,
      },
      <String>{
        if (clearCallId) 'call_id',
        if (clearCaller) 'caller',
        if (clearId) 'id',
        if (clearName) 'name',
        if (clearNamespace) 'namespace',
        if (clearStatus) 'status',
      },
      'LiveInputFunctionCallOutputItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputFunctionCallOutputItemParam(call_id: [REDACTED], caller: [REDACTED], id: [REDACTED], name: [REDACTED], namespace: [REDACTED], output: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FunctionShellActionParam.
@immutable
final class LiveInputFunctionShellActionParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputFunctionShellActionParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFunctionShellActionParam'),
        'LiveInputFunctionShellActionParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'commands',
    'max_output_length',
    'timeout_ms',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `commands` value.
  List<String> get commands => List.unmodifiable(
    (rawJson['commands'] as List).map((value) => value as String),
  );

  /// Canonical `max_output_length` value.
  int? get maxOutputLength => rawJson['max_output_length'] == null
      ? null
      : (rawJson['max_output_length'] as int);

  /// Distinguishes absent `max_output_length` from an explicit null.
  bool get hasMaxOutputLength => rawJson.containsKey('max_output_length');

  /// Canonical `timeout_ms` value.
  int? get timeoutMs =>
      rawJson['timeout_ms'] == null ? null : (rawJson['timeout_ms'] as int);

  /// Distinguishes absent `timeout_ms` from an explicit null.
  bool get hasTimeoutMs => rawJson.containsKey('timeout_ms');
  @override
  void validate() => _validateInputComponent(
    'FunctionShellActionParam',
    rawJson,
    'LiveInputFunctionShellActionParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFunctionShellActionParam copyWith({
    Object? commands = liveUnset,
    Object? maxOutputLength = liveUnset,
    bool clearMaxOutputLength = false,
    Object? timeoutMs = liveUnset,
    bool clearTimeoutMs = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFunctionShellActionParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'commands': commands,
        'max_output_length': maxOutputLength,
        'timeout_ms': timeoutMs,
      },
      <String>{
        if (clearMaxOutputLength) 'max_output_length',
        if (clearTimeoutMs) 'timeout_ms',
      },
      'LiveInputFunctionShellActionParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputFunctionShellActionParam(commands: [REDACTED], max_output_length: [REDACTED], timeout_ms: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FunctionShellCallItemParam.
@immutable
final class LiveInputFunctionShellCallItemParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputFunctionShellCallItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFunctionShellCallItemParam'),
        'LiveInputFunctionShellCallItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'action',
    'call_id',
    'caller',
    'environment',
    'id',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `action` value.
  LiveInputFunctionShellActionParam get action =>
      LiveInputFunctionShellActionParam.fromJson(rawJson['action']);

  /// Canonical `call_id` value.
  String get callId => rawJson['call_id'] as String;

  /// Canonical `caller` value.
  LiveInputToolCallCallerParam? get caller => rawJson['caller'] == null
      ? null
      : LiveInputToolCallCallerParam.fromJson(rawJson['caller']);

  /// Distinguishes absent `caller` from an explicit null.
  bool get hasCaller => rawJson.containsKey('caller');

  /// Canonical `environment` value.
  LiveInputFunctionShellCallItemParamEnvironmentValue? get environment =>
      rawJson['environment'] == null
      ? null
      : LiveInputFunctionShellCallItemParamEnvironmentValue.fromJson(
          rawJson['environment'],
        );

  /// Distinguishes absent `environment` from an explicit null.
  bool get hasEnvironment => rawJson.containsKey('environment');

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `status` value.
  LiveInputFunctionShellCallItemStatus? get status => rawJson['status'] == null
      ? null
      : LiveInputFunctionShellCallItemStatus.fromJson(rawJson['status']);

  /// Distinguishes absent `status` from an explicit null.
  bool get hasStatus => rawJson.containsKey('status');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'FunctionShellCallItemParam',
    rawJson,
    'LiveInputFunctionShellCallItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFunctionShellCallItemParam copyWith({
    Object? action = liveUnset,
    Object? callId = liveUnset,
    Object? caller = liveUnset,
    bool clearCaller = false,
    Object? environment = liveUnset,
    bool clearEnvironment = false,
    Object? id = liveUnset,
    bool clearId = false,
    Object? status = liveUnset,
    bool clearStatus = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFunctionShellCallItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'action': action,
        'call_id': callId,
        'caller': caller,
        'environment': environment,
        'id': id,
        'status': status,
      },
      <String>{
        if (clearCaller) 'caller',
        if (clearEnvironment) 'environment',
        if (clearId) 'id',
        if (clearStatus) 'status',
      },
      'LiveInputFunctionShellCallItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputFunctionShellCallItemParam(action: [REDACTED], call_id: [REDACTED], caller: [REDACTED], environment: [REDACTED], id: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FunctionShellCallOutputContentParam.
@immutable
final class LiveInputFunctionShellCallOutputContentParam
    extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputFunctionShellCallOutputContentParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFunctionShellCallOutputContentParam'),
        'LiveInputFunctionShellCallOutputContentParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'outcome', 'stderr', 'stdout'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `outcome` value.
  LiveInputFunctionShellCallOutputOutcomeParam get outcome =>
      LiveInputFunctionShellCallOutputOutcomeParam.fromJson(rawJson['outcome']);

  /// Canonical `stderr` value.
  String get stderr => rawJson['stderr'] as String;

  /// Canonical `stdout` value.
  String get stdout => rawJson['stdout'] as String;
  @override
  void validate() => _validateInputComponent(
    'FunctionShellCallOutputContentParam',
    rawJson,
    'LiveInputFunctionShellCallOutputContentParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFunctionShellCallOutputContentParam copyWith({
    Object? outcome = liveUnset,
    Object? stderr = liveUnset,
    Object? stdout = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFunctionShellCallOutputContentParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'outcome': outcome, 'stderr': stderr, 'stdout': stdout},
      <String>{},
      'LiveInputFunctionShellCallOutputContentParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputFunctionShellCallOutputContentParam(outcome: [REDACTED], stderr: [REDACTED], stdout: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FunctionShellCallOutputExitOutcomeParam.
@immutable
final class LiveInputFunctionShellCallOutputExitOutcomeParam
    extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(
          json,
          'LiveInputFunctionShellCallOutputExitOutcomeParam',
        ),
        'LiveInputFunctionShellCallOutputExitOutcomeParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'exit_code', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `exit_code` value.
  int get exitCode => rawJson['exit_code'] as int;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'FunctionShellCallOutputExitOutcomeParam',
    rawJson,
    'LiveInputFunctionShellCallOutputExitOutcomeParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFunctionShellCallOutputExitOutcomeParam copyWith({
    Object? exitCode = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'exit_code': exitCode},
      <String>{},
      'LiveInputFunctionShellCallOutputExitOutcomeParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputFunctionShellCallOutputExitOutcomeParam(exit_code: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FunctionShellCallOutputItemParam.
@immutable
final class LiveInputFunctionShellCallOutputItemParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputFunctionShellCallOutputItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFunctionShellCallOutputItemParam'),
        'LiveInputFunctionShellCallOutputItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'call_id',
    'caller',
    'id',
    'max_output_length',
    'output',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `call_id` value.
  String get callId => rawJson['call_id'] as String;

  /// Canonical `caller` value.
  LiveInputToolCallCallerParam? get caller => rawJson['caller'] == null
      ? null
      : LiveInputToolCallCallerParam.fromJson(rawJson['caller']);

  /// Distinguishes absent `caller` from an explicit null.
  bool get hasCaller => rawJson.containsKey('caller');

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `max_output_length` value.
  int? get maxOutputLength => rawJson['max_output_length'] == null
      ? null
      : (rawJson['max_output_length'] as int);

  /// Distinguishes absent `max_output_length` from an explicit null.
  bool get hasMaxOutputLength => rawJson.containsKey('max_output_length');

  /// Canonical `output` value.
  List<LiveInputFunctionShellCallOutputContentParam> get output =>
      List.unmodifiable(
        (rawJson['output'] as List).map(
          LiveInputFunctionShellCallOutputContentParam.fromJson,
        ),
      );

  /// Canonical `status` value.
  LiveInputFunctionShellCallItemStatus? get status => rawJson['status'] == null
      ? null
      : LiveInputFunctionShellCallItemStatus.fromJson(rawJson['status']);

  /// Distinguishes absent `status` from an explicit null.
  bool get hasStatus => rawJson.containsKey('status');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'FunctionShellCallOutputItemParam',
    rawJson,
    'LiveInputFunctionShellCallOutputItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFunctionShellCallOutputItemParam copyWith({
    Object? callId = liveUnset,
    Object? caller = liveUnset,
    bool clearCaller = false,
    Object? id = liveUnset,
    bool clearId = false,
    Object? maxOutputLength = liveUnset,
    bool clearMaxOutputLength = false,
    Object? output = liveUnset,
    Object? status = liveUnset,
    bool clearStatus = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFunctionShellCallOutputItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'call_id': callId,
        'caller': caller,
        'id': id,
        'max_output_length': maxOutputLength,
        'output': output,
        'status': status,
      },
      <String>{
        if (clearCaller) 'caller',
        if (clearId) 'id',
        if (clearMaxOutputLength) 'max_output_length',
        if (clearStatus) 'status',
      },
      'LiveInputFunctionShellCallOutputItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputFunctionShellCallOutputItemParam(call_id: [REDACTED], caller: [REDACTED], id: [REDACTED], max_output_length: [REDACTED], output: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FunctionShellCallOutputTimeoutOutcomeParam.
@immutable
final class LiveInputFunctionShellCallOutputTimeoutOutcomeParam
    extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputFunctionShellCallOutputTimeoutOutcomeParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(
          json,
          'LiveInputFunctionShellCallOutputTimeoutOutcomeParam',
        ),
        'LiveInputFunctionShellCallOutputTimeoutOutcomeParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'FunctionShellCallOutputTimeoutOutcomeParam',
    rawJson,
    'LiveInputFunctionShellCallOutputTimeoutOutcomeParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFunctionShellCallOutputTimeoutOutcomeParam copyWith({
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFunctionShellCallOutputTimeoutOutcomeParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {},
      <String>{},
      'LiveInputFunctionShellCallOutputTimeoutOutcomeParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputFunctionShellCallOutputTimeoutOutcomeParam(type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FunctionShellToolParam.
@immutable
final class LiveInputFunctionShellToolParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputFunctionShellToolParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFunctionShellToolParam'),
        'LiveInputFunctionShellToolParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'allowed_callers',
    'environment',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `allowed_callers` value.
  List<LiveInputCallableToolAllowedCaller>? get allowedCallers =>
      rawJson['allowed_callers'] == null
      ? null
      : List.unmodifiable(
          (rawJson['allowed_callers'] as List).map(
            LiveInputCallableToolAllowedCaller.fromJson,
          ),
        );

  /// Distinguishes absent `allowed_callers` from an explicit null.
  bool get hasAllowedCallers => rawJson.containsKey('allowed_callers');

  /// Canonical `environment` value.
  LiveInputFunctionShellToolParamEnvironmentValue? get environment =>
      rawJson['environment'] == null
      ? null
      : LiveInputFunctionShellToolParamEnvironmentValue.fromJson(
          rawJson['environment'],
        );

  /// Distinguishes absent `environment` from an explicit null.
  bool get hasEnvironment => rawJson.containsKey('environment');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'FunctionShellToolParam',
    rawJson,
    'LiveInputFunctionShellToolParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFunctionShellToolParam copyWith({
    Object? allowedCallers = liveUnset,
    bool clearAllowedCallers = false,
    Object? environment = liveUnset,
    bool clearEnvironment = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFunctionShellToolParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'allowed_callers': allowedCallers, 'environment': environment},
      <String>{
        if (clearAllowedCallers) 'allowed_callers',
        if (clearEnvironment) 'environment',
      },
      'LiveInputFunctionShellToolParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputFunctionShellToolParam(allowed_callers: [REDACTED], environment: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FunctionTool.
@immutable
final class LiveInputFunctionTool extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputFunctionTool.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFunctionTool'),
        'LiveInputFunctionTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'allowed_callers',
    'async',
    'defer_loading',
    'description',
    'name',
    'output_schema',
    'parameters',
    'strict',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `allowed_callers` value.
  List<LiveInputCallableToolAllowedCaller>? get allowedCallers =>
      rawJson['allowed_callers'] == null
      ? null
      : List.unmodifiable(
          (rawJson['allowed_callers'] as List).map(
            LiveInputCallableToolAllowedCaller.fromJson,
          ),
        );

  /// Distinguishes absent `allowed_callers` from an explicit null.
  bool get hasAllowedCallers => rawJson.containsKey('allowed_callers');

  /// Canonical `async` value.
  bool? get async =>
      rawJson['async'] == null ? null : (rawJson['async'] as bool);

  /// Distinguishes absent `async` from an explicit null.
  bool get hasAsync => rawJson.containsKey('async');

  /// Canonical `defer_loading` value.
  bool? get deferLoading => rawJson['defer_loading'] == null
      ? null
      : (rawJson['defer_loading'] as bool);

  /// Distinguishes absent `defer_loading` from an explicit null.
  bool get hasDeferLoading => rawJson.containsKey('defer_loading');

  /// Canonical `description` value.
  String? get description => rawJson['description'] == null
      ? null
      : (rawJson['description'] as String);

  /// Distinguishes absent `description` from an explicit null.
  bool get hasDescription => rawJson.containsKey('description');

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;

  /// Canonical `output_schema` value.
  Map<String, dynamic>? get outputSchema => rawJson['output_schema'] == null
      ? null
      : Map<String, dynamic>.unmodifiable(
          requireLiveObject(
            rawJson['output_schema'],
            'LiveInputFunctionTool.output_schema',
          ),
        );

  /// Distinguishes absent `output_schema` from an explicit null.
  bool get hasOutputSchema => rawJson.containsKey('output_schema');

  /// Canonical `parameters` value.
  Map<String, dynamic>? get parameters => rawJson['parameters'] == null
      ? null
      : Map<String, dynamic>.unmodifiable(
          requireLiveObject(
            rawJson['parameters'],
            'LiveInputFunctionTool.parameters',
          ),
        );

  /// Canonical `strict` value.
  bool? get strict =>
      rawJson['strict'] == null ? null : (rawJson['strict'] as bool);

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() =>
      _validateInputComponent('FunctionTool', rawJson, 'LiveInputFunctionTool');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFunctionTool copyWith({
    Object? allowedCallers = liveUnset,
    bool clearAllowedCallers = false,
    Object? async = liveUnset,
    bool clearAsync = false,
    Object? deferLoading = liveUnset,
    bool clearDeferLoading = false,
    Object? description = liveUnset,
    bool clearDescription = false,
    Object? name = liveUnset,
    Object? outputSchema = liveUnset,
    bool clearOutputSchema = false,
    Object? parameters = liveUnset,
    Object? strict = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFunctionTool.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'allowed_callers': allowedCallers,
        'async': async,
        'defer_loading': deferLoading,
        'description': description,
        'name': name,
        'output_schema': outputSchema,
        'parameters': parameters,
        'strict': strict,
      },
      <String>{
        if (clearAllowedCallers) 'allowed_callers',
        if (clearAsync) 'async',
        if (clearDeferLoading) 'defer_loading',
        if (clearDescription) 'description',
        if (clearOutputSchema) 'output_schema',
      },
      'LiveInputFunctionTool',
    ),
  );
  @override
  String toString() =>
      'LiveInputFunctionTool(allowed_callers: [REDACTED], async: [REDACTED], defer_loading: [REDACTED], description: [REDACTED], name: [REDACTED], output_schema: [REDACTED], parameters: [REDACTED], strict: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FunctionToolCall.
@immutable
final class LiveInputFunctionToolCall extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputFunctionToolCall.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFunctionToolCall'),
        'LiveInputFunctionToolCall',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'arguments',
    'async',
    'call_id',
    'caller',
    'id',
    'name',
    'namespace',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `arguments` value.
  String get arguments => rawJson['arguments'] as String;

  /// Canonical `async` value.
  bool? get async =>
      rawJson['async'] == null ? null : (rawJson['async'] as bool);

  /// Distinguishes absent `async` from an explicit null.
  bool get hasAsync => rawJson.containsKey('async');

  /// Canonical `call_id` value.
  String get callId => rawJson['call_id'] as String;

  /// Canonical `caller` value.
  LiveInputToolCallCaller? get caller => rawJson['caller'] == null
      ? null
      : LiveInputToolCallCaller.fromJson(rawJson['caller']);

  /// Distinguishes absent `caller` from an explicit null.
  bool get hasCaller => rawJson.containsKey('caller');

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;

  /// Canonical `namespace` value.
  String? get namespace =>
      rawJson['namespace'] == null ? null : (rawJson['namespace'] as String);

  /// Distinguishes absent `namespace` from an explicit null.
  bool get hasNamespace => rawJson.containsKey('namespace');

  /// Canonical `status` value.
  String? get status =>
      rawJson['status'] == null ? null : (rawJson['status'] as String);

  /// Distinguishes absent `status` from an explicit null.
  bool get hasStatus => rawJson.containsKey('status');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'FunctionToolCall',
    rawJson,
    'LiveInputFunctionToolCall',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFunctionToolCall copyWith({
    Object? arguments = liveUnset,
    Object? async = liveUnset,
    bool clearAsync = false,
    Object? callId = liveUnset,
    Object? caller = liveUnset,
    bool clearCaller = false,
    Object? id = liveUnset,
    bool clearId = false,
    Object? name = liveUnset,
    Object? namespace = liveUnset,
    bool clearNamespace = false,
    Object? status = liveUnset,
    bool clearStatus = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFunctionToolCall.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'arguments': arguments,
        'async': async,
        'call_id': callId,
        'caller': caller,
        'id': id,
        'name': name,
        'namespace': namespace,
        'status': status,
      },
      <String>{
        if (clearAsync) 'async',
        if (clearCaller) 'caller',
        if (clearId) 'id',
        if (clearNamespace) 'namespace',
        if (clearStatus) 'status',
      },
      'LiveInputFunctionToolCall',
    ),
  );
  @override
  String toString() =>
      'LiveInputFunctionToolCall(arguments: [REDACTED], async: [REDACTED], call_id: [REDACTED], caller: [REDACTED], id: [REDACTED], name: [REDACTED], namespace: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for FunctionToolParam.
@immutable
final class LiveInputFunctionToolParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputFunctionToolParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputFunctionToolParam'),
        'LiveInputFunctionToolParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'allowed_callers',
    'async',
    'defer_loading',
    'description',
    'name',
    'output_schema',
    'parameters',
    'strict',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `allowed_callers` value.
  List<LiveInputCallableToolAllowedCaller>? get allowedCallers =>
      rawJson['allowed_callers'] == null
      ? null
      : List.unmodifiable(
          (rawJson['allowed_callers'] as List).map(
            LiveInputCallableToolAllowedCaller.fromJson,
          ),
        );

  /// Distinguishes absent `allowed_callers` from an explicit null.
  bool get hasAllowedCallers => rawJson.containsKey('allowed_callers');

  /// Canonical `async` value.
  bool? get async =>
      rawJson['async'] == null ? null : (rawJson['async'] as bool);

  /// Distinguishes absent `async` from an explicit null.
  bool get hasAsync => rawJson.containsKey('async');

  /// Canonical `defer_loading` value.
  bool? get deferLoading => rawJson['defer_loading'] == null
      ? null
      : (rawJson['defer_loading'] as bool);

  /// Distinguishes absent `defer_loading` from an explicit null.
  bool get hasDeferLoading => rawJson.containsKey('defer_loading');

  /// Canonical `description` value.
  String? get description => rawJson['description'] == null
      ? null
      : (rawJson['description'] as String);

  /// Distinguishes absent `description` from an explicit null.
  bool get hasDescription => rawJson.containsKey('description');

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;

  /// Canonical `output_schema` value.
  Map<String, dynamic>? get outputSchema => rawJson['output_schema'] == null
      ? null
      : Map<String, dynamic>.unmodifiable(
          requireLiveObject(
            rawJson['output_schema'],
            'LiveInputFunctionToolParam.output_schema',
          ),
        );

  /// Distinguishes absent `output_schema` from an explicit null.
  bool get hasOutputSchema => rawJson.containsKey('output_schema');

  /// Canonical `parameters` value.
  LiveInputEmptyModelParam? get parameters => rawJson['parameters'] == null
      ? null
      : LiveInputEmptyModelParam.fromJson(rawJson['parameters']);

  /// Distinguishes absent `parameters` from an explicit null.
  bool get hasParameters => rawJson.containsKey('parameters');

  /// Canonical `strict` value.
  bool? get strict =>
      rawJson['strict'] == null ? null : (rawJson['strict'] as bool);

  /// Distinguishes absent `strict` from an explicit null.
  bool get hasStrict => rawJson.containsKey('strict');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'FunctionToolParam',
    rawJson,
    'LiveInputFunctionToolParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputFunctionToolParam copyWith({
    Object? allowedCallers = liveUnset,
    bool clearAllowedCallers = false,
    Object? async = liveUnset,
    bool clearAsync = false,
    Object? deferLoading = liveUnset,
    bool clearDeferLoading = false,
    Object? description = liveUnset,
    bool clearDescription = false,
    Object? name = liveUnset,
    Object? outputSchema = liveUnset,
    bool clearOutputSchema = false,
    Object? parameters = liveUnset,
    bool clearParameters = false,
    Object? strict = liveUnset,
    bool clearStrict = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputFunctionToolParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'allowed_callers': allowedCallers,
        'async': async,
        'defer_loading': deferLoading,
        'description': description,
        'name': name,
        'output_schema': outputSchema,
        'parameters': parameters,
        'strict': strict,
      },
      <String>{
        if (clearAllowedCallers) 'allowed_callers',
        if (clearAsync) 'async',
        if (clearDeferLoading) 'defer_loading',
        if (clearDescription) 'description',
        if (clearOutputSchema) 'output_schema',
        if (clearParameters) 'parameters',
        if (clearStrict) 'strict',
      },
      'LiveInputFunctionToolParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputFunctionToolParam(allowed_callers: [REDACTED], async: [REDACTED], defer_loading: [REDACTED], description: [REDACTED], name: [REDACTED], output_schema: [REDACTED], parameters: [REDACTED], strict: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for HTTPError.
@immutable
final class LiveInputHTTPError extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputHTTPError.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputHTTPError'),
        'LiveInputHTTPError',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'code', 'message', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `code` value.
  int get code => rawJson['code'] as int;

  /// Canonical `message` value.
  String get message => rawJson['message'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() =>
      _validateInputComponent('HTTPError', rawJson, 'LiveInputHTTPError');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputHTTPError copyWith({
    Object? code = liveUnset,
    Object? message = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputHTTPError.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'code': code, 'message': message},
      <String>{},
      'LiveInputHTTPError',
    ),
  );
  @override
  String toString() =>
      'LiveInputHTTPError(code: [REDACTED], message: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for HybridSearchOptions.
@immutable
final class LiveInputHybridSearchOptions extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputHybridSearchOptions.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputHybridSearchOptions'),
        'LiveInputHybridSearchOptions',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'embedding_weight', 'text_weight'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `embedding_weight` value.
  num get embeddingWeight => rawJson['embedding_weight'] as num;

  /// Canonical `text_weight` value.
  num get textWeight => rawJson['text_weight'] as num;
  @override
  void validate() => _validateInputComponent(
    'HybridSearchOptions',
    rawJson,
    'LiveInputHybridSearchOptions',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputHybridSearchOptions copyWith({
    Object? embeddingWeight = liveUnset,
    Object? textWeight = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputHybridSearchOptions.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'embedding_weight': embeddingWeight, 'text_weight': textWeight},
      <String>{},
      'LiveInputHybridSearchOptions',
    ),
  );
  @override
  String toString() =>
      'LiveInputHybridSearchOptions(embedding_weight: [REDACTED], text_weight: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for InputImageContent.
@immutable
final class LiveInputImageContent extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputImageContent.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputImageContent'),
        'LiveInputImageContent',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'detail',
    'file_id',
    'image_url',
    'prompt_cache_breakpoint',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `detail` value.
  LiveInputImageDetail get detail =>
      LiveInputImageDetail.fromJson(rawJson['detail']);

  /// Canonical `file_id` value.
  String? get fileId =>
      rawJson['file_id'] == null ? null : (rawJson['file_id'] as String);

  /// Distinguishes absent `file_id` from an explicit null.
  bool get hasFileId => rawJson.containsKey('file_id');

  /// Canonical `image_url` value.
  String? get imageUrl =>
      rawJson['image_url'] == null ? null : (rawJson['image_url'] as String);

  /// Distinguishes absent `image_url` from an explicit null.
  bool get hasImageUrl => rawJson.containsKey('image_url');

  /// Canonical `prompt_cache_breakpoint` value.
  LiveInputPromptCacheBreakpointConfig? get promptCacheBreakpoint =>
      rawJson['prompt_cache_breakpoint'] == null
      ? null
      : LiveInputPromptCacheBreakpointConfig.fromJson(
          rawJson['prompt_cache_breakpoint'],
        );

  /// Distinguishes absent `prompt_cache_breakpoint` from an explicit null.
  bool get hasPromptCacheBreakpoint =>
      rawJson.containsKey('prompt_cache_breakpoint');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'InputImageContent',
    rawJson,
    'LiveInputImageContent',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputImageContent copyWith({
    Object? detail = liveUnset,
    Object? fileId = liveUnset,
    bool clearFileId = false,
    Object? imageUrl = liveUnset,
    bool clearImageUrl = false,
    Object? promptCacheBreakpoint = liveUnset,
    bool clearPromptCacheBreakpoint = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputImageContent.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'detail': detail,
        'file_id': fileId,
        'image_url': imageUrl,
        'prompt_cache_breakpoint': promptCacheBreakpoint,
      },
      <String>{
        if (clearFileId) 'file_id',
        if (clearImageUrl) 'image_url',
        if (clearPromptCacheBreakpoint) 'prompt_cache_breakpoint',
      },
      'LiveInputImageContent',
    ),
  );
  @override
  String toString() =>
      'LiveInputImageContent(detail: [REDACTED], file_id: [REDACTED], image_url: [REDACTED], prompt_cache_breakpoint: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for InputImageContentParamAutoParam.
@immutable
final class LiveInputImageContentParamAutoParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputImageContentParamAutoParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputImageContentParamAutoParam'),
        'LiveInputImageContentParamAutoParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'detail',
    'file_id',
    'image_url',
    'prompt_cache_breakpoint',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `detail` value.
  LiveInputDetailEnum? get detail => rawJson['detail'] == null
      ? null
      : LiveInputDetailEnum.fromJson(rawJson['detail']);

  /// Distinguishes absent `detail` from an explicit null.
  bool get hasDetail => rawJson.containsKey('detail');

  /// Canonical `file_id` value.
  String? get fileId =>
      rawJson['file_id'] == null ? null : (rawJson['file_id'] as String);

  /// Distinguishes absent `file_id` from an explicit null.
  bool get hasFileId => rawJson.containsKey('file_id');

  /// Canonical `image_url` value.
  String? get imageUrl =>
      rawJson['image_url'] == null ? null : (rawJson['image_url'] as String);

  /// Distinguishes absent `image_url` from an explicit null.
  bool get hasImageUrl => rawJson.containsKey('image_url');

  /// Canonical `prompt_cache_breakpoint` value.
  LiveInputPromptCacheBreakpointParam? get promptCacheBreakpoint =>
      rawJson['prompt_cache_breakpoint'] == null
      ? null
      : LiveInputPromptCacheBreakpointParam.fromJson(
          rawJson['prompt_cache_breakpoint'],
        );

  /// Distinguishes absent `prompt_cache_breakpoint` from an explicit null.
  bool get hasPromptCacheBreakpoint =>
      rawJson.containsKey('prompt_cache_breakpoint');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'InputImageContentParamAutoParam',
    rawJson,
    'LiveInputImageContentParamAutoParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputImageContentParamAutoParam copyWith({
    Object? detail = liveUnset,
    bool clearDetail = false,
    Object? fileId = liveUnset,
    bool clearFileId = false,
    Object? imageUrl = liveUnset,
    bool clearImageUrl = false,
    Object? promptCacheBreakpoint = liveUnset,
    bool clearPromptCacheBreakpoint = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputImageContentParamAutoParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'detail': detail,
        'file_id': fileId,
        'image_url': imageUrl,
        'prompt_cache_breakpoint': promptCacheBreakpoint,
      },
      <String>{
        if (clearDetail) 'detail',
        if (clearFileId) 'file_id',
        if (clearImageUrl) 'image_url',
        if (clearPromptCacheBreakpoint) 'prompt_cache_breakpoint',
      },
      'LiveInputImageContentParamAutoParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputImageContentParamAutoParam(detail: [REDACTED], file_id: [REDACTED], image_url: [REDACTED], prompt_cache_breakpoint: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ImageGenTool.
@immutable
final class LiveInputImageGenTool extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputImageGenTool.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputImageGenTool'),
        'LiveInputImageGenTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'action',
    'background',
    'input_fidelity',
    'input_image_mask',
    'model',
    'moderation',
    'output_compression',
    'output_format',
    'partial_images',
    'quality',
    'size',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `action` value.
  LiveInputImageGenActionEnum? get action => rawJson['action'] == null
      ? null
      : LiveInputImageGenActionEnum.fromJson(rawJson['action']);

  /// Distinguishes absent `action` from an explicit null.
  bool get hasAction => rawJson.containsKey('action');

  /// Canonical `background` value.
  String? get background =>
      rawJson['background'] == null ? null : (rawJson['background'] as String);

  /// Distinguishes absent `background` from an explicit null.
  bool get hasBackground => rawJson.containsKey('background');

  /// Canonical `input_fidelity` value.
  LiveInputFidelity? get inputFidelity => rawJson['input_fidelity'] == null
      ? null
      : LiveInputFidelity.fromJson(rawJson['input_fidelity']);

  /// Distinguishes absent `input_fidelity` from an explicit null.
  bool get hasInputFidelity => rawJson.containsKey('input_fidelity');

  /// Canonical `input_image_mask` value.
  LiveInputImageGenToolInputImageMaskValue? get inputImageMask =>
      rawJson['input_image_mask'] == null
      ? null
      : LiveInputImageGenToolInputImageMaskValue.fromJson(
          rawJson['input_image_mask'],
        );

  /// Distinguishes absent `input_image_mask` from an explicit null.
  bool get hasInputImageMask => rawJson.containsKey('input_image_mask');

  /// Canonical `model` value.
  LiveInputImageGenToolModelValue? get model => rawJson['model'] == null
      ? null
      : LiveInputImageGenToolModelValue.fromJson(rawJson['model']);

  /// Distinguishes absent `model` from an explicit null.
  bool get hasModel => rawJson.containsKey('model');

  /// Canonical `moderation` value.
  String? get moderation =>
      rawJson['moderation'] == null ? null : (rawJson['moderation'] as String);

  /// Distinguishes absent `moderation` from an explicit null.
  bool get hasModeration => rawJson.containsKey('moderation');

  /// Canonical `output_compression` value.
  int? get outputCompression => rawJson['output_compression'] == null
      ? null
      : (rawJson['output_compression'] as int);

  /// Distinguishes absent `output_compression` from an explicit null.
  bool get hasOutputCompression => rawJson.containsKey('output_compression');

  /// Canonical `output_format` value.
  String? get outputFormat => rawJson['output_format'] == null
      ? null
      : (rawJson['output_format'] as String);

  /// Distinguishes absent `output_format` from an explicit null.
  bool get hasOutputFormat => rawJson.containsKey('output_format');

  /// Canonical `partial_images` value.
  int? get partialImages => rawJson['partial_images'] == null
      ? null
      : (rawJson['partial_images'] as int);

  /// Distinguishes absent `partial_images` from an explicit null.
  bool get hasPartialImages => rawJson.containsKey('partial_images');

  /// Canonical `quality` value.
  String? get quality =>
      rawJson['quality'] == null ? null : (rawJson['quality'] as String);

  /// Distinguishes absent `quality` from an explicit null.
  bool get hasQuality => rawJson.containsKey('quality');

  /// Canonical `size` value.
  LiveInputImageGenToolSizeValue? get size => rawJson['size'] == null
      ? null
      : LiveInputImageGenToolSizeValue.fromJson(rawJson['size']);

  /// Distinguishes absent `size` from an explicit null.
  bool get hasSize => rawJson.containsKey('size');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() =>
      _validateInputComponent('ImageGenTool', rawJson, 'LiveInputImageGenTool');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputImageGenTool copyWith({
    Object? action = liveUnset,
    bool clearAction = false,
    Object? background = liveUnset,
    bool clearBackground = false,
    Object? inputFidelity = liveUnset,
    bool clearInputFidelity = false,
    Object? inputImageMask = liveUnset,
    bool clearInputImageMask = false,
    Object? model = liveUnset,
    bool clearModel = false,
    Object? moderation = liveUnset,
    bool clearModeration = false,
    Object? outputCompression = liveUnset,
    bool clearOutputCompression = false,
    Object? outputFormat = liveUnset,
    bool clearOutputFormat = false,
    Object? partialImages = liveUnset,
    bool clearPartialImages = false,
    Object? quality = liveUnset,
    bool clearQuality = false,
    Object? size = liveUnset,
    bool clearSize = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputImageGenTool.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'action': action,
        'background': background,
        'input_fidelity': inputFidelity,
        'input_image_mask': inputImageMask,
        'model': model,
        'moderation': moderation,
        'output_compression': outputCompression,
        'output_format': outputFormat,
        'partial_images': partialImages,
        'quality': quality,
        'size': size,
      },
      <String>{
        if (clearAction) 'action',
        if (clearBackground) 'background',
        if (clearInputFidelity) 'input_fidelity',
        if (clearInputImageMask) 'input_image_mask',
        if (clearModel) 'model',
        if (clearModeration) 'moderation',
        if (clearOutputCompression) 'output_compression',
        if (clearOutputFormat) 'output_format',
        if (clearPartialImages) 'partial_images',
        if (clearQuality) 'quality',
        if (clearSize) 'size',
      },
      'LiveInputImageGenTool',
    ),
  );
  @override
  String toString() =>
      'LiveInputImageGenTool(action: [REDACTED], background: [REDACTED], input_fidelity: [REDACTED], input_image_mask: [REDACTED], model: [REDACTED], moderation: [REDACTED], output_compression: [REDACTED], output_format: [REDACTED], partial_images: [REDACTED], quality: [REDACTED], size: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ImageGenToolCall.
@immutable
final class LiveInputImageGenToolCall extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputImageGenToolCall.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputImageGenToolCall'),
        'LiveInputImageGenToolCall',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'action',
    'background',
    'id',
    'output_format',
    'quality',
    'result',
    'revised_prompt',
    'size',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `action` value.
  LiveInputImageGenActionEnum? get action => rawJson['action'] == null
      ? null
      : LiveInputImageGenActionEnum.fromJson(rawJson['action']);

  /// Distinguishes absent `action` from an explicit null.
  bool get hasAction => rawJson.containsKey('action');

  /// Canonical `background` value.
  LiveInputImageBackground? get background => rawJson['background'] == null
      ? null
      : LiveInputImageBackground.fromJson(rawJson['background']);

  /// Distinguishes absent `background` from an explicit null.
  bool get hasBackground => rawJson.containsKey('background');

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `output_format` value.
  LiveInputImageOutputFormat? get outputFormat =>
      rawJson['output_format'] == null
      ? null
      : LiveInputImageOutputFormat.fromJson(rawJson['output_format']);

  /// Distinguishes absent `output_format` from an explicit null.
  bool get hasOutputFormat => rawJson.containsKey('output_format');

  /// Canonical `quality` value.
  String? get quality =>
      rawJson['quality'] == null ? null : (rawJson['quality'] as String);

  /// Distinguishes absent `quality` from an explicit null.
  bool get hasQuality => rawJson.containsKey('quality');

  /// Canonical `result` value.
  String? get result =>
      rawJson['result'] == null ? null : (rawJson['result'] as String);

  /// Canonical `revised_prompt` value.
  String? get revisedPrompt => rawJson['revised_prompt'] == null
      ? null
      : (rawJson['revised_prompt'] as String);

  /// Distinguishes absent `revised_prompt` from an explicit null.
  bool get hasRevisedPrompt => rawJson.containsKey('revised_prompt');

  /// Canonical `size` value.
  LiveInputImageGenToolCallSizeValue? get size => rawJson['size'] == null
      ? null
      : LiveInputImageGenToolCallSizeValue.fromJson(rawJson['size']);

  /// Distinguishes absent `size` from an explicit null.
  bool get hasSize => rawJson.containsKey('size');

  /// Canonical `status` value.
  String get status => rawJson['status'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ImageGenToolCall',
    rawJson,
    'LiveInputImageGenToolCall',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputImageGenToolCall copyWith({
    Object? action = liveUnset,
    bool clearAction = false,
    Object? background = liveUnset,
    bool clearBackground = false,
    Object? id = liveUnset,
    Object? outputFormat = liveUnset,
    bool clearOutputFormat = false,
    Object? quality = liveUnset,
    bool clearQuality = false,
    Object? result = liveUnset,
    Object? revisedPrompt = liveUnset,
    bool clearRevisedPrompt = false,
    Object? size = liveUnset,
    bool clearSize = false,
    Object? status = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputImageGenToolCall.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'action': action,
        'background': background,
        'id': id,
        'output_format': outputFormat,
        'quality': quality,
        'result': result,
        'revised_prompt': revisedPrompt,
        'size': size,
        'status': status,
      },
      <String>{
        if (clearAction) 'action',
        if (clearBackground) 'background',
        if (clearOutputFormat) 'output_format',
        if (clearQuality) 'quality',
        if (clearRevisedPrompt) 'revised_prompt',
        if (clearSize) 'size',
      },
      'LiveInputImageGenToolCall',
    ),
  );
  @override
  String toString() =>
      'LiveInputImageGenToolCall(action: [REDACTED], background: [REDACTED], id: [REDACTED], output_format: [REDACTED], quality: [REDACTED], result: [REDACTED], revised_prompt: [REDACTED], size: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for the canonical inline payload.
@immutable
final class LiveInputImageGenToolInputImageMaskValue extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputImageGenToolInputImageMaskValue.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputImageGenToolInputImageMaskValue'),
        'LiveInputImageGenToolInputImageMaskValue',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'file_id', 'image_url'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `file_id` value.
  String? get fileId =>
      rawJson['file_id'] == null ? null : (rawJson['file_id'] as String);

  /// Distinguishes absent `file_id` from an explicit null.
  bool get hasFileId => rawJson.containsKey('file_id');

  /// Canonical `image_url` value.
  String? get imageUrl =>
      rawJson['image_url'] == null ? null : (rawJson['image_url'] as String);

  /// Distinguishes absent `image_url` from an explicit null.
  bool get hasImageUrl => rawJson.containsKey('image_url');
  @override
  void validate() => _validateInputSchema(
    {
      'additionalProperties': false,
      'properties': {
        'file_id': {'type': 'string'},
        'image_url': {'type': 'string'},
      },
      'required': <dynamic>[],
      'type': 'object',
    },
    rawJson,
    'LiveInputImageGenToolInputImageMaskValue',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputImageGenToolInputImageMaskValue copyWith({
    Object? fileId = liveUnset,
    bool clearFileId = false,
    Object? imageUrl = liveUnset,
    bool clearImageUrl = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputImageGenToolInputImageMaskValue.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'file_id': fileId, 'image_url': imageUrl},
      <String>{if (clearFileId) 'file_id', if (clearImageUrl) 'image_url'},
      'LiveInputImageGenToolInputImageMaskValue',
    ),
  );
  @override
  String toString() =>
      'LiveInputImageGenToolInputImageMaskValue(file_id: [REDACTED], image_url: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for InlineSkillParam.
@immutable
final class LiveInputInlineSkillParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputInlineSkillParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputInlineSkillParam'),
        'LiveInputInlineSkillParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'description',
    'name',
    'source',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `description` value.
  String get description => rawJson['description'] as String;

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;

  /// Canonical `source` value.
  LiveInputInlineSkillSourceParam get source =>
      LiveInputInlineSkillSourceParam.fromJson(rawJson['source']);

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'InlineSkillParam',
    rawJson,
    'LiveInputInlineSkillParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputInlineSkillParam copyWith({
    Object? description = liveUnset,
    Object? name = liveUnset,
    Object? source = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputInlineSkillParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'description': description, 'name': name, 'source': source},
      <String>{},
      'LiveInputInlineSkillParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputInlineSkillParam(description: [REDACTED], name: [REDACTED], source: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for InlineSkillSourceParam.
@immutable
final class LiveInputInlineSkillSourceParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputInlineSkillSourceParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputInlineSkillSourceParam'),
        'LiveInputInlineSkillSourceParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'data', 'media_type', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `data` value.
  String get data => rawJson['data'] as String;

  /// Canonical `media_type` value.
  String get mediaType => rawJson['media_type'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'InlineSkillSourceParam',
    rawJson,
    'LiveInputInlineSkillSourceParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputInlineSkillSourceParam copyWith({
    Object? data = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputInlineSkillSourceParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'data': data},
      <String>{},
      'LiveInputInlineSkillSourceParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputInlineSkillSourceParam(data: [REDACTED], media_type: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ItemReferenceParam.
@immutable
final class LiveInputItemReferenceParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputItemReferenceParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputItemReferenceParam'),
        'LiveInputItemReferenceParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'id', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `type` value.
  String? get type =>
      rawJson['type'] == null ? null : (rawJson['type'] as String);

  /// Distinguishes absent `type` from an explicit null.
  bool get hasType => rawJson.containsKey('type');
  @override
  void validate() => _validateInputComponent(
    'ItemReferenceParam',
    rawJson,
    'LiveInputItemReferenceParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputItemReferenceParam copyWith({
    Object? id = liveUnset,
    Object? type = liveUnset,
    bool clearType = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputItemReferenceParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'id': id, 'type': type},
      <String>{if (clearType) 'type'},
      'LiveInputItemReferenceParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputItemReferenceParam(id: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for KeyPressAction.
@immutable
final class LiveInputKeyPressAction extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputKeyPressAction.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputKeyPressAction'),
        'LiveInputKeyPressAction',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'keys', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `keys` value.
  List<String> get keys => List.unmodifiable(
    (rawJson['keys'] as List).map((value) => value as String),
  );

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'KeyPressAction',
    rawJson,
    'LiveInputKeyPressAction',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputKeyPressAction copyWith({
    Object? keys = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputKeyPressAction.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'keys': keys},
      <String>{},
      'LiveInputKeyPressAction',
    ),
  );
  @override
  String toString() =>
      'LiveInputKeyPressAction(keys: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for LocalEnvironmentParam.
@immutable
final class LiveInputLocalEnvironmentParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputLocalEnvironmentParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputLocalEnvironmentParam'),
        'LiveInputLocalEnvironmentParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'skills', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `skills` value.
  List<LiveInputLocalSkillParam>? get skills => rawJson['skills'] == null
      ? null
      : List.unmodifiable(
          (rawJson['skills'] as List).map(LiveInputLocalSkillParam.fromJson),
        );

  /// Distinguishes absent `skills` from an explicit null.
  bool get hasSkills => rawJson.containsKey('skills');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'LocalEnvironmentParam',
    rawJson,
    'LiveInputLocalEnvironmentParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputLocalEnvironmentParam copyWith({
    Object? skills = liveUnset,
    bool clearSkills = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputLocalEnvironmentParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'skills': skills},
      <String>{if (clearSkills) 'skills'},
      'LiveInputLocalEnvironmentParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputLocalEnvironmentParam(skills: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for LocalShellExecAction.
@immutable
final class LiveInputLocalShellExecAction extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputLocalShellExecAction.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputLocalShellExecAction'),
        'LiveInputLocalShellExecAction',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'command',
    'env',
    'timeout_ms',
    'type',
    'user',
    'working_directory',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `command` value.
  List<String> get command => List.unmodifiable(
    (rawJson['command'] as List).map((value) => value as String),
  );

  /// Canonical `env` value.
  Map<String, dynamic> get env => Map<String, dynamic>.unmodifiable(
    requireLiveObject(rawJson['env'], 'LiveInputLocalShellExecAction.env'),
  );

  /// Canonical `timeout_ms` value.
  int? get timeoutMs =>
      rawJson['timeout_ms'] == null ? null : (rawJson['timeout_ms'] as int);

  /// Distinguishes absent `timeout_ms` from an explicit null.
  bool get hasTimeoutMs => rawJson.containsKey('timeout_ms');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `user` value.
  String? get user =>
      rawJson['user'] == null ? null : (rawJson['user'] as String);

  /// Distinguishes absent `user` from an explicit null.
  bool get hasUser => rawJson.containsKey('user');

  /// Canonical `working_directory` value.
  String? get workingDirectory => rawJson['working_directory'] == null
      ? null
      : (rawJson['working_directory'] as String);

  /// Distinguishes absent `working_directory` from an explicit null.
  bool get hasWorkingDirectory => rawJson.containsKey('working_directory');
  @override
  void validate() => _validateInputComponent(
    'LocalShellExecAction',
    rawJson,
    'LiveInputLocalShellExecAction',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputLocalShellExecAction copyWith({
    Object? command = liveUnset,
    Object? env = liveUnset,
    Object? timeoutMs = liveUnset,
    bool clearTimeoutMs = false,
    Object? user = liveUnset,
    bool clearUser = false,
    Object? workingDirectory = liveUnset,
    bool clearWorkingDirectory = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputLocalShellExecAction.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'command': command,
        'env': env,
        'timeout_ms': timeoutMs,
        'user': user,
        'working_directory': workingDirectory,
      },
      <String>{
        if (clearTimeoutMs) 'timeout_ms',
        if (clearUser) 'user',
        if (clearWorkingDirectory) 'working_directory',
      },
      'LiveInputLocalShellExecAction',
    ),
  );
  @override
  String toString() =>
      'LiveInputLocalShellExecAction(command: [REDACTED], env: [REDACTED], timeout_ms: [REDACTED], type: [REDACTED], user: [REDACTED], working_directory: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for LocalShellToolCall.
@immutable
final class LiveInputLocalShellToolCall extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputLocalShellToolCall.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputLocalShellToolCall'),
        'LiveInputLocalShellToolCall',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'action',
    'call_id',
    'id',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `action` value.
  LiveInputLocalShellExecAction get action =>
      LiveInputLocalShellExecAction.fromJson(rawJson['action']);

  /// Canonical `call_id` value.
  String get callId => rawJson['call_id'] as String;

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `status` value.
  String get status => rawJson['status'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'LocalShellToolCall',
    rawJson,
    'LiveInputLocalShellToolCall',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputLocalShellToolCall copyWith({
    Object? action = liveUnset,
    Object? callId = liveUnset,
    Object? id = liveUnset,
    Object? status = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputLocalShellToolCall.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'action': action, 'call_id': callId, 'id': id, 'status': status},
      <String>{},
      'LiveInputLocalShellToolCall',
    ),
  );
  @override
  String toString() =>
      'LiveInputLocalShellToolCall(action: [REDACTED], call_id: [REDACTED], id: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for LocalShellToolCallOutput.
@immutable
final class LiveInputLocalShellToolCallOutput extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputLocalShellToolCallOutput.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputLocalShellToolCallOutput'),
        'LiveInputLocalShellToolCallOutput',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'id',
    'output',
    'status',
    'type',
    'call_id',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `output` value.
  String get output => rawJson['output'] as String;

  /// Canonical `status` value.
  String? get status =>
      rawJson['status'] == null ? null : (rawJson['status'] as String);

  /// Distinguishes absent `status` from an explicit null.
  bool get hasStatus => rawJson.containsKey('status');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `call_id` value.
  Object? get callId => rawJson['call_id'];
  @override
  void validate() => _validateInputComponent(
    'LocalShellToolCallOutput',
    rawJson,
    'LiveInputLocalShellToolCallOutput',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputLocalShellToolCallOutput copyWith({
    Object? id = liveUnset,
    Object? output = liveUnset,
    Object? status = liveUnset,
    bool clearStatus = false,
    Object? callId = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputLocalShellToolCallOutput.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'id': id, 'output': output, 'status': status, 'call_id': callId},
      <String>{if (clearStatus) 'status'},
      'LiveInputLocalShellToolCallOutput',
    ),
  );
  @override
  String toString() =>
      'LiveInputLocalShellToolCallOutput(id: [REDACTED], output: [REDACTED], status: [REDACTED], type: [REDACTED], call_id: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for LocalShellToolParam.
@immutable
final class LiveInputLocalShellToolParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputLocalShellToolParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputLocalShellToolParam'),
        'LiveInputLocalShellToolParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'LocalShellToolParam',
    rawJson,
    'LiveInputLocalShellToolParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputLocalShellToolParam copyWith({
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputLocalShellToolParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {},
      <String>{},
      'LiveInputLocalShellToolParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputLocalShellToolParam(type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for LocalSkillParam.
@immutable
final class LiveInputLocalSkillParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputLocalSkillParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputLocalSkillParam'),
        'LiveInputLocalSkillParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'description', 'name', 'path'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `description` value.
  String get description => rawJson['description'] as String;

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;

  /// Canonical `path` value.
  String get path => rawJson['path'] as String;
  @override
  void validate() => _validateInputComponent(
    'LocalSkillParam',
    rawJson,
    'LiveInputLocalSkillParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputLocalSkillParam copyWith({
    Object? description = liveUnset,
    Object? name = liveUnset,
    Object? path = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputLocalSkillParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'description': description, 'name': name, 'path': path},
      <String>{},
      'LiveInputLocalSkillParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputLocalSkillParam(description: [REDACTED], name: [REDACTED], path: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for LogProb.
@immutable
final class LiveInputLogProb extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputLogProb.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputLogProb'),
        'LiveInputLogProb',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'bytes',
    'logprob',
    'token',
    'top_logprobs',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `bytes` value.
  List<int> get bytes => List.unmodifiable(
    (rawJson['bytes'] as List).map((value) => value as int),
  );

  /// Canonical `logprob` value.
  num get logprob => rawJson['logprob'] as num;

  /// Canonical `token` value.
  String get token => rawJson['token'] as String;

  /// Canonical `top_logprobs` value.
  List<LiveInputTopLogProb> get topLogprobs => List.unmodifiable(
    (rawJson['top_logprobs'] as List).map(LiveInputTopLogProb.fromJson),
  );
  @override
  void validate() =>
      _validateInputComponent('LogProb', rawJson, 'LiveInputLogProb');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputLogProb copyWith({
    Object? bytes = liveUnset,
    Object? logprob = liveUnset,
    Object? token = liveUnset,
    Object? topLogprobs = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputLogProb.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'bytes': bytes,
        'logprob': logprob,
        'token': token,
        'top_logprobs': topLogprobs,
      },
      <String>{},
      'LiveInputLogProb',
    ),
  );
  @override
  String toString() =>
      'LiveInputLogProb(bytes: [REDACTED], logprob: [REDACTED], token: [REDACTED], top_logprobs: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for MCPApprovalRequest.
@immutable
final class LiveInputMCPApprovalRequest extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputMCPApprovalRequest.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputMCPApprovalRequest'),
        'LiveInputMCPApprovalRequest',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'arguments',
    'id',
    'name',
    'server_label',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `arguments` value.
  String get arguments => rawJson['arguments'] as String;

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;

  /// Canonical `server_label` value.
  String get serverLabel => rawJson['server_label'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'MCPApprovalRequest',
    rawJson,
    'LiveInputMCPApprovalRequest',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputMCPApprovalRequest copyWith({
    Object? arguments = liveUnset,
    Object? id = liveUnset,
    Object? name = liveUnset,
    Object? serverLabel = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputMCPApprovalRequest.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'arguments': arguments,
        'id': id,
        'name': name,
        'server_label': serverLabel,
      },
      <String>{},
      'LiveInputMCPApprovalRequest',
    ),
  );
  @override
  String toString() =>
      'LiveInputMCPApprovalRequest(arguments: [REDACTED], id: [REDACTED], name: [REDACTED], server_label: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for MCPApprovalResponse.
@immutable
final class LiveInputMCPApprovalResponse extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputMCPApprovalResponse.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputMCPApprovalResponse'),
        'LiveInputMCPApprovalResponse',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'approval_request_id',
    'approve',
    'id',
    'reason',
    'type',
    'request_id',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `approval_request_id` value.
  String get approvalRequestId => rawJson['approval_request_id'] as String;

  /// Canonical `approve` value.
  bool get approve => rawJson['approve'] as bool;

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `reason` value.
  String? get reason =>
      rawJson['reason'] == null ? null : (rawJson['reason'] as String);

  /// Distinguishes absent `reason` from an explicit null.
  bool get hasReason => rawJson.containsKey('reason');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `request_id` value.
  Object? get requestId => rawJson['request_id'];
  @override
  void validate() => _validateInputComponent(
    'MCPApprovalResponse',
    rawJson,
    'LiveInputMCPApprovalResponse',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputMCPApprovalResponse copyWith({
    Object? approvalRequestId = liveUnset,
    Object? approve = liveUnset,
    Object? id = liveUnset,
    bool clearId = false,
    Object? reason = liveUnset,
    bool clearReason = false,
    Object? requestId = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputMCPApprovalResponse.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'approval_request_id': approvalRequestId,
        'approve': approve,
        'id': id,
        'reason': reason,
        'request_id': requestId,
      },
      <String>{if (clearId) 'id', if (clearReason) 'reason'},
      'LiveInputMCPApprovalResponse',
    ),
  );
  @override
  String toString() =>
      'LiveInputMCPApprovalResponse(approval_request_id: [REDACTED], approve: [REDACTED], id: [REDACTED], reason: [REDACTED], type: [REDACTED], request_id: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for MCPListTools.
@immutable
final class LiveInputMCPListTools extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputMCPListTools.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputMCPListTools'),
        'LiveInputMCPListTools',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'error',
    'id',
    'server_label',
    'tools',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `error` value.
  String? get error =>
      rawJson['error'] == null ? null : (rawJson['error'] as String);

  /// Distinguishes absent `error` from an explicit null.
  bool get hasError => rawJson.containsKey('error');

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `server_label` value.
  String get serverLabel => rawJson['server_label'] as String;

  /// Canonical `tools` value.
  List<LiveInputMCPListToolsTool> get tools => List.unmodifiable(
    (rawJson['tools'] as List).map(LiveInputMCPListToolsTool.fromJson),
  );

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() =>
      _validateInputComponent('MCPListTools', rawJson, 'LiveInputMCPListTools');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputMCPListTools copyWith({
    Object? error = liveUnset,
    bool clearError = false,
    Object? id = liveUnset,
    Object? serverLabel = liveUnset,
    Object? tools = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputMCPListTools.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'error': error, 'id': id, 'server_label': serverLabel, 'tools': tools},
      <String>{if (clearError) 'error'},
      'LiveInputMCPListTools',
    ),
  );
  @override
  String toString() =>
      'LiveInputMCPListTools(error: [REDACTED], id: [REDACTED], server_label: [REDACTED], tools: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for MCPListToolsTool.
@immutable
final class LiveInputMCPListToolsTool extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputMCPListToolsTool.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputMCPListToolsTool'),
        'LiveInputMCPListToolsTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'annotations',
    'description',
    'input_schema',
    'name',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `annotations` value.
  Map<String, dynamic>? get annotations => rawJson['annotations'] == null
      ? null
      : Map<String, dynamic>.unmodifiable(
          requireLiveObject(
            rawJson['annotations'],
            'LiveInputMCPListToolsTool.annotations',
          ),
        );

  /// Distinguishes absent `annotations` from an explicit null.
  bool get hasAnnotations => rawJson.containsKey('annotations');

  /// Canonical `description` value.
  String? get description => rawJson['description'] == null
      ? null
      : (rawJson['description'] as String);

  /// Distinguishes absent `description` from an explicit null.
  bool get hasDescription => rawJson.containsKey('description');

  /// Canonical `input_schema` value.
  Map<String, dynamic> get inputSchema => Map<String, dynamic>.unmodifiable(
    requireLiveObject(
      rawJson['input_schema'],
      'LiveInputMCPListToolsTool.input_schema',
    ),
  );

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;
  @override
  void validate() => _validateInputComponent(
    'MCPListToolsTool',
    rawJson,
    'LiveInputMCPListToolsTool',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputMCPListToolsTool copyWith({
    Object? annotations = liveUnset,
    bool clearAnnotations = false,
    Object? description = liveUnset,
    bool clearDescription = false,
    Object? inputSchema = liveUnset,
    Object? name = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputMCPListToolsTool.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'annotations': annotations,
        'description': description,
        'input_schema': inputSchema,
        'name': name,
      },
      <String>{
        if (clearAnnotations) 'annotations',
        if (clearDescription) 'description',
      },
      'LiveInputMCPListToolsTool',
    ),
  );
  @override
  String toString() =>
      'LiveInputMCPListToolsTool(annotations: [REDACTED], description: [REDACTED], input_schema: [REDACTED], name: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for MCPProtocolError.
@immutable
final class LiveInputMCPProtocolError extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputMCPProtocolError.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputMCPProtocolError'),
        'LiveInputMCPProtocolError',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'code', 'message', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `code` value.
  int get code => rawJson['code'] as int;

  /// Canonical `message` value.
  String get message => rawJson['message'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'MCPProtocolError',
    rawJson,
    'LiveInputMCPProtocolError',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputMCPProtocolError copyWith({
    Object? code = liveUnset,
    Object? message = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputMCPProtocolError.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'code': code, 'message': message},
      <String>{},
      'LiveInputMCPProtocolError',
    ),
  );
  @override
  String toString() =>
      'LiveInputMCPProtocolError(code: [REDACTED], message: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for MCPTool.
@immutable
final class LiveInputMCPTool extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputMCPTool.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputMCPTool'),
        'LiveInputMCPTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'allowed_callers',
    'allowed_tools',
    'authorization',
    'connector_id',
    'defer_loading',
    'headers',
    'require_approval',
    'server_description',
    'server_label',
    'server_url',
    'tunnel_id',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `allowed_callers` value.
  List<LiveInputCallableToolAllowedCaller>? get allowedCallers =>
      rawJson['allowed_callers'] == null
      ? null
      : List.unmodifiable(
          (rawJson['allowed_callers'] as List).map(
            LiveInputCallableToolAllowedCaller.fromJson,
          ),
        );

  /// Distinguishes absent `allowed_callers` from an explicit null.
  bool get hasAllowedCallers => rawJson.containsKey('allowed_callers');

  /// Canonical `allowed_tools` value.
  LiveInputMCPToolAllowedToolsValue? get allowedTools =>
      rawJson['allowed_tools'] == null
      ? null
      : LiveInputMCPToolAllowedToolsValue.fromJson(rawJson['allowed_tools']);

  /// Distinguishes absent `allowed_tools` from an explicit null.
  bool get hasAllowedTools => rawJson.containsKey('allowed_tools');

  /// Canonical `authorization` value.
  String? get authorization => rawJson['authorization'] == null
      ? null
      : (rawJson['authorization'] as String);

  /// Distinguishes absent `authorization` from an explicit null.
  bool get hasAuthorization => rawJson.containsKey('authorization');

  /// Canonical `connector_id` value.
  String? get connectorId => rawJson['connector_id'] == null
      ? null
      : (rawJson['connector_id'] as String);

  /// Distinguishes absent `connector_id` from an explicit null.
  bool get hasConnectorId => rawJson.containsKey('connector_id');

  /// Canonical `defer_loading` value.
  bool? get deferLoading => rawJson['defer_loading'] == null
      ? null
      : (rawJson['defer_loading'] as bool);

  /// Distinguishes absent `defer_loading` from an explicit null.
  bool get hasDeferLoading => rawJson.containsKey('defer_loading');

  /// Canonical `headers` value.
  Map<String, dynamic>? get headers => rawJson['headers'] == null
      ? null
      : Map<String, dynamic>.unmodifiable(
          requireLiveObject(rawJson['headers'], 'LiveInputMCPTool.headers'),
        );

  /// Distinguishes absent `headers` from an explicit null.
  bool get hasHeaders => rawJson.containsKey('headers');

  /// Canonical `require_approval` value.
  LiveInputMCPToolRequireApprovalValue? get requireApproval =>
      rawJson['require_approval'] == null
      ? null
      : LiveInputMCPToolRequireApprovalValue.fromJson(
          rawJson['require_approval'],
        );

  /// Distinguishes absent `require_approval` from an explicit null.
  bool get hasRequireApproval => rawJson.containsKey('require_approval');

  /// Canonical `server_description` value.
  String? get serverDescription => rawJson['server_description'] == null
      ? null
      : (rawJson['server_description'] as String);

  /// Distinguishes absent `server_description` from an explicit null.
  bool get hasServerDescription => rawJson.containsKey('server_description');

  /// Canonical `server_label` value.
  String get serverLabel => rawJson['server_label'] as String;

  /// Canonical `server_url` value.
  String? get serverUrl =>
      rawJson['server_url'] == null ? null : (rawJson['server_url'] as String);

  /// Distinguishes absent `server_url` from an explicit null.
  bool get hasServerUrl => rawJson.containsKey('server_url');

  /// Canonical `tunnel_id` value.
  String? get tunnelId =>
      rawJson['tunnel_id'] == null ? null : (rawJson['tunnel_id'] as String);

  /// Distinguishes absent `tunnel_id` from an explicit null.
  bool get hasTunnelId => rawJson.containsKey('tunnel_id');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() =>
      _validateInputComponent('MCPTool', rawJson, 'LiveInputMCPTool');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputMCPTool copyWith({
    Object? allowedCallers = liveUnset,
    bool clearAllowedCallers = false,
    Object? allowedTools = liveUnset,
    bool clearAllowedTools = false,
    Object? authorization = liveUnset,
    bool clearAuthorization = false,
    Object? connectorId = liveUnset,
    bool clearConnectorId = false,
    Object? deferLoading = liveUnset,
    bool clearDeferLoading = false,
    Object? headers = liveUnset,
    bool clearHeaders = false,
    Object? requireApproval = liveUnset,
    bool clearRequireApproval = false,
    Object? serverDescription = liveUnset,
    bool clearServerDescription = false,
    Object? serverLabel = liveUnset,
    Object? serverUrl = liveUnset,
    bool clearServerUrl = false,
    Object? tunnelId = liveUnset,
    bool clearTunnelId = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputMCPTool.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'allowed_callers': allowedCallers,
        'allowed_tools': allowedTools,
        'authorization': authorization,
        'connector_id': connectorId,
        'defer_loading': deferLoading,
        'headers': headers,
        'require_approval': requireApproval,
        'server_description': serverDescription,
        'server_label': serverLabel,
        'server_url': serverUrl,
        'tunnel_id': tunnelId,
      },
      <String>{
        if (clearAllowedCallers) 'allowed_callers',
        if (clearAllowedTools) 'allowed_tools',
        if (clearAuthorization) 'authorization',
        if (clearConnectorId) 'connector_id',
        if (clearDeferLoading) 'defer_loading',
        if (clearHeaders) 'headers',
        if (clearRequireApproval) 'require_approval',
        if (clearServerDescription) 'server_description',
        if (clearServerUrl) 'server_url',
        if (clearTunnelId) 'tunnel_id',
      },
      'LiveInputMCPTool',
    ),
  );
  @override
  String toString() =>
      'LiveInputMCPTool(allowed_callers: [REDACTED], allowed_tools: [REDACTED], authorization: [REDACTED], connector_id: [REDACTED], defer_loading: [REDACTED], headers: [REDACTED], require_approval: [REDACTED], server_description: [REDACTED], server_label: [REDACTED], server_url: [REDACTED], tunnel_id: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for MCPToolCall.
@immutable
final class LiveInputMCPToolCall extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputMCPToolCall.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputMCPToolCall'),
        'LiveInputMCPToolCall',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'approval_request_id',
    'arguments',
    'error',
    'id',
    'name',
    'output',
    'server_label',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `approval_request_id` value.
  String? get approvalRequestId => rawJson['approval_request_id'] == null
      ? null
      : (rawJson['approval_request_id'] as String);

  /// Distinguishes absent `approval_request_id` from an explicit null.
  bool get hasApprovalRequestId => rawJson.containsKey('approval_request_id');

  /// Canonical `arguments` value.
  String get arguments => rawJson['arguments'] as String;

  /// Canonical `error` value.
  LiveInputMCPToolCallError? get error => rawJson['error'] == null
      ? null
      : LiveInputMCPToolCallError.fromJson(rawJson['error']);

  /// Distinguishes absent `error` from an explicit null.
  bool get hasError => rawJson.containsKey('error');

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;

  /// Canonical `output` value.
  String? get output =>
      rawJson['output'] == null ? null : (rawJson['output'] as String);

  /// Distinguishes absent `output` from an explicit null.
  bool get hasOutput => rawJson.containsKey('output');

  /// Canonical `server_label` value.
  String get serverLabel => rawJson['server_label'] as String;

  /// Canonical `status` value.
  LiveInputMCPToolCallStatus? get status => rawJson['status'] == null
      ? null
      : LiveInputMCPToolCallStatus.fromJson(rawJson['status']);

  /// Distinguishes absent `status` from an explicit null.
  bool get hasStatus => rawJson.containsKey('status');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() =>
      _validateInputComponent('MCPToolCall', rawJson, 'LiveInputMCPToolCall');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputMCPToolCall copyWith({
    Object? approvalRequestId = liveUnset,
    bool clearApprovalRequestId = false,
    Object? arguments = liveUnset,
    Object? error = liveUnset,
    bool clearError = false,
    Object? id = liveUnset,
    Object? name = liveUnset,
    Object? output = liveUnset,
    bool clearOutput = false,
    Object? serverLabel = liveUnset,
    Object? status = liveUnset,
    bool clearStatus = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputMCPToolCall.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'approval_request_id': approvalRequestId,
        'arguments': arguments,
        'error': error,
        'id': id,
        'name': name,
        'output': output,
        'server_label': serverLabel,
        'status': status,
      },
      <String>{
        if (clearApprovalRequestId) 'approval_request_id',
        if (clearError) 'error',
        if (clearOutput) 'output',
        if (clearStatus) 'status',
      },
      'LiveInputMCPToolCall',
    ),
  );
  @override
  String toString() =>
      'LiveInputMCPToolCall(approval_request_id: [REDACTED], arguments: [REDACTED], error: [REDACTED], id: [REDACTED], name: [REDACTED], output: [REDACTED], server_label: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for MCPToolExecutionError.
@immutable
final class LiveInputMCPToolExecutionError extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputMCPToolExecutionError.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputMCPToolExecutionError'),
        'LiveInputMCPToolExecutionError',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'content', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `content` value.
  Object? get content => rawJson['content'];

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'MCPToolExecutionError',
    rawJson,
    'LiveInputMCPToolExecutionError',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputMCPToolExecutionError copyWith({
    Object? content = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputMCPToolExecutionError.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'content': content},
      <String>{},
      'LiveInputMCPToolExecutionError',
    ),
  );
  @override
  String toString() =>
      'LiveInputMCPToolExecutionError(content: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for MCPToolFilter.
@immutable
final class LiveInputMCPToolFilter extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputMCPToolFilter.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputMCPToolFilter'),
        'LiveInputMCPToolFilter',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'read_only', 'tool_names'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `read_only` value.
  bool? get readOnly =>
      rawJson['read_only'] == null ? null : (rawJson['read_only'] as bool);

  /// Distinguishes absent `read_only` from an explicit null.
  bool get hasReadOnly => rawJson.containsKey('read_only');

  /// Canonical `tool_names` value.
  List<String>? get toolNames => rawJson['tool_names'] == null
      ? null
      : List.unmodifiable(
          (rawJson['tool_names'] as List).map((value) => value as String),
        );

  /// Distinguishes absent `tool_names` from an explicit null.
  bool get hasToolNames => rawJson.containsKey('tool_names');
  @override
  void validate() => _validateInputComponent(
    'MCPToolFilter',
    rawJson,
    'LiveInputMCPToolFilter',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputMCPToolFilter copyWith({
    Object? readOnly = liveUnset,
    bool clearReadOnly = false,
    Object? toolNames = liveUnset,
    bool clearToolNames = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputMCPToolFilter.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'read_only': readOnly, 'tool_names': toolNames},
      <String>{
        if (clearReadOnly) 'read_only',
        if (clearToolNames) 'tool_names',
      },
      'LiveInputMCPToolFilter',
    ),
  );
  @override
  String toString() =>
      'LiveInputMCPToolFilter(read_only: [REDACTED], tool_names: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for the canonical inline payload.
@immutable
final class LiveInputMCPToolRequireApprovalValueBranch0Value
    extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputMCPToolRequireApprovalValueBranch0Value.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(
          json,
          'LiveInputMCPToolRequireApprovalValueBranch0Value',
        ),
        'LiveInputMCPToolRequireApprovalValueBranch0Value',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'always', 'never'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `always` value.
  LiveInputMCPToolFilter? get always => rawJson['always'] == null
      ? null
      : LiveInputMCPToolFilter.fromJson(rawJson['always']);

  /// Distinguishes absent `always` from an explicit null.
  bool get hasAlways => rawJson.containsKey('always');

  /// Canonical `never` value.
  LiveInputMCPToolFilter? get never => rawJson['never'] == null
      ? null
      : LiveInputMCPToolFilter.fromJson(rawJson['never']);

  /// Distinguishes absent `never` from an explicit null.
  bool get hasNever => rawJson.containsKey('never');
  @override
  void validate() => _validateInputSchema(
    {
      'additionalProperties': false,
      'properties': {
        'always': {r'$ref': '#/components/schemas/MCPToolFilter'},
        'never': {r'$ref': '#/components/schemas/MCPToolFilter'},
      },
      'type': 'object',
    },
    rawJson,
    'LiveInputMCPToolRequireApprovalValueBranch0Value',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputMCPToolRequireApprovalValueBranch0Value copyWith({
    Object? always = liveUnset,
    bool clearAlways = false,
    Object? never = liveUnset,
    bool clearNever = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputMCPToolRequireApprovalValueBranch0Value.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'always': always, 'never': never},
      <String>{if (clearAlways) 'always', if (clearNever) 'never'},
      'LiveInputMCPToolRequireApprovalValueBranch0Value',
    ),
  );
  @override
  String toString() =>
      'LiveInputMCPToolRequireApprovalValueBranch0Value(always: [REDACTED], never: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for InputMessage.
@immutable
final class LiveInputMessage extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputMessage.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputMessage'),
        'LiveInputMessage',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'content', 'role', 'status', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `content` value.
  LiveInputMessageContentList get content =>
      LiveInputMessageContentList.fromJson(rawJson['content']);

  /// Canonical `role` value.
  String get role => rawJson['role'] as String;

  /// Canonical `status` value.
  String? get status =>
      rawJson['status'] == null ? null : (rawJson['status'] as String);

  /// Distinguishes absent `status` from an explicit null.
  bool get hasStatus => rawJson.containsKey('status');

  /// Canonical `type` value.
  String? get type =>
      rawJson['type'] == null ? null : (rawJson['type'] as String);

  /// Distinguishes absent `type` from an explicit null.
  bool get hasType => rawJson.containsKey('type');
  @override
  void validate() =>
      _validateInputComponent('InputMessage', rawJson, 'LiveInputMessage');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputMessage copyWith({
    Object? content = liveUnset,
    Object? role = liveUnset,
    Object? status = liveUnset,
    bool clearStatus = false,
    Object? type = liveUnset,
    bool clearType = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputMessage.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'content': content, 'role': role, 'status': status, 'type': type},
      <String>{if (clearStatus) 'status', if (clearType) 'type'},
      'LiveInputMessage',
    ),
  );
  @override
  String toString() =>
      'LiveInputMessage(content: [REDACTED], role: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for MoveParam.
@immutable
final class LiveInputMoveParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputMoveParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputMoveParam'),
        'LiveInputMoveParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'keys', 'type', 'x', 'y'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `keys` value.
  List<String>? get keys => rawJson['keys'] == null
      ? null
      : List.unmodifiable(
          (rawJson['keys'] as List).map((value) => value as String),
        );

  /// Distinguishes absent `keys` from an explicit null.
  bool get hasKeys => rawJson.containsKey('keys');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `x` value.
  int get x => rawJson['x'] as int;

  /// Canonical `y` value.
  int get y => rawJson['y'] as int;
  @override
  void validate() =>
      _validateInputComponent('MoveParam', rawJson, 'LiveInputMoveParam');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputMoveParam copyWith({
    Object? keys = liveUnset,
    bool clearKeys = false,
    Object? x = liveUnset,
    Object? y = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputMoveParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'keys': keys, 'x': x, 'y': y},
      <String>{if (clearKeys) 'keys'},
      'LiveInputMoveParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputMoveParam(keys: [REDACTED], type: [REDACTED], x: [REDACTED], y: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for NamespaceToolParam.
@immutable
final class LiveInputNamespaceToolParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputNamespaceToolParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputNamespaceToolParam'),
        'LiveInputNamespaceToolParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'description',
    'name',
    'tools',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `description` value.
  String get description => rawJson['description'] as String;

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;

  /// Canonical `tools` value.
  List<LiveInputNamespaceToolParamToolsItemValue> get tools =>
      List.unmodifiable(
        (rawJson['tools'] as List).map(
          LiveInputNamespaceToolParamToolsItemValue.fromJson,
        ),
      );

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'NamespaceToolParam',
    rawJson,
    'LiveInputNamespaceToolParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputNamespaceToolParam copyWith({
    Object? description = liveUnset,
    Object? name = liveUnset,
    Object? tools = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputNamespaceToolParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'description': description, 'name': name, 'tools': tools},
      <String>{},
      'LiveInputNamespaceToolParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputNamespaceToolParam(description: [REDACTED], name: [REDACTED], tools: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for OutputMessage.
@immutable
final class LiveInputOutputMessage extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputOutputMessage.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputOutputMessage'),
        'LiveInputOutputMessage',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'content',
    'id',
    'phase',
    'role',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `content` value.
  List<LiveInputOutputMessageContent> get content => List.unmodifiable(
    (rawJson['content'] as List).map(LiveInputOutputMessageContent.fromJson),
  );

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `phase` value.
  LiveInputMessagePhase? get phase => rawJson['phase'] == null
      ? null
      : LiveInputMessagePhase.fromJson(rawJson['phase']);

  /// Distinguishes absent `phase` from an explicit null.
  bool get hasPhase => rawJson.containsKey('phase');

  /// Canonical `role` value.
  String get role => rawJson['role'] as String;

  /// Canonical `status` value.
  String get status => rawJson['status'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'OutputMessage',
    rawJson,
    'LiveInputOutputMessage',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputOutputMessage copyWith({
    Object? content = liveUnset,
    Object? id = liveUnset,
    Object? phase = liveUnset,
    bool clearPhase = false,
    Object? status = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputOutputMessage.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'content': content, 'id': id, 'phase': phase, 'status': status},
      <String>{if (clearPhase) 'phase'},
      'LiveInputOutputMessage',
    ),
  );
  @override
  String toString() =>
      'LiveInputOutputMessage(content: [REDACTED], id: [REDACTED], phase: [REDACTED], role: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for OutputTextContent.
@immutable
final class LiveInputOutputTextContent extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputOutputTextContent.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputOutputTextContent'),
        'LiveInputOutputTextContent',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'annotations',
    'logprobs',
    'text',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `annotations` value.
  List<LiveInputAnnotation> get annotations => List.unmodifiable(
    (rawJson['annotations'] as List).map(LiveInputAnnotation.fromJson),
  );

  /// Canonical `logprobs` value.
  List<LiveInputLogProb> get logprobs => List.unmodifiable(
    (rawJson['logprobs'] as List).map(LiveInputLogProb.fromJson),
  );

  /// Canonical `text` value.
  String get text => rawJson['text'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'OutputTextContent',
    rawJson,
    'LiveInputOutputTextContent',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputOutputTextContent copyWith({
    Object? annotations = liveUnset,
    Object? logprobs = liveUnset,
    Object? text = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputOutputTextContent.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'annotations': annotations, 'logprobs': logprobs, 'text': text},
      <String>{},
      'LiveInputOutputTextContent',
    ),
  );
  @override
  String toString() =>
      'LiveInputOutputTextContent(annotations: [REDACTED], logprobs: [REDACTED], text: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ProgramItemParam.
@immutable
final class LiveInputProgramItemParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputProgramItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputProgramItemParam'),
        'LiveInputProgramItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'call_id',
    'code',
    'fingerprint',
    'id',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `call_id` value.
  String get callId => rawJson['call_id'] as String;

  /// Canonical `code` value.
  String get code => rawJson['code'] as String;

  /// Canonical `fingerprint` value.
  String get fingerprint => rawJson['fingerprint'] as String;

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ProgramItemParam',
    rawJson,
    'LiveInputProgramItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputProgramItemParam copyWith({
    Object? callId = liveUnset,
    Object? code = liveUnset,
    Object? fingerprint = liveUnset,
    Object? id = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputProgramItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'call_id': callId, 'code': code, 'fingerprint': fingerprint, 'id': id},
      <String>{},
      'LiveInputProgramItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputProgramItemParam(call_id: [REDACTED], code: [REDACTED], fingerprint: [REDACTED], id: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ProgramOutputItemParam.
@immutable
final class LiveInputProgramOutputItemParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputProgramOutputItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputProgramOutputItemParam'),
        'LiveInputProgramOutputItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'call_id',
    'id',
    'result',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `call_id` value.
  String get callId => rawJson['call_id'] as String;

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `result` value.
  String get result => rawJson['result'] as String;

  /// Canonical `status` value.
  LiveInputProgramOutputItemStatus get status =>
      LiveInputProgramOutputItemStatus.fromJson(rawJson['status']);

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ProgramOutputItemParam',
    rawJson,
    'LiveInputProgramOutputItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputProgramOutputItemParam copyWith({
    Object? callId = liveUnset,
    Object? id = liveUnset,
    Object? result = liveUnset,
    Object? status = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputProgramOutputItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'call_id': callId, 'id': id, 'result': result, 'status': status},
      <String>{},
      'LiveInputProgramOutputItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputProgramOutputItemParam(call_id: [REDACTED], id: [REDACTED], result: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ProgramToolCallCaller.
@immutable
final class LiveInputProgramToolCallCaller extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputProgramToolCallCaller.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputProgramToolCallCaller'),
        'LiveInputProgramToolCallCaller',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'caller_id', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `caller_id` value.
  String get callerId => rawJson['caller_id'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ProgramToolCallCaller',
    rawJson,
    'LiveInputProgramToolCallCaller',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputProgramToolCallCaller copyWith({
    Object? callerId = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputProgramToolCallCaller.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'caller_id': callerId},
      <String>{},
      'LiveInputProgramToolCallCaller',
    ),
  );
  @override
  String toString() =>
      'LiveInputProgramToolCallCaller(caller_id: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ProgramToolCallCallerParam.
@immutable
final class LiveInputProgramToolCallCallerParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputProgramToolCallCallerParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputProgramToolCallCallerParam'),
        'LiveInputProgramToolCallCallerParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'caller_id', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `caller_id` value.
  String get callerId => rawJson['caller_id'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ProgramToolCallCallerParam',
    rawJson,
    'LiveInputProgramToolCallCallerParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputProgramToolCallCallerParam copyWith({
    Object? callerId = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputProgramToolCallCallerParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'caller_id': callerId},
      <String>{},
      'LiveInputProgramToolCallCallerParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputProgramToolCallCallerParam(caller_id: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ProgrammaticToolCallingParam.
@immutable
final class LiveInputProgrammaticToolCallingParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputProgrammaticToolCallingParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputProgrammaticToolCallingParam'),
        'LiveInputProgrammaticToolCallingParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ProgrammaticToolCallingParam',
    rawJson,
    'LiveInputProgrammaticToolCallingParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputProgrammaticToolCallingParam copyWith({
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputProgrammaticToolCallingParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {},
      <String>{},
      'LiveInputProgrammaticToolCallingParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputProgrammaticToolCallingParam(type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for PromptCacheBreakpointConfig.
@immutable
final class LiveInputPromptCacheBreakpointConfig extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputPromptCacheBreakpointConfig.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputPromptCacheBreakpointConfig'),
        'LiveInputPromptCacheBreakpointConfig',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'mode'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `mode` value.
  String get mode => rawJson['mode'] as String;
  @override
  void validate() => _validateInputComponent(
    'PromptCacheBreakpointConfig',
    rawJson,
    'LiveInputPromptCacheBreakpointConfig',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputPromptCacheBreakpointConfig copyWith({
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputPromptCacheBreakpointConfig.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {},
      <String>{},
      'LiveInputPromptCacheBreakpointConfig',
    ),
  );
  @override
  String toString() =>
      'LiveInputPromptCacheBreakpointConfig(mode: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for PromptCacheBreakpointParam.
@immutable
final class LiveInputPromptCacheBreakpointParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputPromptCacheBreakpointParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputPromptCacheBreakpointParam'),
        'LiveInputPromptCacheBreakpointParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'mode'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `mode` value.
  String get mode => rawJson['mode'] as String;
  @override
  void validate() => _validateInputComponent(
    'PromptCacheBreakpointParam',
    rawJson,
    'LiveInputPromptCacheBreakpointParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputPromptCacheBreakpointParam copyWith({
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputPromptCacheBreakpointParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {},
      <String>{},
      'LiveInputPromptCacheBreakpointParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputPromptCacheBreakpointParam(mode: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for RankingOptions.
@immutable
final class LiveInputRankingOptions extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputRankingOptions.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputRankingOptions'),
        'LiveInputRankingOptions',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'hybrid_search',
    'ranker',
    'score_threshold',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `hybrid_search` value.
  LiveInputHybridSearchOptions? get hybridSearch =>
      rawJson['hybrid_search'] == null
      ? null
      : LiveInputHybridSearchOptions.fromJson(rawJson['hybrid_search']);

  /// Distinguishes absent `hybrid_search` from an explicit null.
  bool get hasHybridSearch => rawJson.containsKey('hybrid_search');

  /// Canonical `ranker` value.
  LiveInputRankerVersionType? get ranker => rawJson['ranker'] == null
      ? null
      : LiveInputRankerVersionType.fromJson(rawJson['ranker']);

  /// Distinguishes absent `ranker` from an explicit null.
  bool get hasRanker => rawJson.containsKey('ranker');

  /// Canonical `score_threshold` value.
  num? get scoreThreshold => rawJson['score_threshold'] == null
      ? null
      : (rawJson['score_threshold'] as num);

  /// Distinguishes absent `score_threshold` from an explicit null.
  bool get hasScoreThreshold => rawJson.containsKey('score_threshold');
  @override
  void validate() => _validateInputComponent(
    'RankingOptions',
    rawJson,
    'LiveInputRankingOptions',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputRankingOptions copyWith({
    Object? hybridSearch = liveUnset,
    bool clearHybridSearch = false,
    Object? ranker = liveUnset,
    bool clearRanker = false,
    Object? scoreThreshold = liveUnset,
    bool clearScoreThreshold = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputRankingOptions.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'hybrid_search': hybridSearch,
        'ranker': ranker,
        'score_threshold': scoreThreshold,
      },
      <String>{
        if (clearHybridSearch) 'hybrid_search',
        if (clearRanker) 'ranker',
        if (clearScoreThreshold) 'score_threshold',
      },
      'LiveInputRankingOptions',
    ),
  );
  @override
  String toString() =>
      'LiveInputRankingOptions(hybrid_search: [REDACTED], ranker: [REDACTED], score_threshold: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ReasoningItem.
@immutable
final class LiveInputReasoningItem extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputReasoningItem.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputReasoningItem'),
        'LiveInputReasoningItem',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'content',
    'encrypted_content',
    'id',
    'status',
    'summary',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `content` value.
  List<LiveInputReasoningTextContent>? get content => rawJson['content'] == null
      ? null
      : List.unmodifiable(
          (rawJson['content'] as List).map(
            LiveInputReasoningTextContent.fromJson,
          ),
        );

  /// Distinguishes absent `content` from an explicit null.
  bool get hasContent => rawJson.containsKey('content');

  /// Canonical `encrypted_content` value.
  String? get encryptedContent => rawJson['encrypted_content'] == null
      ? null
      : (rawJson['encrypted_content'] as String);

  /// Distinguishes absent `encrypted_content` from an explicit null.
  bool get hasEncryptedContent => rawJson.containsKey('encrypted_content');

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `status` value.
  String? get status =>
      rawJson['status'] == null ? null : (rawJson['status'] as String);

  /// Distinguishes absent `status` from an explicit null.
  bool get hasStatus => rawJson.containsKey('status');

  /// Canonical `summary` value.
  List<LiveInputSummaryTextContent> get summary => List.unmodifiable(
    (rawJson['summary'] as List).map(LiveInputSummaryTextContent.fromJson),
  );

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ReasoningItem',
    rawJson,
    'LiveInputReasoningItem',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputReasoningItem copyWith({
    Object? content = liveUnset,
    bool clearContent = false,
    Object? encryptedContent = liveUnset,
    bool clearEncryptedContent = false,
    Object? id = liveUnset,
    Object? status = liveUnset,
    bool clearStatus = false,
    Object? summary = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputReasoningItem.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'content': content,
        'encrypted_content': encryptedContent,
        'id': id,
        'status': status,
        'summary': summary,
      },
      <String>{
        if (clearContent) 'content',
        if (clearEncryptedContent) 'encrypted_content',
        if (clearStatus) 'status',
      },
      'LiveInputReasoningItem',
    ),
  );
  @override
  String toString() =>
      'LiveInputReasoningItem(content: [REDACTED], encrypted_content: [REDACTED], id: [REDACTED], status: [REDACTED], summary: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ReasoningTextContent.
@immutable
final class LiveInputReasoningTextContent extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputReasoningTextContent.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputReasoningTextContent'),
        'LiveInputReasoningTextContent',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'text', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `text` value.
  String get text => rawJson['text'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ReasoningTextContent',
    rawJson,
    'LiveInputReasoningTextContent',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputReasoningTextContent copyWith({
    Object? text = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputReasoningTextContent.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'text': text},
      <String>{},
      'LiveInputReasoningTextContent',
    ),
  );
  @override
  String toString() =>
      'LiveInputReasoningTextContent(text: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for RefusalContent.
@immutable
final class LiveInputRefusalContent extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputRefusalContent.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputRefusalContent'),
        'LiveInputRefusalContent',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'refusal', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `refusal` value.
  String get refusal => rawJson['refusal'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'RefusalContent',
    rawJson,
    'LiveInputRefusalContent',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputRefusalContent copyWith({
    Object? refusal = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputRefusalContent.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'refusal': refusal},
      <String>{},
      'LiveInputRefusalContent',
    ),
  );
  @override
  String toString() =>
      'LiveInputRefusalContent(refusal: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ResponseConfigurationUpdateItemParam.
@immutable
final class LiveInputResponseConfigurationUpdateItemParam
    extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputResponseConfigurationUpdateItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(
          json,
          'LiveInputResponseConfigurationUpdateItemParam',
        ),
        'LiveInputResponseConfigurationUpdateItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'id', 'reasoning', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `reasoning` value.
  LiveInputResponseConfigurationUpdateItemParamReasoningValue? get reasoning =>
      rawJson['reasoning'] == null
      ? null
      : LiveInputResponseConfigurationUpdateItemParamReasoningValue.fromJson(
          rawJson['reasoning'],
        );

  /// Distinguishes absent `reasoning` from an explicit null.
  bool get hasReasoning => rawJson.containsKey('reasoning');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ResponseConfigurationUpdateItemParam',
    rawJson,
    'LiveInputResponseConfigurationUpdateItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputResponseConfigurationUpdateItemParam copyWith({
    Object? id = liveUnset,
    bool clearId = false,
    Object? reasoning = liveUnset,
    bool clearReasoning = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputResponseConfigurationUpdateItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'id': id, 'reasoning': reasoning},
      <String>{if (clearId) 'id', if (clearReasoning) 'reasoning'},
      'LiveInputResponseConfigurationUpdateItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputResponseConfigurationUpdateItemParam(id: [REDACTED], reasoning: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for the canonical inline payload.
@immutable
final class LiveInputResponseConfigurationUpdateItemParamReasoningValue
    extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputResponseConfigurationUpdateItemParamReasoningValue.fromJson(
    Object? json,
  ) : rawJson = snapshotLiveJson(
        requireLiveObject(
          json,
          'LiveInputResponseConfigurationUpdateItemParamReasoningValue',
        ),
        'LiveInputResponseConfigurationUpdateItemParamReasoningValue',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'effort'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `effort` value.
  LiveInputReasoningEffort? get effort => rawJson['effort'] == null
      ? null
      : LiveInputReasoningEffort.fromJson(rawJson['effort']);

  /// Distinguishes absent `effort` from an explicit null.
  bool get hasEffort => rawJson.containsKey('effort');
  @override
  void validate() => _validateInputSchema(
    {
      'properties': {
        'effort': {r'$ref': '#/components/schemas/ReasoningEffort'},
      },
      'type': 'object',
    },
    rawJson,
    'LiveInputResponseConfigurationUpdateItemParamReasoningValue',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputResponseConfigurationUpdateItemParamReasoningValue copyWith({
    Object? effort = liveUnset,
    bool clearEffort = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputResponseConfigurationUpdateItemParamReasoningValue.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'effort': effort},
      <String>{if (clearEffort) 'effort'},
      'LiveInputResponseConfigurationUpdateItemParamReasoningValue',
    ),
  );
  @override
  String toString() =>
      'LiveInputResponseConfigurationUpdateItemParamReasoningValue(effort: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ScreenshotParam.
@immutable
final class LiveInputScreenshotParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputScreenshotParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputScreenshotParam'),
        'LiveInputScreenshotParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ScreenshotParam',
    rawJson,
    'LiveInputScreenshotParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputScreenshotParam copyWith({
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputScreenshotParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {},
      <String>{},
      'LiveInputScreenshotParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputScreenshotParam(type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ScrollParam.
@immutable
final class LiveInputScrollParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputScrollParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputScrollParam'),
        'LiveInputScrollParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'keys',
    'scroll_x',
    'scroll_y',
    'type',
    'x',
    'y',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `keys` value.
  List<String>? get keys => rawJson['keys'] == null
      ? null
      : List.unmodifiable(
          (rawJson['keys'] as List).map((value) => value as String),
        );

  /// Distinguishes absent `keys` from an explicit null.
  bool get hasKeys => rawJson.containsKey('keys');

  /// Canonical `scroll_x` value.
  int get scrollX => rawJson['scroll_x'] as int;

  /// Canonical `scroll_y` value.
  int get scrollY => rawJson['scroll_y'] as int;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `x` value.
  int get x => rawJson['x'] as int;

  /// Canonical `y` value.
  int get y => rawJson['y'] as int;
  @override
  void validate() =>
      _validateInputComponent('ScrollParam', rawJson, 'LiveInputScrollParam');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputScrollParam copyWith({
    Object? keys = liveUnset,
    bool clearKeys = false,
    Object? scrollX = liveUnset,
    Object? scrollY = liveUnset,
    Object? x = liveUnset,
    Object? y = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputScrollParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'keys': keys, 'scroll_x': scrollX, 'scroll_y': scrollY, 'x': x, 'y': y},
      <String>{if (clearKeys) 'keys'},
      'LiveInputScrollParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputScrollParam(keys: [REDACTED], scroll_x: [REDACTED], scroll_y: [REDACTED], type: [REDACTED], x: [REDACTED], y: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for SkillReferenceParam.
@immutable
final class LiveInputSkillReferenceParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputSkillReferenceParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputSkillReferenceParam'),
        'LiveInputSkillReferenceParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'skill_id', 'type', 'version'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `skill_id` value.
  String get skillId => rawJson['skill_id'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `version` value.
  String? get version =>
      rawJson['version'] == null ? null : (rawJson['version'] as String);

  /// Distinguishes absent `version` from an explicit null.
  bool get hasVersion => rawJson.containsKey('version');
  @override
  void validate() => _validateInputComponent(
    'SkillReferenceParam',
    rawJson,
    'LiveInputSkillReferenceParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputSkillReferenceParam copyWith({
    Object? skillId = liveUnset,
    Object? version = liveUnset,
    bool clearVersion = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputSkillReferenceParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'skill_id': skillId, 'version': version},
      <String>{if (clearVersion) 'version'},
      'LiveInputSkillReferenceParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputSkillReferenceParam(skill_id: [REDACTED], type: [REDACTED], version: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for SummaryTextContent.
@immutable
final class LiveInputSummaryTextContent extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputSummaryTextContent.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputSummaryTextContent'),
        'LiveInputSummaryTextContent',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'text', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `text` value.
  String get text => rawJson['text'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'SummaryTextContent',
    rawJson,
    'LiveInputSummaryTextContent',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputSummaryTextContent copyWith({
    Object? text = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputSummaryTextContent.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'text': text},
      <String>{},
      'LiveInputSummaryTextContent',
    ),
  );
  @override
  String toString() =>
      'LiveInputSummaryTextContent(text: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for InputTextContent.
@immutable
final class LiveInputTextContent extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputTextContent.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputTextContent'),
        'LiveInputTextContent',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'prompt_cache_breakpoint',
    'text',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `prompt_cache_breakpoint` value.
  LiveInputPromptCacheBreakpointConfig? get promptCacheBreakpoint =>
      rawJson['prompt_cache_breakpoint'] == null
      ? null
      : LiveInputPromptCacheBreakpointConfig.fromJson(
          rawJson['prompt_cache_breakpoint'],
        );

  /// Distinguishes absent `prompt_cache_breakpoint` from an explicit null.
  bool get hasPromptCacheBreakpoint =>
      rawJson.containsKey('prompt_cache_breakpoint');

  /// Canonical `text` value.
  String get text => rawJson['text'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'InputTextContent',
    rawJson,
    'LiveInputTextContent',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputTextContent copyWith({
    Object? promptCacheBreakpoint = liveUnset,
    bool clearPromptCacheBreakpoint = false,
    Object? text = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputTextContent.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'prompt_cache_breakpoint': promptCacheBreakpoint, 'text': text},
      <String>{if (clearPromptCacheBreakpoint) 'prompt_cache_breakpoint'},
      'LiveInputTextContent',
    ),
  );
  @override
  String toString() =>
      'LiveInputTextContent(prompt_cache_breakpoint: [REDACTED], text: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for InputTextContentParam.
@immutable
final class LiveInputTextContentParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputTextContentParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputTextContentParam'),
        'LiveInputTextContentParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'prompt_cache_breakpoint',
    'text',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `prompt_cache_breakpoint` value.
  LiveInputPromptCacheBreakpointParam? get promptCacheBreakpoint =>
      rawJson['prompt_cache_breakpoint'] == null
      ? null
      : LiveInputPromptCacheBreakpointParam.fromJson(
          rawJson['prompt_cache_breakpoint'],
        );

  /// Distinguishes absent `prompt_cache_breakpoint` from an explicit null.
  bool get hasPromptCacheBreakpoint =>
      rawJson.containsKey('prompt_cache_breakpoint');

  /// Canonical `text` value.
  String get text => rawJson['text'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'InputTextContentParam',
    rawJson,
    'LiveInputTextContentParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputTextContentParam copyWith({
    Object? promptCacheBreakpoint = liveUnset,
    bool clearPromptCacheBreakpoint = false,
    Object? text = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputTextContentParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'prompt_cache_breakpoint': promptCacheBreakpoint, 'text': text},
      <String>{if (clearPromptCacheBreakpoint) 'prompt_cache_breakpoint'},
      'LiveInputTextContentParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputTextContentParam(prompt_cache_breakpoint: [REDACTED], text: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ToolSearchCallItemParam.
@immutable
final class LiveInputToolSearchCallItemParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputToolSearchCallItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputToolSearchCallItemParam'),
        'LiveInputToolSearchCallItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'arguments',
    'call_id',
    'execution',
    'id',
    'status',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `arguments` value.
  LiveInputEmptyModelParam get arguments =>
      LiveInputEmptyModelParam.fromJson(rawJson['arguments']);

  /// Canonical `call_id` value.
  String? get callId =>
      rawJson['call_id'] == null ? null : (rawJson['call_id'] as String);

  /// Distinguishes absent `call_id` from an explicit null.
  bool get hasCallId => rawJson.containsKey('call_id');

  /// Canonical `execution` value.
  LiveInputToolSearchExecutionType? get execution =>
      rawJson['execution'] == null
      ? null
      : LiveInputToolSearchExecutionType.fromJson(rawJson['execution']);

  /// Distinguishes absent `execution` from an explicit null.
  bool get hasExecution => rawJson.containsKey('execution');

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `status` value.
  LiveInputFunctionCallItemStatus? get status => rawJson['status'] == null
      ? null
      : LiveInputFunctionCallItemStatus.fromJson(rawJson['status']);

  /// Distinguishes absent `status` from an explicit null.
  bool get hasStatus => rawJson.containsKey('status');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ToolSearchCallItemParam',
    rawJson,
    'LiveInputToolSearchCallItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputToolSearchCallItemParam copyWith({
    Object? arguments = liveUnset,
    Object? callId = liveUnset,
    bool clearCallId = false,
    Object? execution = liveUnset,
    bool clearExecution = false,
    Object? id = liveUnset,
    bool clearId = false,
    Object? status = liveUnset,
    bool clearStatus = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputToolSearchCallItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'arguments': arguments,
        'call_id': callId,
        'execution': execution,
        'id': id,
        'status': status,
      },
      <String>{
        if (clearCallId) 'call_id',
        if (clearExecution) 'execution',
        if (clearId) 'id',
        if (clearStatus) 'status',
      },
      'LiveInputToolSearchCallItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputToolSearchCallItemParam(arguments: [REDACTED], call_id: [REDACTED], execution: [REDACTED], id: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ToolSearchOutputFunctionToolParam.
@immutable
final class LiveInputToolSearchOutputFunctionToolParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputToolSearchOutputFunctionToolParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputToolSearchOutputFunctionToolParam'),
        'LiveInputToolSearchOutputFunctionToolParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'allowed_callers',
    'async',
    'defer_loading',
    'description',
    'name',
    'output_schema',
    'parameters',
    'strict',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `allowed_callers` value.
  List<LiveInputCallableToolAllowedCaller>? get allowedCallers =>
      rawJson['allowed_callers'] == null
      ? null
      : List.unmodifiable(
          (rawJson['allowed_callers'] as List).map(
            LiveInputCallableToolAllowedCaller.fromJson,
          ),
        );

  /// Distinguishes absent `allowed_callers` from an explicit null.
  bool get hasAllowedCallers => rawJson.containsKey('allowed_callers');

  /// Canonical `async` value.
  bool? get async =>
      rawJson['async'] == null ? null : (rawJson['async'] as bool);

  /// Distinguishes absent `async` from an explicit null.
  bool get hasAsync => rawJson.containsKey('async');

  /// Canonical `defer_loading` value.
  bool? get deferLoading => rawJson['defer_loading'] == null
      ? null
      : (rawJson['defer_loading'] as bool);

  /// Distinguishes absent `defer_loading` from an explicit null.
  bool get hasDeferLoading => rawJson.containsKey('defer_loading');

  /// Canonical `description` value.
  String? get description => rawJson['description'] == null
      ? null
      : (rawJson['description'] as String);

  /// Distinguishes absent `description` from an explicit null.
  bool get hasDescription => rawJson.containsKey('description');

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;

  /// Canonical `output_schema` value.
  Map<String, dynamic>? get outputSchema => rawJson['output_schema'] == null
      ? null
      : Map<String, dynamic>.unmodifiable(
          requireLiveObject(
            rawJson['output_schema'],
            'LiveInputToolSearchOutputFunctionToolParam.output_schema',
          ),
        );

  /// Distinguishes absent `output_schema` from an explicit null.
  bool get hasOutputSchema => rawJson.containsKey('output_schema');

  /// Canonical `parameters` value.
  LiveInputEmptyModelParam? get parameters => rawJson['parameters'] == null
      ? null
      : LiveInputEmptyModelParam.fromJson(rawJson['parameters']);

  /// Distinguishes absent `parameters` from an explicit null.
  bool get hasParameters => rawJson.containsKey('parameters');

  /// Canonical `strict` value.
  bool? get strict =>
      rawJson['strict'] == null ? null : (rawJson['strict'] as bool);

  /// Distinguishes absent `strict` from an explicit null.
  bool get hasStrict => rawJson.containsKey('strict');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ToolSearchOutputFunctionToolParam',
    rawJson,
    'LiveInputToolSearchOutputFunctionToolParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputToolSearchOutputFunctionToolParam copyWith({
    Object? allowedCallers = liveUnset,
    bool clearAllowedCallers = false,
    Object? async = liveUnset,
    bool clearAsync = false,
    Object? deferLoading = liveUnset,
    bool clearDeferLoading = false,
    Object? description = liveUnset,
    bool clearDescription = false,
    Object? name = liveUnset,
    Object? outputSchema = liveUnset,
    bool clearOutputSchema = false,
    Object? parameters = liveUnset,
    bool clearParameters = false,
    Object? strict = liveUnset,
    bool clearStrict = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputToolSearchOutputFunctionToolParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'allowed_callers': allowedCallers,
        'async': async,
        'defer_loading': deferLoading,
        'description': description,
        'name': name,
        'output_schema': outputSchema,
        'parameters': parameters,
        'strict': strict,
      },
      <String>{
        if (clearAllowedCallers) 'allowed_callers',
        if (clearAsync) 'async',
        if (clearDeferLoading) 'defer_loading',
        if (clearDescription) 'description',
        if (clearOutputSchema) 'output_schema',
        if (clearParameters) 'parameters',
        if (clearStrict) 'strict',
      },
      'LiveInputToolSearchOutputFunctionToolParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputToolSearchOutputFunctionToolParam(allowed_callers: [REDACTED], async: [REDACTED], defer_loading: [REDACTED], description: [REDACTED], name: [REDACTED], output_schema: [REDACTED], parameters: [REDACTED], strict: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ToolSearchOutputItemParam.
@immutable
final class LiveInputToolSearchOutputItemParam extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputToolSearchOutputItemParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputToolSearchOutputItemParam'),
        'LiveInputToolSearchOutputItemParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'call_id',
    'execution',
    'id',
    'status',
    'tools',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `call_id` value.
  String? get callId =>
      rawJson['call_id'] == null ? null : (rawJson['call_id'] as String);

  /// Distinguishes absent `call_id` from an explicit null.
  bool get hasCallId => rawJson.containsKey('call_id');

  /// Canonical `execution` value.
  LiveInputToolSearchExecutionType? get execution =>
      rawJson['execution'] == null
      ? null
      : LiveInputToolSearchExecutionType.fromJson(rawJson['execution']);

  /// Distinguishes absent `execution` from an explicit null.
  bool get hasExecution => rawJson.containsKey('execution');

  /// Canonical `id` value.
  String? get id => rawJson['id'] == null ? null : (rawJson['id'] as String);

  /// Distinguishes absent `id` from an explicit null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical `status` value.
  LiveInputFunctionCallItemStatus? get status => rawJson['status'] == null
      ? null
      : LiveInputFunctionCallItemStatus.fromJson(rawJson['status']);

  /// Distinguishes absent `status` from an explicit null.
  bool get hasStatus => rawJson.containsKey('status');

  /// Canonical `tools` value.
  List<LiveInputToolSearchOutputTool> get tools => List.unmodifiable(
    (rawJson['tools'] as List).map(LiveInputToolSearchOutputTool.fromJson),
  );

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ToolSearchOutputItemParam',
    rawJson,
    'LiveInputToolSearchOutputItemParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputToolSearchOutputItemParam copyWith({
    Object? callId = liveUnset,
    bool clearCallId = false,
    Object? execution = liveUnset,
    bool clearExecution = false,
    Object? id = liveUnset,
    bool clearId = false,
    Object? status = liveUnset,
    bool clearStatus = false,
    Object? tools = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputToolSearchOutputItemParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'call_id': callId,
        'execution': execution,
        'id': id,
        'status': status,
        'tools': tools,
      },
      <String>{
        if (clearCallId) 'call_id',
        if (clearExecution) 'execution',
        if (clearId) 'id',
        if (clearStatus) 'status',
      },
      'LiveInputToolSearchOutputItemParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputToolSearchOutputItemParam(call_id: [REDACTED], execution: [REDACTED], id: [REDACTED], status: [REDACTED], tools: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ToolSearchOutputNamespaceToolParam.
@immutable
final class LiveInputToolSearchOutputNamespaceToolParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputToolSearchOutputNamespaceToolParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputToolSearchOutputNamespaceToolParam'),
        'LiveInputToolSearchOutputNamespaceToolParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'description',
    'name',
    'tools',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `description` value.
  String get description => rawJson['description'] as String;

  /// Canonical `name` value.
  String get name => rawJson['name'] as String;

  /// Canonical `tools` value.
  List<LiveInputToolSearchOutputNamespaceToolParamToolsItemValue> get tools =>
      List.unmodifiable(
        (rawJson['tools'] as List).map(
          LiveInputToolSearchOutputNamespaceToolParamToolsItemValue.fromJson,
        ),
      );

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ToolSearchOutputNamespaceToolParam',
    rawJson,
    'LiveInputToolSearchOutputNamespaceToolParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputToolSearchOutputNamespaceToolParam copyWith({
    Object? description = liveUnset,
    Object? name = liveUnset,
    Object? tools = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputToolSearchOutputNamespaceToolParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'description': description, 'name': name, 'tools': tools},
      <String>{},
      'LiveInputToolSearchOutputNamespaceToolParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputToolSearchOutputNamespaceToolParam(description: [REDACTED], name: [REDACTED], tools: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for ToolSearchToolParam.
@immutable
final class LiveInputToolSearchToolParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputToolSearchToolParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputToolSearchToolParam'),
        'LiveInputToolSearchToolParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'description',
    'execution',
    'parameters',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `description` value.
  String? get description => rawJson['description'] == null
      ? null
      : (rawJson['description'] as String);

  /// Distinguishes absent `description` from an explicit null.
  bool get hasDescription => rawJson.containsKey('description');

  /// Canonical `execution` value.
  LiveInputToolSearchExecutionType? get execution =>
      rawJson['execution'] == null
      ? null
      : LiveInputToolSearchExecutionType.fromJson(rawJson['execution']);

  /// Distinguishes absent `execution` from an explicit null.
  bool get hasExecution => rawJson.containsKey('execution');

  /// Canonical `parameters` value.
  LiveInputEmptyModelParam? get parameters => rawJson['parameters'] == null
      ? null
      : LiveInputEmptyModelParam.fromJson(rawJson['parameters']);

  /// Distinguishes absent `parameters` from an explicit null.
  bool get hasParameters => rawJson.containsKey('parameters');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'ToolSearchToolParam',
    rawJson,
    'LiveInputToolSearchToolParam',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputToolSearchToolParam copyWith({
    Object? description = liveUnset,
    bool clearDescription = false,
    Object? execution = liveUnset,
    bool clearExecution = false,
    Object? parameters = liveUnset,
    bool clearParameters = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputToolSearchToolParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'description': description,
        'execution': execution,
        'parameters': parameters,
      },
      <String>{
        if (clearDescription) 'description',
        if (clearExecution) 'execution',
        if (clearParameters) 'parameters',
      },
      'LiveInputToolSearchToolParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputToolSearchToolParam(description: [REDACTED], execution: [REDACTED], parameters: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for TopLogProb.
@immutable
final class LiveInputTopLogProb extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputTopLogProb.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputTopLogProb'),
        'LiveInputTopLogProb',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'bytes', 'logprob', 'token'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `bytes` value.
  List<int> get bytes => List.unmodifiable(
    (rawJson['bytes'] as List).map((value) => value as int),
  );

  /// Canonical `logprob` value.
  num get logprob => rawJson['logprob'] as num;

  /// Canonical `token` value.
  String get token => rawJson['token'] as String;
  @override
  void validate() =>
      _validateInputComponent('TopLogProb', rawJson, 'LiveInputTopLogProb');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputTopLogProb copyWith({
    Object? bytes = liveUnset,
    Object? logprob = liveUnset,
    Object? token = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputTopLogProb.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'bytes': bytes, 'logprob': logprob, 'token': token},
      <String>{},
      'LiveInputTopLogProb',
    ),
  );
  @override
  String toString() =>
      'LiveInputTopLogProb(bytes: [REDACTED], logprob: [REDACTED], token: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for TypeParam.
@immutable
final class LiveInputTypeParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputTypeParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputTypeParam'),
        'LiveInputTypeParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'text', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `text` value.
  String get text => rawJson['text'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() =>
      _validateInputComponent('TypeParam', rawJson, 'LiveInputTypeParam');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputTypeParam copyWith({
    Object? text = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputTypeParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'text': text},
      <String>{},
      'LiveInputTypeParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputTypeParam(text: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for UrlCitationBody.
@immutable
final class LiveInputUrlCitationBody extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputUrlCitationBody.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputUrlCitationBody'),
        'LiveInputUrlCitationBody',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'end_index',
    'start_index',
    'title',
    'type',
    'url',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `end_index` value.
  int get endIndex => rawJson['end_index'] as int;

  /// Canonical `start_index` value.
  int get startIndex => rawJson['start_index'] as int;

  /// Canonical `title` value.
  String get title => rawJson['title'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `url` value.
  String get url => rawJson['url'] as String;
  @override
  void validate() => _validateInputComponent(
    'UrlCitationBody',
    rawJson,
    'LiveInputUrlCitationBody',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputUrlCitationBody copyWith({
    Object? endIndex = liveUnset,
    Object? startIndex = liveUnset,
    Object? title = liveUnset,
    Object? url = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputUrlCitationBody.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'end_index': endIndex,
        'start_index': startIndex,
        'title': title,
        'url': url,
      },
      <String>{},
      'LiveInputUrlCitationBody',
    ),
  );
  @override
  String toString() =>
      'LiveInputUrlCitationBody(end_index: [REDACTED], start_index: [REDACTED], title: [REDACTED], type: [REDACTED], url: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for WaitParam.
@immutable
final class LiveInputWaitParam extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputWaitParam.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputWaitParam'),
        'LiveInputWaitParam',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() =>
      _validateInputComponent('WaitParam', rawJson, 'LiveInputWaitParam');
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputWaitParam copyWith({
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputWaitParam.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {},
      <String>{},
      'LiveInputWaitParam',
    ),
  );
  @override
  String toString() =>
      'LiveInputWaitParam(type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for WebSearchActionFind.
@immutable
final class LiveInputWebSearchActionFind extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputWebSearchActionFind.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputWebSearchActionFind'),
        'LiveInputWebSearchActionFind',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'pattern', 'type', 'url'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `pattern` value.
  String get pattern => rawJson['pattern'] as String;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `url` value.
  String get url => rawJson['url'] as String;
  @override
  void validate() => _validateInputComponent(
    'WebSearchActionFind',
    rawJson,
    'LiveInputWebSearchActionFind',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputWebSearchActionFind copyWith({
    Object? pattern = liveUnset,
    Object? url = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputWebSearchActionFind.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'pattern': pattern, 'url': url},
      <String>{},
      'LiveInputWebSearchActionFind',
    ),
  );
  @override
  String toString() =>
      'LiveInputWebSearchActionFind(pattern: [REDACTED], type: [REDACTED], url: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for WebSearchActionOpenPage.
@immutable
final class LiveInputWebSearchActionOpenPage extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputWebSearchActionOpenPage.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputWebSearchActionOpenPage'),
        'LiveInputWebSearchActionOpenPage',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'type', 'url'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `url` value.
  String? get url => rawJson['url'] == null ? null : (rawJson['url'] as String);

  /// Distinguishes absent `url` from an explicit null.
  bool get hasUrl => rawJson.containsKey('url');
  @override
  void validate() => _validateInputComponent(
    'WebSearchActionOpenPage',
    rawJson,
    'LiveInputWebSearchActionOpenPage',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputWebSearchActionOpenPage copyWith({
    Object? url = liveUnset,
    bool clearUrl = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputWebSearchActionOpenPage.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'url': url},
      <String>{if (clearUrl) 'url'},
      'LiveInputWebSearchActionOpenPage',
    ),
  );
  @override
  String toString() =>
      'LiveInputWebSearchActionOpenPage(type: [REDACTED], url: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for WebSearchActionSearch.
@immutable
final class LiveInputWebSearchActionSearch extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputWebSearchActionSearch.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputWebSearchActionSearch'),
        'LiveInputWebSearchActionSearch',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'queries', 'query', 'sources', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `queries` value.
  List<String>? get queries => rawJson['queries'] == null
      ? null
      : List.unmodifiable(
          (rawJson['queries'] as List).map((value) => value as String),
        );

  /// Distinguishes absent `queries` from an explicit null.
  bool get hasQueries => rawJson.containsKey('queries');

  /// Canonical `query` value.
  String? get query =>
      rawJson['query'] == null ? null : (rawJson['query'] as String);

  /// Distinguishes absent `query` from an explicit null.
  bool get hasQuery => rawJson.containsKey('query');

  /// Canonical `sources` value.
  List<LiveInputWebSearchActionSearchSourcesItemValue>? get sources =>
      rawJson['sources'] == null
      ? null
      : List.unmodifiable(
          (rawJson['sources'] as List).map(
            LiveInputWebSearchActionSearchSourcesItemValue.fromJson,
          ),
        );

  /// Distinguishes absent `sources` from an explicit null.
  bool get hasSources => rawJson.containsKey('sources');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'WebSearchActionSearch',
    rawJson,
    'LiveInputWebSearchActionSearch',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputWebSearchActionSearch copyWith({
    Object? queries = liveUnset,
    bool clearQueries = false,
    Object? query = liveUnset,
    bool clearQuery = false,
    Object? sources = liveUnset,
    bool clearSources = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputWebSearchActionSearch.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'queries': queries, 'query': query, 'sources': sources},
      <String>{
        if (clearQueries) 'queries',
        if (clearQuery) 'query',
        if (clearSources) 'sources',
      },
      'LiveInputWebSearchActionSearch',
    ),
  );
  @override
  String toString() =>
      'LiveInputWebSearchActionSearch(queries: [REDACTED], query: [REDACTED], sources: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for the canonical inline payload.
@immutable
final class LiveInputWebSearchActionSearchSourcesItemValue
    extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputWebSearchActionSearchSourcesItemValue.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(
          json,
          'LiveInputWebSearchActionSearchSourcesItemValue',
        ),
        'LiveInputWebSearchActionSearchSourcesItemValue',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'type', 'url'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `url` value.
  String get url => rawJson['url'] as String;
  @override
  void validate() => _validateInputSchema(
    {
      'properties': {
        'type': {
          'enum': ['url'],
          'type': 'string',
        },
        'url': {'format': 'uri', 'type': 'string'},
      },
      'required': ['type', 'url'],
      'type': 'object',
    },
    rawJson,
    'LiveInputWebSearchActionSearchSourcesItemValue',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputWebSearchActionSearchSourcesItemValue copyWith({
    Object? url = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputWebSearchActionSearchSourcesItemValue.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'url': url},
      <String>{},
      'LiveInputWebSearchActionSearchSourcesItemValue',
    ),
  );
  @override
  String toString() =>
      'LiveInputWebSearchActionSearchSourcesItemValue(type: [REDACTED], url: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for the canonical inline payload.
@immutable
final class LiveInputWebSearchApproximateLocationBranch0Value
    extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputWebSearchApproximateLocationBranch0Value.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(
          json,
          'LiveInputWebSearchApproximateLocationBranch0Value',
        ),
        'LiveInputWebSearchApproximateLocationBranch0Value',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'city',
    'country',
    'region',
    'timezone',
    'type',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `city` value.
  String? get city =>
      rawJson['city'] == null ? null : (rawJson['city'] as String);

  /// Distinguishes absent `city` from an explicit null.
  bool get hasCity => rawJson.containsKey('city');

  /// Canonical `country` value.
  String? get country =>
      rawJson['country'] == null ? null : (rawJson['country'] as String);

  /// Distinguishes absent `country` from an explicit null.
  bool get hasCountry => rawJson.containsKey('country');

  /// Canonical `region` value.
  String? get region =>
      rawJson['region'] == null ? null : (rawJson['region'] as String);

  /// Distinguishes absent `region` from an explicit null.
  bool get hasRegion => rawJson.containsKey('region');

  /// Canonical `timezone` value.
  String? get timezone =>
      rawJson['timezone'] == null ? null : (rawJson['timezone'] as String);

  /// Distinguishes absent `timezone` from an explicit null.
  bool get hasTimezone => rawJson.containsKey('timezone');

  /// Canonical `type` value.
  String? get type =>
      rawJson['type'] == null ? null : (rawJson['type'] as String);

  /// Distinguishes absent `type` from an explicit null.
  bool get hasType => rawJson.containsKey('type');
  @override
  void validate() => _validateInputSchema(
    {
      'properties': {
        'city': {
          'anyOf': [
            {'type': 'string'},
            {'type': 'null'},
          ],
        },
        'country': {
          'anyOf': [
            {'type': 'string'},
            {'type': 'null'},
          ],
        },
        'region': {
          'anyOf': [
            {'type': 'string'},
            {'type': 'null'},
          ],
        },
        'timezone': {
          'anyOf': [
            {'type': 'string'},
            {'type': 'null'},
          ],
        },
        'type': {
          'enum': ['approximate'],
          'type': 'string',
        },
      },
      'type': 'object',
    },
    rawJson,
    'LiveInputWebSearchApproximateLocationBranch0Value',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputWebSearchApproximateLocationBranch0Value copyWith({
    Object? city = liveUnset,
    bool clearCity = false,
    Object? country = liveUnset,
    bool clearCountry = false,
    Object? region = liveUnset,
    bool clearRegion = false,
    Object? timezone = liveUnset,
    bool clearTimezone = false,
    Object? type = liveUnset,
    bool clearType = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputWebSearchApproximateLocationBranch0Value.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'city': city,
        'country': country,
        'region': region,
        'timezone': timezone,
        'type': type,
      },
      <String>{
        if (clearCity) 'city',
        if (clearCountry) 'country',
        if (clearRegion) 'region',
        if (clearTimezone) 'timezone',
        if (clearType) 'type',
      },
      'LiveInputWebSearchApproximateLocationBranch0Value',
    ),
  );
  @override
  String toString() =>
      'LiveInputWebSearchApproximateLocationBranch0Value(city: [REDACTED], country: [REDACTED], region: [REDACTED], timezone: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for WebSearchPreviewTool.
@immutable
final class LiveInputWebSearchPreviewTool extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputWebSearchPreviewTool.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputWebSearchPreviewTool'),
        'LiveInputWebSearchPreviewTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'search_content_types',
    'search_context_size',
    'type',
    'user_location',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `search_content_types` value.
  List<LiveInputSearchContentType>? get searchContentTypes =>
      rawJson['search_content_types'] == null
      ? null
      : List.unmodifiable(
          (rawJson['search_content_types'] as List).map(
            LiveInputSearchContentType.fromJson,
          ),
        );

  /// Distinguishes absent `search_content_types` from an explicit null.
  bool get hasSearchContentTypes => rawJson.containsKey('search_content_types');

  /// Canonical `search_context_size` value.
  LiveInputSearchContextSize? get searchContextSize =>
      rawJson['search_context_size'] == null
      ? null
      : LiveInputSearchContextSize.fromJson(rawJson['search_context_size']);

  /// Distinguishes absent `search_context_size` from an explicit null.
  bool get hasSearchContextSize => rawJson.containsKey('search_context_size');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `user_location` value.
  LiveInputApproximateLocation? get userLocation =>
      rawJson['user_location'] == null
      ? null
      : LiveInputApproximateLocation.fromJson(rawJson['user_location']);

  /// Distinguishes absent `user_location` from an explicit null.
  bool get hasUserLocation => rawJson.containsKey('user_location');
  @override
  void validate() => _validateInputComponent(
    'WebSearchPreviewTool',
    rawJson,
    'LiveInputWebSearchPreviewTool',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputWebSearchPreviewTool copyWith({
    Object? searchContentTypes = liveUnset,
    bool clearSearchContentTypes = false,
    Object? searchContextSize = liveUnset,
    bool clearSearchContextSize = false,
    Object? type = liveUnset,
    Object? userLocation = liveUnset,
    bool clearUserLocation = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputWebSearchPreviewTool.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'search_content_types': searchContentTypes,
        'search_context_size': searchContextSize,
        'type': type,
        'user_location': userLocation,
      },
      <String>{
        if (clearSearchContentTypes) 'search_content_types',
        if (clearSearchContextSize) 'search_context_size',
        if (clearUserLocation) 'user_location',
      },
      'LiveInputWebSearchPreviewTool',
    ),
  );
  @override
  String toString() =>
      'LiveInputWebSearchPreviewTool(search_content_types: [REDACTED], search_context_size: [REDACTED], type: [REDACTED], user_location: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for WebSearchTool.
@immutable
final class LiveInputWebSearchTool extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputWebSearchTool.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputWebSearchTool'),
        'LiveInputWebSearchTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {
    'external_web_access',
    'filters',
    'search_context_size',
    'type',
    'user_location',
  };

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `external_web_access` value.
  bool? get externalWebAccess => rawJson['external_web_access'] == null
      ? null
      : (rawJson['external_web_access'] as bool);

  /// Distinguishes absent `external_web_access` from an explicit null.
  bool get hasExternalWebAccess => rawJson.containsKey('external_web_access');

  /// Canonical `filters` value.
  LiveInputWebSearchToolFiltersValue? get filters => rawJson['filters'] == null
      ? null
      : LiveInputWebSearchToolFiltersValue.fromJson(rawJson['filters']);

  /// Distinguishes absent `filters` from an explicit null.
  bool get hasFilters => rawJson.containsKey('filters');

  /// Canonical `search_context_size` value.
  String? get searchContextSize => rawJson['search_context_size'] == null
      ? null
      : (rawJson['search_context_size'] as String);

  /// Distinguishes absent `search_context_size` from an explicit null.
  bool get hasSearchContextSize => rawJson.containsKey('search_context_size');

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;

  /// Canonical `user_location` value.
  LiveInputWebSearchApproximateLocation? get userLocation =>
      rawJson['user_location'] == null
      ? null
      : LiveInputWebSearchApproximateLocation.fromJson(
          rawJson['user_location'],
        );

  /// Distinguishes absent `user_location` from an explicit null.
  bool get hasUserLocation => rawJson.containsKey('user_location');
  @override
  void validate() => _validateInputComponent(
    'WebSearchTool',
    rawJson,
    'LiveInputWebSearchTool',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputWebSearchTool copyWith({
    Object? externalWebAccess = liveUnset,
    bool clearExternalWebAccess = false,
    Object? filters = liveUnset,
    bool clearFilters = false,
    Object? searchContextSize = liveUnset,
    bool clearSearchContextSize = false,
    Object? type = liveUnset,
    Object? userLocation = liveUnset,
    bool clearUserLocation = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputWebSearchTool.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {
        'external_web_access': externalWebAccess,
        'filters': filters,
        'search_context_size': searchContextSize,
        'type': type,
        'user_location': userLocation,
      },
      <String>{
        if (clearExternalWebAccess) 'external_web_access',
        if (clearFilters) 'filters',
        if (clearSearchContextSize) 'search_context_size',
        if (clearUserLocation) 'user_location',
      },
      'LiveInputWebSearchTool',
    ),
  );
  @override
  String toString() =>
      'LiveInputWebSearchTool(external_web_access: [REDACTED], filters: [REDACTED], search_context_size: [REDACTED], type: [REDACTED], user_location: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for WebSearchToolCall.
@immutable
final class LiveInputWebSearchToolCall extends LiveInputItem {
  /// Parses and validates every canonical known field.
  LiveInputWebSearchToolCall.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputWebSearchToolCall'),
        'LiveInputWebSearchToolCall',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'action', 'id', 'status', 'type'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `action` value.
  Map<String, dynamic>? get action => rawJson['action'] == null
      ? null
      : Map<String, dynamic>.unmodifiable(
          requireLiveObject(
            rawJson['action'],
            'LiveInputWebSearchToolCall.action',
          ),
        );

  /// Distinguishes absent `action` from an explicit null.
  bool get hasAction => rawJson.containsKey('action');

  /// Canonical `id` value.
  String get id => rawJson['id'] as String;

  /// Canonical `status` value.
  LiveInputWebSearchCallStatus get status =>
      LiveInputWebSearchCallStatus.fromJson(rawJson['status']);

  /// Canonical `type` value.
  String get type => rawJson['type'] as String;
  @override
  void validate() => _validateInputComponent(
    'WebSearchToolCall',
    rawJson,
    'LiveInputWebSearchToolCall',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputWebSearchToolCall copyWith({
    Object? action = liveUnset,
    bool clearAction = false,
    Object? id = liveUnset,
    Object? status = liveUnset,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputWebSearchToolCall.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'action': action, 'id': id, 'status': status},
      <String>{if (clearAction) 'action'},
      'LiveInputWebSearchToolCall',
    ),
  );
  @override
  String toString() =>
      'LiveInputWebSearchToolCall(action: [REDACTED], id: [REDACTED], status: [REDACTED], type: [REDACTED], rawJson: [REDACTED])';
}

/// Immutable typed adapter for the canonical inline payload.
@immutable
final class LiveInputWebSearchToolFiltersValue extends LiveInputValue {
  /// Parses and validates every canonical known field.
  LiveInputWebSearchToolFiltersValue.fromJson(Object? json)
    : rawJson = snapshotLiveJson(
        requireLiveObject(json, 'LiveInputWebSearchToolFiltersValue'),
        'LiveInputWebSearchToolFiltersValue',
        knownKeys: _knownKeys,
      ) {
    validate();
  }
  static const Set<String> _knownKeys = {'allowed_domains'};

  /// Complete immutable wire object; all declared fields below are typed.
  final Map<String, dynamic> rawJson;

  /// Canonical `allowed_domains` value.
  List<String>? get allowedDomains => rawJson['allowed_domains'] == null
      ? null
      : List.unmodifiable(
          (rawJson['allowed_domains'] as List).map((value) => value as String),
        );

  /// Distinguishes absent `allowed_domains` from an explicit null.
  bool get hasAllowedDomains => rawJson.containsKey('allowed_domains');
  @override
  void validate() => _validateInputSchema(
    {
      'properties': {
        'allowed_domains': {
          'anyOf': [
            {
              'items': {'type': 'string'},
              'type': 'array',
            },
            {'type': 'null'},
          ],
        },
      },
      'type': 'object',
    },
    rawJson,
    'LiveInputWebSearchToolFiltersValue',
  );
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);

  /// Copies typed members; null is explicit and clear flags remove optional keys.
  LiveInputWebSearchToolFiltersValue copyWith({
    Object? allowedDomains = liveUnset,
    bool clearAllowedDomains = false,
    Map<String, dynamic>? rawJson,

    /// Parses and validates the canonical value.
  }) => LiveInputWebSearchToolFiltersValue.fromJson(
    _copyInputObject(
      this.rawJson,
      _knownKeys,
      rawJson,
      {'allowed_domains': allowedDomains},
      <String>{if (clearAllowedDomains) 'allowed_domains'},
      'LiveInputWebSearchToolFiltersValue',
    ),
  );
  @override
  String toString() =>
      'LiveInputWebSearchToolFiltersValue(allowed_domains: [REDACTED], rawJson: [REDACTED])';
}

/// Typed canonical union inline value.
/// Variants: [LiveEasyInputMessageContentValueBranch0], [LiveEasyInputMessageContentValueBranch1].
@immutable
sealed class LiveEasyInputMessageContentValue extends LiveInputValue {
  const LiveEasyInputMessageContentValue();

  /// Parses and validates the canonical value.
  factory LiveEasyInputMessageContentValue.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveEasyInputMessageContentValue',
    );
    final tagged = _inputTaggedBranch([
      {'type': 'string'},
      {r'$ref': '#/components/schemas/InputMessageContentList'},
    ], wireValue);
    if (tagged == 0) {
      return LiveEasyInputMessageContentValueBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveEasyInputMessageContentValueBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({'type': 'string'}, wireValue)) {
      return LiveEasyInputMessageContentValueBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/InputMessageContentList',
    }, wireValue)) {
      return LiveEasyInputMessageContentValueBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveEasyInputMessageContentValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveEasyInputMessageContentValue copyWith({Object? value = liveUnset}) =>
      LiveEasyInputMessageContentValue.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(
                value,
                context: 'LiveEasyInputMessageContentValue.value',
              ),
      );
}

/// Branch 0 of LiveEasyInputMessageContentValue.
@immutable
final class LiveEasyInputMessageContentValueBranch0
    extends LiveEasyInputMessageContentValue {
  /// Parses and validates the canonical value.
  LiveEasyInputMessageContentValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveEasyInputMessageContentValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'string'},
    rawValue,
    'LiveEasyInputMessageContentValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveEasyInputMessageContentValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveEasyInputMessageContentValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(value, context: 'LiveEasyInputMessageContentValue.value'),
  );
}

/// Branch 1 of LiveEasyInputMessageContentValue.
@immutable
final class LiveEasyInputMessageContentValueBranch1
    extends LiveEasyInputMessageContentValue {
  /// Parses and validates the canonical value.
  LiveEasyInputMessageContentValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveEasyInputMessageContentValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputMessageContentList get value =>
      LiveInputMessageContentList.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/InputMessageContentList'},
    rawValue,
    'LiveEasyInputMessageContentValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveEasyInputMessageContentValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveEasyInputMessageContentValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(value, context: 'LiveEasyInputMessageContentValue.value'),
  );
}

/// Typed canonical union Annotation.
/// Variants: [LiveInputAnnotationBranch0], [LiveInputAnnotationBranch1], [LiveInputAnnotationBranch2], [LiveInputAnnotationBranch3].
@immutable
sealed class LiveInputAnnotation extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputAnnotation();

  /// Parses and validates the canonical value.
  factory LiveInputAnnotation.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(value, 'LiveInputAnnotation');
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/FileCitationBody'},
      {r'$ref': '#/components/schemas/UrlCitationBody'},
      {r'$ref': '#/components/schemas/ContainerFileCitationBody'},
      {r'$ref': '#/components/schemas/FilePath'},
    ], wireValue);
    if (tagged == 0) return LiveInputAnnotationBranch0.fromJson(wireValue);
    if (tagged == 1) return LiveInputAnnotationBranch1.fromJson(wireValue);
    if (tagged == 2) return LiveInputAnnotationBranch2.fromJson(wireValue);
    if (tagged == 3) return LiveInputAnnotationBranch3.fromJson(wireValue);
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FileCitationBody',
    }, wireValue)) {
      return LiveInputAnnotationBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/UrlCitationBody',
    }, wireValue)) {
      return LiveInputAnnotationBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ContainerFileCitationBody',
    }, wireValue)) {
      return LiveInputAnnotationBranch2.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FilePath',
    }, wireValue)) {
      return LiveInputAnnotationBranch3.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputAnnotation: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputAnnotation copyWith({Object? value = liveUnset}) =>
      LiveInputAnnotation.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(value, context: 'LiveInputAnnotation.value'),
      );
}

/// Branch 0 of LiveInputAnnotation.
@immutable
final class LiveInputAnnotationBranch0 extends LiveInputAnnotation {
  /// Parses and validates the canonical value.
  LiveInputAnnotationBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputAnnotationBranch0') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFileCitationBody get value =>
      LiveInputFileCitationBody.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FileCitationBody'},
    rawValue,
    'LiveInputAnnotationBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputAnnotationBranch0 copyWith({Object? value = liveUnset}) =>
      LiveInputAnnotationBranch0.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputAnnotation.value'),
      );
}

/// Branch 1 of LiveInputAnnotation.
@immutable
final class LiveInputAnnotationBranch1 extends LiveInputAnnotation {
  /// Parses and validates the canonical value.
  LiveInputAnnotationBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputAnnotationBranch1') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputUrlCitationBody get value =>
      LiveInputUrlCitationBody.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/UrlCitationBody'},
    rawValue,
    'LiveInputAnnotationBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputAnnotationBranch1 copyWith({Object? value = liveUnset}) =>
      LiveInputAnnotationBranch1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputAnnotation.value'),
      );
}

/// Branch 2 of LiveInputAnnotation.
@immutable
final class LiveInputAnnotationBranch2 extends LiveInputAnnotation {
  /// Parses and validates the canonical value.
  LiveInputAnnotationBranch2.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputAnnotationBranch2') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputContainerFileCitationBody get value =>
      LiveInputContainerFileCitationBody.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ContainerFileCitationBody'},
    rawValue,
    'LiveInputAnnotationBranch2',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputAnnotationBranch2 copyWith({Object? value = liveUnset}) =>
      LiveInputAnnotationBranch2.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputAnnotation.value'),
      );
}

/// Branch 3 of LiveInputAnnotation.
@immutable
final class LiveInputAnnotationBranch3 extends LiveInputAnnotation {
  /// Parses and validates the canonical value.
  LiveInputAnnotationBranch3.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputAnnotationBranch3') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFilePath get value => LiveInputFilePath.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FilePath'},
    rawValue,
    'LiveInputAnnotationBranch3',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputAnnotationBranch3 copyWith({Object? value = liveUnset}) =>
      LiveInputAnnotationBranch3.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputAnnotation.value'),
      );
}

/// Typed canonical value ApplyPatchCallOutputStatusParam.
@immutable
final class LiveInputApplyPatchCallOutputStatusParam extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputApplyPatchCallOutputStatusParam.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputApplyPatchCallOutputStatusParam',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'ApplyPatchCallOutputStatusParam',
    rawValue,
    'LiveInputApplyPatchCallOutputStatusParam',
  );

  /// Parses and validates the canonical value.
  LiveInputApplyPatchCallOutputStatusParam copyWith({
    Object? value = liveUnset,
  }) => LiveInputApplyPatchCallOutputStatusParam.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputApplyPatchCallOutputStatusParam.value',
          ),
  );
}

/// Typed canonical value ApplyPatchCallStatusParam.
@immutable
final class LiveInputApplyPatchCallStatusParam extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputApplyPatchCallStatusParam.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputApplyPatchCallStatusParam',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'ApplyPatchCallStatusParam',
    rawValue,
    'LiveInputApplyPatchCallStatusParam',
  );

  /// Parses and validates the canonical value.
  LiveInputApplyPatchCallStatusParam copyWith({Object? value = liveUnset}) =>
      LiveInputApplyPatchCallStatusParam.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(
                value,
                context: 'LiveInputApplyPatchCallStatusParam.value',
              ),
      );
}

/// Typed canonical union ApplyPatchOperationParam.
/// Variants: [LiveInputApplyPatchOperationParamBranch0], [LiveInputApplyPatchOperationParamBranch1], [LiveInputApplyPatchOperationParamBranch2].
@immutable
sealed class LiveInputApplyPatchOperationParam extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputApplyPatchOperationParam();

  /// Parses and validates the canonical value.
  factory LiveInputApplyPatchOperationParam.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputApplyPatchOperationParam',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/ApplyPatchCreateFileOperationParam'},
      {r'$ref': '#/components/schemas/ApplyPatchDeleteFileOperationParam'},
      {r'$ref': '#/components/schemas/ApplyPatchUpdateFileOperationParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputApplyPatchOperationParamBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputApplyPatchOperationParamBranch1.fromJson(wireValue);
    }
    if (tagged == 2) {
      return LiveInputApplyPatchOperationParamBranch2.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ApplyPatchCreateFileOperationParam',
    }, wireValue)) {
      return LiveInputApplyPatchOperationParamBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ApplyPatchDeleteFileOperationParam',
    }, wireValue)) {
      return LiveInputApplyPatchOperationParamBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ApplyPatchUpdateFileOperationParam',
    }, wireValue)) {
      return LiveInputApplyPatchOperationParamBranch2.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputApplyPatchOperationParam: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputApplyPatchOperationParam copyWith({Object? value = liveUnset}) =>
      LiveInputApplyPatchOperationParam.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(
                value,
                context: 'LiveInputApplyPatchOperationParam.value',
              ),
      );
}

/// Branch 0 of LiveInputApplyPatchOperationParam.
@immutable
final class LiveInputApplyPatchOperationParamBranch0
    extends LiveInputApplyPatchOperationParam {
  /// Parses and validates the canonical value.
  LiveInputApplyPatchOperationParamBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputApplyPatchOperationParamBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputApplyPatchCreateFileOperationParam get value =>
      LiveInputApplyPatchCreateFileOperationParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ApplyPatchCreateFileOperationParam'},
    rawValue,
    'LiveInputApplyPatchOperationParamBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputApplyPatchOperationParamBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputApplyPatchOperationParamBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(value, context: 'LiveInputApplyPatchOperationParam.value'),
  );
}

/// Branch 1 of LiveInputApplyPatchOperationParam.
@immutable
final class LiveInputApplyPatchOperationParamBranch1
    extends LiveInputApplyPatchOperationParam {
  /// Parses and validates the canonical value.
  LiveInputApplyPatchOperationParamBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputApplyPatchOperationParamBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputApplyPatchDeleteFileOperationParam get value =>
      LiveInputApplyPatchDeleteFileOperationParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ApplyPatchDeleteFileOperationParam'},
    rawValue,
    'LiveInputApplyPatchOperationParamBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputApplyPatchOperationParamBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputApplyPatchOperationParamBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(value, context: 'LiveInputApplyPatchOperationParam.value'),
  );
}

/// Branch 2 of LiveInputApplyPatchOperationParam.
@immutable
final class LiveInputApplyPatchOperationParamBranch2
    extends LiveInputApplyPatchOperationParam {
  /// Parses and validates the canonical value.
  LiveInputApplyPatchOperationParamBranch2.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputApplyPatchOperationParamBranch2',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputApplyPatchUpdateFileOperationParam get value =>
      LiveInputApplyPatchUpdateFileOperationParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ApplyPatchUpdateFileOperationParam'},
    rawValue,
    'LiveInputApplyPatchOperationParamBranch2',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputApplyPatchOperationParamBranch2 copyWith({
    Object? value = liveUnset,
  }) => LiveInputApplyPatchOperationParamBranch2.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(value, context: 'LiveInputApplyPatchOperationParam.value'),
  );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0], [LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1].
@immutable
sealed class LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue
    extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue();

  /// Parses and validates the canonical value.
  factory LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue.fromJson(
    Object? value,
  ) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/ContainerNetworkPolicyDisabledParam'},
      {r'$ref': '#/components/schemas/ContainerNetworkPolicyAllowlistParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ContainerNetworkPolicyDisabledParam',
    }, wireValue)) {
      return LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ContainerNetworkPolicyAllowlistParam',
    }, wireValue)) {
      return LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context:
                'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue.value',
          ),
  );
}

/// Branch 0 of LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue.
@immutable
final class LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0
    extends LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue {
  /// Parses and validates the canonical value.
  LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0.fromJson(
    Object? value,
  ) : rawValue = _snapshotInputValue(
        value,
        'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputContainerNetworkPolicyDisabledParam get value =>
      LiveInputContainerNetworkPolicyDisabledParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ContainerNetworkPolicyDisabledParam'},
    rawValue,
    'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context:
                'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue.value',
          ),
  );
}

/// Branch 1 of LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue.
@immutable
final class LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1
    extends LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue {
  /// Parses and validates the canonical value.
  LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1.fromJson(
    Object? value,
  ) : rawValue = _snapshotInputValue(
        value,
        'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputContainerNetworkPolicyAllowlistParam get value =>
      LiveInputContainerNetworkPolicyAllowlistParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ContainerNetworkPolicyAllowlistParam'},
    rawValue,
    'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputAutoCodeInterpreterToolParamNetworkPolicyValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context:
                'LiveInputAutoCodeInterpreterToolParamNetworkPolicyValue.value',
          ),
  );
}

/// Typed canonical value CallableToolAllowedCaller.
@immutable
final class LiveInputCallableToolAllowedCaller extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputCallableToolAllowedCaller.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputCallableToolAllowedCaller',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'CallableToolAllowedCaller',
    rawValue,
    'LiveInputCallableToolAllowedCaller',
  );

  /// Parses and validates the canonical value.
  LiveInputCallableToolAllowedCaller copyWith({Object? value = liveUnset}) =>
      LiveInputCallableToolAllowedCaller.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(
                value,
                context: 'LiveInputCallableToolAllowedCaller.value',
              ),
      );
}

/// Typed canonical value ClickButtonType.
@immutable
final class LiveInputClickButtonType extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputClickButtonType.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputClickButtonType') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'ClickButtonType',
    rawValue,
    'LiveInputClickButtonType',
  );

  /// Parses and validates the canonical value.
  LiveInputClickButtonType copyWith({Object? value = liveUnset}) =>
      LiveInputClickButtonType.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputClickButtonType.value'),
      );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputCodeInterpreterToolCallOutputsItemValueBranch0], [LiveInputCodeInterpreterToolCallOutputsItemValueBranch1].
@immutable
sealed class LiveInputCodeInterpreterToolCallOutputsItemValue
    extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputCodeInterpreterToolCallOutputsItemValue();

  /// Parses and validates the canonical value.
  factory LiveInputCodeInterpreterToolCallOutputsItemValue.fromJson(
    Object? value,
  ) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputCodeInterpreterToolCallOutputsItemValue',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/CodeInterpreterOutputLogs'},
      {r'$ref': '#/components/schemas/CodeInterpreterOutputImage'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputCodeInterpreterToolCallOutputsItemValueBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputCodeInterpreterToolCallOutputsItemValueBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CodeInterpreterOutputLogs',
    }, wireValue)) {
      return LiveInputCodeInterpreterToolCallOutputsItemValueBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CodeInterpreterOutputImage',
    }, wireValue)) {
      return LiveInputCodeInterpreterToolCallOutputsItemValueBranch1.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputCodeInterpreterToolCallOutputsItemValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputCodeInterpreterToolCallOutputsItemValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputCodeInterpreterToolCallOutputsItemValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context: 'LiveInputCodeInterpreterToolCallOutputsItemValue.value',
          ),
  );
}

/// Branch 0 of LiveInputCodeInterpreterToolCallOutputsItemValue.
@immutable
final class LiveInputCodeInterpreterToolCallOutputsItemValueBranch0
    extends LiveInputCodeInterpreterToolCallOutputsItemValue {
  /// Parses and validates the canonical value.
  LiveInputCodeInterpreterToolCallOutputsItemValueBranch0.fromJson(
    Object? value,
  ) : rawValue = _snapshotInputValue(
        value,
        'LiveInputCodeInterpreterToolCallOutputsItemValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCodeInterpreterOutputLogs get value =>
      LiveInputCodeInterpreterOutputLogs.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CodeInterpreterOutputLogs'},
    rawValue,
    'LiveInputCodeInterpreterToolCallOutputsItemValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputCodeInterpreterToolCallOutputsItemValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputCodeInterpreterToolCallOutputsItemValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputCodeInterpreterToolCallOutputsItemValue.value',
          ),
  );
}

/// Branch 1 of LiveInputCodeInterpreterToolCallOutputsItemValue.
@immutable
final class LiveInputCodeInterpreterToolCallOutputsItemValueBranch1
    extends LiveInputCodeInterpreterToolCallOutputsItemValue {
  /// Parses and validates the canonical value.
  LiveInputCodeInterpreterToolCallOutputsItemValueBranch1.fromJson(
    Object? value,
  ) : rawValue = _snapshotInputValue(
        value,
        'LiveInputCodeInterpreterToolCallOutputsItemValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCodeInterpreterOutputImage get value =>
      LiveInputCodeInterpreterOutputImage.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CodeInterpreterOutputImage'},
    rawValue,
    'LiveInputCodeInterpreterToolCallOutputsItemValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputCodeInterpreterToolCallOutputsItemValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputCodeInterpreterToolCallOutputsItemValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputCodeInterpreterToolCallOutputsItemValue.value',
          ),
  );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputCodeInterpreterToolContainerValueBranch0], [LiveInputCodeInterpreterToolContainerValueBranch1].
@immutable
sealed class LiveInputCodeInterpreterToolContainerValue extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputCodeInterpreterToolContainerValue();

  /// Parses and validates the canonical value.
  factory LiveInputCodeInterpreterToolContainerValue.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputCodeInterpreterToolContainerValue',
    );
    final tagged = _inputTaggedBranch([
      {'type': 'string'},
      {r'$ref': '#/components/schemas/AutoCodeInterpreterToolParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputCodeInterpreterToolContainerValueBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputCodeInterpreterToolContainerValueBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({'type': 'string'}, wireValue)) {
      return LiveInputCodeInterpreterToolContainerValueBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/AutoCodeInterpreterToolParam',
    }, wireValue)) {
      return LiveInputCodeInterpreterToolContainerValueBranch1.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputCodeInterpreterToolContainerValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputCodeInterpreterToolContainerValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputCodeInterpreterToolContainerValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context: 'LiveInputCodeInterpreterToolContainerValue.value',
          ),
  );
}

/// Branch 0 of LiveInputCodeInterpreterToolContainerValue.
@immutable
final class LiveInputCodeInterpreterToolContainerValueBranch0
    extends LiveInputCodeInterpreterToolContainerValue {
  /// Parses and validates the canonical value.
  LiveInputCodeInterpreterToolContainerValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputCodeInterpreterToolContainerValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'string'},
    rawValue,
    'LiveInputCodeInterpreterToolContainerValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputCodeInterpreterToolContainerValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputCodeInterpreterToolContainerValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputCodeInterpreterToolContainerValue.value',
          ),
  );
}

/// Branch 1 of LiveInputCodeInterpreterToolContainerValue.
@immutable
final class LiveInputCodeInterpreterToolContainerValueBranch1
    extends LiveInputCodeInterpreterToolContainerValue {
  /// Parses and validates the canonical value.
  LiveInputCodeInterpreterToolContainerValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputCodeInterpreterToolContainerValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputAutoCodeInterpreterToolParam get value =>
      LiveInputAutoCodeInterpreterToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/AutoCodeInterpreterToolParam'},
    rawValue,
    'LiveInputCodeInterpreterToolContainerValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputCodeInterpreterToolContainerValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputCodeInterpreterToolContainerValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputCodeInterpreterToolContainerValue.value',
          ),
  );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputComparisonFilterValueValueBranch0], [LiveInputComparisonFilterValueValueBranch1], [LiveInputComparisonFilterValueValueBranch2], [LiveInputComparisonFilterValueValueBranch3].
@immutable
sealed class LiveInputComparisonFilterValueValue extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputComparisonFilterValueValue();

  /// Parses and validates the canonical value.
  factory LiveInputComparisonFilterValueValue.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputComparisonFilterValueValue',
    );
    final tagged = _inputTaggedBranch([
      {'type': 'string'},
      {'type': 'number'},
      {'type': 'boolean'},
      {
        'items': {
          'oneOf': [
            {'type': 'string'},
            {'type': 'number'},
          ],
        },
        'type': 'array',
      },
    ], wireValue);
    if (tagged == 0) {
      return LiveInputComparisonFilterValueValueBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputComparisonFilterValueValueBranch1.fromJson(wireValue);
    }
    if (tagged == 2) {
      return LiveInputComparisonFilterValueValueBranch2.fromJson(wireValue);
    }
    if (tagged == 3) {
      return LiveInputComparisonFilterValueValueBranch3.fromJson(wireValue);
    }
    if (_matchesInputSchema({'type': 'string'}, wireValue)) {
      return LiveInputComparisonFilterValueValueBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({'type': 'number'}, wireValue)) {
      return LiveInputComparisonFilterValueValueBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({'type': 'boolean'}, wireValue)) {
      return LiveInputComparisonFilterValueValueBranch2.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      'items': {
        'oneOf': [
          {'type': 'string'},
          {'type': 'number'},
        ],
      },
      'type': 'array',
    }, wireValue)) {
      return LiveInputComparisonFilterValueValueBranch3.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputComparisonFilterValueValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputComparisonFilterValueValue copyWith({Object? value = liveUnset}) =>
      LiveInputComparisonFilterValueValue.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(
                value,
                context: 'LiveInputComparisonFilterValueValue.value',
              ),
      );
}

/// Branch 0 of LiveInputComparisonFilterValueValue.
@immutable
final class LiveInputComparisonFilterValueValueBranch0
    extends LiveInputComparisonFilterValueValue {
  /// Parses and validates the canonical value.
  LiveInputComparisonFilterValueValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputComparisonFilterValueValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'string'},
    rawValue,
    'LiveInputComparisonFilterValueValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComparisonFilterValueValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputComparisonFilterValueValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputComparisonFilterValueValue.value',
          ),
  );
}

/// Branch 1 of LiveInputComparisonFilterValueValue.
@immutable
final class LiveInputComparisonFilterValueValueBranch1
    extends LiveInputComparisonFilterValueValue {
  /// Parses and validates the canonical value.
  LiveInputComparisonFilterValueValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputComparisonFilterValueValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  num get value => rawValue! as num;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'number'},
    rawValue,
    'LiveInputComparisonFilterValueValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComparisonFilterValueValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputComparisonFilterValueValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputComparisonFilterValueValue.value',
          ),
  );
}

/// Branch 2 of LiveInputComparisonFilterValueValue.
@immutable
final class LiveInputComparisonFilterValueValueBranch2
    extends LiveInputComparisonFilterValueValue {
  /// Parses and validates the canonical value.
  LiveInputComparisonFilterValueValueBranch2.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputComparisonFilterValueValueBranch2',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  bool get value => rawValue! as bool;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'boolean'},
    rawValue,
    'LiveInputComparisonFilterValueValueBranch2',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComparisonFilterValueValueBranch2 copyWith({
    Object? value = liveUnset,
  }) => LiveInputComparisonFilterValueValueBranch2.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputComparisonFilterValueValue.value',
          ),
  );
}

/// Branch 3 of LiveInputComparisonFilterValueValue.
@immutable
final class LiveInputComparisonFilterValueValueBranch3
    extends LiveInputComparisonFilterValueValue {
  /// Parses and validates the canonical value.
  LiveInputComparisonFilterValueValueBranch3.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputComparisonFilterValueValueBranch3',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  List<LiveInputComparisonFilterValueValueBranch3ItemValue> get value =>
      List.unmodifiable(
        (rawValue! as List).map(
          LiveInputComparisonFilterValueValueBranch3ItemValue.fromJson,
        ),
      );
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {
      'items': {
        'oneOf': [
          {'type': 'string'},
          {'type': 'number'},
        ],
      },
      'type': 'array',
    },
    rawValue,
    'LiveInputComparisonFilterValueValueBranch3',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComparisonFilterValueValueBranch3 copyWith({
    Object? value = liveUnset,
  }) => LiveInputComparisonFilterValueValueBranch3.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputComparisonFilterValueValue.value',
          ),
  );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputComparisonFilterValueValueBranch3ItemValueBranch0], [LiveInputComparisonFilterValueValueBranch3ItemValueBranch1].
@immutable
sealed class LiveInputComparisonFilterValueValueBranch3ItemValue
    extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputComparisonFilterValueValueBranch3ItemValue();

  /// Parses and validates the canonical value.
  factory LiveInputComparisonFilterValueValueBranch3ItemValue.fromJson(
    Object? value,
  ) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputComparisonFilterValueValueBranch3ItemValue',
    );
    final tagged = _inputTaggedBranch([
      {'type': 'string'},
      {'type': 'number'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputComparisonFilterValueValueBranch3ItemValueBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputComparisonFilterValueValueBranch3ItemValueBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({'type': 'string'}, wireValue)) {
      return LiveInputComparisonFilterValueValueBranch3ItemValueBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({'type': 'number'}, wireValue)) {
      return LiveInputComparisonFilterValueValueBranch3ItemValueBranch1.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputComparisonFilterValueValueBranch3ItemValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputComparisonFilterValueValueBranch3ItemValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputComparisonFilterValueValueBranch3ItemValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context:
                'LiveInputComparisonFilterValueValueBranch3ItemValue.value',
          ),
  );
}

/// Branch 0 of LiveInputComparisonFilterValueValueBranch3ItemValue.
@immutable
final class LiveInputComparisonFilterValueValueBranch3ItemValueBranch0
    extends LiveInputComparisonFilterValueValueBranch3ItemValue {
  /// Parses and validates the canonical value.
  LiveInputComparisonFilterValueValueBranch3ItemValueBranch0.fromJson(
    Object? value,
  ) : rawValue = _snapshotInputValue(
        value,
        'LiveInputComparisonFilterValueValueBranch3ItemValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'string'},
    rawValue,
    'LiveInputComparisonFilterValueValueBranch3ItemValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComparisonFilterValueValueBranch3ItemValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputComparisonFilterValueValueBranch3ItemValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context:
                'LiveInputComparisonFilterValueValueBranch3ItemValue.value',
          ),
  );
}

/// Branch 1 of LiveInputComparisonFilterValueValueBranch3ItemValue.
@immutable
final class LiveInputComparisonFilterValueValueBranch3ItemValueBranch1
    extends LiveInputComparisonFilterValueValueBranch3ItemValue {
  /// Parses and validates the canonical value.
  LiveInputComparisonFilterValueValueBranch3ItemValueBranch1.fromJson(
    Object? value,
  ) : rawValue = _snapshotInputValue(
        value,
        'LiveInputComparisonFilterValueValueBranch3ItemValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  num get value => rawValue! as num;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'number'},
    rawValue,
    'LiveInputComparisonFilterValueValueBranch3ItemValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComparisonFilterValueValueBranch3ItemValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputComparisonFilterValueValueBranch3ItemValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context:
                'LiveInputComparisonFilterValueValueBranch3ItemValue.value',
          ),
  );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputCompoundFilterFiltersItemValueBranch0], [LiveInputCompoundFilterFiltersItemValueBranch1].
@immutable
sealed class LiveInputCompoundFilterFiltersItemValue extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputCompoundFilterFiltersItemValue();

  /// Parses and validates the canonical value.
  factory LiveInputCompoundFilterFiltersItemValue.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputCompoundFilterFiltersItemValue',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/ComparisonFilter'},
      {r'$ref': '#/components/schemas/CompoundFilter'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputCompoundFilterFiltersItemValueBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputCompoundFilterFiltersItemValueBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ComparisonFilter',
    }, wireValue)) {
      return LiveInputCompoundFilterFiltersItemValueBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CompoundFilter',
    }, wireValue)) {
      return LiveInputCompoundFilterFiltersItemValueBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputCompoundFilterFiltersItemValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputCompoundFilterFiltersItemValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputCompoundFilterFiltersItemValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context: 'LiveInputCompoundFilterFiltersItemValue.value',
          ),
  );
}

/// Branch 0 of LiveInputCompoundFilterFiltersItemValue.
@immutable
final class LiveInputCompoundFilterFiltersItemValueBranch0
    extends LiveInputCompoundFilterFiltersItemValue {
  /// Parses and validates the canonical value.
  LiveInputCompoundFilterFiltersItemValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputCompoundFilterFiltersItemValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputComparisonFilter get value =>
      LiveInputComparisonFilter.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ComparisonFilter'},
    rawValue,
    'LiveInputCompoundFilterFiltersItemValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputCompoundFilterFiltersItemValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputCompoundFilterFiltersItemValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputCompoundFilterFiltersItemValue.value',
          ),
  );
}

/// Branch 1 of LiveInputCompoundFilterFiltersItemValue.
@immutable
final class LiveInputCompoundFilterFiltersItemValueBranch1
    extends LiveInputCompoundFilterFiltersItemValue {
  /// Parses and validates the canonical value.
  LiveInputCompoundFilterFiltersItemValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputCompoundFilterFiltersItemValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCompoundFilter get value =>
      LiveInputCompoundFilter.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CompoundFilter'},
    rawValue,
    'LiveInputCompoundFilterFiltersItemValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputCompoundFilterFiltersItemValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputCompoundFilterFiltersItemValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputCompoundFilterFiltersItemValue.value',
          ),
  );
}

/// Typed canonical union ComputerAction.
/// Variants: [LiveInputComputerActionBranch0], [LiveInputComputerActionBranch1], [LiveInputComputerActionBranch2], [LiveInputComputerActionBranch3], [LiveInputComputerActionBranch4], [LiveInputComputerActionBranch5], [LiveInputComputerActionBranch6], [LiveInputComputerActionBranch7], [LiveInputComputerActionBranch8].
@immutable
sealed class LiveInputComputerAction extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputComputerAction();

  /// Parses and validates the canonical value.
  factory LiveInputComputerAction.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(value, 'LiveInputComputerAction');
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/ClickParam'},
      {r'$ref': '#/components/schemas/DoubleClickAction'},
      {r'$ref': '#/components/schemas/DragParam'},
      {r'$ref': '#/components/schemas/KeyPressAction'},
      {r'$ref': '#/components/schemas/MoveParam'},
      {r'$ref': '#/components/schemas/ScreenshotParam'},
      {r'$ref': '#/components/schemas/ScrollParam'},
      {r'$ref': '#/components/schemas/TypeParam'},
      {r'$ref': '#/components/schemas/WaitParam'},
    ], wireValue);
    if (tagged == 0) return LiveInputComputerActionBranch0.fromJson(wireValue);
    if (tagged == 1) return LiveInputComputerActionBranch1.fromJson(wireValue);
    if (tagged == 2) return LiveInputComputerActionBranch2.fromJson(wireValue);
    if (tagged == 3) return LiveInputComputerActionBranch3.fromJson(wireValue);
    if (tagged == 4) return LiveInputComputerActionBranch4.fromJson(wireValue);
    if (tagged == 5) return LiveInputComputerActionBranch5.fromJson(wireValue);
    if (tagged == 6) return LiveInputComputerActionBranch6.fromJson(wireValue);
    if (tagged == 7) return LiveInputComputerActionBranch7.fromJson(wireValue);
    if (tagged == 8) return LiveInputComputerActionBranch8.fromJson(wireValue);
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ClickParam',
    }, wireValue)) {
      return LiveInputComputerActionBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/DoubleClickAction',
    }, wireValue)) {
      return LiveInputComputerActionBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/DragParam',
    }, wireValue)) {
      return LiveInputComputerActionBranch2.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/KeyPressAction',
    }, wireValue)) {
      return LiveInputComputerActionBranch3.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/MoveParam',
    }, wireValue)) {
      return LiveInputComputerActionBranch4.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ScreenshotParam',
    }, wireValue)) {
      return LiveInputComputerActionBranch5.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ScrollParam',
    }, wireValue)) {
      return LiveInputComputerActionBranch6.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/TypeParam',
    }, wireValue)) {
      return LiveInputComputerActionBranch7.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/WaitParam',
    }, wireValue)) {
      return LiveInputComputerActionBranch8.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputComputerAction: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputComputerAction copyWith({Object? value = liveUnset}) =>
      LiveInputComputerAction.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(value, context: 'LiveInputComputerAction.value'),
      );
}

/// Branch 0 of LiveInputComputerAction.
@immutable
final class LiveInputComputerActionBranch0 extends LiveInputComputerAction {
  /// Parses and validates the canonical value.
  LiveInputComputerActionBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputComputerActionBranch0') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputClickParam get value => LiveInputClickParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ClickParam'},
    rawValue,
    'LiveInputComputerActionBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComputerActionBranch0 copyWith({Object? value = liveUnset}) =>
      LiveInputComputerActionBranch0.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputComputerAction.value'),
      );
}

/// Branch 1 of LiveInputComputerAction.
@immutable
final class LiveInputComputerActionBranch1 extends LiveInputComputerAction {
  /// Parses and validates the canonical value.
  LiveInputComputerActionBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputComputerActionBranch1') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputDoubleClickAction get value =>
      LiveInputDoubleClickAction.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/DoubleClickAction'},
    rawValue,
    'LiveInputComputerActionBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComputerActionBranch1 copyWith({Object? value = liveUnset}) =>
      LiveInputComputerActionBranch1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputComputerAction.value'),
      );
}

/// Branch 2 of LiveInputComputerAction.
@immutable
final class LiveInputComputerActionBranch2 extends LiveInputComputerAction {
  /// Parses and validates the canonical value.
  LiveInputComputerActionBranch2.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputComputerActionBranch2') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputDragParam get value => LiveInputDragParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/DragParam'},
    rawValue,
    'LiveInputComputerActionBranch2',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComputerActionBranch2 copyWith({Object? value = liveUnset}) =>
      LiveInputComputerActionBranch2.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputComputerAction.value'),
      );
}

/// Branch 3 of LiveInputComputerAction.
@immutable
final class LiveInputComputerActionBranch3 extends LiveInputComputerAction {
  /// Parses and validates the canonical value.
  LiveInputComputerActionBranch3.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputComputerActionBranch3') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputKeyPressAction get value =>
      LiveInputKeyPressAction.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/KeyPressAction'},
    rawValue,
    'LiveInputComputerActionBranch3',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComputerActionBranch3 copyWith({Object? value = liveUnset}) =>
      LiveInputComputerActionBranch3.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputComputerAction.value'),
      );
}

/// Branch 4 of LiveInputComputerAction.
@immutable
final class LiveInputComputerActionBranch4 extends LiveInputComputerAction {
  /// Parses and validates the canonical value.
  LiveInputComputerActionBranch4.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputComputerActionBranch4') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputMoveParam get value => LiveInputMoveParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/MoveParam'},
    rawValue,
    'LiveInputComputerActionBranch4',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComputerActionBranch4 copyWith({Object? value = liveUnset}) =>
      LiveInputComputerActionBranch4.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputComputerAction.value'),
      );
}

/// Branch 5 of LiveInputComputerAction.
@immutable
final class LiveInputComputerActionBranch5 extends LiveInputComputerAction {
  /// Parses and validates the canonical value.
  LiveInputComputerActionBranch5.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputComputerActionBranch5') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputScreenshotParam get value =>
      LiveInputScreenshotParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ScreenshotParam'},
    rawValue,
    'LiveInputComputerActionBranch5',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComputerActionBranch5 copyWith({Object? value = liveUnset}) =>
      LiveInputComputerActionBranch5.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputComputerAction.value'),
      );
}

/// Branch 6 of LiveInputComputerAction.
@immutable
final class LiveInputComputerActionBranch6 extends LiveInputComputerAction {
  /// Parses and validates the canonical value.
  LiveInputComputerActionBranch6.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputComputerActionBranch6') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputScrollParam get value => LiveInputScrollParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ScrollParam'},
    rawValue,
    'LiveInputComputerActionBranch6',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComputerActionBranch6 copyWith({Object? value = liveUnset}) =>
      LiveInputComputerActionBranch6.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputComputerAction.value'),
      );
}

/// Branch 7 of LiveInputComputerAction.
@immutable
final class LiveInputComputerActionBranch7 extends LiveInputComputerAction {
  /// Parses and validates the canonical value.
  LiveInputComputerActionBranch7.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputComputerActionBranch7') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputTypeParam get value => LiveInputTypeParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/TypeParam'},
    rawValue,
    'LiveInputComputerActionBranch7',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComputerActionBranch7 copyWith({Object? value = liveUnset}) =>
      LiveInputComputerActionBranch7.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputComputerAction.value'),
      );
}

/// Branch 8 of LiveInputComputerAction.
@immutable
final class LiveInputComputerActionBranch8 extends LiveInputComputerAction {
  /// Parses and validates the canonical value.
  LiveInputComputerActionBranch8.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputComputerActionBranch8') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputWaitParam get value => LiveInputWaitParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/WaitParam'},
    rawValue,
    'LiveInputComputerActionBranch8',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputComputerActionBranch8 copyWith({Object? value = liveUnset}) =>
      LiveInputComputerActionBranch8.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputComputerAction.value'),
      );
}

/// Typed canonical value ComputerActionList.
@immutable
final class LiveInputComputerActionList extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputComputerActionList.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputComputerActionList') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  List<LiveInputComputerAction> get value => List.unmodifiable(
    (rawValue! as List).map(LiveInputComputerAction.fromJson),
  );
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'ComputerActionList',
    rawValue,
    'LiveInputComputerActionList',
  );

  /// Parses and validates the canonical value.
  LiveInputComputerActionList copyWith({Object? value = liveUnset}) =>
      LiveInputComputerActionList.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputComputerActionList.value'),
      );
}

/// Typed canonical value ComputerEnvironment.
@immutable
final class LiveInputComputerEnvironment extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputComputerEnvironment.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputComputerEnvironment') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'ComputerEnvironment',
    rawValue,
    'LiveInputComputerEnvironment',
  );

  /// Parses and validates the canonical value.
  LiveInputComputerEnvironment copyWith({Object? value = liveUnset}) =>
      LiveInputComputerEnvironment.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputComputerEnvironment.value'),
      );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputContainerAutoParamNetworkPolicyValueBranch0], [LiveInputContainerAutoParamNetworkPolicyValueBranch1].
@immutable
sealed class LiveInputContainerAutoParamNetworkPolicyValue
    extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputContainerAutoParamNetworkPolicyValue();

  /// Parses and validates the canonical value.
  factory LiveInputContainerAutoParamNetworkPolicyValue.fromJson(
    Object? value,
  ) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputContainerAutoParamNetworkPolicyValue',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/ContainerNetworkPolicyDisabledParam'},
      {r'$ref': '#/components/schemas/ContainerNetworkPolicyAllowlistParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputContainerAutoParamNetworkPolicyValueBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputContainerAutoParamNetworkPolicyValueBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ContainerNetworkPolicyDisabledParam',
    }, wireValue)) {
      return LiveInputContainerAutoParamNetworkPolicyValueBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ContainerNetworkPolicyAllowlistParam',
    }, wireValue)) {
      return LiveInputContainerAutoParamNetworkPolicyValueBranch1.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputContainerAutoParamNetworkPolicyValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputContainerAutoParamNetworkPolicyValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputContainerAutoParamNetworkPolicyValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context: 'LiveInputContainerAutoParamNetworkPolicyValue.value',
          ),
  );
}

/// Branch 0 of LiveInputContainerAutoParamNetworkPolicyValue.
@immutable
final class LiveInputContainerAutoParamNetworkPolicyValueBranch0
    extends LiveInputContainerAutoParamNetworkPolicyValue {
  /// Parses and validates the canonical value.
  LiveInputContainerAutoParamNetworkPolicyValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputContainerAutoParamNetworkPolicyValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputContainerNetworkPolicyDisabledParam get value =>
      LiveInputContainerNetworkPolicyDisabledParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ContainerNetworkPolicyDisabledParam'},
    rawValue,
    'LiveInputContainerAutoParamNetworkPolicyValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputContainerAutoParamNetworkPolicyValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputContainerAutoParamNetworkPolicyValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputContainerAutoParamNetworkPolicyValue.value',
          ),
  );
}

/// Branch 1 of LiveInputContainerAutoParamNetworkPolicyValue.
@immutable
final class LiveInputContainerAutoParamNetworkPolicyValueBranch1
    extends LiveInputContainerAutoParamNetworkPolicyValue {
  /// Parses and validates the canonical value.
  LiveInputContainerAutoParamNetworkPolicyValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputContainerAutoParamNetworkPolicyValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputContainerNetworkPolicyAllowlistParam get value =>
      LiveInputContainerNetworkPolicyAllowlistParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ContainerNetworkPolicyAllowlistParam'},
    rawValue,
    'LiveInputContainerAutoParamNetworkPolicyValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputContainerAutoParamNetworkPolicyValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputContainerAutoParamNetworkPolicyValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputContainerAutoParamNetworkPolicyValue.value',
          ),
  );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputContainerAutoParamSkillsItemValueBranch0], [LiveInputContainerAutoParamSkillsItemValueBranch1].
@immutable
sealed class LiveInputContainerAutoParamSkillsItemValue extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputContainerAutoParamSkillsItemValue();

  /// Parses and validates the canonical value.
  factory LiveInputContainerAutoParamSkillsItemValue.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputContainerAutoParamSkillsItemValue',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/SkillReferenceParam'},
      {r'$ref': '#/components/schemas/InlineSkillParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputContainerAutoParamSkillsItemValueBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputContainerAutoParamSkillsItemValueBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/SkillReferenceParam',
    }, wireValue)) {
      return LiveInputContainerAutoParamSkillsItemValueBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/InlineSkillParam',
    }, wireValue)) {
      return LiveInputContainerAutoParamSkillsItemValueBranch1.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputContainerAutoParamSkillsItemValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputContainerAutoParamSkillsItemValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputContainerAutoParamSkillsItemValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context: 'LiveInputContainerAutoParamSkillsItemValue.value',
          ),
  );
}

/// Branch 0 of LiveInputContainerAutoParamSkillsItemValue.
@immutable
final class LiveInputContainerAutoParamSkillsItemValueBranch0
    extends LiveInputContainerAutoParamSkillsItemValue {
  /// Parses and validates the canonical value.
  LiveInputContainerAutoParamSkillsItemValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputContainerAutoParamSkillsItemValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputSkillReferenceParam get value =>
      LiveInputSkillReferenceParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/SkillReferenceParam'},
    rawValue,
    'LiveInputContainerAutoParamSkillsItemValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputContainerAutoParamSkillsItemValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputContainerAutoParamSkillsItemValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputContainerAutoParamSkillsItemValue.value',
          ),
  );
}

/// Branch 1 of LiveInputContainerAutoParamSkillsItemValue.
@immutable
final class LiveInputContainerAutoParamSkillsItemValueBranch1
    extends LiveInputContainerAutoParamSkillsItemValue {
  /// Parses and validates the canonical value.
  LiveInputContainerAutoParamSkillsItemValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputContainerAutoParamSkillsItemValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputInlineSkillParam get value =>
      LiveInputInlineSkillParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/InlineSkillParam'},
    rawValue,
    'LiveInputContainerAutoParamSkillsItemValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputContainerAutoParamSkillsItemValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputContainerAutoParamSkillsItemValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputContainerAutoParamSkillsItemValue.value',
          ),
  );
}

/// Typed canonical value ContainerMemoryLimit.
@immutable
final class LiveInputContainerMemoryLimit extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputContainerMemoryLimit.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputContainerMemoryLimit') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'ContainerMemoryLimit',
    rawValue,
    'LiveInputContainerMemoryLimit',
  );

  /// Parses and validates the canonical value.
  LiveInputContainerMemoryLimit copyWith({Object? value = liveUnset}) =>
      LiveInputContainerMemoryLimit.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputContainerMemoryLimit.value'),
      );
}

/// Typed canonical union InputContent.
/// Variants: [LiveInputContentBranch0], [LiveInputContentBranch1], [LiveInputContentBranch2].
@immutable
sealed class LiveInputContent extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputContent();

  /// Parses and validates the canonical value.
  factory LiveInputContent.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(value, 'LiveInputContent');
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/InputTextContent'},
      {r'$ref': '#/components/schemas/InputImageContent'},
      {r'$ref': '#/components/schemas/InputFileContent'},
    ], wireValue);
    if (tagged == 0) return LiveInputContentBranch0.fromJson(wireValue);
    if (tagged == 1) return LiveInputContentBranch1.fromJson(wireValue);
    if (tagged == 2) return LiveInputContentBranch2.fromJson(wireValue);
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/InputTextContent',
    }, wireValue)) {
      return LiveInputContentBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/InputImageContent',
    }, wireValue)) {
      return LiveInputContentBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/InputFileContent',
    }, wireValue)) {
      return LiveInputContentBranch2.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputContent: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputContent copyWith({Object? value = liveUnset}) =>
      LiveInputContent.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(value, context: 'LiveInputContent.value'),
      );
}

/// Branch 0 of LiveInputContent.
@immutable
final class LiveInputContentBranch0 extends LiveInputContent {
  /// Parses and validates the canonical value.
  LiveInputContentBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputContentBranch0') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputTextContent get value => LiveInputTextContent.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/InputTextContent'},
    rawValue,
    'LiveInputContentBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputContentBranch0 copyWith({Object? value = liveUnset}) =>
      LiveInputContentBranch0.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputContent.value'),
      );
}

/// Branch 1 of LiveInputContent.
@immutable
final class LiveInputContentBranch1 extends LiveInputContent {
  /// Parses and validates the canonical value.
  LiveInputContentBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputContentBranch1') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputImageContent get value => LiveInputImageContent.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/InputImageContent'},
    rawValue,
    'LiveInputContentBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputContentBranch1 copyWith({Object? value = liveUnset}) =>
      LiveInputContentBranch1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputContent.value'),
      );
}

/// Branch 2 of LiveInputContent.
@immutable
final class LiveInputContentBranch2 extends LiveInputContent {
  /// Parses and validates the canonical value.
  LiveInputContentBranch2.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputContentBranch2') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFileContent get value => LiveInputFileContent.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/InputFileContent'},
    rawValue,
    'LiveInputContentBranch2',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputContentBranch2 copyWith({Object? value = liveUnset}) =>
      LiveInputContentBranch2.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputContent.value'),
      );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputCustomToolCallOutputOutputValueBranch0], [LiveInputCustomToolCallOutputOutputValueBranch1].
@immutable
sealed class LiveInputCustomToolCallOutputOutputValue extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputCustomToolCallOutputOutputValue();

  /// Parses and validates the canonical value.
  factory LiveInputCustomToolCallOutputOutputValue.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputCustomToolCallOutputOutputValue',
    );
    final tagged = _inputTaggedBranch([
      {'type': 'string'},
      {
        'items': {
          r'$ref': '#/components/schemas/FunctionAndCustomToolCallOutput',
        },
        'type': 'array',
      },
    ], wireValue);
    if (tagged == 0) {
      return LiveInputCustomToolCallOutputOutputValueBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputCustomToolCallOutputOutputValueBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({'type': 'string'}, wireValue)) {
      return LiveInputCustomToolCallOutputOutputValueBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      'items': {
        r'$ref': '#/components/schemas/FunctionAndCustomToolCallOutput',
      },
      'type': 'array',
    }, wireValue)) {
      return LiveInputCustomToolCallOutputOutputValueBranch1.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputCustomToolCallOutputOutputValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputCustomToolCallOutputOutputValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputCustomToolCallOutputOutputValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context: 'LiveInputCustomToolCallOutputOutputValue.value',
          ),
  );
}

/// Branch 0 of LiveInputCustomToolCallOutputOutputValue.
@immutable
final class LiveInputCustomToolCallOutputOutputValueBranch0
    extends LiveInputCustomToolCallOutputOutputValue {
  /// Parses and validates the canonical value.
  LiveInputCustomToolCallOutputOutputValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputCustomToolCallOutputOutputValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'string'},
    rawValue,
    'LiveInputCustomToolCallOutputOutputValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputCustomToolCallOutputOutputValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputCustomToolCallOutputOutputValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputCustomToolCallOutputOutputValue.value',
          ),
  );
}

/// Branch 1 of LiveInputCustomToolCallOutputOutputValue.
@immutable
final class LiveInputCustomToolCallOutputOutputValueBranch1
    extends LiveInputCustomToolCallOutputOutputValue {
  /// Parses and validates the canonical value.
  LiveInputCustomToolCallOutputOutputValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputCustomToolCallOutputOutputValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  List<LiveInputFunctionAndCustomToolCallOutput> get value => List.unmodifiable(
    (rawValue! as List).map(LiveInputFunctionAndCustomToolCallOutput.fromJson),
  );
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {
      'items': {
        r'$ref': '#/components/schemas/FunctionAndCustomToolCallOutput',
      },
      'type': 'array',
    },
    rawValue,
    'LiveInputCustomToolCallOutputOutputValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputCustomToolCallOutputOutputValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputCustomToolCallOutputOutputValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputCustomToolCallOutputOutputValue.value',
          ),
  );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputCustomToolParamFormatValueBranch0], [LiveInputCustomToolParamFormatValueBranch1].
@immutable
sealed class LiveInputCustomToolParamFormatValue extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputCustomToolParamFormatValue();

  /// Parses and validates the canonical value.
  factory LiveInputCustomToolParamFormatValue.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputCustomToolParamFormatValue',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/CustomTextFormatParam'},
      {r'$ref': '#/components/schemas/CustomGrammarFormatParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputCustomToolParamFormatValueBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputCustomToolParamFormatValueBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CustomTextFormatParam',
    }, wireValue)) {
      return LiveInputCustomToolParamFormatValueBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CustomGrammarFormatParam',
    }, wireValue)) {
      return LiveInputCustomToolParamFormatValueBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputCustomToolParamFormatValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputCustomToolParamFormatValue copyWith({Object? value = liveUnset}) =>
      LiveInputCustomToolParamFormatValue.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(
                value,
                context: 'LiveInputCustomToolParamFormatValue.value',
              ),
      );
}

/// Branch 0 of LiveInputCustomToolParamFormatValue.
@immutable
final class LiveInputCustomToolParamFormatValueBranch0
    extends LiveInputCustomToolParamFormatValue {
  /// Parses and validates the canonical value.
  LiveInputCustomToolParamFormatValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputCustomToolParamFormatValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCustomTextFormatParam get value =>
      LiveInputCustomTextFormatParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CustomTextFormatParam'},
    rawValue,
    'LiveInputCustomToolParamFormatValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputCustomToolParamFormatValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputCustomToolParamFormatValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputCustomToolParamFormatValue.value',
          ),
  );
}

/// Branch 1 of LiveInputCustomToolParamFormatValue.
@immutable
final class LiveInputCustomToolParamFormatValueBranch1
    extends LiveInputCustomToolParamFormatValue {
  /// Parses and validates the canonical value.
  LiveInputCustomToolParamFormatValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputCustomToolParamFormatValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCustomGrammarFormatParam get value =>
      LiveInputCustomGrammarFormatParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CustomGrammarFormatParam'},
    rawValue,
    'LiveInputCustomToolParamFormatValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputCustomToolParamFormatValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputCustomToolParamFormatValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputCustomToolParamFormatValue.value',
          ),
  );
}

/// Typed canonical value DetailEnum.
@immutable
final class LiveInputDetailEnum extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputDetailEnum.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputDetailEnum') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() =>
      _validateInputComponent('DetailEnum', rawValue, 'LiveInputDetailEnum');

  /// Parses and validates the canonical value.
  LiveInputDetailEnum copyWith({Object? value = liveUnset}) =>
      LiveInputDetailEnum.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputDetailEnum.value'),
      );
}

/// Typed canonical value InputFidelity.
@immutable
final class LiveInputFidelity extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputFidelity.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputFidelity') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() =>
      _validateInputComponent('InputFidelity', rawValue, 'LiveInputFidelity');

  /// Parses and validates the canonical value.
  LiveInputFidelity copyWith({Object? value = liveUnset}) =>
      LiveInputFidelity.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputFidelity.value'),
      );
}

/// Typed canonical value FileDetailEnum.
@immutable
final class LiveInputFileDetailEnum extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputFileDetailEnum.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputFileDetailEnum') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'FileDetailEnum',
    rawValue,
    'LiveInputFileDetailEnum',
  );

  /// Parses and validates the canonical value.
  LiveInputFileDetailEnum copyWith({Object? value = liveUnset}) =>
      LiveInputFileDetailEnum.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputFileDetailEnum.value'),
      );
}

/// Typed canonical value FileInputDetail.
@immutable
final class LiveInputFileInputDetail extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputFileInputDetail.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputFileInputDetail') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'FileInputDetail',
    rawValue,
    'LiveInputFileInputDetail',
  );

  /// Parses and validates the canonical value.
  LiveInputFileInputDetail copyWith({Object? value = liveUnset}) =>
      LiveInputFileInputDetail.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputFileInputDetail.value'),
      );
}

/// Typed canonical union Filters.
/// Variants: [LiveInputFiltersBranch0], [LiveInputFiltersBranch1].
@immutable
sealed class LiveInputFilters extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputFilters();

  /// Parses and validates the canonical value.
  factory LiveInputFilters.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(value, 'LiveInputFilters');
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/ComparisonFilter'},
      {r'$ref': '#/components/schemas/CompoundFilter'},
    ], wireValue);
    if (tagged == 0) return LiveInputFiltersBranch0.fromJson(wireValue);
    if (tagged == 1) return LiveInputFiltersBranch1.fromJson(wireValue);
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ComparisonFilter',
    }, wireValue)) {
      return LiveInputFiltersBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CompoundFilter',
    }, wireValue)) {
      return LiveInputFiltersBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputFilters: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputFilters copyWith({Object? value = liveUnset}) =>
      LiveInputFilters.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(value, context: 'LiveInputFilters.value'),
      );
}

/// Branch 0 of LiveInputFilters.
@immutable
final class LiveInputFiltersBranch0 extends LiveInputFilters {
  /// Parses and validates the canonical value.
  LiveInputFiltersBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputFiltersBranch0') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputComparisonFilter get value =>
      LiveInputComparisonFilter.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ComparisonFilter'},
    rawValue,
    'LiveInputFiltersBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFiltersBranch0 copyWith({Object? value = liveUnset}) =>
      LiveInputFiltersBranch0.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputFilters.value'),
      );
}

/// Branch 1 of LiveInputFilters.
@immutable
final class LiveInputFiltersBranch1 extends LiveInputFilters {
  /// Parses and validates the canonical value.
  LiveInputFiltersBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputFiltersBranch1') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCompoundFilter get value =>
      LiveInputCompoundFilter.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CompoundFilter'},
    rawValue,
    'LiveInputFiltersBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFiltersBranch1 copyWith({Object? value = liveUnset}) =>
      LiveInputFiltersBranch1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputFilters.value'),
      );
}

/// Typed canonical union FunctionAndCustomToolCallOutput.
/// Variants: [LiveInputFunctionAndCustomToolCallOutputBranch0], [LiveInputFunctionAndCustomToolCallOutputBranch1], [LiveInputFunctionAndCustomToolCallOutputBranch2].
@immutable
sealed class LiveInputFunctionAndCustomToolCallOutput extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputFunctionAndCustomToolCallOutput();

  /// Parses and validates the canonical value.
  factory LiveInputFunctionAndCustomToolCallOutput.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputFunctionAndCustomToolCallOutput',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/InputTextContent'},
      {r'$ref': '#/components/schemas/InputImageContent'},
      {r'$ref': '#/components/schemas/InputFileContent'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputFunctionAndCustomToolCallOutputBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputFunctionAndCustomToolCallOutputBranch1.fromJson(
        wireValue,
      );
    }
    if (tagged == 2) {
      return LiveInputFunctionAndCustomToolCallOutputBranch2.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/InputTextContent',
    }, wireValue)) {
      return LiveInputFunctionAndCustomToolCallOutputBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/InputImageContent',
    }, wireValue)) {
      return LiveInputFunctionAndCustomToolCallOutputBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/InputFileContent',
    }, wireValue)) {
      return LiveInputFunctionAndCustomToolCallOutputBranch2.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputFunctionAndCustomToolCallOutput: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputFunctionAndCustomToolCallOutput copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionAndCustomToolCallOutput.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context: 'LiveInputFunctionAndCustomToolCallOutput.value',
          ),
  );
}

/// Branch 0 of LiveInputFunctionAndCustomToolCallOutput.
@immutable
final class LiveInputFunctionAndCustomToolCallOutputBranch0
    extends LiveInputFunctionAndCustomToolCallOutput {
  /// Parses and validates the canonical value.
  LiveInputFunctionAndCustomToolCallOutputBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionAndCustomToolCallOutputBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputTextContent get value => LiveInputTextContent.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/InputTextContent'},
    rawValue,
    'LiveInputFunctionAndCustomToolCallOutputBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionAndCustomToolCallOutputBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionAndCustomToolCallOutputBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputFunctionAndCustomToolCallOutput.value',
          ),
  );
}

/// Branch 1 of LiveInputFunctionAndCustomToolCallOutput.
@immutable
final class LiveInputFunctionAndCustomToolCallOutputBranch1
    extends LiveInputFunctionAndCustomToolCallOutput {
  /// Parses and validates the canonical value.
  LiveInputFunctionAndCustomToolCallOutputBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionAndCustomToolCallOutputBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputImageContent get value => LiveInputImageContent.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/InputImageContent'},
    rawValue,
    'LiveInputFunctionAndCustomToolCallOutputBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionAndCustomToolCallOutputBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionAndCustomToolCallOutputBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputFunctionAndCustomToolCallOutput.value',
          ),
  );
}

/// Branch 2 of LiveInputFunctionAndCustomToolCallOutput.
@immutable
final class LiveInputFunctionAndCustomToolCallOutputBranch2
    extends LiveInputFunctionAndCustomToolCallOutput {
  /// Parses and validates the canonical value.
  LiveInputFunctionAndCustomToolCallOutputBranch2.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionAndCustomToolCallOutputBranch2',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFileContent get value => LiveInputFileContent.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/InputFileContent'},
    rawValue,
    'LiveInputFunctionAndCustomToolCallOutputBranch2',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionAndCustomToolCallOutputBranch2 copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionAndCustomToolCallOutputBranch2.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputFunctionAndCustomToolCallOutput.value',
          ),
  );
}

/// Typed canonical value FunctionCallItemStatus.
@immutable
final class LiveInputFunctionCallItemStatus extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputFunctionCallItemStatus.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputFunctionCallItemStatus') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'FunctionCallItemStatus',
    rawValue,
    'LiveInputFunctionCallItemStatus',
  );

  /// Parses and validates the canonical value.
  LiveInputFunctionCallItemStatus copyWith({Object? value = liveUnset}) =>
      LiveInputFunctionCallItemStatus.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(
                value,
                context: 'LiveInputFunctionCallItemStatus.value',
              ),
      );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputFunctionCallOutputItemParamOutputValueBranch0], [LiveInputFunctionCallOutputItemParamOutputValueBranch1].
@immutable
sealed class LiveInputFunctionCallOutputItemParamOutputValue
    extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputFunctionCallOutputItemParamOutputValue();

  /// Parses and validates the canonical value.
  factory LiveInputFunctionCallOutputItemParamOutputValue.fromJson(
    Object? value,
  ) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputFunctionCallOutputItemParamOutputValue',
    );
    final tagged = _inputTaggedBranch([
      {'maxLength': 10485760, 'type': 'string'},
      {
        'items': {
          'discriminator': {'propertyName': 'type'},
          'oneOf': [
            {r'$ref': '#/components/schemas/InputTextContentParam'},
            {r'$ref': '#/components/schemas/InputImageContentParamAutoParam'},
            {r'$ref': '#/components/schemas/InputFileContentParam'},
          ],
        },
        'type': 'array',
      },
    ], wireValue);
    if (tagged == 0) {
      return LiveInputFunctionCallOutputItemParamOutputValueBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputFunctionCallOutputItemParamOutputValueBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      'maxLength': 10485760,
      'type': 'string',
    }, wireValue)) {
      return LiveInputFunctionCallOutputItemParamOutputValueBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      'items': {
        'discriminator': {'propertyName': 'type'},
        'oneOf': [
          {r'$ref': '#/components/schemas/InputTextContentParam'},
          {r'$ref': '#/components/schemas/InputImageContentParamAutoParam'},
          {r'$ref': '#/components/schemas/InputFileContentParam'},
        ],
      },
      'type': 'array',
    }, wireValue)) {
      return LiveInputFunctionCallOutputItemParamOutputValueBranch1.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputFunctionCallOutputItemParamOutputValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputFunctionCallOutputItemParamOutputValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionCallOutputItemParamOutputValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context: 'LiveInputFunctionCallOutputItemParamOutputValue.value',
          ),
  );
}

/// Branch 0 of LiveInputFunctionCallOutputItemParamOutputValue.
@immutable
final class LiveInputFunctionCallOutputItemParamOutputValueBranch0
    extends LiveInputFunctionCallOutputItemParamOutputValue {
  /// Parses and validates the canonical value.
  LiveInputFunctionCallOutputItemParamOutputValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionCallOutputItemParamOutputValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'maxLength': 10485760, 'type': 'string'},
    rawValue,
    'LiveInputFunctionCallOutputItemParamOutputValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionCallOutputItemParamOutputValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionCallOutputItemParamOutputValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputFunctionCallOutputItemParamOutputValue.value',
          ),
  );
}

/// Branch 1 of LiveInputFunctionCallOutputItemParamOutputValue.
@immutable
final class LiveInputFunctionCallOutputItemParamOutputValueBranch1
    extends LiveInputFunctionCallOutputItemParamOutputValue {
  /// Parses and validates the canonical value.
  LiveInputFunctionCallOutputItemParamOutputValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionCallOutputItemParamOutputValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  List<LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue>
  get value => List.unmodifiable(
    (rawValue! as List).map(
      LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue.fromJson,
    ),
  );
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {
      'items': {
        'discriminator': {'propertyName': 'type'},
        'oneOf': [
          {r'$ref': '#/components/schemas/InputTextContentParam'},
          {r'$ref': '#/components/schemas/InputImageContentParamAutoParam'},
          {r'$ref': '#/components/schemas/InputFileContentParam'},
        ],
      },
      'type': 'array',
    },
    rawValue,
    'LiveInputFunctionCallOutputItemParamOutputValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionCallOutputItemParamOutputValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionCallOutputItemParamOutputValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputFunctionCallOutputItemParamOutputValue.value',
          ),
  );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0], [LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1], [LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2].
@immutable
sealed class LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue
    extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue();

  /// Parses and validates the canonical value.
  factory LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue.fromJson(
    Object? value,
  ) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/InputTextContentParam'},
      {r'$ref': '#/components/schemas/InputImageContentParamAutoParam'},
      {r'$ref': '#/components/schemas/InputFileContentParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1.fromJson(
        wireValue,
      );
    }
    if (tagged == 2) {
      return LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/InputTextContentParam',
    }, wireValue)) {
      return LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/InputImageContentParamAutoParam',
    }, wireValue)) {
      return LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/InputFileContentParam',
    }, wireValue)) {
      return LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context:
                'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue.value',
          ),
  );
}

/// Branch 0 of LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue.
@immutable
final class LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0
    extends LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue {
  /// Parses and validates the canonical value.
  LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0.fromJson(
    Object? value,
  ) : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputTextContentParam get value =>
      LiveInputTextContentParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/InputTextContentParam'},
    rawValue,
    'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0
  copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context:
                'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue.value',
          ),
  );
}

/// Branch 1 of LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue.
@immutable
final class LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1
    extends LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue {
  /// Parses and validates the canonical value.
  LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1.fromJson(
    Object? value,
  ) : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputImageContentParamAutoParam get value =>
      LiveInputImageContentParamAutoParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/InputImageContentParamAutoParam'},
    rawValue,
    'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1
  copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context:
                'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue.value',
          ),
  );
}

/// Branch 2 of LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue.
@immutable
final class LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2
    extends LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue {
  /// Parses and validates the canonical value.
  LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2.fromJson(
    Object? value,
  ) : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFileContentParam get value =>
      LiveInputFileContentParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/InputFileContentParam'},
    rawValue,
    'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2
  copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValueBranch2.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context:
                'LiveInputFunctionCallOutputItemParamOutputValueBranch1ItemValue.value',
          ),
  );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputFunctionShellCallItemParamEnvironmentValueBranch0], [LiveInputFunctionShellCallItemParamEnvironmentValueBranch1].
@immutable
sealed class LiveInputFunctionShellCallItemParamEnvironmentValue
    extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputFunctionShellCallItemParamEnvironmentValue();

  /// Parses and validates the canonical value.
  factory LiveInputFunctionShellCallItemParamEnvironmentValue.fromJson(
    Object? value,
  ) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputFunctionShellCallItemParamEnvironmentValue',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/LocalEnvironmentParam'},
      {r'$ref': '#/components/schemas/ContainerReferenceParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputFunctionShellCallItemParamEnvironmentValueBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputFunctionShellCallItemParamEnvironmentValueBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/LocalEnvironmentParam',
    }, wireValue)) {
      return LiveInputFunctionShellCallItemParamEnvironmentValueBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ContainerReferenceParam',
    }, wireValue)) {
      return LiveInputFunctionShellCallItemParamEnvironmentValueBranch1.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputFunctionShellCallItemParamEnvironmentValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputFunctionShellCallItemParamEnvironmentValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionShellCallItemParamEnvironmentValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context:
                'LiveInputFunctionShellCallItemParamEnvironmentValue.value',
          ),
  );
}

/// Branch 0 of LiveInputFunctionShellCallItemParamEnvironmentValue.
@immutable
final class LiveInputFunctionShellCallItemParamEnvironmentValueBranch0
    extends LiveInputFunctionShellCallItemParamEnvironmentValue {
  /// Parses and validates the canonical value.
  LiveInputFunctionShellCallItemParamEnvironmentValueBranch0.fromJson(
    Object? value,
  ) : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionShellCallItemParamEnvironmentValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputLocalEnvironmentParam get value =>
      LiveInputLocalEnvironmentParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/LocalEnvironmentParam'},
    rawValue,
    'LiveInputFunctionShellCallItemParamEnvironmentValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionShellCallItemParamEnvironmentValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionShellCallItemParamEnvironmentValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context:
                'LiveInputFunctionShellCallItemParamEnvironmentValue.value',
          ),
  );
}

/// Branch 1 of LiveInputFunctionShellCallItemParamEnvironmentValue.
@immutable
final class LiveInputFunctionShellCallItemParamEnvironmentValueBranch1
    extends LiveInputFunctionShellCallItemParamEnvironmentValue {
  /// Parses and validates the canonical value.
  LiveInputFunctionShellCallItemParamEnvironmentValueBranch1.fromJson(
    Object? value,
  ) : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionShellCallItemParamEnvironmentValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputContainerReferenceParam get value =>
      LiveInputContainerReferenceParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ContainerReferenceParam'},
    rawValue,
    'LiveInputFunctionShellCallItemParamEnvironmentValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionShellCallItemParamEnvironmentValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionShellCallItemParamEnvironmentValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context:
                'LiveInputFunctionShellCallItemParamEnvironmentValue.value',
          ),
  );
}

/// Typed canonical value FunctionShellCallItemStatus.
@immutable
final class LiveInputFunctionShellCallItemStatus extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputFunctionShellCallItemStatus.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionShellCallItemStatus',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'FunctionShellCallItemStatus',
    rawValue,
    'LiveInputFunctionShellCallItemStatus',
  );

  /// Parses and validates the canonical value.
  LiveInputFunctionShellCallItemStatus copyWith({Object? value = liveUnset}) =>
      LiveInputFunctionShellCallItemStatus.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(
                value,
                context: 'LiveInputFunctionShellCallItemStatus.value',
              ),
      );
}

/// Typed canonical union FunctionShellCallOutputOutcomeParam.
/// Variants: [LiveInputFunctionShellCallOutputOutcomeParamBranch0], [LiveInputFunctionShellCallOutputOutcomeParamBranch1].
@immutable
sealed class LiveInputFunctionShellCallOutputOutcomeParam
    extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputFunctionShellCallOutputOutcomeParam();

  /// Parses and validates the canonical value.
  factory LiveInputFunctionShellCallOutputOutcomeParam.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputFunctionShellCallOutputOutcomeParam',
    );
    final tagged = _inputTaggedBranch([
      {
        r'$ref':
            '#/components/schemas/FunctionShellCallOutputTimeoutOutcomeParam',
      },
      {r'$ref': '#/components/schemas/FunctionShellCallOutputExitOutcomeParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputFunctionShellCallOutputOutcomeParamBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputFunctionShellCallOutputOutcomeParamBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref':
          '#/components/schemas/FunctionShellCallOutputTimeoutOutcomeParam',
    }, wireValue)) {
      return LiveInputFunctionShellCallOutputOutcomeParamBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FunctionShellCallOutputExitOutcomeParam',
    }, wireValue)) {
      return LiveInputFunctionShellCallOutputOutcomeParamBranch1.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputFunctionShellCallOutputOutcomeParam: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputFunctionShellCallOutputOutcomeParam copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionShellCallOutputOutcomeParam.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context: 'LiveInputFunctionShellCallOutputOutcomeParam.value',
          ),
  );
}

/// Branch 0 of LiveInputFunctionShellCallOutputOutcomeParam.
@immutable
final class LiveInputFunctionShellCallOutputOutcomeParamBranch0
    extends LiveInputFunctionShellCallOutputOutcomeParam {
  /// Parses and validates the canonical value.
  LiveInputFunctionShellCallOutputOutcomeParamBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionShellCallOutputOutcomeParamBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFunctionShellCallOutputTimeoutOutcomeParam get value =>
      LiveInputFunctionShellCallOutputTimeoutOutcomeParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {
      r'$ref':
          '#/components/schemas/FunctionShellCallOutputTimeoutOutcomeParam',
    },
    rawValue,
    'LiveInputFunctionShellCallOutputOutcomeParamBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionShellCallOutputOutcomeParamBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionShellCallOutputOutcomeParamBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputFunctionShellCallOutputOutcomeParam.value',
          ),
  );
}

/// Branch 1 of LiveInputFunctionShellCallOutputOutcomeParam.
@immutable
final class LiveInputFunctionShellCallOutputOutcomeParamBranch1
    extends LiveInputFunctionShellCallOutputOutcomeParam {
  /// Parses and validates the canonical value.
  LiveInputFunctionShellCallOutputOutcomeParamBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionShellCallOutputOutcomeParamBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFunctionShellCallOutputExitOutcomeParam get value =>
      LiveInputFunctionShellCallOutputExitOutcomeParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FunctionShellCallOutputExitOutcomeParam'},
    rawValue,
    'LiveInputFunctionShellCallOutputOutcomeParamBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionShellCallOutputOutcomeParamBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionShellCallOutputOutcomeParamBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputFunctionShellCallOutputOutcomeParam.value',
          ),
  );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputFunctionShellToolParamEnvironmentValueBranch0], [LiveInputFunctionShellToolParamEnvironmentValueBranch1], [LiveInputFunctionShellToolParamEnvironmentValueBranch2].
@immutable
sealed class LiveInputFunctionShellToolParamEnvironmentValue
    extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputFunctionShellToolParamEnvironmentValue();

  /// Parses and validates the canonical value.
  factory LiveInputFunctionShellToolParamEnvironmentValue.fromJson(
    Object? value,
  ) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputFunctionShellToolParamEnvironmentValue',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/ContainerAutoParam'},
      {r'$ref': '#/components/schemas/LocalEnvironmentParam'},
      {r'$ref': '#/components/schemas/ContainerReferenceParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputFunctionShellToolParamEnvironmentValueBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputFunctionShellToolParamEnvironmentValueBranch1.fromJson(
        wireValue,
      );
    }
    if (tagged == 2) {
      return LiveInputFunctionShellToolParamEnvironmentValueBranch2.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ContainerAutoParam',
    }, wireValue)) {
      return LiveInputFunctionShellToolParamEnvironmentValueBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/LocalEnvironmentParam',
    }, wireValue)) {
      return LiveInputFunctionShellToolParamEnvironmentValueBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ContainerReferenceParam',
    }, wireValue)) {
      return LiveInputFunctionShellToolParamEnvironmentValueBranch2.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputFunctionShellToolParamEnvironmentValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputFunctionShellToolParamEnvironmentValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionShellToolParamEnvironmentValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context: 'LiveInputFunctionShellToolParamEnvironmentValue.value',
          ),
  );
}

/// Branch 0 of LiveInputFunctionShellToolParamEnvironmentValue.
@immutable
final class LiveInputFunctionShellToolParamEnvironmentValueBranch0
    extends LiveInputFunctionShellToolParamEnvironmentValue {
  /// Parses and validates the canonical value.
  LiveInputFunctionShellToolParamEnvironmentValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionShellToolParamEnvironmentValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputContainerAutoParam get value =>
      LiveInputContainerAutoParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ContainerAutoParam'},
    rawValue,
    'LiveInputFunctionShellToolParamEnvironmentValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionShellToolParamEnvironmentValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionShellToolParamEnvironmentValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputFunctionShellToolParamEnvironmentValue.value',
          ),
  );
}

/// Branch 1 of LiveInputFunctionShellToolParamEnvironmentValue.
@immutable
final class LiveInputFunctionShellToolParamEnvironmentValueBranch1
    extends LiveInputFunctionShellToolParamEnvironmentValue {
  /// Parses and validates the canonical value.
  LiveInputFunctionShellToolParamEnvironmentValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionShellToolParamEnvironmentValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputLocalEnvironmentParam get value =>
      LiveInputLocalEnvironmentParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/LocalEnvironmentParam'},
    rawValue,
    'LiveInputFunctionShellToolParamEnvironmentValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionShellToolParamEnvironmentValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionShellToolParamEnvironmentValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputFunctionShellToolParamEnvironmentValue.value',
          ),
  );
}

/// Branch 2 of LiveInputFunctionShellToolParamEnvironmentValue.
@immutable
final class LiveInputFunctionShellToolParamEnvironmentValueBranch2
    extends LiveInputFunctionShellToolParamEnvironmentValue {
  /// Parses and validates the canonical value.
  LiveInputFunctionShellToolParamEnvironmentValueBranch2.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputFunctionShellToolParamEnvironmentValueBranch2',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputContainerReferenceParam get value =>
      LiveInputContainerReferenceParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ContainerReferenceParam'},
    rawValue,
    'LiveInputFunctionShellToolParamEnvironmentValueBranch2',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputFunctionShellToolParamEnvironmentValueBranch2 copyWith({
    Object? value = liveUnset,
  }) => LiveInputFunctionShellToolParamEnvironmentValueBranch2.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputFunctionShellToolParamEnvironmentValue.value',
          ),
  );
}

/// Typed canonical value GrammarSyntax1.
@immutable
final class LiveInputGrammarSyntax1 extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputGrammarSyntax1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputGrammarSyntax1') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'GrammarSyntax1',
    rawValue,
    'LiveInputGrammarSyntax1',
  );

  /// Parses and validates the canonical value.
  LiveInputGrammarSyntax1 copyWith({Object? value = liveUnset}) =>
      LiveInputGrammarSyntax1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputGrammarSyntax1.value'),
      );
}

/// Typed canonical union Item.
/// Variants: [LiveInputHistoryItemBranch0], [LiveInputHistoryItemBranch1], [LiveInputHistoryItemBranch2], [LiveInputHistoryItemBranch3], [LiveInputHistoryItemBranch4], [LiveInputHistoryItemBranch5], [LiveInputHistoryItemBranch6], [LiveInputHistoryItemBranch7], [LiveInputHistoryItemBranch8], [LiveInputHistoryItemBranch9], [LiveInputHistoryItemBranch10], [LiveInputHistoryItemBranch11], [LiveInputHistoryItemBranch12], [LiveInputHistoryItemBranch13], [LiveInputHistoryItemBranch14], [LiveInputHistoryItemBranch15], [LiveInputHistoryItemBranch16], [LiveInputHistoryItemBranch17], [LiveInputHistoryItemBranch18], [LiveInputHistoryItemBranch19], [LiveInputHistoryItemBranch20], [LiveInputHistoryItemBranch21], [LiveInputHistoryItemBranch22], [LiveInputHistoryItemBranch23], [LiveInputHistoryItemBranch24], [LiveInputHistoryItemBranch25], [LiveInputHistoryItemBranch26], [LiveInputHistoryItemBranch27].
@immutable
sealed class LiveInputHistoryItem extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputHistoryItem();

  /// Parses and validates the canonical value.
  factory LiveInputHistoryItem.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(value, 'LiveInputHistoryItem');
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/InputMessage'},
      {r'$ref': '#/components/schemas/OutputMessage'},
      {r'$ref': '#/components/schemas/FileSearchToolCall'},
      {r'$ref': '#/components/schemas/ComputerToolCall'},
      {r'$ref': '#/components/schemas/ComputerCallOutputItemParam'},
      {r'$ref': '#/components/schemas/WebSearchToolCall'},
      {r'$ref': '#/components/schemas/FunctionToolCall'},
      {r'$ref': '#/components/schemas/FunctionCallOutputItemParam'},
      {r'$ref': '#/components/schemas/ToolSearchCallItemParam'},
      {r'$ref': '#/components/schemas/ToolSearchOutputItemParam'},
      {r'$ref': '#/components/schemas/AdditionalToolsItemParam'},
      {r'$ref': '#/components/schemas/ResponseConfigurationUpdateItemParam'},
      {r'$ref': '#/components/schemas/ReasoningItem'},
      {r'$ref': '#/components/schemas/CompactionSummaryItemParam'},
      {r'$ref': '#/components/schemas/ImageGenToolCall'},
      {r'$ref': '#/components/schemas/CodeInterpreterToolCall'},
      {r'$ref': '#/components/schemas/LocalShellToolCall'},
      {r'$ref': '#/components/schemas/LocalShellToolCallOutput'},
      {r'$ref': '#/components/schemas/FunctionShellCallItemParam'},
      {r'$ref': '#/components/schemas/FunctionShellCallOutputItemParam'},
      {r'$ref': '#/components/schemas/ApplyPatchToolCallItemParam'},
      {r'$ref': '#/components/schemas/ApplyPatchToolCallOutputItemParam'},
      {r'$ref': '#/components/schemas/MCPListTools'},
      {r'$ref': '#/components/schemas/MCPApprovalRequest'},
      {r'$ref': '#/components/schemas/MCPApprovalResponse'},
      {r'$ref': '#/components/schemas/MCPToolCall'},
      {r'$ref': '#/components/schemas/CustomToolCallOutput'},
      {r'$ref': '#/components/schemas/CustomToolCall'},
    ], wireValue);
    if (tagged == 0) return LiveInputHistoryItemBranch0.fromJson(wireValue);
    if (tagged == 1) return LiveInputHistoryItemBranch1.fromJson(wireValue);
    if (tagged == 2) return LiveInputHistoryItemBranch2.fromJson(wireValue);
    if (tagged == 3) return LiveInputHistoryItemBranch3.fromJson(wireValue);
    if (tagged == 4) return LiveInputHistoryItemBranch4.fromJson(wireValue);
    if (tagged == 5) return LiveInputHistoryItemBranch5.fromJson(wireValue);
    if (tagged == 6) return LiveInputHistoryItemBranch6.fromJson(wireValue);
    if (tagged == 7) return LiveInputHistoryItemBranch7.fromJson(wireValue);
    if (tagged == 8) return LiveInputHistoryItemBranch8.fromJson(wireValue);
    if (tagged == 9) return LiveInputHistoryItemBranch9.fromJson(wireValue);
    if (tagged == 10) return LiveInputHistoryItemBranch10.fromJson(wireValue);
    if (tagged == 11) return LiveInputHistoryItemBranch11.fromJson(wireValue);
    if (tagged == 12) return LiveInputHistoryItemBranch12.fromJson(wireValue);
    if (tagged == 13) return LiveInputHistoryItemBranch13.fromJson(wireValue);
    if (tagged == 14) return LiveInputHistoryItemBranch14.fromJson(wireValue);
    if (tagged == 15) return LiveInputHistoryItemBranch15.fromJson(wireValue);
    if (tagged == 16) return LiveInputHistoryItemBranch16.fromJson(wireValue);
    if (tagged == 17) return LiveInputHistoryItemBranch17.fromJson(wireValue);
    if (tagged == 18) return LiveInputHistoryItemBranch18.fromJson(wireValue);
    if (tagged == 19) return LiveInputHistoryItemBranch19.fromJson(wireValue);
    if (tagged == 20) return LiveInputHistoryItemBranch20.fromJson(wireValue);
    if (tagged == 21) return LiveInputHistoryItemBranch21.fromJson(wireValue);
    if (tagged == 22) return LiveInputHistoryItemBranch22.fromJson(wireValue);
    if (tagged == 23) return LiveInputHistoryItemBranch23.fromJson(wireValue);
    if (tagged == 24) return LiveInputHistoryItemBranch24.fromJson(wireValue);
    if (tagged == 25) return LiveInputHistoryItemBranch25.fromJson(wireValue);
    if (tagged == 26) return LiveInputHistoryItemBranch26.fromJson(wireValue);
    if (tagged == 27) return LiveInputHistoryItemBranch27.fromJson(wireValue);
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/InputMessage',
    }, wireValue)) {
      return LiveInputHistoryItemBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/OutputMessage',
    }, wireValue)) {
      return LiveInputHistoryItemBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FileSearchToolCall',
    }, wireValue)) {
      return LiveInputHistoryItemBranch2.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ComputerToolCall',
    }, wireValue)) {
      return LiveInputHistoryItemBranch3.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ComputerCallOutputItemParam',
    }, wireValue)) {
      return LiveInputHistoryItemBranch4.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/WebSearchToolCall',
    }, wireValue)) {
      return LiveInputHistoryItemBranch5.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FunctionToolCall',
    }, wireValue)) {
      return LiveInputHistoryItemBranch6.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FunctionCallOutputItemParam',
    }, wireValue)) {
      return LiveInputHistoryItemBranch7.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ToolSearchCallItemParam',
    }, wireValue)) {
      return LiveInputHistoryItemBranch8.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ToolSearchOutputItemParam',
    }, wireValue)) {
      return LiveInputHistoryItemBranch9.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/AdditionalToolsItemParam',
    }, wireValue)) {
      return LiveInputHistoryItemBranch10.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ResponseConfigurationUpdateItemParam',
    }, wireValue)) {
      return LiveInputHistoryItemBranch11.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ReasoningItem',
    }, wireValue)) {
      return LiveInputHistoryItemBranch12.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CompactionSummaryItemParam',
    }, wireValue)) {
      return LiveInputHistoryItemBranch13.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ImageGenToolCall',
    }, wireValue)) {
      return LiveInputHistoryItemBranch14.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CodeInterpreterToolCall',
    }, wireValue)) {
      return LiveInputHistoryItemBranch15.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/LocalShellToolCall',
    }, wireValue)) {
      return LiveInputHistoryItemBranch16.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/LocalShellToolCallOutput',
    }, wireValue)) {
      return LiveInputHistoryItemBranch17.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FunctionShellCallItemParam',
    }, wireValue)) {
      return LiveInputHistoryItemBranch18.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FunctionShellCallOutputItemParam',
    }, wireValue)) {
      return LiveInputHistoryItemBranch19.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ApplyPatchToolCallItemParam',
    }, wireValue)) {
      return LiveInputHistoryItemBranch20.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ApplyPatchToolCallOutputItemParam',
    }, wireValue)) {
      return LiveInputHistoryItemBranch21.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/MCPListTools',
    }, wireValue)) {
      return LiveInputHistoryItemBranch22.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/MCPApprovalRequest',
    }, wireValue)) {
      return LiveInputHistoryItemBranch23.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/MCPApprovalResponse',
    }, wireValue)) {
      return LiveInputHistoryItemBranch24.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/MCPToolCall',
    }, wireValue)) {
      return LiveInputHistoryItemBranch25.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CustomToolCallOutput',
    }, wireValue)) {
      return LiveInputHistoryItemBranch26.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CustomToolCall',
    }, wireValue)) {
      return LiveInputHistoryItemBranch27.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputHistoryItem: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputHistoryItem copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItem.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 0 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch0 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch0') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputMessage get value => LiveInputMessage.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/InputMessage'},
    rawValue,
    'LiveInputHistoryItemBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch0 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch0.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 1 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch1 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch1') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputOutputMessage get value => LiveInputOutputMessage.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/OutputMessage'},
    rawValue,
    'LiveInputHistoryItemBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch1 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 2 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch2 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch2.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch2') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFileSearchToolCall get value =>
      LiveInputFileSearchToolCall.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FileSearchToolCall'},
    rawValue,
    'LiveInputHistoryItemBranch2',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch2 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch2.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 3 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch3 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch3.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch3') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputComputerToolCall get value =>
      LiveInputComputerToolCall.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ComputerToolCall'},
    rawValue,
    'LiveInputHistoryItemBranch3',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch3 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch3.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 4 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch4 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch4.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch4') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputComputerCallOutputItemParam get value =>
      LiveInputComputerCallOutputItemParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ComputerCallOutputItemParam'},
    rawValue,
    'LiveInputHistoryItemBranch4',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch4 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch4.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 5 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch5 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch5.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch5') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputWebSearchToolCall get value =>
      LiveInputWebSearchToolCall.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/WebSearchToolCall'},
    rawValue,
    'LiveInputHistoryItemBranch5',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch5 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch5.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 6 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch6 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch6.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch6') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFunctionToolCall get value =>
      LiveInputFunctionToolCall.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FunctionToolCall'},
    rawValue,
    'LiveInputHistoryItemBranch6',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch6 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch6.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 7 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch7 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch7.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch7') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFunctionCallOutputItemParam get value =>
      LiveInputFunctionCallOutputItemParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FunctionCallOutputItemParam'},
    rawValue,
    'LiveInputHistoryItemBranch7',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch7 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch7.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 8 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch8 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch8.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch8') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputToolSearchCallItemParam get value =>
      LiveInputToolSearchCallItemParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ToolSearchCallItemParam'},
    rawValue,
    'LiveInputHistoryItemBranch8',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch8 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch8.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 9 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch9 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch9.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch9') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputItemParam get value =>
      LiveInputToolSearchOutputItemParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ToolSearchOutputItemParam'},
    rawValue,
    'LiveInputHistoryItemBranch9',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch9 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch9.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 10 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch10 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch10.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch10') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputAdditionalToolsItemParam get value =>
      LiveInputAdditionalToolsItemParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/AdditionalToolsItemParam'},
    rawValue,
    'LiveInputHistoryItemBranch10',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch10 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch10.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 11 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch11 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch11.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch11') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputResponseConfigurationUpdateItemParam get value =>
      LiveInputResponseConfigurationUpdateItemParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ResponseConfigurationUpdateItemParam'},
    rawValue,
    'LiveInputHistoryItemBranch11',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch11 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch11.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 12 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch12 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch12.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch12') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputReasoningItem get value => LiveInputReasoningItem.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ReasoningItem'},
    rawValue,
    'LiveInputHistoryItemBranch12',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch12 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch12.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 13 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch13 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch13.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch13') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCompactionSummaryItemParam get value =>
      LiveInputCompactionSummaryItemParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CompactionSummaryItemParam'},
    rawValue,
    'LiveInputHistoryItemBranch13',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch13 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch13.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 14 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch14 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch14.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch14') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputImageGenToolCall get value =>
      LiveInputImageGenToolCall.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ImageGenToolCall'},
    rawValue,
    'LiveInputHistoryItemBranch14',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch14 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch14.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 15 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch15 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch15.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch15') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCodeInterpreterToolCall get value =>
      LiveInputCodeInterpreterToolCall.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CodeInterpreterToolCall'},
    rawValue,
    'LiveInputHistoryItemBranch15',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch15 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch15.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 16 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch16 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch16.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch16') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputLocalShellToolCall get value =>
      LiveInputLocalShellToolCall.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/LocalShellToolCall'},
    rawValue,
    'LiveInputHistoryItemBranch16',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch16 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch16.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 17 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch17 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch17.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch17') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputLocalShellToolCallOutput get value =>
      LiveInputLocalShellToolCallOutput.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/LocalShellToolCallOutput'},
    rawValue,
    'LiveInputHistoryItemBranch17',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch17 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch17.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 18 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch18 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch18.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch18') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFunctionShellCallItemParam get value =>
      LiveInputFunctionShellCallItemParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FunctionShellCallItemParam'},
    rawValue,
    'LiveInputHistoryItemBranch18',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch18 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch18.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 19 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch19 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch19.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch19') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFunctionShellCallOutputItemParam get value =>
      LiveInputFunctionShellCallOutputItemParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FunctionShellCallOutputItemParam'},
    rawValue,
    'LiveInputHistoryItemBranch19',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch19 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch19.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 20 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch20 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch20.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch20') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputApplyPatchToolCallItemParam get value =>
      LiveInputApplyPatchToolCallItemParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ApplyPatchToolCallItemParam'},
    rawValue,
    'LiveInputHistoryItemBranch20',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch20 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch20.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 21 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch21 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch21.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch21') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputApplyPatchToolCallOutputItemParam get value =>
      LiveInputApplyPatchToolCallOutputItemParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ApplyPatchToolCallOutputItemParam'},
    rawValue,
    'LiveInputHistoryItemBranch21',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch21 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch21.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 22 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch22 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch22.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch22') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputMCPListTools get value => LiveInputMCPListTools.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/MCPListTools'},
    rawValue,
    'LiveInputHistoryItemBranch22',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch22 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch22.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 23 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch23 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch23.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch23') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputMCPApprovalRequest get value =>
      LiveInputMCPApprovalRequest.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/MCPApprovalRequest'},
    rawValue,
    'LiveInputHistoryItemBranch23',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch23 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch23.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 24 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch24 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch24.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch24') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputMCPApprovalResponse get value =>
      LiveInputMCPApprovalResponse.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/MCPApprovalResponse'},
    rawValue,
    'LiveInputHistoryItemBranch24',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch24 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch24.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 25 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch25 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch25.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch25') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputMCPToolCall get value => LiveInputMCPToolCall.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/MCPToolCall'},
    rawValue,
    'LiveInputHistoryItemBranch25',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch25 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch25.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 26 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch26 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch26.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch26') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCustomToolCallOutput get value =>
      LiveInputCustomToolCallOutput.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CustomToolCallOutput'},
    rawValue,
    'LiveInputHistoryItemBranch26',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch26 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch26.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Branch 27 of LiveInputHistoryItem.
@immutable
final class LiveInputHistoryItemBranch27 extends LiveInputHistoryItem {
  /// Parses and validates the canonical value.
  LiveInputHistoryItemBranch27.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputHistoryItemBranch27') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCustomToolCall get value =>
      LiveInputCustomToolCall.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CustomToolCall'},
    rawValue,
    'LiveInputHistoryItemBranch27',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputHistoryItemBranch27 copyWith({Object? value = liveUnset}) =>
      LiveInputHistoryItemBranch27.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputHistoryItem.value'),
      );
}

/// Typed canonical value ImageBackground.
@immutable
final class LiveInputImageBackground extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputImageBackground.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputImageBackground') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'ImageBackground',
    rawValue,
    'LiveInputImageBackground',
  );

  /// Parses and validates the canonical value.
  LiveInputImageBackground copyWith({Object? value = liveUnset}) =>
      LiveInputImageBackground.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputImageBackground.value'),
      );
}

/// Typed canonical value ImageDetail.
@immutable
final class LiveInputImageDetail extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputImageDetail.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputImageDetail') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() =>
      _validateInputComponent('ImageDetail', rawValue, 'LiveInputImageDetail');

  /// Parses and validates the canonical value.
  LiveInputImageDetail copyWith({Object? value = liveUnset}) =>
      LiveInputImageDetail.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputImageDetail.value'),
      );
}

/// Typed canonical value ImageGenActionEnum.
@immutable
final class LiveInputImageGenActionEnum extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputImageGenActionEnum.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputImageGenActionEnum') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'ImageGenActionEnum',
    rawValue,
    'LiveInputImageGenActionEnum',
  );

  /// Parses and validates the canonical value.
  LiveInputImageGenActionEnum copyWith({Object? value = liveUnset}) =>
      LiveInputImageGenActionEnum.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputImageGenActionEnum.value'),
      );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputImageGenToolCallSizeValueBranch0], [LiveInputImageGenToolCallSizeValueBranch1].
@immutable
sealed class LiveInputImageGenToolCallSizeValue extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputImageGenToolCallSizeValue();

  /// Parses and validates the canonical value.
  factory LiveInputImageGenToolCallSizeValue.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputImageGenToolCallSizeValue',
    );
    final tagged = _inputTaggedBranch([
      {'type': 'string'},
      {
        'enum': ['1024x1024', '1024x1536', '1536x1024'],
        'type': 'string',
      },
    ], wireValue);
    if (tagged == 0) {
      return LiveInputImageGenToolCallSizeValueBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputImageGenToolCallSizeValueBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({'type': 'string'}, wireValue)) {
      return LiveInputImageGenToolCallSizeValueBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      'enum': ['1024x1024', '1024x1536', '1536x1024'],
      'type': 'string',
    }, wireValue)) {
      return LiveInputImageGenToolCallSizeValueBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputImageGenToolCallSizeValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputImageGenToolCallSizeValue copyWith({Object? value = liveUnset}) =>
      LiveInputImageGenToolCallSizeValue.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(
                value,
                context: 'LiveInputImageGenToolCallSizeValue.value',
              ),
      );
}

/// Branch 0 of LiveInputImageGenToolCallSizeValue.
@immutable
final class LiveInputImageGenToolCallSizeValueBranch0
    extends LiveInputImageGenToolCallSizeValue {
  /// Parses and validates the canonical value.
  LiveInputImageGenToolCallSizeValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputImageGenToolCallSizeValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'string'},
    rawValue,
    'LiveInputImageGenToolCallSizeValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputImageGenToolCallSizeValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputImageGenToolCallSizeValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputImageGenToolCallSizeValue.value',
          ),
  );
}

/// Branch 1 of LiveInputImageGenToolCallSizeValue.
@immutable
final class LiveInputImageGenToolCallSizeValueBranch1
    extends LiveInputImageGenToolCallSizeValue {
  /// Parses and validates the canonical value.
  LiveInputImageGenToolCallSizeValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputImageGenToolCallSizeValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {
      'enum': ['1024x1024', '1024x1536', '1536x1024'],
      'type': 'string',
    },
    rawValue,
    'LiveInputImageGenToolCallSizeValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputImageGenToolCallSizeValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputImageGenToolCallSizeValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputImageGenToolCallSizeValue.value',
          ),
  );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputImageGenToolModelValueBranch0], [LiveInputImageGenToolModelValueBranch1].
@immutable
sealed class LiveInputImageGenToolModelValue extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputImageGenToolModelValue();

  /// Parses and validates the canonical value.
  factory LiveInputImageGenToolModelValue.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputImageGenToolModelValue',
    );
    final tagged = _inputTaggedBranch([
      {'type': 'string'},
      {
        'enum': [
          'gpt-image-1',
          'gpt-image-1-mini',
          'gpt-image-1.5',
          'gpt-image-2',
          'gpt-image-2-2026-04-21',
          'gpt-image-2.5-sunburst',
          'gpt-image-2.5-sunburst-2026-09-08',
          'gpt-image-2.5-flare',
          'gpt-image-2.5-flare-2026-09-08',
        ],
        'type': 'string',
      },
    ], wireValue);
    if (tagged == 0) {
      return LiveInputImageGenToolModelValueBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputImageGenToolModelValueBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({'type': 'string'}, wireValue)) {
      return LiveInputImageGenToolModelValueBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      'enum': [
        'gpt-image-1',
        'gpt-image-1-mini',
        'gpt-image-1.5',
        'gpt-image-2',
        'gpt-image-2-2026-04-21',
        'gpt-image-2.5-sunburst',
        'gpt-image-2.5-sunburst-2026-09-08',
        'gpt-image-2.5-flare',
        'gpt-image-2.5-flare-2026-09-08',
      ],
      'type': 'string',
    }, wireValue)) {
      return LiveInputImageGenToolModelValueBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputImageGenToolModelValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputImageGenToolModelValue copyWith({Object? value = liveUnset}) =>
      LiveInputImageGenToolModelValue.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(
                value,
                context: 'LiveInputImageGenToolModelValue.value',
              ),
      );
}

/// Branch 0 of LiveInputImageGenToolModelValue.
@immutable
final class LiveInputImageGenToolModelValueBranch0
    extends LiveInputImageGenToolModelValue {
  /// Parses and validates the canonical value.
  LiveInputImageGenToolModelValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputImageGenToolModelValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'string'},
    rawValue,
    'LiveInputImageGenToolModelValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputImageGenToolModelValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputImageGenToolModelValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(value, context: 'LiveInputImageGenToolModelValue.value'),
  );
}

/// Branch 1 of LiveInputImageGenToolModelValue.
@immutable
final class LiveInputImageGenToolModelValueBranch1
    extends LiveInputImageGenToolModelValue {
  /// Parses and validates the canonical value.
  LiveInputImageGenToolModelValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputImageGenToolModelValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {
      'enum': [
        'gpt-image-1',
        'gpt-image-1-mini',
        'gpt-image-1.5',
        'gpt-image-2',
        'gpt-image-2-2026-04-21',
        'gpt-image-2.5-sunburst',
        'gpt-image-2.5-sunburst-2026-09-08',
        'gpt-image-2.5-flare',
        'gpt-image-2.5-flare-2026-09-08',
      ],
      'type': 'string',
    },
    rawValue,
    'LiveInputImageGenToolModelValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputImageGenToolModelValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputImageGenToolModelValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(value, context: 'LiveInputImageGenToolModelValue.value'),
  );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputImageGenToolSizeValueBranch0], [LiveInputImageGenToolSizeValueBranch1].
@immutable
sealed class LiveInputImageGenToolSizeValue extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputImageGenToolSizeValue();

  /// Parses and validates the canonical value.
  factory LiveInputImageGenToolSizeValue.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputImageGenToolSizeValue',
    );
    final tagged = _inputTaggedBranch([
      {'type': 'string'},
      {
        'enum': ['1024x1024', '1024x1536', '1536x1024', 'auto'],
        'type': 'string',
      },
    ], wireValue);
    if (tagged == 0) {
      return LiveInputImageGenToolSizeValueBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputImageGenToolSizeValueBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({'type': 'string'}, wireValue)) {
      return LiveInputImageGenToolSizeValueBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      'enum': ['1024x1024', '1024x1536', '1536x1024', 'auto'],
      'type': 'string',
    }, wireValue)) {
      return LiveInputImageGenToolSizeValueBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputImageGenToolSizeValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputImageGenToolSizeValue copyWith({Object? value = liveUnset}) =>
      LiveInputImageGenToolSizeValue.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(
                value,
                context: 'LiveInputImageGenToolSizeValue.value',
              ),
      );
}

/// Branch 0 of LiveInputImageGenToolSizeValue.
@immutable
final class LiveInputImageGenToolSizeValueBranch0
    extends LiveInputImageGenToolSizeValue {
  /// Parses and validates the canonical value.
  LiveInputImageGenToolSizeValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputImageGenToolSizeValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'string'},
    rawValue,
    'LiveInputImageGenToolSizeValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputImageGenToolSizeValueBranch0 copyWith({Object? value = liveUnset}) =>
      LiveInputImageGenToolSizeValueBranch0.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(
                value,
                context: 'LiveInputImageGenToolSizeValue.value',
              ),
      );
}

/// Branch 1 of LiveInputImageGenToolSizeValue.
@immutable
final class LiveInputImageGenToolSizeValueBranch1
    extends LiveInputImageGenToolSizeValue {
  /// Parses and validates the canonical value.
  LiveInputImageGenToolSizeValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputImageGenToolSizeValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {
      'enum': ['1024x1024', '1024x1536', '1536x1024', 'auto'],
      'type': 'string',
    },
    rawValue,
    'LiveInputImageGenToolSizeValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputImageGenToolSizeValueBranch1 copyWith({Object? value = liveUnset}) =>
      LiveInputImageGenToolSizeValueBranch1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(
                value,
                context: 'LiveInputImageGenToolSizeValue.value',
              ),
      );
}

/// Typed canonical value ImageOutputFormat.
@immutable
final class LiveInputImageOutputFormat extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputImageOutputFormat.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputImageOutputFormat') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'ImageOutputFormat',
    rawValue,
    'LiveInputImageOutputFormat',
  );

  /// Parses and validates the canonical value.
  LiveInputImageOutputFormat copyWith({Object? value = liveUnset}) =>
      LiveInputImageOutputFormat.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputImageOutputFormat.value'),
      );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputMCPToolAllowedToolsValueBranch0], [LiveInputMCPToolAllowedToolsValueBranch1].
@immutable
sealed class LiveInputMCPToolAllowedToolsValue extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputMCPToolAllowedToolsValue();

  /// Parses and validates the canonical value.
  factory LiveInputMCPToolAllowedToolsValue.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputMCPToolAllowedToolsValue',
    );
    final tagged = _inputTaggedBranch([
      {
        'items': {'type': 'string'},
        'type': 'array',
      },
      {r'$ref': '#/components/schemas/MCPToolFilter'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputMCPToolAllowedToolsValueBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputMCPToolAllowedToolsValueBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      'items': {'type': 'string'},
      'type': 'array',
    }, wireValue)) {
      return LiveInputMCPToolAllowedToolsValueBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/MCPToolFilter',
    }, wireValue)) {
      return LiveInputMCPToolAllowedToolsValueBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputMCPToolAllowedToolsValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputMCPToolAllowedToolsValue copyWith({Object? value = liveUnset}) =>
      LiveInputMCPToolAllowedToolsValue.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(
                value,
                context: 'LiveInputMCPToolAllowedToolsValue.value',
              ),
      );
}

/// Branch 0 of LiveInputMCPToolAllowedToolsValue.
@immutable
final class LiveInputMCPToolAllowedToolsValueBranch0
    extends LiveInputMCPToolAllowedToolsValue {
  /// Parses and validates the canonical value.
  LiveInputMCPToolAllowedToolsValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputMCPToolAllowedToolsValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  List<String> get value =>
      List.unmodifiable((rawValue! as List).map((value) => value as String));
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {
      'items': {'type': 'string'},
      'type': 'array',
    },
    rawValue,
    'LiveInputMCPToolAllowedToolsValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputMCPToolAllowedToolsValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputMCPToolAllowedToolsValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(value, context: 'LiveInputMCPToolAllowedToolsValue.value'),
  );
}

/// Branch 1 of LiveInputMCPToolAllowedToolsValue.
@immutable
final class LiveInputMCPToolAllowedToolsValueBranch1
    extends LiveInputMCPToolAllowedToolsValue {
  /// Parses and validates the canonical value.
  LiveInputMCPToolAllowedToolsValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputMCPToolAllowedToolsValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputMCPToolFilter get value => LiveInputMCPToolFilter.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/MCPToolFilter'},
    rawValue,
    'LiveInputMCPToolAllowedToolsValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputMCPToolAllowedToolsValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputMCPToolAllowedToolsValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(value, context: 'LiveInputMCPToolAllowedToolsValue.value'),
  );
}

/// Typed canonical union MCPToolCallError.
/// Variants: [LiveInputMCPToolCallErrorBranch0], [LiveInputMCPToolCallErrorBranch1], [LiveInputMCPToolCallErrorBranch2].
@immutable
sealed class LiveInputMCPToolCallError extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputMCPToolCallError();

  /// Parses and validates the canonical value.
  factory LiveInputMCPToolCallError.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(value, 'LiveInputMCPToolCallError');
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/MCPProtocolError'},
      {r'$ref': '#/components/schemas/MCPToolExecutionError'},
      {r'$ref': '#/components/schemas/HTTPError'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputMCPToolCallErrorBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputMCPToolCallErrorBranch1.fromJson(wireValue);
    }
    if (tagged == 2) {
      return LiveInputMCPToolCallErrorBranch2.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/MCPProtocolError',
    }, wireValue)) {
      return LiveInputMCPToolCallErrorBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/MCPToolExecutionError',
    }, wireValue)) {
      return LiveInputMCPToolCallErrorBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/HTTPError',
    }, wireValue)) {
      return LiveInputMCPToolCallErrorBranch2.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputMCPToolCallError: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputMCPToolCallError copyWith({Object? value = liveUnset}) =>
      LiveInputMCPToolCallError.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(value, context: 'LiveInputMCPToolCallError.value'),
      );
}

/// Branch 0 of LiveInputMCPToolCallError.
@immutable
final class LiveInputMCPToolCallErrorBranch0 extends LiveInputMCPToolCallError {
  /// Parses and validates the canonical value.
  LiveInputMCPToolCallErrorBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputMCPToolCallErrorBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputMCPProtocolError get value =>
      LiveInputMCPProtocolError.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/MCPProtocolError'},
    rawValue,
    'LiveInputMCPToolCallErrorBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputMCPToolCallErrorBranch0 copyWith({Object? value = liveUnset}) =>
      LiveInputMCPToolCallErrorBranch0.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputMCPToolCallError.value'),
      );
}

/// Branch 1 of LiveInputMCPToolCallError.
@immutable
final class LiveInputMCPToolCallErrorBranch1 extends LiveInputMCPToolCallError {
  /// Parses and validates the canonical value.
  LiveInputMCPToolCallErrorBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputMCPToolCallErrorBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputMCPToolExecutionError get value =>
      LiveInputMCPToolExecutionError.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/MCPToolExecutionError'},
    rawValue,
    'LiveInputMCPToolCallErrorBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputMCPToolCallErrorBranch1 copyWith({Object? value = liveUnset}) =>
      LiveInputMCPToolCallErrorBranch1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputMCPToolCallError.value'),
      );
}

/// Branch 2 of LiveInputMCPToolCallError.
@immutable
final class LiveInputMCPToolCallErrorBranch2 extends LiveInputMCPToolCallError {
  /// Parses and validates the canonical value.
  LiveInputMCPToolCallErrorBranch2.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputMCPToolCallErrorBranch2',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputHTTPError get value => LiveInputHTTPError.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/HTTPError'},
    rawValue,
    'LiveInputMCPToolCallErrorBranch2',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputMCPToolCallErrorBranch2 copyWith({Object? value = liveUnset}) =>
      LiveInputMCPToolCallErrorBranch2.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputMCPToolCallError.value'),
      );
}

/// Typed canonical value MCPToolCallStatus.
@immutable
final class LiveInputMCPToolCallStatus extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputMCPToolCallStatus.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputMCPToolCallStatus') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'MCPToolCallStatus',
    rawValue,
    'LiveInputMCPToolCallStatus',
  );

  /// Parses and validates the canonical value.
  LiveInputMCPToolCallStatus copyWith({Object? value = liveUnset}) =>
      LiveInputMCPToolCallStatus.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputMCPToolCallStatus.value'),
      );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputMCPToolRequireApprovalValueBranch0], [LiveInputMCPToolRequireApprovalValueBranch1].
@immutable
sealed class LiveInputMCPToolRequireApprovalValue extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputMCPToolRequireApprovalValue();

  /// Parses and validates the canonical value.
  factory LiveInputMCPToolRequireApprovalValue.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputMCPToolRequireApprovalValue',
    );
    final tagged = _inputTaggedBranch([
      {
        'additionalProperties': false,
        'properties': {
          'always': {r'$ref': '#/components/schemas/MCPToolFilter'},
          'never': {r'$ref': '#/components/schemas/MCPToolFilter'},
        },
        'type': 'object',
      },
      {
        'enum': ['always', 'never'],
        'type': 'string',
      },
    ], wireValue);
    if (tagged == 0) {
      return LiveInputMCPToolRequireApprovalValueBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputMCPToolRequireApprovalValueBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      'additionalProperties': false,
      'properties': {
        'always': {r'$ref': '#/components/schemas/MCPToolFilter'},
        'never': {r'$ref': '#/components/schemas/MCPToolFilter'},
      },
      'type': 'object',
    }, wireValue)) {
      return LiveInputMCPToolRequireApprovalValueBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      'enum': ['always', 'never'],
      'type': 'string',
    }, wireValue)) {
      return LiveInputMCPToolRequireApprovalValueBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputMCPToolRequireApprovalValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputMCPToolRequireApprovalValue copyWith({Object? value = liveUnset}) =>
      LiveInputMCPToolRequireApprovalValue.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(
                value,
                context: 'LiveInputMCPToolRequireApprovalValue.value',
              ),
      );
}

/// Branch 0 of LiveInputMCPToolRequireApprovalValue.
@immutable
final class LiveInputMCPToolRequireApprovalValueBranch0
    extends LiveInputMCPToolRequireApprovalValue {
  /// Parses and validates the canonical value.
  LiveInputMCPToolRequireApprovalValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputMCPToolRequireApprovalValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputMCPToolRequireApprovalValueBranch0Value get value =>
      LiveInputMCPToolRequireApprovalValueBranch0Value.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {
      'additionalProperties': false,
      'properties': {
        'always': {r'$ref': '#/components/schemas/MCPToolFilter'},
        'never': {r'$ref': '#/components/schemas/MCPToolFilter'},
      },
      'type': 'object',
    },
    rawValue,
    'LiveInputMCPToolRequireApprovalValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputMCPToolRequireApprovalValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputMCPToolRequireApprovalValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputMCPToolRequireApprovalValue.value',
          ),
  );
}

/// Branch 1 of LiveInputMCPToolRequireApprovalValue.
@immutable
final class LiveInputMCPToolRequireApprovalValueBranch1
    extends LiveInputMCPToolRequireApprovalValue {
  /// Parses and validates the canonical value.
  LiveInputMCPToolRequireApprovalValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputMCPToolRequireApprovalValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {
      'enum': ['always', 'never'],
      'type': 'string',
    },
    rawValue,
    'LiveInputMCPToolRequireApprovalValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputMCPToolRequireApprovalValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputMCPToolRequireApprovalValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputMCPToolRequireApprovalValue.value',
          ),
  );
}

/// Typed canonical value InputMessageContentList.
@immutable
final class LiveInputMessageContentList extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputMessageContentList.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputMessageContentList') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  List<LiveInputContent> get value =>
      List.unmodifiable((rawValue! as List).map(LiveInputContent.fromJson));
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'InputMessageContentList',
    rawValue,
    'LiveInputMessageContentList',
  );

  /// Parses and validates the canonical value.
  LiveInputMessageContentList copyWith({Object? value = liveUnset}) =>
      LiveInputMessageContentList.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputMessageContentList.value'),
      );
}

/// Typed canonical value MessagePhase.
@immutable
final class LiveInputMessagePhase extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputMessagePhase.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputMessagePhase') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'MessagePhase',
    rawValue,
    'LiveInputMessagePhase',
  );

  /// Parses and validates the canonical value.
  LiveInputMessagePhase copyWith({Object? value = liveUnset}) =>
      LiveInputMessagePhase.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputMessagePhase.value'),
      );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputNamespaceToolParamToolsItemValueBranch0], [LiveInputNamespaceToolParamToolsItemValueBranch1].
@immutable
sealed class LiveInputNamespaceToolParamToolsItemValue extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputNamespaceToolParamToolsItemValue();

  /// Parses and validates the canonical value.
  factory LiveInputNamespaceToolParamToolsItemValue.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputNamespaceToolParamToolsItemValue',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/FunctionToolParam'},
      {r'$ref': '#/components/schemas/CustomToolParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputNamespaceToolParamToolsItemValueBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputNamespaceToolParamToolsItemValueBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FunctionToolParam',
    }, wireValue)) {
      return LiveInputNamespaceToolParamToolsItemValueBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CustomToolParam',
    }, wireValue)) {
      return LiveInputNamespaceToolParamToolsItemValueBranch1.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputNamespaceToolParamToolsItemValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputNamespaceToolParamToolsItemValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputNamespaceToolParamToolsItemValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context: 'LiveInputNamespaceToolParamToolsItemValue.value',
          ),
  );
}

/// Branch 0 of LiveInputNamespaceToolParamToolsItemValue.
@immutable
final class LiveInputNamespaceToolParamToolsItemValueBranch0
    extends LiveInputNamespaceToolParamToolsItemValue {
  /// Parses and validates the canonical value.
  LiveInputNamespaceToolParamToolsItemValueBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputNamespaceToolParamToolsItemValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFunctionToolParam get value =>
      LiveInputFunctionToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FunctionToolParam'},
    rawValue,
    'LiveInputNamespaceToolParamToolsItemValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputNamespaceToolParamToolsItemValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputNamespaceToolParamToolsItemValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputNamespaceToolParamToolsItemValue.value',
          ),
  );
}

/// Branch 1 of LiveInputNamespaceToolParamToolsItemValue.
@immutable
final class LiveInputNamespaceToolParamToolsItemValueBranch1
    extends LiveInputNamespaceToolParamToolsItemValue {
  /// Parses and validates the canonical value.
  LiveInputNamespaceToolParamToolsItemValueBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputNamespaceToolParamToolsItemValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCustomToolParam get value =>
      LiveInputCustomToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CustomToolParam'},
    rawValue,
    'LiveInputNamespaceToolParamToolsItemValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputNamespaceToolParamToolsItemValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputNamespaceToolParamToolsItemValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputNamespaceToolParamToolsItemValue.value',
          ),
  );
}

/// Typed canonical union OutputMessageContent.
/// Variants: [LiveInputOutputMessageContentBranch0], [LiveInputOutputMessageContentBranch1].
@immutable
sealed class LiveInputOutputMessageContent extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputOutputMessageContent();

  /// Parses and validates the canonical value.
  factory LiveInputOutputMessageContent.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputOutputMessageContent',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/OutputTextContent'},
      {r'$ref': '#/components/schemas/RefusalContent'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputOutputMessageContentBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputOutputMessageContentBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/OutputTextContent',
    }, wireValue)) {
      return LiveInputOutputMessageContentBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/RefusalContent',
    }, wireValue)) {
      return LiveInputOutputMessageContentBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputOutputMessageContent: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputOutputMessageContent copyWith({Object? value = liveUnset}) =>
      LiveInputOutputMessageContent.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(value, context: 'LiveInputOutputMessageContent.value'),
      );
}

/// Branch 0 of LiveInputOutputMessageContent.
@immutable
final class LiveInputOutputMessageContentBranch0
    extends LiveInputOutputMessageContent {
  /// Parses and validates the canonical value.
  LiveInputOutputMessageContentBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputOutputMessageContentBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputOutputTextContent get value =>
      LiveInputOutputTextContent.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/OutputTextContent'},
    rawValue,
    'LiveInputOutputMessageContentBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputOutputMessageContentBranch0 copyWith({Object? value = liveUnset}) =>
      LiveInputOutputMessageContentBranch0.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputOutputMessageContent.value'),
      );
}

/// Branch 1 of LiveInputOutputMessageContent.
@immutable
final class LiveInputOutputMessageContentBranch1
    extends LiveInputOutputMessageContent {
  /// Parses and validates the canonical value.
  LiveInputOutputMessageContentBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputOutputMessageContentBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputRefusalContent get value =>
      LiveInputRefusalContent.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/RefusalContent'},
    rawValue,
    'LiveInputOutputMessageContentBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputOutputMessageContentBranch1 copyWith({Object? value = liveUnset}) =>
      LiveInputOutputMessageContentBranch1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputOutputMessageContent.value'),
      );
}

/// Typed canonical value ProgramOutputItemStatus.
@immutable
final class LiveInputProgramOutputItemStatus extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputProgramOutputItemStatus.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputProgramOutputItemStatus',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'ProgramOutputItemStatus',
    rawValue,
    'LiveInputProgramOutputItemStatus',
  );

  /// Parses and validates the canonical value.
  LiveInputProgramOutputItemStatus copyWith({Object? value = liveUnset}) =>
      LiveInputProgramOutputItemStatus.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(
                value,
                context: 'LiveInputProgramOutputItemStatus.value',
              ),
      );
}

/// Typed canonical value RankerVersionType.
@immutable
final class LiveInputRankerVersionType extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputRankerVersionType.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputRankerVersionType') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'RankerVersionType',
    rawValue,
    'LiveInputRankerVersionType',
  );

  /// Parses and validates the canonical value.
  LiveInputRankerVersionType copyWith({Object? value = liveUnset}) =>
      LiveInputRankerVersionType.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputRankerVersionType.value'),
      );
}

/// Typed canonical union ReasoningEffort.
/// Variants: [LiveInputReasoningEffortBranch0], [LiveInputReasoningEffortBranch1].
@immutable
sealed class LiveInputReasoningEffort extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputReasoningEffort();

  /// Parses and validates the canonical value.
  factory LiveInputReasoningEffort.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(value, 'LiveInputReasoningEffort');
    final tagged = _inputTaggedBranch([
      {
        'enum': ['none', 'minimal', 'low', 'medium', 'high', 'xhigh', 'max'],
        'type': 'string',
      },
      {'type': 'null'},
    ], wireValue);
    if (tagged == 0) return LiveInputReasoningEffortBranch0.fromJson(wireValue);
    if (tagged == 1) return LiveInputReasoningEffortBranch1.fromJson(wireValue);
    if (_matchesInputSchema({
      'enum': ['none', 'minimal', 'low', 'medium', 'high', 'xhigh', 'max'],
      'type': 'string',
    }, wireValue)) {
      return LiveInputReasoningEffortBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({'type': 'null'}, wireValue)) {
      return LiveInputReasoningEffortBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputReasoningEffort: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputReasoningEffort copyWith({Object? value = liveUnset}) =>
      LiveInputReasoningEffort.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(value, context: 'LiveInputReasoningEffort.value'),
      );
}

/// Branch 0 of LiveInputReasoningEffort.
@immutable
final class LiveInputReasoningEffortBranch0 extends LiveInputReasoningEffort {
  /// Parses and validates the canonical value.
  LiveInputReasoningEffortBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputReasoningEffortBranch0') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {
      'enum': ['none', 'minimal', 'low', 'medium', 'high', 'xhigh', 'max'],
      'type': 'string',
    },
    rawValue,
    'LiveInputReasoningEffortBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputReasoningEffortBranch0 copyWith({Object? value = liveUnset}) =>
      LiveInputReasoningEffortBranch0.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputReasoningEffort.value'),
      );
}

/// Branch 1 of LiveInputReasoningEffort.
@immutable
final class LiveInputReasoningEffortBranch1 extends LiveInputReasoningEffort {
  /// Parses and validates the canonical value.
  LiveInputReasoningEffortBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputReasoningEffortBranch1') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  Object? get value => rawValue;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'null'},
    rawValue,
    'LiveInputReasoningEffortBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputReasoningEffortBranch1 copyWith({Object? value = liveUnset}) =>
      LiveInputReasoningEffortBranch1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputReasoningEffort.value'),
      );
}

/// Typed canonical value SearchContentType.
@immutable
final class LiveInputSearchContentType extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputSearchContentType.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputSearchContentType') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'SearchContentType',
    rawValue,
    'LiveInputSearchContentType',
  );

  /// Parses and validates the canonical value.
  LiveInputSearchContentType copyWith({Object? value = liveUnset}) =>
      LiveInputSearchContentType.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputSearchContentType.value'),
      );
}

/// Typed canonical value SearchContextSize.
@immutable
final class LiveInputSearchContextSize extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputSearchContextSize.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputSearchContextSize') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'SearchContextSize',
    rawValue,
    'LiveInputSearchContextSize',
  );

  /// Parses and validates the canonical value.
  LiveInputSearchContextSize copyWith({Object? value = liveUnset}) =>
      LiveInputSearchContextSize.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputSearchContextSize.value'),
      );
}

/// Typed canonical union Tool.
/// Variants: [LiveInputToolBranch0], [LiveInputToolBranch1], [LiveInputToolBranch2], [LiveInputToolBranch3], [LiveInputToolBranch4], [LiveInputToolBranch5], [LiveInputToolBranch6], [LiveInputToolBranch7], [LiveInputToolBranch8], [LiveInputToolBranch9], [LiveInputToolBranch10], [LiveInputToolBranch11], [LiveInputToolBranch12], [LiveInputToolBranch13], [LiveInputToolBranch14], [LiveInputToolBranch15].
@immutable
sealed class LiveInputTool extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputTool();

  /// Parses and validates the canonical value.
  factory LiveInputTool.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(value, 'LiveInputTool');
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/FunctionTool'},
      {r'$ref': '#/components/schemas/FileSearchTool'},
      {r'$ref': '#/components/schemas/ComputerTool'},
      {r'$ref': '#/components/schemas/ComputerUsePreviewTool'},
      {r'$ref': '#/components/schemas/WebSearchTool'},
      {r'$ref': '#/components/schemas/MCPTool'},
      {r'$ref': '#/components/schemas/CodeInterpreterTool'},
      {r'$ref': '#/components/schemas/ProgrammaticToolCallingParam'},
      {r'$ref': '#/components/schemas/ImageGenTool'},
      {r'$ref': '#/components/schemas/LocalShellToolParam'},
      {r'$ref': '#/components/schemas/FunctionShellToolParam'},
      {r'$ref': '#/components/schemas/CustomToolParam'},
      {r'$ref': '#/components/schemas/NamespaceToolParam'},
      {r'$ref': '#/components/schemas/ToolSearchToolParam'},
      {r'$ref': '#/components/schemas/WebSearchPreviewTool'},
      {r'$ref': '#/components/schemas/ApplyPatchToolParam'},
    ], wireValue);
    if (tagged == 0) return LiveInputToolBranch0.fromJson(wireValue);
    if (tagged == 1) return LiveInputToolBranch1.fromJson(wireValue);
    if (tagged == 2) return LiveInputToolBranch2.fromJson(wireValue);
    if (tagged == 3) return LiveInputToolBranch3.fromJson(wireValue);
    if (tagged == 4) return LiveInputToolBranch4.fromJson(wireValue);
    if (tagged == 5) return LiveInputToolBranch5.fromJson(wireValue);
    if (tagged == 6) return LiveInputToolBranch6.fromJson(wireValue);
    if (tagged == 7) return LiveInputToolBranch7.fromJson(wireValue);
    if (tagged == 8) return LiveInputToolBranch8.fromJson(wireValue);
    if (tagged == 9) return LiveInputToolBranch9.fromJson(wireValue);
    if (tagged == 10) return LiveInputToolBranch10.fromJson(wireValue);
    if (tagged == 11) return LiveInputToolBranch11.fromJson(wireValue);
    if (tagged == 12) return LiveInputToolBranch12.fromJson(wireValue);
    if (tagged == 13) return LiveInputToolBranch13.fromJson(wireValue);
    if (tagged == 14) return LiveInputToolBranch14.fromJson(wireValue);
    if (tagged == 15) return LiveInputToolBranch15.fromJson(wireValue);
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FunctionTool',
    }, wireValue)) {
      return LiveInputToolBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FileSearchTool',
    }, wireValue)) {
      return LiveInputToolBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ComputerTool',
    }, wireValue)) {
      return LiveInputToolBranch2.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ComputerUsePreviewTool',
    }, wireValue)) {
      return LiveInputToolBranch3.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/WebSearchTool',
    }, wireValue)) {
      return LiveInputToolBranch4.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/MCPTool',
    }, wireValue)) {
      return LiveInputToolBranch5.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CodeInterpreterTool',
    }, wireValue)) {
      return LiveInputToolBranch6.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ProgrammaticToolCallingParam',
    }, wireValue)) {
      return LiveInputToolBranch7.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ImageGenTool',
    }, wireValue)) {
      return LiveInputToolBranch8.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/LocalShellToolParam',
    }, wireValue)) {
      return LiveInputToolBranch9.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FunctionShellToolParam',
    }, wireValue)) {
      return LiveInputToolBranch10.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CustomToolParam',
    }, wireValue)) {
      return LiveInputToolBranch11.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/NamespaceToolParam',
    }, wireValue)) {
      return LiveInputToolBranch12.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ToolSearchToolParam',
    }, wireValue)) {
      return LiveInputToolBranch13.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/WebSearchPreviewTool',
    }, wireValue)) {
      return LiveInputToolBranch14.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ApplyPatchToolParam',
    }, wireValue)) {
      return LiveInputToolBranch15.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputTool: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputTool copyWith({Object? value = liveUnset}) => LiveInputTool.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(value, context: 'LiveInputTool.value'),
  );
}

/// Branch 0 of LiveInputTool.
@immutable
final class LiveInputToolBranch0 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch0') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFunctionTool get value => LiveInputFunctionTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FunctionTool'},
    rawValue,
    'LiveInputToolBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch0 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch0.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 1 of LiveInputTool.
@immutable
final class LiveInputToolBranch1 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch1') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFileSearchTool get value =>
      LiveInputFileSearchTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FileSearchTool'},
    rawValue,
    'LiveInputToolBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch1 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 2 of LiveInputTool.
@immutable
final class LiveInputToolBranch2 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch2.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch2') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputComputerTool get value => LiveInputComputerTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ComputerTool'},
    rawValue,
    'LiveInputToolBranch2',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch2 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch2.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 3 of LiveInputTool.
@immutable
final class LiveInputToolBranch3 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch3.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch3') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputComputerUsePreviewTool get value =>
      LiveInputComputerUsePreviewTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ComputerUsePreviewTool'},
    rawValue,
    'LiveInputToolBranch3',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch3 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch3.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 4 of LiveInputTool.
@immutable
final class LiveInputToolBranch4 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch4.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch4') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputWebSearchTool get value => LiveInputWebSearchTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/WebSearchTool'},
    rawValue,
    'LiveInputToolBranch4',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch4 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch4.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 5 of LiveInputTool.
@immutable
final class LiveInputToolBranch5 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch5.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch5') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputMCPTool get value => LiveInputMCPTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/MCPTool'},
    rawValue,
    'LiveInputToolBranch5',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch5 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch5.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 6 of LiveInputTool.
@immutable
final class LiveInputToolBranch6 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch6.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch6') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCodeInterpreterTool get value =>
      LiveInputCodeInterpreterTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CodeInterpreterTool'},
    rawValue,
    'LiveInputToolBranch6',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch6 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch6.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 7 of LiveInputTool.
@immutable
final class LiveInputToolBranch7 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch7.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch7') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputProgrammaticToolCallingParam get value =>
      LiveInputProgrammaticToolCallingParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ProgrammaticToolCallingParam'},
    rawValue,
    'LiveInputToolBranch7',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch7 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch7.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 8 of LiveInputTool.
@immutable
final class LiveInputToolBranch8 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch8.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch8') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputImageGenTool get value => LiveInputImageGenTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ImageGenTool'},
    rawValue,
    'LiveInputToolBranch8',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch8 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch8.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 9 of LiveInputTool.
@immutable
final class LiveInputToolBranch9 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch9.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch9') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputLocalShellToolParam get value =>
      LiveInputLocalShellToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/LocalShellToolParam'},
    rawValue,
    'LiveInputToolBranch9',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch9 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch9.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 10 of LiveInputTool.
@immutable
final class LiveInputToolBranch10 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch10.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch10') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFunctionShellToolParam get value =>
      LiveInputFunctionShellToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FunctionShellToolParam'},
    rawValue,
    'LiveInputToolBranch10',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch10 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch10.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 11 of LiveInputTool.
@immutable
final class LiveInputToolBranch11 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch11.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch11') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCustomToolParam get value =>
      LiveInputCustomToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CustomToolParam'},
    rawValue,
    'LiveInputToolBranch11',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch11 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch11.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 12 of LiveInputTool.
@immutable
final class LiveInputToolBranch12 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch12.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch12') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputNamespaceToolParam get value =>
      LiveInputNamespaceToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/NamespaceToolParam'},
    rawValue,
    'LiveInputToolBranch12',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch12 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch12.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 13 of LiveInputTool.
@immutable
final class LiveInputToolBranch13 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch13.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch13') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputToolSearchToolParam get value =>
      LiveInputToolSearchToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ToolSearchToolParam'},
    rawValue,
    'LiveInputToolBranch13',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch13 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch13.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 14 of LiveInputTool.
@immutable
final class LiveInputToolBranch14 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch14.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch14') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputWebSearchPreviewTool get value =>
      LiveInputWebSearchPreviewTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/WebSearchPreviewTool'},
    rawValue,
    'LiveInputToolBranch14',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch14 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch14.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Branch 15 of LiveInputTool.
@immutable
final class LiveInputToolBranch15 extends LiveInputTool {
  /// Parses and validates the canonical value.
  LiveInputToolBranch15.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolBranch15') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputApplyPatchToolParam get value =>
      LiveInputApplyPatchToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ApplyPatchToolParam'},
    rawValue,
    'LiveInputToolBranch15',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolBranch15 copyWith({Object? value = liveUnset}) =>
      LiveInputToolBranch15.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputTool.value'),
      );
}

/// Typed canonical union ToolCallCaller.
/// Variants: [LiveInputToolCallCallerBranch0], [LiveInputToolCallCallerBranch1].
@immutable
sealed class LiveInputToolCallCaller extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputToolCallCaller();

  /// Parses and validates the canonical value.
  factory LiveInputToolCallCaller.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(value, 'LiveInputToolCallCaller');
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/DirectToolCallCaller'},
      {r'$ref': '#/components/schemas/ProgramToolCallCaller'},
    ], wireValue);
    if (tagged == 0) return LiveInputToolCallCallerBranch0.fromJson(wireValue);
    if (tagged == 1) return LiveInputToolCallCallerBranch1.fromJson(wireValue);
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/DirectToolCallCaller',
    }, wireValue)) {
      return LiveInputToolCallCallerBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ProgramToolCallCaller',
    }, wireValue)) {
      return LiveInputToolCallCallerBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputToolCallCaller: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputToolCallCaller copyWith({Object? value = liveUnset}) =>
      LiveInputToolCallCaller.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(value, context: 'LiveInputToolCallCaller.value'),
      );
}

/// Branch 0 of LiveInputToolCallCaller.
@immutable
final class LiveInputToolCallCallerBranch0 extends LiveInputToolCallCaller {
  /// Parses and validates the canonical value.
  LiveInputToolCallCallerBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolCallCallerBranch0') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputDirectToolCallCaller get value =>
      LiveInputDirectToolCallCaller.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/DirectToolCallCaller'},
    rawValue,
    'LiveInputToolCallCallerBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolCallCallerBranch0 copyWith({Object? value = liveUnset}) =>
      LiveInputToolCallCallerBranch0.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolCallCaller.value'),
      );
}

/// Branch 1 of LiveInputToolCallCaller.
@immutable
final class LiveInputToolCallCallerBranch1 extends LiveInputToolCallCaller {
  /// Parses and validates the canonical value.
  LiveInputToolCallCallerBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputToolCallCallerBranch1') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputProgramToolCallCaller get value =>
      LiveInputProgramToolCallCaller.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ProgramToolCallCaller'},
    rawValue,
    'LiveInputToolCallCallerBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolCallCallerBranch1 copyWith({Object? value = liveUnset}) =>
      LiveInputToolCallCallerBranch1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolCallCaller.value'),
      );
}

/// Typed canonical union ToolCallCallerParam.
/// Variants: [LiveInputToolCallCallerParamBranch0], [LiveInputToolCallCallerParamBranch1].
@immutable
sealed class LiveInputToolCallCallerParam extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputToolCallCallerParam();

  /// Parses and validates the canonical value.
  factory LiveInputToolCallCallerParam.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputToolCallCallerParam',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/DirectToolCallCallerParam'},
      {r'$ref': '#/components/schemas/ProgramToolCallCallerParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputToolCallCallerParamBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputToolCallCallerParamBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/DirectToolCallCallerParam',
    }, wireValue)) {
      return LiveInputToolCallCallerParamBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ProgramToolCallCallerParam',
    }, wireValue)) {
      return LiveInputToolCallCallerParamBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputToolCallCallerParam: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputToolCallCallerParam copyWith({Object? value = liveUnset}) =>
      LiveInputToolCallCallerParam.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(value, context: 'LiveInputToolCallCallerParam.value'),
      );
}

/// Branch 0 of LiveInputToolCallCallerParam.
@immutable
final class LiveInputToolCallCallerParamBranch0
    extends LiveInputToolCallCallerParam {
  /// Parses and validates the canonical value.
  LiveInputToolCallCallerParamBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolCallCallerParamBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputDirectToolCallCallerParam get value =>
      LiveInputDirectToolCallCallerParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/DirectToolCallCallerParam'},
    rawValue,
    'LiveInputToolCallCallerParamBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolCallCallerParamBranch0 copyWith({Object? value = liveUnset}) =>
      LiveInputToolCallCallerParamBranch0.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolCallCallerParam.value'),
      );
}

/// Branch 1 of LiveInputToolCallCallerParam.
@immutable
final class LiveInputToolCallCallerParamBranch1
    extends LiveInputToolCallCallerParam {
  /// Parses and validates the canonical value.
  LiveInputToolCallCallerParamBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolCallCallerParamBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputProgramToolCallCallerParam get value =>
      LiveInputProgramToolCallCallerParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ProgramToolCallCallerParam'},
    rawValue,
    'LiveInputToolCallCallerParamBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolCallCallerParamBranch1 copyWith({Object? value = liveUnset}) =>
      LiveInputToolCallCallerParamBranch1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolCallCallerParam.value'),
      );
}

/// Typed canonical value ToolSearchExecutionType.
@immutable
final class LiveInputToolSearchExecutionType extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputToolSearchExecutionType.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchExecutionType',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'ToolSearchExecutionType',
    rawValue,
    'LiveInputToolSearchExecutionType',
  );

  /// Parses and validates the canonical value.
  LiveInputToolSearchExecutionType copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchExecutionType.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(
                value,
                context: 'LiveInputToolSearchExecutionType.value',
              ),
      );
}

/// Typed canonical union inline value.
/// Variants: [LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0], [LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1].
@immutable
sealed class LiveInputToolSearchOutputNamespaceToolParamToolsItemValue
    extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputToolSearchOutputNamespaceToolParamToolsItemValue();

  /// Parses and validates the canonical value.
  factory LiveInputToolSearchOutputNamespaceToolParamToolsItemValue.fromJson(
    Object? value,
  ) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputToolSearchOutputNamespaceToolParamToolsItemValue',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/ToolSearchOutputFunctionToolParam'},
      {r'$ref': '#/components/schemas/CustomToolParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0.fromJson(
        wireValue,
      );
    }
    if (tagged == 1) {
      return LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ToolSearchOutputFunctionToolParam',
    }, wireValue)) {
      return LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0.fromJson(
        wireValue,
      );
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CustomToolParam',
    }, wireValue)) {
      return LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1.fromJson(
        wireValue,
      );
    }
    throw const FormatException(
      'LiveInputToolSearchOutputNamespaceToolParamToolsItemValue: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputToolSearchOutputNamespaceToolParamToolsItemValue copyWith({
    Object? value = liveUnset,
  }) => LiveInputToolSearchOutputNamespaceToolParamToolsItemValue.fromJson(
    identical(value, liveUnset)
        ? toJson()
        : _inputWire(
            value,
            context:
                'LiveInputToolSearchOutputNamespaceToolParamToolsItemValue.value',
          ),
  );
}

/// Branch 0 of LiveInputToolSearchOutputNamespaceToolParamToolsItemValue.
@immutable
final class LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0
    extends LiveInputToolSearchOutputNamespaceToolParamToolsItemValue {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0.fromJson(
    Object? value,
  ) : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputFunctionToolParam get value =>
      LiveInputToolSearchOutputFunctionToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ToolSearchOutputFunctionToolParam'},
    rawValue,
    'LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context:
                'LiveInputToolSearchOutputNamespaceToolParamToolsItemValue.value',
          ),
  );
}

/// Branch 1 of LiveInputToolSearchOutputNamespaceToolParamToolsItemValue.
@immutable
final class LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1
    extends LiveInputToolSearchOutputNamespaceToolParamToolsItemValue {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1.fromJson(
    Object? value,
  ) : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCustomToolParam get value =>
      LiveInputCustomToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CustomToolParam'},
    rawValue,
    'LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputToolSearchOutputNamespaceToolParamToolsItemValueBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context:
                'LiveInputToolSearchOutputNamespaceToolParamToolsItemValue.value',
          ),
  );
}

/// Typed canonical union ToolSearchOutputTool.
/// Variants: [LiveInputToolSearchOutputToolBranch0], [LiveInputToolSearchOutputToolBranch1], [LiveInputToolSearchOutputToolBranch2], [LiveInputToolSearchOutputToolBranch3], [LiveInputToolSearchOutputToolBranch4], [LiveInputToolSearchOutputToolBranch5], [LiveInputToolSearchOutputToolBranch6], [LiveInputToolSearchOutputToolBranch7], [LiveInputToolSearchOutputToolBranch8], [LiveInputToolSearchOutputToolBranch9], [LiveInputToolSearchOutputToolBranch10], [LiveInputToolSearchOutputToolBranch11], [LiveInputToolSearchOutputToolBranch12], [LiveInputToolSearchOutputToolBranch13], [LiveInputToolSearchOutputToolBranch14], [LiveInputToolSearchOutputToolBranch15].
@immutable
sealed class LiveInputToolSearchOutputTool extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputToolSearchOutputTool();

  /// Parses and validates the canonical value.
  factory LiveInputToolSearchOutputTool.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputToolSearchOutputTool',
    );
    final tagged = _inputTaggedBranch([
      {r'$ref': '#/components/schemas/FunctionTool'},
      {r'$ref': '#/components/schemas/FileSearchTool'},
      {r'$ref': '#/components/schemas/ComputerTool'},
      {r'$ref': '#/components/schemas/ComputerUsePreviewTool'},
      {r'$ref': '#/components/schemas/WebSearchTool'},
      {r'$ref': '#/components/schemas/MCPTool'},
      {r'$ref': '#/components/schemas/CodeInterpreterTool'},
      {r'$ref': '#/components/schemas/ProgrammaticToolCallingParam'},
      {r'$ref': '#/components/schemas/ImageGenTool'},
      {r'$ref': '#/components/schemas/LocalShellToolParam'},
      {r'$ref': '#/components/schemas/FunctionShellToolParam'},
      {r'$ref': '#/components/schemas/CustomToolParam'},
      {r'$ref': '#/components/schemas/ToolSearchOutputNamespaceToolParam'},
      {r'$ref': '#/components/schemas/ToolSearchToolParam'},
      {r'$ref': '#/components/schemas/WebSearchPreviewTool'},
      {r'$ref': '#/components/schemas/ApplyPatchToolParam'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputToolSearchOutputToolBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputToolSearchOutputToolBranch1.fromJson(wireValue);
    }
    if (tagged == 2) {
      return LiveInputToolSearchOutputToolBranch2.fromJson(wireValue);
    }
    if (tagged == 3) {
      return LiveInputToolSearchOutputToolBranch3.fromJson(wireValue);
    }
    if (tagged == 4) {
      return LiveInputToolSearchOutputToolBranch4.fromJson(wireValue);
    }
    if (tagged == 5) {
      return LiveInputToolSearchOutputToolBranch5.fromJson(wireValue);
    }
    if (tagged == 6) {
      return LiveInputToolSearchOutputToolBranch6.fromJson(wireValue);
    }
    if (tagged == 7) {
      return LiveInputToolSearchOutputToolBranch7.fromJson(wireValue);
    }
    if (tagged == 8) {
      return LiveInputToolSearchOutputToolBranch8.fromJson(wireValue);
    }
    if (tagged == 9) {
      return LiveInputToolSearchOutputToolBranch9.fromJson(wireValue);
    }
    if (tagged == 10) {
      return LiveInputToolSearchOutputToolBranch10.fromJson(wireValue);
    }
    if (tagged == 11) {
      return LiveInputToolSearchOutputToolBranch11.fromJson(wireValue);
    }
    if (tagged == 12) {
      return LiveInputToolSearchOutputToolBranch12.fromJson(wireValue);
    }
    if (tagged == 13) {
      return LiveInputToolSearchOutputToolBranch13.fromJson(wireValue);
    }
    if (tagged == 14) {
      return LiveInputToolSearchOutputToolBranch14.fromJson(wireValue);
    }
    if (tagged == 15) {
      return LiveInputToolSearchOutputToolBranch15.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FunctionTool',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FileSearchTool',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ComputerTool',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch2.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ComputerUsePreviewTool',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch3.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/WebSearchTool',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch4.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/MCPTool',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch5.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CodeInterpreterTool',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch6.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ProgrammaticToolCallingParam',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch7.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ImageGenTool',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch8.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/LocalShellToolParam',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch9.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/FunctionShellToolParam',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch10.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/CustomToolParam',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch11.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ToolSearchOutputNamespaceToolParam',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch12.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ToolSearchToolParam',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch13.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/WebSearchPreviewTool',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch14.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      r'$ref': '#/components/schemas/ApplyPatchToolParam',
    }, wireValue)) {
      return LiveInputToolSearchOutputToolBranch15.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputToolSearchOutputTool: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputToolSearchOutputTool copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputTool.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 0 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch0
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFunctionTool get value => LiveInputFunctionTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FunctionTool'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch0 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch0.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 1 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch1
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFileSearchTool get value =>
      LiveInputFileSearchTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FileSearchTool'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch1 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch1.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 2 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch2
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch2.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch2',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputComputerTool get value => LiveInputComputerTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ComputerTool'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch2',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch2 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch2.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 3 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch3
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch3.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch3',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputComputerUsePreviewTool get value =>
      LiveInputComputerUsePreviewTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ComputerUsePreviewTool'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch3',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch3 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch3.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 4 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch4
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch4.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch4',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputWebSearchTool get value => LiveInputWebSearchTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/WebSearchTool'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch4',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch4 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch4.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 5 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch5
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch5.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch5',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputMCPTool get value => LiveInputMCPTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/MCPTool'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch5',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch5 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch5.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 6 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch6
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch6.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch6',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCodeInterpreterTool get value =>
      LiveInputCodeInterpreterTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CodeInterpreterTool'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch6',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch6 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch6.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 7 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch7
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch7.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch7',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputProgrammaticToolCallingParam get value =>
      LiveInputProgrammaticToolCallingParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ProgrammaticToolCallingParam'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch7',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch7 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch7.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 8 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch8
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch8.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch8',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputImageGenTool get value => LiveInputImageGenTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ImageGenTool'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch8',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch8 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch8.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 9 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch9
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch9.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch9',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputLocalShellToolParam get value =>
      LiveInputLocalShellToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/LocalShellToolParam'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch9',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch9 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch9.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 10 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch10
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch10.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch10',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputFunctionShellToolParam get value =>
      LiveInputFunctionShellToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/FunctionShellToolParam'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch10',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch10 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch10.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 11 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch11
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch11.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch11',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputCustomToolParam get value =>
      LiveInputCustomToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/CustomToolParam'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch11',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch11 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch11.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 12 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch12
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch12.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch12',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputNamespaceToolParam get value =>
      LiveInputToolSearchOutputNamespaceToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ToolSearchOutputNamespaceToolParam'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch12',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch12 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch12.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 13 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch13
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch13.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch13',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputToolSearchToolParam get value =>
      LiveInputToolSearchToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ToolSearchToolParam'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch13',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch13 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch13.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 14 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch14
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch14.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch14',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputWebSearchPreviewTool get value =>
      LiveInputWebSearchPreviewTool.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/WebSearchPreviewTool'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch14',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch14 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch14.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Branch 15 of LiveInputToolSearchOutputTool.
@immutable
final class LiveInputToolSearchOutputToolBranch15
    extends LiveInputToolSearchOutputTool {
  /// Parses and validates the canonical value.
  LiveInputToolSearchOutputToolBranch15.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputToolSearchOutputToolBranch15',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputApplyPatchToolParam get value =>
      LiveInputApplyPatchToolParam.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {r'$ref': '#/components/schemas/ApplyPatchToolParam'},
    rawValue,
    'LiveInputToolSearchOutputToolBranch15',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputToolSearchOutputToolBranch15 copyWith({Object? value = liveUnset}) =>
      LiveInputToolSearchOutputToolBranch15.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputToolSearchOutputTool.value'),
      );
}

/// Typed canonical union VectorStoreFileAttributes.
/// Variants: [LiveInputVectorStoreFileAttributesBranch0], [LiveInputVectorStoreFileAttributesBranch1].
@immutable
sealed class LiveInputVectorStoreFileAttributes extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputVectorStoreFileAttributes();

  /// Parses and validates the canonical value.
  factory LiveInputVectorStoreFileAttributes.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputVectorStoreFileAttributes',
    );
    final tagged = _inputTaggedBranch([
      {
        'additionalProperties': {
          'oneOf': [
            {'maxLength': 512, 'type': 'string'},
            {'type': 'number'},
            {'type': 'boolean'},
          ],
        },
        'maxProperties': 16,
        'propertyNames': {'maxLength': 64, 'type': 'string'},
        'type': 'object',
      },
      {'type': 'null'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputVectorStoreFileAttributesBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputVectorStoreFileAttributesBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      'additionalProperties': {
        'oneOf': [
          {'maxLength': 512, 'type': 'string'},
          {'type': 'number'},
          {'type': 'boolean'},
        ],
      },
      'maxProperties': 16,
      'propertyNames': {'maxLength': 64, 'type': 'string'},
      'type': 'object',
    }, wireValue)) {
      return LiveInputVectorStoreFileAttributesBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({'type': 'null'}, wireValue)) {
      return LiveInputVectorStoreFileAttributesBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputVectorStoreFileAttributes: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputVectorStoreFileAttributes copyWith({Object? value = liveUnset}) =>
      LiveInputVectorStoreFileAttributes.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(
                value,
                context: 'LiveInputVectorStoreFileAttributes.value',
              ),
      );
}

/// Branch 0 of LiveInputVectorStoreFileAttributes.
@immutable
final class LiveInputVectorStoreFileAttributesBranch0
    extends LiveInputVectorStoreFileAttributes {
  /// Parses and validates the canonical value.
  LiveInputVectorStoreFileAttributesBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputVectorStoreFileAttributesBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  Map<String, dynamic> get value => Map<String, dynamic>.unmodifiable(
    requireLiveObject(rawValue, 'LiveInputVectorStoreFileAttributes.branch0'),
  );
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {
      'additionalProperties': {
        'oneOf': [
          {'maxLength': 512, 'type': 'string'},
          {'type': 'number'},
          {'type': 'boolean'},
        ],
      },
      'maxProperties': 16,
      'propertyNames': {'maxLength': 64, 'type': 'string'},
      'type': 'object',
    },
    rawValue,
    'LiveInputVectorStoreFileAttributesBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputVectorStoreFileAttributesBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputVectorStoreFileAttributesBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputVectorStoreFileAttributes.value',
          ),
  );
}

/// Branch 1 of LiveInputVectorStoreFileAttributes.
@immutable
final class LiveInputVectorStoreFileAttributesBranch1
    extends LiveInputVectorStoreFileAttributes {
  /// Parses and validates the canonical value.
  LiveInputVectorStoreFileAttributesBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputVectorStoreFileAttributesBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  Object? get value => rawValue;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'null'},
    rawValue,
    'LiveInputVectorStoreFileAttributesBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputVectorStoreFileAttributesBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputVectorStoreFileAttributesBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputVectorStoreFileAttributes.value',
          ),
  );
}

/// Typed canonical union WebSearchApproximateLocation.
/// Variants: [LiveInputWebSearchApproximateLocationBranch0], [LiveInputWebSearchApproximateLocationBranch1].
@immutable
sealed class LiveInputWebSearchApproximateLocation extends LiveInputValue {
  /// Creates the immutable value base.
  const LiveInputWebSearchApproximateLocation();

  /// Parses and validates the canonical value.
  factory LiveInputWebSearchApproximateLocation.fromJson(Object? value) {
    final wireValue = _snapshotInputValue(
      value,
      'LiveInputWebSearchApproximateLocation',
    );
    final tagged = _inputTaggedBranch([
      {
        'properties': {
          'city': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
          },
          'country': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
          },
          'region': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
          },
          'timezone': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
          },
          'type': {
            'enum': ['approximate'],
            'type': 'string',
          },
        },
        'type': 'object',
      },
      {'type': 'null'},
    ], wireValue);
    if (tagged == 0) {
      return LiveInputWebSearchApproximateLocationBranch0.fromJson(wireValue);
    }
    if (tagged == 1) {
      return LiveInputWebSearchApproximateLocationBranch1.fromJson(wireValue);
    }
    if (_matchesInputSchema({
      'properties': {
        'city': {
          'anyOf': [
            {'type': 'string'},
            {'type': 'null'},
          ],
        },
        'country': {
          'anyOf': [
            {'type': 'string'},
            {'type': 'null'},
          ],
        },
        'region': {
          'anyOf': [
            {'type': 'string'},
            {'type': 'null'},
          ],
        },
        'timezone': {
          'anyOf': [
            {'type': 'string'},
            {'type': 'null'},
          ],
        },
        'type': {
          'enum': ['approximate'],
          'type': 'string',
        },
      },
      'type': 'object',
    }, wireValue)) {
      return LiveInputWebSearchApproximateLocationBranch0.fromJson(wireValue);
    }
    if (_matchesInputSchema({'type': 'null'}, wireValue)) {
      return LiveInputWebSearchApproximateLocationBranch1.fromJson(wireValue);
    }
    throw const FormatException(
      'LiveInputWebSearchApproximateLocation: unsupported canonical union value',
    );
  }

  /// Copies the canonical union value without losing its wire context.
  LiveInputWebSearchApproximateLocation copyWith({Object? value = liveUnset}) =>
      LiveInputWebSearchApproximateLocation.fromJson(
        identical(value, liveUnset)
            ? toJson()
            : _inputWire(
                value,
                context: 'LiveInputWebSearchApproximateLocation.value',
              ),
      );
}

/// Branch 0 of LiveInputWebSearchApproximateLocation.
@immutable
final class LiveInputWebSearchApproximateLocationBranch0
    extends LiveInputWebSearchApproximateLocation {
  /// Parses and validates the canonical value.
  LiveInputWebSearchApproximateLocationBranch0.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputWebSearchApproximateLocationBranch0',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Parses and validates the canonical value.
  LiveInputWebSearchApproximateLocationBranch0Value get value =>
      LiveInputWebSearchApproximateLocationBranch0Value.fromJson(rawValue);
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {
      'properties': {
        'city': {
          'anyOf': [
            {'type': 'string'},
            {'type': 'null'},
          ],
        },
        'country': {
          'anyOf': [
            {'type': 'string'},
            {'type': 'null'},
          ],
        },
        'region': {
          'anyOf': [
            {'type': 'string'},
            {'type': 'null'},
          ],
        },
        'timezone': {
          'anyOf': [
            {'type': 'string'},
            {'type': 'null'},
          ],
        },
        'type': {
          'enum': ['approximate'],
          'type': 'string',
        },
      },
      'type': 'object',
    },
    rawValue,
    'LiveInputWebSearchApproximateLocationBranch0',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputWebSearchApproximateLocationBranch0 copyWith({
    Object? value = liveUnset,
  }) => LiveInputWebSearchApproximateLocationBranch0.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputWebSearchApproximateLocation.value',
          ),
  );
}

/// Branch 1 of LiveInputWebSearchApproximateLocation.
@immutable
final class LiveInputWebSearchApproximateLocationBranch1
    extends LiveInputWebSearchApproximateLocation {
  /// Parses and validates the canonical value.
  LiveInputWebSearchApproximateLocationBranch1.fromJson(Object? value)
    : rawValue = _snapshotInputValue(
        value,
        'LiveInputWebSearchApproximateLocationBranch1',
      ) {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  Object? get value => rawValue;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputSchema(
    {'type': 'null'},
    rawValue,
    'LiveInputWebSearchApproximateLocationBranch1',
  );

  /// Parses and validates the canonical value.
  @override
  LiveInputWebSearchApproximateLocationBranch1 copyWith({
    Object? value = liveUnset,
  }) => LiveInputWebSearchApproximateLocationBranch1.fromJson(
    identical(value, liveUnset)
        ? rawValue
        : _inputWire(
            value,
            context: 'LiveInputWebSearchApproximateLocation.value',
          ),
  );
}

/// Typed canonical value WebSearchCallStatus.
@immutable
final class LiveInputWebSearchCallStatus extends LiveInputValue {
  /// Parses and validates the canonical value.
  LiveInputWebSearchCallStatus.fromJson(Object? value)
    : rawValue = _snapshotInputValue(value, 'LiveInputWebSearchCallStatus') {
    validate();
  }

  /// Deeply immutable finite wire value.
  final Object? rawValue;

  /// Typed canonical scalar or branch value.
  String get value => rawValue! as String;
  @override
  Object? toJson() => rawValue;
  @override
  void validate() => _validateInputComponent(
    'WebSearchCallStatus',
    rawValue,
    'LiveInputWebSearchCallStatus',
  );

  /// Parses and validates the canonical value.
  LiveInputWebSearchCallStatus copyWith({Object? value = liveUnset}) =>
      LiveInputWebSearchCallStatus.fromJson(
        identical(value, liveUnset)
            ? rawValue
            : _inputWire(value, context: 'LiveInputWebSearchCallStatus.value'),
      );
}

Object? _snapshotInputValue(Object? value, String context) => snapshotLiveJson(
  {'value': value},
  context,
  knownKeys: const {'value'},
)['value'];

Object? _inputWire(
  Object? value, {
  String context = 'LiveInputValue',
  Set<Object>? ancestors,
}) {
  if (value is LiveInputValue) return value.toJson();
  if (value is LiveJsonModel) return value.toJson();
  final seen = ancestors ?? HashSet<Object>.identity();
  if (value is List || value is Map) {
    if (!seen.add(value!)) {
      throw FormatException('$context: expected acyclic JSON');
    }
    try {
      if (value is List) {
        return [
          for (var index = 0; index < value.length; index++)
            _inputWire(
              value[index],
              context: '$context[$index]',
              ancestors: seen,
            ),
        ];
      }
      final map = value as Map;
      return map.map(
        (key, value) => MapEntry(
          key,
          _inputWire(value, context: '$context member', ancestors: seen),
        ),
      );
    } finally {
      seen.remove(value);
    }
  }
  return value;
}

Map<String, dynamic> _copyInputObject(
  Map<String, dynamic> current,
  Set<String> known,
  Map<String, dynamic>? raw,
  Map<String, Object?> changes,
  Set<String> clear,
  String context,
) {
  final result = mergeLiveJson(raw ?? current, known, {
    for (final key in known)
      if (current.containsKey(key)) key: current[key],
  });
  for (final entry in changes.entries) {
    if (!identical(entry.value, liveUnset)) {
      result[entry.key] = _inputWire(
        entry.value,
        context: '$context.${entry.key}',
      );
    }
  }
  clear.forEach(result.remove);
  return result;
}

void _validateInputComponent(String component, Object? value, String context) =>
    _validateInputSchema(
      _inputSchemas[component] as Map<String, dynamic>,
      value,
      context,
    );

bool _matchesInputSchema(Map<String, dynamic> schema, Object? value) {
  try {
    _validateInputSchema(schema, value, 'LiveInputValue');
    return true;
  } on FormatException {
    return false;
  }
}

void _validateInputSchema(
  Map<String, dynamic> schema,
  Object? value,
  String context,
) {
  final reference = schema[r'$ref'];
  if (reference is String) {
    _validateInputComponent(reference.split('/').last, value, context);
  }
  final alternatives = schema['oneOf'] ?? schema['anyOf'];
  if (alternatives is List) {
    // The canonical InputItem/EasyInputMessage and nested Item schemas overlap.
    // Branch factories select a specific declared contract; admission here
    // preserves a value that satisfies at least one canonical alternative.
    FormatException? failure;
    var matched = false;
    for (final branch in alternatives) {
      final shape = branch as Map<String, dynamic>;
      if (value != null && shape['type'] == 'null') continue;
      if (value == null && shape['type'] != null && shape['type'] != 'null') {
        continue;
      }
      try {
        _validateInputSchema(shape, value, context);
        matched = true;
        break;
      } on FormatException catch (error) {
        failure ??= error;
      }
    }
    if (!matched) {
      throw FormatException(
        failure?.message ?? '$context: unsupported canonical union value',
      );
    }
  }
  final type = schema['type'];
  if (type == 'null' && value != null) {
    throw FormatException('$context: expected null');
  }
  if (type == 'string') {
    final text = requireLiveString(value, context);
    validateLiveLength(
      text,
      context,
      min: schema['minLength'] as int?,
      max: schema['maxLength'] as int?,
    );
    final pattern = schema['pattern'];
    if (pattern is String && !RegExp(pattern).hasMatch(text)) {
      throw FormatException('$context: unsupported string shape');
    }
  }
  if (type == 'integer') {
    requireLiveInt(value, context);
  }
  if (type == 'number') {
    requireLiveNumber(value, context);
  }
  if (type == 'boolean') {
    requireLiveBool(value, context);
  }
  if (value is num) {
    if (!value.isFinite) {
      throw FormatException('$context: expected a finite number');
    }
    if (schema['minimum'] is num && value < (schema['minimum'] as num)) {
      throw FormatException('$context: number below canonical minimum');
    }
    if (schema['maximum'] is num && value > (schema['maximum'] as num)) {
      throw FormatException('$context: number above canonical maximum');
    }
  }
  final allowed = schema['enum'];
  if (allowed is List && !allowed.contains(value)) {
    throw FormatException('$context: unsupported canonical value');
  }
  if (type == 'array') {
    final list = requireLiveList(value, context);
    final min = schema['minItems'] as int?;
    final max = schema['maxItems'] as int?;
    if ((min != null && list.length < min) ||
        (max != null && list.length > max)) {
      throw FormatException('$context: invalid item count');
    }
    final items = schema['items'];
    if (items is Map<String, dynamic>) {
      for (var index = 0; index < list.length; index++) {
        _validateInputSchema(items, list[index], '$context[$index]');
      }
    }
  }
  if (type == 'object' || schema.containsKey('properties')) {
    final object = requireLiveObject(value, context);
    final properties =
        schema['properties'] as Map<String, dynamic>? ?? const {};
    for (final key in schema['required'] as List? ?? const []) {
      if (!object.containsKey(key)) {
        throw FormatException('$context.$key: required field');
      }
    }
    final max = schema['maxProperties'] as int?;
    if (max != null && object.length > max) {
      throw FormatException('$context: too many properties');
    }
    for (final entry in object.entries) {
      if (properties.containsKey(entry.key)) {
        _validateInputSchema(
          properties[entry.key] as Map<String, dynamic>,
          entry.value,
          '$context.${entry.key}',
        );
      } else {
        final additional = schema['additionalProperties'];
        if (additional == false) {
          throw FormatException('$context: unexpected field');
        }
        if (additional is Map<String, dynamic>) {
          _validateInputSchema(additional, entry.value, '$context member');
        }
      }
      final propertyNames = schema['propertyNames'];
      if (propertyNames is Map<String, dynamic>) {
        _validateInputSchema(propertyNames, entry.key, '$context member name');
      }
    }
  }
}

int? _inputTaggedBranch(List<dynamic> branches, Object? value) {
  if (value is! Map) return null;
  for (final field in ['type', 'role']) {
    if (!value.containsKey(field)) continue;
    final matches = <int>[];
    for (var index = 0; index < branches.length; index++) {
      var schema = branches[index] as Map<String, dynamic>;
      final ref = schema[r'$ref'];
      if (ref is String) {
        schema = _inputSchemas[ref.split('/').last] as Map<String, dynamic>;
      }
      final properties = schema['properties'];
      if (properties is! Map) continue;
      var property = properties[field];
      if (property is! Map) continue;
      final alternatives = property['anyOf'] ?? property['oneOf'];
      if (alternatives is List) {
        final nonnull = alternatives.where(
          (branch) => (branch as Map)['type'] != 'null',
        );
        if (nonnull.length == 1) property = nonnull.single;
      }
      final allowed = (property as Map)['enum'];
      if (allowed is List && allowed.contains(value[field])) matches.add(index);
    }
    if (matches.length == 1) return matches.single;
  }
  return null;
}

const Map<String, dynamic> _inputSchemas = {
  'AdditionalToolsItemParam': {
    'properties': {
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'role': {
        'enum': ['developer'],
        'type': 'string',
      },
      'tools': {
        'items': {r'$ref': '#/components/schemas/Tool'},
        'type': 'array',
      },
      'type': {
        'enum': ['additional_tools'],
        'type': 'string',
      },
    },
    'required': ['type', 'role', 'tools'],
    'type': 'object',
  },
  'Annotation': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {r'$ref': '#/components/schemas/FileCitationBody'},
      {r'$ref': '#/components/schemas/UrlCitationBody'},
      {r'$ref': '#/components/schemas/ContainerFileCitationBody'},
      {r'$ref': '#/components/schemas/FilePath'},
    ],
  },
  'ApplyPatchCallOutputStatusParam': {
    'enum': ['completed', 'failed'],
    'type': 'string',
  },
  'ApplyPatchCallStatusParam': {
    'enum': ['in_progress', 'completed'],
    'type': 'string',
  },
  'ApplyPatchCreateFileOperationParam': {
    'properties': {
      'diff': {'maxLength': 10485760, 'type': 'string'},
      'path': {'minLength': 1, 'type': 'string'},
      'type': {
        'enum': ['create_file'],
        'type': 'string',
      },
    },
    'required': ['type', 'path', 'diff'],
    'type': 'object',
  },
  'ApplyPatchDeleteFileOperationParam': {
    'properties': {
      'path': {'minLength': 1, 'type': 'string'},
      'type': {
        'enum': ['delete_file'],
        'type': 'string',
      },
    },
    'required': ['type', 'path'],
    'type': 'object',
  },
  'ApplyPatchOperationParam': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {r'$ref': '#/components/schemas/ApplyPatchCreateFileOperationParam'},
      {r'$ref': '#/components/schemas/ApplyPatchDeleteFileOperationParam'},
      {r'$ref': '#/components/schemas/ApplyPatchUpdateFileOperationParam'},
    ],
  },
  'ApplyPatchToolCallItemParam': {
    'properties': {
      'call_id': {'maxLength': 64, 'minLength': 1, 'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCallerParam'},
          {'type': 'null'},
        ],
      },
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'operation': {r'$ref': '#/components/schemas/ApplyPatchOperationParam'},
      'status': {r'$ref': '#/components/schemas/ApplyPatchCallStatusParam'},
      'type': {
        'enum': ['apply_patch_call'],
        'type': 'string',
      },
    },
    'required': ['type', 'call_id', 'status', 'operation'],
    'type': 'object',
  },
  'ApplyPatchToolCallOutputItemParam': {
    'properties': {
      'call_id': {'maxLength': 64, 'minLength': 1, 'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCallerParam'},
          {'type': 'null'},
        ],
      },
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'output': {
        'anyOf': [
          {'maxLength': 10485760, 'type': 'string'},
          {'type': 'null'},
        ],
      },
      'status': {
        r'$ref': '#/components/schemas/ApplyPatchCallOutputStatusParam',
      },
      'type': {
        'enum': ['apply_patch_call_output'],
        'type': 'string',
      },
    },
    'required': ['type', 'call_id', 'status'],
    'type': 'object',
  },
  'ApplyPatchToolParam': {
    'properties': {
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'minItems': 1,
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['apply_patch'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'ApplyPatchUpdateFileOperationParam': {
    'properties': {
      'diff': {'maxLength': 10485760, 'type': 'string'},
      'path': {'minLength': 1, 'type': 'string'},
      'type': {
        'enum': ['update_file'],
        'type': 'string',
      },
    },
    'required': ['type', 'path', 'diff'],
    'type': 'object',
  },
  'ApproximateLocation': {
    'properties': {
      'city': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'country': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'region': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'timezone': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['approximate'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'AutoCodeInterpreterToolParam': {
    'properties': {
      'file_ids': {
        'items': {'type': 'string'},
        'maxItems': 50,
        'type': 'array',
      },
      'memory_limit': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ContainerMemoryLimit'},
          {'type': 'null'},
        ],
      },
      'network_policy': {
        'discriminator': {'propertyName': 'type'},
        'oneOf': [
          {r'$ref': '#/components/schemas/ContainerNetworkPolicyDisabledParam'},
          {
            r'$ref':
                '#/components/schemas/ContainerNetworkPolicyAllowlistParam',
          },
        ],
      },
      'type': {
        'enum': ['auto'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'CallableToolAllowedCaller': {
    'enum': ['direct', 'programmatic'],
    'type': 'string',
  },
  'ClickButtonType': {
    'enum': ['left', 'right', 'wheel', 'back', 'forward'],
    'type': 'string',
  },
  'ClickParam': {
    'properties': {
      'button': {r'$ref': '#/components/schemas/ClickButtonType'},
      'keys': {
        'anyOf': [
          {
            'items': {'type': 'string'},
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['click'],
        'type': 'string',
      },
      'x': {'type': 'integer'},
      'y': {'type': 'integer'},
    },
    'required': ['type', 'button', 'x', 'y'],
    'type': 'object',
  },
  'CodeInterpreterOutputImage': {
    'properties': {
      'type': {
        'enum': ['image'],
        'type': 'string',
      },
      'url': {'format': 'uri', 'type': 'string'},
    },
    'required': ['type', 'url'],
    'type': 'object',
  },
  'CodeInterpreterOutputLogs': {
    'properties': {
      'logs': {'type': 'string'},
      'type': {
        'enum': ['logs'],
        'type': 'string',
      },
    },
    'required': ['type', 'logs'],
    'type': 'object',
  },
  'CodeInterpreterTool': {
    'properties': {
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'minItems': 1,
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'container': {
        'oneOf': [
          {'type': 'string'},
          {r'$ref': '#/components/schemas/AutoCodeInterpreterToolParam'},
        ],
      },
      'type': {
        'enum': ['code_interpreter'],
        'type': 'string',
      },
    },
    'required': ['type', 'container'],
    'type': 'object',
  },
  'CodeInterpreterToolCall': {
    'properties': {
      'code': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'container_id': {'type': 'string'},
      'id': {'type': 'string'},
      'outputs': {
        'anyOf': [
          {
            'discriminator': {'propertyName': 'type'},
            'items': {
              'discriminator': {'propertyName': 'type'},
              'oneOf': [
                {r'$ref': '#/components/schemas/CodeInterpreterOutputLogs'},
                {r'$ref': '#/components/schemas/CodeInterpreterOutputImage'},
              ],
            },
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'status': {
        'enum': [
          'in_progress',
          'completed',
          'incomplete',
          'interpreting',
          'failed',
        ],
        'type': 'string',
      },
      'type': {
        'enum': ['code_interpreter_call'],
        'type': 'string',
      },
    },
    'required': ['type', 'id', 'status', 'container_id', 'code', 'outputs'],
    'type': 'object',
  },
  'CompactionSummaryItemParam': {
    'properties': {
      'encrypted_content': {'maxLength': 104857600, 'type': 'string'},
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['compaction'],
        'type': 'string',
      },
    },
    'required': ['type', 'encrypted_content'],
    'type': 'object',
  },
  'CompactionTriggerItemParam': {
    'properties': {
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['compaction_trigger'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'ComparisonFilter': {
    'additionalProperties': false,
    'properties': {
      'key': {'type': 'string'},
      'type': {
        'enum': ['eq', 'ne', 'gt', 'gte', 'lt', 'lte', 'in', 'nin'],
        'type': 'string',
      },
      'value': {
        'oneOf': [
          {'type': 'string'},
          {'type': 'number'},
          {'type': 'boolean'},
          {
            'items': {
              'oneOf': [
                {'type': 'string'},
                {'type': 'number'},
              ],
            },
            'type': 'array',
          },
        ],
      },
    },
    'required': ['type', 'key', 'value'],
    'type': 'object',
  },
  'CompoundFilter': {
    'additionalProperties': false,
    'properties': {
      'filters': {
        'items': {
          'discriminator': {'propertyName': 'type'},
          'oneOf': [
            {r'$ref': '#/components/schemas/ComparisonFilter'},
            {r'$ref': '#/components/schemas/CompoundFilter'},
          ],
        },
        'type': 'array',
      },
      'type': {
        'enum': ['and', 'or'],
        'type': 'string',
      },
    },
    'required': ['type', 'filters'],
    'type': 'object',
  },
  'ComputerAction': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {r'$ref': '#/components/schemas/ClickParam'},
      {r'$ref': '#/components/schemas/DoubleClickAction'},
      {r'$ref': '#/components/schemas/DragParam'},
      {r'$ref': '#/components/schemas/KeyPressAction'},
      {r'$ref': '#/components/schemas/MoveParam'},
      {r'$ref': '#/components/schemas/ScreenshotParam'},
      {r'$ref': '#/components/schemas/ScrollParam'},
      {r'$ref': '#/components/schemas/TypeParam'},
      {r'$ref': '#/components/schemas/WaitParam'},
    ],
  },
  'ComputerActionList': {
    'items': {r'$ref': '#/components/schemas/ComputerAction'},
    'type': 'array',
  },
  'ComputerCallOutputItemParam': {
    'properties': {
      'acknowledged_safety_checks': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/ComputerCallSafetyCheckParam',
            },
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'call_id': {'maxLength': 64, 'minLength': 1, 'type': 'string'},
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'output': {r'$ref': '#/components/schemas/ComputerScreenshotImage'},
      'status': {
        'anyOf': [
          {r'$ref': '#/components/schemas/FunctionCallItemStatus'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['computer_call_output'],
        'type': 'string',
      },
    },
    'required': ['call_id', 'type', 'output'],
    'type': 'object',
  },
  'ComputerCallSafetyCheckParam': {
    'properties': {
      'code': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'id': {'type': 'string'},
      'message': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'required': ['id'],
    'type': 'object',
  },
  'ComputerEnvironment': {
    'enum': ['windows', 'mac', 'linux', 'ubuntu', 'browser'],
    'type': 'string',
  },
  'ComputerScreenshotImage': {
    'properties': {
      'file_id': {'type': 'string'},
      'image_url': {'format': 'uri', 'type': 'string'},
      'type': {
        'enum': ['computer_screenshot'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'ComputerTool': {
    'properties': {
      'type': {
        'enum': ['computer'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'ComputerToolCall': {
    'properties': {
      'action': {r'$ref': '#/components/schemas/ComputerAction'},
      'actions': {r'$ref': '#/components/schemas/ComputerActionList'},
      'call_id': {'type': 'string'},
      'id': {'type': 'string'},
      'pending_safety_checks': {
        'items': {r'$ref': '#/components/schemas/ComputerCallSafetyCheckParam'},
        'type': 'array',
      },
      'status': {
        'enum': ['in_progress', 'completed', 'incomplete'],
        'type': 'string',
      },
      'type': {
        'enum': ['computer_call'],
        'type': 'string',
      },
    },
    'required': ['type', 'id', 'call_id', 'pending_safety_checks', 'status'],
    'type': 'object',
  },
  'ComputerUsePreviewTool': {
    'properties': {
      'display_height': {'type': 'integer'},
      'display_width': {'type': 'integer'},
      'environment': {r'$ref': '#/components/schemas/ComputerEnvironment'},
      'type': {
        'enum': ['computer_use_preview'],
        'type': 'string',
      },
    },
    'required': ['type', 'environment', 'display_width', 'display_height'],
    'type': 'object',
  },
  'ContainerAutoParam': {
    'properties': {
      'file_ids': {
        'items': {'type': 'string'},
        'maxItems': 50,
        'type': 'array',
      },
      'memory_limit': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ContainerMemoryLimit'},
          {'type': 'null'},
        ],
      },
      'network_policy': {
        'discriminator': {'propertyName': 'type'},
        'oneOf': [
          {r'$ref': '#/components/schemas/ContainerNetworkPolicyDisabledParam'},
          {
            r'$ref':
                '#/components/schemas/ContainerNetworkPolicyAllowlistParam',
          },
        ],
      },
      'skills': {
        'items': {
          'discriminator': {'propertyName': 'type'},
          'oneOf': [
            {r'$ref': '#/components/schemas/SkillReferenceParam'},
            {r'$ref': '#/components/schemas/InlineSkillParam'},
          ],
        },
        'maxItems': 200,
        'type': 'array',
      },
      'type': {
        'enum': ['container_auto'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'ContainerFileCitationBody': {
    'properties': {
      'container_id': {'type': 'string'},
      'end_index': {'type': 'integer'},
      'file_id': {'type': 'string'},
      'filename': {'type': 'string'},
      'start_index': {'type': 'integer'},
      'type': {
        'enum': ['container_file_citation'],
        'type': 'string',
      },
    },
    'required': [
      'type',
      'container_id',
      'file_id',
      'start_index',
      'end_index',
      'filename',
    ],
    'type': 'object',
  },
  'ContainerMemoryLimit': {
    'enum': ['1g', '4g', '16g', '64g'],
    'type': 'string',
  },
  'ContainerNetworkPolicyAllowlistParam': {
    'properties': {
      'allowed_domains': {
        'items': {'type': 'string'},
        'minItems': 1,
        'type': 'array',
      },
      'domain_secrets': {
        'items': {
          r'$ref':
              '#/components/schemas/ContainerNetworkPolicyDomainSecretParam',
        },
        'minItems': 1,
        'type': 'array',
      },
      'type': {
        'enum': ['allowlist'],
        'type': 'string',
      },
    },
    'required': ['type', 'allowed_domains'],
    'type': 'object',
  },
  'ContainerNetworkPolicyDisabledParam': {
    'properties': {
      'type': {
        'enum': ['disabled'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'ContainerNetworkPolicyDomainSecretParam': {
    'properties': {
      'domain': {'minLength': 1, 'type': 'string'},
      'name': {'minLength': 1, 'type': 'string'},
      'value': {'maxLength': 10485760, 'minLength': 1, 'type': 'string'},
    },
    'required': ['domain', 'name', 'value'],
    'type': 'object',
  },
  'ContainerReferenceParam': {
    'properties': {
      'container_id': {'type': 'string'},
      'type': {
        'enum': ['container_reference'],
        'type': 'string',
      },
    },
    'required': ['type', 'container_id'],
    'type': 'object',
  },
  'CoordParam': {
    'properties': {
      'x': {'type': 'integer'},
      'y': {'type': 'integer'},
    },
    'required': ['x', 'y'],
    'type': 'object',
  },
  'CustomGrammarFormatParam': {
    'properties': {
      'definition': {'type': 'string'},
      'syntax': {r'$ref': '#/components/schemas/GrammarSyntax1'},
      'type': {
        'enum': ['grammar'],
        'type': 'string',
      },
    },
    'required': ['type', 'syntax', 'definition'],
    'type': 'object',
  },
  'CustomTextFormatParam': {
    'properties': {
      'type': {
        'enum': ['text'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'CustomToolCall': {
    'properties': {
      'async': {'type': 'boolean'},
      'call_id': {'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCaller'},
          {'type': 'null'},
        ],
      },
      'id': {'type': 'string'},
      'input': {'type': 'string'},
      'name': {'type': 'string'},
      'namespace': {'type': 'string'},
      'type': {
        'enum': ['custom_tool_call'],
        'type': 'string',
      },
    },
    'required': ['type', 'call_id', 'name', 'input'],
    'type': 'object',
  },
  'CustomToolCallOutput': {
    'properties': {
      'call_id': {'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCallerParam'},
          {'type': 'null'},
        ],
      },
      'id': {'type': 'string'},
      'output': {
        'oneOf': [
          {'type': 'string'},
          {
            'items': {
              r'$ref': '#/components/schemas/FunctionAndCustomToolCallOutput',
            },
            'type': 'array',
          },
        ],
      },
      'type': {
        'enum': ['custom_tool_call_output'],
        'type': 'string',
      },
    },
    'required': ['type', 'call_id', 'output'],
    'type': 'object',
  },
  'CustomToolParam': {
    'properties': {
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'minItems': 1,
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'async': {'type': 'boolean'},
      'defer_loading': {'type': 'boolean'},
      'description': {'type': 'string'},
      'format': {
        'discriminator': {'propertyName': 'type'},
        'oneOf': [
          {r'$ref': '#/components/schemas/CustomTextFormatParam'},
          {r'$ref': '#/components/schemas/CustomGrammarFormatParam'},
        ],
      },
      'name': {'type': 'string'},
      'type': {
        'enum': ['custom'],
        'type': 'string',
      },
    },
    'required': ['type', 'name'],
    'type': 'object',
  },
  'DetailEnum': {
    'enum': ['low', 'high', 'auto', 'original'],
    'type': 'string',
  },
  'DirectToolCallCaller': {
    'properties': {
      'type': {
        'enum': ['direct'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'DirectToolCallCallerParam': {
    'properties': {
      'type': {
        'enum': ['direct'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'DoubleClickAction': {
    'properties': {
      'keys': {
        'anyOf': [
          {
            'items': {'type': 'string'},
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['double_click'],
        'type': 'string',
      },
      'x': {'type': 'integer'},
      'y': {'type': 'integer'},
    },
    'required': ['type', 'x', 'y', 'keys'],
    'type': 'object',
  },
  'DragParam': {
    'properties': {
      'keys': {
        'anyOf': [
          {
            'items': {'type': 'string'},
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'path': {
        'items': {r'$ref': '#/components/schemas/CoordParam'},
        'type': 'array',
      },
      'type': {
        'enum': ['drag'],
        'type': 'string',
      },
    },
    'required': ['type', 'path'],
    'type': 'object',
  },
  'EasyInputMessage': {
    'properties': {
      'content': {
        'oneOf': [
          {'type': 'string'},
          {r'$ref': '#/components/schemas/InputMessageContentList'},
        ],
      },
      'phase': {
        'anyOf': [
          {r'$ref': '#/components/schemas/MessagePhase'},
          {'type': 'null'},
        ],
      },
      'role': {
        'enum': ['user', 'assistant', 'system', 'developer'],
        'type': 'string',
      },
      'type': {
        'enum': ['message'],
        'type': 'string',
      },
    },
    'required': ['role', 'content'],
    'type': 'object',
  },
  'EmptyModelParam': {
    'properties': <String, dynamic>{},
    'required': <dynamic>[],
    'type': 'object',
  },
  'FileCitationBody': {
    'properties': {
      'file_id': {'type': 'string'},
      'filename': {'type': 'string'},
      'index': {'type': 'integer'},
      'type': {
        'enum': ['file_citation'],
        'type': 'string',
      },
    },
    'required': ['type', 'file_id', 'index', 'filename'],
    'type': 'object',
  },
  'FileDetailEnum': {
    'enum': ['auto', 'low', 'high'],
    'type': 'string',
  },
  'FileInputDetail': {
    'enum': ['auto', 'low', 'high'],
    'type': 'string',
  },
  'FilePath': {
    'properties': {
      'file_id': {'type': 'string'},
      'index': {'type': 'integer'},
      'type': {
        'enum': ['file_path'],
        'type': 'string',
      },
    },
    'required': ['type', 'file_id', 'index'],
    'type': 'object',
  },
  'FileSearchTool': {
    'properties': {
      'filters': {
        'anyOf': [
          {r'$ref': '#/components/schemas/Filters'},
          {'type': 'null'},
        ],
      },
      'max_num_results': {'type': 'integer'},
      'ranking_options': {r'$ref': '#/components/schemas/RankingOptions'},
      'type': {
        'enum': ['file_search'],
        'type': 'string',
      },
      'vector_store_ids': {
        'items': {'type': 'string'},
        'type': 'array',
      },
    },
    'required': ['type', 'vector_store_ids'],
    'type': 'object',
  },
  'FileSearchToolCall': {
    'properties': {
      'id': {'type': 'string'},
      'queries': {
        'items': {'type': 'string'},
        'type': 'array',
      },
      'results': {
        'anyOf': [
          {
            'items': {
              'properties': {
                'attributes': {
                  r'$ref': '#/components/schemas/VectorStoreFileAttributes',
                },
                'file_id': {'type': 'string'},
                'filename': {'type': 'string'},
                'score': {'format': 'float', 'type': 'number'},
                'text': {'type': 'string'},
              },
              'type': 'object',
            },
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'status': {
        'enum': [
          'in_progress',
          'searching',
          'completed',
          'incomplete',
          'failed',
        ],
        'type': 'string',
      },
      'type': {
        'enum': ['file_search_call'],
        'type': 'string',
      },
    },
    'required': ['id', 'type', 'status', 'queries'],
    'type': 'object',
  },
  'Filters': {
    'anyOf': [
      {r'$ref': '#/components/schemas/ComparisonFilter'},
      {r'$ref': '#/components/schemas/CompoundFilter'},
    ],
  },
  'FunctionAndCustomToolCallOutput': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {r'$ref': '#/components/schemas/InputTextContent'},
      {r'$ref': '#/components/schemas/InputImageContent'},
      {r'$ref': '#/components/schemas/InputFileContent'},
    ],
  },
  'FunctionCallItemStatus': {
    'enum': ['in_progress', 'completed', 'incomplete'],
    'type': 'string',
  },
  'FunctionCallOutputItemParam': {
    'properties': {
      'call_id': {
        'anyOf': [
          {'maxLength': 64, 'minLength': 1, 'type': 'string'},
          {'type': 'null'},
        ],
      },
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCallerParam'},
          {'type': 'null'},
        ],
      },
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'name': {
        'anyOf': [
          {'maxLength': 128, 'minLength': 1, 'type': 'string'},
          {'type': 'null'},
        ],
      },
      'namespace': {
        'anyOf': [
          {
            'maxLength': 64,
            'minLength': 1,
            'pattern': r'^[a-zA-Z0-9_-]+$',
            'type': 'string',
          },
          {'type': 'null'},
        ],
      },
      'output': {
        'oneOf': [
          {'maxLength': 10485760, 'type': 'string'},
          {
            'items': {
              'discriminator': {'propertyName': 'type'},
              'oneOf': [
                {r'$ref': '#/components/schemas/InputTextContentParam'},
                {
                  r'$ref':
                      '#/components/schemas/InputImageContentParamAutoParam',
                },
                {r'$ref': '#/components/schemas/InputFileContentParam'},
              ],
            },
            'type': 'array',
          },
        ],
      },
      'status': {
        'anyOf': [
          {r'$ref': '#/components/schemas/FunctionCallItemStatus'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['function_call_output'],
        'type': 'string',
      },
    },
    'required': ['type', 'output'],
    'type': 'object',
  },
  'FunctionShellActionParam': {
    'properties': {
      'commands': {
        'items': {'type': 'string'},
        'type': 'array',
      },
      'max_output_length': {
        'anyOf': [
          {'type': 'integer'},
          {'type': 'null'},
        ],
      },
      'timeout_ms': {
        'anyOf': [
          {'type': 'integer'},
          {'type': 'null'},
        ],
      },
    },
    'required': ['commands'],
    'type': 'object',
  },
  'FunctionShellCallItemParam': {
    'properties': {
      'action': {r'$ref': '#/components/schemas/FunctionShellActionParam'},
      'call_id': {'maxLength': 64, 'minLength': 1, 'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCallerParam'},
          {'type': 'null'},
        ],
      },
      'environment': {
        'anyOf': [
          {
            'discriminator': {'propertyName': 'type'},
            'oneOf': [
              {r'$ref': '#/components/schemas/LocalEnvironmentParam'},
              {r'$ref': '#/components/schemas/ContainerReferenceParam'},
            ],
          },
          {'type': 'null'},
        ],
      },
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'status': {
        'anyOf': [
          {r'$ref': '#/components/schemas/FunctionShellCallItemStatus'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['shell_call'],
        'type': 'string',
      },
    },
    'required': ['call_id', 'type', 'action'],
    'type': 'object',
  },
  'FunctionShellCallItemStatus': {
    'enum': ['in_progress', 'completed', 'incomplete'],
    'type': 'string',
  },
  'FunctionShellCallOutputContentParam': {
    'properties': {
      'outcome': {
        r'$ref': '#/components/schemas/FunctionShellCallOutputOutcomeParam',
      },
      'stderr': {'maxLength': 10485760, 'type': 'string'},
      'stdout': {'maxLength': 10485760, 'type': 'string'},
    },
    'required': ['stdout', 'stderr', 'outcome'],
    'type': 'object',
  },
  'FunctionShellCallOutputExitOutcomeParam': {
    'properties': {
      'exit_code': {'type': 'integer'},
      'type': {
        'enum': ['exit'],
        'type': 'string',
      },
    },
    'required': ['type', 'exit_code'],
    'type': 'object',
  },
  'FunctionShellCallOutputItemParam': {
    'properties': {
      'call_id': {'maxLength': 64, 'minLength': 1, 'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCallerParam'},
          {'type': 'null'},
        ],
      },
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'max_output_length': {
        'anyOf': [
          {'type': 'integer'},
          {'type': 'null'},
        ],
      },
      'output': {
        'items': {
          r'$ref': '#/components/schemas/FunctionShellCallOutputContentParam',
        },
        'type': 'array',
      },
      'status': {
        'anyOf': [
          {r'$ref': '#/components/schemas/FunctionShellCallItemStatus'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['shell_call_output'],
        'type': 'string',
      },
    },
    'required': ['call_id', 'type', 'output'],
    'type': 'object',
  },
  'FunctionShellCallOutputOutcomeParam': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {
        r'$ref':
            '#/components/schemas/FunctionShellCallOutputTimeoutOutcomeParam',
      },
      {r'$ref': '#/components/schemas/FunctionShellCallOutputExitOutcomeParam'},
    ],
  },
  'FunctionShellCallOutputTimeoutOutcomeParam': {
    'properties': {
      'type': {
        'enum': ['timeout'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'FunctionShellToolParam': {
    'properties': {
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'minItems': 1,
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'environment': {
        'anyOf': [
          {
            'discriminator': {'propertyName': 'type'},
            'oneOf': [
              {r'$ref': '#/components/schemas/ContainerAutoParam'},
              {r'$ref': '#/components/schemas/LocalEnvironmentParam'},
              {r'$ref': '#/components/schemas/ContainerReferenceParam'},
            ],
          },
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['shell'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'FunctionTool': {
    'properties': {
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'async': {'type': 'boolean'},
      'defer_loading': {'type': 'boolean'},
      'description': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'name': {'type': 'string'},
      'output_schema': {
        'anyOf': [
          {'additionalProperties': <String, dynamic>{}, 'type': 'object'},
          {'type': 'null'},
        ],
      },
      'parameters': {
        'anyOf': [
          {'additionalProperties': <String, dynamic>{}, 'type': 'object'},
          {'type': 'null'},
        ],
      },
      'strict': {
        'anyOf': [
          {'type': 'boolean'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['function'],
        'type': 'string',
      },
    },
    'required': ['type', 'name', 'strict', 'parameters'],
    'type': 'object',
  },
  'FunctionToolCall': {
    'properties': {
      'arguments': {'type': 'string'},
      'async': {'type': 'boolean'},
      'call_id': {'type': 'string'},
      'caller': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ToolCallCaller'},
          {'type': 'null'},
        ],
      },
      'id': {'type': 'string'},
      'name': {'type': 'string'},
      'namespace': {'type': 'string'},
      'status': {
        'enum': ['in_progress', 'completed', 'incomplete'],
        'type': 'string',
      },
      'type': {
        'enum': ['function_call'],
        'type': 'string',
      },
    },
    'required': ['type', 'call_id', 'name', 'arguments'],
    'type': 'object',
  },
  'FunctionToolParam': {
    'properties': {
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'minItems': 1,
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'async': {'type': 'boolean'},
      'defer_loading': {'type': 'boolean'},
      'description': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'name': {
        'maxLength': 128,
        'minLength': 1,
        'pattern': r'^[a-zA-Z0-9_-]+$',
        'type': 'string',
      },
      'output_schema': {
        'anyOf': [
          {'additionalProperties': <String, dynamic>{}, 'type': 'object'},
          {'type': 'null'},
        ],
      },
      'parameters': {
        'anyOf': [
          {r'$ref': '#/components/schemas/EmptyModelParam'},
          {'type': 'null'},
        ],
      },
      'strict': {
        'anyOf': [
          {'type': 'boolean'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['function'],
        'type': 'string',
      },
    },
    'required': ['name', 'type'],
    'type': 'object',
  },
  'GrammarSyntax1': {
    'enum': ['lark', 'regex'],
    'type': 'string',
  },
  'HTTPError': {
    'properties': {
      'code': {'type': 'integer'},
      'message': {'type': 'string'},
      'type': {
        'enum': ['http_error'],
        'type': 'string',
      },
    },
    'required': ['type', 'code', 'message'],
    'type': 'object',
  },
  'HybridSearchOptions': {
    'properties': {
      'embedding_weight': {'type': 'number'},
      'text_weight': {'type': 'number'},
    },
    'required': ['embedding_weight', 'text_weight'],
    'type': 'object',
  },
  'ImageBackground': {
    'enum': ['transparent', 'opaque', 'auto'],
    'type': 'string',
  },
  'ImageDetail': {
    'enum': ['low', 'high', 'auto', 'original'],
    'type': 'string',
  },
  'ImageGenActionEnum': {
    'enum': ['generate', 'edit', 'auto'],
    'type': 'string',
  },
  'ImageGenTool': {
    'properties': {
      'action': {r'$ref': '#/components/schemas/ImageGenActionEnum'},
      'background': {
        'enum': ['transparent', 'opaque', 'auto'],
        'type': 'string',
      },
      'input_fidelity': {
        'anyOf': [
          {r'$ref': '#/components/schemas/InputFidelity'},
          {'type': 'null'},
        ],
      },
      'input_image_mask': {
        'additionalProperties': false,
        'properties': {
          'file_id': {'type': 'string'},
          'image_url': {'type': 'string'},
        },
        'required': <dynamic>[],
        'type': 'object',
      },
      'model': {
        'anyOf': [
          {'type': 'string'},
          {
            'enum': [
              'gpt-image-1',
              'gpt-image-1-mini',
              'gpt-image-1.5',
              'gpt-image-2',
              'gpt-image-2-2026-04-21',
              'gpt-image-2.5-sunburst',
              'gpt-image-2.5-sunburst-2026-09-08',
              'gpt-image-2.5-flare',
              'gpt-image-2.5-flare-2026-09-08',
            ],
            'type': 'string',
          },
        ],
      },
      'moderation': {
        'enum': ['auto', 'low'],
        'type': 'string',
      },
      'output_compression': {'maximum': 100, 'minimum': 0, 'type': 'integer'},
      'output_format': {
        'enum': ['png', 'webp', 'jpeg'],
        'type': 'string',
      },
      'partial_images': {'maximum': 3, 'minimum': 0, 'type': 'integer'},
      'quality': {
        'enum': ['low', 'medium', 'high', 'xhigh', 'max', 'auto'],
        'type': 'string',
      },
      'size': {
        'anyOf': [
          {'type': 'string'},
          {
            'enum': ['1024x1024', '1024x1536', '1536x1024', 'auto'],
            'type': 'string',
          },
        ],
      },
      'type': {
        'enum': ['image_generation'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'ImageGenToolCall': {
    'properties': {
      'action': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ImageGenActionEnum'},
          {'type': 'null'},
        ],
      },
      'background': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ImageBackground'},
          {'type': 'null'},
        ],
      },
      'id': {'type': 'string'},
      'output_format': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ImageOutputFormat'},
          {'type': 'null'},
        ],
      },
      'quality': {
        'anyOf': [
          {
            'enum': ['low', 'medium', 'high', 'xhigh', 'max', 'auto'],
            'type': 'string',
          },
          {'type': 'null'},
        ],
      },
      'result': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'revised_prompt': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'size': {
        'anyOf': [
          {
            'anyOf': [
              {'type': 'string'},
              {
                'enum': ['1024x1024', '1024x1536', '1536x1024'],
                'type': 'string',
              },
            ],
          },
          {'type': 'null'},
        ],
      },
      'status': {
        'enum': ['in_progress', 'completed', 'generating', 'failed'],
        'type': 'string',
      },
      'type': {
        'enum': ['image_generation_call'],
        'type': 'string',
      },
    },
    'required': ['type', 'id', 'status', 'result'],
    'type': 'object',
  },
  'ImageOutputFormat': {
    'enum': ['png', 'webp', 'jpeg'],
    'type': 'string',
  },
  'InlineSkillParam': {
    'properties': {
      'description': {'type': 'string'},
      'name': {'type': 'string'},
      'source': {r'$ref': '#/components/schemas/InlineSkillSourceParam'},
      'type': {
        'enum': ['inline'],
        'type': 'string',
      },
    },
    'required': ['type', 'name', 'description', 'source'],
    'type': 'object',
  },
  'InlineSkillSourceParam': {
    'properties': {
      'data': {'maxLength': 70254592, 'minLength': 1, 'type': 'string'},
      'media_type': {
        'enum': ['application/zip'],
        'type': 'string',
      },
      'type': {
        'enum': ['base64'],
        'type': 'string',
      },
    },
    'required': ['type', 'media_type', 'data'],
    'type': 'object',
  },
  'InputContent': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {r'$ref': '#/components/schemas/InputTextContent'},
      {r'$ref': '#/components/schemas/InputImageContent'},
      {r'$ref': '#/components/schemas/InputFileContent'},
    ],
  },
  'InputFidelity': {
    'enum': ['high', 'low'],
    'type': 'string',
  },
  'InputFileContent': {
    'properties': {
      'detail': {r'$ref': '#/components/schemas/FileInputDetail'},
      'file_data': {'type': 'string'},
      'file_id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'file_url': {'format': 'uri', 'type': 'string'},
      'filename': {'type': 'string'},
      'prompt_cache_breakpoint': {
        r'$ref': '#/components/schemas/PromptCacheBreakpointConfig',
      },
      'type': {
        'enum': ['input_file'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'InputFileContentParam': {
    'properties': {
      'detail': {r'$ref': '#/components/schemas/FileDetailEnum'},
      'file_data': {
        'anyOf': [
          {'maxLength': 73400320, 'type': 'string'},
          {'type': 'null'},
        ],
      },
      'file_id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'file_url': {
        'anyOf': [
          {'format': 'uri', 'type': 'string'},
          {'type': 'null'},
        ],
      },
      'filename': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'prompt_cache_breakpoint': {
        'anyOf': [
          {r'$ref': '#/components/schemas/PromptCacheBreakpointParam'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['input_file'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'InputImageContent': {
    'properties': {
      'detail': {r'$ref': '#/components/schemas/ImageDetail'},
      'file_id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'image_url': {
        'anyOf': [
          {'format': 'uri', 'type': 'string'},
          {'type': 'null'},
        ],
      },
      'prompt_cache_breakpoint': {
        r'$ref': '#/components/schemas/PromptCacheBreakpointConfig',
      },
      'type': {
        'enum': ['input_image'],
        'type': 'string',
      },
    },
    'required': ['type', 'detail'],
    'type': 'object',
  },
  'InputImageContentParamAutoParam': {
    'properties': {
      'detail': {
        'anyOf': [
          {r'$ref': '#/components/schemas/DetailEnum'},
          {'type': 'null'},
        ],
      },
      'file_id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'image_url': {
        'anyOf': [
          {'format': 'uri', 'maxLength': 20971520, 'type': 'string'},
          {'type': 'null'},
        ],
      },
      'prompt_cache_breakpoint': {
        'anyOf': [
          {r'$ref': '#/components/schemas/PromptCacheBreakpointParam'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['input_image'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'InputItem': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {r'$ref': '#/components/schemas/EasyInputMessage'},
      {r'$ref': '#/components/schemas/Item', 'type': 'object'},
      {r'$ref': '#/components/schemas/CompactionTriggerItemParam'},
      {r'$ref': '#/components/schemas/ItemReferenceParam'},
      {r'$ref': '#/components/schemas/ProgramItemParam'},
      {r'$ref': '#/components/schemas/ProgramOutputItemParam'},
    ],
  },
  'InputMessage': {
    'properties': {
      'content': {r'$ref': '#/components/schemas/InputMessageContentList'},
      'role': {
        'enum': ['user', 'system', 'developer'],
        'type': 'string',
      },
      'status': {
        'enum': ['in_progress', 'completed', 'incomplete'],
        'type': 'string',
      },
      'type': {
        'enum': ['message'],
        'type': 'string',
      },
    },
    'required': ['role', 'content'],
    'type': 'object',
  },
  'InputMessageContentList': {
    'items': {r'$ref': '#/components/schemas/InputContent'},
    'type': 'array',
  },
  'InputTextContent': {
    'properties': {
      'prompt_cache_breakpoint': {
        r'$ref': '#/components/schemas/PromptCacheBreakpointConfig',
      },
      'text': {'type': 'string'},
      'type': {
        'enum': ['input_text'],
        'type': 'string',
      },
    },
    'required': ['type', 'text'],
    'type': 'object',
  },
  'InputTextContentParam': {
    'properties': {
      'prompt_cache_breakpoint': {
        'anyOf': [
          {r'$ref': '#/components/schemas/PromptCacheBreakpointParam'},
          {'type': 'null'},
        ],
      },
      'text': {'maxLength': 10485760, 'type': 'string'},
      'type': {
        'enum': ['input_text'],
        'type': 'string',
      },
    },
    'required': ['type', 'text'],
    'type': 'object',
  },
  'Item': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {r'$ref': '#/components/schemas/InputMessage'},
      {r'$ref': '#/components/schemas/OutputMessage'},
      {r'$ref': '#/components/schemas/FileSearchToolCall'},
      {r'$ref': '#/components/schemas/ComputerToolCall'},
      {r'$ref': '#/components/schemas/ComputerCallOutputItemParam'},
      {r'$ref': '#/components/schemas/WebSearchToolCall'},
      {r'$ref': '#/components/schemas/FunctionToolCall'},
      {r'$ref': '#/components/schemas/FunctionCallOutputItemParam'},
      {r'$ref': '#/components/schemas/ToolSearchCallItemParam'},
      {r'$ref': '#/components/schemas/ToolSearchOutputItemParam'},
      {r'$ref': '#/components/schemas/AdditionalToolsItemParam'},
      {r'$ref': '#/components/schemas/ResponseConfigurationUpdateItemParam'},
      {r'$ref': '#/components/schemas/ReasoningItem'},
      {r'$ref': '#/components/schemas/CompactionSummaryItemParam'},
      {r'$ref': '#/components/schemas/ImageGenToolCall'},
      {r'$ref': '#/components/schemas/CodeInterpreterToolCall'},
      {r'$ref': '#/components/schemas/LocalShellToolCall'},
      {r'$ref': '#/components/schemas/LocalShellToolCallOutput'},
      {r'$ref': '#/components/schemas/FunctionShellCallItemParam'},
      {r'$ref': '#/components/schemas/FunctionShellCallOutputItemParam'},
      {r'$ref': '#/components/schemas/ApplyPatchToolCallItemParam'},
      {r'$ref': '#/components/schemas/ApplyPatchToolCallOutputItemParam'},
      {r'$ref': '#/components/schemas/MCPListTools'},
      {r'$ref': '#/components/schemas/MCPApprovalRequest'},
      {r'$ref': '#/components/schemas/MCPApprovalResponse'},
      {r'$ref': '#/components/schemas/MCPToolCall'},
      {r'$ref': '#/components/schemas/CustomToolCallOutput'},
      {r'$ref': '#/components/schemas/CustomToolCall'},
    ],
    'type': 'object',
  },
  'ItemReferenceParam': {
    'properties': {
      'id': {'type': 'string'},
      'type': {
        'anyOf': [
          {
            'enum': ['item_reference'],
            'type': 'string',
          },
          {'type': 'null'},
        ],
      },
    },
    'required': ['id'],
    'type': 'object',
  },
  'KeyPressAction': {
    'properties': {
      'keys': {
        'items': {'type': 'string'},
        'type': 'array',
      },
      'type': {
        'enum': ['keypress'],
        'type': 'string',
      },
    },
    'required': ['type', 'keys'],
    'type': 'object',
  },
  'LocalEnvironmentParam': {
    'properties': {
      'skills': {
        'items': {r'$ref': '#/components/schemas/LocalSkillParam'},
        'maxItems': 200,
        'type': 'array',
      },
      'type': {
        'enum': ['local'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'LocalShellExecAction': {
    'properties': {
      'command': {
        'items': {'type': 'string'},
        'type': 'array',
      },
      'env': {
        'additionalProperties': {'type': 'string'},
        'type': 'object',
      },
      'timeout_ms': {
        'anyOf': [
          {'type': 'integer'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['exec'],
        'type': 'string',
      },
      'user': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'working_directory': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'required': ['type', 'command', 'env'],
    'type': 'object',
  },
  'LocalShellToolCall': {
    'properties': {
      'action': {r'$ref': '#/components/schemas/LocalShellExecAction'},
      'call_id': {'type': 'string'},
      'id': {'type': 'string'},
      'status': {
        'enum': ['in_progress', 'completed', 'incomplete'],
        'type': 'string',
      },
      'type': {
        'enum': ['local_shell_call'],
        'type': 'string',
      },
    },
    'required': ['type', 'id', 'call_id', 'action', 'status'],
    'type': 'object',
  },
  'LocalShellToolCallOutput': {
    'properties': {
      'id': {'type': 'string'},
      'output': {'type': 'string'},
      'status': {
        'anyOf': [
          {
            'enum': ['in_progress', 'completed', 'incomplete'],
            'type': 'string',
          },
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['local_shell_call_output'],
        'type': 'string',
      },
    },
    'required': ['id', 'type', 'call_id', 'output'],
    'type': 'object',
  },
  'LocalShellToolParam': {
    'properties': {
      'type': {
        'enum': ['local_shell'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'LocalSkillParam': {
    'properties': {
      'description': {'type': 'string'},
      'name': {'type': 'string'},
      'path': {'type': 'string'},
    },
    'required': ['name', 'description', 'path'],
    'type': 'object',
  },
  'LogProb': {
    'properties': {
      'bytes': {
        'items': {'type': 'integer'},
        'type': 'array',
      },
      'logprob': {'type': 'number'},
      'token': {'type': 'string'},
      'top_logprobs': {
        'items': {r'$ref': '#/components/schemas/TopLogProb'},
        'type': 'array',
      },
    },
    'required': ['token', 'logprob', 'bytes', 'top_logprobs'],
    'type': 'object',
  },
  'MCPApprovalRequest': {
    'properties': {
      'arguments': {'type': 'string'},
      'id': {'type': 'string'},
      'name': {'type': 'string'},
      'server_label': {'type': 'string'},
      'type': {
        'enum': ['mcp_approval_request'],
        'type': 'string',
      },
    },
    'required': ['type', 'id', 'server_label', 'name', 'arguments'],
    'type': 'object',
  },
  'MCPApprovalResponse': {
    'properties': {
      'approval_request_id': {'type': 'string'},
      'approve': {'type': 'boolean'},
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'reason': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['mcp_approval_response'],
        'type': 'string',
      },
    },
    'required': ['type', 'request_id', 'approve', 'approval_request_id'],
    'type': 'object',
  },
  'MCPListTools': {
    'properties': {
      'error': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'id': {'type': 'string'},
      'server_label': {'type': 'string'},
      'tools': {
        'items': {r'$ref': '#/components/schemas/MCPListToolsTool'},
        'type': 'array',
      },
      'type': {
        'enum': ['mcp_list_tools'],
        'type': 'string',
      },
    },
    'required': ['type', 'id', 'server_label', 'tools'],
    'type': 'object',
  },
  'MCPListToolsTool': {
    'properties': {
      'annotations': {
        'anyOf': [
          {'type': 'object'},
          {'type': 'null'},
        ],
      },
      'description': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'input_schema': {'type': 'object'},
      'name': {'type': 'string'},
    },
    'required': ['name', 'input_schema'],
    'type': 'object',
  },
  'MCPProtocolError': {
    'properties': {
      'code': {'type': 'integer'},
      'message': {'type': 'string'},
      'type': {
        'enum': ['mcp_protocol_error'],
        'type': 'string',
      },
    },
    'required': ['type', 'code', 'message'],
    'type': 'object',
  },
  'MCPTool': {
    'properties': {
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'minItems': 1,
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'allowed_tools': {
        'anyOf': [
          {
            'oneOf': [
              {
                'items': {'type': 'string'},
                'type': 'array',
              },
              {r'$ref': '#/components/schemas/MCPToolFilter'},
            ],
          },
          {'type': 'null'},
        ],
      },
      'authorization': {'type': 'string'},
      'connector_id': {
        'deprecated': true,
        'enum': [
          'connector_dropbox',
          'connector_gmail',
          'connector_googlecalendar',
          'connector_googledrive',
          'connector_microsoftteams',
          'connector_outlookcalendar',
          'connector_outlookemail',
          'connector_sharepoint',
        ],
        'type': 'string',
      },
      'defer_loading': {'type': 'boolean'},
      'headers': {
        'anyOf': [
          {
            'additionalProperties': {'type': 'string'},
            'type': 'object',
          },
          {'type': 'null'},
        ],
      },
      'require_approval': {
        'anyOf': [
          {
            'oneOf': [
              {
                'additionalProperties': false,
                'properties': {
                  'always': {r'$ref': '#/components/schemas/MCPToolFilter'},
                  'never': {r'$ref': '#/components/schemas/MCPToolFilter'},
                },
                'type': 'object',
              },
              {
                'enum': ['always', 'never'],
                'type': 'string',
              },
            ],
          },
          {'type': 'null'},
        ],
      },
      'server_description': {'type': 'string'},
      'server_label': {'type': 'string'},
      'server_url': {'format': 'uri', 'type': 'string'},
      'tunnel_id': {'pattern': r'^tunnel_[a-z0-9]{32}$', 'type': 'string'},
      'type': {
        'enum': ['mcp'],
        'type': 'string',
      },
    },
    'required': ['type', 'server_label'],
    'type': 'object',
  },
  'MCPToolCall': {
    'properties': {
      'approval_request_id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'arguments': {'type': 'string'},
      'error': {
        'anyOf': [
          {r'$ref': '#/components/schemas/MCPToolCallError'},
          {'type': 'null'},
        ],
      },
      'id': {'type': 'string'},
      'name': {'type': 'string'},
      'output': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'server_label': {'type': 'string'},
      'status': {r'$ref': '#/components/schemas/MCPToolCallStatus'},
      'type': {
        'enum': ['mcp_call'],
        'type': 'string',
      },
    },
    'required': ['type', 'id', 'server_label', 'name', 'arguments'],
    'type': 'object',
  },
  'MCPToolCallError': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {r'$ref': '#/components/schemas/MCPProtocolError'},
      {r'$ref': '#/components/schemas/MCPToolExecutionError'},
      {r'$ref': '#/components/schemas/HTTPError'},
    ],
  },
  'MCPToolCallStatus': {
    'enum': ['in_progress', 'completed', 'incomplete', 'calling', 'failed'],
    'type': 'string',
  },
  'MCPToolExecutionError': {
    'properties': {
      'content': <String, dynamic>{},
      'type': {
        'enum': ['mcp_tool_execution_error'],
        'type': 'string',
      },
    },
    'required': ['type', 'content'],
    'type': 'object',
  },
  'MCPToolFilter': {
    'additionalProperties': false,
    'properties': {
      'read_only': {'type': 'boolean'},
      'tool_names': {
        'items': {'type': 'string'},
        'type': 'array',
      },
    },
    'required': <dynamic>[],
    'type': 'object',
  },
  'MessagePhase': {
    'enum': ['commentary', 'final_answer'],
    'type': 'string',
  },
  'MoveParam': {
    'properties': {
      'keys': {
        'anyOf': [
          {
            'items': {'type': 'string'},
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['move'],
        'type': 'string',
      },
      'x': {'type': 'integer'},
      'y': {'type': 'integer'},
    },
    'required': ['type', 'x', 'y'],
    'type': 'object',
  },
  'NamespaceToolParam': {
    'properties': {
      'description': {'type': 'string'},
      'name': {'minLength': 1, 'type': 'string'},
      'tools': {
        'items': {
          'discriminator': {'propertyName': 'type'},
          'oneOf': [
            {r'$ref': '#/components/schemas/FunctionToolParam'},
            {r'$ref': '#/components/schemas/CustomToolParam'},
          ],
        },
        'minItems': 1,
        'type': 'array',
      },
      'type': {
        'enum': ['namespace'],
        'type': 'string',
      },
    },
    'required': ['type', 'name', 'description', 'tools'],
    'type': 'object',
  },
  'OutputMessage': {
    'properties': {
      'content': {
        'items': {r'$ref': '#/components/schemas/OutputMessageContent'},
        'type': 'array',
      },
      'id': {'type': 'string'},
      'phase': {
        'anyOf': [
          {r'$ref': '#/components/schemas/MessagePhase'},
          {'type': 'null'},
        ],
      },
      'role': {
        'enum': ['assistant'],
        'type': 'string',
      },
      'status': {
        'enum': ['in_progress', 'completed', 'incomplete'],
        'type': 'string',
      },
      'type': {
        'enum': ['message'],
        'type': 'string',
      },
    },
    'required': ['id', 'type', 'role', 'content', 'status'],
    'type': 'object',
  },
  'OutputMessageContent': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {r'$ref': '#/components/schemas/OutputTextContent'},
      {r'$ref': '#/components/schemas/RefusalContent'},
    ],
  },
  'OutputTextContent': {
    'properties': {
      'annotations': {
        'items': {r'$ref': '#/components/schemas/Annotation'},
        'type': 'array',
      },
      'logprobs': {
        'items': {r'$ref': '#/components/schemas/LogProb'},
        'type': 'array',
      },
      'text': {'type': 'string'},
      'type': {
        'enum': ['output_text'],
        'type': 'string',
      },
    },
    'required': ['type', 'text', 'annotations', 'logprobs'],
    'type': 'object',
  },
  'ProgramItemParam': {
    'properties': {
      'call_id': {'maxLength': 64, 'minLength': 1, 'type': 'string'},
      'code': {'maxLength': 10485760, 'type': 'string'},
      'fingerprint': {'maxLength': 10485760, 'type': 'string'},
      'id': {'type': 'string'},
      'type': {
        'enum': ['program'],
        'type': 'string',
      },
    },
    'required': ['id', 'type', 'call_id', 'code', 'fingerprint'],
    'type': 'object',
  },
  'ProgramOutputItemParam': {
    'properties': {
      'call_id': {'maxLength': 64, 'minLength': 1, 'type': 'string'},
      'id': {'type': 'string'},
      'result': {'maxLength': 10485760, 'type': 'string'},
      'status': {r'$ref': '#/components/schemas/ProgramOutputItemStatus'},
      'type': {
        'enum': ['program_output'],
        'type': 'string',
      },
    },
    'required': ['id', 'type', 'call_id', 'result', 'status'],
    'type': 'object',
  },
  'ProgramOutputItemStatus': {
    'enum': ['completed', 'incomplete'],
    'type': 'string',
  },
  'ProgramToolCallCaller': {
    'properties': {
      'caller_id': {'type': 'string'},
      'type': {
        'enum': ['program'],
        'type': 'string',
      },
    },
    'required': ['type', 'caller_id'],
    'type': 'object',
  },
  'ProgramToolCallCallerParam': {
    'properties': {
      'caller_id': {'maxLength': 64, 'minLength': 1, 'type': 'string'},
      'type': {
        'enum': ['program'],
        'type': 'string',
      },
    },
    'required': ['type', 'caller_id'],
    'type': 'object',
  },
  'ProgrammaticToolCallingParam': {
    'properties': {
      'type': {
        'enum': ['programmatic_tool_calling'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'PromptCacheBreakpointConfig': {
    'properties': {
      'mode': {
        'enum': ['explicit'],
        'type': 'string',
      },
    },
    'required': ['mode'],
    'type': 'object',
  },
  'PromptCacheBreakpointParam': {
    'properties': {
      'mode': {
        'enum': ['explicit'],
        'type': 'string',
      },
    },
    'required': ['mode'],
    'type': 'object',
  },
  'RankerVersionType': {
    'enum': ['auto', 'default-2024-11-15'],
    'type': 'string',
  },
  'RankingOptions': {
    'properties': {
      'hybrid_search': {r'$ref': '#/components/schemas/HybridSearchOptions'},
      'ranker': {r'$ref': '#/components/schemas/RankerVersionType'},
      'score_threshold': {'type': 'number'},
    },
    'required': <dynamic>[],
    'type': 'object',
  },
  'ReasoningEffort': {
    'anyOf': [
      {
        'enum': ['none', 'minimal', 'low', 'medium', 'high', 'xhigh', 'max'],
        'type': 'string',
      },
      {'type': 'null'},
    ],
  },
  'ReasoningItem': {
    'properties': {
      'content': {
        'items': {r'$ref': '#/components/schemas/ReasoningTextContent'},
        'type': 'array',
      },
      'encrypted_content': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'id': {'type': 'string'},
      'status': {
        'enum': ['in_progress', 'completed', 'incomplete'],
        'type': 'string',
      },
      'summary': {
        'items': {r'$ref': '#/components/schemas/SummaryTextContent'},
        'type': 'array',
      },
      'type': {
        'enum': ['reasoning'],
        'type': 'string',
      },
    },
    'required': ['id', 'summary', 'type'],
    'type': 'object',
  },
  'ReasoningTextContent': {
    'properties': {
      'text': {'type': 'string'},
      'type': {
        'enum': ['reasoning_text'],
        'type': 'string',
      },
    },
    'required': ['type', 'text'],
    'type': 'object',
  },
  'RefusalContent': {
    'properties': {
      'refusal': {'type': 'string'},
      'type': {
        'enum': ['refusal'],
        'type': 'string',
      },
    },
    'required': ['type', 'refusal'],
    'type': 'object',
  },
  'ResponseConfigurationUpdateItemParam': {
    'properties': {
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'reasoning': {
        'properties': {
          'effort': {r'$ref': '#/components/schemas/ReasoningEffort'},
        },
        'type': 'object',
      },
      'type': {
        'enum': ['configuration_update'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'ScreenshotParam': {
    'properties': {
      'type': {
        'enum': ['screenshot'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'ScrollParam': {
    'properties': {
      'keys': {
        'anyOf': [
          {
            'items': {'type': 'string'},
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'scroll_x': {'type': 'integer'},
      'scroll_y': {'type': 'integer'},
      'type': {
        'enum': ['scroll'],
        'type': 'string',
      },
      'x': {'type': 'integer'},
      'y': {'type': 'integer'},
    },
    'required': ['type', 'x', 'y', 'scroll_x', 'scroll_y'],
    'type': 'object',
  },
  'SearchContentType': {
    'enum': ['text', 'image'],
    'type': 'string',
  },
  'SearchContextSize': {
    'enum': ['low', 'medium', 'high'],
    'type': 'string',
  },
  'SkillReferenceParam': {
    'properties': {
      'skill_id': {'maxLength': 64, 'minLength': 1, 'type': 'string'},
      'type': {
        'enum': ['skill_reference'],
        'type': 'string',
      },
      'version': {'type': 'string'},
    },
    'required': ['type', 'skill_id'],
    'type': 'object',
  },
  'SummaryTextContent': {
    'properties': {
      'text': {'type': 'string'},
      'type': {
        'enum': ['summary_text'],
        'type': 'string',
      },
    },
    'required': ['type', 'text'],
    'type': 'object',
  },
  'Tool': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {r'$ref': '#/components/schemas/FunctionTool'},
      {r'$ref': '#/components/schemas/FileSearchTool'},
      {r'$ref': '#/components/schemas/ComputerTool'},
      {r'$ref': '#/components/schemas/ComputerUsePreviewTool'},
      {r'$ref': '#/components/schemas/WebSearchTool'},
      {r'$ref': '#/components/schemas/MCPTool'},
      {r'$ref': '#/components/schemas/CodeInterpreterTool'},
      {r'$ref': '#/components/schemas/ProgrammaticToolCallingParam'},
      {r'$ref': '#/components/schemas/ImageGenTool'},
      {r'$ref': '#/components/schemas/LocalShellToolParam'},
      {r'$ref': '#/components/schemas/FunctionShellToolParam'},
      {r'$ref': '#/components/schemas/CustomToolParam'},
      {r'$ref': '#/components/schemas/NamespaceToolParam'},
      {r'$ref': '#/components/schemas/ToolSearchToolParam'},
      {r'$ref': '#/components/schemas/WebSearchPreviewTool'},
      {r'$ref': '#/components/schemas/ApplyPatchToolParam'},
    ],
  },
  'ToolCallCaller': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {r'$ref': '#/components/schemas/DirectToolCallCaller'},
      {r'$ref': '#/components/schemas/ProgramToolCallCaller'},
    ],
  },
  'ToolCallCallerParam': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {r'$ref': '#/components/schemas/DirectToolCallCallerParam'},
      {r'$ref': '#/components/schemas/ProgramToolCallCallerParam'},
    ],
  },
  'ToolSearchCallItemParam': {
    'properties': {
      'arguments': {r'$ref': '#/components/schemas/EmptyModelParam'},
      'call_id': {
        'anyOf': [
          {'maxLength': 64, 'minLength': 1, 'type': 'string'},
          {'type': 'null'},
        ],
      },
      'execution': {r'$ref': '#/components/schemas/ToolSearchExecutionType'},
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'status': {
        'anyOf': [
          {r'$ref': '#/components/schemas/FunctionCallItemStatus'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['tool_search_call'],
        'type': 'string',
      },
    },
    'required': ['type', 'arguments'],
    'type': 'object',
  },
  'ToolSearchExecutionType': {
    'enum': ['server', 'client'],
    'type': 'string',
  },
  'ToolSearchOutputFunctionToolParam': {
    'properties': {
      'allowed_callers': {
        'anyOf': [
          {
            'items': {
              r'$ref': '#/components/schemas/CallableToolAllowedCaller',
            },
            'minItems': 1,
            'type': 'array',
          },
          {'type': 'null'},
        ],
      },
      'async': {'type': 'boolean'},
      'defer_loading': {'type': 'boolean'},
      'description': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'name': {
        'maxLength': 128,
        'minLength': 1,
        'pattern': r'^(?![\s\S]*[\r\n])[a-zA-Z0-9_.-]+$',
        'type': 'string',
      },
      'output_schema': {
        'anyOf': [
          {'additionalProperties': <String, dynamic>{}, 'type': 'object'},
          {'type': 'null'},
        ],
      },
      'parameters': {
        'anyOf': [
          {r'$ref': '#/components/schemas/EmptyModelParam'},
          {'type': 'null'},
        ],
      },
      'strict': {
        'anyOf': [
          {'type': 'boolean'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['function'],
        'type': 'string',
      },
    },
    'required': ['name', 'type'],
    'type': 'object',
  },
  'ToolSearchOutputItemParam': {
    'properties': {
      'call_id': {
        'anyOf': [
          {'maxLength': 64, 'minLength': 1, 'type': 'string'},
          {'type': 'null'},
        ],
      },
      'execution': {r'$ref': '#/components/schemas/ToolSearchExecutionType'},
      'id': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'status': {
        'anyOf': [
          {r'$ref': '#/components/schemas/FunctionCallItemStatus'},
          {'type': 'null'},
        ],
      },
      'tools': {
        'items': {r'$ref': '#/components/schemas/ToolSearchOutputTool'},
        'type': 'array',
      },
      'type': {
        'enum': ['tool_search_output'],
        'type': 'string',
      },
    },
    'required': ['type', 'tools'],
    'type': 'object',
  },
  'ToolSearchOutputNamespaceToolParam': {
    'properties': {
      'description': {'type': 'string'},
      'name': {'minLength': 1, 'type': 'string'},
      'tools': {
        'items': {
          'discriminator': {'propertyName': 'type'},
          'oneOf': [
            {r'$ref': '#/components/schemas/ToolSearchOutputFunctionToolParam'},
            {r'$ref': '#/components/schemas/CustomToolParam'},
          ],
        },
        'minItems': 1,
        'type': 'array',
      },
      'type': {
        'enum': ['namespace'],
        'type': 'string',
      },
    },
    'required': ['type', 'name', 'description', 'tools'],
    'type': 'object',
  },
  'ToolSearchOutputTool': {
    'discriminator': {'propertyName': 'type'},
    'oneOf': [
      {r'$ref': '#/components/schemas/FunctionTool'},
      {r'$ref': '#/components/schemas/FileSearchTool'},
      {r'$ref': '#/components/schemas/ComputerTool'},
      {r'$ref': '#/components/schemas/ComputerUsePreviewTool'},
      {r'$ref': '#/components/schemas/WebSearchTool'},
      {r'$ref': '#/components/schemas/MCPTool'},
      {r'$ref': '#/components/schemas/CodeInterpreterTool'},
      {r'$ref': '#/components/schemas/ProgrammaticToolCallingParam'},
      {r'$ref': '#/components/schemas/ImageGenTool'},
      {r'$ref': '#/components/schemas/LocalShellToolParam'},
      {r'$ref': '#/components/schemas/FunctionShellToolParam'},
      {r'$ref': '#/components/schemas/CustomToolParam'},
      {r'$ref': '#/components/schemas/ToolSearchOutputNamespaceToolParam'},
      {r'$ref': '#/components/schemas/ToolSearchToolParam'},
      {r'$ref': '#/components/schemas/WebSearchPreviewTool'},
      {r'$ref': '#/components/schemas/ApplyPatchToolParam'},
    ],
  },
  'ToolSearchToolParam': {
    'properties': {
      'description': {
        'anyOf': [
          {'type': 'string'},
          {'type': 'null'},
        ],
      },
      'execution': {r'$ref': '#/components/schemas/ToolSearchExecutionType'},
      'parameters': {
        'anyOf': [
          {r'$ref': '#/components/schemas/EmptyModelParam'},
          {'type': 'null'},
        ],
      },
      'type': {
        'enum': ['tool_search'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'TopLogProb': {
    'properties': {
      'bytes': {
        'items': {'type': 'integer'},
        'type': 'array',
      },
      'logprob': {'type': 'number'},
      'token': {'type': 'string'},
    },
    'required': ['token', 'logprob', 'bytes'],
    'type': 'object',
  },
  'TypeParam': {
    'properties': {
      'text': {'type': 'string'},
      'type': {
        'enum': ['type'],
        'type': 'string',
      },
    },
    'required': ['type', 'text'],
    'type': 'object',
  },
  'UrlCitationBody': {
    'properties': {
      'end_index': {'type': 'integer'},
      'start_index': {'type': 'integer'},
      'title': {'type': 'string'},
      'type': {
        'enum': ['url_citation'],
        'type': 'string',
      },
      'url': {'format': 'uri', 'type': 'string'},
    },
    'required': ['type', 'url', 'start_index', 'end_index', 'title'],
    'type': 'object',
  },
  'VectorStoreFileAttributes': {
    'anyOf': [
      {
        'additionalProperties': {
          'oneOf': [
            {'maxLength': 512, 'type': 'string'},
            {'type': 'number'},
            {'type': 'boolean'},
          ],
        },
        'maxProperties': 16,
        'propertyNames': {'maxLength': 64, 'type': 'string'},
        'type': 'object',
      },
      {'type': 'null'},
    ],
  },
  'WaitParam': {
    'properties': {
      'type': {
        'enum': ['wait'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'WebSearchActionFind': {
    'properties': {
      'pattern': {'type': 'string'},
      'type': {
        'enum': ['find_in_page'],
        'type': 'string',
      },
      'url': {'format': 'uri', 'type': 'string'},
    },
    'required': ['type', 'url', 'pattern'],
    'type': 'object',
  },
  'WebSearchActionOpenPage': {
    'properties': {
      'type': {
        'enum': ['open_page'],
        'type': 'string',
      },
      'url': {
        'anyOf': [
          {'format': 'uri', 'type': 'string'},
          {'type': 'null'},
        ],
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'WebSearchActionSearch': {
    'properties': {
      'queries': {
        'items': {'type': 'string'},
        'type': 'array',
      },
      'query': {'deprecated': true, 'type': 'string'},
      'sources': {
        'items': {
          'properties': {
            'type': {
              'enum': ['url'],
              'type': 'string',
            },
            'url': {'format': 'uri', 'type': 'string'},
          },
          'required': ['type', 'url'],
          'type': 'object',
        },
        'type': 'array',
      },
      'type': {
        'enum': ['search'],
        'type': 'string',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'WebSearchApproximateLocation': {
    'anyOf': [
      {
        'properties': {
          'city': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
          },
          'country': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
          },
          'region': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
          },
          'timezone': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
          },
          'type': {
            'enum': ['approximate'],
            'type': 'string',
          },
        },
        'type': 'object',
      },
      {'type': 'null'},
    ],
  },
  'WebSearchCallStatus': {
    'enum': ['in_progress', 'searching', 'completed', 'failed', 'incomplete'],
    'type': 'string',
  },
  'WebSearchPreviewTool': {
    'properties': {
      'search_content_types': {
        'items': {r'$ref': '#/components/schemas/SearchContentType'},
        'type': 'array',
      },
      'search_context_size': {
        r'$ref': '#/components/schemas/SearchContextSize',
      },
      'type': {
        'enum': ['web_search_preview', 'web_search_preview_2025_03_11'],
        'type': 'string',
      },
      'user_location': {
        'anyOf': [
          {r'$ref': '#/components/schemas/ApproximateLocation'},
          {'type': 'null'},
        ],
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'WebSearchTool': {
    'properties': {
      'external_web_access': {'type': 'boolean'},
      'filters': {
        'anyOf': [
          {
            'properties': {
              'allowed_domains': {
                'anyOf': [
                  {
                    'items': {'type': 'string'},
                    'type': 'array',
                  },
                  {'type': 'null'},
                ],
              },
            },
            'type': 'object',
          },
          {'type': 'null'},
        ],
      },
      'search_context_size': {
        'enum': ['low', 'medium', 'high'],
        'type': 'string',
      },
      'type': {
        'enum': ['web_search', 'web_search_2025_08_26'],
        'type': 'string',
      },
      'user_location': {
        r'$ref': '#/components/schemas/WebSearchApproximateLocation',
      },
    },
    'required': ['type'],
    'type': 'object',
  },
  'WebSearchToolCall': {
    'properties': {
      'action': {
        'discriminator': {'propertyName': 'type'},
        'oneOf': [
          {r'$ref': '#/components/schemas/WebSearchActionSearch'},
          {r'$ref': '#/components/schemas/WebSearchActionOpenPage'},
          {r'$ref': '#/components/schemas/WebSearchActionFind'},
        ],
        'type': 'object',
      },
      'id': {'type': 'string'},
      'status': {r'$ref': '#/components/schemas/WebSearchCallStatus'},
      'type': {
        'enum': ['web_search_call'],
        'type': 'string',
      },
    },
    'required': ['id', 'type', 'status'],
    'type': 'object',
  },
};
