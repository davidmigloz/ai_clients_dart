---
name: create-pr
description: >-
  Create a pull request for the ai_clients_dart monorepo with proper
  conventional commit titles, structured descriptions, labels, and assignees.
  Use this skill whenever the user asks to create a PR, open a pull request,
  push changes for review, submit changes, or anything related to creating
  or opening a GitHub pull request — even if they don't say "PR" explicitly.
---

# Create PR Skill for ai_clients_dart

This skill creates pull requests with proper conventional commit titles, structured descriptions that serve as extended changelog entries, correct labels, and the right assignees. It analyzes changes, creates commits, generates a branch, and opens the PR via `gh`.

Parse `$ARGUMENTS` for options:
- **`--draft`** — create the PR as a draft
- **`--base <branch>`** — target a different base branch (default: `main`)
- Any remaining free-form text is treated as **context or instructions** about which changes to include or how to describe them

---

## Step 1: Validate Environment

1. **CLI availability**: `git` and `gh` must be on PATH.
2. **GitHub auth**: `gh auth status` must show authenticated.
3. **Repository root**: Use `git rev-parse --show-toplevel` to determine the repo root. All commands should use absolute paths or `cd` to repo root first (Bash doesn't persist `cd` between calls).
4. **Base branch**: Resolve `{base}` from `--base` argument (default: `main`). Verify it exists: `git rev-parse --verify {base}`. If it fails, try `git fetch origin {base}` and re-verify. If still invalid, report the error and stop.

---

## Step 2: Analyze Changes

Gather the full picture of what needs to go into the PR.

1. **Uncommitted changes**:
   ```bash
   git status --porcelain    # all modified/untracked/staged files
   git diff --stat           # unstaged changes summary
   git diff --cached --stat  # staged changes summary
   ```

2. **Existing commits on branch** (if already on a non-base branch):
   ```bash
   git log {base}..HEAD --oneline   # {base} is the --base argument, default: main
   ```

3. **Categorize by package**: For each changed file, extract the `packages/{pkg}/` prefix. Files outside `packages/` go into a "root" category.

4. **No changes?** If the working tree is clean AND there are no commits ahead of the base branch, report this and stop.

5. **User-specified subset**: If the user's instructions mention specific files or packages to include, filter to only those. Otherwise, include all changes by default — the user asked for a PR, so include everything. Only ask for clarification if the user's `$ARGUMENTS` mention a package or scope but it's genuinely ambiguous which files they mean.

Present findings:
```
Changes detected:
  packages/openai_dart/ — 5 files modified
  packages/open_responses/ — 12 files modified, 3 new files
  Root — 2 files modified

Existing commits on branch (2):
  abc1234 feat(openai_dart): add response stream extensions
  def5678 fix(openai_dart): handle null content in delta
```

---

## Step 3: Understand Changes

Read the changed files to understand **what** was modified and **why** it matters. This context is essential for writing a good PR title and description — you cannot write a meaningful `## Summary` or `## Details` section from file names alone.

- For modified files, read the diff (`git diff` or `git diff --cached`) to understand the nature of changes
- For new files, read their content
- Identify the user-facing impact: new APIs, changed behavior, fixed bugs, breaking changes
- Note any patterns: is this an OpenAPI spec update? A new feature? A bug fix? A refactor?

---

## Step 4: Determine Commit Strategy

Based on the analysis, propose how to group changes into commits:

- **Single package, single type**: One commit. Example: `feat(chromadb): add quantization support`
- **Single package, mixed types**: Separate commits per type. Example: `feat(openai_dart): add streaming extensions` + `fix(openai_dart): handle null content`
- **Multiple packages, related change**: One commit with no scope or a shared scope if the change is logically unified. Example: `fix: resolve verification warnings`
- **Multiple packages, unrelated changes**: Suggest splitting into separate PRs. If the user wants one PR, create separate commits per package/type.

Log the commit plan for the user's reference (this is informational, not a confirmation gate — proceed immediately after):
- The conventional commit message
- Which files are included
- The commit type classification

> If there are already commits on the current branch (from Step 2), incorporate those into the plan — don't re-commit changes that are already committed. Only create new commits for uncommitted changes.

### Conventional commit format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Types**: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `chore`, `build`, `style`, `ci`

**Scope**: The package name (e.g., `openai_dart`, `chromadb`). Omit scope for cross-cutting changes.

**Breaking changes**: Add `!` after the type/scope (e.g., `feat(chromadb)!: make collection fields required`) or include `BREAKING CHANGE:` in the commit body footer.

---

## Step 5: Create Branch

If already on a non-base branch with relevant commits, reuse it.

Otherwise, generate a branch name:
- **Single package**: `{type}/{pkg}-{kebab-case-description}`
  Example: `feat/chromadb-quantization-support`
- **Multiple packages**: `{type}/{kebab-case-description}`
  Example: `fix/resolve-verification-warnings`
- Maximum 60 characters — truncate the description if needed
- If the branch name already exists, append a counter: `-2`, `-3`, etc.

Create the branch directly:
```bash
git checkout -b {branch-name}
```

---

## Step 6: Create Commits

For each commit in the plan from Step 4:

1. **Stage specific files** — never use `git add -A` or `git add .`
   ```bash
   git add path/to/file1 path/to/file2
   ```
2. **Never stage sensitive files** — skip `.env`, credentials, API keys. Warn the user if such files appear in the changes.
3. **Commit with HEREDOC format**:
   ```bash
   git commit -m "$(cat <<'EOF'
   type(scope): description

   Optional body with more context.
   EOF
   )"
   ```
4. **Verify**: `git log -1 --oneline`

If a pre-commit hook fails: diagnose the issue, fix it (e.g., run `dart format`), re-stage the affected files, and create a **NEW** commit (never amend).

If a pre-commit hook succeeds but modifies files (e.g., a formatter rewrites staged files), the commit goes through with the pre-hook content. Check `git status` after each commit — if the hook left modified files, stage them and create an additional commit (e.g., `style: apply formatting`).

---

## Step 7: Generate PR Title

Derive from the commits:

- **Single commit**: Use the commit subject as-is
  Example: `feat(chromadb): update OpenAPI spec and implement new models`
- **Multiple commits, same package**: Most significant type + package scope + synthesized description
- **Multiple commits, multiple packages**: Most significant type + no scope (or comma-separated scopes if 2-3 packages) + synthesized description

**Type significance order** (use the highest): `feat` > `fix` > `refactor` > `perf` > `docs` > `chore`

Title must be **under 70 characters**. If the user provided a title override via `$ARGUMENTS`, use it — but warn if it doesn't follow conventional commit format.

---

## Step 8: Generate PR Description

The PR description serves two audiences: **package consumers** who discover changes through changelogs and want to understand what's new, and **code reviewers** who need to assess the changes. Structure it to serve both.

### Template

```markdown
## Summary
- Primary change and user-facing impact
- Secondary changes or additional context

## Details

[Additional context that wouldn't fit in a changelog bullet. Include when applicable:]
- New API usage examples with code blocks
- Configuration changes and their effects
- Architecture decisions and trade-offs
- Behavioral changes and their rationale

## Breaking Changes

> Only include this section if there are breaking changes.

- What changed and why it's breaking
- Migration path with before/after code examples:

  ```dart
  // Before
  final name = collection.name ?? 'unknown';

  // After — name is now non-nullable
  final name = collection.name;
  ```

## References

> Only include this section when there are official announcements, blog posts,
> release pages, or documentation links that add context for package consumers.

- [Link title](URL) — brief description of relevance

## Test Plan

- [ ] Unit tests pass for affected packages
- [ ] New tests added for new functionality
- [ ] Sealed class/enum changes include variant, round-trip, and error tests
- [ ] `fromJson`/`toJson` round-trip serialization verified
- [ ] `==`/`hashCode` contract verified (same fields in both)
```

### Writing guidance

**`## Summary`** — This is what the release skill extracts for changelog entries. Write bullets that explain the **user-facing impact**, not just what files changed. Be specific about capabilities added, bugs fixed, or behaviors altered. A consumer reading only this section should understand what the release means for them.

**`## Details`** — This is the extended changelog entry. When a consumer sees a changelog bullet and wants to know more, they open the PR and read this section. Include code examples showing how to use new APIs, explain non-obvious design decisions, and provide context that helps someone adopt the changes. This section is **optional for trivial changes** (typo fixes, dependency bumps) but **expected for features and breaking changes**.

**`## Breaking Changes`** — Only present when commits include `!` or `BREAKING CHANGE:` footer. The release skill uses this section as a reliable signal for semver verification — it's more precise than heuristic phrase matching in the general body. Always include migration steps with before/after code.

**`## References`** — Optional. Include when the PR relates to an official
announcement, blog post, API release page, or documentation update from the
upstream provider. The release skill uses these links to enrich changelog
summaries (e.g., linking to a provider's blog post about a new model). Each
entry should have a descriptive title, the URL, and a brief note on why it
matters. If there are no relevant external links, omit the section entirely.

**`## Test Plan`** — Checklist of what was tested or needs testing. Helps reviewers know what to verify. Check the boxes (`[x]`) for items you have already verified (e.g., tests you ran before creating the PR). Leave unchecked (`[ ]`) only items that still need verification.

**Documentation accuracy** — Before finalizing the PR, verify that README examples, doc comment method names, and field lists still match the implementation. Renames and field additions are common sources of stale documentation.

---

## Step 9: Determine Labels

### Package labels (`p:`)

Map changed directories to labels using this table:

| Directory | Label |
|-----------|-------|
| `anthropic_sdk_dart` | `p:anthropic_sdk_dart` |
| `chromadb` | `p:chromadb` |
| `googleai_dart` | `p:googleai_dart` |
| `mistralai_dart` | `p:mistralai_dart` |
| `ollama_dart` | `p:ollama_dart` |
| `open_responses` | `p:open_responses_dart` |
| `openai_dart` | `p:openai_dart` |
| `openai_realtime_dart` | `p:openai_realtime_dart` |
| `tavily_dart` | `p:tavily_dart` |
| `vertex_ai` | `p:vertex_ai` |

> Note the special case: directory `open_responses` maps to label `p:open_responses_dart`.

Apply one `p:` label for each affected package. If changes are only in root files (outside `packages/`), omit the `p:` label — this is valid for cross-cutting changes like CI, docs, or skill files.

### Type labels (`t:`)

Map from the **most significant** commit type across all commits:

| Commit Type | Label |
|-------------|-------|
| `feat` | `t:feature` |
| `fix` | `t:bug` |
| `docs` | `t:docs` |
| `refactor`, `perf` | `t:enhancement` |
| `chore`, `build`, `ci`, `style`, `test` | `t:chore` |

Apply exactly one `t:` label.

---

## Step 10: Determine Assignee

Read `.github/CODEOWNERS` and match changed file paths against the patterns to find the code owner(s). Currently all paths map to `@davidmigloz`.

```bash
cat .github/CODEOWNERS
```

If CODEOWNERS is extended in the future, match the most specific pattern for each changed file and collect unique owners.

---

## Step 11: Push and Create PR

Do NOT ask the user for confirmation — proceed directly. The user asked you to create a PR, so create it. They can always edit later via the GitHub UI or `gh pr edit`.

### Push and create

1. **Push**:
   ```bash
   git push -u origin {branch-name}
   ```

2. **Create PR**:
   ```bash
   gh pr create \
     --title "the pr title" \
     --body "$(cat <<'EOF'
   ## Summary
   - ...

   ## Details
   ...

   ## Test Plan
   - [ ] ...
   EOF
   )" \
     --label "p:chromadb,t:feature" \
     --assignee "davidmigloz" \
     --base {base}
   ```
   Add `--draft` if the user requested it or passed `--draft` in arguments.

3. **Report the PR URL** to the user.

---

## Edge Cases

1. **No changes** → report and stop
2. **Already on a feature branch with commits** → detect and reuse; only create new commits for uncommitted changes
3. **Changes only outside `packages/`** → omit `p:` label; use root scope or no scope for commits
4. **Breaking changes** → ensure `!` in commit type, include `## Breaking Changes` section in PR body
5. **User wants to split into multiple PRs** → guide them to specify a subset, create one PR, then repeat
6. **Branch name collision** → append counter suffix (`-2`, `-3`, etc.)
7. **Pre-commit hook failure** → fix issue, re-stage, create NEW commit (never amend)
8. **User overrides title** → use as-is, but warn if it doesn't follow conventional commit format
9. **Sensitive files in changes** → never stage `.env`, credentials, keys; warn the user
10. **Mixed staged and unstaged changes** → include all by default; if the user specified a subset, filter to that
11. **Auto-synced files** → some files (e.g., CLAUDE.md) may be auto-generated by hooks; after staging, verify all expected files are included via `git status`
12. **Existing PR on branch** → if `gh pr view` shows an open PR on the current branch, push the new commits and update it with `gh pr edit` (title, body, labels) instead of creating a new one; report the existing PR URL
