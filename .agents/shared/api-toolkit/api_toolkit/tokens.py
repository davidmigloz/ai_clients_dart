from __future__ import annotations

import functools
from typing import Any


@functools.lru_cache(maxsize=1)
def _get_encoder() -> Any:
    try:
        import tiktoken
    except ImportError as exc:  # pragma: no cover - import guard
        raise RuntimeError(
            "tiktoken is required for llms.txt generation. "
            "Install toolkit dependencies via: "
            "pip install -r .agents/shared/api-toolkit/requirements.txt"
        ) from exc
    return tiktoken.get_encoding("o200k_base")


def count_tokens(text: str) -> int:
    if not text:
        return 0
    return len(_get_encoder().encode(text))


def format_token_count(count: int) -> str:
    if count >= 1000:
        value = count / 1000
        if value >= 100:
            return f"~{round(value)}k"
        return f"~{value:.1f}k".replace(".0k", "k")
    return f"~{count}"
