# API Toolkit (Shared)

Unified shared toolkit for OpenAPI and WebSocket package maintenance.

## Public CLI

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py <command> ...
```

Commands:
- `create` - bootstrap a new OpenAPI package, skill config, and creation plan
- `fetch` - fetch or copy the latest candidate spec/schema into scratch output
- `review` - diff canonical vs candidate specs and report implementation gaps
- `describe` - introspect config, specs, and manifest state
- `scaffold` - generate schema, enum, message, config, or barrel scaffolds
- `verify` - run implementation, export, docs, or combined verification

## Config Contract

Each migrated skill keeps exactly four config files in `config/`:
- `package.json`
- `specs.json`
- `manifest.json`
- `documentation.json`

Checked-in canonical specs live under the package `specs/` directory, not inside skill config.

`specs.json` may also define:
- `output_dir` for fetched candidate specs; when omitted, api-toolkit uses the OS temp directory
- per-spec auth with `requires_auth`, `auth_env_vars`, and optional `auth` transport config

Auth transport config shape:

```json
{
  "location": "header",
  "name": "Authorization",
  "prefix": "Bearer "
}
```

## Workflow

Existing package update loop:
1. `fetch`
2. `review`
3. implement with `scaffold` plus package refs
4. `verify --checks all --scope all`
5. run separate package-level Dart quality steps

New package bootstrap loop:
1. `create`
2. implement with `scaffold`
3. `verify --checks all --scope all`
4. run separate package-level Dart quality steps

## Path Resolution

- Existing-package commands resolve package and repo roots from `--config-dir`
- Use an absolute `--config-dir` when running outside the repo root
- `create` supports `--repo-root`; use it when bootstrapping from outside the repo root
- Multi-spec skills should use `--spec-name` for `review`, `describe`, `scaffold`, and `verify`

## CLI DX

- All commands support `--format text|json`
- `describe`, `review`, and `verify` support `--fields`
- JSON is the default when stdout is not a TTY
- Exit codes: `0` success, `1` actionable verification failure, `2` usage/config/runtime failure
- Use `--dry-run` where available before mutating workflows

## Shared References

- [Core Implementation Patterns](references/implementation-patterns-core.md)
- [Core Review Checklist](references/REVIEW_CHECKLIST-core.md)
