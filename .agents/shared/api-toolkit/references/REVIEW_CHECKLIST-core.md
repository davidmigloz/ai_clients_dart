# Core Review Checklist

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch --config-dir <config-dir>
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir <config-dir>
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir <config-dir> --checks all --scope all
```

After toolkit verification, run the package-level Dart quality steps documented in the package skill.
