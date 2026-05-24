# Changelog Format

Format spec for **Step 5** of the release skill. For each released package, prepend a
new `## {new_version}` section to `packages/{pkg}/CHANGELOG.md`. Use the PR summaries
collected in Step 4b as the **primary source** for the AI-written summary; fall back to
commit messages when PR context is unavailable.

### Changelog section format

```markdown
## {new_version}

> [!CAUTION]                                                                                                           ← only if breaking
> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

{AI-written summary of main changes, 1-3 sentences}

- **BREAKING** **FEAT**: Description ([#N](https://github.com/davidmigloz/ai_clients_dart/issues/N)). ([abcd1234](https://github.com/davidmigloz/ai_clients_dart/commit/{full_40_char_hash}))
- **FEAT**: Description. ([abcd1234](https://github.com/davidmigloz/ai_clients_dart/commit/{full_40_char_hash}))
- **FIX**: Description. ([abcd1234](https://github.com/davidmigloz/ai_clients_dart/commit/{full_40_char_hash}))
```

### Formatting rules

1. **Remove package scope** from entries: `feat(googleai_dart): Foo` → `**FEAT**: Foo`
2. **Short hash** in display = first **8 characters** of the commit hash
3. **Full 40-char hash** in the commit URL
4. **Extract issue numbers** from:
   - `(#N)` in the commit subject — there may be **multiple** references (e.g., `(#913) (#914)`); collect all of them
   - `Closes #N`, `Fixes #N`, `Resolves #N` in the commit body
   - Render all collected issue numbers in the order they appear: `([#913](...)) ([#914](...))`
   - If no issue number found, omit the issue link portion entirely
5. **Ordering within the changelog section**:
   - BREAKING entries first (any type with breaking change)
   - Then release-triggering types: FEAT, FIX, REFACTOR, PERF, DOCS
   - Then non-release types (if included): BUILD, STYLE, CI, TEST, CHORE
   - Within each type group, sort by **commit date descending** (newest first)
6. **All links in new changelog entries** must point to `https://github.com/davidmigloz/ai_clients_dart` (older historical entries may still reference `davidmigloz/langchain_dart` — leave those as-is)
7. **Standard markdown list**: `- **TYPE**: ...` (no leading space)
8. **Breaking note**: Only include the following if there are breaking changes:
   ```
   > [!CAUTION]
   > This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.
   ```
9. **AI summary**: Write 1-3 sentences summarizing the main changes in plain English. Place it between the breaking note (if any) and the entry list.

   **Primary source**: Use the PR summaries collected in Step 4b as the primary source for writing the summary. PR descriptions contain the rationale, scope, and user-facing impact that commit subjects lack. Synthesize across multiple PRs into a coherent narrative — do not simply parrot PR titles or concatenate bullet points.

   **Quality guidance**:
   - Focus on **user-facing impact**: what changed, why it matters, and any migration notes
   - Mention specific capabilities added or problems fixed, not just "updated X"
   - If a release includes breaking changes, call out what broke and what users need to do

   **Announcement links**: If PR references include links to official
   announcements or blog posts (from the `references` field collected in
   Step 4b), weave them naturally into the summary prose using inline
   markdown links — e.g., "Added [Gemini Embedding 2](https://blog.google/...)
   support." Do not create a separate references list; embed the links where
   they add context to the narrative.

   **Fallback**: If PR context is unavailable for some or all commits (e.g., Step 4b was skipped, PRs failed to fetch, or commits have no PR references), fall back to commit messages. Synthesize commit subjects into the best summary possible.

   **Before/after example** — commit-only summary (current quality):
   > Updated OpenAPI spec and added new models.

   **PR-enriched summary (target quality):**
   > Update ChromaDB client to latest API spec — adds quantization support, spanned index config, and read-level controls for queries. Collection fields that were previously nullable are now required, matching the upstream API contract.

### Pre-existing changelog sections

Before writing a new changelog section, check if `## {new_version}` already exists in `CHANGELOG.md`:

1. **Detection**: Match `^## {new_version}` (exact version, at start of line) in the file.
2. **If the section already exists**:
   1. **Review the existing content for quality**: Pre-existing sections may be draft notes, rough bullet points, or incomplete text from a PR. Read the content carefully and ensure it is polished, well-structured, and presentable as a published changelog. Fix grammar, formatting, missing links, or unclear descriptions. Ensure it follows the same formatting conventions as the rest of the changelog (bold type prefixes, issue/commit links, ordering rules defined above).
   2. **Append** a `### Commits` subsection at the end of the existing section with the auto-generated commit entries (using the standard formatting rules above). This preserves the hand-written narrative while adding the structured commit log.
   3. If the existing section lacks a breaking change note but the commits include breaking changes, add the `> [!CAUTION]` / `> This release has breaking changes. See the [Migration Guide](MIGRATION.md) for upgrade instructions.` admonition at the top of the section (after the `## {version}` heading).
3. **If the section does not exist**: Proceed with normal prepend behavior as described above.
