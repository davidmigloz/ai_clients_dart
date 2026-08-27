## 0.2.5

Repoints the package's `documentation:` metadata from the retired `langchaindart.dev` domain to its [pub.dev API reference](https://pub.dev/documentation/tavily_dart/latest/), so the documentation link shown on pub.dev resolves again. Metadata-only release — no code or API changes.

- **CHORE**: Replace dead langchaindart.dev documentation URL ([#248](https://github.com/davidmigloz/ai_clients_dart/issues/248)). ([c0765c27](https://github.com/davidmigloz/ai_clients_dart/commit/c0765c2784d6feffc3d528edb1000be7bdd2e3e9))

## 0.2.4

Annotates `llms.txt` with per-link token counts and per-package totals so coding agents can budget context before fetching documentation, examples, or changelogs — inspired by Addy Osmani's [Agentic Engine Optimization](https://addyosmani.com/blog/agentic-engine-optimization/) article.

- **FEAT**: Annotate llms.txt with token counts and tighten agent-facing docs ([#181](https://github.com/davidmigloz/ai_clients_dart/issues/181)). ([a1e82aca](https://github.com/davidmigloz/ai_clients_dart/commit/a1e82acad8b713afc5d6d67d6e8d34937ac3f6a8))

## 0.2.3

Overhauls README documentation with standardized structure and adds [llms.txt](llms.txt) ecosystem files for improved LLM discoverability.

- **DOCS**: Overhaul READMEs and add llms.txt ecosystem ([#149](https://github.com/davidmigloz/ai_clients_dart/issues/149)). ([98f11483](https://github.com/davidmigloz/ai_clients_dart/commit/98f114832f18f236ee4ab526ba2c34d53ad3d093))

## 0.2.2

Updated README with badges, sponsor section, and improved documentation.

- **DOCS**: Improve READMEs with badges, sponsor section, and vertex_ai deprecation ([#90](https://github.com/davidmigloz/ai_clients_dart/issues/90)). ([5741f2f3](https://github.com/davidmigloz/ai_clients_dart/commit/5741f2f3bcecdc947235aa10e9a7534baef95741))
- **CHORE**: Bump Dart SDK to 3.9.0 ([#52](https://github.com/davidmigloz/ai_clients_dart/issues/52)). ([eae130b7](https://github.com/davidmigloz/ai_clients_dart/commit/eae130b785d38074e85d460eefa9210f4acdf215))
- **CI**: Add GitHub Actions test workflow ([#50](https://github.com/davidmigloz/ai_clients_dart/issues/50)). ([6c5f079a](https://github.com/davidmigloz/ai_clients_dart/commit/6c5f079ac94e78cad66071ad9eb8ad51db974695))

## 0.2.1

Updated repository URLs to new location.

- **DOCS**: Refactors repository URLs to new location. ([76835268](https://github.com/davidmigloz/ai_clients_dart/commit/768352686cdc91529fd7d37a288d69a28cc825f9))

## 0.2.0+1

- **REFACTOR**: Fix pub format warnings ([#809](https://github.com/davidmigloz/langchain_dart/issues/809)). ([640cdefb](https://github.com/davidmigloz/langchain_dart/commit/640cdefbede9c0a0182fb6bb4005a20aa6f35635))

## 0.2.0

> [!CAUTION]
> This release has breaking changes.

- **FEAT**: Upgrade to http v1.5.0 ([#785](https://github.com/davidmigloz/langchain_dart/issues/785)). ([f7c87790](https://github.com/davidmigloz/langchain_dart/commit/f7c8779011015b5a4a7f3a07dca32bde1bb2ea88))
- **BREAKING** **BUILD**: Require Dart >=3.8.0 ([#792](https://github.com/davidmigloz/langchain_dart/issues/792)). ([b887f5c6](https://github.com/davidmigloz/langchain_dart/commit/b887f5c62e307b3a510c5049e3d1fbe7b7b4f4c9))

## 0.1.3

- **FEAT**: Migrate to Freezed v3 ([#773](https://github.com/davidmigloz/langchain_dart/issues/773)). ([f87c8c03](https://github.com/davidmigloz/langchain_dart/commit/f87c8c03711ef382d2c9de19d378bee92e7631c1))

## 0.1.2

- **BUILD**: Update dependencies ([#751](https://github.com/davidmigloz/langchain_dart/issues/751)). ([250a3c6](https://github.com/davidmigloz/langchain_dart/commit/250a3c6a6c1815703a61a142ba839c0392a31015))

## 0.1.1

- **FEAT**: Update dependencies (requires Dart 3.6.0) ([#709](https://github.com/davidmigloz/langchain_dart/issues/709)). ([9e3467f7](https://github.com/davidmigloz/langchain_dart/commit/9e3467f7caabe051a43c0eb3c1110bc4a9b77b81))
- **FIX**: Made apiKey optional for `TavilyAnswerTool` and `TavilySearchResultsTool` ([#646](https://github.com/davidmigloz/langchain_dart/issues/646)). ([5085ea4a](https://github.com/davidmigloz/langchain_dart/commit/5085ea4ad8b5cd072832e73afcbb7075a6375307))
- **FIX**: Fix linter issues ([#656](https://github.com/davidmigloz/langchain_dart/issues/656)). ([88a79c65](https://github.com/davidmigloz/langchain_dart/commit/88a79c65aad23bcf5859e58a7375a4b686cf02ef))
- **REFACTOR**: Remove fetch_client dependency in favor of http v1.3.0 ([#659](https://github.com/davidmigloz/langchain_dart/issues/659)). ([0e0a685c](https://github.com/davidmigloz/langchain_dart/commit/0e0a685c376895425dbddb0f9b83758c700bb0c7))

## 0.1.0+1

- **REFACTOR**: Upgrade api clients generator version ([#610](https://github.com/davidmigloz/langchain_dart/issues/610)). ([0c8750e8](https://github.com/davidmigloz/langchain_dart/commit/0c8750e85b34764f99b6e34cc531776ffe8fba7c))

## 0.1.0

- **FEAT**: Implement tavily_dart, a Dart client for Tavily API ([#456](https://github.com/davidmigloz/langchain_dart/issues/456)). ([fbfb79ba](https://github.com/davidmigloz/langchain_dart/commit/fbfb79bad81dbbd5844a90938fda79b201f20047))

## 0.0.1-dev.1

- Bootstrap package.
