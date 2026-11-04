# Live image error replay completion

Completes the existing #424 image-call component in its public Live InputItem
context, discovered during #427 verification. No additional issue, endpoint,
release, or plan scope is introduced.

## Source and reproduced gap

Authority remains OpenAPI `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`, Node
7.47.0 `c717857c3151bde92e07e4d396301a9c67163e68`, and Python 3.42.0
`0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`. The adjacent receipt records
canonical component and SDK file hashes.

Before this correction, `LiveClientEvent.fromJson` accepted both explicit-null
and string image errors within `response.item.create`. The embedded Live schema
did not know the new `error` property, so it treated those values as finite
future metadata. Valid errors already survived raw round trips; the defects were
missing typed access/copy support and missing known-field validation.

`LiveInputImageGenToolCall.error` now reuses `ImageGenerationCallError`, with
`hasError` and a sentinel-based `copyWith(error: ..., clearError: ...)`. Clearing
removes the optional key; assigning null is rejected. Known error fields cannot
be overridden by replacement raw extras. The existing full-wire equality/hash,
private diagnostics, immutable snapshots and finite/acyclic JSON admission apply
to the complete error and all future metadata.

Only three embedded validation components change: `ImageGenToolCall`,
`ImageGenToolCallError`, and `ImageGenToolCallModerationDetails`. Their validation
shapes exactly match the fixed source after removing descriptive/default/vendor
metadata. Error code and param remain required nullable keys; type and message
are required strings; optional error/moderation objects reject explicit null.
Moderation stage is closed to input/output/unknown when writing a Live item.
The shared received error model continues to retain future strings; replaying
such a future stage fails safely rather than rewriting it to a known stage.

Node's input-item image-call error declarations agree with the canonical optional
nonnull objects and required nullable code/param fields. Python's received
Pydantic model defaults nullable members to None; this adapter follows the
canonical writable contract, consistent with the other Live InputItem adapters.

## Related inline image mappings

The related existing Live image wrappers serialize actual canonical inline
values. They are not additional complete ImageGenTool or ImageGenToolCall DTOs:

| Dart carrier | Exact canonical context |
| --- | --- |
| LiveInputImageGenToolInputImageMaskValue | ImageGenTool/properties/input_image_mask |
| LiveInputImageGenToolCallSizeValue | ImageGenToolCall/properties/size/anyOf/0 |
| LiveInputImageGenToolCallSizeValueBranch0/1 | Previous pointer/anyOf/0 or 1 |
| LiveInputImageGenToolModelValue | ImageGenTool/properties/model |
| LiveInputImageGenToolModelValueBranch0/1 | Previous pointer/anyOf/0 or 1 |
| LiveInputImageGenToolSizeValue | ImageGenTool/properties/size |
| LiveInputImageGenToolSizeValueBranch0/1 | Previous pointer/anyOf/0 or 1 |
| LiveInputFidelity | Scalar InputFidelity, high or low |

The mask validates its closed two-property object. String branches accept open
strings and the alternate branches validate the exact source suggestions; these
do not impose a client model allowlist. The scalar fidelity wrapper validates
its closed writable values and is not an object with missing properties.
Existing alias fixtures verify wire values, copies, finite admission, ownership,
and privacy. The adjacent ledger preserves these pointers for manual verification.

The global verifier's whole-parent and object-kind diagnostics for these existing
wrappers are known context/representation limitations. This correction does not
change their runtime behavior, relabel a parent schema as an invented DTO, add a
skip, alter coverage exclusions, or suppress unrelated global diagnostics.

## Validation

- The two initial public parser regressions failed before the correction, proving
  both invalid values were previously admitted.
- Thirty focused tests cover primary/sideband/fork public command round trips,
  Responses-output-to-Live conversion, omitted/null/malformed errors, every
  required member, moderation stages/categories, typed and raw-copy ownership,
  full-wire equality/hash, safe diagnostics, finite values and cycles.
- The focused plus existing Live input/alias/regression selection passes all
  2,779 tests on each of the VM, Chrome JavaScript and Chrome WebAssembly.
- Scoped Dart fixes and fatal-info package analysis pass. The parent milestone
  owns the complete integrated unit suite and canonical/manifest promotion.
- Frozen local fetch/review and scratch-only canonical promotion precede toolkit
  verification. Type-scoped implementation checks for the Live call, shared error
  and shared moderation details report zero errors/warnings. Four advisory type
  naming infos concern existing Live enum wrappers and the exact received stage
  value class. No repository manifest or skip is changed.

No external API, key, upload, image generation or billable operation was used.
