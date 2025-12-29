# WebSocket Updater (Shared)

Generic, config-driven WebSocket API update workflow for Dart API client packages.

## Design Philosophy

This core skill contains **unique WebSocket scripts** that are 100% config-driven. For verification scripts, use [openapi-updater](../openapi-updater/README.md) since they work with both REST and WebSocket APIs.

## Directory Structure

```
websocket-updater/
├── README.md             # This file
├── scripts/
│   ├── fetch_schema.py         # Fetch WebSocket schema from config
│   └── analyze_changes.py      # Compare schemas, generate changelog/plan
└── assets/
    ├── sealed_message_template.dart  # Sealed class for WebSocket messages
    ├── model_template.dart           # Model class template
    ├── enum_template.dart            # Enum type template
    ├── test_template.dart            # Unit test template
    └── example_template.dart         # Example file template
```

## Required Config Files

Create these in your extension skill's `config/` directory:

| File | Purpose |
|------|---------|
| `package.json` | Package paths and naming conventions |
| `specs.json` | WebSocket endpoints and auth config |
| `schema.json` | Message types, config types, enums |
| `models.json` | Critical models for verification |
| `documentation.json` | README verification rules |

### `schema.json` - WebSocket Schema Definition

```json
{
  "info": {
    "title": "API Name",
    "version": "v1beta"
  },
  "websocket_endpoints": {
    "google_ai": "wss://example.com/...",
    "vertex_ai": "wss://example.com/..."
  },
  "message_types": {
    "client": {
      "MessageName": {
        "description": "Description",
        "fields": {
          "fieldName": {"type": "string", "required": true}
        }
      }
    },
    "server": {
      "ResponseName": {
        "description": "Description",
        "fields": {}
      }
    }
  },
  "config_types": {
    "ConfigName": {
      "fields": {
        "fieldName": {"type": "string"}
      }
    }
  },
  "enums": {
    "EnumName": {
      "values": ["VALUE_ONE", "VALUE_TWO"]
    }
  }
}
```

## Script Usage

### Fetch Schema

```bash
python3 {core}/scripts/fetch_schema.py --config-dir {ext}/config
python3 {core}/scripts/fetch_schema.py --config-dir {ext}/config --spec live
```

### Analyze Changes

```bash
python3 {core}/scripts/analyze_changes.py --config-dir {ext}/config \
  current.json latest.json --format all
```

### Verification (use openapi-updater)

```bash
# These work for both REST and WebSocket APIs
python3 ../openapi-updater/scripts/verify_exports.py --config-dir {ext}/config
python3 ../openapi-updater/scripts/verify_readme.py --config-dir {ext}/config
python3 ../openapi-updater/scripts/verify_model_properties.py --config-dir {ext}/config
```

## Templates

### `sealed_message_template.dart`

Use for client/server message hierarchies:
- Sealed base class with factory fromJson
- Concrete subclasses for each message type
- toJson includes wrapper key (e.g., `{"setup": {...}}`)

### Other Templates

Same as openapi-updater - see that shared library for details.

## WebSocket-Specific Patterns

### Message Structure

```
Client → Server: {"messageType": { ...fields... }}
Server → Client: {"responseType": { ...fields... }}
```

### Binary Data

- Use `List<int>` for raw bytes
- Use base64 encoding in JSON
- Audio: 16kHz input, 24kHz output (for Live API)
