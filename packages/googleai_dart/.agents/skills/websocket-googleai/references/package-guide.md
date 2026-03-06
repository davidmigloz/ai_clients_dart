# googleai_dart WebSocket Package Guide

## Core Paths

- Package root: `packages/googleai_dart`
- Skill config: `packages/googleai_dart/.agents/skills/websocket-googleai/config`
- Canonical specs: `packages/googleai_dart/specs/`

## Toolkit Commands

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py describe --config-dir packages/googleai_dart/.agents/skills/websocket-googleai/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py scaffold --config-dir packages/googleai_dart/.agents/skills/websocket-googleai/config --target message --name ExampleMessage --dry-run
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/googleai_dart/.agents/skills/websocket-googleai/config --checks exports --scope all
```
