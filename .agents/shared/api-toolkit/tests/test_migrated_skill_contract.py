from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
TOOLKIT_ROOT = ROOT / ".agents" / "shared" / "api-toolkit"

if str(TOOLKIT_ROOT) not in sys.path:
    sys.path.insert(0, str(TOOLKIT_ROOT))

from api_toolkit.config import load_toolkit_config
from api_toolkit.operations import command_describe, command_verify


CONFIG_DIRS = [
    ROOT / "packages" / "anthropic_sdk_dart" / ".agents" / "skills" / "openapi-anthropic" / "config",
    ROOT / "packages" / "chromadb" / ".agents" / "skills" / "openapi-chromadb" / "config",
    ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "openapi-googleai" / "config",
    ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "websocket-googleai" / "config",
    ROOT / "packages" / "mistralai_dart" / ".agents" / "skills" / "openapi-mistral" / "config",
    ROOT / "packages" / "ollama_dart" / ".agents" / "skills" / "openapi-ollama" / "config",
    ROOT / "packages" / "open_responses" / ".agents" / "skills" / "openapi-open-responses" / "config",
    ROOT / "packages" / "openai_dart" / ".agents" / "skills" / "openapi-openai" / "config",
]

BANNED_REFERENCES = [
    ".claude",
    ".agents/shared/openapi-toolkit",
    ".agents/shared/websocket-toolkit",
    "verify_model_properties.py",
    "verify_schema_deep.py",
    "generate_model.py",
    "generate_enum.py",
    "generate_message.py",
    "generate_config.py",
]

DEAD_SPEC_KEYS = {
    "discovery_patterns",
    "discovery_names",
    "message_types",
}


EXPECTED_SKIP_KEYS = {
    "anthropic_sdk_dart/openapi-anthropic": [
        "Base64ImageSource",
        "Base64PDFSource",
        "BashTool20250124",
        "BuiltInTool",
        "CacheControlEphemeral",
        "CanceledResult",
        "CitationCharLocation",
        "CitationContentBlockLocation",
        "CitationPageLocation",
        "CitationWebSearchResultLocation",
        "CitationsDelta",
        "CodeExecutionTool20250522",
        "CompactionDelta",
        "ComputerUseTool (beta)",
        "ContentBlockDeltaEvent",
        "ContentBlockStartEvent",
        "ContentBlockStopEvent",
        "CreateMessageRequest",
        "DirectToolCaller",
        "DocumentBlockParam",
        "ErrorEvent",
        "ErroredResult",
        "ExpiredResult",
        "ImageBlockParam",
        "InputJSONDelta",
        "McpToolset (beta)",
        "MemoryTool20250818",
        "MessageBatchIndividualResponse",
        "MessageDeltaEvent",
        "MessageStartEvent",
        "MessageStopEvent",
        "PingEvent",
        "PlainTextSource",
        "RedactedThinkingBlock",
        "RequestBashCodeExecutionToolResultBlockParam",
        "RequestCodeExecutionToolResultBlockParam",
        "RequestCompactionBlockParam",
        "RequestContainerUploadBlockParam",
        "RequestCounts",
        "RequestTextEditorCodeExecutionToolResultBlockParam",
        "RequestToolReferenceBlockParam",
        "RequestToolSearchToolResultBlockParam",
        "RequestWebFetchToolResultBlockParam",
        "RequestWebSearchToolResultBlockParam",
        "ResponseBashCodeExecutionToolResultBlock",
        "ResponseCodeExecutionToolResultBlock",
        "ResponseCompactionBlock",
        "ResponseContainerUploadBlock",
        "ResponseTextEditorCodeExecutionToolResultBlock",
        "ResponseToolSearchToolResultBlock",
        "ResponseWebFetchToolResultBlock",
        "ResponseWebSearchToolResultBlock",
        "ResponseWebSearchToolResultError",
        "ServerToolUseBlock",
        "ServerToolUseBlockParam",
        "SignatureDelta",
        "SucceededResult",
        "TextBlock",
        "TextBlockParam",
        "TextDelta",
        "TextEditor20250124",
        "TextEditor20250429",
        "TextEditor20250728",
        "ThinkingBlock",
        "ThinkingConfigAdaptive",
        "ThinkingConfigDisabled",
        "ThinkingConfigEnabled",
        "ThinkingDelta",
        "Tool",
        "ToolCaller",
        "ToolChoiceAny",
        "ToolChoiceAuto",
        "ToolChoiceNone",
        "ToolChoiceTool",
        "ToolDefinition",
        "ToolResultBlockParam",
        "ToolResultBlockParamContentVariant0",
        "ToolResultBlockParamContentVariant1",
        "ToolSearchToolBm25",
        "ToolSearchToolRegex",
        "ToolUseBlock",
        "ToolUseBlockParam",
        "URLImageSource",
        "URLPDFSource",
        "WebFetchTool20250910",
        "WebSearchTool20250305",
        "array of ResponseWebSearchResultBlock",
        "various built-in tool schemas",
    ],
    "chromadb/openapi-chromadb": [
        "Collection",
        "GetResponse",
        "QueryResponse",
    ],
    "googleai_dart/openapi-googleai": [
        "AgentOption",
        "AudioDelta",
        "AudioMimeTypeOption",
        "Blob",
        "Candidate",
        "CodeExecutionCallArguments",
        "CodeExecutionCallContent",
        "CodeExecutionCallDelta",
        "CodeExecutionResultDelta",
        "ContentDelta",
        "ContentStart",
        "ContentStop",
        "CreateAgentInteractionParams",
        "CreateModelInteractionParams",
        "DocumentDelta",
        "DocumentMimeTypeOption",
        "Error",
        "ErrorEvent",
        "FileData",
        "FileSearchResultDelta",
        "Function",
        "FunctionCallDelta",
        "FunctionResponse",
        "FunctionResultDelta",
        "GenerationConfig",
        "GoogleSearchCallArguments",
        "GoogleSearchCallContent",
        "GoogleSearchCallDelta",
        "GoogleSearchResult",
        "GoogleSearchResultDelta",
        "GroundingChunk",
        "GroundingMetadata",
        "ImageDelta",
        "ImageMimeTypeOption",
        "Interaction",
        "InteractionEvent",
        "InteractionSseEvent",
        "InteractionStatusUpdate",
        "McpServerToolCallDelta",
        "McpServerToolResultContent",
        "McpServerToolResultDelta",
        "ModelOption",
        "Part",
        "ResponseModality",
        "TextDelta",
        "ThinkingLevel",
        "ThinkingSummaries",
        "ThoughtSignatureDelta",
        "ThoughtSummary",
        "ThoughtSummaryDelta",
        "Tool",
        "ToolChoice",
        "ToolChoiceConfig",
        "ToolChoiceType",
        "ToolConfig",
        "UrlContextCallArguments",
        "UrlContextCallContent",
        "UrlContextCallDelta",
        "UrlContextResultDelta",
        "VideoDelta",
        "VideoMimeTypeOption",
        "interactions:CodeExecution",
        "interactions:ComputerUse",
        "interactions:Content",
        "interactions:FileSearch",
        "interactions:GoogleSearch",
        "interactions:McpServer",
        "interactions:MediaResolution",
        "interactions:UrlContext",
    ],
    "googleai_dart/websocket-googleai": [
        "ActivityHandling",
        "AutomaticActivityDetection",
        "BidiGenerateContentClientContent",
        "BidiGenerateContentRealtimeInput",
        "BidiGenerateContentServerContent",
        "BidiGenerateContentSetup",
        "BidiGenerateContentSetupComplete",
        "BidiGenerateContentToolCall",
        "BidiGenerateContentToolCallCancellation",
        "BidiGenerateContentToolResponse",
        "ContextWindowCompressionConfig",
        "EndSensitivity",
        "GoAway",
        "LiveConfig",
        "LiveGenerationConfig",
        "PrebuiltVoiceConfig",
        "ProactivityConfig",
        "RealtimeInputConfig",
        "SessionResumptionUpdate",
        "SlidingWindow",
        "SpeechConfig",
        "StartSensitivity",
        "Transcription",
        "TurnCoverage",
        "VoiceConfig",
    ],
    "mistralai_dart/openapi-mistral": [
        "AssistantMessage",
        "ChatCompletionResponse",
        "EmbeddingResponse",
        "FunctionName",
        "FunctionTool",
        "ImageURLChunk",
        "ModelCard",
        "ResponseFormat",
        "SystemMessage",
        "TextChunk",
        "ToolMessage",
        "UserMessage",
    ],
    "ollama_dart/openapi-ollama": [
        "GenerateChatCompletionRequest",
        "GenerateChatCompletionResponse",
        "GenerateCompletionRequest",
        "GenerateCompletionResponse",
        "GenerateEmbeddingRequest",
        "GenerateEmbeddingResponse",
        "Message",
        "Model",
        "ModelInfo",
        "RequestOptions",
        "Tool",
    ],
    "open_responses/openapi-open-responses": [
        "AllowedToolsParam",
        "ErrorPayload",
        "ErrorStreamingEvent",
        "FunctionCallItemParam",
        "FunctionCallOutputItemParam",
        "FunctionToolParam",
        "InputFileContentParam",
        "InputImageContentParam",
        "InputTextContentParam",
        "InputVideoContentParam",
        "ItemReferenceParam",
        "LogProb",
        "MessageItemParam",
        "OutputTextContent",
        "ReasoningParam",
        "RefusalContent",
        "ResponseCompletedStreamingEvent",
        "ResponseContentPartAddedStreamingEvent",
        "ResponseContentPartDoneStreamingEvent",
        "ResponseCreatedStreamingEvent",
        "ResponseFailedStreamingEvent",
        "ResponseFunctionCallArgumentsDeltaStreamingEvent",
        "ResponseFunctionCallArgumentsDoneStreamingEvent",
        "ResponseInProgressStreamingEvent",
        "ResponseIncompleteStreamingEvent",
        "ResponseOutputItemAddedStreamingEvent",
        "ResponseOutputItemDoneStreamingEvent",
        "ResponseOutputTextAnnotationAddedStreamingEvent",
        "ResponseOutputTextDeltaStreamingEvent",
        "ResponseOutputTextDoneStreamingEvent",
        "ResponseQueuedStreamingEvent",
        "ResponseReasoningDeltaStreamingEvent",
        "ResponseReasoningDoneStreamingEvent",
        "ResponseReasoningSummaryDeltaStreamingEvent",
        "ResponseReasoningSummaryDoneStreamingEvent",
        "ResponseReasoningSummaryPartAddedStreamingEvent",
        "ResponseReasoningSummaryPartDoneStreamingEvent",
        "ResponseRefusalDeltaStreamingEvent",
        "ResponseRefusalDoneStreamingEvent",
        "ResponseResource",
        "SpecificFunctionParam",
        "TextParam",
        "TopLogProb",
        "UrlCitationAnnotation",
    ],
    "openai_dart/openapi-openai": [
        "AssistantObject",
        "AssistantToolsCode",
        "AssistantToolsFileSearch",
        "AssistantToolsFunction",
        "ChatCompletionNamedToolChoice",
        "ChatCompletionRequestAssistantMessage",
        "ChatCompletionRequestDeveloperMessage",
        "ChatCompletionRequestMessage",
        "ChatCompletionRequestMessageContentPartAudio",
        "ChatCompletionRequestMessageContentPartImage",
        "ChatCompletionRequestMessageContentPartText",
        "ChatCompletionRequestSystemMessage",
        "ChatCompletionRequestToolMessage",
        "ChatCompletionRequestUserMessage",
        "ChatCompletionTool",
        "ChatStreamEvent",
        "CompletionUsage",
        "CreateChatCompletionRequest",
        "CreateChatCompletionResponse",
        "CreateChatCompletionStreamResponse",
        "CreateEmbeddingResponse",
        "CreateImageRequest",
        "CreateSpeechRequest",
        "CreateTranscriptionRequest",
        "FunctionObject",
        "MessageContentImageFileObject",
        "MessageContentImageUrlObject",
        "MessageContentRefusalObject",
        "MessageContentTextAnnotationsFileCitationObject",
        "MessageContentTextAnnotationsFilePathObject",
        "MessageContentTextObject",
        "ResponseFormatJsonObject",
        "ResponseFormatJsonSchema",
        "ResponseFormatText",
        "RunObject",
        "RunStepDetailsMessageCreationObject",
        "RunStepDetailsToolCallsCodeObject",
        "RunStepDetailsToolCallsCodeOutputImageObject",
        "RunStepDetailsToolCallsCodeOutputLogsObject",
        "RunStepDetailsToolCallsFileSearchObject",
        "RunStepDetailsToolCallsFunctionObject",
        "RunStepDetailsToolCallsObject",
        "ThreadObject",
    ],
}


EXPECTED_DOC_EXCLUSIONS = {
    "anthropic_sdk_dart/openapi-anthropic": {
        "excluded_resources": ["base_resource", "message_batches_resource", "streaming_resource"],
        "excluded_from_examples": [],
    },
    "chromadb/openapi-chromadb": {
        "excluded_resources": ["base_resource"],
        "excluded_from_examples": [],
    },
    "googleai_dart/openapi-googleai": {
        "excluded_resources": [
            "base_resource",
            "documents_resource",
            "generated_files_resource",
            "operations_resource",
            "permissions_resource",
            "resource_base",
            "streaming",
        ],
        "excluded_from_examples": [],
    },
    "googleai_dart/websocket-googleai": {
        "excluded_resources": ["base_resource", "resource_base"],
        "excluded_from_examples": [],
    },
    "mistralai_dart/openapi-mistral": {
        "excluded_resources": ["base_resource", "streaming_resource"],
        "excluded_from_examples": [],
    },
    "ollama_dart/openapi-ollama": {
        "excluded_resources": ["base_resource", "streaming"],
        "excluded_from_examples": [],
    },
    "open_responses/openapi-open-responses": {
        "excluded_resources": ["base_resource", "streaming"],
        "excluded_from_examples": ["responses"],
    },
    "openai_dart/openapi-openai": {
        "excluded_resources": [
            "assistants",
            "base_resource",
            "beta",
            "inputTokens",
            "messages",
            "runs",
            "streaming",
            "threads",
            "vectorStores",
        ],
        "excluded_from_examples": [],
    },
}


def _config_label(config_dir: Path) -> str:
    rel = config_dir.relative_to(ROOT / "packages")
    return f"{rel.parts[0]}/{rel.parts[3]}"


class MigratedSkillContractTests(unittest.TestCase):
    def test_migrated_configs_use_four_file_contract(self) -> None:
        expected = {"documentation.json", "manifest.json", "package.json", "specs.json"}
        for config_dir in CONFIG_DIRS:
            self.assertTrue(config_dir.exists(), msg=f"Missing config dir: {config_dir}")
            files = {path.name for path in config_dir.iterdir() if path.is_file()}
            self.assertEqual(files, expected, msg=f"Unexpected config files in {config_dir}")

    def test_all_real_configs_load_under_new_toolkit(self) -> None:
        for config_dir in CONFIG_DIRS:
            config = load_toolkit_config(config_dir)
            self.assertIn(config.manifest.surface, {"openapi", "websocket"})
            self.assertEqual(config.config_dir, config_dir.resolve())
            self.assertGreaterEqual(len(config.specs), 1)

    def test_all_manifest_paths_are_package_root_relative(self) -> None:
        for config_dir in CONFIG_DIRS:
            manifest = load_toolkit_config(config_dir).manifest
            for entry in manifest.types.values():
                self.assertFalse(
                    entry.file.startswith("packages/"),
                    msg=f"{config_dir}: manifest path must be package-root-relative for {entry.key}",
                )

    def test_no_real_specs_json_contains_dead_legacy_keys(self) -> None:
        for config_dir in CONFIG_DIRS:
            raw = (config_dir / "specs.json").read_text()
            for key in DEAD_SPEC_KEYS:
                self.assertNotIn(f'"{key}"', raw, msg=f"{config_dir}: unexpected legacy key {key}")
            if config_dir.name == "config" and "websocket-googleai" in str(config_dir):
                specs = load_toolkit_config(config_dir)
                self.assertTrue(specs.specs["live"].websocket_endpoints)
                self.assertIn("experimental", command_describe(type("Args", (), {"config_dir": config_dir, "spec_name": "live", "type_name": None})())[1]["selected_spec"])

    def test_openapi_googleai_contains_main_and_interactions_entries(self) -> None:
        config_dir = ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "openapi-googleai" / "config"
        config = load_toolkit_config(config_dir)
        specs = {entry.spec for entry in config.manifest.types.values()}
        self.assertIn("main", specs)
        self.assertIn("interactions", specs)
        self.assertIn("interactions:Tool", config.manifest.types)

    def test_describe_filters_real_interactions_entries(self) -> None:
        config_dir = ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "openapi-googleai" / "config"
        _, payload = command_describe(type("Args", (), {"config_dir": config_dir, "spec_name": "interactions", "type_name": None})())
        self.assertTrue(payload["types"])
        self.assertTrue(all(item["spec"] == "interactions" for item in payload["types"].values()))

    def test_real_preflight_config_loads_for_supported_packages(self) -> None:
        for package in ("openai_dart", "anthropic_sdk_dart"):
            config_dir = ROOT / "packages" / package / ".agents" / "skills" / (
                "openapi-openai" if package == "openai_dart" else "openapi-anthropic"
            ) / "config"
            config = load_toolkit_config(config_dir)
            self.assertIn("stats_url", config.preflight)
            self.assertIn("stats_field", config.preflight)

    def test_websocket_schema_lives_under_package_specs(self) -> None:
        package_specs_dir = ROOT / "packages" / "googleai_dart" / "specs"
        self.assertTrue((package_specs_dir / "live-api-schema.source.json").exists())
        self.assertTrue((package_specs_dir / "live-api-schema.json").exists())
        self.assertFalse(
            (ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "websocket-googleai" / "config" / "schema.json").exists()
        )

    def test_active_docs_and_skill_files_have_no_legacy_references(self) -> None:
        scan_roots = [
            ROOT / ".agents" / "shared" / "api-toolkit",
            ROOT / "docs" / "new_dart_api_client.md",
            *(ROOT / "packages").glob("*/.agents/skills"),
        ]
        offenders: list[str] = []
        for root in scan_roots:
            candidates = [root] if root.is_file() else [path for path in root.rglob("*") if path.is_file()]
            for path in candidates:
                if path.is_relative_to(TOOLKIT_ROOT / "tests"):
                    continue
                if path.suffix not in {".md", ".json", ".yaml", ".yml", ".py"}:
                    continue
                text = path.read_text()
                for banned in BANNED_REFERENCES:
                    if banned in text:
                        offenders.append(f"{path.relative_to(ROOT)} -> {banned}")
        self.assertEqual(offenders, [])

    def test_real_skill_labels_use_canonical_product_and_surface_names(self) -> None:
        for config_dir in CONFIG_DIRS:
            config = load_toolkit_config(config_dir)
            surface = "WebSocket" if config.manifest.surface == "websocket" else "OpenAPI"
            expected = (
                f'  display_name: "{config.package.display_name} {surface}"\n'
                f'  short_description: "Manage {config.package.display_name} {surface} workflow"\n'
            )
            skill_yaml = config_dir.parent / "agents" / "openai.yaml"
            self.assertIn(expected, skill_yaml.read_text(), msg=f"Unexpected skill label text in {skill_yaml}")

    def test_real_manifests_do_not_mark_skipped_entries_as_critical(self) -> None:
        offenders: list[str] = []
        for config_dir in CONFIG_DIRS:
            config = load_toolkit_config(config_dir)
            for entry in config.manifest.types.values():
                if entry.kind == "skip" and "critical" in entry.tags:
                    offenders.append(f"{config_dir}: {entry.key}")
        self.assertEqual(offenders, [])

    def test_real_skill_workflows_describe_candidate_spec_promotion(self) -> None:
        for config_dir in CONFIG_DIRS:
            text = (config_dir.parent / "SKILL.md").read_text()
            self.assertIn("latest-<spec>.json", text, msg=f"Missing candidate spec guidance in {config_dir}")
            self.assertIn("/specs/", text, msg=f"Missing canonical spec guidance in {config_dir}")

    def test_real_skill_docs_describe_repo_root_command_usage(self) -> None:
        expected = "run the repo-relative examples from the repository root"
        for config_dir in CONFIG_DIRS:
            text = (config_dir.parent / "SKILL.md").read_text()
            self.assertIn(expected, text, msg=f"Missing repo-root guidance in {config_dir}")
            self.assertNotIn("Commands work from any directory", text, msg=f"Stale command guidance in {config_dir}")

    def test_real_local_file_specs_omit_remote_fetch_fields(self) -> None:
        offenders: list[str] = []
        for config_dir in CONFIG_DIRS:
            raw = json.loads((config_dir / "specs.json").read_text())
            for spec_name, spec in raw["specs"].items():
                if spec.get("fetch_mode") != "local_file":
                    continue
                remote_only = sorted(key for key in ("url", "requires_auth", "auth_env_vars") if key in spec)
                if remote_only:
                    offenders.append(f"{config_dir}:{spec_name} -> {', '.join(remote_only)}")
        self.assertEqual(offenders, [])

    def test_requires_auth_false_specs_do_not_declare_auth_env_vars(self) -> None:
        offenders: list[str] = []
        for config_dir in CONFIG_DIRS:
            raw = json.loads((config_dir / "specs.json").read_text())
            for spec_name, spec in raw["specs"].items():
                if spec.get("requires_auth") is False and spec.get("auth_env_vars"):
                    offenders.append(f"{config_dir}:{spec_name}")
        self.assertEqual(offenders, [])

    def test_public_remote_skill_docs_do_not_claim_auth_when_fetch_is_public(self) -> None:
        expected = {
            ROOT / "packages" / "anthropic_sdk_dart" / ".agents" / "skills" / "openapi-anthropic" / "SKILL.md",
            ROOT / "packages" / "mistralai_dart" / ".agents" / "skills" / "openapi-mistral" / "SKILL.md",
            ROOT / "packages" / "openai_dart" / ".agents" / "skills" / "openapi-openai" / "SKILL.md",
        }
        for path in expected:
            self.assertIn("- Auth: No auth env vars required.", path.read_text(), msg=f"Unexpected auth guidance in {path}")

    def test_googleai_main_spec_uses_header_auth_transport(self) -> None:
        specs_path = ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "openapi-googleai" / "config" / "specs.json"
        raw = json.loads(specs_path.read_text())
        self.assertEqual(
            raw["specs"]["main"].get("auth"),
            {
                "location": "header",
                "name": "x-goog-api-key",
                "prefix": "",
            },
        )

    def test_real_package_guides_use_package_and_surface_titles(self) -> None:
        for config_dir in CONFIG_DIRS:
            config = load_toolkit_config(config_dir)
            surface = "WebSocket" if config.manifest.surface == "websocket" else "OpenAPI"
            guide_path = config_dir.parent / "references" / "package-guide.md"
            self.assertTrue(guide_path.exists(), msg=f"Missing package guide for {config_dir}")
            title = guide_path.read_text().splitlines()[0]
            self.assertEqual(title, f"# {config.package.name} {surface} Package Guide", msg=f"Unexpected title in {guide_path}")

    def test_real_implementation_patterns_link_to_shared_core_from_skill_directory(self) -> None:
        expected_link = "[implementation-patterns-core.md](../../../../../../.agents/shared/api-toolkit/references/implementation-patterns-core.md)"
        for config_dir in CONFIG_DIRS:
            patterns_path = config_dir.parent / "references" / "implementation-patterns.md"
            self.assertTrue(patterns_path.exists(), msg=f"Missing implementation patterns for {config_dir}")
            text = patterns_path.read_text()
            self.assertIn(expected_link, text, msg=f"Unexpected shared core link in {patterns_path}")

    def test_shared_generic_assets_do_not_hardcode_googleai_package(self) -> None:
        for path in (
            TOOLKIT_ROOT / "assets" / "example_template.dart",
            TOOLKIT_ROOT / "assets" / "test_template.dart",
        ):
            text = path.read_text()
            self.assertNotIn("package:googleai_dart", text, msg=f"Found hardcoded googleai import in {path}")

    def test_real_manifest_coverage_aliases_match_audited_grouped_resources(self) -> None:
        expected = {
            ROOT / "packages" / "anthropic_sdk_dart" / ".agents" / "skills" / "openapi-anthropic" / "config": {
                "resource_aliases": {},
                "excluded_resources": ["complete"],
            },
            ROOT / "packages" / "chromadb" / ".agents" / "skills" / "openapi-chromadb" / "config": {
                "resource_aliases": {
                    "healthcheck": "health",
                    "heartbeat": "health",
                    "pre_flight_checks": "health",
                    "reset": "health",
                    "version": "health",
                },
                "excluded_resources": [],
            },
            ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "openapi-googleai" / "config": {
                "resource_aliases": {"dynamic": "models"},
                "excluded_resources": [],
            },
            ROOT / "packages" / "mistralai_dart" / ".agents" / "skills" / "openapi-mistral" / "config": {
                "resource_aliases": {},
                "excluded_resources": [],
            },
            ROOT / "packages" / "ollama_dart" / ".agents" / "skills" / "openapi-ollama" / "config": {
                "resource_aliases": {
                    "copy": "models",
                    "create": "models",
                    "delete": "models",
                    "ps": "models",
                    "pull": "models",
                    "push": "models",
                    "show": "models",
                    "tags": "models",
                    "generate": "completions",
                    "embed": "embeddings",
                },
                "excluded_resources": [],
            },
        }
        for config_dir, coverage_expectation in expected.items():
            raw = json.loads((config_dir / "manifest.json").read_text())
            coverage = raw["coverage"]
            self.assertEqual(coverage.get("resource_aliases", {}), coverage_expectation["resource_aliases"], msg=f"Unexpected resource_aliases in {config_dir}")
            self.assertEqual(coverage.get("excluded_resources", []), coverage_expectation["excluded_resources"], msg=f"Unexpected excluded_resources in {config_dir}")

    def test_real_manifest_skip_keys_match_audited_snapshot(self) -> None:
        actual = {}
        for config_dir in CONFIG_DIRS:
            config = load_toolkit_config(config_dir)
            skipped = sorted(entry.key for entry in config.manifest.types.values() if entry.kind == "skip")
            if skipped:
                actual[_config_label(config_dir)] = skipped
        self.assertEqual(actual, EXPECTED_SKIP_KEYS)

    def test_real_documentation_exclusions_match_audited_snapshot(self) -> None:
        actual = {}
        for config_dir in CONFIG_DIRS:
            raw = json.loads((config_dir / "documentation.json").read_text())
            excluded_resources = sorted(raw.get("excluded_resources", []))
            excluded_from_examples = sorted(raw.get("excluded_from_examples", []))
            if excluded_resources or excluded_from_examples:
                actual[_config_label(config_dir)] = {
                    "excluded_resources": excluded_resources,
                    "excluded_from_examples": excluded_from_examples,
                }
        self.assertEqual(actual, EXPECTED_DOC_EXCLUSIONS)

    def test_real_implementation_verify_reports_skip_summary(self) -> None:
        for config_dir in CONFIG_DIRS:
            label = _config_label(config_dir)
            exit_code, payload = command_verify(
                type(
                    "Args",
                    (),
                    {
                        "config_dir": config_dir,
                        "spec_name": None,
                        "checks": "implementation",
                        "scope": "all",
                        "type_name": None,
                        "baseline": None,
                        "git_ref": None,
                    },
                )()
            )
            self.assertEqual(exit_code, 0, msg=f"{config_dir}: {payload['summary']}")
            result = payload["results"]["implementation"]
            config = load_toolkit_config(config_dir)
            selected_spec = config.get_spec(None)[0]
            expected_skipped = sorted(
                entry.key
                for entry in config.manifest.types.values()
                if entry.spec == selected_spec and entry.kind == "skip"
            )
            self.assertTrue(result["coverage_summary"]["partial_coverage"], msg=f"{config_dir}: expected partial implementation coverage")
            self.assertEqual(result["coverage_summary"]["skipped_entry_count"], len(expected_skipped))
            self.assertEqual(result["coverage_summary"]["skipped_keys"], expected_skipped)
            self.assertIn("implementation", payload["summary"]["warning_checks"], msg=f"{config_dir}: missing implementation warning summary")

    def test_real_docs_verify_reports_exclusion_summary(self) -> None:
        for config_dir in CONFIG_DIRS:
            label = _config_label(config_dir)
            exit_code, payload = command_verify(
                type(
                    "Args",
                    (),
                    {
                        "config_dir": config_dir,
                        "spec_name": None,
                        "checks": "docs",
                        "scope": "all",
                        "type_name": None,
                        "baseline": None,
                        "git_ref": None,
                    },
                )()
            )
            self.assertEqual(exit_code, 0, msg=f"{config_dir}: {payload['summary']}")
            result = payload["results"]["docs"]
            expected_exclusions = EXPECTED_DOC_EXCLUSIONS[label]
            self.assertTrue(result["coverage_summary"]["partial_coverage"], msg=f"{config_dir}: expected partial docs coverage")
            self.assertEqual(result["coverage_summary"]["excluded_resources"], expected_exclusions["excluded_resources"])
            self.assertEqual(result["coverage_summary"]["excluded_from_examples"], expected_exclusions["excluded_from_examples"])
            self.assertIn("docs", payload["summary"]["warning_checks"], msg=f"{config_dir}: missing docs warning summary")

    def test_full_verify_passes_for_all_real_skills(self) -> None:
        for config_dir in CONFIG_DIRS:
            exit_code, payload = command_verify(
                type(
                    "Args",
                    (),
                    {
                        "config_dir": config_dir,
                        "spec_name": None,
                        "checks": "all",
                        "scope": "all",
                        "type_name": None,
                        "baseline": None,
                        "git_ref": None,
                    },
                )()
            )
            self.assertEqual(exit_code, 0, msg=f"{config_dir}: {payload['summary']}")

    def test_openapi_googleai_full_verify_passes_for_each_spec(self) -> None:
        config_dir = ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "openapi-googleai" / "config"
        for spec_name in ("main", "interactions"):
            exit_code, payload = command_verify(
                type(
                    "Args",
                    (),
                    {
                        "config_dir": config_dir,
                        "spec_name": spec_name,
                        "checks": "all",
                        "scope": "all",
                        "type_name": None,
                        "baseline": None,
                        "git_ref": None,
                    },
                )()
            )
            self.assertEqual(exit_code, 0, msg=f"{spec_name}: {payload['summary']}")


if __name__ == "__main__":
    unittest.main()
