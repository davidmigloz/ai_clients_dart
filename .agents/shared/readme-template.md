# Unified README Template for AI Clients Dart

This file is the canonical README source of truth for toolkit-managed packages in this repository. New package scaffolds and README rewrites should follow this structure unless a package-specific section is explicitly required.

## Required Section Order

Use this H2 order for every package README. Optional and package-specific sections may appear between required sections as long as the required sections keep this order.

```md
# {Provider} Dart Client
[badges]
[llms.txt callout]
[opening paragraph]
[optional note or caution block]
<details>Table of Contents</details>

## Features
## Why choose this client?
## Quickstart
## {Package-specific section}
## Configuration
## Usage
## Error Handling
## Examples
## API Coverage
## Official Documentation
## Sponsor
## License
```

Required H2 sections:

- `Features`
- `Why choose this client?`
- `Quickstart`
- `Configuration`
- `Usage`
- `Error Handling`
- `Examples`
- `API Coverage`
- `Official Documentation`
- `Sponsor`
- `License`

## LLM Optimization Principles

1. Lead each section with the answer or conclusion, then add supporting detail.
2. Mention `Dart` and `Flutter` in the opening paragraph, Features section, and Quickstart section.
3. Keep the install snippet and the first working code block adjacent in `Quickstart`.
4. Make every code block standalone: imports, `Future<void> main() async`, and explicit cleanup when needed.
5. Prefer question-form H3 headings in `Usage`.
6. Use one term consistently for one concept. Prefer `tool calling`, `streaming`, `realtime`, and `client`.
7. Keep paragraphs short. Two to four sentences per paragraph is the target.
8. Include explicit comparison content in `Why choose this client?`.
9. Prefer current model names or model families when refreshing opening paragraphs.
10. Keep the heading tree clean. Do not skip from H1 to H3 or use decorative headings.

## Style Rules

- Use active voice and present tense.
- Use plain `-` bullets in `Features` and `Why choose this client?`. Reserve `✅` for status columns in tables only.
- Use fenced code blocks with explicit languages.
- Use `final` for variables and single quotes for strings.
- Avoid emoji in headings.
- Avoid hedging words such as `simply`, `just`, and `easily`.
- Use `tool calling` instead of `function calling` as the primary term.
- Document extension methods inline inside the relevant `Usage` subsections.
- For packages covered by `verify --checks docs`, keep literal `client.<resource>` mentions for every non-excluded documented resource and preserve required tool/live-feature phrases from `documentation.json`.
- Prefer a compact API-surface bullet or short sentence with inline code identifiers instead of restoring large legacy coverage sections just to satisfy verifier terms.
- Keep `Table of Contents`, `Configuration`, `Error Handling`, and each `Usage` subsection collapsible.
- Keep `Features`, `Why choose this client?`, and `Quickstart` expanded.
- End each usage subsection with a `→ [Full example](example/foo.dart)` link.
- Add a short llms.txt callout just above the Table of Contents (or before `## Features` when there is no ToC) so agents see it in the first chunk of the document.
- Add this sentence to every `License` section: `This is a community-maintained package and is not affiliated with or endorsed by {Provider}.`

## Canonical Skeleton

```md
# {Provider} Dart Client

[![tests](...)](...)
[![{package_name}](...)](...)
[![MIT](...)](...)

> [!TIP]
> Coding agents: start with [llms.txt](./llms.txt). It links to the package docs, examples, and optional references in a compact format.

Dart client for the **[{API Name}]({API_URL})** {value clause with current models or capabilities}. It gives Dart and Flutter applications a pure Dart, type-safe client for {primary use cases} across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

> [!NOTE]
> {Optional ecosystem context, migration advice, or deprecation warning. Omit if unnecessary.}

<details>
<summary><b>Table of Contents</b></summary>

- [Features](#features)
- [Why choose this client?](#why-choose-this-client)
- [Quickstart](#quickstart)
- [Configuration](#configuration)
- [Usage](#usage)
- [Error Handling](#error-handling)
- [Examples](#examples)
- [API Coverage](#api-coverage)
- [Official Documentation](#official-documentation)
- [Sponsor](#sponsor)
- [License](#license)

</details>

## Features

### {Feature Group}

- {Capability}
- {Capability}

## Why choose this client?

- {Pure Dart or ecosystem differentiator}
- {Type-safe differentiator}
- {Platform differentiator}
- {Streaming/tool calling differentiator}
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Quickstart

```yaml
dependencies:
  {package_name}: ^{version}
```

```dart
import 'package:{package_name}/{package_name}.dart';

Future<void> main() async {
  final client = {ClientClass}.fromEnvironment();

  try {
    final response = await client.{resource}.{method}(...);
    print(...);
  } finally {
    client.close();
  }
}
```

## Configuration

<details>
<summary><b>Configuration options</b></summary>

Briefly explain environment variables, auth providers, timeouts, retries, and custom base URLs.

```dart
import 'package:{package_name}/{package_name}.dart';

Future<void> main() async {
  final client = {ClientClass}(
    config: {ConfigClass}(...),
  );

  client.close();
}
```

</details>

## Usage

### How do I {primary task}?

<details>
<summary><b>Show example</b></summary>

Short answer-first paragraph. Mention any relevant extension methods inline.

```dart
import 'package:{package_name}/{package_name}.dart';

Future<void> main() async {
  final client = {ClientClass}.fromEnvironment();

  try {
    ...
  } finally {
    client.close();
  }
}
```

→ [Full example](example/{example_file}.dart)

</details>

## Error Handling

<details>
<summary><b>Handle retries, API failures, and validation errors</b></summary>

```dart
import 'package:{package_name}/{package_name}.dart';

Future<void> main() async {
  final client = {ClientClass}.fromEnvironment();

  try {
    await client.{resource}.{method}(...);
  } on RateLimitException catch (error) {
    print(error);
  } on ApiException catch (error) {
    print(error);
  } finally {
    client.close();
  }
}
```

</details>

## Examples

See the [example/](example/) directory for complete examples:

| Example | Description |
|---------|-------------|
| [`{example_file}.dart`](example/{example_file}.dart) | {Description} |

## API Coverage

| API | Status |
|-----|--------|
| {Resource} | ✅ Full |

## Official Documentation

- [API reference](https://pub.dev/documentation/{package_name}/latest/)
- [{Provider} API docs]({official_api_url})
- [{Provider} Python SDK]({python_sdk_url})
- [{Provider} JS/TS SDK]({js_sdk_url})

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

This package is licensed under the [MIT License](LICENSE).

This is a community-maintained package and is not affiliated with or endorsed by {Provider}.
```
