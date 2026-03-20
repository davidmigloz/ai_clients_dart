---
name: upskill
description: >-
  Extract validated review findings from merged PRs and update skill files
  (checklists, implementation patterns) to prevent recurring issues. Use
  whenever asked to learn from PR reviews, mine review comments, update
  review checklists, upskill from past feedback, or improve skills based
  on code review history — even if the user just says "upskill" or
  "learn from recent PRs."
---

# Upskill Skill for ai_clients_dart

This skill automates the feedback loop from PR reviews to skill files. It extracts validated review findings (comments marked `**Valid.**` by the PR author), consolidates them into generalizable patterns, and updates the review checklists and implementation pattern files to prevent recurring issues.

Parse `$ARGUMENTS` for options:
- **`/upskill`** — Full apply mode (no flags). Runs the complete workflow (Steps 1–9), updating files and state after confirmation.
- **`--plan`** — Extract and analyze findings without editing any files. Safe to run anytime.
- **`--dry-run`** — Run the full apply workflow (extraction, consolidation, validation, proposed updates) but stop before actually editing files. Shows exactly what would change without changing anything.
- **`--from N`** — Start after PR number N instead of the config's `last_checked_pr`.

---

## Step 1: Validate Environment

Perform all checks before proceeding. Fail fast with an actionable error message if any check fails.

1. **CLI availability**: `git`, `gh`, and `jq` must be on PATH.
2. **GitHub auth**: `gh auth status` must show authenticated.
3. **Repository root**: Use `git rev-parse --show-toplevel` to determine the repo root. All file paths are relative to this root.

> **Note:** The Bash tool does not persist `cd` across calls. Prefix all shell commands with `cd "$REPO_ROOT" &&` or use absolute paths.

4. **Rate limit**: Check remaining API calls:
   ```bash
   gh api rate_limit --jq '.rate.remaining'
   ```
   If remaining < 100, warn the user and stop — the extraction phase makes many API calls.

---

## Step 2: Determine PR Range

1. Read `.agents/skills/upskill/config/state.json`:
   ```json
   {
     "last_checked_pr": 122,
     "last_run_date": "2026-03-19"
   }
   ```
   > **Note:** On the very first run, `last_run_date` will be `null`. In this case, rely solely on `last_checked_pr` to determine the PR range.
2. If the file does not exist or is unreadable, default `last_checked_pr` to `0` and warn: "No state file found — this is a first run, scanning all merged PRs."
3. If `--from N` was provided, override `last_checked_pr` with N.
4. Set `START_PR` to the effective starting PR number: use the `--from N` value if provided, otherwise `last_checked_pr` from state.
5. Record the starting PR number for the summary.

---

## Step 3: Fetch Merged PRs

Use the GitHub REST API with pagination to fetch all closed PRs, then filter to merged ones above the starting PR number.

> **Note:** All `gh api` examples below use `{owner}/{repo}` as a placeholder. Derive the actual value from the current repository:
> ```bash
> gh repo view --json nameWithOwner --jq '.nameWithOwner'
> ```
> Use the result (e.g., `davidmigloz/ai_clients_dart`) in place of `{owner}/{repo}` throughout. Similarly, `{N}` refers to the PR number being processed.

```bash
gh api "repos/{owner}/{repo}/pulls?state=closed&per_page=100" --paginate \
  | jq -s --argjson start_pr "$START_PR" '[.[][] | select(.merged_at != null) | {number, title, merged_at, author: .user.login}]
  | [.[] | select(.number > $start_pr)] | sort_by(.number)'
```

`--paginate` emits one JSON array per page. Pipe into `jq -s` (slurp) to collect all pages into a single outer array, then `[][]` flattens it into one list before filtering and sorting.

- **0 results** → report "No new merged PRs since #N", stop.
- Display count before proceeding: "Found N merged PRs (#X to #Y)"

---

## Step 4: Extract Valid Findings

For each PR, fetch its review comments:

```bash
gh api "repos/{owner}/{repo}/pulls/{N}/comments" --paginate \
  | jq -s '[.[][] | {id, body, path, line, in_reply_to_id, user: .user.login}]'
```

Pipe into `jq -s` to merge all pages into one array so parent-comment lookup via `in_reply_to_id` works even when a parent and its reply land on different pages.

### Identification logic

1. Find comments where:
   - `body` starts with `**Valid.**`, **AND**
   - `user` matches the PR author (only the PR author's acknowledgments count, not maintainer or bot follow-ups), **AND**
   - `in_reply_to_id` is present and non-null (ignore top-level PR comments from the author that start with `**Valid.**` but have no parent).
2. Using `in_reply_to_id`, look up the parent comment; if no parent is found, skip this `**Valid.**` comment. Verify the parent comment has `user` different from the PR author (it should be a reviewer's comment, not a self-reply).
3. Build a finding record for each match:
   - **PR number** and **file path** (`path` field)
   - **Reviewer comment**: the parent comment's `body` — describes the issue/bug found
   - **Author acknowledgment**: the `**Valid.**` reply's `body` — may describe the fix or just confirm
   - **Commit diff context** (optional enrichment): if the acknowledgment references a commit hash, fetch the commit via `gh api repos/{owner}/{repo}/commits/{hash}` to get the actual fix. Otherwise, the reviewer's comment alone is sufficient — it describes what went wrong, which is what the skill files need to prevent.

### Scaling strategy

- **≤ 20 PRs**: Process inline in the main conversation. Most incremental runs will have 3–10 PRs with < 50 findings — fits easily in context.
- **> 20 PRs**: Spawn a single subagent with explicit instructions: "Process ALL PRs in this list. Do not stop early. Report progress every 10 PRs." Pass the full PR list and extraction logic. A single subagent is more reliable than parallel extractors.

### Early exit

- **0 findings across all PRs** → update `.agents/skills/upskill/config/state.json` to advance the cursor to the highest PR number processed (unless in `--plan` or `--dry-run` mode), report "No valid findings in N PRs", and stop.

---

## Step 5: Consolidate into Patterns (LLM-driven)

Take the raw findings and consolidate them into actionable patterns:

1. **Group**: Identify the same bug pattern appearing across different files or PRs → merge into one pattern with a count.
2. **Generalize**: Abstract an actionable rule from specific instances. The rule should be something a developer or agent can follow to avoid the issue in the future.
3. **Filter**: Keep patterns with 2+ instances OR a clear systemic pitfall (even from a single instance, if it reveals a gap in current guidance).
4. **Categorize**: Read the current section headings from the target files to derive the category list dynamically — do not use a hardcoded list.
   - For **core-scoped** patterns: read section headings from `REVIEW_CHECKLIST-core.md` and `implementation-patterns-core.md`.
   - For **package-specific** patterns: also read the relevant per-package files (e.g., `packages/openai_dart/.agents/skills/openapi-openai/references/REVIEW_CHECKLIST.md`). Each package's files may have different section structures — adapt accordingly.
   - Map each pattern to the most relevant existing section. If no existing section fits, propose a new section name.
   - **Fallback**: If a target file has no section headings (e.g., a new or flat file), treat the entire file as a single "General" section and place patterns there.
5. **Target**: Determine which file each pattern belongs in:
   - Short checklist item → `REVIEW_CHECKLIST-core.md` (or per-package `REVIEW_CHECKLIST.md`)
   - Detailed pattern with code examples → `implementation-patterns-core.md` (or per-package `implementation-patterns.md`)
   - Package-specific pattern → the corresponding per-package file

### Output format

Present consolidated patterns in this format:

```
## Consolidated Patterns (N patterns from M raw findings)

### Pattern 1: {name} ({count} occurrences)
- **Category**: {section name from target file}
- **Target**: {file path(s)}
- **Rule**: {1-line actionable rule}
- **Code example**: {if applicable — show wrong vs right}
- **PRs**: #{X}, #{Y}

### Pattern 2: ...
```

---

## Step 6: Validate Against Existing Skill Files

Read every target file identified in Step 5. For each consolidated pattern, classify it as:

- **Already covered** — the pattern is already documented (same rule, same scope). Skip it.
- **Enhance existing** — a related item exists but the new pattern adds nuance, a new code example, or a broader scope. Augment the current item.
- **New addition** — no existing item covers this pattern. Add it as a new item in the appropriate section.

Present the validation results:

```
## Validation Results

### Already covered (skip)
- Pattern 1: {name} — covered by {file}:{section}:{item}

### Enhance existing
- Pattern 2: {name} — augments {file}:{section}:{item}

### New additions
- Pattern 3: {name} — new item in {file}:{section}
```

In **`--plan` mode**: display these results and stop here. Do not edit any files.

---

## Step 7: Present Proposed Updates

For each pattern classified as "Enhance existing" or "New addition", show the exact proposed change:

```
### Update 1: {pattern name}
**File**: .agents/shared/api-toolkit/references/REVIEW_CHECKLIST-core.md
**Section**: {section name from file, or "General" if no sections exist}
**Action**: Add new checklist item after existing item about X

**Text to add**:
- [ ] **{Rule name}**: {1-line description of the rule}

---
```

In **`--dry-run` mode**: display the proposed updates and stop here. Do not edit any files or update config.

Wait for user confirmation before proceeding. The user may:
- **Approve all** → proceed to Step 8
- **Approve some, reject others** → apply only approved changes
- **Modify wording** → use the user's version instead

---

## Step 8: Update Skill Files

Apply confirmed changes by editing the files directly. Read each target file first, then apply precise edits.

### Strict file scope — only these files may be edited:

- `.agents/shared/api-toolkit/references/REVIEW_CHECKLIST-core.md`
- `.agents/shared/api-toolkit/references/implementation-patterns-core.md`
- `packages/*/.agents/skills/*/references/REVIEW_CHECKLIST.md`
- `packages/*/.agents/skills/*/references/implementation-patterns.md`
- `.agents/skills/upskill/config/state.json` (state tracking — updated in Step 9)

### Must NOT edit:

- Any Dart source code (`*.dart`)
- Any `SKILL.md` file
- `CLAUDE.md`
- Any file not listed in the "Strict file scope" section above

### Table of contents

If `implementation-patterns-core.md` gains a new section and the file has a table of contents, update it to include a link to the new section.

---

## Step 9: Update Config & Report

### Update state

Write `.agents/skills/upskill/config/state.json` with the highest PR number processed and today's date:

```json
{
  "last_checked_pr": {highest_pr_number},
  "last_run_date": "{YYYY-MM-DD}"
}
```

### Summary report

Present a summary of the run:

```
## Upskill Summary

PRs processed: #{first} to #{last} (N PRs)
Valid findings: M
Consolidated patterns: P
  Already documented: A
  Enhanced existing: E
  New additions: N

Files updated:
- REVIEW_CHECKLIST-core.md (+N items)
- implementation-patterns-core.md (+N sections)
- packages/openai_dart/.../REVIEW_CHECKLIST.md (+N items)
```

Suggest using `/create-pr` to push the changes.

---

## Edge Cases

1. **0 new PRs** → report "No new merged PRs since #{N}", stop.
2. **0 findings** → update `.agents/skills/upskill/config/state.json` to advance cursor (unless in `--plan` or `--dry-run` mode), report "No valid findings", stop.
3. **All patterns already documented** → report, update `.agents/skills/upskill/config/state.json` (unless in `--plan` or `--dry-run` mode), stop.
4. **No config file** → first run, default `--from 0`, warn user.
5. **Rate limit < 100** → warn and stop before making API calls.
6. **`--plan` mode** → run through Step 6, display results, skip all edits (including config update).
   - **`--dry-run` mode** → run through Step 7 (show proposed updates), skip all file edits and config updates.
7. **PR has 0 review comments** → skip that PR, continue to next.
8. `**Not applicable.**` or other non-Valid replies → filter to `**Valid.**` prefix only.
9. **> 20 PRs to process** → spawn single subagent for extraction to avoid context overflow.
10. **Parent comment not found** → if `in_reply_to_id` points to a comment not in the fetched set (edge case with deleted comments), skip that finding and warn.
