# AI Clients Dart

A collection of Dart client libraries for popular AI APIs. Provides type-safe, well-documented, and idiomatic interfaces to OpenAI, Anthropic, Google AI (Gemini), Mistral, Ollama, and other providers. Ready for Dart and Flutter.

## Repository Structure

This repository uses a **Pub Workspace** defined at the root level (`/pubspec.yaml`).

```
ai_clients_dart/
├── packages/             # Client packages
├── pubspec.yaml          # Workspace root, centralized dependencies, melos config
└── analysis_options.yaml # Dart linting rules
```

## Development Commands

### Dart Monorepo Setup

```bash
# Workspace initialization (CLI required for melos) - run from repository root
melos bootstrap   # Install dependencies and link local packages
```

### Code Quality

Use CLI commands with quiet flags to minimize context noise. Run in this order — `dart fix` auto-fixes analyzer issues before `dart analyze` surfaces only those needing manual attention:

```bash
dart format --show=none --summary=line .   # Format; only prints summary
dart fix --apply                           # Auto-fix analyzer issues with quick fixes
dart analyze .                             # Only shows issues needing manual attention
```

### Testing

```bash
dart test --reporter=failures-only packages/<pkg>/test/unit/   # Only prints failures
```

**IMPORTANT**: Never run integration tests (which hit live APIs) unless explicitly requested by the user — they are expensive. Only run unit tests by default by targeting `test/unit/` directories (e.g., `dart test --reporter=failures-only packages/<pkg>/test/unit/`).

**Test placement rules:**
- `test/integration/` — Tests that hit **live external APIs** (require API keys, network access). Must be tagged with `@Tags(['integration'])` and include a `library;` directive so CI can exclude them.
- `test/unit/` — All other tests, including tests with local `HttpServer`, `MockClient`, or any self-contained test that does not call external services. These run in CI by default.

### Dependency Management

```bash
dart pub get
dart pub upgrade
dart pub outdated
```

### MCP Tools

Before using Dart MCP tools, register the workspace root:

```txt
mcp__dart__add_roots(roots: [
  {uri: "file:///path/to/repository"}
])
```

**Static analysis** — `mcp__dart__analyze_files()` provides structured, LLM-friendly output and can be used as an alternative to `dart analyze`.

**Code navigation** (semantic Dart understanding — uses the Dart Analysis Server):
- **`mcp__dart__hover(uri, line, column)`** — Type info and documentation at a file position (zero-based line/column). Use to understand a type or API without reading the full source.
- **`mcp__dart__signature_help(uri, line, column)`** — Function/constructor signatures at a call site (zero-based line/column). Use to check exact parameters when writing code.
- **`mcp__dart__resolve_workspace_symbol(query)`** — Fuzzy symbol lookup by name. **Caution:** returns results from all dependencies (including `.pub-cache`), which can be very noisy. Prefer `Grep`/`Glob` for searching within the project.

## Versioning

This repository uses [Conventional Commits](https://www.conventionalcommits.org/) and [Melos](https://melos.invertase.dev/) for versioning.

### Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat` - New feature (minor version bump)
- `fix` - Bug fix (patch version bump)
- `docs` - Documentation only
- `refactor` - Code change that neither fixes a bug nor adds a feature
- `test` - Adding or updating tests
- `chore` - Maintenance tasks

**Breaking changes:** Add `!` after type or include `BREAKING CHANGE:` in footer (major version bump).

### Releasing

Use the `/release` skill to publish packages. It handles the full lifecycle: detecting changes, computing semver bumps, writing changelogs, publishing to pub.dev, creating git tags, and creating a GitHub release.

```
/release --plan      # Preview release plan (no changes)
/release --dry-run   # Full workflow except actual publish/tag/commit
/release             # Full release
```

## GitHub

### Creating Pull Requests

Use the `/create-pr` skill to create pull requests. It handles conventional commit titles, structured descriptions, labels, and assignees automatically.

```
/create-pr              # Create PR from all uncommitted changes
/create-pr --draft      # Create as draft PR
```

### Labels

Labels are managed automatically by `/create-pr`, but for reference:

- **`p:{package}`** (required) - The package(s) affected (e.g., `p:openai_dart`, `p:googleai_dart`)
- **`t:{type}`** (required) - The type of issue/PR (e.g., `t:bug`, `t:feature`, `t:enhancement`)
- **`f:{flag}`** (optional) - Additional flags (e.g., `f:help-wanted`, `f:good-first-issue`)

### Assignees

Assigned automatically by `/create-pr` from `.github/CODEOWNERS`.
