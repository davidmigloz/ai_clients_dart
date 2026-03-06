# Adding a New Dart API Client Package

Use the unified toolkit to bootstrap a new OpenAPI package instead of creating skill/config files by hand.

## Bootstrap

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py create \
  --repo-root /absolute/path/to/ai_clients_dart \
  --package-name your_package_dart \
  --display-name "Your Package" \
  --spec-url https://api.example.com/openapi.json
```

This creates the package skeleton, skill config, canonical spec, manifest, and an initial creation plan. It does not run `melos bootstrap`, Dart tests, or full model/resource generation.

If you run `create` from the repo root, `--repo-root` is optional. If you run it from anywhere else, pass `--repo-root`.

## Follow-up Workflow

1. Inspect the generated config with `describe`
2. Use `scaffold` to start enums and core models
3. Run `fetch` and `review` as the spec evolves
4. Run `verify --checks all --scope all`
5. Run package-level Dart quality steps
