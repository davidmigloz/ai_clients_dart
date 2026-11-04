# Named enum completeness verification (#246)

Reviewed against merged base `fb211b05590e68761c0866cb766771e879f4df8a`.
This implements the issue's priority A: unchanged/untracked named string-enum
verification under `--scope all`. Upfront schema-coverage nudges, reverse enum
drift and automatic inline-enum discovery remain outside this bounded change.

## Resulting behavior

OpenAPI implementation verification builds one model declaration index and
checks uniquely matched named string enums even when the spec did not change
and the manifest has no entry. Explicit manifest mappings, schema aliases,
exclusions and intentional skips retain precedence. Inferred entries are
request-local verification data; the command writes no manifest or spec files.
The output reports checked inferred enums, unmatched schemas and explicit skips;
ambiguous declarations receive a warning rather than an arbitrary match.

The common checker accepts enums, constant value classes and sealed variants.
It uses exact fixed strings and actual enum constant names, including typed
same-file top-level codecs/extensions and direct sealed subtype relationships.
Comments, unrelated types, method parameters and generic type arguments cannot
supply missing values. Raw/escaped/triple strings and nested interpolation remain
masked while declaration boundaries are located. Value classes can retain future
raw strings without inventing an unknown wire value. Existing explicit enum
fallback policy remains; inferred completeness checks do not impose a new
unknown-value parsing policy on an existing package.

Changed/critical/type scopes do not discover unrelated enums. An explicitly
selected sealed representation still follows its own codec/type closure.
Integer and manually mapped inline-enum checks remain supported. This is static
representation evidence, not a Dart type checker or proof of parser control
flow; it does not claim complete schema or endpoint parity.

## Validation

- **189 command tests:** pass, with two pre-existing skips.
- **21 Dart-inspection tests:** pass.
- **287 complete toolkit tests:** five pre-existing real-contract methods fail,
  with two pre-existing skips. The unchanged merged-base tooling runs 268 tests
  with the same five failing methods and two skips. The difference is 19 added
  regressions; no unrelated API/source or configuration repairs are hidden here.
- **Eight managed docs and README gates:** zero errors. Existing warnings are
  one Google docs warning and four Ollama README warnings. Flat/grouped/nested
  collapsible README layouts remain compatible, including OpenAI's 62 topics.
- Python compilation and `git diff --check`: pass. No Dart package source,
  canonical schema, global manifest, version or release files change.

The tests reproduce the original unchanged MessageRole omission, then pass after
adding every source value. They cover exact-value/class scoping, raw-string
wrappers, sealed variants across files, typed codecs/extensions, ambiguous names,
explicit aliases/skips, implicit string types, constant-vs-parameter names,
generic arguments/bounds and nested interpolation with quoted keys. Root's three
adversarial lexical review findings were corrected with regressions. Final independent
source/requirements review reran nine focused end-to-end tests and the original
three adversarial probes; all passed.

## Truthful cross-package implementation comparison

Old/new implementation verification was compared directly for every managed
configuration using the same current package sources. Exactly three additional
errors are now visible; there are no other added or removed errors:

| Package / type | Newly visible diagnostic |
| --- | --- |
| Google / ActivityHandling | `ACTIVITY_HANDLING_UNSPECIFIED` is missing |
| Mistral / BatchJobStatus | `TIMEOUT_EXCEEDED` is missing; existing `TIMED_OUT` is a different wire value |
| Anthropic / StopReason | Its own unknown/unspecified fallback is missing; the old file-wide check borrowed RefusalCategory's fallback |

Real-skill regressions assert each complete diagnostic, including its file/type,
and reject unexpected errors. These unrelated package APIs remain unchanged;
adding enum values could itself affect consumer exhaustive switches. No new
exclusion, acknowledged skip or ticket suppresses these findings.

Chroma, Google WebSocket, Ollama, OpenResponses and OpenAI implementation findings
are unchanged. The existing OpenResponses ErrorPayload required/nullability
finding and OpenAI's existing global parity findings remain visible. Canonical
OpenAI promotion/reconciliation belongs to #427.

The five already-failing real-contract test methods are:

- `test_full_verify_passes_for_all_real_skills`
- `test_real_implementation_verify_reports_skip_summary`
- `test_real_manifest_coverage_aliases_match_audited_grouped_resources`
- `test_real_manifest_skip_keys_match_audited_snapshot`
- `test_real_preflight_config_loads_for_supported_packages`

The first two now progress past the newly asserted enum findings and encounter
the unchanged OpenResponses mismatch; the baseline full check stopped earlier at
its stale Anthropic known-failure assumption. The other three compare older
skip/coverage/preflight snapshots with current configuration. This receipt does
not claim that the existing complete toolkit suite is globally green.

## Reproduction

Install the existing pinned requirements into an isolated Python environment,
then run:

```bash
GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=commit.gpgsign GIT_CONFIG_VALUE_0=false \
  python -m unittest discover -s .agents/shared/api-toolkit/tests -q
```

The command-local Git setting affects only synthetic temporary-repository unit
fixtures, avoiding inherited machine signing configuration. It does not change
repository/global Git settings or feature commit signing. Tokenizer test data is
cached separately; no live AI API, credential registration or billable work is
performed.
