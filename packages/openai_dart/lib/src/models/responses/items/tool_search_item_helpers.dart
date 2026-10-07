import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';
import '../config/item_status.dart';
import '../config/tool_search_execution_type.dart';
import '../multi_agent/agent_tag.dart';
import '../tools/response_tool.dart';

/// Reads a required nullable call identifier, retaining its explicit null key.
String? toolSearchRequiredCallId(Map<String, dynamic> json, String context) {
  if (!json.containsKey('call_id')) {
    throw FormatException('$context.call_id: required key missing');
  }
  return optionalJsonString(json, 'call_id', context, nullable: true);
}

/// Reads optional execution without treating an explicit null as omission.
ToolSearchExecutionType? toolSearchOptionalExecution(
  Map<String, dynamic> json,
  String context,
) => json.containsKey('execution')
    ? ToolSearchExecutionType.fromJson(
        requireJsonString(json['execution'], '$context.execution'),
      )
    : null;

/// Reads optional nullable input status while retaining enum fallback behavior.
ItemStatus? toolSearchOptionalStatus(
  Map<String, dynamic> json,
  String context,
) => json['status'] == null
    ? null
    : ItemStatus.fromJson(requireJsonString(json['status'], '$context.status'));

/// Reads beta agent metadata with the input/output nullability distinction.
AgentTag? toolSearchJsonAgent(
  Map<String, dynamic> json,
  String context, {
  bool nullable = false,
}) {
  if (!json.containsKey('agent') || (nullable && json['agent'] == null)) {
    return null;
  }
  final agent = requireJsonObject(json['agent'], '$context.agent');
  return AgentTag(
    agentName: requireJsonString(
      agent['agent_name'],
      '$context.agent.agent_name',
    ),
  );
}

/// Reads required object-shaped request arguments and snapshots nested JSON.
Map<String, dynamic> toolSearchInputArguments(
  Map<String, dynamic> json,
  String context,
) => freezeJsonObject(
  requireJsonObject(
    _toolSearchJsonValue(json['arguments'], '$context.arguments'),
    '$context.arguments',
  ),
);

/// Reads required arbitrary returned JSON, including null, and snapshots it.
Object? toolSearchReturnedArguments(Map<String, dynamic> json, String context) {
  if (!json.containsKey('arguments')) {
    throw FormatException('$context.arguments: required key missing');
  }
  return freezeJsonObject({
    'arguments': _toolSearchJsonValue(json['arguments'], '$context.arguments'),
  })['arguments'];
}

Object? _toolSearchJsonValue(Object? value, String context) {
  if (value == null || value is String || value is bool || value is int) {
    return value;
  }
  if (value is double && value.isFinite) return value;
  if (value is List) {
    return [
      for (var index = 0; index < value.length; index++)
        _toolSearchJsonValue(value[index], '$context[$index]'),
    ];
  }
  if (value is Map) {
    final object = requireJsonObject(value, context);
    return {
      for (final entry in object.entries)
        entry.key: _toolSearchJsonValue(entry.value, '$context.${entry.key}'),
    };
  }
  throw FormatException('$context: expected a JSON value');
}

/// Reads discovered tools with indexed context and an immutable list snapshot.
List<ResponseTool> toolSearchJsonTools(Object? value, String context) {
  if (value is! List) throw FormatException('$context: expected an array');
  return List<ResponseTool>.unmodifiable([
    for (var index = 0; index < value.length; index++)
      _toolSearchJsonTool(value[index], '$context[$index]'),
  ]);
}

ResponseTool _toolSearchJsonTool(Object? value, String context) {
  final object = requireJsonObject(value, context);
  try {
    return ResponseTool.fromToolSearchOutputJson(object);
  } on FormatException catch (error) {
    throw FormatException('$context: ${error.message}');
  }
}

/// Reuses shared deep comparison for arbitrary JSON roots.
bool toolSearchArgumentsEqual(Object? first, Object? second) =>
    mapsDeepEqual({'arguments': first}, {'arguments': second});

/// Reuses shared order-independent deep hashing for arbitrary JSON roots.
int toolSearchArgumentsHash(Object? value) =>
    mapDeepHashCode({'arguments': value});

/// Summarizes arbitrary JSON without disclosing strings, scalars or payloads.
String toolSearchArgumentsSummary(Object? value) => switch (value) {
  null => 'null',
  final Map<dynamic, dynamic> map => '${map.length} entries',
  final List<dynamic> list => '${list.length} items',
  final String string => '[${string.length} chars]',
  final bool _ => 'boolean',
  final num _ => 'number',
  _ => value.runtimeType.toString(),
};

/// Summarizes an optional actor string without exposing its contents.
String toolSearchActorSummary(String? value) =>
    value == null ? 'null' : '[${value.length} chars]';
