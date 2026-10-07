# Container configuration contract specification

Status: implemented and independently reviewed; acceptance evidence is recorded
in the [container review](reviews/02-container-configuration.md). This is Phase 2 of the
[alignment roadmap](README.md). Decisions is merged in
[PR #319](https://github.com/davidmigloz/ai_clients_dart/pull/319).

## Outcome and sources

A caller can configure a standalone container, inspect its returned memory and
network settings, and supply its ID to Code Interpreter. Automatic Code Interpreter
containers use the same correct memory and network wire values. Network allowlists
can carry domain-scoped secrets; standalone creation supports skill references and
inline skill bundles. Container listing can filter by name.

The October 7 candidate was fetched again and is semantically identical to the
promoted [ee483b4 OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json).
Relevant schemas are `ContainerMemoryLimit`, `AutoCodeInterpreterToolParam`,
`ContainerNetworkPolicy*Param`, `CreateContainerBody`, `ContainerResource`,
`SkillReferenceParam`, `InlineSkillParam`, and `InlineSkillSourceParam`.

Primary cross-checks:

- [Container creation reference](https://developers.openai.com/api/reference/resources/containers/methods/create).
- [Python 3.26.0 create parameters](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/container_create_params.py).
- [Python 3.26.0 response](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/container_create_response.py).
- [Python 3.26.0 tool parameters](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/responses/tool_param.py).
- [Node 7.30.0 container contracts](https://github.com/openai/openai-node/blob/v7.30.0/src/resources/containers/containers.ts).

Follow the canonical DELETE response contract already implemented in Dart. The
Node resource's `void` return differs from the pinned schema; this ticket does not
change deletion. No package release or broad retry/transport redesign is included.

## Public design and compatibility

Use a shared immutable `ContainerMemoryLimit` value class, following `ServiceTier`,
with `gb1`, `gb4`, `gb16`, and `gb64` constants and an open string constructor.
Preserve unfamiliar returned strings exactly. Replace the existing integer MB
field with `ContainerMemoryLimit?`; do not round unsupported legacy sizes.

Move shared configuration into the container model directory and re-export memory
and network types from the existing Code Interpreter library. `ContainerNetworkPolicy`
keeps `disabled` and positional `allowlist(domains, {domainSecrets})` conveniences.
Its concrete allowlist exposes `allowedDomains`, replacing `allowedHosts`.
`ContainerNetworkPolicyDomainSecret` carries `domain`, `name`, and `value`.

Use dedicated `ContainerSkill` reference/inline variants, and a `ContainerSkillSource`
base64 ZIP variant. These are configuration shapes, distinct from existing `Skill`
resource entities. The source accepts an already encoded string; no new byte/bundle
factory or archive validation is required. ZIP data is raw base64 in `data`, unlike
the Decisions image data URL field.

Keep `ContainerExpiration` as the strict request shape. Add
`ContainerExpirationInfo` for response members that are independently optional.
Likewise, `ContainerNetworkPolicyInfo` represents response policy with required
string `type` and optional `allowedDomains`; responses do not contain secrets.
`Container.expiresAfter` therefore changes to the response-specific type.

The user permits targeted breaking corrections with migration guidance. Document
memory values, named allowlist construction, required request name, the response
expiration type, and loss of const construction where defensive collection copies
require nonconst constructors. Keep scalar constructors const where practical.
Version numbers are assigned by the later release workflow, not this ticket.

## Requirements

### CONT-01: Correct shared memory values

All four presets serialize exactly as `1g`, `4g`, `16g`, `64g`. Code Interpreter
automatic configuration, standalone creation, and container responses use the same
value type. Parse strings with contextual errors for malformed JSON; never accept
integer MB as the API wire representation. Custom strings survive parsing,
serialization, equality/hash, copying, and diagnostics.

Automatic configuration permits explicit JSON null for memory; normalize it to
absence following the existing optional-nullable request convention. Standalone
memory is optional but not nullable on the wire; reject explicit null in parsing.
Omit unspecified memory so the server applies its documented creation default `1g`.
Do not hardcode that default into a request or response.

### CONT-02: Correct network policy

Support fixed `disabled` and `allowlist` discriminators. Allowlist requires an
ordered string array `allowed_domains`; serialize only that canonical key.
Known subtype parsers validate their discriminator and required field types.
The old `allowed_hosts` JSON key is not the canonical contract. Migration guidance
must explain both the Dart property change and corrected serialization.

### CONT-03: Domain-scoped secrets

Allowlist accepts optional ordered `domain_secrets` entries with required strings
`domain`, `name`, and `value`. Omit absent secrets; reject explicit null in parsed
nonnullable fields. Preserve all three values in serialization/copy/equality/hash.
Redact `value` in string diagnostics; never log the full secret through containing
objects. Document server limits instead of adding a general validation framework.

### CONT-04: Complete standalone creation

`CreateContainerRequest` requires `name: String` and retains optional file IDs and
strict request expiration. Add optional memory, request network policy, and ordered
skills. Minimal JSON is exactly `{"name":"fixture"}`. Empty names are permitted
by the reviewed schema. Request expiration, when supplied, requires `anchor` and
integer `minutes`; do not convert that member to seconds based on prose.
The request expiration parser validates the fixed `last_active_at` anchor.

The ordinary JSON POST `/containers` must carry these fields through the existing
HTTP pipeline, configured URL and headers. Add parsing and copy methods with full
field equality/hash. Optional nonnullable request objects/lists are omitted when
absent and reject explicit null in parsed JSON.

### CONT-05: Skill configuration

Reference: required `type: skill_reference`, `skill_id`; optional nonnullable
string `version`. Preserve omission, `latest`, and numeric strings such as `7`;
do not serialize a numeric version as a JSON integer.

Inline: required `type: inline`, `name`, `description`, and `source`. Known source
requires `type: base64`, `media_type: application/zip`, and string `data`.
Emit both fixed source members. Do not decode/rewrite the supplied base64 string;
redact opaque bundle data in diagnostics.

Do not add skills to Code Interpreter `type: auto`: its reviewed schema has no
skills field. Future hosted-shell `type: container_auto` is a different shape and
remains a separate milestone. Standalone creation has no schema maxItems for
files/skills; hosted-shell limits must not be applied here.

### CONT-06: Complete and tolerant response shapes

Preserve required id/object/name/created-at/status and optional last-active time,
memory, expiration, and response network policy on create/retrieve/list. Required
fields fail with contextual `FormatException`; do not synthesize a required object
type. Status remains an open string.

Response policy requires `type`, but `allowed_domains` is optional even for
allowlist. Expiration `{}`, anchor-only, and minutes-only are valid. Optional
members are not nullable on the wire; distinguish omission from invalid null.
Validate returned expiration's fixed `last_active_at` anchor when present, and
the list response's fixed `object: list`. Container `object` remains an open
string as specified by `ContainerResource`.
Invent neither returned skills nor domain secrets. `isActive` recognizes current
`running` and legacy `active` statuses; other statuses remain false.

Keep list `firstId` and `lastId` nullable and accept omitted/null IDs for empty
pages and existing provider fixtures. This is an intentional compatibility
exception to the snapshot's required string fields. Do not invent pagination IDs;
record the resulting two toolkit requiredness findings as deliberate exceptions.

### CONT-07: Public transport and listing integration

Export the shared types through normal package/container imports and preserve the
old Code Interpreter import path by re-exporting moved types. Exact POST Responses
fixtures exercise both automatic configuration and a returned/existing container ID.

Add `name` to `client.containers.list` query parameters. Retain the legacy `before`
parameter for source compatibility and mark its noncanonical status in documentation;
new examples use canonical `after` pagination. Do not alter endpoint paths or DELETE
return semantics. Existing auth/error/cancellation behavior remains shared.

### CONT-08: Model integrity and future variants

Take defensive unmodifiable copies of lists, including nested unknown JSON.
Changed `Container`, `ContainerList`, and creation/configuration models compare
all visible fields, with matching content-based hashes and complete copy methods.
Nullable copy parameters can explicitly clear values through the shared sentinel.

Unknown object variants for Code Interpreter containers, network policies, skills,
and skill sources preserve recursively immutable raw JSON and deep equality/hash.
Malformed known variants still fail. Response policy modes and memory strings stay
open. No new count/range/content validation framework is introduced.

### CONT-09: Documentation, coverage, and migration

Register the concrete/union/scalar wrapper coverage, including identical beta
contracts where applicable, without suppressing unrelated gaps. Update examples,
README, and agent-facing example index. Demonstrate valid standalone configuration
and using its returned ID; avoid placeholders that pretend an empty ZIP is an
installable skill. Record migration instructions and independently reviewed
acceptance evidence before opening the implementation PR.

## Acceptance fixtures and boundaries

Use public imports, `OpenAIClient` with `MockClient`, and exact independently
specified request/response JSON. No external service is needed for these fixtures.

```json
{
  "name": "fixture-container",
  "memory_limit": "4g",
  "network_policy": {
    "type": "allowlist",
    "allowed_domains": ["api.example.com"],
    "domain_secrets": [
      {"domain": "api.example.com", "name": "API_TOKEN", "value": "fixture-secret"}
    ]
  },
  "skills": [
    {"type": "skill_reference", "skill_id": "skill_fixture", "version": "7"},
    {
      "type": "inline", "name": "wire-fixture", "description": "Serialization fixture",
      "source": {"type": "base64", "media_type": "application/zip", "data": "UEsFBgAAAAAAAAAAAAAAAAAAAAAAAA=="}
    }
  ]
}
```

The ZIP above is only a wire fixture. Response fixture: required identity/status,
memory `4g`, policy `{"type":"allowlist"}` with no domains, and expiration `{}`.
Also test omitted configuration, full policy/expiration, zero timestamps, unfamiliar
memory/modes, all four memory presets, and malformed required/nonnullable fields.

Mutable source lists/maps must not change models or their hashes. Same-length
container lists with different contents must differ. Distinct request settings
must differ even when names match. Secret and bundle diagnostic tests must assert
the sensitive payload itself is absent. Transport fixtures verify method/path,
query name/after, body, headers, and preservation through list/retrieve/create.

Run focused unit checks during implementation, then format/fix/analyze, the package
unit suite, and toolkit checks. Requirements and repository-standards reviews are
independent of the authors. Live testing, if used, must stay within the user's
low-cost authorization and guarantee cleanup; never run the full integration suite.
