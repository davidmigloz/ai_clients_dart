# Image API review — September 16, 2026

Reviewed `POST /images/generations` and both JSON and multipart forms of
`POST /images/edits`, including their SSE responses.

## Sources

- [Images 2.5 announcement](https://openai.com/index/introducing-chatgpt-images-2-5/)
- [API changelog](https://developers.openai.com/api/docs/changelog): September 8
  model/quality release and August 20 transparent-background preview for Image 2.
- [Generation reference](https://developers.openai.com/api/reference/resources/images/methods/generate)
  and [edit reference](https://developers.openai.com/api/reference/resources/images/methods/edit).
- [Published OpenAPI specification](https://github.com/openai/openai-openapi/blob/main/openapi.json),
  fetched and promoted to `openapi.json`. The previous SDK `.stats.yml` discovery
  URL returns 404; fetching now uses the public OpenAPI repository directly.
- Official Python SDK: [model IDs](https://github.com/openai/openai-python/blob/main/src/openai/types/image_model.py),
  [generation parameters](https://github.com/openai/openai-python/blob/main/src/openai/types/image_generate_params.py),
  [edit parameters](https://github.com/openai/openai-python/blob/main/src/openai/types/image_edit_params.py),
  [response](https://github.com/openai/openai-python/blob/main/src/openai/types/images_response.py),
  and the generation/edit `partial_image` and `completed` event models in the same directory.

## Alignment

| Surface | Result |
| --- | --- |
| Model IDs | Added Flare, Sunburst, and both `2026-09-08` snapshots. Arbitrary string model IDs remain supported. |
| Quality | Added `xhigh` and `max` to the shared enum used by generation, multipart edits, JSON edits, responses, and all four SSE event models. |
| Sizes | Replaced the closed size enum with a value class. Custom and future strings round-trip without becoming `unknown`, matching the SDK's string-or-preset types. Existing size constants and the preset list remain available. |
| Background/output | Existing transparent/opaque/auto and PNG/WebP/JPEG options already match. Updated documentation for Image 2.5 and Image 2 preview transparency. |
| Image references | Existing JSON edits support URLs, data URLs, uploaded file IDs, multiple references, and a mask. Multipart edits retain the existing single-source upload interface. |
| Other request fields | No new generation/edit fields are needed for the Image 2.5 release. Existing compression, count, input fidelity, moderation, user, and streaming fields remain available where supported. |
| Usage | Existing optional usage metadata and input/output token details already cover the SDK response shapes. |

The tests exercise all four new model IDs and both quality additions through all
six resource paths (three request forms, with and without streaming). They also
verify multipart field names, JSON image/mask references, response metadata, all
four SSE event parsers, custom-size equality, and preservation of transient sizes.
See `MIGRATION.md` for the enum-to-value-class compatibility change.

## Verification scope

The full public specification includes changes beyond images. All-check toolkit
verification reports eight errors outside this update:

- Four errors for the unimplemented `PromptCacheOptions.comparison_response_id`
  field and its serialization/copy methods, plus three related warnings.
- Four resource coverage errors for `agents`, `live`, `safety`, and `vaults`.

The prior pinned specification passed toolkit verification. These newly exposed
gaps are not suppressed in the manifest; implementing those API surfaces is
outside this image-endpoint update. Image generation is now actively checked by
the manifest instead of being skipped under its stale class name.

Only unit tests are run. Live image-generation integration tests require an
explicit request and have not been run.
