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

### MCP Tools Setup

**IMPORTANT**: Before using Dart MCP tools, you must register the workspace root:

```txt
// In Claude Code, run this first to enable MCP tools
mcp__dart__add_roots(roots: [
  {uri: "file:///path/to/repository"}
])
```

**MCP Tools provide enhanced error handling, integrated results, and better reliability compared to CLI commands. Use MCP tools whenever available, with CLI fallbacks only when necessary.**

### Dart Monorepo Setup

```bash
# Workspace initialization (CLI required for melos) - run from repository root
melos bootstrap   # Install dependencies and link local packages
```

**Using MCP Tools (Preferred):**

```txt
# Code quality (use MCP tools)
# First ensure workspace root is registered with mcp__dart__add_roots
mcp__dart__dart_format()             # Format all Dart files
mcp__dart__analyze_files()           # Run Dart analyzer with zero warnings
mcp__dart__dart_fix()                # Apply automated fixes

# Testing (use MCP tools)
mcp__dart__run_tests()               # Run all tests with enhanced reporting
# For specific test configurations, use testRunnerArgs parameter:
# mcp__dart__run_tests(testRunnerArgs: {name: ["test description"]})

# Dependency management (use MCP tools)
mcp__dart__pub(command: "get")       # Get dependencies
mcp__dart__pub(command: "upgrade")   # Upgrade dependencies
mcp__dart__pub(command: "outdated")  # Check outdated dependencies
```

**Using CLI (Fallback):**

```bash
# Individual commands
dart fix --apply
dart format .
dart analyze .

# Testing
melos run test              # Run all tests
melos run test:diff         # Run tests only on changed packages (vs main)
```

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

```bash
melos version    # Bump versions based on conventional commits, update changelogs
melos publish    # Publish packages to pub.dev
```
