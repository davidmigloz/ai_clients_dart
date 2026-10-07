import '../../common/json_helpers.dart';
import '../multi_agent/agent_tag.dart';
import '../tools/tool_call_caller.dart';

/// Reads a required nullable integer and checks key presence.
int? shellRequiredNullableInt(
  Map<String, dynamic> json,
  String key,
  String context,
) {
  if (!json.containsKey(key)) {
    throw FormatException('$context.$key: required key missing');
  }
  return json[key] == null ? null : requireJsonInt(json[key], '$context.$key');
}

/// Reads an optional nullable integer.
int? shellOptionalNullableInt(
  Map<String, dynamic> json,
  String key,
  String context,
) => json[key] == null ? null : requireJsonInt(json[key], '$context.$key');

/// Reads a required array with contextual element validation.
List<T> shellJsonList<T>(
  Object? value,
  String context,
  T Function(Object?, String) parse,
) {
  if (value is! List) throw FormatException('$context: expected an array');
  return List<T>.unmodifiable([
    for (var i = 0; i < value.length; i++) parse(value[i], '$context[$i]'),
  ]);
}

/// Reads agent metadata while retaining the existing provider-null tolerance.
AgentTag? shellJsonAgent(
  Map<String, dynamic> json,
  String context, {
  bool nullable = true,
}) {
  if (json.containsKey('agent') && json['agent'] == null && !nullable) {
    throw FormatException('$context.agent: expected an object');
  }
  if (json['agent'] == null) return null;
  final value = requireJsonObject(json['agent'], '$context.agent');
  return AgentTag(
    agentName: requireJsonString(
      value['agent_name'],
      '$context.agent.agent_name',
    ),
  );
}

/// Reads nullable caller metadata with contextual known-variant validation.
ToolCallCaller? shellJsonCaller(Map<String, dynamic> json, String context) {
  if (json['caller'] == null) return null;
  final value = requireJsonObject(json['caller'], '$context.caller');
  final type = requireJsonString(value['type'], '$context.caller.type');
  if (type == 'program') {
    requireJsonString(value['caller_id'], '$context.caller.caller_id');
  }
  if (type != 'program' && type != 'direct') {
    throw FormatException('$context.caller.type: unsupported caller');
  }
  return ToolCallCaller.fromJson(value);
}
