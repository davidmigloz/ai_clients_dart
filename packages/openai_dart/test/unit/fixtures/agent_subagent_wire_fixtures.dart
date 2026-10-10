import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';

/// Independent canonical values; synthetic secrets only, never read from an API.
final subagentWireFixtures = <SubagentWireFixture>[
  SubagentWireFixture(
    schema: 'AgentContentResource',
    minimal: jsonDecode(r'''{"type":"output_text","text":""}'''),
    full: jsonDecode(
      r'''{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}''',
    ),
    parse: (value) =>
        AgentSessionContent.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'encrypted_content'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'AgentMessageItemResource',
    minimal: jsonDecode(
      r'''{"id":"item_synthetic","turn_id":"turn_child","type":"agent_message","sender_agent_id":"","recipient_agent_id":"","content":[]}''',
    ),
    full: jsonDecode(
      r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"agent_message"}''',
    ),
    parse: (value) => AgentSessionAgentMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [
      'id',
      'turn_id',
      'type',
      'sender_agent_id',
      'recipient_agent_id',
      'content',
    ],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'BrowserAuthenticationFieldResource',
    minimal: jsonDecode(
      r'''{"id":"item_synthetic","label":"","type":"","required":false}''',
    ),
    full: jsonDecode(
      r'''{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationField.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['id', 'label', 'type', 'required'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'BrowserAuthenticationHistoryRequestKindResource',
    minimal: jsonDecode(
      r'''{"type":"browser_authentication","reason":null,"credential_origin":null,"fields":[],"options":[]}''',
    ),
    full: jsonDecode(
      r'''{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    requiredKeys: ['type', 'reason', 'credential_origin', 'fields', 'options'],
    nullableKeys: ['credential_origin', 'reason'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema:
        'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication',
    minimal: jsonDecode(
      r'''{"type":"browser_authentication","reason":null,"credential_origin":null,"fields":[],"options":[]}''',
    ),
    full: jsonDecode(
      r'''{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
          value! as Map<String, dynamic>,
        ),
    requiredKeys: ['type', 'reason', 'credential_origin', 'fields', 'options'],
    nullableKeys: ['credential_origin', 'reason'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'BrowserAuthenticationOptionResource',
    minimal: jsonDecode(
      r'''{"id":"item_synthetic","label":"","field_ids":[]}''',
    ),
    full: jsonDecode(
      r'''{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationOption.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['id', 'label', 'field_ids'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'BrowserAuthenticationRequestItemResource',
    minimal: jsonDecode(
      r'''{"turn_id":"turn_child","request_id":"","request":{"type":"browser_authentication","reason":null,"credential_origin":null,"fields":[],"options":[]},"id":"item_synthetic","type":"computer_use_approval_request"}''',
    ),
    full: jsonDecode(
      r'''{"id":"item_synthetic","request":{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"},"request_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_approval_request"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    requiredKeys: ['turn_id', 'request_id', 'request', 'id', 'type'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'CloseSubagentCallItemResource',
    minimal: jsonDecode(
      r'''{"type":"close_subagent_call","id":"item_synthetic","turn_id":"turn_child","status":"in_progress","sender_agent_id":"","recipient_agent_id":""}''',
    ),
    full: jsonDecode(
      r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCloseSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'status',
      'sender_agent_id',
      'recipient_agent_id',
    ],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'CommandExecutionItemResource',
    minimal: jsonDecode(
      r'''{"type":"command_execution","id":"item_synthetic","turn_id":"turn_child","command":"","cwd":null,"status":"in_progress","output":null,"exit_code":null,"duration_ms":null}''',
    ),
    full: jsonDecode(
      r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
    ),
    parse: (value) => AgentSessionCommandExecutionItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'command',
      'cwd',
      'status',
      'output',
      'exit_code',
      'duration_ms',
    ],
    nullableKeys: ['cwd', 'duration_ms', 'exit_code', 'output'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'ComputerScreenshotResource',
    minimal: jsonDecode(
      r'''{"type":"computer_screenshot","image_url":"data:image/jpeg;base64,UFJJVkFURQ=="}''',
    ),
    full: jsonDecode(
      r'''{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"computer_screenshot"}''',
    ),
    parse: (value) => AgentSessionComputerScreenshotResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'image_url'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'ComputerUseApprovalRequestResultItemResource',
    minimal: jsonDecode(
      r'''{"id":"item_synthetic","type":"computer_use_approval_request_result","turn_id":"turn_child","request_id":"","response":{"type":"browser_authentication","action":"submit","selected_option":null}}''',
    ),
    full: jsonDecode(
      r'''{"id":"item_synthetic","request_id":"PRIVATE-field-café🚀","response":{"action":"cancel","type":"browser_authentication"},"turn_id":"turn_child","type":"computer_use_approval_request_result"}''',
    ),
    parse: (value) =>
        AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    requiredKeys: ['id', 'type', 'turn_id', 'request_id', 'response'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'ComputerUseApprovalResponseKindResource',
    minimal: jsonDecode(
      r'''{"type":"browser_authentication","action":"submit","selected_option":null}''',
    ),
    full: jsonDecode(
      r'''{"action":"cancel","type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationResponseResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    requiredKeys: ['type', 'action'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema:
        'ComputerUseApprovalResponseKindResourceBrowserAuthenticationCancelResource',
    minimal: jsonDecode(
      r'''{"type":"browser_authentication","action":"cancel"}''',
    ),
    full: jsonDecode(
      r'''{"action":"cancel","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationCancelResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'action'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema:
        'ComputerUseApprovalResponseKindResourceBrowserAuthenticationSubmitResource',
    minimal: jsonDecode(
      r'''{"type":"browser_authentication","action":"submit","selected_option":null}''',
    ),
    full: jsonDecode(
      r'''{"action":"submit","selected_option":"PRIVATE-field-café🚀","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationSubmitResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'action', 'selected_option'],
    nullableKeys: ['selected_option'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'ComputerUseCallItemResource',
    minimal: jsonDecode(
      r'''{"type":"computer_use_call","id":"item_synthetic","turn_id":"turn_child","title":null,"status":"in_progress","output":null}''',
    ),
    full: jsonDecode(
      r'''{"id":"item_synthetic","output":{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"computer_screenshot"},"status":"incomplete","title":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_call"}''',
    ),
    parse: (value) => AgentSessionComputerUseCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'id', 'turn_id', 'title', 'status', 'output'],
    nullableKeys: ['output', 'title'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'CreateSubagentCallItemResource',
    minimal: jsonDecode(
      r'''{"type":"create_subagent_call","id":"item_synthetic","turn_id":"turn_child","status":"in_progress","agent_id":"subagent_child","content":[],"model":null,"reasoning_effort":null}''',
    ),
    full: jsonDecode(
      r'''{"agent_id":"subagent_child","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"create_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCreateSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'status',
      'agent_id',
      'content',
      'model',
      'reasoning_effort',
    ],
    nullableKeys: ['model', 'reasoning_effort'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'EncryptedContentResource',
    minimal: jsonDecode(
      r'''{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}''',
    ),
    full: jsonDecode(
      r'''{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}''',
    ),
    parse: (value) => AgentSessionEncryptedContentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'encrypted_content'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'ErrorBodyResource',
    minimal: jsonDecode(r'''{"type":"","code":"","message":"","param":null}'''),
    full: jsonDecode(
      r'''{"code":"PRIVATE-field-café🚀","message":"PRIVATE-field-café🚀","param":"PRIVATE-field-café🚀","type":"PRIVATE-field-café🚀"}''',
    ),
    parse: (value) => AgentErrorBody.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'code', 'message', 'param'],
    nullableKeys: ['param'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'ErrorResponse-2',
    minimal: jsonDecode(
      r'''{"error":{"type":"","code":"","message":"","param":null}}''',
    ),
    full: jsonDecode(
      r'''{"error":{"code":"PRIVATE-field-café🚀","message":"PRIVATE-field-café🚀","param":"PRIVATE-field-café🚀","type":"PRIVATE-field-café🚀"}}''',
    ),
    parse: (value) =>
        AgentErrorResponse.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['error'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'FunctionCallItemResource',
    minimal: jsonDecode(
      r'''{"type":"function_call","id":"item_synthetic","turn_id":"turn_child","call_id":"","name":"","arguments":"","status":"in_progress"}''',
    ),
    full: jsonDecode(
      r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","call_id":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"function_call"}''',
    ),
    parse: (value) => AgentSessionFunctionCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'call_id',
      'name',
      'arguments',
      'status',
    ],
    nullableKeys: ['arguments'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'FunctionCallOutputItemResource',
    minimal: jsonDecode(
      r'''{"id":"item_synthetic","turn_id":"turn_child","type":"function_call_output","call_id":"","status":"in_progress","output":null,"error":null}''',
    ),
    full: jsonDecode(
      r'''{"call_id":"PRIVATE-field-café🚀","error":"PRIVATE-field-café🚀","id":"item_synthetic","output":[{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}],"status":"incomplete","turn_id":"turn_child","type":"function_call_output"}''',
    ),
    parse: (value) => AgentSessionFunctionCallOutputItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [
      'id',
      'turn_id',
      'type',
      'call_id',
      'status',
      'output',
      'error',
    ],
    nullableKeys: ['error', 'output'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'FunctionCallOutputResource',
    minimal: jsonDecode(r'''""'''),
    full: jsonDecode(
      r'''[{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}]''',
    ),
    parse: AgentSessionFunctionOutputResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'FunctionCallStatusResource',
    minimal: jsonDecode(r'''"in_progress"'''),
    full: jsonDecode(r'''"incomplete"'''),
    parse: AgentSessionFunctionCallStatusResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'InputContentResource',
    minimal: jsonDecode(r'''{"type":"input_text","text":""}'''),
    full: jsonDecode(
      r'''{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}''',
    ),
    parse: (value) => AgentSessionInputContentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'image_url'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'InputContentResourceInputImage',
    minimal: jsonDecode(
      r'''{"type":"input_image","image_url":"data:image/jpeg;base64,UFJJVkFURQ=="}''',
    ),
    full: jsonDecode(
      r'''{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}''',
    ),
    parse: (value) => AgentSessionInputContentResourceInputImage.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'image_url'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'InputContentResourceInputText',
    minimal: jsonDecode(r'''{"type":"input_text","text":""}'''),
    full: jsonDecode(
      r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"input_text"}''',
    ),
    parse: (value) => AgentSessionInputContentResourceInputText.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'InputTokensDetailsResource-2',
    minimal: jsonDecode(r'''{"cached_tokens":0}'''),
    full: jsonDecode(r'''{"cached_tokens":2}'''),
    parse: (value) => AgentSessionInputTokensDetailsResourceDetails.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['cached_tokens'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'InterruptSubagentCallItemResource',
    minimal: jsonDecode(
      r'''{"type":"interrupt_subagent_call","id":"item_synthetic","turn_id":"turn_child","status":"in_progress","sender_agent_id":"","recipient_agent_id":""}''',
    ),
    full: jsonDecode(
      r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"interrupt_subagent_call"}''',
    ),
    parse: (value) => AgentSessionInterruptSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'status',
      'sender_agent_id',
      'recipient_agent_id',
    ],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'ListOrderParam',
    minimal: jsonDecode(r'''"asc"'''),
    full: jsonDecode(r'''"desc"'''),
    parse: AgentListOrder.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  SubagentWireFixture(
    schema: 'McpCallItemResource',
    minimal: jsonDecode(
      r'''{"type":"mcp_call","id":"item_synthetic","turn_id":"turn_child","server_label":"","name":"","arguments":"","status":"in_progress","output":null,"error":null}''',
    ),
    full: jsonDecode(
      r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
    ),
    parse: (value) => AgentSessionMcpCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'server_label',
      'name',
      'arguments',
      'status',
      'output',
      'error',
    ],
    nullableKeys: ['error', 'output', 'arguments', 'output', 'error'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'MessageContentResource',
    minimal: jsonDecode(r'''{"type":"input_text","text":""}'''),
    full: jsonDecode(
      r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}''',
    ),
    parse: (value) =>
        AgentSessionMessageContent.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'MessageContentResourceInputImage',
    minimal: jsonDecode(
      r'''{"type":"input_image","image_url":"data:image/jpeg;base64,UFJJVkFURQ=="}''',
    ),
    full: jsonDecode(
      r'''{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}''',
    ),
    parse: (value) => AgentSessionMessageContentResourceInputImage.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'image_url'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'MessageContentResourceInputText',
    minimal: jsonDecode(r'''{"type":"input_text","text":""}'''),
    full: jsonDecode(
      r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"input_text"}''',
    ),
    parse: (value) => AgentSessionMessageContentResourceInputText.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'MessageContentResourceOutputText',
    minimal: jsonDecode(r'''{"type":"output_text","text":""}'''),
    full: jsonDecode(
      r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}''',
    ),
    parse: (value) => AgentSessionMessageContentResourceOutputText.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'MessageItemResource',
    minimal: jsonDecode(
      r'''{"type":"message","id":null,"turn_id":"turn_child","role":"user","content":[],"status":"in_progress","phase":null}''',
    ),
    full: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}],"id":"item_synthetic","phase":"final_answer","role":"assistant","status":"incomplete","turn_id":"turn_child","type":"message"}''',
    ),
    parse: (value) => AgentSessionMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'role',
      'content',
      'status',
      'phase',
    ],
    nullableKeys: ['id', 'phase'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'MessagePhaseResource',
    minimal: jsonDecode(r'''"commentary"'''),
    full: jsonDecode(r'''"final_answer"'''),
    parse: AgentSessionMessagePhaseResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'OutputItemStatusResource',
    minimal: jsonDecode(r'''"in_progress"'''),
    full: jsonDecode(r'''"incomplete"'''),
    parse: AgentSessionOutputItemStatusResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'OutputTextResource',
    minimal: jsonDecode(r'''{"type":"output_text","text":""}'''),
    full: jsonDecode(
      r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}''',
    ),
    parse: (value) =>
        AgentSessionOutputTextResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'OutputTokensDetailsResource-2',
    minimal: jsonDecode(r'''{"reasoning_tokens":0}'''),
    full: jsonDecode(r'''{"reasoning_tokens":2}'''),
    parse: (value) => AgentSessionOutputTokensDetailsResourceDetails.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['reasoning_tokens'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'ReasoningItemResource',
    minimal: jsonDecode(
      r'''{"type":"reasoning","id":"item_synthetic","turn_id":"turn_child","summary":[],"status":null}''',
    ),
    full: jsonDecode(
      r'''{"id":"item_synthetic","status":"incomplete","summary":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"summary_text"}],"turn_id":"turn_child","type":"reasoning"}''',
    ),
    parse: (value) => AgentSessionReasoningItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'id', 'turn_id', 'summary', 'status'],
    nullableKeys: ['status'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'ResumeSubagentCallItemResource',
    minimal: jsonDecode(
      r'''{"type":"resume_subagent_call","id":"item_synthetic","turn_id":"turn_child","status":"in_progress","sender_agent_id":"","recipient_agent_id":""}''',
    ),
    full: jsonDecode(
      r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"resume_subagent_call"}''',
    ),
    parse: (value) => AgentSessionResumeSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'status',
      'sender_agent_id',
      'recipient_agent_id',
    ],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'SendSubagentInputCallItemResource',
    minimal: jsonDecode(
      r'''{"type":"send_subagent_input_call","id":"item_synthetic","turn_id":"turn_child","status":"in_progress","sender_agent_id":"","recipient_agent_id":"","content":[]}''',
    ),
    full: jsonDecode(
      r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"send_subagent_input_call"}''',
    ),
    parse: (value) => AgentSessionSendSubagentInputCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'status',
      'sender_agent_id',
      'recipient_agent_id',
      'content',
    ],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'SessionItemListResource',
    minimal: jsonDecode(
      r'''{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}''',
    ),
    full: jsonDecode(
      r'''{"data":[{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic","object":"list"}''',
    ),
    parse: (value) =>
        AgentSessionItemList.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['object', 'data', 'first_id', 'last_id', 'has_more'],
    nullableKeys: ['first_id', 'last_id'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'SessionMessageRoleResource',
    minimal: jsonDecode(r'''"user"'''),
    full: jsonDecode(r'''"assistant"'''),
    parse: AgentSessionMessageRoleResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'SessionTurnErrorCodeResource',
    minimal: jsonDecode(r'''"context_length_exceeded"'''),
    full: jsonDecode(r'''"internal_error"'''),
    parse: AgentSessionTurnErrorCodeResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'SessionTurnErrorResource',
    minimal: jsonDecode(r'''{"code":"context_length_exceeded","message":""}'''),
    full: jsonDecode(
      r'''{"code":"internal_error","message":"PRIVATE-field-café🚀"}''',
    ),
    parse: (value) =>
        AgentSessionTurnErrorResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['code', 'message'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'SessionTurnItemResource',
    minimal: jsonDecode(
      r'''{"type":"message","id":null,"turn_id":"turn_child","role":"user","content":[],"status":"in_progress","phase":null}''',
    ),
    full: jsonDecode(
      r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItem.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'status',
      'sender_agent_id',
      'recipient_agent_id',
    ],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'SessionTurnListResource',
    minimal: jsonDecode(
      r'''{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}''',
    ),
    full: jsonDecode(
      r'''{"data":[{"agent_id":"subagent_child","completed_at":2,"created_at":2,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":2,"status":"cancelled","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic","object":"list"}''',
    ),
    parse: (value) =>
        AgentSessionTurnList.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['object', 'data', 'first_id', 'last_id', 'has_more'],
    nullableKeys: ['first_id', 'last_id'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'SubagentObjectResource',
    minimal: jsonDecode(r'''"agent.session.subagent"'''),
    full: jsonDecode(r'''"agent.session.subagent"'''),
    parse: AgentSessionSubagentObjectResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'SubagentResource',
    minimal: jsonDecode(
      r'''{"id":"subagent_child","object":"agent.session.subagent","session_id":"session_synthetic","name":null,"instructions":null,"parent_agent_id":"root_agent","status":"active","opened_at":1,"closed_at":null}''',
    ),
    full: jsonDecode(
      r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
    ),
    parse: (value) =>
        AgentSessionSubagent.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'id',
      'object',
      'session_id',
      'name',
      'instructions',
      'parent_agent_id',
      'status',
      'opened_at',
      'closed_at',
    ],
    nullableKeys: ['closed_at', 'instructions', 'name'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'SubagentStatusResource',
    minimal: jsonDecode(r'''"active"'''),
    full: jsonDecode(r'''"closed"'''),
    parse: AgentSessionSubagentStatusResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'SummaryTextResource',
    minimal: jsonDecode(r'''{"type":"summary_text","text":""}'''),
    full: jsonDecode(
      r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"summary_text"}''',
    ),
    parse: (value) => AgentSessionSummaryTextResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'TokenUsageResource',
    minimal: jsonDecode(
      r'''{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}''',
    ),
    full: jsonDecode(
      r'''{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}''',
    ),
    parse: (value) =>
        AgentSessionTokenUsageResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'input_tokens',
      'input_tokens_details',
      'output_tokens',
      'output_tokens_details',
      'total_tokens',
    ],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'TurnObjectResource',
    minimal: jsonDecode(r'''"agent.session.turn"'''),
    full: jsonDecode(r'''"agent.session.turn"'''),
    parse: AgentSessionTurnObjectResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'TurnResource',
    minimal: jsonDecode(
      r'''{"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","agent_id":"subagent_child","subagent_id":"subagent_child","status":"queued","created_at":1,"started_at":null,"completed_at":null,"error":null,"usage":null}''',
    ),
    full: jsonDecode(
      r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
    ),
    parse: (value) => AgentSessionTurn.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'id',
      'object',
      'session_id',
      'agent_id',
      'subagent_id',
      'status',
      'created_at',
      'started_at',
      'completed_at',
      'error',
      'usage',
    ],
    nullableKeys: [
      'completed_at',
      'error',
      'started_at',
      'subagent_id',
      'usage',
    ],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'TurnStatusResource',
    minimal: jsonDecode(r'''"queued"'''),
    full: jsonDecode(r'''"cancelled"'''),
    parse: AgentSessionTurnStatusResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'WaitForSubagentsCallItemResource',
    minimal: jsonDecode(
      r'''{"type":"wait_for_subagents_call","id":"item_synthetic","turn_id":"turn_child","status":"in_progress","sender_agent_id":"","recipient_agent_ids":[]}''',
    ),
    full: jsonDecode(
      r'''{"id":"item_synthetic","recipient_agent_ids":["PRIVATE-field-café🚀"],"sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"wait_for_subagents_call"}''',
    ),
    parse: (value) => AgentSessionWaitForSubagentsCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'status',
      'sender_agent_id',
      'recipient_agent_ids',
    ],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'WebSearchActionResource',
    minimal: jsonDecode(r'''{"type":"search","query":null,"queries":null}'''),
    full: jsonDecode(r'''{"type":"other"}'''),
    parse: (value) => AgentSessionWebSearchActionResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'WebSearchActionResourceFindInPage',
    minimal: jsonDecode(
      r'''{"type":"find_in_page","url":null,"pattern":null}''',
    ),
    full: jsonDecode(
      r'''{"pattern":"PRIVATE-field-café🚀","type":"find_in_page","url":"https://private.example.test/login"}''',
    ),
    parse: (value) => AgentSessionWebSearchActionResourceFindInPage.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'url', 'pattern'],
    nullableKeys: ['pattern', 'url'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'WebSearchActionResourceOpenPage',
    minimal: jsonDecode(r'''{"type":"open_page","url":null}'''),
    full: jsonDecode(
      r'''{"type":"open_page","url":"https://private.example.test/login"}''',
    ),
    parse: (value) => AgentSessionWebSearchActionResourceOpenPage.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'url'],
    nullableKeys: ['url'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'WebSearchActionResourceOther',
    minimal: jsonDecode(r'''{"type":"other"}'''),
    full: jsonDecode(r'''{"type":"other"}'''),
    parse: (value) => AgentSessionWebSearchActionResourceOther.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'WebSearchActionResourceSearch',
    minimal: jsonDecode(r'''{"type":"search","query":null,"queries":null}'''),
    full: jsonDecode(
      r'''{"queries":["PRIVATE-field-café🚀"],"query":"PRIVATE-field-café🚀","type":"search"}''',
    ),
    parse: (value) => AgentSessionWebSearchActionResourceSearch.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'query', 'queries'],
    nullableKeys: ['queries', 'query'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema: 'WebSearchCallItemResource',
    minimal: jsonDecode(
      r'''{"type":"web_search_call","id":"item_synthetic","turn_id":"turn_child","status":"in_progress","action":null}''',
    ),
    full: jsonDecode(
      r'''{"action":{"type":"other"},"id":"item_synthetic","status":"incomplete","turn_id":"turn_child","type":"web_search_call"}''',
    ),
    parse: (value) => AgentSessionWebSearchCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'id', 'turn_id', 'status', 'action'],
    nullableKeys: ['action'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  SubagentWireFixture(
    schema:
        '#/paths/~1agents~1sessions~1{session_id}~1subagents/get/responses/200/content/application~1json/schema',
    minimal: jsonDecode(
      r'''{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}''',
    ),
    full: jsonDecode(
      r'''{"data":[{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"},{"id":"subagent_nested","object":"agent.session.subagent","session_id":"session_synthetic","name":null,"instructions":null,"parent_agent_id":"subagent_child","status":"active","opened_at":1,"closed_at":null}],"first_id":"subagent_child","has_more":true,"last_id":"subagent_nested","object":"list"}''',
    ),
    parse: (value) =>
        AgentSessionSubagentList.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['object', 'data', 'first_id', 'last_id', 'has_more'],
    nullableKeys: ['first_id', 'last_id'],
    optionalNonnullKeys: [],
    writable: false,
  ),
];

/// Source requirements and actual exported parser for one schema.
class SubagentWireFixture {
  const SubagentWireFixture({
    required this.schema,
    required this.minimal,
    required this.full,
    required this.parse,
    required this.requiredKeys,
    required this.nullableKeys,
    required this.optionalNonnullKeys,
    required this.writable,
  });
  final String schema;
  final Object? minimal;
  final Object? full;
  final AgentJsonModel Function(Object?) parse;
  final List<String> requiredKeys;
  final List<String> nullableKeys;
  final List<String> optionalNonnullKeys;
  final bool writable;
}

/// Real typed copies for every concrete fixture branch, including shared values.
AgentJsonModel copySubagentFixture(AgentJsonModel model) => switch (model) {
  final AgentErrorBody value => value.copyWith(),
  final AgentErrorResponse value => value.copyWith(),
  final AgentListOrder value => AgentListOrder.fromJson(value.toJson()),
  final AgentSessionAgentMessageItemResource value => value.copyWith(),
  final AgentSessionBrowserAuthenticationCancelResource value =>
    value.copyWith(),
  final AgentSessionBrowserAuthenticationField value => value.copyWith(),
  final AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication
  value =>
    value.copyWith(),
  final AgentSessionBrowserAuthenticationOption value => value.copyWith(),
  final AgentSessionBrowserAuthenticationRequestItemResource value =>
    value.copyWith(),
  final AgentSessionBrowserAuthenticationSubmitResource value =>
    value.copyWith(),
  final AgentSessionCloseSubagentCallItemResource value => value.copyWith(),
  final AgentSessionCommandExecutionItemResource value => value.copyWith(),
  final AgentSessionComputerScreenshotResource value => value.copyWith(),
  final AgentSessionComputerUseApprovalRequestResultItemResource value =>
    value.copyWith(),
  final AgentSessionComputerUseCallItemResource value => value.copyWith(),
  final AgentSessionCreateSubagentCallItemResource value => value.copyWith(),
  final AgentSessionEncryptedContentResource value => value.copyWith(),
  final AgentSessionFunctionCallItemResource value => value.copyWith(),
  final AgentSessionFunctionCallOutputItemResource value => value.copyWith(),
  final AgentSessionFunctionCallStatusResource value =>
    AgentSessionFunctionCallStatusResource.fromJson(value.toJson()),
  final AgentSessionFunctionOutputResource value =>
    AgentSessionFunctionOutputResource.fromJson(value.toJson()),
  final AgentSessionInputContentResourceInputImage value => value.copyWith(),
  final AgentSessionInputContentResourceInputText value => value.copyWith(),
  final AgentSessionInputTokensDetailsResourceDetails value => value.copyWith(),
  final AgentSessionInterruptSubagentCallItemResource value => value.copyWith(),
  final AgentSessionItemList value => value.copyWith(),
  final AgentSessionMcpCallItemResource value => value.copyWith(),
  final AgentSessionMessageContentResourceInputImage value => value.copyWith(),
  final AgentSessionMessageContentResourceInputText value => value.copyWith(),
  final AgentSessionMessageContentResourceOutputText value => value.copyWith(),
  final AgentSessionMessageItemResource value => value.copyWith(),
  final AgentSessionMessagePhaseResource value =>
    AgentSessionMessagePhaseResource.fromJson(value.toJson()),
  final AgentSessionMessageRoleResource value =>
    AgentSessionMessageRoleResource.fromJson(value.toJson()),
  final AgentSessionOutputItemStatusResource value =>
    AgentSessionOutputItemStatusResource.fromJson(value.toJson()),
  final AgentSessionOutputTextResource value => value.copyWith(),
  final AgentSessionOutputTokensDetailsResourceDetails value =>
    value.copyWith(),
  final AgentSessionReasoningItemResource value => value.copyWith(),
  final AgentSessionResumeSubagentCallItemResource value => value.copyWith(),
  final AgentSessionSendSubagentInputCallItemResource value => value.copyWith(),
  final AgentSessionSubagent value => value.copyWith(),
  final AgentSessionSubagentList value => value.copyWith(),
  final AgentSessionSubagentObjectResource value =>
    AgentSessionSubagentObjectResource.fromJson(value.toJson()),
  final AgentSessionSubagentStatusResource value =>
    AgentSessionSubagentStatusResource.fromJson(value.toJson()),
  final AgentSessionSummaryTextResource value => value.copyWith(),
  final AgentSessionTokenUsageResource value => value.copyWith(),
  final AgentSessionTurn value => value.copyWith(),
  final AgentSessionTurnErrorCodeResource value =>
    AgentSessionTurnErrorCodeResource.fromJson(value.toJson()),
  final AgentSessionTurnErrorResource value => value.copyWith(),
  final AgentSessionTurnList value => value.copyWith(),
  final AgentSessionTurnObjectResource value =>
    AgentSessionTurnObjectResource.fromJson(value.toJson()),
  final AgentSessionTurnStatusResource value =>
    AgentSessionTurnStatusResource.fromJson(value.toJson()),
  final AgentSessionWaitForSubagentsCallItemResource value => value.copyWith(),
  final AgentSessionWebSearchActionResourceFindInPage value => value.copyWith(),
  final AgentSessionWebSearchActionResourceOpenPage value => value.copyWith(),
  final AgentSessionWebSearchActionResourceOther value => value.copyWith(),
  final AgentSessionWebSearchActionResourceSearch value => value.copyWith(),
  final AgentSessionWebSearchCallItemResource value => value.copyWith(),
  _ => throw StateError('Unrecognized source fixture type'),
};
