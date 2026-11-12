# Align Files, Skills, memory, vaults and deployments

[GitHub issue #485](https://github.com/davidmigloz/ai_clients_dart/issues/485).

Tracks [#477](https://github.com/davidmigloz/ai_clients_dart/issues/477). Slice `08-agent-resources` of the [fixed November alignment](https://github.com/davidmigloz/ai_clients_dart/issues/477).

Reconcile existing GA Files/Skills and the Managed Agents ancillary resources with the current wire contract and public beta aliases.

## Dependencies

- #478
- #479

## Acceptance

- [ ] Verify all supported upload/download and multipart flows using deterministic local bytes, media types and failure metadata.
- [ ] Cover current memory stores, memories, versions, vault credentials, dreams, deployments and deployment-run changes, including list filters and gated endpoints.
- [ ] Document legacy beta headers, GA aliases and availability, and preserve earlier callers across current and legacy responses.
- [ ] Independently reviewed against the pinned sources; exact-head CI passes before squash merge.

Use public-entry-point fixtures and the package review checklist. Keep live API calls outside this work.

## Files and Skills source decisions

- Files GA has upload, list, retrieve, delete, and download. The equivalent current beta namespace uses the same paths and shape, with optional beta header selection and the scoped list query. The Managed Agents guide requires `managed-agents-2026-04-01` on scoped listing. Dart selects it for scopeId, preserves explicit managed-agent beta names and caller routing, and permits current page cursors or the documented compatibility ID cursors. No live calls were made. [Files guide](https://platform.claude.com/docs/en/build-with-claude/files) · [Session files](https://platform.claude.com/docs/en/managed-agents/files)
- Pinned Skills body schemas call the array `files`. Both SDK serializers and the API guide send repeated `files[]` multipart parts. Dart preserves that shape, caller-supplied media types, and relative filenames. The API guide allows root SKILL.md although some generated schema descriptions mention a top-level directory. Dart sends either layout unchanged. [Python upload extraction](https://github.com/anthropics/anthropic-sdk-python/blob/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/_utils/_utils.py) · [TypeScript uploads](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/internal/uploads.ts) · [Skills guide](https://platform.claude.com/docs/en/build-with-claude/skills-guide)
- Skills GA has eight CRUD operations. Both pinned official SDKs also expose the ZIP download in the beta namespace and send no default beta header. Their binary convention is `Accept: application/binary`; the documented download response media types are ZIP or file-specific binary. Both Dart operations preserve raw bytes. [TypeScript skill downloads](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/resources/beta/skills/versions.ts) · [TypeScript files](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/resources/files.ts)
- The older Files header can return `has_more`, `first_id`, and `last_id` without expiration metadata. This shape is supported and tested. The older Skills header can return `display_title`, string source, and a nullable microsecond version pointer. Current typed Dart and official SDKs use current Skills shapes. Documented migration removes the historical header. [Files migration](https://platform.claude.com/docs/en/build-with-claude/files#migrate-from-files-api-2025-04-14) · [Skills migration](https://platform.claude.com/docs/en/build-with-claude/skills-guide#migrate-from-skills-2025-10-02)
- File upload, file download, skill multipart upload and ZIP download now have fixtures on the normal public paths using non-UTF-8 bytes and real finalized multipart headers. Response-body request IDs and known error codes survive 404 expired downloads and 400 duplicate skill failures. Earlier cancellation and malformed response fixtures remain in #501 and #502.
- Documentation inventory verified package README Files and Skills Usage, `files_example.dart`, `skills_example.dart`, their example-index entries, and Dartdoc in FilesResource, SkillsResource, FileListResponse, SkillFile, and SkillSource. Regenerated llms.txt in scratch and verified toolkit docs and README. Runnable examples document ANTHROPIC_API_KEY and arguments. The Dart Files resource still requires dart:io, documented in its Usage section.
- The final `scope_id` query controls the Managed Agents beta, including base-URL and configured query parameters. Files and Skills encode each identifier as one segment and reject empty or dot-only identifiers before dispatch, including dot prefixes followed by semicolon parameters. [Pinned TypeScript path encoder](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/internal/utils/path.ts)
