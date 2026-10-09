import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';

/// New history witnesses independently validated against frozen JSONSchema.
final agentSessionHistoryFixtures = <AgentSessionHistoryFixture>[
  AgentSessionHistoryFixture(
    schema: 'SessionItemListResource',
    minimal:
        jsonDecode(
              r'''{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}''',
            )
            as Map<String, dynamic>,
    full:
        jsonDecode(
              r'''{"object":"list","data":[{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent_message"},{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"close_subagent_call"},{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"},{"id":"PRIVATE-fixture","request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"},{"id":"PRIVATE-fixture","request_id":"PRIVATE-fixture","response":{"action":"submit","selected_option":"PRIVATE-fixture","type":"browser_authentication"},"turn_id":"PRIVATE-fixture","type":"computer_use_approval_request_result"},{"id":"PRIVATE-fixture","output":{"image_url":"PRIVATE-fixture","type":"computer_screenshot"},"status":"in_progress","title":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_call"},{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"},{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture","name":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call"},{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","id":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call_output"},{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"interrupt_subagent_call"},{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"},{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},{"id":"PRIVATE-fixture","status":"in_progress","summary":[{"text":"PRIVATE-fixture","type":"summary_text"}],"turn_id":"PRIVATE-fixture","type":"reasoning"},{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"resume_subagent_call"},{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"},{"id":"PRIVATE-fixture","recipient_agent_ids":["PRIVATE-fixture"],"sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"wait_for_subagents_call"},{"action":{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"},"id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"web_search_call"}],"first_id":"first","last_id":"last","has_more":true}''',
            )
            as Map<String, dynamic>,
    parse: AgentSessionItemList.fromJson,
    copy: (value) => (value as AgentSessionItemList).copyWith(),
  ),
  AgentSessionHistoryFixture(
    schema: 'SessionTurnListResource',
    minimal:
        jsonDecode(
              r'''{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}''',
            )
            as Map<String, dynamic>,
    full:
        jsonDecode(
              r'''{"object":"list","data":[{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}],"first_id":"first","last_id":"last","has_more":true}''',
            )
            as Map<String, dynamic>,
    parse: AgentSessionTurnList.fromJson,
    copy: (value) => (value as AgentSessionTurnList).copyWith(),
  ),
  AgentSessionHistoryFixture(
    schema: 'SessionTraceListResource',
    minimal:
        jsonDecode(
              r'''{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}''',
            )
            as Map<String, dynamic>,
    full:
        jsonDecode(
              r'''{"object":"list","data":[{"id":"turn_1","object":"agent.session.trace","session_id":"session_known","created_at":1,"otlp":{"resourceSpans":[{"scopeSpans":[{"spans":[{"attributes":[{"key":"PRIVATE","value":{"arrayValue":{"values":[null,true,{"PRIVATE":"café🚀"}]}}}]}]}]}],"arbitrary":{"PRIVATE":[1,null,false]}}}],"first_id":"first","last_id":"last","has_more":true}''',
            )
            as Map<String, dynamic>,
    parse: AgentSessionTraceList.fromJson,
    copy: (value) => (value as AgentSessionTraceList).copyWith(),
  ),
  AgentSessionHistoryFixture(
    schema: 'SessionTurnTraceResource',
    minimal:
        jsonDecode(
              r'''{"id":"turn_1","object":"agent.session.trace","session_id":"session_known","created_at":1,"otlp":{}}''',
            )
            as Map<String, dynamic>,
    full:
        jsonDecode(
              r'''{"id":"turn_1","object":"agent.session.trace","session_id":"session_known","created_at":1,"otlp":{"resourceSpans":[{"scopeSpans":[{"spans":[{"attributes":[{"key":"PRIVATE","value":{"arrayValue":{"values":[null,true,{"PRIVATE":"café🚀"}]}}}]}]}]}],"arbitrary":{"PRIVATE":[1,null,false]}}}''',
            )
            as Map<String, dynamic>,
    parse: AgentSessionTurnTrace.fromJson,
    copy: (value) => (value as AgentSessionTurnTrace).copyWith(),
  ),
];

/// Exact independent canonical wire witness plus exported parser/copy API.
class AgentSessionHistoryFixture {
  /// Creates a fixed canonical fixture.
  const AgentSessionHistoryFixture({
    required this.schema,
    required this.minimal,
    required this.full,
    required this.parse,
    required this.copy,
  });

  /// Real canonical schema name.
  final String schema;

  /// Required fields and nullable empty-page boundaries.
  final Map<String, dynamic> minimal;

  /// All known nested variants/arbitrary OTLP values.
  final Map<String, dynamic> full;

  /// Actual exported parser.
  final AgentJsonModel Function(Map<String, dynamic>) parse;

  /// Actual typed copy API.
  final AgentJsonModel Function(AgentJsonModel) copy;
}
