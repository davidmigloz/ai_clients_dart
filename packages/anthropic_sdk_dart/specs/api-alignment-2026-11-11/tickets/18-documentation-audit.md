# Audit all Anthropic documentation and examples

[GitHub issue #503](https://github.com/davidmigloz/ai_clients_dart/issues/503).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Audit the entire package's documentation against the November 11 fixed source set and the public Dart API after the implementation slices merge. Start with existing content and repeat the check against the integrated package before #492 closes.

## Scope

- Package and repository README entries, installation and quickstart, collapsible Usage sections, the example index, every runnable Dart example, `llms.txt`, `MIGRATION.md`, package metadata links, public Dartdoc and linked developer documentation.
- Messages, tools and streaming, batches, Files and Skills, Managed Agents, Profiles, Admin, Compliance and provider adapters. Check feature availability, credentials, headers, API versions, model IDs, beta gates, platform restrictions, deprecations and retirements.
- Existing and newly introduced snippets. Compare every request and response shape, public import, symbol, parameter and option with the pinned sources and merged Dart code.

## Acceptance

- [ ] Record an inventory of the files, runnable examples and Usage topics reviewed. Fix stale text and broken links, and route any discovered behavior gaps to the appropriate implementation issue with evidence.
- [ ] Lead the package README with a basic Messages call. Keep Usage topics collapsible and ordered by relevance. Align the examples, index and quickstart on the supported default API version. Document the explicit legacy option and before-and-after snippets for each breaking change.
- [ ] Confirm each runnable example has the required environment or argument instructions. Verify examples with static analysis and use local transport fixtures for behavior that static analysis cannot check. Keep historical changelog entries intact.
- [ ] Run the Anthropic toolkit documentation and example-index workflow, regenerate `llms.txt`, and verify export coverage, index consistency and link targets against the reviewed tree.
- [ ] Complete an independent adversarial review and pass CI on each exact documentation PR head before squash merge. Report verification evidence and any exact remaining access blocker in #492.

Use local fixtures. Live API calls require separate authorization.

## Baseline findings

- The root README installs `anthropic_sdk_dart: ^1.4.0`, while the package is at 10.0.0. The package README places Features before the basic Messages quickstart and retains older provider documentation links.
- Baseline Dartdoc generated successfully with 76 warnings on the macOS checkout. Investigate unresolved symbol references, relative README links that do not resolve inside generated API docs, and case-only MCP name collisions in generated file paths. Compare on a case-sensitive filesystem before attributing warnings to the package API.
- The package README index omits `abort_example.dart` and `batch_example.dart`. Review whether each is distinct and index every retained example. Check all 36 baseline examples, including the older Messages MCP connector example and model IDs in Managed Agents snippets, against the applicable pinned API contract.
