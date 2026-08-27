## 0.2.5

Repoints the package's `documentation:` metadata from the retired `langchaindart.dev` domain to its [pub.dev API reference](https://pub.dev/documentation/vertex_ai/latest/), so the documentation link shown on pub.dev resolves again. Metadata-only release — no code or API changes.

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
- **CHORE**: Bump googleapis from 15.0.0 to 16.0.0 and Dart SDK to 3.9.0 ([#52](https://github.com/davidmigloz/ai_clients_dart/issues/52)). ([eae130b7](https://github.com/davidmigloz/ai_clients_dart/commit/eae130b785d38074e85d460eefa9210f4acdf215))
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

## 0.1.2

- **BUILD**: Update dependencies ([#751](https://github.com/davidmigloz/langchain_dart/issues/751)). ([250a3c6](https://github.com/davidmigloz/langchain_dart/commit/250a3c6a6c1815703a61a142ba839c0392a31015))

## 0.1.1

- **FEAT**: Update dependencies (requires Dart 3.6.0) ([#709](https://github.com/davidmigloz/langchain_dart/issues/709)). ([9e3467f7](https://github.com/davidmigloz/langchain_dart/commit/9e3467f7caabe051a43c0eb3c1110bc4a9b77b81))
- **REFACTOR**: Remove fetch_client dependency in favor of http v1.3.0 ([#659](https://github.com/davidmigloz/langchain_dart/issues/659)). ([0e0a685c](https://github.com/davidmigloz/langchain_dart/commit/0e0a685c376895425dbddb0f9b83758c700bb0c7))
- **FIX**: Fix linter issues ([#656](https://github.com/davidmigloz/langchain_dart/issues/656)). ([88a79c65](https://github.com/davidmigloz/langchain_dart/commit/88a79c65aad23bcf5859e58a7375a4b686cf02ef))

## 0.1.0+3

- **REFACTOR**: Add new lint rules and fix issues ([#621](https://github.com/davidmigloz/langchain_dart/issues/621)). ([60b10e00](https://github.com/davidmigloz/langchain_dart/commit/60b10e008acf55ebab90789ad08d2449a44b69d8))

## 0.1.0+2

 - Update a dependency to the latest release.

## 0.1.0+1

 - Update a dependency to the latest release.

## 0.1.0

- **REFACTOR**: Minor changes ([#363](https://github.com/davidmigloz/langchain_dart/issues/363)). ([ffe539c1](https://github.com/davidmigloz/langchain_dart/commit/ffe539c13f92cce5f564107430163b44be1dfd96))

## 0.0.10

- **FEAT**: Update meta and test dependencies ([#331](https://github.com/davidmigloz/langchain_dart/issues/331)). ([912370ee](https://github.com/davidmigloz/langchain_dart/commit/912370ee0ba667ee9153303395a457e6caf5c72d))
- **DOCS**: Update pubspecs. ([d23ed89a](https://github.com/davidmigloz/langchain_dart/commit/d23ed89adf95a34a78024e2f621dc0af07292f44))

## 0.0.9+1

- **DOCS**: Update CHANGELOG.md. ([d0d46534](https://github.com/davidmigloz/langchain_dart/commit/d0d46534565d6f52d819d62329e8917e00bc7030))

## 0.0.9

- **FEAT**: Add count tokens method to vertex_ai client ([#306](https://github.com/davidmigloz/langchain_dart/issues/306)). ([54ae317d](https://github.com/davidmigloz/langchain_dart/commit/54ae317dda43f0313dca708d3831633252113c81))

## 0.0.8

- **FEAT**: Update internal dependencies ([#291](https://github.com/davidmigloz/langchain_dart/issues/291)). ([69621cc6](https://github.com/davidmigloz/langchain_dart/commit/69621cc61659980d046518ee20ce055e806cba1f))

## 0.0.7+2

- **DOCS**: Add `public_member_api_docs` lint rule and document missing APIs ([#223](https://github.com/davidmigloz/langchain_dart/issues/223)). ([52380433](https://github.com/davidmigloz/langchain_dart/commit/523804331783970870b023946c016be6c0797920))

## 0.0.7+1

- **REFACTOR**: Require `http.Client` instead of `AuthClient` ([#156](https://github.com/davidmigloz/langchain_dart/issues/156)). ([0f7fee7f](https://github.com/davidmigloz/langchain_dart/commit/0f7fee7f0780e5b650ec50307a7fda65e242e822))

## 0.0.7

- **FIX**: Fix typo in stop sequences field deserialization ([#152](https://github.com/davidmigloz/langchain_dart/issues/152)). ([4f7161da](https://github.com/davidmigloz/langchain_dart/commit/4f7161da55309bcbd5a62c21ba2a7fa703c4eb09))
- **FEAT**: Add support for stopSequence and candidateCount ([#150](https://github.com/davidmigloz/langchain_dart/issues/150)). ([eab7d968](https://github.com/davidmigloz/langchain_dart/commit/eab7d968f464db58a04f3453b4470ad3859536aa))
- **FEAT**: Support task type and title in embeddings models ([#149](https://github.com/davidmigloz/langchain_dart/issues/149)). ([421d36bd](https://github.com/davidmigloz/langchain_dart/commit/421d36bdfe1ad8c4776811f6e1f0d3bf8c316ee3))
- **DOCS**: Fix invalid package topics. ([f81b833a](https://github.com/davidmigloz/langchain_dart/commit/f81b833aae33e0a945ef4450da12344886224bae))
- **DOCS**: Add topics to pubspecs. ([8c1d6297](https://github.com/davidmigloz/langchain_dart/commit/8c1d62970710cc326fd5930101918aaf16b18f74))

## 0.0.6

- **FIX**: typecast exception when null publicationDate ([#148](https://github.com/davidmigloz/langchain_dart/issues/148)). ([d4afc131](https://github.com/davidmigloz/langchain_dart/commit/d4afc1315f7fc041a7730346942891bb966f8d14))
- **DOCS**: Update packages example. ([4f8488fc](https://github.com/davidmigloz/langchain_dart/commit/4f8488fcb324e31b9d8dece7d1999333d7982253))

## 0.0.5

- **DOCS**: Fix typos. ([282cfa24](https://github.com/davidmigloz/langchain_dart/commit/282cfa24caa7b91ce28db6b1997af4c2c3ecf3e4))
- **DOCS**: Update readme. ([b61eda5b](https://github.com/davidmigloz/langchain_dart/commit/b61eda5ba506b4602592511c6a9be1e7aae5bf57))

## 0.0.4

- **DOCS**: Fix API documentation errors ([#138](https://github.com/davidmigloz/langchain_dart/issues/138)). ([1aa38fce](https://github.com/davidmigloz/langchain_dart/commit/1aa38fce17eed7f325e7872d03096740256d57be))

## 0.0.3

- **REFACTOR**: Fix Dart 3.1.0 linter issues ([#125](https://github.com/davidmigloz/langchain_dart/issues/125)). ([cc32f3f1](https://github.com/davidmigloz/langchain_dart/commit/cc32f3f13240c28cf174a9dbffc7d61bc061f843))

## 0.0.2+1

- **FIX**: approximateNeighborsCount deserialization issue ([#120](https://github.com/davidmigloz/langchain_dart/issues/120)). ([f3381208](https://github.com/davidmigloz/langchain_dart/commit/f33812082191d3105d692f1d6bf461069df14750))
- **DOCS**: Update readme. ([81f67c5e](https://github.com/davidmigloz/langchain_dart/commit/81f67c5e2f5963df9756d3245dd263b2060af173))

## 0.0.2

- **FIX**: Expose index deployed indexes references ([#118](https://github.com/davidmigloz/langchain_dart/issues/118)). ([f3635f23](https://github.com/davidmigloz/langchain_dart/commit/f3635f23554b60c856a11aaea95881030a00315e))
- **FEAT**: Integrate Vertex AI Matching Engine vector store ([#103](https://github.com/davidmigloz/langchain_dart/issues/103)). ([289c3eef](https://github.com/davidmigloz/langchain_dart/commit/289c3eef722206ac9dea0c968c036ad3289d10be))
- **FEAT**: Support updating Matching Engine index ([#117](https://github.com/davidmigloz/langchain_dart/issues/117)). ([0ffd31fa](https://github.com/davidmigloz/langchain_dart/commit/0ffd31fa3a1f32bdcc6bf9a9fa2c5023a10b3687))
- **FEAT**: Add GCP Vertex AI Matching Engine client ([#116](https://github.com/davidmigloz/langchain_dart/issues/116)). ([2c1bbfcc](https://github.com/davidmigloz/langchain_dart/commit/2c1bbfcca22a4ddfb40bcb28e8ec8cbca865a9a5))

## 0.0.1

- **REFACTOR**: Move Vertex AI client to its own package ([#111](https://github.com/davidmigloz/langchain_dart/issues/111)). ([d8aea156](https://github.com/davidmigloz/langchain_dart/commit/d8aea15633f1a9fb0df35cf9cc44bbc93ad46cd8))
- **FEAT**: Integrate Google Vertex AI PaLM Embeddings ([#100](https://github.com/davidmigloz/langchain_dart/issues/100)). ([d777eccc](https://github.com/davidmigloz/langchain_dart/commit/d777eccc0c81c58b322f28e6e3c4a8763f3f84b7))
- **FEAT**: Integrate Google Vertex AI PaLM Chat Model ([#99](https://github.com/davidmigloz/langchain_dart/issues/99)). ([3897595d](https://github.com/davidmigloz/langchain_dart/commit/3897595db597d5957ef80ae7a1de35c5f41265b8))
- **FEAT**: Integrate Google Vertex AI PaLM Text model ([#98](https://github.com/davidmigloz/langchain_dart/issues/98)). ([b2746c23](https://github.com/davidmigloz/langchain_dart/commit/b2746c235d68045ba20afd1f2be7c24dcccb5f24))

## 0.0.1-dev.1

- Bootstrap package.
