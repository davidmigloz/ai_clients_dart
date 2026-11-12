# Documentation and runnable examples audit

The initial review began at `e4a5b5946bf0bb15408bc111ab7b144c87c5d1c1` against the November 11 source cutoff. Integrated verification below covers the feature-complete package. [Documentation ticket #503](https://github.com/davidmigloz/ai_clients_dart/issues/503)

## Files reviewed

- The repository README Anthropic install and Messages sample, the package README Quickstart, Configuration, Usage, Examples, API Coverage, and published metadata in `pubspec.yaml`.
- The package `MIGRATION.md`, generated `llms.txt`, public Dartdoc reachable from `lib/anthropic_sdk_dart.dart`, and the package workflow links in the Anthropic skill and review checklist. `CHANGELOG.md` remains historical.
- The usage links and generated example index resolve to their own package. The README retains relative section anchors and uses source URLs for files that do not exist in generated Dartdoc.

## Usage order

1. How do I send a Claude message?
2. How do I stream Claude responses?
3. How do I decode a structured response?
4. How do I use tool calling?
5. How do I run a loop with custom tools?
6. How do I restrict URLs Claude can fetch?
7. How do I handle browser and computer toolset calls?
8. How do I count tokens?
9. How do I send images or documents?
10. How do I enable extended thinking?
11. How do I keep conversation state on the server?
12. How do I compact a conversation?
13. How do I list available models?
14. How do I run message batches?
15. How do I manage files?
16. How do I manage skills?
17. How do I connect a remote MCP server?
18. How do I use Claude Platform on AWS?
19. How do I use Claude on Amazon Bedrock?
20. How do I use Claude on Google Cloud?
21. How do I use Claude in Microsoft Foundry?
22. How do I use managed agents?
23. How do I manage agent environments?
24. How do I poll work from a self-hosted environment?
25. How do I manage MCP tunnels?
26. How do I manage agent memory stores?
27. How do I attribute Claude requests to a user profile?
28. How do I manage organization workspaces and access?
29. How do I report organization usage and costs?
30. How do I subscribe to organization webhook events?
31. How do I send Claude API traces to a collector?
32. How do I inventory and validate Claude Enterprise plugins?
33. How do I audit Claude Tag settings in Slack?
34. How do I use the Compliance API?

## Runnable example inventory

Inference examples that call `AnthropicClient.fromEnvironment()` can use `ANTHROPIC_AUTH_TOKEN` with the required scope when `ANTHROPIC_API_KEY` is unset or empty. Examples that check an explicit key describe that variable and the required access below.

The environment column refers to variables in the process running `dart run`. `API key` means `ANTHROPIC_API_KEY`. The default API wire version is `2026-10-21`; the API version example explicitly opts into `2023-06-01` with `--legacy`. Example model IDs are literal values in the sample, including its illustrative snippets where present.

| Example | Credentials and arguments | Claude model IDs | Coverage |
| --- | --- | --- | --- |
| `abort_example.dart` | API key | `claude-sonnet-5` | Buffered and SSE cancellation; timeout uses a timer and `AbortedException` |
| `advisor_example.dart` | API key | `claude-opus-5`, `claude-sonnet-5` | Advisor beta on a supported executor/advisor pairing |
| `anthropic_sdk_dart_example.dart` | API key | `claude-sonnet-5` | Basic, multi-turn, system-prompt, and streamed Messages |
| `api_version_example.dart` | API key | `claude-sonnet-4-6`, `claude-sonnet-5-5` | No arguments for current behavior; `--legacy` selects the older API and model |
| `batch_example.dart` | API key | `claude-sonnet-5` | Bounded polling, then streamed JSONL results when the batch ends |
| `browser_use_example.dart` | API key | `claude-sonnet-5-5` | Browser toolset with a stub browser and typed browser state |
| `compliance_content_example.dart` | `ANTHROPIC_COMPLIANCE_ACCESS_KEY`, `ANTHROPIC_COMPLIANCE_ARTIFACT_ID` | — | Compliance Access Key with `read:compliance_user_data`; optional artifact ID |
| `compliance_example.dart` | `ANTHROPIC_ADMIN_KEY`, `ANTHROPIC_COMPLIANCE_ACCESS_KEY` | — | Compliance Access Key or scoped Admin key for Activity Feed |
| `computer_use_example.dart` | API key | `claude-sonnet-5-5` | Computer toolset with stub screenshots and tool-result replay |
| `context_management_example.dart` | API key | `claude-sonnet-5-5` | Context-management beta and token counting |
| `current_user_profiles_example.dart` | API key | — | Owning organization credential; optional existing `uprof_` ID |
| `deployments_example.dart` | API key | `claude-sonnet-5-5` | Existing environment ID in the API key’s workspace; creates one agent, deployment and run, then archives the deployment and agent |
| `diagnostics_example.dart` | API key | `claude-sonnet-5-5` | Claude API; local text path meeting the cacheable length; cache breakpoint and prior message ID |
| `document_example.dart` | API key | `claude-sonnet-5` | Optional local PDF path; embedded text example works without a PDF |
| `dreams_example.dart` | API key | `claude-sonnet-5` | Claude API research preview; existing memory store and completed session IDs |
| `error_handling_example.dart` | API key | `claude-sonnet-5` | Intentional invalid-key and validation responses, then typed handling |
| `fallback_example.dart` | API key | `claude-fable-5-1`, `claude-opus-5` | Access to Fable and Opus; server fallback and fallback-credit beta |
| `files_example.dart` | API key on native, `ANTHROPIC_PROXY_URL` on Web | — | No args uploads sample bytes; local path uploads a file; `--session sesn_…` pages through accessible Managed Agents output files and downloads only downloadable content |
| `managed_agents_example.dart` | API key, `MCP_AUTHORIZATION_TOKEN`, `MCP_SERVER_URL` | `claude-fable-5-1`, `claude-sonnet-5-5` | Managed Agents beta; optional MCP server URL and OAuth token for credential validation |
| `managed_agents_workflow_example.dart` | API key | `claude-sonnet-5` | Managed Agents beta; creates an agent and a workflow session |
| `mcp_example.dart` | API key, `MCP_AUTHORIZATION_TOKEN`, `MCP_SERVER_URL` | `claude-sonnet-5-5` | Messages MCP beta on Claude API; public server URL and optional bearer token |
| `memory_stores_example.dart` | API key | — | Managed Agents memory beta; creates and archives a memory store |
| `message_batches_example.dart` | API key | `claude-sonnet-5` | Creates a batch and inspects its status; results once ended |
| `message_thread_helper_example.dart` | API key | `claude-sonnet-5-5` | Messages thread beta and bounded recovery helper |
| `message_threads_example.dart` | API key | `claude-sonnet-5-5` | Messages thread beta with explicit continuation and streaming |
| `messages_example.dart` | API key | `claude-sonnet-5` | Messages, system instructions, multi-turn, and JSON-shaped text |
| `mid_conversation_system_example.dart` | API key | `claude-opus-5` | Opus 5 supports system turns; clear-at and effort fields need their beta flags |
| `models_example.dart` | API key | `claude-sonnet-5-5` | Model lifecycle filters and capabilities; model retrieve uses Sonnet 5.5 |
| `on_demand_compaction_example.dart` | API key | `claude-sonnet-5-5` | Signed compaction beta; replay compacted history |
| `organization_admin_example.dart` | `ANTHROPIC_ADMIN_KEY` | — | Claude Console Admin key; read-only workspace and organization operations |
| `search_result_example.dart` | API key | `claude-sonnet-5` | Developer-supplied cited search results |
| `session_threads_example.dart` | API key | — | Existing multiagent session ID; `--archive` permits archiving an idle child outside a workflow run |
| `skills_example.dart` | API key | — | Organization Skills access; creates versions, retrieves `latest`, downloads a ZIP to `downloaded_skill.zip`, and deletes the example skill |
| `streaming_example.dart` | API key | `claude-sonnet-5` | Stream raw events and accumulate text/usage |
| `thinking_example.dart` | API key | `claude-sonnet-5-5` | Adaptive thinking, beta progress with web search enabled, and preserved-thinking policy and replay |
| `token_counting_example.dart` | API key | `claude-sonnet-5` | Count tokens for text, tools, and conversation turns |
| `tool_calling_example.dart` | API key | `claude-sonnet-5` | Local tool handler and assistant/tool-result replay |
| `user_profiles_example.dart` | API key | `claude-sonnet-5` | Legacy beta profile management with owning organization credential |
| `vision_example.dart` | API key | `claude-sonnet-5` | Claude endpoint accepting URL images; optional local JPEG path |
| `web_search_example.dart` | API key | `claude-sonnet-5-5` | Organization with web search enabled; current direct search and domain allowlist |

## Verification and sources

- Reviewed the basic Messages contract, SDK API versions, model restrictions, and deprecated Sonnet 4.5 against the migration and lifecycle guides. Retain Sonnet 4.6 only in the intentional legacy API sample. [API migration](https://platform.claude.com/docs/en/api/migration-2026-10-21) · [Model lifecycle](https://platform.claude.com/docs/en/about-claude/model-deprecations)
- Validated web search, advisor, prompt-cache diagnostics, and mid-conversation examples against the current tool and message contracts. The search example supplies one domain policy and enables direct calls for `web_search_20260318`. [Web search](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-search-tool) · [Advisor](https://platform.claude.com/docs/en/agents-and-tools/tool-use/advisor-tool) · [Cache diagnostics](https://platform.claude.com/docs/en/build-with-claude/cache-diagnostics) · [Mid-conversation system messages](https://platform.claude.com/docs/en/build-with-claude/mid-conversation-system-messages)
- Checked model and feature restrictions for Managed Agents and Dreams, session thread archive status, and the special credential requirements for User Profiles and Compliance. [Managed Agents setup](https://platform.claude.com/docs/en/managed-agents/agent-setup) · [Session threads](https://platform.claude.com/docs/en/managed-agents/session-threads) · [Dreams](https://platform.claude.com/docs/en/managed-agents/dreams) · [User Profiles](https://platform.claude.com/docs/en/manage-claude/user-profiles) · [Compliance access](https://platform.claude.com/docs/en/manage-claude/compliance-api-access)
- Strict analysis covers all 40 runnable examples. A loopback fixture executed web search and cache diagnostics and checked the exact API version, runtime authentication, tool shape, cache breakpoint, and prior message ID. The package unit fixtures cover other resource request and response paths.
- Case-sensitive Dartdoc with link validation reported 44 warnings on the baseline and zero after the documentation fixes. The 44 are two unresolved Dartdoc references and 42 README file links. The same baseline generated 80 warnings on a case-insensitive output volume. The additional 36 are collisions for exported `MCP...` and `Mcp...` names. A case-sensitive output volume retains both generated symbol paths.
- The shared toolkit recognizes canonical absolute URLs under the package source directory and either supported Quickstart position. Full verifier reports for eight managed configurations were identical before and after the toolkit change. The full toolkit test run had the same five baseline failures in `test_migrated_skill_contract.py`, with two new targeted README tests passing.

## Integrated checkpoint

The package at `39a786dd491cdc9de6496a5dc05b5a4a1fdd6ce1` adds five examples. Both example indexes contain all 45 once. Strict analysis passed, and 2,286 unit tests passed with three environment-dependent skips.

| Example | Credentials and arguments | Claude model IDs | Coverage |
| --- | --- | --- | --- |
| `environments_example.dart` | API key for the workspace | — | Managed Agents beta cloud environment creation, update, and archive |
| `environment_work_example.dart` | `ANTHROPIC_ENVIRONMENT_ID`, `ANTHROPIC_ENVIRONMENT_KEY` on a dedicated test environment | — | Poll, acknowledge, heartbeat, and stop after acquiring the lease |
| `organization_rbac_example.dart` | `ANTHROPIC_ADMIN_KEY` with RBAC/member or organization audit scopes | — | Read Enterprise RBAC groups, group members, roles, and permissions |
| `organization_spend_example.dart` | `ANTHROPIC_ADMIN_KEY` with `read:spend_limits` | — | Read Enterprise effective limits and pending increase requests |
| `workload_identity_example.dart` | `ANTHROPIC_FEDERATION_RULE_ID`, `ANTHROPIC_ORGANIZATION_ID`, `ANTHROPIC_SERVICE_ACCOUNT_ID`, `ANTHROPIC_IDENTITY_TOKEN_FILE` or `ANTHROPIC_IDENTITY_TOKEN`; `ANTHROPIC_WORKSPACE_ID` when the rule covers multiple workspaces | `claude-sonnet-5-5` | Exchange a scoped JWT and send a Messages request |

## Workspace MCP tunnels

Run `mcp_tunnels_example.dart` with a workspace-scoped, already minted OAuth access token in `ANTHROPIC_TUNNEL_WIF_TOKEN` and preview access. `ANTHROPIC_WORKSPACE_ID` is optional and must match the token. Pass one optional PEM file path to create and archive a CA certificate. The example archives its tunnel and prints only resource IDs and the certificate fingerprint. No model ID is required. [MCP tunnels guide](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/overview)

## Runnable member sign-out

`organization_sign_out_example.dart` takes a `user_` ID and an `ANTHROPIC_ADMIN_KEY` with `write:members`. It demonstrates the documented account-wide sign-out and reports when a `503` requires an explicit repeat. The SDK retry policy does not retry HTTP `503` for POST operations. [Claude Enterprise member sign-out](https://platform.claude.com/docs/en/manage-claude/user-management#sign-a-member-out-everywhere)

## Files on Web

Byte upload, metadata retrieval, listing, deletion, and binary download use the same HTTP resource on native and Web builds. Use a CORS-enabled backend or proxy and keep Claude API keys in the backend. The browser example uses the compile-time `ANTHROPIC_PROXY_URL`. Local file-path upload uses Dart I/O. The README and Files example identify these transport requirements. [Files API](https://platform.claude.com/docs/en/build-with-claude/files)

## Cloud provider examples

| Example | Credentials and arguments | Claude model IDs | Coverage |
| --- | --- | --- | --- |
| `claude_aws_example.dart` | `AWS_REGION`, `ANTHROPIC_AWS_WORKSPACE_ID`, and `ANTHROPIC_AWS_API_KEY` or `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` with optional `AWS_SESSION_TOKEN` | `claude-sonnet-5-5` | Regional native Claude Messages |
| `bedrock_example.dart` | `AWS_REGION`, `AWS_BEARER_TOKEN_BEDROCK` or IAM credentials, mode `runtime` or `mantle`, and provider model or profile ID. Optional `BEDROCK_ANTHROPIC_VERSION` | CLI argument | Runtime AWS event stream or Mantle SSE |
| `google_cloud_example.dart` | `GOOGLE_CLOUD_PROJECT`, `GOOGLE_OAUTH_ACCESS_TOKEN`, mode `native` or `vertex`, and model ID. Native Messages also requires `ANTHROPIC_GOOGLE_CLOUD_WORKSPACE_ID`; Vertex accepts `CLOUD_ML_REGION` | CLI argument | Anthropic-managed and Vertex Messages routes |
| `foundry_example.dart` | `ANTHROPIC_FOUNDRY_RESOURCE` and `ANTHROPIC_FOUNDRY_API_KEY` or `AZURE_ACCESS_TOKEN`; deployment name. Set `ANTHROPIC_FOUNDRY_AZURE_HOSTED=true` for an Azure-hosted deployment | CLI deployment argument | Foundry SSE |

## Structured outputs

`structured_output_example.dart` uses `ANTHROPIC_API_KEY` and `claude-sonnet-5`. It decodes a constrained JSON result with the Messages helper. Pass `--stream` to accumulate and decode SSE. [Structured outputs](https://platform.claude.com/docs/en/build-with-claude/structured-outputs)

## Messages tool runner

`message_tool_runner_example.dart` uses `ANTHROPIC_API_KEY` and `claude-sonnet-5` or `claude-sonnet-5-5` for signed compaction. It decodes a custom tool call and returns a result before the next assistant turn. Pass `--stream` for SSE or `--thread` for the Messages threads beta. Pass `--compact` for stateless on-demand compaction. [Claude tool runner](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-runner)

## Web fetch and document sources

| Example | Credentials and arguments | Claude model IDs | Coverage |
| --- | --- | --- | --- |
| `web_fetch_example.dart` | `ANTHROPIC_API_KEY` and one HTTPS URL | `claude-sonnet-5-5` | Restricts eligible URLs to user input and displays provider fetch errors. |
| `custom_content_document_example.dart` | `ANTHROPIC_API_KEY` | `claude-sonnet-5-5` | Cites text from explicit document chunks and displays the cited block index. |

[Web fetch](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-fetch-tool) · [Citations](https://platform.claude.com/docs/en/build-with-claude/citations)

## Lazy Message Batches history

`batch_pagination_example.dart` uses `ANTHROPIC_API_KEY` or `ANTHROPIC_AUTH_TOKEN`. Optional `ANTHROPIC_WORKSPACE_ID`, `ANTHROPIC_BETAS` and a starting `after_id` preserve the request scope and pagination position. No Claude model ID is required. It requests the next page on demand and stops after 20 items. [Message Batches API](https://platform.claude.com/docs/en/build-with-claude/batch-processing)

## Browser toolset runner

`message_toolset_runner_example.dart` uses `ANTHROPIC_API_KEY` and `claude-sonnet-5-5` on a provider that supports browser toolsets. It sends a browser toolset definition, then echoes the member ID and family in the paired result with a typed `browser_state` block. Its executor is a stub and does not need a browser driver or visit the site. [Claude toolset guide](https://platform.claude.com/docs/en/agents-and-tools/tool-use/browser-use-sdk)

## Successful Messages response metadata

`message_response_metadata_example.dart` uses `ANTHROPIC_API_KEY` or `ANTHROPIC_AUTH_TOKEN` and `claude-sonnet-5-5`. It reads status and optional Claude request, workspace, AWS request and Azure request identifiers from one Messages response. A local HTTP fixture verified actual request headers and decoded output.

## Inline tool definitions

`inline_tools_example.dart` uses `ANTHROPIC_API_KEY`, `claude-sonnet-5-5`, and Claude API access to `inline-tools-2026-09-15`. It adds a custom inventory tool in a mid-conversation system message and prints the returned tool request. No local tool service or argument is needed. [Tool changes guide](https://platform.claude.com/docs/en/build-with-claude/mid-conversation-system-messages)

## Organization administration

| Example | Credentials and arguments | Claude model IDs | Coverage |
| --- | --- | --- | --- |
| `organization_telemetry_example.dart` | Authorized organization-level `ANTHROPIC_ADMIN_API_KEY` with telemetry destination access | — | Pages OpenTelemetry destinations and displays their delivery state. |
| `organization_claude_tag_example.dart` | `ANTHROPIC_ADMIN_API_KEY` with `read:claude_tag`, and one Slack workspace `T…` or Grid `E…` ID | — | Reads inherited Slack channel settings and setting sources through cursor paging. |
| `organization_plugins_example.dart` | `ANTHROPIC_ADMIN_API_KEY` with `read:plugins`; optional public marketplace GitHub repository URL | — | Pages organization-owned plugins and optionally validates a public marketplace. |
| `organization_webhooks_example.dart` | `ANTHROPIC_ADMIN_API_KEY` for an approved Claude API organization | — | Pages organization webhook endpoints with the required beta header. |
| `organization_webhook_receiver_example.dart` | `ANTHROPIC_WEBHOOK_KEY` and a local signed fixture to localhost port 8080 | — | Verifies Standard Webhooks signatures and parses events. Provider delivery was pending at the audit cutoff. |
| `federation_issuers_example.dart` | `ANTHROPIC_AUTH_TOKEN` with `org:admin` | — | Lists registered OIDC issuers and follows the returned cursor. |
| `service_accounts_example.dart` | `ANTHROPIC_AUTH_TOKEN` with `org:admin`; optional `svac_` ID | — | Lists service accounts or their workspace memberships. |
| `federation_rules_example.dart` | `ANTHROPIC_AUTH_TOKEN` with `org:admin`; optional `fdis_` ID | — | Lists federation rules, optionally filtered by issuer. |
| `external_keys_example.dart` | Authorized organization `ANTHROPIC_ADMIN_KEY` | — | Lists customer-managed encryption keys and follows a cursor without printing key coordinates. |
| `organization_analytics_example.dart` | Scoped `ANTHROPIC_ADMIN_API_KEY` and two UTC RFC 3339 timestamps | — | Pages through dimensioned usage and cost reports. |
| `organization_activity_example.dart` | Claude Enterprise Analytics key with `read:analytics` in `ANTHROPIC_ADMIN_API_KEY`, plus one UTC date as `YYYY-MM-DD` | — | Shows daily summaries, Claude Tag counts and complete cursor paging for user activity. |
| `organization_legacy_analytics_example.dart` | `ANTHROPIC_ADMIN_API_KEY` and the `console` or `enterprise` mode plus two UTC RFC 3339 timestamps | — | Reads a Console Admin or Enterprise Analytics report with its corresponding key type. |

[Manage WIF with the Admin API](https://platform.claude.com/docs/en/manage-claude/wif-admin-api)

## Integrated verification

The final documentation pass used feature-complete package source at `355327abe239e706e2ef2c0d97cbfa8d6386228a`. The README leads with a Messages quickstart. All 34 Usage headings contain collapsible content across 39 sections. The README, generated `llms.txt`, and this inventory list all 71 runnable examples once. The inventory covers their explicit credentials, command arguments and model IDs.

- Full unit suite passed with 2,970 tests and zero skips. Formatting, `dart fix` and strict package analysis were clean.
- The 44 README and 27 migration Dart snippets compiled with no errors or warnings. The analyzer reported 12 code-style infos for the extracted snippets.
- Link checks resolved 91 local targets and 77 external links, including official documentation anchors. Case-sensitive Dartdoc had zero warnings and zero errors. The same source before the documentation edits had 74 warnings for local README links and two unresolved Dartdoc references combined.
- The toolkit found no failing checks. The README advisory for the missing sign-out example link is resolved. The baseline implementation and consistency checks retain 4 and 2 advisories respectively. Documentation and export checks have none.
- Native loopbacks covered ordinary Messages, response identifiers, cache diagnostics, web fetch, structured output, tool runner and browser toolset callbacks, signed compaction, and batch cursor resume and early termination. Additional fixtures covered Files and Skills, Managed Agents deployments and Dreams, cloud transports, organization activity and legacy reports, sign-out, webhook signature and recovery, telemetry, Claude Tag, and plugin validation. No live Claude API calls were made.

- Both JSON migration pairs for direct assistant documents and nested user tool-result citations were exercised through the public client. The latter uncovered missing request fields fixed in #560. Explicit legacy requests retain citations and cache controls, and current requests reject nonempty user citations before dispatch.
