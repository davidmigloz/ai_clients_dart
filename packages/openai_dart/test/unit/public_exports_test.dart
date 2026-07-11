import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test('new public types are exported from the package barrel', () {
    // Compile-time check: if any of these types is not exported from the
    // package barrel, this list fails to resolve and the file no longer
    // compiles.
    const exportedTypes = <Type>[
      // Prompt caching (GPT-5.6 sync).
      PromptCacheBreakpointConfig,
      PromptCacheMode,
      PromptCacheTtl,
      PromptCacheOptions,
      PromptCacheOptionsParam,
      ComputerScreenshotContent,
      // Moderation policy.
      ModerationMode,
      ModerationConfigParam,
      ModerationPolicyParam,
      // Reasoning mode.
      ReasoningMode,
      StandardReasoningMode,
      ProReasoningMode,
      CustomReasoningMode,
      // Streaming.
      ReasoningSummaryPartStatus,
      // Programmatic tool calling.
      ToolCallCaller,
      DirectToolCallCaller,
      ProgramToolCallCaller,
      CallableToolAllowedCaller,
      ProgrammaticToolCallingTool,
      ResponseToolChoiceProgrammatic,
      ProgramOutputStatus,
      ProgramItem,
      ProgramOutputItem,
      ProgramOutputItemResponse,
      ProgramOutputResultItem,
      // Multi-agent Responses beta.
      AgentTag,
      MultiAgentAction,
      MultiAgentConfig,
      AgentMessageItem,
      AgentMessageOutputItem,
      MultiAgentCallItem,
      MultiAgentCallOutputItem,
      MultiAgentCallOutputItemResponse,
      MultiAgentCallOutputResultItem,
      ResponseInjectEvent,
      ResponseInjectCreatedEvent,
      ResponseInjectFailedEvent,
      ResponseInjectError,
      ResponseInjectErrorCode,
      // Content unions.
      EncryptedContent,
      TextOutputContent,
      InputImageOutputContent,
      ComputerScreenshotOutputContent,
      InputFileOutputContent,
      EncryptedOutputContent,
    ];
    expect(exportedTypes, isNotEmpty);
    expect(ReasoningEffort.max.toJson(), 'max');
    expect(const AgentTag(agentName: 'planner'), isA<AgentTag>());
  });
}
