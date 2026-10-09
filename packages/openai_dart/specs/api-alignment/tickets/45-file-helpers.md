# Portable file and artifact convenience

Status: deferred outside the bounded milestone; not implemented.
GitHub: [#397](https://github.com/davidmigloz/ai_clients_dart/issues/397).
Primary requirements: `AGENTS-FILE-HELPER-01`, `AGENTS-FILE-HELPER-02`, `AGENTS-FILE-HELPER-03`.
Native GitHub blockers: [#390](https://github.com/davidmigloz/ai_clients_dart/issues/390), [#396](https://github.com/davidmigloz/ai_clients_dart/issues/396).
Original tracker: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317); removed from its active child list.
Specification: [Agents and Vaults](../agents-vaults.md), AGENTS-FILE-HELPER-01–03.
Dependencies: [ticket 38](38-files-artifacts.md) and [ticket 44](44-result-parser.md).

Deferred backlog: retained for future explicit prioritization; this ticket does not block completion of #317. Its acceptance remains unchecked, and implementation will not start automatically.

## User capability and scope

A caller can stage explicitly selected portable file data using the existing
Files API, retain observed uploads after a partial failure, locate one published
artifact for the completed session/turn/path and download its exact binary
content. An optional isolated filesystem adapter accepts explicit local paths.
This owns **zero new HTTP operations**; ticket 38 owns raw file/artifact resources.

Portable byte/stream APIs must remain usable in browsers and Wasm. Filesystem
selection belongs to an optional dart:io entrypoint, separate from the main
library. Published artifacts outlive an expired hosted environment; live files
are mutable and require a connected environment. Unpublished outputs have no
promised recovery or persistence.

## Acceptance criteria

- [ ] Explicit selected data uploads through the existing Files API with purpose=user_data, then maps returned file IDs to caller-selected /workspace destinations. Validate all destinations before uploads; ordering is deterministic and no directory synchronization or automatic deletion occurs.
- [ ] Upload/staging failure and cancellation expose detached IDs of uploads actually observed as successful so the caller can clean them up. Never fabricate an ID after uncertain delivery or delete files automatically; private bytes/path metadata stay out of printable errors.
- [ ] Artifact lookup matches the exact session, completed turn and hosted path across all pages, rejecting zero or multiple matches. Wrong-turn/path candidates and page-two matches have actual public mock fixtures.
- [ ] Preserve opaque artifact last_id cursors, including nullable legacy item IDs, and reject repeated/nonadvancing pagination instead of looping. Do not substitute the separate live-file page/next pagination contract.
- [ ] Portable binary download/sink methods preserve non-UTF8 bytes and release sources on sink failure or abort. A hosted artifact path never chooses the local output destination.
- [ ] The optional filesystem adapter accepts only explicit caller-selected regular files/destinations and verifies symlink, replacement/identity and size-change cases. It documents stable application-owned directories as an operational requirement, without claiming a filesystem sandbox.
- [ ] Before implementation, explicitly choose and document Dart overwrite behavior. Test parent/destination type, symlink and overwrite cases; do not claim Node's verified regular-file overwrite policy and Python's delegated stream_to_file behavior are identical.
- [ ] Portable model ownership/copy/equality/hash and diagnostic privacy cover filenames, staged IDs, partial failures and artifact selections; filesystem implementation and tests stay isolated from the browser entrypoint.
- [ ] A public offline example stages selected bytes, collects a completed result, finds its uniquely matched artifact and downloads to an explicit sink. README/llms and exports distinguish portable helpers, optional IO and caller cleanup.
- [ ] Portable fixtures pass on VM, actual Chrome JavaScript and Wasm; optional IO fixtures run on VM only. Appropriate package checks, independent requirements/engineering reviews and exact final-head CI pass before user-authorized merge.

## Evidence and validation plan

Sources are pinned [Python file helpers](https://github.com/openai/openai-python/blob/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/lib/beta/agents/_files.py),
[Node file helpers](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/beta/agents/files.ts),
[Python artifact lookup](https://github.com/openai/openai-python/blob/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/lib/beta/agents/_artifacts.py),
[Node artifact lookup](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/beta/agents/result-artifacts.ts)
and [Node filesystem helpers](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/helpers/beta/agents/filesystem.ts).
Wire authority remains the raw ticket's canonical OpenAPI mappings.

Default validation uses synthetic bytes, public mocks and temporary local files:
**no API key, live call or cost**. Planning evidence satisfies no checkbox.
No runtime provider, automatic cleanup, release or version bump is included.
