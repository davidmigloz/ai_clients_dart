import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'AgentSessionAgentMessageItemResource.content: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionAgentMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"agent_message"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionAgentMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"type":"output_text","text":""}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"agent_message"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(content: replacement.content);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionAgentMessageItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionAgentMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"agent_message"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionAgentMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic_alternate","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"agent_message"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionAgentMessageItemResource.recipientAgentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionAgentMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"agent_message"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionAgentMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀_alternate","sender_agent_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"agent_message"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        recipientAgentId: replacement.recipientAgentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionAgentMessageItemResource.senderAgentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionAgentMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"agent_message"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionAgentMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀_alternate","turn_id":"turn_child","type":"agent_message"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        senderAgentId: replacement.senderAgentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionAgentMessageItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionAgentMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"agent_message"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionAgentMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","turn_id":"turn_child_alternate","type":"agent_message"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationField.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionBrowserAuthenticationField.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionBrowserAuthenticationField.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic_alternate","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationField.label: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionBrowserAuthenticationField.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionBrowserAuthenticationField.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","label":"PRIVATE-field-café🚀_alternate","required":true,"type":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(label: replacement.label);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationField.required: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionBrowserAuthenticationField.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionBrowserAuthenticationField.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":false,"type":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(required: replacement.required);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationField.type: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionBrowserAuthenticationField.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionBrowserAuthenticationField.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(type: replacement.type);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.credentialOrigin: replacement, full equality/hash and copy presence',
    () {
      final original =
          AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
            jsonDecode(
                  r'''{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"}''',
                )
                as Map<String, dynamic>,
          );
      final replacement =
          AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
            jsonDecode(
                  r'''{"credential_origin":"https://private.example.test/login_alternate","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"}''',
                )
                as Map<String, dynamic>,
          );
      final result = original.copyWith(
        credentialOrigin: replacement.credentialOrigin,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(credentialOrigin: null);
      expect(cleared.toJson().containsKey('credential_origin'), isTrue);
      expect(cleared.toJson()['credential_origin'], isNull);
      expect(
        () => original.copyWith(credentialOrigin: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fields: replacement, full equality/hash and copy presence',
    () {
      final original =
          AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
            jsonDecode(
                  r'''{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"}''',
                )
                as Map<String, dynamic>,
          );
      final replacement =
          AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
            jsonDecode(
                  r'''{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"","type":"","required":false}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"}''',
                )
                as Map<String, dynamic>,
          );
      final result = original.copyWith(fields: replacement.fields);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.options: replacement, full equality/hash and copy presence',
    () {
      final original =
          AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
            jsonDecode(
                  r'''{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"}''',
                )
                as Map<String, dynamic>,
          );
      final replacement =
          AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
            jsonDecode(
                  r'''{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"id":"item_synthetic","label":"","field_ids":[]}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"}''',
                )
                as Map<String, dynamic>,
          );
      final result = original.copyWith(options: replacement.options);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.reason: replacement, full equality/hash and copy presence',
    () {
      final original =
          AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
            jsonDecode(
                  r'''{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"}''',
                )
                as Map<String, dynamic>,
          );
      final replacement =
          AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
            jsonDecode(
                  r'''{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀_alternate","type":"browser_authentication"}''',
                )
                as Map<String, dynamic>,
          );
      final result = original.copyWith(reason: replacement.reason);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(reason: null);
      expect(cleared.toJson().containsKey('reason'), isTrue);
      expect(cleared.toJson()['reason'], isNull);
      expect(() => original.copyWith(reason: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionBrowserAuthenticationOption.fieldIds: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionBrowserAuthenticationOption.fromJson(
        jsonDecode(
              r'''{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionBrowserAuthenticationOption.fromJson(
        jsonDecode(
              r'''{"field_ids":["/workspace/next"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(fieldIds: replacement.fieldIds);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationOption.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionBrowserAuthenticationOption.fromJson(
        jsonDecode(
              r'''{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionBrowserAuthenticationOption.fromJson(
        jsonDecode(
              r'''{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic_alternate","label":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationOption.label: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionBrowserAuthenticationOption.fromJson(
        jsonDecode(
              r'''{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionBrowserAuthenticationOption.fromJson(
        jsonDecode(
              r'''{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(label: replacement.label);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationRequestItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original =
          AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request":{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"},"request_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_approval_request"}''',
                )
                as Map<String, dynamic>,
          );
      final replacement =
          AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic_alternate","request":{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"},"request_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_approval_request"}''',
                )
                as Map<String, dynamic>,
          );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationRequestItemResource.request: replacement, full equality/hash and copy presence',
    () {
      final original =
          AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request":{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"},"request_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_approval_request"}''',
                )
                as Map<String, dynamic>,
          );
      final replacement =
          AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request":{"type":"browser_authentication","reason":null,"credential_origin":null,"fields":[],"options":[]},"request_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_approval_request"}''',
                )
                as Map<String, dynamic>,
          );
      final result = original.copyWith(request: replacement.request);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationRequestItemResource.requestId: replacement, full equality/hash and copy presence',
    () {
      final original =
          AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request":{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"},"request_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_approval_request"}''',
                )
                as Map<String, dynamic>,
          );
      final replacement =
          AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request":{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"},"request_id":"PRIVATE-field-café🚀_alternate","turn_id":"turn_child","type":"computer_use_approval_request"}''',
                )
                as Map<String, dynamic>,
          );
      final result = original.copyWith(requestId: replacement.requestId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationRequestItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original =
          AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request":{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"},"request_id":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_approval_request"}''',
                )
                as Map<String, dynamic>,
          );
      final replacement =
          AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request":{"credential_origin":"https://private.example.test/login","fields":[{"id":"item_synthetic","label":"PRIVATE-field-café🚀","required":true,"type":"PRIVATE-field-café🚀"}],"options":[{"field_ids":["PRIVATE-field-café🚀"],"id":"item_synthetic","label":"PRIVATE-field-café🚀"}],"reason":"PRIVATE-field-café🚀","type":"browser_authentication"},"request_id":"PRIVATE-field-café🚀","turn_id":"turn_child_alternate","type":"computer_use_approval_request"}''',
                )
                as Map<String, dynamic>,
          );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCloseSubagentCallItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCloseSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCloseSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic_alternate","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCloseSubagentCallItemResource.recipientAgentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCloseSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCloseSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀_alternate","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        recipientAgentId: replacement.recipientAgentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCloseSubagentCallItemResource.senderAgentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCloseSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCloseSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀_alternate","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        senderAgentId: replacement.senderAgentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCloseSubagentCallItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCloseSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCloseSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"in_progress","turn_id":"turn_child","type":"close_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCloseSubagentCallItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCloseSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCloseSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child_alternate","type":"close_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.command: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀_alternate","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(command: replacement.command);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.cwd: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀_alternate","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(cwd: replacement.cwd);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(cwd: null);
      expect(cleared.toJson().containsKey('cwd'), isTrue);
      expect(cleared.toJson()['cwd'], isNull);
      expect(() => original.copyWith(cwd: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.durationMs: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":3,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(durationMs: replacement.durationMs);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(durationMs: null);
      expect(cleared.toJson().containsKey('duration_ms'), isTrue);
      expect(cleared.toJson()['duration_ms'], isNull);
      expect(
        () => original.copyWith(durationMs: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.exitCode: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":3,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(exitCode: replacement.exitCode);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(exitCode: null);
      expect(cleared.toJson().containsKey('exit_code'), isTrue);
      expect(cleared.toJson()['exit_code'], isNull);
      expect(
        () => original.copyWith(exitCode: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic_alternate","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.output: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀_alternate","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(output: replacement.output);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(output: null);
      expect(cleared.toJson().containsKey('output'), isTrue);
      expect(cleared.toJson()['output'], isNull);
      expect(() => original.copyWith(output: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"in_progress","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCommandExecutionItemResource.fromJson(
        jsonDecode(
              r'''{"command":"PRIVATE-field-café🚀","cwd":"PRIVATE-field-café🚀","duration_ms":2,"exit_code":2,"id":"item_synthetic","output":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child_alternate","type":"command_execution"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionComputerScreenshotResource.imageUrl: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionComputerScreenshotResource.fromJson(
        jsonDecode(
              r'''{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"computer_screenshot"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionComputerScreenshotResource.fromJson(
        jsonDecode(
              r'''{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==_alternate","type":"computer_screenshot"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(imageUrl: replacement.imageUrl);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionComputerUseApprovalRequestResultItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original =
          AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request_id":"PRIVATE-field-café🚀","response":{"action":"cancel","type":"browser_authentication"},"turn_id":"turn_child","type":"computer_use_approval_request_result"}''',
                )
                as Map<String, dynamic>,
          );
      final replacement =
          AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic_alternate","request_id":"PRIVATE-field-café🚀","response":{"action":"cancel","type":"browser_authentication"},"turn_id":"turn_child","type":"computer_use_approval_request_result"}''',
                )
                as Map<String, dynamic>,
          );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionComputerUseApprovalRequestResultItemResource.requestId: replacement, full equality/hash and copy presence',
    () {
      final original =
          AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request_id":"PRIVATE-field-café🚀","response":{"action":"cancel","type":"browser_authentication"},"turn_id":"turn_child","type":"computer_use_approval_request_result"}''',
                )
                as Map<String, dynamic>,
          );
      final replacement =
          AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request_id":"PRIVATE-field-café🚀_alternate","response":{"action":"cancel","type":"browser_authentication"},"turn_id":"turn_child","type":"computer_use_approval_request_result"}''',
                )
                as Map<String, dynamic>,
          );
      final result = original.copyWith(requestId: replacement.requestId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionComputerUseApprovalRequestResultItemResource.response: replacement, full equality/hash and copy presence',
    () {
      final original =
          AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request_id":"PRIVATE-field-café🚀","response":{"action":"cancel","type":"browser_authentication"},"turn_id":"turn_child","type":"computer_use_approval_request_result"}''',
                )
                as Map<String, dynamic>,
          );
      final replacement =
          AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request_id":"PRIVATE-field-café🚀","response":{"type":"browser_authentication","action":"submit","selected_option":null},"turn_id":"turn_child","type":"computer_use_approval_request_result"}''',
                )
                as Map<String, dynamic>,
          );
      final result = original.copyWith(response: replacement.response);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionComputerUseApprovalRequestResultItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original =
          AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request_id":"PRIVATE-field-café🚀","response":{"action":"cancel","type":"browser_authentication"},"turn_id":"turn_child","type":"computer_use_approval_request_result"}''',
                )
                as Map<String, dynamic>,
          );
      final replacement =
          AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
            jsonDecode(
                  r'''{"id":"item_synthetic","request_id":"PRIVATE-field-café🚀","response":{"action":"cancel","type":"browser_authentication"},"turn_id":"turn_child_alternate","type":"computer_use_approval_request_result"}''',
                )
                as Map<String, dynamic>,
          );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionBrowserAuthenticationSubmitResource.selectedOption: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionBrowserAuthenticationSubmitResource.fromJson(
        jsonDecode(
              r'''{"action":"submit","selected_option":"PRIVATE-field-café🚀","type":"browser_authentication"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionBrowserAuthenticationSubmitResource.fromJson(
        jsonDecode(
              r'''{"action":"submit","selected_option":"PRIVATE-field-café🚀_alternate","type":"browser_authentication"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        selectedOption: replacement.selectedOption,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(selectedOption: null);
      expect(cleared.toJson().containsKey('selected_option'), isTrue);
      expect(cleared.toJson()['selected_option'], isNull);
      expect(
        () => original.copyWith(selectedOption: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionComputerUseCallItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionComputerUseCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","output":{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"computer_screenshot"},"status":"incomplete","title":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionComputerUseCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic_alternate","output":{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"computer_screenshot"},"status":"incomplete","title":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionComputerUseCallItemResource.output: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionComputerUseCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","output":{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"computer_screenshot"},"status":"incomplete","title":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionComputerUseCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","output":{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==_alternate","type":"computer_screenshot"},"status":"incomplete","title":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(output: replacement.output);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(output: null);
      expect(cleared.toJson().containsKey('output'), isTrue);
      expect(cleared.toJson()['output'], isNull);
      expect(() => original.copyWith(output: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionComputerUseCallItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionComputerUseCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","output":{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"computer_screenshot"},"status":"incomplete","title":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionComputerUseCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","output":{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"computer_screenshot"},"status":"in_progress","title":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionComputerUseCallItemResource.title: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionComputerUseCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","output":{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"computer_screenshot"},"status":"incomplete","title":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionComputerUseCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","output":{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"computer_screenshot"},"status":"incomplete","title":"PRIVATE-field-café🚀_alternate","turn_id":"turn_child","type":"computer_use_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(title: replacement.title);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(title: null);
      expect(cleared.toJson().containsKey('title'), isTrue);
      expect(cleared.toJson()['title'], isNull);
      expect(() => original.copyWith(title: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionComputerUseCallItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionComputerUseCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","output":{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"computer_screenshot"},"status":"incomplete","title":"PRIVATE-field-café🚀","turn_id":"turn_child","type":"computer_use_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionComputerUseCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","output":{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"computer_screenshot"},"status":"incomplete","title":"PRIVATE-field-café🚀","turn_id":"turn_child_alternate","type":"computer_use_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCreateSubagentCallItemResource.agentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child_alternate","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(agentId: replacement.agentId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCreateSubagentCallItemResource.content: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","content":[{"type":"output_text","text":""}],"id":"item_synthetic","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(content: replacement.content);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCreateSubagentCallItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic_alternate","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCreateSubagentCallItemResource.model: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","model":"PRIVATE-field-café🚀_alternate","reasoning_effort":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(model: replacement.model);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(model: null);
      expect(cleared.toJson().containsKey('model'), isTrue);
      expect(cleared.toJson()['model'], isNull);
      expect(() => original.copyWith(model: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionCreateSubagentCallItemResource.reasoningEffort: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀_alternate","status":"incomplete","turn_id":"turn_child","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        reasoningEffort: replacement.reasoningEffort,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(reasoningEffort: null);
      expect(cleared.toJson().containsKey('reasoning_effort'), isTrue);
      expect(cleared.toJson()['reasoning_effort'], isNull);
      expect(
        () => original.copyWith(reasoningEffort: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionCreateSubagentCallItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀","status":"in_progress","turn_id":"turn_child","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionCreateSubagentCallItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionCreateSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","model":"PRIVATE-field-café🚀","reasoning_effort":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child_alternate","type":"create_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionEncryptedContentResource.encryptedContent: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionEncryptedContentResource.fromJson(
        jsonDecode(
              r'''{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionEncryptedContentResource.fromJson(
        jsonDecode(
              r'''{"encrypted_content":"PRIVATE-encrypted-opaque_alternate","type":"encrypted_content"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        encryptedContent: replacement.encryptedContent,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionFunctionCallItemResource.arguments: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionFunctionCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","call_id":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"function_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionFunctionCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":{"future":["PRIVATE-replacement",null]},"call_id":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"function_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(arguments: replacement.arguments);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionFunctionCallItemResource.callId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionFunctionCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","call_id":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"function_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionFunctionCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","call_id":"PRIVATE-field-café🚀_alternate","id":"item_synthetic","name":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"function_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(callId: replacement.callId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionFunctionCallItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionFunctionCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","call_id":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"function_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionFunctionCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","call_id":"PRIVATE-field-café🚀","id":"item_synthetic_alternate","name":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"function_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionFunctionCallItemResource.name: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionFunctionCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","call_id":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"function_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionFunctionCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","call_id":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀_alternate","status":"incomplete","turn_id":"turn_child","type":"function_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionFunctionCallItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionFunctionCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","call_id":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"function_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionFunctionCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","call_id":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","status":"in_progress","turn_id":"turn_child","type":"function_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionFunctionCallItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionFunctionCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","call_id":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"function_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionFunctionCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","call_id":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child_alternate","type":"function_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionFunctionCallOutputItemResource.callId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionFunctionCallOutputItemResource.fromJson(
        jsonDecode(
              r'''{"call_id":"PRIVATE-field-café🚀","error":"PRIVATE-field-café🚀","id":"item_synthetic","output":[{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}],"status":"incomplete","turn_id":"turn_child","type":"function_call_output"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionFunctionCallOutputItemResource.fromJson(
        jsonDecode(
              r'''{"call_id":"PRIVATE-field-café🚀_alternate","error":"PRIVATE-field-café🚀","id":"item_synthetic","output":[{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}],"status":"incomplete","turn_id":"turn_child","type":"function_call_output"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(callId: replacement.callId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionFunctionCallOutputItemResource.error: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionFunctionCallOutputItemResource.fromJson(
        jsonDecode(
              r'''{"call_id":"PRIVATE-field-café🚀","error":"PRIVATE-field-café🚀","id":"item_synthetic","output":[{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}],"status":"incomplete","turn_id":"turn_child","type":"function_call_output"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionFunctionCallOutputItemResource.fromJson(
        jsonDecode(
              r'''{"call_id":"PRIVATE-field-café🚀","error":"PRIVATE-field-café🚀_alternate","id":"item_synthetic","output":[{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}],"status":"incomplete","turn_id":"turn_child","type":"function_call_output"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(error: replacement.error);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(error: null);
      expect(cleared.toJson().containsKey('error'), isTrue);
      expect(cleared.toJson()['error'], isNull);
      expect(() => original.copyWith(error: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionFunctionCallOutputItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionFunctionCallOutputItemResource.fromJson(
        jsonDecode(
              r'''{"call_id":"PRIVATE-field-café🚀","error":"PRIVATE-field-café🚀","id":"item_synthetic","output":[{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}],"status":"incomplete","turn_id":"turn_child","type":"function_call_output"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionFunctionCallOutputItemResource.fromJson(
        jsonDecode(
              r'''{"call_id":"PRIVATE-field-café🚀","error":"PRIVATE-field-café🚀","id":"item_synthetic_alternate","output":[{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}],"status":"incomplete","turn_id":"turn_child","type":"function_call_output"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionFunctionCallOutputItemResource.output: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionFunctionCallOutputItemResource.fromJson(
        jsonDecode(
              r'''{"call_id":"PRIVATE-field-café🚀","error":"PRIVATE-field-café🚀","id":"item_synthetic","output":[{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}],"status":"incomplete","turn_id":"turn_child","type":"function_call_output"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionFunctionCallOutputItemResource.fromJson(
        jsonDecode(
              r'''{"call_id":"PRIVATE-field-café🚀","error":"PRIVATE-field-café🚀","id":"item_synthetic","output":"","status":"incomplete","turn_id":"turn_child","type":"function_call_output"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(output: replacement.output);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(output: null);
      expect(cleared.toJson().containsKey('output'), isTrue);
      expect(cleared.toJson()['output'], isNull);
      expect(() => original.copyWith(output: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionFunctionCallOutputItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionFunctionCallOutputItemResource.fromJson(
        jsonDecode(
              r'''{"call_id":"PRIVATE-field-café🚀","error":"PRIVATE-field-café🚀","id":"item_synthetic","output":[{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}],"status":"incomplete","turn_id":"turn_child","type":"function_call_output"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionFunctionCallOutputItemResource.fromJson(
        jsonDecode(
              r'''{"call_id":"PRIVATE-field-café🚀","error":"PRIVATE-field-café🚀","id":"item_synthetic","output":[{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}],"status":"in_progress","turn_id":"turn_child","type":"function_call_output"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionFunctionCallOutputItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionFunctionCallOutputItemResource.fromJson(
        jsonDecode(
              r'''{"call_id":"PRIVATE-field-café🚀","error":"PRIVATE-field-café🚀","id":"item_synthetic","output":[{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}],"status":"incomplete","turn_id":"turn_child","type":"function_call_output"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionFunctionCallOutputItemResource.fromJson(
        jsonDecode(
              r'''{"call_id":"PRIVATE-field-café🚀","error":"PRIVATE-field-café🚀","id":"item_synthetic","output":[{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}],"status":"incomplete","turn_id":"turn_child_alternate","type":"function_call_output"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionInputContentResourceInputImage.imageUrl: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionInputContentResourceInputImage.fromJson(
        jsonDecode(
              r'''{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionInputContentResourceInputImage.fromJson(
        jsonDecode(
              r'''{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==_alternate","type":"input_image"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(imageUrl: replacement.imageUrl);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionInputContentResourceInputText.text: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionInputContentResourceInputText.fromJson(
        jsonDecode(
              r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"input_text"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionInputContentResourceInputText.fromJson(
        jsonDecode(
              r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]_alternate","type":"input_text"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(text: replacement.text);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionInputTokensDetailsResourceDetails.cachedTokens: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionInputTokensDetailsResourceDetails.fromJson(
        jsonDecode(r'''{"cached_tokens":2}''') as Map<String, dynamic>,
      );
      final replacement =
          AgentSessionInputTokensDetailsResourceDetails.fromJson(
            jsonDecode(r'''{"cached_tokens":3}''') as Map<String, dynamic>,
          );
      final result = original.copyWith(cachedTokens: replacement.cachedTokens);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionInterruptSubagentCallItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionInterruptSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"interrupt_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionInterruptSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic_alternate","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"interrupt_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionInterruptSubagentCallItemResource.recipientAgentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionInterruptSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"interrupt_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionInterruptSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀_alternate","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"interrupt_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        recipientAgentId: replacement.recipientAgentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionInterruptSubagentCallItemResource.senderAgentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionInterruptSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"interrupt_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionInterruptSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀_alternate","status":"incomplete","turn_id":"turn_child","type":"interrupt_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        senderAgentId: replacement.senderAgentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionInterruptSubagentCallItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionInterruptSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"interrupt_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionInterruptSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"in_progress","turn_id":"turn_child","type":"interrupt_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionInterruptSubagentCallItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionInterruptSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"interrupt_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionInterruptSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child_alternate","type":"interrupt_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionMcpCallItemResource.arguments: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":{"future":["PRIVATE-replacement",null]},"error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(arguments: replacement.arguments);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionMcpCallItemResource.error: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":{"future":["PRIVATE-replacement",null]},"id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(error: replacement.error);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(error: null);
      expect(cleared.toJson().containsKey('error'), isTrue);
      expect(cleared.toJson()['error'], isNull);
      expect(() => original.copyWith(error: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionMcpCallItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic_alternate","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionMcpCallItemResource.name: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀_alternate","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionMcpCallItemResource.output: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":{"future":["PRIVATE-replacement",null]},"server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(output: replacement.output);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(output: null);
      expect(cleared.toJson().containsKey('output'), isTrue);
      expect(cleared.toJson()['output'], isNull);
      expect(() => original.copyWith(output: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionMcpCallItemResource.serverLabel: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀_alternate","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(serverLabel: replacement.serverLabel);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionMcpCallItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"in_progress","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionMcpCallItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMcpCallItemResource.fromJson(
        jsonDecode(
              r'''{"arguments":"{\"PRIVATE\":\"synthetic\"}","error":"PRIVATE-field-café🚀","id":"item_synthetic","name":"PRIVATE-field-café🚀","output":"PRIVATE-field-café🚀","server_label":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child_alternate","type":"mcp_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionMessageContentResourceInputImage.imageUrl: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMessageContentResourceInputImage.fromJson(
        jsonDecode(
              r'''{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==","type":"input_image"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMessageContentResourceInputImage.fromJson(
        jsonDecode(
              r'''{"image_url":"data:image/jpeg;base64,UFJJVkFURQ==_alternate","type":"input_image"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(imageUrl: replacement.imageUrl);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionMessageContentResourceInputText.text: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMessageContentResourceInputText.fromJson(
        jsonDecode(
              r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"input_text"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMessageContentResourceInputText.fromJson(
        jsonDecode(
              r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]_alternate","type":"input_text"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(text: replacement.text);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionMessageContentResourceOutputText.text: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMessageContentResourceOutputText.fromJson(
        jsonDecode(
              r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMessageContentResourceOutputText.fromJson(
        jsonDecode(
              r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]_alternate","type":"output_text"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(text: replacement.text);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionMessageItemResource.content: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}],"id":"item_synthetic","phase":"final_answer","role":"assistant","status":"incomplete","turn_id":"turn_child","type":"message"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"type":"input_text","text":""}],"id":"item_synthetic","phase":"final_answer","role":"assistant","status":"incomplete","turn_id":"turn_child","type":"message"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(content: replacement.content);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionMessageItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}],"id":"item_synthetic","phase":"final_answer","role":"assistant","status":"incomplete","turn_id":"turn_child","type":"message"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}],"id":"item_synthetic_alternate","phase":"final_answer","role":"assistant","status":"incomplete","turn_id":"turn_child","type":"message"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(id: null);
      expect(cleared.toJson().containsKey('id'), isTrue);
      expect(cleared.toJson()['id'], isNull);
      expect(() => original.copyWith(id: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionMessageItemResource.phase: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}],"id":"item_synthetic","phase":"final_answer","role":"assistant","status":"incomplete","turn_id":"turn_child","type":"message"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}],"id":"item_synthetic","phase":"commentary","role":"assistant","status":"incomplete","turn_id":"turn_child","type":"message"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(phase: replacement.phase);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(phase: null);
      expect(cleared.toJson().containsKey('phase'), isTrue);
      expect(cleared.toJson()['phase'], isNull);
      expect(() => original.copyWith(phase: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionMessageItemResource.role: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}],"id":"item_synthetic","phase":"final_answer","role":"assistant","status":"incomplete","turn_id":"turn_child","type":"message"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}],"id":"item_synthetic","phase":"final_answer","role":"user","status":"incomplete","turn_id":"turn_child","type":"message"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(role: replacement.role);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionMessageItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}],"id":"item_synthetic","phase":"final_answer","role":"assistant","status":"incomplete","turn_id":"turn_child","type":"message"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}],"id":"item_synthetic","phase":"final_answer","role":"assistant","status":"in_progress","turn_id":"turn_child","type":"message"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionMessageItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}],"id":"item_synthetic","phase":"final_answer","role":"assistant","status":"incomplete","turn_id":"turn_child","type":"message"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionMessageItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}],"id":"item_synthetic","phase":"final_answer","role":"assistant","status":"incomplete","turn_id":"turn_child_alternate","type":"message"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionOutputTextResource.text: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionOutputTextResource.fromJson(
        jsonDecode(
              r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"output_text"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionOutputTextResource.fromJson(
        jsonDecode(
              r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]_alternate","type":"output_text"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(text: replacement.text);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionOutputTokensDetailsResourceDetails.reasoningTokens: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionOutputTokensDetailsResourceDetails.fromJson(
        jsonDecode(r'''{"reasoning_tokens":2}''') as Map<String, dynamic>,
      );
      final replacement =
          AgentSessionOutputTokensDetailsResourceDetails.fromJson(
            jsonDecode(r'''{"reasoning_tokens":3}''') as Map<String, dynamic>,
          );
      final result = original.copyWith(
        reasoningTokens: replacement.reasoningTokens,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionReasoningItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionReasoningItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","status":"incomplete","summary":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"summary_text"}],"turn_id":"turn_child","type":"reasoning"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionReasoningItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic_alternate","status":"incomplete","summary":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"summary_text"}],"turn_id":"turn_child","type":"reasoning"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionReasoningItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionReasoningItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","status":"incomplete","summary":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"summary_text"}],"turn_id":"turn_child","type":"reasoning"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionReasoningItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","status":"in_progress","summary":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"summary_text"}],"turn_id":"turn_child","type":"reasoning"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(status: null);
      expect(cleared.toJson().containsKey('status'), isTrue);
      expect(cleared.toJson()['status'], isNull);
      expect(() => original.copyWith(status: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionReasoningItemResource.summary: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionReasoningItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","status":"incomplete","summary":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"summary_text"}],"turn_id":"turn_child","type":"reasoning"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionReasoningItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","status":"incomplete","summary":[{"type":"summary_text","text":""}],"turn_id":"turn_child","type":"reasoning"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(summary: replacement.summary);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionReasoningItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionReasoningItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","status":"incomplete","summary":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"summary_text"}],"turn_id":"turn_child","type":"reasoning"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionReasoningItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","status":"incomplete","summary":[{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"summary_text"}],"turn_id":"turn_child_alternate","type":"reasoning"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionResumeSubagentCallItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionResumeSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"resume_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionResumeSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic_alternate","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"resume_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionResumeSubagentCallItemResource.recipientAgentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionResumeSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"resume_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionResumeSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀_alternate","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"resume_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        recipientAgentId: replacement.recipientAgentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionResumeSubagentCallItemResource.senderAgentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionResumeSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"resume_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionResumeSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀_alternate","status":"incomplete","turn_id":"turn_child","type":"resume_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        senderAgentId: replacement.senderAgentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionResumeSubagentCallItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionResumeSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"resume_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionResumeSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"in_progress","turn_id":"turn_child","type":"resume_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionResumeSubagentCallItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionResumeSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"resume_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionResumeSubagentCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child_alternate","type":"resume_subagent_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSendSubagentInputCallItemResource.content: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSendSubagentInputCallItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"send_subagent_input_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSendSubagentInputCallItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"type":"output_text","text":""}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"send_subagent_input_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(content: replacement.content);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSendSubagentInputCallItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSendSubagentInputCallItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"send_subagent_input_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSendSubagentInputCallItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic_alternate","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"send_subagent_input_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSendSubagentInputCallItemResource.recipientAgentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSendSubagentInputCallItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"send_subagent_input_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSendSubagentInputCallItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀_alternate","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"send_subagent_input_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        recipientAgentId: replacement.recipientAgentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSendSubagentInputCallItemResource.senderAgentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSendSubagentInputCallItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"send_subagent_input_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSendSubagentInputCallItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀_alternate","status":"incomplete","turn_id":"turn_child","type":"send_subagent_input_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        senderAgentId: replacement.senderAgentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSendSubagentInputCallItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSendSubagentInputCallItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"send_subagent_input_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSendSubagentInputCallItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"in_progress","turn_id":"turn_child","type":"send_subagent_input_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSendSubagentInputCallItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSendSubagentInputCallItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"send_subagent_input_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSendSubagentInputCallItemResource.fromJson(
        jsonDecode(
              r'''{"content":[{"encrypted_content":"PRIVATE-encrypted-opaque","type":"encrypted_content"}],"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child_alternate","type":"send_subagent_input_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionItemList.data: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionItemList.fromJson(
        jsonDecode(
              r'''{"data":[{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionItemList.fromJson(
        jsonDecode(
              r'''{"data":[{"type":"message","id":null,"turn_id":"turn_child","role":"user","content":[],"status":"in_progress","phase":null}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(data: replacement.data);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionItemList.firstId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionItemList.fromJson(
        jsonDecode(
              r'''{"data":[{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionItemList.fromJson(
        jsonDecode(
              r'''{"data":[{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}],"first_id":"item_synthetic_alternate","has_more":true,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(firstId: replacement.firstId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(firstId: null);
      expect(cleared.toJson().containsKey('first_id'), isTrue);
      expect(cleared.toJson()['first_id'], isNull);
      expect(() => original.copyWith(firstId: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionItemList.hasMore: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionItemList.fromJson(
        jsonDecode(
              r'''{"data":[{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionItemList.fromJson(
        jsonDecode(
              r'''{"data":[{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}],"first_id":"item_synthetic","has_more":false,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(hasMore: replacement.hasMore);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionItemList.lastId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionItemList.fromJson(
        jsonDecode(
              r'''{"data":[{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionItemList.fromJson(
        jsonDecode(
              r'''{"data":[{"id":"item_synthetic","recipient_agent_id":"PRIVATE-field-café🚀","sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"close_subagent_call"}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic_alternate","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(lastId: replacement.lastId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(lastId: null);
      expect(cleared.toJson().containsKey('last_id'), isTrue);
      expect(cleared.toJson()['last_id'], isNull);
      expect(() => original.copyWith(lastId: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionTurnErrorResource.code: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurnErrorResource.fromJson(
        jsonDecode(
              r'''{"code":"internal_error","message":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurnErrorResource.fromJson(
        jsonDecode(
              r'''{"code":"context_length_exceeded","message":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(code: replacement.code);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTurnErrorResource.message: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurnErrorResource.fromJson(
        jsonDecode(
              r'''{"code":"internal_error","message":"PRIVATE-field-café🚀"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurnErrorResource.fromJson(
        jsonDecode(
              r'''{"code":"internal_error","message":"PRIVATE-field-café🚀_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(message: replacement.message);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTurnList.data: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurnList.fromJson(
        jsonDecode(
              r'''{"data":[{"agent_id":"subagent_child","completed_at":2,"created_at":2,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":2,"status":"cancelled","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurnList.fromJson(
        jsonDecode(
              r'''{"data":[{"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","agent_id":"subagent_child","subagent_id":"subagent_child","status":"queued","created_at":1,"started_at":null,"completed_at":null,"error":null,"usage":null}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(data: replacement.data);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTurnList.firstId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurnList.fromJson(
        jsonDecode(
              r'''{"data":[{"agent_id":"subagent_child","completed_at":2,"created_at":2,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":2,"status":"cancelled","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurnList.fromJson(
        jsonDecode(
              r'''{"data":[{"agent_id":"subagent_child","completed_at":2,"created_at":2,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":2,"status":"cancelled","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}],"first_id":"item_synthetic_alternate","has_more":true,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(firstId: replacement.firstId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(firstId: null);
      expect(cleared.toJson().containsKey('first_id'), isTrue);
      expect(cleared.toJson()['first_id'], isNull);
      expect(() => original.copyWith(firstId: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionTurnList.hasMore: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurnList.fromJson(
        jsonDecode(
              r'''{"data":[{"agent_id":"subagent_child","completed_at":2,"created_at":2,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":2,"status":"cancelled","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurnList.fromJson(
        jsonDecode(
              r'''{"data":[{"agent_id":"subagent_child","completed_at":2,"created_at":2,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":2,"status":"cancelled","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}],"first_id":"item_synthetic","has_more":false,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(hasMore: replacement.hasMore);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTurnList.lastId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurnList.fromJson(
        jsonDecode(
              r'''{"data":[{"agent_id":"subagent_child","completed_at":2,"created_at":2,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":2,"status":"cancelled","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurnList.fromJson(
        jsonDecode(
              r'''{"data":[{"agent_id":"subagent_child","completed_at":2,"created_at":2,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":2,"status":"cancelled","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}],"first_id":"item_synthetic","has_more":true,"last_id":"item_synthetic_alternate","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(lastId: replacement.lastId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(lastId: null);
      expect(cleared.toJson().containsKey('last_id'), isTrue);
      expect(cleared.toJson()['last_id'], isNull);
      expect(() => original.copyWith(lastId: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionSubagent.closedAt: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":3,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(closedAt: replacement.closedAt);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(closedAt: null);
      expect(cleared.toJson().containsKey('closed_at'), isTrue);
      expect(cleared.toJson()['closed_at'], isNull);
      expect(
        () => original.copyWith(closedAt: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionSubagent.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child_alternate","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSubagent.instructions: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":""}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(instructions: replacement.instructions);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(instructions: null);
      expect(cleared.toJson().containsKey('instructions'), isTrue);
      expect(cleared.toJson()['instructions'], isNull);
      expect(
        () => original.copyWith(instructions: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionSubagent.name: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀_alternate","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(name: null);
      expect(cleared.toJson().containsKey('name'), isTrue);
      expect(cleared.toJson()['name'], isNull);
      expect(() => original.copyWith(name: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionSubagent.openedAt: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":2,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(openedAt: replacement.openedAt);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSubagent.parentAgentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent_alternate","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        parentAgentId: replacement.parentAgentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSubagent.sessionId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic_alternate","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(sessionId: replacement.sessionId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSubagent.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSubagent.fromJson(
        jsonDecode(
              r'''{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"active"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSummaryTextResource.text: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSummaryTextResource.fromJson(
        jsonDecode(
              r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]","type":"summary_text"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSummaryTextResource.fromJson(
        jsonDecode(
              r'''{"text":"PRIVATE-task-café🚀 [image preview] [audio preview]_alternate","type":"summary_text"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(text: replacement.text);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTokenUsageResource.inputTokens: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTokenUsageResource.fromJson(
        jsonDecode(
              r'''{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTokenUsageResource.fromJson(
        jsonDecode(
              r'''{"input_tokens":3,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(inputTokens: replacement.inputTokens);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTokenUsageResource.inputTokensDetails: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTokenUsageResource.fromJson(
        jsonDecode(
              r'''{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTokenUsageResource.fromJson(
        jsonDecode(
              r'''{"input_tokens":2,"input_tokens_details":{"cached_tokens":0},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        inputTokensDetails: replacement.inputTokensDetails,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTokenUsageResource.outputTokens: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTokenUsageResource.fromJson(
        jsonDecode(
              r'''{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTokenUsageResource.fromJson(
        jsonDecode(
              r'''{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":3,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(outputTokens: replacement.outputTokens);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTokenUsageResource.outputTokensDetails: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTokenUsageResource.fromJson(
        jsonDecode(
              r'''{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTokenUsageResource.fromJson(
        jsonDecode(
              r'''{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":2}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        outputTokensDetails: replacement.outputTokensDetails,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTokenUsageResource.totalTokens: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTokenUsageResource.fromJson(
        jsonDecode(
              r'''{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTokenUsageResource.fromJson(
        jsonDecode(
              r'''{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":3}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(totalTokens: replacement.totalTokens);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTurn.agentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child_alternate","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(agentId: replacement.agentId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTurn.completedAt: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":3,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(completedAt: replacement.completedAt);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(completedAt: null);
      expect(cleared.toJson().containsKey('completed_at'), isTrue);
      expect(cleared.toJson()['completed_at'], isNull);
      expect(
        () => original.copyWith(completedAt: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionTurn.createdAt: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":2,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(createdAt: replacement.createdAt);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTurn.error: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"context_length_exceeded","message":""},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(error: replacement.error);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(error: null);
      expect(cleared.toJson().containsKey('error'), isTrue);
      expect(cleared.toJson()['error'], isNull);
      expect(() => original.copyWith(error: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionTurn.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child_alternate","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTurn.sessionId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic_alternate","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(sessionId: replacement.sessionId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTurn.startedAt: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":2,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(startedAt: replacement.startedAt);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(startedAt: null);
      expect(cleared.toJson().containsKey('started_at'), isTrue);
      expect(cleared.toJson()['started_at'], isNull);
      expect(
        () => original.copyWith(startedAt: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionTurn.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"queued","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionTurn.subagentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child_alternate","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(subagentId: replacement.subagentId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(subagentId: null);
      expect(cleared.toJson().containsKey('subagent_id'), isTrue);
      expect(cleared.toJson()['subagent_id'], isNull);
      expect(
        () => original.copyWith(subagentId: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionTurn.usage: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":2,"input_tokens_details":{"cached_tokens":2},"output_tokens":2,"output_tokens_details":{"reasoning_tokens":2},"total_tokens":2}}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionTurn.fromJson(
        jsonDecode(
              r'''{"agent_id":"subagent_child","completed_at":2,"created_at":1,"error":{"code":"internal_error","message":"PRIVATE-field-café🚀"},"id":"turn_child","object":"agent.session.turn","session_id":"session_synthetic","started_at":1,"status":"failed","subagent_id":"subagent_child","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(usage: replacement.usage);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(usage: null);
      expect(cleared.toJson().containsKey('usage'), isTrue);
      expect(cleared.toJson()['usage'], isNull);
      expect(() => original.copyWith(usage: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionWaitForSubagentsCallItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWaitForSubagentsCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_ids":["PRIVATE-field-café🚀"],"sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"wait_for_subagents_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWaitForSubagentsCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic_alternate","recipient_agent_ids":["PRIVATE-field-café🚀"],"sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"wait_for_subagents_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionWaitForSubagentsCallItemResource.recipientAgentIds: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWaitForSubagentsCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_ids":["PRIVATE-field-café🚀"],"sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"wait_for_subagents_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWaitForSubagentsCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_ids":["/workspace/next"],"sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"wait_for_subagents_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        recipientAgentIds: replacement.recipientAgentIds,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionWaitForSubagentsCallItemResource.senderAgentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWaitForSubagentsCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_ids":["PRIVATE-field-café🚀"],"sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"wait_for_subagents_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWaitForSubagentsCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_ids":["PRIVATE-field-café🚀"],"sender_agent_id":"PRIVATE-field-café🚀_alternate","status":"incomplete","turn_id":"turn_child","type":"wait_for_subagents_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        senderAgentId: replacement.senderAgentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionWaitForSubagentsCallItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWaitForSubagentsCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_ids":["PRIVATE-field-café🚀"],"sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"wait_for_subagents_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWaitForSubagentsCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_ids":["PRIVATE-field-café🚀"],"sender_agent_id":"PRIVATE-field-café🚀","status":"in_progress","turn_id":"turn_child","type":"wait_for_subagents_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionWaitForSubagentsCallItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWaitForSubagentsCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_ids":["PRIVATE-field-café🚀"],"sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child","type":"wait_for_subagents_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWaitForSubagentsCallItemResource.fromJson(
        jsonDecode(
              r'''{"id":"item_synthetic","recipient_agent_ids":["PRIVATE-field-café🚀"],"sender_agent_id":"PRIVATE-field-café🚀","status":"incomplete","turn_id":"turn_child_alternate","type":"wait_for_subagents_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionWebSearchActionResourceFindInPage.pattern: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWebSearchActionResourceFindInPage.fromJson(
        jsonDecode(
              r'''{"pattern":"PRIVATE-field-café🚀","type":"find_in_page","url":"https://private.example.test/login"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWebSearchActionResourceFindInPage.fromJson(
        jsonDecode(
              r'''{"pattern":"PRIVATE-field-café🚀_alternate","type":"find_in_page","url":"https://private.example.test/login"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(pattern: replacement.pattern);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(pattern: null);
      expect(cleared.toJson().containsKey('pattern'), isTrue);
      expect(cleared.toJson()['pattern'], isNull);
      expect(() => original.copyWith(pattern: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionWebSearchActionResourceFindInPage.url: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWebSearchActionResourceFindInPage.fromJson(
        jsonDecode(
              r'''{"pattern":"PRIVATE-field-café🚀","type":"find_in_page","url":"https://private.example.test/login"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWebSearchActionResourceFindInPage.fromJson(
        jsonDecode(
              r'''{"pattern":"PRIVATE-field-café🚀","type":"find_in_page","url":"https://private.example.test/login_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(url: replacement.url);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(url: null);
      expect(cleared.toJson().containsKey('url'), isTrue);
      expect(cleared.toJson()['url'], isNull);
      expect(() => original.copyWith(url: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionWebSearchActionResourceOpenPage.url: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWebSearchActionResourceOpenPage.fromJson(
        jsonDecode(
              r'''{"type":"open_page","url":"https://private.example.test/login"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWebSearchActionResourceOpenPage.fromJson(
        jsonDecode(
              r'''{"type":"open_page","url":"https://private.example.test/login_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(url: replacement.url);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(url: null);
      expect(cleared.toJson().containsKey('url'), isTrue);
      expect(cleared.toJson()['url'], isNull);
      expect(() => original.copyWith(url: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionWebSearchActionResourceSearch.queries: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWebSearchActionResourceSearch.fromJson(
        jsonDecode(
              r'''{"queries":["PRIVATE-field-café🚀"],"query":"PRIVATE-field-café🚀","type":"search"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWebSearchActionResourceSearch.fromJson(
        jsonDecode(
              r'''{"queries":["/workspace/next"],"query":"PRIVATE-field-café🚀","type":"search"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(queries: replacement.queries);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(queries: null);
      expect(cleared.toJson().containsKey('queries'), isTrue);
      expect(cleared.toJson()['queries'], isNull);
      expect(() => original.copyWith(queries: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionWebSearchActionResourceSearch.query: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWebSearchActionResourceSearch.fromJson(
        jsonDecode(
              r'''{"queries":["PRIVATE-field-café🚀"],"query":"PRIVATE-field-café🚀","type":"search"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWebSearchActionResourceSearch.fromJson(
        jsonDecode(
              r'''{"queries":["PRIVATE-field-café🚀"],"query":"PRIVATE-field-café🚀_alternate","type":"search"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(query: replacement.query);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(query: null);
      expect(cleared.toJson().containsKey('query'), isTrue);
      expect(cleared.toJson()['query'], isNull);
      expect(() => original.copyWith(query: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionWebSearchCallItemResource.action: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWebSearchCallItemResource.fromJson(
        jsonDecode(
              r'''{"action":{"type":"other"},"id":"item_synthetic","status":"incomplete","turn_id":"turn_child","type":"web_search_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWebSearchCallItemResource.fromJson(
        jsonDecode(
              r'''{"action":{"type":"search","query":null,"queries":null},"id":"item_synthetic","status":"incomplete","turn_id":"turn_child","type":"web_search_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(action: replacement.action);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(action: null);
      expect(cleared.toJson().containsKey('action'), isTrue);
      expect(cleared.toJson()['action'], isNull);
      expect(() => original.copyWith(action: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionWebSearchCallItemResource.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWebSearchCallItemResource.fromJson(
        jsonDecode(
              r'''{"action":{"type":"other"},"id":"item_synthetic","status":"incomplete","turn_id":"turn_child","type":"web_search_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWebSearchCallItemResource.fromJson(
        jsonDecode(
              r'''{"action":{"type":"other"},"id":"item_synthetic_alternate","status":"incomplete","turn_id":"turn_child","type":"web_search_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionWebSearchCallItemResource.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWebSearchCallItemResource.fromJson(
        jsonDecode(
              r'''{"action":{"type":"other"},"id":"item_synthetic","status":"incomplete","turn_id":"turn_child","type":"web_search_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWebSearchCallItemResource.fromJson(
        jsonDecode(
              r'''{"action":{"type":"other"},"id":"item_synthetic","status":"in_progress","turn_id":"turn_child","type":"web_search_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionWebSearchCallItemResource.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionWebSearchCallItemResource.fromJson(
        jsonDecode(
              r'''{"action":{"type":"other"},"id":"item_synthetic","status":"incomplete","turn_id":"turn_child","type":"web_search_call"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionWebSearchCallItemResource.fromJson(
        jsonDecode(
              r'''{"action":{"type":"other"},"id":"item_synthetic","status":"incomplete","turn_id":"turn_child_alternate","type":"web_search_call"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSubagentList.data: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSubagentList.fromJson(
        jsonDecode(
              r'''{"data":[{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"},{"id":"subagent_nested","object":"agent.session.subagent","session_id":"session_synthetic","name":null,"instructions":null,"parent_agent_id":"subagent_child","status":"active","opened_at":1,"closed_at":null}],"first_id":"subagent_child","has_more":true,"last_id":"subagent_nested","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSubagentList.fromJson(
        jsonDecode(
              r'''{"data":[{"id":"subagent_child","object":"agent.session.subagent","session_id":"session_synthetic","name":null,"instructions":null,"parent_agent_id":"root_agent","status":"active","opened_at":1,"closed_at":null}],"first_id":"subagent_child","has_more":true,"last_id":"subagent_nested","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(data: replacement.data);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSubagentList.firstId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSubagentList.fromJson(
        jsonDecode(
              r'''{"data":[{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"},{"id":"subagent_nested","object":"agent.session.subagent","session_id":"session_synthetic","name":null,"instructions":null,"parent_agent_id":"subagent_child","status":"active","opened_at":1,"closed_at":null}],"first_id":"subagent_child","has_more":true,"last_id":"subagent_nested","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSubagentList.fromJson(
        jsonDecode(
              r'''{"data":[{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"},{"id":"subagent_nested","object":"agent.session.subagent","session_id":"session_synthetic","name":null,"instructions":null,"parent_agent_id":"subagent_child","status":"active","opened_at":1,"closed_at":null}],"first_id":"subagent_child_alternate","has_more":true,"last_id":"subagent_nested","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(firstId: replacement.firstId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(firstId: null);
      expect(cleared.toJson().containsKey('first_id'), isTrue);
      expect(cleared.toJson()['first_id'], isNull);
      expect(() => original.copyWith(firstId: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionSubagentList.hasMore: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSubagentList.fromJson(
        jsonDecode(
              r'''{"data":[{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"},{"id":"subagent_nested","object":"agent.session.subagent","session_id":"session_synthetic","name":null,"instructions":null,"parent_agent_id":"subagent_child","status":"active","opened_at":1,"closed_at":null}],"first_id":"subagent_child","has_more":true,"last_id":"subagent_nested","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSubagentList.fromJson(
        jsonDecode(
              r'''{"data":[{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"},{"id":"subagent_nested","object":"agent.session.subagent","session_id":"session_synthetic","name":null,"instructions":null,"parent_agent_id":"subagent_child","status":"active","opened_at":1,"closed_at":null}],"first_id":"subagent_child","has_more":false,"last_id":"subagent_nested","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(hasMore: replacement.hasMore);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSubagentList.lastId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSubagentList.fromJson(
        jsonDecode(
              r'''{"data":[{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"},{"id":"subagent_nested","object":"agent.session.subagent","session_id":"session_synthetic","name":null,"instructions":null,"parent_agent_id":"subagent_child","status":"active","opened_at":1,"closed_at":null}],"first_id":"subagent_child","has_more":true,"last_id":"subagent_nested","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSubagentList.fromJson(
        jsonDecode(
              r'''{"data":[{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"},{"id":"subagent_nested","object":"agent.session.subagent","session_id":"session_synthetic","name":null,"instructions":null,"parent_agent_id":"subagent_child","status":"active","opened_at":1,"closed_at":null}],"first_id":"subagent_child","has_more":true,"last_id":"subagent_nested_alternate","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(lastId: replacement.lastId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(lastId: null);
      expect(cleared.toJson().containsKey('last_id'), isTrue);
      expect(cleared.toJson()['last_id'], isNull);
      expect(() => original.copyWith(lastId: Object()), throwsFormatException);
    },
  );
}
