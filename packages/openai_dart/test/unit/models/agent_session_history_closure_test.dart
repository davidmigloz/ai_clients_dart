import 'dart:convert';
import 'package:test/test.dart';
import '../fixtures/agent_session_history_fixtures.dart';
import '../fixtures/agent_session_wire_fixtures.dart';

void main() {
  const schemas = [
    'AgentContentResource',
    'AgentMessageItemResource',
    'BrowserAuthenticationFieldResource',
    'BrowserAuthenticationHistoryRequestKindResource',
    'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication',
    'BrowserAuthenticationOptionResource',
    'BrowserAuthenticationRequestItemResource',
    'CloseSubagentCallItemResource',
    'CommandExecutionItemResource',
    'ComputerScreenshotResource',
    'ComputerUseApprovalRequestResultItemResource',
    'ComputerUseApprovalResponseKindResource',
    'ComputerUseApprovalResponseKindResourceBrowserAuthenticationCancelResource',
    'ComputerUseApprovalResponseKindResourceBrowserAuthenticationSubmitResource',
    'ComputerUseCallItemResource',
    'CreateSubagentCallItemResource',
    'EncryptedContentResource',
    'ErrorBodyResource',
    'ErrorResponse-2',
    'FunctionCallItemResource',
    'FunctionCallOutputItemResource',
    'FunctionCallOutputResource',
    'FunctionCallStatusResource',
    'InputContentResource',
    'InputContentResourceInputImage',
    'InputContentResourceInputText',
    'InputTokensDetailsResource-2',
    'InterruptSubagentCallItemResource',
    'ListOrderParam',
    'McpCallItemResource',
    'MessageContentResource',
    'MessageContentResourceInputImage',
    'MessageContentResourceInputText',
    'MessageContentResourceOutputText',
    'MessageItemResource',
    'MessagePhaseResource',
    'OutputItemStatusResource',
    'OutputTextResource',
    'OutputTokensDetailsResource-2',
    'ReasoningItemResource',
    'ResumeSubagentCallItemResource',
    'SendSubagentInputCallItemResource',
    'SessionItemListResource',
    'SessionMessageRoleResource',
    'SessionTraceListResource',
    'SessionTurnErrorCodeResource',
    'SessionTurnErrorResource',
    'SessionTurnItemResource',
    'SessionTurnListResource',
    'SessionTurnTraceResource',
    'SummaryTextResource',
    'TokenUsageResource',
    'TurnObjectResource',
    'TurnResource',
    'TurnStatusResource',
    'WaitForSubagentsCallItemResource',
    'WebSearchActionResource',
    'WebSearchActionResourceFindInPage',
    'WebSearchActionResourceOpenPage',
    'WebSearchActionResourceOther',
    'WebSearchActionResourceSearch',
    'WebSearchCallItemResource',
  ];
  for (final schema in schemas) {
    final newFixtures = agentSessionHistoryFixtures.where(
      (f) => f.schema == schema,
    );
    final oldFixtures = agentSessionWireFixtures.where(
      (f) => f.schema == schema,
    );
    test('$schema: frozen minimal/full closure roundtrip', () {
      if (newFixtures.isNotEmpty) {
        final fixture = newFixtures.single;
        for (final wire in [fixture.minimal, fixture.full]) {
          final model = fixture.parse(wire);
          expect(model.toJson(), wire);
          expect(fixture.copy(model), model);
          expect(fixture.copy(model).hashCode, model.hashCode);
        }
      } else {
        final fixture = oldFixtures.single;
        for (final wire in [fixture.minimal, fixture.full]) {
          final model = fixture.parse(jsonDecode(jsonEncode(wire)));
          expect(model.toJson(), wire);
          expect(fixture.copy(model), model);
          expect(fixture.copy(model).hashCode, model.hashCode);
        }
      }
    });
  }
}
