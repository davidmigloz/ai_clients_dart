# Legacy API-key redirects

The baseline is `e48325ba16b33c8bbbe1912b9bac6f208ea6a459`. The probes sent synthetic credentials to separate servers bound to loopback. They exercised the exported `AnthropicClient` with its native and browser transports. The receiving server recorded credential-header presence only.

| Route | Source response | Baseline native destination | Baseline Chrome destination |
| --- | --- | --- | --- |
| Models retrieve | GET 302 | `x-api-key` forwarded | `x-api-key` forwarded |
| Files content | GET 302 | `x-api-key` forwarded | `x-api-key` forwarded |
| Files byte upload | POST 303 | GET with `x-api-key` | GET with `x-api-key` |
| Skills version ZIP | GET 302 | `x-api-key` forwarded | Shares the buffered path |
| Skills multipart create | POST 303 | GET with `x-api-key` | Shares the multipart path |
| Messages create | POST 303 | GET with `x-api-key` | Shares the buffered path |
| Messages SSE | POST 303 | GET with `x-api-key` | GET with `x-api-key` |
| Batch JSONL results | GET 302 | `x-api-key` forwarded | Shares the streaming path |

Native reproduced each row against both a different port on the same host and `127.0.0.1` redirected to `localhost` on a different port. Native and Chrome stripped a standard Authorization header on cross-origin redirects. Native forwarded the API key on a same-origin relative redirect as expected.

The pinned Python SDK enables HTTPX2 redirects and sends API keys as Bearer authorization by default. HTTPX2 strips Authorization across origins and has an HTTP-to-HTTPS exception for a same-host upgrade. The pinned TypeScript SDK sends Bearer authorization by default and delegates redirects to Fetch. A Node loopback test using Fetch reproduced stripping Authorization and forwarding a manually supplied `x-api-key`. Anthropic documents the legacy key header as supported. The Files reference documents a direct binary download with a successful 200 response.

- [Pinned Python authentication](https://github.com/anthropics/anthropic-sdk-python/blob/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/_client.py#L378)
- [Pinned Python redirects](https://github.com/anthropics/anthropic-sdk-python/blob/5139cf2e7d07aa618a6c30b7e0c712f10ccb5ad9/src/anthropic/_base_client.py#L1003)
- [HTTPX2 redirect header policy](https://github.com/pydantic/httpx2/blob/c39c6e3e4272b9cb8d407125296f079b59d5de9f/src/httpx2/httpx2/_client.py#L529)
- [Pinned TypeScript authentication and transport](https://github.com/anthropics/anthropic-sdk-typescript/blob/590783078cd961a0df698d9fddc0275c65ff3afd/src/client.ts)
- [Fetch redirect header policy](https://fetch.spec.whatwg.org/#http-redirect-fetch)
- [API version authentication migration](https://platform.claude.com/docs/en/api/migration-2026-10-21)
- [Files reference](https://platform.claude.com/docs/en/api/http/files)

The initial request carries the configured legacy header. On a transport that exposes redirect responses, the shared send helper follows same-origin redirects using the native GET, HEAD, and POST 303 behavior and existing hop count. It releases the redirect body and returns a typed exception with the original status and provider request ID on a different origin. It omits the redirect location from diagnostics. It checks cancellation before admitting another hop. The default browser transport uses Fetch redirect error mode for requests carrying `x-api-key`. Standard Authorization follows the underlying transport policy. Protected endpoints continue using their explicit redirect settings.

The 17 cross-origin and mixed-case regressions fail on the baseline and pass with the guard. The patch passes 21 local redirect tests and a real Chrome loopback test. The latter saw zero forwarded legacy headers and still followed the standard Authorization control without forwarding Authorization.
